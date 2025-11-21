# Development Container (DevContainer)

A reusable development and staging environment for the infrastructure project.

**Location:** `/root/infra/.devcontainer/`

## Overview

This devcontainer provides a consistent, isolated development environment with all the tools needed to work with the infrastructure services. It includes:

- **Development Tools**: Git, Docker, Docker Compose, editors
- **Language Runtimes**: Node.js, Python, PHP, Ruby
- **Database Clients**: PostgreSQL, MySQL, Redis clients
- **Infrastructure Tools**: HashiCorp Vault, Terraform
- **VS Code Integration**: Pre-configured extensions and settings

## Quick Start

### Using VS Code

1. **Open in VS Code:**
   ```bash
   code /root/infra
   ```

2. **Reopen in Container:**
   - Press `F1` or `Ctrl+Shift+P`
   - Select "Dev Containers: Reopen in Container"
   - Wait for the container to build and start

3. **Start Developing:**
   - The workspace will open in `/workspace`
   - All services are accessible via Docker networks
   - Use the integrated terminal to run commands

### Using Docker Compose Directly

```bash
cd /root/infra/.devcontainer
docker compose up -d
docker compose exec devcontainer bash
```

## Features

### Pre-installed Tools

- **Docker & Docker Compose**: Full Docker CLI access
- **Node.js 20.x**: Latest LTS version with npm, yarn, pnpm
- **Python 3**: With pip and common packages
- **PHP**: With Composer
- **Ruby**: With Bundler (for Rails/Mastodon development)
- **Database Clients**: PostgreSQL, MySQL, Redis CLI tools
- **HashiCorp Tools**: Vault CLI, Terraform
- **Utilities**: jq, yq, curl, wget, git, vim, nano

### VS Code Extensions

Pre-installed extensions:
- Docker
- Remote Containers
- GitLens
- YAML support
- Python
- PHP Intelephense
- ESLint
- Tailwind CSS
- JSON tools
- Terraform/HCL

### Network Access

The devcontainer is connected to:
- **devcontainer-network**: Internal development network
- **traefik-network**: Access to all Traefik-managed services

You can access services by their container names:
- `vault` - HashiCorp Vault
- `traefik` - Traefik reverse proxy
- `wordpress-db` - WordPress MySQL database
- `wikijs-db` - WikiJS PostgreSQL database
- `linkstack-db` - LinkStack MySQL database

## Usage

### Accessing Services

```bash
# Access Vault
export VAULT_ADDR=http://vault:8200
vault status

# Access databases
psql -h wikijs-db -U wikijs -d wiki
mysql -h wordpress-db -u wordpress -p

# Access Redis (if running)
redis-cli -h redis-host
```

### Managing Infrastructure

```bash
# View all services status
infra-status

# View logs for a service
infra-logs vault
infra-logs wordpress

# Use docker compose aliases
dc ps          # docker compose ps
dc logs -f     # docker compose logs -f
dc up -d       # docker compose up -d
dc down        # docker compose down
```

### Working with Services

```bash
# Navigate to a service directory
cd vault
dc up -d

# View logs
dc logs -f

# Execute commands in containers
dc exec vault vault status
dc exec wordpress wp --info --allow-root
```

### Development Workflow

1. **Start Services:**
   ```bash
   cd /workspace/vault
   docker compose up -d
   ```

2. **Make Changes:**
   - Edit files in VS Code
   - Changes are synced to the container

3. **Test Changes:**
   ```bash
   # Test Vault
   curl http://vault:8200/v1/sys/health
   
   # Test WordPress
   curl http://wordpress:80
   ```

4. **Commit Changes:**
   ```bash
   git add .
   git commit -m "Your changes"
   ```

## Environment Variables

Pre-configured environment variables:
- `VAULT_ADDR=http://vault:8200`
- `DOCKER_HOST=unix:///var/run/docker.sock`
- `TZ=America/New_York`

Add custom variables in `devcontainer.json`:
```json
"remoteEnv": {
  "CUSTOM_VAR": "value"
}
```

## Port Forwarding

The following ports are automatically forwarded:
- `8080` - Traefik Dashboard
- `3000` - Node.js apps
- `3306` - MySQL
- `5432` - PostgreSQL
- `6379` - Redis
- `8200` - Vault

Access forwarded ports via `localhost`:
```bash
curl http://localhost:8080  # Traefik Dashboard
```

## Customization

### Adding Tools

Edit `.devcontainer/Dockerfile`:
```dockerfile
RUN apt-get install -y your-tool-here
```

### Adding VS Code Extensions

Edit `.devcontainer/devcontainer.json`:
```json
"extensions": [
  "publisher.extension-name"
]
```

### Custom Scripts

Add scripts to `.devcontainer/post-create.sh` or `.devcontainer/post-start.sh`

## Troubleshooting

### Container Won't Start

```bash
# Check Docker Compose logs
cd /root/infra/.devcontainer
docker compose logs

# Rebuild the container
docker compose build --no-cache
docker compose up -d
```

### Can't Access Docker

Ensure Docker socket is mounted:
```bash
ls -la /var/run/docker.sock
```

### Network Issues

Check network connectivity:
```bash
docker network inspect traefik-network
ping vault
```

### Permission Issues

The devcontainer runs as `devuser` (UID 1000). If you have permission issues:
```bash
sudo chown -R devuser:devuser /workspace
```

## Staging Environment

This devcontainer can also serve as a staging environment:

1. **Create Staging Overrides:**
   ```bash
   cp docker-compose.yml docker-compose.staging.yml
   # Modify for staging
   ```

2. **Use Different Networks:**
   ```bash
   docker compose -f docker-compose.yml -f docker-compose.staging.yml up -d
   ```

3. **Test Before Production:**
   - Make changes in devcontainer
   - Test locally
   - Deploy to staging
   - Deploy to production

## Best Practices

1. **Keep Container Updated:**
   ```bash
   docker compose build --pull
   ```

2. **Use Volume Mounts:**
   - Code changes are synced automatically
   - Use named volumes for caches

3. **Isolate Services:**
   - Each service has its own network
   - Use Traefik for external access

4. **Version Control:**
   - Commit `.devcontainer` changes
   - Document customizations

5. **Clean Up:**
   ```bash
   docker compose down -v  # Remove volumes
   docker system prune     # Clean up unused resources
   ```

## File Structure

```
.devcontainer/
├── devcontainer.json      # VS Code devcontainer config
├── docker-compose.yml     # Docker Compose configuration
├── Dockerfile            # Container image definition
├── post-create.sh        # Post-creation setup script
├── post-start.sh         # Post-start script
└── README.md            # This file
```

## Additional Resources

- [VS Code Dev Containers](https://code.visualstudio.com/docs/remote/containers)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [DevContainer Specification](https://containers.dev/)

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review service-specific README files
3. Check Docker and VS Code logs

