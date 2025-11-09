#!/usr/bin/env python3
"""
Release agent.

Packages approved work into a signed commit and optional push with assumption
annotations in the commit message.
"""

from __future__ import annotations

import argparse
import importlib.util
import sys
from pathlib import Path
from typing import Dict

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


class ReleaseAgent(BaseAgent):
    """Branch + commit orchestrator."""

    def __init__(self, name: str, config: Dict[str, object]) -> None:
        super().__init__(name, config)
        self.repo_root = utils.REPO_ROOT

    def build_arg_parser(self) -> argparse.ArgumentParser:
        parser = super().build_arg_parser()
        parser.add_argument("--scope", required=True, help="Commit scope prefix.")
        parser.add_argument("--summary", required=True, help="Commit summary.")
        parser.add_argument(
            "--assumption",
            default="no additional assumptions",
            help="Explicit assumption text appended to commit message.",
        )
        parser.add_argument(
            "--push",
            action="store_true",
            help="Push the current branch after committing.",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Preview git commands without executing.",
        )
        parser.add_argument(
            "--host",
            help="Host override for allowed_hosts enforcement.",
        )
        return parser

    def handle(self, parser: argparse.ArgumentParser, args: argparse.Namespace) -> int:
        utils.enforce_allowed_host(self.name, self.allowed_hosts, args.host)

        status = utils.run_command(
            ["git", "status", "--short"],
            cwd=self.repo_root,
            dry_run=args.dry_run,
        )
        if not args.dry_run and not status.stdout.strip():
            parser.error("nothing to commit; working tree clean.")

        commit_message = f"{args.scope}: {args.summary} (assumption: {args.assumption})"
        commit_result = utils.run_command(
            ["git", "commit", "-S", "-m", commit_message],
            cwd=self.repo_root,
            dry_run=args.dry_run,
            stream=True,
        )
        if not commit_result.ok:
            return commit_result.returncode

        if args.push:
            push_result = utils.run_command(
                ["git", "push"],
                cwd=self.repo_root,
                dry_run=args.dry_run,
                stream=True,
            )
            if not push_result.ok:
                return push_result.returncode

        if not args.dry_run:
            rev = utils.run_command(
                ["git", "rev-parse", "HEAD"],
                cwd=self.repo_root,
            )
            hash_line = rev.stdout.strip()
        else:
            hash_line = "<dry-run>"

        utils.log_server_event(
            "release-agent",
            f"committed {hash_line}",
            dry_run=args.dry_run,
        )
        print(f"release-agent ready: {hash_line}")
        return 0


def main() -> int:  # pragma: no cover
    agent = ReleaseAgent(
        "release-agent",
        config={"description": "Create signed commits with assumption annotations."},
    )
    return agent.run()


if __name__ == "__main__":
    raise SystemExit(main())
