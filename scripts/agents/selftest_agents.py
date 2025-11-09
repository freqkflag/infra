#!/usr/bin/env python3
"""
Smoke-check loader for all Cursor automation agents.

Ensures every registry entry can be instantiated, catching import errors early.
"""

from __future__ import annotations

import importlib.util
import json
from pathlib import Path
from typing import Any, Dict

REPO_ROOT = Path(__file__).resolve().parents[2]
REGISTRY_PATH = REPO_ROOT / ".cursor" / "agents" / "registry.json"
RUNNER_PATH = REPO_ROOT / ".cursor" / "agents" / "runner.py"


def load_runner_module():
    spec = importlib.util.spec_from_file_location("cursor_agent_runner", RUNNER_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"unable to load runner at {RUNNER_PATH}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main() -> int:
    registry: Dict[str, Any] = json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))
    runner = load_runner_module()
    instances = []
    for name in registry.get("agents", {}):
        agent = runner.instantiate_agent(name, registry)
        instances.append(agent)
        print(f"[ok] {name} -> {agent.__class__.__name__}")
    print(f"{len(instances)} agents instantiated successfully.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
