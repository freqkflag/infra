#!/bin/bash
#
# Import Agent Event Router Workflow with A2A Support to n8n
# Uses n8n API to import the workflow
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_FILE="$(cd "$SCRIPT_DIR/../n8n" && pwd)/agent-event-router.json"
N8N_URL="${N8N_URL:-https://n8n.freqkflag.co}"
INFRA_DIR="/root/infra"

# Load credentials from .workspace/.env
if [ -f "${INFRA_DIR}/.workspace/.env" ]; then
    source "${INFRA_DIR}/.workspace/.env"
fi

N8N_USER="${N8N_USER:-admin}"
N8N_PASSWORD="${N8N_PASSWORD:-}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if workflow file exists
if [ ! -f "$WORKFLOW_FILE" ]; then
    error "Workflow file not found: $WORKFLOW_FILE"
    exit 1
fi

log "Workflow file: $WORKFLOW_FILE"
log "n8n URL: $N8N_URL"

# Try API import if credentials available
if [ -n "$N8N_PASSWORD" ]; then
    log "Attempting API import..."
    
    # Login and get session cookie
    login_response=$(curl -s -c /tmp/n8n-cookies.txt -X POST "${N8N_URL}/rest/login" \
      -H "Content-Type: application/json" \
      -d "{\"email\":\"${N8N_USER}\",\"password\":\"${N8N_PASSWORD}\"}" 2>&1)
    
    if echo "$login_response" | grep -q "session\|cookie" || [ $? -eq 0 ]; then
        log "Login successful"
        
        # Read workflow JSON
        workflow_json=$(cat "$WORKFLOW_FILE")
        
        # Import workflow via API
        import_response=$(curl -s -b /tmp/n8n-cookies.txt -X POST "${N8N_URL}/rest/workflows" \
          -H "Content-Type: application/json" \
          -d "$workflow_json" 2>&1)
        
        if echo "$import_response" | grep -q '"id"'; then
            workflow_id=$(echo "$import_response" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
            log "✅ Workflow imported successfully!"
            log "   Workflow ID: $workflow_id"
            log "   Name: Agent Event Router"
            log ""
            log "Next steps:"
            log "1. Go to ${N8N_URL}/workflows"
            log "2. Find 'Agent Event Router' workflow"
            log "3. Toggle 'Activate workflow' switch to activate it"
            log "4. Test webhook: curl -X POST ${N8N_URL}/webhook/agent-events -H 'Content-Type: application/json' -d '{\"agent\":\"status\",\"session_id\":\"a2a-test-123\"}'"
        else
            error "Failed to import workflow"
            echo "$import_response" | head -20
            warn "Use manual import instead (see instructions below)"
        fi
        
        rm -f /tmp/n8n-cookies.txt
    else
        error "Login failed"
        warn "Use manual import instead"
    fi
else
    warn "N8N_PASSWORD not set. Cannot use API import."
fi

# Always provide manual import instructions
echo ""
echo "=========================================="
echo "MANUAL IMPORT INSTRUCTIONS"
echo "=========================================="
echo ""
echo "1. Open n8n in browser: ${N8N_URL}"
echo "2. Navigate to 'Workflows' page"
echo "3. Click 'Add Workflow' button"
echo "4. In the workflow editor, click the three dots menu (...) in the top right"
echo "5. Select 'Import from File'"
echo "6. Select file: $WORKFLOW_FILE"
echo "7. The workflow will be imported with all A2A nodes:"
echo "   - A2A Session Manager"
echo "   - Invoke Agent Script (A2A)"
echo "   - Format Response (A2A)"
echo "   - A2A Session Update"
echo "8. Click 'Save' to save the workflow"
echo "9. Toggle 'Activate workflow' switch to activate it"
echo ""
echo "Test the webhook after activation:"
echo "  curl -X POST ${N8N_URL}/webhook/agent-events \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"agent\":\"status\",\"session_id\":\"a2a-test-123\",\"task_id\":\"test-task\"}'"
echo ""

