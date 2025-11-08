# Cursor Agent Context — Cult of Joey Infra

## Objective
Deploy and maintain the entire self-hosted ecosystem defined in `Cursor Deployment Framework`.

## Primary Agents
- **infra-architect** — reads `project-plan.yml` and composes Docker, Traefik, and network files.
- **secrets-keeper** — handles Infisical variable injection and validation.
- **dev-orchestrator** — runs deployments on each host, verifies tunnels, executes preflight safety checks.
- **security-sentinel** — monitors ClamAV, firewalls, and WAF reports; updates changelog.md.
- **api-gatekeeper** — manages Kong routes, policies, and key rotations.
- **automator** — triggers Node-RED/n8n workflows for backups, logs, and scans.

## Base Environment
.env path: `/Users/freqkflag/Projects/.workspace/.env`  
Secrets loaded via: `infisical run --env=production`  
Primary networks: `edge` (external bridge)  

## General Protocol
1. Verify `.env` presence and Infisical connectivity.  
2. Mount secrets into context using Infisical CLI.  
3. Build Compose files per service under `~/infra/services/`.  
4. Validate network links (`edge`, tunnels, ports).  
5. Deploy with `docker compose up -d` and confirm health.  
6. Append all changes to `~/server-changelog.md`.

---

### 3. **project-plan.yml** — defines infrastructure as tasks
A YAML blueprint Cursor can parse or use with an agent script.

```yaml
project: "Cult of Joey Infra Deployment"
version: "2025-11-08"

environments:
  - name: vps.host
    domain: freqkflag.co
    services:
      - traefik
      - infisical
      - kong
      - gitea
      - ghost
      - wordpress
      - discourse
      - wiki
      - linkstack
      - localai
      - openwebui
      - node-red
      - clamav
      - postgres
      - mariadb
      - redis
  - name: home.macmini
    domain: twist3dkink.online
    services: [frontend, dev-tools]
  - name: home.linux
    domain: cult-of-joey.com
    services: [vaultwarden, bookstack]

workflows:
  deploy:
    - run: preflight-check
    - run: load-secrets
    - run: compose-up
    - run: verify-containers
    - run: log-to-changelog
  backup:
    - run: backup-databases
    - run: sync-to-homelab
  security:
    - run: clamav-scan
    - run: update-signatures
    - run: report-results

policies:
  secrets: infisical-only
  databases: centralized-on-vps
  ingress: cloudflare-tunnels
  network: edge-shared
