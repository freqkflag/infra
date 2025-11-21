#!/bin/bash
#
# Status Agent Helper Script
# Quick invocation for status_agent
#
# Usage:
#   ./status.sh [output_file]
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

output_file="${1:-}"

echo -e "${BLUE}Invoking status_agent...${NC}"
echo -e "${YELLOW}Purpose: Global project status and next steps tracker${NC}"
echo ""

cd "$INFRA_DIR" || exit 1

cat << EOF

========================================
CURSOR AI PROMPT:
========================================

Act as status_agent. Analyze /root/infra. Return global project status with architecture overview, current phase, overall health, and key findings in strict JSON.

========================================
AGENT FILE REFERENCE:
========================================

$(cat "$AGENTS_DIR/status-agent.md")

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
echo -e "${BLUE}Agent file: $AGENTS_DIR/status-agent.md${NC}"

