# Supabase Runbook

**Service ID:** `supabase`  
**Status:** configured  
**Last Updated:** 2025-11-21

---

## Purpose

[Brief description of what this service does and why it exists in the infrastructure]

**Domain(s):** supabase.freqkflag.co  
**URL(s):** https://supabase.freqkflag.co

---

## Quick Reference

### Start Service
```bash
cd /root/infra/supabase
docker compose up -d
```

### Stop Service
```bash
cd /root/infra/supabase
docker compose down
```

### Restart Service
```bash
cd /root/infra/supabase
docker compose restart
```

### View Logs
```bash
cd /root/infra/supabase
docker compose logs -f
```

### Service Status
```bash
cd /root/infra/supabase
docker compose ps
```

---

## Runme & Cursor Automation Hooks

- Tag runnable snippets with Runme metadata so Cursor can surface the dispatcher menu:
  ```markdown
  ```bash {"id":"supabase-restart","runme":{"label":"Restart Supabase","tags":["runbook","supabase"]}}
  cd /root/infra/supabase
  docker compose restart
  ```
  ```
- Each Runme cell should ultimately call a dispatcher (see `docs/runbooks/RUNME_INTEGRATION_PLAN.md`) that asks whether to run locally or ship commands to a fresh Cursor agent thread.

### AI Orchestration Prompts (copy/paste ready)

**Full Multi-Agent Sweep**
```
Use the Multi-Agent Orchestrator preset. Scope analysis to /root/infra/supabase (Supabase) first, then capture upstream dependencies from compose.orchestrator.yml. Return strict JSON with prioritized run actions plus any restart commands needed for Supabase.
```

**Service Health Check**
```
Act as status_agent. Focus on /root/infra/supabase and the supabase containers. Confirm docker compose ps, health checks, and Traefik routing. Return strict JSON with health summary + restart recommendation.
```

**Targeted Operational Command**
```
Act as Deployment Runner. Execute the following commands for Supabase at /root/infra/supabase:
cd /root/infra/supabase
docker compose up -d
Verify the service at https://supabase.freqkflag.co and capture logs if unhealthy.
```

---


## Health Checks

### Container Health
```bash
docker ps | grep supabase
# Should show: Up X (healthy)
```

### Service Endpoint
```bash
curl -k https://[service-domain]
# Expected: HTTP 200 or appropriate response
```

### Internal Health Check
```bash
docker exec supabase [health-check-command]
```

---

## Configuration

### Environment Variables
- Location: `/root/infra/supabase/.env`
- Key variables:
  - `[VAR1]` - [description]
  - `[VAR2]` - [description]

### Docker Compose
- Location: `/root/infra/supabase/docker-compose.yml`
- Networks: traefik-network (external)
- Volumes: Service-specific data volumes
- Ports: Via Traefik (HTTPS)

### Dependencies
- traefik, postgres - Required for service operation
- [Dependency 2] - Required for service operation

---

## Common Issues & Fixes

### Issue: [Common Problem 1]
**Symptoms:** [What you see]
**Cause:** [Why it happens]
**Fix:**
```bash
[exact commands to fix]
```

### Issue: [Common Problem 2]
**Symptoms:** [What you see]
**Cause:** [Why it happens]
**Fix:**
```bash
[exact commands to fix]
```

### Issue: Container Won't Start
**Symptoms:** Container exits immediately or restarts in loop
**Diagnosis:**
```bash
cd /root/infra/supabase
docker compose logs --tail=50
```

**Common Causes:**
- Missing environment variables
- Port conflicts
- Volume permission issues
- Database connection failures

**Fix:**
```bash
# Check logs first
docker compose logs

# Verify .env file exists and has required variables
cat .env

# Check for port conflicts
netstat -tuln | grep [port]

# Restart with fresh state (if safe)
docker compose down -v
docker compose up -d
```

---

## Backup & Restore

### Backup
```bash
# Backup data directory
tar -czf supabase-backup-$(date +%Y%m%d).tar.gz \
  /root/infra/supabase/data

# Backup database (if applicable)
docker exec [db-container] pg_dump -U [user] [database] > backup.sql
```

### Restore
```bash
# Restore data directory
tar -xzf supabase-backup-YYYYMMDD.tar.gz -C /

# Restore database (if applicable)
docker exec -i [db-container] psql -U [user] [database] < backup.sql
```

### Backup Schedule
- **Frequency:** [daily|weekly|monthly]
- **Retention:** [X days|weeks|months]
- **Location:** [backup-location]

---

## Updates & Maintenance

### Update Service
```bash
cd /root/infra/supabase
docker compose pull
docker compose up -d
```

### Update Configuration
1. Edit `.env` or `docker-compose.yml`
2. Restart service: `docker compose restart`
3. Verify: `docker compose ps`

### Maintenance Window
- **Recommended:** [time/day]
- **Downtime:** [estimated downtime]
- **Impact:** [affected services/users]

---

## Monitoring

### Key Metrics
- [Metric 1]: [how to check]
- [Metric 2]: [how to check]

### Log Locations
- Container logs: `docker compose logs`
- Application logs: `/root/infra/supabase/data/logs/`
- System logs: `journalctl -u docker`

### Alerts
- [Alert condition 1]: [action]
- [Alert condition 2]: [action]

---

## Troubleshooting

### Service Not Accessible
1. Check container status: `docker compose ps`
2. Check Traefik routing: `docker logs traefik | grep [service]`
3. Check DNS: `nslookup [service-domain]`
4. Check SSL: `curl -vI https://[service-domain]`

### Database Connection Issues
1. Verify database container is running
2. Check connection string in `.env`
3. Test connection: `docker exec [db-container] psql -U [user] -d [db]`

### Performance Issues
1. Check resource usage: `docker stats supabase`
2. Review logs for errors: `docker compose logs --tail=100`
3. Check disk space: `df -h`

---

## Security

### Access Control
- [Who has access]
- [How to grant/revoke access]

### Secrets Management
- Secrets stored in: [location]
- Managed by: [Infisical|.env file]
- Rotation: [frequency]

### Network Security
- Exposed ports: Via Traefik (HTTPS)
- Internal only: [yes|no]
- Firewall rules: [rules]

---

## Related Documentation

- [Service README](../supabase/README.md)
- [Infrastructure Cookbook](../INFRASTRUCTURE_COOKBOOK.md)
- [Service Registry](../SERVICES.yml)

---

## Emergency Contacts

- **On-Call:** [contact]
- **Escalation:** [contact]
- **Documentation:** [links]

---

**Last Updated:** 2025-11-21  
**Maintained By:** [team/person]

