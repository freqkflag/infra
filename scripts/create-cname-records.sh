#!/bin/bash
# Create CNAME records for all services in INFRASTRUCTURE_MAP.md
# Usage: ./create-cname-records.sh

set -e

ZONE_FREQKFLAG="freqkflag.co"
ZONE_CULTOFJOEY="cultofjoey.com"

# Function to create CNAME record
create_cname() {
    local zone=$1
    local subdomain=$2
    local target=$3
    
    echo "Creating CNAME: ${subdomain}.${zone} -> ${target}"
    python3 scripts/cloudflare-dns-manager.py upsert-cname \
        --zone "$zone" \
        --subdomain "$subdomain" \
        --target "$target" \
        --proxied
}

# freqkflag.co subdomains pointing to freqkflag.co
echo "=== Creating CNAME records for freqkflag.co ==="
create_cname "$ZONE_FREQKFLAG" "traefik" "$ZONE_FREQKFLAG"
create_cname "$ZONE_FREQKFLAG" "infisical" "$ZONE_FREQKFLAG"
create_cname "$ZONE_FREQKFLAG" "adminer" "$ZONE_FREQKFLAG"
create_cname "$ZONE_FREQKFLAG" "wiki" "$ZONE_FREQKFLAG"
create_cname "$ZONE_FREQKFLAG" "n8n" "$ZONE_FREQKFLAG"
create_cname "$ZONE_FREQKFLAG" "nodered" "$ZONE_FREQKFLAG"
create_cname "$ZONE_FREQKFLAG" "backstage" "$ZONE_FREQKFLAG"
create_cname "$ZONE_FREQKFLAG" "gitlab" "$ZONE_FREQKFLAG"
create_cname "$ZONE_FREQKFLAG" "supabase" "$ZONE_FREQKFLAG"
create_cname "$ZONE_FREQKFLAG" "api.supabase" "$ZONE_FREQKFLAG"
create_cname "$ZONE_FREQKFLAG" "mail" "$ZONE_FREQKFLAG"
create_cname "$ZONE_FREQKFLAG" "webmail" "$ZONE_FREQKFLAG"
create_cname "$ZONE_FREQKFLAG" "ops" "$ZONE_FREQKFLAG"
create_cname "$ZONE_FREQKFLAG" "grafana" "$ZONE_FREQKFLAG"
create_cname "$ZONE_FREQKFLAG" "prometheus" "$ZONE_FREQKFLAG"
create_cname "$ZONE_FREQKFLAG" "alertmanager" "$ZONE_FREQKFLAG"
create_cname "$ZONE_FREQKFLAG" "loki" "$ZONE_FREQKFLAG"

# cultofjoey.com subdomains pointing to cultofjoey.com
echo ""
echo "=== Creating CNAME records for cultofjoey.com ==="
create_cname "$ZONE_CULTOFJOEY" "link" "$ZONE_CULTOFJOEY"

echo ""
echo "=== All CNAME records created successfully ==="

