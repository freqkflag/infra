#!/bin/bash
# Infrastructure Routing Sanity Check
# Tests all service URLs from the VPS and returns a compact status table

set -uo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Service URLs from SERVICES.yml
declare -A SERVICES=(
    ["wiki.freqkflag.co"]="WikiJS"
    ["n8n.freqkflag.co"]="n8n"
    ["nodered.freqkflag.co"]="Node-RED"
    ["mail.freqkflag.co"]="Mailu Admin"
    ["webmail.freqkflag.co"]="Mailu Webmail"
    ["supabase.freqkflag.co"]="Supabase Studio"
    ["api.supabase.freqkflag.co"]="Supabase API"
    ["adminer.freqkflag.co"]="Adminer"
    ["cultofjoey.com"]="WordPress"
    ["link.cultofjoey.com"]="LinkStack"
    ["twist3dkinkst3r.com"]="Mastodon"
)

# Optional: Add monitoring/logging if configured
declare -A OPTIONAL_SERVICES=(
    ["grafana.freqkflag.co"]="Grafana"
    ["prometheus.freqkflag.co"]="Prometheus"
    ["loki.freqkflag.co"]="Loki"
)

# Results arrays
declare -a RESULTS
declare -a FAILED
declare -a SKIPPED

# Function to check a URL
check_url() {
    local domain=$1
    local name=$2
    local timeout=5
    local path="/"
    
    # Skip if domain is null or localhost
    if [[ "$domain" == "null" ]] || [[ "$domain" == "traefik.localhost" ]]; then
        SKIPPED+=("$name ($domain)")
        return 0
    fi
    
    # Test HTTPS connection
        path="/v1/sys/health"
    fi
    
    # Test HTTPS connection
    local response=$(curl -k -s -o /dev/null -w "%{http_code}" --max-time $timeout --connect-timeout $timeout "https://$domain$path" 2>/dev/null || echo "000")
    
    if [[ "$response" == "000" ]]; then
        # Connection failed
        FAILED+=("$name ($domain)")
        RESULTS+=("$name|$domain|FAIL|Connection timeout/refused")
        return 1
    elif [[ "$response" =~ ^[23] ]]; then
        # 2xx or 3xx = success
        RESULTS+=("$name|$domain|OK|HTTP $response")
        return 0
    elif [[ "$response" == "404" ]]; then
        # 404 might mean service is up but not configured
        RESULTS+=("$name|$domain|WARN|HTTP 404 (service may not be running)")
        return 0
    else
        # Other error codes
        FAILED+=("$name ($domain)")
        RESULTS+=("$name|$domain|FAIL|HTTP $response")
        return 1
    fi
}

# Main execution
echo "=== Infrastructure Routing Sanity Check ==="
echo ""
echo "Testing service URLs from VPS..."
echo ""

# Check Traefik network first
if ! docker network inspect traefik-network &>/dev/null; then
    echo -e "${RED}✗ ERROR: traefik-network not found${NC}"
    exit 1
fi

# Check Traefik container
if ! docker ps --format '{{.Names}}' | grep -q "^traefik$"; then
    echo -e "${RED}✗ ERROR: Traefik container not running${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Traefik network exists${NC}"
echo -e "${GREEN}✓ Traefik container running${NC}"
echo ""

# Test all services
for domain in "${!SERVICES[@]}"; do
    name="${SERVICES[$domain]}"
    check_url "$domain" "$name" || true
done

# Test optional services (don't fail if they're not configured)
for domain in "${!OPTIONAL_SERVICES[@]}"; do
    name="${OPTIONAL_SERVICES[$domain]}"
    check_url "$domain" "$name" || true
done

# Print results table
echo ""
echo "=== Results ==="
printf "%-25s %-35s %-8s %s\n" "SERVICE" "DOMAIN" "STATUS" "DETAILS"
echo "--------------------------------------------------------------------------------"

for result in "${RESULTS[@]}"; do
    IFS='|' read -r name domain status details <<< "$result"
    
    if [[ "$status" == "OK" ]]; then
        printf "%-25s %-35s ${GREEN}%-8s${NC} %s\n" "$name" "$domain" "$status" "$details"
    elif [[ "$status" == "WARN" ]]; then
        printf "%-25s %-35s ${YELLOW}%-8s${NC} %s\n" "$name" "$domain" "$status" "$details"
    else
        printf "%-25s %-35s ${RED}%-8s${NC} %s\n" "$name" "$domain" "$status" "$details"
    fi
done

# Summary
echo ""
echo "=== Summary ==="
TOTAL=${#RESULTS[@]}
PASSED=$(printf '%s\n' "${RESULTS[@]}" | grep -c "|OK|" || echo "0")
WARNED=$(printf '%s\n' "${RESULTS[@]}" | grep -c "|WARN|" || echo "0")
FAILED_COUNT=${#FAILED[@]}

echo "Total services tested: $TOTAL"
echo -e "${GREEN}Passed: $PASSED${NC}"
if [[ $WARNED -gt 0 ]]; then
    echo -e "${YELLOW}Warnings: $WARNED${NC}"
fi
if [[ $FAILED_COUNT -gt 0 ]]; then
    echo -e "${RED}Failed: $FAILED_COUNT${NC}"
    echo ""
    echo "Failed services:"
    for failed in "${FAILED[@]}"; do
        echo -e "  ${RED}✗${NC} $failed"
    done
    exit 1
fi

if [[ $WARNED -gt 0 ]]; then
    echo ""
    echo -e "${YELLOW}Note: Some services returned 404 - they may not be running or configured${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}✓ All services routing correctly!${NC}"
exit 0
