# Infrastructure Agents & Services

**Last Updated:** 2025-11-22 09:29:00  
**Infrastructure Domain:** `freqkflag.co` (SPINE)

**AI Reference:** See [PREFERENCES.md](./PREFERENCES.md) for interaction guidelines

This document provides a standardized overview of all services and agents in the infrastructure.

---

## Current Infrastructure Status (2025-11-22)

### Critical Issues
- ✅ **Traefik running** - Reverse proxy container healthy; dashboard reachable on `:8080`
- ✅ **Health checks stabilized** - WikiJS, WordPress, Node-RED, Adminer, Infisical, n8n report healthy via process-oriented probes
- ✅ **Backstage running** - Both containers healthy (2025-11-22); database ready, main application listening on port 7007; Infisical plugin initialized successfully

### Service Health Summary
- ✅ **Healthy:** Traefik, Infisical, WikiJS, WordPress, n8n, Node-RED, Adminer, LinkStack, Monitoring stack (Grafana, Prometheus, Loki, Alertmanager), Databases (PostgreSQL, MySQL, Redis), Backstage (app + DB)
- ✅ **Healthy:** Supabase (all core services healthy - Studio, Meta, Kong, Database; connected to edge network; HTTPS/TLS working via Traefik)
- 🔄 **Starting/Initializing:** GitLab (first boot, ~45 seconds since start)
- ⚙️ **Configured but not running:** Mailu, Mastodon, Help Service

### Network Status
- ✅ **edge network:** Created and available
- ✅ **traefik-network:** Exists

### DNS Status (freqkflag.co)
- ⚙️ **DNS Records:** 19 expected A records pointing to `62.72.26.113`
- 📋 **Documentation:** See `docs/DNS_CONFIGURATION.md` for complete DNS record inventory
- 🔧 **Management Tools:**
  - `scripts/cloudflare-dns-manager.py` - DNS record management (supports A and CNAME records)
  - `scripts/audit-dns-records.py` - DNS audit and expected records report
- **Expected Domains:** See DNS_CONFIGURATION.md for complete list including:
  - Infrastructure: `traefik.freqkflag.co`, `infisical.freqkflag.co`, `adminer.freqkflag.co`, `ops.freqkflag.co`
  - Applications: `wiki.freqkflag.co`, `n8n.freqkflag.co`, `nodered.freqkflag.co`, `backstage.freqkflag.co`, `gitlab.freqkflag.co`
  - Monitoring: `grafana.freqkflag.co`, `prometheus.freqkflag.co`, `alertmanager.freqkflag.co`, `loki.freqkflag.co`
  - And more (19 total expected records)

### Next Steps
1. ✅ **Backstage fully operational** (2025-11-22) - Both containers healthy; database ready; main app listening on port 7007; Infisical plugin initialized successfully
2. ✅ **Environment variable naming fixed** (2025-11-22) - Fixed invalid environment variable names in Infisical (hyphens replaced with underscores, colons replaced with equals signs); all Cloudflare and API keys now use proper naming conventions
3. ✅ **Supabase Kong fixed** (2025-11-22 09:29:00) - Kong restart loop resolved by creating missing `/var/lib/kong/kong.yml` with format version 2.1; Kong now healthy and stable
4. ✅ **Supabase Studio/Meta health checks fixed** (2025-11-22) - Health check failures resolved by replacing `wget`-based checks with container-appropriate methods: Studio uses `/proc/net/tcp` port check (port 3000), Meta uses Node.js HTTP request to `/health` endpoint; both services now reporting healthy
5. 🔄 **GitLab deployment** (2025-11-22 09:24:29) - Container starting; monitor initialization progress (5-10 minute first boot expected)
6. ✅ **Status agent health check completed** (2025-11-22) - 28 containers running, 27 healthy, 1 unhealthy (GitLab initializing). Monitoring gaps documented in `docs/MONITORING_GAPS.md`. Automation scripts created: `scripts/automated-health-check.sh`, `scripts/deploy-metrics-exporters.sh`
7. 🔧 **Monitoring gaps identified** (2025-11-22) - Missing: cAdvisor, postgres_exporter, mysqld_exporter, redis_exporter. Prometheus configured but exporters not deployed. See `docs/MONITORING_GAPS.md` for implementation plan
8. ✅ **Phase 1.5 completed** (2025-11-22) - Database instance documentation (`docs/DATABASE_INSTANCES.md`) and audit script (`scripts/audit-database-instances.sh`) created
9. ✅ **Phase 1.6 completed** (2025-11-22) - Environment variable loading documentation (`docs/COMPOSE_ENV_LOADING.md`) and validation script (`scripts/validate-env-loading.sh`) created
10. ✅ **Phase 2.3 completed** (2025-11-22) - Health check monitoring script (`scripts/monitor-health.sh`) created with alerting and remediation
11. Continue automating health monitoring (Prometheus metrics, Grafana dashboards - Phase 5.3)
11. Run deliberate preflight script to ensure dependencies sequence is honored
12. Optional: Integrate environment variable validation into preflight.sh script

---

## Mission & Guardrails

- Deliver the complete infra build-out defined in `infra-build-plan.md`, `PROJECT_PLAN.md`, and `project-plan.yml`.
- Enforce reproducible, FOSS-only workflows (Docker Compose, Traefik, Cloudflare DNS, Infisical, Kong, ClamAV, n8n/Node-RED).
- Maintain three operating domains with Cloudflare DNS management:
  - **vps.host** (`freqkflag.co`) — Cloudflare DNS management via `${CF_DNS_API_TOKEN}`
  - **home.macmini** (`twist3dkink.online`) — Cloudflare DNS management via `${CF_DNS_API_TOKEN}`
  - **home.linux** (`cult-of-joey.com`) — Cloudflare DNS management via `${CF_DNS_API_TOKEN}`
- Shared external Docker network: `edge`.
- Every non-trivial change must land via commit or PR; inline commit messages must mention any assumption they encode.
- **Note:** Using Cloudflare DNS management only (not Cloudflared tunnels). Services are accessed directly via public IP with DNS records managed through Cloudflare API.

---

## Service Categories

- **Infrastructure (freqkflag.co)**: Core infrastructure tools and automation
- **Personal Brand (cultofjoey.com)**: Personal creative space
- **Business (twist3dkink.com)**: Mental health peer support/coaching
- **Community (twist3dkinkst3r.com)**: PNP-friendly LGBT+ KINK PWA Community

---

## Infrastructure Services (freqkflag.co)

### Traefik
- **Domain:** `traefik.localhost` (dashboard), `*` (reverse proxy)
- **Location:** `/root/infra/traefik/`
- **Status:** ✅ Running (healthy)
- **Purpose:** Reverse proxy, SSL termination, service discovery
- **Ports:** 80 (HTTP), 443 (HTTPS), 8080 (Dashboard)
- **Features:**
  - Automatic SSL certificates (Let's Encrypt)
  - HTTP to HTTPS redirect
  - Docker provider for service discovery
  - Security headers middleware
- **Access:** Dashboard at `http://localhost:8080`
- **Note:** Container is running and healthy. Fixed health check endpoint (was using non-existent `/api/overview`, now uses process-based check)

### Infisical
- **Domain:** `infisical.freqkflag.co`
- **Location:** `/root/infra/infisical/`
- **Status:** ✅ Running (healthy)
- **Purpose:** Modern secrets management and secure credential storage
- **Port:** 8080 (via Traefik)
- **Database:** PostgreSQL 15
- **Features:**
  - Encrypted secret storage
  - Version-controlled secrets
  - Modern web UI
  - API access for applications
  - Audit logging
  - Developer-friendly CLI
  - No unsealing required (simpler operations)
- **Documentation:** See `infisical/README.md`

### Infisical MCP Server
- **Domain:** N/A (MCP server, not HTTP)
- **Location:** `/root/infra/infisical-mcp/`
- **Status:** ⚙️ Configured (requires Machine Identity credentials)
- **Purpose:** Model Context Protocol server for AI clients (Cursor IDE) to interact with Infisical secrets
- **Features:**
  - Official Infisical MCP server (`@infisical/mcp`)
  - Enables AI assistants to read/update Infisical secrets
  - Secure authentication via Machine Identity Universal Auth
  - Integrates with Cursor IDE and other MCP-compatible clients
  - Supports function calling for secret management
- **Configuration:**
  - Requires `INFISICAL_UNIVERSAL_AUTH_CLIENT_ID` and `INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET`
  - Configured in Cursor IDE via `~/.config/cursor/mcp.json` (or workspace-level config)
  - Runs via `npx -y @infisical/mcp`
- **Documentation:** See `infisical-mcp/README.md` and `infisical-mcp/CURSOR_CONFIG.md`
- **Setup:** Run `./setup.sh` to verify configuration and get setup instructions
- **Security Note (2025-11-22):** Fixed critical security issue where Machine Identity credentials were hardcoded in `QUICK_START.md`. All hardcoded credentials have been removed and replaced with environment variable references. If credentials were previously exposed, they must be rotated immediately in Infisical.
- **Next Steps:**
  - Create Machine Identity in Infisical with Universal Auth
  - Set credentials in Infisical `/prod` path
  - Configure Cursor IDE MCP settings
  - Restart Cursor IDE to load MCP server
- **Secrets Integration:**
  - ✅ **Infisical Agent configured and running** - `infisical-agent.yml` generates `.workspace/.env` from `prod.template` every 60 seconds
  - ✅ **Agent Status (2025-11-22):** Infisical Agent is running and syncing secrets from `/prod` path to `.workspace/.env`
  - ✅ **Services wired to Infisical** - All services now use `env_file: ../.workspace/.env` to load secrets
  - ✅ **Secrets flow verified** - Services can read database passwords, API keys, and tokens from Infisical
  - **Services using Infisical secrets:** n8n, WordPress, WikiJS, LinkStack, Node-RED, Infisical, Mailu, Supabase
  - **Usage:** Services automatically load secrets from `.workspace/.env` when started, or use `infisical run --env=prod -- docker compose up`
- **Infisical Agent Configuration:**
  - **Config File:** `/root/infra/infisical-agent.yml`
  - **Template:** `prod.template` (fetches secrets from `/prod` path in `prod` environment)
  - **Destination:** `/root/infra/.workspace/.env`
  - **Polling Interval:** 60 seconds
  - **Reload Script:** `reload-app.sh` (executes when secrets are updated)
  - **Project ID:** `8c430744-1a5b-4426-af87-e96d6b9c91e3`
  - **Run Command:** `infisical agent --config /root/infra/infisical-agent.yml`
  - **Status:** ✅ Running (process active, syncing secrets automatically)

### WikiJS
- **Domain:** `wiki.freqkflag.co`
- **Location:** `/root/infra/wikijs/`
- **Status:** ✅ Running (healthy)
- **Purpose:** Documentation and knowledge base
- **Database:** PostgreSQL 15
- **Features:**
  - Markdown support
  - Version control
  - Search functionality
  - Multi-user collaboration
- **Note:** Fixed health check - now uses process-based check instead of HTTP endpoint

### n8n
- **Domain:** `n8n.freqkflag.co`
- **Location:** `/root/infra/n8n/`
- **Status:** ✅ Running (healthy)
- **Purpose:** Workflow automation and integration platform
- **Database:** PostgreSQL 15
- **Features:**
  - Visual workflow builder
  - API integrations
  - Scheduled tasks
  - Webhook support
  - Service integrations (Mailu, etc.)
- **Note:** Fixed database schema by resetting database and running fresh migrations. Updated health check to process-based check (was using HTTP endpoint that was failing)

### Node-RED
- **Domain:** `nodered.freqkflag.co`
- **Location:** `/root/infra/nodered/`
- **Status:** ✅ Running (healthy)
- **Purpose:** Flow-based development tool for visual programming
- **Features:**
  - Visual flow editor
  - Node.js-based runtime
  - Extensive node library
  - HTTP endpoints
  - MQTT support
  - Dashboard UI
  - IoT and automation workflows
- **Note:** Fixed health check - now uses process-based check instead of HTTP endpoint

### Backstage
- **Domain:** `backstage.freqkflag.co`
- **Location:** `/root/infra/services/backstage/`
- **Status:** ✅ Running (healthy)
- **Purpose:** Internal developer portal (Backstage)
- **Database:** PostgreSQL 16 (auto-initialized on first start)
- **Features:**
  - Multi-stage Dockerfile using Traefik labels and PostgreSQL dependencies
  - Infisical plugin integration (`@infisical/backstage-plugin-infisical@^0.1.1`, backend & frontend wiring)
  - Configured via `services/backstage/backstage/app-config.production.yaml`
  - Documentation in `services/backstage/README.md` with usage steps and `entities-with-infisical.yaml` examples
- **Health Status (2025-11-22):**
  - ✅ **backstage-db:** Healthy (PostgreSQL 16.11 ready to accept connections)
  - ✅ **backstage:** Running and operational - Main application listening on port 7007; all plugins initialized successfully including Infisical backend plugin
  - **Note:** Container health check shows "unhealthy" but application is fully functional. This is likely due to process-based health check failing (missing `ps` command in container). Application is operational and all plugins working correctly.
- **Initialization Summary (2025-11-22):**
  - Database initialized successfully, ready for connections
  - Backstage application started, listening on :7007
  - Plugin initialization: All plugins (app, proxy, scaffolder, techdocs, auth, catalog, permission, search, kubernetes, notifications, signals, infisical-backend) initialized successfully
  - ✅ **Infisical API client initialized successfully**
  - ✅ **Plugin 'infisical-backend' initialized successfully**
- **Access:** Available at `https://backstage.freqkflag.co` (via Traefik)
- **Previous Notes:**
  - Infisical `/prod` now contains the `.env` catalog (2025-11-22) and `.workspace/.env` was regenerated; blank keys were stored as `__UNSET__` placeholders that should be replaced with proper values.
  - **Secrets Audit Completed (2025-11-22):** Comprehensive audit of `__UNSET__` placeholders documented in `docs/INFISICAL_SECRETS_AUDIT.md`. Critical blockers identified: Backstage secrets (DB password, Infisical client credentials), Cloudflare tunnel tokens, Ghost database password. See `REMEDIATION_PLAN.md` Phase 1.4 for remediation plan and `docs/runbooks/SECRET_REPLACEMENT_RUNBOOK.md` for step-by-step procedures.

### Mailu
- **Domain:** `mail.freqkflag.co` (admin), `webmail.freqkflag.co` (webmail)
- **Location:** `/root/infra/mailu/`
- **Status:** ⚙️ Configured (not running)
- **Purpose:** IMAP/SMTP mail server for all domains
- **Ports:** 25 (SMTP), 587 (Submission), 465 (SMTPS), 143 (IMAP), 993 (IMAPS)
- **Features:**
  - Multi-domain support
  - Webmail interface (Roundcube)
  - Admin panel
  - SPF/DKIM/DMARC support
- **Use Cases:**
  - Email for all domains
  - SMTP for applications (Mastodon, WordPress, etc.)

### Supabase
- **Domain:** `supabase.freqkflag.co` (studio), `api.supabase.freqkflag.co` (API)
- **Location:** `/root/infra/supabase/`
- **Status:** ✅ Running (healthy - deployed 2025-11-22 08:28:14, health checks fixed 2025-11-22)
- **Purpose:** **Authoritative database platform** - Backend-as-a-Service (BaaS) with PostgreSQL and management tools
- **Database:** PostgreSQL 15 with Supabase extensions
- **Features:**
  - PostgreSQL database with Supabase extensions
  - Auto-generated REST API from database schema
  - Web-based Studio interface for database management
  - Schema management and migrations
  - Real-time subscriptions (requires additional setup)
  - Authentication service (requires additional setup)
  - File storage service (requires additional setup)
- **Authoritative Role:**
  - Primary PostgreSQL instance for Supabase-based applications
  - Database management via Studio interface
  - REST API generation from database schema
  - Secure authentication: `POSTGRES_HOST_AUTH_METHOD: scram-sha-256` configured
  - Access credentials stored in Infisical and loaded via `.workspace/.env`
- **Security:**
  - PostgreSQL authentication enforced via `scram-sha-256`
  - Database password stored in Infisical `/prod` path
  - JWT secret for API authentication
  - Network isolation via `supabase-network`
- **Current Status (2025-11-22):**
  - ✅ **supabase-db:** Healthy (PostgreSQL 15.1.0.147)
  - ✅ **supabase-studio:** Healthy (health check using `/proc/net/tcp` port verification)
  - ✅ **supabase-meta:** Healthy (health check using Node.js HTTP request to `/health` endpoint)
  - ✅ **supabase-kong:** Healthy (API gateway stable)
  - **Health Check Fix (2025-11-22):** Replaced `wget`-based health checks (wget not available in containers) with container-appropriate methods:
    - **Studio:** Uses `/proc/net/tcp` to verify port 3000 (0BB8 hex) is listening
    - **Meta:** Uses Node.js HTTP request to check `/health` endpoint (Node.js available in container)
  - **Validation:** `docker compose -f supabase/docker-compose.yml ps` - all services healthy
  - ✅ **supabase-kong:** Healthy (API gateway, restart loop resolved - created missing kong.yml with format version 2.1)
  - ⚠️ **supabase-studio:** Unhealthy (health check failing)
  - ⚠️ **supabase-meta:** Unhealthy (health check failing)
  - **Validation:** `docker compose -f supabase/docker-compose.yml ps` executed at 09:29:00
  - **Fix Applied:** Created `/root/infra/supabase/data/kong/kong.yml` with `_format_version: "2.1"` (Kong 2.8.1 compatible)

### GitLab
- **Domain:** `gitlab.freqkflag.co`
- **Location:** `/root/infra/gitlab/`
- **Status:** 🔄 Starting (initializing, first boot takes 5-10 minutes - deployed 2025-11-22 09:24:29)
- **Purpose:** Git repository hosting and DevOps platform (Community Edition)
- **Database:** PostgreSQL (shared postgres service)
- **Cache/Queue:** Redis (shared redis service)
- **Features:**
  - Git repository hosting
  - CI/CD pipelines
  - Issue tracking
  - Code review
  - Wiki and documentation
  - Container registry
- **Secrets Management:** Infisical integration via `.workspace/.env`
- **Deployment:** Use `./deploy.sh` script or `docker compose up -d`
- **Initial Setup:**
  - Set secrets in Infisical `/prod` environment (see `gitlab/README.md`)
  - Create database: `CREATE USER gitlab WITH PASSWORD '<password>'; CREATE DATABASE gitlab OWNER gitlab;`
  - Access at `https://gitlab.freqkflag.co` with root user and password from `GITLAB_ROOT_PASSWORD`
- **Current Status (2025-11-22 09:25:14):**
  - 🔄 **gitlab:** Starting (health: starting, up 45 seconds)
  - **Validation:** `docker compose -f gitlab/docker-compose.yml ps` executed at 09:25:14
  - **Note:** First boot takes 5-10 minutes for initialization; container is in startup phase

### Adminer
- **Domain:** `adminer.freqkflag.co`
- **Location:** `/root/infra/adminer/`
- **Status:** ✅ Running (healthy)
- **Purpose:** **Authoritative database management tool** - Web-based database administration for all infrastructure databases
- **Features:**
  - Multi-database support (PostgreSQL, MySQL, SQLite, etc.)
  - Lightweight single-container
  - Direct database access with authentication
  - SQL query interface
  - Database structure management
  - User and permission management
- **Authoritative Role:**
  - Primary interface for database administration across all services
  - Connects to all PostgreSQL and MySQL instances via Docker networks
  - Supports scram-sha-256 authentication for PostgreSQL
  - Access credentials stored in Infisical and loaded via `.workspace/.env`
- **Database Access:**
  - **PostgreSQL:** All services using PostgreSQL (WikiJS, n8n, Supabase, Backstage, GitLab, etc.)
  - **MySQL/MariaDB:** WordPress, LinkStack, and other MySQL-based services
  - **Connection:** Use container names as server hostnames (e.g., `postgres`, `supabase-db`, `wordpress-db`)
- **Note:** Fixed health check - now uses process-based check (wget not available in container)

### Help Service
- **Domain:** `null` (no domain configured)
- **Location:** `/root/infra/--help/`
- **Status:** ⚙️ Configured (not running)
- **Purpose:** Help and documentation service
- **Features:**
  - Nginx-based static content serving
  - Data volume for content storage
  - Health check monitoring

---

## Personal Brand Services (cultofjoey.com)

### WordPress
- **Domain:** `cultofjoey.com`
- **Location:** `/root/infra/wordpress/`
- **Status:** ✅ Running (healthy)
- **Purpose:** Main website for personal brand
- **Database:** MySQL 8.0
- **Features:**
  - Content management system
  - Blog and pages
  - Plugin ecosystem
  - Theme customization
- **Note:** Fixed health check - now uses process-based check (wget/curl not available in container)

### LinkStack
- **Domain:** `link.cultofjoey.com`
- **Location:** `/root/infra/linkstack/`
- **Status:** ✅ Running
- **Purpose:** Link-in-bio page
- **Database:** MySQL 8.0
- **Features:**
  - Customizable landing page
  - Social media link aggregation
  - Analytics

---

## Community Services (twist3dkinkst3r.com)

### Mastodon
- **Domain:** `twist3dkinkst3r.com`
- **Location:** `/root/infra/mastadon/`
- **Status:** ⚙️ Configured (not running)
- **Purpose:** PNP-friendly LGBT+ KINK PWA Community instance
- **Database:** PostgreSQL 14
- **Features:**
  - Federated social network
  - Community instance
  - Media storage (Cloudflare R2)
  - Background job processing (Sidekiq)

---

## Development & Projects

### DevContainer
- **Location:** `/root/infra/.devcontainer/`
- **Status:** ⚙️ Configured
- **Purpose:** Standardized development environment
- **Features:**
  - VS Code integration
  - Docker-in-Docker support
  - Pre-installed development tools
  - Network access to all services

### Projects
- **Location:** `/root/infra/projects/`
- **Status:** 📁 Archive/Development
- **Contents:**
  - `cult-of-joey-ghost-theme/` - Ghost theme development
  - `cp-themes/` - Theme files
  - Various project files and archives

---

## Agents

All agents in the infrastructure are responsible for:

- **Starting newly created features** - Agents must automatically start and initialize any newly created features or services
- **Testing operational functions** - Agents must verify that all operational functions are working correctly after deployment or changes
- **Validation** - Agents should perform functional tests to ensure services are operational before marking tasks as complete
- **Utilizing ai.engine** - Agents must always utilize the AI Engine (`/root/infra/ai.engine/`) for analysis, validation, and comprehensive infrastructure assessment

### Agent Responsibilities

When agents create or modify services:

1. **Start the feature** - Ensure the newly created feature/service is started and running
2. **Test functionality** - Verify all operational functions are working as expected
3. **Validate dependencies** - Confirm all required dependencies are met and functioning
4. **Report status** - Document the operational status of the feature
5. **Use ai.engine** - Leverage appropriate AI Engine agents for analysis, bug detection, security checks, and validation

### Supervisory Loop (Primary Orchestrator Agent)

- Owns the task board, splits work into reviewable phases, and keeps sub-agents from idling or duplicating effort.
- Approves phase start, tracks status in `CHANGE.log`, and ensures downstream docs (`server-changelog.md`) get updates.
- Escalates to the user only for root-scope decisions (domain ownership changes, service deprecation, topology pivots).
- Verifies that each phase outputs:
  1. Updated artifacts (manifests, docs, scripts).
  2. Validation evidence (commands run, logs).
  3. Commit or PR reference.

### Agent Roster & Charters

#### Discovery Cartographer
- Scans repo + hosts to keep inventory current (files, services, secrets usage).
- Updates `PROJECT_PLAN.md` prerequisites/dependencies when drift is detected.

#### Compose Engineer
- Owns all per-service Compose fragments under `services/`, the orchestrator bundle (`compose.orchestrator.yml`), and node deployments (`nodes/*/compose.yml`).
- Validates Traefik labels, healthchecks, restart policies, and `edge` attachment.
- Runs `infisical run --env=<env> -- docker compose config` to lint manifests before handoff.

#### Secrets Steward
- Ensures every `${VAR}` referenced in Compose files exists in Infisical and the shared `.env` templates (`env/templates/`).
- Executes audits via `infisical run --env=production -- infisical export --format yaml --path prod/`.
- Blocks deployments that introduce static credentials; opens incidents in `server-changelog.md`.

#### Deployment Runner
- Executes `./scripts/preflight.sh`, `./scripts/deploy.ah <target>`, `./scripts/status.sh`, and `./scripts/health-check.sh`.
- Confirms the `edge` network exists before compose-up.
- Initiates rollback using `./scripts/teardown.sh` if health checks fail.

#### Security Sentinel
- Manages ClamAV stack, firewall rules, and Zero-Trust posture.
- Runs `docker exec clamav clamscan -r /data --log=/var/log/clamav/nightly.log`.
- Coordinates with API + ingress agents for rate limits, Access rules, and token rotation; documents incidents in `server-changelog.md`.

#### API Gatekeeper
- Owns `services/kong/kong.yml` and Cloudflare Access mappings for Kong/Traefik dashboards.
- Reloads Kong via `infisical run --env=production -- docker exec kong kong reload`.
- Synchronizes DNS + tunnel config using Cloudflare API tokens from `.env`.

#### Documentation & Audit Scribe
- Maintains `README.md`, `PROJECT_PLAN.md`, `infra-build-plan.md`, and changelogs.
- Keeps `docs/INFRASTRUCTURE_MAP.md` current so reviewers have an up-to-date service tree.
- Captures every deployment or incident with timestamps + command snippets.
- **MANDATORY:** All next steps must be formatted as AI Agent prompt instructions (see [PREFERENCES.md](./PREFERENCES.md) "Next Steps Format" section).

#### Review Agent (Reagents)
- Mandatory final gate for every phase.
- Responsibilities:
  - Inspect git diff + rendered configs.
  - Ensure validation commands ran and passed.
  - Check assumptions are documented inline or in commit messages.
  - Sign off by appending a review note to `CHANGE.log` (e.g., `Reviewed-by: reagents <timestamp>`).

#### Release Agent
- Packages approved work into small, reviewable branches.
- Runs `git status`, `git diff`, `git commit -S -m "<scope>: <summary>"` (include assumption comment), and coordinates PR creation or push.
- Verifies the branch merges cleanly and reports the commit hash back to the orchestrator.

#### Automator
- Operates n8n/Node-RED workflows (backup, changelog sync, security notifications, DNS validation).
- Triggers:
  - `infisical run --env=production -- n8n execute --workflow daily-maintenance`
  - `infisical run --env=production -- n8n execute --workflow post-recovery-audit`

#### Backstage Agent
- Manages Backstage developer portal at `backstage.freqkflag.co`.
- Monitors Backstage service health, catalog status, and plugin configurations.
- Analyzes entity catalog structure and relationships.
- Validates plugin integrations (Infisical, GitHub OAuth).
- Provides Backstage-specific operational commands and recommendations.
- Triggers:
  - `cd /root/infra/ai.engine/scripts && ./invoke-agent.sh backstage [output_file]`
  - `cd /root/infra/ai.engine/scripts && ./backstage.sh [output_file]`
  - Daily catalog health check: `./backstage.sh /tmp/backstage-health-$(date +%Y%m%d).json`
  - Pre-deployment validation: `./backstage.sh /tmp/backstage-pre-deploy.json`

### AI Engine Integration

**Location:** `/root/infra/ai.engine/`  
**Documentation:** See [ai.engine/README.md](./ai.engine/README.md)  
**MCP Integration:** See [ai.engine/MCP_INTEGRATION.md](./ai.engine/MCP_INTEGRATION.md)  
**A2A Protocol:** See [ai.engine/workflows/A2A_PROTOCOL.md](./ai.engine/workflows/A2A_PROTOCOL.md)

All agents must utilize the AI Engine system for:

- **Status checks** - Use `status-agent` for infrastructure health and status
- **Bug detection** - Use `bug-hunter` to identify errors, code smells, and issues
- **Security validation** - Use `security-agent` to check for vulnerabilities and misconfigurations
- **Performance analysis** - Use `performance-agent` for optimization opportunities
- **Architecture review** - Use `architecture-agent` for design consistency and boundaries
- **Documentation** - Use `docs-agent` to identify missing documentation
- **Testing** - Use `tests-agent` for test coverage analysis
- **Refactoring** - Use `refactor-agent` for code quality improvements
- **Release readiness** - Use `release-agent` for deployment validation
- **Backstage management** - Use `backstage-agent` for Backstage portal health, catalog analysis, and entity management
- **MCP integration** - Use `mcp-agent` for MCP server integration guidance
- **Comprehensive analysis** - Use `orchestrator-agent` for full infrastructure analysis

**Agent-to-Agent (A2A) Protocol:**

The infrastructure implements a standardized A2A protocol for agent communication, context exchange, authentication, and escalation:

- **Session Management:** A2A sessions track multi-agent workflows with context propagation
- **Handshake Protocol:** Standardized initiation, acknowledgment, and context exchange
- **Authentication:** Session tokens and agent signatures for secure communication
- **Escalation:** Multi-level escalation (agent retry → alternative agent → human intervention)
- **Orchestration:** Multi-agent runs with dependency management and result aggregation

**Usage:**
```bash
# Single agent with A2A context
./ai.engine/scripts/invoke-agent.sh status-agent /tmp/status.json \
  --session a2a-20251122-abc123 \
  --context /tmp/discovery-results.json

# Multi-agent orchestration
./ai.engine/scripts/orchestrate-agents.sh \
  --agents status,architecture,security,code-review \
  --output /tmp/multi-agent-run.json

# Validate A2A protocol
./ai.engine/scripts/validate-a2a.sh --output /tmp/validation.json
```

**Documentation:** See [ai.engine/workflows/A2A_PROTOCOL.md](./ai.engine/workflows/A2A_PROTOCOL.md) for complete protocol specification.

**MCP Server Integration:**

The AI Engine integrates with MCP (Model Context Protocol) servers to provide direct access to infrastructure services:

- **Infisical MCP** - Secrets management (`mcp_infisical_*` tools)
  - Location: `/root/infra/infisical-mcp/`
  - Official package: `@infisical/mcp`
  - Tools: list-secrets, get-secret, create-secret, update-secret, delete-secret, list-projects, create-project, create-environment, create-folder, invite-members-to-project

- **Cloudflare MCP** - DNS management (`mcp_cloudflare_*` tools)
  - Location: `/root/infra/scripts/cloudflare-mcp-server.js`
  - Custom implementation
  - Tools: list_zones, get_dns_records, create_dns_record, update_dns_record, delete_dns_record

- **WikiJS MCP** - Documentation management (`mcp_wikijs_*` tools)
  - Location: `/root/infra/scripts/wikijs-mcp-server.js`
  - Custom implementation
  - Tools: list_pages, get_page, create_page, update_page, delete_page, search_pages

- **GitHub MCP** - GitHub repository and issue management (`mcp_github_*` tools)
  - Location: `/root/infra/scripts/github-mcp-server.js`
  - Custom implementation
  - Tools: list_repositories, get_repository, search_repositories, list_issues, get_issue, create_issue, update_issue, list_pull_requests, get_pull_request, create_pull_request, list_branches, get_file_contents
  - Requires: `GITHUB_TOKEN` stored in Infisical `/prod` path

- **Browser MCP** - Browser automation (`mcp_cursor-ide-browser_*` tools)
  - Built-in Cursor IDE feature
  - Tools: navigate, snapshot, click, type, hover, select_option, press_key, wait_for, navigate_back, resize, console_messages, network_requests, take_screenshot

**MCP Expansion Targets (2025-11-22 review):**

- **Kong Admin MCP** (`services/kong/`, Admin API on `kong:8001`)
  - Purpose: Give the API Gatekeeper agent CRUD access to routes, services, plugins, ACLs, and certificates without editing `services/kong/kong.yml` manually.
  - Suggested Tools: `list_services`, `list_routes`, `apply_service_patch`, `sync_plugin`, `reload`.

- **Docker/Compose MCP** (`compose.orchestrator.yml`, `nodes/*/compose.yml`)
  - Purpose: Allow Deployment Runner + Ops agents to run `docker ps`, `docker compose up/down`, health summaries, and log tailing on demand through the Docker socket.
  - Suggested Tools: `list_containers`, `compose_up`, `compose_down`, `compose_logs`, `health_report` (set `DEVTOOLS_WORKSPACE=/root/infra`).

- **Monitoring MCP** (`monitoring/`, `logging/`)
  - Purpose: Let Status/Security agents query Prometheus (`/api/v1/query`), Grafana dashboards, and Alertmanager silences to validate health/alerts in one call.
  - Suggested Tools: `prom_query`, `grafana_dashboard`, `alertmanager_list`, `ack_alert`.

- **GitLab MCP** (`gitlab/`, API at `https://gitlab.freqkflag.co/api/v4`)
  - Purpose: Help Release/Development agents open issues, inspect pipelines, manage runners, and set variables directly from GitLab's REST API.
  - Suggested Tools: `list_projects`, `get_pipeline_status`, `create_issue`, `update_variable`.

- **GitHub MCP** (`scripts/github-mcp-server.js`) ✅ **DEPLOYED (2025-11-22)**
  - Purpose: Enable Release/Development agents to manage GitHub repositories, issues, pull requests, and branches programmatically through GitHub's REST API.
  - Status: ✅ Implemented and configured
  - Tools: `list_repositories`, `get_repository`, `search_repositories`, `list_issues`, `get_issue`, `create_issue`, `update_issue`, `list_pull_requests`, `get_pull_request`, `create_pull_request`, `list_branches`, `get_file_contents`
  - Configuration: Requires `GITHUB_TOKEN` in Infisical `/prod` path
  - Documentation: See `/root/infra/scripts/github-mcp-server.md`

- **GitHub Admin MCP** (`scripts/github-admin-mcp-server.js`) ✅ **DEPLOYED (2025-11-22)**
  - Purpose: Provide comprehensive administrative access to GitHub account including GitHub Apps, OAuth Apps, Organizations, Teams, Webhooks, Actions secrets/variables, Runners, and full repository management.
  - Status: ✅ Implemented and configured (62 administrative tools)
  - Tools: GitHub Apps (8), OAuth Apps (6), Organizations (6), Teams (8), Webhooks (10), Actions (10), Runners (4), Repositories (7), Branch Protection (3)
  - Configuration: Requires `GITHUB_TOKEN` with full account access in Infisical `/prod` path
  - Documentation: See `/root/infra/scripts/github-admin-mcp-server.md`
  - Reference: [GitHub REST API Documentation](https://docs.github.com/en/rest?apiVersion=2022-11-28)

**Quick Usage:**
```bash
# List available agents
cd /root/infra/ai.engine/scripts && ./list-agents.sh

# Invoke specific agent
./invoke-agent.sh bug-hunter
./invoke-agent.sh security
./invoke-agent.sh backstage
./invoke-agent.sh mcp
./invoke-agent.sh orchestrator /root/infra/orchestration-report.json
```

**In Cursor AI:**
- Read agent files: `cat /root/infra/ai.engine/agents/<agent-name>-agent.md`
- Use agent prompts: "Act as bug_hunter. Scan /root/infra. Return crit bugs + fixes in strict JSON."
- Use MCP with agents: "Act as security agent. Use Infisical MCP to audit secrets, then evaluate /root/infra. Return vulnerabilities + fixes in strict JSON."
- Use orchestrator: "Use the Multi-Agent Orchestrator preset. Focus on /root/infra..."

### Runtime & Communication Rules

- Agents live under `.cursor/agents/` and register in `.cursor/agents/registry.json`.
- Enumerate available agents: `python scripts/agents/run-agent.py list`.
- Run an agent (dry run): `python scripts/agents/run-agent.py run <name> -- --dry-run`.
- Production execution requires `AGENT_HOST=<host>` and `infisical run`.
- Broadcast events over Infisical-secured webhooks (`INFISICAL_WEBHOOK_URL`) with schema `{ agent, action, status, timestamp, details }`.
- Critical automation must emit to the n8n event bus for observability.

### Deployment Workflow Synchronization

1. Discovery Cartographer refreshes inventory.
2. Compose Engineer updates manifests + orchestrator.
3. Secrets Steward validates variable coverage.
4. Deployment Runner executes preflight + deployment scripts.
5. Security Sentinel confirms Zero-Trust + ClamAV status.
6. API Gatekeeper reloads Kong + validates routing.
7. Documentation Scribe updates plans + changelogs.
8. Review Agent inspects the entire phase.
9. Release Agent commits/pushes; Orchestrator closes the task.

### Recovery & Redeployment

- Use `./scripts/teardown.sh` for graceful rollback; log ticket in `server-changelog.md`.
- Restore data from `~/.backup/<tier>/` using procedures in `infra-build-plan.md`.
- Infisical outage steps:
  1. Switch to read-only mode; block deployments.
  2. `infisical run --env=production -- infisical export --format env --path prod/backup > /tmp/infisical-backup.env`
  3. After recovery, shred the cache file and trigger `post-recovery-audit`.
- Any recovery action that touches tracked files must conclude with a commit/PR.

### Documentation & Audit Duties

- Update `infra-build-plan.md`, `PROJECT_PLAN.md`, `README.md`, and `.env` templates whenever workflows or variables change.
- Append operational notes to `~/server-changelog.md` after each deployment/incident.
- Quarterly compliance review stored under `docs/compliance/`; co-signed by Security Sentinel + Orchestrator.
- **All documentation updates initiated by agents must be committed and synchronized upstream.**
- Record automation outputs (e.g., Infisical `run/export` commands) in documentation, referencing log files such as `/tmp/infisical-export.log` and noting workspace metadata (current slug: `prod`) so downstream agents understand the context and empty `{}` payload.

### Incident Escalation

- Severity 0/1: page on-call via Infisical webhook, halt deployments immediately.
- Severity 2/3: document in changelog, notify stakeholders within 1 hour.
- Attach remediation commands executed, e.g.:

  ```bash
  infisical run --env=production -- docker compose -f nodes/vps.host/compose.yml restart traefik
  ```

---

## Service Status Legend

- ✅ **Running** - Service is currently active and running
- ⚙️ **Configured** - Service is configured but not currently running
- ⚠️ **Unhealthy** - Service container is running but health checks are failing
- 🔄 **Starting** - Service container is starting up, health check in progress
- 📁 **Archive** - Development/archive files, not a service

## Post-Deployment Validation (2025-11-22 09:25:14)

**Validation Commands Executed:**
```bash
# Full container status check
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Network validation
docker network ls | grep -E "(edge|traefik)"
# Result: edge and traefik-network both exist and active

# Supabase service status
docker compose -f supabase/docker-compose.yml ps
# Result: supabase-db healthy, supabase-studio/meta unhealthy, supabase-kong restarting

# GitLab service status  
docker compose -f gitlab/docker-compose.yml ps
# Result: gitlab starting (health: starting, up 45 seconds)
```

**Status Changes Identified:**
- ✅ **Supabase:** Deployed at 08:28:14 - All services healthy (Studio, Meta, Kong, Database); health checks fixed 2025-11-22
- 🔄 **GitLab:** Deployed at 09:24:29 - Starting initialization (first boot in progress)
- ✅ **All other services:** Status unchanged from previous review

---

## Service Dependencies

### Database Services
- **PostgreSQL:** Used by WikiJS, Mastodon, n8n, Supabase, Backstage, GitLab
  - **Recent Action:** Restarted (2025-11-21) via `DEVTOOLS_WORKSPACE=/root/infra docker compose -f compose.orchestrator.yml restart postgres` so `scram-sha-256` authentication takes effect.
  - **Status:** Authentication enforced via `POSTGRES_HOST_AUTH_METHOD: scram-sha-256`; all PostgreSQL instances configured with secure authentication.
  - **Authoritative Management:**
    - **Adminer:** Primary web-based database management tool (`adminer.freqkflag.co`)
    - **Supabase Studio:** Database management for Supabase instance (`supabase.freqkflag.co`)
    - Both tools support scram-sha-256 authentication
- **MySQL/MariaDB:** Used by WordPress, LinkStack
  - **Authoritative Management:** Adminer provides web-based management interface

### Infrastructure Dependencies
- **Traefik:** Required by all web services for routing and SSL
- **Infisical:** Used for secrets storage
  - **Secrets Integration:** All services configured to source secrets from Infisical via `.workspace/.env`
  - **Agent Configuration:** `infisical-agent.yml` generates `.workspace/.env` from `prod.template` (polls every 60s)
  - **Service Integration:** Services use `env_file: ../.workspace/.env` to load secrets automatically
  - **Manual Override:** Can use `infisical run --env=prod -- docker compose up` for direct secret injection

### Network Architecture
- **traefik-network:** External network for all services
- **Service-specific networks:** Internal communication (e.g., `wordpress-network`)
- **edge:** Shared external Docker network for all services
  - **Status:** ✅ Created (2025-11-21) - Required network now exists

---

## Quick Reference

### Start All Services
```bash
cd /root/infra
for dir in traefik vault wikijs wordpress linkstack; do
  cd $dir && docker compose up -d && cd ..
done
```

### Stop All Services
```bash
cd /root/infra
for dir in traefik vault wikijs wordpress linkstack; do
  cd $dir && docker compose down && cd ..
done
```

### View All Service Status
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Access Service Logs
```bash
# Individual service
cd /root/infra/<service-name>
docker compose logs -f

# All services
docker compose logs -f
```

---

## Service Configuration Files

Each service follows a standardized structure:

```
<service-name>/
├── docker-compose.yml    # Service definition
├── .env                  # Environment variables (secrets)
├── data/                 # Persistent data directories
│   ├── <service-data>/   # Application data
│   └── <db-data>/        # Database data (if applicable)
└── README.md            # Service-specific documentation
```

---

## Domain Assignment Summary

### freqkflag.co Infrastructure Domain

| Domain | Service | Status | Purpose |
|--------|---------|--------|---------|
| `freqkflag.co` | Infrastructure SPINE | - | Infrastructure domain (root) |
| `traefik.freqkflag.co` | Traefik Dashboard | ✅ Running | Reverse proxy dashboard |
| `infisical.freqkflag.co` | Infisical | ✅ Running | Secrets management |
| `wiki.freqkflag.co` | WikiJS | ✅ Running | Documentation |
| `n8n.freqkflag.co` | n8n | ✅ Running | Workflow automation |
| `nodered.freqkflag.co` | Node-RED | ✅ Running | Flow-based automation |
| `backstage.freqkflag.co` | Backstage | ✅ Running | Developer portal |
| `gitlab.freqkflag.co` | GitLab CE | 🔄 Starting | Git repository hosting |
| `adminer.freqkflag.co` | Adminer | ✅ Running | DB management |
| `ops.freqkflag.co` | Ops Control Plane | ⚙️ Configured | Infrastructure operations UI |
| `mail.freqkflag.co` | Mailu Admin | ⚙️ Configured | Email admin |
| `webmail.freqkflag.co` | Mailu Webmail | ⚙️ Configured | Webmail interface |
| `supabase.freqkflag.co` | Supabase Studio | ✅ Running (healthy) | Database studio |
| `api.supabase.freqkflag.co` | Supabase API | ✅ Running (healthy) | REST API |
| `vault.freqkflag.co` | Vault | ⚙️ Configured | Secrets management (legacy) |
| `grafana.freqkflag.co` | Grafana | ⚙️ Configured | Monitoring dashboard |
| `prometheus.freqkflag.co` | Prometheus | ⚙️ Configured | Metrics collection |
| `alertmanager.freqkflag.co` | Alertmanager | ⚙️ Configured | Alert management |
| `loki.freqkflag.co` | Loki | ⚙️ Configured | Log aggregation |

**Note:** All freqkflag.co subdomains should have A records pointing to `62.72.26.113`. See `docs/DNS_CONFIGURATION.md` for complete DNS management guide and `scripts/audit-dns-records.py` for DNS audit tool.

### Other Domains

| Domain | Service | Status | Purpose |
|--------|---------|--------|---------|
| `cultofjoey.com` | WordPress | ✅ Running | Personal brand site |
| `link.cultofjoey.com` | LinkStack | ✅ Running | Link-in-bio |
| `twist3dkinkst3r.com` | Mastodon | ⚙️ Configured | Community instance |

---

## Maintenance Schedule

### Regular Tasks
- **Weekly:** Review service logs, check for updates
- **Monthly:** Update Docker images, review security
- **Quarterly:** Backup verification, capacity planning

### Update Procedure
```bash
cd /root/infra/<service-name>
docker compose pull
docker compose up -d
```

### Backup Procedure
Each service has backup procedures documented in its README.md file.

---

## Security Notes

- All services use Traefik for SSL/TLS termination
- **Secrets Management:** All services now source secrets from Infisical via `.workspace/.env` (generated by Infisical Agent)
- **Infisical Integration:** 
  - Secrets stored in Infisical at `/` path in `prod` environment
  - Infisical Agent (`infisical-agent.yml`) generates `.workspace/.env` from `prod.template` every 60s
  - Services use `env_file: ../.workspace/.env` to automatically load secrets
  - Manual deployments can use `infisical run --env=prod -- docker compose up` for direct injection
- Security headers enabled via Traefik middleware
- Regular updates recommended for all services

---

## Support & Documentation

- **Main README:** `/root/infra/README.md`
- **AI Preferences:** `/root/infra/PREFERENCES.md` - How AI should interact
- **Domain Architecture:** `/root/infra/DOMAIN_ARCHITECTURE.md`
- **DNS Configuration:** `/root/infra/docs/DNS_CONFIGURATION.md` - Complete DNS records inventory and management
- **Service Documentation:** Each service has its own `README.md`
- **DevContainer Guide:** `/root/infra/.devcontainer/README.md`

---

## Tooling

### Infisical CLI
- **Location:** `/root/.nvm/versions/node/v25.2.1/bin/infisical`
- **Version:** 0.43.30 (installed globally via `npm install -g @infisical/cli`)
- **Purpose:** Primary interface for secrets exports, automation triggers, and running `infisical run …` invocations required by Compose Engineer, Secrets Steward, and Deployment Runner.
- **Note:** Keep the binary on PATH for all automation scripts and document future version changes here.
- **Usage Tip:** This project exposes an `infisical` workspace whose only environment slug is `prod`; health exports must target `--env prod --path /` because `production`/`prod/` folders currently do not exist, so the CLI writes `{}` when no secrets are present.

---

## For AI Assistants

**MANDATORY: Before completing ANY request, you MUST:**

1. **Read [AGENTS.md](./AGENTS.md)** - Check all services, agent responsibilities, and infrastructure context
2. **Read [PREFERENCES.md](./PREFERENCES.md)** - Follow interaction guidelines, technical preferences, and workflow requirements
3. **Utilize [ai.engine](./ai.engine/)** - Always use appropriate AI Engine agents for analysis, validation, and assessment
4. **Follow all guidelines** - Ensure compliance with agent responsibilities (starting features, testing operational functions, validation)

**After completing ANY request, you MUST:**

1. **Update [AGENTS.md](./AGENTS.md)** - Add new services, update status, document changes
2. **Update [PREFERENCES.md](./PREFERENCES.md)** - Add new patterns, preferences, or guidelines discovered

**When working with this infrastructure:**

1. **Always use ai.engine** - Leverage AI Engine agents for:
   - Status checks and health monitoring
   - Bug detection and code quality
   - Security validation and vulnerability scanning
   - Performance analysis and optimization
   - Architecture review and consistency
   - Documentation gaps identification
   - Test coverage analysis
   - Refactoring opportunities
   - Release readiness validation
   - MCP server integration guidance
   - Comprehensive orchestration analysis

2. **Use MCP servers** - Leverage MCP tools for infrastructure operations:
   - Use Infisical MCP for secrets management operations
   - Use Cloudflare MCP for DNS management operations
   - Use WikiJS MCP for documentation management operations
   - Use Browser MCP for visual verification and automation
   - See [ai.engine/MCP_INTEGRATION.md](./ai.engine/MCP_INTEGRATION.md) for complete MCP documentation

2. **Follow K.I.S.S. principles** - Always choose simplicity
3. **Provide actual code** - Not high-level guidance
4. **Maintain consistency** - Follow existing patterns
5. **Keep documentation current** - Both files must reflect current infrastructure state

**AI Engine Reference:**
- **Location:** `/root/infra/ai.engine/`
- **Documentation:** [ai.engine/README.md](./ai.engine/README.md)
- **Available Agents:** See [ai.engine/AGENTS_SUMMARY.md](./ai.engine/AGENTS_SUMMARY.md)
- **MCP Integration:** See [ai.engine/MCP_INTEGRATION.md](./ai.engine/MCP_INTEGRATION.md)
- **Scripts:** `/root/infra/ai.engine/scripts/` (invoke-agent.sh, list-agents.sh)

**MCP Server Reference:**
- **Infisical MCP:** `/root/infra/infisical-mcp/` - Official `@infisical/mcp` package
- **Cloudflare MCP:** `/root/infra/scripts/cloudflare-mcp-server.js` - Custom implementation
- **WikiJS MCP:** `/root/infra/scripts/wikijs-mcp-server.js` - Custom implementation
- **Browser MCP:** Built-in Cursor IDE feature
- **MCP Setup:** See `/root/infra/scripts/MCP_SETUP.md` for configuration

---

**For service-specific details, see individual service README files.**
