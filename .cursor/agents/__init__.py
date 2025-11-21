"""
Cursor automation agents package.

Modules under this package implement runnable agents that can be invoked via
`.cursor` commands or the shared infra `scripts/agents/run-agent.py` wrapper.
"""

from .base import BaseAgent  # re-export convenience

__all__ = ["BaseAgent"]


