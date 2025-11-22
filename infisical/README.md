# Infisical Secrets Management

**Status:** ⚙️ Configured (Ready to Deploy)  
**Domain:** `infisical.freqkflag.co`  
**Location:** `/root/infra/infisical/`

Modern, developer-friendly secrets management platform.

## Why Infisical?

- ✅ **Better Docker integration** - No restart issues
- ✅ **No unsealing required** - Simpler operations
- ✅ **Modern UI/UX** - Intuitive interface
- ✅ **Developer-friendly** - Simple API and CLI
- ✅ **Easy setup** - Simple configuration

## Quick Start

### 1. Generate Secrets

```bash
cd /root/infra/infisical
./generate-secrets.sh > .env
# Review and edit .env if needed
```

### 2. Start Services

```bash
docker compose up -d
```

### 3. Access Infisical

- **Web UI:** https://infisical.freqkflag.co
- **API:** https://infisical.freqkflag.co/api/v1

### 4. Initial Setup

1. Visit the web UI
2. Create your first project
3. Set up your organization
4. Start adding secrets

## Features

- Encrypted secret storage
- Version-controlled secrets
- API access for applications
- Audit logging
- Modern web UI
- CLI tools
- Self-hosted option
- No unsealing required

## Migration from Vault

### Automated Migration

```bash
# Set environment variables
export VAULT_ADDR=https://vault.freqkflag.co
export VAULT_TOKEN=<your-vault-token>
export INFISICAL_URL=https://infisical.freqkflag.co
export INFISICAL_TOKEN=<your-infisical-token>
export INFISICAL_PROJECT_ID=<your-project-id>

# Run migration
./migrate-from-vault.sh
```

### Manual Migration

1. Export secrets from Vault:
   ```bash
   vault kv get -format=json secret/env > vault-secrets.json
   ```

2. Import to Infisical via UI or API

## Configuration

### Environment Variables

See `.env.example` for all available options.

Key variables:
- `POSTGRES_*` - Database configuration
- `ENCRYPTION_KEY` - Encryption key (generate with `openssl rand -base64 32`)
- `JWT_*_SECRET` - JWT signing secrets (generate with `openssl rand -base64 32`)
- `SMTP_*` - Email configuration (optional, can use Mailu)

### Generate Secrets Script

```bash
./generate-secrets.sh > .env
```

This generates all required random secrets automatically.

## Management

### Start
```bash
docker compose up -d
```

### Stop
```bash
docker compose down
```

### Logs
```bash
docker compose logs -f infisical
```

### Backup
```bash
# Backup database
docker compose exec infisical-db pg_dump -U infisical infisical > backup.sql
```

## Integration

### Infisical Agent (Automatic Secret Sync)

**Status:** ✅ Configured and Running (2025-11-22)

The Infisical Agent automatically syncs secrets from Infisical `/prod` path to `.workspace/.env` every 60 seconds.

**Configuration:**
- **Config File:** `/root/infra/infisical-agent.yml`
- **Template:** `prod.template` (fetches from `/prod` path)
- **Destination:** `/root/infra/.workspace/.env`
- **Polling Interval:** 60 seconds
- **Project ID:** `8c430744-1a5b-4426-af87-e96d6b9c91e3`

**Start Agent:**
```bash
cd /root/infra
infisical agent --config /root/infra/infisical-agent.yml
```

**Verify Agent Status:**
```bash
# Check if agent is running
ps aux | grep "infisical.*agent"

# Check agent token file
ls -lh .workspace/.infisical-agent-token

# Check last sync time
stat .workspace/.env | grep Modify
```

**Manual Secret Sync:**
```bash
# Export secrets directly (if agent not running)
infisical export --env prod --path /prod --format env > .workspace/.env
```

**Documentation:** See `gitlab/SECRETS_SYNC.md` for detailed configuration and troubleshooting.

### API Usage

```bash
# Get secret
curl -H "Authorization: Bearer $INFISICAL_TOKEN" \
  https://infisical.freqkflag.co/api/v1/secrets/<secret-key>
```

### CLI Installation

```bash
npm install -g infisical
# or
brew install infisical
```

## Documentation

- [Infisical Docs](https://infisical.com/docs)
- [Docker Deployment](https://infisical.com/docs/documentation/deploying/self-hosting/docker)
- [API Reference](https://infisical.com/docs/documentation/api/overview)
- [CLI Reference](https://infisical.com/docs/documentation/cli/overview)

## Troubleshooting

### Service won't start
- Check `.env` file exists and has all required variables
- Verify database is healthy: `docker compose ps infisical-db`
- Check logs: `docker compose logs infisical`

### Can't access web UI
- Verify Traefik routing: `curl -I https://infisical.freqkflag.co`
- Check container is on traefik-network
- Review Traefik logs for routing issues

### Migration issues
- Ensure Infisical is running and accessible
- Verify Infisical token has proper permissions
- Check project ID is correct

