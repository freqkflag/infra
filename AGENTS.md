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

**When working with this infrastructure:**

1. **Read [PREFERENCES.md](./PREFERENCES.md)** - Understand interaction style and preferences
2. **Reference [AGENTS.md](./AGENTS.md)** - Know all available services
3. **Follow K.I.S.S. principles** - Always choose simplicity
4. **Provide actual code** - Not high-level guidance
5. **Maintain consistency** - Follow existing patterns

---

**For service-specific details, see individual service README files.**

