#!/usr/bin/env python3
"""
Secrets Steward agent.

Audits ${VAR} usage in compose/env templates and validates coverage via
``infisical export`` to prevent static credentials from landing in the repo.
"""

from __future__ import annotations

import argparse
import importlib.util
import re
import sys
from pathlib import Path
from typing import Dict, List, Set

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


STATIC_SECRET_PATTERN = re.compile(r"password\s*:\s*['\"]?([A-Za-z0-9_!@#$%^&*-]+)")


class SecretsStewardAgent(BaseAgent):
    """Ensure every compose variable is represented in Infisical + env templates."""

    def __init__(self, name: str, config: Dict[str, object]) -> None:
        super().__init__(name, config)
        self.repo_root = utils.REPO_ROOT
        self.template_dir = utils.resolve_repo_path("env", "templates")
        self.default_env = str(config.get("default_env", "production"))
        self.infisical_path = str(config.get("infisical_path", "prod/"))

    # ---------------------------------------------------------------- parser
    def build_arg_parser(self) -> argparse.ArgumentParser:
        parser = super().build_arg_parser()
        parser.add_argument(
            "--env",
            default=self.default_env,
            help="Infisical environment for exports.",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Report findings without executing Infisical commands.",
        )
        parser.add_argument(
            "--host",
            help="Host override for allowed_hosts enforcement.",
        )
        return parser

    # ---------------------------------------------------------------- handle
    def handle(self, parser: argparse.ArgumentParser, args: argparse.Namespace) -> int:
        utils.enforce_allowed_host(self.name, self.allowed_hosts, args.host)

        compose_files = utils.list_compose_files()
        compose_vars = self._collect_compose_vars(compose_files)

        templates = utils.parse_env_templates(self.template_dir)
        template_vars = {var for entries in templates.values() for var in entries}

        infisical_vars = self._export_infisical(args.env, args.dry_run)

        missing_templates = sorted(compose_vars - template_vars)
        missing_infisical = sorted(compose_vars - infisical_vars)
        static_secrets = self._scan_static_secrets(compose_files)

        report_lines = [
            f"Compose vars discovered: {len(compose_vars)}",
            f"Template coverage: {len(template_vars)}",
            f"Infisical coverage: {len(infisical_vars)}",
        ]

        if missing_templates:
            report_lines.append(f"Missing from templates: {', '.join(missing_templates)}")
        if missing_infisical:
            report_lines.append(
                f"Missing from Infisical ({args.env}): {', '.join(missing_infisical)}"
            )
        if static_secrets:
            report_lines.append(
                f"Static credential hints: {', '.join(static_secrets)}"
            )

        for line in report_lines:
            print(line)

        if missing_templates or missing_infisical or static_secrets:
            details: List[str] = []
            if missing_templates:
                details.append(f"Template gaps: {', '.join(missing_templates)}")
            if missing_infisical:
                details.append(
                    f"Infisical gaps ({args.env}): {', '.join(missing_infisical)}"
                )
            if static_secrets:
                details.append(
                    f"Static secrets suspected in: {', '.join(static_secrets)}"
                )
            utils.log_server_event(
                "secrets-steward",
                "detected configuration gaps.",
                dry_run=args.dry_run,
                details=details,
            )
        else:
            utils.log_server_event(
                "secrets-steward",
                "all variables accounted for.",
                dry_run=args.dry_run,
            )
        return 1 if (missing_templates or missing_infisical or static_secrets) else 0

    # -------------------------------------------------------------- internals
    def _collect_compose_vars(self, compose_files: List[Path]) -> Set[str]:
        vars_found: Set[str] = set()
        for compose_file in compose_files:
            text = utils.read_text(compose_file)
            vars_found.update(utils.extract_env_vars_from_text(text))
        return vars_found

    def _export_infisical(self, env: str, dry_run: bool) -> Set[str]:
        result = utils.run_infisical(
            env,
            [
                "infisical",
                "export",
                "--format",
                "yaml",
                "--path",
                self.infisical_path,
            ],
            cwd=self.repo_root,
            dry_run=dry_run,
        )
        if dry_run or not result.stdout:
            return set()
        data = utils.yaml_safe_load(result.stdout)
        vars_found: Set[str] = set()
        for key in data.keys():
            vars_found.add(str(key))
        return vars_found

    def _scan_static_secrets(self, compose_files: List[Path]) -> List[str]:
        flagged: List[str] = []
        for compose_file in compose_files:
            for match in STATIC_SECRET_PATTERN.finditer(utils.read_text(compose_file)):
                token = match.group(1)
                if "$" not in token:
                    flagged.append(str(compose_file.relative_to(self.repo_root)))
                    break
        return flagged


def main() -> int:  # pragma: no cover
    agent = SecretsStewardAgent(
        "secrets-steward",
        config={"description": "Audit compose env var coverage against Infisical."},
    )
    return agent.run()


if __name__ == "__main__":
    raise SystemExit(main())
