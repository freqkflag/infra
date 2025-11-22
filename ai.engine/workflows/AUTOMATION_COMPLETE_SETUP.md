# Complete Automation Setup: n8n + Node-RED Integration

**Date:** 2025-11-22  
**Status:** ✅ Infrastructure Ready, ⏭️ Flows Need Configuration

## Summary

Successfully set up automation infrastructure using **n8n** (workflow orchestration) and **Node-RED** (event-driven automation) working together. Workflows are imported but require manual activation in n8n UI due to strict API validation.

## ✅ Completed Infrastructure Setup

### 1. n8n Configuration
- ✅ Fixed rate limiting (changed to `rate-limit@file`)
- ✅ Imported 2 workflows via API:
  - Agent Event Router (ID: `b05wnEzvdIZIH1yD`)
  - Health Check Monitor (ID: `V9eXapAUbgZdftA7`)
- ✅ Workflows updated with `continueOnFail` options
- ✅ API accessible with key: `n8n_api_9a6147aa807de95a996ca3f99da1f8ffb4de87b575a944d6a49aa67816bbaea879169ab17508d79b`

### 2. Node-RED Configuration  
- ✅ Added Traefik labels to `/root/infra/nodered/docker-compose.yml`
- ✅ Container running and accessible
- ⏭️ Domain: `nodered.freqkflag.co` (needs DNS verification)
- ⏭️ Flows need to be created

## Architecture: n8n + Node-RED Integration

```
┌─────────────────────────────────────────────────────────────┐
│                    Event Sources                            │
├─────────────────────────────────────────────────────────────┤
│  • Docker Events (Node-RED monitors)                        │
│  • Scheduled Tasks (Cron → Agents → Files)                  │
│  • Webhook Events (n8n receives)                            │
│  • File Changes (Node-RED watches orchestration/)           │
└────────────┬────────────────────┬───────────────────────────┘
             │                    │
             ▼                    ▼
┌──────────────────────┐  ┌──────────────────────┐
│      n8n             │  │     Node-RED         │
│  (Orchestration)     │◄─┤  (Event Processing)  │
├──────────────────────┤  ├──────────────────────┤
│ Agent Event Router   │  │ Docker Event Handler │
│ Health Check Monitor │  │ Agent Aggregator     │
│ Node-RED Integration │  │ Notification Router  │
└────────────┬─────────┘  └──────────┬───────────┘
             │                       │
             └───────────┬───────────┘
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Agent Execution Layer                          │
├─────────────────────────────────────────────────────────────┤
│  /root/infra/ai.engine/scripts/invoke-agent.sh             │
│  Individual agent scripts                                   │
└────────────┬───────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────┐
│              Output Processing                              │
├─────────────────────────────────────────────────────────────┤
│  /root/infra/orchestration/*.json                           │
│  Node-RED processes → WikiJS updates                        │
│  Node-RED routes → Notifications                            │
└─────────────────────────────────────────────────────────────┘
```

## n8n Workflow Activation Solution

### Issue
API activation fails due to strict validation. Workflows need manual UI activation after fixing node configurations.

### Fix Process

**Option 1: Manual UI Activation (Recommended)**
1. Access n8n at `https://n8n.freqkflag.co/workflows`
2. Open each workflow
3. Check for red error indicators on nodes
4. Fix HTTP Request nodes:
   - Update URLs to valid endpoints OR
   - Ensure `continueOnFail: true` is set in options
5. Toggle "Active" switch in top-right corner

**Option 2: API Workaround**
Since API validation is strict, we need to:
- Remove all read-only properties from nodes
- Ensure exact node structure matches n8n schema
- This is complex - manual UI activation is simpler

### Current Workflow Status

| Workflow | ID | Status | Webhook | Notes |
|----------|-----|--------|---------|-------|
| Agent Event Router | `b05wnEzvdIZIH1yD` | Imported, Inactive | `/webhook/agent-events` | Needs activation |
| Health Check Monitor | `V9eXapAUbgZdftA7` | Imported, Inactive | `/webhook/health-alert` | Needs activation |

## Node-RED Flows Setup

### Required Flows

#### 1. Docker Event Handler
**Monitors:** Docker container events  
**Triggers:** Container die, health check failures  
**Action:** POST to `https://n8n.freqkflag.co/webhook/health-alert`

#### 2. Agent Result Aggregator  
**Monitors:** `/root/infra/orchestration/*.json`  
**Action:** Parse, aggregate, update WikiJS

#### 3. Notification Router
**Endpoint:** `POST /notify`  
**Routes:** Critical → Discord, Warning → Email, Info → Log

#### 4. n8n Integration Webhook
**Endpoint:** `POST /n8n/webhook`  
**Purpose:** Receive events from n8n workflows

### Node-RED Setup Steps

1. ✅ **Access Node-RED**
   - URL: `https://nodered.freqkflag.co`
   - Verify Traefik labels are applied

2. ⏭️ **Install Required Nodes**
   ```bash
   # Access Node-RED, go to Manage Palette
   # Install:
   # - node-red-node-file-watcher
   # Standard nodes are built-in
   ```

3. ⏭️ **Create Flows**
   - Use browser automation or manual creation
   - See `nodered-flows-setup.md` for detailed flow configurations

## Integration Flow Examples

### Health Check Failure Flow

```
1. Docker detects unhealthy container
   ↓
2. Node-RED Docker Event Handler receives event
   ↓  
3. Node-RED formats and POSTs to n8n/webhook/health-alert
   ↓
4. n8n Health Check Monitor routes to ops agent
   ↓
5. n8n POSTs to /webhook/agent-events (agent: ops)
   ↓
6. n8n Agent Event Router triggers ops agent script
   ↓
7. Agent writes output to orchestration/ops-YYYYMMDD-HHMMSS.json
   ↓
8. Node-RED Agent Aggregator detects new file
   ↓
9. Node-RED processes, updates WikiJS, sends notification
```

### Scheduled Agent Run Flow

```
1. Cron runs: /root/infra/ai.engine/scripts/status.sh
   ↓
2. Agent writes: orchestration/status-YYYYMMDD.json
   ↓
3. Node-RED Agent Aggregator detects new file
   ↓
4. Node-RED parses JSON, generates summary
   ↓
5. Node-RED updates WikiJS with findings
   ↓
6. If critical issues → Notification Router sends alert
```

## Next Steps

### Immediate Actions

1. **Activate n8n Workflows**
   - Open workflows in UI
   - Fix any node configuration errors
   - Toggle activation

2. **Create Node-RED Flows**
   - Access Node-RED UI
   - Create 4 flows as documented
   - Test each flow

3. **Test Integration**
   - Test webhook endpoints
   - Test Docker event triggering
   - Test file watching

### Configuration Files Updated

- ✅ `/root/infra/n8n/docker-compose.yml` - Rate limiting fixed
- ✅ `/root/infra/nodered/docker-compose.yml` - Traefik labels added
- ✅ Workflow JSON files updated with `continueOnFail` options

### Documentation Created

- ✅ `IMPORT_STATUS.md` - n8n import status
- ✅ `COMPLETION_SUMMARY.md` - Work completed summary
- ✅ `nodered-flows-setup.md` - Node-RED setup guide
- ✅ `FULL_AUTOMATION_SOLUTION.md` - Complete architecture
- ✅ `AUTOMATION_COMPLETE_SETUP.md` - This document

## Quick Reference

**n8n:**
- URL: `https://n8n.freqkflag.co`
- API Key: `n8n_api_9a6147aa807de95a996ca3f99da1f8ffb4de87b575a944d6a49aa67816bbaea879169ab17508d79b`
- Webhooks: `/webhook/agent-events`, `/webhook/health-alert`

**Node-RED:**
- URL: `https://nodered.freqkflag.co`  
- Endpoints: `/n8n/webhook`, `/notify`
- Monitors: Docker events, `/root/infra/orchestration/` files

**Agent Scripts:**
- Location: `/root/infra/ai.engine/scripts/`
- Invoker: `invoke-agent.sh <agent_name> [output_file]`
- Output: `/root/infra/orchestration/*.json`

---

**Last Updated:** 2025-11-22  
**Next:** Activate workflows and create Node-RED flows

