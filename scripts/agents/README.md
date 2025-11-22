# Infra Agent System

This directory defines the shared runtime used by both Cursor automations and
production hosts to execute infra agents.

## Components

- `run-agent.py` — CLI wrapper that loads the agent registry and invokes the
  requested agent with the same runtime used inside `.cursor`.
- `templates/` — Skeletons for new agents (bash or python). Copy one into
  `.cursor/agents/` and update `registry.json`.
- `registry.template.json` — Example registry payload for onboarding new
  agents without touching production entries.

## Usage

### List registered agents

```bash
python scripts/agents/run-agent.py list
```

### Describe an agent contract

```bash
python scripts/agents/run-agent.py describe logger-agent
```

### Execute an agent (direct)

```bash
python scripts/agents/run-agent.py run logger-agent -- --dry-run
python scripts/agents/run-agent.py run lint-resolver-agent -- --file .cursor/agents/lint_resolver_agent.py
python scripts/agents/run-agent.py run lint-resolver-agent -- --watch
```

All arguments placed after `--` are passed directly to the agent.

### Execute arbitrary script blocks (non-interactive)

For dispatcher/automation use cases (e.g., Runme), execute arbitrary Python code blocks:

```bash
python scripts/agents/run-agent.py run <agent> -- --script <tempfile>
```

The script file is executed as Python code with access to:
- `agent`: The instantiated agent instance
- `registry`: The agent registry
- `REPO_ROOT`: Repository root path
- Standard library modules (`os`, `sys`, `json`, `subprocess`, `tempfile`, `Path`)

Example script:
```python
# Access the agent instance
print(f"Running agent: {agent.name}")
print(f"Agent config: {agent.config}")

# Access registry
print(f"Available agents: {list(registry['agents'].keys())}")

# Use REPO_ROOT
config_file = REPO_ROOT / ".cursor" / "agents" / "registry.json"
print(f"Registry path: {config_file}")

# Scripts can call agent methods or perform arbitrary operations
result = agent.run(["--dry-run"])
sys.exit(result)
```

### Execute via host-friendly wrappers

```bash
scripts/agents/preflight-agent.sh --env production
scripts/agents/deploy-agent.sh --target vps.host --env production
scripts/agents/status-agent.sh --skip-health
```

Wrappers simply forward arguments to `run-agent.py` from the repository root.

## Adding a New Agent

1. Copy a template from `templates/` into `.cursor/agents/<agent-name>.py`
   (or `.sh`).
2. Implement the agent logic, returning a zero exit code on success.
3. Append the agent definition to `.cursor/agents/registry.json` with:
   - `module_path`: relative path to the module (`.cursor/agents/<agent>.py`)
   - `class`: exported class deriving from the `BaseAgent` defined in `.cursor/agents/base.py`
   - `allowed_hosts`, `outputs`, `tags`, and any other metadata.
4. Expose a wrapper in `scripts/agents/` if host-side execution is required.
5. Update `AGENTS.md` and infra changelog.

## Production Invocation

Host automation (cron/systemd/n8n) can call:

```bash
/usr/bin/env python3 /Users/freqkflag/Projects/GitHub/infra/scripts/agents/run-agent.py run <agent-name>
```

Set `AGENT_HOST=<host-label>` in the environment when running outside Cursor.
