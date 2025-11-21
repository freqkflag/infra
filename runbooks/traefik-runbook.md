# Traefik Runbook

**Service ID:** `traefik`  
**Status:** running  
**Last Updated:** 2025-11-21

---

## Purpose

Traefik is the reverse proxy and SSL termination layer for all services. It provides automatic SSL certificates via Let's Encrypt, HTTP to HTTPS redirects, security headers, and service discovery via Docker labels.

**Domain(s):** `traefik.localhost` (dashboard)  
**URL(s):** 
- Dashboard: `http://localhost:8080`
- All services via HTTPS on their respective domains

---

## Quick Reference

### Start Service
```bash
cd /root/infra/traefik
docker compose up -d
```

### Stop Service
```bash
cd /root/infra/traefik
docker compose down
```

### Restart Service
```bash
cd /root/infra/traefik
docker compose restart traefik
```

### View Logs
```bash
cd /root/infra/traefik
docker compose logs -f traefik
```

### Service Status
```bash
cd /root/infra/traefik
docker compose ps
```

---

## Health Checks

### Container Health
```bash
docker ps | grep traefik
# Should show: Up X (healthy)
```

### Service Endpoint
```bash
curl -I http://localhost:8080
# Expected: HTTP 200
```

### Dashboard Access
```bash
curl http://localhost:8080/api/overview
# Should return JSON with service overview
```

---

## Configuration

### Environment Variables
- Location: `/root/infra/traefik/.env`
- Key variables:
  - `TRAEFIK_EMAIL` - Email for Let's Encrypt certificates

### Docker Compose
- Location: `/root/infra/traefik/docker-compose.yml`
- Networks: `traefik-network` (external, created by Traefik)
- Volumes:
  - `./config/traefik.yml` - Static configuration
  - `./dynamic/` - Dynamic configuration (middlewares)
  - `./acme/acme.json` - SSL certificates (600 permissions)

### Ports
- `80` - HTTP (redirects to HTTPS)
- `443` - HTTPS
- `8080` - Dashboard (internal only)

### Dependencies
- None (Traefik is the foundation service)

---

## Common Issues & Fixes

### Issue: SSL Certificate Not Generated
**Symptoms:** Services show SSL errors, certificates not created
**Cause:** Let's Encrypt rate limits, DNS not propagated, or email not set
**Fix:**
```bash
# Check Let's Encrypt logs
docker logs traefik | grep -i acme

# Verify DNS is pointing to server
nslookup your-domain.com

# Check acme.json permissions
ls -la /root/infra/traefik/acme/acme.json
chmod 600 /root/infra/traefik/acme/acme.json

# Restart Traefik
docker compose restart traefik
```

### Issue: Service Not Accessible via Traefik
**Symptoms:** Service container running but 404 from Traefik
**Cause:** Missing Traefik labels, wrong network, or service not on traefik-network
**Fix:**
```bash
# Check if service is on traefik-network
docker network inspect traefik-network | grep <service-name>

# Verify Traefik labels in docker-compose.yml
grep -A 10 "traefik.enable" /root/infra/<service>/docker-compose.yml

# Check Traefik logs for routing errors
docker logs traefik | grep <service-domain>
```

### Issue: Container Won't Start
**Symptoms:** Container exits immediately or restarts in loop
**Diagnosis:**
```bash
cd /root/infra/traefik
docker compose logs --tail=50
```

**Common Causes:**
- Port 80/443 already in use
- Invalid configuration file syntax
- Missing acme.json file

**Fix:**
```bash
# Check for port conflicts
netstat -tuln | grep -E ':80|:443'

# Validate configuration
docker compose config

# Create acme.json if missing
touch acme/acme.json
chmod 600 acme/acme.json

# Restart
docker compose up -d
```

---

## Backup & Restore

### Backup
```bash
# Backup configuration
tar -czf traefik-backup-$(date +%Y%m%d).tar.gz \
  /root/infra/traefik/config \
  /root/infra/traefik/dynamic \
  /root/infra/traefik/acme/acme.json

# Backup is critical - contains all SSL certificates
```

### Restore
```bash
# Restore configuration
tar -xzf traefik-backup-YYYYMMDD.tar.gz -C /

# Restart Traefik
cd /root/infra/traefik
docker compose restart traefik
```

### Backup Schedule
- **Frequency:** Weekly
- **Retention:** 12 weeks
- **Location:** `/root/.backup/traefik/`

---

## Updates & Maintenance

### Update Service
```bash
cd /root/infra/traefik
docker compose pull
docker compose up -d
```

### Update Configuration
1. Edit `config/traefik.yml` or `dynamic/*.yml`
2. Restart service: `docker compose restart traefik`
3. Verify: `docker compose ps` and check dashboard

### Maintenance Window
- **Recommended:** Low-traffic hours
- **Downtime:** ~30 seconds (restart time)
- **Impact:** All services briefly unavailable during restart

---

## Monitoring

### Key Metrics
- **Request rate:** Check dashboard at `http://localhost:8080`
- **SSL certificate expiry:** Check dashboard or `acme/acme.json`
- **Error rate:** `docker logs traefik | grep -i error`

### Log Locations
- Container logs: `docker compose logs traefik`
- Access logs: Available via dashboard

### Alerts
- **High error rate:** Check service health
- **Certificate expiry:** Let's Encrypt auto-renews, but monitor

---

## Troubleshooting

### Service Not Accessible
1. Check container status: `docker compose ps`
2. Check port binding: `netstat -tuln | grep -E ':80|:443'`
3. Check logs: `docker compose logs traefik --tail=100`
4. Check dashboard: `curl http://localhost:8080`

### SSL Certificate Issues
1. Check Let's Encrypt logs: `docker logs traefik | grep acme`
2. Verify DNS: `nslookup your-domain.com`
3. Check rate limits: Let's Encrypt has rate limits (50/week/domain)
4. Check acme.json: `ls -la acme/acme.json` (should be 600)

### Routing Issues
1. Check service labels: `docker inspect <service-container> | grep -i traefik`
2. Check network: `docker network inspect traefik-network`
3. Check Traefik logs: `docker logs traefik | grep <domain>`

---

## Security

### Access Control
- Dashboard is internal only (localhost:8080)
- No external access to dashboard
- All services use HTTPS via Traefik

### Secrets Management
- Let's Encrypt certificates stored in `acme/acme.json` (600 permissions)
- Email for certificates in `.env` file

### Network Security
- Exposed ports: 80, 443 (required for web traffic)
- Dashboard: 8080 (internal only)
- All traffic encrypted via HTTPS

---

## Related Documentation

- [Traefik README](../traefik/README.md)
- [Infrastructure Cookbook](../INFRASTRUCTURE_COOKBOOK.md)
- [Service Registry](../SERVICES.yml)

---

## Emergency Contacts

- **Critical:** Traefik failure affects all services
- **Recovery:** Restart usually resolves most issues
- **Escalation:** Check service logs and Traefik logs

---

**Last Updated:** 2025-11-21  
**Maintained By:** Infrastructure Team

