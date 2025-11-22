# MCP Server Setup Guide

## Overview

This directory contains MCP (Model Context Protocol) servers for infrastructure management:

- **Cloudflare MCP Server** - DNS management
- **WikiJS MCP Server** - Wiki page management
- **Supabase MCP Server** - Supabase database and API management
- **GitHub MCP Server** - GitHub repository and issue management
- **Kong Admin MCP Server** - Kong API Gateway management (NEW - Phase 3.4)
- **Docker/Compose MCP Server** - Docker container lifecycle management (NEW - Phase 3.4)
- **Monitoring MCP Server** - Prometheus, Grafana, Alertmanager queries (NEW - Phase 3.4)
- **GitLab MCP Server** - GitLab projects, pipelines, issues management (NEW - Phase 3.4)

## WikiJS MCP Server

### Configuration

The WikiJS MCP server is configured to read from `/root/.env`:
- `WIKIJS_API_KEY` - Your WikiJS API key
- `WIKIJS_API_URL` - WikiJS URL (default: https://wiki.freqkflag.co)

### Setup in Cursor/Claude Desktop

Add to your MCP configuration file (typically `~/.config/cursor/mcp.json` or similar):

```json
{
  "mcpServers": {
    "wikijs": {
      "command": "node",
      "args": ["/root/infra/scripts/wikijs-mcp-server.js"],
      "env": {
        "WIKIJS_API_KEY": "your-api-key-from-env",
        "WIKIJS_API_URL": "https://wiki.freqkflag.co"
      }
    },
    "cloudflare": {
      "command": "node",
      "args": ["/root/infra/scripts/cloudflare-mcp-server.js"],
      "env": {
        "CLOUDFLARE_API_TOKEN": "your-cloudflare-token"
      }
    },
    "supabase": {
      "command": "node",
      "args": ["/root/infra/scripts/supabase-mcp-server.js"],
      "env": {
        "SUPABASE_URL": "https://api.supabase.freqkflag.co",
        "SUPABASE_ANON_KEY": "your-anon-key",
        "SUPABASE_SERVICE_KEY": "your-service-key",
        "POSTGRES_PASSWORD": "your-db-password"
      }
    },
    "kong": {
      "command": "node",
      "args": ["/root/infra/scripts/kong-mcp-server.js"],
      "env": {
        "KONG_ADMIN_URL": "http://kong:8001",
        "KONG_ADMIN_KEY": "${KONG_ADMIN_KEY}"
      }
    },
    "docker-compose": {
      "command": "node",
      "args": ["/root/infra/scripts/docker-compose-mcp-server.js"],
      "env": {
        "DEVTOOLS_WORKSPACE": "/root/infra"
      }
    },
    "monitoring": {
      "command": "node",
      "args": ["/root/infra/scripts/monitoring-mcp-server.js"],
      "env": {
        "PROMETHEUS_URL": "https://prometheus.freqkflag.co",
        "GRAFANA_URL": "https://grafana.freqkflag.co",
        "ALERTMANAGER_URL": "https://alertmanager.freqkflag.co",
        "GRAFANA_API_KEY": "${GRAFANA_API_KEY}"
      }
    },
    "gitlab": {
      "command": "node",
      "args": ["/root/infra/scripts/gitlab-mcp-server.js"],
      "env": {
        "GITLAB_URL": "https://gitlab.freqkflag.co",
        "GITLAB_PAT": "${GITLAB_PAT}"
      }
    }
  }
}
```

### Available Tools

#### WikiJS Tools
- `list_pages` - List all WikiJS pages
- `get_page` - Get page by ID or path
- `create_page` - Create new page
- `update_page` - Update existing page
- `delete_page` - Delete page
- `search_pages` - Search pages

#### Cloudflare Tools
- `list_zones` - List all Cloudflare zones
- `get_dns_records` - Get DNS records for a zone
- `create_dns_record` - Create DNS record
- `update_dns_record` - Update DNS record
- `delete_dns_record` - Delete DNS record

#### Supabase Tools
- `get_project_info` - Get Supabase project information
- `list_tables` - List all tables in a schema
- `describe_table` - Get table structure and columns
- `execute_query` - Execute SQL SELECT query (read-only)
- `list_extensions` - List installed PostgreSQL extensions
- `enable_extension` - Enable a PostgreSQL extension
- `list_functions` - List database functions
- `rest_query` - Query table via REST API
- `rest_insert` - Insert data via REST API
- `rest_update` - Update data via REST API
- `rest_delete` - Delete data via REST API

#### GitHub Tools
- `list_repositories` - List repositories
- `get_repository` - Get repository information
- `list_issues` - List issues
- `create_issue` - Create issue
- `list_pull_requests` - List pull requests
- And more (see `github-mcp-server.md`)

#### Kong Admin Tools (NEW - Phase 3.4)
- `list_services` - List all Kong services
- `list_routes` - List all Kong routes
- `apply_service_patch` - Create or update a Kong service
- `sync_plugin` - Create or update a Kong plugin
- `reload` - Reload Kong configuration

#### Docker/Compose Tools (NEW - Phase 3.4)
- `list_containers` - List all Docker containers with status and health
- `compose_up` - Start services using docker compose
- `compose_down` - Stop services using docker compose
- `compose_logs` - Get logs from docker compose services
- `health_report` - Get aggregated health status of all containers

#### Monitoring Tools (NEW - Phase 3.4)
- `prom_query` - Execute a PromQL query against Prometheus
- `grafana_dashboard` - Get Grafana dashboard by UID
- `alertmanager_list` - List all active alerts from Alertmanager
- `ack_alert` - Acknowledge/silence an alert in Alertmanager

#### GitLab Tools (NEW - Phase 3.4)
- `list_projects` - List all GitLab projects
- `get_pipeline_status` - Get status of a GitLab pipeline
- `create_issue` - Create a new GitLab issue
- `update_variable` - Update a GitLab CI/CD variable

### Usage Examples

Once configured, you can use the MCP tools in your AI assistant:

**Create WikiJS Page:**
```
Use the wikijs create_page tool to create a page titled "My New Page" 
at path "projects/my-page" with content "# My Page\n\nContent here"
```

**List WikiJS Pages:**
```
List all pages in WikiJS using the wikijs list_pages tool
```

**Create DNS Record:**
```
Use the cloudflare create_dns_record tool to create an A record 
for subdomain.example.com pointing to 1.2.3.4
```

**List Supabase Tables:**
```
Use the supabase list_tables tool to see all tables in the public schema
```

**Query Supabase Data:**
```
Use the supabase rest_query tool to get users from the users table with a limit of 10
```

## Testing

### Test WikiJS MCP Server

```bash
cd /root/infra/scripts
export WIKIJS_API_KEY="your-key"
export WIKIJS_API_URL="https://wiki.freqkflag.co"
node wikijs-mcp-server.js
```

### Test Cloudflare MCP Server

```bash
cd /root/infra/scripts
export CLOUDFLARE_API_TOKEN="your-token"
node cloudflare-mcp-server.js
```

### Test Supabase MCP Server

```bash
cd /root/infra/scripts
source /root/infra/.workspace/.env
node supabase-mcp-server.js
```

Or with explicit environment variables:

```bash
cd /root/infra/scripts
export SUPABASE_URL="https://api.supabase.freqkflag.co"
export SUPABASE_ANON_KEY="your-anon-key"
export SUPABASE_SERVICE_KEY="your-service-key"
export POSTGRES_PASSWORD="your-db-password"
node supabase-mcp-server.js
```

## Troubleshooting

### Server won't start
- Check environment variables are set
- Verify API keys are valid
- Check Node.js version (requires 18+)

### Tools not available
- Restart your MCP client
- Check MCP configuration file syntax
- Verify server paths are correct

### API errors
- Verify API keys have proper permissions
- Check service URLs are accessible
- Review service logs for detailed errors

## Security Notes

- API keys are stored in `/root/.env` (600 permissions)
- Never commit API keys to version control
- Use secure storage for production
- Rotate API keys regularly

## Related Documentation

- [WikiJS Runbook](../../runbooks/wikijs-runbook.md)
- [MCP Protocol Specification](https://modelcontextprotocol.io)
- [WikiJS API Documentation](https://docs.requarks.io/api)

