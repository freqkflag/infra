# Node-RED Automation Flows

**Location:** `/root/infra/ai.engine/workflows/nodered/`  
**Purpose:** Node-RED flows for AI Engine agent automation

## Available Flows

### 1. Docker Event Handler (`docker-events.json`)

**Purpose:** Monitors Docker events and triggers ops-agent on container failures

**Features:**
- Monitors Docker events stream
- Filters for critical events (die, health_status: unhealthy, oom)
- Triggers n8n webhook for ops-agent execution
- Logs events for debugging

**Trigger Events:**
- Container die events
- Health check failures
- Out of memory (OOM) events

**Output:** POST to `http://n8n:5678/webhook/docker-events`

### 2. Agent Result Aggregator (`agent-aggregator.json`)

**Purpose:** Aggregates agent results from orchestration directory

**Features:**
- Reads all JSON files from `/root/infra/orchestration/`
- Aggregates results by agent
- Generates summary statistics
- Routes by severity (critical vs info)
- Saves aggregated reports
- Updates WikiJS with findings

**Schedule:** Runs every 6 hours (cron: `0 */6 * * *`)

**Output:**
- Aggregated JSON report: `/root/infra/orchestration/aggregated-{timestamp}.json`
- Critical notifications via n8n webhook
- Info updates to WikiJS

### 3. Notification Router (`notification-router.json`)

**Purpose:** Routes agent notifications based on severity

**Features:**
- HTTP endpoint: `/notifications` (POST)
- Extracts severity from payload
- Routes to appropriate channels:
  - **Critical:** Discord webhook + Alertmanager + Email
  - **Error:** Alertmanager + Email
  - **Warning:** Email + WikiJS
  - **Info:** WikiJS + Log file

**Endpoint:** `http://nodered:1880/notifications`

**Payload Format:**
```json
{
  "agent": "bug-hunter",
  "severity": "critical|error|warning|info",
  "message": "Agent execution completed",
  "timestamp": "2025-11-22T12:00:00Z",
  "data": {...}
}
```

### 4. Scheduled Agent Runner (`scheduled-agents.json`)

**Purpose:** Runs agents on scheduled intervals

**Schedules:**
- **Daily (00:00 UTC):** status, backstage
- **Hourly (00:00):** ops
- **Weekly (Sunday 02:00 UTC):** orchestrator, security, performance, docs

**Features:**
- Cron-based triggers
- Invokes agent scripts via exec node
- Formats results
- Sends notifications on completion

**Agent Scripts:** `/root/infra/ai.engine/scripts/invoke-agent.sh`

## Importing Flows

### Method 1: Manual Import (Recommended)

1. Access Node-RED via SSH tunnel:
   ```bash
   ssh -L 1880:localhost:1880 root@62.72.26.113
   ```

2. Open browser: `http://localhost:1880`

3. Login with credentials:
   - Username: `admin`
   - Password: `nodered-infra-2025`

4. Import each flow:
   - Menu → Import → Select flow JSON file
   - Click "Deploy"

### Method 2: API Import

```bash
cd /root/infra/ai.engine/workflows/nodered

# Import single flow
curl -X POST -u "admin:nodered-infra-2025" \
  -H "Content-Type: application/json" \
  -d @docker-events.json \
  http://nodered:1880/flows

# Or use the import script
./import-flows.sh http://nodered:1880
```

### Method 3: Copy to Node-RED Data Directory

```bash
# Copy flows to Node-RED data directory
cp *.json /root/infra/nodered/data/flows/

# Restart Node-RED
cd /root/infra/nodered && docker compose restart
```

## Configuration

### Environment Variables

Set in Infisical or `.workspace/.env`:

- `DISCORD_WEBHOOK_URL` - Discord webhook for critical notifications
- `NODERED_USERNAME` - Node-RED admin username (default: `admin`)
- `NODERED_PASSWORD_HASH` - bcrypt password hash

### Service URLs

Flows use these internal service URLs:

- `http://n8n:5678` - n8n webhook endpoints
- `http://wiki:3000` - WikiJS API
- `http://alertmanager:9093` - Alertmanager API
- `http://nodered:1880` - Node-RED API (self-reference)

## Testing Flows

### Test Docker Event Handler

```bash
# Trigger a test event
docker stop traefik && docker start traefik

# Check Node-RED debug panel for event
```

### Test Notification Router

```bash
curl -X POST http://nodered:1880/notifications \
  -H "Content-Type: application/json" \
  -d '{
    "agent": "test",
    "severity": "critical",
    "message": "Test notification",
    "timestamp": "2025-11-22T12:00:00Z"
  }'
```

### Test Scheduled Agents

```bash
# Manually trigger a scheduled flow
# In Node-RED: Click inject node → Deploy
```

## Troubleshooting

### Flows Not Running

1. Check Node-RED is running: `docker ps | grep nodered`
2. Check flow is deployed (green dot in Node-RED UI)
3. Check debug panel for errors
4. Check Node-RED logs: `docker logs nodered`

### API Import Fails

1. Verify authentication: `curl -u "admin:nodered-infra-2025" http://nodered:1880/flows`
2. Check JSON syntax: `jq . docker-events.json`
3. Verify Node-RED API is accessible

### Docker Events Not Captured

1. Verify Docker socket is accessible
2. Check exec node has proper permissions
3. Verify Docker events command works: `docker events --filter 'event=die'`

### Notifications Not Sent

1. Verify service URLs are correct
2. Check network connectivity: `docker exec nodered ping n8n`
3. Check webhook URLs in Infisical
4. Verify notification payload format

## Flow Dependencies

### Required Node-RED Nodes

All flows use standard Node-RED nodes:
- `inject` - Trigger nodes
- `function` - JavaScript processing
- `switch` - Routing logic
- `http request` - API calls
- `http in` - Webhook endpoints
- `http response` - Response handling
- `exec` - Command execution
- `file` - File operations
- `debug` - Debugging output

### External Dependencies

- **n8n** - Webhook endpoints for agent triggers
- **WikiJS** - Documentation updates
- **Alertmanager** - Alert routing
- **Docker** - Event monitoring

## Next Steps

1. ✅ **Flows created** - All 4 flows defined
2. ⏭️ **Import flows** - Import into Node-RED
3. ⏭️ **Configure webhooks** - Set up n8n webhook endpoints
4. ⏭️ **Test flows** - Verify all flows work correctly
5. ⏭️ **Monitor execution** - Track flow execution and results

---

**Status:** ✅ Flows Created  
**Last Updated:** 2025-11-22

