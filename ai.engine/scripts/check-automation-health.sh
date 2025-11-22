#!/bin/bash
#
# Automation Health Check Script
# Checks AI Engine automation system health and reports issues
# Used by medic-agent for diagnosis
#
# Usage:
#   ./check-automation-health.sh [output_file]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_ENGINE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INFRA_DIR="/root/infra"
OUTPUT_FILE="${1:-/tmp/automation-health-$(date +%Y%m%d-%H%M%S).json}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Initialize JSON output
json_output="{"

check_n8n() {
    local n8n_url="https://n8n.freqkflag.co"
    local accessible=false
    local workflows_active=0
    local workflows_inactive=0
    local webhook_endpoints=()
    local issues=()
    
    if curl -s -f "$n8n_url" > /dev/null 2>&1; then
        accessible=true
        # Try to get workflow status via API (if API key available)
        if [ -n "${N8N_API_KEY:-}" ]; then
            local workflows=$(curl -s -H "X-N8N-API-KEY: $N8N_API_KEY" "$n8n_url/api/v1/workflows" 2>/dev/null || echo "[]")
            workflows_active=$(echo "$workflows" | jq '[.[] | select(.active == true)] | length' 2>/dev/null || echo "0")
            workflows_inactive=$(echo "$workflows" | jq '[.[] | select(.active == false)] | length' 2>/dev/null || echo "0")
        else
            issues+=("N8N_API_KEY not set - cannot check workflow status")
        fi
    else
        accessible=false
        issues+=("n8n not accessible at $n8n_url")
    fi
    
    json_output+="\"n8n\": {\"accessible\": $accessible, \"workflows_active\": $workflows_active, \"workflows_inactive\": $workflows_inactive, \"issues\": $(echo "${issues[@]}" | jq -R -s -c 'split("\n") | map(select(. != ""))')},"
}

check_nodered() {
    local nodered_url="https://nodered.freqkflag.co"
    local accessible=false
    local flows_active=0
    local flows_inactive=0
    local issues=()
    
    if curl -s -f "$nodered_url" > /dev/null 2>&1; then
        accessible=true
    else
        accessible=false
        issues+=("Node-RED not accessible at $nodered_url")
    fi
    
    json_output+="\"nodered\": {\"accessible\": $accessible, \"flows_active\": $flows_active, \"flows_inactive\": $flows_inactive, \"issues\": $(echo "${issues[@]}" | jq -R -s -c 'split("\n") | map(select(. != ""))')},"
}

check_scheduled_tasks() {
    local cron_jobs="[]"
    local systemd_timers="[]"
    local missing_tasks=()
    local failed_tasks=()
    
    # Check cron jobs
    if command -v crontab &> /dev/null; then
        cron_jobs=$(crontab -l 2>/dev/null | grep -i "ai.engine\|orchestration" | jq -R -s -c 'split("\n") | map(select(. != ""))' || echo "[]")
    fi
    
    # Check systemd timers
    if systemctl list-timers --all --no-pager 2>/dev/null | grep -i "ai.engine\|orchestration" > /dev/null; then
        systemd_timers=$(systemctl list-timers --all --no-pager 2>/dev/null | grep -i "ai.engine\|orchestration" | jq -R -s -c 'split("\n") | map(select(. != ""))' || echo "[]")
    fi
    
    # Expected scheduled tasks (from AUTOMATION_WORKFLOWS.md)
    local expected_tasks=(
        "status.*daily"
        "backstage.*daily"
        "ops.*hourly"
        "orchestrator.*weekly"
        "security.*weekly"
    )
    
    for task in "${expected_tasks[@]}"; do
        if ! crontab -l 2>/dev/null | grep -q "$task" && ! systemctl list-timers --all --no-pager 2>/dev/null | grep -q "$task"; then
            missing_tasks+=("$task")
        fi
    done
    
    json_output+="\"scheduled_tasks\": {\"cron_jobs\": $cron_jobs, \"systemd_timers\": $systemd_timers, \"missing_tasks\": $(echo "${missing_tasks[@]}" | jq -R -s -c 'split("\n") | map(select(. != ""))'), \"failed_tasks\": []},"
}

check_webhook_endpoints() {
    local registered=()
    local responding=()
    local failing=()
    
    local endpoints=(
        "https://n8n.freqkflag.co/webhook/agent-events"
        "https://n8n.freqkflag.co/webhook/health-alert"
    )
    
    for endpoint in "${endpoints[@]}"; do
        registered+=("$endpoint")
        if curl -s -f -X POST "$endpoint" -H "Content-Type: application/json" -d '{"test":true}' > /dev/null 2>&1; then
            responding+=("$endpoint")
        else
            failing+=("$endpoint")
        fi
    done
    
    json_output+="\"webhook_endpoints\": {\"registered\": $(echo "${registered[@]}" | jq -R -s -c 'split("\n") | map(select(. != ""))'), \"responding\": $(echo "${responding[@]}" | jq -R -s -c 'split("\n") | map(select(. != ""))'), \"failing\": $(echo "${failing[@]}" | jq -R -s -c 'split("\n") | map(select(. != ""))')},"
}

check_agent_scripts() {
    local total=0
    local executable=0
    local missing=()
    local broken=()
    
    local scripts=(
        "invoke-agent.sh"
        "status.sh"
        "bug-hunter.sh"
        "security.sh"
        "medic.sh"
        "post-agent-automation.sh"
    )
    
    for script in "${scripts[@]}"; do
        ((total++))
        local script_path="$AI_ENGINE_DIR/scripts/$script"
        if [ -f "$script_path" ]; then
            if [ -x "$script_path" ]; then
                ((executable++))
            else
                broken+=("$script (not executable)")
            fi
        else
            missing+=("$script")
        fi
    done
    
    json_output+="\"agent_scripts\": {\"total\": $total, \"executable\": $executable, \"missing\": $(echo "${missing[@]}" | jq -R -s -c 'split("\n") | map(select(. != ""))'), \"broken\": $(echo "${broken[@]}" | jq -R -s -c 'split("\n") | map(select(. != ""))')},"
}

check_orchestration_directory() {
    local orchestration_dir="/root/infra/orchestration"
    local exists=false
    local writable=false
    local recent_files=0
    
    if [ -d "$orchestration_dir" ]; then
        exists=true
        if [ -w "$orchestration_dir" ]; then
            writable=true
        fi
        # Count files from last 24 hours
        recent_files=$(find "$orchestration_dir" -type f -mtime -1 2>/dev/null | wc -l || echo "0")
    fi
    
    json_output+="\"orchestration_directory\": {\"exists\": $exists, \"writable\": $writable, \"recent_files\": $recent_files},"
}

check_recent_agent_runs() {
    local orchestration_dir="/root/infra/orchestration"
    local recent_runs=()
    
    if [ -d "$orchestration_dir" ]; then
        recent_runs=$(find "$orchestration_dir" -type f -name "*.json" -mtime -1 -exec basename {} \; 2>/dev/null | jq -R -s -c 'split("\n") | map(select(. != ""))' || echo "[]")
    fi
    
    json_output+="\"recent_agent_runs\": $recent_runs"
}

main() {
    echo -e "${BLUE}AI Engine Automation Health Check${NC}"
    echo "=========================================="
    echo ""
    
    check_n8n
    check_nodered
    check_scheduled_tasks
    check_webhook_endpoints
    check_agent_scripts
    check_orchestration_directory
    check_recent_agent_runs
    
    # Close JSON
    json_output+="}"
    
    # Output JSON
    echo "$json_output" | jq '.' > "$OUTPUT_FILE" 2>/dev/null || echo "$json_output" > "$OUTPUT_FILE"
    
    echo -e "${GREEN}Health check completed${NC}"
    echo "Output: $OUTPUT_FILE"
    echo ""
    
    # Display summary
    echo "Summary:"
    echo "$json_output" | jq '.' 2>/dev/null || cat "$OUTPUT_FILE"
}

main "$@"

