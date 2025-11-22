# MCP Usage Procedures and Examples

**Created:** 2025-11-22  
**Location:** `/root/infra/ai.engine/`  
**Purpose:** Step-by-step procedures and examples for using MCP servers with AI Engine agents

## Overview

This document provides practical procedures and examples for using MCP (Model Context Protocol) servers with AI Engine agents. It covers common use cases, step-by-step procedures, and real-world examples.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Infisical MCP Procedures](#infisical-mcp-procedures)
3. [Cloudflare MCP Procedures](#cloudflare-mcp-procedures)
4. [WikiJS MCP Procedures](#wikijs-mcp-procedures)
5. [Browser MCP Procedures](#browser-mcp-procedures)
6. [Agent Integration Examples](#agent-integration-examples)
7. [Troubleshooting Procedures](#troubleshooting-procedures)

---

## Quick Start

### Verify MCP Server Availability

```bash
# Check if MCP servers are configured
cat ~/.config/cursor/mcp.json

# Test Infisical MCP
npx @modelcontextprotocol/inspector npx -y @infisical/mcp

# Test Cloudflare MCP
cd /root/infra/scripts
node cloudflare-mcp-server.js

# Test WikiJS MCP
cd /root/infra/scripts
node wikijs-mcp-server.js
```

### Basic MCP Usage in Cursor AI

```
# Example: List Infisical secrets
Use the Infisical MCP server to list all secrets in the prod environment at path /prod

# Example: Create DNS record
Use the Cloudflare MCP server to create an A record for api.example.com pointing to 1.2.3.4

# Example: Create WikiJS page
Use the WikiJS MCP server to create a page titled "New Documentation" at path "docs/new-doc"
```

---

## Infisical MCP Procedures

### Procedure 1: Audit Secrets Coverage

**Use Case:** Check which secrets are configured in Infisical

**Steps:**
1. Use Infisical MCP to list all secrets
2. Compare with service requirements
3. Identify missing secrets

**Example:**
```
Act as security agent. Use Infisical MCP to list all secrets in the prod environment at path /prod. 
Then evaluate /root/infra for missing secrets. Return security findings in strict JSON.
```

**MCP Tool Call:**
```json
{
  "tool": "mcp_infisical_list-secrets",
  "arguments": {
    "projectId": "8c430744-1a5b-4426-af87-e96d6b9c91e3",
    "environmentSlug": "prod",
    "secretPath": "/prod"
  }
}
```

### Procedure 2: Update Secret Value

**Use Case:** Update a secret value in Infisical

**Steps:**
1. Use Infisical MCP to get current secret value
2. Update secret with new value
3. Verify update was successful

**Example:**
```
Use Infisical MCP to update the DATABASE_PASSWORD secret in the prod environment at path /prod with value "new-secure-password"
```

**MCP Tool Call:**
```json
{
  "tool": "mcp_infisical_update-secret",
  "arguments": {
    "projectId": "8c430744-1a5b-4426-af87-e96d6b9c91e3",
    "environmentSlug": "prod",
    "secretName": "DATABASE_PASSWORD",
    "secretValue": "new-secure-password",
    "secretPath": "/prod"
  }
}
```

### Procedure 3: Create New Secret

**Use Case:** Add a new secret for a service

**Steps:**
1. Identify secret name and value
2. Use Infisical MCP to create secret
3. Verify secret was created

**Example:**
```
Use Infisical MCP to create a new secret API_KEY with value "sk-1234567890" in the prod environment at path /prod
```

**MCP Tool Call:**
```json
{
  "tool": "mcp_infisical_create-secret",
  "arguments": {
    "projectId": "8c430744-1a5b-4426-af87-e96d6b9c91e3",
    "environmentSlug": "prod",
    "secretName": "API_KEY",
    "secretValue": "sk-1234567890",
    "secretPath": "/prod"
  }
}
```

---

## Cloudflare MCP Procedures

### Procedure 1: List All DNS Zones

**Use Case:** Get overview of all managed domains

**Steps:**
1. Use Cloudflare MCP to list zones
2. Review zone configuration
3. Identify zones needing updates

**Example:**
```
Act as ops_agent. Use Cloudflare MCP to list all zones, then analyze /root/infra for DNS configuration issues. 
Return operational insights in strict JSON.
```

**MCP Tool Call:**
```json
{
  "tool": "mcp_cloudflare_list_zones",
  "arguments": {}
}
```

### Procedure 2: Create DNS Record

**Use Case:** Add a new subdomain DNS record

**Steps:**
1. Identify zone name
2. Determine record type (A, CNAME, TXT, etc.)
3. Use Cloudflare MCP to create record
4. Verify record was created

**Example:**
```
Use Cloudflare MCP to create an A record for api.freqkflag.co pointing to 1.2.3.4 with Cloudflare proxy enabled
```

**MCP Tool Call:**
```json
{
  "tool": "mcp_cloudflare_create_dns_record",
  "arguments": {
    "zone_name": "freqkflag.co",
    "type": "A",
    "name": "api",
    "content": "1.2.3.4",
    "proxied": true
  }
}
```

### Procedure 3: Update DNS Record

**Use Case:** Change IP address for existing record

**Steps:**
1. Get current DNS record
2. Update record with new IP
3. Verify update was successful

**Example:**
```
Use Cloudflare MCP to get DNS records for freqkflag.co, then update the A record for api.freqkflag.co to point to 5.6.7.8
```

**MCP Tool Call:**
```json
{
  "tool": "mcp_cloudflare_get_dns_records",
  "arguments": {
    "zone_name": "freqkflag.co"
  }
}
```

Then:
```json
{
  "tool": "mcp_cloudflare_update_dns_record",
  "arguments": {
    "zone_name": "freqkflag.co",
    "record_id": "record-id-from-get",
    "type": "A",
    "name": "api",
    "content": "5.6.7.8",
    "proxied": true
  }
}
```

---

## WikiJS MCP Procedures

### Procedure 1: List All Pages

**Use Case:** Get overview of existing documentation

**Steps:**
1. Use WikiJS MCP to list pages
2. Review page structure
3. Identify documentation gaps

**Example:**
```
Act as docs agent. Use WikiJS MCP to list all pages, then scan /root/infra for missing documentation. 
Return missing docs + structure in strict JSON.
```

**MCP Tool Call:**
```json
{
  "tool": "mcp_wikijs_list_pages",
  "arguments": {
    "limit": 50,
    "offset": 0
  }
}
```

### Procedure 2: Create Documentation Page

**Use Case:** Add new documentation for a service

**Steps:**
1. Prepare page content (markdown)
2. Determine page path
3. Use WikiJS MCP to create page
4. Verify page was created

**Example:**
```
Use WikiJS MCP to create a page titled "Service Deployment Guide" at path "docs/deployment-guide" with markdown content
```

**MCP Tool Call:**
```json
{
  "tool": "mcp_wikijs_create_page",
  "arguments": {
    "title": "Service Deployment Guide",
    "path": "docs/deployment-guide",
    "content": "# Service Deployment Guide\n\nThis guide covers...",
    "editor": "markdown",
    "isPublished": true,
    "tags": ["deployment", "guide"]
  }
}
```

### Procedure 3: Update Existing Page

**Use Case:** Update documentation with new information

**Steps:**
1. Get current page content
2. Update content with new information
3. Use WikiJS MCP to update page
4. Verify update was successful

**Example:**
```
Use WikiJS MCP to get the page at path "docs/deployment-guide", then update it with new deployment steps
```

**MCP Tool Call:**
```json
{
  "tool": "mcp_wikijs_get_page",
  "arguments": {
    "path": "docs/deployment-guide"
  }
}
```

Then:
```json
{
  "tool": "mcp_wikijs_update_page",
  "arguments": {
    "path": "docs/deployment-guide",
    "content": "# Service Deployment Guide\n\nUpdated content...",
    "tags": ["deployment", "guide", "updated"]
  }
}
```

---

## Browser MCP Procedures

### Procedure 1: Visual Verification

**Use Case:** Verify a service is accessible and working

**Steps:**
1. Navigate to service URL
2. Take snapshot
3. Verify page loaded correctly
4. Take screenshot for documentation

**Example:**
```
Use browser MCP to navigate to https://wiki.freqkflag.co, take a snapshot, and then take a screenshot
```

**MCP Tool Calls:**
```json
{
  "tool": "mcp_cursor-ide-browser_browser_navigate",
  "arguments": {
    "url": "https://wiki.freqkflag.co"
  }
}
```

```json
{
  "tool": "mcp_cursor-ide-browser_browser_snapshot",
  "arguments": {}
}
```

```json
{
  "tool": "mcp_cursor-ide-browser_browser_take_screenshot",
  "arguments": {
    "filename": "wiki-homepage.png",
    "fullPage": true
  }
}
```

### Procedure 2: Automated Testing

**Use Case:** Test a web form or interaction

**Steps:**
1. Navigate to page
2. Fill form fields
3. Submit form
4. Verify result

**Example:**
```
Use browser MCP to navigate to https://wiki.freqkflag.co/login, type username and password, click login button, and verify login was successful
```

**MCP Tool Calls:**
```json
{
  "tool": "mcp_cursor-ide-browser_browser_navigate",
  "arguments": {
    "url": "https://wiki.freqkflag.co/login"
  }
}
```

```json
{
  "tool": "mcp_cursor-ide-browser_browser_type",
  "arguments": {
    "element": "Username field",
    "ref": "input[name='username']",
    "text": "admin"
  }
}
```

```json
{
  "tool": "mcp_cursor-ide-browser_browser_type",
  "arguments": {
    "element": "Password field",
    "ref": "input[name='password']",
    "text": "password",
    "submit": true
  }
}
```

---

## Agent Integration Examples

### Example 1: Security Audit with Infisical MCP

**Scenario:** Audit secrets coverage and security

**Agent Prompt:**
```
Act as security agent. Use Infisical MCP to list all secrets in the prod environment at path /prod. 
Then evaluate /root/infra for:
1. Missing secrets
2. Exposed secrets
3. Weak secret values
4. Security misconfigurations

Return vulnerabilities + fixes in strict JSON.
```

**Expected MCP Calls:**
1. `mcp_infisical_list-secrets` - Get all secrets
2. `mcp_infisical_get-secret` - Get specific secrets for analysis

### Example 2: DNS Management with Cloudflare MCP

**Scenario:** Verify DNS configuration for all services

**Agent Prompt:**
```
Act as ops_agent. Use Cloudflare MCP to:
1. List all zones
2. Get DNS records for each zone
3. Verify DNS records match service configuration in /root/infra

Return operational insights + DNS issues in strict JSON.
```

**Expected MCP Calls:**
1. `mcp_cloudflare_list_zones` - Get all zones
2. `mcp_cloudflare_get_dns_records` - Get records for each zone

### Example 3: Documentation Sync with WikiJS MCP

**Scenario:** Sync code documentation to WikiJS

**Agent Prompt:**
```
Act as docs agent. Use WikiJS MCP to:
1. List existing pages
2. Check which services have documentation
3. Create missing documentation pages from /root/infra service README files

Return missing docs + created pages in strict JSON.
```

**Expected MCP Calls:**
1. `mcp_wikijs_list_pages` - Get existing pages
2. `mcp_wikijs_search_pages` - Search for specific pages
3. `mcp_wikijs_create_page` - Create missing pages

### Example 4: Visual Verification with Browser MCP

**Scenario:** Verify services are accessible

**Agent Prompt:**
```
Act as status_agent. Use browser MCP to:
1. Navigate to each service URL
2. Take snapshots
3. Verify services are responding

Then analyze /root/infra and return status with service accessibility in strict JSON.
```

**Expected MCP Calls:**
1. `mcp_cursor-ide-browser_browser_navigate` - Navigate to each service
2. `mcp_cursor-ide-browser_browser_snapshot` - Get page state
3. `mcp_cursor-ide-browser_browser_take_screenshot` - Capture screenshots

---

## Troubleshooting Procedures

### Procedure 1: MCP Server Not Available

**Symptoms:**
- Agent cannot find MCP tools
- Function calls fail with "tool not found"

**Steps:**
1. Check MCP configuration:
   ```bash
   cat ~/.config/cursor/mcp.json
   ```

2. Verify environment variables:
   ```bash
   cat .workspace/.env | grep -E "INFISICAL|CLOUDFLARE|WIKIJS"
   ```

3. Test MCP server manually:
   ```bash
   # Infisical
   npx @modelcontextprotocol/inspector npx -y @infisical/mcp
   
   # Cloudflare
   cd /root/infra/scripts
   node cloudflare-mcp-server.js
   
   # WikiJS
   cd /root/infra/scripts
   node wikijs-mcp-server.js
   ```

4. Restart Cursor IDE to reload MCP servers

### Procedure 2: Authentication Errors

**Symptoms:**
- MCP tools return authentication errors
- "Unauthorized" or "Invalid credentials" messages

**Steps:**
1. Verify API keys/tokens:
   ```bash
   # Infisical
   cat .workspace/.env | grep INFISICAL_UNIVERSAL_AUTH
   
   # Cloudflare
   cat .workspace/.env | grep CLOUDFLARE_API_TOKEN
   
   # WikiJS
   cat .workspace/.env | grep WIKIJS_API_KEY
   ```

2. Test authentication:
   ```bash
   # Infisical
   infisical secrets list --env prod --path /prod
   
   # Cloudflare
   curl -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" https://api.cloudflare.com/client/v4/zones
   
   # WikiJS
   curl -H "Authorization: Bearer $WIKIJS_API_KEY" https://wiki.freqkflag.co/api/pages
   ```

3. Regenerate credentials if needed

### Procedure 3: Tool Execution Failures

**Symptoms:**
- MCP tools execute but return errors
- Invalid parameter errors

**Steps:**
1. Check tool parameter schemas in MCP documentation
2. Verify required parameters are provided
3. Review MCP server logs
4. Test with MCP Inspector:
   ```bash
   npx @modelcontextprotocol/inspector npx -y @infisical/mcp
   ```

---

## Best Practices

### 1. Always Verify MCP Availability

Before using MCP tools in agents, verify they are available:
```
Act as mcp_agent. Check MCP server availability, then provide recommendations for using MCP tools.
```

### 2. Use MCP for Infrastructure Operations

Prefer MCP tools over manual operations:
- Use Infisical MCP for secrets management
- Use Cloudflare MCP for DNS management
- Use WikiJS MCP for documentation
- Use Browser MCP for visual verification

### 3. Error Handling

Always handle MCP failures gracefully:
- Check for MCP tool availability before use
- Provide fallback instructions when MCP tools fail
- Log MCP errors for debugging

### 4. Security

Never expose secrets in agent outputs:
- Use MCP tools for secret operations
- Verify permissions before destructive operations
- Audit MCP tool usage

### 5. Documentation

Document MCP usage patterns:
- Track which MCP tools are used
- Document integration patterns
- Share best practices

---

## Related Documentation

- [MCP Integration Guide](./MCP_INTEGRATION.md) - Complete MCP integration documentation
- [AI Engine README](./README.md) - Main AI Engine documentation
- [MCP Agent](./agents/mcp-agent.md) - MCP agent definition
- [Infisical MCP Server](../../infisical-mcp/README.md) - Infisical MCP docs
- [MCP Setup Guide](../../scripts/MCP_SETUP.md) - General MCP setup

---

**Last Updated:** 2025-11-22  
**Maintained By:** Infrastructure Agents

