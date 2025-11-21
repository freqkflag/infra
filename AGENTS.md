# Infrastructure Agents & Services

**Last Updated:** 2025-11-20  
**Infrastructure Domain:** `freqkflag.co` (SPINE)

**AI Reference:** See [PREFERENCES.md](./PREFERENCES.md) for interaction guidelines

This document provides a standardized overview of all services and agents in the infrastructure.

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
- **Status:** ✅ Running
- **Purpose:** Reverse proxy, SSL termination, service discovery
- **Ports:** 80 (HTTP), 443 (HTTPS), 8080 (Dashboard)
- **Features:**
  - Automatic SSL certificates (Let's Encrypt)
  - HTTP to HTTPS redirect
  - Docker provider for service discovery
  - Security headers middleware
- **Access:** Dashboard at `http://localhost:8080`

### Infisical
- **Domain:** `infisical.freqkflag.co`
- **Location:** `/root/infra/infisical/`
- **Status:** ⚙️ Configured (not running)
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

### WikiJS
- **Domain:** `wiki.freqkflag.co`
- **Location:** `/root/infra/wikijs/`
- **Status:** ✅ Running
- **Purpose:** Documentation and knowledge base
- **Database:** PostgreSQL 15
- **Features:**
  - Markdown support
  - Version control
  - Search functionality
  - Multi-user collaboration

### n8n
- **Domain:** `n8n.freqkflag.co`
- **Location:** `/root/infra/n8n/`
- **Status:** ⚙️ Configured (not running)
- **Purpose:** Workflow automation and integration platform
- **Database:** PostgreSQL 15
- **Features:**
  - Visual workflow builder
  - API integrations
  - Scheduled tasks
  - Webhook support
  - Service integrations (Mailu, etc.)

### Node-RED
- **Domain:** `nodered.freqkflag.co`
- **Location:** `/root/infra/nodered/`
- **Status:** ⚙️ Configured (not running)
- **Purpose:** Flow-based development tool for visual programming
- **Features:**
  - Visual flow editor
  - Node.js-based runtime
  - Extensive node library
  - HTTP endpoints
  - MQTT support
  - Dashboard UI
  - IoT and automation workflows

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
- **Status:** ⚙️ Configured (not running)
- **Purpose:** Web-based database management tool
- **Features:**
  - Multi-database support (PostgreSQL, MySQL, SQLite, etc.)
  - Lightweight single-container
  - Direct database access
  - SQL query interface

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
- **Status:** ✅ Running
- **Purpose:** Main website for personal brand
- **Database:** MySQL 8.0
- **Features:**
  - Content management system
  - Blog and pages
  - Plugin ecosystem
  - Theme customization

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

---

## Service Status Legend

- ✅ **Running** - Service is currently active and running
- ⚙️ **Configured** - Service is configured but not currently running
- 📁 **Archive** - Development/archive files, not a service

---

## Service Dependencies

### Database Services
- **PostgreSQL:** Used by WikiJS, Mastodon, n8n, Supabase
- **MySQL:** Used by WordPress, LinkStack

### Infrastructure Dependencies
- **Traefik:** Required by all web services for routing and SSL
- **Infisical:** Used for secrets storage

### Network Architecture
- **traefik-network:** External network for all services
- **Service-specific networks:** Internal communication (e.g., `wordpress-network`)

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
| `n8n.freqkflag.co` | n8n | ⚙️ Configured | Workflow automation |
| `mail.freqkflag.co` | Mailu Admin | ⚙️ Configured | Email admin |
| `webmail.freqkflag.co` | Mailu Webmail | ⚙️ Configured | Webmail interface |
| `supabase.freqkflag.co` | Supabase Studio | ⚙️ Configured | Database studio |
| `api.supabase.freqkflag.co` | Supabase API | ⚙️ Configured | REST API |
| `adminer.freqkflag.co` | Adminer | ⚙️ Configured | DB management |
| `nodered.freqkflag.co` | Node-RED | ⚙️ Configured | Flow-based automation |
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
- Secrets stored in `.env` files (600 permissions recommended)
- Infisical available for sensitive credential storage
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

