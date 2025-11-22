#!/bin/bash
#
# Create GitLab database and user
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load environment variables
if [ -f "$INFRA_ROOT/.workspace/.env" ]; then
    export POSTGRES_USER=$(grep "^POSTGRES_USER=" "$INFRA_ROOT/.workspace/.env" | cut -d'=' -f2 | tr -d "'\"")
    export POSTGRES_PASSWORD=$(grep "^POSTGRES_PASSWORD=" "$INFRA_ROOT/.workspace/.env" | cut -d'=' -f2 | tr -d "'\"")
    export GITLAB_DB_USER=$(grep "^GITLAB_DB_USER=" "$INFRA_ROOT/.workspace/.env" | cut -d'=' -f2 | tr -d "'\"")
    export GITLAB_DB_PASSWORD=$(grep "^GITLAB_DB_PASSWORD=" "$INFRA_ROOT/.workspace/.env" | cut -d'=' -f2 | tr -d "'\"")
    export GITLAB_DB_NAME=$(grep "^GITLAB_DB_NAME=" "$INFRA_ROOT/.workspace/.env" | cut -d'=' -f2 | tr -d "'\"")
fi

# Defaults
POSTGRES_USER=${POSTGRES_USER:-postgres}
GITLAB_DB_USER=${GITLAB_DB_USER:-gitlab}
GITLAB_DB_NAME=${GITLAB_DB_NAME:-gitlab}

# Find PostgreSQL container
POSTGRES_CONTAINER=$(docker ps --format "{{.Names}}" | grep -i postgres | head -1)

if [ -z "$POSTGRES_CONTAINER" ]; then
    echo "Error: PostgreSQL container not found"
    exit 1
fi

echo "=== Creating GitLab database ==="
echo "PostgreSQL container: $POSTGRES_CONTAINER"
echo "PostgreSQL user: $POSTGRES_USER"
echo "GitLab DB user: $GITLAB_DB_USER"
echo "GitLab DB name: $GITLAB_DB_NAME"
echo ""

# Generate password if not set
if [ -z "${GITLAB_DB_PASSWORD:-}" ]; then
    GITLAB_DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    echo "Generated GitLab DB password: $GITLAB_DB_PASSWORD"
    echo "⚠️  Save this password and set it in Infisical as GITLAB_DB_PASSWORD"
    echo ""
fi

# Create user and database
echo "Creating GitLab database user and database..."
docker exec -i "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -d postgres <<EOF 2>&1 | grep -v "already exists" || true
CREATE USER $GITLAB_DB_USER WITH PASSWORD '$GITLAB_DB_PASSWORD';
CREATE DATABASE $GITLAB_DB_NAME OWNER $GITLAB_DB_USER;
GRANT ALL PRIVILEGES ON DATABASE $GITLAB_DB_NAME TO $GITLAB_DB_USER;
EOF

# Verify creation
echo ""
echo "Verifying database creation..."
docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -d postgres -c "\l" | grep "$GITLAB_DB_NAME" || echo "Warning: Database not found in list"

echo ""
echo "=== Database setup complete ==="
echo "Database: $GITLAB_DB_NAME"
echo "User: $GITLAB_DB_USER"
echo "Password: $GITLAB_DB_PASSWORD"
echo ""
echo "⚠️  Make sure GITLAB_DB_PASSWORD is set in Infisical!"
