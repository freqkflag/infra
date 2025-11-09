#!/usr/bin/env python3
"""
API Gatekeeper agent.

Validates Kong configuration, Cloudflare domain mappings, and triggers Kong
reloads under Infisical control.
"""

from __future__ import annotations

import argparse
import importlib.util
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


class APIGatekeeperAgent(BaseAgent):
    """Ensure Kong and Cloudflare Access data stay in sync."""

    def __init__(self, name: str, config: Dict[str, object]) -> None:
        super().__init__(name, config)
        self.repo_root = utils.REPO_ROOT
        self.default_env = str(config.get("default_env", "production"))
        self.kong_config = utils.resolve_repo_path("services", "kong", "kong.yml")
        self.env_template_dir = utils.resolve_repo_path("env", "templates")

    def build_arg_parser(self) -> argparse.ArgumentParser:
        parser = super().build_arg_parser()
        parser.add_argument(
            "--env",
            default=self.default_env,
            help="Infisical environment for Kong reload.",
        )
        parser.add_argument(
            "--skip-reload",
            action="store_true",
            help="Skip the Kong reload step (still validates configs).",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Report findings without executing commands.",
        )
        parser.add_argument(
            "--host",
            help="Host override for allowed_hosts enforcement.",
        )
        return parser

    def handle(self, parser: argparse.ArgumentParser, args: argparse.Namespace) -> int:
        utils.enforce_allowed_host(self.name, self.allowed_hosts, args.host)

        kong_findings = self._validate_kong()
        domain_findings = self._validate_domains()

        findings = kong_findings + domain_findings

        if not args.skip_reload:
            utils.run_infisical(
                args.env,
                ["docker", "exec", "kong", "kong", "reload"],
                cwd=self.repo_root,
                dry_run=args.dry_run,
                stream=True,
            )

        if findings:
            utils.log_server_event(
                "api-gatekeeper",
                "detected configuration gaps:",
                dry_run=args.dry_run,
                details=findings,
            )
            for entry in findings:
                print(f"[WARN] {entry}")
            return 1

        utils.log_server_event(
            "api-gatekeeper",
            "Kong + DNS checks passed.",
            dry_run=args.dry_run,
        )
        print("Kong configuration validated and reload triggered.")
        return 0

    # -------------------------------------------------------------- internals
    def _validate_kong(self) -> List[str]:
        if not self.kong_config.exists():
            return ["Kong config missing at services/kong/kong.yml."]
        data = utils.yaml_load_file(self.kong_config)
        findings: List[str] = []
        if "services" not in data:
            findings.append("Kong config missing 'services' definitions.")
        if "routes" not in data:
            findings.append("Kong config missing 'routes' definitions.")
        return findings

    def _validate_domains(self) -> List[str]:
        env_templates = utils.parse_env_templates(self.env_template_dir)
        defined_vars: Set[str] = {
            key for template in env_templates.values() for key in template
        }
        findings: List[str] = []
        for domains_file in sorted(
            utils.resolve_repo_path("nodes").rglob("domains.yml")
        ):
            data = utils.yaml_load_file(domains_file)
            domains = data.get("domains", []) if isinstance(data, dict) else []
            for entry in domains:
                env_key = entry.get("env")
                if env_key and env_key not in defined_vars:
                    rel = domains_file.relative_to(self.repo_root)
                    findings.append(f"{env_key} missing from env templates (see {rel}).")
        return findings


def main() -> int:  # pragma: no cover
    agent = APIGatekeeperAgent(
        "api-gatekeeper",
        config={"description": "Validate Kong routes and Cloudflare Access mappings."},
    )
    return agent.run()


if __name__ == "__main__":
    raise SystemExit(main())
