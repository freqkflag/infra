<<<<<<< HEAD
# Cult of Joey Infra

Self-hosted multi-node infrastructure managed with FOSS tooling and Cloudflare Zero-Trust edge.

## Overview

- Primary hosts: `vps.host`, `home.macmini`, `home.linux`
- Core stack: Docker Compose, Traefik, Cloudflared, Infisical, Kong OSS, ClamAV, n8n/Node-RED
- Service definitions and policy are governed by `infra-build-plan.md`, `PROJECT_PLAN.md`, and `project-plan.yml`

## Quick Start Bootstrap

1. Prepare environment (copy `.env.example` and extend with `env/templates/*.env.example` values):

   ```bash
   test -f .workspace/.env
   docker --version
   docker compose version
   infisical --version
   ```

2. Bootstrap node:

   ```bash
   chmod +x bootstrap.sh
   ./bootstrap.sh
   ```

3. Run preflight checks:

   ```bash
   cd ~/infra
   ./scripts/preflight.sh
   ```

4. Deploy target host (example: VPS):

   ```bash
   infisical run --env=production -- ./scripts/deploy.ah vps.host
   ```

5. Validate stack:

   ```bash
   ./scripts/status.sh
   ./scripts/health-check.sh
   ```

6. Log deployment:

   ```bash
   ./scripts/sync.sh
   ```

## Deployment Commands

- Compose orchestrator (profiles: `vps`, `mac`, `linux`):

  ```bash
  infisical run --env=production -- docker compose -f compose.orchestrator.yml --profile vps up -d
  ```

- Update services for Mac mini:

  ```bash
  infisical run --env=development -- ./scripts/deploy.ah home.macmini
  ```

- Update homelab stack:

  ```bash
  infisical run --env=homelab -- ./scripts/deploy.ah home.linux
  ```

- Teardown selected services (example: Ghost + WordPress):

  ```bash
  infisical run --env=production -- docker compose -f nodes/vps.host/compose.yml down ghost wordpress
  ```

## Architecture Reference

- Detailed orchestration order, service dependencies, and rollback procedures live in `infra-build-plan.md`
- High-level project map resides in `project-plan.yml`
- Agent responsibilities and automation workflows documented in `AGENTS.md`

## Project Structure

```text
~/infra/
├─ README.md                   — quickstart and command reference
├─ AGENTS.md                   — supervised-agent roster
├─ PROJECT_PLAN.md             — sequenced build plan
├─ infra-build-plan.md         — detailed orchestration blueprint
├─ project-plan.yml            — declarative environment map
├─ compose.orchestrator.yml    — master Compose bundle (profiles per host)
├─ env/templates/              — shared + host-specific env examples
├─ services/                   — per-service Compose definitions
├─ nodes/                      — per-node deployment configs, domains, scripts
└─ scripts/                    — automation (preflight, deploy, backup, status, sync, etc.)
```

### Environment Templates

- `env/templates/base.env.example` — shared defaults (`TZ`, Cloudflare, Traefik, DBs).
- `env/templates/vps.env.example` — production domains + app creds.
- `env/templates/mac.env.example` — Mac mini development overrides.
- `env/templates/linux.env.example` — homelab overrides.
- Merge the templates into `.workspace/.env` before running bootstrap or deployment scripts.

## Maintenance Guidelines

- Append operations to `~/server-changelog.md` on each host.
- All secrets flow through Infisical; never commit credentials.
- Compose manifests must use `edge` network, `restart: unless-stopped`, and healthchecks.
- Follow security workflows from `infra-build-plan.md` (ClamAV scans, Kong rate limits, CF Zero-Trust).

## License

MIT License – committed to community-driven FOSS tooling.
=======
# Cult of Joey - Infra  
Self-hosted multi-node infrastructure managed with FOSS tools and zero-trust edge.

## Description  
This repository defines the deployment, orchestration, and governance framework for the Cult of Joey ecosystem. With this stack you will operate across a VPS, Mac mini dev node, and homelab node — using Docker Compose, Traefik, Cloudflare Tunnels, Infisical, Kong OSS, and ClamAV.

## Architecture Overview  
- Rolling unified ingress via Cloudflare Tunnels + Traefik  
- Centralised secrets and configuration via Infisical  
- Centralised databases/caches on the VPS (Postgres, MariaDB, Redis)  
- API gateway with Kong OSS  
- Malware scanning with ClamAV  
- Automation with n8n / Node-RED  
- Full observability, backups, and change-tracking on all nodes  

## Getting Started  
1. Clone repo to `~/infra` on your local dev machine.  
2. Ensure `.env` exists at `/Users/freqkflag/Projects/.workspace/.env`.  
3. Ensure Docker Compose, Traefik, Cloudflared, and required tooling are installed on each host.  
4. Run:  
   ```bash  
   cd ~/infra  
   ./cursor deploy vps.host  
   ```
   or
   ```bash
   ./cursor deploy home.macmini
   ```
   (depending on target host)

Project Structure
```
~/infra/
├─ agents.md          — behavioural config for Cursor and agents  
├─ project-plan.yml   — declarative plan of services & hosts  
├─ services/          — sub-folders for each service (Compose files)  
├─ scripts/           — helper scripts (backup, scan, etc)  
└─ docs/              — runbooks, network templates, etc
```
Contributing & Maintenance
	•	All changes must append ~/server-changelog.md on the host (see “Logging & Change Tracking”).
	•	Use Infisical to manage secrets — never commit them to Git.
	•	Services should run only via Docker Compose + labels; no other orchestrator unless explicitly approved.

License

MIT License – safe use of community-driven FOSS tools.
>>>>>>> 6f675cc (Add initial project structure and configuration files for Cult of Joey Infra deployment)
