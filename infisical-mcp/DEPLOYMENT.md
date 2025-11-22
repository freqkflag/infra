# Infisical MCP Server Deployment Guide

**Last Updated:** 2025-11-22

This document provides step-by-step instructions for deploying and configuring the Infisical MCP server on the VPS and integrating it with Cursor IDE.

## Prerequisites

- ✅ Infisical CLI installed (`infisical --version`)
- ✅ Infisical instance running at `https://infisical.freqkflag.co`
- ✅ Access to Infisical web UI for creating Machine Identity
- ✅ Node.js 14+ installed (for `npx` command)
- ✅ Cursor IDE installed

## Deployment Steps

### Step 1: Create Machine Identity in Infisical

1. **Log into Infisical:**
   - Navigate to `https://infisical.freqkflag.co`
   - Log in with admin credentials

2. **Create Machine Identity:**
   - Go to **Settings → Machine Identities**
   - Click **Create Machine Identity**
   - Enter name: `infisical-mcp-server`
   - Select authentication method: **Universal Auth**
   - Generate credentials

3. **Copy Credentials:**
   - Copy the **Client ID** (starts with `client_`)
   - Copy the **Client Secret** (starts with `secret_`)
   - **Important:** Save these securely; you won't be able to view the secret again

4. **Configure Permissions:**
   - Grant the Machine Identity read/write access to `/prod` path
   - Set environment: `prod`
   - Ensure proper scopes for secret management

### Step 2: Add Credentials to Infisical Secrets

Store the credentials in Infisical itself for automatic syncing:

```bash
cd /root/infra

# Set Client ID
infisical secrets set --env prod --path /prod \
  INFISICAL_UNIVERSAL_AUTH_CLIENT_ID=<your-client-id>

# Set Client Secret
infisical secrets set --env prod --path /prod \
  INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET=<your-client-secret>

# Verify secrets are set
infisical secrets list --env prod --path /prod | grep INFISICAL_UNIVERSAL_AUTH
```

### Step 3: Wait for Infisical Agent Sync

The Infisical Agent automatically syncs secrets from `/prod` to `.workspace/.env` every 60 seconds.

**Or manually trigger sync:**
```bash
# Check agent status
ps aux | grep "infisical agent"

# If agent is running, wait 60s for next sync
# Or manually regenerate .workspace/.env from template
cd /root/infra
infisical run --env prod --path /prod -- \
  env | grep INFISICAL_UNIVERSAL_AUTH > /tmp/mcp-env.txt
cat /tmp/mcp-env.txt >> .workspace/.env
```

### Step 4: Verify Configuration

Run the setup script to verify everything is configured correctly:

```bash
cd /root/infra/infisical-mcp
./setup.sh
```

The script will:
- ✅ Check for Infisical CLI
- ✅ Verify environment variables exist
- ✅ Test Infisical connectivity
- ✅ Display Cursor configuration instructions

### Step 5: Configure Cursor IDE

1. **Locate Cursor MCP Configuration:**
   - **Linux:** `~/.config/cursor/mcp.json`
   - **macOS:** `~/Library/Application Support/Cursor/mcp.json`
   - **Windows:** `%APPDATA%\Cursor\mcp.json`

2. **Create Configuration File:**
   ```bash
   mkdir -p ~/.config/cursor  # Linux
   # or
   mkdir -p ~/Library/Application\ Support/Cursor  # macOS
   ```

3. **Add MCP Server Configuration:**
   Create or edit the MCP configuration file with:

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

   **Note:** If environment variable resolution doesn't work, use direct values:
   ```json
   {
     "mcpServers": {
       "infisical": {
         "command": "npx",
         "args": ["-y", "@infisical/mcp"],
         "env": {
           "INFISICAL_HOST_URL": "https://infisical.freqkflag.co",
           "INFISICAL_UNIVERSAL_AUTH_CLIENT_ID": "<your-actual-client-id>",
           "INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET": "<your-actual-secret>"
         }
       }
     }
   }
   ```

4. **Ensure Environment Variables are Available:**
   
   If using `${VAR}` syntax, ensure variables are in Cursor's environment:
   
   ```bash
   # Add to ~/.bashrc or ~/.profile (Linux)
   # Add to ~/.zshrc (macOS)
   export INFISICAL_UNIVERSAL_AUTH_CLIENT_ID=<client-id>
   export INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET=<client-secret>
   export INFISICAL_HOST_URL=https://infisical.freqkflag.co
   ```
   
   Then restart Cursor IDE.

### Step 6: Restart Cursor IDE

1. **Completely close Cursor IDE**
2. **Reopen Cursor IDE**
3. **Verify MCP Server Started:**
   - Check Cursor's developer console (`Help → Toggle Developer Tools`)
   - Look for MCP-related messages
   - Check for errors

### Step 7: Test MCP Server

#### Test 1: Using MCP Inspector (Recommended)

```bash
cd /root/infra/infisical-mcp

# Export environment variables
export INFISICAL_UNIVERSAL_AUTH_CLIENT_ID=<client-id>
export INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET=<client-secret>
export INFISICAL_HOST_URL=https://infisical.freqkflag.co

# Launch MCP Inspector
npx @modelcontextprotocol/inspector npx -y @infisical/mcp
```

This will:
- Launch a web UI in your browser
- Allow you to test all available MCP tools
- Verify authentication works
- Debug any issues

#### Test 2: Using Cursor AI Assistant

Once Cursor IDE is configured, test with AI assistant queries:

1. **List secrets:**
   - "What secrets are stored in Infisical?"
   - "List all secrets in the /prod path"

2. **Read secrets:**
   - "What is the database password?"
   - "Show me the value of POSTGRES_PASSWORD"

3. **Update secrets:**
   - "Update the database password to a new value"
   - "Set N8N_PASSWORD to a new password"

### Step 8: (Optional) Deploy as Docker Container

For standalone testing or non-Cursor use cases:

```bash
cd /root/infra/infisical-mcp

# Ensure environment variables are in .workspace/.env
cat ../.workspace/.env | grep INFISICAL_UNIVERSAL_AUTH

# Start container
docker compose up -d

# Check logs
docker compose logs -f infisical-mcp

# Stop container
docker compose down
```

**Note:** Docker deployment is primarily for testing. Cursor IDE integration uses the direct `npx` approach.

## Verification Checklist

- [ ] Machine Identity created in Infisical
- [ ] Universal Auth credentials generated
- [ ] Credentials stored in Infisical `/prod` path
- [ ] `.workspace/.env` contains `INFISICAL_UNIVERSAL_AUTH_*` variables
- [ ] Setup script runs without errors
- [ ] Cursor MCP configuration file created
- [ ] Cursor IDE restarted
- [ ] MCP Inspector test passes
- [ ] AI assistant can interact with Infisical secrets

## Troubleshooting

See `README.md` and `CURSOR_CONFIG.md` for detailed troubleshooting steps.

Common issues:
- **Environment variables not resolving** → Use direct values or system env vars
- **MCP server not starting** → Check Node.js/npx installation
- **Authentication errors** → Verify Machine Identity credentials and permissions
- **Cursor not detecting MCP** → Check configuration file location and JSON syntax

## Security Considerations

- ✅ Credentials stored in Infisical (encrypted)
- ✅ Machine Identity uses least privilege access
- ✅ All secret access logged in Infisical audit logs
- ✅ Never commit credentials to version control
- ✅ Rotate credentials periodically (recommended: every 90 days)

## Documentation

- **Service README:** `/root/infra/infisical-mcp/README.md`
- **Cursor Configuration:** `/root/infra/infisical-mcp/CURSOR_CONFIG.md`
- **Setup Script:** `/root/infra/infisical-mcp/setup.sh`
- **Official Docs:** https://github.com/Infisical/infisical-mcp-server

## Next Steps

After successful deployment:

1. **Test all MCP tools** using MCP Inspector
2. **Use AI assistant** to manage secrets via natural language
3. **Monitor Infisical audit logs** for secret access
4. **Document any custom workflows** or patterns discovered
5. **Rotate credentials** periodically for security

---

**Last Updated:** 2025-11-22  
**Maintained By:** Infrastructure Agents

