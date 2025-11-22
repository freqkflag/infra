#!/bin/bash
# Generate random secrets for Infisical
# Usage: ./generate-secrets.sh

set -euo pipefail

echo "=== Generating Infisical Secrets ==="
echo ""

# Function to generate random secret (32 bytes) encoded as base64 for AES-256
generate_secret() {
    openssl rand -base64 32 | tr -d '\n'
}

# Function to generate 32-byte base64-encoded key for ENCRYPTION_KEY (matches generate_secret for AES-256)
generate_encryption_key() {
    openssl rand -base64 32 | tr -d '\n'
}

echo "# Infisical Environment Variables"
echo "# Generated: $(date)"
echo ""
echo "# Database"
echo "POSTGRES_DB=infisical"
echo "POSTGRES_USER=infisical"
echo "POSTGRES_PASSWORD=$(generate_secret)"
echo ""
echo "# Encryption Keys"
echo "ENCRYPTION_KEY=$(generate_encryption_key)"
echo "ROOT_ENCRYPTION_KEY=$(generate_secret)"
echo ""
echo "# JWT Secrets"
echo "JWT_SIGNUP_SECRET=$(generate_secret)"
echo "JWT_REFRESH_SECRET=$(generate_secret)"
echo "JWT_AUTH_SECRET=$(generate_secret)"
echo "JWT_SERVICE_SECRET=$(generate_secret)"
echo "JWT_PROVIDER_AUTH_SECRET=$(generate_secret)"
echo ""
echo "# SMTP (optional)"
echo "SMTP_FROM_ADDRESS=noreply@freqkflag.co"
echo "SMTP_FROM_NAME=Infisical"
echo "SMTP_HOST=mail.freqkflag.co"
echo "SMTP_PORT=587"
echo "SMTP_SECURE=true"
echo "SMTP_USERNAME="
echo "SMTP_PASSWORD="
echo ""
echo "# Features"
echo "ENABLE_SIGNUP=true"
echo "LOG_LEVEL=info"
