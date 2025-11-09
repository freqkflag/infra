<!-- Infra Build Plan generated 2025-11-09 -->
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

2. Confirm environment file and Infisical credentials:

   ```bash
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
├── README.md
├── project-plan.yml
├── services/
│   ├── traefik/compose.yml
│   ├── cloudflared/compose.yml
│   ├── infisical/compose.yml
│   ├── kong/compose.yml
│   ├── postgres/compose.yml
│   ├── mariadb/compose.yml
│   ├── redis/compose.yml
│   ├── clamav/compose.yml
│   └── apps/* (ghost, wordpress, discourse, wikijs, gitea, linkstack, localai, openwebui, node-red)
├── nodes/
│   ├── vps.host.yml
│   ├── home.macmini.yml
│   └── home.linux.yml
└── scripts/
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
| 4     | Cloudflared    | Traefik, CF token                    | Publishes tunnel |
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

- `networks: [edge]`
- `restart: unless-stopped`
- `healthcheck` with meaningful command and intervals
- `env_file: .workspace/.env` (or relative path)
- Secrets via `Infisical` injection: deploy with `infisical run --env=production -- docker compose ...`
- Traefik labels using existing naming conventions (e.g., `traefik.http.routers.<service>.rule`)

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
   ./scripts/health-check.sh
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

3. Deploy Cloudflared tunnel:

   ```bash
   infisical run --env=production -- docker compose -f nodes/vps.host/compose.yml up -d cloudflared
   ```

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

1. Ensure VPN / tunnel connection established via Cloudflared container.
2. Deploy dev services:

   ```bash
   infisical run --env=development -- docker compose -f nodes/home.macmini/compose.yml up -d frontend dev-tools
   ```

3. Register with centralized databases via environment variables (DB host `vps.host`).

### 7.4 Homelab Sequence

1. Start Cloudflared tunnel:

   ```bash
   infisical run --env=homelab -- docker compose -f nodes/home.linux/compose.yml up -d cloudflared
   ```

2. Deploy core services:

   ```bash
   infisical run --env=homelab -- docker compose -f nodes/home.linux/compose.yml up -d vaultwarden bookstack auxiliary
   ```

## 8. Secret Management (Infisical)

- Organize secrets per environment path (`prod/`, `dev/`, `homelab/`).
- No hardcoded credentials in Compose files; reference variables like `${POSTGRES_PASSWORD}`.
- During automation tasks (backups, health checks), wrap command with `infisical run`.
- Regularly rotate secrets; record rotations in `server-changelog.md`.

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
  ./scripts/health-check.sh
  ```

- Inspect Traefik routes:

  ```bash
  docker exec traefik traefik healthcheck
  ```

- Verify Kong status:

  ```bash
  curl -s https://api.freqkflag.co/status --header "Authorization: Kong-Key ${KONG_ADMIN_KEY}"
  ```

- Confirm cloudflared tunnel:

  ```bash
  docker logs --tail 50 cloudflared
  ```

- Monitor resource usage:

  ```bash
  docker stats --no-stream
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

1. Stop application tier:

   ```bash
   infisical run --env=production -- docker compose -f nodes/vps.host/compose.yml down ghost wordpress discourse wikijs gitea linkstack localai openwebui node-red
   ```

2. Stop security/gateway services:

   ```bash
   infisical run --env=production -- docker compose -f nodes/vps.host/compose.yml down clamav kong cloudflared traefik infisical
   ```

3. Remove network (only if no hosts rely on it):

   ```bash
   docker network rm edge
   ```

4. Document actions in changelog:

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

## 15. Next Actions for Cursor Agents

1. Build host-specific Compose files under `nodes/<node>/`.
2. Create per-service Compose manifests with health checks and restart policies.
3. Implement `scripts/health-check.sh` and `scripts/teardown.sh`.
4. Update `AGENTS.md` and `README.md` per this plan.
5. Validate `.gitignore` to exclude secrets, logs, and backups.

This document is the authoritative deployment reference for the Cult of Joey
infrastructure and must be updated alongside any stack modifications.
