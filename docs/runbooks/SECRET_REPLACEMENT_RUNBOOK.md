# Secret Replacement Runbook

**Purpose:** Step-by-step procedure for replacing `__UNSET__` placeholders in Infisical with real secret values  
**Audience:** Infrastructure Lead, DevOps Team  
**Last Updated:** 2025-11-22  
**Status:** ✅ All __UNSET__ placeholders resolved (2025-11-22)

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

### Cloudflare DNS API Token

**Required Secret:**
- `CF_DNS_API_TOKEN` - Cloudflare DNS API token for DNS management and DNS-01 challenge

**Note:** Using Cloudflare DNS management only (not Cloudflared tunnels). Services are accessed directly via public IP with DNS records managed through Cloudflare API.

**Procedure:**
```bash
# 1. Generate DNS API token (via Cloudflare UI)
# - Navigate to Cloudflare Dashboard
# - Go to My Profile > API Tokens
# - Click "Create Token"
# - Use "Edit zone DNS" template or create custom token with:
#   - Zone: DNS:Edit permissions
#   - Zone Settings: Zone:Read permissions (for zone ID lookup)
# - Copy token

# 2. Store DNS API token in Infisical
infisical secrets set --env prod --path /prod CF_DNS_API_TOKEN="<from_cloudflare>"

# 3. Wait for Infisical Agent to sync (60s polling) or verify manually
grep "CF_DNS_API_TOKEN" .workspace/.env

# 4. Verify DNS API access
# Test DNS record management (requires CF_ACCOUNT_ID and CF_ZONE_* variables)
curl -X GET "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_FREQKFLAG_CO}/dns_records" \
  -H "Authorization: Bearer ${CF_DNS_API_TOKEN}" \
  -H "Content-Type: application/json"

# 5. Verify SSL certificate generation
# Check Traefik logs for successful DNS-01 challenge
docker logs traefik --tail 50 | grep -i "certificate\|acme\|dns"
```

**Verification:**
- [ ] DNS API token stored in Infisical `/prod`
- [ ] Token appears in `.workspace/.env` (check via Infisical Agent)
- [ ] DNS API access works (can list/manage DNS records)
- [ ] SSL certificates generate successfully via DNS-01 challenge (check Traefik logs)
- [ ] Services accessible via external domains

---

### Ghost Service Secrets

**Required Secrets:**
- `GHOST_DB_PASSWORD` - MariaDB password for Ghost database connection
- `GHOST_API_KEY` - Ghost Content API key for programmatic access (NEW - 2025-11-22)

**Procedure for Database Password:**
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

**Procedure for API Key (NEW - 2025-11-22):**
```bash
# 1. Access Ghost admin panel
# Navigate to: https://ghost.freqkflag.co/ghost/#/settings/integrations

# 2. Create new custom integration
# - Click "Add custom integration"
# - Name it (e.g., "Infrastructure API")
# - Copy the Content API Key

# 3. Store API key in Infisical
infisical secrets set --env prod --path /prod GHOST_API_KEY="<content_api_key_from_ghost>"

# 4. Wait for Infisical Agent to sync (60s polling) or restart Ghost
docker compose -f services/ghost/compose.yml restart ghost

# 5. Verify API key works
curl -H "Authorization: Ghost ${GHOST_API_KEY}" \
  https://ghost.freqkflag.co/ghost/api/content/posts/
```

**Verification:**
- [ ] Ghost container starts without database errors
- [ ] Ghost can connect to MariaDB
- [ ] `GHOST_API_KEY` appears in `.workspace/.env` (check via Infisical Agent)
- [ ] Ghost API responds to requests with API key
- [ ] Health check passes

---

### Webhook URLs

**Required Secrets (Optional):**
- `INFISICAL_WEBHOOK_URL` - **NEW (2025-11-22):** Currently `__UNSET__`, required for agent event broadcasting
- `ALERTMANAGER_WEBHOOK_URL` - Optional, for Alertmanager notifications
- `N8N_WEBHOOK_URL` - Optional, for external n8n workflow triggers

**Procedure for INFISICAL_WEBHOOK_URL (NEW - 2025-11-22):**
```bash
# 1. Create n8n webhook workflow (recommended approach)
# - Navigate to: https://n8n.freqkflag.co
# - Create new workflow named "Agent Events"
# - Add "Webhook" trigger node
# - Configure webhook path: `/webhook/agent-events`
# - Save workflow and activate
# - Copy webhook URL: https://n8n.freqkflag.co/webhook/agent-events

# 2. Store webhook URL in Infisical
infisical secrets set --env prod --path /prod INFISICAL_WEBHOOK_URL="https://n8n.freqkflag.co/webhook/agent-events"

# 3. Wait for Infisical Agent to sync (60s polling) or verify manually
grep "INFISICAL_WEBHOOK_URL" .workspace/.env

# 4. Test webhook
curl -X POST "https://n8n.freqkflag.co/webhook/agent-events" \
  -H "Content-Type: application/json" \
  -d '{"agent": "test", "action": "test", "status": "success", "timestamp": "'$(date -Iseconds)'", "details": {"test": true}}'

# 5. Verify agents can broadcast events (see AGENTS.md line 394)
```

**Procedure for Other Webhooks:**
```bash
# For Alertmanager: https://discord.com/api/webhooks/<id>/<token>
# For n8n external: https://n8n.freqkflag.co/webhook/<workflow-id>

# Store webhook URL
infisical secrets set --env prod --path /prod ALERTMANAGER_WEBHOOK_URL="<discord_webhook_url>"
infisical secrets set --env prod --path /prod N8N_WEBHOOK_URL="<n8n_webhook_url>"

# Restart services if needed
docker compose -f compose.orchestrator.yml restart n8n alertmanager
```

**Verification:**
- [ ] `INFISICAL_WEBHOOK_URL` appears in `.workspace/.env` (check via Infisical Agent)
- [ ] Webhook endpoint accessible
- [ ] Test webhook call succeeds
- [ ] Receiving service (n8n workflow) processes webhook correctly
- [ ] Agent event broadcasting works (see `AGENTS.md` for agent webhook usage)

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
**Status:** ✅ All `__UNSET__` placeholders resolved (2025-11-22)  
**Next Review:** 2025-12-22 (monthly audit)

