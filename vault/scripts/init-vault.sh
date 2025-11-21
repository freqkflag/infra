#!/bin/bash
# Vault Initialization Script
# Initializes Vault in production mode and saves unseal keys

set -e

VAULT_ADDR="${VAULT_ADDR:-http://localhost:8200}"
KEYS_FILE="${KEYS_FILE:-/vault/init/keys.txt}"
ROOT_TOKEN_FILE="${ROOT_TOKEN_FILE:-/vault/init/root-token.txt}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Vault Initialization Script"
echo "============================"
echo ""

# Check if Vault is running
if ! curl -s -f "${VAULT_ADDR}/v1/sys/health" > /dev/null 2>&1; then
    echo -e "${RED}Error: Cannot connect to Vault at ${VAULT_ADDR}${NC}"
    echo "Make sure Vault is running: docker compose up -d"
    exit 1
fi

# Check if Vault is already initialized
INIT_STATUS=$(curl -s "${VAULT_ADDR}/v1/sys/init" | jq -r '.initialized' 2>/dev/null || echo "false")

if [ "$INIT_STATUS" = "true" ]; then
    echo -e "${YELLOW}Warning: Vault is already initialized${NC}"
    echo ""
    read -p "Do you want to re-initialize? This will DELETE all data! (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Initialization cancelled."
        exit 0
    fi
    echo -e "${RED}Re-initialization will delete all existing data!${NC}"
    echo "This requires Vault to be sealed and data directory to be cleared."
    echo "Manual intervention required - see documentation."
    exit 1
fi

# Check if Vault is sealed
SEAL_STATUS=$(curl -s "${VAULT_ADDR}/v1/sys/seal-status" | jq -r '.sealed' 2>/dev/null || echo "unknown")

if [ "$SEAL_STATUS" = "true" ]; then
    echo -e "${YELLOW}Vault is sealed. Please unseal first or start fresh.${NC}"
    exit 1
fi

echo "Initializing Vault..."
echo ""

# Initialize Vault
# Key shares: 5, Key threshold: 3
INIT_RESPONSE=$(vault operator init -key-shares=5 -key-threshold=3 -format=json 2>&1)

if [ $? -ne 0 ]; then
    echo -e "${RED}Error initializing Vault:${NC}"
    echo "$INIT_RESPONSE"
    exit 1
fi

# Extract unseal keys and root token
UNSEAL_KEYS=$(echo "$INIT_RESPONSE" | jq -r '.unseal_keys_b64[]')
ROOT_TOKEN=$(echo "$INIT_RESPONSE" | jq -r '.root_token')

# Create directory for keys if it doesn't exist
mkdir -p "$(dirname "$KEYS_FILE")"
mkdir -p "$(dirname "$ROOT_TOKEN_FILE")"

# Save unseal keys
echo "$UNSEAL_KEYS" > "$KEYS_FILE"
chmod 600 "$KEYS_FILE"

# Save root token
echo "$ROOT_TOKEN" > "$ROOT_TOKEN_FILE"
chmod 600 "$ROOT_TOKEN_FILE"

echo -e "${GREEN}✓ Vault initialized successfully${NC}"
echo ""
echo "=========================================="
echo "IMPORTANT: Save these keys securely!"
echo "=========================================="
echo ""
echo "Unseal Keys (5 keys, need 3 to unseal):"
echo "$UNSEAL_KEYS" | nl -w2 -s'. '
echo ""
echo "Root Token:"
echo "$ROOT_TOKEN"
echo ""
echo "Keys saved to:"
echo "  Unseal Keys: $KEYS_FILE"
echo "  Root Token: $ROOT_TOKEN_FILE"
echo ""
echo -e "${YELLOW}WARNING:${NC}"
echo "  - Store unseal keys in a secure location"
echo "  - Do NOT commit keys to git"
echo "  - Backup keys to secure off-site location"
echo "  - Root token provides full access - protect it!"
echo ""
echo "Next steps:"
echo "  1. Unseal Vault using: ./scripts/unseal-vault.sh"
echo "  2. Set VAULT_TOKEN environment variable"
echo "  3. Verify Vault is operational"
echo ""

