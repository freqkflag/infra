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
  for candidate in "/Users/freqkflag/Projects/.workspace/.env" "$HOME/.workspace/.env"; do
    if [[ -f "${candidate}" ]]; then
      ENV_FILE="${candidate}"
      break
    fi
  done
fi

if [[ -z "${ENV_FILE}" || ! -f "${ENV_FILE}" ]]; then
  fail "Missing environment file. Set WORKSPACE_ENV_FILE or create one at /Users/freqkflag/Projects/.workspace/.env or $HOME/.workspace/.env"
fi

require_cli docker
require_cli infisical

if ! docker compose version >/dev/null 2>&1; then
  fail "Docker Compose V2 (docker compose) is unavailable. Upgrade Docker or install the compose plugin."
fi

if ! docker info >/dev/null 2>&1; then
  fail "Docker daemon is not reachable. Start Docker and rerun preflight."
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
