# n8n and Node-RED Integration

**Created:** 2025-11-22  
**Purpose:** Wire n8n and Node-RED to work together for comprehensive automation

## Overview

n8n and Node-RED are now configured to work together:
- **n8n:** Handles complex workflows, webhooks, and scheduled tasks
- **Node-RED:** Handles real-time event processing, Docker monitoring, and data aggregation
- **Integration:** Bidirectional communication between both platforms

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Event Sources                            │
├─────────────────────────────────────────────────────────────┤
│  • Docker Events                                             │
│  • Health Checks                                             │
│  • Agent Triggers                                            │
│  • Scheduled Tasks                                           │
└───────────────────┬─────────────────────────────────────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
        ▼                       ▼
┌───────────────┐       ┌───────────────┐
│   Node-RED    │ ◄───► │     n8n       │
├───────────────┤       ├───────────────┤
│ • Real-time   │       │ • Workflows   │
│ • Docker      │       │ • Webhooks    │
│ • Aggregation │       │ • Scheduling  │
└───────────────┘       └───────────────┘
        │                       │
        └───────────┬───────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │   Agent API Server    │
        │   Port 8081           │
        └───────────────────────┘
```

## Network Configuration

Both services are now on shared networks:

### n8n Networks
- `n8n-network` - Internal network (database)
- `traefik-network` - External access via Traefik
- `edge` - **NEW** - Shared network with Node-RED

### Node-RED Networks
- `nodered-network` - Internal network
- `edge` - Shared network with n8n
- `traefik-network` - **NEW** - External access via Traefik

### Communication Methods

**Direct Container Communication:**
- n8n → Node-RED: `http://nodered:1880`
- Node-RED → n8n: `http://n8n:5678`

**External Access:**
- n8n: `https://n8n.freqkflag.co`
- Node-RED: `https://nodered.freqkflag.co` (via Traefik)

## Integration Flows

### 1. Node-RED → n8n Integration

**Purpose:** Node-RED processes events and triggers n8n workflows

**Flow File:** `nodered/n8n-integration-flow.json`

**Features:**
- Receives events from Node-RED flows
- Routes to appropriate n8n webhooks
- Processes Docker events → triggers n8n health alerts
- Handles agent events → triggers n8n agent workflows

**Endpoints:**
- Node-RED HTTP In: `/n8n/webhook` (receives from n8n)
- Calls n8n: `http://n8n:5678/webhook/health-alert`
- Calls Agent API: `http://host.docker.internal:8081/api/v1/agents/invoke`

### 2. n8n → Node-RED Integration

**Purpose:** n8n workflows trigger Node-RED flows for real-time processing

**Workflow File:** `n8n/nodered-integration-workflow.json`

**Features:**
- Webhook endpoint for triggering Node-RED: `/webhook/nodered/trigger`
- Scheduled sync with Node-RED (every 5 minutes)
- Sends data to Node-RED for processing
- Receives responses from Node-RED

**Endpoints:**
- n8n Webhook: `https://n8n.freqkflag.co/webhook/nodered/trigger`
- Calls Node-RED: `http://nodered:1880/n8n/webhook`

## Use Cases

### Use Case 1: Docker Event Monitoring

**Flow:**
1. Node-RED monitors Docker events
2. Filters critical events (die, health_status: unhealthy)
3. Triggers n8n webhook: `/webhook/health-alert`
4. n8n processes alert and triggers ops-agent
5. Results logged and notifications sent

**Implementation:**
- Node-RED flow: Docker event monitor → Filter → HTTP Request to n8n
- n8n workflow: Health Check Monitor → Trigger Ops Agent

### Use Case 2: Agent Result Aggregation

**Flow:**
1. Agent API executes agent scripts
2. Node-RED watches orchestration directory for new files
3. Node-RED aggregates agent results
4. Sends aggregated data to n8n
5. n8n updates WikiJS and sends notifications

**Implementation:**
- Node-RED flow: File watcher → Parse JSON → Aggregate → HTTP Request to n8n
- n8n workflow: Receive aggregated data → Update WikiJS → Send notifications

### Use Case 3: Real-time Event Processing

**Flow:**
1. Event occurs (Docker event, health check, etc.)
2. Node-RED processes event in real-time
3. Node-RED triggers n8n webhook for workflow orchestration
4. n8n executes workflow (agent triggers, notifications, etc.)
5. Results flow back to Node-RED for further processing

**Implementation:**
- Node-RED: Real-time event handler → HTTP Request to n8n
- n8n: Webhook receiver → Workflow execution → HTTP Request back to Node-RED

### Use Case 4: Scheduled Tasks Sync

**Flow:**
1. n8n scheduled workflow runs
2. Checks Node-RED status
3. Syncs data with Node-RED
4. Node-RED processes and responds
5. n8n logs sync status

**Implementation:**
- n8n: Schedule trigger (every 5 min) → HTTP Request to Node-RED → Process response
- Node-RED: HTTP In node receives sync requests → Process → HTTP Response

## Setup Instructions

### Step 1: Update Docker Compose Files

**Already completed** - Both services are on shared networks:
- ✅ n8n added to `edge` network
- ✅ Node-RED added to `traefik-network` network

### Step 2: Restart Services

```bash
# Restart n8n
cd /root/infra/n8n
docker compose down
docker compose up -d

# Restart Node-RED
cd /root/infra/nodered
docker compose down
docker compose up -d
```

### Step 3: Import Node-RED Flow

1. Access Node-RED: `https://nodered.freqkflag.co`
2. Click menu (☰) → Import
3. Import flow from: `/root/infra/ai.engine/workflows/nodered/n8n-integration-flow.json`
4. Deploy the flow

### Step 4: Import n8n Workflow

1. Access n8n: `https://n8n.freqkflag.co`
2. Click "Workflows" → "Add workflow"
3. Click menu (...) → "Import from File"
4. Import workflow from: `/root/infra/ai.engine/workflows/n8n/nodered-integration-workflow.json`
5. Activate the workflow

### Step 5: Test Integration

**Test Node-RED → n8n:**
```bash
# Trigger Node-RED webhook (which calls n8n)
curl -X POST https://nodered.freqkflag.co/n8n/webhook \
  -H "Content-Type: application/json" \
  -d '{
    "type": "health-alert",
    "data": {
      "service": "traefik",
      "status": "unhealthy",
      "health_check": "failed"
    }
  }'
```

**Test n8n → Node-RED:**
```bash
# Trigger n8n webhook (which calls Node-RED)
curl -X POST https://n8n.freqkflag.co/webhook/nodered/trigger \
  -H "Content-Type: application/json" \
  -d '{
    "type": "agent-event",
    "data": {
      "agent": "status",
      "trigger": "webhook"
    }
  }'
```

## Integration Endpoints

### Node-RED Endpoints

**HTTP In Nodes:**
- `/n8n/webhook` - Receives webhooks from n8n
- `/health` - Health check endpoint

**HTTP Request Nodes:**
- Calls n8n: `http://n8n:5678/webhook/health-alert`
- Calls Agent API: `http://host.docker.internal:8081/api/v1/agents/invoke`
- Calls Alertmanager: `http://alertmanager:9093/api/v1/alerts`

### n8n Endpoints

**Webhook Nodes:**
- `/webhook/agent-events` - Agent event router
- `/webhook/health-alert` - Health check monitor
- `/webhook/nodered/trigger` - Node-RED trigger endpoint

**HTTP Request Nodes:**
- Calls Node-RED: `http://nodered:1880/n8n/webhook`
- Calls Agent API: `http://host.docker.internal:8081/api/v1/agents/invoke`

## Communication Patterns

### Pattern 1: Event-Driven (Node-RED → n8n)

```
Event → Node-RED → Process → n8n Webhook → n8n Workflow → Actions
```

**Example:** Docker event → Node-RED processes → Triggers n8n health alert → n8n triggers ops-agent

### Pattern 2: Workflow-Driven (n8n → Node-RED)

```
n8n Workflow → Node-RED Webhook → Node-RED Flow → Process → Response → n8n
```

**Example:** n8n scheduled task → Sends to Node-RED → Node-RED aggregates data → Sends back to n8n

### Pattern 3: Bidirectional

```
n8n ←→ Node-RED ←→ External Services
```

**Example:** n8n triggers Node-RED → Node-RED processes → Calls Agent API → Node-RED sends results back to n8n

## Monitoring and Debugging

### Node-RED Debug Panel

- View flow execution in real-time
- Check message payloads
- Monitor HTTP requests/responses
- View error messages

### n8n Execution Logs

- View workflow executions
- Check node outputs
- Monitor webhook calls
- View error details

### Test Endpoints

```bash
# Test Node-RED health
curl http://localhost:1880/health

# Test n8n health
curl https://n8n.freqkflag.co/healthz

# Test integration
curl -X POST http://localhost:1880/n8n/webhook \
  -H "Content-Type: application/json" \
  -d '{"type":"test","data":{"message":"integration test"}}'
```

## Configuration Files

### Updated Files
- ✅ `/root/infra/n8n/docker-compose.yml` - Added `edge` network
- ✅ `/root/infra/nodered/docker-compose.yml` - Added `traefik-network` network

### New Files
- ✅ `/root/infra/ai.engine/workflows/nodered/n8n-integration-flow.json` - Node-RED integration flow
- ✅ `/root/infra/ai.engine/workflows/n8n/nodered-integration-workflow.json` - n8n integration workflow
- ✅ `/root/infra/ai.engine/workflows/N8N_NODERED_INTEGRATION.md` - This documentation

## Next Steps

1. ✅ **Network Configuration:** Both services on shared networks
2. ⏭️ **Restart Services:** Restart n8n and Node-RED
3. ⏭️ **Import Flows:** Import integration flows into both platforms
4. ⏭️ **Test Integration:** Test bidirectional communication
5. ⏭️ **Monitor:** Set up monitoring and alerting

---

**Status:** ✅ Configuration Complete  
**Next:** Restart services and import flows  
**Last Updated:** 2025-11-22

