# n8n and Node-RED Integration Summary

**Date:** 2025-11-22  
**Status:** ✅ Configuration Complete, ⏭️ Import Required

## What Was Accomplished

### 1. ✅ Network Configuration

**Updated Docker Compose Files:**
- ✅ **n8n:** Added to `edge` network (shared with Node-RED)
- ✅ **Node-RED:** Added to `traefik-network` (shared with n8n)
- ✅ Both services can now communicate directly via container names

**Communication Methods:**
- **n8n → Node-RED:** `http://nodered:1880`
- **Node-RED → n8n:** `http://n8n:5678`
- **Both → Agent API:** `http://host.docker.internal:8081`

### 2. ✅ Integration Flows Created

**Node-RED Flow:**
- **File:** `nodered/n8n-integration-flow-proper.json`
- **Purpose:** Receives webhooks from n8n and processes them
- **Endpoints:**
  - HTTP In: `/n8n/webhook` (receives from n8n)
  - HTTP Request: Calls n8n webhooks and Agent API
  - Handles: agent events, health alerts, generic events

**n8n Workflow:**
- **File:** `n8n/nodered-integration-workflow.json`
- **Purpose:** Triggers Node-RED flows and syncs with Node-RED
- **Endpoints:**
  - Webhook: `/webhook/nodered/trigger` (receives triggers)
  - HTTP Request: Calls Node-RED at `http://nodered:1880/n8n/webhook`
  - Scheduled: Syncs with Node-RED every 5 minutes

### 3. ✅ Documentation Created

**Integration Guides:**
- `N8N_NODERED_INTEGRATION.md` - Complete integration documentation
- `N8N_NODERED_INTEGRATION_SUMMARY.md` - This summary
- Setup script: `scripts/setup-n8n-nodered-integration.sh`

## Integration Architecture

```
┌─────────────────────────────────────────┐
│           Event Sources                  │
│  • Docker Events                         │
│  • Health Checks                         │
│  • Agent Triggers                        │
└───────────┬─────────────────────────────┘
            │
    ┌───────┴───────┐
    │               │
    ▼               ▼
┌─────────┐   ┌─────────┐
│ Node-RED│◄─►│   n8n   │
└─────────┘   └─────────┘
    │               │
    └───────┬───────┘
            │
            ▼
    ┌───────────────┐
    │ Agent API     │
    │ Port 8081     │
    └───────────────┘
```

## Use Cases Enabled

### Use Case 1: Docker Event Processing
**Flow:** Docker Event → Node-RED (real-time) → n8n (workflow) → Agent API → Actions

### Use Case 2: Agent Result Aggregation
**Flow:** Agent API → Node-RED (watches files) → Aggregates → n8n → WikiJS/Notifications

### Use Case 3: Bidirectional Communication
**Flow:** n8n ←→ Node-RED ←→ External Services

### Use Case 4: Scheduled Sync
**Flow:** n8n (schedule) → Node-RED (sync) → Response → n8n

## Files Created/Updated

### Updated Files
- ✅ `/root/infra/n8n/docker-compose.yml` - Added `edge` network
- ✅ `/root/infra/nodered/docker-compose.yml` - Added `traefik-network` network

### New Files
- ✅ `/root/infra/ai.engine/workflows/nodered/n8n-integration-flow-proper.json` - Node-RED integration flow
- ✅ `/root/infra/ai.engine/workflows/n8n/nodered-integration-workflow.json` - n8n integration workflow
- ✅ `/root/infra/ai.engine/workflows/N8N_NODERED_INTEGRATION.md` - Complete documentation
- ✅ `/root/infra/ai.engine/workflows/scripts/setup-n8n-nodered-integration.sh` - Setup script

## Next Steps (Manual Actions Required)

### 1. Restart Services

```bash
cd /root/infra

# Restart n8n
docker compose -f n8n/docker-compose.yml down
docker compose -f n8n/docker-compose.yml up -d

# Restart Node-RED
docker compose -f nodered/docker-compose.yml down
docker compose -f nodered/docker-compose.yml up -d
```

### 2. Verify Network Connectivity

```bash
# Check both services are on edge network
docker network inspect edge | grep -E "(n8n|nodered)"

# Test connectivity (after services restart)
docker exec n8n ping -c 1 nodered
docker exec nodered ping -c 1 n8n
```

### 3. Import Node-RED Flow

1. Access Node-RED: `https://nodered.freqkflag.co`
2. Click menu (☰) → Import
3. Select or paste flow from: `/root/infra/ai.engine/workflows/nodered/n8n-integration-flow-proper.json`
4. Deploy the flow
5. Verify HTTP In node is active: `/n8n/webhook`

### 4. Import n8n Workflow

1. Access n8n: `https://n8n.freqkflag.co`
2. Click "Workflows" → "Add workflow"
3. Click menu (...) → "Import from File"
4. Import from: `/root/infra/ai.engine/workflows/n8n/nodered-integration-workflow.json`
5. Activate the workflow
6. Verify webhook endpoint: `/webhook/nodered/trigger`

### 5. Test Integration

**Test Node-RED → n8n:**
```bash
# Trigger Node-RED webhook (which calls n8n)
curl -X POST http://localhost:1880/n8n/webhook \
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
- **HTTP In:** `/n8n/webhook` - Receives webhooks from n8n
- **HTTP Request:** Calls n8n at `http://n8n:5678/webhook/health-alert`
- **HTTP Request:** Calls Agent API at `http://host.docker.internal:8081/api/v1/agents/invoke`

### n8n Endpoints
- **Webhook:** `/webhook/nodered/trigger` - Receives triggers for Node-RED
- **HTTP Request:** Calls Node-RED at `http://nodered:1880/n8n/webhook`
- **HTTP Request:** Calls Agent API at `http://host.docker.internal:8081/api/v1/agents/invoke`

## Configuration Summary

- ✅ **n8n Network:** n8n-network, traefik-network, **edge** (NEW)
- ✅ **Node-RED Network:** nodered-network, edge, **traefik-network** (NEW)
- ✅ **Communication:** Direct container-to-container via service names
- ✅ **Integration Flows:** Created and ready for import
- ✅ **Documentation:** Complete integration guide created

## Troubleshooting

### Services Not Communicating

1. **Verify services are on shared network:**
   ```bash
   docker network inspect edge | grep -E "(n8n|nodered)"
   ```

2. **Restart services:**
   ```bash
   docker compose -f n8n/docker-compose.yml restart
   docker compose -f nodered/docker-compose.yml restart
   ```

3. **Test connectivity:**
   ```bash
   docker exec n8n ping nodered
   docker exec nodered ping n8n
   ```

### Webhooks Not Responding

1. **Check workflows/flows are active:**
   - n8n: Verify workflow "Active" toggle is ON
   - Node-RED: Verify flow is deployed (green status)

2. **Check endpoint paths:**
   - Node-RED: `/n8n/webhook`
   - n8n: `/webhook/nodered/trigger`

3. **Check logs:**
   ```bash
   docker logs n8n --tail=50
   docker logs nodered --tail=50
   ```

---

**Status:** ✅ Configuration Complete  
**Next:** Import flows and test integration  
**Last Updated:** 2025-11-22

