#!/bin/bash
#
# AI Engine Automation Setup Script
# Sets up all automation triggers, workflows, and scheduled tasks
#
# Usage:
#   ./setup-automation.sh [--dry-run] [--skip-webhooks] [--skip-scheduled]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOWS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
AI_ENGINE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
INFRA_DIR="/root/infra"

DRY_RUN="${1:-}"
SKIP_WEBHOOKS="${2:-}"
SKIP_SCHEDULED="${3:-}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

dry_run_log() {
    if [ "$DRY_RUN" = "--dry-run" ]; then
        echo -e "${BLUE}[DRY-RUN]${NC} $1"
    else
        log "$1"
    fi
}

# Step 1: Set up webhook endpoints in n8n
setup_n8n_webhooks() {
    if [ "$SKIP_WEBHOOKS" = "--skip-webhooks" ]; then
        warn "Skipping webhook setup"
        return
    fi

    log "Setting up n8n webhooks..."
    
    # Import n8n workflows
    if [ "$DRY_RUN" != "--dry-run" ]; then
        # Check if n8n is accessible
        if curl -s -f "https://n8n.freqkflag.co/healthz" > /dev/null 2>&1; then
            log "n8n is accessible, importing workflows..."
            # Import workflows via n8n API (requires authentication)
            # curl -X POST "https://n8n.freqkflag.co/api/v1/workflows" \
            #   -H "Authorization: Bearer ${N8N_API_TOKEN}" \
            #   -H "Content-Type: application/json" \
            #   -d @${WORKFLOWS_DIR}/n8n/agent-event-router.json
            log "Workflow import requires manual setup via n8n UI"
        else
            warn "n8n not accessible, skipping workflow import"
        fi
    else
        dry_run_log "Would import n8n workflows from ${WORKFLOWS_DIR}/n8n/"
    fi
}

# Step 2: Set up scheduled tasks (cron/systemd)
setup_scheduled_tasks() {
    if [ "$SKIP_SCHEDULED" = "--skip-scheduled" ]; then
        warn "Skipping scheduled tasks setup"
        return
    fi

    log "Setting up scheduled tasks..."

    local cron_file="/tmp/ai-engine-automation-cron"
    cat > "$cron_file" << 'EOF'
# AI Engine Automation - Scheduled Agent Runs
# Generated: $(date)

# Daily automation
0 0 * * * /root/infra/ai.engine/scripts/status.sh /root/infra/orchestration/status-$(date +\%Y\%m\%d).json >> /var/log/ai-engine-automation.log 2>&1
0 6 * * * /root/infra/ai.engine/scripts/backstage.sh /root/infra/orchestration/backstage-$(date +\%Y\%m\%d).json >> /var/log/ai-engine-automation.log 2>&1

# Hourly automation
0 * * * * /root/infra/ai.engine/scripts/ops.sh /root/infra/orchestration/ops-$(date +\%Y\%m\%d-\%H\%M).json >> /var/log/ai-engine-automation.log 2>&1

# Weekly automation
0 2 * * 0 /root/infra/ai.engine/scripts/orchestrator.sh /root/infra/orchestration/orchestration-$(date +\%Y\%m\%d).json >> /var/log/ai-engine-automation.log 2>&1
0 3 * * 1 /root/infra/ai.engine/scripts/security.sh /root/infra/orchestration/security-$(date +\%Y\%m\%d).json >> /var/log/ai-engine-automation.log 2>&1
0 4 * * 3 /root/infra/ai.engine/scripts/performance.sh /root/infra/orchestration/performance-$(date +\%Y\%m\%d).json >> /var/log/ai-engine-automation.log 2>&1
0 5 * * 5 /root/infra/ai.engine/scripts/docs.sh /root/infra/orchestration/docs-$(date +\%Y\%m\%d).json >> /var/log/ai-engine-automation.log 2>&1

# Monthly automation
0 6 1 * * /root/infra/ai.engine/scripts/refactor.sh /root/infra/orchestration/refactor-$(date +\%Y\%m).json >> /var/log/ai-engine-automation.log 2>&1
0 7 15 * * /root/infra/ai.engine/scripts/mcp.sh /root/infra/orchestration/mcp-$(date +\%Y\%m).json >> /var/log/ai-engine-automation.log 2>&1
EOF

    if [ "$DRY_RUN" != "--dry-run" ]; then
        # Check if cron entries already exist
        if crontab -l 2>/dev/null | grep -q "ai.engine/scripts/status.sh"; then
            warn "Cron entries already exist, skipping installation"
        else
            log "Installing cron entries..."
            (crontab -l 2>/dev/null; cat "$cron_file") | crontab -
            log "Cron entries installed successfully"
        fi
    else
        dry_run_log "Would install cron entries from $cron_file"
        cat "$cron_file"
    fi

    rm -f "$cron_file"
}

# Step 3: Set up event monitoring
setup_event_monitoring() {
    log "Setting up event monitoring..."

    local monitor_script="/usr/local/bin/docker-event-monitor.sh"
    
    if [ "$DRY_RUN" != "--dry-run" ]; then
        cat > "$monitor_script" << 'EOF'
#!/bin/bash
# Docker Event Monitor - Triggers agents on Docker events

WEBHOOK_URL="${INFISICAL_WEBHOOK_URL:-https://n8n.freqkflag.co/webhook/docker-events}"

docker events --filter 'event=die' \
  --filter 'event=health_status: unhealthy' \
  --filter 'event=start' \
  --format '{{json .}}' | while read event; do
    
    # Extract container name and event type
    container=$(echo "$event" | jq -r '.Actor.Attributes.name // .Actor.ID')
    event_type=$(echo "$event" | jq -r '.Action')
    
    # Trigger ops-agent on unhealthy events
    if [ "$event_type" = "health_status: unhealthy" ] || [ "$event_type" = "die" ]; then
        curl -X POST "$WEBHOOK_URL" \
          -H "Content-Type: application/json" \
          -d "{\"event\":\"$event_type\",\"container\":\"$container\",\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"trigger_agent\":\"ops\"}" \
          -f -s >/dev/null 2>&1 || echo "Failed to send webhook"
    fi
done
EOF

        chmod +x "$monitor_script"
        log "Event monitoring script created at $monitor_script"
        
        # Create systemd service for event monitoring
        if [ ! -f "/etc/systemd/system/docker-event-monitor.service" ]; then
            cat > /etc/systemd/system/docker-event-monitor.service << 'EOF'
[Unit]
Description=Docker Event Monitor for AI Engine Automation
After=docker.service
Requires=docker.service

[Service]
Type=simple
ExecStart=/usr/local/bin/docker-event-monitor.sh
Restart=always
RestartSec=10
Environment="INFISICAL_WEBHOOK_URL=https://n8n.freqkflag.co/webhook/docker-events"

[Install]
WantedBy=multi-user.target
EOF

            systemctl daemon-reload
            systemctl enable docker-event-monitor.service
            log "Docker event monitor service created and enabled"
            warn "Start the service manually: systemctl start docker-event-monitor"
        else
            warn "Docker event monitor service already exists"
        fi
    else
        dry_run_log "Would create event monitoring script at $monitor_script"
        dry_run_log "Would create systemd service for event monitoring"
    fi
}

# Step 4: Set up orchestration directory
setup_orchestration_directory() {
    log "Setting up orchestration directory..."
    
    if [ "$DRY_RUN" != "--dry-run" ]; then
        mkdir -p "${INFRA_DIR}/orchestration"
        chmod 755 "${INFRA_DIR}/orchestration"
        log "Orchestration directory created at ${INFRA_DIR}/orchestration"
    else
        dry_run_log "Would create orchestration directory at ${INFRA_DIR}/orchestration"
    fi
}

# Step 5: Configure webhook URL in Infisical
configure_webhook_url() {
    log "Configuring webhook URL in Infisical..."
    
    if [ "$DRY_RUN" != "--dry-run" ]; then
        # Check if INFISICAL_WEBHOOK_URL is already set
        if infisical secrets get --env prod --path /prod INFISICAL_WEBHOOK_URL > /dev/null 2>&1; then
            warn "INFISICAL_WEBHOOK_URL already set in Infisical"
        else
            log "Setting INFISICAL_WEBHOOK_URL in Infisical..."
            infisical secrets set --env prod --path /prod INFISICAL_WEBHOOK_URL="https://n8n.freqkflag.co/webhook/agent-events" || warn "Failed to set webhook URL (requires authentication)"
        fi
    else
        dry_run_log "Would set INFISICAL_WEBHOOK_URL in Infisical"
    fi
}

# Main execution
main() {
    log "Starting AI Engine automation setup..."
    log "Script directory: $SCRIPT_DIR"
    log "Workflows directory: $WORKFLOWS_DIR"
    log "AI Engine directory: $AI_ENGINE_DIR"
    
    if [ "$DRY_RUN" = "--dry-run" ]; then
        warn "DRY RUN MODE - No changes will be made"
    fi
    
    setup_orchestration_directory
    setup_n8n_webhooks
    setup_scheduled_tasks
    setup_event_monitoring
    configure_webhook_url
    
    log "Automation setup complete!"
    
    if [ "$DRY_RUN" != "--dry-run" ]; then
        log ""
        log "Next steps:"
        log "1. Import n8n workflows from ${WORKFLOWS_DIR}/n8n/ via n8n UI"
        log "2. Import Node-RED flows from ${WORKFLOWS_DIR}/nodered/ via Node-RED UI"
        log "3. Start docker-event-monitor service: systemctl start docker-event-monitor"
        log "4. Test webhook: curl -X POST https://n8n.freqkflag.co/webhook/agent-events -d '{\"agent\":\"status\",\"trigger\":\"test\"}'"
        log "5. Verify cron jobs: crontab -l | grep ai.engine"
    fi
}

main "$@"

