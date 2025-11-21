# Vault Deployment

HashiCorp Vault running in **production mode**.

**Location:** `/root/infra/vault/`

## Quick Start

### First Time Setup

```bash
cd /root/infra/vault

# 1. Start Vault (will be sealed initially)
docker compose up -d

# 2. Wait for Vault to start
docker compose logs -f vault

# 3. Initialize Vault (first time only)
docker compose exec vault /vault/scripts/init-vault.sh

# 4. Unseal Vault (requires 3 of 5 unseal keys)
docker compose exec vault /vault/scripts/unseal-vault.sh

# 5. Set root token (from initialization output)
export VAULT_TOKEN=<root-token>
export VAULT_ADDR=https://vault.freqkflag.co
```

### Normal Operations

```bash
# Start Vault
docker compose up -d

# Unseal Vault (after restart)
docker compose exec vault /vault/scripts/unseal-vault.sh

# Check status
curl https://vault.freqkflag.co/v1/sys/health
```

## Configuration

- **Port:** `32772:8200` (mapped to host port 32772)
- **Domain:** `vault.freqkflag.co` (via Traefik)
- **Storage:** File storage backend (`./data/`)
- **Logs:** `./logs/` (application and audit logs)
- **Config:** `./config/vault.hcl`

## Production Features

- ✅ Production mode (not dev mode)
- ✅ Unseal key protection (5 keys, 3 required)
- ✅ Audit logging enabled
- ✅ Secure key storage
- ✅ TLS termination via Traefik

## Initialization

Vault must be initialized on first run:

```bash
docker compose exec vault /vault/scripts/init-vault.sh
```

This will:
- Generate 5 unseal keys (need 3 to unseal)
- Generate root token
- Save keys to `/vault/init/keys.txt`
- Save root token to `/vault/init/root-token.txt`

**IMPORTANT:** 
- Save unseal keys securely (not in git)
- Backup keys to secure off-site location
- Protect root token

## Unsealing

After Vault starts or restarts, it must be unsealed:

```bash
# Automatic (uses keys from file)
docker compose exec vault /vault/scripts/unseal-vault.sh

# Manual
docker compose exec vault vault operator unseal <key-1>
docker compose exec vault vault operator unseal <key-2>
docker compose exec vault vault operator unseal <key-3>
```

## Access

### Via CLI

```bash
export VAULT_ADDR=https://vault.freqkflag.co
export VAULT_TOKEN=<your-token>

vault status
vault kv list secret/
```

### Via Web UI

- URL: https://vault.freqkflag.co
- Login with root token or user token

### Via API

```bash
curl -H "X-Vault-Token: <token>" \
  https://vault.freqkflag.co/v1/sys/health
```

## Management

### Start

```bash
docker compose up -d
# Then unseal: docker compose exec vault /vault/scripts/unseal-vault.sh
```

### Stop

```bash
docker compose down
```

### Restart

```bash
docker compose restart
# Then unseal: docker compose exec vault /vault/scripts/unseal-vault.sh
```

### Logs

```bash
# Application logs
docker compose logs -f vault

# Audit logs (inside container)
docker compose exec vault tail -f /vault/logs/audit.log
```

### Status

```bash
# Health check
curl https://vault.freqkflag.co/v1/sys/health

# Seal status
curl https://vault.freqkflag.co/v1/sys/seal-status

# Via CLI
vault status
```

## Security

### Unseal Keys

- **Location:** `/vault/init/keys.txt` (inside container)
- **Backup:** Copy to secure location outside container
- **Protection:** File permissions 600
- **Storage:** Never commit to git

### Root Token

- **Location:** `/vault/init/root-token.txt` (inside container)
- **Usage:** Only for initial setup
- **Best Practice:** Create admin user and revoke root token

### Audit Logs

- **Location:** `./logs/audit.log`
- **Format:** JSON
- **Retention:** Configure log rotation

## Migration from Dev Mode

If migrating from dev mode:

1. **Backup dev data:**
   ```bash
   tar -czf vault-dev-backup-$(date +%Y%m%d).tar.gz ./data
   ```

2. **Export secrets** (if any):
   ```bash
   # Use Vault CLI to export secrets
   vault kv list secret/ > secrets-list.txt
   ```

3. **Stop dev Vault:**
   ```bash
   docker compose down
   ```

4. **Clear data** (fresh start):
   ```bash
   rm -rf ./data/*
   ```

5. **Start production Vault:**
   ```bash
   docker compose up -d
   ```

6. **Initialize:**
   ```bash
   docker compose exec vault /vault/scripts/init-vault.sh
   ```

7. **Unseal:**
   ```bash
   docker compose exec vault /vault/scripts/unseal-vault.sh
   ```

8. **Re-import secrets** (if needed)

## Troubleshooting

### Vault Won't Start

- Check logs: `docker compose logs vault`
- Verify config: `docker compose config`
- Check disk space: `df -h`

### Cannot Unseal

- Verify keys are correct
- Check seal status: `curl https://vault.freqkflag.co/v1/sys/seal-status`
- Ensure Vault is running

### Connection Refused

- Check Vault is running: `docker ps | grep vault`
- Verify Traefik routing
- Check SSL certificate

## Scripts

- `scripts/init-vault.sh` - Initialize Vault
- `scripts/unseal-vault.sh` - Unseal Vault

## Documentation

- [Vault Operation Guide](../../VAULT_OPERATION_GUIDE.md)
- [Official Vault Docs](https://www.vaultproject.io/docs)
