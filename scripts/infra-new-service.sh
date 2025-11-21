#!/bin/bash
# Infrastructure Service Scaffolder
# Creates a new service with folder structure, docker-compose.yml, SERVICES.yml entry, and runbook
# Usage: ./infra-new-service.sh <service-id> [service-name] [type] [domain]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(dirname "$SCRIPT_DIR")"
SERVICES_FILE="$INFRA_DIR/SERVICES.yml"
RUNBOOKS_DIR="$INFRA_DIR/runbooks"
TEMPLATE_RUNBOOK="$RUNBOOKS_DIR/TEMPLATE_SERVICE_RUNBOOK.md"

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <service-id> [service-name] [type] [domain]"
    echo ""
    echo "Examples:"
    echo "  $0 myapp 'My App' app myapp.freqkflag.co"
    echo "  $0 newdb db null"
    echo ""
    exit 1
fi

SERVICE_ID=$1
SERVICE_NAME=${2:-$(echo "$SERVICE_ID" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g' | sed 's/^./\U&/g')}
SERVICE_TYPE=${3:-app}
SERVICE_DOMAIN=${4:-null}
SERVICE_DIR="$INFRA_DIR/$SERVICE_ID"

# Validate service ID
if [[ ! "$SERVICE_ID" =~ ^[a-z0-9-]+$ ]]; then
    echo "Error: Service ID must be lowercase alphanumeric with hyphens only"
    exit 1
fi

# Check if service already exists
if [[ -d "$SERVICE_DIR" ]]; then
    echo "Error: Service directory already exists: $SERVICE_DIR"
    exit 1
fi

if grep -q "id: $SERVICE_ID" "$SERVICES_FILE" 2>/dev/null; then
    echo "Error: Service ID already exists in SERVICES.yml"
    exit 1
fi

echo "Creating new service: $SERVICE_ID"
echo "  Name: $SERVICE_NAME"
echo "  Type: $SERVICE_TYPE"
echo "  Domain: $SERVICE_DOMAIN"
echo "  Directory: $SERVICE_DIR"
echo ""

# Create directory structure
mkdir -p "$SERVICE_DIR/data"
echo "✓ Created directory structure"

# Create basic docker-compose.yml
cat > "$SERVICE_DIR/docker-compose.yml" <<EOF
services:
  ${SERVICE_ID}:
    image: nginx:alpine
    container_name: ${SERVICE_ID}
    environment:
      TZ: \${TZ:-America/New_York}
    volumes:
      - ./data:/data
    networks:
      - traefik-network
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 128M
    security_opt:
      - no-new-privileges:true
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:80"]
      interval: 30s
      timeout: 10s
      retries: 3
EOF

# Add Traefik labels if domain is provided
if [[ "$SERVICE_DOMAIN" != "null" ]] && [[ -n "$SERVICE_DOMAIN" ]]; then
    cat >> "$SERVICE_DIR/docker-compose.yml" <<EOF
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.${SERVICE_ID}.rule=Host(\`${SERVICE_DOMAIN}\`)"
      - "traefik.http.routers.${SERVICE_ID}.entrypoints=websecure"
      - "traefik.http.routers.${SERVICE_ID}.tls.certresolver=letsencrypt"
      - "traefik.http.routers.${SERVICE_ID}.middlewares=security-headers@file"
      - "traefik.http.services.${SERVICE_ID}.loadbalancer.server.port=80"

EOF
fi

cat >> "$SERVICE_DIR/docker-compose.yml" <<EOF
networks:
  traefik-network:
    external: true
    name: traefik-network
EOF

echo "✓ Created docker-compose.yml"

# Create .env template
cat > "$SERVICE_DIR/.env.example" <<EOF
# ${SERVICE_NAME} Configuration
# Copy this file to .env and update values

TZ=America/New_York
EOF
echo "✓ Created .env.example"

# Create README.md
cat > "$SERVICE_DIR/README.md" <<EOF
# ${SERVICE_NAME}

**Service ID:** \`${SERVICE_ID}\`  
**Type:** ${SERVICE_TYPE}  
**Status:** configured

## Quick Start

1. **Configure Environment:**
   \`\`\`bash
   cd /root/infra/${SERVICE_ID}
   cp .env.example .env
   nano .env
   \`\`\`

2. **Deploy:**
   \`\`\`bash
   docker compose up -d
   \`\`\`

3. **Verify:**
   \`\`\`bash
   docker compose ps
   docker compose logs -f
   \`\`\`

## Management

### Start/Stop/Restart
\`\`\`bash
./scripts/infra-service.sh start ${SERVICE_ID}
./scripts/infra-service.sh stop ${SERVICE_ID}
./scripts/infra-service.sh restart ${SERVICE_ID}
\`\`\`

## Configuration

See runbook for detailed configuration and troubleshooting:
- [Runbook](../runbooks/${SERVICE_ID}-runbook.md)

## Links

- **Service URL:** ${SERVICE_DOMAIN}
- **Documentation:** [WikiJS](https://wiki.freqkflag.co)
- **Metrics:** [Grafana](https://grafana.freqkflag.co)
- **Logs:** [Loki](https://grafana.freqkflag.co/explore)

EOF
echo "✓ Created README.md"

# Add entry to SERVICES.yml
# Create temporary file with service entry
TEMP_FILE=$(mktemp)
cat > "$TEMP_FILE" <<EOF
  - id: ${SERVICE_ID}
    name: ${SERVICE_NAME}
    dir: /root/infra/${SERVICE_ID}
    url: $([ "$SERVICE_DOMAIN" != "null" ] && echo "https://${SERVICE_DOMAIN}" || echo "null")
    type: ${SERVICE_TYPE}
    status: configured
    depends_on: [traefik]
    description: ${SERVICE_NAME} service
$([ "$SERVICE_DOMAIN" != "null" ] && echo "    domain: ${SERVICE_DOMAIN}" || echo "")

EOF

# Find insertion point (before metadata section)
if grep -q "^# Service Metadata" "$SERVICES_FILE"; then
    # Insert before metadata section using awk
    awk -v insert="$(cat "$TEMP_FILE")" '/^# Service Metadata/ {print insert} 1' "$SERVICES_FILE" > "${SERVICES_FILE}.tmp" && mv "${SERVICES_FILE}.tmp" "$SERVICES_FILE"
else
    # Append to end
    echo "" >> "$SERVICES_FILE"
    cat "$TEMP_FILE" >> "$SERVICES_FILE"
fi

rm -f "$TEMP_FILE"

echo "✓ Added entry to SERVICES.yml"

# Create runbook from template
if [[ -f "$TEMPLATE_RUNBOOK" ]]; then
    RUNBOOK_FILE="$RUNBOOKS_DIR/${SERVICE_ID}-runbook.md"
    SERVICE_URL="$([ "$SERVICE_DOMAIN" != "null" ] && echo "https://${SERVICE_DOMAIN}" || echo "N/A")"
    CURRENT_DATE=$(date +%Y-%m-%d)
    
    sed -e "s|\[Service Name\]|${SERVICE_NAME}|g" \
        -e "s|\[service-id\]|${SERVICE_ID}|g" \
        -e "s|\[service-dir\]|${SERVICE_ID}|g" \
        -e "s|\[service-name\]|${SERVICE_ID}|g" \
        -e "s|\[primary-domain\]|${SERVICE_DOMAIN}|g" \
        -e "s|\[service-urls\]|${SERVICE_URL}|g" \
        -e "s|\[date\]|${CURRENT_DATE}|g" \
        "$TEMPLATE_RUNBOOK" > "$RUNBOOK_FILE"
    echo "✓ Created runbook: ${RUNBOOK_FILE}"
else
    echo "⚠ Template runbook not found, skipping runbook creation"
fi

echo ""
echo "✅ Service '${SERVICE_ID}' created successfully!"
echo ""
echo "Next steps:"
echo "1. Edit ${SERVICE_DIR}/docker-compose.yml to customize the service"
echo "2. Copy ${SERVICE_DIR}/.env.example to ${SERVICE_DIR}/.env and configure"
echo "3. Review and update ${RUNBOOKS_DIR}/${SERVICE_ID}-runbook.md"
echo "4. Start the service: ./scripts/infra-service.sh start ${SERVICE_ID}"
echo ""

