# Vault Dev to Production Migration Guide

Step-by-step guide for migrating from dev mode to production mode.

## Prerequisites

- Backup current Vault data
- Export all secrets (if any)
- Access to Vault container
- Secure location to store unseal keys

## Migration Steps

### 1. Backup Current Data

```bash
cd /root/infra/vault

# Backup data directory
tar -czf vault-dev-backup-$(date +%Y%m%d_%H%M%S).tar.gz ./data

# Backup to secure location
cp vault-dev-backup-*.tar.gz /secure/backup/location/
```

### 2. Export Secrets (If Any)

If you have secrets in dev Vault, export them:

```bash
# Set environment
export VAULT_ADDR=http://localhost:32772
export VAULT_TOKEN=<dev-root-token>

# Export all secrets
vault kv get -format=json secret/env > vault-secrets-backup-$(date +%Y%m%d).json

# Or export specific paths
vault kv list secret/ > vault-paths-backup.txt
```

### 3. Stop Dev Vault

```bash
cd /root/infra/vault
docker compose down
```

### 4. Clear Data (Fresh Start)

**WARNING:** This will delete all existing data!

```bash
# Backup first!
cp -r ./data ./data.backup

# Clear data for fresh initialization
rm -rf ./data/*
```

### 5. Update Configuration

The docker-compose.yml and vault.hcl are already updated. Verify:

```bash
# Check docker-compose.yml doesn't have -dev flags
grep -v "^#" docker-compose.yml | grep -i dev

# Should return nothing (no dev mode flags)
```

### 6. Start Production Vault

```bash
docker compose up -d

# Wait for Vault to start
docker compose logs -f vault
# Press Ctrl+C when you see "Vault server started!"
```

### 7. Initialize Vault

```bash
docker compose exec vault /vault/scripts/init-vault.sh
```

This will:
- Generate 5 unseal keys
- Generate root token
- Save to `/vault/init/keys.txt` and `/vault/init/root-token.txt`

**IMPORTANT:** Copy the output and save unseal keys securely!

### 8. Unseal Vault

```bash
docker compose exec vault /vault/scripts/unseal-vault.sh
```

Or manually:
```bash
docker compose exec vault vault operator unseal <key-1>
docker compose exec vault vault operator unseal <key-2>
docker compose exec vault vault operator unseal <key-3>
```

### 9. Verify Vault is Operational

```bash
# Set environment
export VAULT_ADDR=https://vault.freqkflag.co
export VAULT_TOKEN=<root-token-from-step-7>

# Check status
vault status

# Should show:
# Sealed: false
# Initialized: true
```

### 10. Re-import Secrets (If Any)

If you exported secrets in step 2:

```bash
# Import from JSON backup
cat vault-secrets-backup-*.json | jq -r '.data.data | to_entries[] | "\(.key)=\(.value)"' | \
  while IFS='=' read -r key value; do
    vault kv patch secret/env "$key"="$value"
  done
```

Or manually:
```bash
vault kv put secret/env KEY1="value1" KEY2="value2" ...
```

### 11. Test Functionality

```bash
# Test read
vault kv get secret/env

# Test write
vault kv patch secret/env TEST_KEY="test_value"

# Test delete
vault kv patch -method=rm secret/env TEST_KEY
```

### 12. Update Environment Variables

Update your `~/.bashrc` or `~/.zshrc`:

```bash
export VAULT_ADDR=https://vault.freqkflag.co
export VAULT_TOKEN=<new-root-token>
```

## Post-Migration

### Secure Key Storage

1. **Copy unseal keys** from container to secure location:
   ```bash
   docker compose exec vault cat /vault/init/keys.txt > ~/secure/vault-unseal-keys.txt
   chmod 600 ~/secure/vault-unseal-keys.txt
   ```

2. **Backup keys** to secure off-site location
3. **Distribute keys** to trusted individuals (if needed)
4. **Document key locations** securely

### Create Admin User (Recommended)

Instead of using root token, create an admin user:

```bash
# Create admin policy
vault policy write admin - <<EOF
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF

# Create admin user (if using userpass auth)
vault auth enable userpass
vault write auth/userpass/users/admin \
  password=<secure-password> \
  policies=admin

# Use admin user instead of root token
vault auth -method=userpass username=admin
```

## Rollback Procedure

If you need to rollback to dev mode:

1. **Stop production Vault:**
   ```bash
   docker compose down
   ```

2. **Restore dev data:**
   ```bash
   rm -rf ./data/*
   tar -xzf vault-dev-backup-*.tar.gz
   ```

3. **Restore dev docker-compose.yml:**
   ```bash
   git checkout docker-compose.yml  # If using git
   # Or manually restore from backup
   ```

4. **Start dev Vault:**
   ```bash
   docker compose up -d
   ```

## Troubleshooting

### Vault Won't Start

- Check logs: `docker compose logs vault`
- Verify config: `docker compose config`
- Check disk space: `df -h`

### Cannot Initialize

- Ensure Vault is running
- Check data directory permissions
- Verify config file is correct

### Cannot Unseal

- Verify keys are correct
- Check seal status: `vault status`
- Ensure you have 3 of 5 keys

## Security Checklist

- [ ] Unseal keys backed up to secure location
- [ ] Root token stored securely
- [ ] Keys not committed to git
- [ ] Multiple secure backups of keys
- [ ] Admin user created (optional)
- [ ] Root token revoked (after admin setup, optional)
- [ ] Audit logging verified
- [ ] Access controls tested

## Notes

- Dev mode data cannot be directly migrated to production
- Production mode requires manual unsealing after restart
- Unseal keys are critical - lose them and you lose access
- Consider using auto-unseal (KMS) for production environments

