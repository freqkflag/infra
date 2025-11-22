# GitHub Admin MCP Server

**Status:** ✅ Configured  
**Location:** `/root/infra/scripts/github-admin-mcp-server.js`  
**Type:** Custom implementation (Comprehensive Administrative Tools)  
**Version:** 2.0.0

## Overview

GitHub Admin MCP (Model Context Protocol) server provides comprehensive administrative access to your GitHub account through function calling. This enables AI assistants to manage GitHub Apps, OAuth Apps, Organizations, Teams, Webhooks, Actions secrets/variables, Runners, Repositories, and more programmatically.

**Reference:** [GitHub REST API Documentation](https://docs.github.com/en/rest?apiVersion=2022-11-28)

## Features

The GitHub Admin MCP server provides comprehensive GitHub administrative API access:

### GitHub Apps Management
- Create, list, update, and delete GitHub Apps
- Manage app installations
- Configure app permissions and webhooks

### OAuth Apps Management
- Create, list, update, and delete OAuth Apps
- Reset OAuth app tokens
- Manage OAuth app configurations

### Organizations Management
- List and get organization information
- Update organization settings
- Manage organization members
- Configure organization permissions

### Teams Management
- Create, list, update, and delete teams
- Manage team members
- Configure team permissions and privacy

### Webhooks Management
- Create, list, update, and delete organization webhooks
- Create, list, update, and delete repository webhooks
- Configure webhook events and secrets

### GitHub Actions Management
- Manage repository secrets (list, create, update, delete)
- Manage organization secrets
- Manage repository variables
- Get public keys for secret encryption

### Self-Hosted Runners
- List organization runners
- List repository runners
- Get and delete runners

### Repository Management (Enhanced)
- Create, update, and delete repositories
- Transfer repositories
- Manage collaborators
- Configure branch protection rules

## Configuration

### Required Environment Variables

Set these in `.workspace/.env` (managed by Infisical Agent):

- `GITHUB_TOKEN` or `GH_TOKEN` - GitHub Personal Access Token (PAT) with full account access
- `GITHUB_API_URL` - (Optional) Custom GitHub API URL (defaults to `https://api.github.com`)

### GitHub Token Scopes

The GitHub token requires full account access with the following scopes:

- `repo` - Full control of private repositories
- `admin:org` - Full control of orgs and teams
- `admin:public_key` - Full control of user public keys
- `admin:repo_hook` - Full control of repository hooks
- `admin:org_hook` - Full control of organization hooks
- `admin:gpg_key` - Full control of user GPG keys
- `write:packages` - Upload packages to GitHub Package Registry
- `read:packages` - Download packages from GitHub Package Registry
- `delete:packages` - Delete packages from GitHub Package Registry
- `admin:enterprise` - Full control of enterprise settings (if applicable)

**Note:** For GitHub Enterprise Server, use `GITHUB_API_URL` to point to your enterprise instance.

### Cursor IDE Configuration

The MCP server is configured in `~/.config/cursor/mcp.json`:

```json
{
  "mcpServers": {
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

**Note:** Cursor will automatically load environment variables from `.workspace/.env` when resolving `${VAR}` placeholders.

## Available Tools

### GitHub Apps Management (7 tools)

1. **`mcp_github-admin_list_github_apps`** - List GitHub Apps
2. **`mcp_github-admin_get_github_app`** - Get GitHub App
3. **`mcp_github-admin_create_github_app`** - Create GitHub App
4. **`mcp_github-admin_update_github_app`** - Update GitHub App
5. **`mcp_github-admin_delete_github_app`** - Delete GitHub App
6. **`mcp_github-admin_list_app_installations`** - List app installations
7. **`mcp_github-admin_get_app_installation`** - Get app installation
8. **`mcp_github-admin_delete_app_installation`** - Delete app installation

### OAuth Apps Management (6 tools)

9. **`mcp_github-admin_list_oauth_apps`** - List OAuth Apps
10. **`mcp_github-admin_get_oauth_app`** - Get OAuth App
11. **`mcp_github-admin_create_oauth_app`** - Create OAuth App
12. **`mcp_github-admin_update_oauth_app`** - Update OAuth App
13. **`mcp_github-admin_delete_oauth_app`** - Delete OAuth App
14. **`mcp_github-admin_reset_oauth_app_token`** - Reset OAuth App token

### Organizations Management (6 tools)

15. **`mcp_github-admin_list_organizations`** - List organizations
16. **`mcp_github-admin_get_organization`** - Get organization
17. **`mcp_github-admin_update_organization`** - Update organization
18. **`mcp_github-admin_list_organization_members`** - List org members
19. **`mcp_github-admin_add_organization_member`** - Add org member
20. **`mcp_github-admin_remove_organization_member`** - Remove org member

### Teams Management (8 tools)

21. **`mcp_github-admin_list_teams`** - List teams
22. **`mcp_github-admin_get_team`** - Get team
23. **`mcp_github-admin_create_team`** - Create team
24. **`mcp_github-admin_update_team`** - Update team
25. **`mcp_github-admin_delete_team`** - Delete team
26. **`mcp_github-admin_list_team_members`** - List team members
27. **`mcp_github-admin_add_team_member`** - Add team member
28. **`mcp_github-admin_remove_team_member`** - Remove team member

### Webhooks Management (10 tools)

29. **`mcp_github-admin_list_org_webhooks`** - List org webhooks
30. **`mcp_github-admin_create_org_webhook`** - Create org webhook
31. **`mcp_github-admin_get_org_webhook`** - Get org webhook
32. **`mcp_github-admin_update_org_webhook`** - Update org webhook
33. **`mcp_github-admin_delete_org_webhook`** - Delete org webhook
34. **`mcp_github-admin_list_repo_webhooks`** - List repo webhooks
35. **`mcp_github-admin_create_repo_webhook`** - Create repo webhook
36. **`mcp_github-admin_get_repo_webhook`** - Get repo webhook
37. **`mcp_github-admin_update_repo_webhook`** - Update repo webhook
38. **`mcp_github-admin_delete_repo_webhook`** - Delete repo webhook

### GitHub Actions Secrets & Variables (10 tools)

39. **`mcp_github-admin_list_repo_secrets`** - List repo secrets
40. **`mcp_github-admin_get_repo_public_key`** - Get repo public key
41. **`mcp_github-admin_create_or_update_repo_secret`** - Create/update repo secret
42. **`mcp_github-admin_delete_repo_secret`** - Delete repo secret
43. **`mcp_github-admin_list_org_secrets`** - List org secrets
44. **`mcp_github-admin_get_org_public_key`** - Get org public key
45. **`mcp_github-admin_list_repo_variables`** - List repo variables
46. **`mcp_github-admin_create_repo_variable`** - Create repo variable
47. **`mcp_github-admin_update_repo_variable`** - Update repo variable
48. **`mcp_github-admin_delete_repo_variable`** - Delete repo variable

### Self-Hosted Runners (4 tools)

49. **`mcp_github-admin_list_org_runners`** - List org runners
50. **`mcp_github-admin_list_repo_runners`** - List repo runners
51. **`mcp_github-admin_get_runner`** - Get runner
52. **`mcp_github-admin_delete_runner`** - Delete runner

### Repository Management (7 tools)

53. **`mcp_github-admin_create_repository`** - Create repository
54. **`mcp_github-admin_update_repository`** - Update repository
55. **`mcp_github-admin_delete_repository`** - Delete repository
56. **`mcp_github-admin_transfer_repository`** - Transfer repository
57. **`mcp_github-admin_list_collaborators`** - List collaborators
58. **`mcp_github-admin_add_collaborator`** - Add collaborator
59. **`mcp_github-admin_remove_collaborator`** - Remove collaborator

### Branch Protection (3 tools)

60. **`mcp_github-admin_get_branch_protection`** - Get branch protection
61. **`mcp_github-admin_update_branch_protection`** - Update branch protection
62. **`mcp_github-admin_delete_branch_protection`** - Delete branch protection

**Total: 62 administrative tools**

## Usage Examples

### Create a GitHub App

```json
{
  "name": "My GitHub App",
  "url": "https://myapp.com",
  "description": "My awesome GitHub App",
  "callback_url": "https://myapp.com/callback",
  "webhook_url": "https://myapp.com/webhook",
  "permissions": {
    "metadata": "read",
    "contents": "read"
  },
  "events": ["push", "pull_request"]
}
```

### Create an OAuth App

```json
{
  "name": "My OAuth App",
  "url": "https://myapp.com",
  "description": "My OAuth application",
  "callback_url": "https://myapp.com/callback"
}
```

### Create an Organization Webhook

```json
{
  "org": "myorg",
  "config": {
    "url": "https://myapp.com/webhook",
    "content_type": "json",
    "secret": "mysecret"
  },
  "events": ["push", "pull_request"],
  "active": true
}
```

### Create a Repository Secret

First, get the public key:
```json
{
  "owner": "freqkflag",
  "repo": "infra"
}
```

Then encrypt your secret value and create/update:
```json
{
  "owner": "freqkflag",
  "repo": "infra",
  "secret_name": "MY_SECRET",
  "encrypted_value": "<encrypted-value>",
  "key_id": "<key-id>"
}
```

### Create a Team

```json
{
  "org": "myorg",
  "name": "Developers",
  "description": "Development team",
  "privacy": "secret",
  "permission": "push"
}
```

## Setup Steps

1. **GitHub Token:** Already configured in Infisical as `GITHUB_TOKEN`
2. **Verify Token Sync:** Check `.workspace/.env` for `GITHUB_TOKEN`
3. **Configure Cursor IDE:** Add GitHub Admin MCP to `~/.config/cursor/mcp.json`
4. **Restart Cursor IDE:** Close and reopen to load the new MCP server

## Testing

### Quick Test Script

Test the MCP server independently:

```bash
cd /root/infra/scripts
export GITHUB_TOKEN=$(grep GITHUB_TOKEN /root/infra/.workspace/.env | cut -d'=' -f2)
npx @modelcontextprotocol/inspector node github-admin-mcp-server.js
```

### Verifying Cursor Integration

1. Open Cursor IDE
2. Check MCP server status in Cursor's MCP panel
3. Use AI assistant and test GitHub Admin queries:
   - "List my GitHub Apps"
   - "Create a new GitHub App"
   - "List all organizations I'm a member of"
   - "Create a team in my organization"

## Security Considerations

- **Token Storage:** GitHub token stored securely in Infisical and synced to `.workspace/.env`
- **Full Account Access:** Token has full administrative access - use with caution
- **Token Rotation:** Regularly rotate GitHub tokens (recommended: every 90 days)
- **Audit Logging:** All GitHub API access is logged by GitHub
- **Least Privilege:** Consider using more restricted tokens for specific use cases

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
- Check token has required scopes
- Ensure token has access to the resources you're trying to access

### Rate Limiting

GitHub API has rate limits:
- **Authenticated requests:** 5,000 requests/hour
- **Unauthenticated requests:** 60 requests/hour

The MCP server will return rate limit errors if limits are exceeded. Wait for the rate limit window to reset.

### Secret Encryption

When creating/updating secrets, you must:
1. Get the public key using `get_repo_public_key` or `get_org_public_key`
2. Encrypt your secret value using the public key (use `tweetsodium` or similar)
3. Use the encrypted value and key_id when creating/updating the secret

## Related Documentation

- **GitHub REST API:** https://docs.github.com/en/rest?apiVersion=2022-11-28
- **GitHub Apps:** https://docs.github.com/en/apps
- **OAuth Apps:** https://docs.github.com/en/apps/oauth-apps
- **MCP Protocol:** https://modelcontextprotocol.io
- **Standard GitHub MCP Server:** `/root/infra/scripts/github-mcp-server.md`

---

**Last Updated:** 2025-11-22  
**Maintained By:** Infrastructure Agents

