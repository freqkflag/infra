# Rate Limiting & Dashboard Security Applied

**Date:** 2025-11-21  
**Status:** ✅ Complete

## Summary

Rate limiting has been applied to all services, and the Traefik dashboard has been secured with basic authentication.

---

## Rate Limiting Configuration

### Middleware Definitions

Two rate limiting middlewares are configured in `traefik/dynamic/middlewares.yml`:

1. **`rate-limit`** (Standard)
   - Average: 100 requests/minute
   - Burst: 50 requests
   - Period: 1 minute
   - Applied to: Public-facing services

2. **`rate-limit-strict`** (Sensitive)
   - Average: 10 requests/minute
   - Burst: 5 requests
   - Period: 1 minute
   - Applied to: Admin/authentication endpoints

---

## Services with Rate Limiting Applied

### Strict Rate Limiting (10 req/min)

Applied to sensitive/admin services:

- ✅ **adminer** - Database management tool
- ✅ **infisical** - Secrets management
- ✅ **n8n** - Workflow automation (has built-in auth)
- ✅ **ops** - Control plane
- ✅ **vault** - Secrets management (deprecated, migrating to Infisical)
- ✅ **grafana** - Monitoring dashboards
- ✅ **prometheus** - Metrics collection
- ✅ **alertmanager** - Alert management
- ✅ **mailu-admin** - Email admin panel

### Standard Rate Limiting (100 req/min)

Applied to public-facing services:

- ✅ **wordpress** - Main website
- ✅ **linkstack** - Link-in-bio page
- ✅ **wikijs** - Documentation
- ✅ **nodered** - Flow automation
- ✅ **loki** - Log aggregation
- ✅ **mailu-webmail** - Webmail interface
- ✅ **mailu-front** - Mail frontend
- ✅ **mastodon** - Social instance
- ✅ **supabase-studio** - Database studio
- ✅ **supabase-api** - API endpoint

---

## Traefik Dashboard Security

### Changes Applied

1. **Basic Authentication Added**
   - Middleware: `traefik-dashboard-auth`
   - Location: `traefik/dynamic/middlewares.yml`
   - Default credentials: `admin:changeme`
   - **⚠️ IMPORTANT: Change the password!**

2. **Insecure Mode Disabled**
   - `traefik/config/traefik.yml`: `insecure: false`
   - Dashboard now requires authentication

3. **HTTPS Enabled**
   - Dashboard router moved to `websecure` entrypoint
   - TLS certificate via Let's Encrypt
   - Security headers applied

4. **Strict Rate Limiting**
   - Dashboard protected with `rate-limit-strict` middleware

### Accessing the Dashboard

**Before:** `http://localhost:8080` (no auth)  
**After:** `https://traefik.localhost` (requires basic auth)

**Default Credentials:**
- Username: `admin`
- Password: `changeme`

**⚠️ Change the password immediately:**

```bash
# Generate new password hash
docker run --rm httpd:2.4-alpine htpasswd -nbB admin YOUR_NEW_PASSWORD

# Update traefik/dynamic/middlewares.yml
# Replace the hash in traefik-dashboard-auth.users
```

---

## Files Modified

### Rate Limiting
- ✅ `/root/infra/adminer/docker-compose.yml`
- ✅ `/root/infra/infisical/docker-compose.yml`
- ✅ `/root/infra/n8n/docker-compose.yml`
- ✅ `/root/infra/ops/docker-compose.yml`
- ✅ `/root/infra/vault/docker-compose.yml`
- ✅ `/root/infra/monitoring/docker-compose.yml` (grafana, prometheus, alertmanager)
- ✅ `/root/infra/wordpress/docker-compose.yml`
- ✅ `/root/infra/linkstack/docker-compose.yml`
- ✅ `/root/infra/wikijs/docker-compose.yml`
- ✅ `/root/infra/nodered/docker-compose.yml`
- ✅ `/root/infra/logging/docker-compose.yml` (loki)
- ✅ `/root/infra/mailu/docker-compose.yml` (admin, webmail, front)
- ✅ `/root/infra/mastadon/docker-compose.yml`
- ✅ `/root/infra/supabase/docker-compose.yml` (studio, api)

### Dashboard Security
- ✅ `/root/infra/traefik/dynamic/middlewares.yml` - Added basic auth middleware
- ✅ `/root/infra/traefik/config/traefik.yml` - Disabled insecure mode
- ✅ `/root/infra/traefik/docker-compose.yml` - Added auth middleware and HTTPS

---

## Verification

### Check Rate Limiting Middleware
```bash
docker exec traefik cat /etc/traefik/dynamic/middlewares.yml | grep -A 5 rate-limit
```

### Check Dashboard Auth
```bash
docker exec traefik cat /etc/traefik/dynamic/middlewares.yml | grep -A 3 traefik-dashboard-auth
```

### Test Dashboard Access
```bash
# Should require authentication
curl -I https://traefik.localhost

# With credentials
curl -u admin:changeme -I https://traefik.localhost
```

### Check Service Labels
```bash
# Verify rate limiting is applied
docker inspect <container-name> | grep -A 2 middlewares
```

---

## Next Steps

### Immediate
1. **Change Traefik dashboard password** (see instructions above)
2. **Restart services** to apply rate limiting (if not already running):
   ```bash
   cd /root/infra
   for dir in adminer infisical n8n ops vault monitoring wordpress linkstack wikijs nodered logging mailu mastadon supabase; do
     cd $dir && docker compose up -d && cd ..
   done
   ```

### This Week
3. **Monitor rate limiting** - Check logs for rate limit hits
4. **Adjust limits** if needed based on actual traffic patterns
5. **Document password** in secure location (Infisical)

---

## Notes

- Rate limiting is applied via Traefik middleware chains
- Middleware order: `security-headers@file,rate-limit@file` or `security-headers@file,rate-limit-strict@file`
- Services need to be restarted to pick up new labels
- Rate limiting counters are per-IP by default
- Dashboard password hash uses bcrypt (secure)

---

**See [QUICK_FIXES_APPLIED.md](./QUICK_FIXES_APPLIED.md) for other security fixes.**

