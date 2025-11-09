#!/usr/bin/env python3
"""
Base primitives for Cursor automation agents.
"""

from __future__ import annotations

import abc
import argparse
import os
from pathlib import Path
from typing import Any, Dict, Iterable, Optional, Sequence


class BaseAgent(abc.ABC):
    """
    Abstract base class for all agents.

    Every agent receives its metadata configuration block from the registry and
    is responsible for implementing ``handle`` to perform its core logic.
    """

    def __init__(self, name: str, config: Dict[str, Any]) -> None:
        self.name = name
        self.config = config

    # --------------------------------------------------------------------- util
    @staticmethod
    def expand_path(value: str) -> Path:
        """Expand ``~`` and environment variables, returning an absolute path."""
        return Path(os.path.expandvars(os.path.expanduser(value))).resolve()

    @staticmethod
    def ensure_parent(path: Path) -> None:
        """Create the parent directory for ``path`` if it does not exist."""
        path.parent.mkdir(parents=True, exist_ok=True)

    # ---------------------------------------------------------------- interface
    def build_arg_parser(self) -> argparse.ArgumentParser:
        """Return an ``ArgumentParser`` configured with the agent description."""
        description = self.config.get("description") or f"Run agent {self.name}"
        parser = argparse.ArgumentParser(
            prog=self.name,
            description=description,
            formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        )
        return parser

    def run(self, argv: Optional[Sequence[str]] = None) -> int:
        """
        Parse arguments from ``argv`` (or ``sys.argv``) and execute the agent.
        """
        parser = self.build_arg_parser()
        args = parser.parse_args(argv)
        return self.handle(parser, args)

    @abc.abstractmethod
    def handle(
        self, parser: argparse.ArgumentParser, args: argparse.Namespace
    ) -> int:
        """
        Execute the agent with parsed CLI arguments.
        """

    # ---------------------------------------------------------------- metadata
    @property
    def allowed_hosts(self) -> Iterable[str]:
        return self.config.get("allowed_hosts", [])

    @property
    def outputs(self) -> Iterable[str]:
        return self.config.get("outputs", [])

    @property
    def tags(self) -> Iterable[str]:
        return self.config.get("tags", [])


