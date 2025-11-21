# HashiCorp Vault Operation Guide

## What is Vault?

Vault is a secure secrets management system that stores your passwords, API keys, tokens, and other sensitive information in an encrypted database. Think of it as a super-secure digital safe for all your credentials.

**Your Vault Location:** `https://vault.freqkflag.co`

---

## Quick Start

### 1. Initial Setup (First Time Only)

If Vault is not initialized, you need to initialize it:

```bash
cd /root/infra/vault
docker compose up -d
docker compose exec vault /vault/scripts/init-vault.sh
```

This will generate:
- 5 unseal keys (you need 3 to unseal)
- 1 root token

**IMPORTANT:** Save these keys securely! They are saved to:
- Unseal keys: `/vault/init/keys.txt` (inside container)
- Root token: `/vault/init/root-token.txt` (inside container)

### 2. Unseal Vault

After starting Vault, it must be unsealed:

```bash
# Automatic (uses keys from file)
docker compose exec vault /vault/scripts/unseal-vault.sh

# Or manual (requires 3 of 5 keys)
docker compose exec vault vault operator unseal <key-1>
docker compose exec vault vault operator unseal <key-2>
docker compose exec vault vault operator unseal <key-3>
```

### 3. Set Up Your Environment

Before using Vault, you need to tell your computer where it is and authenticate:

```bash
export VAULT_ADDR=https://vault.freqkflag.co
export VAULT_TOKEN=<your-root-token>
```

**Tip:** Add these lines to your `~/.bashrc` or `~/.zshrc` file so they're set automatically every time you open a terminal.

---

## Basic Operations

### Viewing Secrets

#### See All Secrets at Once
```bash
vault kv get secret/env
```

#### Get a Specific Secret
```bash
vault kv get -field=SECRET_NAME secret/env
```

**Example:**
```bash
vault kv get -field=GITHUB_ACCESS_TOKEN secret/env
```

#### Get Multiple Specific Secrets
```bash
vault kv get -format=json secret/env | jq '.data.data | {GITHUB_ACCESS_TOKEN, OPENAI_API_KEY}'
```

### Adding or Updating Secrets

#### Update a Single Secret
```bash
vault kv patch secret/env GITHUB_ACCESS_TOKEN="new_token_value"
```

#### Add Multiple New Secrets
```bash
vault kv patch secret/env KEY1="value1" KEY2="value2" KEY3="value3"
```

#### Replace All Secrets (Use with Caution!)
```bash
vault kv put secret/env KEY1="value1" KEY2="value2" KEY3="value3"
```

### Deleting Secrets

#### Delete a Specific Secret Field
```bash
vault kv patch -method=rm secret/env KEY_TO_DELETE
```

#### Delete the Entire Secret Path
```bash
vault kv delete secret/env
```

---

## Common Use Cases

### 1. Export All Secrets to a File

```bash
vault kv get -format=json secret/env | jq -r '.data.data | to_entries[] | "\(.key)=\(.value)"' > secrets_backup.txt
```

### 2. Use Secrets in a Script

```bash
#!/bin/bash
export VAULT_ADDR=https://vault.freqkflag.co
export VAULT_TOKEN=zucbyg2os11v2mkbeka5d943cqfdzbwy

# Get a secret and use it
GITHUB_TOKEN=$(vault kv get -field=GITHUB_ACCESS_TOKEN secret/env)
echo "Using GitHub token: ${GITHUB_TOKEN:0:10}..."
```

### 3. Update Secrets from a .env File

If you have a `.env` file and want to update Vault:

```bash
# Use the import script
/root/infra/import-secrets-to-vault.sh
```

### 4. Check Vault Status

```bash
vault status
```

This shows:
- Whether Vault is sealed (locked) or unsealed (accessible)
- Version information
- Cluster information

---

## Vault Sealing and Unsealing

### What is Sealing?

When Vault is **sealed**, it's locked and cannot be accessed. This is a security feature. In production mode, Vault seals automatically on restart and must be unsealed manually.

### Check if Vault is Sealed

```bash
vault status
# or
curl https://vault.freqkflag.co/v1/sys/seal-status
```

Look for `Sealed: false` (unsealed/accessible) or `Sealed: true` (sealed/locked).

### Unseal Vault (If Sealed)

In production mode, Vault uses **Shamir's Secret Sharing**:
- 5 unseal keys are generated
- You need **3 of 5 keys** to unseal
- Keys are stored in `/vault/init/keys.txt` (inside container)

**Automatic unseal (recommended):**
```bash
cd /root/infra/vault
docker compose exec vault /vault/scripts/unseal-vault.sh
```

**Manual unseal:**
```bash
docker compose exec vault vault operator unseal <key-1>
docker compose exec vault vault operator unseal <key-2>
docker compose exec vault vault operator unseal <key-3>
```

**Via API:**
```bash
curl -X PUT https://vault.freqkflag.co/v1/sys/unseal \
  -d '{"key":"<unseal-key-1>"}'
curl -X PUT https://vault.freqkflag.co/v1/sys/unseal \
  -d '{"key":"<unseal-key-2>"}'
curl -X PUT https://vault.freqkflag.co/v1/sys/unseal \
  -d '{"key":"<unseal-key-3>"}'
```

### Seal Vault (Lock It)

To lock Vault for security:

```bash
vault operator seal
# or
curl -X PUT https://vault.freqkflag.co/v1/sys/seal \
  -H "X-Vault-Token: <token>"
```

---

## Security Best Practices

### 1. Protect Your Unseal Keys

Your unseal keys are critical for accessing Vault. Keep them secure!

- **Never commit keys to git**
- **Store keys securely** (backup to secure off-site location)
- **Distribute keys** to trusted individuals (5 keys, need 3)
- **Backup keys** to multiple secure locations
- Keys are stored in `/vault/init/keys.txt` (inside container)

### 2. Protect Your Root Token

Your root token has full access to everything. Keep it secure!

- **Never commit it to git**
- **Store it securely** (consider using Vault itself or secure password manager)
- **Don't share it** unless absolutely necessary
- **Create admin users** and revoke root token after setup

### 2. Use App Roles (Advanced)

For applications, create app-specific tokens with limited permissions instead of using the root token.

### 3. Regular Backups

Export your secrets regularly:

```bash
vault kv get -format=json secret/env > vault_backup_$(date +%Y%m%d).json
```

### 4. Rotate Secrets Regularly

Update passwords and tokens periodically:

```bash
vault kv patch secret/env PASSWORD="new_secure_password"
```

---

## Troubleshooting

### "Error: permission denied"

- Check that `VAULT_TOKEN` is set correctly
- Verify the token hasn't expired
- Ensure Vault is unsealed (`vault status`)

### "Error: connection refused"

- Verify `VAULT_ADDR` is correct: `https://vault.twist3dkink.com`
- Check your internet connection
- Ensure the Vault service is running

### "Error: no value found"

- The secret path might not exist
- Check the path spelling: `secret/env` (not `secrets/env`)
- Verify the secret was created successfully

### Vault is Sealed

```bash
# Check status
vault status

# If sealed, unseal it (requires 3 of 5 keys)
cd /root/infra/vault
docker compose exec vault /vault/scripts/unseal-vault.sh

# Or manually
docker compose exec vault vault operator unseal <key-1>
docker compose exec vault vault operator unseal <key-2>
docker compose exec vault vault operator unseal <key-3>
```

---

## Useful Commands Reference

| Command | Purpose |
|---------|---------|
| `vault status` | Check Vault health and seal status |
| `vault kv get secret/env` | View all secrets |
| `vault kv get -field=KEY secret/env` | Get one specific secret |
| `vault kv patch secret/env KEY="value"` | Update/add a secret |
| `vault kv delete secret/env` | Delete all secrets (dangerous!) |
| `vault operator unseal KEY` | Unlock Vault |
| `vault operator seal` | Lock Vault |
| `vault auth -method=token token=TOKEN` | Authenticate with a token |
| `vault kv list secret/` | List all secret paths |

---

## Integration Examples

### Using Vault Secrets in Docker Compose

```yaml
services:
  app:
    environment:
      GITHUB_TOKEN: ${GITHUB_TOKEN}
```

Then in your script:
```bash
export GITHUB_TOKEN=$(vault kv get -field=GITHUB_ACCESS_TOKEN secret/env)
docker-compose up
```

### Using Vault Secrets in Python

```python
import os
import subprocess

def get_vault_secret(key):
    cmd = ['vault', 'kv', 'get', '-field', key, 'secret/env']
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout.strip()

github_token = get_vault_secret('GITHUB_ACCESS_TOKEN')
```

### Using Vault Secrets in Node.js

```javascript
const { execSync } = require('child_process');

function getVaultSecret(key) {
  return execSync(`vault kv get -field=${key} secret/env`, { encoding: 'utf8' }).trim();
}

const githubToken = getVaultSecret('GITHUB_ACCESS_TOKEN');
```

---

## Current Secrets Stored

Your Vault currently contains **81 secrets** organized in the `secret/env` path, including:

- **API Keys:** GitHub, OpenAI, Anthropic, Cloudflare
- **Service Tokens:** Infisical, Coolify, Dokploy
- **Database Credentials:** Dokploy database password
- **Domain Configuration:** Cloudflare zone IDs, tunnel tokens
- **Infrastructure:** VPS, Homelab, MacLab configurations
- **Application Keys:** Ghost, Strapi API keys
- **And more...**

---

## Getting Help

- **Vault Documentation:** https://developer.hashicorp.com/vault/docs
- **Vault CLI Reference:** `vault --help` or `vault kv --help`
- **Check Vault Status:** `vault status`

---

## Quick Reference Card

```bash
# Setup (add to ~/.bashrc)
export VAULT_ADDR=https://vault.freqkflag.co
export VAULT_TOKEN=<your-root-token>

# View all secrets
vault kv get secret/env

# Get one secret
vault kv get -field=KEY_NAME secret/env

# Update secret
vault kv patch secret/env KEY_NAME="new_value"

# Check status
vault status

# Unseal (if needed - requires 3 of 5 keys)
cd /root/infra/vault
docker compose exec vault /vault/scripts/unseal-vault.sh
```

---

**Last Updated:** November 20, 2025  
**Vault Mode:** Production  
**Unseal Keys:** 5 keys, 3 required to unseal  
**Total Secrets:** 81 (if migrated from dev mode)
