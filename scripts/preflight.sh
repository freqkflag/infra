#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '%s\n' "$@"
}

fail() {
  printf '❌ %s\n' "$@" >&2
  exit 1
}

require_cli() {
  if ! command -v "$1" >/dev/null 2>&1; then
    fail "Missing required CLI: $1"
  fi
}

log "=== Preflight Check Starting ==="

# Verify env file exists
ENV_FILE="${WORKSPACE_ENV_FILE:-}"

if [[ -z "${ENV_FILE}" ]]; then
  for candidate in "$PWD/.workspace/.env" "$HOME/.workspace/.env"; do
    if [[ -f "${candidate}" ]]; then
      ENV_FILE="${candidate}"
      break
    fi
  done
fi

if [[ -z "${ENV_FILE}" || ! -f "${ENV_FILE}" ]]; then
  fail "Missing environment file. Set WORKSPACE_ENV_FILE or create one at $PWD/.workspace/.env or $HOME/.workspace/.env"
fi

require_cli docker
require_cli infisical

if ! docker compose version >/dev/null 2>&1; then
  fail "Docker Compose V2 (docker compose) is unavailable. Upgrade Docker or install the compose plugin."
fi

PYTHON_BIN=""
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="python3"
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN="python"
else
  fail "Python is required to perform docker health checks. Install python3."
fi

if ! "$PYTHON_BIN" - <<'PY'
import subprocess
import sys

try:
    subprocess.run(
        ["docker", "info"],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        timeout=5,
    )
except subprocess.TimeoutExpired:
    sys.exit(124)
except subprocess.CalledProcessError:
    sys.exit(1)
except Exception:
    sys.exit(2)
PY
then
  status=$?
  if [[ $status -eq 124 ]]; then
    fail "Docker daemon did not respond within 5 seconds. Start Docker and rerun preflight."
  else
    fail "Docker daemon is not reachable. Start Docker and rerun preflight."
  fi
fi

# Ensure edge network exists
if ! docker network inspect edge >/dev/null 2>&1; then
  log "Creating edge network..."
  docker network create --driver bridge edge >/dev/null
else
  log "Edge network already exists"
fi

log "✅ Preflight OK"
exit 0
