# WikiJS Runbook

**Service ID:** `wikijs`  
**Status:** running  
**Last Updated:** 2025-11-21

---

## Purpose

WikiJS is a modern, powerful, and extensible wiki software built on Node.js. It serves as the documentation and knowledge base for the infrastructure.

**Domain(s):** `wiki.freqkflag.co`  
**URL(s):** `https://wiki.freqkflag.co`

---

## Quick Reference

### Start Service
```bash
cd /root/infra/wikijs
docker compose up -d
```

### Stop Service
```bash
cd /root/infra/wikijs
docker compose down
```

### Restart Service
```bash
cd /root/infra/wikijs
docker compose restart wikijs
```

### View Logs
```bash
cd /root/infra/wikijs
docker compose logs -f wikijs
```

### Service Status
```bash
cd /root/infra/wikijs
docker compose ps
```

---

## Runme & Cursor Automation Hooks

- Tag runnable snippets with Runme metadata so Cursor can surface the dispatcher menu:
  ```markdown
  ```bash {"id":"wikijs-restart","runme":{"label":"Restart WikiJS","tags":["runbook","wikijs"]}}
  cd /root/infra/wikijs
  docker compose restart
  ```
  ```
- Each Runme cell should ultimately call a dispatcher (see `docs/runbooks/RUNME_INTEGRATION_PLAN.md`) that asks whether to run locally or ship commands to a fresh Cursor agent thread.

### AI Orchestration Prompts (copy/paste ready)

**Full Multi-Agent Sweep**
```
Use the Multi-Agent Orchestrator preset. Scope analysis to /root/infra/wikijs (WikiJS) first, then capture upstream dependencies from compose.orchestrator.yml. Return strict JSON with prioritized run actions plus any restart commands needed for WikiJS.
```

**Service Health Check**
```
Act as status_agent. Focus on /root/infra/wikijs and the wikijs containers. Confirm docker compose ps, health checks, and Traefik routing. Return strict JSON with health summary + restart recommendation.
```

**Targeted Operational Command**
```
Act as Deployment Runner. Execute the following commands for WikiJS at /root/infra/wikijs:
cd /root/infra/wikijs
docker compose up -d
Verify the service at https://wiki.freqkflag.co and capture logs if unhealthy.
```

---


## Health Checks

### Container Health
```bash
docker ps | grep wikijs
# Should show: Up X (healthy)
```

### Service Endpoint
```bash
curl -k -I https://wiki.freqkflag.co
# Expected: HTTP 200
```

### Database Connection
```bash
docker exec wikijs-db pg_isready -U wikijs
# Should return: wikijs-db:5432 - accepting connections
```

---

## Configuration

### Environment Variables
- Location: `/root/infra/wikijs/.env`
- Key variables:
  - `DB_TYPE` - Database type (postgres)
  - `DB_HOST` - Database host (wikijs-db)
  - `DB_PORT` - Database port (5432)
  - `DB_USER` - Database user
  - `DB_PASS` - Database password
  - `DB_NAME` - Database name (wiki)

### Docker Compose
- Location: `/root/infra/wikijs/docker-compose.yml`
- Networks: `wikijs-network`, `traefik-network`
- Volumes:
  - `./data/wiki` - Wiki content and uploads
  - `./data/postgres` - Database data

### Dependencies
- **Traefik** - Required for HTTPS routing
- **PostgreSQL** - Embedded database (wikijs-db container)

---

## Common Issues & Fixes

### Issue: Wiki Not Accessible
**Symptoms:** 404 or connection refused
**Cause:** Traefik routing issue or container not running
**Fix:**
```bash
# Check container status
docker compose ps

# Check Traefik routing
docker logs traefik | grep wiki.freqkflag.co

# Verify DNS
nslookup wiki.freqkflag.co

# Restart service
docker compose restart wikijs
```

### Issue: Database Connection Failed
**Symptoms:** Wiki shows database error on startup
**Cause:** Database container not running or wrong credentials
**Fix:**
```bash
# Check database container
docker compose ps wikijs-db

# Check database logs
docker compose logs wikijs-db

# Verify credentials in .env
cat .env | grep DB_

# Restart database
docker compose restart wikijs-db
```

### Issue: Container Won't Start
**Symptoms:** Container exits immediately
**Diagnosis:**
```bash
cd /root/infra/wikijs
docker compose logs --tail=50 wikijs
```

**Common Causes:**
- Missing .env file
- Database not ready
- Port conflicts
- Volume permission issues

**Fix:**
```bash
# Check if .env exists
ls -la .env

# Wait for database to be ready
docker compose up -d wikijs-db
sleep 10

# Check logs
docker compose logs wikijs

# Restart
docker compose up -d
```

---

## Backup & Restore

### Backup
```bash
# Backup wiki content
tar -czf wikijs-content-backup-$(date +%Y%m%d).tar.gz \
  /root/infra/wikijs/data/wiki

# Backup database
docker exec wikijs-db pg_dump -U wikijs wiki > wikijs-db-backup-$(date +%Y%m%d).sql

# Combined backup
tar -czf wikijs-full-backup-$(date +%Y%m%d).tar.gz \
  /root/infra/wikijs/data/wiki \
  wikijs-db-backup-*.sql
```

### Restore
```bash
# Restore wiki content
tar -xzf wikijs-content-backup-YYYYMMDD.tar.gz -C /

# Restore database
docker exec -i wikijs-db psql -U wikijs wiki < wikijs-db-backup-YYYYMMDD.sql

# Restart service
docker compose restart wikijs
```

### Backup Schedule
- **Frequency:** Daily
- **Retention:** 30 days
- **Location:** `/root/.backup/wikijs/`

---

## Updates & Maintenance

### Update Service
```bash
cd /root/infra/wikijs
docker compose pull
docker compose up -d
```

### Update Configuration
1. Edit `.env` file
2. Restart service: `docker compose restart wikijs`
3. Verify: Visit `https://wiki.freqkflag.co`

### Maintenance Window
- **Recommended:** Low-traffic hours
- **Downtime:** ~1 minute (restart time)
- **Impact:** Wiki temporarily unavailable

---

## Monitoring

### Key Metrics
- **Page views:** Check WikiJS admin panel
- **Database size:** `docker exec wikijs-db psql -U wikijs -c "SELECT pg_size_pretty(pg_database_size('wiki'));"`
- **Disk usage:** `du -sh /root/infra/wikijs/data`

### Log Locations
- Container logs: `docker compose logs wikijs`
- Application logs: Available in WikiJS admin panel
- Database logs: `docker compose logs wikijs-db`

---

## Troubleshooting

### Service Not Accessible
1. Check container status: `docker compose ps`
2. Check Traefik routing: `docker logs traefik | grep wiki`
3. Check DNS: `nslookup wiki.freqkflag.co`
4. Check SSL: `curl -vI https://wiki.freqkflag.co`

### Database Connection Issues
1. Verify database container is running: `docker compose ps wikijs-db`
2. Check connection string in `.env`
3. Test connection: `docker exec wikijs-db psql -U wikijs -d wiki -c "SELECT 1;"`

### Performance Issues
1. Check resource usage: `docker stats wikijs wikijs-db`
2. Review logs for errors: `docker compose logs --tail=100`
3. Check disk space: `df -h`

---

## Security

### Access Control
- Admin access via web UI
- User management in WikiJS admin panel
- Authentication configured in WikiJS settings

### Secrets Management
- Database credentials in `.env` file (600 permissions)
- Consider moving to Infisical for production

### Network Security
- Exposed via Traefik only (HTTPS)
- No direct port exposure
- Database internal only

---

## Related Documentation

- [WikiJS README](../wikijs/README.md)
- [Infrastructure Cookbook](../INFRASTRUCTURE_COOKBOOK.md)
- [Service Registry](../SERVICES.yml)

---

## Emergency Contacts

- **Critical:** WikiJS failure affects documentation access
- **Recovery:** Usually resolved by restart
- **Data Loss:** Check backups in `/root/.backup/wikijs/`

---

**Last Updated:** 2025-11-21  
**Maintained By:** Infrastructure Team

