#!/usr/bin/env python3
"""
Status agent implementation.
"""

from __future__ import annotations

import argparse
import datetime as dt
import importlib.util
import os
import subprocess
import sys
from pathlib import Path
from typing import Dict, Sequence

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


class StatusAgent(BaseAgent):
    """Run scripts/status.sh and scripts/health-check.sh."""

    def __init__(self, name: str, config: Dict[str, str]) -> None:
        super().__init__(name, config)
        self.repo_root = Path(__file__).resolve().parents[2]
        self.infra_root = self._detect_infra_root(config)
        self.changelog_path = self.infra_root / "server-changelog.md"

    def build_arg_parser(self) -> argparse.ArgumentParser:
        parser = super().build_arg_parser()
        parser.add_argument(
            "--skip-health",
            action="store_true",
            help="Skip scripts/health-check.sh.",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Print commands without executing.",
        )
        return parser

    def handle(self, parser: argparse.ArgumentParser, args: argparse.Namespace) -> int:
        commands = [["./scripts/status.sh"]]
        if not args.skip_health:
            commands.append(["./scripts/health-check.sh"])

        if args.dry_run:
            for cmd in commands:
                print("DRY RUN:", " ".join(cmd))
            return 0

        rc = 0
        for cmd in commands:
            result = subprocess.run(cmd, cwd=self.repo_root, check=False)
            if result.returncode != 0:
                rc = result.returncode
                break

        status = "success" if rc == 0 else f"failure rc={rc}"
        detail = "status-only" if args.skip_health else "status+health"
        self._log_event(f"{detail} -> {status}")

        if rc != 0:
            parser.exit(rc)
        return 0

    # ------------------------------------------------------------------ helpers
    def _detect_infra_root(self, config: Dict[str, str]) -> Path:
        candidates = [
            config.get("infra_root"),
            config.get("fallback_infra_root"),
            "~/infra",
        ]
        for candidate in candidates:
            if not candidate:
                continue
            path = self._expand_path(candidate)
            if path.exists():
                return path
        return self.repo_root

    def _expand_path(self, value: str) -> Path:
        expanded = os.path.expandvars(os.path.expanduser(value))
        path = Path(expanded)
        if path.is_absolute():
            return path.resolve()
        return (self.repo_root / path).resolve()

    def _log_event(self, message: str) -> None:
        timestamp = dt.datetime.now(dt.timezone.utc).isoformat()
        entry = f"{timestamp} - status-agent - {message}"
        self.changelog_path.parent.mkdir(parents=True, exist_ok=True)
        with self.changelog_path.open("a", encoding="utf-8") as fh:
            fh.write(entry + "\n")


def main(argv: Sequence[str] | None = None) -> int:
    agent = StatusAgent(
        "status-agent",
        config={
            "description": "Run scripts/status.sh and scripts/health-check.sh.",
        },
    )
    return agent.run(argv)


if __name__ == "__main__":
    raise SystemExit(main())


