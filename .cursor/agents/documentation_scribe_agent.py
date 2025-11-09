#!/usr/bin/env python3
"""
Documentation & Audit Scribe agent.

Appends timestamped operational notes to the canonical docs and changelogs.
"""

from __future__ import annotations

import argparse
import importlib.util
import sys
from pathlib import Path
from typing import Dict, Iterable, List

BASE_MODULE_PATH = Path(__file__).resolve().parent / "base.py"
UTILS_MODULE_PATH = Path(__file__).resolve().parent / "utils.py"
BASE_MODULE_ID = "cursor_agent_base"
UTILS_MODULE_ID = "cursor_agent_utils"


def _load_module(module_id: str, path: Path):
    if module_id in sys.modules:
        return sys.modules[module_id]
    spec = importlib.util.spec_from_file_location(module_id, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"unable to load module {module_id} from {path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_id] = module
    spec.loader.exec_module(module)
    return module


BaseAgent = getattr(_load_module(BASE_MODULE_ID, BASE_MODULE_PATH), "BaseAgent")
utils = _load_module(UTILS_MODULE_ID, UTILS_MODULE_PATH)


class DocumentationScribeAgent(BaseAgent):
    """Record automation notes across README/PROJECT_PLAN/infra-build-plan."""

    DEFAULT_DOCS = ["README.md", "PROJECT_PLAN.md", "infra-build-plan.md"]

    def __init__(self, name: str, config: Dict[str, object]) -> None:
        super().__init__(name, config)
        self.repo_root = utils.REPO_ROOT
        self.doc_targets = [
            utils.resolve_repo_path(path) for path in config.get("docs", self.DEFAULT_DOCS)
        ]

    def build_arg_parser(self) -> argparse.ArgumentParser:
        parser = super().build_arg_parser()
        parser.add_argument(
            "--note",
            required=True,
            help="Summary of the documentation update.",
        )
        parser.add_argument(
            "--command",
            action="append",
            dest="commands",
            default=[],
            help="Command snippet to record (can be repeated).",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Print doc updates without writing files.",
        )
        parser.add_argument(
            "--host",
            help="Host override for allowed_hosts enforcement.",
        )
        return parser

    def handle(self, parser: argparse.ArgumentParser, args: argparse.Namespace) -> int:
        utils.enforce_allowed_host(self.name, self.allowed_hosts, args.host)
        timestamp = utils.timestamp()
        entry_lines = self._build_entry(timestamp, args.note, args.commands)

        for path in self.doc_targets:
            utils.append_lines(path, entry_lines, dry_run=args.dry_run)

        changelog_entry = [
            f"{timestamp} documentation-scribe {args.note}",
            *[f"  cmd: {cmd}" for cmd in args.commands],
        ]
        utils.append_lines(
            utils.DEFAULT_CHANGELOG_PATH, changelog_entry, dry_run=args.dry_run
        )
        utils.log_server_event(
            "documentation-scribe",
            args.note,
            dry_run=args.dry_run,
            details=[f"cmd: {cmd}" for cmd in args.commands],
        )
        print(f"Recorded documentation note across {len(self.doc_targets)} files.")
        return 0

    def _build_entry(self, timestamp: str, note: str, commands: Iterable[str]) -> List[str]:
        lines = [
            "",
            f"<!-- doc-scribe:start {timestamp} -->",
            f"- {timestamp}: {note}",
        ]
        for cmd in commands:
            lines.append(f"  - {cmd}")
        lines.append("<!-- doc-scribe:end -->")
        return lines


def main() -> int:  # pragma: no cover
    agent = DocumentationScribeAgent(
        "documentation-scribe",
        config={"description": "Append automation notes to docs and changelogs."},
    )
    return agent.run()


if __name__ == "__main__":
    raise SystemExit(main())
