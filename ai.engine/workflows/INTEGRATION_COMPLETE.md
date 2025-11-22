# n8n and Node-RED Integration - Complete

**Date:** 2025-11-22  
**Status:** ✅ Configuration Complete

## Summary

n8n and Node-RED are now wired to work together with bidirectional communication enabled.

## Configuration Complete

### ✅ Network Configuration

**Both services are now on shared networks:**
- ✅ **n8n:** On `edge` network (shared with Node-RED)
- ✅ **Node-RED:** On `edge` network (shared with n8n)
- ✅ Both can communicate directly via container names

**Communication:**
- n8n → Node-RED: `http://nodered:1880`
- Node-RED → n8n: `http://n8n:5678`
- Both → Agent API: `http://host.docker.internal:8081`

### ✅ Integration Flows Created

**Node-RED Flow:**
- **File:** `ai.engine/workflows/nodered/n8n-integration-flow-proper.json`
- **Purpose:** Receives webhooks from n8n and processes events
- **Endpoints:** `/n8n/webhook` (receives from n8n)

**n8n Workflow:**
- **File:** `ai.engine/workflows/n8n/nodered-integration-workflow.json`
- **Purpose:** Triggers Node-RED flows and syncs with Node-RED
- **Endpoints:** `/webhook/nodered/trigger` (receives triggers)

### ✅ Documentation

- `N8N_NODERED_INTEGRATION.md` - Complete integration guide
- `N8N_NODERED_INTEGRATION_SUMMARY.md` - Quick summary
- `INTEGRATION_COMPLETE.md` - This file

## Quick Start

### 1. Import Node-RED Flow

1. Access Node-RED: `https://nodered.freqkflag.co`
2. Menu (☰) → Import
3. Import: `ai.engine/workflows/nodered/n8n-integration-flow-proper.json`
4. Deploy flow

### 2. Import n8n Workflow

1. Access n8n: `https://n8n.freqkflag.co`
2. Workflows → Add workflow
3. Menu (...) → Import from File
4. Import: `ai.engine/workflows/n8n/nodered-integration-workflow.json`
5. Activate workflow

### 3. Test Integration

**Test Node-RED → n8n:**
```bash
curl -X POST http://localhost:1880/n8n/webhook \
  -H "Content-Type: application/json" \
  -d '{"type":"health-alert","data":{"service":"traefik","status":"unhealthy"}}'
```

**Test n8n → Node-RED:**
```bash
curl -X POST https://n8n.freqkflag.co/webhook/nodered/trigger \
  -H "Content-Type: application/json" \
  -d '{"type":"agent-event","data":{"agent":"status"}}'
```

## Integration Endpoints

- **Node-RED:** `http://nodered:1880/n8n/webhook` (receives from n8n)
- **n8n:** `http://n8n:5678/webhook/nodered/trigger` (receives triggers)
- **External Node-RED:** `https://nodered.freqkflag.co/n8n/webhook`
- **External n8n:** `https://n8n.freqkflag.co/webhook/nodered/trigger`

## Status

✅ **Network:** Both services on shared networks  
✅ **Flows:** Integration flows created  
✅ **Documentation:** Complete guides available  
⏭️ **Import:** Ready for import into both platforms  
⏭️ **Testing:** Ready for integration testing

---

**Configuration Complete!**  
**Next:** Import flows and test integration  
**Last Updated:** 2025-11-22

