# Infrastructure AI Engine

AI-powered analysis and orchestration system for infrastructure management.

## Overview

The AI Engine provides specialized virtual agents for comprehensive infrastructure analysis. Each agent focuses on a specific domain and outputs structured JSON for easy integration and automation.

## Directory Structure

```
ai.engine/
├── agents/              # Virtual agent definitions
│   ├── status-agent.md
│   ├── bug-hunter-agent.md
│   ├── performance-agent.md
│   ├── security-agent.md
│   ├── architecture-agent.md
│   ├── docs-agent.md
│   ├── tests-agent.md
│   ├── refactor-agent.md
│   ├── release-agent.md
│   ├── orchestrator-agent.md
│   └── README.md
└── scripts/             # Helper scripts
    ├── invoke-agent.sh
    └── list-agents.sh
```

## Quick Start

### List Available Agents

```bash
cd /root/infra/ai.engine/scripts
./list-agents.sh
```

### Invoke an Agent

```bash
# Invoke bug-hunter agent
./invoke-agent.sh bug-hunter

# Invoke orchestrator (full analysis)
./invoke-agent.sh orchestrator /root/infra/orchestration-report.json
```

### Use Agents in Cursor

1. **Individual Agent:**
   ```
   Act as bug_hunter. Scan /root/infra. Return crit bugs + fixes in strict JSON.
   ```

2. **Orchestrator (All Agents):**
   ```
   Use the Multi-Agent Orchestrator preset. Focus on /root/infra first, then repo-wide context. 
   Return a single strict JSON object with aggregated output from:
   status_agent, bug_hunter, performance, security, architecture, docs, tests, refactor, release.
   ```

3. **Read Agent File:**
   ```bash
   cat /root/infra/ai.engine/agents/bug-hunter-agent.md
   ```
   Then provide the content to Cursor AI.

## Available Agents

### 1. **status_agent** (`status-agent.md`)
Global project status and next steps tracker.

**Output:** Service status, blockers, key findings, architecture overview.

**Use when:** Quick status check or infrastructure overview.

### 2. **bug_hunter** (`bug-hunter-agent.md`)
Aggressive bug scanner for errors, code smells, and instability.

**Output:** Critical bugs, warnings, code smells, recommended fixes.

**Use when:** Finding bugs, warnings, or code smells.

### 3. **performance** (`performance-agent.md`)
Performance hotspot identifier and optimization suggester.

**Output:** Hotspots, build/CI issues, dependency costs, optimization suggestions.

**Use when:** Identifying performance bottlenecks or optimization opportunities.

### 4. **security** (`security-agent.md`)
Security vulnerability scanner and misconfiguration detector.

**Output:** Vulnerabilities, secret leaks, misconfigurations, security recommendations.

**Use when:** Finding security vulnerabilities, secret leaks, or misconfigurations.

### 5. **architecture** (`architecture-agent.md`)
Architecture analyzer for boundaries, consistency, and large-scale design.

**Output:** Architecture overview, boundary violations, cross-service concerns, refactor opportunities.

**Use when:** Understanding architecture, boundaries, or refactoring opportunities.

### 6. **docs** (`docs-agent.md`)
Documentation gap identifier and structure proposer.

**Output:** Missing docs, files to document, proposed doc structure, doc generation plan.

**Use when:** Identifying missing documentation or proposing doc structure.

### 7. **tests** (`tests-agent.md`)
Test coverage analyzer and missing test identifier.

**Output:** Coverage summary, missing tests, flaky tests, high-priority test targets.

**Use when:** Analyzing test coverage or identifying missing tests.

### 8. **refactor** (`refactor-agent.md`)
Refactoring target identifier and duplication detector.

**Output:** Refactor targets, duplication groups, legacy patterns, simplifications.

**Use when:** Finding refactoring opportunities or duplication.

### 9. **release** (`release-agent.md`)
Release readiness evaluator and release note drafter.

**Output:** Release readiness, blockers, required changes, draft release notes.

**Use when:** Evaluating release readiness or drafting release notes.

### 10. **orchestrator** (`orchestrator-agent.md`)
Multi-agent orchestrator that coordinates all agents.

**Output:** Complete JSON report with all agent findings aggregated.

**Use when:** Comprehensive infrastructure analysis or full orchestration.

## Agent Characteristics

- **Aggressive**: Agents actively search for issues, don't wait for problems to surface
- **Proactive**: Agents recommend improvements without being asked
- **Large-repo aware**: Agents optimize for large, complex codebases
- **JSON output**: All agents output strict JSON (no reasoning, only conclusions)
- **Tool-callable**: Agents can be invoked via prompts, tool calls, or AI instructions

## Integration Examples

### Cursor Integration

```bash
# Example 1: Quick bug scan
cat /root/infra/ai.engine/agents/bug-hunter-agent.md | cursor-ai

# Example 2: Security audit
cat /root/infra/ai.engine/agents/security-agent.md | cursor-ai

# Example 3: Full orchestration
cat /root/infra/ai.engine/agents/orchestrator-agent.md | cursor-ai > orchestration-report.json
```

### Script Integration

```bash
#!/bin/bash
# Run bug-hunter and save results
./invoke-agent.sh bug-hunter /tmp/bugs.json

# Parse JSON results
jq '.critical_bugs[] | select(.severity == "CRITICAL")' /tmp/bugs.json
```

### CI/CD Integration

```yaml
# Example GitHub Actions workflow
- name: Run Security Agent
  run: |
    cd /root/infra/ai.engine/scripts
    ./invoke-agent.sh security security-report.json
  continue-on-error: true
```

## Agent Output Format

All agents output strict JSON with the following structure:

```json
{
  "field1": "...",
  "field2": [...],
  ...
}
```

Each agent has its own specific output format. See individual agent files for details.

## Best Practices

1. **Run orchestrator weekly** for comprehensive analysis
2. **Run security agent** before releases
3. **Run bug_hunter** after major changes
4. **Run status_agent** for quick health checks
5. **Save outputs** for tracking changes over time

## Workflow

### Weekly Analysis
```bash
./invoke-agent.sh orchestrator /root/infra/orchestration/$(date +%Y-%m-%d).json
```

### Pre-Release Checklist
```bash
./invoke-agent.sh release release-readiness.json
./invoke-agent.sh security security-audit.json
./invoke-agent.sh tests test-coverage.json
```

### Quick Health Check
```bash
./invoke-agent.sh status /tmp/status.json
```

## Agent Persistence

Agents maintain persistence through:
- Tracking previous findings and issues
- Remembering recurring problems
- Identifying patterns across runs
- Proactive state updates

## Troubleshooting

### Agent not found
```bash
# List available agents
./list-agents.sh

# Check agent file exists
ls -la /root/infra/ai.engine/agents/
```

### Invalid JSON output
- Ensure agent file is properly formatted
- Check Cursor AI has access to the codebase
- Verify /root/infra directory exists and is readable

### Agent timeout
- For large repos, agents may take time to analyze
- Consider running individual agents instead of orchestrator
- Check system resources (CPU, memory)

## Related Documentation

- [Agents README](./agents/README.md) - Detailed agent documentation
- [Infrastructure Runbook](../runbooks/infra-runbook.md) - Orchestrator usage
- [Infrastructure Cookbook](../INFRASTRUCTURE_COOKBOOK.md) - Infrastructure reference

---

**Last Updated:** 2025-11-21  
**Location:** `/root/infra/ai.engine/`

