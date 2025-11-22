# Health Check Standards

**Created:** 2025-11-22  
**Last Updated:** 2025-11-22  
**Status:** Active Documentation

---

## Overview

This document defines the standard health check patterns used across all services in the infrastructure. It provides guidelines for consistent health check configuration.

---

## Standard Health Check Configuration

### Standard Values

- **Interval:** `30s` (check every 30 seconds)
- **Timeout:** `5s` (wait 5 seconds for response)
- **Retries:** `5` (retry 5 times before marking unhealthy)
- **Start Period:** `30s` (allow 30 seconds for initial startup)

### Standard Template

```yaml
healthcheck:
  test:
    - CMD-SHELL
    - "<health-check-command>"
  interval: 30s
  timeout: 5s
  retries: 5
  start_period: 30s
```

---

## Health Check Patterns

### Pattern 1: HTTP Endpoint Check

**Use for:** Web services with HTTP endpoints

```yaml
healthcheck:
  test:
    - CMD-SHELL
    - "curl -fsSL http://127.0.0.1:<port>/ || exit 1"
  interval: 30s
  timeout: 5s
  retries: 5
  start_period: 30s
```

**Examples:**
- WikiJS: `curl -fsSL http://127.0.0.1:3000/ || exit 1`
- WordPress: `curl -fsSL http://127.0.0.1/ || exit 1`
- Node-RED: `curl -fsSL http://127.0.0.1:1880/ || exit 1`

### Pattern 2: HTTP Health Endpoint

**Use for:** Services with dedicated `/health` or `/healthz` endpoints

```yaml
healthcheck:
  test:
    - CMD-SHELL
    - "curl -fsSL http://127.0.0.1:<port>/health || exit 1"
  interval: 30s
  timeout: 5s
  retries: 5
  start_period: 30s
```

**Examples:**
- n8n: `curl -fsSL http://127.0.0.1:5678/healthz || exit 1`
- Infisical: `curl -fsSL http://127.0.0.1:8080/api/status || exit 1`

### Pattern 3: Process Check

**Use for:** Services without HTTP endpoints or when HTTP check unavailable

```yaml
healthcheck:
  test:
    - CMD-SHELL
    - "kill -0 1 2>/dev/null && ps aux | grep -v grep | grep -q <process-name> && exit 0 || exit 1"
  interval: 30s
  timeout: 5s
  retries: 5
  start_period: 10s
```

**Examples:**
- Traefik: `kill -0 1 2>/dev/null && ps aux | grep -v grep | grep -q traefik && exit 0 || exit 1`
- Adminer: `kill -0 1 2>/dev/null && ps aux | grep -v grep | grep -q adminer && exit 0 || exit 1`

### Pattern 4: Database Connection Check

**Use for:** Database services

```yaml
healthcheck:
  test:
    - CMD-SHELL
    - "pg_isready -U <user> -d <database> || exit 1"
  interval: 30s
  timeout: 5s
  retries: 5
  start_period: 20s
```

**Examples:**
- PostgreSQL: `pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}`
- MySQL/MariaDB: `mysqladmin ping -u <user> -p<password> || exit 1`

### Pattern 5: Port Check (Alternative)

**Use for:** Services where HTTP tools unavailable but port check works

```yaml
healthcheck:
  test:
    - CMD-SHELL
    - "grep -q '0BB8' /proc/net/tcp || exit 1"  # Port 3000 in hex
  interval: 30s
  timeout: 5s
  retries: 5
  start_period: 30s
```

**Note:** Port numbers in hex (3000 = 0BB8, 8080 = 1F90, etc.)

---

## Service-Specific Examples

### WikiJS

```yaml
healthcheck:
  test:
    - CMD-SHELL
    - "curl -fsSL http://127.0.0.1:3000/ || exit 1"
  interval: 30s
  timeout: 5s
  retries: 5
  start_period: 30s
```

### WordPress

```yaml
healthcheck:
  test:
    - CMD-SHELL
    - "curl -fsSL http://127.0.0.1/ || exit 1"
  interval: 30s
  timeout: 5s
  retries: 5
  start_period: 30s
```

### Node-RED

```yaml
healthcheck:
  test:
    - CMD-SHELL
    - "curl -fsSL http://127.0.0.1:1880/ || exit 1"
  interval: 30s
  timeout: 5s
  retries: 5
  start_period: 30s
```

### n8n

```yaml
healthcheck:
  test:
    - CMD-SHELL
    - "ps aux | grep -v grep | grep -q n8n && exit 0 || exit 1"
  interval: 30s
  timeout: 5s
  retries: 5
  start_period: 30s
```

### Infisical

```yaml
healthcheck:
  test:
    - CMD-SHELL
    - "curl -fsSL http://127.0.0.1:8080/api/status || exit 1"
  interval: 30s
  timeout: 5s
  retries: 5
  start_period: 20s
```

### PostgreSQL

```yaml
healthcheck:
  test:
    - CMD-SHELL
    - "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"
  interval: 30s
  timeout: 5s
  retries: 5
  start_period: 20s
```

### Traefik

```yaml
healthcheck:
  test:
    - CMD-SHELL
    - "sh -c 'kill -0 1 2>/dev/null && ps aux | grep -v grep | grep -q traefik && exit 0 || exit 1'"
  interval: 30s
  timeout: 5s
  retries: 5
  start_period: 10s
```

---

## Start Period Guidelines

### Short Start Period (10-20s)

**Use for:** Lightweight services that start quickly

- Traefik: `10s`
- Redis: `10s`
- Adminer: `10s`
- PostgreSQL: `20s`

### Standard Start Period (30s)

**Use for:** Most application services

- WikiJS: `30s`
- WordPress: `30s`
- Node-RED: `30s`
- n8n: `30s`

### Long Start Period (40-60s)

**Use for:** Services with complex initialization

- Ghost: `40s`
- Backstage: `60s`
- GitLab: `60s` (first boot takes 5-10 minutes)

---

## Best Practices

### ✅ DO

1. **Use appropriate check type** (HTTP for web services, process for others)
2. **Set realistic start periods** (allow time for initialization)
3. **Use consistent intervals** (30s standard)
4. **Test health checks** before deploying
5. **Use environment variables** for ports and credentials
6. **Document health check method** in service README

### ❌ DON'T

1. **Don't use wget** if not available in container (use curl or process check)
2. **Don't set start period too short** (service may fail before ready)
3. **Don't use external dependencies** (check localhost only)
4. **Don't skip health checks** (always configure them)
5. **Don't use inconsistent intervals** (standardize on 30s)

---

## Troubleshooting

### Issue: Health Check Always Fails

**Solutions:**
1. Verify command works inside container: `docker exec <container> <command>`
2. Check if required tools are available (curl, wget, ps, etc.)
3. Verify port is correct
4. Check if service is actually listening on expected port
5. Increase start period if service takes time to initialize

### Issue: Health Check Fails Intermittently

**Solutions:**
1. Increase timeout (from 5s to 10s)
2. Increase retries (from 5 to 10)
3. Check service logs for errors
4. Verify resource constraints (CPU, memory)

### Issue: Health Check Never Runs

**Solutions:**
1. Verify healthcheck section is in compose file
2. Check Docker version (healthchecks require Docker 1.12+)
3. Verify compose file syntax: `docker compose config`

---

## Helper Script

Use `scripts/health-check-template.sh` to generate standard health check configurations:

```bash
./scripts/health-check-template.sh http 3000
# Generates HTTP health check for port 3000

./scripts/health-check-template.sh process n8n
# Generates process check for n8n

./scripts/health-check-template.sh database postgres
# Generates database check for PostgreSQL
```

---

## References

- **Template File:** `scripts/health-check-template.sh`
- **Main Documentation:** `AGENTS.md` - Service catalog with health check examples
- **Remediation Plan:** `REMEDIATION_PLAN.md` - Phase 3.3 health check standardization
- **Monitoring:** `scripts/monitor-health.sh` - Health check monitoring script

---

**Last Updated:** 2025-11-22  
**Maintained By:** DevOps Team / Infrastructure Lead

