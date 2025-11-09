#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="$HOME/.backup/daily"
mkdir -p "$BACKUP_DIR"

echo "=== Running backup ==="
timestamp=$(date +"%Y%m%d_%H%M")

docker exec postgres pg_dumpall -U postgres > "$BACKUP_DIR/postgres_$timestamp.sql" || true
docker exec mariadb mysqldump -u root --all-databases > "$BACKUP_DIR/mariadb_$timestamp.sql" || true
tar czf "$BACKUP_DIR/docker_volumes_$timestamp.tar.gz" $(docker volume ls -q)

echo "✅ Backup complete: $BACKUP_DIR"
exit 0
