#!/bin/bash
# Vault Unseal Script
# Unseals Vault using unseal key shares

set -e

VAULT_ADDR="${VAULT_ADDR:-http://localhost:8200}"
KEYS_FILE="${KEYS_FILE:-/vault/init/keys.txt}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Vault Unseal Script"
echo "==================="
echo ""

# Check if Vault is running
if ! curl -s -f "${VAULT_ADDR}/v1/sys/health" > /dev/null 2>&1; then
    echo -e "${RED}Error: Cannot connect to Vault at ${VAULT_ADDR}${NC}"
    echo "Make sure Vault is running: docker compose up -d"
    exit 1
fi

# Check seal status
SEAL_STATUS=$(curl -s "${VAULT_ADDR}/v1/sys/seal-status" | jq -r '.sealed' 2>/dev/null || echo "unknown")

if [ "$SEAL_STATUS" = "false" ]; then
    echo -e "${GREEN}Vault is already unsealed${NC}"
    exit 0
fi

if [ "$SEAL_STATUS" != "true" ]; then
    echo -e "${RED}Error: Cannot determine Vault seal status${NC}"
    exit 1
fi

# Get progress
PROGRESS=$(curl -s "${VAULT_ADDR}/v1/sys/seal-status" | jq -r '.progress' 2>/dev/null || echo "0")
THRESHOLD=$(curl -s "${VAULT_ADDR}/v1/sys/seal-status" | jq -r '.t' 2>/dev/null || echo "3")

echo "Vault is sealed."
echo "Progress: $PROGRESS/$THRESHOLD keys provided"
echo ""

# Check if keys file exists
if [ ! -f "$KEYS_FILE" ]; then
    echo -e "${YELLOW}Keys file not found: $KEYS_FILE${NC}"
    echo "Please provide unseal keys manually:"
    echo ""
    
    KEYS_NEEDED=$((THRESHOLD - PROGRESS))
    for i in $(seq 1 $KEYS_NEEDED); do
        read -sp "Enter unseal key $i: " key
        echo ""
        
        if vault operator unseal "$key" > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Key $i accepted${NC}"
        else
            echo -e "${RED}✗ Invalid key${NC}"
            exit 1
        fi
        
        # Check if unsealed
        SEAL_STATUS=$(curl -s "${VAULT_ADDR}/v1/sys/seal-status" | jq -r '.sealed' 2>/dev/null)
        if [ "$SEAL_STATUS" = "false" ]; then
            echo -e "${GREEN}✓ Vault unsealed successfully${NC}"
            exit 0
        fi
    done
else
    # Read keys from file
    echo "Reading unseal keys from: $KEYS_FILE"
    echo ""
    
    KEYS=()
    while IFS= read -r line || [ -n "$line" ]; do
        if [ ! -z "$line" ]; then
            KEYS+=("$line")
        fi
    done < "$KEYS_FILE"
    
    if [ ${#KEYS[@]} -lt $THRESHOLD ]; then
        echo -e "${RED}Error: Not enough keys in file (need $THRESHOLD, found ${#KEYS[@]})${NC}"
        exit 1
    fi
    
    # Unseal with required keys
    KEYS_NEEDED=$((THRESHOLD - PROGRESS))
    for i in $(seq 0 $((KEYS_NEEDED - 1))); do
        if [ $i -lt ${#KEYS[@]} ]; then
            KEY="${KEYS[$i]}"
            echo "Using key $((i + 1))..."
            
            if vault operator unseal "$KEY" > /dev/null 2>&1; then
                echo -e "${GREEN}✓ Key $((i + 1)) accepted${NC}"
            else
                echo -e "${RED}✗ Invalid key${NC}"
                exit 1
            fi
            
            # Check if unsealed
            SEAL_STATUS=$(curl -s "${VAULT_ADDR}/v1/sys/seal-status" | jq -r '.sealed' 2>/dev/null)
            if [ "$SEAL_STATUS" = "false" ]; then
                echo -e "${GREEN}✓ Vault unsealed successfully${NC}"
                exit 0
            fi
        fi
    done
fi

# Final check
SEAL_STATUS=$(curl -s "${VAULT_ADDR}/v1/sys/seal-status" | jq -r '.sealed' 2>/dev/null)
if [ "$SEAL_STATUS" = "false" ]; then
    echo -e "${GREEN}✓ Vault unsealed successfully${NC}"
else
    echo -e "${YELLOW}Warning: Vault may still be sealed${NC}"
    echo "Check status: curl ${VAULT_ADDR}/v1/sys/seal-status"
    exit 1
fi

