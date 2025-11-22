#!/bin/bash
# Reload script for Infisical Agent
# This script is executed when secrets are updated from Infisical

set -euo pipefail

echo "$(date -Iseconds) - Infisical Agent: Secrets updated, reloading services..."

# Optional: Add service reload logic here if needed
# For example, restart services that depend on updated secrets:
# docker compose -f compose.orchestrator.yml restart service-name

echo "$(date -Iseconds) - Infisical Agent: Reload complete"

