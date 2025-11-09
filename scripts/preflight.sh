#!/usr/bin/env bash
set -euo pipefail

echo "=== Preflight Check Starting ==="

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
  echo "❌ Missing environment file. Set WORKSPACE_ENV_FILE or create one at /Users/freqkflag/Projects/.workspace/.env or $HOME/.workspace/.env"
  exit 1
fi

# Check Docker and Compose
docker --version >/dev/null
docker compose version >/dev/null

# Ensure edge network exists
if ! docker network inspect edge >/dev/null 2>&1; then
  echo "Creating edge network..."
  docker network create --driver bridge edge
else
  echo "Edge network already exists"
fi

echo "✅ Preflight OK"
exit 0
