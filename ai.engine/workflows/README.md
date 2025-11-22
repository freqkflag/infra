# AI Engine Automation Workflows

**Location:** `/root/infra/ai.engine/workflows/`  
**Purpose:** Automation workflows and triggers for AI Engine agents

## Quick Start

### 1. Set Up Automation

```bash
cd /root/infra/ai.engine/workflows/scripts
./setup-automation.sh
```

**Dry run mode:**
```bash
./setup-automation.sh --dry-run
```

### 2. Import n8n Workflows

1. Access n8n at `https://n8n.freqkflag.co`
2. Import workflows from `n8n/` directory:
   - `agent-event-router.json` - Routes webhook events to agents
   - `health-check-monitor.json` - Monitors health checks and triggers ops-agent

### 3. Import Node-RED Flows

1. Access Node-RED at `https://nodered.freqkflag.co`
2. Import flows from `nodered/` directory:
   - `docker-events.json` - Processes Docker events
   - `agent-aggregator.json` - Aggregates agent results
   - `notification-router.json` - Routes notifications

### 4. Test Automation

```bash
# Trigger an agent via webhook
./trigger-agent.sh status /tmp/status.json webhook

# Trigger an agent directly
./trigger-agent.sh bug-hunter /tmp/bugs.json direct
```

## Directory Structure

```
workflows/
├── n8n/                    # n8n workflow definitions
│   ├── agent-event-router.json
│   ├── health-check-monitor.json
│   └── scheduled-agent-runner.json
├── nodered/                # Node-RED flow definitions
│   ├── docker-events.json
│   ├── agent-aggregator.json
│   └── notification-router.json
├── scripts/                # Automation scripts
│   ├── setup-automation.sh
│   └── trigger-agent.sh
└── README.md               # This file
```

## Available Workflows

### n8n Workflows

#### Agent Event Router
- **Purpose:** Route webhook events to appropriate agents
- **Webhook:** `https://n8n.freqkflag.co/webhook/agent-events`
- **Payload:**
  ```json
  {
    "agent": "status",
    "trigger": "manual|webhook|scheduled|event",
    "output_file": "/root/infra/orchestration/status-20251122.json",
    "metadata": {
      "source": "manual",
      "timestamp": "2025-11-22T12:00:00Z"
    }
  }
  ```

#### Health Check Monitor
- **Purpose:** Monitor health checks and trigger ops-agent on failures
- **Webhook:** `https://n8n.freqkflag.co/webhook/health-alert`
- **Payload:**
  ```json
  {
    "service": "traefik",
    "status": "unhealthy",
    "health_check": "failed",
    "timestamp": "2025-11-22T12:00:00Z"
  }
  ```

### Node-RED Flows

#### Docker Event Handler
- **Purpose:** Process Docker events and trigger agents
- **Input:** Docker events stream
- **Output:** Webhook to n8n

#### Agent Result Aggregator
- **Purpose:** Aggregate and process agent results
- **Input:** Agent JSON outputs from `orchestration/` directory
- **Output:** Aggregated reports and WikiJS updates

#### Notification Router
- **Purpose:** Route notifications based on severity
- **Input:** Agent notifications
- **Output:** Discord/Email/Log based on severity

## Automation Triggers

### Scheduled Triggers

**Daily:**
- Status check: `0 0 * * *` (00:00 UTC)
- Backstage check: `0 6 * * *` (06:00 UTC)

**Hourly:**
- Ops check: `0 * * * *` (top of every hour)

**Weekly:**
- Orchestrator: `0 2 * * 0` (Sunday 02:00 UTC)
- Security audit: `0 3 * * 1` (Monday 03:00 UTC)
- Performance analysis: `0 4 * * 3` (Wednesday 04:00 UTC)
- Documentation check: `0 5 * * 5` (Friday 05:00 UTC)

**Monthly:**
- Refactoring analysis: `0 6 1 * *` (1st of month 06:00 UTC)
- MCP integration review: `0 7 15 * *` (15th of month 07:00 UTC)

### Event-Driven Triggers

**Docker Events:**
- Container die events → Trigger ops-agent
- Health check failures → Trigger ops-agent
- Container start events → Log to WikiJS

**Health Check Failures:**
- Service unhealthy → Trigger ops-agent → Alertmanager
- Health check failed → Log to WikiJS

**Git Events:**
- Pull request opened → Trigger bug-hunter
- Push to main → Trigger security audit
- Merge to main → Trigger orchestrator

### Webhook Triggers

**Manual Trigger:**
```bash
curl -X POST https://n8n.freqkflag.co/webhook/agent-events \
  -H "Content-Type: application/json" \
  -d '{
    "agent": "status",
    "trigger": "manual",
    "output_file": "/tmp/status.json"
  }'
```

**Health Check Alert:**
```bash
curl -X POST https://n8n.freqkflag.co/webhook/health-alert \
  -H "Content-Type: application/json" \
  -d '{
    "service": "traefik",
    "status": "unhealthy",
    "health_check": "failed"
  }'
```

## Scripts

### setup-automation.sh

Sets up all automation triggers, workflows, and scheduled tasks.

**Usage:**
```bash
./setup-automation.sh [--dry-run] [--skip-webhooks] [--skip-scheduled]
```

**Options:**
- `--dry-run` - Show what would be done without making changes
- `--skip-webhooks` - Skip webhook setup
- `--skip-scheduled` - Skip scheduled tasks setup

**What it does:**
1. Creates orchestration directory
2. Imports n8n workflows (requires manual setup via UI)
3. Sets up cron jobs for scheduled agent runs
4. Creates Docker event monitoring service
5. Configures webhook URL in Infisical

### trigger-agent.sh

Triggers an agent via webhook or direct invocation.

**Usage:**
```bash
./trigger-agent.sh <agent_name> [output_file] [trigger_type]
```

**Examples:**
```bash
# Via webhook
./trigger-agent.sh status /tmp/status.json webhook

# Direct invocation
./trigger-agent.sh bug-hunter /tmp/bugs.json direct

# Use default output file
./trigger-agent.sh orchestrator
```

## Output Storage

All agent outputs are stored in `/root/infra/orchestration/`:

```
orchestration/
├── status-20251122.json
├── bugs-20251122.json
├── security-20251122.json
├── orchestrator-20251122.json
└── ...
```

## Monitoring

### Agent Execution Logs

```bash
# View automation logs
tail -f /var/log/ai-engine-automation.log

# View cron job execution
grep ai-engine /var/log/cron
```

### Docker Event Monitor

```bash
# Check service status
systemctl status docker-event-monitor

# View logs
journalctl -u docker-event-monitor -f
```

### Webhook Logs

Check n8n execution logs at `https://n8n.freqkflag.co/executions`

## Troubleshooting

### Webhook Not Triggering

1. Check n8n workflow is active
2. Verify webhook URL is correct
3. Check n8n logs for errors
4. Test webhook manually with curl

### Scheduled Tasks Not Running

1. Verify cron jobs are installed: `crontab -l | grep ai.engine`
2. Check cron service is running: `systemctl status cron`
3. View cron logs: `grep CRON /var/log/syslog`

### Docker Events Not Captured

1. Check event monitor service: `systemctl status docker-event-monitor`
2. View service logs: `journalctl -u docker-event-monitor -f`
3. Verify Docker socket is accessible

## Next Steps

**See [NEXT_STEPS_AI_PROMPT.md](./NEXT_STEPS_AI_PROMPT.md) for detailed AI prompts to continue implementation.**

1. ✅ **Documentation created** - This README
2. ✅ **Workflows created** - n8n workflow JSON files
3. ✅ **Scripts created** - Setup and trigger scripts
4. ✅ **External webhook access enabled** - n8n configured for external triggers
5. ⏭️ **Import workflows** - Import into n8n and Node-RED
6. ⏭️ **Configure agent invocation** - Set up n8n to invoke agent scripts
7. ⏭️ **Run setup script** - Execute `setup-automation.sh`
8. ⏭️ **Test automation** - Verify all trigger types work
9. ⏭️ **Monitor execution** - Track agent runs and results

**For AI assistants continuing this work, use the prompts in NEXT_STEPS_AI_PROMPT.md.**

---

**Status:** ✅ Documentation Complete, ⏭️ Implementation Ready  
**Last Updated:** 2025-11-22

