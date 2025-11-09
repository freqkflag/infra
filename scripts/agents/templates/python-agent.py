#!/usr/bin/env python3
"""
Skeleton for a Python-based infra agent.
"""

from __future__ import annotations

from typing import Dict

import importlib.util
import sys
from pathlib import Path

BASE_MODULE_PATH = Path(__file__).resolve().parents[3] / ".cursor" / "agents" / "base.py"
BASE_MODULE_ID = "cursor_agent_base"

if BASE_MODULE_ID in sys.modules:
    _base_module = sys.modules[BASE_MODULE_ID]
else:
    _base_spec = importlib.util.spec_from_file_location(BASE_MODULE_ID, BASE_MODULE_PATH)
    if _base_spec is None or _base_spec.loader is None:
        raise RuntimeError(f"unable to load base agent from {BASE_MODULE_PATH}")
    _base_module = importlib.util.module_from_spec(_base_spec)
    sys.modules[BASE_MODULE_ID] = _base_module
    _base_spec.loader.exec_module(_base_module)

BaseAgent = getattr(_base_module, "BaseAgent")


class TemplateAgent(BaseAgent):
    """Describe the purpose of this agent."""

    def __init__(self, name: str, config: Dict[str, str]) -> None:
        super().__init__(name, config)

    def build_arg_parser(self):
        parser = super().build_arg_parser()
        # parser.add_argument("--example", help="Example flag")
        return parser

    def handle(self, parser, args):
        # TODO: implement agent logic
        return 0


def main() -> int:
    agent = TemplateAgent(
        "template-agent",
        config={
            "description": "Replace with agent description.",
        },
    )
    return agent.run()


if __name__ == "__main__":
    raise SystemExit(main())


