#!/usr/bin/env python3
"""
Automator agent.

Executes n8n/Node-RED workflows via Infisical and emits webhook events per the
automation guardrails.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import os
import sys
import urllib.error
import urllib.request
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


class AutomatorAgent(BaseAgent):
    """n8n workflow trigger with webhook emissions."""

    def __init__(self, name: str, config: Dict[str, object]) -> None:
        super().__init__(name, config)
        self.repo_root = utils.REPO_ROOT
        self.default_env = str(config.get("default_env", "production"))
        self.workflows = config.get(
            "workflows",
            [
                "daily-maintenance",
                "post-recovery-audit",
            ],
        )

    def build_arg_parser(self) -> argparse.ArgumentParser:
        parser = super().build_arg_parser()
        parser.add_argument(
            "--workflow",
            choices=self.workflows,
            default=self.workflows[0],
            help="Workflow to trigger via n8n execute.",
        )
        parser.add_argument(
            "--env",
            default=self.default_env,
            help="Infisical environment for workflow secrets.",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Preview workflow execution and webhook payload.",
        )
        parser.add_argument(
            "--host",
            help="Host override for allowed_hosts enforcement.",
        )
        return parser

    def handle(self, parser: argparse.ArgumentParser, args: argparse.Namespace) -> int:
        utils.enforce_allowed_host(self.name, self.allowed_hosts, args.host)
        command = [
            "n8n",
            "execute",
            "--workflow",
            args.workflow,
        ]
        result = utils.run_infisical(
            args.env,
            command,
            cwd=self.repo_root,
            dry_run=args.dry_run,
            stream=True,
        )
        status = "success" if result.ok else f"failure:{result.returncode}"
        payload = {
            "agent": self.name,
            "action": args.workflow,
            "status": status,
            "timestamp": utils.timestamp(),
            "details": {"env": args.env},
        }
        self._emit_webhook(payload, args.dry_run)

        utils.log_server_event(
            "automator", f"{args.workflow} -> {status}", dry_run=args.dry_run
        )
        return 0 if result.ok else result.returncode

    def _emit_webhook(self, payload: Dict[str, object], dry_run: bool) -> None:
        url = os.environ.get("INFISICAL_WEBHOOK_URL")
        if not url:
            print("INFISICAL_WEBHOOK_URL not set; skipping webhook.")
            return
        data = json.dumps(payload).encode("utf-8")
        if dry_run:
            print(f"DRY RUN webhook -> {url}: {payload}")
            return
        request = urllib.request.Request(
            url,
            data=data,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        try:
            with urllib.request.urlopen(request, timeout=15) as response:
                response.read()
        except urllib.error.URLError as exc:
            print(f"[WARN] webhook dispatch failed: {exc}")


def main() -> int:  # pragma: no cover
    agent = AutomatorAgent(
        "automator",
        config={"description": "Trigger n8n workflows and emit webhook events."},
    )
    return agent.run()


if __name__ == "__main__":
    raise SystemExit(main())
