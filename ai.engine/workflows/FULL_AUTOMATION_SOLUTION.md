# Full Automation Solution: n8n + Node-RED Integration

**Date:** 2025-11-22  
**Status:** ✅ Workflows Imported, ⏭️ Activation & Node-RED Setup Required

## Executive Summary

Successfully imported n8n workflows but activation requires UI configuration due to strict API validation. Full automation solution requires both **n8n** (orchestration) and **Node-RED** (event-driven automation) working together.

## Current Status

### ✅ Completed

1. **Fixed n8n Rate Limiting**
   - Changed middleware from `rate-limit-strict@file` to `rate-limit@file`
   - Resolved 429 errors
   - Updated `/root/infra/n8n/docker-compose.yml`

2. **Imported n8n Workflows via API**
   - **Agent Event Router** (ID: `b05wnEzvdIZIH1yD`) - Webhook: `/webhook/agent-events`
   - **Health Check Monitor** (ID: `V9eXapAUbgZdftA7`) - Webhook: `/webhook/health-alert`
   - **Node-RED Integration** workflow JSON exists but not yet imported

3. **Fixed Workflow Configuration Issues**
   - Updated HTTP Request nodes with `continueOnFail` option
   - Fixed problematic URLs to prevent validation errors
   - Workflows can be saved but API activation fails due to strict validation

### ⏭️ Pending

1. **n8n Workflow Activation** - Requires manual UI activation after node configuration
2. **Node-RED Setup** - Needs Traefik labels and flow creation
3. **Full Integration** - Connect n8n and Node-RED workflows

## n8n Workflow Activation Issue

**Problem:** API activation fails with validation errors:
- `Cannot read properties of undefined (reading 'description')`
- `propertyValues[itemName] is not iterable`

**Root Cause:** n8n's API has very strict validation that requires:
- All nodes must have exact structure matching current n8n version
- Some properties are read-only and cannot be set via API
- Node configurations must match schema exactly

**Solution:** Manual activation via UI is required:
1. Open each workflow in n8n UI
2. Check and fix any node configuration errors (red indicators)
3. Ensure all HTTP Request nodes have valid URLs or continueOnFail enabled
4. Activate via toggle switch in top-right corner

## Node-RED Integration Plan

### Node-RED Status
- ✅ Container running and healthy
- ❌ Not accessible via HTTPS (missing Traefik labels)
- ⏭️ Flows need to be created

### Required Node-RED Flows

#### 1. Docker Event Handler Flow
**Purpose:** Monitor Docker container events and trigger n8n

**Flow:**
```
[docker events] → [filter critical] → [format] → [POST to n8n/webhook/health-alert]
```

**Triggers:**
- Container dies (`die` event)
- Health check fails (`health_status: unhealthy`)
- Container restarts unexpectedly

#### 2. Agent Result Aggregator Flow  
**Purpose:** Process agent output files and create summaries

**Flow:**
```
[file watch orchestration/] → [read JSON] → [route by agent] → [aggregate] → [WikiJS update]
```

**Monitors:** `/root/infra/orchestration/*.json`
**Actions:**
- Parse agent output JSON files
- Route by agent type (status, bug-hunter, security, etc.)
- Generate aggregated summaries
- Update WikiJS with findings
- Save aggregated reports

#### 3. Notification Router Flow
**Purpose:** Route notifications by severity

**Flow:**
```
[HTTP In /notify] → [extract severity] → [switch] → [Discord/Email/Log]
```

**Routes:**
- **Critical** → Discord webhook
- **Warning** → Email notification  
- **Info** → File log

#### 4. n8n Integration Webhook
**Purpose:** Receive events from n8n workflows

**Flow:**
```
[HTTP In /n8n/webhook] → [process event] → [route to handler flows]
```

**Receives:** Events from n8n workflows
**Forwards:** To appropriate Node-RED flows for processing

### Node-RED Setup Steps

1. **Add Traefik Labels** to `nodered/docker-compose.yml`:
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.nodered.rule=Host(`nodered.freqkflag.co`)"
  - "traefik.http.routers.nodered.entrypoints=websecure"
  - "traefik.http.routers.nodered.tls.certresolver=letsencrypt"
  - "traefik.http.services.nodered.loadbalancer.server.port=1880"
```

2. **Restart Node-RED** to apply Traefik labels

3. **Access Node-RED** at `https://nodered.freqkflag.co`

4. **Install Required Nodes:**
   - `node-red-node-file-watcher` (file watching)
   - Standard nodes: `http in`, `http request`, `function`, `switch`, `file`

5. **Create Flows** as documented in `nodered-flows-setup.md`

## Complete Automation Architecture

```
┌─────────────────────────────────────────────────────────┐
│              Automation Triggers                        │
├─────────────────────────────────────────────────────────┤
│  Scheduled (Cron)                                        │
│  Docker Events (Node-RED)                                │
│  Webhooks (n8n)                                          │
│  File Changes (Node-RED)                                 │
└────────────┬────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────┐
│              Orchestration Layer                        │
├─────────────────────────────────────────────────────────┤
│  n8n Workflows:                                          │
│    • Agent Event Router (webhook routing)               │
│    • Health Check Monitor (alert routing)               │
│    • Node-RED Integration (bi-directional)              │
│                                                          │
│  Node-RED Flows:                                         │
│    • Docker Event Handler (event monitoring)            │
│    • Agent Result Aggregator (file processing)          │
│    • Notification Router (alert routing)                │
│    • n8n Integration Webhook (event receiver)           │
└────────────┬────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────┐
│           Agent Execution Layer                         │
├─────────────────────────────────────────────────────────┤
│  /root/infra/ai.engine/scripts/invoke-agent.sh         │
│  Individual agent scripts                               │
└────────────┬────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────┐
│              Output & Storage                           │
├─────────────────────────────────────────────────────────┤
│  /root/infra/orchestration/*.json                       │
│  WikiJS updates                                          │
│  Notifications (Discord/Email)                          │
│  CHANGELOG entries                                       │
└─────────────────────────────────────────────────────────┘
```

## Integration Flow Examples

### Example 1: Health Check Failure

```
1. Docker → [die/unhealthy event]
2. Node-RED Docker Event Handler → [formats alert]
3. Node-RED → POST to n8n/webhook/health-alert
4. n8n Health Check Monitor → [routes to ops agent]
5. n8n → POST to /webhook/agent-events (agent: ops)
6. n8n Agent Event Router → [triggers ops agent script]
7. Agent executes → [writes output JSON]
8. Node-RED Agent Result Aggregator → [watches for new JSON]
9. Node-RED → [processes output] → [updates WikiJS] + [sends notification]
```

### Example 2: Scheduled Agent Run

```
1. Cron → [runs daily status.sh]
2. Agent executes → [writes status-20251122.json]
3. Node-RED Agent Result Aggregator → [detects new file]
4. Node-RED → [parses JSON] → [routes by agent type]
5. Node-RED → [generates summary] → [updates WikiJS]
6. If critical issues found → [sends notification via Notification Router]
```

## Next Steps Priority

### Immediate (Complete Automation)

1. **Fix Node-RED Accessibility**
   - Add Traefik labels to `nodered/docker-compose.yml`
   - Restart Node-RED container
   - Verify access at `https://nodered.freqkflag.co`

2. **Activate n8n Workflows via UI**
   - Open each workflow in n8n
   - Fix any configuration errors
   - Toggle activation switch

3. **Create Node-RED Flows**
   - Install required nodes
   - Create Docker Event Handler flow
   - Create Agent Result Aggregator flow
   - Create Notification Router flow
   - Create n8n Integration webhook flow

4. **Test Integration**
   - Test webhook endpoints
   - Test Docker event triggering
   - Test file watching
   - Test notification routing

### Documentation

- ✅ Created: `IMPORT_STATUS.md` - n8n import status
- ✅ Created: `COMPLETION_SUMMARY.md` - Summary of work completed
- ✅ Created: `nodered-flows-setup.md` - Node-RED setup guide
- ✅ Created: `FULL_AUTOMATION_SOLUTION.md` - This document

## Configuration Files

### n8n Workflows
- `/root/infra/ai.engine/workflows/n8n/agent-event-router.json`
- `/root/infra/ai.engine/workflows/n8n/health-check-monitor.json`
- `/root/infra/ai.engine/workflows/n8n/nodered-integration-workflow.json`

### Node-RED Flows (To Be Created)
- Docker Event Handler flow
- Agent Result Aggregator flow
- Notification Router flow
- n8n Integration webhook flow

## API Keys & Credentials

**n8n API Key:**
```
n8n_api_9a6147aa807de95a996ca3f99da1f8ffb4de87b575a944d6a49aa67816bbaea879169ab17508d79b
```

**Storage:** Store in Infisical at `/prod` as `N8N_API_KEY`

## Troubleshooting

### n8n Workflow Activation Fails
- **Solution:** Activate via UI after fixing node configurations
- **Check:** All HTTP Request nodes have valid URLs or `continueOnFail: true`
- **Verify:** Webhook nodes have proper path configuration

### Node-RED Not Accessible
- **Check:** Traefik labels in `nodered/docker-compose.yml`
- **Verify:** Container is running: `docker ps | grep nodered`
- **Test:** Internal access: `docker exec nodered curl -s http://localhost:1880`

### Integration Not Working
- **Verify:** Both services are accessible
- **Check:** Network connectivity (both on `edge` network)
- **Test:** Webhook endpoints individually
- **Review:** Flow logs in both n8n and Node-RED

---

**Last Updated:** 2025-11-22  
**Status:** Ready for Node-RED setup and final integration

