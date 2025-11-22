#!/bin/bash
#
# Agent Trigger Script
# Triggers an agent via webhook or direct invocation
#
# Usage:
#   ./trigger-agent.sh <agent_name> [output_file] [trigger_type]
#
# Examples:
#   ./trigger-agent.sh status /tmp/status.json webhook
#   ./trigger-agent.sh bug-hunter /tmp/bugs.json direct
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_ENGINE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
INFRA_DIR="/root/infra"

agent_name="${1:-}"
output_file="${2:-}"
trigger_type="${3:-webhook}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
    cat << EOF
Usage: $0 <agent_name> [output_file] [trigger_type]

Available agents:
  status, bug-hunter, performance, security, architecture, docs, tests,
  refactor, release, development, ops, backstage, mcp, orchestrator

Trigger types:
  webhook  - Trigger via n8n webhook (default)
  direct   - Direct script invocation

Examples:
  $0 status /tmp/status.json webhook
  $0 bug-hunter /tmp/bugs.json direct
  $0 orchestrator /root/infra/orchestration/report.json webhook

EOF
    exit 1
}

if [ -z "$agent_name" ]; then
    echo -e "${RED}Error: Agent name required${NC}" >&2
    usage
fi

# Default output file if not specified
if [ -z "$output_file" ]; then
    output_file="/root/infra/orchestration/${agent_name}-$(date +%Y%m%d-%H%M%S).json"
fi

WEBHOOK_URL="${INFISICAL_WEBHOOK_URL:-https://n8n.freqkflag.co/webhook/agent-events}"

if [ "$trigger_type" = "webhook" ]; then
    echo -e "${BLUE}Triggering agent '$agent_name' via webhook...${NC}"
    echo -e "${YELLOW}Webhook URL: $WEBHOOK_URL${NC}"
    echo -e "${YELLOW}Output file: $output_file${NC}"
    
    response=$(curl -s -X POST "$WEBHOOK_URL" \
      -H "Content-Type: application/json" \
      -d "{
        \"agent\": \"$agent_name\",
        \"trigger\": \"manual\",
        \"output_file\": \"$output_file\",
        \"metadata\": {
          \"source\": \"trigger-agent-script\",
          \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
        }
      }")
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Agent triggered successfully${NC}"
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
    else
        echo -e "${RED}Failed to trigger agent${NC}" >&2
        exit 1
    fi
elif [ "$trigger_type" = "direct" ]; then
    echo -e "${BLUE}Invoking agent '$agent_name' directly...${NC}"
    echo -e "${YELLOW}Output file: $output_file${NC}"
    
    if [ -f "${AI_ENGINE_DIR}/scripts/invoke-agent.sh" ]; then
        "${AI_ENGINE_DIR}/scripts/invoke-agent.sh" "$agent_name" "$output_file"
    else
        echo -e "${RED}Error: invoke-agent.sh not found${NC}" >&2
        exit 1
    fi
else
    echo -e "${RED}Error: Invalid trigger type '$trigger_type'${NC}" >&2
    usage
fi

