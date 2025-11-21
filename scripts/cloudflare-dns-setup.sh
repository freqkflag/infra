#!/bin/bash
# Setup DNS records for all services across Cloudflare zones
# Uses credentials from ~/.env

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/cloudflare-dns-manager.py"

# Load credentials
if [ -f ~/.env ]; then
    export $(grep -v '^#' ~/.env | xargs)
fi

echo "=== Cloudflare DNS Setup ==="
echo ""

# Check credentials
if [ -z "${CLOUDFLARE_API_TOKEN:-}" ] && [ -z "${CLOUDFLARE_API_KEY:-}" ]; then
    echo "Error: Cloudflare credentials not found in ~/.env"
    echo ""
    echo "Add one of these to ~/.env:"
    echo "  CLOUDFLARE_API_TOKEN=your_token_here"
    echo "  OR"
    echo "  CLOUDFLARE_API_KEY=your_key"
    echo "  CLOUDFLARE_EMAIL=your_email"
    exit 1
fi

# Get server IP (for A records if needed)
SERVER_IP=$(curl -s ifconfig.me || curl -s icanhazip.com || echo "")

echo "Server IP: ${SERVER_IP:-unknown}"
echo ""

# List all zones
echo "Available zones:"
python3 "$PYTHON_SCRIPT" list-zones
echo ""

# Get zones from SERVICES.yml or manually specify
ZONES=(
    "freqkflag.co"
    "cultofjoey.com"
    "twist3dkink.com"
    "twist3dkinkst3r.com"
)

# Services that need DNS records
declare -A SERVICES=(
    ["infisical.freqkflag.co"]="infisical"
    ["vault.freqkflag.co"]="vault"
    ["wiki.freqkflag.co"]="wikijs"
    ["n8n.freqkflag.co"]="n8n"
    ["nodered.freqkflag.co"]="nodered"
    ["mail.freqkflag.co"]="mailu"
    ["webmail.freqkflag.co"]="mailu"
    ["supabase.freqkflag.co"]="supabase"
    ["adminer.freqkflag.co"]="adminer"
    ["cultofjoey.com"]="wordpress"
    ["link.cultofjoey.com"]="linkstack"
    ["twist3dkinkst3r.com"]="mastodon"
)

echo "Setting up DNS records..."
echo ""

for domain in "${!SERVICES[@]}"; do
    zone=$(echo "$domain" | sed 's/.*\.\([^.]*\.[^.]*\)$/\1/')
    subdomain=$(echo "$domain" | sed "s/\.$zone//")
    
    if [ "$subdomain" == "$zone" ]; then
        # Root domain - use A record
        echo "Setting A record: $domain -> $SERVER_IP"
        # Note: A record creation not yet implemented in script
    else
        # Subdomain - use CNAME
        echo "Setting CNAME: $subdomain.$zone -> $SERVER_IP (or appropriate target)"
        python3 "$PYTHON_SCRIPT" create-cname \
            --zone "$zone" \
            --subdomain "$subdomain" \
            --target "$SERVER_IP" \
            --proxied || echo "  ⚠ Failed or already exists"
    fi
done

echo ""
echo "✓ DNS setup complete"

