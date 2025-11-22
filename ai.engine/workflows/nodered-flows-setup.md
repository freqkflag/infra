# Node-RED Flows Setup for Automation

**Date:** 2025-11-22  
**Purpose:** Create Node-RED flows to complement n8n workflows for full automation

## Overview

Node-RED will handle:
1. **Docker Event Monitoring** - Watch for container events and trigger n8n
2. **Agent Result Aggregation** - Process agent JSON outputs from `/root/infra/orchestration/`
3. **Notification Routing** - Route alerts by severity
4. **n8n Integration** - Receive events from n8n for further processing

## Required Node-RED Flows

### 1. Docker Event Handler Flow

**Purpose:** Monitor Docker container events and forward critical events to n8n

**Nodes Required:**
- `docker-events` node (node-red-contrib-docker-events) OR `exec` node to run `docker events`
- `function` node to filter events (die, health_status: unhealthy)
- `function` node to format payload
- `http request` node to POST to `https://n8n.freqkflag.co/webhook/docker-events`

**Flow Structure:**
```
[Docker Events] -> [Filter Function] -> [Format Function] -> [HTTP Request to n8n]
```

**Configuration:**
- Monitor for: `die`, `health_status: unhealthy`
- Format payload: `{service, status, event, timestamp}`
- POST to: `https://n8n.freqkflag.co/webhook/docker-events` (or agent-event-router)

### 2. Agent Result Aggregator Flow

**Purpose:** Watch for new agent output files and process them

**Nodes Required:**
- `file watch` node (node-red-node-file-watcher) OR `inject` node with cron schedule
- `file in` node to read JSON files
- `function` node to parse and validate JSON
- `switch` node to route by agent type
- `function` node to generate summaries
- `http request` node for WikiJS updates
- `file` node to save aggregated reports

**Flow Structure:**
```
[File Watch] -> [Read File] -> [Parse JSON] -> [Route by Agent] -> [Generate Summary] -> [WikiJS Update] + [Save Report]
```

**Configuration:**
- Watch directory: `/root/infra/orchestration/`
- Filter: `*.json` files
- Route by: `agent` field in JSON
- Generate summary per agent type
- Update WikiJS with findings
- Save aggregated report to `/root/infra/orchestration/aggregated/`

### 3. Notification Router Flow

**Purpose:** Receive notifications from agents/n8n and route by severity

**Nodes Required:**
- `http in` node (endpoint: `/notify`)
- `function` node to extract severity
- `switch` node to route by severity (critical, warning, info)
- `http request` nodes for:
  - Critical: Discord webhook
  - Warning: Email (via SMTP or n8n)
  - Info: Log to file

**Flow Structure:**
```
[HTTP In /notify] -> [Extract Severity] -> [Switch by Severity] -> [Discord/Email/Log]
```

**Configuration:**
- Endpoint: `POST /notify`
- Extract severity from: `msg.payload.severity` or `msg.payload.level`
- Critical → Discord webhook
- Warning → Email notification
- Info → File log

### 4. n8n Integration Webhook

**Purpose:** Receive events from n8n workflows

**Nodes Required:**
- `http in` node (endpoint: `/n8n/webhook`)
- `function` node to process event
- Routes to other flows based on event type

**Flow Structure:**
```
[HTTP In /n8n/webhook] -> [Process Event] -> [Route to Handler Flows]
```

## Setup Instructions

### Step 1: Access Node-RED

1. Navigate to `https://nodered.freqkflag.co` (or check if it needs Traefik configuration)
2. If not accessible, check Traefik labels in `nodered/docker-compose.yml`
3. Login with credentials from Infisical

### Step 2: Install Required Nodes

Install the following Node-RED nodes:
- `node-red-node-file-watcher` (for file watching)
- `node-red-contrib-docker-events` (optional, for Docker events)
- Standard nodes: `http in`, `http request`, `function`, `switch`, `file`

### Step 3: Create Flows

Import or manually create each flow listed above.

### Step 4: Configure Credentials

Store in Node-RED credentials or Infisical:
- Discord webhook URL
- Email SMTP settings
- n8n webhook URLs
- WikiJS API credentials

### Step 5: Test Each Flow

Test each flow individually before deploying all.

## Integration with n8n

n8n workflows will:
- Send events to Node-RED via HTTP Request nodes
- Receive processed data from Node-RED
- Use Node-RED for file watching and Docker event monitoring (if n8n can't do it directly)

## Next Steps

1. ✅ Check Node-RED accessibility
2. ⏭️ Install required nodes
3. ⏭️ Create Docker Event Handler flow
4. ⏭️ Create Agent Result Aggregator flow  
5. ⏭️ Create Notification Router flow
6. ⏭️ Create n8n Integration webhook flow
7. ⏭️ Test integration between n8n and Node-RED

