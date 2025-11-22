#!/bin/bash
#
# Post-Agent Automation Script
# Automatically commits changes, triggers code review, and creates PRs after agent runs
#
# Usage:
#   ./post-agent-automation.sh <agent_name> <output_file> [commit_message]
#
# This script:
# 1. Checks for uncommitted changes
# 2. Commits changes with appropriate message
# 3. Triggers code review agent
# 4. Optionally creates PR (if configured)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_ENGINE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
INFRA_DIR="/root/infra"

agent_name="${1:-}"
output_file="${2:-}"
commit_message="${3:-}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

cd "$INFRA_DIR"

# Check if git is available
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git not found${NC}" >&2
    exit 1
fi

# Check if there are uncommitted changes
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    echo -e "${YELLOW}No uncommitted changes found${NC}"
    exit 0
fi

echo -e "${BLUE}Post-Agent Automation: $agent_name${NC}"
echo ""

# Get list of changed files
changed_files=$(git status --short | wc -l)
echo -e "${YELLOW}Found $changed_files changed file(s)${NC}"

# Generate commit message if not provided
if [ -z "$commit_message" ]; then
    timestamp=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
    commit_message="chore: automated changes from $agent_name agent ($timestamp)"
fi

# Stage all changes
echo -e "${BLUE}Staging changes...${NC}"
git add -A

# Check if there are staged changes
if git diff --cached --quiet; then
    echo -e "${YELLOW}No staged changes to commit${NC}"
    exit 0
fi

# Commit changes
echo -e "${BLUE}Committing changes...${NC}"
if git commit -m "$commit_message" 2>&1; then
    commit_hash=$(git rev-parse --short HEAD)
    echo -e "${GREEN}✓ Committed changes: $commit_hash${NC}"
    echo "  Message: $commit_message"
else
    echo -e "${RED}Failed to commit changes${NC}" >&2
    exit 1
fi

# Trigger code review agent
echo ""
echo -e "${BLUE}Triggering code review agent...${NC}"
code_review_output="/root/infra/orchestration/code-review-$(date +%Y%m%d-%H%M%S).json"

if [ -f "${AI_ENGINE_DIR}/scripts/invoke-agent.sh" ]; then
    if "${AI_ENGINE_DIR}/scripts/invoke-agent.sh" code-review "$code_review_output" 2>&1; then
        echo -e "${GREEN}✓ Code review agent completed${NC}"
        echo "  Output: $code_review_output"
        
        # Check for critical issues in code review
        if command -v jq &> /dev/null && [ -f "$code_review_output" ]; then
            critical_issues=$(jq -r '.code_quality_issues[]? | select(.severity == "CRITICAL" or .severity == "HIGH") | .issue' "$code_review_output" 2>/dev/null | wc -l || echo "0")
            if [ "$critical_issues" -gt 0 ]; then
                echo -e "${YELLOW}⚠ Found $critical_issues critical/high severity issues in code review${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}⚠ Code review agent failed (non-critical)${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Code review agent script not found${NC}"
fi

# Push to remote if configured
if git remote | grep -q origin; then
    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "main" ] && [ "$current_branch" != "master" ]; then
        echo ""
        echo -e "${BLUE}Pushing to remote...${NC}"
        if git push -u origin "$current_branch" 2>&1; then
            echo -e "${GREEN}✓ Pushed to remote: $current_branch${NC}"
        else
            echo -e "${YELLOW}⚠ Failed to push to remote (non-critical)${NC}"
        fi
    else
        echo -e "${YELLOW}Skipping push (on main/master branch)${NC}"
    fi
fi

echo ""
echo -e "${GREEN}Post-agent automation completed${NC}"

