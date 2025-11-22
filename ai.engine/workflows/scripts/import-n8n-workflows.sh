#!/bin/bash
#
# Import n8n Workflows Script
# Attempts to import workflows via n8n API or provides manual import instructions
#
# Usage:
#   ./import-n8n-workflows.sh [--api-token <token>]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOWS_DIR="$(cd "$SCRIPT_DIR/../n8n" && pwd)"
N8N_URL="${N8N_URL:-https://n8n.freqkflag.co}"
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

# Check if n8n is accessible
check_n8n() {
    log "Checking n8n accessibility..."
    if curl -s -f "${N8N_URL}/healthz" > /dev/null 2>&1; then
        log "n8n is accessible at ${N8N_URL}"
        return 0
    else
        warn "n8n not accessible at ${N8N_URL}"
        return 1
    fi
}

# Attempt to get API token via login
get_api_token() {
    if [ -z "$N8N_PASSWORD" ]; then
        error "N8N_PASSWORD not set. Cannot authenticate."
        return 1
    fi
    
    log "Attempting to get n8n API token..."
    
    # Try to login and get session cookie
    response=$(curl -s -c /tmp/n8n-cookies.txt -X POST "${N8N_URL}/rest/login" \
      -H "Content-Type: application/json" \
      -d "{\"email\":\"${N8N_USER}\",\"password\":\"${N8N_PASSWORD}\"}" 2>&1)
    
    if echo "$response" | grep -q "session"; then
        log "Login successful"
        return 0
    else
        error "Login failed"
        return 1
    fi
}

# Import workflow via API
import_workflow_api() {
    local workflow_file="$1"
    local workflow_name=$(basename "$workflow_file" .json)
    
    log "Importing workflow: $workflow_name"
    
    # Read workflow JSON and import via API
    if curl -s -b /tmp/n8n-cookies.txt -X POST "${N8N_URL}/rest/workflows" \
      -H "Content-Type: application/json" \
      -d @"$workflow_file" > /tmp/n8n-import-result.json 2>&1; then
        
        if grep -q '"id"' /tmp/n8n-import-result.json; then
            log "✅ Workflow imported successfully: $workflow_name"
            return 0
        else
            error "Failed to import workflow: $workflow_name"
            cat /tmp/n8n-import-result.json
            return 1
        fi
    else
        error "API import failed for: $workflow_name"
        return 1
    fi
}

# Provide manual import instructions
manual_import_instructions() {
    log "Providing manual import instructions..."
    echo ""
    echo "=========================================="
    echo "MANUAL IMPORT INSTRUCTIONS"
    echo "=========================================="
    echo ""
    echo "1. Access n8n at: ${N8N_URL}"
    echo "2. Login with credentials"
    echo "3. Click 'Workflows' in the left sidebar"
    echo "4. Click 'Add workflow' button"
    echo "5. Click the three dots menu (...) in the top right"
    echo "6. Select 'Import from File'"
    echo "7. Import each workflow file:"
    echo ""
    
    for workflow_file in "${WORKFLOWS_DIR}"/*.json; do
        if [ -f "$workflow_file" ]; then
            echo "   - $(basename "$workflow_file")"
        fi
    done
    
    echo ""
    echo "8. After importing, activate each workflow by toggling the 'Active' switch"
    echo "9. Test webhook endpoints:"
    echo "   - https://n8n.freqkflag.co/webhook/agent-events"
    echo "   - https://n8n.freqkflag.co/webhook/health-alert"
    echo ""
}

# Main execution
main() {
    log "Starting n8n workflow import process..."
    log "Workflows directory: $WORKFLOWS_DIR"
    log "n8n URL: $N8N_URL"
    
    # Check n8n accessibility
    if ! check_n8n; then
        warn "n8n not accessible. Providing manual import instructions..."
        manual_import_instructions
        exit 0
    fi
    
    # Try API import if credentials available
    if [ -n "$N8N_PASSWORD" ] && get_api_token; then
        log "Attempting API import..."
        
        success=0
        failed=0
        
        for workflow_file in "${WORKFLOWS_DIR}"/*.json; do
            if [ -f "$workflow_file" ]; then
                if import_workflow_api "$workflow_file"; then
                    ((success++))
                else
                    ((failed++))
                fi
            fi
        done
        
        log "Import complete: $success successful, $failed failed"
        
        if [ $failed -gt 0 ]; then
            warn "Some workflows failed to import via API. Use manual import for failed workflows."
            manual_import_instructions
        fi
    else
        warn "API import not available. Using manual import."
        manual_import_instructions
    fi
    
    rm -f /tmp/n8n-cookies.txt /tmp/n8n-import-result.json
    
    log "Workflow import process complete!"
}

main "$@"

