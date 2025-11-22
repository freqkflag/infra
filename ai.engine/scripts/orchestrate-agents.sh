#!/bin/bash
#
# Multi-Agent Orchestration Script
# Orchestrates multiple agents in sequence with A2A protocol
#
# Usage:
#   ./orchestrate-agents.sh --agents <agent1,agent2,...> [--output <output_file>] [--session-timeout <seconds>]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="/root/infra"
INVOKE_SCRIPT="${SCRIPT_DIR}/invoke-agent.sh"
A2A_SESSION_SCRIPT="${SCRIPT_DIR}/a2a-session.sh"
SESSIONS_DIR="${INFRA_DIR}/.workspace/a2a-sessions"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Defaults
SESSION_TIMEOUT=3600
OUTPUT_FILE=""

# Parse arguments
AGENTS=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --agents)
            AGENTS="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --session-timeout)
            SESSION_TIMEOUT="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}" >&2
            exit 1
            ;;
    esac
done

if [ -z "$AGENTS" ]; then
    echo -e "${RED}Error: --agents required${NC}" >&2
    echo "Usage: $0 --agents <agent1,agent2,...> [--output <output_file>] [--session-timeout <seconds>]"
    exit 1
fi

# Create session
TASK_ID="task-$(date +%s)"
TASK_METADATA=$(cat <<EOF
{
  "type": "multi-agent-run",
  "priority": "normal",
  "timeout": $SESSION_TIMEOUT,
  "agents": [$(echo "$AGENTS" | sed "s/,/,\"/g" | sed "s/^/\"/g" | sed "s/$/\"/g" | sed "s/,/,\n    /g")]
}
EOF
)

SESSION_ID=$("$A2A_SESSION_SCRIPT" create "$TASK_ID" "$TASK_METADATA")
echo -e "${GREEN}[A2A] Created session: $SESSION_ID${NC}"

# Split agents
IFS=',' read -ra AGENT_ARRAY <<< "$AGENTS"

# Execute agents in sequence
PREVIOUS_OUTPUT=""
AGENT_OUTPUTS=()

for i in "${!AGENT_ARRAY[@]}"; do
    AGENT="${AGENT_ARRAY[$i]}"
    AGENT_OUTPUT="${INFRA_DIR}/.workspace/a2a-sessions/${SESSION_ID}-${AGENT}.json"
    
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Executing agent $((i+1))/${#AGENT_ARRAY[@]}: $AGENT${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    # Build invoke command
    INVOKE_CMD="$INVOKE_SCRIPT $AGENT $AGENT_OUTPUT --session $SESSION_ID"
    
    if [ -n "$PREVIOUS_OUTPUT" ] && [ -f "$PREVIOUS_OUTPUT" ]; then
        INVOKE_CMD="$INVOKE_CMD --context $PREVIOUS_OUTPUT"
    fi
    
    # Execute agent
    echo -e "${YELLOW}Command: $INVOKE_CMD${NC}"
    
    # Update session: agent executing
    "$A2A_SESSION_SCRIPT" update "$SESSION_ID" "$AGENT" "executing" "" || true
    
    # Note: Actual agent execution would happen here via Cursor AI
    # For now, we create the output file structure
    cat > "$AGENT_OUTPUT" <<EOF
{
  "agent_id": "$AGENT",
  "session_id": "$SESSION_ID",
  "status": "pending_execution",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "output": "Agent execution pending - provide agent file content to Cursor AI"
}
EOF
    
    echo -e "${YELLOW}Agent output file: $AGENT_OUTPUT${NC}"
    echo -e "${YELLOW}Provide agent file content to Cursor AI to execute:${NC}"
    echo -e "${YELLOW}  $INVOKE_CMD${NC}"
    
    # Wait for user confirmation (in automated mode, this would be async)
    read -p "Press Enter after agent execution completes..." || true
    
    # Update session: agent completed
    if [ -f "$AGENT_OUTPUT" ]; then
        "$A2A_SESSION_SCRIPT" update "$SESSION_ID" "$AGENT" "completed" "$AGENT_OUTPUT" || true
        PREVIOUS_OUTPUT="$AGENT_OUTPUT"
        AGENT_OUTPUTS+=("$AGENT_OUTPUT")
        echo -e "${GREEN}Agent $AGENT completed${NC}"
    else
        "$A2A_SESSION_SCRIPT" update "$SESSION_ID" "$AGENT" "failed" "" || true
        echo -e "${RED}Agent $AGENT failed${NC}"
    fi
done

# Aggregate results
if [ -n "$OUTPUT_FILE" ]; then
    echo -e "${BLUE}Aggregating results to: $OUTPUT_FILE${NC}"
    
    # Create aggregated output
    cat > "$OUTPUT_FILE" <<EOF
{
  "session_id": "$SESSION_ID",
  "task_id": "$TASK_ID",
  "agents": [$(IFS=','; echo "${AGENT_ARRAY[*]}" | sed "s/,/,\"/g" | sed "s/^/\"/g" | sed "s/$/\"/g" | sed "s/,/,\n    /g")],
  "agent_outputs": [$(IFS=','; printf '"%s"\n' "${AGENT_OUTPUTS[@]}" | sed 's/$/,/' | sed '$s/,$//' | sed 's/^/    /')],
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
    
    echo -e "${GREEN}Results aggregated to: $OUTPUT_FILE${NC}"
fi

echo -e "${GREEN}[A2A] Multi-agent orchestration completed${NC}"
echo -e "${BLUE}Session ID: $SESSION_ID${NC}"

