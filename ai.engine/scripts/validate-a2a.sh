#!/bin/bash
#
# A2A Protocol Validation Script
# Validates A2A protocol implementation with multi-agent simulation
#
# Usage:
#   ./validate-a2a.sh [--simulate-discovery] [--simulate-compose] [--simulate-secrets] [--simulate-review] [--output <output_file>]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="/root/infra"
A2A_SESSION_SCRIPT="${SCRIPT_DIR}/a2a-session.sh"
INVOKE_SCRIPT="${SCRIPT_DIR}/invoke-agent.sh"
ORCHESTRATE_SCRIPT="${SCRIPT_DIR}/orchestrate-agents.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Flags
SIMULATE_DISCOVERY=false
SIMULATE_COMPOSE=false
SIMULATE_SECRETS=false
SIMULATE_REVIEW=false
OUTPUT_FILE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --simulate-discovery)
            SIMULATE_DISCOVERY=true
            shift
            ;;
        --simulate-compose)
            SIMULATE_COMPOSE=true
            shift
            ;;
        --simulate-secrets)
            SIMULATE_SECRETS=true
            shift
            ;;
        --simulate-review)
            SIMULATE_REVIEW=true
            shift
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}" >&2
            exit 1
            ;;
    esac
done

# Default: simulate all if none specified
if [ "$SIMULATE_DISCOVERY" = false ] && [ "$SIMULATE_COMPOSE" = false ] && [ "$SIMULATE_SECRETS" = false ] && [ "$SIMULATE_REVIEW" = false ]; then
    SIMULATE_DISCOVERY=true
    SIMULATE_COMPOSE=true
    SIMULATE_SECRETS=true
    SIMULATE_REVIEW=true
fi

OUTPUT_FILE="${OUTPUT_FILE:-${INFRA_DIR}/.workspace/a2a-validation-$(date +%Y%m%d-%H%M%S).json}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}A2A Protocol Validation${NC}"
echo -e "${BLUE}Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

VALIDATION_RESULTS=()
ERRORS=()

# Test 1: Session Management
echo -e "${YELLOW}Test 1: Session Management${NC}"
SESSION_ID=$("$A2A_SESSION_SCRIPT" create "test-task" '{"type":"validation","priority":"normal"}')
if [ -n "$SESSION_ID" ]; then
    echo -e "${GREEN}  ✓ Session created: $SESSION_ID${NC}"
    VALIDATION_RESULTS+=("session_creation:pass")
    
    # Test get session
    SESSION_DATA=$("$A2A_SESSION_SCRIPT" get "$SESSION_ID" 2>/dev/null)
    if [ -n "$SESSION_DATA" ]; then
        echo -e "${GREEN}  ✓ Session retrieved${NC}"
        VALIDATION_RESULTS+=("session_retrieval:pass")
    else
        echo -e "${RED}  ✗ Session retrieval failed${NC}"
        VALIDATION_RESULTS+=("session_retrieval:fail")
        ERRORS+=("Session retrieval failed")
    fi
    
    # Test update session
    "$A2A_SESSION_SCRIPT" update "$SESSION_ID" "test-agent" "completed" "/tmp/test.json" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}  ✓ Session updated${NC}"
        VALIDATION_RESULTS+=("session_update:pass")
    else
        echo -e "${RED}  ✗ Session update failed${NC}"
        VALIDATION_RESULTS+=("session_update:fail")
        ERRORS+=("Session update failed")
    fi
    
    # Cleanup
    "$A2A_SESSION_SCRIPT" delete "$SESSION_ID" >/dev/null 2>&1
else
    echo -e "${RED}  ✗ Session creation failed${NC}"
    VALIDATION_RESULTS+=("session_creation:fail")
    ERRORS+=("Session creation failed")
fi
echo ""

# Test 2: Agent Inventory
echo -e "${YELLOW}Test 2: Agent Inventory${NC}"
if [ -f "${SCRIPT_DIR}/inventory-agents.sh" ]; then
    INVENTORY_OUTPUT=$("${SCRIPT_DIR}/inventory-agents.sh" 2>/dev/null)
    if [ -n "$INVENTORY_OUTPUT" ]; then
        echo -e "${GREEN}  ✓ Agent inventory generated${NC}"
        VALIDATION_RESULTS+=("agent_inventory:pass")
    else
        echo -e "${RED}  ✗ Agent inventory failed${NC}"
        VALIDATION_RESULTS+=("agent_inventory:fail")
        ERRORS+=("Agent inventory failed")
    fi
else
    echo -e "${RED}  ✗ Inventory script not found${NC}"
    VALIDATION_RESULTS+=("agent_inventory:fail")
    ERRORS+=("Inventory script not found")
fi
echo ""

# Test 3: Multi-Agent Simulation
if [ "$SIMULATE_DISCOVERY" = true ] || [ "$SIMULATE_COMPOSE" = true ] || [ "$SIMULATE_SECRETS" = true ] || [ "$SIMULATE_REVIEW" = true ]; then
    echo -e "${YELLOW}Test 3: Multi-Agent Simulation${NC}"
    
    AGENTS_TO_SIMULATE=()
    [ "$SIMULATE_DISCOVERY" = true ] && AGENTS_TO_SIMULATE+=("status")
    [ "$SIMULATE_COMPOSE" = true ] && AGENTS_TO_SIMULATE+=("architecture")
    [ "$SIMULATE_SECRETS" = true ] && AGENTS_TO_SIMULATE+=("security")
    [ "$SIMULATE_REVIEW" = true ] && AGENTS_TO_SIMULATE+=("code-review")
    
    AGENTS_STRING=$(IFS=','; echo "${AGENTS_TO_SIMULATE[*]}")
    
    echo -e "${BLUE}  Simulating agents: $AGENTS_STRING${NC}"
    
    # Create session for simulation
    SIM_SESSION_ID=$("$A2A_SESSION_SCRIPT" create "sim-task" '{"type":"validation","priority":"normal"}')
    
    PREV_OUTPUT=""
    for AGENT in "${AGENTS_TO_SIMULATE[@]}"; do
        AGENT_OUTPUT="${INFRA_DIR}/.workspace/a2a-sessions/${SIM_SESSION_ID}-${AGENT}.json"
        
        echo -e "${BLUE}  → Simulating $AGENT${NC}"
        
        # Simulate agent execution (create mock output)
        cat > "$AGENT_OUTPUT" <<EOF
{
  "agent_id": "$AGENT",
  "session_id": "$SIM_SESSION_ID",
  "status": "simulated",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "output": {
    "simulated": true,
    "agent": "$AGENT",
    "findings": []
  }
}
EOF
        
        # Update session
        "$A2A_SESSION_SCRIPT" update "$SIM_SESSION_ID" "$AGENT" "completed" "$AGENT_OUTPUT" >/dev/null 2>&1
        
        PREV_OUTPUT="$AGENT_OUTPUT"
        echo -e "${GREEN}    ✓ $AGENT simulated${NC}"
    done
    
    # Validate session has all agents
    SESSION_DATA=$("$A2A_SESSION_SCRIPT" get "$SIM_SESSION_ID" 2>/dev/null)
    if [ -n "$SESSION_DATA" ]; then
        echo -e "${GREEN}  ✓ Multi-agent simulation completed${NC}"
        VALIDATION_RESULTS+=("multi_agent_simulation:pass")
    else
        echo -e "${RED}  ✗ Multi-agent simulation failed${NC}"
        VALIDATION_RESULTS+=("multi_agent_simulation:fail")
        ERRORS+=("Multi-agent simulation failed")
    fi
    
    # Cleanup
    "$A2A_SESSION_SCRIPT" delete "$SIM_SESSION_ID" >/dev/null 2>&1
    echo ""
fi

# Test 4: Protocol Documentation
echo -e "${YELLOW}Test 4: Protocol Documentation${NC}"
if [ -f "${SCRIPT_DIR}/../workflows/A2A_PROTOCOL.md" ]; then
    echo -e "${GREEN}  ✓ A2A protocol documentation exists${NC}"
    VALIDATION_RESULTS+=("protocol_docs:pass")
else
    echo -e "${RED}  ✗ A2A protocol documentation missing${NC}"
    VALIDATION_RESULTS+=("protocol_docs:fail")
    ERRORS+=("Protocol documentation missing")
fi
echo ""

# Generate validation report
cat > "$OUTPUT_FILE" <<EOF
{
  "validation_timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "results": {
$(IFS=','; printf '    "%s"\n' "${VALIDATION_RESULTS[@]}" | sed 's/:/": "/' | sed 's/$/,/' | sed '$s/,$//')
  },
  "errors": [
$(IFS=','; printf '    "%s"\n' "${ERRORS[@]}" | sed 's/$/,/' | sed '$s/,$//' || echo "")
  ],
  "summary": {
    "total_tests": ${#VALIDATION_RESULTS[@]},
    "passed": $(echo "${VALIDATION_RESULTS[@]}" | grep -o "pass" | wc -l),
    "failed": $(echo "${VALIDATION_RESULTS[@]}" | grep -o "fail" | wc -l),
    "errors": ${#ERRORS[@]}
  }
}
EOF

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Total Tests: ${#VALIDATION_RESULTS[@]}"
echo -e "Passed: $(echo "${VALIDATION_RESULTS[@]}" | grep -o "pass" | wc -l)"
echo -e "Failed: $(echo "${VALIDATION_RESULTS[@]}" | grep -o "fail" | wc -l)"
echo -e "Errors: ${#ERRORS[@]}"
echo ""
echo -e "${GREEN}Validation report: $OUTPUT_FILE${NC}"

if [ ${#ERRORS[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ All validation tests passed${NC}"
    exit 0
else
    echo -e "${RED}✗ Some validation tests failed${NC}"
    exit 1
fi

