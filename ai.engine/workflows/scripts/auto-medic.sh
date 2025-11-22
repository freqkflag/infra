#!/bin/bash
#
# Auto-Medic Script
# Automatically runs medic-agent when automation failures are detected
# Can be scheduled or triggered by automation monitoring
#
# Usage:
#   ./auto-medic.sh [trigger_reason]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_ENGINE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
INFRA_DIR="/root/infra"

trigger_reason="${1:-scheduled}"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Auto-Medic: AI Engine Automation Health Check${NC}"
echo "=========================================="
echo ""
echo -e "${YELLOW}Trigger: $trigger_reason${NC}"
echo ""

# Run health check first
echo -e "${BLUE}Running automation health check...${NC}"
health_output="/tmp/automation-health-$(date +%Y%m%d-%H%M%S).json"
"$AI_ENGINE_DIR/scripts/check-automation-health.sh" "$health_output"

# Check for critical issues
if command -v jq &> /dev/null && [ -f "$health_output" ]; then
    critical_issues=$(jq -r '[.n8n.issues[], .nodered.issues[], .webhook_endpoints.failing[]] | length' "$health_output" 2>/dev/null || echo "0")
    
    if [ "$critical_issues" -gt 0 ]; then
        echo -e "${RED}⚠ Found $critical_issues critical issues${NC}"
        echo ""
        echo "Running medic-agent to diagnose and fix..."
        echo ""
        
        # Run medic agent
        medic_output="/root/infra/orchestration/medic-$(date +%Y%m%d-%H%M%S).json"
        "$AI_ENGINE_DIR/scripts/invoke-agent.sh" medic "$medic_output"
        
        echo ""
        echo -e "${GREEN}✓ Medic agent completed${NC}"
        echo "  Output: $medic_output"
        
        # Check if fixes were executed
        if [ -f "$medic_output" ] && command -v jq &> /dev/null; then
            fixes_count=$(jq -r '.executed_fixes | length' "$medic_output" 2>/dev/null || echo "0")
            if [ "$fixes_count" -gt 0 ]; then
                echo -e "${GREEN}✓ Executed $fixes_count fixes${NC}"
            fi
        fi
    else
        echo -e "${GREEN}✓ No critical issues found${NC}"
    fi
else
    echo -e "${YELLOW}⚠ jq not available or health check failed - running medic anyway${NC}"
    echo ""
    
    # Run medic agent anyway
    medic_output="/root/infra/orchestration/medic-$(date +%Y%m%d-%H%M%S).json"
    "$AI_ENGINE_DIR/scripts/invoke-agent.sh" medic "$medic_output"
    
    echo ""
    echo -e "${GREEN}✓ Medic agent completed${NC}"
    echo "  Output: $medic_output"
fi

echo ""
echo -e "${GREEN}Auto-medic completed${NC}"

