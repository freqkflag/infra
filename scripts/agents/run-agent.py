#!/usr/bin/env python3
"""
Wrapper for running Cursor agents from the infra scripts directory.
"""

from __future__ import annotations

import sys

import importlib.util
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
RUNNER_PATH = REPO_ROOT / ".cursor" / "agents" / "runner.py"

spec = importlib.util.spec_from_file_location("cursor_agent_runner", RUNNER_PATH)
if spec is None or spec.loader is None:
    raise RuntimeError(f"unable to load Cursor runner from {RUNNER_PATH}")
runner_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner_module)
main = runner_module.main


if __name__ == "__main__":
    raise SystemExit(main())


