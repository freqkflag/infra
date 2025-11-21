# Ops Agent & Enhanced Control Plane

**Created:** 2025-11-21  
**Status:** ✅ Core Implementation Complete  
**Domain:** `ops.freqkflag.co`

## What Was Created

### 1. **Ops Agent** (`/root/infra/ai.engine/agents/ops-agent.md`)
Specialized infrastructure operations agent that provides full command and control over infrastructure.

**Capabilities:**
- Execute orchestrator-agent commands
- View and manage current tasks
- Communicate with all virtual agents
- Execute infrastructure commands
- Monitor service health and logs
- Manage service lifecycle (start/stop/restart)
- View infrastructure metrics and alerts

### 2. **Enhanced Server** (`/root/infra/ops/server-enhanced.js`)
Comprehensive backend API with:

**New Endpoints:**
- **Agent Communication**: `/api/agents/*`, `/api/chat/*`
- **Task Management**: `/api/tasks/*`
- **Orchestrator Execution**: `/api/orchestrator/*`
- **Infrastructure Commands**: `/api/infra/*`

**Features:**
- Real-time SSE for chat updates
- Task tracking and status management
- Secure command execution (with restrictions)
- Infrastructure overview and metrics

### 3. **Enhanced Package** (`/root/infra/ops/package-enhanced.json`)
Updated dependencies including `uuid` for task management.

## API Reference

### Agent Communication

```bash
# List all agents
GET /api/agents

# Get agent definition
GET /api/agents/:id

# Send message to agent
POST /api/agents/:id/chat
Body: { "message": "Analyze infrastructure status" }

# Get chat history
GET /api/chat/history?agent=bug-hunter&limit=50

# Real-time chat updates (SSE)
GET /api/chat/sse
```

### Task Management

```bash
# List all tasks
GET /api/tasks?status=running&agent=orchestrator

# Get task details
GET /api/tasks/:id

# Create task
POST /api/tasks
Body: { "type": "analysis", "description": "...", "agent": "orchestrator" }

# Update task
PUT /api/tasks/:id
Body: { "status": "completed", "result": {...} }

# Cancel task
DELETE /api/tasks/:id
```

### Orchestrator Execution

```bash
# Execute orchestrator command
POST /api/orchestrator/execute
Body: { 
  "command": "analyze",  # or "agent"
  "args": ["bug-hunter"]  # if command is "agent"
}

# List orchestrator reports
GET /api/orchestrator/reports

# Get report content
GET /api/orchestrator/reports/:name
```

### Infrastructure Commands

```bash
# Execute infrastructure command
POST /api/infra/command
Body: { 
  "command": "cd /root/infra && docker ps",
  "timeout": 30000
}

# Get infrastructure overview
GET /api/infra/overview
```

## Usage Examples

### Example 1: Run Orchestrator Analysis

```bash
curl -X POST https://ops.freqkflag.co/api/orchestrator/execute \
  -u admin:changeme \
  -H "Content-Type: application/json" \
  -d '{"command": "analyze"}'
```

Response:
```json
{
  "task": {
    "id": "uuid-here",
    "type": "orchestrator",
    "status": "running",
    "description": "Execute orchestrator command: analyze"
  },
  "result": {
    "success": true,
    "outputFile": "/root/infra/orchestration/orchestration-1234567890.json"
  }
}
```

### Example 2: Send Message to Agent

```bash
curl -X POST https://ops.freqkflag.co/api/agents/bug-hunter/chat \
  -u admin:changeme \
  -H "Content-Type: application/json" \
  -d '{"message": "Scan for critical bugs"}'
```

### Example 3: Execute Infrastructure Command

```bash
curl -X POST https://ops.freqkflag.co/api/infra/command \
  -u admin:changeme \
  -H "Content-Type: application/json" \
  -d '{"command": "docker ps --format json"}'
```

### Example 4: Get Infrastructure Overview

```bash
curl https://ops.freqkflag.co/api/infra/overview \
  -u admin:changeme
```

Response:
```json
{
  "containers": {
    "total": 22,
    "running": 17,
    "stopped": 5
  },
  "services": {
    "total": 18,
    "running": 12
  },
  "system": {
    "disk": "21G / 193G (11%)",
    "memory": "Mem: 4.6G / 15G"
  },
  "timestamp": "2025-11-21T..."
}
```

## Security Features

### Command Restrictions
- Only allows commands in `/root/infra` or docker commands
- Blocks dangerous commands:
  - `rm -rf`
  - `mkfs`
  - `dd if=`
  - `shutdown`
  - `reboot`
  - `format`
- Command timeout (default 30s, max 5min for orchestrator)
- Max output buffer (10MB)

### Authentication
- Basic Auth (env vars: `OPS_AUTH_USER`, `OPS_AUTH_PASS`)
- All endpoints protected except `/health` and `/api/chat/sse`
- Can be extended with OAuth for production

## Next Steps for UI Enhancement

### 1. Add Chat Interface
```html
<div class="panel" id="agentChatPanel">
  <h2>🤖 Agent Chat</h2>
  <select id="agentSelector"></select>
  <div id="chatMessages"></div>
  <input type="text" id="chatInput" placeholder="Message agent...">
  <button onclick="sendAgentMessage()">Send</button>
</div>
```

### 2. Add Task Management View
```html
<div class="panel" id="tasksPanel">
  <h2>📋 Tasks</h2>
  <div id="taskList"></div>
  <button onclick="refreshTasks()">Refresh</button>
</div>
```

### 3. Add Orchestrator Control
```html
<div class="panel" id="orchestratorPanel">
  <h2>🎯 Orchestrator</h2>
  <button onclick="runOrchestrator()">Run Full Analysis</button>
  <select id="agentSelect"></select>
  <button onclick="runAgent()">Run Agent</button>
  <div id="orchestratorResults"></div>
</div>
```

### 4. Add Command Execution
```html
<div class="panel" id="commandPanel">
  <h2>⚡ Command Execution</h2>
  <input type="text" id="commandInput" placeholder="cd /root/infra && docker ps">
  <button onclick="executeCommand()">Execute</button>
  <pre id="commandOutput"></pre>
</div>
```

## Deployment Steps

### 1. Install Dependencies
```bash
cd /root/infra/ops
npm install uuid
```

### 2. Create Orchestration Directory
```bash
mkdir -p /root/infra/orchestration
```

### 3. Backup Current Server
```bash
cp server.js server.js.backup
cp public/index.html public/index.html.backup
```

### 4. Deploy Enhanced Server
```bash
# Option A: Replace (if ready)
cp server-enhanced.js server.js
cp package-enhanced.json package.json

# Option B: Run alongside (for testing)
# Update docker-compose.yml to use server-enhanced.js
```

### 5. Update docker-compose.yml
```yaml
environment:
  OPS_AUTH_USER: ${OPS_AUTH_USER:-admin}
  OPS_AUTH_PASS: ${OPS_AUTH_PASS:-changeme}  # CHANGE THIS!
```

### 6. Restart Service
```bash
cd /root/infra/ops
docker compose down
docker compose up -d
```

## Testing

### Test Agent List
```bash
curl https://ops.freqkflag.co/api/agents -u admin:changeme
```

### Test Task Creation
```bash
curl -X POST https://ops.freqkflag.co/api/tasks \
  -u admin:changeme \
  -H "Content-Type: application/json" \
  -d '{"type": "test", "description": "Test task"}'
```

### Test Infrastructure Overview
```bash
curl https://ops.freqkflag.co/api/infra/overview -u admin:changeme
```

## Files Created

```
/root/infra/
├── ai.engine/
│   └── agents/
│       └── ops-agent.md              ✅ NEW
└── ops/
    ├── server-enhanced.js            ✅ NEW
    ├── package-enhanced.json         ✅ NEW
    ├── ENHANCED_FEATURES.md          ✅ NEW
    └── OPS_AGENT_SUMMARY.md          ✅ THIS FILE
```

## Integration with Existing Agents

The ops-agent integrates with all existing agents:

- **status_agent** - View infrastructure status
- **bug_hunter** - Scan for bugs via chat
- **performance** - Analyze performance via chat
- **security** - Security audits via chat
- **architecture** - Architecture analysis via chat
- **docs** - Documentation gap analysis via chat
- **tests** - Test coverage analysis via chat
- **refactor** - Refactoring recommendations via chat
- **release** - Release readiness checks via chat
- **orchestrator** - Full multi-agent analysis

## Future Enhancements

1. **WebSocket Support** - Real-time bidirectional communication
2. **Command History** - Store and replay command history
3. **Scheduled Tasks** - Schedule orchestrator runs
4. **Webhooks** - Webhook notifications for task completion
5. **Agent Plugins** - Custom agent integrations
6. **Dashboard Widgets** - Customizable dashboard panels
7. **Alerts Integration** - Connect with Alertmanager
8. **Audit Logging** - Track all command executions

---

**Status:** ✅ Core Implementation Complete  
**Next:** UI Enhancement (optional but recommended)

