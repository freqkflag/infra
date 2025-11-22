#!/bin/bash
# Health Check Monitoring and Remediation Script
# Purpose: Monitor all container health status, alert on failures, and attempt automatic remediation
# Usage: ./scripts/monitor-health.sh [--alert-only] [--remediate] [--service <service-name>]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$INFRA_DIR"

# Configuration
LOG_FILE="${LOG_FILE:-/var/log/health-monitor.log}"
MAX_RESTART_ATTEMPTS=3
RESTART_COOLDOWN=300  # 5 minutes in seconds
ALERT_WEBHOOK_URL="${INFISICAL_WEBHOOK_URL:-https://n8n.freqkflag.co/webhook/health-alert}"
REMEDIATE=false
ALERT_ONLY=false
SERVICE_FILTER=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --remediate)
            REMEDIATE=true
            shift
            ;;
        --alert-only)
            ALERT_ONLY=true
            shift
            ;;
        --service)
            SERVICE_FILTER="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 [--alert-only] [--remediate] [--service <service-name>]" >&2
            exit 1
            ;;
    esac
done

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Logging function
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Get restart count for a container
get_restart_count() {
    local container=$1
    local restart_file="/tmp/health-monitor-restarts-${container}"
    if [ -f "$restart_file" ]; then
        cat "$restart_file"
    else
        echo "0"
    fi
}

# Increment restart count
increment_restart_count() {
    local container=$1
    local restart_file="/tmp/health-monitor-restarts-${container}"
    local count=$(get_restart_count "$container")
    echo $((count + 1)) > "$restart_file"
}

# Reset restart count
reset_restart_count() {
    local container=$1
    local restart_file="/tmp/health-monitor-restarts-${container}"
    rm -f "$restart_file"
}

# Check if container is in cooldown period
is_in_cooldown() {
    local container=$1
    local cooldown_file="/tmp/health-monitor-cooldown-${container}"
    
    if [ ! -f "$cooldown_file" ]; then
        return 1  # Not in cooldown
    fi
    
    local cooldown_time=$(cat "$cooldown_file")
    local current_time=$(date +%s)
    local elapsed=$((current_time - cooldown_time))
    
    if [ $elapsed -lt $RESTART_COOLDOWN ]; then
        return 0  # In cooldown
    else
        rm -f "$cooldown_file"
        return 1  # Cooldown expired
    fi
}

# Set cooldown period
set_cooldown() {
    local container=$1
    local cooldown_file="/tmp/health-monitor-cooldown-${container}"
    echo "$(date +%s)" > "$cooldown_file"
}

# Send alert via webhook
send_alert() {
    local container=$1
    local status=$2
    local message=$3
    local restart_count=$(get_restart_count "$container")
    
    local payload=$(cat <<EOF
{
  "agent": "health-monitor",
  "action": "health-alert",
  "status": "failure",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "details": {
    "container": "$container",
    "health_status": "$status",
    "message": "$message",
    "restart_count": $restart_count,
    "max_restarts": $MAX_RESTART_ATTEMPTS,
    "remediation_enabled": $REMEDIATE
  }
}
EOF
)
    
    if [ -n "$ALERT_WEBHOOK_URL" ] && [ "$ALERT_WEBHOOK_URL" != "__UNSET__" ]; then
        log "INFO" "Sending alert for $container to $ALERT_WEBHOOK_URL"
        curl -s -X POST "$ALERT_WEBHOOK_URL" \
            -H "Content-Type: application/json" \
            -d "$payload" > /dev/null 2>&1 || log "WARN" "Failed to send alert for $container"
    else
        log "WARN" "Alert webhook URL not configured, skipping alert for $container"
    fi
}

# Restart container
restart_container() {
    local container=$1
    local service_name=$(docker inspect --format='{{index .Config.Labels "com.docker.compose.service"}}' "$container" 2>/dev/null || echo "")
    local compose_file=$(docker inspect --format='{{index .Config.Labels "com.docker.compose.project.working_dir"}}' "$container" 2>/dev/null || echo "")
    
    log "INFO" "Attempting to restart container: $container"
    
    # Try to restart using docker compose if we can find the compose file
    if [ -n "$service_name" ] && [ -n "$compose_file" ] && [ -f "$compose_file/docker-compose.yml" ]; then
        log "INFO" "Restarting service $service_name using compose file: $compose_file/docker-compose.yml"
        cd "$compose_file"
        docker compose restart "$service_name" || docker restart "$container"
        cd "$INFRA_DIR"
    else
        # Fallback to direct docker restart
        log "INFO" "Restarting container directly: $container"
        docker restart "$container"
    fi
    
    increment_restart_count "$container"
    set_cooldown "$container"
    log "INFO" "Container $container restarted (attempt $(get_restart_count "$container")/$MAX_RESTART_ATTEMPTS)"
}

# Check container health
check_container_health() {
    local container=$1
    local health_status=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$container" 2>/dev/null || echo "unknown")
    local restart_count=$(get_restart_count "$container")
    
    # Skip if container is healthy or running (no health check)
    if [ "$health_status" = "healthy" ] || [ "$health_status" = "running" ]; then
        # Reset restart count if healthy
        if [ "$health_status" = "healthy" ]; then
            reset_restart_count "$container"
        fi
        return 0
    fi
    
    # Container is unhealthy
    log "WARN" "Container $container is $health_status (restart count: $restart_count/$MAX_RESTART_ATTEMPTS)"
    
    # Send alert
    send_alert "$container" "$health_status" "Container health check failed"
    
    # Attempt remediation if enabled
    if [ "$REMEDIATE" = true ] && [ "$ALERT_ONLY" = false ]; then
        # Check if in cooldown
        if is_in_cooldown "$container"; then
            log "INFO" "Container $container is in cooldown period, skipping restart"
            return 1
        fi
        
        # Check restart limit
        if [ $restart_count -ge $MAX_RESTART_ATTEMPTS ]; then
            log "ERROR" "Container $container has exceeded max restart attempts ($MAX_RESTART_ATTEMPTS), escalation required"
            send_alert "$container" "$health_status" "Max restart attempts exceeded, manual intervention required"
            return 1
        fi
        
        # Attempt restart
        restart_container "$container"
    fi
    
    return 1
}

# Main monitoring function
main() {
    log "INFO" "Starting health check monitoring (remediate=$REMEDIATE, alert_only=$ALERT_ONLY)"
    
    local unhealthy_count=0
    local total_count=0
    
    # Get all containers
    local containers
    if [ -n "$SERVICE_FILTER" ]; then
        containers=$(docker ps -a --filter "name=$SERVICE_FILTER" --format "{{.Names}}")
    else
        containers=$(docker ps -a --format "{{.Names}}")
    fi
    
    if [ -z "$containers" ]; then
        log "WARN" "No containers found"
        return 0
    fi
    
    echo ""
    echo "=========================================="
    echo "Health Check Monitoring"
    echo "Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    echo "=========================================="
    echo ""
    
    printf "%-40s %-15s %-10s\n" "CONTAINER" "STATUS" "RESTARTS"
    printf "%-40s %-15s %-10s\n" "----------------------------------------" "---------------" "----------"
    
    while IFS= read -r container; do
        if [ -z "$container" ]; then
            continue
        fi
        
        total_count=$((total_count + 1))
        local restart_count=$(get_restart_count "$container")
        local health_status=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$container" 2>/dev/null || echo "unknown")
        
        if check_container_health "$container"; then
            if [ "$health_status" = "healthy" ]; then
                printf "%-40s ${GREEN}%-15s${NC} %-10s\n" "$container" "$health_status" "$restart_count"
            else
                printf "%-40s ${GREEN}%-15s${NC} %-10s\n" "$container" "$health_status" "$restart_count"
            fi
        else
            unhealthy_count=$((unhealthy_count + 1))
            if [ "$health_status" = "unhealthy" ]; then
                printf "%-40s ${RED}%-15s${NC} ${YELLOW}%-10s${NC}\n" "$container" "$health_status" "$restart_count"
            else
                printf "%-40s ${YELLOW}%-15s${NC} %-10s\n" "$container" "$health_status" "$restart_count"
            fi
        fi
    done <<< "$containers"
    
    echo ""
    echo "=========================================="
    echo "Summary"
    echo "=========================================="
    echo "Total containers: $total_count"
    echo -e "Unhealthy containers: ${RED}$unhealthy_count${NC}"
    echo -e "Healthy containers: ${GREEN}$((total_count - unhealthy_count))${NC}"
    echo ""
    
    if [ $unhealthy_count -gt 0 ]; then
        log "WARN" "Found $unhealthy_count unhealthy container(s) out of $total_count total"
        return 1
    else
        log "INFO" "All containers healthy ($total_count total)"
        return 0
    fi
}

# Run main function
main "$@"

