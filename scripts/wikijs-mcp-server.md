# WikiJS MCP Server

## Overview

MCP (Model Context Protocol) server for WikiJS page management. Provides tools for creating, reading, updating, and deleting WikiJS pages programmatically.

## Features

- List all pages
- Get page by ID or path
- Create new pages
- Update existing pages
- Delete pages
- Search pages

## Setup

### Prerequisites

- Node.js 18+
- WikiJS API key stored in `/root/.env`

### Environment Variables

The server reads from `/root/.env`:
- `WIKIJS_API_KEY` - Your WikiJS API key
- `WIKIJS_API_URL` - WikiJS URL (default: https://wiki.freqkflag.co)

### Installation

Dependencies are already installed in `/root/infra/scripts/`:
```bash
cd /root/infra/scripts
npm install
```

## Usage

### As MCP Server

Configure in your MCP client (e.g., Cursor):

```json
{
  "mcpServers": {
    "wikijs": {
      "command": "node",
      "args": ["/root/infra/scripts/wikijs-mcp-server.js"],
      "env": {
        "WIKIJS_API_KEY": "your-api-key",
        "WIKIJS_API_URL": "https://wiki.freqkflag.co"
      }
    }
  }
}
```

### Direct Usage

```bash
# Set environment variables
export WIKIJS_API_KEY="your-api-key"
export WIKIJS_API_URL="https://wiki.freqkflag.co"

# Run server
node /root/infra/scripts/wikijs-mcp-server.js
```

## Available Tools

### list_pages
List all pages in WikiJS.

**Parameters:**
- `limit` (number, optional): Maximum pages to return (default: 50)
- `offset` (number, optional): Pagination offset (default: 0)

### get_page
Get a specific page by path or ID.

**Parameters:**
- `path` (string, optional): Page path (e.g., 'projects/fl-clone')
- `id` (number, optional): Page ID

### create_page
Create a new page.

**Parameters:**
- `title` (string, required): Page title
- `path` (string, required): Page path
- `content` (string, required): Page content (markdown)
- `description` (string, optional): Page description
- `editor` (string, optional): 'markdown' or 'wysiwyg' (default: 'markdown')
- `isPublished` (boolean, optional): Publish immediately (default: true)
- `tags` (array, optional): Page tags

### update_page
Update an existing page.

**Parameters:**
- `id` (number, optional): Page ID
- `path` (string, optional): Page path
- `title` (string, optional): New title
- `content` (string, optional): New content
- `description` (string, optional): New description
- `tags` (array, optional): New tags

### delete_page
Delete a page.

**Parameters:**
- `id` (number, optional): Page ID
- `path` (string, optional): Page path

### search_pages
Search pages by query.

**Parameters:**
- `query` (string, required): Search query
- `limit` (number, optional): Maximum results (default: 20)

## Examples

### Create FL Clone Documentation Page

```javascript
// Via MCP client
{
  "tool": "create_page",
  "arguments": {
    "title": "FL Clone - Building Process Documentation",
    "path": "projects/fl-clone-building-process",
    "content": "# FL Clone Documentation\n\n...",
    "description": "Complete documentation of the FL Clone social platform",
    "editor": "markdown",
    "isPublished": true,
    "tags": ["fl-clone", "rails", "vue", "social-platform"]
  }
}
```

### Update Existing Page

```javascript
{
  "tool": "update_page",
  "arguments": {
    "path": "projects/fl-clone-building-process",
    "content": "# Updated Content\n\n..."
  }
}
```

### Search Pages

```javascript
{
  "tool": "search_pages",
  "arguments": {
    "query": "FL Clone",
    "limit": 10
  }
}
```

## Error Handling

The server returns structured error responses:
```json
{
  "error": "Error message",
  "details": "Additional error details"
}
```

## Security

- API key is read from environment variables
- Never commit API keys to version control
- Use secure storage for production

## Troubleshooting

### Server won't start
- Check WIKIJS_API_KEY is set in `/root/.env`
- Verify WikiJS is accessible at WIKIJS_API_URL
- Check Node.js version (requires 18+)

### API errors
- Verify API key is valid and has proper permissions
- Check WikiJS API endpoint is correct
- Review WikiJS logs for detailed errors

## Related Documentation

- [WikiJS API Documentation](https://docs.requarks.io/api)
- [MCP Protocol Specification](https://modelcontextprotocol.io)
- [WikiJS Runbook](../../runbooks/wikijs-runbook.md)

