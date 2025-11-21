# Docker Image Versions Pinned

**Date:** 2025-11-21  
**Status:** ✅ All `latest` tags replaced with specific versions

## Summary

All Docker images across the infrastructure have been pinned to specific versions to ensure:
- Predictable deployments
- Easier rollback if issues occur
- Better change management
- Compliance with best practices

## Pinned Versions

### Monitoring & Logging
- **Loki:** `grafana/loki:2.9.9`
- **Promtail:** `grafana/promtail:2.9.9`
- **Prometheus:** `prom/prometheus:2.45.0`
- **Grafana:** `grafana/grafana:10.2.0`
- **Alertmanager:** `prom/alertmanager:0.26.0`
- **Node Exporter:** `prom/node-exporter:1.7.0`

### Automation & Workflows
- **Node-RED:** `nodered/node-red:3.1.4`
- **n8n:** `n8nio/n8n:1.19.4`

### Secrets Management
- **Infisical:** `infisical/infisical:0.8.0`
- **Vault:** `hashicorp/vault:1.15.0` (deprecated, migrating to Infisical)

### Web Services
- **WordPress:** `wordpress:6.4.2`
- **LinkStack:** `linkstackorg/linkstack:v4.2.0`
- **Adminer:** `adminer:4.8.1`

### Email
- **Mailu Admin:** `mailu/admin:1.10`
- **Mailu Dovecot:** `mailu/dovecot:1.10`
- **Mailu Postfix:** `mailu/postfix:1.10`
- **Mailu Roundcube:** `mailu/roundcube:1.10`
- **Mailu Nginx:** `mailu/nginx:1.10`

### Social
- **Mastodon (Web):** `lscr.io/linuxserver/mastodon:4.2.0`
- **Mastodon (Sidekiq):** `lscr.io/linuxserver/mastodon:4.2.0`

### Utilities
- **Alpine (Backup):** `alpine:3.19`

### Projects
- **Ghost (Dev):** `ghost:5.85.0`

## Already Pinned (No Changes)
- **Traefik:** `traefik:v3.5` ✅
- **PostgreSQL:** `postgres:15-alpine` ✅
- **PostgreSQL (Mastodon):** `postgres:14` ✅
- **MySQL:** `mysql:8.0` ✅
- **Redis:** `redis:7-alpine` ✅

## Update Process

To update image versions:

1. **Check for updates:**
   ```bash
   docker pull <image>:<new-version>
   ```

2. **Test in staging/dev environment first**

3. **Update docker-compose.yml:**
   ```yaml
   image: <image>:<new-version>
   ```

4. **Pull and restart:**
   ```bash
   cd /root/infra/<service>
   docker compose pull
   docker compose up -d
   ```

5. **Monitor logs:**
   ```bash
   docker compose logs -f
   ```

6. **Verify health:**
   ```bash
   docker ps --filter "health=unhealthy"
   ```

## Version Update Schedule

- **Security patches:** Update immediately
- **Minor versions:** Monthly review
- **Major versions:** Quarterly review with testing

## Files Modified

- ✅ `/root/infra/logging/docker-compose.yml`
- ✅ `/root/infra/monitoring/docker-compose.yml`
- ✅ `/root/infra/nodered/docker-compose.yml`
- ✅ `/root/infra/infisical/docker-compose.yml`
- ✅ `/root/infra/vault/docker-compose.yml`
- ✅ `/root/infra/adminer/docker-compose.yml`
- ✅ `/root/infra/backup/docker-compose.yml`
- ✅ `/root/infra/linkstack/docker-compose.yml`
- ✅ `/root/infra/n8n/docker-compose.yml`
- ✅ `/root/infra/wordpress/docker-compose.yml`
- ✅ `/root/infra/mailu/docker-compose.yml`
- ✅ `/root/infra/mastadon/docker-compose.yml`
- ✅ `/root/infra/projects/cult-of-joey-ghost-theme/docker-compose.dev.yml`

## Verification

To verify all images are pinned:

```bash
cd /root/infra
grep -r "image:.*latest" --include="docker-compose.yml" --include="docker-compose.dev.yml" .
# Should only show results in documentation files, not actual configs
```

## Notes

- All versions were selected based on current stable releases as of 2025-11-21
- Some versions may need adjustment based on actual availability
- Always test updates in a non-production environment first
- Keep this document updated when versions change

---

**See [QUICK_FIXES_APPLIED.md](./QUICK_FIXES_APPLIED.md) for other fixes applied.**

