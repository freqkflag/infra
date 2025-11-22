# MCP Server Integration

**Created:** 2025-11-22  
**Location:** `/root/infra/ai.engine/`  
**Purpose:** Documentation for using MCP (Model Context Protocol) servers with AI Engine agents

## Overview

The AI Engine integrates with multiple MCP servers to provide direct access to
infrastructure services through function calling. This enables AI agents to
interact with Cloudflare DNS, WikiJS, Infisical, and browser automation without
manual intervention.

## Available MCP Servers

### 1. Infisical MCP Server

**Type:** Official package (`@infisical/mcp`)  
**Location:** `/root/infra/infisical-mcp/`  
**Status:** ✅ Configured and available

**Purpose:** Secure secrets management and credential storage

**Available Tools:**

- `mcp_infisical_list-secrets` - List all secrets in a project/environment
- `mcp_infisical_get-secret` - Get a specific secret value
- `mcp_infisical_create-secret` - Create a new secret
- `mcp_infisical_update-secret` - Update an existing secret
- `mcp_infisical_delete-secret` - Delete a secret
- `mcp_infisical_list-projects` - List all Infisical projects
- `mcp_infisical_create-project` - Create a new project
- `mcp_infisical_create-environment` - Create a new environment
- `mcp_infisical_create-folder` - Create a folder in secret path
- `mcp_infisical_invite-members-to-project` - Invite members to a project

**Configuration:**

- Requires `INFISICAL_UNIVERSAL_AUTH_CLIENT_ID` and
  `INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET`
- Configured in Cursor IDE via `~/.config/cursor/mcp.json`
- Uses self-hosted Infisical instance at `https://infisical.freqkflag.co`

**Documentation:** See `/root/infra/infisical-mcp/README.md`

**Usage Example:**

```text
Use the Infisical MCP server to list all secrets in the prod environment at
path /prod
```

### 2. Cloudflare MCP Server

**Type:** Custom implementation  
**Location:** `/root/infra/scripts/cloudflare-mcp-server.js`  
**Status:** ✅ Configured and available

**Purpose:** DNS management and zone configuration

**Available Tools:**

- `mcp_cloudflare_list_zones` - List all Cloudflare zones (domains)
- `mcp_cloudflare_get_dns_records` - Get DNS records for a zone
- `mcp_cloudflare_create_dns_record` - Create a DNS record (A, CNAME, TXT, etc.)
- `mcp_cloudflare_update_dns_record` - Update an existing DNS record
- `mcp_cloudflare_delete_dns_record` - Delete a DNS record

**Configuration:**

- Requires `CLOUDFLARE_API_TOKEN` or `CF_API_TOKEN` environment variable
- Configured in Cursor IDE via `~/.config/cursor/mcp.json`

**Documentation:** See `/root/infra/scripts/cloudflare-mcp-server.md`

**Usage Example:**

```text
Use the Cloudflare MCP server to create an A record for api.example.com
pointing to 1.2.3.4
```

### 3. WikiJS MCP Server

**Type:** Custom implementation  
**Location:** `/root/infra/scripts/wikijs-mcp-server.js`  
**Status:** ✅ Configured and available

**Purpose:** WikiJS page management and documentation

**Available Tools:**

- `mcp_wikijs_list_pages` - List all WikiJS pages
- `mcp_wikijs_get_page` - Get page by ID or path
- `mcp_wikijs_create_page` - Create a new page
- `mcp_wikijs_update_page` - Update an existing page
- `mcp_wikijs_delete_page` - Delete a page
- `mcp_wikijs_search_pages` - Search pages by query

**Configuration:**

- Requires `WIKIJS_API_KEY` environment variable
- Optional: `WIKIJS_API_URL` (defaults to `https://wiki.freqkflag.co`)
- Configured in Cursor IDE via `~/.config/cursor/mcp.json`

**Documentation:** See `/root/infra/scripts/wikijs-mcp-server.md`

**Usage Example:**

```text
Use the WikiJS MCP server to create a new page titled "Infrastructure Guide"
at path "docs/infrastructure-guide"
```

### 4. Cursor IDE Browser MCP Server

**Type:** Built-in Cursor IDE feature  
**Status:** ✅ Available by default

**Purpose:** Browser automation and web interaction

**Available Tools:**

- `mcp_cursor-ide-browser_browser_navigate` - Navigate to a URL
- `mcp_cursor-ide-browser_browser_snapshot` - Capture accessibility snapshot
- `mcp_cursor-ide-browser_browser_click` - Click on an element
- `mcp_cursor-ide-browser_browser_type` - Type text into an element
- `mcp_cursor-ide-browser_browser_hover` - Hover over an element
- `mcp_cursor-ide-browser_browser_select_option` - Select dropdown option
- `mcp_cursor-ide-browser_browser_press_key` - Press a key
- `mcp_cursor-ide-browser_browser_wait_for` - Wait for text/time
- `mcp_cursor-ide-browser_browser_navigate_back` - Navigate back
- `mcp_cursor-ide-browser_browser_resize` - Resize browser window
- `mcp_cursor-ide-browser_browser_console_messages` - Get console messages
- `mcp_cursor-ide-browser_browser_network_requests` - Get network requests
- `mcp_cursor-ide-browser_browser_take_screenshot` - Take a screenshot

**Configuration:**

- No configuration required - available by default in Cursor IDE

**Usage Example:**

```text
Use the browser MCP server to navigate to https://wiki.freqkflag.co and take
a screenshot
```

## Integration with AI Engine Agents

All AI Engine agents can use MCP servers through function calling. When an
agent needs to interact with infrastructure services, it can invoke MCP tools
directly.

### Agent Usage Patterns

#### 1. Status Agent + MCP

```text
Act as status_agent. Use Infisical MCP to check secret coverage, then analyze
/root/infra. Return global status in strict JSON.
```

#### 2. Security Agent + MCP

```text
Act as security agent. Use Infisical MCP to audit secrets, then evaluate
/root/infra. Return vulnerabilities + fixes in strict JSON.
```

#### 3. Ops Agent + MCP

```text
Act as ops_agent. Use Cloudflare MCP to check DNS records, then analyze
/root/infra. Return operational insights in strict JSON.
```

#### 4. Docs Agent + MCP

```text
Act as docs agent. Use WikiJS MCP to check existing documentation, then scan
/root/infra. Return missing docs + structure in strict JSON.
```

## MCP Tool Reference

### Infisical Tools

#### List Secrets

```json
{
  "projectId": "8c430744-1a5b-4426-af87-e96d6b9c91e3",
  "environmentSlug": "prod",
  "secretPath": "/prod"
}
```

#### Get Secret

```json
{
  "projectId": "8c430744-1a5b-4426-af87-e96d6b9c91e3",
  "environmentSlug": "prod",
  "secretName": "DATABASE_PASSWORD",
  "secretPath": "/prod"
}
```

#### Create Secret

```json
{
  "projectId": "8c430744-1a5b-4426-af87-e96d6b9c91e3",
  "environmentSlug": "prod",
  "secretName": "NEW_SECRET",
  "secretValue": "secret-value",
  "secretPath": "/prod"
}
```

### Cloudflare Tools

#### List Zones

```json
{}
```

#### Get DNS Records

```json
{
  "zone_name": "freqkflag.co"
}
```

#### Create DNS Record

```json
{
  "zone_name": "freqkflag.co",
  "type": "A",
  "name": "api",
  "content": "1.2.3.4",
  "proxied": true
}
```

### WikiJS Tools

#### List Pages

```json
{
  "limit": 50,
  "offset": 0
}
```

#### Get Page

```json
{
  "path": "projects/fl-clone"
}
```

#### Create Page

```json
{
  "title": "New Page",
  "path": "docs/new-page",
  "content": "# New Page\n\nContent here",
  "editor": "markdown",
  "isPublished": true
}
```

### Browser Tools

#### Navigate

```json
{
  "url": "https://wiki.freqkflag.co"
}
```

#### Snapshot

```json
{}
```

#### Click

```json
{
  "element": "Login button",
  "ref": "button#login"
}
```

## Best Practices

### 1. Use MCP for Infrastructure Operations

- Always use MCP servers for infrastructure operations (DNS, secrets,
  documentation)
- Avoid manual steps when MCP tools are available
- Prefer MCP tools over direct API calls in agent workflows

### 2. Error Handling

- Always check for MCP tool availability before use
- Handle authentication errors gracefully
- Provide fallback instructions when MCP tools fail

### 3. Security

- Never expose secrets or credentials in agent outputs
- Use MCP tools for secret operations (Infisical)
- Verify permissions before performing destructive operations

### 4. Documentation

- Use WikiJS MCP to create/update documentation
- Keep documentation synchronized with code changes
- Use MCP tools to verify documentation coverage

### 5. Testing

- Test MCP tools independently before using in agents
- Verify MCP server connectivity
- Check environment variables are set correctly

## Troubleshooting

### MCP Server Not Available

**Symptoms:**

- Agent cannot find MCP tools
- Function calls fail with "tool not found"

**Solutions:**

1. Check MCP server configuration in `~/.config/cursor/mcp.json`
2. Verify environment variables are set
3. Restart Cursor IDE to reload MCP servers
4. Test MCP server manually using MCP Inspector

### Authentication Errors

**Symptoms:**

- MCP tools return authentication errors
- "Unauthorized" or "Invalid credentials" messages

**Solutions:**

1. Verify API keys/tokens are correct
2. Check environment variables in `.workspace/.env`
3. Test authentication manually
4. Regenerate credentials if needed

### Tool Execution Failures

**Symptoms:**

- MCP tools execute but return errors
- Invalid parameter errors

**Solutions:**

1. Check tool parameter schemas
2. Verify required parameters are provided
3. Review MCP server logs
4. Test with MCP Inspector

## Configuration Files

### Cursor IDE MCP Configuration

**Location:** `~/.config/cursor/mcp.json` (Linux) or
`~/Library/Application Support/Cursor/mcp.json` (macOS)

**Example Configuration:**

```json
{
  "mcpServers": {
    "infisical": {
      "command": "npx",
      "args": ["-y", "@infisical/mcp"],
      "env": {
        "INFISICAL_HOST_URL": "https://infisical.freqkflag.co",
        "INFISICAL_UNIVERSAL_AUTH_CLIENT_ID": "${INFISICAL_UNIVERSAL_AUTH_CLIENT_ID}",
        "INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET": "${INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET}"
      }
    },
    "cloudflare": {
      "command": "node",
      "args": ["/root/infra/scripts/cloudflare-mcp-server.js"],
      "env": {
        "CLOUDFLARE_API_TOKEN": "${CF_DNS_API_TOKEN}"
      }
    },
    "wikijs": {
      "command": "node",
      "args": ["/root/infra/scripts/wikijs-mcp-server.js"],
      "env": {
        "WIKIJS_API_KEY": "${WIKIJS_API_KEY}",
        "WIKIJS_API_URL": "https://wiki.freqkflag.co"
      }
    }
  }
}
```

## Related Documentation

- [AI Engine README](./README.md) - Main AI Engine documentation
- [MCP Usage Procedures](./MCP_USAGE_PROCEDURES.md) - Step-by-step procedures and examples
- [MCP Agent](./agents/mcp-agent.md) - MCP agent definition
- [Infisical MCP Server](../infisical-mcp/README.md) - Infisical MCP documentation
- [MCP Setup Guide](../scripts/MCP_SETUP.md) - General MCP setup
- [Cloudflare MCP Server](../scripts/cloudflare-mcp-server.md) - Cloudflare MCP docs
- [WikiJS MCP Server](../scripts/wikijs-mcp-server.md) - WikiJS MCP docs
- [MCP Protocol Specification](https://modelcontextprotocol.io) - Official MCP docs

---

**Last Updated:** 2025-11-22  
**Maintained By:** Infrastructure Agents
