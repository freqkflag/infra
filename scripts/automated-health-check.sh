#!/usr/bin/env bash
# Automated Health Check Script
# Monitors all Docker containers and reports unhealthy services
# Run via cron: */5 * * * * /root/infra/scripts/automated-health-check.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${LOG_DIR:-/var/log/infra}"
LOG_FILE="${LOG_FILE:-$LOG_DIR/health-check.log}"
ALERT_WEBHOOK="${ALERT_WEBHOOK_URL:-}"
COMPOSE_FILE="${COMPOSE_FILE:-compose.orchestrator.yml}"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Function to check container health
check_container_health() {
    local container="$1"
    local health
    
    health=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$container" 2>/dev/null || echo "unknown")
    
    if [ "$health" = "unhealthy" ]; then
        return 1
    elif [ "$health" = "running" ] && docker inspect --format='{{.State.Health}}' "$container" 2>/dev/null | grep -q "Health"; then
        # Container has health check but shows "running" instead of "healthy" - might be starting
        return 2
    elif [ "$health" != "healthy" ] && [ "$health" != "running" ]; then
        return 1
    fi
    
    return 0
}

# Collect all containers
log "Starting health check..."

FAILED_CONTAINERS=()
WARNING_CONTAINERS=()

# Get all running containers
CONTAINERS=$(docker ps --format "{{.Names}}")

if [ -z "$CONTAINERS" ]; then
    log "ERROR: No containers found"
    exit 1
fi

# Check each container
while IFS= read -r container; do
    if ! check_container_health "$container"; then
        exit_code=$?
        if [ $exit_code -eq 1 ]; then
            FAILED_CONTAINERS+=("$container")
        elif [ $exit_code -eq 2 ]; then
            WARNING_CONTAINERS+=("$container")
        fi
    fi
done <<< "$CONTAINERS"

# Report results
if [ ${#FAILED_CONTAINERS[@]} -gt 0 ]; then
    log "CRITICAL: Unhealthy containers detected: ${FAILED_CONTAINERS[*]}"
    
    # Send alert via webhook if configured
    if [ -n "$ALERT_WEBHOOK" ]; then
        curl -X POST "$ALERT_WEBHOOK" \
            -H "Content-Type: application/json" \
            -d "{\"text\": \"🚨 Health check failed: ${FAILED_CONTAINERS[*]}\", \"severity\": \"critical\"}" \
            -f -s >/dev/null 2>&1 || log "WARNING: Failed to send webhook alert"
    fi
    
    # Exit with error code
    exit 1
elif [ ${#WARNING_CONTAINERS[@]} -gt 0 ]; then
    log "WARNING: Containers without health checks: ${WARNING_CONTAINERS[*]}"
    exit 0
else
    log "SUCCESS: All containers healthy"
    exit 0
fi

