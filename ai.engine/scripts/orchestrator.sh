#!/bin/bash
#
# Orchestrator Agent Helper Script
# Quick invocation for orchestrator agent
#
# Usage:
#   ./orchestrator.sh [output_file]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$(cd "$SCRIPT_DIR/../agents" && pwd)"
INFRA_DIR="/root/infra"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

output_file="${1:-/root/infra/orchestration-report.json}"

echo -e "${BLUE}Invoking orchestrator agent...${NC}"
echo -e "${YELLOW}Purpose: Multi-agent orchestrator coordinating all agents${NC}"
echo ""

cd "$INFRA_DIR" || exit 1

cat << EOF

========================================
CURSOR AI PROMPT:
========================================

Use the Multi-Agent Orchestrator preset. Focus on /root/infra first, then repo-wide context. Return a single strict JSON object with aggregated output from all agents.

========================================
AGENT FILE REFERENCE:
========================================

$(cat "$AGENTS_DIR/orchestrator-agent.md")

========================================
END PROMPT
========================================

EOF

if [ -n "$output_file" ]; then
    echo -e "${GREEN}Save output to: $output_file${NC}"
    echo -e "${YELLOW}Provide the prompt above to Cursor AI and save the JSON response to the specified file.${NC}"
else
    echo -e "${GREEN}Provide the prompt above to Cursor AI.${NC}"
fi

echo ""
echo -e "${BLUE}Agent file: $AGENTS_DIR/orchestrator-agent.md${NC}"

