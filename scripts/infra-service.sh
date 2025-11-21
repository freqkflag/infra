#!/bin/bash
# Infrastructure Service Lifecycle Management
# Usage: ./infra-service.sh [start|stop|restart|status] <service-id>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(dirname "$SCRIPT_DIR")"
SERVICES_FILE="$INFRA_DIR/SERVICES.yml"

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 [start|stop|restart|status] <service-id>"
    exit 1
fi

ACTION=$1
SERVICE_ID=$2

# Parse SERVICES.yml to find service directory (simple grep-based parser)
SERVICE_DIR=$(grep -A 10 "id: $SERVICE_ID" "$SERVICES_FILE" | grep "dir:" | head -1 | sed 's/.*dir:[[:space:]]*//' | sed 's/[[:space:]]*$//' || echo "")

if [[ -z "$SERVICE_DIR" ]] || [[ "$SERVICE_DIR" == "null" ]]; then
    echo "Error: Service '$SERVICE_ID' not found in SERVICES.yml"
    exit 1
fi

# Handle relative paths
if [[ "$SERVICE_DIR" != /* ]]; then
    SERVICE_DIR="$INFRA_DIR/$SERVICE_DIR"
fi

if [[ ! -d "$SERVICE_DIR" ]]; then
    echo "Error: Service directory not found: $SERVICE_DIR"
    exit 1
fi

cd "$SERVICE_DIR"

case "$ACTION" in
    start)
        echo "Starting $SERVICE_ID..."
        docker compose up -d
        ;;
    stop)
        echo "Stopping $SERVICE_ID..."
        docker compose down
        ;;
    restart)
        echo "Restarting $SERVICE_ID..."
        docker compose restart
        ;;
    status)
        docker compose ps
        ;;
    *)
        echo "Error: Unknown action '$ACTION'. Use: start, stop, restart, or status"
        exit 1
        ;;
esac

