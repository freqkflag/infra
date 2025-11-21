#!/bin/bash
#
# Release Agent Helper Script
# Quick invocation for release agent
#
# Usage:
#   ./release.sh [output_file]
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

echo -e "${BLUE}Invoking release agent...${NC}"
echo -e "${YELLOW}Purpose: Release readiness evaluator and release note drafter${NC}"
echo ""

cd "$INFRA_DIR" || exit 1

cat << EOF

========================================
CURSOR AI PROMPT:
========================================

Act as release agent. Evaluate /root/infra for release readiness, blockers, required changes, and draft release notes. Return strict JSON.

========================================
AGENT FILE REFERENCE:
========================================

$(cat "$AGENTS_DIR/release-agent.md")

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
echo -e "${BLUE}Agent file: $AGENTS_DIR/release-agent.md${NC}"

