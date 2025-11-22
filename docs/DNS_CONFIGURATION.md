# DNS Configuration for freqkflag.co

**Last Updated:** 2025-11-22  
**Server IP:** 62.72.26.113  
**DNS Provider:** Cloudflare

## Overview

This document tracks all DNS records for the `freqkflag.co` domain that should exist based on the infrastructure configuration. All services are accessed via Traefik reverse proxy running on the server at `62.72.26.113`.

## Expected DNS Records

All records should be **A records** pointing to `62.72.26.113`. Records can be proxied (orange cloud) or DNS-only (grey cloud) depending on requirements.

### Infrastructure Services

| Domain | Service | Type | Status |
|--------|---------|------|--------|
| `freqkflag.co` | Root domain | A | Required |
| `traefik.freqkflag.co` | Traefik Dashboard | A | Required |
| `infisical.freqkflag.co` | Infisical | A | Required |
| `adminer.freqkflag.co` | Adminer | A | Required |
| `ops.freqkflag.co` | Ops Control Plane | A | Required |

### Application Services

| Domain | Service | Type | Status |
|--------|---------|------|--------|
| `wiki.freqkflag.co` | WikiJS | A | Required |
| `n8n.freqkflag.co` | n8n | A | Required |
| `nodered.freqkflag.co` | Node-RED | A | Required |
| `backstage.freqkflag.co` | Backstage | A | Required |
| `gitlab.freqkflag.co` | GitLab CE | A | Required |
| `supabase.freqkflag.co` | Supabase Studio | A | Required |
| `api.supabase.freqkflag.co` | Supabase API | A | Required |
| `mail.freqkflag.co` | Mailu Admin | A | Required |
| `webmail.freqkflag.co` | Mailu Webmail | A | Required |
| `vault.freqkflag.co` | Vault | A | Required |

### Monitoring & Logging

| Domain | Service | Type | Status |
|--------|---------|------|--------|
| `grafana.freqkflag.co` | Grafana | A | Required |
| `prometheus.freqkflag.co` | Prometheus | A | Required |
| `alertmanager.freqkflag.co` | Alertmanager | A | Required |
| `loki.freqkflag.co` | Loki | A | Required |

## DNS Management

### Using cloudflare-dns-manager.py

The script supports creating/updating A records:

```bash
# Set API token
export CLOUDFLARE_API_TOKEN='your-token'

# Create/update A record for subdomain
python3 scripts/cloudflare-dns-manager.py upsert-a \
  --zone freqkflag.co \
  --subdomain wiki \
  --ip 62.72.26.113 \
  --proxied

# Create/update root domain A record
python3 scripts/cloudflare-dns-manager.py upsert-a \
  --zone freqkflag.co \
  --subdomain "" \
  --ip 62.72.26.113 \
  --proxied
```

### Using Cloudflare API Directly

```bash
export CF_API_TOKEN='your-token'
export ZONE_ID='your-zone-id'

# Create A record
curl -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
  -H "Authorization: Bearer ${CF_API_TOKEN}" \
  -H "Content-Type: application/json" \
  --data '{
    "type": "A",
    "name": "wiki",
    "content": "62.72.26.113",
    "ttl": 3600,
    "proxied": true
  }'
```

### Audit Script

Run the audit script to see all expected DNS records:

```bash
python3 scripts/audit-dns-records.py
```

This script:
- Scans all `docker-compose.yml` and `compose.yml` files for Traefik `Host()` labels
- Reads `SERVICES.yml` for service domain configurations
- Generates a report of all expected DNS records
- Provides update commands

## Verification

### Check DNS Records

```bash
# List all DNS records for zone
python3 scripts/cloudflare-dns-manager.py list-records --zone freqkflag.co

# Test DNS resolution
dig wiki.freqkflag.co
nslookup backstage.freqkflag.co
```

### Verify Service Accessibility

All services should be accessible via HTTPS through Traefik:

```bash
# Test service endpoints
curl -I https://wiki.freqkflag.co
curl -I https://backstage.freqkflag.co
curl -I https://infisical.freqkflag.co
```

## Notes

- **A Records vs CNAME**: Use A records for IP addresses. CNAME records are for pointing to other domain names.
- **Proxied vs DNS-only**: 
  - Proxied (orange cloud): Traffic goes through Cloudflare CDN, provides DDoS protection and caching
  - DNS-only (grey cloud): Direct connection to server, required for some services (e.g., mail servers)
- **Nested Subdomains**: For subdomains like `api.supabase.freqkflag.co`, create the record with the full subdomain name.
- **Root Domain**: The root domain `freqkflag.co` should also have an A record pointing to the server IP.

## Related Documentation

- [AGENTS.md](../AGENTS.md) - Service inventory and status
- [SERVICES.yml](../SERVICES.yml) - Service definitions
- [scripts/cloudflare-dns-manager.py](../scripts/cloudflare-dns-manager.py) - DNS management script
- [scripts/audit-dns-records.py](../scripts/audit-dns-records.py) - DNS audit script

