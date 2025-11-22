#!/bin/bash
#
# Medic Agent Helper Script
# Quick invocation for medic_agent
#
# Usage:
#   ./medic.sh [output_file]
#
# Example:
#   ./medic.sh /root/infra/orchestration/medic-$(date +%Y%m%d).json
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$(cd "$SCRIPT_DIR/../agents" && pwd)"
OUTPUT_FILE="${1:-/root/infra/orchestration/medic-$(date +%Y%m%d-%H%M%S).json}"

# Colors
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Medic Agent - AI Engine Automation Health Check${NC}"
echo "=========================================="
echo ""
echo -e "${YELLOW}Purpose: Self-diagnose, review, analyze, plan, set tasks, and fix AI Engine automation system${NC}"
echo ""
echo "Analyzing automation system health..."
echo ""

# Create output directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Agent prompt
cat << 'EOF'
Act as medic_agent. Analyze /root/infra/ai.engine automation system for missed triggers, failed flows, broken patterns, and automation failures. Diagnose issues, create fix plans, set tasks, and execute fixes automatically. Return strict JSON.

EOF

echo ""
echo -e "${BLUE}Agent file: $AGENTS_DIR/medic-agent.md${NC}"
echo -e "${BLUE}Output file: $OUTPUT_FILE${NC}"
echo ""
echo "=========================================="
echo ""
echo "Provide the agent file content to Cursor AI and save output to: $OUTPUT_FILE"
echo ""

