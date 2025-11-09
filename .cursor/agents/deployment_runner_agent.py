#!/usr/bin/env python3
"""
Deployment Runner agent.

Wraps the preflight/deploy/status/health scripts under Infisical while ensuring
the shared ``edge`` network exists and triggering rollback on failures.
"""

from __future__ import annotations

import argparse
import importlib.util
import sys
from pathlib import Path
from typing import Dict, List, Tuple

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


class DeploymentRunnerAgent(BaseAgent):
    """Execute the deployment pipeline end-to-end."""

    def __init__(self, name: str, config: Dict[str, object]) -> None:
        super().__init__(name, config)
        self.repo_root = utils.REPO_ROOT
        self.default_env = str(config.get("default_env", "production"))

    # ---------------------------------------------------------------- parser
    def build_arg_parser(self) -> argparse.ArgumentParser:
        parser = super().build_arg_parser()
        parser.add_argument(
            "--target",
            required=True,
            help="Deployment target (passed to scripts/deploy.ah).",
        )
        parser.add_argument(
            "--env",
            default=self.default_env,
            help="Infisical environment used for wrapper commands.",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Print steps without executing scripts.",
        )
        parser.add_argument(
            "--host",
            help="Host override for allowed_hosts enforcement.",
        )
        return parser

    # ---------------------------------------------------------------- handle
    def handle(self, parser: argparse.ArgumentParser, args: argparse.Namespace) -> int:
        utils.enforce_allowed_host(self.name, self.allowed_hosts, args.host)
        env = args.env or self.default_env
        self._ensure_edge_network(args.dry_run)

        steps: List[Tuple[str, List[str]]] = [
            ("preflight", ["./scripts/preflight.sh"]),
            ("deploy", ["./scripts/deploy.ah", args.target]),
            ("status", ["./scripts/status.sh"]),
            ("health", ["./scripts/health-check.sh"]),
        ]

        for label, command in steps:
            result = utils.run_infisical(
                env,
                command,
                cwd=self.repo_root,
                dry_run=args.dry_run,
                stream=True,
            )
            if not result.ok:
                if label == "health" and not args.dry_run:
                    self._rollback(args.dry_run, env)
                utils.log_server_event(
                    "deployment-runner",
                    f"step '{label}' failed rc={result.returncode}",
                    dry_run=args.dry_run,
                )
                return result.returncode

        utils.log_server_event(
            "deployment-runner",
            f"target {args.target} succeeded.",
            dry_run=args.dry_run,
        )
        return 0

    # -------------------------------------------------------------- internals
    def _ensure_edge_network(self, dry_run: bool) -> None:
        result = utils.run_command(
            ["docker", "network", "ls", "--format", "{{.Name}}"],
            cwd=self.repo_root,
            dry_run=dry_run,
        )
        if dry_run:
            return
        networks = {line.strip() for line in result.stdout.splitlines()}
        if "edge" in networks:
            return
        utils.run_command(
            ["docker", "network", "create", "edge"],
            cwd=self.repo_root,
            dry_run=dry_run,
            check=True,
        )

    def _rollback(self, dry_run: bool, env: str) -> None:
        utils.run_infisical(
            env,
            ["./scripts/teardown.sh"],
            cwd=self.repo_root,
            dry_run=dry_run,
            stream=True,
        )


def main() -> int:  # pragma: no cover
    agent = DeploymentRunnerAgent(
        "deployment-runner",
        config={"description": "Execute preflight/deploy/status/health scripts."},
    )
    return agent.run()


if __name__ == "__main__":
    raise SystemExit(main())
