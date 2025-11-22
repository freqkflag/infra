# Virtual Agents Summary

**Created:** 2025-11-21  
**Location:** `/root/infra/ai.engine/agents/`

## ✅ Created Agents

### Core Agents (9 specialized agents)

1. **status_agent** (`status-agent.md`) - Global project status + next steps
2. **bug_hunter** (`bug-hunter-agent.md`) - Errors, smells, instability
3. **performance** (`performance-agent.md`) - Performance hotspots, build/CI bottlenecks
4. **security** (`security-agent.md`) - Vulnerabilities, secrets, insecure patterns
5. **architecture** (`architecture-agent.md`) - Architecture & boundaries, consistency
6. **docs** (`docs-agent.md`) - Documentation gaps and structure
7. **tests** (`tests-agent.md`) - Test coverage, missing tests, flaky tests
8. **refactor** (`refactor-agent.md`) - Refactor & cleanup strategy
9. **release** (`release-agent.md`) - Release readiness, blockers, release notes

### Integration Agent

10. **mcp_agent** (`mcp-agent.md`) - MCP server integration and tool usage guidance

### Orchestration Agent

11. **orchestrator** (`orchestrator-agent.md`) - Multi-agent orchestrator coordinating all agents

## Helper Scripts

- **invoke-agent.sh** - Invoke individual agents or orchestrator
- **list-agents.sh** - List all available agents

## Usage Examples

### Quick Invocation

```bash
cd /root/infra/ai.engine/scripts

# List available agents
./list-agents.sh

# Invoke bug-hunter agent
./invoke-agent.sh bug-hunter

# Invoke orchestrator (full analysis)
./invoke-agent.sh orchestrator /root/infra/orchestration-report.json
```

### Cursor AI Integration

```bash
# Individual agent
cat /root/infra/ai.engine/agents/bug-hunter-agent.md | cursor-ai

# Orchestrator (all agents)
cat /root/infra/ai.engine/agents/orchestrator-agent.md | cursor-ai > report.json
```

### Direct Prompt Usage

```
Act as bug_hunter. Scan /root/infra. Return crit bugs + fixes in strict JSON.
```

```
Use the Multi-Agent Orchestrator preset. Focus on /root/infra first, then repo-wide context. 
Return a single strict JSON object with aggregated output from:
status_agent, bug_hunter, performance, security, architecture, docs, tests, refactor, release, mcp_agent.
```

### MCP Integration

All agents can use MCP (Model Context Protocol) servers for infrastructure operations:

- **Infisical MCP** - Secrets management (`mcp_infisical_*` tools)
- **Cloudflare MCP** - DNS management (`mcp_cloudflare_*` tools)
- **WikiJS MCP** - Documentation management (`mcp_wikijs_*` tools)
- **Browser MCP** - Browser automation (`mcp_cursor-ide-browser_*` tools)

**See [MCP_INTEGRATION.md](../MCP_INTEGRATION.md) for complete MCP integration documentation.**

**Example with MCP:**
```
Act as security agent. Use Infisical MCP to audit secrets, then evaluate /root/infra. 
Return vulnerabilities + fixes in strict JSON.
```

## Agent Characteristics

- ✅ **Aggressive**: Actively search for issues, don't wait for problems
- ✅ **Proactive**: Recommend improvements without being asked
- ✅ **Large-repo aware**: Optimize for large, complex codebases
- ✅ **JSON output**: Strict JSON (no reasoning, only conclusions)
- ✅ **Tool-callable**: Can be invoked via prompts, tool calls, or AI instructions
- ✅ **Reusable**: Each agent is standalone and can be used independently

## Output Format

All agents output strict JSON with structured fields:

- **status_agent**: `{ summary, architecture, current_phase, overall_health, key_findings, service_status, blockers, recurring_issues }`
- **bug_hunter**: `{ critical_bugs, warnings, code_smells, recommended_fixes }`
- **performance**: `{ hotspots, build_and_ci_issues, dependency_costs, optimization_suggestions }`
- **security**: `{ vulnerabilities, secret_leaks, misconfigurations, security_recommendations }`
- **architecture**: `{ architecture_overview, boundary_violations, cross_service_concerns, refactor_opportunities }`
- **docs**: `{ missing_docs, files_to_document, proposed_doc_structure, doc_generation_plan }`
- **tests**: `{ coverage_summary, missing_tests, flaky_tests, high_priority_test_targets }`
- **refactor**: `{ refactor_targets, duplication_groups, legacy_patterns, simplifications }`
- **release**: `{ release_readiness, blockers, required_changes, draft_release_notes }`
- **mcp_agent**: `{ mcp_servers_available, mcp_opportunities, mcp_integration_recommendations, mcp_usage_patterns, missing_mcp_integrations, mcp_best_practices }`
- **orchestrator**: Aggregates all agent outputs + `{ global_next_steps, exec }`

## Files Created

```
/root/infra/ai.engine/
├── agents/
│   ├── status-agent.md          ✅
│   ├── bug-hunter-agent.md      ✅
│   ├── performance-agent.md     ✅
│   ├── security-agent.md        ✅
│   ├── architecture-agent.md    ✅
│   ├── docs-agent.md            ✅
│   ├── tests-agent.md           ✅
│   ├── refactor-agent.md        ✅
│   ├── release-agent.md         ✅
│   ├── development-agent.md     ✅
│   ├── ops-agent.md             ✅
│   ├── mcp-agent.md             ✅
│   ├── orchestrator-agent.md    ✅
│   └── README.md                ✅
├── scripts/
│   ├── invoke-agent.sh          ✅
│   └── list-agents.sh           ✅
├── PROMPT_CATALOG.md            ✅
├── MCP_INTEGRATION.md           ✅
├── README.md                     ✅
└── AGENTS_SUMMARY.md            ✅ (this file)
```

## Next Steps

1. ✅ **Agents created** - All specialized agents defined
2. ✅ **Scripts created** - Helper scripts for invocation
3. ✅ **Documentation created** - README and usage guides
4. ⏭️ **Test agents** - Run individual agents to verify output
5. ⏭️ **Integrate orchestrator** - Use in weekly analysis workflow
6. ⏭️ **CI/CD integration** - Add agents to CI/CD pipeline if needed

## Integration Points

- **Infrastructure Runbook** (`/root/infra/runbooks/infra-runbook.md`) - Orchestrator usage
- **Orchestration Reports** (`/root/infra/orchestration/`) - Save orchestration JSONs
- **CI/CD Pipeline** - Can invoke agents in automated workflows
- **MCP Servers** - Direct infrastructure service access via MCP tools
  - Infisical MCP (`@infisical/mcp`) - Secrets management
  - Cloudflare MCP (custom) - DNS management
  - WikiJS MCP (custom) - Documentation management
  - Browser MCP (built-in) - Browser automation

## MCP Integration

**See [MCP_INTEGRATION.md](../MCP_INTEGRATION.md) for complete MCP integration documentation.**

All agents can use MCP tools through function calling. MCP servers provide direct access to:
- Secrets management (Infisical)
- DNS configuration (Cloudflare)
- Documentation (WikiJS)
- Browser automation (Cursor IDE)

---

**Status:** ✅ Complete  
**Ready for use:** Yes  
**MCP Integration:** ✅ Available

