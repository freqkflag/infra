# Cursor Agent Context — Cult of Joey Infra

## 1. Mission

- Maintain the infrastructure described in `infra-build-plan.md` and
  `project-plan.yml`.
- Deliver reproducible, audited deployments across VPS, Mac mini, and homelab
  nodes.
- Operate exclusively with FOSS tooling (Docker Compose, Traefik, Cloudflared,
  Infisical, Kong, ClamAV, n8n/Node-RED).

## 2. Operating Domains

- **vps.host** (`freqkflag.co`) — token `${CF_TUNNEL_TOKEN_VPS}` — production
  ingress and data plane.
- **home.macmini** (`twist3dkink.online`) — token `${CF_TUNNEL_TOKEN_MAC}` —
  development and controller node.
- **home.linux** (`cult-of-joey.com`) — token `${CF_TUNNEL_TOKEN_LINUX}` —
  auxiliary homelab services.
- Shared Docker network: `edge`

## Agent Runtime

- Cursor agents live under `.cursor/agents/` and are registered in
  `.cursor/agents/registry.json`.
- Use `python scripts/agents/run-agent.py list` to enumerate available automations.
- Run an agent locally with `python scripts/agents/run-agent.py run <name> --
  --dry-run`.
- Production hosts can invoke agents via the same entrypoint; set
  `AGENT_HOST=<host>` when required.
- **All agents MUST push a commit or create a pull request when completing
  tasks which result in changes to tracked files or configuration. This
  ensures every change made or triggered by an agent is auditable and
  permanently recorded.**

## 3. Agent Roster & Charters

### 3.1 infra-architect

- Generate and maintain Compose manifests in `services/` and host bundles in
  `docker-compose/`.
- Validate Traefik labels, healthchecks, and `edge` network attachment for
  every service.
- Produce topology updates in `infra-build-plan.md` when architecture shifts.
- Trigger build when `project-plan.yml` changes:

  ```bash
  infisical run --env=production -- ./scripts/preflight.sh
  ```

- After any update or verification that modifies the codebase or infra
  definitions, push a commit or submit a PR.

### 3.2 secrets-keeper

- Ensure Infisical secrets cover all environment variables referenced in
  Compose files.
- Deny deployments containing static credentials; remediate by creating
  Infisical entries.
- Run periodic audit:

  ```bash
  infisical run --env=production -- infisical export --format yaml --path prod/
  ```

- Coordinate secret rotation with `automator` and update the changelog.
- On any update to secret configuration files or manifests, commit and push the
  changes, or open a pull request for review.

### 3.3 dev-orchestrator

- Execute host-specific deployments using `./scripts/deploy.ah <target>`.
- Verify edge network membership before applying changes
- After deployment run:

  ```bash
  ./scripts/status.sh
  ./scripts/health-check.sh
  ```

- If validation fails, initiate rollback via `./scripts/teardown.sh`
- Any changes to operational or deployment scripts driven by automation must
  be committed or submitted via PR.

### 3.4 security-sentinel

- Manage ClamAV stack, firewall, WAF signals, and Zero-Trust posture.
- Schedule malware scans and review logs:

  ```bash
  docker exec clamav clamscan -r /data --log=/var/log/clamav/nightly.log
  ```

- Coordinate with `api-gatekeeper` to enforce rate limits and key rotation.
- Document incidents in `~/server-changelog.md`.
- Following log or security policy updates, ensure a commit is pushed or a PR
  is created.

### 3.5 api-gatekeeper

- Own Kong declarative config (`services/kong/kong.yml`)
- Apply config updates:

  ```bash
  infisical run --env=production -- docker exec kong kong reload
  ```

- Rotate API keys through Infisical and ensure CF Access guards the admin
  interface.
- Validate routing alignment with Traefik and ClamAV hooks.
- On changes to Kong configuration or routing policies, commit and push or
  create a PR with the updates.

### 3.6 automator

- Operate n8n/Node-RED workflows stored in `automation/` (future directory).
- Tasks: backups, changelog sync, security notifications, DNS validation.
- Trigger daily maintenance:

  ```bash
  infisical run --env=production -- n8n execute --workflow daily-maintenance
  ```

- Publish run outcomes to `~/server-changelog.md` and alert channels.
- Ensure any automated modification of playbooks, scripts, or workflow
  definitions results in a commit or PR.

## 4. Inter-Agent Communication

- Use Infisical-secured webhooks (`INFISICAL_WEBHOOK_URL`) to broadcast events.
- Maintain message schema: `{ agent, action, status, timestamp, details }`.
- Shared Slack/Matrix channel for synchronous escalations (configured via
  Infisical tokens).
- All critical automation emits to the n8n event bus; `automator` maintains
  routing rules.

## 5. Deployment Workflow Synchronization

1. `infra-architect` prepares manifests and submits PR.
2. `secrets-keeper` validates secret coverage via Infisical.
3. `dev-orchestrator` runs preflight and executes deployment.
4. `security-sentinel` confirms firewall/WAF/ClamAV status.
5. `api-gatekeeper` reloads Kong and checks API policies.
6. `automator` schedules health checks and backups, updates changelog.
7. **Each agent records state modifications via commit or PR for traceability.**

## 6. Recovery & Redeployment

- Use `./scripts/teardown.sh` for graceful rollback; record the ticket in the
  changelog.
- Restore data from `~/.backup/<tier>/` using procedures in
  `infra-build-plan.md`.
- If Infisical outage occurs, follow emergency playbook:
  1. Switch to read-only mode, block new deployments.
  2. Export cached secrets:

     ```bash
     infisical export --format env --path prod/backup > /tmp/infisical-backup.env
     ```

  3. Restore service once the Infisical cluster is healthy, then delete the
     cache file.
- After recovery, `automator` triggers the audit workflow:

  ```bash
  infisical run --env=production -- n8n execute --workflow post-recovery-audit
  ```

- **All recovery work that updates infra/state/configuration files must be
  pushed as a commit or opened as a PR.**

## 9. Automation Agents

- `preflight-agent` — runs `scripts/preflight.sh` through Infisical; invoke via
  `python scripts/agents/run-agent.py run preflight-agent -- --env production`.
- `deploy-agent` — executes `scripts/deploy.ah <target>` through Infisical;
  pass `--target` (e.g. `vps.host`).
- `status-agent` — runs `scripts/status.sh` and optionally `scripts/health-check.sh`.
- `logger-agent` — consolidates infra change logs into `CHANGE.log`.
- `lint-resolver-agent` — applies language-aware lint fixers (e.g.
  `ruff --fix`) when lint violations are detected; supports `--watch` mode to
  poll for new diagnostics and auto-resolve them.
- Host wrappers live under `scripts/agents/*.sh` for cron/systemd orchestration.
- **All agents are responsible for pushing their own codebase or config changes
  as commits or opening pull requests, ensuring a complete audit trail for all
  automated operations.**

## 7. Documentation & Audit Duties

- Update `infra-build-plan.md` and `README.md` whenever services or workflows
  change.
- Append operational notes to `~/server-changelog.md` after every deployment or
  incident.
- Quarterly, `infra-architect` and `security-sentinel` co-sign compliance
  review stored in `docs/compliance/`.
- **All documentation updates initiated by agents must be committed and
  synchronized upstream.**

## 8. Incident Escalation

- Severity 0/1 incidents: Page on-call via Infisical webhook integration; halt
  deployments.
- Severity 2/3: Document in changelog, notify within 1 hour.
- Always attach remediation commands executed, e.g.:

  ```bash
  infisical run --env=production -- docker compose -f docker-compose/vps.host.yml restart traefik
  ```

These directives keep Cursor agents aligned with the infrastructure build plan
while preserving security, reproducibility, and observability.
**Committing or opening a PR for every agent-initiated change is mandatory for
continuous auditability.**
