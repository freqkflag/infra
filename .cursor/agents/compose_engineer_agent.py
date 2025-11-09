#!/usr/bin/env python3
"""
Compose Engineer agent.

Validates service compose fragments, orchestrator bundles, and node manifests by
running ``docker compose config`` under Infisical and ensuring Traefik/health
requirements are present.
"""

from __future__ import annotations

import argparse
import importlib.util
import sys
from pathlib import Path
from typing import Dict, List, Sequence

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


class ComposeEngineerAgent(BaseAgent):
    """Lint compose files and verify foundational labels/networks."""

    def __init__(self, name: str, config: Dict[str, object]) -> None:
        super().__init__(name, config)
        self.repo_root = utils.REPO_ROOT
        self.default_env = str(config.get("default_env", "production"))

    # ---------------------------------------------------------------- parser
    def build_arg_parser(self) -> argparse.ArgumentParser:
        parser = super().build_arg_parser()
        parser.add_argument(
            "--env",
            default=self.default_env,
            help="Infisical environment passed to docker compose config.",
        )
        parser.add_argument(
            "--files",
            nargs="*",
            help="Specific compose files to lint. Defaults to all managed manifests.",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Print commands without executing them.",
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
        compose_files = self._resolve_compose_files(args.files)

        issues: Dict[str, List[str]] = {}
        for compose_file in compose_files:
            file_issues = self._lint_file(compose_file, env, args.dry_run)
            if file_issues:
                issues[str(compose_file)] = file_issues

        status = (
            f"{len(compose_files)} files linted; {len(issues)} with warnings."
        )
        utils.log_server_event("compose-engineer", status, dry_run=args.dry_run)

        if issues:
            for path, warnings in issues.items():
                print(f"[WARN] {path}")
                for warning in warnings:
                    print(f"  - {warning}")
            return 1

        print(status)
        return 0

    # -------------------------------------------------------------- internals
    def _resolve_compose_files(self, requested: Sequence[str] | None) -> List[Path]:
        if requested:
            result = []
            for entry in requested:
                path = Path(entry)
                if not path.is_absolute():
                    path = self.repo_root / entry
                if not path.exists():
                    raise SystemExit(f"compose file not found: {entry}")
                result.append(path.resolve())
            return result
        return utils.list_compose_files()

    def _lint_file(self, compose_file: Path, env: str, dry_run: bool) -> List[str]:
        result = utils.run_infisical(
            env,
            ["docker", "compose", "-f", str(compose_file), "config"],
            cwd=compose_file.parent,
            dry_run=dry_run,
        )
        warnings: List[str] = []
        output = result.stdout

        if "edge" not in output:
            warnings.append("edge network not referenced in rendered config")
        if "healthcheck:" not in output:
            warnings.append("no healthcheck section detected")
        if "traefik.http." not in output and "traefik.enable" not in output:
            warnings.append("Traefik labels missing from config")
        return warnings


def main() -> int:  # pragma: no cover - manual helper
    agent = ComposeEngineerAgent(
        "compose-engineer",
        config={"description": "Lint compose manifests via docker compose config."},
    )
    return agent.run()


if __name__ == "__main__":
    raise SystemExit(main())
