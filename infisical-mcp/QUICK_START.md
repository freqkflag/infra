# Infisical MCP Server - Quick Start

**Status:** ✅ Credentials Configured - Ready for Cursor IDE Setup

## ✅ Completed Steps

1. **Secrets stored in Infisical:**
   - `INFISICAL_UNIVERSAL_AUTH_CLIENT_ID` = `f2504243-280a-4456-b5a1-a58619d71f67`
   - `INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET` = `c4c8d6968ee80934db83fd70d032c725335318fc0b59aa59c4c5d31bb00050f7`
   - Location: `/prod` path in `prod` environment
   - Project ID: `8c430744-1a5b-4426-af87-e96d6b9c91e3`

2. **Setup verification:** ✅ All checks passed

## Next Steps

### 1. Wait for Infisical Agent Sync (or sync manually)

The Infisical Agent automatically syncs secrets every 60 seconds. Check if secrets are in `.workspace/.env`:

```bash
cd /root/infra
grep INFISICAL_UNIVERSAL_AUTH .workspace/.env
```

**Or manually sync:**
```bash
cd /root/infra
infisical run --projectId 8c430744-1a5b-4426-af87-e96d6b9c91e3 --env prod --path /prod -- \
  printenv | grep INFISICAL_UNIVERSAL_AUTH > /tmp/mcp-secrets.txt
cat /tmp/mcp-secrets.txt >> .workspace/.env
```

### 2. Configure Cursor IDE

Create or edit `~/.config/cursor/mcp.json` (Linux) or `~/Library/Application Support/Cursor/mcp.json` (macOS):

```json
{
  "mcpServers": {
    "infisical": {
      "command": "npx",
      "args": ["-y", "@infisical/mcp"],
      "env": {
        "INFISICAL_HOST_URL": "https://infisical.freqkflag.co",
        "INFISICAL_UNIVERSAL_AUTH_CLIENT_ID": "f2504243-280a-4456-b5a1-a58619d71f67",
        "INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET": "c4c8d6968ee80934db83fd70d032c725335318fc0b59aa59c4c5d31bb00050f7"
      }
    }
  }
}
```

**Note:** Using direct values for now. Once environment variables are synced, you can use `${VAR}` syntax.

### 3. Restart Cursor IDE

1. Completely close Cursor IDE
2. Reopen Cursor IDE
3. The MCP server should start automatically

### 4. Test the Setup

#### Option A: Use MCP Inspector (Recommended)

```bash
cd /root/infra/infisical-mcp
export INFISICAL_UNIVERSAL_AUTH_CLIENT_ID=f2504243-280a-4456-b5a1-a58619d71f67
export INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET=c4c8d6968ee80934db83fd70d032c725335318fc0b59aa59c4c5d31bb00050f7
export INFISICAL_HOST_URL=https://infisical.freqkflag.co
npx @modelcontextprotocol/inspector npx -y @infisical/mcp
```

This launches a web UI where you can test all MCP tools.

#### Option B: Use Test Script

```bash
cd /root/infra/infisical-mcp
export INFISICAL_UNIVERSAL_AUTH_CLIENT_ID=f2504243-280a-4456-b5a1-a58619d71f67
export INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET=c4c8d6968ee80934db83fd70d032c725335318fc0b59aa59c4c5d31bb00050f7
export INFISICAL_HOST_URL=https://infisical.freqkflag.co
./test.sh
```

#### Option C: Test in Cursor IDE

Once Cursor IDE is configured and restarted, test with AI assistant:

- "What secrets are stored in Infisical?"
- "List all secrets in the /prod path"
- "What is the database password?"

## Verification Checklist

- [x] Machine Identity created in Infisical
- [x] Credentials stored in Infisical `/prod` path
- [x] Setup script passes all checks
- [ ] Secrets synced to `.workspace/.env` (wait 60s or sync manually)
- [ ] Cursor IDE MCP configuration created
- [ ] Cursor IDE restarted
- [ ] MCP server tested with MCP Inspector
- [ ] AI assistant can access Infisical secrets

## Troubleshooting

### Secrets Not in .workspace/.env

The Infisical Agent syncs every 60 seconds. To check status:

```bash
ps aux | grep "infisical agent"
```

If not running, secrets won't auto-sync. You can:
1. Wait for agent to sync (up to 60s)
2. Manually copy values to `.workspace/.env`
3. Use direct values in Cursor config (already provided above)

### MCP Server Not Starting in Cursor

1. Verify Cursor configuration file exists and has valid JSON
2. Check Cursor developer console for errors (`Help → Toggle Developer Tools`)
3. Verify Node.js and npx are available: `node --version && npx --version`
4. Test MCP server manually using MCP Inspector (see above)

### Authentication Errors

If you see authentication errors:
1. Verify credentials are correct in Infisical
2. Check Machine Identity has proper permissions
3. Ensure `INFISICAL_HOST_URL` matches your instance (`https://infisical.freqkflag.co`)

## Documentation

- **Complete Setup:** `DEPLOYMENT.md`
- **Cursor Configuration:** `CURSOR_CONFIG.md`
- **Service Documentation:** `README.md`
- **Build Summary:** `BUILD_SUMMARY.md`

---

**Last Updated:** 2025-11-22  
**Status:** ✅ Credentials Configured - Ready for Cursor IDE

