#!/usr/bin/env python3
"""
Security Sentinel agent.

Executes the ClamAV scan, inspects gateway configs for Zero-Trust signals, and
captures incidents in server-changelog.md.
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


class SecuritySentinelAgent(BaseAgent):
    """Security watchdog coordinating ClamAV and gateway posture."""

    def __init__(self, name: str, config: Dict[str, object]) -> None:
        super().__init__(name, config)
        self.repo_root = utils.REPO_ROOT
        self.kong_config = utils.resolve_repo_path("services", "kong", "kong.yml")
        self.traefik_config = utils.resolve_repo_path("traefik", "traefik.yml")

    def build_arg_parser(self) -> argparse.ArgumentParser:
        parser = super().build_arg_parser()
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Print security commands without running them.",
        )
        parser.add_argument(
            "--host",
            help="Host override for allowed_hosts enforcement.",
        )
        return parser

    def handle(self, parser: argparse.ArgumentParser, args: argparse.Namespace) -> int:
        utils.enforce_allowed_host(self.name, self.allowed_hosts, args.host)
        findings: List[str] = []

        result = utils.run_command(
            [
                "docker",
                "exec",
                "clamav",
                "clamscan",
                "-r",
                "/data",
                "--log=/var/log/clamav/nightly.log",
            ],
            cwd=self.repo_root,
            dry_run=args.dry_run,
            stream=True,
        )
        if not result.ok:
            findings.append("ClamAV scan reported issues (check container logs).")

        security_checks = self._inspect_gateway_configs()
        findings.extend(security_checks)

        if findings:
            utils.log_server_event(
                "security-sentinel",
                "incidents detected:",
                dry_run=args.dry_run,
                details=findings,
            )
            for line in findings:
                print(f"[ALERT] {line}")
            return 1

        utils.log_server_event(
            "security-sentinel",
            "checks passed.",
            dry_run=args.dry_run,
        )
        print("Security checks completed with no findings.")
        return 0

    # -------------------------------------------------------------- internals
    def _inspect_gateway_configs(self) -> List[str]:
        issues: List[str] = []
        if self.kong_config.exists():
            text = utils.read_text(self.kong_config)
            if "rate-limiting" not in text:
                issues.append("Kong config missing rate-limiting plugin.")
            if "access" not in text.lower():
                issues.append("Kong config missing Access policy references.")
        else:
            issues.append("Kong config not found.")

        if self.traefik_config.exists():
            text = utils.read_text(self.traefik_config)
            if "middlewares" not in text:
                issues.append("Traefik config missing middleware definitions.")
        else:
            issues.append("Traefik config not found.")
        return issues


def main() -> int:  # pragma: no cover
    agent = SecuritySentinelAgent(
        "security-sentinel",
        config={"description": "Run ClamAV scan and verify Zero-Trust posture."},
    )
    return agent.run()


if __name__ == "__main__":
    raise SystemExit(main())
