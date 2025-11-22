# A2A Session Management Enhancement Summary

**Date:** 2025-11-22  
**Status:** ✅ Complete

## Enhancements Made

### 1. Agent API Server Enhanced (`agent-api-server.py`)

**Added A2A Session Management Endpoints:**

- `POST /api/v1/sessions/create` - Create new A2A session
- `GET /api/v1/sessions/<session_id>` - Get session data
- `POST /api/v1/sessions/<session_id>/update` - Update session with agent results
- `DELETE /api/v1/sessions/<session_id>` - Delete session

**Features:**
- Calls `a2a-session.sh` script directly
- Fallback to client-side generation if script not available
- Error handling and timeout protection
- JSON response format

### 2. n8n Workflow Enhanced (`agent-event-router.json`)

**New/Updated Nodes:**

1. **A2A Session Check** (Code node)
   - Checks if `session_id` exists in request
   - Prepares data for session creation if needed
   - Routes to conditional node

2. **A2A Session Conditional** (IF node)
   - Routes to session creation if `needs_session_creation = true`
   - Bypasses creation if `session_id` already provided

3. **A2A Session Create** (HTTP Request node)
   - Calls `/api/v1/sessions/create` endpoint
   - Creates new session with task metadata
   - Returns `session_id`

4. **A2A Merge Session** (Set node)
   - Merges `session_id` from creation or existing
   - Prepares unified data structure

5. **A2A Session Manager** (Set node - Enhanced)
   - Manages session context
   - Prepares data for agent invocation
   - Includes `session_id`, `context_file`, `task_id`

6. **A2A Session Update** (HTTP Request node - Enhanced)
   - Calls `/api/v1/sessions/<session_id>/update` endpoint
   - Updates session with agent execution results
   - Tracks agent status and output files

### 3. Updated Workflow Flow

```
Webhook (agent-events)
    ↓
Merge Event Data
    ↓
Route By Agent (Switch)
    ↓
A2A Session Check ← Checks for existing session_id
    ↓
A2A Session Conditional ← Routes based on need
    ├─→ [true] → A2A Session Create → A2A Merge Session
    └─→ [false] → A2A Merge Session
    ↓
A2A Session Manager ← Prepares context
    ↓
Invoke Agent Script (A2A) ← Enhanced with session/context
    ↓
Format Response (A2A) ← Includes A2A metadata
    ↓
A2A Session Update ← Updates session via API
    ↓
Log Event
    ↓
Respond to Webhook
```

## API Integration

**Agent API Server** (`agent-api-server.py`):
- **Port:** 8081
- **Endpoints:**
  - `/api/v1/agents/invoke` - Invoke agents
  - `/api/v1/agents/list` - List agents
  - `/api/v1/sessions/create` - Create A2A session (NEW)
  - `/api/v1/sessions/<id>` - Get session (NEW)
  - `/api/v1/sessions/<id>/update` - Update session (NEW)
  - `/api/v1/sessions/<id>` - Delete session (NEW)

**Access:** `http://host.docker.internal:8081` (from n8n container)

## Usage Examples

### Example 1: New Session (Auto-Created)

```bash
curl -X POST https://n8n.freqkflag.co/webhook/agent-events \
  -H 'Content-Type: application/json' \
  -d '{
    "agent": "status",
    "task_id": "task-123"
  }'
```

**Result:** Workflow creates new session automatically

### Example 2: Existing Session (Context Passing)

```bash
curl -X POST https://n8n.freqkflag.co/webhook/agent-events \
  -H 'Content-Type: application/json' \
  -d '{
    "agent": "architecture",
    "session_id": "a2a-20251122-abc123",
    "context_file": "/tmp/status-results.json",
    "task_id": "task-123"
  }'
```

**Result:** Workflow uses existing session, passes context

### Example 3: Multi-Agent Sequence

```bash
# Agent 1
curl -X POST https://n8n.freqkflag.co/webhook/agent-events \
  -d '{"agent":"status","task_id":"multi-test"}'

# Agent 2 (with context from Agent 1)
curl -X POST https://n8n.freqkflag.co/webhook/agent-events \
  -d '{
    "agent":"security",
    "session_id":"<session_id_from_agent_1>",
    "context_file":"<output_from_agent_1>",
    "task_id":"multi-test"
  }'
```

## Validation

✅ **JSON Validation:** Passed  
✅ **A2A Nodes:** 8 nodes integrated  
✅ **API Integration:** Agent API server enhanced  
✅ **Error Handling:** Timeout and error handling added  
✅ **Session Management:** Full CRUD operations via API  

## Files Modified

1. **`ai.engine/workflows/scripts/agent-api-server.py`**
   - Added A2A session management endpoints
   - Integrated with `a2a-session.sh` script
   - Added fallback handling

2. **`ai.engine/workflows/n8n/agent-event-router.json`**
   - Added 4 new A2A nodes
   - Enhanced 2 existing nodes
   - Improved workflow flow with conditional routing

3. **`ai.engine/scripts/a2a-session-api.py`** (Created, optional)
   - Standalone A2A session API server
   - Can be used if separate service needed

## Next Steps

1. **Start Agent API Server:**
   ```bash
   cd /root/infra/ai.engine/workflows/scripts
   python3 agent-api-server.py &
   ```

2. **Import Updated Workflow:**
   - Import `agent-event-router.json` in n8n UI
   - Activate workflow

3. **Test A2A Integration:**
   ```bash
   # Test session creation
   curl -X POST http://localhost:8081/api/v1/sessions/create \
     -H 'Content-Type: application/json' \
     -d '{"task_id":"test-123"}'
   
   # Test workflow webhook
   curl -X POST https://n8n.freqkflag.co/webhook/agent-events \
     -H 'Content-Type: application/json' \
     -d '{"agent":"status"}'
   ```

## Benefits

✅ **Real Session Management:** Uses actual `a2a-session.sh` script  
✅ **API-Based:** HTTP endpoints for reliability  
✅ **Error Handling:** Graceful fallbacks and timeouts  
✅ **Context Passing:** Full support for multi-agent workflows  
✅ **Backward Compatible:** Works with or without session_id  

---

**Enhancement Complete:** 2025-11-22

