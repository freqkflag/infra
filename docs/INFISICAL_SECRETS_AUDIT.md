# Infisical Secrets Audit - __UNSET__ Placeholders

**Created:** 2025-11-22  
**Auditor:** docs-agent (ai.engine)  
**Status:** Active - Remediation Required  
**Priority:** HIGH

---

## Executive Summary

This audit identifies all secrets in Infisical `/prod` environment that contain `__UNSET__` placeholders or are missing required values. These placeholders were created during the initial `.env` catalog injection on 2025-11-22 when blank values were stored as `__UNSET__` placeholders.

**Impact:** Services requiring these secrets will fail to start or operate incorrectly until real values are provided.

**Remediation Timeline:** Immediate (within 7 days)

---

## Audit Methodology

1. **Service Analysis:** Reviewed all service compose files to identify required environment variables
2. **Template Review:** Analyzed `env/templates/base.env.example` and `env/templates/vps.env.example`
3. **Documentation Review:** Cross-referenced with `AGENTS.md`, `REMEDIATION_PLAN.md`, and service READMEs
4. **Infisical Export:** Attempted to export and filter for `__UNSET__` placeholders

---

## Critical Secrets Requiring Immediate Action

### 1. Backstage Service Secrets

**Service:** Backstage (`backstage.freqkflag.co`)  
**Status:** ⚠️ BLOCKED - Service cannot start without these secrets  
**Location:** `/root/infra/services/backstage/compose.yml`

| Secret | Purpose | Owner | Priority | Notes |
|--------|---------|-------|----------|-------|
| `BACKSTAGE_DB_PASSWORD` | PostgreSQL database password for Backstage | Infrastructure Lead | 🔴 CRITICAL | Required for database initialization |
| `INFISICAL_CLIENT_ID` | Infisical API client ID for plugin integration | Infrastructure Lead | 🔴 CRITICAL | Required for Infisical plugin functionality |
| `INFISICAL_CLIENT_SECRET` | Infisical API client secret for plugin integration | Infrastructure Lead | 🔴 CRITICAL | Required for Infisical plugin authentication |

**Impact:** Backstage service is configured but cannot start. Database container fails to initialize, and Infisical plugin cannot authenticate.

**Reference:** 
- `services/backstage/compose.yml` (lines 16, 20-21)
- `services/backstage/README.md` (lines 32, 36-37)
- `AGENTS.md` (line 151)

**Action Required:**
1. Generate strong password for `BACKSTAGE_DB_PASSWORD` (minimum 32 characters)
2. Create Infisical machine identity for Backstage plugin
3. Store `INFISICAL_CLIENT_ID` and `INFISICAL_CLIENT_SECRET` in Infisical
4. Update `.workspace/.env` via Infisical Agent
5. Restart Backstage containers

---

### 2. Ghost Service Secrets

**Service:** Ghost CMS (`ghost.freqkflag.co`)  
**Status:** ⚠️ POTENTIALLY BLOCKED - Service may fail database connection or API functionality  
**Location:** `/root/infra/services/ghost/compose.yml`

| Secret | Purpose | Owner | Priority | Notes |
|--------|---------|-------|----------|-------|
| `GHOST_DB_PASSWORD` | MariaDB password for Ghost database connection | Infrastructure Lead | 🟠 HIGH | Required for Ghost to connect to MariaDB |
| `GHOST_API_KEY` | Ghost Content API key for programmatic access | Infrastructure Lead | 🟡 MEDIUM | **NEW (2025-11-22):** Currently `__UNSET__` - Required for API integrations, webhooks, and external content management |

**Impact:** 
- Ghost service cannot connect to MariaDB database if password is `__UNSET__` or missing
- Ghost API integrations, webhooks, and programmatic content management will fail if `GHOST_API_KEY` is `__UNSET__`

**Current Status (2025-11-22 Audit):**
- `GHOST_API_KEY=__UNSET__` found in `.workspace/.env` (line 10)
- `GHOST_DB_PASSWORD` status unknown - needs verification

**Reference:**
- `services/ghost/compose.yml` (line 13)
- `env/templates/vps.env.example` (line 20)
- `.workspace/.env` (line 10) - `GHOST_API_KEY=__UNSET__`

**Action Required:**
1. Verify MariaDB user `ghost` exists and has correct password
2. Store `GHOST_DB_PASSWORD` in Infisical `/prod` (if missing or using default)
3. Generate Ghost API key via Ghost admin panel (`https://ghost.freqkflag.co/ghost/#/settings/integrations`)
4. Store `GHOST_API_KEY` in Infisical `/prod`
5. Update `.workspace/.env` via Infisical Agent (automatic, 60s polling)
6. Restart Ghost container if running

---

### 3. Webhook Configuration Secrets

**Services:** n8n, Alertmanager, Agent Automation  
**Status:** ⚠️ FUNCTIONALITY LIMITED - Webhook integrations disabled  
**Location:** Multiple services

| Secret | Purpose | Owner | Priority | Notes |
|--------|---------|-------|----------|-------|
| `INFISICAL_WEBHOOK_URL` | Webhook endpoint for agent event broadcasting | Infrastructure Lead | 🟡 MEDIUM | **NEW (2025-11-22):** Currently `__UNSET__` - Used by agents for event notifications (see `AGENTS.md` line 394) |
| `N8N_WEBHOOK_URL` | n8n webhook endpoint for external integrations | Automation Lead | 🟡 MEDIUM | Optional - n8n can generate webhooks internally |
| `ALERTMANAGER_WEBHOOK_URL` | Webhook for Alertmanager notifications | DevOps Lead | 🟡 MEDIUM | Optional - for Discord/Matrix/Slack integration |

**Impact:** 
- Agent automation events cannot be broadcast via webhooks
- External systems cannot trigger n8n workflows via webhooks
- Alertmanager cannot send notifications to external services

**Current Status (2025-11-22 Audit):**
- `INFISICAL_WEBHOOK_URL=__UNSET__` found in `.workspace/.env` (line 34)
- Agent webhook broadcasting disabled until configured

**Reference:**
- `AGENTS.md` (line 394) - Agent webhook broadcasting
- `n8n/docker-compose.yml` (line 34) - WEBHOOK_URL configuration
- `monitoring/config/alertmanager/alertmanager.yml` (lines 88-98) - Webhook configs
- `.workspace/.env` (line 34) - `INFISICAL_WEBHOOK_URL=__UNSET__`

**Action Required:**
1. **INFISICAL_WEBHOOK_URL:** 
   - Option A: Create n8n webhook workflow at `https://n8n.freqkflag.co/webhook/agent-events`
   - Option B: Use Infisical webhook endpoint (if supported)
   - Store URL in Infisical `/prod` as `INFISICAL_WEBHOOK_URL`
2. **N8N_WEBHOOK_URL:** Configure if external systems need to trigger workflows (optional)
3. **ALERTMANAGER_WEBHOOK_URL:** Configure Discord/Matrix/Slack webhooks if alerting needed (optional)

---

### 4. Cloudflare DNS Management

**Service:** Cloudflare DNS (all nodes)  
**Status:** ⚠️ CRITICAL - DNS management and SSL certificates require API token  
**Location:** `env/templates/base.env.example`

**Note:** Using Cloudflare DNS management only (not Cloudflared tunnels). Services are accessed directly via public IP with DNS records managed through Cloudflare API.

| Secret | Purpose | Owner | Priority | Notes |
|--------|---------|-------|----------|-------|
| `CF_DNS_API_TOKEN` | Cloudflare DNS API token for DNS management and DNS-01 challenge | Infrastructure Lead | 🔴 CRITICAL | Required for DNS record management and Let's Encrypt certificate generation via DNS-01 challenge |

**Impact:** 
- DNS records cannot be managed automatically if API token is missing
- SSL certificates cannot be generated via DNS-01 challenge if DNS API token is missing

**Reference:**
- `env/templates/base.env.example` (lines 5-9)
- `infra-build-plan.md` - Domain architecture

**Action Required:**
1. Generate Cloudflare DNS API token with DNS:Edit permissions via Cloudflare Dashboard
2. Store token in Infisical `/prod` as `CF_DNS_API_TOKEN`
3. Verify DNS records can be managed via API
4. Verify SSL certificates generate successfully via DNS-01 challenge

---

### 5. Kong API Gateway Secrets

**Service:** Kong OSS (`api.freqkflag.co`, `api-admin.freqkflag.co`)  
**Status:** ⚠️ SECURITY RISK - Admin access may be unsecured  
**Location:** `env/templates/base.env.example`

| Secret | Purpose | Owner | Priority | Notes |
|--------|---------|-------|----------|-------|
| `KONG_ADMIN_KEY` | API key for Kong admin API access | Infrastructure Lead | 🟠 HIGH | Required for secure admin API access |

**Impact:** Kong admin API may be accessible without authentication if key is missing.

**Reference:**
- `env/templates/base.env.example` (line 32)
- `services/kong/compose.yml` - Kong configuration

**Action Required:**
1. Generate strong API key for Kong admin access
2. Store in Infisical `/prod`
3. Configure Kong to require admin key for all admin API requests
4. Update Kong configuration if needed

---

### 6. Service-Specific Database Passwords

**Services:** Multiple (WordPress, Discourse, WikiJS, LinkStack, Gitea, etc.)  
**Status:** ⚠️ VARIES - Some services may have defaults, others require explicit passwords  
**Location:** `env/templates/vps.env.example`

| Secret | Service | Owner | Priority | Notes |
|--------|---------|-------|----------|-------|
| `WORDPRESS_DB_PASSWORD` | WordPress | Infrastructure Lead | 🟠 HIGH | Check if WordPress is using default or custom password |
| `DISCOURSE_DB_PASSWORD` | Discourse | Infrastructure Lead | 🟡 MEDIUM | Discourse not currently running |
| `WIKIJS_DB_PASSWORD` | WikiJS | Infrastructure Lead | 🟠 HIGH | WikiJS is running - verify password is set |
| `LINKSTACK_DB_PASSWORD` | LinkStack | Infrastructure Lead | 🟠 HIGH | LinkStack is running - verify password is set |
| `GITEA_DB_PASSWORD` | Gitea | Infrastructure Lead | 🟡 MEDIUM | Gitea not currently running |

**Impact:** Services may fail database connections or use insecure default passwords.

**Reference:**
- `env/templates/vps.env.example` (lines 20-61)
- Service compose files in `/root/infra/services/`

**Action Required:**
1. Audit each service's database password status
2. Generate strong passwords for any using defaults or `__UNSET__`
3. Store in Infisical `/prod`
4. Rotate passwords if currently using weak defaults

---

## Secret Collection Plan

### Phase 1: Critical Blockers (Days 1-2)

**Priority:** 🔴 CRITICAL - Services cannot start

1. **Backstage Secrets**
   - Generate `BACKSTAGE_DB_PASSWORD` (32+ character random password)
   - Create Infisical machine identity for Backstage
   - Store `INFISICAL_CLIENT_ID` and `INFISICAL_CLIENT_SECRET`

2. **Cloudflare Tokens**
   - Generate `CF_TUNNEL_TOKEN_VPS`, `CF_TUNNEL_TOKEN_MAC`, `CF_TUNNEL_TOKEN_LINUX`
   - Generate `CF_DNS_API_TOKEN` with DNS:Edit permissions

### Phase 2: High Priority (Days 3-4)

**Priority:** 🟠 HIGH - Services may fail or have security issues

1. **Ghost Database Password**
   - Verify MariaDB user `ghost` exists
   - Set `GHOST_DB_PASSWORD` if missing

2. **Kong Admin Key**
   - Generate `KONG_ADMIN_KEY`
   - Configure Kong to require key

3. **Service Database Passwords**
   - Audit WordPress, WikiJS, LinkStack passwords
   - Generate and store if using defaults

### Phase 3: Medium Priority (Days 5-7)

**Priority:** 🟡 MEDIUM - Functionality limitations

1. **Webhook URLs**
   - Configure `INFISICAL_WEBHOOK_URL` if agent automation needed
   - Configure `ALERTMANAGER_WEBHOOK_URL` if alerting needed
   - Configure `N8N_WEBHOOK_URL` if external integrations needed

---

## Secret Generation Guidelines

### Password Requirements

- **Minimum Length:** 32 characters
- **Character Set:** Mixed case letters, numbers, special characters
- **Generation Method:** Use cryptographically secure random generator
- **Storage:** Never store in plaintext; use Infisical exclusively

### API Token Requirements

- **Cloudflare Tokens:** Generate via Cloudflare Zero Trust dashboard
- **Infisical Client Credentials:** Create machine identity via Infisical UI
- **Kong Admin Key:** Generate via Kong admin API or CLI

### Webhook URL Requirements

- **Format:** Full HTTPS URL (e.g., `https://n8n.freqkflag.co/webhook/agent-events`)
- **Authentication:** Include authentication token in URL or headers
- **Validation:** Test webhook endpoint before storing

---

## Remediation Procedures

### Procedure 1: Store Secret in Infisical

```bash
# Via Infisical CLI
cd /root/infra
infisical secrets set --env prod --path /prod SECRET_NAME="secret_value"

# Via Infisical Web UI
# 1. Navigate to https://infisical.freqkflag.co
# 2. Select workspace and environment (prod)
# 3. Navigate to path `/prod`
# 4. Add or update secret
# 5. Save changes
```

### Procedure 2: Verify Secret Injection

```bash
# Check if secret is in .workspace/.env (generated by Infisical Agent)
cd /root/infra
grep "SECRET_NAME" .workspace/.env

# Or export from Infisical directly
infisical export --env prod --path /prod --format env | grep "SECRET_NAME"
```

### Procedure 3: Restart Service After Secret Update

```bash
# Restart specific service
cd /root/infra
docker compose -f services/<service>/compose.yml restart <service>

# Or restart via orchestrator
docker compose -f compose.orchestrator.yml restart <service>
```

---

## Verification Checklist

After storing each secret, verify:

- [ ] Secret appears in Infisical `/prod` path
- [ ] Secret appears in `.workspace/.env` (if using Infisical Agent)
- [ ] Service can read secret from environment
- [ ] Service starts successfully
- [ ] Service health check passes
- [ ] Service functionality works as expected

---

## Owner Assignments

| Secret Category | Owner | Contact Method | Deadline |
|----------------|-------|----------------|----------|
| Backstage Secrets | Infrastructure Lead | Internal | 2025-11-24 |
| Cloudflare Tokens | Infrastructure Lead | Internal | 2025-11-24 |
| Ghost Database | Infrastructure Lead | Internal | 2025-11-25 |
| Kong Admin Key | Infrastructure Lead | Internal | 2025-11-25 |
| Service DB Passwords | Infrastructure Lead | Internal | 2025-11-26 |
| Webhook URLs | Automation Lead / DevOps Lead | Internal | 2025-11-29 |

---

## Tracking and Reporting

- **Daily Updates:** Update `REMEDIATION_PLAN.md` with progress
- **Completion Status:** Mark secrets as complete in this document
- **Issues:** Document any blockers or issues in `server-changelog.md`

---

## References

- **Infisical Documentation:** See `infisical/README.md`
- **Service Documentation:** See individual service READMEs in `/root/infra/services/`
- **Remediation Plan:** See `REMEDIATION_PLAN.md`
- **Agent Guidelines:** See `AGENTS.md`

---

**Last Updated:** 2025-11-22  
**Next Review:** 2025-11-29 (after remediation deadline)

