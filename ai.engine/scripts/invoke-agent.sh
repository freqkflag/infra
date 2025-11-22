#!/bin/bash
#
# Infrastructure Virtual Agent Invoker (A2A Enhanced)
# Invokes specialized virtual agents for infrastructure analysis with A2A protocol support
#
# Usage:
#   ./invoke-agent.sh <agent_name> [output_file] [--session <session_id>] [--context <context_file>] [--mcp-tools <tools>]
#
# Available agents:
#   status, bug-hunter, performance, security, architecture, docs, tests, refactor, release, code-review, backstage, git, orchestrator
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$(cd "$SCRIPT_DIR/../agents" && pwd)"
INFRA_DIR="/root/infra"
A2A_SESSION_SCRIPT="${SCRIPT_DIR}/a2a-session.sh"
SESSIONS_DIR="${INFRA_DIR}/.workspace/a2a-sessions"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print usage
usage() {
    cat << EOF
Usage: $0 <agent_name> [output_file] [--session <session_id>] [--context <context_file>] [--mcp-tools <tools>]

Available agents:
  status          - Global project status and next steps
  bug-hunter      - Bug scanner (errors, smells, instability)
  performance     - Performance hotspots and optimizations
  security        - Security vulnerabilities and misconfigurations
  architecture    - Architecture analysis and refactoring
  docs            - Documentation gaps and structure
  tests           - Test coverage and missing tests
  refactor        - Refactoring targets and duplication
  release         - Release readiness and blockers
  code-review     - Code quality review (best practices, maintainability, standards)
  backstage       - Backstage developer portal management
  git             - Git operations and repository management
  orchestrator    - Full multi-agent orchestration

A2A Protocol Options:
  --session <session_id>    - Use existing A2A session
  --context <context_file>  - Pass context from previous agents
  --mcp-tools <tools>       - Comma-separated list of MCP tools to use

Examples:
  $0 status
  $0 bug-hunter /tmp/bugs.json
  $0 orchestrator /root/infra/orchestration-report.json
  $0 status /tmp/status.json --session a2a-20251122-abc123 --context /tmp/discovery-results.json
  $0 security /tmp/security.json --mcp-tools infisical,cloudflare

EOF
    exit 1
}

# Validate agent name
validate_agent() {
    local agent="$1"
    local agent_file=""
    
    case "$agent" in
        status)
            agent_file="${AGENTS_DIR}/status-agent.md"
            ;;
        bug-hunter)
            agent_file="${AGENTS_DIR}/bug-hunter-agent.md"
            ;;
        performance)
            agent_file="${AGENTS_DIR}/performance-agent.md"
            ;;
        security)
            agent_file="${AGENTS_DIR}/security-agent.md"
            ;;
        architecture)
            agent_file="${AGENTS_DIR}/architecture-agent.md"
            ;;
        docs)
            agent_file="${AGENTS_DIR}/docs-agent.md"
            ;;
        tests)
            agent_file="${AGENTS_DIR}/tests-agent.md"
            ;;
        refactor)
            agent_file="${AGENTS_DIR}/refactor-agent.md"
            ;;
        release)
            agent_file="${AGENTS_DIR}/release-agent.md"
            ;;
        code-review)
            agent_file="${AGENTS_DIR}/code-review-agent.md"
            ;;
        backstage)
            agent_file="${AGENTS_DIR}/backstage-agent.md"
            ;;
        git)
            agent_file="${AGENTS_DIR}/git-agent.md"
            ;;
        orchestrator)
            agent_file="${AGENTS_DIR}/orchestrator-agent.md"
            ;;
        *)
            echo -e "${RED}Error: Unknown agent '$agent'${NC}" >&2
            usage
            ;;
    esac
    
    if [ ! -f "$agent_file" ]; then
        echo -e "${RED}Error: Agent file not found: $agent_file${NC}" >&2
        exit 1
    fi
    
    echo "$agent_file"
}

# Parse A2A arguments
parse_a2a_args() {
    local session_id=""
    local context_file=""
    local mcp_tools=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --session)
                session_id="$2"
                shift 2
                ;;
            --context)
                context_file="$2"
                shift 2
                ;;
            --mcp-tools)
                mcp_tools="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    echo "$session_id|$context_file|$mcp_tools"
}

# Perform A2A handshake
a2a_handshake() {
    local session_id="$1"
    local agent_id="$2"
    local session_file="${SESSIONS_DIR}/${session_id}.json"
    
    if [ ! -f "$session_file" ]; then
        echo -e "${YELLOW}Warning: Session not found, creating new session${NC}" >&2
        session_id=$("$A2A_SESSION_SCRIPT" create)
        session_file="${SESSIONS_DIR}/${session_id}.json"
    fi
    
    # Log handshake initiation
    echo -e "${BLUE}[A2A] Handshake initiated: $agent_id${NC}"
    echo -e "${BLUE}[A2A] Session: $session_id${NC}"
    
    # Update session with agent execution
    "$A2A_SESSION_SCRIPT" update "$session_id" "$agent_id" "executing" "" || true
    
    echo "$session_id"
}

# Load context from previous agents
load_context() {
    local context_file="$1"
    local session_id="$2"
    
    if [ -n "$context_file" ] && [ -f "$context_file" ]; then
        echo -e "${BLUE}[A2A] Loading context from: $context_file${NC}"
        cat "$context_file"
    elif [ -n "$session_id" ]; then
        local session_data=$("$A2A_SESSION_SCRIPT" get "$session_id" 2>/dev/null || echo "{}")
        if command -v jq >/dev/null 2>&1; then
            echo "$session_data" | jq -r '.context // {}'
        else
            echo "{}"
        fi
    else
        echo "{}"
    fi
}

# Main execution
main() {
    if [ $# -lt 1 ]; then
        usage
    fi
    
    local agent_name="$1"
    local output_file="${2:-}"
    local agent_file
    local session_id=""
    local context_file=""
    local mcp_tools=""
    
    # Parse remaining arguments for A2A
    shift 2 2>/dev/null || shift 1
    local a2a_args=$(parse_a2a_args "$@")
    session_id=$(echo "$a2a_args" | cut -d'|' -f1)
    context_file=$(echo "$a2a_args" | cut -d'|' -f2)
    mcp_tools=$(echo "$a2a_args" | cut -d'|' -f3)
    
    agent_file=$(validate_agent "$agent_name")
    
    echo -e "${BLUE}Invoking agent: $agent_name${NC}"
    echo -e "${YELLOW}Agent file: $agent_file${NC}"
    
    if [ -n "$output_file" ]; then
        echo -e "${YELLOW}Output file: $output_file${NC}"
    fi
    
    # A2A Protocol: Handshake
    if [ -n "$session_id" ] || [ -n "$context_file" ]; then
        session_id=$(a2a_handshake "${session_id:-}" "$agent_name")
    fi
    
    # A2A Protocol: Load context
    local context_data=""
    if [ -n "$session_id" ] || [ -n "$context_file" ]; then
        context_data=$(load_context "${context_file:-}" "${session_id:-}")
    fi
    
    # Change to infra directory
    cd "$INFRA_DIR" || exit 1
    
    # Create instructions for Cursor with A2A context
    cat << EOF

========================================
INSTRUCTIONS FOR CURSOR AI:
========================================

Read the following agent definition and execute its analysis:

$(cat "$agent_file")

EOF

    if [ -n "$context_data" ] && [ "$context_data" != "{}" ]; then
        cat << EOF

========================================
A2A CONTEXT (from previous agents):
========================================

$context_data

========================================
EOF
    fi
    
    if [ -n "$mcp_tools" ]; then
        cat << EOF

========================================
MCP TOOLS AVAILABLE:
========================================

Available MCP tools: $mcp_tools
Use these tools through function calling as needed.

========================================
EOF
    fi
    
    cat << EOF

========================================
END INSTRUCTIONS
========================================

EOF
    
    if [ -n "$output_file" ]; then
        echo -e "${GREEN}Instructions saved. Provide the agent file content to Cursor AI and save output to: $output_file${NC}"
        
        # A2A Protocol: Update session on completion
        if [ -n "$session_id" ]; then
            echo -e "${BLUE}[A2A] Session will be updated on completion: $session_id${NC}"
            echo -e "${YELLOW}After agent execution, run:${NC}"
            echo -e "${YELLOW}  $A2A_SESSION_SCRIPT update $session_id $agent_name completed $output_file${NC}"
        fi
    else
        echo -e "${GREEN}Instructions ready. Provide the agent file content to Cursor AI.${NC}"
    fi
    
    # Also display the agent file location for reference
    echo -e "${BLUE}Agent file location: $agent_file${NC}"
    
    if [ -n "$session_id" ]; then
        echo -e "${BLUE}[A2A] Session ID: $session_id${NC}"
    fi
}

main "$@"

