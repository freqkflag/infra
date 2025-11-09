#!/usr/bin/env python3
"""
Shared helpers for Cursor automation agents.

The infra automation suite relies on repeatable behavior across agents, notably
for command execution, host validation, Infisical invocation, and structured
documentation updates.  This module centralizes those utilities to keep the
agent implementations lean and consistent.
"""

from __future__ import annotations

import datetime as dt
import json
import os
import re
import shlex
import socket
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Mapping, MutableMapping, Optional, Sequence
from urllib import error as urlerror
from urllib import request as urlrequest

try:
    import yaml  # type: ignore
except ImportError:  # pragma: no cover - optional dependency
    yaml = None

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_LOG_PATH = REPO_ROOT / "server-changelog.md"
DEFAULT_CHANGELOG_PATH = REPO_ROOT / "CHANGE.log"

HOST_ALIASES = {
    "mac": {"home.macmini", "macmini", "twist3dkink", "twist3dkink.online"},
    "vps": {"vps.host", "freqkflag", "freqkflag.co"},
    "linux": {"home.linux", "cult-of-joey.com"},
}

ENV_VAR_PATTERN = re.compile(r"\$\{([A-Za-z0-9_]+)(?::-[^}]+)?\}")


@dataclass
class CommandResult:
    """Simple container for subprocess execution results."""

    command: List[str]
    returncode: int
    stdout: str
    stderr: str
    was_dry_run: bool = False

    @property
    def ok(self) -> bool:
        return self.returncode == 0


def timestamp() -> str:
    """Return the current UTC timestamp with timezone info."""
    return dt.datetime.now(tz=dt.timezone.utc).isoformat()


def resolve_repo_path(*parts: str) -> Path:
    """Return an absolute path anchored at the repository root."""
    return (REPO_ROOT.joinpath(*parts)).resolve()


def read_text(path: Path) -> str:
    if not path.exists():
        return ""
    return path.read_text(encoding="utf-8")


def append_lines(path: Path, lines: Iterable[str], dry_run: bool = False) -> None:
    """Append ``lines`` to ``path`` while honoring dry-run mode."""
    if dry_run:
        preview = "\n".join(lines)
        print(f"DRY RUN append -> {path}\n{preview}")
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as handle:
        for line in lines:
            handle.write(f"{line}\n")


def resolve_host_label(explicit: Optional[str] = None) -> str:
    """Resolve the current host label, honoring overrides and AGENT_HOST."""
    if explicit:
        return explicit

    env_host = (
        os.environ.get("AGENT_HOST")
        or os.environ.get("LOGGER_AGENT_HOST")
        or os.environ.get("HOSTNAME")
    )
    if env_host:
        return env_host

    return socket.gethostname()


def map_host_alias(host: str) -> str:
    """Map a hostname to the infra alias (mac/vps/linux) when possible."""
    normalized = host.lower()
    for alias, candidates in HOST_ALIASES.items():
        if normalized in candidates:
            return alias
        if any(candidate in normalized for candidate in candidates):
            return alias
    return normalized


def enforce_allowed_host(
    agent_name: str, allowed_hosts: Iterable[str], explicit_host: Optional[str] = None
) -> str:
    """
    Ensure the current host (or its alias) is in the ``allowed_hosts`` list.

    Returns the resolved alias for downstream logging.  Raises ``SystemExit``
    when the host is not permitted.
    """
    resolved = resolve_host_label(explicit_host)
    alias = map_host_alias(resolved)

    allowed = list(allowed_hosts)
    if allowed and alias not in allowed and resolved not in allowed:
        raise SystemExit(
            f"{agent_name} is not permitted to run on host '{resolved}' (alias '{alias}')."
        )
    return alias


def _prepare_env(env: Optional[Mapping[str, str]] = None) -> MutableMapping[str, str]:
    merged: MutableMapping[str, str] = os.environ.copy()
    if env:
        merged.update(env)
    return merged


def run_command(
    command: Sequence[str],
    *,
    cwd: Optional[Path] = None,
    env: Optional[Mapping[str, str]] = None,
    dry_run: bool = False,
    check: bool = False,
    stream: bool = False,
) -> CommandResult:
    """
    Execute ``command`` with optional cwd/env.

    When ``dry_run`` is True, prints the command and returns a successful
    ``CommandResult`` without executing anything.  By default output is
    captured; set ``stream=True`` to inherit stdout/stderr directly.
    """
    printable = shlex.join(command)
    location = f" (cwd={cwd})" if cwd else ""
    print(f"[agent] run{location}: {printable}")

    if dry_run:
        return CommandResult(list(command), 0, "", "", was_dry_run=True)

    run_env = _prepare_env(env)
    try:
        if stream:
            completed = subprocess.run(
                command,
                cwd=str(cwd) if cwd else None,
                env=run_env,
                check=False,
            )
            result = CommandResult(list(command), completed.returncode, "", "")
        else:
            completed = subprocess.run(
                command,
                cwd=str(cwd) if cwd else None,
                env=run_env,
                capture_output=True,
                text=True,
                check=False,
            )
            result = CommandResult(
                list(command),
                completed.returncode,
                completed.stdout,
                completed.stderr,
            )
    except FileNotFoundError as exc:
        raise SystemExit(f"command not found: {command[0]} ({exc})") from exc

    if check and result.returncode != 0:
        raise SystemExit(
            f"command failed with exit code {result.returncode}: {printable}\n{result.stderr}"
        )

    return result


def run_infisical(
    env_name: str,
    inner_command: Sequence[str],
    *,
    cwd: Optional[Path] = None,
    dry_run: bool = False,
    check: bool = False,
    stream: bool = False,
    secret_path: Optional[str] = None,
) -> CommandResult:
    """Invoke ``infisical run`` with optional secret path support."""
    path_value = secret_path or os.environ.get("INFISICAL_SECRET_PATH")
    command = [
        "infisical",
        "run",
        f"--env={env_name}",
    ]
    if path_value:
        command.append(f"--path={path_value}")
    command.extend(["--", *inner_command])
    return run_command(
        command,
        cwd=cwd,
        dry_run=dry_run,
        check=check,
        stream=stream,
    )


def git_status_paths(*prefixes: str) -> List[str]:
    """
    Return porcelain status lines for files under the provided ``prefixes``.
    """
    result = run_command(
        ["git", "status", "--porcelain"],
        cwd=REPO_ROOT,
        dry_run=False,
        check=False,
    )
    lines = result.stdout.splitlines()
    filtered: List[str] = []
    for line in lines:
        if len(line) < 4:
            continue
        path = line[3:]
        if not prefixes:
            filtered.append(line)
        else:
            if any(path.startswith(prefix.rstrip("/") + "/") or path == prefix for prefix in prefixes):
                filtered.append(line)
    return filtered


def list_compose_files() -> List[Path]:
    """Return all compose files under services/ and nodes/ plus orchestrator."""
    compose_files: List[Path] = []
    orchestrator = resolve_repo_path("compose.orchestrator.yml")
    if orchestrator.exists():
        compose_files.append(orchestrator)

    for base in ("services", "nodes"):
        root = resolve_repo_path(base)
        if not root.exists():
            continue
        for path in sorted(root.rglob("compose.yml")):
            compose_files.append(path)
    return compose_files


def extract_env_vars_from_text(text: str) -> List[str]:
    """Find ${VAR} references within ``text``."""
    return [match.group(1) for match in ENV_VAR_PATTERN.finditer(text)]


def parse_env_file(path: Path) -> Dict[str, str]:
    """Parse a simple KEY=VALUE env template file."""
    env_vars: Dict[str, str] = {}
    if not path.exists():
        return env_vars
    with path.open("r", encoding="utf-8") as handle:
        for raw in handle:
            line = raw.strip()
            if not line or line.startswith("#"):
                continue
            if "=" not in line:
                continue
            key, value = line.split("=", 1)
            env_vars[key.strip()] = value.strip()
    return env_vars


def parse_env_templates(template_dir: Path) -> Dict[str, Dict[str, str]]:
    """Load all env template files under ``template_dir``."""
    data: Dict[str, Dict[str, str]] = {}
    if not template_dir.exists():
        return data
    for template in sorted(template_dir.glob("*.env*")):
        data[template.name] = parse_env_file(template)
    return data


def update_marker_block(path: Path, marker: str, payload_lines: List[str]) -> bool:
    """
    Replace or append a marker block inside ``path``.

    Returns True when the file content changed.
    """
    start = f"<!-- {marker}:start -->"
    end = f"<!-- {marker}:end -->"
    block = "\n".join([start, *payload_lines, end]) + "\n"
    text = read_text(path)
    if start in text and end in text:
        before, remainder = text.split(start, 1)
        _, after = remainder.split(end, 1)
        new_text = before + block + after
    else:
        sep = "\n\n" if text.strip() else ""
        new_text = text + sep + block

    if new_text == text:
        return False
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(new_text, encoding="utf-8")
    return True


def summarize_git_diff() -> str:
    """Return ``git status --short`` output for quick review."""
    result = run_command(
        ["git", "status", "--short"],
        cwd=REPO_ROOT,
        dry_run=False,
    )
    return result.stdout.strip()


def json_dumps(data: Dict[str, object]) -> str:
    return json.dumps(data, indent=2, sort_keys=True)


def yaml_safe_load(text: str) -> Dict[str, object]:
    """Parse YAML text and return a dict (requires PyYAML)."""
    if yaml is None:
        raise SystemExit(
            "PyYAML is required for this agent action. Install via 'pip install pyyaml'."
        )
    loaded = yaml.safe_load(text)  # type: ignore[no-any-unimported]
    if not isinstance(loaded, dict):
        return {}
    return loaded


def yaml_load_file(path: Path) -> Dict[str, object]:
    return yaml_safe_load(read_text(path))


def log_server_event(
    agent: str,
    message: str,
    *,
    dry_run: bool = False,
    details: Optional[Iterable[str]] = None,
) -> None:
    """Append a standardized entry to server-changelog.md."""
    lines = [f"- {timestamp()} — {agent} {message}"]
    if details:
        lines.extend(f"  - {item}" for item in details)
    append_lines(DEFAULT_LOG_PATH, lines, dry_run=dry_run)


def _webhook_url() -> str:
    url = os.environ.get("INFISICAL_WEBHOOK_URL")
    if not url:
        raise SystemExit(
            "INFISICAL_WEBHOOK_URL is not set; populate it in the environment before running agents."
        )
    return url


def post_webhook(payload: Dict[str, object], *, dry_run: bool = False) -> None:
    """
    Send ``payload`` to ``INFISICAL_WEBHOOK_URL`` as JSON.

    Honors ``dry_run`` by printing the payload instead of performing the HTTP
    request.
    """
    url = _webhook_url()
    serialized = json.dumps(payload, indent=2, sort_keys=True)
    if dry_run:
        print(f"DRY RUN webhook -> {url}\n{serialized}")
        return

    data = serialized.encode("utf-8")
    req = urlrequest.Request(
        url,
        data=data,
        headers={"Content-Type": "application/json", "Content-Length": str(len(data))},
        method="POST",
    )
    try:
        with urlrequest.urlopen(req, timeout=15) as resp:
            # Drain response to ensure the request completes; ignore body.
            resp.read()
    except urlerror.URLError as exc:  # pragma: no cover - network error handling
        raise SystemExit(f"webhook POST to {url} failed: {exc}") from exc
