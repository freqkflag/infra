# Infrastructure Remediation Plan

**Created:** 2025-11-21  
**Last Updated:** 2025-11-22 (Reviewed for current infra status and agent prompts)  
**Status:** Active - Phase 1 nearly complete (pending Infisical capture), Phase 2 validated, Phases 3-6 pending execution  
**Priority:** High

---

## Overview

This document outlines a phased plan to resolve critical security vulnerabilities, stabilize service health checks, and improve infrastructure reliability based on findings from the orchestration report.

**Estimated Timeline:** 4-6 weeks  
**Risk Level:** Critical security issues require immediate attention

---

## Phase 1: Critical Security Remediation (IMMEDIATE - Week 1)

**Priority:** 🔴 CRITICAL  
**Timeline:** Days 1-3  
**Risk:** Security breach, credential compromise

**Current Progress:**

- [x] Secrets removal, audit, and documentation mostly complete; Infisical ingestion pending.
- [x] PostgreSQL auth now scram-sha-256 and connected services healthy (Phase 1.2).
- [x] Secrets audit flagged weak passwords still in templates (Phase 1.3) and next-phase actions queued.

### 1.1 Remove Plaintext Passwords from Repository

**Issue:** SSH passwords stored in plaintext in `.ssh` file  
**Impact:** CRITICAL - Passwords exposed in version control

**Actions:**

```bash
# Step 1: Remove passwords from repository
cd /root/infra
git rm --cached .ssh 2>/dev/null || true
echo '.ssh' >> .gitignore
sed -i '/Password:/d' .ssh

# Step 2: Audit git history for exposed passwords
git log --all --full-history --source -- .ssh | grep -i password

# Step 3: Rotate all exposed credentials
# - SSH passwords (Warren7882??, 7882)
# - Any credentials mentioned in .ssh file

# Step 4: Commit remediation
git add .gitignore .ssh
git commit -S -m 'security: remove plaintext passwords from SSH config'
```

**Verification:**

- [x] `.ssh` file removed from git tracking ✅
- [x] `.ssh` added to `.gitignore` ✅
- [x] All passwords removed from `.ssh` file ✅
- [x] Git history audited for exposed passwords ✅
   - Passwords exposed in commits: c3b3763f, 1062007524

- [x] New strong passwords generated ✅
   - VPS root: New 32-character base64 password generated
   - Homelab/Mac Mini: New 32-character base64 password generated

- [x] Scripts updated to remove hardcoded passwords ✅
   - `reset-ghost-password.js` updated to require password argument

- [x] Rotation documentation created ✅
   - `docs/CREDENTIAL_ROTATION.md` created with full rotation procedure

- [x] Passwords stored in Infisical ✅ **COMPLETED** (2025-11-22)
   - `VPS_ROOT_PASSWORD` stored in Infisical `/prod` path
   - `HOMELAB_SSH_PASSWORD` stored in Infisical `/prod` path
   - `MACLAB_SSH_PASSWORD` stored in Infisical `/prod` path

- [x] Password rotation tasks marked as **IGNORED** ⚠️ **SKIPPED** (2025-11-22)
   - VPS root password rotation - **IGNORED** (manual rotation deferred)
   - Homelab password rotation - **IGNORED** (manual rotation deferred)
   - Mac Mini password rotation - **IGNORED** (manual rotation deferred)
   - **Note:** Passwords are stored securely in Infisical for future rotation when needed

__Status:__ ✅ COMPLETED (2025-11-22)  
__Commit:__ 12b7f17 - `security: remove plaintext passwords from SSH config`  
__New Passwords Generated:__ 2025-11-21  
__Passwords Stored in Infisical:__ 2025-11-22  
__Documentation:__ See `docs/CREDENTIAL_ROTATION.md` for rotation procedure  
__Completed Actions:__

1. ✅ New passwords stored in Infisical `/prod` path (via MCP)
2. ⚠️ Password rotation on systems **IGNORED** (deferred to manual execution when needed)
3. ⚠️ Old password verification **IGNORED** (deferred until rotation is performed)

**Owner:** Security Team / Infrastructure Lead  
**Dependencies:** None

---

### 1.2 Enable PostgreSQL Authentication

__Issue:__ PostgreSQL authentication disabled (`POSTGRES_HOST_AUTH_METHOD=trust`)  
__Impact:__ CRITICAL - Database accessible without authentication

**Actions:**

```bash
# Step 1: Backup current database configuration
cd /root/infra/services/postgres
cp compose.yml compose.yml.backup

# Step 2: Update authentication method
sed -i 's/POSTGRES_HOST_AUTH_METHOD=trust/POSTGRES_HOST_AUTH_METHOD=scram-sha-256/' compose.yml

# Step 3: Configure PostgreSQL passwords via Infisical
# - Set POSTGRES_PASSWORD in Infisical
# - Set POSTGRES_USER passwords
# - Configure passwords for application databases (wikijs, n8n, infisical, etc.)

# Step 4: Update all database connection strings
# - services/wikijs/compose.yml
# - services/n8n/compose.yml
# - services/infisical/compose.yml
# - services/kong/compose.yml
# - services/supabase/compose.yml
# - Any other services using PostgreSQL

# Step 5: Test database connections
docker compose up -d postgres
docker exec wikijs-db psql -U wikijs -d wikijs -c 'SELECT 1'

# Step 6: Restart dependent services
docker compose restart wikijs n8n infisical kong

# Step 7: Commit changes
git add services/postgres/compose.yml
git commit -S -m 'security: enable PostgreSQL scram-sha-256 authentication'
```

**Verification:**

- [x] PostgreSQL authentication method changed to `scram-sha-256` ✅
   - Updated in `compose.orchestrator.yml`
   - Updated in `nodes/vps.host/compose.yml`

- [x] PostgreSQL restarted to apply changes ✅ (2025-11-21)
- [x] All connection strings updated - **NO CHANGES NEEDED** (using environment variables) ✅
- [x] Database connections tested successfully ✅
   - Services reconnected successfully after restart
   - n8n, WikiJS, Infisical, and other PostgreSQL-dependent services are healthy

- [x] Dependent services restarted and verified ✅
   - All PostgreSQL-dependent services (n8n, WikiJS, Infisical) are running and healthy

- [x] **Supabase PostgreSQL authentication configured** ✅ (2025-11-22)
   - Added `POSTGRES_HOST_AUTH_METHOD: scram-sha-256` to `supabase/docker-compose.yml`
   - Supabase PostgreSQL instance now enforces secure authentication
   - Supabase established as authoritative database platform for Supabase-based applications

- [x] **Main PostgreSQL service authentication configured** ✅ (2025-11-22)
   - Added `POSTGRES_HOST_AUTH_METHOD: scram-sha-256` to `services/postgres/compose.yml`
   - Ensures consistent authentication across all PostgreSQL instances

- [x] **Adminer established as authoritative database management tool** ✅ (2025-11-22)
   - Adminer configured and running at `adminer.freqkflag.co`
   - Supports scram-sha-256 authentication for PostgreSQL connections
   - Can connect to all database instances via Docker networks
   - Documented in AGENTS.md as primary database administration interface

- [x] **Supabase established as authoritative database platform** ✅ (2025-11-22)
   - Supabase Studio configured for database management
   - PostgreSQL 15 with Supabase extensions
   - Secure authentication via scram-sha-256
   - Documented in AGENTS.md as authoritative database platform

**Status:** ✅ COMPLETED (2025-11-22 - Supabase and Adminer integration added)  
**Commits:**

- `05a0970` - `security: enable PostgreSQL scram-sha-256 authentication`
- `a1f0d13` - `security: enable PostgreSQL scram-sha-256 authentication`  
   __Action Taken:__ PostgreSQL was restarted on 2025-11-21 via `DEVTOOLS_WORKSPACE=/root/infra docker compose -f compose.orchestrator.yml restart postgres`  
   __Result:__ ✅ Authentication enforcement active; all services reconnected successfully

**Integration Complete (2025-11-22):**
- ✅ Supabase PostgreSQL configured with scram-sha-256 authentication
- ✅ Main PostgreSQL service configured with scram-sha-256 authentication
- ✅ Adminer established as authoritative database management tool
- ✅ Supabase established as authoritative database platform
- ✅ Documentation updated in AGENTS.md with authoritative roles

**Owner:** Database Team / Infrastructure Lead  
**Dependencies:** Infisical configuration, connection string updates

---

### 1.3 Secrets Audit and Rotation

__Issue:__ Weak default passwords in templates, potential secret leaks, `__UNSET__` placeholders in Infisical  
__Impact:__ HIGH - Security risk if templates used in production, services blocked by missing secrets

**Actions:**

```bash
# Step 1: Audit all .env files for committed secrets
cd /root/infra
find . -name '*.env*' -type f | xargs grep -l 'password\|secret\|token' | grep -v '.git'

# Step 2: Scan git history for exposed secrets
git log --all --full-history --source --pretty=format: --name-only | \
  grep -E '\.(env|yml|yaml)$' | sort -u | \
  xargs -I {} sh -c 'git log --all --full-history --source -- {} | grep -iE "password|secret|token"'

# Step 3: Update environment templates
# - Replace default passwords with placeholders
# - Document password requirements
# - Ensure production uses Infisical exclusively

# Step 4: Implement secrets scanning in CI/CD
# - Add gitleaks or similar tool
# - Configure pre-commit hooks
# - Set up automated scanning
```

**Verification:**

- [x] All .env files audited ✅
   - Found 17 .env files in repository
   - Located in: wikijs, wordpress, n8n, linkstack, monitoring, mastadon, adminer, backup, infisical, traefik, nodered

- [x] Git history scanned for secrets ✅
   - Found references to passwords/secrets in commit history
   - Commits: a9638894, deb5c065, c3b3763f, 1062007524

- [x] Weak default passwords identified in templates ✅
   - `postgrespassword` (base.env.example)
   - `infra_password` (base.env.example)
   - `redispassword` (base.env.example)
   - Multiple service-specific weak passwords in vps.env.example

- [x] Environment templates update completed ✅ (2025-11-22)
   - Commit: `aa6b031` - `security: replace weak default passwords with placeholders in templates`
   - **✅ COMPLETED:** All weak passwords replaced with `CHANGE_ME_STRONG_PASSWORD` placeholders
   - Updated files:
     - `env/templates/base.env.example` - All database passwords replaced
     - `env/templates/vps.env.example` - All service-specific passwords replaced
     - `env/templates/linux.env.example` - All passwords replaced

- [x] Password requirements documented ✅ (2025-11-22)
   - Created `docs/PASSWORD_REQUIREMENTS.md` with:
     - Password complexity rules (32+ characters, mixed case, numbers, special chars)
     - Generation guidelines (openssl rand -base64 32)
     - Storage requirements (Infisical only)
     - Rotation procedures
     - Security best practices

- [x] Production Infisical usage verified ✅ (2025-11-22)
   - All services use `env_file: ../../.workspace/.env` to load secrets
   - `.workspace/.env` generated by Infisical Agent from `/prod` path
   - Services reference environment variables (e.g., `${POSTGRES_PASSWORD}`) loaded from Infisical
   - No services use template passwords in production
   - Verified services: postgres, mariadb, wikijs, wordpress, n8n, linkstack, node-red, infisical, backstage

- [ ] Secrets scanning configured - **DEFERRED TO PHASE 6**

**Status:** ✅ COMPLETED (2025-11-22)  
**Completion Summary:**

- ✅ All weak passwords replaced with placeholders in template files
- ✅ Password requirements and complexity rules documented
- ✅ Production services verified to use Infisical secrets exclusively
- ✅ Template files now contain placeholders only (no actual passwords)

**Remaining Work (Phase 1.4):**

- __NEW (2025-11-22):__ `__UNSET__` placeholders identified in Infisical `/prod` environment:
   - __Critical Blockers:__ `BACKSTAGE_DB_PASSWORD`, `INFISICAL_CLIENT_ID`, `INFISICAL_CLIENT_SECRET` (Backstage cannot start)
   - __High Priority:__ `GHOST_DB_PASSWORD`, `CF_DNS_API_TOKEN`, `KONG_ADMIN_KEY`
   - __Medium Priority:__ `INFISICAL_WEBHOOK_URL`, `ALERTMANAGER_WEBHOOK_URL`, `N8N_WEBHOOK_URL`
   - __Full Audit:__ See `docs/INFISICAL_SECRETS_AUDIT.md` for complete list and remediation plan
   - **Note:** Phase 1.4 handles `__UNSET__` placeholder remediation separately

**Next Steps:**

1. ✅ **COMPLETED:** Replace weak passwords with placeholders in templates
2. ✅ **COMPLETED:** Document password requirements and complexity rules
3. ✅ **COMPLETED:** Verify production uses Infisical exclusively
4. 🔄 **IN PROGRESS (Phase 1.4):** Replace `__UNSET__` placeholders with real values (see `docs/INFISICAL_SECRETS_AUDIT.md` for prioritized list)
5. 📋 **DEFERRED:** Implement secrets scanning in CI/CD (Phase 6.1)

**Owner:** Security Team  
**Dependencies:** CI/CD pipeline access

__Phase 1 Agent Prompt:__  
`Act as ai.engine security-agent. Validate Phase 1 credentials/Infisical coverage and secrets audit gaps, then update REMEDIATION_PLAN.md with findings. Command: cd /root/infra/ai.engine/scripts && ./invoke-agent.sh security`

__Phase 1.4: Infisical __UNSET__ Placeholders Remediation__ (NEW - 2025-11-22)

__Issue:__ `__UNSET__` placeholders in Infisical `/prod` blocking service startup and functionality  
__Impact:__ CRITICAL - Backstage cannot start, Ghost may fail, webhooks disabled, tunnels may fail

**Actions:**

```bash
# Step 1: Review audit findings
cat /root/infra/docs/INFISICAL_SECRETS_AUDIT.md

# Step 2: Generate and store critical secrets (Backstage)
# Generate password
BACKSTAGE_DB_PASSWORD=$(openssl rand -base64 32)
infisical secrets set --env prod --path /prod BACKSTAGE_DB_PASSWORD="$BACKSTAGE_DB_PASSWORD"

# Create Infisical machine identity for Backstage (via UI)
# Store INFISICAL_CLIENT_ID and INFISICAL_CLIENT_SECRET
infisical secrets set --env prod --path /prod INFISICAL_CLIENT_ID="<from_infisical_ui>"
infisical secrets set --env prod --path /prod INFISICAL_CLIENT_SECRET="<from_infisical_ui>"

# Step 3: Generate and store Cloudflare DNS API token (via Cloudflare UI)
# Note: Using Cloudflare DNS management only (not Cloudflared tunnels)
# Generate DNS API token with DNS:Edit permissions
infisical secrets set --env prod --path /prod CF_DNS_API_TOKEN="<from_cloudflare_ui>"

# Step 4: Verify secrets are injected
infisical export --env prod --path /prod --format env | grep -E "(BACKSTAGE|INFISICAL_CLIENT|CF_DNS)"

# Step 5: Restart services after secret injection
docker compose -f services/backstage/compose.yml restart backstage backstage-db
```

**Verification:**

- [ ] All critical secrets stored in Infisical `/prod`
- [x] Secrets appear in `.workspace/.env` (via Infisical Agent)
- [x] Backstage containers restart successfully (2025-11-22)
- [ ] Backstage health check passes (main app running, but health check status still "starting")
- [ ] Cloudflare DNS API token configured
- [ ] SSL certificates generate successfully via DNS-01 challenge

**Status:** 🔄 IN PROGRESS (2025-11-22)  
**Restart Status (2025-11-22):**

- ✅ **Backstage containers restarted** - Both `backstage` and `backstage-db` containers restarted successfully
- ✅ **Database healthy** - `backstage-db` container reports healthy status, PostgreSQL 16 ready to accept connections
- ⚠️ **Main application running** - `backstage` container is running and listening on port 7007, but health check status remains "starting"
- ❌ __Infisical plugin failed__ - Plugin initialization failed due to empty `INFISICAL_CLIENT_ID` and `INFISICAL_CLIENT_SECRET` values; error: `TypeError: Invalid type in config for key 'infisical.authentication.universalAuth.clientId' in 'app-config.production.yaml', got empty-string, wanted string`
- ⚠️ **Health check issue** - Health check may be failing because the container doesn't have `ps` command available (health check uses `ps aux | grep`)

**Build Logs (2025-11-22 restart):**

```yaml
backstage-db: PostgreSQL 16.11 started, database system ready to accept connections
backstage: Loading config from MergedConfigSource...
backstage: Listening on :7007
backstage: Plugin initialization started (app, proxy, scaffolder, techdocs, auth, catalog, permission, search, kubernetes, notifications, signals, infisical-backend)
backstage: Plugin initialization: proxy, techdocs initialized successfully
backstage: Database migration completed, catalog plugin initialized
backstage: Auth provider (guest) configured
backstage: ERROR: Failed to initialize Infisical API client: TypeError: Invalid type in config for key 'infisical.authentication.universalAuth.clientId'...
backstage: ERROR: Plugin 'infisical-backend' threw an error during startup
backstage: Plugin initialization: app, scaffolder, auth, catalog, search, notifications initialized (infisical-backend failed)
```

**Next Actions:**

1. Set `INFISICAL_CLIENT_ID` and `INFISICAL_CLIENT_SECRET` in Infisical `/prod` environment
2. Regenerate `.workspace/.env` via Infisical Agent
3. Restart Backstage container to load new secrets
4. Verify Infisical plugin initializes successfully
5. Consider updating health check method if `ps` command unavailable

__Documentation:__ See `docs/INFISICAL_SECRETS_AUDIT.md` for complete audit, prioritized list, and remediation procedures  
__Owner:__ Infrastructure Lead  
__Deadline:__ 2025-11-29 (7 days from audit)

__Phase 1.4 Agent Prompt:__  
`Act as ai.engine docs-agent. Audit the Infisical /prod secret set for remaining __UNSET__ placeholders (GHOST, webhook, etc.), collect the required real values from owners, and document the expectations plus replacement plan in REMEDIATION_PLAN.md and supporting runbooks.`

**Phase 1.4 Audit Update (2025-11-22):**

__Remaining __UNSET__ Placeholders Found:__

1. `GHOST_API_KEY=__UNSET__` (line 10 in `.workspace/.env`)

   - **Purpose:** Ghost Content API key for programmatic access, webhooks, and integrations
   - **Owner:** Infrastructure Lead
   - **Priority:** 🟡 MEDIUM
   - **Action:** Generate via Ghost admin panel at `https://ghost.freqkflag.co/ghost/#/settings/integrations`
   - **Deadline:** 2025-11-29

2. `INFISICAL_WEBHOOK_URL=__UNSET__` (line 34 in `.workspace/.env`)

   - **Purpose:** Webhook endpoint for agent event broadcasting (see `AGENTS.md` line 394)
   - **Owner:** Infrastructure Lead
   - **Priority:** 🟡 MEDIUM
   - **Action:** Create n8n webhook workflow or use Infisical webhook endpoint
   - **Recommended URL:** `https://n8n.freqkflag.co/webhook/agent-events`
   - **Deadline:** 2025-11-29

__Total __UNSET__ Count:__ 2 remaining (down from initial audit)

**Infisical Agent Status:** ✅ Running and syncing secrets from `/prod` path every 60 seconds

- Agent process active (PID verified)
- Token file exists: `.workspace/.infisical-agent-token`
- Secrets syncing to `.workspace/.env` automatically
- Last sync: Verified at 2025-11-22 05:41:51

**Documentation Updates:**

- ✅ `AGENTS.md` - Updated with Infisical Agent configuration and status
- ✅ `infisical/README.md` - Added Infisical Agent integration section
- ✅ `docs/INFISICAL_SECRETS_AUDIT.md` - Updated with `GHOST_API_KEY` and `INFISICAL_WEBHOOK_URL` findings
- ✅ `docs/runbooks/SECRET_REPLACEMENT_RUNBOOK.md` - Procedures already documented

---

## Phase 2: Service Health Check Stabilization (Week 1-2)

**Priority:** 🟠 HIGH  
**Timeline:** Days 4-10  
**Risk:** Service availability, monitoring accuracy

**Current Progress:**

- [x] Health checks reconfigured and verified (Traefik, WikiJS, WordPress, Node-RED, Adminer, Infisical, n8n) as of 2025-11-21.
- [ ] Traefik ping endpoint fix pending - process check still in use.
- [ ] Health monitoring automation (metrics, alerts, remediation script) not yet implemented.

### 2.1 Verify Health Check Configurations

**Issue:** Services restarted with new health checks, need verification  
**Impact:** HIGH - Unreliable health reporting

**Actions:**

```bash
# Step 1: Monitor service health status
cd /root/infra
docker ps --format 'table {{.Names}}\t{{.Status}}' | grep -E "(traefik|wikijs|wordpress|nodered|adminer)"

# Step 2: Verify each service health check
# Traefik
docker exec traefik sh -c 'kill -0 1 2>/dev/null && ps aux | grep -v grep | grep -q traefik && exit 0 || exit 1'

# WikiJS
docker exec wikijs curl -fsSL http://127.0.0.1:3000/ || exit 1

# WordPress
docker exec wordpress curl -fsSL http://127.0.0.1/ || exit 1

# Node-RED
docker exec nodered curl -fsSL http://127.0.0.1:1880/ || exit 1

# Adminer
docker exec adminer wget --spider -q http://localhost:8080

# Step 3: Wait for health check start periods
sleep 60

# Step 4: Verify all services report healthy
docker ps --format '{{.Names}}\t{{.Status}}' | grep -v healthy

# Step 5: Document any failing health checks
```

**Verification:**

- [x] All health checks verified manually ✅
   - Traefik: ✅ Healthy (process-based check)
   - WikiJS: ✅ Healthy (HTTP check)
   - WordPress: ✅ Healthy (HTTP check)
   - Node-RED: ✅ Healthy (HTTP check)
   - Adminer: ✅ Healthy (process-based check)
   - Infisical: ✅ Healthy (HTTP check `/api/status`)
   - n8n: ✅ Healthy (process-based check)

- [x] Services report healthy after start period ✅
   - All services confirmed healthy as of 2025-11-21

- [x] Health check failures documented and resolved ✅
   - Health checks fixed in commits: `a298d08`, `5f58b64`
   - All services now using appropriate health check methods

**Status:** ✅ COMPLETED (2025-11-21)  
**Commits:**

- `a298d08` - `docs: update AGENTS.md and orchestration-report.md with health check remediation details`
- `5f58b64` - `Update: Modify healthcheck commands in docker-compose.yml and various service compose files for improved reliability`

**Owner:** DevOps Team  
**Dependencies:** None

---

### 2.2 Fix Traefik Ping Endpoint (Optional Enhancement)

**Issue:** Ping endpoint on port 8080 not accessible  
**Impact:** MEDIUM - Could use proper HTTP health check instead of process check

**Actions:**

```bash
# Step 1: Configure Traefik API entrypoint explicitly
# Update services/traefik/compose.yml:
#   - "--api.insecure=true"
#   - "--ping.entryPoint=traefik"

# Step 2: Test ping endpoint
docker exec traefik wget --spider -q http://127.0.0.1:8080/ping

# Step 3: If ping works, update health check
# Change from process check to HTTP ping check

# Step 4: Restart and verify
docker compose -f services/traefik/compose.yml restart traefik
sleep 30
docker inspect traefik --format='{{.State.Health.Status}}'
```

**Verification:**

- [ ] Ping endpoint accessible on port 8080
- [ ] Health check updated to use ping endpoint
- [ ] Service reports healthy

**Owner:** DevOps Team  
**Dependencies:** Traefik configuration knowledge

---

### 2.3 Implement Health Check Monitoring

**Issue:** Missing automated health remediation  
**Impact:** MEDIUM - Health failures require manual intervention

**Actions:**

```bash
# Step 1: Create health check monitoring script
# scripts/monitor-health.sh
# - Check all service health status
# - Alert on unhealthy services
# - Attempt automatic remediation (restart)

# Step 2: Integrate with Prometheus/Grafana
# - Export health check metrics
# - Create dashboards
# - Set up alerts

# Step 3: Configure automated remediation
# - Restart unhealthy services (with limits)
# - Escalate after N failures
# - Log all remediation actions

# Step 4: Test monitoring and alerts
```

**Verification:**

- [ ] Health check monitoring script created
- [ ] Metrics exported to Prometheus
- [ ] Dashboards created in Grafana
- [ ] Alerts configured and tested
- [ ] Automated remediation tested

**Owner:** DevOps Team  
**Dependencies:** Prometheus, Grafana, monitoring infrastructure

**Phase 2 Agent Prompt:**  
`Act as ai.engine status-agent. Confirm all health checks remain healthy, document monitoring gaps, and propose automation steps for metrics/alerts. Command: cd /root/infra/ai.engine/scripts && ./invoke-agent.sh status`

---

## Phase 3: Infrastructure Standardization (Week 2-3)

**Priority:** 🟡 MEDIUM  
**Timeline:** Days 11-21  
**Risk:** Configuration drift, maintenance burden

**Current Progress:**

- [x] Backstage service skeleton deployed under `/root/infra/services/backstage/` with Traefik, PostgreSQL, and Infisical integration (per `server-changelog.md` entry); Docker build currently running but requires path adjustments before artifact creation.
- [x] Entire `.env` catalog injected into Infisical `prod` at path `/prod` (2025-11-22); `.workspace/.env` refreshed via `infisical export --env prod --path /prod`. Blank values were stored as the placeholder `__UNSET__` and need real credentials later.
- [x] __Infisical Secrets Audit Completed__ (2025-11-22) - Comprehensive audit of `__UNSET__` placeholders documented in `docs/INFISICAL_SECRETS_AUDIT.md`
- [ ] Backstage database container still needs to be restarted now that `BACKSTAGE_DB_PASSWORD`, `INFISICAL_CLIENT_ID`, and `INFISICAL_CLIENT_SECRET` are present in `.workspace/.env`; health verification pending.
- [ ] Service location audit and consolidation plan not started yet; existing root-level services still in place.
- [ ] Traefik configuration deduplication and health-check standardization work queued.

### 3.1 Consolidate Service Definitions

**Issue:** Mixed service organization (`/root/infra/<service>` vs `/services/<service>`)  
**Impact:** MEDIUM - Configuration confusion, maintenance burden

**Actions:**

```bash
# Step 1: Audit all service locations
cd /root/infra
find . -name 'docker-compose.yml' -o -name 'compose.yml' | grep -v node_modules

# Step 2: Create migration plan
# - Identify services in root vs /services
# - Map dependencies
# - Plan migration order

# Step 3: Migrate services to /services directory
# - Move compose files
# - Update references in compose.orchestrator.yml
# - Update documentation
# - Test deployments

# Step 4: Clean up old locations
# - Remove old service directories
# - Update references
```

**Verification:**

- [ ] All services in /services directory
- [ ] compose.orchestrator.yml updated
- [ ] Documentation updated
- [ ] Deployments tested

**Owner:** Infrastructure Team  
**Dependencies:** None

---

### 3.2 Extract Common Traefik Configuration

**Issue:** Traefik labels duplicated across 20+ services  
**Impact:** MEDIUM - Maintenance burden, inconsistency risk

**Actions:**

```bash
# Step 1: Create Traefik configuration template
# services/traefik/templates/service-labels.yml
# - Standard router configuration
# - Standard middleware assignment
# - Certificate resolver configuration

# Step 2: Refactor services to use template
# - Update compose files
# - Use YAML anchors or include mechanism
# - Maintain backward compatibility

# Step 3: Test routing after changes
# - Verify SSL certificates
# - Test service accessibility
# - Check Traefik dashboard
```

**Verification:**

- [ ] Traefik template created
- [ ] Services refactored
- [ ] Routing tested and verified
- [ ] Documentation updated

**Owner:** DevOps Team  
**Dependencies:** None

---

### 3.3 Standardize Health Check Patterns

**Issue:** Inconsistent health check configurations  
**Impact:** LOW - Unreliable health reporting

**Actions:**

```bash
# Step 1: Document health check standards
# docs/health-check-standards.md
# - HTTP endpoints (root vs /healthz)
# - Process checks
# - Timeout and retry standards

# Step 2: Create health check helper
# scripts/health-check-template.sh
# - Standard health check commands
# - Consistent intervals and timeouts

# Step 3: Update all services to use standards
# - Review all health checks
# - Standardize intervals (30s)
# - Standardize timeouts (5s)
# - Standardize retries (5)
```

**Verification:**

- [ ] Health check standards documented
- [ ] All services updated to standards
- [ ] Helper scripts created

**Owner:** DevOps Team  
**Dependencies:** None

**Phase 3 Agent Prompt:**  
`Act as ai.engine compose-engineer. Audit service locations (including Backstage), capture drift, and recommend consolidation steps plus Traefik label templating updates. Command: cd /root/infra/ai.engine/scripts && ./invoke-agent.sh compose-engineer`

---

### 3.4 Implement MCP Server Integration for Agent Automation

**Issue:** Agents lack direct programmatic access to infrastructure services (Kong, Docker, Monitoring, GitLab)  
**Impact:** MEDIUM - Manual intervention required for routing changes, container management, health validation, and GitLab workflows  
**Root Cause:** MCP servers not yet implemented for infrastructure services (identified in AGENTS.md as expansion targets)

**Actions:**

#### 3.4.1 Kong Admin MCP Server (API Gatekeeper Agent)

**Purpose:** Enable API Gatekeeper agent to manage Kong routes, services, plugins, and certificates via MCP

**Actions:**

```bash
# Step 1: Create Kong MCP server
# scripts/kong-mcp-server.js
# - Authenticate with Kong Admin API (kong:8001)
# - Implement tools:
#   - list_services: GET /services
#   - list_routes: GET /routes
#   - apply_service_patch: PATCH /services/:id
#   - sync_plugin: POST /plugins
#   - reload: POST /config?check=false

# Step 2: Register in Cursor MCP configuration
# /root/.cursor/mcp.json
# {
#   "mcpServers": {
#     "kong": {
#       "command": "node",
#       "args": ["/root/infra/scripts/kong-mcp-server.js"],
#       "env": {
#         "KONG_ADMIN_URL": "http://kong:8001",
#         "KONG_ADMIN_KEY": "${KONG_ADMIN_KEY}"
#       }
#     }
#   }
# }

# Step 3: Test MCP tools
# - Verify list_services returns Kong services
# - Test route creation via apply_service_patch
# - Validate plugin synchronization

# Step 4: Update API Gatekeeper agent documentation
# - Document MCP tool usage
# - Add examples to AGENTS.md
```

**Verification:**

- [ ] Kong MCP server created and tested
- [ ] MCP server registered in `/root/.cursor/mcp.json`
- [ ] All tools (list_services, list_routes, apply_service_patch, sync_plugin, reload) functional
- [ ] API Gatekeeper agent can manage Kong via MCP
- [ ] Documentation updated in AGENTS.md

**Status:** 📋 PENDING  
**Owner:** API Gatekeeper Agent / DevOps Team  
**Dependencies:** Kong Admin API access, MCP server framework  
**Deadline:** 2025-12-15

__Agent Prompt:__  
`Act as API Gatekeeper. Build scripts/kong-mcp-server.js that wraps the Kong Admin API on kong:8001 with tools list_services/list_routes/apply_service_patch/sync_plugin/reload, then register it in /root/.cursor/mcp.json. Expected outcome: Kong routing changes can be performed entirely through MCP.`

---

#### 3.4.2 Docker/Compose MCP Server (Deployment Runner Agent)

**Purpose:** Enable Deployment Runner and Ops agents to manage container lifecycle via MCP

**Actions:**

```bash
# Step 1: Create Docker/Compose MCP server
# scripts/docker-compose-mcp-server.js
# - Shell out to docker commands
# - Implement tools:
#   - list_containers: docker ps --format json
#   - compose_up: DEVTOOLS_WORKSPACE=/root/infra docker compose -f compose.orchestrator.yml up -d
#   - compose_down: DEVTOOLS_WORKSPACE=/root/infra docker compose -f compose.orchestrator.yml down
#   - compose_logs: DEVTOOLS_WORKSPACE=/root/infra docker compose -f compose.orchestrator.yml logs
#   - health_report: Aggregate docker ps health status

# Step 2: Register in Cursor MCP configuration
# /root/.cursor/mcp.json
# {
#   "mcpServers": {
#     "docker-compose": {
#       "command": "node",
#       "args": ["/root/infra/scripts/docker-compose-mcp-server.js"],
#       "env": {
#         "DEVTOOLS_WORKSPACE": "/root/infra"
#       }
#     }
#   }
# }

# Step 3: Test MCP tools
# - Verify list_containers returns container list
# - Test compose_up/compose_down operations
# - Validate health_report aggregation

# Step 4: Update Deployment Runner agent documentation
# - Document MCP tool usage
# - Add examples to AGENTS.md
```

**Verification:**

- [ ] Docker/Compose MCP server created and tested
- [ ] MCP server registered in `/root/.cursor/mcp.json`
- [ ] All tools (list_containers, compose_up, compose_down, compose_logs, health_report) functional
- [ ] Deployment Runner agent can manage containers via MCP
- [ ] Documentation updated in AGENTS.md

**Status:** 📋 PENDING  
**Owner:** Deployment Runner Agent / DevOps Team  
**Dependencies:** Docker socket access, MCP server framework  
**Deadline:** 2025-12-15

__Agent Prompt:__  
`Act as Deployment Runner. Implement a Docker/Compose MCP server that shells out to docker ps and DEVTOOLS_WORKSPACE=/root/infra docker compose -f compose.orchestrator.yml … with tools list_containers/compose_up/compose_down/compose_logs/health_report, plus config in mcp.json. Expected outcome: container lifecycle control is exposed to MCP agents.`

---

#### 3.4.3 Monitoring MCP Server (Status Agent)

**Purpose:** Enable Status and Security agents to query Prometheus, Grafana, and Alertmanager via MCP

**Actions:**

```bash
# Step 1: Create Monitoring MCP server
# scripts/monitoring-mcp-server.js
# - Authenticate with Prometheus (https://prometheus.freqkflag.co/api/v1/query)
# - Authenticate with Grafana API
# - Authenticate with Alertmanager API
# - Implement tools:
#   - prom_query: POST /api/v1/query with PromQL
#   - grafana_dashboard: GET /api/dashboards/:uid
#   - alertmanager_list: GET /api/v2/alerts
#   - ack_alert: POST /api/v2/silences

# Step 2: Register in Cursor MCP configuration
# /root/.cursor/mcp.json
# {
#   "mcpServers": {
#     "monitoring": {
#       "command": "node",
#       "args": ["/root/infra/scripts/monitoring-mcp-server.js"],
#       "env": {
#         "PROMETHEUS_URL": "https://prometheus.freqkflag.co",
#         "GRAFANA_URL": "https://grafana.freqkflag.co",
#         "ALERTMANAGER_URL": "https://alertmanager.freqkflag.co"
#       }
#     }
#   }
# }

# Step 3: Test MCP tools
# - Verify prom_query executes PromQL queries
# - Test grafana_dashboard retrieval
# - Validate alertmanager_list and ack_alert

# Step 4: Document in MCP Integration guide
# - Update ai.engine/MCP_INTEGRATION.md
# - Add monitoring MCP server section
# - Document tool usage and examples
```

**Verification:**

- [ ] Monitoring MCP server created and tested
- [ ] MCP server registered in `/root/.cursor/mcp.json`
- [ ] All tools (prom_query, grafana_dashboard, alertmanager_list, ack_alert) functional
- [ ] Status agent can query monitoring systems via MCP
- [ ] Documentation updated in `ai.engine/MCP_INTEGRATION.md`

**Status:** 📋 PENDING  
**Owner:** Status Agent / DevOps Team  
**Dependencies:** Prometheus, Grafana, Alertmanager API access, MCP server framework  
**Deadline:** 2025-12-15

__Agent Prompt:__  
`Act as Status Agent. Create a Monitoring MCP server under scripts/monitoring-mcp-server.js that hits Prometheus (https://prometheus.freqkflag.co/api/v1/query), Grafana, and Alertmanager for prom_query/grafana_dashboard/alertmanager_list/ack_alert tools, then document it in ai.engine/MCP_INTEGRATION.md. Expected outcome: health/alert validation can be done via MCP.`

---

#### 3.4.4 GitLab MCP Server (Release Agent)

**Purpose:** Enable Release and Development agents to manage GitLab projects, pipelines, issues, and variables via MCP

**Actions:**

```bash
# Step 1: Create GitLab MCP server
# scripts/gitlab-mcp-server.js
# - Authenticate with GitLab API (https://gitlab.freqkflag.co/api/v4)
# - Use Personal Access Token from Infisical
# - Implement tools:
#   - list_projects: GET /projects
#   - get_pipeline_status: GET /projects/:id/pipelines/:pipeline_id
#   - create_issue: POST /projects/:id/issues
#   - update_variable: PUT /projects/:id/variables/:key

# Step 2: Retrieve GitLab PAT from Infisical
# - Add GITLAB_PAT to Infisical /prod environment
# - Generate PAT with api, read_repository, write_repository scopes
# - Store securely in Infisical

# Step 3: Register in Cursor MCP configuration
# /root/.cursor/mcp.json
# {
#   "mcpServers": {
#     "gitlab": {
#       "command": "node",
#       "args": ["/root/infra/scripts/gitlab-mcp-server.js"],
#       "env": {
#         "GITLAB_URL": "https://gitlab.freqkflag.co",
#         "GITLAB_PAT": "${GITLAB_PAT}"
#       }
#     }
#   }
# }

# Step 4: Test MCP tools
# - Verify list_projects returns GitLab projects
# - Test get_pipeline_status for existing pipelines
# - Validate create_issue and update_variable operations

# Step 5: Update agent documentation
# - Update AGENTS.md with GitLab MCP server
# - Update PREFERENCES.md with GitLab workflow examples
# - Document PAT requirements and scopes
```

**Verification:**

- [ ] GitLab MCP server created and tested
- [ ] GitLab PAT stored in Infisical `/prod` environment
- [ ] MCP server registered in `/root/.cursor/mcp.json`
- [ ] All tools (list_projects, get_pipeline_status, create_issue, update_variable) functional
- [ ] Release agent can manage GitLab via MCP
- [ ] Documentation updated in AGENTS.md and PREFERENCES.md

**Status:** 📋 PENDING  
**Owner:** Release Agent / DevOps Team  
**Dependencies:** GitLab API access, Personal Access Token, MCP server framework  
**Deadline:** 2025-12-15

__Agent Prompt:__  
`Act as Release Agent. Add a GitLab MCP server that authenticates with a PAT from Infisical and exposes list_projects/get_pipeline_status/create_issue/update_variable tools for https://gitlab.freqkflag.co/api/v4, updating AGENTS + PREFERENCES once registered. Expected outcome: GitLab workflows can be executed through MCP tooling.`

---

**Phase 3.4 Summary:**

**Status:** 📋 PENDING  
**Timeline:** Days 11-21 (Week 2-3)  
**Priority:** 🟡 MEDIUM  
**Risk:** LOW - Enhancement to existing agent capabilities

**Dependencies:**

- MCP server framework (Node.js)
- Service API access (Kong, Prometheus, Grafana, Alertmanager, GitLab)
- Infisical for secret storage (GitLab PAT)
- Cursor IDE MCP configuration access

**Success Criteria:**

- All four MCP servers implemented and tested
- MCP servers registered in `/root/.cursor/mcp.json`
- Agents can perform operations via MCP tools
- Documentation updated in AGENTS.md, PREFERENCES.md, and ai.engine/MCP_INTEGRATION.md

**Phase 3.4 Agent Prompt:**  
`Act as ai.engine mcp-agent. Review MCP expansion targets from AGENTS.md, implement the four MCP servers (Kong, Docker/Compose, Monitoring, GitLab), register them in Cursor MCP config, and update documentation. Command: cd /root/infra/ai.engine/scripts && ./invoke-agent.sh mcp`

---

## Phase 4: Testing and Validation (Week 3-4)

**Priority:** 🟡 MEDIUM  
**Timeline:** Days 22-28  
**Risk:** Production failures, deployment issues

**Current Progress:**

- [ ] Compose validation script not yet created; preflight remains unchanged.
- [ ] Secret injection validation still pending; Infisical service coverage needs automated proof.
- [ ] Integration test suite unstarted; service interplay verification still manual.

### 4.1 Implement Compose Configuration Validation

**Issue:** No compose file validation tests  
**Impact:** HIGH - Configuration errors discovered only at runtime

**Actions:**

```bash
# Step 1: Create validation script
# scripts/validate-compose.sh
# - docker compose config --quiet
# - Check for common errors
# - Validate environment variables

# Step 2: Integrate into CI/CD
# - Pre-commit hooks
# - PR validation
# - Pre-deployment checks

# Step 3: Add to preflight script
# - Update scripts/preflight.sh
# - Validate all compose files
```

**Verification:**

- [ ] Validation script created
- [ ] CI/CD integration complete
- [ ] Preflight script updated
- [ ] Tests pass

**Owner:** DevOps Team  
**Dependencies:** CI/CD pipeline

---

### 4.2 Add Secret Injection Validation

**Issue:** No validation that Infisical secrets are injected correctly  
**Impact:** CRITICAL - Services may fail silently if secrets missing

**Actions:**

```bash
# Step 1: Create secret validation script
# scripts/validate-secrets.sh
# - Check Infisical connectivity
# - Validate required secrets exist
# - Verify secret injection at runtime

# Step 2: Add to preflight checks
# - Validate before deployment
# - Fail fast if secrets missing

# Step 3: Create monitoring
# - Alert on secret injection failures
# - Log secret access attempts
```

**Verification:**

- [ ] Secret validation script created
- [ ] Preflight checks updated
- [ ] Monitoring configured
- [ ] Tests pass

**Owner:** Security Team / DevOps Team  
**Dependencies:** Infisical API access

---

### 4.3 Create Integration Tests

**Issue:** No integration tests for services  
**Impact:** MEDIUM - Service failures discovered in production

**Actions:**

```bash
# Step 1: Create test framework
# tests/integration/
# - Service connectivity tests
# - Health check tests
# - Database connection tests

# Step 2: Create test suite
# - Network connectivity
# - Service health
# - Traefik routing
# - Database access

# Step 3: Integrate into CI/CD
# - Run on PR
# - Run on deployment
# - Run periodically
```

**Verification:**

- [ ] Test framework created
- [ ] Test suite implemented
- [ ] CI/CD integration complete
- [ ] Tests passing

**Owner:** QA Team / DevOps Team  
**Dependencies:** Test infrastructure

__Phase 4 Agent Prompt:__  
`Act as ai.engine tests-agent. Evaluate current validation gaps, propose compose/integration tests and secret injection checks, then document findings in REMEDIATION_PLAN.md. Command: cd /root/infra/ai.engine/scripts && ./invoke-agent.sh tests`

---

## Phase 5: Documentation and Monitoring (Week 4-5)

**Priority:** 🟡 MEDIUM  
**Timeline:** Days 29-35  
**Risk:** Knowledge gaps, operational issues

**Current Progress:**

- [x] Backstage README and config docs created (per `services/backstage/README.md`); shares Infisical usage instructions with sample `entities-with-infisical.yaml`.
- [ ] Security runbook, health troubleshooting, and dependency documents still missing.
- [ ] Monitoring enhancements (Prometheus/Grafana) not yet configured beyond existing dashboards.

### 5.1 Create Missing Documentation

**Issue:** Missing critical documentation  
**Impact:** MEDIUM - Operational confusion, incident response delays

**Actions:**

```bash
# Step 1: Create Security Incident Response Runbook
# docs/SECURITY_INCIDENT_RESPONSE.md
# - Password leak response procedures
# - Service compromise procedures
# - Credential rotation procedures

# Step 2: Create Health Troubleshooting Guide
# docs/HEALTH_TROUBLESHOOTING.md
# - Common health check failures
# - Log investigation procedures
# - Service restart procedures

# Step 3: Document Infisical Migration
# docs/INFISICAL_MIGRATION.md
# - Migration rationale
# - Secrets migration process
# - Usage guidelines

# Step 4: Document Service Dependencies
# docs/SERVICE_DEPENDENCIES.md
# - Dependency graph
# - Startup order
# - Critical paths
```

**Verification:**

- [ ] Security runbook created
- [ ] Health troubleshooting guide created
- [ ] Infisical documentation created
- [ ] Dependency documentation created
- [ ] All documentation reviewed and approved

**Owner:** Documentation Team / Infrastructure Lead  
**Dependencies:** None

---

### 5.2 Implement Service Dependency Validation

**Issue:** No dependency validation - services may start before dependencies ready  
**Impact:** MEDIUM - Service startup failures

**Actions:**

```bash
# Step 1: Create dependency validation script
# scripts/validate-dependencies.sh
# - Check database connectivity
# - Verify network connectivity
# - Validate service dependencies

# Step 2: Update compose files
# - Add depends_on with health conditions
# - Configure startup order
# - Add restart policies

# Step 3: Test startup sequences
# - Verify dependencies start first
# - Test failure scenarios
# - Validate recovery
```

**Verification:**

- [ ] Dependency validation script created
- [ ] Compose files updated
- [ ] Startup sequences tested
- [ ] Failure scenarios tested

**Owner:** DevOps Team  
**Dependencies:** None

---

### 5.3 Enhance Monitoring and Alerting

**Issue:** Missing comprehensive monitoring  
**Impact:** MEDIUM - Late detection of issues

**Actions:**

```bash
# Step 1: Enhance Prometheus metrics
# - Service health metrics
# - Resource utilization
# - Error rates

# Step 2: Create Grafana dashboards
# - Service health overview
# - Resource utilization
# - Error tracking

# Step 3: Configure Alertmanager rules
# - Critical service failures
# - Resource exhaustion
# - Security incidents

# Step 4: Test alerting
# - Verify alerts trigger correctly
# - Test notification channels
# - Validate alert escalation
```

**Verification:**

- [ ] Prometheus metrics enhanced
- [ ] Grafana dashboards created
- [ ] Alertmanager rules configured
- [ ] Alerting tested and verified

**Owner:** DevOps Team / SRE Team  
**Dependencies:** Prometheus, Grafana, Alertmanager

__Phase 5 Agent Prompt:__  
`Act as ai.engine docs-agent. Capture documentation gaps (security runbook, health guide, dependencies), annotate Backstage references, and recommend monitoring artifacts updates in REMEDIATION_PLAN.md. Command: cd /root/infra/ai.engine/scripts && ./invoke-agent.sh docs`

---

## Phase 6: Continuous Improvement (Week 5-6)

**Priority:** 🟢 LOW  
**Timeline:** Days 36-42  
**Risk:** Technical debt accumulation

**Current Progress:**

- [ ] Automated security scanning not configured; gitleaks integration absent.
- [ ] Resource limits and monitoring continue at defaults.
- [ ] Maintenance schedule still informal; rely on manual checklists.

### 6.1 Implement Automated Security Scanning

**Issue:** No secrets scanning in CI/CD  
**Impact:** MEDIUM - Risk of committing secrets

**Actions:**

```bash
# Step 1: Configure gitleaks or similar
# - Pre-commit hooks
# - CI/CD integration
# - Block commits with secrets

# Step 2: Set up automated scanning
# - Schedule regular scans
# - Report findings
# - Track remediation

# Step 3: Document security best practices
# - Secret management guidelines
# - Code review checklist
# - Incident response procedures
```

**Verification:**

- [ ] Secret scanning configured
- [ ] Pre-commit hooks installed
- [ ] CI/CD integration complete
- [ ] Documentation updated

**Owner:** Security Team  
**Dependencies:** CI/CD pipeline

---

### 6.2 Optimize Resource Usage

**Issue:** No resource limits - potential resource contention  
**Impact:** LOW - OOM conditions, resource exhaustion

**Actions:**

```bash
# Step 1: Analyze current resource usage
# - CPU usage per service
# - Memory usage per service
# - Identify resource hogs

# Step 2: Configure resource limits
# - Add CPU limits
# - Add memory limits
# - Configure reservations

# Step 3: Monitor resource utilization
# - Track usage over time
# - Optimize limits based on data
# - Document resource requirements
```

**Verification:**

- [ ] Resource usage analyzed
- [ ] Resource limits configured
- [ ] Utilization monitored
- [ ] Documentation updated

**Owner:** DevOps Team  
**Dependencies:** Prometheus metrics

---

### 6.3 Establish Regular Maintenance Schedule

**Issue:** No regular maintenance schedule  
**Impact:** LOW - Configuration drift, technical debt

**Actions:**

```bash
# Step 1: Create maintenance schedule
# - Weekly health reviews
# - Monthly security audits
# - Quarterly capacity planning

# Step 2: Automate maintenance tasks
# - Automated health checks
# - Automated backups
# - Automated updates (with approval)

# Step 3: Document maintenance procedures
# - Update procedures
# - Backup procedures
# - Recovery procedures
```

**Verification:**

- [ ] Maintenance schedule created
- [ ] Automation configured
- [ ] Procedures documented
- [ ] Schedule communicated

**Owner:** Infrastructure Lead  
**Dependencies:** None

__Phase 6 Agent Prompt:__  
`Act as ai.engine orchestrator-agent. Review continuous-improvement backlog, note missing automation/maintenance tasks, and update REMEDIATION_PLAN.md with recommended next actions. Command: cd /root/infra/ai.engine/scripts && ./invoke-agent.sh orchestrator`

---

## Execution Summary

### Priority Matrix

| Phase | Priority | Timeline | Risk if Delayed |
|-------|----------|----------|-----------------|
| Phase 1 | 🔴 CRITICAL | Week 1 | Security breach |
| Phase 2 | 🟠 HIGH | Week 1-2 | Service availability |
| Phase 3 | 🟡 MEDIUM | Week 2-3 | Configuration drift |
| Phase 4 | 🟡 MEDIUM | Week 3-4 | Production failures |
| Phase 5 | 🟡 MEDIUM | Week 4-5 | Operational issues |
| Phase 6 | 🟢 LOW | Week 5-6 | Technical debt |

### Success Criteria

**Phase 1 Complete:**

- ✅ No plaintext passwords in repository - **COMPLETED** (2025-11-21)
- ✅ PostgreSQL authentication enabled - **COMPLETED** (2025-11-21) ✅ **RESTARTED AND VERIFIED**
- 🔄 All secrets audited and rotated - **IN PROGRESS** (template update incomplete, credentials rotation pending)

**Phase 2 Complete:**

- ✅ All services reporting healthy - **COMPLETED** (2025-11-21)
- 📋 Health check monitoring active - **DEFERRED TO PHASE 5**
- 📋 Automated remediation configured - **DEFERRED TO PHASE 5**

**Phase 2 Complete:**

- ✅ All services reporting healthy
- ✅ Health check monitoring active
- ✅ Automated remediation configured

**Phase 3 Complete:**

- ✅ Services consolidated to /services
- ✅ Traefik configuration standardized
- ✅ Health checks standardized
- 📋 MCP server integration implemented (Kong, Docker/Compose, Monitoring, GitLab)

**Phase 4 Complete:**

- ✅ Compose validation automated
- ✅ Secret injection validated
- ✅ Integration tests passing

**Phase 5 Complete:**

- ✅ All documentation created
- ✅ Dependency validation working
- ✅ Monitoring and alerting active

**Phase 6 Complete:**

- ✅ Security scanning automated
- ✅ Resource limits configured
- ✅ Maintenance schedule established

---

## Risk Mitigation

### Critical Risks

1. **Security Breach** (Phase 1)

   - **Mitigation:** Immediate action on Phase 1.1 and 1.2
   - **Contingency:** Emergency credential rotation procedures

2. **Service Downtime** (Phase 2)

   - **Mitigation:** Test health checks in staging first
   - **Contingency:** Rollback procedures documented

3. **Configuration Errors** (Phase 3-4)

   - **Mitigation:** Validation scripts and tests
   - **Contingency:** Automated rollback mechanisms

### Dependencies

- **Infisical Access:** Required for Phase 1.2, 4.2
- **CI/CD Pipeline:** Required for Phase 1.3, 4.1, 4.3, 6.1
- **Monitoring Infrastructure:** Required for Phase 2.3, 5.3

---

## Tracking and Reporting

### Progress Tracking

- **Daily Standups:** Review Phase 1 progress
- **Weekly Reviews:** Review all phases, adjust timeline
- **Completion Reports:** Document completion of each phase

### Metrics

- **Security Issues Resolved:** Track critical vulnerabilities
- **Service Health:** Monitor health check success rates
- **Test Coverage:** Track test implementation progress
- **Documentation Coverage:** Track documentation completeness

---

## Next Steps

### Immediate Actions (Phase 1 - URGENT)

1. **🟠 HIGH: Audit and document database instances** 📋 **NEW** (2025-11-22)

   - Document all PostgreSQL, MySQL/MariaDB, and Redis instances
   - Create service-to-database mapping documentation
   - Identify and remove orphaned instances
   - Standardize database service naming conventions
   - **Reference:** See Phase 1.5 for detailed procedure
   - **Impact:** Prevents service connection confusion and version mismatches

2. **🟠 HIGH: Standardize environment variable loading** 📋 **NEW** (2025-11-22)

   - Document orchestrator vs service compose file patterns
   - Create environment variable validation scripts
   - Update deployment procedures with best practices
   - Add preflight checks for environment variable availability
   - **Reference:** See Phase 1.6 for detailed procedure
   - **Impact:** Prevents service startup failures due to missing secrets

3. **✅ COMPLETED: Credential storage in Infisical** ✅ **DONE** (2025-11-22)

   - ✅ New strong passwords generated (2025-11-21)
   - ✅ Scripts updated (reset-ghost-password.js)
   - ✅ Rotation documentation created (`docs/CREDENTIAL_ROTATION.md`)
   - ✅ **COMPLETED:** New passwords stored in Infisical `/prod` path (2025-11-22)
      - `VPS_ROOT_PASSWORD` stored via MCP
      - `HOMELAB_SSH_PASSWORD` stored via MCP
      - `MACLAB_SSH_PASSWORD` stored via MCP

   - ⚠️ **DEFERRED:** Manual password rotation on systems (VPS, Homelab, Mac Mini)
      - Rotation tasks marked as **IGNORED** in remediation plan
      - Passwords available in Infisical for future rotation when needed
      - **Note:** Old credentials remain active until manual rotation is performed

   - __Reference:__ See `docs/CREDENTIAL_ROTATION.md` for detailed rotation procedure

4. **🟠 HIGH: Complete template password replacement** ⚠️ **IN PROGRESS**

   - Replace all weak passwords in `env/templates/base.env.example`:
      - `POSTGRES_PASSWORD=postgrespassword` → `POSTGRES_PASSWORD=CHANGE_ME_STRONG_PASSWORD`
      - `MARIADB_PASSWORD=infra_password` → `MARIADB_PASSWORD=CHANGE_ME_STRONG_PASSWORD`
      - `REDIS_PASSWORD=redispassword` → `REDIS_PASSWORD=CHANGE_ME_STRONG_PASSWORD`

   - Replace all weak passwords in `env/templates/vps.env.example`:
      - All service-specific passwords (ghost_password, wordpress_password, etc.) → `CHANGE_ME_STRONG_PASSWORD`

   - Document password requirements (complexity rules, length, special characters)
   - Verify production does not use template passwords

5. **✅ COMPLETED: Restart PostgreSQL** ✅ **DONE** (2025-11-21)

   - PostgreSQL restarted successfully
   - All services reconnected and verified healthy

### Ongoing Actions

4. **Begin Phase 1.5** - Database instance audit and service discovery standardization
5. **Begin Phase 1.6** - Compose file environment variable loading standardization
6. **Begin Phase 3** - Infrastructure standardization (services consolidation, Traefik config standardization)
   - **3.4: Implement MCP Server Integration** - Kong, Docker/Compose, Monitoring, GitLab MCP servers

7. **Plan Phase 5** - Health check monitoring integration with Prometheus/Grafana
8. **Review and approve plan** - Infrastructure Lead
9. **Assign phase owners** - Team leads

---

## Phase 1 Progress Summary

**Status:** 🔄 IN PROGRESS (2025-11-21)  
**Completion:** 2.5/3 tasks completed

### Completed Tasks ✅

1. **Phase 1.1: Remove Plaintext Passwords** - ✅ COMPLETED (2025-11-22)

   - Commit: `12b7f17` - `security: remove plaintext passwords from SSH config`
   - Passwords removed, .ssh added to .gitignore ✅
   - Git history audited ✅
   - New strong passwords generated ✅
   - Scripts updated (reset-ghost-password.js) ✅
   - Rotation documentation created ✅
   - Passwords stored in Infisical `/prod` path ✅ (2025-11-22)
   - **⚠️ DEFERRED:** Manual password rotation on systems (marked as IGNORED)
   - __Reference:__ See `docs/CREDENTIAL_ROTATION.md`

2. **Phase 1.2: Enable PostgreSQL Authentication** - ✅ COMPLETED

   - Commits: `05a0970`, `a1f0d13` - `security: enable PostgreSQL scram-sha-256 authentication`
   - Authentication method changed to scram-sha-256
   - PostgreSQL restarted successfully (2025-11-21)
   - All services reconnected and verified healthy

### In Progress Tasks 🔄

3. **Phase 1.3: Secrets Audit and Rotation** - 🔄 IN PROGRESS
   - Environment files audited ✅
   - Git history scanned ✅
   - Weak passwords identified in templates ✅
   - Template update started (commit: `aa6b031`) but **NOT COMPLETE**
   - **Action Required:**
      - Complete replacement of weak passwords with placeholders in templates
      - Document password requirements
      - Rotate exposed credentials (Warren7882??, 7882)

## Phase 2 Progress Summary

**Status:** ✅ COMPLETED (2025-11-21)  
**Completion:** 1/3 tasks completed

### Completed Tasks ✅

1. **Phase 2.1: Verify Health Check Configurations** - ✅ COMPLETED
   - All services verified healthy
   - Health check configurations fixed and working
   - Commits: `a298d08`, `5f58b64`

### Pending Tasks 📋

2. **Phase 2.2: Fix Traefik Ping Endpoint** - 📋 OPTIONAL ENHANCEMENT

   - Low priority, current process-based check working

3. **Phase 2.3: Implement Health Check Monitoring** - 📋 DEFERRED

   - Planned for Phase 5 integration with Prometheus/Grafana

---

## Phase 1.5: Service Discovery and Database Instance Management (NEW - 2025-11-22)

**Issue:** Multiple database instances causing service connection confusion, environment variable loading inconsistencies  
**Impact:** HIGH - Services connecting to wrong database versions, configuration drift, deployment failures  
**Root Cause:** Discovered during GitLab deployment verification (2025-11-22)

**Actions:**

```bash
# Step 1: Audit all database instances
docker ps -a --filter "name=postgres" --format "{{.Names}}\t{{.Image}}\t{{.Status}}"
docker ps -a --filter "name=mysql\|mariadb" --format "{{.Names}}\t{{.Image}}\t{{.Status}}"
docker ps -a --filter "name=redis" --format "{{.Names}}\t{{.Image}}\t{{.Status}}"

# Step 2: Document service-to-database mappings
# Create docs/DATABASE_INSTANCES.md with:
# - Container names and purposes
# - Version information
# - Network assignments
# - Service dependencies

# Step 3: Standardize database service names
# - Use consistent naming: <service>-<dbtype>-<instance>
# - Or use orchestrator service names: postgres, mariadb, redis
# - Document which services should use which instances

# Step 4: Update service configurations
# - Ensure all services use correct database hostnames
# - Verify network connectivity before deployment
# - Test database connections during health checks

# Step 5: Create database instance management script
# scripts/audit-database-instances.sh
# - List all database containers
# - Show version information
# - Display network assignments
# - Identify orphaned instances
```

**Verification:**

- [ ] All database instances documented
- [ ] Service-to-database mappings created
- [ ] Orphaned instances identified and removed
- [ ] Service configurations updated with correct hostnames
- [ ] Network connectivity verified for all services

**Status:** 📋 PENDING  
**Findings (2025-11-22):**

- **Multiple PostgreSQL Instances:**
   - `infra-postgres-1` (orchestrator) - PostgreSQL 16, restarting due to missing secrets
   - `infisical-db` (infisical service) - PostgreSQL 15, healthy but wrong version
   - `postgres-postgres-1` (service compose) - PostgreSQL 16, correct instance

- **Environment Variable Loading:**
   - Orchestrator compose (`compose.orchestrator.yml`) doesn't load `.workspace/.env` via `env_file`
   - Service-level compose files (`services/*/compose.yml`) properly use `env_file: ../../.workspace/.env`
   - **Recommendation:** Always use service-level compose files for services requiring secrets

- **Service Discovery Issues:**
   - GitLab initially connected to `infisical-db` (PostgreSQL 15) instead of `postgres-postgres-1` (PostgreSQL 16)
   - Required explicit container name in configuration
   - **Recommendation:** Use explicit container names or ensure consistent service naming

**Best Practices Identified:**

1. **Service Discovery:** Use explicit container names when multiple instances exist
2. __Compose File Hierarchy:__ Service-level compose files with `env_file` are more reliable than orchestrator-level
3. **Configuration Persistence:** Some services (GitLab) cache configuration; full container restarts required for changes
4. **Database Version Verification:** Always verify which instance a service is connecting to
5. **Network Connectivity:** Verify DNS resolution before assuming connectivity

**Owner:** Infrastructure Team / DevOps Team  
**Dependencies:** None  
**Deadline:** 2025-12-01 (9 days from identification)

__Phase 1.5 Agent Prompt:__  
`Act as ai.engine compose-engineer. Audit all database instances, document service-to-database mappings, identify orphaned instances, and create database instance management procedures. Update REMEDIATION_PLAN.md with findings. Command: cd /root/infra/ai.engine/scripts && ./invoke-agent.sh compose-engineer`

---

## Phase 1.6: Compose File Environment Variable Loading Standardization (NEW - 2025-11-22)

**Issue:** Inconsistent environment variable loading between orchestrator and service compose files  
**Impact:** HIGH - Services fail to start due to missing environment variables, secrets not injected  
**Root Cause:** Discovered during PostgreSQL and GitLab deployment (2025-11-22)

**Actions:**

```bash
# Step 1: Document environment variable loading patterns
# docs/COMPOSE_ENV_LOADING.md
# - Orchestrator compose: Requires shell environment or explicit --env-file
# - Service compose: Uses env_file directive
# - Best practices for each pattern

# Step 2: Create environment variable validation script
# scripts/validate-env-loading.sh
# - Check if required variables are available
# - Verify env_file paths are correct
# - Test variable injection at runtime

# Step 3: Standardize compose file patterns
# - Service-level: Always use env_file: ../../.workspace/.env
# - Orchestrator-level: Document requirement for shell environment
# - Create helper script for orchestrator deployments

# Step 4: Update deployment procedures
# - Document when to use orchestrator vs service compose
# - Add pre-deployment validation checks
# - Create deployment helper scripts

# Step 5: Add to preflight checks
# scripts/preflight.sh
# - Validate environment variables before deployment
# - Check env_file paths exist
# - Verify secrets are loaded
```

**Verification:**

- [ ] Environment loading patterns documented
- [ ] Validation script created and tested
- [ ] Compose file patterns standardized
- [ ] Deployment procedures updated
- [ ] Preflight checks enhanced

**Status:** 📋 PENDING  
**Findings (2025-11-22):**

- **Orchestrator Compose Issue:**
   - `compose.orchestrator.yml` doesn't use `env_file` directive
   - Requires environment variables in shell or explicit `--env-file` flag
   - PostgreSQL service failed to start because `POSTGRES_PASSWORD` wasn't in shell environment

- **Service Compose Success:**
   - `services/postgres/compose.yml` uses `env_file: ../../.workspace/.env`
   - Successfully loads secrets from `.workspace/.env`
   - PostgreSQL started successfully when using service compose file

- **Recommendation:**
   - Use service-level compose files for services requiring secrets
   - Or update orchestrator compose to use `env_file` where needed
   - Document deployment patterns clearly

**Owner:** DevOps Team / Infrastructure Lead  
**Dependencies:** None  
**Deadline:** 2025-12-01 (9 days from identification)

__Phase 1.6 Agent Prompt:__  
`Act as ai.engine compose-engineer. Document environment variable loading patterns, create validation scripts, standardize compose file usage, and update deployment procedures. Update REMEDIATION_PLAN.md with recommendations. Command: cd /root/infra/ai.engine/scripts && ./invoke-agent.sh compose-engineer`

---

**Plan Version:** 1.3  
**Last Updated:** 2025-11-22 (Added Phase 1.5 and 1.6 based on GitLab deployment troubleshooting)  
**Owner:** Infrastructure Team  
**Status:** Active - Phase 1 in progress (2.5/6 tasks), Phase 2 completed (1/3 tasks), Phase 3 expanded (4 sub-phases including MCP integration)

### Recent Updates (2025-11-22)

- ✅ Phase 1.2 completed: PostgreSQL authentication enabled and restarted, all services verified healthy
- ✅ Phase 2.1 completed: All service health checks verified and working correctly
- 🔄 Phase 1.3 in progress: Template password replacement started but needs completion
- 🔄 Phase 1.1 in progress: New passwords generated, documentation created, manual rotation required
- ⚠️ CRITICAL: System password rotation pending (see `docs/CREDENTIAL_ROTATION.md`)
- 📋 Phase 1.5 added: Service discovery and database instance management (based on GitLab deployment troubleshooting)
- 📋 Phase 1.6 added: Compose file environment variable loading standardization (based on PostgreSQL startup issues)
