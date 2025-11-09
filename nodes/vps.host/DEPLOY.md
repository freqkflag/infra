# vps.host Deployment Guide

End-to-end procedure for deploying the production node (`freqkflag.co`) on any host that runs the Cult of Joey infrastructure stack.

---

## 1. Prerequisites

| Requirement | Verification |
| --- | --- |
| Docker Engine + Compose v2 | `docker --version && docker compose version` |
| Infisical CLI (authenticated) | `infisical --version && infisical status --workspace prod` |
| Git repository synced | `cd ~/infra && git pull` |
| Workspace environment file | `test -f .workspace/.env` |
| Edge network available | `docker network inspect edge >/dev/null 2>&1 || docker network create --driver bridge edge` |

- Run commands from the repository root `~/infra`.
- All secret-bearing commands must be wrapped with `infisical run --env=production -- …`.
- Make sure the host has outbound access to Docker Hub, Infisical, and Cloudflare.

### 1.1 Prepare `.workspace/.env`

1. Copy and merge template values:
   ```bash
   cp env/templates/base.env.example .workspace/.env
   cat env/templates/vps.env.example >> .workspace/.env
   ```
2. Remove placeholder data and replace with production values (DNS tokens, database passwords, Traefik credentials, etc.).
3. For auditability, sync updates into Infisical once validated:
   ```bash
   infisical run --env=production -- infisical secrets set --path prod/ --file .workspace/.env
   ```

Key variables required for deployment include (not exhaustive):

- `CF_TUNNEL_TOKEN_VPS`, `TRAEFIK_DASHBOARD_HOST`, `TRAEFIK_DASHBOARD_USERS`
- `INFISICAL_ENCRYPTION_KEY`, `INFISICAL_AUTH_SECRET`, `INFISICAL_PUBLIC_URL`
- `KONG_ADMIN_KEY`, domain-specific envs such as `GHOST_DOMAIN`, `WORDPRESS_DOMAIN`, etc.

> See `env/templates/base.env.example` and `env/templates/vps.env.example` for the authoritative list.

---

## 2. Preflight Checklist

Before deploying, run the automation preflight to validate tooling, Docker health, and the shared `edge` network:

```bash
infisical run --env=production -- ./scripts/preflight.sh
```

The script ensures:
- Required CLIs are present (Docker, Docker Compose, Infisical, Python).
- Docker daemon is healthy and responsive.
- `.workspace/.env` exists.
- The `edge` Docker network is created if missing.

Resolve any failures before proceeding.

---

## 3. Deploying the Node

### 3.1 Standard Rollout (recommended)

```bash
infisical run --env=production -- ./nodes/vps.host/deploy.sh
```

This wrapper:
1. Loads `.workspace/.env` via `WORKSPACE_ENV_FILE`.
2. Re-runs `scripts/preflight.sh`.
3. Executes `docker compose -f nodes/vps.host/compose.yml pull`.
4. Stacks the services with `docker compose … up -d`.
5. Invokes `scripts/status.sh` for a basic health summary.

### 3.2 Using the Global Orchestrator

```bash
infisical run --env=production -- ./scripts/deploy.ah vps.host
```

Identical flow without the per-node wrapper. Useful when orchestrating multiple nodes from a single entry point or when automating via agents.

### 3.3 Phased Deployment (foundation-first)

If rolling out from scratch or performing controlled recovery, deploy services in dependency order (from `infra-build-plan.md`):

```bash
# 1. Infisical data stores
infisical run --env=production -- docker compose -f nodes/vps.host/compose.yml up -d infisical-db infisical-redis

# 2. Infisical API
infisical run --env=production -- docker compose -f nodes/vps.host/compose.yml up -d infisical

# 3. Ingress layer
infisical run --env=production -- docker compose -f nodes/vps.host/compose.yml up -d traefik cloudflared

# 4. Control plane & shared databases
infisical run --env=production -- docker compose -f nodes/vps.host/compose.yml up -d kong postgres mariadb redis

# 5. Security services
infisical run --env=production -- docker compose -f nodes/vps.host/compose.yml up -d clamav

# 6. Application tier
infisical run --env=production -- docker compose -f nodes/vps.host/compose.yml up -d gitea ghost wordpress discourse wikijs linkstack localai openwebui node-red
```

> Adjust service lists as needed when introducing new workloads. All containers attach to the external `edge` network and rely on Traefik ingress.

---

## 4. Verification & Health Checks

Immediately after deployment:

```bash
./scripts/status.sh
./nodes/vps.host/health-check.sh
```

- `scripts/status.sh` prints container summary, edge network membership, disk usage, and tail of Cloudflared logs.
- `nodes/vps.host/health-check.sh` wraps `scripts/health-check.sh vps.host`, which verifies each declared service responds to its health probe.

Additional targeted checks:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker logs --tail 50 traefik
docker logs --tail 50 cloudflared
curl -fs https://api.freqkflag.co/status --header "Authorization: Kong-Key ${KONG_ADMIN_KEY}"
docker exec traefik traefik healthcheck --ping
```

If a service fails health checks, re-run the specific compose target with `--force-recreate` or consult logs for misconfigured environment variables.

---

## 5. Common Operations

### 5.1 Update or Redeploy Selected Services

```bash
# Plan mode (no changes) and then apply
infisical run --env=production -- ./scripts/redeploy_vps.host.sh --plan
infisical run --env=production -- ./scripts/redeploy_vps.host.sh ghost wordpress
```

`scripts/redeploy_vps.host.sh` composes all stack files under `nodes/vps.host/compose/` (if present) or the bundle at `nodes/vps.host/compose.yml`. Use `--no-health-check` to skip automated validation when necessary.

### 5.2 Teardown

```bash
# Remove specific services
infisical run --env=production -- ./nodes/vps.host/teardown.sh ghost wordpress

# Remove entire stack
infisical run --env=production -- ./nodes/vps.host/teardown.sh
```

Always document teardowns in `~/server-changelog.md` and ensure dependent nodes (Mac mini, homelab) are aware of outages.

### 5.3 Post-Deployment Logging

1. Append deployment summary to `~/server-changelog.md`.
2. Run the sync helper (if configured) to persist logs:
   ```bash
   ./scripts/sync.sh
   ```
3. Notify automation agents via Infisical-secured webhook if required by the operational playbook.

---

## 6. Troubleshooting

| Symptom | Resolution |
| --- | --- |
| `Missing environment file` during preflight | Ensure `.workspace/.env` exists and is readable; set `WORKSPACE_ENV_FILE` explicitly if running from CI. |
| Docker network errors for `edge` | Create the network manually: `docker network create --driver bridge edge`. |
| `infisical run` prompts for login | Run `infisical login` ahead of deployment or provide a service token via `INFISICAL_TOKEN`. |
| Services start but Traefik routes fail | Verify domain variables and Cloudflare DNS configuration; confirm `CF_TUNNEL_TOKEN_VPS` is valid. |
| Health check failures for Infisical | Confirm DB credentials (`INFISICAL_DB_USER`, `INFISICAL_DB_PASSWORD`) and that the `infisical-db` container is healthy. |
| Kong admin/API unreachable | Ensure `KONG_ADMIN_KEY` is set and Cloudflare Access is configured; check Traefik/Kong labels in `nodes/vps.host/compose.yml`. |

---

## 7. Reference

- Compose bundle: `nodes/vps.host/compose.yml`
- Deployment scripts: `nodes/vps.host/deploy.sh`, `scripts/deploy.ah`, `scripts/redeploy_vps.host.sh`
- Health & status: `scripts/status.sh`, `nodes/vps.host/health-check.sh`
- Documentation: `nodes/vps.host/README.md`, `infra-build-plan.md`, `project-plan.yml`, `PROJECT_PLAN.md`
- Environment templates: `env/templates/base.env.example`, `env/templates/vps.env.example`

Maintain alignment with the `infra-build-plan.md` architecture and ensure any configuration drift is captured through PRs with updated documentation and changelog entries.

