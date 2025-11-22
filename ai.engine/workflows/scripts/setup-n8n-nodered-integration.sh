#!/bin/bash
#
# Setup n8n and Node-RED Integration
# Verifies connectivity and provides import instructions
#
# Usage:
#   ./setup-n8n-nodered-integration.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOWS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

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

# Check services are running
check_services() {
    log "Checking service status..."
    
    if docker ps | grep -q "n8n"; then
        log "✅ n8n is running"
    else
        error "❌ n8n is not running"
        return 1
    fi
    
    if docker ps | grep -q "nodered"; then
        log "✅ Node-RED is running"
    else
        error "❌ Node-RED is not running"
        return 1
    fi
}

# Test connectivity between services
test_connectivity() {
    log "Testing connectivity between services..."
    
    # Test n8n → Node-RED
    log "Testing n8n → Node-RED..."
    if docker exec n8n curl -s -f http://nodered:1880/health > /dev/null 2>&1; then
        log "✅ n8n can reach Node-RED"
    else
        warn "⚠️ n8n cannot reach Node-RED (may need to restart services)"
    fi
    
    # Test Node-RED → n8n
    log "Testing Node-RED → n8n..."
    if docker exec nodered curl -s -f http://n8n:5678/healthz > /dev/null 2>&1; then
        log "✅ Node-RED can reach n8n"
    else
        warn "⚠️ Node-RED cannot reach n8n (may need to restart services)"
    fi
}

# Check network connectivity
check_networks() {
    log "Checking network configuration..."
    
    # Check edge network
    if docker network inspect edge > /dev/null 2>&1; then
        log "✅ edge network exists"
        
        # Check n8n is on edge network
        if docker network inspect edge | grep -q "\"Name\": \"n8n\""; then
            log "✅ n8n is on edge network"
        else
            warn "⚠️ n8n is not on edge network"
        fi
        
        # Check Node-RED is on edge network
        if docker network inspect edge | grep -q "\"Name\": \"nodered\""; then
            log "✅ Node-RED is on edge network"
        else
            warn "⚠️ Node-RED is not on edge network"
        fi
    else
        error "❌ edge network does not exist"
        return 1
    fi
}

# Provide import instructions
import_instructions() {
    log ""
    log "=========================================="
    log "INTEGRATION SETUP INSTRUCTIONS"
    log "=========================================="
    log ""
    
    log "1. Import Node-RED Flow:"
    log "   - Access Node-RED: https://nodered.freqkflag.co"
    log "   - Click menu (☰) → Import"
    log "   - Import flow from:"
    log "     ${WORKFLOWS_DIR}/nodered/n8n-integration-flow-proper.json"
    log "   - Deploy the flow"
    log ""
    
    log "2. Import n8n Workflow:"
    log "   - Access n8n: https://n8n.freqkflag.co"
    log "   - Click 'Workflows' → 'Add workflow'"
    log "   - Click menu (...) → 'Import from File'"
    log "   - Import workflow from:"
    log "     ${WORKFLOWS_DIR}/n8n/nodered-integration-workflow.json"
    log "   - Activate the workflow"
    log ""
    
    log "3. Test Integration:"
    log ""
    log "   Test Node-RED → n8n:"
    log "   curl -X POST http://localhost:1880/n8n/webhook \\"
    log "     -H 'Content-Type: application/json' \\"
    log "     -d '{\"type\":\"health-alert\",\"data\":{\"service\":\"traefik\",\"status\":\"unhealthy\"}}'"
    log ""
    log "   Test n8n → Node-RED:"
    log "   curl -X POST https://n8n.freqkflag.co/webhook/nodered/trigger \\"
    log "     -H 'Content-Type: application/json' \\"
    log "     -d '{\"type\":\"agent-event\",\"data\":{\"agent\":\"status\"}}'"
    log ""
}

# Main execution
main() {
    log "Setting up n8n and Node-RED integration..."
    log ""
    
    check_services
    check_networks
    test_connectivity
    import_instructions
    
    log ""
    log "✅ Integration setup complete!"
    log ""
    log "See ${WORKFLOWS_DIR}/N8N_NODERED_INTEGRATION.md for detailed documentation"
}

main "$@"

