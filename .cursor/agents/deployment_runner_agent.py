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
from typing import Dict, List, Optional, Tuple

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
            ("health", ["./scripts/health-check.sh", args.target]),
        ]

        step_meta = {
            "preflight": {"event": "preflight-check", "mutates": False},
            "deploy": {"event": "deploy-run", "mutates": True},
            "status": {"event": "status-check", "mutates": False},
            "health": {"event": "health-check", "mutates": False},
        }

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
                self._emit_webhook(
                    step_meta[label]["event"],
                    status="error",
                    error=f"step '{label}' failed rc={result.returncode}",
                    details={"command": command, "returncode": result.returncode},
                    dry_run=args.dry_run,
                )
                utils.log_server_event(
                    "deployment-runner",
                    f"step '{label}' failed rc={result.returncode}",
                    dry_run=args.dry_run,
                )
                return result.returncode
            else:
                meta = step_meta[label]
                if meta["mutates"]:
                    self._emit_webhook(
                        meta["event"],
                        status="success",
                        details={"command": command, "returncode": result.returncode},
                        dry_run=args.dry_run,
                    )
                else:
                    self._emit_webhook(
                        meta["event"],
                        status="noop",
                        details={"command": command, "returncode": result.returncode},
                        dry_run=args.dry_run,
                    )

        utils.log_server_event(
            "deployment-runner",
            f"target {args.target} succeeded.",
            dry_run=args.dry_run,
        )
        self._emit_webhook(
            "deployment-complete",
            status="success",
            details={"target": args.target},
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
            self._emit_webhook(
                "edge-network-check",
                status="noop",
                details={"command": result.command, "returncode": result.returncode, "dry_run": True},
                dry_run=True,
            )
            return
        networks = {line.strip() for line in result.stdout.splitlines()}
        if "edge" in networks:
            self._emit_webhook(
                "edge-network-check",
                status="noop",
                details={"state": "exists"},
                dry_run=False,
            )
            return
        create_result = utils.run_command(
            ["docker", "network", "create", "edge"],
            cwd=self.repo_root,
            dry_run=dry_run,
            check=False,
        )
        if create_result.ok:
            self._emit_webhook(
                "edge-network-create",
                status="success",
                details={"command": create_result.command, "returncode": create_result.returncode},
                dry_run=dry_run,
            )
        else:
            self._emit_webhook(
                "edge-network-create",
                status="error",
                error=f"failed rc={create_result.returncode}",
                details={"command": create_result.command, "returncode": create_result.returncode},
                dry_run=dry_run,
            )
            raise SystemExit("failed to create edge network")

    def _rollback(self, dry_run: bool, env: str) -> None:
        result = utils.run_infisical(
            env,
            ["./scripts/teardown.sh"],
            cwd=self.repo_root,
            dry_run=dry_run,
            stream=True,
        )
        if result.ok:
            self._emit_webhook(
                "rollback",
                status="success",
                details={"command": ["./scripts/teardown.sh"], "returncode": result.returncode},
                dry_run=dry_run,
            )
        else:
            self._emit_webhook(
                "rollback",
                status="error",
                error=f"teardown failed rc={result.returncode}",
                details={"command": ["./scripts/teardown.sh"], "returncode": result.returncode},
                dry_run=dry_run,
            )

    def _emit_webhook(
        self,
        event: str,
        *,
        status: str,
        details: Optional[Dict[str, object]] = None,
        error: Optional[str] = None,
        dry_run: bool = False,
    ) -> None:
        payload: Dict[str, object] = {"agent": self.name, "event": event, "status": status}
        if details is not None:
            payload["details"] = details
        if error is not None:
            payload["error"] = error
        utils.post_webhook(payload, dry_run=dry_run)


def main() -> int:  # pragma: no cover
    agent = DeploymentRunnerAgent(
        "deployment-runner",
        config={"description": "Execute preflight/deploy/status/health scripts."},
    )
    return agent.run()


if __name__ == "__main__":
    raise SystemExit(main())
