# Infrastructure Runbooks Index

**Last Updated:** 2025-11-21  
**Purpose:** Central index of all service runbooks for quick reference

This page serves as the master index for all infrastructure service runbooks. Each runbook contains:
- Quick start/stop commands
- Health checks
- Common issues and fixes
- Backup/restore procedures
- Troubleshooting guides

---

## Infrastructure Services (freqkflag.co)

### Core Infrastructure
- [Traefik](./traefik-runbook.md) - Reverse proxy, SSL termination, service discovery
- [Infisical](./infisical-runbook.md) - Modern secrets management and secure credential storage

### Documentation & Tools
- [WikiJS](./wikijs-runbook.md) - Documentation and knowledge base
- [n8n](./n8n-runbook.md) - Workflow automation and integration platform
- [Node-RED](./nodered-runbook.md) - Flow-based development tool for visual programming
- [Adminer](./adminer-runbook.md) - Web-based database management tool

### Data & Storage
- [Supabase](./supabase-runbook.md) - Backend-as-a-Service platform
- [Mailu](./mailu-runbook.md) - IMAP/SMTP mail server

---

## Personal Brand Services (cultofjoey.com)

- [WordPress](./wordpress-runbook.md) - Main website for personal brand
- [LinkStack](./linkstack-runbook.md) - Link-in-bio page

---

## Community Services (twist3dkinkst3r.com)

- [Mastodon](./mastadon-runbook.md) - Federated social network instance

---

## Quick Commands

### Start All Services
```bash
cd /root/infra
./scripts/infra-service.sh start-all
```

### Stop All Services
```bash
cd /root/infra
./scripts/infra-service.sh stop-all
```

### Check Service Status
```bash
cd /root/infra
./scripts/infra-service.sh list
```

### View Service Logs
```bash
cd /root/infra/<service-dir>
docker compose logs -f
```

---

## Service Management

All services can be managed using the standardized script:

```bash
./scripts/infra-service.sh <command> <service-id>
```

**Commands:**
- `start` - Start a service
- `stop` - Stop a service
- `restart` - Restart a service
- `status` - Show service status
- `list` - List all services

---

## Related Documentation

- [Infrastructure Cookbook](../INFRASTRUCTURE_COOKBOOK.md) - Complete infrastructure reference
- [Services Registry](../SERVICES.yml) - Machine-readable service catalog
- [Agents & Services](../AGENTS.md) - Complete service catalog
- [Operational Guide](../OPERATIONAL_GUIDE.md) - Day-to-day operations

---

**Note:** This index is automatically maintained. For the most up-to-date service list, see [SERVICES.yml](../SERVICES.yml).

