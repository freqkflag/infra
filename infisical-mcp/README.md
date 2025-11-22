# Infisical MCP Server

**Status:** ✅ Configured  
**Domain:** N/A (MCP server, not HTTP)  
**Location:** `/root/infra/infisical-mcp/`

## Overview

Infisical MCP (Model Context Protocol) server enables AI clients (like Cursor IDE) to interact with Infisical secrets management through function calling. This allows AI assistants to securely read, update, and manage secrets stored in Infisical.

## Architecture

The MCP server runs as a Node.js process that communicates via stdio/stdout with AI clients. It's configured to:
- Connect to self-hosted Infisical instance at `https://infisical.freqkflag.co`
- Authenticate using Machine Identity universal auth credentials
- Provide secure access to secrets without exposing credentials to AI clients

## Configuration

### Required Environment Variables

Set these in `.workspace/.env` (managed by Infisical Agent):

- `INFISICAL_UNIVERSAL_AUTH_CLIENT_ID` - Machine Identity universal auth client ID
- `INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET` - Machine Identity universal auth client secret
- `INFISICAL_HOST_URL` - (Optional) Custom Infisical host URL (defaults to `https://infisical.freqkflag.co`)

### Cursor IDE Configuration

The MCP server is configured in `.cursor/mcp.json`:

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
    }
  }
}
```

**Note:** Cursor will automatically load environment variables from `.workspace/.env` when resolving `${VAR}` placeholders.

## Deployment

### Option 1: Direct Process (Recommended for Cursor IDE)

The MCP server is configured to run directly via `npx` in Cursor IDE. No separate service deployment needed.

### Option 2: Docker Container (For Standalone/Testing)

If you need to run the MCP server as a standalone Docker container:

```bash
cd /root/infra/infisical-mcp
docker compose up -d
```

**Note:** Docker deployment is primarily for testing. Cursor IDE integration uses the direct `npx` approach.

## Setup Steps

1. **Create Machine Identity in Infisical:**
   - Log into Infisical at `https://infisical.freqkflag.co`
   - Navigate to Settings → Machine Identities
   - Create a new Machine Identity
   - Generate Universal Auth credentials (Client ID and Secret)
   - Grant appropriate permissions (read/write to `/prod` path)

2. **Add Credentials to Infisical Secrets:**
   ```bash
   infisical secrets set --env prod --path /prod INFISICAL_UNIVERSAL_AUTH_CLIENT_ID=<client-id>
   infisical secrets set --env prod --path /prod INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET=<client-secret>
   ```

3. **Sync Secrets:**
   - The Infisical Agent will automatically sync these to `.workspace/.env`
   - Or manually regenerate: The agent polls every 60 seconds

4. **Restart Cursor IDE:**
   - Close and reopen Cursor IDE to load the new MCP configuration
   - The MCP server will start automatically when Cursor launches

## Testing

### Quick Test Script

Use the provided test script to verify everything is configured:

```bash
cd /root/infra/infisical-mcp
./test.sh
```

This script will:
- ✅ Check for required environment variables
- ✅ Verify Infisical connectivity
- ✅ Check Node.js and npx installation
- ✅ Launch MCP Inspector for interactive testing

### Using MCP Inspector

Test the MCP server independently:

```bash
cd /root/infra/infisical-mcp
export INFISICAL_UNIVERSAL_AUTH_CLIENT_ID=<client-id>
export INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET=<client-secret>
export INFISICAL_HOST_URL=https://infisical.freqkflag.co
npx @modelcontextprotocol/inspector npx -y @infisical/mcp
```

This launches the MCP Inspector UI in your browser where you can:
- View available tools
- Test function calls
- Verify authentication
- Debug issues

### Verifying Cursor Integration

1. Open Cursor IDE
2. Check MCP server status in Cursor's MCP panel (if available)
3. Use AI assistant and test Infisical-related queries:
   - "What secrets are stored in Infisical?"
   - "Update the database password in Infisical"
   - "List all secrets in the /prod path"

## Available MCP Tools

The Infisical MCP server provides tools for:

- **Reading secrets** - Get secret values from Infisical
- **Writing secrets** - Create or update secrets
- **Listing secrets** - Browse secret paths and keys
- **Environment management** - Manage different environments
- **Path operations** - Navigate and organize secret paths

Refer to [Infisical MCP Server Documentation](https://github.com/Infisical/infisical-mcp-server) for complete tool reference.

## Troubleshooting

### MCP Server Not Starting

1. **Check environment variables:**
   ```bash
   cat .workspace/.env | grep INFISICAL_UNIVERSAL_AUTH
   ```

2. **Verify Infisical connectivity:**
   ```bash
   curl -I https://infisical.freqkflag.co/api/status
   ```

3. **Test MCP server directly:**
   ```bash
   INFISICAL_UNIVERSAL_AUTH_CLIENT_ID=<id> \
   INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET=<secret> \
   INFISICAL_HOST_URL=https://infisical.freqkflag.co \
   npx -y @infisical/mcp
   ```

### Authentication Errors

- Verify Machine Identity credentials are correct
- Check that Machine Identity has proper permissions
- Ensure `INFISICAL_HOST_URL` matches your Infisical instance URL

### Cursor Not Detecting MCP Server

- Verify `.cursor/mcp.json` exists and is valid JSON
- Check that environment variables are resolved (not literal `${VAR}` strings)
- Restart Cursor IDE completely
- Check Cursor logs for MCP-related errors

## Security Considerations

- **Machine Identity credentials** are stored in Infisical and synced to `.workspace/.env`
- **Least privilege** - Grant Machine Identity only necessary permissions
- **Secrets never exposed** - AI clients never see secret values directly, only through MCP tool calls
- **Audit logging** - All secret access is logged in Infisical

## Documentation

- **Official Repository:** https://github.com/Infisical/infisical-mcp-server
- **MCP Protocol:** https://modelcontextprotocol.io
- **Infisical Docs:** https://infisical.com/docs

## Maintenance

- **Update MCP Server:**
  ```bash
  npm install -g @infisical/mcp@latest
  ```

- **Monitor Logs:**
  - Check Cursor IDE logs for MCP server errors
  - Monitor Infisical audit logs for secret access

- **Rotate Credentials:**
  - Periodically rotate Machine Identity credentials
  - Update in Infisical `/prod` path
  - Allow Infisical Agent to sync (60s polling)

---

**Last Updated:** 2025-11-22  
**Maintained By:** Infrastructure Agents

