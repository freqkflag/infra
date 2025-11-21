#!/bin/bash
# Fix Infisical encryption keys by regenerating in hex format
# Usage: ./fix-encryption-keys.sh

set -euo pipefail

echo "=== Fixing Infisical Encryption Keys ==="
echo ""
echo "This script will regenerate encryption keys in base64 format (44 chars = 32 bytes for AES-256)"
echo ""

# Backup existing .env if it exists
if [ -f .env ]; then
    echo "Backing up existing .env to .env.backup.$(date +%Y%m%d_%H%M%S)"
    cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
fi

# Generate new keys in base64 format (44 chars = 32 bytes when decoded)
echo "Generating new encryption keys..."
ENCRYPTION_KEY=$(openssl rand -base64 32 | tr -d '\n')
ROOT_ENCRYPTION_KEY=$(openssl rand -base64 32 | tr -d '\n')

echo ""
echo "New keys generated:"
echo "ENCRYPTION_KEY length: ${#ENCRYPTION_KEY} chars (base64, decodes to 32 bytes)"
echo "ROOT_ENCRYPTION_KEY length: ${#ROOT_ENCRYPTION_KEY} chars (base64, decodes to 32 bytes)"
echo ""

# Update .env file
if [ -f .env ]; then
    # Update existing keys
    sed -i "s/^ENCRYPTION_KEY=.*/ENCRYPTION_KEY=${ENCRYPTION_KEY}/" .env
    sed -i "s/^ROOT_ENCRYPTION_KEY=.*/ROOT_ENCRYPTION_KEY=${ROOT_ENCRYPTION_KEY}/" .env
    echo "✅ Updated .env file with new hex-format keys"
else
    echo "⚠️  .env file not found. Please run generate-secrets.sh first, then run this script again."
    exit 1
fi

echo ""
echo "Next steps:"
echo "1. Restart Infisical: docker compose restart infisical"
echo "2. Check logs: docker compose logs -f infisical"
echo "3. If issues persist, check INFISICAL_ISSUES.md"

