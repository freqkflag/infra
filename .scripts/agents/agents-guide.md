
## Creating New Infra Agents

Agents are small single-purpose automation units that Cursor can run from either the Mac or VPS.
Every agent should have:

* a **contract** entry in `agents.md`
* a **runtime module** stored in `.cursor/agents/<agent-name>.py`
* zero secrets inside the agent file (all secrets flow through Infisical)
* a predictable and auditable output to changelog
* an optional host wrapper in `scripts/agents/` when production hosts need to invoke it

---

### 1) name the agent

Names are always lowercase with hyphens:

* `logger-agent`
* `repo-linter`
* `compose-health`
* `backup-sync`

### 2) define the contract in agents.md

Every agent must get one block like this:

```yaml
- name: my-agent-name
  allowed_hosts:
    - mac
    - vps
  description: short sentence for what the agent does
  entrypoint: ./scripts/agents/my-agent-name.sh
  outputs:
    - ~/infra/server-changelog.md
  after_run:
    - git add .
    - git commit -m "my-agent-name run"
    - git push
```

The contract is the law. If two agents disagree → the contract wins.

### 3) create the agent module

Store all Cursor-facing agent modules under:

```
~/infra/.cursor/agents/<agent-name>.py
```

If you need a host-side wrapper (cron/systemd), copy one of the templates from
`scripts/agents/templates/` and place it in `scripts/agents/`.

Agents must:

* exit non-zero if failure
* never write secrets
* only append, never rewrite infra logs

example skeleton:

```bash
#!/usr/bin/env bash
set -eo pipefail

echo "# $(date -Iseconds) — my-agent-name" >> ~/infra/server-changelog.md
echo "- ran my-agent-name actions" >> ~/infra/server-changelog.md
```

### 4) declare the agent in the registry

Append the agent metadata to `.cursor/agents/registry.json`. Example block:

```json
{
  "module": ".cursor.agents.my_agent",
  "class": "MyAgent",
  "description": "Describe the automation.",
  "allowed_hosts": ["mac", "vps"],
  "outputs": ["~/infra/server-changelog.md"],
  "tags": ["automation"]
}
```

### 5) test locally before commit

```bash
python scripts/agents/run-agent.py describe my-agent-name
python scripts/agents/run-agent.py run my-agent-name -- --dry-run
```

### 6) commit the new agent

```bash
git add agents.md .cursor/agents/my-agent-name.py .cursor/agents/registry.json
git commit -m "add my-agent-name"
git push
```

---

### future flow

later when we start publishing wiki pages to freqkflag.co/docs — these same agent outputs become indexable source material.

this structure keeps the infra human readable and recoverable.
