#!/bin/bash
set -e

echo "🚀 Setting up development environment..."

# Install additional tools if needed
echo "📦 Installing additional development tools..."

# Create useful directories
mkdir -p ~/.local/bin
mkdir -p ~/.config

# Set up git (if not already configured)
if [ -z "$(git config --global user.name)" ]; then
    echo "⚠️  Git user.name not set. Please configure:"
    echo "   git config --global user.name 'Your Name'"
    echo "   git config --global user.email 'your.email@example.com'"
fi

# Install useful scripts
cat > ~/.local/bin/infra-status << 'EOF'
#!/bin/bash
echo "=== Infrastructure Status ==="
echo ""
echo "Docker Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "Docker Networks:"
docker network ls
echo ""
echo "Docker Volumes:"
docker volume ls
EOF

chmod +x ~/.local/bin/infra-status

cat > ~/.local/bin/infra-logs << 'EOF'
#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: infra-logs <service-name>"
    echo "Example: infra-logs vault"
    exit 1
fi
cd /workspace
find . -name "docker-compose.yml" -exec grep -l "$1" {} \; | head -1 | xargs -I {} sh -c 'cd $(dirname {}) && docker compose logs -f '$1''
EOF

chmod +x ~/.local/bin/infra-logs

echo "✅ Development environment setup complete!"
echo ""
echo "📝 Useful commands:"
echo "   infra-status  - Show infrastructure status"
echo "   infra-logs    - View logs for a service"
echo "   dc            - Alias for docker compose"
echo ""
echo "🔗 Services available:"
echo "   - Vault: http://vault:8200"
echo "   - Traefik Dashboard: http://localhost:8080"
echo ""

