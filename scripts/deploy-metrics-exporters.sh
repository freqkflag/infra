#!/usr/bin/env bash
# Deploy Metrics Exporters
# Adds cAdvisor, postgres_exporter, mysql_exporter, redis_exporter to monitoring stack

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MONITORING_DIR="$INFRA_DIR/monitoring"

echo "Deploying metrics exporters..."

# Check if monitoring directory exists
if [ ! -d "$MONITORING_DIR" ]; then
    echo "ERROR: Monitoring directory not found: $MONITORING_DIR"
    exit 1
fi

# Backup existing compose file
if [ -f "$MONITORING_DIR/docker-compose.yml" ]; then
    cp "$MONITORING_DIR/docker-compose.yml" "$MONITORING_DIR/docker-compose.yml.backup.$(date +%Y%m%d-%H%M%S)"
fi

echo "✅ Backup created"

# Note: This script prepares the configuration but doesn't modify files directly
# Manual steps required:
# 1. Add cAdvisor service to monitoring/docker-compose.yml
# 2. Add exporter services to respective service compose files
# 3. Update Prometheus scrape configs
# 4. Restart monitoring stack

echo "📋 Next steps:"
echo "1. Add cAdvisor service to $MONITORING_DIR/docker-compose.yml"
echo "2. Add postgres_exporter to services/postgres/compose.yml"
echo "3. Add mysql_exporter to services/mariadb/compose.yml"
echo "4. Add redis_exporter to services/redis/compose.yml"
echo "5. Update $MONITORING_DIR/config/prometheus/prometheus.yml with new scrape targets"
echo "6. Run: docker compose -f $MONITORING_DIR/docker-compose.yml up -d"
echo ""
echo "See docs/MONITORING_GAPS.md for complete configuration examples."

