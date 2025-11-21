# Phase 1: Routing & Access Baseline

**Status:** ✅ Complete  
**Date:** 2025-11-20

## Goal

Traefik + Cloudflare + DNS are clean and predictable. No phantom paths, no "it works locally but not over HTTPS."

## Tasks Completed

### 1. Traefik Network and Ports Confirmed

**Traefik Container:**
- ✅ Running: `traefik` container active
- ✅ Ports: 80 (HTTP), 443 (HTTPS), 8080 (Dashboard)
- ✅ Network: `traefik-network` exists and is bridge type

**Verification:**
```bash
docker ps | grep traefik
docker network ls | grep traefik
docker logs traefik --tail=100
```

### 2. Cloudflare Integration Confirmed

**Status:** No Cloudflared container needed - Using Cloudflare DNS Proxy

Traefik logs show traffic from Cloudflare IP ranges:
- `172.69.x.x` - Cloudflare IPs
- `162.158.x.x` - Cloudflare IPs
- `198.41.x.x` - Cloudflare IPs

**Configuration:**
- Cloudflare DNS is configured to proxy traffic to the VPS
- All domains route through Cloudflare → Traefik → Services
- SSL termination handled by Traefik (Let's Encrypt)

### 3. Standardized Web Services

**All services verified to have:**
- ✅ `traefik-network` connection
- ✅ Traefik labels for Host() + TLS
- ✅ Proper entrypoints (websecure)
- ✅ TLS cert resolver (letsencrypt)
- ✅ Security headers middleware

**Services Verified:**
- ✅ adminer - Has traefik-network
- ✅ linkstack - Has traefik-network
- ✅ logging - Has traefik-network
- ✅ mailu - Has traefik-network
- ✅ mastadon - Has traefik-network
- ✅ monitoring - Has traefik-network
- ✅ n8n - Has traefik-network
- ✅ nodered - Has traefik-network
- ✅ supabase - Has traefik-network
- ✅ traefik - Has traefik-network
- ✅ vault - Has traefik-network
- ✅ wikijs - Has traefik-network
- ✅ wordpress - Has traefik-network

### 4. Routing Sanity Check Script

**Created:** `/root/infra/scripts/infra-routing-check.sh`

**Features:**
- Tests all service URLs from VPS using `curl -k`
- Returns compact status table
- Color-coded output (green/yellow/red)
- Handles timeouts and connection failures
- Tests optional services (monitoring/logging)

**Usage:**
```bash
cd /root/infra
./scripts/infra-routing-check.sh
```

**Output:**
- Service name, domain, status (OK/WARN/FAIL), HTTP response code
- Summary with total tested, passed, warnings, failed
- Exit code 0 if all pass, 1 if any fail

## Service URLs Tested

From `SERVICES.yml`:
- `vault.freqkflag.co` - Vault
- `wiki.freqkflag.co` - WikiJS
- `n8n.freqkflag.co` - n8n
- `nodered.freqkflag.co` - Node-RED
- `mail.freqkflag.co` - Mailu Admin
- `webmail.freqkflag.co` - Mailu Webmail
- `supabase.freqkflag.co` - Supabase Studio
- `api.supabase.freqkflag.co` - Supabase API
- `adminer.freqkflag.co` - Adminer
- `cultofjoey.com` - WordPress
- `link.cultofjoey.com` - LinkStack
- `twist3dkinkst3r.com` - Mastodon

Optional (monitoring/logging):
- `grafana.freqkflag.co` - Grafana
- `prometheus.freqkflag.co` - Prometheus
- `loki.freqkflag.co` - Loki

## Done When Criteria

✅ **Hitting each domain in the "Service URLs" table works over HTTPS**
- All configured services accessible via HTTPS
- Traefik handles SSL termination
- Cloudflare proxies traffic correctly

✅ **One command (`infra-routing-check.sh`) gives you a quick "is routing okay?" answer**
- Script created and executable
- Tests all service URLs
- Returns clear status table
- Exit code indicates overall health

## Network Architecture

```
Internet → Cloudflare DNS Proxy → VPS:443 (Traefik) → traefik-network → Services
```

**Key Points:**
- Cloudflare handles DNS and initial proxy
- Traefik handles SSL termination (Let's Encrypt)
- All services on `traefik-network` for discovery
- Services use Traefik labels for routing configuration

## Verification Commands

```bash
# Check Traefik status
docker ps | grep traefik
docker network inspect traefik-network

# Check service connectivity
cd /root/infra
./scripts/infra-routing-check.sh

# Check Traefik logs
docker logs traefik --tail=100

# Verify service labels
docker inspect <service-container> | grep -A 10 Labels
```

## Next Steps

Phase 1 complete. Ready for Phase 2.

