#!/usr/bin/env bash
set -euo pipefail

echo "=== Preflight Check Starting ==="

# Verify env file exists
ENV_FILE="/Users/freqkflag/Projects/.workspace/.env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ Missing environment file at $ENV_FILE"
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
