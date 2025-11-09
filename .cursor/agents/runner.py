#!/usr/bin/env python3
"""
Runner for Cursor automation agents.
"""

from __future__ import annotations

import argparse
import importlib
import importlib.util
import json
import sys
from pathlib import Path
from types import ModuleType
from typing import Any, Dict, Iterable, Optional, Sequence

REGISTRY_PATH = Path(__file__).resolve().parent / "registry.json"
REPO_ROOT = REGISTRY_PATH.parents[2]
BASE_MODULE_PATH = REGISTRY_PATH.parent / "base.py"
BASE_MODULE_ID = "cursor_agent_base"

if BASE_MODULE_ID in sys.modules:
    _base_module = sys.modules[BASE_MODULE_ID]
else:
    _base_spec = importlib.util.spec_from_file_location(
        BASE_MODULE_ID, BASE_MODULE_PATH
    )
    if _base_spec is None or _base_spec.loader is None:
        raise RuntimeError(f"unable to load base agent from {BASE_MODULE_PATH}")
    _base_module = importlib.util.module_from_spec(_base_spec)
    sys.modules[BASE_MODULE_ID] = _base_module
    _base_spec.loader.exec_module(_base_module)
BaseAgent = getattr(_base_module, "BaseAgent")


def load_registry() -> Dict[str, Any]:
    if not REGISTRY_PATH.exists():
        raise FileNotFoundError(f"registry not found at {REGISTRY_PATH}")
    with REGISTRY_PATH.open("r", encoding="utf-8") as fh:
        return json.load(fh)


def iter_agents(registry: Dict[str, Any]) -> Iterable[tuple[str, Dict[str, Any]]]:
    agents = registry.get("agents", {})
    for name, config in agents.items():
        yield name, config


def load_module(name: str, config: Dict[str, Any]) -> ModuleType:
    module_path = config.get("module_path")
    module_name = config.get("module")

    if module_path:
        path = Path(module_path)
        if not path.is_absolute():
            path = REPO_ROOT / path
        if not path.exists():
            raise FileNotFoundError(f"module path not found for agent '{name}': {path}")

        module_id = f"cursor_agent_{name.replace('-', '_')}"
        spec = importlib.util.spec_from_file_location(module_id, path)
        if spec is None or spec.loader is None:
            raise ImportError(f"unable to load spec for agent '{name}' from {path}")
        module = importlib.util.module_from_spec(spec)
        sys.modules[module_id] = module
        spec.loader.exec_module(module)
        return module

    if module_name:
        return importlib.import_module(module_name)

    raise ValueError(f"agent '{name}' missing module_path or module")


def instantiate_agent(name: str, registry: Dict[str, Any]) -> BaseAgent:
    agents = registry.get("agents", {})
    if name not in agents:
        raise KeyError(f"agent '{name}' not found in registry")

    config = agents[name]
    class_name = config.get("class", "Agent")
    module = load_module(name, config)
    cls = getattr(module, class_name)
    if not issubclass(cls, BaseAgent):
        raise TypeError(f"{class_name} is not a BaseAgent subclass")

    return cls(name=name, config=config)


def build_main_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="cursor-agent-runner",
        description="Cursor automation agent runner",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    list_parser = subparsers.add_parser("list", help="List registered agents")
    list_parser.set_defaults(handler=handle_list)

    describe_parser = subparsers.add_parser(
        "describe", help="Describe an agent from the registry"
    )
    describe_parser.add_argument("agent", help="Agent name to describe")
    describe_parser.add_argument(
        "--format",
        choices=("json", "text"),
        default="text",
        help="Output format",
    )
    describe_parser.set_defaults(handler=handle_describe)

    run_parser = subparsers.add_parser("run", help="Execute an agent")
    run_parser.add_argument("agent", help="Agent name to execute")
    run_parser.add_argument(
        "agent_args",
        nargs=argparse.REMAINDER,
        help="Arguments passed to the agent after '--'",
    )
    run_parser.set_defaults(handler=handle_run)

    return parser


def handle_list(args: argparse.Namespace, registry: Dict[str, Any]) -> int:
    for name, config in iter_agents(registry):
        summary = config.get("description", "").strip()
        print(f"{name}: {summary}")
    return 0


def handle_describe(args: argparse.Namespace, registry: Dict[str, Any]) -> int:
    name = args.agent
    agents = registry.get("agents", {})
    if name not in agents:
        raise SystemExit(f"agent '{name}' is not registered")

    config = agents[name]
    if args.format == "json":
        json.dump(config, sys.stdout, indent=2, sort_keys=True)
        print()
    else:
        lines = [
            f"name: {name}",
            f"description: {config.get('description', '')}",
        ]
        allowed = ", ".join(config.get("allowed_hosts", []))
        if allowed:
            lines.append(f"allowed_hosts: {allowed}")

        tags = ", ".join(config.get("tags", []))
        if tags:
            lines.append(f"tags: {tags}")

        outputs = config.get("outputs", [])
        if outputs:
            lines.append("outputs:")
            lines.extend(f"  - {item}" for item in outputs)

        state_file = config.get("state_file")
        if state_file:
            lines.append(f"state_file: {state_file}")

        print("\n".join(lines))
    return 0


def handle_run(args: argparse.Namespace, registry: Dict[str, Any]) -> int:
    agent_args = args.agent_args or []
    if agent_args and agent_args[0] == "--":
        agent_args = agent_args[1:]

    agent = instantiate_agent(args.agent, registry)
    return agent.run(agent_args)


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = build_main_parser()
    args = parser.parse_args(argv)
    registry = load_registry()
    handler = getattr(args, "handler", None)
    if handler is None:
        parser.error("no handler associated with command")
    return handler(args, registry)


if __name__ == "__main__":
    raise SystemExit(main())


