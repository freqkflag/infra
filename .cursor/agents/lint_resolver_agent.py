#!/usr/bin/env python3
"""
Lint resolver agent implementation.
"""

from __future__ import annotations

import argparse
import datetime as dt
import fnmatch
import importlib.util
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Dict, Iterable, List, Mapping, MutableMapping, Sequence

BASE_MODULE_PATH = Path(__file__).resolve().parent / "base.py"
BASE_MODULE_ID = "cursor_agent_base"

if BASE_MODULE_ID in sys.modules:
    _base_module = sys.modules[BASE_MODULE_ID]
else:
    _base_spec = importlib.util.spec_from_file_location(
        BASE_MODULE_ID,
        BASE_MODULE_PATH,
    )
    if _base_spec is None or _base_spec.loader is None:
        raise RuntimeError(f"unable to load base agent from {BASE_MODULE_PATH}")
    _base_module = importlib.util.module_from_spec(_base_spec)
    sys.modules[BASE_MODULE_ID] = _base_module
    _base_spec.loader.exec_module(_base_module)
BaseAgent = getattr(_base_module, "BaseAgent")


DEFAULT_RESOLVERS = [
    {
        "id": "python-ruff",
        "patterns": [
            "*.py",
            "scripts/**/*.py",
            ".cursor/**/*.py",
        ],
        "commands": [
            [
                ["uv", "run", "ruff", "check", "--fix", "{file}"],
                ["ruff", "check", "--fix", "{file}"],
            ],
            [
                ["uv", "run", "ruff", "format", "{file}"],
                ["ruff", "format", "{file}"],
            ],
        ],
        "verify": [
            [
                ["uv", "run", "ruff", "check", "{file}"],
                ["ruff", "check", "{file}"],
            ],
        ],
    },
]


class LintResolverAgent(BaseAgent):
    """Resolve lint warnings by running language aware fixers."""

    def __init__(self, name: str, config: Dict[str, object]) -> None:
        super().__init__(name, config)
        self.repo_root = Path(__file__).resolve().parents[2]
        self.infra_root = self._detect_infra_root(config)
        self.changelog_path = self.infra_root / "server-changelog.md"
        self.resolvers = self._load_resolvers(config)

    # ---------------------------------------------------------------- argument
    def build_arg_parser(self) -> argparse.ArgumentParser:
        parser = super().build_arg_parser()
        parser.add_argument(
            "--file",
            help="Path to linted file relative to the repository root.",
        )
        parser.add_argument(
            "--rule",
            help="Lint rule identifier (optional, used for resolver selection).",
        )
        parser.add_argument(
            "--message",
            help="Original lint message for logging context.",
        )
        parser.add_argument(
            "--list-resolvers",
            action="store_true",
            help="List configured resolvers and exit.",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Print commands without executing them.",
        )
        return parser

    # ----------------------------------------------------------------- runtime
    def handle(self, parser: argparse.ArgumentParser, args: argparse.Namespace) -> int:
        if args.list_resolvers:
            self._print_resolvers()
            return 0

        if not args.file:
            parser.error("--file is required unless --list-resolvers is used")

        target_path = self._resolve_target_path(args.file)
        if not target_path.exists():
            parser.error(f"target file does not exist: {target_path}")

        relative = target_path.relative_to(self.repo_root).as_posix()
        resolver = self._select_resolver(relative, args.rule)
        if resolver is None:
            parser.error(
                f"no resolver found for file '{relative}'"
                + (f" with rule '{args.rule}'" if args.rule else "")
            )

        context = {
            "file": relative,
            "abs_file": str(target_path),
            "rule": args.rule or "",
            "message": args.message or "",
            "repo_root": str(self.repo_root),
            "infra_root": str(self.infra_root),
        }

        try:
            self._run_resolver(resolver, context, dry_run=args.dry_run)
        except RuntimeError as exc:
            self._log_event(
                relative,
                resolver.get("id", "<unknown>"),
                status=f"failure: {exc}",
                rule=args.rule,
            )
            parser.exit(1)

        self._log_event(
            relative,
            resolver.get("id", "<unknown>"),
            status="success",
            rule=args.rule,
        )
        return 0

    # ------------------------------------------------------------------ helpers
    def _detect_infra_root(self, config: Mapping[str, object]) -> Path:
        candidates = [
            config.get("infra_root"),
            config.get("fallback_infra_root"),
            "~/infra",
        ]
        for candidate in candidates:
            if not candidate or not isinstance(candidate, str):
                continue
            path = self._expand_path(candidate)
            if path.exists():
                return path
        return self.repo_root

    def _expand_path(self, value: str) -> Path:
        expanded = os.path.expandvars(os.path.expanduser(value))
        path = Path(expanded)
        if path.is_absolute():
            return path.resolve()
        return (self.repo_root / path).resolve()

    def _load_resolvers(self, config: Mapping[str, object]) -> List[Dict[str, object]]:
        custom = config.get("resolvers")
        if isinstance(custom, list) and custom:
            return custom
        return DEFAULT_RESOLVERS

    def _print_resolvers(self) -> None:
        for resolver in self.resolvers:
            resolver_id = resolver.get("id", "<unnamed>")
            patterns = resolver.get("patterns", [])
            rules = resolver.get("rules", [])
            print(f"- {resolver_id}")
            print(f"  patterns: {patterns!r}")
            if rules:
                print(f"  rules: {rules!r}")

    def _resolve_target_path(self, value: str) -> Path:
        candidate = Path(value)
        if candidate.is_absolute():
            return candidate.resolve()
        return (self.repo_root / candidate).resolve()

    def _select_resolver(
        self, relative_path: str, rule: str | None
    ) -> Dict[str, object] | None:
        for resolver in self.resolvers:
            patterns = resolver.get("patterns")
            if patterns and not self._matches_patterns(relative_path, patterns):
                continue

            rules = resolver.get("rules")
            if rule and rules:
                if not any(self._matches_rule(rule, candidate) for candidate in rules):
                    continue

            return resolver
        return None

    @staticmethod
    def _matches_patterns(path: str, patterns: Iterable[object]) -> bool:
        for pattern in patterns:
            if not isinstance(pattern, str):
                continue
            if fnmatch.fnmatch(path, pattern):
                return True
        return False

    @staticmethod
    def _matches_rule(rule: str, candidate: object) -> bool:
        if isinstance(candidate, str):
            return fnmatch.fnmatch(rule, candidate)
        return False

    def _run_resolver(
        self,
        resolver: Dict[str, object],
        context: Dict[str, str],
        *,
        dry_run: bool,
    ) -> None:
        commands = resolver.get("commands") or []
        if not isinstance(commands, list) or not commands:
            raise RuntimeError("resolver has no commands configured")

        environment = self._build_environment(resolver.get("env"), context)

        for group in commands:
            cmd = self._pick_command(group, context)
            if cmd is None:
                raise RuntimeError("no available command for resolver")
            self._execute(cmd, environment, dry_run=dry_run)

        verify_groups = resolver.get("verify") or []
        if isinstance(verify_groups, list) and verify_groups:
            for group in verify_groups:
                cmd = self._pick_command(group, context)
                if cmd is None:
                    continue
                self._execute(cmd, environment, dry_run=dry_run)

    def _build_environment(
        self,
        env_config: object,
        context: Dict[str, str],
    ) -> MutableMapping[str, str]:
        env = os.environ.copy()
        if isinstance(env_config, Mapping):
            for key, value in env_config.items():
                if not isinstance(key, str):
                    continue
                if isinstance(value, str):
                    env[key] = value.format_map(context)
        return env

    def _pick_command(
        self,
        group: object,
        context: Dict[str, str],
    ) -> List[str] | None:
        candidates: List[List[str]] = []

        if isinstance(group, list):
            if group and all(isinstance(item, str) for item in group):
                candidates.append([item.format_map(context) for item in group])
            else:
                for entry in group:
                    if isinstance(entry, list) and entry:
                        formatted = [part.format_map(context) for part in entry]
                        candidates.append(formatted)
        elif isinstance(group, tuple):
            for entry in group:
                if isinstance(entry, (list, tuple)):
                    formatted = [str(part).format_map(context) for part in entry]
                    candidates.append(formatted)

        for candidate in candidates:
            if not candidate:
                continue
            command = candidate
            if self._command_available(command[0]):
                return command
        return None

    def _command_available(self, executable: str) -> bool:
        if os.path.isabs(executable):
            return os.access(executable, os.X_OK)

        repo_candidate = self.repo_root / executable
        if repo_candidate.exists() and os.access(repo_candidate, os.X_OK):
            return True

        return shutil.which(executable) is not None

    def _execute(
        self,
        command: Sequence[str],
        environment: Mapping[str, str],
        *,
        dry_run: bool,
    ) -> None:
        if dry_run:
            print("DRY RUN:", " ".join(command))
            return
        result = subprocess.run(
            command,
            cwd=self.repo_root,
            env=environment,
            check=False,
        )
        if result.returncode != 0:
            raise RuntimeError(
                f"command '{' '.join(command)}' failed with code {result.returncode}"
            )

    def _log_event(
        self,
        relative_file: str,
        resolver_id: str,
        *,
        status: str,
        rule: str | None,
    ) -> None:
        timestamp = dt.datetime.now(dt.timezone.utc).isoformat()
        rule_fragment = f", rule={rule}" if rule else ""
        entry = (
            f"{timestamp} - lint-resolver-agent - "
            f"{relative_file} -> {resolver_id} -> {status}{rule_fragment}"
        )
        self.changelog_path.parent.mkdir(parents=True, exist_ok=True)
        with self.changelog_path.open("a", encoding="utf-8") as handle:
            handle.write(entry + "\n")


def main(argv: Sequence[str] | None = None) -> int:
    agent = LintResolverAgent(
        "lint-resolver-agent",
        config={
            "description": "Resolve lint warnings with language aware fixers.",
        },
    )
    return agent.run(argv)


if __name__ == "__main__":
    raise SystemExit(main())


