# Infrastructure Cookbook

**Your Personal Source of Truth for VPS Infrastructure**

**Last Updated:** 2025-11-20  
**VPS Location:** `/root/infra/`  
**Infrastructure Domain:** `freqkflag.co` (SPINE)

---

## Table of Contents

1. [Infrastructure Overview](#infrastructure-overview)
2. [Domain Architecture](#domain-architecture)
3. [Service Catalog](#service-catalog)
4. [Network Architecture](#network-architecture)
5. [Service Management](#service-management)
6. [Monitoring & Observability](#monitoring--observability)
7. [Logging](#logging)
8. [Backup & Recovery](#backup--recovery)
9. [Security](#security)
10. [CI/CD & Automation](#cicd--automation)
11. [Development Environment](#development-environment)
12. [Troubleshooting](#troubleshooting)
13. [Operational Procedures](#operational-procedures)
14. [Quick Reference](#quick-reference)

---

## Infrastructure Overview

### Philosophy

**K.I.S.S. (Keep It Simple, Stupid)** - The primary principle guiding all infrastructure decisions. Complexity is the enemy.

### Architecture Principles

- **Docker Compose** for all services
- **Traefik** for reverse proxy and SSL termination
- **Standardized structure** across all services
- **Local data directories** (`./data/`) for persistence
- **Health checks** on all services
- **Resource limits** on all containers
- **Security hardening** throughout

### Infrastructure Location

```
/root/infra/
├── traefik/          # Reverse proxy (MUST START FIRST)
├── vault/            # Secrets management
├── monitoring/       # Prometheus + Grafana
├── logging/          # Loki + Promtail
├── backup/           # Automated backups
├── wikijs/           # Documentation wiki
├── wordpress/        # Personal brand site
├── linkstack/        # Link-in-bio
├── n8n/              # Workflow automation
├── mailu/            # Email server
├── supabase/         # Backend-as-a-Service
├── adminer/          # Database management
├── mastadon/         # Mastodon instance
├── .devcontainer/    # Development environment
└── projects/          # Development projects
```

---

## Domain Architecture

### Central Infrastructure Domain: `freqkflag.co` (SPINE)

**Purpose:** Core infrastructure tools, automation, AI services, and internal tools.

**Services:**
- `wiki.freqkflag.co` - WikiJS documentation
- `vault.freqkflag.co` - HashiCorp Vault (secrets)
- `n8n.freqkflag.co` - Workflow automation
- `mail.freqkflag.co` - Mailu admin panel
- `webmail.freqkflag.co` - Mailu webmail
- `supabase.freqkflag.co` - Supabase Studio
- `api.supabase.freqkflag.co` - Supabase API
- `adminer.freqkflag.co` - Database management
- `grafana.freqkflag.co` - Grafana dashboards
- `prometheus.freqkflag.co` - Prometheus metrics
- `loki.freqkflag.co` - Loki logs

### Personal Brand: `cultofjoey.com`

**Purpose:** Personal creative space and brand presence.

**Services:**
- `cultofjoey.com` - WordPress main site
- `link.cultofjoey.com` - LinkStack link-in-bio

### Business: `twist3dkink.com`

**Purpose:** Kink-affirming LGBTQIA+ trauma-informed mental health peer support/coaching.

**Services:**
- (Future services to be deployed)

### Community: `twist3dkinkst3r.com`

**Purpose:** PNP-friendly LGBT+ KINK PWA Community/Hook-UP web app.

**Services:**
- `twist3dkinkst3r.com` - Mastodon instance

---

## Service Catalog

### Infrastructure Services

#### Traefik
- **Location:** `/root/infra/traefik/`
- **Status:** ✅ Running
- **Purpose:** Reverse proxy, SSL termination, service discovery
- **Ports:** 80, 443, 8080 (dashboard)
- **Access:** Dashboard at `http://localhost:8080`
- **Features:**
  - Automatic Let's Encrypt SSL certificates
  - HTTP to HTTPS redirect
  - Docker provider for auto-discovery
  - Security headers middleware
  - Prometheus metrics
- **Start First:** Traefik must be started before all other services

#### Vault
- **Location:** `/root/infra/vault/`
- **Status:** ✅ Running (Production Mode)
- **Purpose:** Secrets management
- **Domain:** `vault.freqkflag.co`
- **Port:** 32772:8200 (direct), 8200 (via Traefik)
- **Mode:** Production (5 unseal keys, 3 required)
- **Initialization:** Required on first start
- **Unsealing:** Required after each restart
- **Scripts:**
  - `scripts/init-vault.sh` - Initialize Vault
  - `scripts/unseal-vault.sh` - Unseal Vault

#### WikiJS
- **Location:** `/root/infra/wikijs/`
- **Status:** ✅ Running
- **Domain:** `wiki.freqkflag.co`
- **Database:** PostgreSQL 15
- **Purpose:** Documentation and knowledge base

#### n8n
- **Location:** `/root/infra/n8n/`
- **Status:** ⚙️ Configured
- **Domain:** `n8n.freqkflag.co`
- **Database:** PostgreSQL 15
- **Purpose:** Workflow automation

#### Mailu
- **Location:** `/root/infra/mailu/`
- **Status:** ⚙️ Configured
- **Domains:** `mail.freqkflag.co`, `webmail.freqkflag.co`
- **Purpose:** IMAP/SMTP mail server
- **Ports:** 25, 587, 465, 143, 993

#### Supabase
- **Location:** `/root/infra/supabase/`
- **Status:** ⚙️ Configured
- **Domains:** `supabase.freqkflag.co`, `api.supabase.freqkflag.co`
- **Database:** PostgreSQL 15 with Supabase extensions
- **Purpose:** Backend-as-a-Service

#### Adminer
- **Location:** `/root/infra/adminer/`
- **Status:** ⚙️ Configured
- **Domain:** `adminer.freqkflag.co`
- **Purpose:** Web-based database management

#### Node-RED
- **Location:** `/root/infra/nodered/`
- **Status:** ⚙️ Configured
- **Domain:** `nodered.freqkflag.co`
- **Purpose:** Flow-based development tool for visual programming
- **Features:**
  - Visual flow editor
  - Node.js runtime
  - HTTP endpoints
  - MQTT support
  - Dashboard UI

### Personal Brand Services

#### WordPress
- **Location:** `/root/infra/wordpress/`
- **Status:** ✅ Running
- **Domain:** `cultofjoey.com`
- **Database:** MySQL 8.0
- **Purpose:** Main personal brand website

#### LinkStack
- **Location:** `/root/infra/linkstack/`
- **Status:** ✅ Running
- **Domain:** `link.cultofjoey.com`
- **Database:** MySQL 8.0
- **Purpose:** Link-in-bio page

### Community Services

#### Mastodon
- **Location:** `/root/infra/mastadon/`
- **Status:** ⚙️ Configured
- **Domain:** `twist3dkinkst3r.com`
- **Database:** PostgreSQL 14
- **Purpose:** Federated social network instance
- **Components:** Web, Sidekiq (background jobs), Redis, PostgreSQL

### Observability Services

#### Monitoring (Prometheus + Grafana)
- **Location:** `/root/infra/monitoring/`
- **Status:** ⚙️ Configured
- **Domains:** `grafana.freqkflag.co`, `prometheus.freqkflag.co`
- **Components:**
  - Prometheus (metrics collection)
  - Grafana (visualization)
  - Node Exporter (host metrics)

#### Logging (Loki + Promtail)
- **Location:** `/root/infra/logging/`
- **Status:** ⚙️ Configured
- **Domain:** `loki.freqkflag.co`
- **Components:**
  - Loki (log aggregation)
  - Promtail (log shipper)
  - Integrated with Grafana

### Automation Services

#### Backup
- **Location:** `/root/infra/backup/`
- **Status:** ⚙️ Configured
- **Purpose:** Automated database and volume backups
- **Frequency:** Daily (databases), Weekly (volumes)
- **Retention:** 30 days daily, 12 weeks weekly

---

## Network Architecture

### Networks

#### traefik-network (External)
- **Type:** Bridge network
- **Purpose:** Connects all services to Traefik
- **Created by:** Traefik service
- **Used by:** All web-accessible services

#### Service-Specific Networks (Internal)
Each service has its own internal network:
- `vault-network`
- `wikijs-network`
- `wordpress-network`
- `linkstack-network`
- `n8n-network`
- `mastodon-network`
- `mailu-network`
- `supabase-network`
- `adminer-network`
- `monitoring-network`
- `logging-network`
- `backup-network`

**Purpose:** Isolate service communication, allow database containers to be non-routable from outside.

### Network Flow

```
Internet → Traefik (80/443) → Service Containers
                ↓
         traefik-network
                ↓
    Service-specific networks
                ↓
        Database Containers
```

---

## Service Management

### Standard Service Structure

Every service follows this structure:

```
<service-name>/
├── docker-compose.yml    # Service definition
├── .env                  # Environment variables (secrets)
├── .env.example          # Template (if exists)
├── data/                 # Persistent data
│   ├── <service-data>/   # Application data
│   └── <db-data>/        # Database data (if applicable)
├── config/               # Configuration files (if needed)
├── scripts/              # Utility scripts (if needed)
└── README.md            # Service documentation
```

### Starting Services

#### Start Individual Service

```bash
cd /root/infra/<service-name>
docker compose up -d
```

#### Start All Running Services

```bash
cd /root/infra
for dir in traefik vault wikijs wordpress linkstack; do
  cd $dir && docker compose up -d && cd ..
done
```

**IMPORTANT:** Always start Traefik first!

#### Start with Dependencies

```bash
# Start Traefik first
cd /root/infra/traefik && docker compose up -d

# Start Vault and unseal
cd /root/infra/vault && docker compose up -d
docker compose exec vault /vault/scripts/unseal-vault.sh

# Start other services
cd /root/infra/wikijs && docker compose up -d
cd /root/infra/wordpress && docker compose up -d
cd /root/infra/linkstack && docker compose up -d
```

### Stopping Services

#### Stop Individual Service

```bash
cd /root/infra/<service-name>
docker compose down
```

#### Stop All Services

```bash
cd /root/infra
for dir in traefik vault wikijs wordpress linkstack; do
  cd $dir && docker compose down && cd ..
done
```

### Restarting Services

```bash
cd /root/infra/<service-name>
docker compose restart
```

**Note:** Vault requires unsealing after restart.

### Viewing Status

#### All Services

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

#### Specific Service

```bash
cd /root/infra/<service-name>
docker compose ps
```

#### Health Status

```bash
docker inspect <container-name> | jq '.[0].State.Health'
```

### Viewing Logs

#### Service Logs

```bash
cd /root/infra/<service-name>
docker compose logs -f
```

#### Recent Logs

```bash
docker compose logs --tail=100
```

#### Specific Container

```bash
docker logs -f <container-name>
```

### Updating Services

```bash
cd /root/infra/<service-name>
docker compose pull
docker compose up -d
docker compose logs -f  # Monitor startup
```

---

## Monitoring & Observability

### Prometheus

- **URL:** https://prometheus.freqkflag.co
- **Metrics Endpoint:** http://prometheus:9090/metrics
- **Configuration:** `/root/infra/monitoring/config/prometheus/prometheus.yml`
- **Data Retention:** 30 days
- **Scrapes:** Traefik, Node Exporter, Docker, databases, applications

### Grafana

- **URL:** https://grafana.freqkflag.co
- **Default User:** `admin` (password in `monitoring/.env`)
- **Datasources:**
  - Prometheus (metrics)
  - Loki (logs)
- **Dashboards:** Auto-provisioned from `monitoring/config/grafana/dashboards/`

### Node Exporter

- **Purpose:** Host system metrics
- **Port:** 9100
- **Metrics:** CPU, memory, disk, network

### Adding Service to Monitoring

1. Add Prometheus labels to service:
```yaml
labels:
  - "prometheus.io/scrape=true"
  - "prometheus.io/port=8080"
```

2. Add scrape config to `monitoring/config/prometheus/prometheus.yml`

3. Restart Prometheus:
```bash
cd /root/infra/monitoring
docker compose restart prometheus
```

---

## Logging

### Loki

- **URL:** https://loki.freqkflag.co
- **API:** http://loki:3100
- **Retention:** 30 days
- **Storage:** Filesystem (`./data/loki/`)

### Promtail

- **Purpose:** Collects logs from Docker containers
- **Configuration:** `/root/infra/logging/config/promtail/promtail-config.yml`
- **Sources:**
  - Docker container logs
  - System logs
  - Application logs

### Viewing Logs in Grafana

1. Go to Grafana: https://grafana.freqkflag.co
2. Click "Explore"
3. Select "Loki" datasource
4. Use LogQL queries:

```logql
# All logs from a service
{service="wikijs"}

# Logs from a container
{container="wikijs"}

# Logs containing error
{service="wordpress"} |= "error"

# Logs from a domain
{domain="cultofjoey.com"}
```

### Log Rotation

Configure Docker log rotation:

```bash
cd /root/infra/logging
./scripts/log-rotation.sh configure
sudo systemctl restart docker
```

---

## Backup & Recovery

### Automated Backups

**Location:** `/root/infra/backup/`

**Schedule:**
- **Daily:** All databases (PostgreSQL, MySQL)
- **Weekly:** Critical volumes (Monday)
- **Retention:** 30 days daily, 12 weeks weekly

**Run Backup:**

```bash
cd /root/infra/backup
docker compose run --rm backup
```

**Automated (Cron/Systemd):**

```bash
# Add to crontab
0 2 * * * cd /root/infra/backup && docker compose run --rm backup
```

### Backup Locations

- **Daily:** `/root/infra/backup/data/daily/`
- **Weekly:** `/root/infra/backup/data/weekly/`
- **Logs:** `/root/infra/backup/data/logs/`

### Restore Procedures

#### PostgreSQL

```bash
# Extract
gunzip <backup-file>.dump.gz

# Restore
docker exec -i <db-container> pg_restore \
  -U <user> -d <database> --clean < <backup-file>.dump
```

#### MySQL

```bash
# Extract
gunzip <backup-file>.sql.gz

# Restore
docker exec -i <db-container> mysql -u <user> -p <database> < <backup-file>.sql
```

#### Volume

```bash
# Extract
tar -xzf <volume-backup>.tar.gz -C /root/infra/<service>/
```

**See:** `runbooks/backup-restore.md` for detailed procedures.

---

## Security

### Container Security

All containers have:
- **Resource limits** (CPU/memory)
- **Security options** (`no-new-privileges:true`)
- **Health checks** for monitoring
- **Non-root users** where possible

### Network Security

- **Traefik** handles all external access
- **SSL/TLS** termination at Traefik
- **Security headers** via Traefik middleware
- **No direct port exposure** (except Traefik)

### Secrets Management

#### Vault (Production Mode)

- **5 unseal keys** (3 required to unseal)
- **Root token** for initial setup
- **Audit logging** enabled
- **Keys stored:** `/vault/init/keys.txt` (inside container)

**Unseal Keys:**
- Must be backed up securely
- Never commit to git
- Store in multiple secure locations
- Distribute to trusted individuals

#### Environment Variables

- **`.env` files** with 600 permissions
- **Never commit** secrets to git
- **Use Vault** for sensitive credentials
- **Rotate regularly**

### Image Security

**Vulnerability Scanning:**

```bash
cd /root/infra
./scripts/scan-images.sh
```

**Automated:** Weekly scans via GitHub Actions

**Policy:**
- **CRITICAL:** Patch within 24 hours
- **HIGH:** Patch within 7 days
- **MEDIUM:** Patch within 30 days

### Security Headers

Configured in Traefik:
- XSS Protection
- Content Type No-Sniff
- HSTS (1 year)
- Frame Options

**See:** `SECURITY.md` for complete security policies.

---

## CI/CD & Automation

### GitHub Actions Workflows

**Location:** `/root/infra/.github/workflows/`

#### CI Pipeline (`ci.yml`)
- Validates YAML syntax
- Validates docker-compose files
- Security scanning
- Tests configurations

#### Security Scan (`security-scan.yml`)
- Weekly Trivy scans
- Reports HIGH/CRITICAL vulnerabilities
- Uploads to GitHub Security

#### Deploy (`deploy.yml`)
- Validates configurations
- Runs security scans
- Prepares for deployment

#### Update Images (`update-images.yml`)
- Weekly image update checks
- Creates issues for review

### Local Scripts

**Location:** `/root/infra/scripts/`

- `scan-images.sh` - Trivy vulnerability scanning

---

## Development Environment

### DevContainer

**Location:** `/root/infra/.devcontainer/`

**Features:**
- VS Code integration
- Docker-in-Docker support
- Pre-installed tools
- Network access to all services

**Usage:**

```bash
code /root/infra
# Press F1 → "Dev Containers: Reopen in Container"
```

### Projects Directory

**Location:** `/root/infra/projects/`

**Contents:**
- Ghost theme development
- WordPress themes
- Design specifications
- Development archives

---

## Troubleshooting

### Service Won't Start

1. **Check logs:**
   ```bash
   docker compose logs <service>
   ```

2. **Verify health:**
   ```bash
   docker compose ps
   ```

3. **Check resources:**
   ```bash
   docker stats
   ```

4. **Verify network:**
   ```bash
   docker network ls
   docker network inspect traefik-network
   ```

5. **Check dependencies:**
   - Ensure Traefik is running
   - Ensure database is healthy (if applicable)

### High Resource Usage

1. **Check resource limits:**
   ```bash
   docker stats --no-stream
   ```

2. **Review service logs:**
   ```bash
   docker compose logs <service>
   ```

3. **Check for errors:**
   - Look for loops or leaks
   - Review application logs

4. **Adjust limits** in `docker-compose.yml` if needed

### Network Issues

1. **Verify Traefik:**
   ```bash
   docker ps | grep traefik
   docker logs traefik
   ```

2. **Check service labels:**
   ```bash
   docker inspect <container> | jq '.[0].Config.Labels'
   ```

3. **Verify SSL certificates:**
   ```bash
   docker logs traefik | grep -i certificate
   ```

4. **Check DNS:**
   - Verify domain points to server
   - Check Let's Encrypt challenge

### Database Issues

1. **Check database health:**
   ```bash
   docker compose ps <db-service>
   ```

2. **Verify connections:**
   - Check application logs
   - Test database connection

3. **Check disk space:**
   ```bash
   df -h
   ```

4. **Review database logs:**
   ```bash
   docker compose logs <db-service>
   ```

### Vault Issues

#### Vault Sealed

```bash
cd /root/infra/vault
docker compose exec vault /vault/scripts/unseal-vault.sh
```

#### Vault Not Initialized

```bash
cd /root/infra/vault
docker compose exec vault /vault/scripts/init-vault.sh
```

#### Cannot Connect

- Verify Vault is running: `docker ps | grep vault`
- Check Traefik routing
- Verify SSL certificate

**See:** `vault/README.md` and `VAULT_OPERATION_GUIDE.md`

---

## Operational Procedures

### Daily Operations

- [ ] Check service health
- [ ] Review critical logs
- [ ] Verify backups completed
- [ ] Check disk space
- [ ] Monitor resource usage

### Weekly Operations

- [ ] Review all service logs
- [ ] Check for security updates
- [ ] Verify backup integrity
- [ ] Review monitoring dashboards
- [ ] Update documentation

### Monthly Operations

- [ ] Update all Docker images
- [ ] Review security scan results
- [ ] Rotate secrets
- [ ] Capacity planning
- [ ] Performance review
- [ ] DR test (quarterly)

### Service Updates

1. **Backup first:**
   ```bash
   cd /root/infra/backup
   docker compose run --rm backup
   ```

2. **Update service:**
   ```bash
   cd /root/infra/<service>
   docker compose pull
   docker compose up -d
   ```

3. **Monitor:**
   ```bash
   docker compose logs -f
   ```

4. **Verify:**
   - Health checks passing
   - Service accessible
   - No errors in logs

### Emergency Procedures

**See:** `runbooks/incident-response.md`

**Quick Actions:**
1. Assess severity
2. Contain issue
3. Restore from backup if needed
4. Document incident
5. Post-mortem

---

## Quick Reference

### Essential Commands

```bash
# Service status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Start Traefik (first)
cd /root/infra/traefik && docker compose up -d

# Start Vault and unseal
cd /root/infra/vault && docker compose up -d
docker compose exec vault /vault/scripts/unseal-vault.sh

# View logs
docker compose logs -f

# Update service
docker compose pull && docker compose up -d

# Backup
cd /root/infra/backup && docker compose run --rm backup
```

### Service URLs

| Service | URL | Status |
|---------|-----|--------|
| WikiJS | https://wiki.freqkflag.co | ✅ |
| Vault | https://vault.freqkflag.co | ✅ |
| WordPress | https://cultofjoey.com | ✅ |
| LinkStack | https://link.cultofjoey.com | ✅ |
| Grafana | https://grafana.freqkflag.co | ⚙️ |
| Prometheus | https://prometheus.freqkflag.co | ⚙️ |
| n8n | https://n8n.freqkflag.co | ⚙️ |
| Mailu Admin | https://mail.freqkflag.co | ⚙️ |
| Mailu Webmail | https://webmail.freqkflag.co | ⚙️ |
| Supabase | https://supabase.freqkflag.co | ⚙️ |
| Adminer | https://adminer.freqkflag.co | ⚙️ |
| Node-RED | https://nodered.freqkflag.co | ⚙️ |
| Mastodon | https://twist3dkinkst3r.com | ⚙️ |

### File Locations

| Item | Location |
|------|----------|
| Service configs | `/root/infra/<service>/docker-compose.yml` |
| Environment vars | `/root/infra/<service>/.env` |
| Service data | `/root/infra/<service>/data/` |
| Backups | `/root/infra/backup/data/` |
| Logs | `/root/infra/<service>/logs/` or via Loki |
| Scripts | `/root/infra/scripts/` |
| Documentation | `/root/infra/*.md` |

### Environment Variables

**Vault:**
```bash
export VAULT_ADDR=https://vault.freqkflag.co
export VAULT_TOKEN=<root-token>
```

**Docker Compose:**
- Each service has its own `.env` file
- Never commit `.env` files to git
- Use `.env.example` as template

### Health Check Endpoints

| Service | Endpoint |
|---------|----------|
| Traefik | http://localhost:8080/ping |
| Vault | https://vault.freqkflag.co/v1/sys/health |
| Prometheus | http://prometheus:9090/-/healthy |
| Grafana | http://grafana:3000/api/health |
| Loki | http://loki:3100/ready |

---

## Documentation Index

### Core Documentation

- **[AGENTS.md](./AGENTS.md)** - Complete service catalog
- **[PREFERENCES.md](./PREFERENCES.md)** - AI interaction guidelines
- **[DOMAIN_ARCHITECTURE.md](./DOMAIN_ARCHITECTURE.md)** - Domain structure
- **[README.md](./README.md)** - Main infrastructure overview

### Operational Documentation

- **[OPERATIONAL_GUIDE.md](./OPERATIONAL_GUIDE.md)** - Day-to-day operations
- **[SECURITY.md](./SECURITY.md)** - Security policies
- **[DISASTER_RECOVERY.md](./DISASTER_RECOVERY.md)** - DR procedures
- **[VAULT_OPERATION_GUIDE.md](./VAULT_OPERATION_GUIDE.md)** - Vault usage

### Runbooks

- **[runbooks/incident-response.md](./runbooks/incident-response.md)** - Incident procedures
- **[runbooks/service-recovery.md](./runbooks/service-recovery.md)** - Service recovery
- **[runbooks/backup-restore.md](./runbooks/backup-restore.md)** - Backup/restore

### Service Documentation

Each service has its own `README.md`:
- `traefik/README.md`
- `vault/README.md`
- `wikijs/README.md`
- `wordpress/README.md`
- `linkstack/README.md`
- `n8n/README.md`
- `mailu/README.md`
- `supabase/README.md`
- `adminer/README.md`
- `mastadon/README.md`
- `monitoring/README.md`
- `logging/README.md`
- `backup/README.md`

---

## Maintenance Schedule

### Daily
- Service health checks
- Backup verification
- Log review

### Weekly
- Service log review
- Security scan review
- Backup integrity check
- Monitoring dashboard review

### Monthly
- Docker image updates
- Security audit
- Secret rotation
- Capacity planning
- Performance review

### Quarterly
- Disaster recovery test
- Full backup restore test
- Documentation review
- Architecture review

---

## Support & Resources

### Internal Resources

- **WikiJS:** https://wiki.freqkflag.co
- **Grafana:** https://grafana.freqkflag.co
- **Vault:** https://vault.freqkflag.co

### External Resources

- **Traefik Docs:** https://doc.traefik.io/traefik/
- **Vault Docs:** https://www.vaultproject.io/docs
- **Docker Docs:** https://docs.docker.com/
- **Docker Compose Docs:** https://docs.docker.com/compose/

### Emergency Contacts

- **Primary:** [Your contact]
- **Backup:** [Backup contact]
- **Hosting Provider:** [Provider support]

---

## Known Issues & Notes

### Vault Port Conflict

If Vault fails to start with "address already in use" error:

1. **Check for old containers:**
   ```bash
   docker ps -a | grep vault
   ```

2. **Stop and remove old containers:**
   ```bash
   docker stop $(docker ps -aq --filter "name=vault")
   docker rm $(docker ps -aq --filter "name=vault")
   ```

3. **Check for processes using port 8200:**
   ```bash
   lsof -i :8200
   ss -tlnp | grep 8200
   ```

4. **Restart Vault:**
   ```bash
   cd /root/infra/vault
   docker compose down
   docker compose up -d
   ```

### Vault Initialization

Vault must be initialized on first production start:

```bash
cd /root/infra/vault
docker compose exec vault /vault/scripts/init-vault.sh
```

Save the unseal keys and root token securely!

### Vault Unsealing

After each restart, Vault must be unsealed:

```bash
cd /root/infra/vault
docker compose exec vault /vault/scripts/unseal-vault.sh
```

---

## Version History

- **2025-11-20:** Initial cookbook creation
- **2025-11-20:** Infrastructure modernization completed
- **2025-11-20:** Vault production mode conversion
- **2025-11-20:** Comprehensive cookbook documentation

---

**This cookbook is your single source of truth for the VPS infrastructure. Keep it updated as the infrastructure evolves.**

