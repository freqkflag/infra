#!/bin/bash
#
# Infrastructure Virtual Agent Invoker
# Invokes specialized virtual agents for infrastructure analysis
#
# Usage:
#   ./invoke-agent.sh <agent_name> [output_file]
#
# Available agents:
#   status, bug-hunter, performance, security, architecture, docs, tests, refactor, release, backstage, orchestrator
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$(cd "$SCRIPT_DIR/../agents" && pwd)"
INFRA_DIR="/root/infra"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print usage
usage() {
    cat << EOF
Usage: $0 <agent_name> [output_file]

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
  backstage       - Backstage developer portal management
  orchestrator    - Full multi-agent orchestration

Examples:
  $0 status
  $0 bug-hunter /tmp/bugs.json
  $0 orchestrator /root/infra/orchestration-report.json

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
        backstage)
            agent_file="${AGENTS_DIR}/backstage-agent.md"
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

# Main execution
main() {
    if [ $# -lt 1 ]; then
        usage
    fi
    
    local agent_name="$1"
    local output_file="${2:-}"
    local agent_file
    
    agent_file=$(validate_agent "$agent_name")
    
    echo -e "${BLUE}Invoking agent: $agent_name${NC}"
    echo -e "${YELLOW}Agent file: $agent_file${NC}"
    
    if [ -n "$output_file" ]; then
        echo -e "${YELLOW}Output file: $output_file${NC}"
    fi
    
    # Change to infra directory
    cd "$INFRA_DIR" || exit 1
    
    # Create instructions for Cursor
    cat << EOF

========================================
INSTRUCTIONS FOR CURSOR AI:
========================================

Read the following agent definition and execute its analysis:

$(cat "$agent_file")

========================================
END INSTRUCTIONS
========================================

EOF
    
    if [ -n "$output_file" ]; then
        echo -e "${GREEN}Instructions saved. Provide the agent file content to Cursor AI and save output to: $output_file${NC}"
    else
        echo -e "${GREEN}Instructions ready. Provide the agent file content to Cursor AI.${NC}"
    fi
    
    # Also display the agent file location for reference
    echo -e "${BLUE}Agent file location: $agent_file${NC}"
}

main "$@"

