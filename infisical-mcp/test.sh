#!/bin/bash
# Infisical MCP Server Test Script
# This script tests the Infisical MCP server connectivity and functionality

set -e

echo "=== Infisical MCP Server Test ==="
echo ""

# Load from .workspace/.env if available (BEFORE validation checks)
if [ -f "../.workspace/.env" ]; then
    echo "Loading environment variables from .workspace/.env..."
    set -a
    source ../.workspace/.env
    set +a
    echo "✅ Environment variables loaded"
    echo ""
fi

# Check if required environment variables are set
if [ -z "$INFISICAL_UNIVERSAL_AUTH_CLIENT_ID" ]; then
    echo "❌ INFISICAL_UNIVERSAL_AUTH_CLIENT_ID not set"
    echo "   Source from .workspace/.env or set manually"
    echo ""
    echo "   export INFISICAL_UNIVERSAL_AUTH_CLIENT_ID=<client-id>"
    echo "   export INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET=<client-secret>"
    echo "   export INFISICAL_HOST_URL=https://infisical.freqkflag.co"
    exit 1
fi

if [ -z "$INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET" ]; then
    echo "❌ INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET not set"
    echo "   Source from .workspace/.env or set manually"
    echo ""
    echo "   export INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET=<client-secret>"
    exit 1
fi

# Set default INFISICAL_HOST_URL if not set
export INFISICAL_HOST_URL=${INFISICAL_HOST_URL:-https://infisical.freqkflag.co}

echo "Configuration:"
echo "  INFISICAL_HOST_URL: $INFISICAL_HOST_URL"
echo "  INFISICAL_UNIVERSAL_AUTH_CLIENT_ID: ${INFISICAL_UNIVERSAL_AUTH_CLIENT_ID:0:10}... (hidden)"
echo ""

# Test 1: Check Infisical connectivity
echo "Test 1: Checking Infisical connectivity..."
if curl -s -f -I "$INFISICAL_HOST_URL/api/status" > /dev/null 2>&1; then
    echo "✅ Infisical is accessible at $INFISICAL_HOST_URL"
else
    echo "❌ Could not reach Infisical at $INFISICAL_HOST_URL"
    exit 1
fi
echo ""

# Test 2: Check Node.js and npx
echo "Test 2: Checking Node.js and npx..."
if command -v node &> /dev/null; then
    echo "✅ Node.js found: $(node --version)"
else
    echo "❌ Node.js not found. Please install Node.js 14+"
    exit 1
fi

if command -v npx &> /dev/null; then
    echo "✅ npx found: $(npx --version)"
else
    echo "❌ npx not found. Please install npm (comes with Node.js)"
    exit 1
fi
echo ""

# Test 3: Test MCP server with MCP Inspector
echo "Test 3: Testing MCP server..."
echo "   This will launch MCP Inspector in your browser"
echo "   Press Ctrl+C to exit"
echo ""
echo "   Opening MCP Inspector..."
echo "   URL: http://localhost:5173 (or check terminal output)"
echo ""

# Export environment variables explicitly
export INFISICAL_UNIVERSAL_AUTH_CLIENT_ID
export INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET
export INFISICAL_HOST_URL

# Launch MCP Inspector
npx @modelcontextprotocol/inspector npx -y @infisical/mcp

