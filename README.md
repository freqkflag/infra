# Cult of Joey Infra

Self-hosted multi-node infrastructure managed with FOSS tooling and Cloudflare Zero-Trust edge.

## Overview

- Primary hosts: `vps.host`, `home.macmini`, `home.linux`
- Core stack: Docker Compose, Traefik, Cloudflared, Infisical, Kong OSS, ClamAV, n8n/Node-RED
- Service definitions and policy are governed by `infra-build-plan.md`, `PROJECT_PLAN.md`, and `project-plan.yml`

## Quick Start Bootstrap

1. Prepare environment:

   ```bash
   test -f /Users/freqkflag/Projects/.workspace/.env
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
  infisical run --env=production -- docker compose -f docker-compose/vps.host.yml down ghost wordpress
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
├─ services/                   — per-service Compose definitions
├─ docker-compose/             — host-specific Compose bundles
└─ scripts/                    — automation (preflight, deploy, backup, status, sync, etc.)
```

## Maintenance Guidelines

- Append operations to `~/server-changelog.md` on each host.
- All secrets flow through Infisical; never commit credentials.
- Compose manifests must use `edge` network, `restart: unless-stopped`, and healthchecks.
- Follow security workflows from `infra-build-plan.md` (ClamAV scans, Kong rate limits, CF Zero-Trust).

## License

MIT License – committed to community-driven FOSS tooling.
