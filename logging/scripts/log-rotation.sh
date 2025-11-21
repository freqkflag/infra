#!/bin/bash
# Log rotation script for Docker containers
# This script manages log rotation for all Docker containers

set -e

LOG_DIR="/var/lib/docker/containers"
MAX_SIZE="10m"
MAX_FILES=3

# Configure Docker log rotation
configure_docker_logging() {
    echo "Configuring Docker log rotation..."
    
    # Create or update daemon.json
    DOCKER_DAEMON_JSON="/etc/docker/daemon.json"
    
    if [ -f "$DOCKER_DAEMON_JSON" ]; then
        echo "Backing up existing daemon.json..."
        cp "$DOCKER_DAEMON_JSON" "${DOCKER_DAEMON_JSON}.bak"
    fi
    
    cat > "$DOCKER_DAEMON_JSON" <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "${MAX_SIZE}",
    "max-file": "${MAX_FILES}"
  }
}
EOF
    
    echo "Docker log rotation configured. Restart Docker daemon to apply changes."
    echo "Run: sudo systemctl restart docker"
}

# Clean old logs
clean_old_logs() {
    echo "Cleaning old container logs..."
    find "$LOG_DIR" -name "*-json.log" -type f -mtime +30 -delete
    echo "Old logs cleaned."
}

# Main
case "${1:-}" in
    configure)
        configure_docker_logging
        ;;
    clean)
        clean_old_logs
        ;;
    *)
        echo "Usage: $0 {configure|clean}"
        echo "  configure - Configure Docker log rotation"
        echo "  clean     - Clean old log files"
        exit 1
        ;;
esac

