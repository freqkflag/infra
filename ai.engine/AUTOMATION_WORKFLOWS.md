# AI Engine Automation Workflows

**Created:** 2025-11-22  
**Location:** `/root/infra/ai.engine/`  
**Purpose:** Complete automation workflow system for all AI Engine agents

## Overview

This document defines the complete automation system for triggering and orchestrating all AI Engine agents. The system uses n8n, Node-RED, webhooks, scheduled tasks, and event-driven triggers to automate agent execution.

## Automation Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Automation Triggers                       │
├─────────────────────────────────────────────────────────────┤
│  • Scheduled (Cron/Systemd)                                 │
│  • Webhook Events                                            │
│  • Docker Events                                             │
│  • Health Check Failures                                     │
│  • Git Events (PR, Push, Merge)                             │
│  • Manual API Calls                                          │
└───────────────────┬─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────┐
│              Orchestration Layer (n8n/Node-RED)             │
├─────────────────────────────────────────────────────────────┤
│  • Route events to appropriate agents                        │
│  • Aggregate agent outputs                                   │
│  • Store results and trigger notifications                   │
│  • Handle errors and retries                                 │
└───────────────────┬─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────┐
│                  Agent Execution Layer                       │
├─────────────────────────────────────────────────────────────┤
│  • ai.engine/scripts/invoke-agent.sh                        │
│  • Individual agent scripts                                  │
│  • Orchestrator for multi-agent runs                        │
└───────────────────┬─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────┐
│                    Output & Storage                          │
├─────────────────────────────────────────────────────────────┤
│  • JSON reports in orchestration/                           │
│  • CHANGELOG entries                                         │
│  • Webhook notifications                                     │
│  • WikiJS documentation updates                              │
└─────────────────────────────────────────────────────────────┘
```

## Available Agents

### Core Analysis Agents (14 agents)

| Agent | Purpose | Trigger Frequency | Output Location |
|-------|---------|-------------------|-----------------|
| **status** | Global project status | Daily, On-demand | `orchestration/status-{date}.json` |
| **bug-hunter** | Bug scanner | On PR, Daily, On failure | `orchestration/bugs-{date}.json` |
| **performance** | Performance hotspots | Weekly, On-demand | `orchestration/performance-{date}.json` |
| **security** | Security vulnerabilities | On PR, Weekly, On alert | `orchestration/security-{date}.json` |
| **architecture** | Architecture analysis | Weekly, On major changes | `orchestration/architecture-{date}.json` |
| **docs** | Documentation gaps | Weekly, On new features | `orchestration/docs-{date}.json` |
| **tests** | Test coverage | On PR, Weekly | `orchestration/tests-{date}.json` |
| **refactor** | Refactoring targets | Monthly, On-demand | `orchestration/refactor-{date}.json` |
| **release** | Release readiness | Pre-release, Weekly | `orchestration/release-{date}.json` |
| **development** | Full technical sweep | Weekly, On-demand | `orchestration/development-{date}.json` |
| **ops** | Infrastructure operations | On alert, Hourly, On-demand | `orchestration/ops-{date}.json` |
| **backstage** | Backstage portal management | Daily, On catalog change | `orchestration/backstage-{date}.json` |
| **mcp** | MCP integration guidance | On-demand, Monthly | `orchestration/mcp-{date}.json` |
| **orchestrator** | Multi-agent orchestration | Weekly, On-demand | `orchestration/orchestration-{date}.json` |

## Automation Trigger Events

### 1. Scheduled Triggers

#### Daily Automation
```bash
# Status check (runs at 00:00 UTC daily)
0 0 * * * /root/infra/ai.engine/scripts/status.sh /root/infra/orchestration/status-$(date +\%Y\%m\%d).json

# Ops check (runs at top of every hour)
0 * * * * /root/infra/ai.engine/scripts/ops.sh /root/infra/orchestration/ops-$(date +\%Y\%m\%d-\%H\%M).json

# Backstage health check (runs daily at 06:00 UTC)
0 6 * * * /root/infra/ai.engine/scripts/backstage.sh /root/infra/orchestration/backstage-$(date +\%Y\%m\%d).json
```

#### Weekly Automation
```bash
# Full orchestration (runs every Sunday at 02:00 UTC)
0 2 * * 0 /root/infra/ai.engine/scripts/orchestrator.sh /root/infra/orchestration/orchestration-$(date +\%Y\%m\%d).json

# Security audit (runs every Monday at 03:00 UTC)
0 3 * * 1 /root/infra/ai.engine/scripts/security.sh /root/infra/orchestration/security-$(date +\%Y\%m\%d).json

# Performance analysis (runs every Wednesday at 04:00 UTC)
0 4 * * 3 /root/infra/ai.engine/scripts/performance.sh /root/infra/orchestration/performance-$(date +\%Y\%m\%d).json

# Documentation check (runs every Friday at 05:00 UTC)
0 5 * * 5 /root/infra/ai.engine/scripts/docs.sh /root/infra/orchestration/docs-$(date +\%Y\%m\%d).json
```

#### Monthly Automation
```bash
# Refactoring analysis (runs on 1st of month at 06:00 UTC)
0 6 1 * * /root/infra/ai.engine/scripts/refactor.sh /root/infra/orchestration/refactor-$(date +\%Y\%m).json

# MCP integration review (runs on 15th of month at 07:00 UTC)
0 7 15 * * /root/infra/ai.engine/scripts/mcp.sh /root/infra/orchestration/mcp-$(date +\%Y\%m).json
```

### 2. Webhook Triggers

#### Agent Event Webhook
**Endpoint:** `https://n8n.freqkflag.co/webhook/agent-events`  
**Purpose:** Accept agent execution requests via HTTP POST  
**Payload:**
```json
{
  "agent": "bug-hunter",
  "trigger": "manual|webhook|scheduled|event",
  "output_file": "/root/infra/orchestration/bugs-{timestamp}.json",
  "metadata": {
    "source": "github-webhook",
    "event": "pull_request",
    "pr_number": 123
  }
}
```

#### Health Check Failure Webhook
**Endpoint:** `https://n8n.freqkflag.co/webhook/health-alert`  
**Purpose:** Trigger ops-agent on health check failure  
**Payload:**
```json
{
  "service": "traefik",
  "status": "unhealthy",
  "health_check": "failed",
  "timestamp": "2025-11-22T12:00:00Z",
  "trigger_agent": "ops"
}
```

#### Docker Event Webhook
**Endpoint:** `https://n8n.freqkflag.co/webhook/docker-events`  
**Purpose:** Trigger agents on Docker container events  
**Payload:**
```json
{
  "event": "die|start|health_status: unhealthy",
  "container": "traefik",
  "timestamp": "2025-11-22T12:00:00Z",
  "trigger_agent": "ops"
}
```

### 3. Event-Driven Triggers

#### Docker Events
```bash
# Monitor Docker events and trigger ops-agent on failures
docker events --filter 'event=die' --filter 'event=health_status: unhealthy' \
  --format '{{json .}}' | while read event; do
    curl -X POST https://n8n.freqkflag.co/webhook/docker-events \
      -H "Content-Type: application/json" \
      -d "$event"
done
```

#### Health Check Failures
```bash
# Health check script triggers webhook on failure
/root/infra/scripts/automated-health-check.sh
# On failure: POST to /webhook/health-alert
```

#### Git Events (GitHub/GitLab)
```yaml
# GitHub Actions workflow
on:
  pull_request:
    types: [opened, synchronize, reopened]
  push:
    branches: [main, develop]
jobs:
  trigger-bug-hunter:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger bug-hunter
        run: |
          curl -X POST https://n8n.freqkflag.co/webhook/agent-events \
            -H "Content-Type: application/json" \
            -d '{"agent":"bug-hunter","trigger":"github-webhook","event":"${{ github.event_name }}"}'
```

### 4. Manual API Triggers

#### Direct Agent Invocation
```bash
# Via script
/root/infra/ai.engine/scripts/invoke-agent.sh bug-hunter /tmp/output.json

# Via HTTP API (if implemented)
curl -X POST https://api.freqkflag.co/agents/invoke \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"agent":"bug-hunter","output_file":"/tmp/output.json"}'
```

## n8n Workflows

### Workflow 1: Agent Event Router

**Purpose:** Route webhook events to appropriate agents  
**Trigger:** Webhook `https://n8n.freqkflag.co/webhook/agent-events`  
**Nodes:**
1. Webhook (receive event)
2. Switch (route by agent name)
3. HTTP Request (invoke agent script via SSH/API)
4. Set (format output)
5. HTTP Request (store results)
6. HTTP Request (send notification)

**Workflow JSON:** See `workflows/n8n/agent-event-router.json`

### Workflow 2: Health Check Monitor

**Purpose:** Monitor health checks and trigger ops-agent  
**Trigger:** Webhook `https://n8n.freqkflag.co/webhook/health-alert`  
**Nodes:**
1. Webhook (receive health alert)
2. Filter (critical alerts only)
3. HTTP Request (invoke ops-agent)
4. Set (format alert)
5. HTTP Request (send to Alertmanager)
6. HTTP Request (log to WikiJS)

**Workflow JSON:** See `workflows/n8n/health-check-monitor.json`

### Workflow 3: Scheduled Agent Runner

**Purpose:** Execute scheduled agent runs  
**Trigger:** Cron expression  
**Nodes:**
1. Cron (daily/weekly/monthly schedule)
2. Switch (route by schedule type)
3. HTTP Request (invoke agent script)
4. Set (format results)
5. HTTP Request (store in orchestration/)
6. HTTP Request (update CHANGELOG)

**Workflow JSON:** See `workflows/n8n/scheduled-agent-runner.json`

### Workflow 4: Orchestrator Weekly Run

**Purpose:** Weekly full infrastructure analysis  
**Trigger:** Cron `0 2 * * 0` (Sunday 02:00 UTC)  
**Nodes:**
1. Cron (weekly schedule)
2. HTTP Request (invoke orchestrator)
3. Code (parse JSON results)
4. HTTP Request (store results)
5. HTTP Request (update WikiJS with findings)
6. HTTP Request (send summary notification)

**Workflow JSON:** See `workflows/n8n/orchestrator-weekly.json`

## Node-RED Flows

### Flow 1: Docker Event Handler

**Purpose:** Process Docker events and trigger agents  
**Input:** Docker events stream  
**Nodes:**
1. `docker-events` (inject Docker events)
2. Switch (filter by event type)
3. Function (format event payload)
4. HTTP Request (POST to n8n webhook)
5. Debug (log events)

**Flow JSON:** See `workflows/nodered/docker-events.json`

### Flow 2: Agent Result Aggregator

**Purpose:** Aggregate and process agent results  
**Input:** Agent JSON outputs  
**Nodes:**
1. File In (read orchestration/ directory)
2. Function (parse and aggregate JSON)
3. Switch (route by agent type)
4. Function (generate summary)
5. HTTP Request (update WikiJS)
6. File Out (save aggregated report)

**Flow JSON:** See `workflows/nodered/agent-aggregator.json`

### Flow 3: Notification Router

**Purpose:** Route agent notifications based on severity  
**Input:** Agent notifications  
**Nodes:**
1. HTTP In (receive notifications)
2. Function (extract severity)
3. Switch (route by severity)
4. HTTP Request (Discord webhook for critical)
5. HTTP Request (Email for warnings)
6. HTTP Request (Log for info)

**Flow JSON:** See `workflows/nodered/notification-router.json`

## Implementation Steps

### Step 1: Set Up Webhook Endpoints

1. Create n8n webhook workflows (see n8n workflows section)
2. Configure webhook URLs in Infisical:
   ```bash
   infisical secrets set --env prod --path /prod INFISICAL_WEBHOOK_URL="https://n8n.freqkflag.co/webhook/agent-events"
   ```
3. Test webhooks:
   ```bash
   curl -X POST https://n8n.freqkflag.co/webhook/agent-events \
     -H "Content-Type: application/json" \
     -d '{"agent":"status","trigger":"test"}'
   ```

### Step 2: Create n8n Workflows

1. Import workflow JSON files (see `workflows/n8n/` directory)
2. Configure HTTP Request nodes to invoke agent scripts
3. Set up authentication for agent script execution
4. Configure notification endpoints (Discord, Email, etc.)

### Step 3: Create Node-RED Flows

1. Import flow JSON files (see `workflows/nodered/` directory)
2. Configure Docker event monitoring
3. Set up file watchers for orchestration/ directory
4. Configure notification routing

### Step 4: Set Up Scheduled Tasks

1. Create systemd timers or cron jobs (see Scheduled Triggers section)
2. Test individual agent invocations
3. Monitor first scheduled runs
4. Adjust schedules as needed

### Step 5: Set Up Event Monitors

1. Configure Docker event monitoring script
2. Set up health check failure webhook
3. Configure Git webhook integration (GitHub/GitLab)
4. Test event-driven triggers

## Agent Invocation Methods

### Method 1: Direct Script Invocation

```bash
# Invoke individual agent
/root/infra/ai.engine/scripts/invoke-agent.sh bug-hunter /tmp/output.json

# Invoke orchestrator
/root/infra/ai.engine/scripts/orchestrator.sh /root/infra/orchestration/report.json
```

### Method 2: Via n8n HTTP Request

```json
{
  "method": "POST",
  "url": "http://localhost:8080/api/v1/agents/invoke",
  "body": {
    "agent": "bug-hunter",
    "output_file": "/tmp/output.json"
  }
}
```

### Method 3: Via Webhook

```bash
curl -X POST https://n8n.freqkflag.co/webhook/agent-events \
  -H "Content-Type: application/json" \
  -d '{
    "agent": "bug-hunter",
    "trigger": "webhook",
    "output_file": "/tmp/output.json"
  }'
```

### Method 4: Via Node-RED Flow

Use HTTP Request node to POST to agent webhook endpoint.

## Output Storage

### Directory Structure

```
/root/infra/orchestration/
├── status-20251122.json
├── bugs-20251122.json
├── security-20251122.json
├── orchestrator-20251122.json
└── ...
```

### Output Format

All agents output strict JSON. Example:
```json
{
  "agent": "bug-hunter",
  "timestamp": "2025-11-22T12:00:00Z",
  "results": {
    "critical_bugs": [...],
    "warnings": [...],
    "code_smells": [...]
  }
}
```

## Notification Channels

### Critical Alerts
- Discord webhook
- Email notification
- Alertmanager integration

### Warnings
- Email notification
- WikiJS documentation update

### Info
- WikiJS documentation update
- CHANGELOG entry

## Error Handling

### Retry Logic
- Failed agent runs retry up to 3 times
- Exponential backoff between retries
- Alert on persistent failures

### Error Notifications
- Failed runs send to ops-agent
- Critical failures trigger immediate notification
- Errors logged to CHANGELOG

## Monitoring

### Agent Execution Metrics
- Execution count per agent
- Success/failure rates
- Execution duration
- Output size

### Automation Health
- Webhook availability
- Scheduled task execution
- Event handler status
- Notification delivery

## Security Considerations

1. **Webhook Authentication:** All webhooks require authentication token
2. **Agent Script Permissions:** Limit script execution permissions
3. **Output Sanitization:** Sanitize agent outputs before storage
4. **Secret Management:** All secrets via Infisical, never in workflows
5. **Network Isolation:** Agent execution in isolated network

## Next Steps

1. ✅ **Documentation created** - This document
2. ⏭️ **Create n8n workflows** - Import workflow JSON files
3. ⏭️ **Create Node-RED flows** - Import flow JSON files
4. ⏭️ **Set up webhooks** - Configure webhook endpoints
5. ⏭️ **Configure scheduled tasks** - Set up cron/systemd timers
6. ⏭️ **Test automation** - Verify all trigger types work
7. ⏭️ **Monitor execution** - Track agent runs and results

---

**Status:** ✅ Documentation Complete  
**Next:** Implement workflows and triggers  
**Last Updated:** 2025-11-22

