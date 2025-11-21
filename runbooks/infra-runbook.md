
Infra Playbook (One-Page)

Location: /root/infra/INFRA_PLAYBOOK.md
Purpose: Central guide for running the Cursor Multi-Agent Infra Orchestrator and maintaining the infra layer.

⸻

1. Directory Purpose

/root/infra contains all infrastructure code and operational assets:
	•	IaC (Terraform/Pulumi/CloudFormation)
	•	CI/CD pipelines
	•	Deployment tooling
	•	Service wiring & configs
	•	Observability & security settings

Cursor’s Multi-Agent Orchestrator treats this directory as the authoritative infra root.

⸻

2. Multi-Agent Orchestrator (Primary Agent)

Paste this into a Cursor system prompt to run the orchestrator:

Use the Multi-Agent Orchestrator preset. Focus on /root/infra first, then repo-wide context. 
Return a single strict JSON object with aggregated output from:
status_agent, bug_hunter, performance, security, architecture, docs, tests, refactor, release.

Include:
- Key findings
- Prioritized next steps
- Risks/blockers
- Exec: cursor_instructions + shell_commands

No chain-of-thought. Concise but technically rigorous.


⸻

3. How to Run an Orchestration Cycle
	1.	Open Cursor → Load the Orchestrator prompt
	2.	Tell it to analyze /root/infra first, then expand outward.
	3.	Review returned JSON:
	•	global_next_steps.prioritized_actions → your task list
	•	exec.cursor_instructions → actions Cursor can apply
	•	exec.shell_commands → manual commands (review before running)
	4.	Save the JSON to:
/root/infra/orchestration/YYYY-MM-DD.json
	5.	Update /root/infra/INFRA_STATE.md with:
	•	What’s done
	•	What’s pending
	•	New risks/debt

⸻

4. Recommended Files

/root/infra/
  INFRA_PLAYBOOK.md        ← this file  
  INFRA_STATE.md           ← rolling infra status  
  orchestration/           ← stored orchestration JSONs  
  ci/                      ← pipelines  
  deployments/             ← environment deploy logic  
  configs/                 ← shared configs  
  docs/                    ← infra documentation  


⸻

5. Persistence Workflow

To simulate persistent memory between runs:
	1.	Save each orchestration JSON inside /root/infra/orchestration/.
	2.	Maintain a simple state file at:
/root/infra/INFRA_STATE.md
	3.	At the start of each Cursor session, run:

Load context from /root/infra/INFRA_STATE.md and the most recent orchestration file. 
Update your analysis and next steps accordingly.

This keeps Cursor “stateful” across sessions.

⸻

6. Using Sub-Agents Directly

For targeted scans (faster than a full orchestration):
	•	Bug scan:
Act as bug_hunter. Scan /root/infra. Return crit bugs + fixes in strict JSON.
	•	Security scan:
Act as security agent. Evaluate secrets, auth, exposure, configs. Strict JSON.
	•	Architecture check:
Act as architecture agent. Look for boundary violations + refactor targets.
	•	Test coverage:
Act as tests agent. Identify missing tests for infra scripts/modules.

⸻

7. Cadence
	•	Weekly: Full multi-agent orchestration
	•	Before releases: Run release agent + security agent
	•	After major changes: Run architecture + bug_hunter
	•	Continuous improvement: Follow prioritized actions from JSON

⸻

8. Golden Rule

Always follow the JSON output structure and execute the top priorities listed in global_next_steps.
Cursor becomes the planner; you execute or delegate.

⸻

If you want, I can also generate:
✅ a matching INFRA_STATE.md template
✅ a bootstrap shell script to create the entire /root/infra layout
Just tell me.