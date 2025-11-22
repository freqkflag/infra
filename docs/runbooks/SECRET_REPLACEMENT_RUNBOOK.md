# Secret Replacement Runbook

**Purpose:** Step-by-step procedure for replacing `__UNSET__` placeholders in Infisical with real secret values  
**Audience:** Infrastructure Lead, DevOps Team  
**Last Updated:** 2025-11-22

---

## Prerequisites

- Access to Infisical web UI (`https://infisical.freqkflag.co`)
- Infisical CLI installed and authenticated (`infisical --version`)
- Access to Cloudflare Zero Trust dashboard (for tunnel tokens)
- Access to service documentation and compose files

---

## General Procedure

### Step 1: Identify Secret to Replace

1. Review `docs/INFISICAL_SECRETS_AUDIT.md` for prioritized list
2. Check service compose file to understand secret usage
3. Verify secret is actually `__UNSET__` or missing:
   ```bash
   cd /root/infra
   infisical export --env prod --path /prod --format env | grep "SECRET_NAME"
   ```

### Step 2: Generate or Obtain Secret Value

**For Passwords:**
```bash
# Generate 32-character random password
openssl rand -base64 32

# Or use pwgen if available
pwgen -s 32 1
```

**For API Tokens:**
- Cloudflare tokens: Generate via Cloudflare Zero Trust dashboard
- Infisical credentials: Create machine identity via Infisical UI
- Other API tokens: Follow service-specific documentation

**For Webhook URLs:**
- Format: `https://<service-domain>/webhook/<endpoint>`
- Include authentication token if required
- Test endpoint before storing

### Step 3: Store Secret in Infisical

**Via CLI:**
```bash
cd /root/infra
infisical secrets set --env prod --path /prod SECRET_NAME="secret_value"
```

**Via Web UI:**
1. Navigate to `https://infisical.freqkflag.co`
2. Select workspace and environment (`prod`)
3. Navigate to path `/prod`
4. Click "Add Secret" or edit existing secret
5. Enter secret name and value
6. Save changes

### Step 4: Verify Secret Injection

**Check Infisical Agent output:**
```bash
# Wait for Infisical Agent to poll (60s interval)
sleep 65

# Check .workspace/.env
cd /root/infra
grep "SECRET_NAME" .workspace/.env
```

**Or export directly:**
```bash
infisical export --env prod --path /prod --format env | grep "SECRET_NAME"
```

### Step 5: Restart Affected Service

```bash
# Restart specific service
cd /root/infra
docker compose -f services/<service>/compose.yml restart <service>

# Or via orchestrator
docker compose -f compose.orchestrator.yml restart <service>

# Verify service starts successfully
docker ps | grep <service>
docker logs <service> --tail 50
```

### Step 6: Verify Service Health

```bash
# Check health status
docker inspect <service> --format='{{.State.Health.Status}}'

# Or check service-specific health endpoint
curl -f https://<service-domain>/health || echo "Health check failed"
```

### Step 7: Document Completion

1. Update `docs/INFISICAL_SECRETS_AUDIT.md` - Mark secret as complete
2. Update `REMEDIATION_PLAN.md` - Note completion in Phase 1.4
3. Append to `server-changelog.md` - Record secret replacement

---

## Service-Specific Procedures

### Backstage Secrets

**Required Secrets:**
- `BACKSTAGE_DB_PASSWORD`
- `INFISICAL_CLIENT_ID`
- `INFISICAL_CLIENT_SECRET`

**Procedure:**
```bash
# 1. Generate database password
BACKSTAGE_DB_PASSWORD=$(openssl rand -base64 32)
infisical secrets set --env prod --path /prod BACKSTAGE_DB_PASSWORD="$BACKSTAGE_DB_PASSWORD"

# 2. Create Infisical machine identity (via UI)
# - Navigate to Infisical UI
# - Go to Machine Identities section
# - Create new machine identity for Backstage
# - Copy CLIENT_ID and CLIENT_SECRET

# 3. Store Infisical credentials
infisical secrets set --env prod --path /prod INFISICAL_CLIENT_ID="<from_ui>"
infisical secrets set --env prod --path /prod INFISICAL_CLIENT_SECRET="<from_ui>"

# 4. Restart Backstage
docker compose -f services/backstage/compose.yml restart backstage backstage-db

# 5. Verify
docker logs backstage --tail 50
docker logs backstage-db --tail 50
```

**Verification:**
- [ ] Backstage container starts without errors
- [ ] Database initializes successfully
- [ ] Infisical plugin authenticates
- [ ] Health check passes

---

### Cloudflare Tunnel Tokens

**Required Secrets:**
- `CF_TUNNEL_TOKEN_VPS`
- `CF_TUNNEL_TOKEN_MAC`
- `CF_TUNNEL_TOKEN_LINUX`
- `CF_DNS_API_TOKEN`

**Procedure:**
```bash
# 1. Generate tunnel tokens (via Cloudflare UI)
# - Navigate to Cloudflare Zero Trust dashboard
# - Go to Networks > Tunnels
# - Create or edit tunnel for each node
# - Copy tunnel token

# 2. Store tunnel tokens
infisical secrets set --env prod --path /prod CF_TUNNEL_TOKEN_VPS="<from_cloudflare>"
infisical secrets set --env prod --path /prod CF_TUNNEL_TOKEN_MAC="<from_cloudflare>"
infisical secrets set --env prod --path /prod CF_TUNNEL_TOKEN_LINUX="<from_cloudflare>"

# 3. Generate DNS API token (via Cloudflare UI)
# - Navigate to Cloudflare Dashboard
# - Go to My Profile > API Tokens
# - Create token with DNS:Edit permissions
# - Copy token

# 4. Store DNS API token
infisical secrets set --env prod --path /prod CF_DNS_API_TOKEN="<from_cloudflare>"

# 5. Restart Cloudflared containers
docker compose -f compose.orchestrator.yml restart cloudflared

# 6. Verify tunnels
docker logs cloudflared --tail 50
# Check for "Connection established" messages
```

**Verification:**
- [ ] Tunnels establish successfully (check logs)
- [ ] Services accessible via external domains
- [ ] SSL certificates generate successfully (check Traefik logs)

---

### Ghost Database Password

**Required Secret:**
- `GHOST_DB_PASSWORD`

**Procedure:**
```bash
# 1. Verify MariaDB user exists
docker exec mariadb mysql -u root -p"${MARIADB_ROOT_PASSWORD}" -e "SELECT User FROM mysql.user WHERE User='ghost';"

# 2. Generate password if user doesn't exist or password unknown
GHOST_DB_PASSWORD=$(openssl rand -base64 32)

# 3. Create or update MariaDB user (if needed)
docker exec mariadb mysql -u root -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS 'ghost'@'%' IDENTIFIED BY '${GHOST_DB_PASSWORD}';"
docker exec mariadb mysql -u root -p"${MARIADB_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON ghost.* TO 'ghost'@'%';"
docker exec mariadb mysql -u root -p"${MARIADB_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

# 4. Store password in Infisical
infisical secrets set --env prod --path /prod GHOST_DB_PASSWORD="$GHOST_DB_PASSWORD"

# 5. Restart Ghost
docker compose -f services/ghost/compose.yml restart ghost

# 6. Verify
docker logs ghost --tail 50
# Check for successful database connection
```

**Verification:**
- [ ] Ghost container starts without database errors
- [ ] Ghost can connect to MariaDB
- [ ] Health check passes

---

### Webhook URLs

**Required Secrets (Optional):**
- `INFISICAL_WEBHOOK_URL`
- `ALERTMANAGER_WEBHOOK_URL`
- `N8N_WEBHOOK_URL`

**Procedure:**
```bash
# 1. Determine webhook endpoint
# For n8n: https://n8n.freqkflag.co/webhook/<workflow-id>
# For Alertmanager: https://discord.com/api/webhooks/<id>/<token>
# For Infisical: Check if Infisical supports webhooks or use n8n

# 2. Store webhook URL
infisical secrets set --env prod --path /prod INFISICAL_WEBHOOK_URL="https://n8n.freqkflag.co/webhook/agent-events"

# 3. Configure receiving service (n8n workflow, Discord webhook, etc.)
# 4. Test webhook
curl -X POST "$WEBHOOK_URL" -H "Content-Type: application/json" -d '{"test": true}'

# 5. Restart services if needed
docker compose -f compose.orchestrator.yml restart n8n alertmanager
```

**Verification:**
- [ ] Webhook endpoint accessible
- [ ] Test webhook call succeeds
- [ ] Receiving service processes webhook correctly

---

## Troubleshooting

### Secret Not Appearing in .workspace/.env

**Issue:** Secret stored in Infisical but not appearing in `.workspace/.env`

**Solution:**
```bash
# 1. Check Infisical Agent status
docker ps | grep infisical-agent

# 2. Check Infisical Agent logs
docker logs infisical-agent --tail 50

# 3. Manually trigger template generation
cd /root/infra
infisical run --env prod -- cat prod.template

# 4. Restart Infisical Agent
docker restart infisical-agent
```

### Service Fails After Secret Update

**Issue:** Service fails to start or crashes after secret replacement

**Solution:**
```bash
# 1. Check service logs
docker logs <service> --tail 100

# 2. Verify secret format (no extra quotes, correct encoding)
infisical export --env prod --path /prod --format env | grep "SECRET_NAME"

# 3. Check service compose file for correct variable name
grep -r "SECRET_NAME" services/<service>/

# 4. Verify secret is actually set (not empty)
docker exec <service> env | grep "SECRET_NAME"
```

### Secret Value Contains Special Characters

**Issue:** Secret value contains characters that break shell parsing

**Solution:**
```bash
# Use single quotes or escape special characters
infisical secrets set --env prod --path /prod SECRET_NAME='value with $pecial chars'

# Or use base64 encoding
echo -n "value with special chars" | base64
infisical secrets set --env prod --path /prod SECRET_NAME="<base64_encoded>"
# Service must decode base64 value
```

---

## Security Best Practices

1. **Never log secret values** - Use `grep` to check presence, not values
2. **Rotate secrets regularly** - Follow rotation schedule in `docs/CREDENTIAL_ROTATION.md`
3. **Use strong passwords** - Minimum 32 characters, mixed character sets
4. **Limit secret access** - Only grant access to users/services that need it
5. **Audit secret access** - Review Infisical audit logs regularly
6. **Never commit secrets** - Verify `.workspace/.env` is in `.gitignore`

---

## References

- **Audit Document:** `docs/INFISICAL_SECRETS_AUDIT.md`
- **Remediation Plan:** `REMEDIATION_PLAN.md` (Phase 1.4)
- **Infisical Documentation:** `infisical/README.md`
- **Credential Rotation:** `docs/CREDENTIAL_ROTATION.md`

---

**Last Updated:** 2025-11-22  
**Next Review:** After all `__UNSET__` placeholders are replaced

