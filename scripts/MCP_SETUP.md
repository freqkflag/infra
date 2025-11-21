# MCP Server Setup Guide

## Overview

This directory contains MCP (Model Context Protocol) servers for infrastructure management:

- **Cloudflare MCP Server** - DNS management
- **WikiJS MCP Server** - Wiki page management

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

