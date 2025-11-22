# GitHub MCP Server

**Status:** ✅ Configured  
**Location:** `/root/infra/scripts/github-mcp-server.js`  
**Type:** Custom implementation

## Overview

GitHub MCP (Model Context Protocol) server enables AI clients (like Cursor IDE) to interact with GitHub repositories through function calling. This allows AI assistants to manage repositories, issues, pull requests, and more programmatically.

## Features

The GitHub MCP server provides comprehensive GitHub API access:

- **Repository Management** - List, get, and search repositories
- **Issue Management** - Create, update, list, and get issues
- **Pull Request Management** - Create, list, and get pull requests
- **Branch Management** - List branches
- **File Operations** - Get file contents from repositories
- **Search** - Search repositories with advanced queries

## Configuration

### Required Environment Variables

Set these in `.workspace/.env` (managed by Infisical Agent):

- `GITHUB_TOKEN` or `GH_TOKEN` - GitHub Personal Access Token (PAT) with appropriate scopes
- `GITHUB_API_URL` - (Optional) Custom GitHub API URL (defaults to `https://api.github.com`)

### GitHub Token Scopes

The GitHub token requires the following scopes for full functionality:

- `repo` - Full control of private repositories (for private repos)
- `public_repo` - Access public repositories
- `read:org` - Read organization membership (if accessing org repos)
- `write:org` - Write organization membership (if managing org repos)

**Note:** For GitHub Enterprise Server, use `GITHUB_API_URL` to point to your enterprise instance.

### Cursor IDE Configuration

The MCP server is configured in `~/.config/cursor/mcp.json`:

```json
{
  "mcpServers": {
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

**Note:** Cursor will automatically load environment variables from `.workspace/.env` when resolving `${VAR}` placeholders.

## Available Tools

### Repository Tools

- `mcp_github_list_repositories` - List repositories for user or organization
- `mcp_github_get_repository` - Get repository information
- `mcp_github_search_repositories` - Search repositories with query

### Issue Tools

- `mcp_github_list_issues` - List issues for a repository
- `mcp_github_get_issue` - Get a specific issue
- `mcp_github_create_issue` - Create a new issue
- `mcp_github_update_issue` - Update an existing issue

### Pull Request Tools

- `mcp_github_list_pull_requests` - List pull requests for a repository
- `mcp_github_get_pull_request` - Get a specific pull request
- `mcp_github_create_pull_request` - Create a new pull request

### Branch Tools

- `mcp_github_list_branches` - List branches for a repository

### File Tools

- `mcp_github_get_file_contents` - Get file contents from a repository

## Usage Examples

### List Repositories

```json
{
  "owner": "freqkflag",
  "type": "all",
  "sort": "updated"
}
```

### Create Issue

```json
{
  "owner": "freqkflag",
  "repo": "infra",
  "title": "New feature request",
  "body": "Description of the feature",
  "labels": ["enhancement", "infrastructure"]
}
```

### Create Pull Request

```json
{
  "owner": "freqkflag",
  "repo": "infra",
  "title": "Add GitHub MCP server",
  "body": "This PR adds GitHub MCP server integration",
  "head": "feature/github-mcp",
  "base": "main"
}
```

### Get File Contents

```json
{
  "owner": "freqkflag",
  "repo": "infra",
  "path": "README.md",
  "ref": "main"
}
```

## Setup Steps

1. **Create GitHub Personal Access Token:**
   - Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Generate new token with required scopes
   - Copy the token

2. **Add Token to Infisical:**
   ```bash
   infisical secrets set --env prod --path /prod GITHUB_TOKEN=<your-token>
   ```

3. **Sync Secrets:**
   - The Infisical Agent will automatically sync to `.workspace/.env`
   - Or wait for the 60-second polling interval

4. **Configure Cursor IDE:**
   - Add GitHub MCP server configuration to `~/.config/cursor/mcp.json`
   - Restart Cursor IDE to load the new MCP server

## Testing

### Quick Test Script

Test the MCP server independently:

```bash
cd /root/infra/scripts
export GITHUB_TOKEN=<your-token>
npx @modelcontextprotocol/inspector node github-mcp-server.js
```

This launches the MCP Inspector UI where you can:
- View available tools
- Test function calls
- Verify authentication
- Debug issues

### Verifying Cursor Integration

1. Open Cursor IDE
2. Check MCP server status in Cursor's MCP panel (if available)
3. Use AI assistant and test GitHub-related queries:
   - "List my repositories"
   - "Create an issue in the infra repo"
   - "Get the README from the infra repository"

## Security Considerations

- **Token Storage** - GitHub token is stored in Infisical and synced to `.workspace/.env`
- **Least Privilege** - Grant token only necessary scopes
- **Token Rotation** - Regularly rotate GitHub tokens
- **Audit Logging** - All GitHub API access is logged by GitHub

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
   GITHUB_TOKEN=<token> node /root/infra/scripts/github-mcp-server.js
   ```

### Authentication Errors

- Verify GitHub token is valid and not expired
- Check token has required scopes
- Ensure token has access to the repositories you're trying to access

### Rate Limiting

GitHub API has rate limits:
- **Authenticated requests:** 5,000 requests/hour
- **Unauthenticated requests:** 60 requests/hour

The MCP server will return rate limit errors if limits are exceeded. Wait for the rate limit window to reset.

## Related Documentation

- **GitHub API Documentation:** https://docs.github.com/en/rest
- **MCP Protocol:** https://modelcontextprotocol.io
- **Infisical MCP Server:** `/root/infra/infisical-mcp/README.md`
- **Cloudflare MCP Server:** `/root/infra/scripts/cloudflare-mcp-server.md`
- **WikiJS MCP Server:** `/root/infra/scripts/wikijs-mcp-server.md`

---

**Last Updated:** 2025-11-22  
**Maintained By:** Infrastructure Agents

