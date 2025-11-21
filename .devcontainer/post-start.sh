#!/bin/bash
set -e

echo "🔄 Starting development environment..."

# Check if we can access Docker
if docker ps > /dev/null 2>&1; then
    echo "✅ Docker access confirmed"
else
    echo "⚠️  Warning: Cannot access Docker. Make sure Docker socket is mounted."
fi

# Check network connectivity to services
echo "🔍 Checking service connectivity..."

if ping -c 1 vault > /dev/null 2>&1; then
    echo "✅ Vault is reachable"
else
    echo "⚠️  Vault is not reachable (may not be running)"
fi

# Display current directory structure
echo ""
echo "📁 Current workspace: /workspace"
echo "   Available services:"
ls -d */ 2>/dev/null | grep -v "^\.devcontainer" | sed 's|/$||' | sed 's/^/   - /' || echo "   (none)"

echo ""
echo "🎉 Development environment ready!"

