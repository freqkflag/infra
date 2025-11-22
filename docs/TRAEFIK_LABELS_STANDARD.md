# Traefik Labels Standard

**Created:** 2025-11-22  
**Last Updated:** 2025-11-22  
**Status:** Active Documentation

---

## Overview

This document defines the standard Traefik label patterns used across all services in the infrastructure. It provides templates and examples for consistent routing configuration.

---

## Standard Label Patterns

### Basic HTTP Service

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.<service>.rule=Host(`<domain>`)"
  - "traefik.http.routers.<service>.entrypoints=websecure"
  - "traefik.http.routers.<service>.tls.certresolver=letsencrypt"
  - "traefik.http.services.<service>.loadbalancer.server.port=<port>"
  - "traefik.http.routers.<service>.middlewares=secure-headers@file"
```

### Variables

- `<service>` - Service name (e.g., `wikijs`, `wordpress`, `n8n`)
- `<domain>` - Full domain name (e.g., `wiki.freqkflag.co`, `cultofjoey.com`)
- `<port>` - Service port (e.g., `3000`, `80`, `8080`)

---

## Middleware Patterns

### Public Services (Default)

Use `secure-headers@file` middleware for public-facing services:

```yaml
- "traefik.http.routers.<service>.middlewares=secure-headers@file"
```

**Applies to:**
- Public websites (WordPress, Ghost, etc.)
- Documentation (WikiJS)
- Public APIs

### Admin Services (Basic Auth)

Use `traefik-auth` middleware for admin/internal services:

```yaml
- "traefik.http.routers.<service>.middlewares=traefik-auth,secure-headers@file"
- "traefik.http.middlewares.traefik-auth.basicauth.users=${TRAEFIK_DASHBOARD_USERS}"
```

**Applies to:**
- Adminer (database management)
- Traefik dashboard
- Other admin interfaces

**Note:** `TRAEFIK_DASHBOARD_USERS` format: `username:$$apr1$$hash$$hash` (htpasswd format)

### Cloudflare Access Protected Services

Use `cf-access@file` middleware for Cloudflare Access protected services:

```yaml
- "traefik.http.routers.<service>.middlewares=cf-access@file"
```

**Applies to:**
- n8n (workflow automation)
- Node-RED (flow automation)
- Internal tools requiring Cloudflare Access

---

## Complete Examples

### Example 1: WikiJS (Public Service)

```yaml
services:
  wikijs:
    image: requarks/wiki:2.5
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.wikijs.rule=Host(`wiki.freqkflag.co`)"
      - "traefik.http.routers.wikijs.entrypoints=websecure"
      - "traefik.http.routers.wikijs.tls.certresolver=letsencrypt"
      - "traefik.http.services.wikijs.loadbalancer.server.port=3000"
      - "traefik.http.routers.wikijs.middlewares=secure-headers@file"
```

### Example 2: Adminer (Admin Service with Basic Auth)

```yaml
services:
  adminer:
    image: adminer:latest
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.adminer.rule=Host(`adminer.freqkflag.co`)"
      - "traefik.http.routers.adminer.entrypoints=websecure"
      - "traefik.http.routers.adminer.tls.certresolver=letsencrypt"
      - "traefik.http.services.adminer.loadbalancer.server.port=8080"
      - "traefik.http.routers.adminer.middlewares=traefik-auth,secure-headers@file"
      - "traefik.http.middlewares.traefik-auth.basicauth.users=${TRAEFIK_DASHBOARD_USERS}"
```

### Example 3: n8n (Cloudflare Access Protected)

```yaml
services:
  n8n:
    image: n8nio/n8n:latest
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.n8n.rule=Host(`n8n.freqkflag.co`)"
      - "traefik.http.routers.n8n.entrypoints=websecure"
      - "traefik.http.routers.n8n.tls.certresolver=letsencrypt"
      - "traefik.http.services.n8n.loadbalancer.server.port=5678"
      - "traefik.http.routers.n8n.middlewares=cf-access@file"
```

### Example 4: WordPress (Public Service on Custom Domain)

```yaml
services:
  wordpress:
    image: wordpress:latest
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.wordpress.rule=Host(`cultofjoey.com`)"
      - "traefik.http.routers.wordpress.entrypoints=websecure"
      - "traefik.http.routers.wordpress.tls.certresolver=letsencrypt"
      - "traefik.http.services.wordpress.loadbalancer.server.port=80"
      - "traefik.http.routers.wordpress.middlewares=secure-headers@file"
```

---

## Label Reference

### Required Labels

| Label | Description | Example |
|-------|-------------|---------|
| `traefik.enable` | Enable Traefik for this service | `true` |
| `traefik.http.routers.<service>.rule` | Host routing rule | `Host(\`wiki.freqkflag.co\`)` |
| `traefik.http.routers.<service>.entrypoints` | Entry point | `websecure` |
| `traefik.http.routers.<service>.tls.certresolver` | Certificate resolver | `letsencrypt` |
| `traefik.http.services.<service>.loadbalancer.server.port` | Service port | `3000` |

### Optional Labels

| Label | Description | Example |
|-------|-------------|---------|
| `traefik.http.routers.<service>.middlewares` | Middleware chain | `secure-headers@file` |
| `traefik.http.middlewares.<name>.basicauth.users` | Basic auth users | `${TRAEFIK_DASHBOARD_USERS}` |

---

## Best Practices

### ✅ DO

1. **Always use `websecure` entrypoint** for HTTPS services
2. **Always use `letsencrypt` cert resolver** for automatic SSL
3. **Use `secure-headers@file`** for public services
4. **Use descriptive service names** in router labels
5. **Reference environment variables** for domains and ports
6. **Use consistent naming** (service name matches router name)

### ❌ DON'T

1. **Don't use `web` entrypoint** (HTTP only, redirects to HTTPS)
2. **Don't hardcode domains** (use environment variables)
3. **Don't skip TLS** (always use `letsencrypt`)
4. **Don't mix middleware patterns** (choose one: public, admin, or cf-access)
5. **Don't use inconsistent service names** (keep router and service names aligned)

---

## Template Usage

### Using YAML Anchors (Recommended)

```yaml
x-traefik-labels: &traefik-labels
  - "traefik.enable=true"
  - "traefik.http.routers.wikijs.rule=Host(`${WIKIJS_DOMAIN}`)"
  - "traefik.http.routers.wikijs.entrypoints=websecure"
  - "traefik.http.routers.wikijs.tls.certresolver=letsencrypt"
  - "traefik.http.services.wikijs.loadbalancer.server.port=3000"
  - "traefik.http.routers.wikijs.middlewares=secure-headers@file"

services:
  wikijs:
    image: requarks/wiki:2.5
    labels:
      <<: *traefik-labels
```

### Direct Reference

See `services/traefik/templates/service-labels.yml` for complete template examples.

---

## Migration Guide

### Updating Existing Services

1. **Identify service type** (public, admin, cf-access)
2. **Copy appropriate template** from `services/traefik/templates/service-labels.yml`
3. **Replace variables** (`<service>`, `<domain>`, `<port>`)
4. **Update compose file** with new labels
5. **Test deployment** and verify routing
6. **Update documentation** if needed

### Validation

```bash
# Validate compose syntax
docker compose -f services/<service>/compose.yml config

# Test routing
curl -I https://<domain>
```

---

## Troubleshooting

### Issue: Service Not Accessible

**Check:**
1. Labels are correctly formatted
2. Domain matches DNS record
3. Service port is correct
4. Service is running and healthy
5. Traefik is running and healthy

### Issue: SSL Certificate Not Generated

**Check:**
1. DNS record exists and points to server IP
2. `CF_DNS_API_TOKEN` is set in `.workspace/.env`
3. Traefik can access Cloudflare API
4. Certificate resolver is `letsencrypt`

### Issue: Middleware Not Applied

**Check:**
1. Middleware name is correct
2. Middleware is defined in Traefik dynamic config
3. Middleware chain is properly formatted
4. No conflicting middleware rules

---

## References

- **Template File:** `services/traefik/templates/service-labels.yml`
- **Traefik Documentation:** https://doc.traefik.io/traefik/
- **Main Documentation:** `AGENTS.md` - Service catalog
- **Remediation Plan:** `REMEDIATION_PLAN.md` - Phase 3.2 Traefik configuration

---

**Last Updated:** 2025-11-22  
**Maintained By:** DevOps Team / Infrastructure Lead

