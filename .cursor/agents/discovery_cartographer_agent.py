#!/usr/bin/env python3
"""
Discovery Cartographer agent.

Keeps an up-to-date inventory of Compose manifests, env templates, and repo
drift so downstream automation can plan work from PROJECT_PLAN.md.
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


class DiscoveryCartographerAgent(BaseAgent):
    """Inventory scanner for services, nodes, and env templates."""

    MARKER = "discovery-cartographer"

    def __init__(self, name: str, config: Dict[str, object]) -> None:
        super().__init__(name, config)
        self.repo_root = utils.REPO_ROOT
        self.template_dir = utils.resolve_repo_path("env", "templates")
        project_plan = config.get("project_plan", "PROJECT_PLAN.md")
        self.project_plan_path = self.repo_root / project_plan

    # ---------------------------------------------------------------- parser
    def build_arg_parser(self) -> argparse.ArgumentParser:
        parser = super().build_arg_parser()
        parser.add_argument(
            "--host",
            help="Host override; defaults to AGENT_HOST or system hostname.",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Collect inventory without writing docs.",
        )
        parser.add_argument(
            "--skip-plan",
            action="store_true",
            help="Skip updating PROJECT_PLAN.md marker block.",
        )
        return parser

    # ---------------------------------------------------------------- handle
    def handle(self, parser: argparse.ArgumentParser, args: argparse.Namespace) -> int:
        utils.enforce_allowed_host(self.name, self.allowed_hosts, args.host)
        compose_files = utils.list_compose_files()
        templates = utils.parse_env_templates(self.template_dir)
        drift = utils.git_status_paths("services", "nodes", "env/templates")
        env_vars = sorted(
            {key for template in templates.values() for key in template.keys()}
        )

        summary_lines = self._build_summary_lines(compose_files, env_vars, drift)

        if not args.skip_plan:
            changed = utils.update_marker_block(
                self.project_plan_path,
                self.MARKER,
                summary_lines,
            )
            if changed and args.dry_run:
                print(
                    f"[discovery-cartographer] PROJECT_PLAN.md would be updated (dry-run)."
                )

        utils.log_server_event(
            "discovery-cartographer",
            f"scanned {len(compose_files)} compose files; drift entries={len(drift)}",
            dry_run=args.dry_run,
        )
        self._emit_stdout(compose_files, env_vars, drift)
        return 0

    # -------------------------------------------------------------- internals
    def _build_summary_lines(
        self,
        compose_files: List[Path],
        env_vars: List[str],
        drift: List[str],
    ) -> List[str]:
        lines = [
            "",
            "### Discovery Cartographer Inventory",
            "",
            f"- Last run: {utils.timestamp()}",
            f"- Compose manifests tracked: {len(compose_files)}",
            f"- Known template variables: {len(env_vars)}",
            "",
            "**Drift Signals**",
        ]
        if drift:
            lines.extend(f"- {entry}" for entry in drift)
        else:
            lines.append("- None detected")
        lines.append("")
        return lines

    def _emit_stdout(
        self, compose_files: List[Path], env_vars: List[str], drift: List[str]
    ) -> None:
        print("== Compose Files ==")
        for path in compose_files:
            print(f"- {path.relative_to(self.repo_root)}")

        print("\n== Template Variables ==")
        chunk = ", ".join(env_vars) if env_vars else "<none>"
        print(chunk)

        print("\n== Drift ==")
        if drift:
            for entry in drift:
                print(f"- {entry}")
        else:
            print("No drift detected.")


def main() -> int:  # pragma: no cover - manual smoke helper
    agent = DiscoveryCartographerAgent(
        "discovery-cartographer",
        config={"description": "Inventory repo/services/env templates for drift."},
    )
    return agent.run()


if __name__ == "__main__":
    raise SystemExit(main())
