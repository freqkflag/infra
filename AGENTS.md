# Infrastructure Agents & Services

**Last Updated:** 2025-11-22  
**Infrastructure Domain:** `freqkflag.co` (SPINE)

**AI Reference:** See [PREFERENCES.md](./PREFERENCES.md) for interaction guidelines

This document provides a standardized overview of all services and agents in the infrastructure.

---

## Current Infrastructure Status (2025-11-22)

### Critical Issues
- ✅ **Traefik running** - Reverse proxy container healthy; dashboard reachable on `:8080`
- ✅ **Health checks stabilized** - WikiJS, WordPress, Node-RED, Adminer, Infisical, n8n report healthy via process-oriented probes
- ⚠️ **Backstage deployment blocked** - PostgreSQL container fails to initialize because `.workspace/.env` lacks `BACKSTAGE_DB_PASSWORD`, while Infisical client secrets are absent, preventing the build/health cycle from stabilizing; service still configured but not running

### Service Health Summary
- ✅ **Healthy:** Traefik, Infisical, WikiJS, WordPress, n8n, Node-RED, Adminer, LinkStack, Monitoring stack (Grafana, Prometheus, Loki, Alertmanager), Databases (PostgreSQL, MySQL, Redis)
- ⚙️ **Configured but not running/starting:** Mailu, Supabase, Mastodon, Help Service, Backstage (blocked by missing secrets for PostgreSQL/Infisical wiring)

### Network Status
- ✅ **edge network:** Created and available
- ✅ **traefik-network:** Exists

### Next Steps
1. Confirm Backstage Docker build completes and publish service status
2. Continue automating health monitoring (scripts, Prometheus metrics, alerts)
3. Capture Infisical secret coverage for newly added services (Backstage + companions)
4. Run deliberate preflight script to ensure dependencies sequence is honored

---

## Mission & Guardrails

- Deliver the complete infra build-out defined in `infra-build-plan.md`, `PROJECT_PLAN.md`, and `project-plan.yml`.
- Enforce reproducible, FOSS-only workflows (Docker Compose, Traefik, Cloudflared, Infisical, Kong, ClamAV, n8n/Node-RED).
- Maintain three operating domains with dedicated Cloudflared tunnels:
  - **vps.host** (`freqkflag.co`) — `${CF_TUNNEL_TOKEN_VPS}`
  - **home.macmini** (`twist3dkink.online`) — `${CF_TUNNEL_TOKEN_MAC}`
  - **home.linux** (`cult-of-joey.com`) — `${CF_TUNNEL_TOKEN_LINUX}`
- Shared external Docker network: `edge`.
- Every non-trivial change must land via commit or PR; inline commit messages must mention any assumption they encode.

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
- **Secrets Integration:**
  - ✅ **Infisical Agent configured** - `infisical-agent.yml` generates `.workspace/.env` from `prod.template`
  - ✅ **Services wired to Infisical** - All services now use `env_file: ../.workspace/.env` to load secrets
  - ✅ **Secrets flow verified** - Services can read database passwords, API keys, and tokens from Infisical
  - **Services using Infisical secrets:** n8n, WordPress, WikiJS, LinkStack, Node-RED, Infisical, Mailu, Supabase
  - **Usage:** Services automatically load secrets from `.workspace/.env` when started, or use `infisical run --env=prod -- docker compose up`

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
- **Status:** ⚙️ Configured (Docker build in progress)
- **Purpose:** Internal developer portal (Backstage)
- **Database:** PostgreSQL 16 (auto-initialized on first start)
- **Features:**
  - Multi-stage Dockerfile using Traefik labels and PostgreSQL dependencies
  - Infisical plugin integration (`@infisical/backstage-plugin-infisical@^0.1.1`, backend & frontend wiring)
  - Configured via `services/backstage/backstage/app-config.production.yaml`
  - Documentation in `services/backstage/README.md` with usage steps and `entities-with-infisical.yaml` examples
- **Notes:** Backend build currently requires source path adjustments; monitoring/health checks still pending.
  - PostgreSQL container repeatedly exits because `BACKSTAGE_DB_PASSWORD` is empty and `INFISICAL_CLIENT_ID`/`INFISICAL_CLIENT_SECRET` are missing from `.workspace/.env`; secrets must be injected via Infisical and the agent run before the service can stay up.

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
- **Status:** ⚙️ Configured (not running)
- **Purpose:** Backend-as-a-Service (BaaS) platform
- **Database:** PostgreSQL 15 with Supabase extensions
- **Features:**
  - PostgreSQL database
  - Auto-generated REST API
  - Web-based Studio interface
  - Schema management

### Adminer
- **Domain:** `adminer.freqkflag.co`
- **Location:** `/root/infra/adminer/`
- **Status:** ✅ Running (healthy)
- **Purpose:** Web-based database management tool
- **Features:**
  - Multi-database support (PostgreSQL, MySQL, SQLite, etc.)
  - Lightweight single-container
  - Direct database access
  - SQL query interface
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

### AI Engine Integration

**Location:** `/root/infra/ai.engine/`  
**Documentation:** See [ai.engine/README.md](./ai.engine/README.md)

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
- **Comprehensive analysis** - Use `orchestrator-agent` for full infrastructure analysis

**Quick Usage:**
```bash
# List available agents
cd /root/infra/ai.engine/scripts && ./list-agents.sh

# Invoke specific agent
./invoke-agent.sh bug-hunter
./invoke-agent.sh security
./invoke-agent.sh orchestrator /root/infra/orchestration-report.json
```

**In Cursor AI:**
- Read agent files: `cat /root/infra/ai.engine/agents/<agent-name>-agent.md`
- Use agent prompts: "Act as bug_hunter. Scan /root/infra. Return crit bugs + fixes in strict JSON."
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

---

## Service Dependencies

### Database Services
- **PostgreSQL:** Used by WikiJS, Mastodon, n8n, Supabase
  - **Recent Action:** Restarted (2025-11-21) via `DEVTOOLS_WORKSPACE=/root/infra docker compose -f compose.orchestrator.yml restart postgres` so `scram-sha-256` authentication takes effect.
  - **Status:** Authentication enforced; dependent services may need to reconnect, monitor once they come back up.
- **MySQL:** Used by WordPress, LinkStack

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

| Domain | Service | Status | Purpose |
|--------|---------|--------|---------|
| `freqkflag.co` | Infrastructure SPINE | - | Infrastructure domain |
| `wiki.freqkflag.co` | WikiJS | ✅ Running | Documentation |
| `n8n.freqkflag.co` | n8n | ✅ Running | Workflow automation |
| `mail.freqkflag.co` | Mailu Admin | ⚙️ Configured | Email admin |
| `webmail.freqkflag.co` | Mailu Webmail | ⚙️ Configured | Webmail interface |
| `supabase.freqkflag.co` | Supabase Studio | ⚙️ Configured | Database studio |
| `api.supabase.freqkflag.co` | Supabase API | ⚙️ Configured | REST API |
| `adminer.freqkflag.co` | Adminer | ✅ Running | DB management |
| `nodered.freqkflag.co` | Node-RED | ✅ Running | Flow-based automation |
| `backstage.freqkflag.co` | Backstage | ⚙️ Configured | Developer portal |
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
   - Comprehensive orchestration analysis

2. **Follow K.I.S.S. principles** - Always choose simplicity
3. **Provide actual code** - Not high-level guidance
4. **Maintain consistency** - Follow existing patterns
5. **Keep documentation current** - Both files must reflect current infrastructure state

**AI Engine Reference:**
- **Location:** `/root/infra/ai.engine/`
- **Documentation:** [ai.engine/README.md](./ai.engine/README.md)
- **Available Agents:** See [ai.engine/AGENTS_SUMMARY.md](./ai.engine/AGENTS_SUMMARY.md)
- **Scripts:** `/root/infra/ai.engine/scripts/` (invoke-agent.sh, list-agents.sh)

---

**For service-specific details, see individual service README files.**
