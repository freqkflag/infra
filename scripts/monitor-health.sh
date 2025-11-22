#!/bin/bash
#
# Health Check Monitoring Script
# Monitors all service health status, alerts on failures, and attempts remediation
#
# Usage:
#   ./scripts/monitor-health.sh [--remediate] [--alert-only]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$INFRA_DIR"

REMEDIATE="${1:-}"
ALERT_ONLY="${2:-}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
MAX_RESTART_ATTEMPTS=3
RESTART_COOLDOWN=300  # 5 minutes
ALERT_WEBHOOK_URL="${INFISICAL_WEBHOOK_URL:-https://n8n.freqkflag.co/webhook/health-alert}"
LOG_FILE="/var/log/health-monitor.log"

# Track restart attempts
RESTART_TRACKING_FILE="/tmp/health-monitor-restarts.json"

# Initialize restart tracking
if [ ! -f "$RESTART_TRACKING_FILE" ]; then
    echo '{}' > "$RESTART_TRACKING_FILE"
fi

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

check_service_health() {
    local service_name="$1"
    local health_status=$(docker inspect --format='{{.State.Health.Status}}' "$service_name" 2>/dev/null || echo "unknown")
    
    if [ "$health_status" = "healthy" ]; then
        return 0
    else
        return 1
    fi
}

get_restart_count() {
    local service_name="$1"
    jq -r ".\"$service_name\" // 0" "$RESTART_TRACKING_FILE" 2>/dev/null || echo "0"
}

increment_restart_count() {
    local service_name="$1"
    local current_count=$(get_restart_count "$service_name")
    local new_count=$((current_count + 1))
    
    local temp_file=$(mktemp)
    jq ".\"$service_name\" = $new_count" "$RESTART_TRACKING_FILE" > "$temp_file"
    mv "$temp_file" "$RESTART_TRACKING_FILE"
    echo "$new_count"
}

reset_restart_count() {
    local service_name="$1"
    local temp_file=$(mktemp)
    jq "del(.\"$service_name\")" "$RESTART_TRACKING_FILE" > "$temp_file"
    mv "$temp_file" "$RESTART_TRACKING_FILE"
}

send_alert() {
    local service_name="$1"
    local status="$2"
    local health_check="$3"
    
    local payload=$(cat <<EOF
{
  "service": "$service_name",
  "status": "$status",
  "health_check": "$health_check",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "trigger_agent": "ops"
}
EOF
)
    
    if curl -s -X POST "$ALERT_WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "$payload" > /dev/null 2>&1; then
        log "INFO" "Alert sent for $service_name"
        return 0
    else
        log "ERROR" "Failed to send alert for $service_name"
        return 1
    fi
}

remediate_service() {
    local service_name="$1"
    local restart_count=$(get_restart_count "$service_name")
    
    if [ "$restart_count" -ge "$MAX_RESTART_ATTEMPTS" ]; then
        log "ERROR" "Service $service_name exceeded max restart attempts ($MAX_RESTART_ATTEMPTS)"
        send_alert "$service_name" "unhealthy" "max_restarts_exceeded"
        return 1
    fi
    
    log "WARN" "Attempting to restart $service_name (attempt $((restart_count + 1))/$MAX_RESTART_ATTEMPTS)"
    
    # Find compose file for service
    local compose_file=""
    if [ -f "services/${service_name}/compose.yml" ]; then
        compose_file="services/${service_name}/compose.yml"
    elif [ -f "${service_name}/docker-compose.yml" ]; then
        compose_file="${service_name}/docker-compose.yml"
    else
        log "ERROR" "Could not find compose file for $service_name"
        return 1
    fi
    
    # Restart service
    if docker compose -f "$compose_file" restart "$service_name" > /dev/null 2>&1; then
        local new_count=$(increment_restart_count "$service_name")
        log "INFO" "Restarted $service_name (total restarts: $new_count)"
        
        # Wait for health check
        sleep 30
        
        # Check if service is now healthy
        if check_service_health "$service_name"; then
            log "INFO" "Service $service_name is now healthy"
            reset_restart_count "$service_name"
            return 0
        else
            log "WARN" "Service $service_name still unhealthy after restart"
            return 1
        fi
    else
        log "ERROR" "Failed to restart $service_name"
        return 1
    fi
}

main() {
    log "INFO" "Starting health check monitoring"
    
    # Get all running containers
    local containers=$(docker ps --format "{{.Names}}" | grep -v "^$" || true)
    
    if [ -z "$containers" ]; then
        log "WARN" "No running containers found"
        exit 0
    fi
    
    local unhealthy_count=0
    local healthy_count=0
    
    echo -e "${BLUE}Health Check Monitoring${NC}"
    echo "=========================================="
    echo ""
    
    while IFS= read -r container; do
        if [ -z "$container" ]; then
            continue
        fi
        
        # Skip health check for containers without health checks
        local has_healthcheck=$(docker inspect --format='{{.Config.Healthcheck}}' "$container" 2>/dev/null || echo "")
        if [ -z "$has_healthcheck" ] || [ "$has_healthcheck" = "<no value>" ]; then
            continue
        fi
        
        if check_service_health "$container"; then
            echo -e "${GREEN}✓${NC} $container: healthy"
            ((healthy_count++))
        else
            echo -e "${RED}✗${NC} $container: unhealthy"
            ((unhealthy_count++))
            
            # Send alert
            send_alert "$container" "unhealthy" "health_check_failed"
            
            # Attempt remediation if enabled
            if [ "$REMEDIATE" = "--remediate" ] && [ "$ALERT_ONLY" != "--alert-only" ]; then
                remediate_service "$container"
            fi
        fi
    done <<< "$containers"
    
    echo ""
    echo "=========================================="
    echo -e "Healthy: ${GREEN}$healthy_count${NC}"
    echo -e "Unhealthy: ${RED}$unhealthy_count${NC}"
    echo ""
    
    log "INFO" "Health check completed: $healthy_count healthy, $unhealthy_count unhealthy"
    
    if [ $unhealthy_count -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
}

main "$@"

