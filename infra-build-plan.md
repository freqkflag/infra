<!-- Infra Build Plan generated 2025-11-09, updated 2025-11-09 -->
# Cursor Infrastructure Build Plan

## 1. Purpose

- Define an auditable, reproducible deployment blueprint for `freqkflag/infra`
- Cover VPS (`vps.host`), Mac mini (`home.macmini`), and homelab (`home.linux`)
- Ensure all services run via Docker Compose with shared `edge` network and Infisical-managed secrets

## 2. Prerequisites

1. Verify base tooling on target node:

   ```bash
   docker --version
   docker compose version
   infisical --version
   ```

2. Prepare environment file and Infisical credentials:

   ```bash
   # Copy base template and merge host-specific overrides
   cp .env.example .workspace/.env
   # Merge values from env/templates/base.env.example
   # Then layer host-specific: env/templates/vps.env.example (or mac/linux)
   
   test -f .workspace/.env
   infisical status --workspace prod
   ```

3. Ensure repository presence:

   ```bash
   test -d ~/infra || git clone git@github.com:freqkflag/infra.git ~/infra
   cd ~/infra && git pull
   ```

4. Create edge network if absent (preflight also covers this):

   ```bash
   docker network inspect edge >/dev/null 2>&1 || docker network create --driver bridge edge
   ```

## 3. Repository Layout Expectations

```text
infra/
├── infra-build-plan.md
├── AGENTS.md
├── PROJECT_PLAN.md
├── README.md
├── project-plan.yml
├── compose.orchestrator.yml    # Master bundle with profiles per host
├── env/
│   └── templates/
│       ├── base.env.example    # Shared defaults
│       ├── vps.env.example     # Production overrides
│       ├── mac.env.example     # Mac mini dev overrides
│       └── linux.env.example   # Homelab overrides
├── services/                   # Per-service Compose definitions
│   ├── traefik/compose.yml
│   ├── cloudflared/compose.yml
│   ├── infisical/compose.yml
│   ├── kong/compose.yml
│   ├── postgres/compose.yml
│   ├── mariadb/compose.yml
│   ├── redis/compose.yml
│   ├── clamav/compose.yml
│   └── apps/* (ghost, wordpress, discourse, wikijs, gitea, linkstack, localai, openwebui, node-red, vaultwarden, bookstack, auxiliary, frontend, dev-tools)
├── nodes/                      # Per-node deployment configs
│   ├── vps.host/
│   │   ├── compose.yml         # Host-specific service bundle
│   │   ├── deploy.sh           # Wrapper around scripts/deploy.ah
│   │   ├── health-check.sh     # Per-node health validation
│   │   ├── teardown.sh         # Per-node teardown wrapper
│   │   ├── domains.yml         # Domain-to-service mappings
│   │   └── networks.yml        # Network and tunnel metadata
│   ├── home.macmini/
│   │   ├── compose.yml
│   │   ├── deploy.sh
│   │   ├── health-check.sh
│   │   ├── teardown.sh
│   │   ├── domains.yml
│   │   └── networks.yml
│   └── home.linux/
│       ├── compose.yml
│       ├── deploy.sh
│       ├── health-check.sh
│       ├── teardown.sh
│       ├── domains.yml
│       └── networks.yml
└── scripts/                    # Global automation scripts
    ├── preflight.sh
    ├── deploy.ah
    ├── backup.sh
    ├── status.sh
    ├── sync.sh
    ├── health-check.sh
    └── teardown.sh
```

## 4. Service Dependency Graph (VPS Core)

| Order | Service        | Depends On                           | Notes |
| ----- | -------------- | ------------------------------------ | ----- |
| 1     | Infisical DB   | Docker daemon, persistent volumes    | PostgreSQL + Redis backing Infisical |
| 2     | Infisical API  | Infisical DB                         | Provides secret injection |
| 3     | Traefik        | Cloudflare API (DNS-01), edge network| Handles TLS + ingress |
| 4     | Cloudflare DNS | Cloudflare API (DNS-01)              | DNS management and certificate validation |
| 5     | Kong OSS       | Traefik, Infisical                   | API gateway and auth |
| 6     | Databases      | Traefik (for admin UIs), Infisical   | PostgreSQL, MariaDB, Redis for apps |
| 7     | ClamAV         | Databases (for logging)              | Malware scanning service |
| 8     | Application    | Databases, ClamAV, Kong, Traefik     | Ghost, WordPress, Discourse, etc. |
| 9     | Automation     | Application tier, ClamAV             | n8n / Node-RED for workflows |

## 5. Environment Mapping

- **vps.host (`freqkflag.co`)**: runs Items 1–9 above; hosts centralized DBs,
  Infisical, ingress stack.
- **home.macmini (`twist3dkink.online`)**: runs frontend builds, dev tools;
  consumes VPS databases.
- **home.linux (`cult-of-joey.com`)**: runs Vaultwarden, BookStack, auxiliary
  services; consumes VPS databases and Infisical.

## 6. Compose Standards

Every Compose definition must include:

- `networks: [edge]` (external network)
- `restart: unless-stopped`
- `healthcheck` with meaningful command and intervals
- `env_file: ../../.workspace/.env` (relative path from service directory) or `.workspace/.env` (from repo root)
- Secrets via `Infisical` injection: deploy with `infisical run --env=<environment> -- docker compose ...`
- Traefik labels using existing naming conventions:
  - `traefik.enable=true`
  - `traefik.http.routers.<service>.rule=Host(\`${DOMAIN_VAR}\`)`
  - `traefik.http.routers.<service>.entrypoints=websecure`
  - `traefik.http.routers.<service>.tls.certresolver=letsencrypt` (required for TLS)
  - `traefik.http.services.<service>.loadbalancer.server.port=<port>`
  - Middleware labels as needed (`secure-headers@file`, `cf-access@file`)
- TLS certificate resolver: `letsencrypt` (uses Cloudflare DNS-01 challenge)

## 7. Deployment Workflow

### 7.1 Global Workflow

1. Run preflight:

   ```bash
   cd ~/infra
   ./scripts/preflight.sh
   ```

2. Load secrets and deploy target stack:

   ```bash
   infisical run --env=production -- ./scripts/deploy.ah vps.host
   ```

3. Validate status:

   ```bash
   ./scripts/status.sh
   ./scripts/health-check.sh vps.host  # or home.macmini, home.linux
   # Or use node-specific wrapper:
   ./nodes/vps.host/health-check.sh
   ```

4. Append changelog:

   ```bash
   ./scripts/sync.sh
   ```

### 7.2 VPS Foundation Sequence

1. Deploy Infisical:

   ```bash
   infisical run --env=production -- docker compose -f nodes/vps.host/compose.yml up -d infisical
   ```

2. Deploy Traefik:

   ```bash
   infisical run --env=production -- docker compose -f nodes/vps.host/compose.yml up -d traefik
   ```

3. Configure Cloudflare DNS (via API or dashboard):
   - Ensure `CF_DNS_API_TOKEN` is set in Infisical
   - DNS records will be managed via Cloudflare DNS API
   - **Note:** Using Cloudflare DNS management only (not Cloudflared tunnels)

4. Deploy Kong and databases:

   ```bash
   infisical run --env=production -- docker compose -f nodes/vps.host/compose.yml up -d kong postgres mariadb redis
   ```

5. Deploy ClamAV:

   ```bash
   infisical run --env=production -- docker compose -f nodes/vps.host/compose.yml up -d clamav
   ```

6. Deploy application tier:

   ```bash
   infisical run --env=production -- docker compose -f nodes/vps.host/compose.yml up -d ghost wordpress discourse wikijs gitea linkstack localai openwebui node-red
   ```

### 7.3 Mac mini Sequence

1. Ensure DNS records are configured via Cloudflare DNS API.
2. Deploy dev services:

   ```bash
   infisical run --env=development -- docker compose -f nodes/home.macmini/compose.yml up -d frontend dev-tools
   ```

3. Register with centralized databases via environment variables (DB host `vps.host`).

### 7.4 Homelab Sequence

1. Configure Cloudflare DNS for homelab domains:

   ```bash
   # Ensure CF_DNS_API_TOKEN is set in Infisical
   # DNS records managed via Cloudflare DNS API
   # Note: Using Cloudflare DNS management only (not Cloudflared tunnels)
   ```

2. Deploy core services:

   ```bash
   infisical run --env=homelab -- docker compose -f nodes/home.linux/compose.yml up -d vaultwarden bookstack auxiliary
   ```

## 8. Secret Management (Infisical)

- Organize secrets per environment path (`prod/`, `dev/`, `homelab/`).
- No hardcoded credentials in Compose files; reference variables like `${POSTGRES_PASSWORD}`.
- Environment templates live in `env/templates/`:
  - `base.env.example` — shared defaults (timezone, Cloudflare tokens, Traefik, DB connection strings)
  - `vps.env.example` — production domains and application credentials
  - `mac.env.example` — Mac mini development overrides
  - `linux.env.example` — homelab service overrides
- Merge templates into `.workspace/.env` before bootstrap or deployment.
- During automation tasks (backups, health checks), wrap command with `infisical run --env=<environment>`.
- Regularly rotate secrets; record rotations in `server-changelog.md`.
- Sync local `.workspace/.env` to Infisical when updating secrets:

  ```bash
  infisical --domain https://vault.freqkflag.co/api secrets set --file .workspace/.env --env prod --path / --token <service-token>
  ```

## 9. Automation & Maintenance

- **Backups**: `./scripts/backup.sh` triggered daily by Cron or n8n. Outputs to `~/.backup/daily`.
- **Sync Routine**: `./scripts/sync.sh` runs preflight, backup, status, and logs results.
- **Automation Orchestrator**: n8n/Node-RED flows manage:
  - Scheduled backups (`backup.sh`)
  - ClamAV scans using REST hooks
  - Changelog notifications via webhook
- Each run must append timestamped entries to `server-changelog.md`.

## 10. Security Hardening

1. Enforce Cloudflare Zero-Trust for admin subdomains (Kong, Traefik dashboards, Infisical).
2. Configure firewall to allow only 22/80/443 and container-specific internal ports.
3. Enable Traefik middlewares for rate limiting and headers.
4. Ensure Kong plugins (`key-auth`, `rate-limiting`, `cors`) are active for all APIs.
5. Schedule ClamAV nightly scan:

   ```bash
   docker exec clamav clamscan -r /data --log=/var/log/clamav/nightly.log
   ```

6. Run security workflow weekly:

   ```bash
   infisical run --env=production -- n8n execute --workflow security-audit
   ```

## 11. Validation & Monitoring

- Run health checks after deployments:

  ```bash
  # Global health check (requires target argument)
  ./scripts/health-check.sh vps.host
  
  # Or use node-specific wrapper
  ./nodes/vps.host/health-check.sh
  ```

- Inspect Traefik routes and TLS status:

  ```bash
  docker exec traefik traefik healthcheck
  docker exec traefik traefik api --raw /api/http/routers
  ```

- Verify Kong status:

  ```bash
  curl -s https://api.freqkflag.co/status --header "Authorization: Kong-Key ${KONG_ADMIN_KEY}"
  ```

- Confirm Cloudflare DNS configuration:

  ```bash
  # Verify DNS records via Cloudflare API
  curl -X GET "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_FREQKFLAG_CO}/dns_records" \
    -H "Authorization: Bearer ${CF_DNS_API_TOKEN}" \
    -H "Content-Type: application/json"
  ```

- Monitor resource usage:

  ```bash
  docker stats --no-stream
  ```

- Validate TLS certificates:

  ```bash
  # Check certificate resolver configuration
  docker exec traefik cat /letsencrypt/acme.json | jq .
  # Verify domain resolution
  curl -I https://traefik.freqkflag.co
  ```

## 12. Backup & Restore Procedures

1. Run manual backup:

   ```bash
   ./scripts/backup.sh
   ```

2. Sync backups to homelab:

   ```bash
   ./scripts/sync.sh
   rsync -av ~/.backup/ user@home.linux:~/.backup/
   ```

3. Restore PostgreSQL:

   ```bash
   gunzip < ~/.backup/daily/postgres_<timestamp>.sql.gz | docker exec -i postgres psql -U postgres
   ```

4. Restore MariaDB:

   ```bash
   docker exec -i mariadb mysql -u root < ~/.backup/daily/mariadb_<timestamp>.sql
   ```

5. Restore volumes:

   ```bash
   tar xzf ~/.backup/daily/docker_volumes_<timestamp>.tar.gz -C /
   ```

## 13. Teardown / Rollback

1. Stop application tier (using node-specific script or direct compose):

   ```bash
   # Using node wrapper
   infisical run --env=production -- ./nodes/vps.host/teardown.sh ghost wordpress discourse
   
   # Or direct compose command
   infisical run --env=production -- docker compose -f nodes/vps.host/compose.yml down ghost wordpress discourse wikijs gitea linkstack localai openwebui node-red
   ```

2. Stop security/gateway services:

   ```bash
   infisical run --env=production -- docker compose -f nodes/vps.host/compose.yml down clamav kong cloudflared traefik infisical
   ```

3. Full teardown (using global script):

   ```bash
   infisical run --env=production -- ./scripts/teardown.sh vps.host
   ```

4. Remove network (only if no hosts rely on it):

   ```bash
   docker network rm edge
   ```

5. Document actions in changelog:

   ```bash
   echo "$(date +"%Y-%m-%d %H:%M:%S") - Performed teardown on vps.host" >> ~/server-changelog.md
   ```

## 14. Compliance & Audit

- All changes recorded in Git and `server-changelog.md`.
- Use MIT-licensed or equivalent FOSS services only.
- Maintain versioned Compose files; no mutable manual edits on hosts.
- Quarterly audit script (to implement in n8n):

  ```bash
  infisical run --env=production -- ./scripts/status.sh && docker image ls
  ```

## 15. Node Configuration Files

Each node directory (`nodes/<host>/`) contains:

- **`compose.yml`**: Host-specific service bundle using `extends` to reference `services/*/compose.yml`
- **`deploy.sh`**: Wrapper script that calls `scripts/deploy.ah` with the correct target
- **`health-check.sh`**: Per-node health validation wrapper
- **`teardown.sh`**: Per-node teardown wrapper
- **`domains.yml`**: Domain-to-service mappings and Cloudflare zone configuration
- **`networks.yml`**: Network metadata and Cloudflared tunnel token references

### Domain Configuration (`domains.yml`)

Each `domains.yml` file maps environment variables to hostnames and services:

```yaml
zone: freqkflag.co
cloudflare_zone_variable: CF_ZONE_FREQKFLAG_CO
domains:
  - env: GHOST_DOMAIN
    host: ghost.freqkflag.co
    service: ghost
```

### Network Configuration (`networks.yml`)

Each `networks.yml` file documents network requirements:

```yaml
networks:
  - name: edge
    scope: external
    purpose: shared overlay network for all nodes
tunnels:
  - name: cloudflared-vps
    token_env: CF_TUNNEL_TOKEN_VPS
    description: Cloudflare tunnel anchoring freqkflag.co ingress
```

## 16. Deployment Alternatives

### Option 1: Node-Specific Scripts (Recommended)

```bash
infisical run --env=production -- ./nodes/vps.host/deploy.sh
infisical run --env=development -- ./nodes/home.macmini/deploy.sh
infisical run --env=homelab -- ./nodes/home.linux/deploy.sh
```

### Option 2: Global Deploy Script

```bash
infisical run --env=production -- ./scripts/deploy.ah vps.host
infisical run --env=development -- ./scripts/deploy.ah home.macmini
infisical run --env=homelab -- ./scripts/deploy.ah home.linux
```

### Option 3: Orchestrator Compose (Profiles)

```bash
infisical run --env=production -- docker compose -f compose.orchestrator.yml --profile vps up -d
infisical run --env=development -- docker compose -f compose.orchestrator.yml --profile mac up -d
infisical run --env=homelab -- docker compose -f compose.orchestrator.yml --profile linux up -d
```

## 17. Maintenance Status

✅ **Completed:**

- Host-specific Compose files under `nodes/<node>/compose.yml`
- Per-service Compose manifests with health checks and restart policies
- `scripts/health-check.sh` and `scripts/teardown.sh` implemented
- Node-specific wrapper scripts (`deploy.sh`, `health-check.sh`, `teardown.sh`)
- Domain and network configuration files (`domains.yml`, `networks.yml`)
- Environment template structure (`env/templates/`)
- TLS certificate resolver configuration (`letsencrypt`)
- Traefik middleware definitions (`services/traefik/dynamic/middlewares.yml`)

📋 **Ongoing:**

- Keep `AGENTS.md` and `README.md` synchronized with this plan
- Validate `.gitignore` excludes secrets, logs, and backups
- Maintain changelog entries for all deployments

This document is the authoritative deployment reference for the Cult of Joey
infrastructure and must be updated alongside any stack modifications.
