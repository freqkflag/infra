# n8n Workflow Import Guide

**Purpose:** Guide for importing and configuring AI Engine automation workflows in n8n

**Location:** `/root/infra/ai.engine/workflows/n8n/`

## Overview

The workflows need to be imported into n8n and configured to execute agent scripts. Since n8n runs in Docker, agent scripts must be executed via a method that can access the host system.

## Workflow Files

1. **agent-event-router.json** - Routes webhook events to AI Engine agents
2. **health-check-monitor.json** - Monitors health checks and triggers ops-agent

## Import Methods

### Method 1: Manual Import (Recommended)

1. **Access n8n:**
   ```
   https://n8n.freqkflag.co
   ```

2. **Login** with your credentials

3. **Import Workflows:**
   - Click "Workflows" in left sidebar
   - Click "Add workflow" button
   - Click three dots menu (...) → "Import from File"
   - Select workflow files:
     - `agent-event-router.json`
     - `health-check-monitor.json`

4. **Configure Workflows:**

   After importing, you need to configure the "Invoke Agent Script" node in each workflow:

   **Option A: Use HTTP Request to Call Script Runner API**
   
   Update the "Invoke Agent Script" node to:
   ```
   Method: POST
   URL: http://host.docker.internal:8080/api/v1/agents/invoke
   Body: 
   {
     "agent": "={{$json.body.agent}}",
     "output_file": "={{$json.body.output_file || '/root/infra/orchestration/' + $json.body.agent + '-' + $now.format('YYYYMMDD-HHmmss') + '.json'}}",
     "trigger": "={{$json.body.trigger || 'webhook'}}"
   }
   ```

   **Option B: Use Execute Command (if scripts are mounted)**
   
   If you mount `/root/infra` into n8n container, you can use Execute Command node:
   ```
   Command: bash
   Arguments: -c '/root/infra/ai.engine/workflows/scripts/trigger-agent.sh "{{ $json.body.agent }}" "{{ $json.body.output_file || \"/root/infra/orchestration/\" + $json.body.agent + \"-\" + $now.format(\"YYYYMMDD-HHmmss\") + \".json\" }}" webhook'
   ```

### Method 2: API Import (Requires Authentication)

Run the import script:

```bash
cd /root/infra/ai.engine/workflows/scripts
export N8N_PASSWORD="your-password"
./import-n8n-workflows.sh
```

Or provide password interactively:
```bash
./import-n8n-workflows.sh
```

## Post-Import Configuration

### 1. Configure Agent Script Execution

The workflows need a way to execute agent scripts. Choose one approach:

#### Approach 1: Create Simple API Endpoint (Recommended)

Create a simple HTTP endpoint that executes agent scripts:

**Create file:** `/root/infra/ai.engine/workflows/scripts/agent-api-server.py`

```python
#!/usr/bin/env python3
from flask import Flask, request, jsonify
import subprocess
import json

app = Flask(__name__)

@app.route('/api/v1/agents/invoke', methods=['POST'])
def invoke_agent():
    data = request.json
    agent = data.get('agent')
    output_file = data.get('output_file', f'/root/infra/orchestration/{agent}-{timestamp}.json')
    trigger = data.get('trigger', 'webhook')
    
    try:
        script_path = '/root/infra/ai.engine/workflows/scripts/trigger-agent.sh'
        result = subprocess.run(
            [script_path, agent, output_file, trigger],
            capture_output=True,
            text=True,
            timeout=300
        )
        
        return jsonify({
            'status': 'success',
            'agent': agent,
            'output_file': output_file,
            'stdout': result.stdout,
            'stderr': result.stderr,
            'returncode': result.returncode
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```

**Run as service:**
```bash
# Create systemd service or run in Docker
python3 /root/infra/ai.engine/workflows/scripts/agent-api-server.py
```

**Update n8n workflow** to call: `http://host.docker.internal:8080/api/v1/agents/invoke`

#### Approach 2: Mount Scripts into n8n Container

Update `n8n/docker-compose.yml`:

```yaml
volumes:
  - ./data/n8n:/home/node/.n8n
  - /root/infra:/root/infra:ro  # Mount infra directory
```

Then use Execute Command node in n8n workflow.

#### Approach 3: SSH Execution

If n8n has SSH access to host:

1. Configure SSH credentials in n8n
2. Use SSH node to execute:
   ```bash
   /root/infra/ai.engine/workflows/scripts/trigger-agent.sh {{agent}} {{output_file}} webhook
   ```

### 2. Activate Workflows

1. Open each workflow in n8n
2. Toggle the "Active" switch in top right
3. Save the workflow

### 3. Test Webhook Endpoints

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
- Triggers ops-agent
- Sends alert to Alertmanager (if configured)
- Logs to WikiJS (if configured)

### 4. Verify Agent Execution

Check that agent scripts executed successfully:

```bash
# Check orchestration directory for output files
ls -lah /root/infra/orchestration/

# Check automation logs
tail -f /var/log/ai-engine-automation.log

# Check n8n execution logs in UI
# Visit: https://n8n.freqkflag.co/executions
```

## Troubleshooting

### Webhook Not Responding

1. **Check workflow is active:**
   - Open workflow in n8n
   - Verify "Active" toggle is ON
   - Save if needed

2. **Check webhook path:**
   - Verify webhook path matches: `/webhook/agent-events`
   - Check webhook URL in n8n UI

3. **Check Traefik routing:**
   ```bash
   docker logs traefik | grep n8n
   ```

### Agent Script Not Executing

1. **Check script path:**
   - Verify script exists: `/root/infra/ai.engine/workflows/scripts/trigger-agent.sh`
   - Check script permissions: `chmod +x /root/infra/ai.engine/workflows/scripts/trigger-agent.sh`

2. **Check execution method:**
   - If using API endpoint, verify server is running
   - If using Execute Command, verify scripts are mounted
   - If using SSH, verify SSH credentials are configured

3. **Check n8n execution logs:**
   - View execution details in n8n UI
   - Check for error messages
   - Review node outputs

### Workflow Import Failed

1. **Check JSON format:**
   ```bash
   python3 -m json.tool agent-event-router.json > /dev/null
   ```

2. **Import manually:**
   - Copy workflow JSON
   - Paste into n8n workflow editor
   - Save workflow

## Next Steps

After successful import and configuration:

1. ✅ Test webhook endpoints
2. ✅ Verify agent scripts execute
3. ✅ Check output files are created
4. ⏭️ Set up scheduled agent runs
5. ⏭️ Configure notification channels
6. ⏭️ Monitor automation execution

---

**Last Updated:** 2025-11-22  
**Location:** `/root/infra/ai.engine/workflows/`

