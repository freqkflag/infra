# Next Steps: AI Prompt for Automation Workflows

**Context:** The AI Engine automation workflow system has been fully documented and configured. n8n external webhook access is now enabled. The following steps need to be completed to fully operationalize the automation system.

**Status:** ✅ Documentation complete, ⏭️ Implementation in progress

---

## Immediate Next Steps (Priority Order)

### 1. Import n8n Workflows

**Action:** Import the created n8n workflow JSON files into the n8n instance.

**Prompt:**
```
Access the n8n instance at https://n8n.freqkflag.co and import the following workflow files:

1. Import workflow: /root/infra/ai.engine/workflows/n8n/agent-event-router.json
   - This workflow routes webhook events to appropriate AI Engine agents
   - Webhook endpoint: /webhook/agent-events
   - Verify the workflow is active after import

2. Import workflow: /root/infra/ai.engine/workflows/n8n/health-check-monitor.json
   - This workflow monitors health checks and triggers ops-agent on failures
   - Webhook endpoint: /webhook/health-alert
   - Verify the workflow is active after import

After importing, test each webhook endpoint:
- Test agent-event-router: curl -X POST https://n8n.freqkflag.co/webhook/agent-events -H "Content-Type: application/json" -d '{"agent":"status","trigger":"test"}'
- Test health-check-monitor: curl -X POST https://n8n.freqkflag.co/webhook/health-alert -H "Content-Type: application/json" -d '{"service":"traefik","status":"unhealthy","health_check":"failed","timestamp":"2025-11-22T12:00:00Z"}'

Update the workflows if needed to properly invoke agent scripts (may need to configure HTTP Request nodes to call agent scripts via SSH or local API).
```

---

### 2. Configure Agent Script Invocation in n8n Workflows

**Action:** Update n8n workflows to properly invoke agent scripts on the server.

**Prompt:**
```
The n8n workflows need to actually invoke the AI Engine agent scripts. The current workflow JSON files have placeholder HTTP Request nodes. Update them to:

1. For agent-event-router workflow:
   - Replace the "Invoke Agent Script" HTTP Request node with an SSH node or execute command node
   - Configure it to run: /root/infra/ai.engine/scripts/invoke-agent.sh {agent_name} {output_file}
   - Use the agent name from webhook payload: {{$json.body.agent}}
   - Generate output file path: /root/infra/orchestration/{{$json.body.agent}}-{{$now.format('YYYYMMDD-HHmmss')}}.json
   - Handle authentication (SSH key or system user)

   Alternative: Create a local API endpoint that n8n can call, or use n8n's Execute Command node if available.

2. Verify the workflow can successfully trigger agents and receive results.

3. Test with: curl -X POST https://n8n.freqkflag.co/webhook/agent-events -H "Content-Type: application/json" -d '{"agent":"status","trigger":"manual"}'
```

---

### 3. Set Up Scheduled Tasks (Cron Jobs)

**Action:** Install the scheduled agent runs as cron jobs.

**Prompt:**
```
Run the automation setup script to install scheduled tasks:

cd /root/infra/ai.engine/workflows/scripts
./setup-automation.sh

This will:
- Set up orchestration directory
- Install cron jobs for daily, weekly, and monthly agent runs
- Create Docker event monitoring service
- Configure webhook URL in Infisical (if needed)

Verify cron jobs are installed:
crontab -l | grep ai.engine

Expected cron jobs:
- Daily status check: 0 0 * * *
- Daily backstage check: 0 6 * * *
- Hourly ops check: 0 * * * *
- Weekly orchestrator: 0 2 * * 0
- Weekly security: 0 3 * * 1
- Weekly performance: 0 4 * * 3
- Weekly docs: 0 5 * * 5
- Monthly refactor: 0 6 1 * *
- Monthly MCP: 0 7 15 * *

If setup script needs modifications, update it based on actual agent script locations and paths.
```

---

### 4. Create Node-RED Flows

**Action:** Create Node-RED flows for event-driven automation and result aggregation.

**Prompt:**
```
Access Node-RED at https://nodered.freqkflag.co and create the following flows:

1. Docker Event Handler Flow:
   - Purpose: Process Docker events and trigger agents via webhook
   - Nodes needed:
     * Docker Events node (monitor container events)
     * Function node (filter for die, health_status: unhealthy events)
     * Function node (format payload)
     * HTTP Request node (POST to https://n8n.freqkflag.co/webhook/docker-events)
   - Trigger: On container die or health check failure
   - Output: Webhook to n8n agent-event-router

2. Agent Result Aggregator Flow:
   - Purpose: Aggregate and process agent JSON outputs
   - Nodes needed:
     * Watch node (monitor /root/infra/orchestration/ directory)
     * Function node (parse JSON files)
     * Switch node (route by agent type)
     * Function node (generate summary)
     * HTTP Request node (update WikiJS with findings)
     * File node (save aggregated report)
   - Trigger: When new agent output files are created
   - Output: Aggregated reports and WikiJS updates

3. Notification Router Flow:
   - Purpose: Route agent notifications based on severity
   - Nodes needed:
     * HTTP In node (receive notifications)
     * Function node (extract severity from agent output)
     * Switch node (route by severity: critical, warning, info)
     * HTTP Request nodes (Discord webhook for critical, Email for warnings, Log for info)
   - Trigger: Receives agent notifications
   - Output: Appropriate notification channel

Save these flows and ensure they're active. Test each flow to verify functionality.
```

---

### 5. Test Complete Automation System

**Action:** Test all automation triggers and verify end-to-end functionality.

**Prompt:**
```
Test the complete automation system:

1. Test Webhook Triggering:
   cd /root/infra/ai.engine/workflows/scripts
   ./trigger-agent.sh status /tmp/test-status.json webhook
   ./trigger-agent.sh bug-hunter /tmp/test-bugs.json direct
   Verify agents execute and produce output files.

2. Test Scheduled Tasks:
   Manually trigger a scheduled task to verify it works:
   /root/infra/ai.engine/scripts/status.sh /root/infra/orchestration/test-status-$(date +%Y%m%d).json
   Check that output file is created in orchestration/ directory.

3. Test Health Check Failure Trigger:
   Simulate a health check failure:
   curl -X POST https://n8n.freqkflag.co/webhook/health-alert \
     -H "Content-Type: application/json" \
     -d '{"service":"traefik","status":"unhealthy","health_check":"failed","timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}'
   Verify ops-agent is triggered and processes the alert.

4. Test Docker Event Trigger:
   Trigger a Docker event (if Docker event monitoring is set up):
   docker stop traefik && docker start traefik
   Verify event is captured and processed.

5. Verify Output Storage:
   Check that all agent outputs are stored in /root/infra/orchestration/
   List files: ls -lah /root/infra/orchestration/

6. Check Logs:
   - n8n execution logs: https://n8n.freqkflag.co/executions
   - Automation logs: tail -f /var/log/ai-engine-automation.log
   - Docker event monitor: journalctl -u docker-event-monitor -f

Document any issues found and create fixes.
```

---

### 6. Set Up Docker Event Monitoring

**Action:** Create and start the Docker event monitoring service.

**Prompt:**
```
Set up Docker event monitoring:

1. Review the event monitoring script created by setup-automation.sh:
   cat /usr/local/bin/docker-event-monitor.sh

2. If service wasn't created, create systemd service:
   - Service file: /etc/systemd/system/docker-event-monitor.service
   - Enable and start the service
   - Verify it's running: systemctl status docker-event-monitor

3. Test Docker event capture:
   - Trigger an event: docker stop <container> && docker start <container>
   - Check logs: journalctl -u docker-event-monitor -f
   - Verify webhook is called to n8n

4. If the monitoring script needs updates, modify it and restart the service.

Ensure the service automatically starts on boot and handles restarts gracefully.
```

---

### 7. Configure Notification Channels

**Action:** Set up notification endpoints (Discord, Email, etc.) for agent alerts.

**Prompt:**
```
Configure notification channels for agent alerts:

1. Discord Webhook (for critical alerts):
   - Create Discord webhook URL
   - Store in Infisical: infisical secrets set --env prod --path /prod DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/..."
   - Update n8n workflows to use this webhook for critical alerts
   - Test with a critical alert

2. Email Notifications (for warnings):
   - Configure SMTP settings if not already done
   - Update n8n workflows or Node-RED flows to send emails for warnings
   - Test with a warning alert

3. Logging (for info):
   - Verify automation logs are written to /var/log/ai-engine-automation.log
   - Set up log rotation if needed
   - Test logging functionality

4. Alertmanager Integration (optional):
   - If using Prometheus Alertmanager, configure webhook endpoint
   - Update health-check-monitor workflow to send to Alertmanager
   - Test alert routing

Document all notification endpoints and test each channel.
```

---

### 8. Create Agent API Endpoint (Optional Enhancement)

**Action:** Create a simple API endpoint for agent invocation if n8n SSH/command execution doesn't work well.

**Prompt:**
```
If n8n workflows cannot directly invoke agent scripts, create a simple API endpoint:

1. Create a simple HTTP API service (Python/Node.js) that:
   - Accepts POST requests to /api/v1/agents/invoke
   - Validates agent name and parameters
   - Executes the appropriate agent script
   - Returns agent output or status
   - Handles authentication (API key from Infisical)

2. Deploy as a container or systemd service:
   - Use Docker Compose or systemd
   - Expose on internal network only (not publicly)
   - Configure Traefik route if needed: api.freqkflag.co/agents

3. Update n8n workflows to call this API instead of direct script execution

4. Test API endpoint:
   curl -X POST http://localhost:8080/api/v1/agents/invoke \
     -H "Authorization: Bearer ${API_TOKEN}" \
     -H "Content-Type: application/json" \
     -d '{"agent":"status","output_file":"/tmp/test.json"}'

Alternative: Use the existing scripts/agents/run-agent.py if it supports HTTP API mode.
```

---

### 9. Monitor and Verify Automation

**Action:** Set up monitoring for the automation system itself.

**Prompt:**
```
Create monitoring and verification for the automation system:

1. Create a health check for automation system:
   - Check that n8n is accessible
   - Check that webhook endpoints respond
   - Check that cron jobs are scheduled
   - Check that Docker event monitor is running
   - Check that orchestration directory exists and is writable

2. Create a monitoring script:
   /root/infra/ai.engine/workflows/scripts/check-automation-health.sh
   - Tests all components
   - Returns exit code 0 if healthy, non-zero if issues found
   - Outputs status to logs

3. Add monitoring to scheduled tasks or Prometheus:
   - Run health check script periodically
   - Alert if automation system is unhealthy
   - Track automation metrics (executions, successes, failures)

4. Review automation logs weekly:
   - Check for failed agent runs
   - Check for missed scheduled tasks
   - Check for webhook failures
   - Document and fix issues

5. Update documentation with any changes or improvements discovered.
```

---

### 10. Documentation Updates

**Action:** Keep documentation current as implementation progresses.

**Prompt:**
```
Update documentation as automation system is implemented:

1. Update AUTOMATION_WORKFLOWS.md with:
   - Actual n8n workflow configuration (after import)
   - Actual Node-RED flow configuration (after creation)
   - Any issues encountered and solutions
   - Performance metrics or observations

2. Update workflows/README.md with:
   - Setup verification steps
   - Troubleshooting guide based on actual issues
   - Best practices discovered
   - Usage examples from real deployments

3. Update AUTOMATION_SETUP_SUMMARY.md with:
   - Completion status of each step
   - Testing results
   - Known issues and workarounds

4. Document any custom configurations or deviations from planned setup.

Keep all documentation current and accurate.
```

---

## Quick Reference: Current Status

✅ **Completed:**
- Automation workflow documentation created
- n8n workflow JSON files created
- Automation setup scripts created
- External webhook access enabled in n8n
- Scheduled task definitions created
- Event-driven trigger documentation created

⏭️ **Next Actions:**
1. Import n8n workflows
2. Configure agent script invocation
3. Set up scheduled tasks
4. Create Node-RED flows
5. Test complete system

---

## Usage Instructions for AI

**When continuing this work, use this format:**

```
I need to continue implementing the AI Engine automation workflows. 
The current status is: [specify which step you're on]

Please:
1. [Specific action from the prompts above]
2. [Any additional context or requirements]
3. [Test and verify the implementation]
```

**Example:**
```
I need to continue implementing the AI Engine automation workflows.
The current status is: Ready to import n8n workflows.

Please:
1. Import the n8n workflows from /root/infra/ai.engine/workflows/n8n/
2. Configure the workflows to properly invoke agent scripts
3. Test each webhook endpoint to verify they work
4. Document any configuration changes needed
```

---

**Last Updated:** 2025-11-22  
**Location:** `/root/infra/ai.engine/workflows/NEXT_STEPS_AI_PROMPT.md`

