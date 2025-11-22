# Cursor IDE Configuration for Infisical MCP Server

This document provides instructions for configuring Cursor IDE to use the Infisical MCP server.

## Configuration File Location

Cursor IDE MCP configuration is typically stored in:
- **Linux:** `~/.config/cursor/mcp.json`
- **macOS:** `~/Library/Application Support/Cursor/mcp.json`
- **Windows:** `%APPDATA%\Cursor\mcp.json`

If the file doesn't exist, create it.

## Configuration Content

Add the following configuration to your Cursor MCP configuration file:

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

**Important Notes:**

1. **Environment Variable Resolution:** Cursor IDE may need environment variables to be available at runtime. Ensure your environment variables are loaded:
   - From `.workspace/.env` (if Cursor supports workspace env files)
   - From system environment variables
   - Or use absolute values (less secure)

2. **Alternative: Direct Values (Not Recommended):**
   If environment variable resolution doesn't work, you can use direct values (store securely):
   ```json
   {
     "mcpServers": {
       "infisical": {
         "command": "npx",
         "args": ["-y", "@infisical/mcp"],
         "env": {
           "INFISICAL_HOST_URL": "https://infisical.freqkflag.co",
           "INFISICAL_UNIVERSAL_AUTH_CLIENT_ID": "<your-client-id>",
           "INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET": "<your-client-secret>"
         }
       }
     }
   }
   ```

## Setup Steps

1. **Create Machine Identity in Infisical:**
   - Log into Infisical at `https://infisical.freqkflag.co`
   - Navigate to **Settings → Machine Identities**
   - Click **Create Machine Identity**
   - Generate **Universal Auth** credentials
   - Copy the **Client ID** and **Client Secret**

2. **Add Credentials to Infisical Secrets:**
   ```bash
   cd /root/infra
   infisical secrets set --env prod --path /prod INFISICAL_UNIVERSAL_AUTH_CLIENT_ID=<client-id>
   infisical secrets set --env prod --path /prod INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET=<client-secret>
   ```

3. **Sync Secrets to .workspace/.env:**
   - Wait for Infisical Agent to sync (polls every 60s), or
   - Manually copy values from Infisical to `.workspace/.env`

4. **Configure Cursor IDE:**
   - Create or edit the MCP configuration file at the location listed above
   - Add the configuration JSON shown above
   - If using environment variables, ensure they're available to Cursor IDE

5. **Restart Cursor IDE:**
   - Completely close and restart Cursor IDE
   - The MCP server should start automatically

6. **Verify Connection:**
   - Open Cursor IDE
   - Check for MCP server status (if available in UI)
   - Test with AI assistant queries like:
     - "What secrets are in Infisical?"
     - "List all secrets in the /prod path"

## Troubleshooting

### MCP Server Not Starting

1. **Check Node.js and npx:**
   ```bash
   node --version
   npx --version
   ```
   Ensure Node.js 14+ is installed.

2. **Test MCP Server Manually:**
   ```bash
   cd /root/infra/infisical-mcp
   export INFISICAL_UNIVERSAL_AUTH_CLIENT_ID=<id>
   export INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET=<secret>
   export INFISICAL_HOST_URL=https://infisical.freqkflag.co
   npx -y @infisical/mcp
   ```

3. **Use MCP Inspector:**
   ```bash
   npx @modelcontextprotocol/inspector npx -y @infisical/mcp
   ```
   This launches a web UI to test the MCP server.

### Environment Variables Not Resolved

If `${VAR}` syntax doesn't work in Cursor:

1. **Use system environment variables:**
   ```bash
   # Add to ~/.bashrc or ~/.profile
   export INFISICAL_UNIVERSAL_AUTH_CLIENT_ID=<id>
   export INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET=<secret>
   export INFISICAL_HOST_URL=https://infisical.freqkflag.co
   ```
   Then restart Cursor IDE.

2. **Or use direct values** (less secure, but functional)

### Cursor Not Detecting MCP Server

1. **Verify configuration file location:**
   - Check the exact path for your OS
   - Ensure the file exists and has valid JSON

2. **Check file permissions:**
   ```bash
   ls -la ~/.config/cursor/mcp.json  # Linux
   ```

3. **Check Cursor logs:**
   - Look for MCP-related errors in Cursor's developer console
   - Usually accessible via `Help → Toggle Developer Tools`

## Alternative: Workspace-Level Configuration

If Cursor supports workspace-level MCP configuration, you can create `.cursor/mcp.json` in the workspace root. However, this file may be blocked by `.gitignore` for security reasons.

## Security Best Practices

1. **Never commit credentials** to version control
2. **Use environment variables** instead of hardcoded values
3. **Rotate credentials** periodically
4. **Use least privilege** - grant Machine Identity only necessary permissions
5. **Monitor access logs** in Infisical for suspicious activity

## Documentation

- **Infisical MCP Server:** https://github.com/Infisical/infisical-mcp-server
- **MCP Protocol:** https://modelcontextprotocol.io
- **Infisical Docs:** https://infisical.com/docs

---

**Last Updated:** 2025-11-22

