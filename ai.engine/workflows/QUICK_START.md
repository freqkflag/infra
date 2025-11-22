# n8n and Node-RED Integration - Quick Start

**Status:** ✅ Configured and Ready

## Quick Status

✅ **Network:** Both services on shared `edge` network  
✅ **Services:** Both running and healthy  
✅ **Flows:** Integration flows created  
⏭️ **Import:** Ready for import

## Import Flows (2 minutes)

### 1. Import Node-RED Flow

```
1. Go to: https://nodered.freqkflag.co
2. Menu (☰) → Import
3. Copy/paste from: ai.engine/workflows/nodered/n8n-integration-flow-proper.json
4. Click Deploy
```

### 2. Import n8n Workflow

```
1. Go to: https://n8n.freqkflag.co
2. Workflows → Add workflow
3. Menu (...) → Import from File
4. Select: ai.engine/workflows/n8n/nodered-integration-workflow.json
5. Toggle "Active" switch
6. Save
```

## Test Integration (30 seconds)

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

## Communication

- **n8n → Node-RED:** `http://nodered:1880/n8n/webhook`
- **Node-RED → n8n:** `http://n8n:5678/webhook/health-alert`
- **Both → Agent API:** `http://host.docker.internal:8081/api/v1/agents/invoke`

## Files

- **Node-RED Flow:** `ai.engine/workflows/nodered/n8n-integration-flow-proper.json`
- **n8n Workflow:** `ai.engine/workflows/n8n/nodered-integration-workflow.json`
- **Documentation:** `N8N_NODERED_INTEGRATION.md`

---

**Ready to import!** 🚀

