#!/bin/bash
# Setup DNS records for Infisical across all zones
# Uses Cloudflare API to create/update CNAME records

set -euo pipefail

# Load credentials from ~/.env
if [ -f ~/.env ]; then
    export $(grep -v '^#' ~/.env | xargs)
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/cloudflare-dns-manager.py"

# Domains that need infisical subdomain
DOMAINS=(
    "freqkflag.co"
    # Add other domains as needed
)

TARGET="infisical.freqkflag.co"  # Or your server IP if not using CNAME chain
PROXIED=true

echo "=== Setting up Infisical DNS Records ==="
echo ""

# Check credentials
if [ -z "${CLOUDFLARE_API_TOKEN:-}" ] && [ -z "${CLOUDFLARE_API_KEY:-}" ]; then
    echo "Error: Cloudflare credentials not found"
    echo "Set CLOUDFLARE_API_TOKEN or (CLOUDFLARE_API_KEY + CLOUDFLARE_EMAIL) in ~/.env"
    exit 1
fi

# List zones first
echo "Available zones:"
python3 "$PYTHON_SCRIPT" list-zones
echo ""

# Create/update CNAME records
for domain in "${DOMAINS[@]}"; do
    echo "Setting up infisical.$domain..."
    python3 "$PYTHON_SCRIPT" upsert-cname \
        --zone "$domain" \
        --subdomain "infisical" \
        --target "$TARGET" \
        --proxied "$PROXIED" || echo "  ⚠ Failed for $domain"
done

echo ""
echo "✓ DNS setup complete"

