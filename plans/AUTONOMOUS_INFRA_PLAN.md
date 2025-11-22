# Autonomous Infra Recovery & Operations Plan

**Scope:** `/root/infra`  
**Owner:** Orchestrator Agent (`ai.engine/agents/orchestrator-agent.md`)  
**Protocols:** [Agent-to-Agent Protocol](../ai.engine/workflows/A2A_PROTOCOL.md) v1.0.0  
**Success Criteria:** Every routed dashboard/API (Traefik, Infisical, Grafana, Backstage, Supabase, n8n, Node-RED, WordPress, LinkStack, Adminer, GitLab) must be reachable via HTTPS from an arbitrary browser using Cloudflare-managed DNS (`*.freqkflag.co`, `cultofjoey.com`, `twist3dkink.online`).

---

## Guiding Principles

1. **Full Autonomy:** All actions are executed via `ai.engine` agents using the A2A handshake (session tokens, context exchange, MCP integration). Human interaction is limited to top-level approval.
2. **Orchestrator-First:** Every phase starts with the orchestrator agent coordinating downstream specialists; each agent run logs to `/root/infra/.workspace/a2a-sessions/`.
3. **Documentation Coupling:** `docs/INFRASTRUCTURE_MAP.md`, `AGENTS.md`, `PREFERENCES.md`, `server-changelog.md`, and relevant service READMEs must be updated in the same phase that changes occur.
4. **Validation Evidence:** Each phase emits proof commands (`docker ps`, `curl -I`, `infisical run`, AI agent outputs) and stores structured results (JSON) under `orchestration-report.json` or `reports/<phase>.json`.
5. **Dashboards-As-Goal:** A phase cannot close unless browser-accessible dashboards/APIs in scope respond with 200/3xx over HTTPS via Traefik with valid certs.

---

## Phase Overview

| Phase | Name | Outcome |
| ----- | ---- | ------- |
| P0 | A2A Kickoff & Assessment | Active session, repo status baseline, orchestration report |
| P1 | Secrets & Config Integrity | Infisical coverage verified, `.workspace/.env` synced |
| P2 | Core Infrastructure Bring-up | Traefik, Infisical, DB, monitoring stack healthy |
| P3 | Application & Automation Stack | App services (WikiJS, WordPress, LinkStack, n8n, Node-RED, Backstage, Supabase, GitLab) deployed & tested |
| P4 | Observability & Dashboard Validation | Grafana/Prometheus, Backstage, Adminer, Traefik dashboards reachable via browser |
| P5 | Documentation, Review, Release | Docs + changelog updated, review + signed commit, release readiness confirmed |

Each phase embeds an **AI Agent Prompt** so sub-agents can run with zero manual translation.

---

## Phase Details

### Phase 0 — A2A Kickoff & Assessment
- **Objective:** Initialize A2A session, gather repository + runtime status, and produce orchestrator baseline JSON.
- **Services/Artifacts:** `AGENTS.md`, `PREFERENCES.md`, `.workspace/a2a-sessions/`, `orchestration-report.json`.
- **Agent Sequence:** Orchestrator → Status → Architecture → Security → Docs → Release.
- **AI Prompt:**  
  ```
  Act as orchestrator-agent. Start new A2A session (`./ai.engine/scripts/invoke-agent.sh orchestrator orchestration-report.json`). Aggregate status, architecture, security, docs, and release findings for /root/infra; store session context and report path for downstream phases.
  ```
- **Validation:** `cat orchestration-report.json | jq '.'` and ensure session file exists.

### Phase 1 — Secrets & Config Integrity
- **Objective:** Guarantee every `${VAR}` referenced in Compose/README files exists in Infisical and `.workspace/.env`.
- **Scope:** `env/templates/*.env.example`, `.workspace/.env`, `infisical-agent.yml`, service compose files.
- **Agent Sequence:** Secrets Steward → Docs → Security.
- **AI Prompt:**  
  ```
  Act as secrets-steward. Use A2A session <SESSION_ID> to run `infisical run --env=prod -- infisical export --format yaml --path /prod`. Diff results against env/templates + compose references, create missing secrets, regenerate .workspace/.env via infisical agent, and publish audit log under ai.engine/reports/phase1-secrets.json.
  ```
- **Validation:** Attach `phase1-secrets.json` to session, show regenerations complete, update `server-changelog.md` with audit note.

### Phase 2 — Core Infrastructure Bring-up
- **Objective:** Traefik, Infisical (API + DB), shared databases, monitoring stack online with health checks passing and `edge` network enforced.
- **Scope:** `traefik/`, `infisical/`, `services/postgres/`, `services/mariadb/`, `monitoring/`, `compose.orchestrator.yml`, `nodes/vps.host`.
- **Agent Sequence:** Compose Engineer → Deployment Runner → Security Sentinel → Architecture Agent.
- **AI Prompt:**  
  ```
  Act as compose engineer under A2A session <SESSION_ID>. Validate traefik/infisical/core DB compose files (docker compose config), ensure edge network + Traefik labels, then delegate to deployment-runner agent to execute `infisical run --env=prod -- ./scripts/deploy.ah vps.host --profile core`. Collect health-check outputs and Traefik dashboard reachability into ai.engine/reports/phase2-core.json.
  ```
- **Validation:** `curl -I https://traefik.freqkflag.co`, `curl -I https://infisical.freqkflag.co`, `docker ps --format '{{.Names}} {{.Status}}' | grep -E 'traefik|infisical|postgres'`.

### Phase 3 — Application & Automation Stack
- **Objective:** Deploy and validate WikiJS, WordPress, LinkStack, n8n, Node-RED, Backstage, Supabase, GitLab along with dependencies (Mailu optional flagged).
- **Scope:** `services/*/compose.yml`, `supabase/docker-compose.yml`, `services/backstage/compose.yml`, `n8n/docker-compose.yml`, `wordpress/`, `linkstack/`, `docs/INFRASTRUCTURE_MAP.md`.
- **Agent Sequence:** Orchestrator (delegation) → Compose Engineer → Deployment Runner → Security Sentinel → Backstage Agent → Automator (n8n workflows).
- **AI Prompt:**  
  ```
  Act as orchestrator-agent with session <SESSION_ID>. For each app service (wikijs, wordpress, linkstack, n8n, nodered, backstage, supabase, gitlab), run compose validation, deploy via node-specific compose file, confirm Traefik routing and service-specific health (e.g., Backstage port 7007, Supabase Studio/API). Use automator agent to trigger n8n/node-red workflows after deploy. Store per-service validation data in ai.engine/reports/phase3-apps.json and update docs/INFRASTRUCTURE_MAP.md statuses.
  ```
- **Validation:** Browser/API checks for each domain (document `curl -I` results), `docker ps` verifying containers running with healthy status.

### Phase 4 — Observability & Dashboard Validation
- **Objective:** Ensure dashboards (Grafana, Prometheus, Loki, Alertmanager, Backstage UI, Adminer, Traefik, Supabase, n8n, Node-RED) are externally reachable with TLS and authentication guards, and monitoring alerts clean.
- **Scope:** `monitoring/`, `services/backstage/`, `adminer/`, `n8n/`, `nodered/`, `supabase/`, `docs/INFRASTRUCTURE_MAP.md`.
- **Agent Sequence:** Status Agent → Security Agent → Performance Agent → Docs Agent.
- **AI Prompt:**  
  ```
  Act as status-agent using session <SESSION_ID>. Execute dashboard validation script (`./scripts/health-check.sh --dashboards`) ensuring HTTPS reachability and auth prompts. Pass context to security and performance agents to verify TLS, headers, and latency. Document findings plus screenshots/command output references in ai.engine/reports/phase4-observability.json.
  ```
- **Validation:** Collected HTTP status codes, screenshot references, updated monitoring alerts summary.

### Phase 5 — Documentation, Review, Release
- **Objective:** Synchronize documentation, capture changelog, run review + release workflow, and ensure branch ready for merge.
- **Scope:** `docs/INFRASTRUCTURE_MAP.md`, `AGENTS.md`, `PREFERENCES.md`, `PROJECT_PLAN.md`, `server-changelog.md`, `CHANGE.log`.
- **Agent Sequence:** Documentation & Audit Scribe → Review Agent → Release Agent.
- **AI Prompt:**  
  ```
  Act as docs-agent under session <SESSION_ID>. Update all documentation artifacts with latest deployment data, embed AI prompts for follow-up tasks, and reference validation evidence. Hand context to review-agent to inspect git diff + run validation commands, then to release-agent to commit (`git commit -S -m "infra: autonomous stack bring-up (assumes DNS propagated)"`) and summarize outputs. Store final state in ai.engine/reports/phase5-release.json and append Reviewed-by + release notes to CHANGE.log and server-changelog.md.
  ```
- **Validation:** `git status` clean, signed commit hash recorded, `CHANGE.log` includes review note, `server-changelog.md` logs deployment.

---

## Execution Flow (Autonomous Loop)

1. **Create Session:** `./ai.engine/scripts/a2a-session.sh create`
2. **Run Phases Sequentially:** Invoke prompts above using `./ai.engine/scripts/invoke-agent.sh <agent> ... --session <session_id> --context <phase_context.json>`
3. **Share Context:** After each phase, store outputs under `ai.engine/reports/phaseX-*.json` and pass path via `--context`.
4. **Escalation:** If a phase fails, orchestrator triggers remediation plan (fallback to `REMEDIATION_PLAN.md`).
5. **Completion Signal:** Release agent posts success summary referencing accessible dashboards and attaches `phase5-release.json`.

---

## Validation Checklist (Success = All Dashboards Reachable)

- [ ] `https://traefik.freqkflag.co` dashboard accessible with auth
- [ ] `https://infisical.freqkflag.co` UI loads and secrets accessible
- [ ] `https://grafana.freqkflag.co`, `https://prometheus.freqkflag.co`, `https://alertmanager.freqkflag.co`, `https://loki.freqkflag.co` responsive
- [ ] `https://adminer.freqkflag.co` reachable
- [ ] `https://wiki.freqkflag.co`, `https://n8n.freqkflag.co`, `https://nodered.freqkflag.co`, `https://backstage.freqkflag.co`, `https://supabase.freqkflag.co`, `https://api.supabase.freqkflag.co`, `https://gitlab.freqkflag.co`, `https://cultofjoey.com`, `https://link.cultofjoey.com` respond with 200/secure redirect
- [ ] AI Engine reports archived (`ai.engine/reports/phase*.json`) and referenced in documentation
- [ ] `docs/INFRASTRUCTURE_MAP.md` statuses align with reality

---

## Operational Notes

- **Automation Trigger:** When ready to execute, run `./ai.engine/scripts/invoke-agent.sh orchestrator orchestration-report.json --session <session_id>` to kick off Phase 0. Downstream scripts will reuse the `--session` flag for context continuity.
- **MCP Integration:** Use `--mcp-tools infisical,cloudflare,wikijs,github` flags as needed per phase to manipulate secrets, DNS, docs, and repos.
- **Telemetry:** Each agent must emit `{ agent, action, status, timestamp, details }` to the Infisical-secured webhook defined in `PREFERENCES.md`.

This plan supersedes ad-hoc recovery instructions and should be referenced before any infra-wide change. Update it whenever services, domains, or protocols evolve.
