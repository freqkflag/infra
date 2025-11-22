# GitHub Admin MCP Server Setup Guide

**Created:** 2025-11-22  
**Location:** `/root/infra/scripts/github-admin-mcp-server.js`  
**Version:** 2.0.0

## Quick Setup

### Step 1: Verify GitHub Token

The GitHub token is already configured in Infisical. Verify it's synced:

```bash
grep GITHUB_TOKEN /root/infra/.workspace/.env
```

If not present, wait up to 60 seconds for Infisical Agent to sync.

### Step 2: Configure Cursor IDE

Add the GitHub Admin MCP server to your Cursor IDE configuration:

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
    },
    "github-admin": {
      "command": "node",
      "args": ["/root/infra/scripts/github-admin-mcp-server.js"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

### Step 3: Restart Cursor IDE

Close and reopen Cursor IDE to load the new MCP server configuration.

### Step 4: Test GitHub Admin MCP Server

**Using MCP Inspector:**
```bash
cd /root/infra/scripts
export GITHUB_TOKEN=$(grep GITHUB_TOKEN /root/infra/.workspace/.env | cut -d'=' -f2)
npx @modelcontextprotocol/inspector node github-admin-mcp-server.js
```

**Using Cursor AI:**
Test with queries like:
- "List my GitHub Apps"
- "List all organizations I'm a member of"
- "Create a new team in my organization"
- "List all webhooks for my organization"

## Available Administrative Tools

### GitHub Apps Management (8 tools)
- List, get, create, update, delete GitHub Apps
- Manage app installations

### OAuth Apps Management (6 tools)
- List, get, create, update, delete OAuth Apps
- Reset OAuth app tokens

### Organizations Management (6 tools)
- List, get, update organizations
- Manage organization members

### Teams Management (8 tools)
- List, get, create, update, delete teams
- Manage team members

### Webhooks Management (10 tools)
- Manage organization webhooks
- Manage repository webhooks

### GitHub Actions (10 tools)
- Manage repository secrets and variables
- Manage organization secrets
- Get public keys for encryption

### Self-Hosted Runners (4 tools)
- List, get, delete runners (org and repo)

### Repository Management (7 tools)
- Create, update, delete repositories
- Transfer repositories
- Manage collaborators

### Branch Protection (3 tools)
- Get, update, delete branch protection rules

**Total: 62 administrative tools**

## Usage Examples

### Create a GitHub App
```text
Use GitHub Admin MCP to create a GitHub App named "My App" with URL
https://myapp.com and callback URL https://myapp.com/callback
```

### List Organizations
```text
Use GitHub Admin MCP to list all organizations I'm a member of
```

### Create a Team
```text
Use GitHub Admin MCP to create a team named "Developers" in organization
"myorg" with push permission
```

### Create an Organization Webhook
```text
Use GitHub Admin MCP to create an organization webhook for "myorg" with
URL https://myapp.com/webhook and events push and pull_request
```

## Verification Checklist

- [ ] GitHub token configured in Infisical (`GITHUB_TOKEN`)
- [ ] Token synced to `.workspace/.env` (check with `grep GITHUB_TOKEN`)
- [ ] Cursor IDE MCP configuration updated
- [ ] Cursor IDE restarted
- [ ] GitHub Admin MCP server accessible in Cursor (test with AI queries)

## Security Notes

- **Full Account Access:** The GitHub Admin MCP server requires a token with full account access
- **Token Storage:** Token stored securely in Infisical and synced to `.workspace/.env`
- **Token Rotation:** Regularly rotate GitHub tokens (recommended: every 90 days)
- **Audit Logging:** All GitHub API access is logged by GitHub
- **Use with Caution:** Administrative tools can make significant changes - verify actions before executing

## Troubleshooting

### MCP Server Not Starting

1. **Check environment variables:**
   ```bash
   cat .workspace/.env | grep GITHUB_TOKEN
   ```

2. **Verify GitHub connectivity:**
   ```bash
   curl -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/user
   ```

3. **Test MCP server directly:**
   ```bash
   GITHUB_TOKEN=<token> node /root/infra/scripts/github-admin-mcp-server.js
   ```

### Authentication Errors

- Verify GitHub token is valid and not expired
- Check token has required scopes (full account access)
- Ensure token has access to the resources you're trying to access

### Rate Limiting

GitHub API has rate limits:
- **Authenticated requests:** 5,000 requests/hour
- **Unauthenticated requests:** 60 requests/hour

The MCP server will return rate limit errors if limits are exceeded. Wait for the rate limit window to reset.

## Related Documentation

- [GitHub Admin MCP Server Documentation](./github-admin-mcp-server.md)
- [Standard GitHub MCP Server](./github-mcp-server.md)
- [MCP Integration Guide](../ai.engine/MCP_INTEGRATION.md)
- [GitHub REST API Documentation](https://docs.github.com/en/rest?apiVersion=2022-11-28)

---

**Last Updated:** 2025-11-22  
**Maintained By:** Infrastructure Agents

