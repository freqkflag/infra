# Infrastructure Virtual Agents

Specialized virtual agents for infrastructure analysis, each focused on a specific domain. These agents can be invoked individually or orchestrated together for comprehensive analysis.

## Available Agents

### 1. **status_agent** (`status-agent.md`)
Global project status and next steps tracker. Maintains architecture overview, current phase, overall health, and key findings.

**Use when:** You need a quick status check or overview of the infrastructure.

**Output:** Service status, blockers, key findings, architecture overview.

### 2. **bug_hunter** (`bug-hunter-agent.md`)
Aggressive bug scanner for errors, code smells, and instability.

**Use when:** You need to find bugs, warnings, or code smells.

**Output:** Critical bugs, warnings, code smells, recommended fixes.

### 3. **performance** (`performance-agent.md`)
Performance hotspot identifier and optimization suggester.

**Use when:** You need to identify performance bottlenecks or optimization opportunities.

**Output:** Hotspots, build/CI issues, dependency costs, optimization suggestions.

### 4. **security** (`security-agent.md`)
Security vulnerability scanner and misconfiguration detector.

**Use when:** You need to find security vulnerabilities, secret leaks, or misconfigurations.

**Output:** Vulnerabilities, secret leaks, misconfigurations, security recommendations.

### 5. **architecture** (`architecture-agent.md`)
Architecture analyzer for boundaries, consistency, and large-scale design.

**Use when:** You need to understand architecture, boundaries, or refactoring opportunities.

**Output:** Architecture overview, boundary violations, cross-service concerns, refactor opportunities.

### 6. **docs** (`docs-agent.md`)
Documentation gap identifier and structure proposer.

**Use when:** You need to identify missing documentation or propose doc structure.

**Output:** Missing docs, files to document, proposed doc structure, doc generation plan.

### 7. **tests** (`tests-agent.md`)
Test coverage analyzer and missing test identifier.

**Use when:** You need to analyze test coverage or identify missing tests.

**Output:** Coverage summary, missing tests, flaky tests, high-priority test targets.

### 8. **refactor** (`refactor-agent.md`)
Refactoring target identifier and duplication detector.

**Use when:** You need to find refactoring opportunities or duplication.

**Output:** Refactor targets, duplication groups, legacy patterns, simplifications.

### 9. **release** (`release-agent.md`)
Release readiness evaluator and release note drafter.

**Use when:** You need to evaluate release readiness or draft release notes.

**Output:** Release readiness, blockers, required changes, draft release notes.

## Usage

### Individual Agent Invocation

To invoke a single agent, use the agent's prompt directly:

```bash
# Example: Run bug_hunter
cat /root/infra/ai.engine/agents/bug-hunter-agent.md | cursor-ai
```

### Tool-Callable Agents

Each agent can be invoked via tool calls or AI instructions:

```
Act as bug_hunter. Scan /root/infra. Return crit bugs + fixes in strict JSON.
```

```
Act as security agent. Evaluate secrets, auth, exposure, configs. Strict JSON.
```

```
Act as architecture agent. Look for boundary violations + refactor targets.
```

### Orchestration

All agents can be orchestrated together using the multi-agent orchestrator:

```
Use the Multi-Agent Orchestrator preset. Focus on /root/infra first, then repo-wide context. 
Return a single strict JSON object with aggregated output from:
status_agent, bug_hunter, performance, security, architecture, docs, tests, refactor, release.
```

## Agent Characteristics

- **Aggressive**: Agents actively search for issues, don't wait for problems to surface
- **Proactive**: Agents recommend improvements without being asked
- **Large-repo aware**: Agents optimize for large, complex codebases
- **JSON output**: All agents output strict JSON (no reasoning, only conclusions)
- **Tool-callable**: Agents can be invoked via prompts, tool calls, or AI instructions

## Integration with Orchestrator

The orchestrator (`runbooks/infra-runbook.md`) coordinates all agents and aggregates their findings into a single comprehensive report. Individual agents can also be run independently for focused analysis.

## Agent Persistence

Agents maintain persistence through:
- Tracking previous findings and issues
- Remembering recurring problems
- Identifying patterns across runs
- Proactive state updates

## Quick Reference

| Agent | Purpose | Priority Output |
|-------|---------|----------------|
| `status_agent` | Global status | Service health, blockers |
| `bug_hunter` | Bug detection | Critical bugs, warnings |
| `performance` | Performance analysis | Hotspots, optimizations |
| `security` | Security scanning | Vulnerabilities, misconfigs |
| `architecture` | Architecture review | Boundaries, refactors |
| `docs` | Documentation gaps | Missing docs, structure |
| `tests` | Test coverage | Missing tests, priorities |
| `refactor` | Refactoring targets | Duplication, legacy code |
| `release` | Release readiness | Blockers, release notes |

---

**Last Updated:** 2025-11-21  
**Location:** `/root/infra/ai.engine/agents/`

