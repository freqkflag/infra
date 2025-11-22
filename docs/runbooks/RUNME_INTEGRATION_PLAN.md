# Runme & Runbook Integration Plan

**Created:** 2025-11-22  
**Location:** `/root/infra/docs/runbooks/`  
**Status:** Draft requirements for expanding runbook automation

---

## Objectives

1. **Execution Dispatch Choice** – Every runnable section inside a runbook (or any `runme` block) should prompt the operator to choose whether the command executes directly in the terminal or whether it should be forwarded to a new Cursor agent chat for execution/validation.
2. **Built-in Orchestration Prompts** – Newly generated runbooks must bundle copy/paste-ready AI prompts so operators can immediately launch orchestration or service-scoped agents without digging through other docs.

---

## Requirement 1 — Execution Target Selector

### Desired UX

1. Operator clicks **Run** on a `runme` block embedded in a runbook.
2. A lightweight dispatcher asks:  
   `Choose execution target: (1) Local Terminal  (2) Cursor Agent`.
3. The dispatcher either:
   - Runs the captured block locally (respecting the environment variables already provided by Runme), **or**
   - Launches a fresh Cursor agent chat preloaded with the same commands/prompts so that automation can continue inside Cursor.

### Proposed Implementation

| Step | Action | Notes |
|------|--------|-------|
| 1 | **Create `scripts/runme-dispatch.sh`** | Bash script that reads stdin, writes it to a temp file, and displays a simple `select` menu (use `gum` if available, fallback to POSIX `select`). |
| 2 | **Local execution path** | `bash "$tempfile"` (or `env -i "$SHELL"` for clean env) so Runme keeps the context. Capture exit code and bubble up to Runme. |
| 3 | **Cursor agent path** | Pipe the command and surrounding context into an agent starter. Minimal version: `python scripts/agents/run-agent.py run status-agent -- --prompt-file "$tempfile"` (requires extending `status-agent`/`runner` to accept adhoc prompts). Stretch goal: call `ai.engine/scripts/invoke-agent.sh orchestrator "$tempfile"` and auto-open a new Cursor chat via CLI integration once available. |
| 4 | **Metadata handshake** | Annotate every runbook block with `{"runme":{"label":"<action>","dispatch":"cursor"}}` so Runme knows to call the dispatcher wrapper. (Template now documents this expectation.) |
| 5 | **Telemetry (optional)** | Emit events to the n8n bus or `CHANGE.log` when a block is routed to Cursor for traceability. |

### Additional Considerations

- **Security:** Restrict which agents may be launched automatically (env var such as `RUNME_ALLOWED_AGENTS="status-agent,deploy-agent"`).
- **Extensibility:** Dispatcher can accept flags (e.g., `--agent orchestrator`, `--default local`) so different blocks specify preferred defaults.
- **Cursor Integration:** If Cursor exposes a CLI (e.g., `cursor agents run <preset>`), wire the dispatcher to call it; otherwise fall back to printing the prompt and instructing the operator to paste it manually.

---

## Requirement 2 — Auto-Created Orchestration Prompts

### Current Progress

- `runbooks/TEMPLATE_SERVICE_RUNBOOK.md` now contains a dedicated **Runme & Cursor Automation Hooks** section.
- Each template includes:
  - A snippet showing how to tag `runme` metadata.
  - Three copy/paste-ready AI prompts (multi-agent sweep, status-agent health check, deployment runner restart) customized with `[service-id]`, `[service-dir]`, and `[Service Name]` placeholders so `scripts/generate-runbooks.py` stamps service-specific prompts automatically.

### Remaining Enhancements

1. **Generator Awareness:** Optionally update `scripts/generate-runbooks.py` to auto-generate UUIDs for Runme block IDs (if `runme` requires uniqueness across files).
2. **WikiJS Sync:** Ensure `runbooks/WIKIJS_INDEX.md` references the new automation section so operators know prompts exist when browsing WikiJS.
3. **Prompt Catalog Linkage:** Mirror the same prompts inside `ai.engine/PROMPT_CATALOG.md` for central visibility.

---

## Suggested Implementation Steps

1. Act as Automator. Prototype `scripts/runme-dispatch.sh` that reads stdin, prompts for execution target (local shell vs Cursor agent), and either runs the commands or emits a ready-to-paste agent prompt with service metadata. Expected: dispatcher script committed with basic selection workflow.
2. Act as Review Agent. Extend `.cursor/agents/runner.py` (or add a wrapper) so `python scripts/agents/run-agent.py run <agent> -- --script <tempfile>` executes arbitrary blocks routed from Runme. Expected: dispatcher can launch Cursor agents non-interactively.
3. Act as Documentation Scribe. Re-run `scripts/generate-runbooks.py` (or manually patch legacy runbooks) so each file contains the new "Runme & Cursor Automation Hooks" section and validated placeholders. Expected: runbook library consistently advertises automation prompts.
4. Act as MCP Integrator. Update `.cursor/mcp.json` and/or Cursor presets to include the orchestrator prompt referenced in the template so "send to Cursor" opens the correct preset automatically. Expected: reproducible instructions for launching the agent chat from IDE.
5. Act as Security Sentinel. Document the dispatcher workflow in `INFRASTRUCTURE_COOKBOOK.md`, note auditing/logging expectations, and append a `CHANGE.log` entry whenever the dispatcher is introduced. Expected: traceability for automation routing decisions.

---

## Open Questions

- Does Runme currently expose lifecycle hooks we can intercept? If not, the dispatcher must be called explicitly inside each block (e.g., `cat <<'EOF' | ./scripts/runme-dispatch.sh --agent orchestrator ...`).
- Should every block default to local execution, or should critical actions (deploy/teardown) default to Cursor-supervised execution?
- How should secrets be handled when a block is shipped to Cursor? (Likely rely on Infisical and avoid printing `.env` contents.)

---

**Next Review:** After dispatcher prototype exists or when Cursor CLI exposes agent spawning hooks.
