#!/bin/bash
# Health Check Template Generator
# Purpose: Generate standard health check configurations
# Usage: ./scripts/health-check-template.sh <type> <args...>

set -euo pipefail

TYPE="${1:-}"
shift || true

case "$TYPE" in
    http)
        PORT="${1:-80}"
        ENDPOINT="${2:-/}"
        cat <<EOF
healthcheck:
  test:
    - CMD-SHELL
    - "curl -fsSL http://127.0.0.1:${PORT}${ENDPOINT} || exit 1"
  interval: 30s
  timeout: 5s
  retries: 5
  start_period: 30s
EOF
        ;;
    process)
        PROCESS="${1:-}"
        if [ -z "$PROCESS" ]; then
            echo "Error: Process name required for process check" >&2
            echo "Usage: $0 process <process-name>" >&2
            exit 1
        fi
        cat <<EOF
healthcheck:
  test:
    - CMD-SHELL
    - "kill -0 1 2>/dev/null && ps aux | grep -v grep | grep -q ${PROCESS} && exit 0 || exit 1"
  interval: 30s
  timeout: 5s
  retries: 5
  start_period: 10s
EOF
        ;;
    database)
        DB_TYPE="${1:-postgres}"
        case "$DB_TYPE" in
            postgres)
                USER="${2:-postgres}"
                DB="${3:-postgres}"
                cat <<EOF
healthcheck:
  test:
    - CMD-SHELL
    - "pg_isready -U ${USER} -d ${DB} || exit 1"
  interval: 30s
  timeout: 5s
  retries: 5
  start_period: 20s
EOF
                ;;
            mysql|mariadb)
                USER="${2:-root}"
                cat <<EOF
healthcheck:
  test:
    - CMD-SHELL
    - "mysqladmin ping -u ${USER} -p\${MARIADB_ROOT_PASSWORD} || exit 1"
  interval: 30s
  timeout: 5s
  retries: 5
  start_period: 20s
EOF
                ;;
            *)
                echo "Error: Unknown database type: $DB_TYPE" >&2
                echo "Supported: postgres, mysql, mariadb" >&2
                exit 1
                ;;
        esac
        ;;
    port)
        PORT="${1:-3000}"
        # Convert port to hex
        HEX_PORT=$(printf "%04X" "$PORT")
        cat <<EOF
healthcheck:
  test:
    - CMD-SHELL
    - "grep -q '${HEX_PORT}' /proc/net/tcp || exit 1"
  interval: 30s
  timeout: 5s
  retries: 5
  start_period: 30s
EOF
        ;;
    *)
        cat <<EOF
Health Check Template Generator

Usage: $0 <type> [args...]

Types:
  http <port> [endpoint]     - HTTP endpoint check
                               Example: $0 http 3000 /
  
  process <name>              - Process check
                               Example: $0 process n8n
  
  database <type> [user] [db] - Database connection check
                               Example: $0 database postgres postgres wikijs
  
  port <port>                 - Port check (via /proc/net/tcp)
                               Example: $0 port 3000

Examples:
  $0 http 3000 /              # HTTP check on port 3000, root endpoint
  $0 http 8080 /health         # HTTP check on port 8080, /health endpoint
  $0 process traefik           # Process check for traefik
  $0 database postgres postgres wikijs  # PostgreSQL check
  $0 port 3000                 # Port check for port 3000
EOF
        exit 1
        ;;
esac

