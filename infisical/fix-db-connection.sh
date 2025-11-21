#!/bin/bash
# Fix database connection string with URL-encoded password

set -euo pipefail

cd "$(dirname "$0")"

# Source .env
export $(grep -v '^#' .env | xargs)

# URL encode password
ENCODED_PWD=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${POSTGRES_PASSWORD}', safe=''))")

# Update docker-compose.yml to use encoded password
sed -i "s|DB_CONNECTION_URI: postgresql://\${POSTGRES_USER:-infisical}:\${POSTGRES_PASSWORD}@|DB_CONNECTION_URI: postgresql://\${POSTGRES_USER:-infisical}:${ENCODED_PWD}@|" docker-compose.yml

echo "✓ Updated DB_CONNECTION_URI with URL-encoded password"

