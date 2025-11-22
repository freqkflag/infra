# Fix "Route By Agent" Node Type Issue

## Problem
The "Route By Agent" node uses `n8n-nodes-base.switch` typeVersion 3, which is not available in your n8n instance.

## Solution Options

### Option 1: Replace Switch with IF Node (Recommended)

1. Open the workflow: https://n8n.freqkflag.co/workflow/b05wnEzvdIZIH1yD
2. Click on the "Route By Agent" node
3. Delete the node (press Delete key or right-click > Delete)
4. Add a new **IF** node from the node palette
5. Configure the IF node:
   - Condition: `{{$json.body.agent}}` equals `status`
   - This will route status agent events to the "true" output
   - Other agents will go to "false" output
6. Connect:
   - From "Merge Event Data" → To "IF" node
   - From "IF" node (true) → To "Invoke Agent Script"
   - From "IF" node (false) → To "Respond to Webhook" (or create separate handlers)
7. Save the workflow (Ctrl+S)
8. Try activating

### Option 2: Remove Routing Entirely (Simplest)

1. Open the workflow
2. Delete the "Route By Agent" switch node
3. Connect "Merge Event Data" directly to "Invoke Agent Script"
4. This will process all agent events the same way
5. Save and activate

### Option 3: Use Code Node for Routing

1. Delete the "Route By Agent" switch node
2. Add a **Code** node
3. Use this code to route:
```javascript
const agent = $input.item.json.body.agent;
const agents = ['status', 'bug-hunter', 'security', 'ops', 'orchestrator'];

if (agents.includes(agent)) {
  return [{ json: $input.item.json }];
} else {
  return [{ json: { ...$input.item.json, skip: true } }];
}
```
4. Connect and save

## Simplified Workflow JSON

I've created a simplified version without the Switch node at:
`/tmp/simplified-agent-router.json`

You can import this to replace the current workflow if needed.

## After Fixing

Test the webhook:
```bash
curl -X POST https://n8n.freqkflag.co/webhook/agent-events \
  -H "Content-Type: application/json" \
  -d '{"agent":"status","trigger":"test"}'
```

Expected: HTTP 200 OK

