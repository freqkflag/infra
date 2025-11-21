# Infrastructure Repository

Central infrastructure management for all services and applications.

## Domain Architecture

See [DOMAIN_ARCHITECTURE.md](./DOMAIN_ARCHITECTURE.md) for complete domain structure.

### Quick Reference

- **`freqkflag.co`** - Infrastructure SPINE (automation, AI, tools, internal)
- **`cultofjoey.com`** - Personal creative space and brand
- **`twist3dkink.com`** - Mental health peer support/coaching business
- **`twist3dkinkst3r.com`** - PNP-friendly LGBT+ KINK PWA Community

## Services

**See [AGENTS.md](./AGENTS.md) for complete service catalog and details.**

### Quick Overview

**Infrastructure (`freqkflag.co`):**
- Traefik, Vault, WikiJS, n8n, Mailu, Supabase, Adminer

**Personal Brand (`cultofjoey.com`):**
- WordPress, LinkStack

**Community (`twist3dkinkst3r.com`):**
- Mastodon

## Quick Start

### Development Environment

Use the devcontainer for a consistent development environment:

```bash
code /root/infra
# Press F1 → "Dev Containers: Reopen in Container"
```

See [.devcontainer/README.md](./.devcontainer/README.md) for details.

### Service Management

```bash
# Start a service
cd vault && docker compose up -d

# View logs
docker compose logs -f

# Stop a service
docker compose down
```

## Directory Structure

```
infra/
├── .devcontainer/      # Development container configuration
├── adminer/            # Database management tool
├── linkstack/          # Link-in-bio platform
├── mailu/              # Mail server (IMAP/SMTP)
├── mastadon/           # Mastodon instance
├── n8n/                # Workflow automation
├── projects/           # Development projects and themes
├── supabase/           # Backend-as-a-Service
├── traefik/            # Reverse proxy and SSL
├── vault/              # Secrets management
├── wikijs/             # Documentation wiki
├── wordpress/          # WordPress site
├── AGENTS.md           # Complete service catalog
├── DOMAIN_ARCHITECTURE.md  # Domain structure documentation
└── README.md           # This file
```

## Traefik Integration

All services are automatically configured with Traefik for:
- SSL/TLS certificates (Let's Encrypt)
- HTTP to HTTPS redirect
- Security headers
- Service discovery

## Documentation

- **[Infrastructure Cookbook](./INFRASTRUCTURE_COOKBOOK.md)** - ⭐ **Your Personal Source of Truth** - Complete infrastructure reference
- **[Services Registry](./SERVICES.yml)** - Machine-readable service catalog (YAML)
- [Agents & Services](./AGENTS.md) - Complete service catalog and reference
- [AI Preferences](./PREFERENCES.md) - How AI should interact with this infrastructure
- [Domain Architecture](./DOMAIN_ARCHITECTURE.md) - Domain structure and assignments
- [Vault Operations](./VAULT_OPERATION_GUIDE.md) - Vault usage guide
- [Operational Guide](./OPERATIONAL_GUIDE.md) - Day-to-day operations
- [Security](./SECURITY.md) - Security policies and procedures
- [Disaster Recovery](./DISASTER_RECOVERY.md) - DR procedures
- [DevContainer](./.devcontainer/README.md) - Development environment setup

## Network Architecture

All services connect to:
- **traefik-network** - External network for Traefik routing
- **Service-specific networks** - Internal service communication

## Security Notes

- Change default passwords in `.env` files
- Keep `.env` files secure (600 permissions)
- Regularly update Docker images
- Use Vault for sensitive credentials
- Enable security headers via Traefik

## Maintenance

### Updates

```bash
# Update a service
cd <service-directory>
docker compose pull
docker compose up -d
```

### Backups

Each service has backup procedures documented in its README.

### Monitoring

- Traefik Dashboard: `http://localhost:8080`
- Service logs: `docker compose logs -f <service>`

---

**Last Updated:** 2025-11-20
