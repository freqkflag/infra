#!/usr/bin/env python3
"""
Logger agent implementation.
"""

from __future__ import annotations

import argparse
import importlib.util
import datetime as dt
import glob
import json
import socket
import sys
import os
from pathlib import Path
from typing import Dict, Iterable, List, Sequence

BASE_MODULE_PATH = Path(__file__).resolve().parent / "base.py"
BASE_MODULE_ID = "cursor_agent_base"

if BASE_MODULE_ID in sys.modules:
    _base_module = sys.modules[BASE_MODULE_ID]
else:
    _base_spec = importlib.util.spec_from_file_location(
        BASE_MODULE_ID, BASE_MODULE_PATH
    )
    if _base_spec is None or _base_spec.loader is None:
        raise RuntimeError(f"unable to load base agent from {BASE_MODULE_PATH}")
    _base_module = importlib.util.module_from_spec(_base_spec)
    sys.modules[BASE_MODULE_ID] = _base_module
    _base_spec.loader.exec_module(_base_module)
BaseAgent = getattr(_base_module, "BaseAgent")


class LoggerAgent(BaseAgent):
    """Append infra change logs into a consolidated CHANGE.log."""

    HOST_ALIAS_MAP = {
        "home.macmini": "mac",
        "macmini": "mac",
        "twist3dkink": "mac",
        "twist3dkink.online": "mac",
        "vps.host": "vps",
        "freqkflag": "vps",
        "freqkflag.co": "vps",
    }

    def __init__(self, name: str, config: Dict[str, str]) -> None:
        super().__init__(name, config)

        self.repo_root = Path(__file__).resolve().parents[2]
        infra_setting = config.get("infra_root", "~/infra")
        infra_candidate = self._expand_to_path(infra_setting, base=self.repo_root)

        if not infra_candidate.exists():
            fallback_setting = config.get("fallback_infra_root")
            if fallback_setting:
                fallback_candidate = self._expand_to_path(
                    fallback_setting, base=self.repo_root
                )
                if fallback_candidate.exists():
                    infra_candidate = fallback_candidate
            if not infra_candidate.exists() and self.repo_root.exists():
                infra_candidate = self.repo_root

        self.infra_root = infra_candidate

        target_setting = config.get("target_log", "CHANGE.log")
        self.target_log = self._resolve_with_root(target_setting)

        state_setting = config.get(
            "state_file", ".state/logger-agent.json"
        )
        self.state_file = self._resolve_with_root(state_setting)

        source_items = config.get("source_logs", [])
        direct: List[Path] = []
        patterns: List[str] = []
        for item in source_items:
            if any(char in item for char in "*?[]"):
                patterns.append(self._expand_pattern(item))
            else:
                direct.append(self._resolve_with_root(item))

        self.direct_sources = direct
        self.glob_patterns = patterns

    # ------------------------------------------------------------------ helpers
    @staticmethod
    def _expand_to_path(value: str, base: Path) -> Path:
        expanded = Path(os.path.expandvars(os.path.expanduser(value)))
        if expanded.is_absolute():
            return expanded
        return (base / expanded).resolve()

    def _resolve_with_root(self, value: str) -> Path:
        expanded = Path(os.path.expandvars(os.path.expanduser(value)))
        if expanded.is_absolute():
            return expanded
        return (self.infra_root / expanded).resolve()

    def _expand_pattern(self, pattern: str) -> str:
        expanded = os.path.expandvars(os.path.expanduser(pattern))
        if os.path.isabs(expanded):
            return expanded
        return str((self.infra_root / expanded).resolve())

    def build_arg_parser(self) -> argparse.ArgumentParser:
        parser = super().build_arg_parser()
        parser.add_argument(
            "--host",
            help="Host label override. Defaults to LOGGER_AGENT_HOST / AGENT_HOST / autodetect.",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Print planned CHANGE.log entries without writing files.",
        )
        return parser

    # ----------------------------------------------------------------- lifecycle
    def handle(self, parser: argparse.ArgumentParser, args: argparse.Namespace) -> int:
        if not self.infra_root.exists():
            parser.error(f"infra root not found at {self.infra_root}")

        host_label = self.resolve_host_label(args.host)
        state = self.load_state()
        blocks: List[str] = []
        any_updates = False

        for path in self.source_paths():
            try:
                data = self.read_new_bytes(path, state)
            except FileNotFoundError:
                continue

            if not data:
                continue

            try:
                payload = data.decode("utf-8")
            except UnicodeDecodeError:
                payload = data.decode("utf-8", errors="replace")

            block = self.build_block(host_label, path, payload)
            if block:
                blocks.append(block)
                any_updates = True

        if any_updates:
            self.append_blocks(blocks, dry_run=args.dry_run)

        if args.dry_run:
            if not any_updates:
                sys.stdout.write("No new log entries detected.\n")
        else:
            self.save_state(state)

        return 0

    # ------------------------------------------------------------------ behavior
    def resolve_host_label(self, cli_host: str | None) -> str:
        if cli_host:
            return cli_host

        env_host = os.environ.get("LOGGER_AGENT_HOST") or os.environ.get("AGENT_HOST")
        if env_host:
            return env_host

        hostname = socket.gethostname().lower()
        fqdn = socket.getfqdn().lower()

        for candidate in (hostname, fqdn):
            for key, alias in self.HOST_ALIAS_MAP.items():
                if key in candidate:
                    return alias

        return hostname

    def load_state(self) -> Dict[str, Dict[str, int]]:
        if not self.state_file.exists():
            return {}
        try:
            with self.state_file.open("r", encoding="utf-8") as fh:
                return json.load(fh)
        except (json.JSONDecodeError, OSError):
            return {}

    def save_state(self, state: Dict[str, Dict[str, int]]) -> None:
        self.ensure_parent(self.state_file)
        with self.state_file.open("w", encoding="utf-8") as fh:
            json.dump(state, fh, indent=2, sort_keys=True)

    def source_paths(self) -> List[Path]:
        paths: List[Path] = []

        for src in self.direct_sources:
            if src.exists():
                resolved = src.resolve()
                if resolved not in paths:
                    paths.append(resolved)

        for pattern in self.glob_patterns:
            for match in glob.glob(pattern, recursive=True):
                path = Path(match)
                if not path.is_file():
                    continue
                resolved = path.resolve()
                if resolved == self.target_log:
                    continue
                if resolved not in paths:
                    paths.append(resolved)

        return sorted(paths)

    @staticmethod
    def inode_id(path: Path) -> str:
        stat = path.stat()
        return f"{stat.st_ino}:{stat.st_dev}"

    def read_new_bytes(
        self, path: Path, state: Dict[str, Dict[str, int]]
    ) -> bytes:
        record = state.get(str(path))
        current_inode = self.inode_id(path)
        offset = 0

        if record and record.get("inode") == current_inode:
            offset = int(record.get("offset", 0))
            current_size = path.stat().st_size
            if offset > current_size:
                offset = 0
        else:
            offset = 0

        with path.open("rb") as fh:
            fh.seek(offset)
            data = fh.read()

        state[str(path)] = {"inode": current_inode, "offset": path.stat().st_size}
        return data

    def build_block(self, host: str, source: Path, payload: str) -> str:
        timestamp = dt.datetime.now(dt.timezone.utc).isoformat()
        header = f"# {timestamp} — {host} — {self.name}"
        subheader = f"## source: {source}"
        body = payload.rstrip("\n")
        if not body:
            return ""
        return "\n".join([header, subheader, body, ""])

    def append_blocks(self, blocks: Iterable[str], dry_run: bool = False) -> None:
        rendered = [block for block in blocks if block]
        if not rendered:
            return

        output = (
            "\n\n".join(block.strip("\n") for block in rendered).rstrip() + "\n"
        )

        if dry_run:
            sys.stdout.write(output)
            return

        self.ensure_parent(self.target_log)
        needs_leading_newline = (
            self.target_log.exists() and self.target_log.stat().st_size > 0
        )

        with self.target_log.open("a", encoding="utf-8") as fh:
            if needs_leading_newline:
                fh.write("\n")
            fh.write(output)


def main(argv: Sequence[str] | None = None) -> int:
    agent = LoggerAgent(
        "logger-agent",
        config={
            "description": "Merge infra change logs into CHANGE.log (standalone).",
            "source_logs": [
                "~/infra/server-changelog.md",
                "~/infra/**/*.log",
            ],
        },
    )
    return agent.run(argv)


if __name__ == "__main__":
    raise SystemExit(main())


