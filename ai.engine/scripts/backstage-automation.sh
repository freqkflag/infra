#!/bin/bash
#
# Backstage Agent Automation Script
# Automated triggers for Backstage agent health checks and catalog analysis
#
# Usage:
#   ./backstage-automation.sh [daily|pre-deploy|catalog-sync|health-check]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="/root/infra"
REPORTS_DIR="${INFRA_DIR}/ai.engine/reports"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Create reports directory if it doesn't exist
mkdir -p "$REPORTS_DIR"

# Function to run backstage agent
run_backstage_agent() {
    local output_file="$1"
    local description="$2"
    
    echo -e "${BLUE}Running Backstage agent: $description${NC}"
    echo -e "${YELLOW}Output: $output_file${NC}"
    
    cd "$INFRA_DIR" || exit 1
    
    # Note: This script prepares the command for manual execution or CI/CD
    # In a CI/CD environment, you would invoke the agent via Cursor AI API or similar
    cat << EOF

========================================
BACKSTAGE AGENT AUTOMATION
========================================

Description: $description
Output File: $output_file
Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

To execute:
1. Provide the following prompt to Cursor AI:
   "Act as backstage_agent. Analyze /root/infra/services/backstage for Backstage service health, entity catalog status, plugin configurations, and actionable insights. Return strict JSON."

2. Save the JSON response to: $output_file

3. For automated execution, integrate with:
   - n8n workflow: POST to n8n webhook with agent prompt
   - CI/CD pipeline: Use Cursor AI API or similar
   - Scheduled task: Cron job with agent invocation

Agent File: ${SCRIPT_DIR}/../agents/backstage-agent.md

========================================

EOF

    echo -e "${GREEN}Automation command prepared.${NC}"
    echo -e "${YELLOW}For full automation, integrate with n8n workflow or CI/CD pipeline.${NC}"
}

# Main execution
case "${1:-health-check}" in
    daily)
        output_file="${REPORTS_DIR}/backstage-daily-$(date +%Y%m%d-%H%M%S).json"
        run_backstage_agent "$output_file" "Daily Backstage health check and catalog analysis"
        ;;
    pre-deploy)
        output_file="${REPORTS_DIR}/backstage-pre-deploy-$(date +%Y%m%d-%H%M%S).json"
        run_backstage_agent "$output_file" "Pre-deployment Backstage validation"
        ;;
    catalog-sync)
        output_file="${REPORTS_DIR}/backstage-catalog-sync-$(date +%Y%m%d-%H%M%S).json"
        run_backstage_agent "$output_file" "Backstage catalog synchronization check"
        ;;
    health-check)
        output_file="${REPORTS_DIR}/backstage-health-$(date +%Y%m%d-%H%M%S).json"
        run_backstage_agent "$output_file" "Backstage service health check"
        ;;
    *)
        echo -e "${RED}Error: Unknown automation type '$1'${NC}" >&2
        echo "Usage: $0 [daily|pre-deploy|catalog-sync|health-check]"
        exit 1
        ;;
esac

