# GitHub MCP Server Setup Guide

**Created:** 2025-11-22  
**Location:** `/root/infra/scripts/github-mcp-server.js`

## Quick Setup

### Step 1: Create GitHub Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
   - URL: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Give it a descriptive name (e.g., "Infra MCP Server")
4. Select the following scopes:
   - ✅ `repo` - Full control of private repositories
   - ✅ `public_repo` - Access public repositories
   - ✅ `read:org` - Read organization membership (if accessing org repos)
   - ✅ `write:org` - Write organization membership (if managing org repos)
5. Click "Generate token"
6. **Copy the token immediately** (you won't be able to see it again)

### Step 2: Add Token to Infisical

Add the GitHub token to Infisical using the MCP tools or CLI:

**Using Infisical MCP (Recommended):**
```text
Use Infisical MCP to create a secret named GITHUB_TOKEN with the token value in the /prod path
```

**Using Infisical CLI:**
```bash
infisical secrets set --env prod --path /prod GITHUB_TOKEN=<your-token-here>
```

**Using Infisical Web UI:**
1. Navigate to https://infisical.freqkflag.co
2. Go to your project → `prod` environment → `/prod` path
3. Click "Add Secret"
4. Name: `GITHUB_TOKEN`
5. Value: `<your-token-here>`
6. Save

### Step 3: Verify Secret Sync

The Infisical Agent will automatically sync the secret to `.workspace/.env` within 60 seconds. Verify:

```bash
grep GITHUB_TOKEN /root/infra/.workspace/.env
```

### Step 4: Configure Cursor IDE

Add the GitHub MCP server to your Cursor IDE configuration:

**Location:** `~/.config/cursor/mcp.json` (Linux) or `~/Library/Application Support/Cursor/mcp.json` (macOS)

**Add to existing configuration:**
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
    },
    "github": {
      "command": "node",
      "args": ["/root/infra/scripts/github-mcp-server.js"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

### Step 5: Restart Cursor IDE

Close and reopen Cursor IDE to load the new MCP server configuration.

### Step 6: Test GitHub MCP Server

**Using MCP Inspector:**
```bash
cd /root/infra/scripts
export GITHUB_TOKEN=$(grep GITHUB_TOKEN /root/infra/.workspace/.env | cut -d'=' -f2)
npx @modelcontextprotocol/inspector node github-mcp-server.js
```

**Using Cursor AI:**
Test with queries like:
- "List my GitHub repositories"
- "Create an issue in the infra repository titled 'Test GitHub MCP'"
- "Get the README file from the infra repository"

## Verification Checklist

- [ ] GitHub token created with required scopes
- [ ] Token added to Infisical `/prod` path as `GITHUB_TOKEN`
- [ ] Secret synced to `.workspace/.env` (check with `grep GITHUB_TOKEN`)
- [ ] Cursor IDE MCP configuration updated
- [ ] Cursor IDE restarted
- [ ] GitHub MCP server accessible in Cursor (test with AI queries)

## Troubleshooting

### Token Not Found
**Error:** `GITHUB_TOKEN environment variable is required`

**Solution:**
1. Verify token is in Infisical: Check `/prod` path in Infisical UI
2. Wait for Infisical Agent sync (60s polling interval)
3. Check `.workspace/.env`: `grep GITHUB_TOKEN /root/infra/.workspace/.env`
4. Manually trigger sync if needed

### Authentication Errors
**Error:** `401 Unauthorized` or `Bad credentials`

**Solution:**
1. Verify token is valid and not expired
2. Check token has required scopes
3. Regenerate token if needed
4. Update token in Infisical

### Rate Limiting
**Error:** `403 API rate limit exceeded`

**Solution:**
- GitHub API allows 5,000 requests/hour for authenticated requests
- Wait for rate limit window to reset
- Consider using GitHub App authentication for higher limits

## Security Notes

- **Token Storage:** GitHub token is stored securely in Infisical and synced to `.workspace/.env`
- **Token Rotation:** Regularly rotate GitHub tokens (recommended: every 90 days)
- **Scope Limitation:** Grant only necessary scopes to minimize risk
- **Audit Logging:** All GitHub API access is logged by GitHub

## Related Documentation

- [GitHub MCP Server Documentation](./github-mcp-server.md)
- [MCP Integration Guide](../ai.engine/MCP_INTEGRATION.md)
- [Infisical MCP Server](../infisical-mcp/README.md)
- [GitHub API Documentation](https://docs.github.com/en/rest)

---

**Last Updated:** 2025-11-22  
**Maintained By:** Infrastructure Agents

