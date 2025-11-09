#!/usr/bin/env python3
"""
Review Agent (Reagents).

Final gate that inspects git diff output, renders compose configs, and verifies
validation evidence files before appending a Reviewed-by line to CHANGE.log.
"""

from __future__ import annotations

import argparse
import importlib.util
import sys
from pathlib import Path
from typing import Dict, List

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


class ReviewAgent(BaseAgent):
    """Diff + validation enforcement gate."""

    def __init__(self, name: str, config: Dict[str, object]) -> None:
        super().__init__(name, config)
        self.repo_root = utils.REPO_ROOT
        self.compose_file = utils.resolve_repo_path("compose.orchestrator.yml")

    def build_arg_parser(self) -> argparse.ArgumentParser:
        parser = super().build_arg_parser()
        parser.add_argument(
            "--validation",
            action="append",
            dest="validation_files",
            default=[],
            help="Path to a validation log file (repeatable).",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Review without writing Reviewed-by entry.",
        )
        parser.add_argument(
            "--host",
            help="Host override for allowed_hosts enforcement.",
        )
        return parser

    def handle(self, parser: argparse.ArgumentParser, args: argparse.Namespace) -> int:
        utils.enforce_allowed_host(self.name, self.allowed_hosts, args.host)
        diff_stat = utils.run_command(
            ["git", "diff", "--stat"],
            cwd=self.repo_root,
            dry_run=args.dry_run,
        )
        print(diff_stat.stdout)

        if self.compose_file.exists():
            utils.run_command(
                ["docker", "compose", "-f", str(self.compose_file), "config"],
                cwd=self.compose_file.parent,
                dry_run=args.dry_run,
                stream=True,
            )

        missing = self._validate_evidence(args.validation_files)
        if missing:
            for entry in missing:
                print(f"[ERROR] validation evidence missing or empty: {entry}")
            return 1

        reviewed_line = f"Reviewed-by: reagents {utils.timestamp()}"
        utils.append_lines(
            utils.DEFAULT_CHANGELOG_PATH, [reviewed_line], dry_run=args.dry_run
        )
        utils.log_server_event(
            "review-agent",
            "diff + validation review complete.",
            dry_run=args.dry_run,
        )
        print("Review completed and logged.")
        return 0

    def _validate_evidence(self, candidates: List[str]) -> List[str]:
        missing: List[str] = []
        for candidate in candidates:
            path = Path(candidate)
            if not path.is_absolute():
                path = self.repo_root / candidate
            if not path.exists():
                missing.append(str(path))
                continue
            if not path.read_text(encoding="utf-8").strip():
                missing.append(str(path))
        return missing
