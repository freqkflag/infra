# Ops Control Plane - Enhanced Features

**Version:** 2.0.0  
**Domain:** `ops.freqkflag.co`

## New Features

### 1. **Agent Communication** 🤖
- Chat interface to communicate with all virtual agents
- Real-time SSE updates for agent responses
- Chat history with agent filtering
- Direct agent invocation and response viewing

**API Endpoints:**
- `GET /api/agents` - List all available agents
- `GET /api/agents/:id` - Get agent definition
- `POST /api/agents/:id/chat` - Send message to agent
- `GET /api/chat/history` - Get chat history
- `GET /api/chat/sse` - Real-time chat updates (SSE)

### 2. **Task Management** 📋
- View all current tasks across all agents
- Task status tracking (pending, running, completed, failed, cancelled)
- Filter tasks by status or agent
- Task details and results viewing

**API Endpoints:**
- `GET /api/tasks` - Get all tasks (filterable by status/agent)
- `GET /api/tasks/:id` - Get task details
- `POST /api/tasks` - Create new task
- `PUT /api/tasks/:id` - Update task
- `DELETE /api/tasks/:id` - Cancel task

### 3. **Orchestrator Command Execution** 🎯
- Execute orchestrator analysis commands
- Execute individual agent commands
- View orchestrator reports
- Download report JSON files

**API Endpoints:**
- `POST /api/orchestrator/execute` - Execute orchestrator command
- `GET /api/orchestrator/reports` - List all orchestrator reports
- `GET /api/orchestrator/reports/:name` - Get report content

**Commands:**
- `analyze` - Run full orchestrator analysis
- `agent <agent-name>` - Run specific agent

### 4. **Infrastructure Command Execution** ⚡
- Execute safe shell commands in /root/infra
- Docker command execution (ps, logs, inspect, stats)
- Command security restrictions (blocks dangerous commands)
- Command history and task tracking

**API Endpoints:**
- `POST /api/infra/command` - Execute infrastructure command
- `GET /api/infra/overview` - Get infrastructure overview

**Security:**
- Only allows commands in /root/infra or docker commands
- Blocks dangerous commands (rm -rf, mkfs, dd, shutdown, reboot)
- Command timeout (default 30s)
- Max output buffer (10MB)

### 5. **Enhanced Infrastructure Visibility** 👁️
- Container stats (total, running, stopped)
- Service status aggregation
- System resources (disk, memory)
- Real-time health metrics

## UI Components

### Main Dashboard
- Service status table (existing)
- Health metrics (existing)
- Recent incidents (existing)

### New Panels

1. **Agent Chat Panel** 💬
   - Agent selector dropdown
   - Chat message input
   - Chat history display
   - Real-time message updates

2. **Task Management Panel** 📋
   - Task list with filters
   - Task status badges
   - Task details modal
   - Task cancellation

3. **Orchestrator Control Panel** 🎯
   - Command execution form
   - Running tasks indicator
   - Report list
   - Report viewer

4. **Command Execution Panel** ⚡
   - Command input (with history)
   - Command output display
   - Command safety warnings
   - Quick command buttons

5. **Infrastructure Overview Panel** 👁️
   - Container statistics
   - Service statistics
   - System resources
   - Real-time updates

## Migration Guide

### Option 1: Gradual Migration
1. Deploy `server-enhanced.js` alongside `server.js`
2. Test new endpoints
3. Update UI gradually
4. Switch over when stable

### Option 2: Full Replacement
1. Backup current `server.js` and `index.html`
2. Rename `server-enhanced.js` to `server.js`
3. Deploy enhanced UI
4. Update `package.json` dependencies

### Dependencies
```bash
cd /root/infra/ops
npm install uuid
```

### Environment Variables
No new environment variables required. Uses existing:
- `OPS_AUTH_USER` (default: admin)
- `OPS_AUTH_PASS` (default: changeme)

## File Structure

```
ops/
├── server.js                 # Original server
├── server-enhanced.js        # Enhanced server (NEW)
├── package.json              # Original package.json
├── package-enhanced.json     # Enhanced package.json (NEW)
├── public/
│   ├── index.html            # Original UI
│   └── index-enhanced.html   # Enhanced UI (TO BE CREATED)
└── ENHANCED_FEATURES.md      # This file
```

## Next Steps

1. ✅ Create ops-agent.md definition
2. ✅ Create server-enhanced.js with all API endpoints
3. ✅ Create package-enhanced.json with uuid dependency
4. ⏭️ Create enhanced UI (index-enhanced.html)
5. ⏭️ Test all endpoints
6. ⏭️ Deploy to ops.freqkflag.co
7. ⏭️ Update README.md with new features

