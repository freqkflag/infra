# Cult of Joey Infra — Agent Operating Manual

## 1. Mission & Guardrails

- Deliver the complete infra build-out defined in `infra-build-plan.md`, `PROJECT_PLAN.md`, and `project-plan.yml`.
- Enforce reproducible, FOSS-only workflows (Docker Compose, Traefik, Cloudflared, Infisical, Kong, ClamAV, n8n/Node-RED).
- Maintain three operating domains with dedicated Cloudflared tunnels:
  - **vps.host** (`freqkflag.co`) — `${CF_TUNNEL_TOKEN_VPS}`
  - **home.macmini** (`twist3dkink.online`) — `${CF_TUNNEL_TOKEN_MAC}`
  - **home.linux** (`cult-of-joey.com`) — `${CF_TUNNEL_TOKEN_LINUX}`
- Shared external Docker network: `edge`.
- Every non-trivial change must land via commit or PR; inline commit messages must mention any assumption they encode.

## 2. Supervisory Loop (Primary Orchestrator Agent)

- Owns the task board, splits work into reviewable phases, and keeps sub-agents from idling or duplicating effort.
- Approves phase start, tracks status in `CHANGE.log`, and ensures downstream docs (`server-changelog.md`) get updates.
- Escalates to the user only for root-scope decisions (domain ownership changes, service deprecation, topology pivots).
- Verifies that each phase outputs:
  1. Updated artifacts (manifests, docs, scripts).
  2. Validation evidence (commands run, logs).
  3. Commit or PR reference.

## 3. Agent Roster & Charters

### 3.1 Discovery Cartographer
- Scans repo + hosts to keep inventory current (files, services, secrets usage).
- Updates `PROJECT_PLAN.md` prerequisites/dependencies when drift is detected.

### 3.2 Compose Engineer
- Owns all per-service Compose fragments under `services/` and the orchestrator bundle (`compose.orchestrator.yml` + `docker-compose/*.yml`).
- Validates Traefik labels, healthchecks, restart policies, and `edge` attachment.
- Runs `infisical run --env=<env> -- docker compose config` to lint manifests before handoff.

### 3.3 Secrets Steward
- Ensures every `${VAR}` referenced in Compose files exists in Infisical and the shared `.env` templates (`env/templates/`).
- Executes audits via `infisical run --env=production -- infisical export --format yaml --path prod/`.
- Blocks deployments that introduce static credentials; opens incidents in `server-changelog.md`.

### 3.4 Deployment Runner
- Executes `./scripts/preflight.sh`, `./scripts/deploy.ah <target>`, `./scripts/status.sh`, and `./scripts/health-check.sh`.
- Confirms the `edge` network exists before compose-up.
- Initiates rollback using `./scripts/teardown.sh` if health checks fail.

### 3.5 Security Sentinel
- Manages ClamAV stack, firewall rules, and Zero-Trust posture.
- Runs `docker exec clamav clamscan -r /data --log=/var/log/clamav/nightly.log`.
- Coordinates with API + ingress agents for rate limits, Access rules, and token rotation; documents incidents in `server-changelog.md`.

### 3.6 API Gatekeeper
- Owns `services/kong/kong.yml` and Cloudflare Access mappings for Kong/Traefik dashboards.
- Reloads Kong via `infisical run --env=production -- docker exec kong kong reload`.
- Synchronizes DNS + tunnel config using Cloudflare API tokens from `.env`.

### 3.7 Documentation & Audit Scribe
- Maintains `README.md`, `PROJECT_PLAN.md`, `infra-build-plan.md`, and changelogs.
- Captures every deployment or incident with timestamps + command snippets.

### 3.8 Review Agent (Reagents)
- Mandatory final gate for every phase.
- Responsibilities:
  - Inspect git diff + rendered configs.
  - Ensure validation commands ran and passed.
  - Check assumptions are documented inline or in commit messages.
  - Sign off by appending a review note to `CHANGE.log` (e.g., `Reviewed-by: reagents <timestamp>`).

### 3.9 Release Agent
- Packages approved work into small, reviewable branches.
- Runs `git status`, `git diff`, `git commit -S -m "<scope>: <summary>"` (include assumption comment), and coordinates PR creation or push.
- Verifies the branch merges cleanly and reports the commit hash back to the orchestrator.

### 3.10 Automator
- Operates n8n/Node-RED workflows (backup, changelog sync, security notifications, DNS validation).
- Triggers:
  - `infisical run --env=production -- n8n execute --workflow daily-maintenance`
  - `infisical run --env=production -- n8n execute --workflow post-recovery-audit`

## 4. Runtime & Communication Rules

- Agents live under `.cursor/agents/` and register in `.cursor/agents/registry.json`.
- Enumerate available agents: `python scripts/agents/run-agent.py list`.
- Run an agent (dry run): `python scripts/agents/run-agent.py run <name> -- --dry-run`.
- Production execution requires `AGENT_HOST=<host>` and `infisical run`.
- Broadcast events over Infisical-secured webhooks (`INFISICAL_WEBHOOK_URL`) with schema `{ agent, action, status, timestamp, details }`.
- Critical automation must emit to the n8n event bus for observability.

## 5. Deployment Workflow Synchronization

1. Discovery Cartographer refreshes inventory.
2. Compose Engineer updates manifests + orchestrator.
3. Secrets Steward validates variable coverage.
4. Deployment Runner executes preflight + deployment scripts.
5. Security Sentinel confirms Zero-Trust + ClamAV status.
6. API Gatekeeper reloads Kong + validates routing.
7. Documentation Scribe updates plans + changelogs.
8. Review Agent inspects the entire phase.
9. Release Agent commits/pushes; Orchestrator closes the task.

## 6. Recovery & Redeployment

- Use `./scripts/teardown.sh` for graceful rollback; log ticket in `server-changelog.md`.
- Restore data from `~/.backup/<tier>/` using procedures in `infra-build-plan.md`.
- Infisical outage steps:
  1. Switch to read-only mode; block deployments.
  2. `infisical export --format env --path prod/backup > /tmp/infisical-backup.env`
  3. After recovery, shred the cache file and trigger `post-recovery-audit`.
- Any recovery action that touches tracked files must conclude with a commit/PR.

## 7. Documentation & Audit Duties

- Update `infra-build-plan.md`, `PROJECT_PLAN.md`, `README.md`, and `.env` templates whenever workflows or variables change.
- Append operational notes to `~/server-changelog.md` after each deployment/incident.
- Quarterly compliance review stored under `docs/compliance/`; co-signed by Security Sentinel + Orchestrator.
- **All documentation updates initiated by agents must be committed and synchronized upstream.**

## 8. Incident Escalation

- Severity 0/1: page on-call via Infisical webhook, halt deployments immediately.
- Severity 2/3: document in changelog, notify stakeholders within 1 hour.
- Attach remediation commands executed, e.g.:

  ```bash
  infisical run --env=production -- docker compose -f docker-compose/vps.host.yml restart traefik
  ```

These directives keep the supervised agent swarm aligned with the orchestrator’s build plan while ensuring every action is reviewable, auditable, and quickly recoverable.
