# Infrastructure Map & Tree

_Last reviewed: 2025-11-22 (status-agent validation - mismatches corrected)_

This document gives a quick visual and textual map of every service, the node it runs on, and the domain that fronts it. It is intended for review sessions before deployments, audits, or onboarding efforts.

## Legend

- ✅ Running & healthy
- ⚙️ Configured but not currently running
- ⚠️ Running but has a known issue (see referenced notes)
- 🔄 Starting (initializing)

## Node → Service Tree

```text
vps.host (freqkflag.co / SPINE)
├─ ✅ Traefik – Reverse proxy & LE automation (`traefik.freqkflag.co`)
├─ ✅ Infisical – Secrets manager + MCP (`infisical.freqkflag.co`)
├─ ✅ Adminer – DB administration hub (`adminer.freqkflag.co`)
├─ ✅ WikiJS – Documentation (`wiki.freqkflag.co`)
├─ ✅ n8n – Automation workflows (`n8n.freqkflag.co`)
├─ ✅ Node-RED – Automation workflows (`nodered.freqkflag.co`)
├─ ✅ LinkStack – Link hub (`link.cultofjoey.com`)
├─ ✅ Monitoring stack – Grafana/Prometheus/Loki/Alertmanager (`grafana|prometheus|loki|alertmanager.freqkflag.co`)
├─ ✅ Databases – PostgreSQL + MySQL backing the above services
├─ ✅ Backstage – Developer portal + Infisical plugin (`backstage.freqkflag.co`)
├─ ✅ WordPress – Primary personal brand site (`cultofjoey.com`)
├─ ✅ Ops Control Plane – Infrastructure operations UI (`ops.freqkflag.co`)
├─ ⚙️ Mailu – Full mail stack (`mail.freqkflag.co`, `webmail.freqkflag.co`)
├─ ⚠️ Supabase – BaaS platform (`supabase.freqkflag.co`, `api.supabase.freqkflag.co`) - Running but Kong restarting, Studio/Meta unhealthy
├─ ⚙️ Help Service – Static docs service (`--help/`)
└─ 🔄 GitLab – Git hosting (`gitlab.freqkflag.co`) - Starting (initializing)

home.macmini (twist3dkink.online)
├─ ⚙️ Frontend bundle (`dev.twist3dkink.online`)
└─ ⚙️ Dev tools (`tools.twist3dkink.online`)

home.linux (cult-of-joey.com)
├─ ✅ LinkStack – Link-in-bio (`link.cultofjoey.com`)
├─ ⚙️ Vaultwarden (`vault.cult-of-joey.com`)
├─ ⚙️ BookStack (`notes.cult-of-joey.com`)
└─ ⚙️ Auxiliary services (`aux.cult-of-joey.com`)

twist3dkinkst3r.com workloads
└─ ⚙️ Mastodon + PWA backend (`twist3dkinkst3r.com`, Sidekiq, PostgreSQL, R2 storage)
```

## Domain Coverage Snapshot

| Domain                | Role/Use Case                            | Primary Node      | Status |
|-----------------------|------------------------------------------|-------------------|--------|
| `freqkflag.co`        | Infrastructure spine, automation, AI     | `vps.host`        | ✅     |
| `cultofjoey.com`      | Personal brand/public web                | `vps.host`        | ✅     |
| `twist3dkink.com`     | Mental health/coaching business          | `home.macmini`    | ⚙️     |
| `twist3dkinkst3r.com` | Community PWA + Mastodon                 | `vps.host` / TBD  | ⚙️     |

**DNS Reference:** `domains/map.yml` tracks every expected hostname → service → node mapping (currently 19 A records for `freqkflag.co`). See `docs/DNS_CONFIGURATION.md` for the exhaustive record inventory.

## Network & Dependencies

- Shared external Docker network: `edge` (see `networks/map.yml`)
- Local networks per stack (e.g., `traefik-network`, `supabase-network`)
- Traefik fronts every HTTP(S) workload; ensure Traefik + `edge` exist before compose-up
- Infisical agent populates `.workspace/.env` every 60s; every compose file uses the shared env (see `infisical-agent.yml`)

## Agent Communication

- **A2A Protocol:** Agents communicate via standardized A2A protocol for context exchange and orchestration
- **Session Management:** Multi-agent workflows use A2A sessions for tracking and context propagation
- **Agent Inventory:** List all agents and MCP servers using `ai.engine/scripts/inventory-agents.sh`
- **Orchestration:** Use `ai.engine/scripts/orchestrate-agents.sh` for multi-agent workflows
- **Documentation:** See [ai.engine/workflows/A2A_PROTOCOL.md](../ai.engine/workflows/A2A_PROTOCOL.md) for protocol specification

## Validation Notes

- Health signals pulled from `AGENTS.md` status table (2025-11-22) and service directories.
- For live verification, run `./scripts/status.sh` or the relevant AI Engine agent (`ai.engine/scripts/invoke-agent.sh status-agent`).
- For multi-agent validation, use `ai.engine/scripts/validate-a2a.sh` to test A2A protocol implementation.
- Update this file whenever service state, domain mappings, or node assignments change so reviewers have an accurate tree to cross-check with compose files and DNS maps.

### Post-Deployment Validation (2025-11-22 09:25:14)

**Validation Commands Executed:**
```bash
# Container status check
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Network validation
docker network ls | grep -E "(edge|traefik)"

# Supabase service status
docker compose -f supabase/docker-compose.yml ps

# GitLab service status
docker compose -f gitlab/docker-compose.yml ps
```

**Status Changes Identified:**
- ✅ **Supabase:** Now running - Database healthy, but Kong restarting and Studio/Meta services unhealthy (updated to ⚠️ status)
- 🔄 **GitLab:** Now starting - Initialization in progress (updated from ⚙️ to 🔄 status)
- ✅ **Ops Control Plane:** Added to tree - Running healthy on `ops.freqkflag.co`
- ✅ **WordPress:** Domain corrected - Changed from `wp.freqkflag.co` to `cultofjoey.com` (verified via container labels)
- ✅ **LinkStack:** Domain corrected on vps.host - Changed from `link.freqkflag.co` to `link.cultofjoey.com` for consistency
- 📝 **home.linux WordPress entry:** Removed duplicate entry - WordPress actually runs on vps.host, not home.linux
- 📝 **Domain Coverage:** Updated `cultofjoey.com` primary node from `home.linux` to `vps.host` to match actual deployment
