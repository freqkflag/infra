# n8n Workflow Import Status

**Date:** 2025-11-22  
**Status:** ✅ Configuration Complete, ⏭️ Manual Import Required

## Completed

1. ✅ **Created workflow JSON files:**
   - `agent-event-router.json` - Routes webhook events to agents (updated to use API endpoint)
   - `health-check-monitor.json` - Monitors health checks

2. ✅ **Created Agent API Server:**
   - `agent-api-server.py` - Flask API server for executing agent scripts
   - `agent-api-server.service` - Systemd service file
   - `setup-agent-api.sh` - Setup script

3. ✅ **Configured API endpoint:**
   - Port: 8081 (changed from 8080 due to conflict)
   - URL: `http://host.docker.internal:8081/api/v1/agents/invoke`
   - Health check: `http://localhost:8081/health`

4. ✅ **Updated workflows:**
   - Updated agent-event-router.json to call the API endpoint
   - Configured to use `host.docker.internal` for Docker container access

## Next Steps (Manual Actions Required)

### 1. Start Agent API Server

The API server should start automatically, but verify:

```bash
sudo systemctl status agent-api-server
```

If not running, start it:

```bash
sudo systemctl start agent-api-server
sudo systemctl enable agent-api-server
```

Test the API:

```bash
curl http://localhost:8081/health
curl http://localhost:8081/api/v1/agents/list
```

### 2. Import Workflows into n8n

**Manual Import (Recommended):**

1. Access n8n: https://n8n.freqkflag.co
2. Login with credentials
3. Click "Workflows" in left sidebar
4. Click "Add workflow" button
5. Click three dots menu (...) → "Import from File"
6. Import files from `/root/infra/ai.engine/workflows/n8n/`:
   - `agent-event-router.json`
   - `health-check-monitor.json`

**Or use the import script:**

```bash
cd /root/infra/ai.engine/workflows/scripts
export N8N_PASSWORD="your-password"
./import-n8n-workflows.sh
```

### 3. Activate Workflows

After importing:

1. Open each workflow in n8n
2. Toggle the "Active" switch in top right
3. Save the workflow

### 4. Test Webhook Endpoints

**Test Agent Event Router:**

```bash
curl -X POST https://n8n.freqkflag.co/webhook/agent-events \
  -H "Content-Type: application/json" \
  -d '{
    "agent": "status",
    "trigger": "test",
    "output_file": "/root/infra/orchestration/test-status.json"
  }'
```

**Expected Response:**
```json
{
  "status": "success",
  "message": "Agent triggered",
  "agent": "status",
  "timestamp": "2025-11-22T12:00:00.000Z"
}
```

**Test Health Check Monitor:**

```bash
curl -X POST https://n8n.freqkflag.co/webhook/health-alert \
  -H "Content-Type: application/json" \
  -d '{
    "service": "traefik",
    "status": "unhealthy",
    "health_check": "failed",
    "timestamp": "2025-11-22T12:00:00Z"
  }'
```

**Expected Behavior:**
- Filters critical alerts
- Triggers ops-agent via agent-event-router webhook
- Sends alert to Alertmanager (if configured)
- Logs to WikiJS (if configured)

### 5. Verify Agent Execution

Check that agents execute successfully:

```bash
# Check orchestration directory for output files
ls -lah /root/infra/orchestration/

# Check API server logs
sudo journalctl -u agent-api-server -f

# Check n8n execution logs in UI
# Visit: https://n8n.freqkflag.co/executions
```

## Configuration Summary

- **API Server:** Running on port 8081
- **API Endpoint:** `http://host.docker.internal:8081/api/v1/agents/invoke`
- **Webhook Endpoints:**
  - Agent Events: `https://n8n.freqkflag.co/webhook/agent-events`
  - Health Alert: `https://n8n.freqkflag.co/webhook/health-alert`

## Troubleshooting

### API Server Not Running

```bash
# Check status
sudo systemctl status agent-api-server

# Check logs
sudo journalctl -u agent-api-server -n 50

# Restart
sudo systemctl restart agent-api-server
```

### Webhook Not Responding

1. Verify workflow is active in n8n
2. Check webhook path matches
3. Check Traefik routing: `docker logs traefik | grep n8n`

### Agent Script Not Executing

1. Verify API server is accessible: `curl http://localhost:8081/health`
2. Check API server logs: `sudo journalctl -u agent-api-server -f`
3. Test API directly: `curl -X POST http://localhost:8081/api/v1/agents/invoke -H "Content-Type: application/json" -d '{"agent":"status"}'`

## Files Created

- ✅ `/root/infra/ai.engine/workflows/n8n/agent-event-router.json` (updated)
- ✅ `/root/infra/ai.engine/workflows/n8n/health-check-monitor.json`
- ✅ `/root/infra/ai.engine/workflows/scripts/agent-api-server.py`
- ✅ `/root/infra/ai.engine/workflows/scripts/agent-api-server.service`
- ✅ `/root/infra/ai.engine/workflows/scripts/setup-agent-api.sh`
- ✅ `/root/infra/ai.engine/workflows/scripts/import-n8n-workflows.sh`
- ✅ `/root/infra/ai.engine/workflows/N8N_WORKFLOW_IMPORT_GUIDE.md`

---

**Status:** ✅ Configuration Complete  
**Next:** Import workflows into n8n and test  
**Last Updated:** 2025-11-22

