#!/bin/bash
#
# List all available virtual agents
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$(cd "$SCRIPT_DIR/../agents" && pwd)"

echo "Available Infrastructure Virtual Agents:"
echo "========================================"
echo ""

for agent_file in "$AGENTS_DIR"/*-agent.md; do
    if [ -f "$agent_file" ]; then
        agent_name=$(basename "$agent_file" -agent.md)
        echo "  • $agent_name"
        echo "    File: $agent_file"
        echo ""
    fi
done

echo "Usage:"
echo "  ./invoke-agent.sh <agent_name> [output_file]"
echo ""
echo "Example:"
echo "  ./invoke-agent.sh bug-hunter /tmp/bugs.json"
echo ""

