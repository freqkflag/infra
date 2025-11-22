#!/bin/bash
# Infisical MCP Server Setup Script
# This script helps configure the Infisical MCP server for Cursor IDE

set -e

echo "=== Infisical MCP Server Setup ==="
echo ""

# Check if Infisical CLI is installed
if ! command -v infisical &> /dev/null; then
    echo "❌ Infisical CLI not found. Please install it first:"
    echo "   npm install -g @infisical/cli"
    exit 1
fi

echo "✅ Infisical CLI found: $(infisical --version)"
echo ""

# Check if .workspace/.env exists
if [ ! -f "../.workspace/.env" ]; then
    echo "⚠️  .workspace/.env not found. Creating from template..."
    mkdir -p ../.workspace
    touch ../.workspace/.env
fi

# Check for required environment variables
echo "Checking for required environment variables..."
REQUIRED_VARS=(
    "INFISICAL_UNIVERSAL_AUTH_CLIENT_ID"
    "INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET"
)

MISSING_VARS=()
for var in "${REQUIRED_VARS[@]}"; do
    if ! grep -q "^${var}=" ../.workspace/.env 2>/dev/null; then
        MISSING_VARS+=("$var")
    fi
done

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo ""
    echo "⚠️  Missing required environment variables:"
    for var in "${MISSING_VARS[@]}"; do
        echo "   - $var"
    done
    echo ""
    echo "To set these variables:"
    echo "1. Create a Machine Identity in Infisical:"
    echo "   - Log into https://infisical.freqkflag.co"
    echo "   - Navigate to Settings → Machine Identities"
    echo "   - Create a new Machine Identity"
    echo "   - Generate Universal Auth credentials"
    echo ""
    echo "2. Add credentials to Infisical secrets:"
    echo "   infisical secrets set --env prod --path /prod INFISICAL_UNIVERSAL_AUTH_CLIENT_ID=<client-id>"
    echo "   infisical secrets set --env prod --path /prod INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET=<client-secret>"
    echo ""
    echo "3. Wait for Infisical Agent to sync (60s) or manually update .workspace/.env"
    echo ""
    exit 1
fi

echo "✅ Required environment variables found"
echo ""

# Test Infisical connection
echo "Testing Infisical connection..."
if curl -s -f -I "https://infisical.freqkflag.co/api/status" > /dev/null 2>&1; then
    echo "✅ Infisical is accessible at https://infisical.freqkflag.co"
else
    echo "⚠️  Could not reach Infisical at https://infisical.freqkflag.co"
    echo "   Verify the service is running and accessible"
fi

echo ""
echo "=== Cursor IDE Configuration ==="
echo ""
echo "To configure Cursor IDE to use the Infisical MCP server:"
echo ""
echo "1. Add the following to your Cursor MCP configuration:"
echo "   (Location: ~/.config/cursor/mcp.json or Cursor settings)"
echo ""
cat <<'EOF'
{
  "mcpServers": {
    "infisical": {
      "command": "npx",
      "args": ["-y", "@infisical/mcp"],
      "env": {
        "INFISICAL_HOST_URL": "https://infisical.freqkflag.co",
        "INFISICAL_UNIVERSAL_AUTH_CLIENT_ID": "${INFISICAL_UNIVERSAL_AUTH_CLIENT_ID}",
        "INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET": "${INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET}"
      }
    }
  }
}
EOF

echo ""
echo "2. Restart Cursor IDE to load the MCP configuration"
echo ""
echo "3. Test the MCP server using MCP Inspector:"
echo "   cd /root/infra/infisical-mcp"
echo "   INFISICAL_UNIVERSAL_AUTH_CLIENT_ID=<id> \\"
echo "   INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET=<secret> \\"
echo "   INFISICAL_HOST_URL=https://infisical.freqkflag.co \\"
echo "   npx @modelcontextprotocol/inspector npx -y @infisical/mcp"
echo ""
echo "✅ Setup script completed!"
echo "   See README.md for detailed documentation"

