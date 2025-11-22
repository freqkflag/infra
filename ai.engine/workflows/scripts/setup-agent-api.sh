#!/bin/bash
#
# Setup Agent API Server
# Installs and starts the agent API server for n8n integration
#
# Usage:
#   ./setup-agent-api.sh [--install] [--start]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_SERVER="$SCRIPT_DIR/agent-api-server.py"
SERVICE_FILE="$SCRIPT_DIR/agent-api-server.service"
SERVICE_NAME="agent-api-server"

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

# Check if Flask is installed
check_flask() {
    if python3 -c "import flask" 2>/dev/null; then
        log "Flask is installed"
        return 0
    else
        warn "Flask is not installed"
        return 1
    fi
}

# Install Flask
install_flask() {
    log "Installing Flask..."
    python3 -m pip install flask --quiet
    if check_flask; then
        log "Flask installed successfully"
    else
        error "Failed to install Flask"
        return 1
    fi
}

# Install systemd service
install_service() {
    log "Installing systemd service..."
    
    if [ ! -f "$SERVICE_FILE" ]; then
        error "Service file not found: $SERVICE_FILE"
        return 1
    fi
    
    # Copy service file
    sudo cp "$SERVICE_FILE" "/etc/systemd/system/${SERVICE_NAME}.service"
    
    # Reload systemd
    sudo systemctl daemon-reload
    
    # Enable service
    sudo systemctl enable "${SERVICE_NAME}.service"
    
    log "Service installed and enabled"
}

# Start service
start_service() {
    log "Starting agent API server..."
    
    if systemctl is-active --quiet "${SERVICE_NAME}"; then
        log "Service is already running"
        return 0
    fi
    
    sudo systemctl start "${SERVICE_NAME}.service"
    
    sleep 2
    
    if systemctl is-active --quiet "${SERVICE_NAME}"; then
        log "Service started successfully"
    else
        error "Failed to start service"
        sudo systemctl status "${SERVICE_NAME}.service"
        return 1
    fi
}

# Test API server
test_api() {
    log "Testing API server..."
    
    sleep 2
    
    if curl -s -f "http://localhost:8080/health" > /dev/null; then
        log "✅ API server is responding"
        
        # Test list agents endpoint
        response=$(curl -s "http://localhost:8080/api/v1/agents/list")
        if echo "$response" | grep -q "agents"; then
            log "✅ API server is functional"
            return 0
        fi
    else
        error "API server is not responding"
        return 1
    fi
}

# Main execution
main() {
    log "Setting up Agent API Server..."
    
    # Check and install Flask
    if ! check_flask; then
        install_flask
    fi
    
    # Make script executable
    chmod +x "$API_SERVER"
    
    # Install service
    install_service
    
    # Start service
    start_service
    
    # Test API
    test_api
    
    log ""
    log "✅ Agent API Server setup complete!"
    log ""
    log "API Endpoint: http://localhost:8080/api/v1/agents/invoke"
    log "Health Check: http://localhost:8080/health"
    log "List Agents: http://localhost:8080/api/v1/agents/list"
    log ""
    log "For Docker containers, use: http://host.docker.internal:8080"
    log ""
    log "Service status:"
    systemctl status "${SERVICE_NAME}.service" --no-pager -l || true
}

main "$@"

