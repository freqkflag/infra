# n8n A2A Workflow Test Report

**Date:** 2025-11-22  
**Workflow:** Agent Event Router (A2A Enhanced)  
**Status:** ✅ Ready for Import and Activation

## Workflow File

**Location:** `/root/infra/ai.engine/workflows/n8n/agent-event-router.json`  
**JSON Validation:** ✅ Valid  
**A2A Nodes:** 4 nodes integrated

## A2A Nodes in Workflow

1. **A2A Session Manager** (`a2a-session-manager`)
   - Type: Code node
   - Function: Creates/retrieves A2A sessions
   - Generates session IDs when not provided
   - Manages task metadata

2. **Invoke Agent Script (A2A)** (`invoke-agent`)
   - Type: HTTP Request node
   - Enhanced with: `session_id`, `context_file`, `task_id` parameters
   - Supports A2A protocol context passing

3. **Format Response (A2A)** (`format-response`)
   - Type: Set node
   - Includes: `session_id`, `task_id`, `a2a_protocol` in response
   - Enhanced with A2A metadata

4. **A2A Session Update** (`a2a-session-update`)
   - Type: Code node
   - Function: Updates A2A session with agent results
   - Tracks agent execution status

## Import Instructions

### Method 1: Manual Import (Recommended)

1. **Access n8n UI:**
   - URL: `https://n8n.freqkflag.co`
   - Navigate to "Workflows" page

2. **Import Workflow:**
   - Click "Add Workflow" button
   - In the workflow editor, click the three dots menu (...) in the top right
   - Select "Import from File"
   - Select file: `/root/infra/ai.engine/workflows/n8n/agent-event-router.json`

3. **Verify Import:**
   - Check that all 4 A2A nodes are present:
     - A2A Session Manager
     - Invoke Agent Script (A2A)
     - Format Response (A2A)
     - A2A Session Update

4. **Save and Activate:**
   - Click "Save" button
   - Toggle "Activate workflow" switch to ON

### Method 2: API Import (If credentials available)

```bash
# Run import script
cd /root/infra
./ai.engine/workflows/scripts/import-a2a-workflow.sh
```

**Note:** Requires `N8N_PASSWORD` in `.workspace/.env`

## Workflow Flow

```
Webhook (agent-events)
    ↓
Merge Event Data
    ↓
Route By Agent (Switch)
    ↓
A2A Session Manager ← Creates/retrieves session
    ↓
Invoke Agent Script (A2A) ← Enhanced with session/context
    ↓
Format Response (A2A) ← Includes A2A metadata
    ↓
A2A Session Update ← Updates session
    ↓
Log Event
    ↓
Respond to Webhook
```

## Testing

### Test 1: Basic Webhook (No A2A)

```bash
curl -X POST https://n8n.freqkflag.co/webhook/agent-events \
  -H 'Content-Type: application/json' \
  -d '{
    "agent": "status",
    "trigger": "test"
  }'
```

**Expected:** Workflow executes, A2A Session Manager creates new session

### Test 2: Webhook with A2A Session

```bash
curl -X POST https://n8n.freqkflag.co/webhook/agent-events \
  -H 'Content-Type: application/json' \
  -d '{
    "agent": "status",
    "session_id": "a2a-test-123",
    "task_id": "test-task",
    "context_file": "/tmp/test-context.json"
  }'
```

**Expected:** Workflow uses provided session, passes context to agent

### Test 3: Multi-Agent Sequence

```bash
# Agent 1
curl -X POST https://n8n.freqkflag.co/webhook/agent-events \
  -H 'Content-Type: application/json' \
  -d '{
    "agent": "status",
    "task_id": "multi-agent-test"
  }'

# Agent 2 (with context from Agent 1)
curl -X POST https://n8n.freqkflag.co/webhook/agent-events \
  -H 'Content-Type: application/json' \
  -d '{
    "agent": "architecture",
    "session_id": "<session_id_from_agent_1>",
    "context_file": "<output_file_from_agent_1>",
    "task_id": "multi-agent-test"
  }'
```

**Expected:** Context propagated between agents via A2A protocol

## Validation Checklist

- [ ] Workflow imported successfully
- [ ] All 4 A2A nodes present
- [ ] Workflow saved
- [ ] Workflow activated
- [ ] Webhook accessible: `https://n8n.freqkflag.co/webhook/agent-events`
- [ ] Test 1 passes (basic webhook)
- [ ] Test 2 passes (A2A session)
- [ ] Test 3 passes (multi-agent sequence)
- [ ] Session files created in `.workspace/a2a-sessions/`
- [ ] Session updates working

## Troubleshooting

### Workflow Not Importing

- **Check JSON validity:** `python3 -m json.tool ai.engine/workflows/n8n/agent-event-router.json`
- **Check file permissions:** Ensure file is readable
- **Try manual import:** Use UI import instead of API

### A2A Nodes Not Working

- **Check Code nodes:** Verify JavaScript code is correct
- **Check HTTP Request:** Verify URL and parameters
- **Check session directory:** Ensure `.workspace/a2a-sessions/` exists

### Webhook Not Responding

- **Check workflow activation:** Ensure workflow is activated
- **Check webhook path:** Verify path is `/webhook/agent-events`
- **Check n8n logs:** `docker logs n8n`

## Next Steps

1. **Import workflow** using instructions above
2. **Activate workflow** in n8n UI
3. **Test webhook** with sample requests
4. **Monitor sessions** in `.workspace/a2a-sessions/`
5. **Integrate with orchestration** scripts

## Related Files

- **Workflow:** `ai.engine/workflows/n8n/agent-event-router.json`
- **Import Script:** `ai.engine/workflows/scripts/import-a2a-workflow.sh`
- **A2A Protocol:** `ai.engine/workflows/A2A_PROTOCOL.md`
- **Implementation Report:** `ai.engine/workflows/A2A_IMPLEMENTATION_REPORT.md`

---

**Report Generated:** 2025-11-22  
**Status:** Ready for Testing

