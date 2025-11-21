# DevContainer Quick Start Guide

## 🚀 Getting Started

### Option 1: VS Code (Recommended)

1. Open VS Code in the infra directory:
   ```bash
   code /root/infra
   ```

2. Reopen in Container:
   - Press `F1` → "Dev Containers: Reopen in Container"
   - Or click the popup notification

3. Wait for container to build (first time only)

### Option 2: Docker Compose

```bash
cd /root/infra/.devcontainer
docker compose up -d
docker compose exec devcontainer bash
```

## 📋 Common Commands

### Infrastructure Management

```bash
# View all services
infra-status

# View service logs
infra-logs vault
infra-logs wordpress

# Docker Compose shortcuts
dc ps          # List containers
dc logs -f     # Follow logs
dc up -d       # Start services
dc down        # Stop services
```

### Service Access

```bash
# Vault
export VAULT_ADDR=http://vault:8200
vault status

# Databases
psql -h wikijs-db -U wikijs -d wiki
mysql -h wordpress-db -u wordpress -p

# Traefik Dashboard
curl http://localhost:8080
```

### Working with Services

```bash
# Navigate to service
cd vault

# Start service
docker compose up -d

# View logs
docker compose logs -f

# Execute commands
docker compose exec vault vault status
```

## 🔧 Development Workflow

1. **Make Changes** - Edit files in VS Code
2. **Test Locally** - Use docker compose commands
3. **Commit** - Git is pre-configured
4. **Deploy** - Push to repository

## 🌐 Service URLs

- **Traefik Dashboard**: http://localhost:8080
- **Vault**: http://vault:8200 (internal)
- **WordPress**: http://wordpress:80 (internal)
- **WikiJS**: http://wikijs:3000 (internal)

## 📦 Installed Tools

- Docker & Docker Compose
- Node.js 20.x (npm, yarn, pnpm)
- Python 3 (pip, venv)
- PHP (Composer)
- Ruby (Bundler)
- PostgreSQL, MySQL, Redis clients
- HashiCorp Vault & Terraform
- Git, jq, yq, curl, wget

## 🆘 Troubleshooting

```bash
# Rebuild container
cd /root/infra/.devcontainer
docker compose build --no-cache
docker compose up -d

# Check logs
docker compose logs

# Check network
docker network inspect traefik-network
```

## 📚 More Information

See [README.md](./README.md) for complete documentation.

