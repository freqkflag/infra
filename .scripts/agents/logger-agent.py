#!/usr/bin/env python3
"""
Compatibility wrapper for the logger-agent runtime.
"""

from __future__ import annotations

import sys

from cursor.agents.runner import main as runner_main


def main() -> int:
    extra_args = sys.argv[1:]
    runner_args = ["run", "logger-agent"]
    if extra_args:
        runner_args.append("--")
        runner_args.extend(extra_args)
    return runner_main(runner_args)


if __name__ == "__main__":
    raise SystemExit(main())