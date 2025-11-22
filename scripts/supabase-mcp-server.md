# Supabase MCP Server

## Overview

The Supabase MCP Server provides tools for managing your self-hosted Supabase instance via the Model Context Protocol. It supports both direct database operations (via PostgreSQL) and REST API operations.

## Configuration

The server reads configuration from environment variables:

- `SUPABASE_URL` or `SUPABASE_PUBLIC_URL` - Supabase API URL (default: `https://api.supabase.freqkflag.co`)
- `SUPABASE_ANON_KEY` or `ANON_KEY` - Supabase anonymous key (for public operations)
- `SUPABASE_SERVICE_KEY` or `SERVICE_ROLE_KEY` - Supabase service role key (for admin operations)
- `SUPABASE_DB_HOST` - Database host (default: `supabase-db`)
- `SUPABASE_DB_USER` - Database user (default: `supabase_admin`)
- `POSTGRES_PASSWORD` - Database password
- `POSTGRES_DB` - Database name (default: `postgres`)

## Setup in Cursor/Claude Desktop

Add to your MCP configuration file (typically `~/.config/cursor/mcp.json` or similar):

```json
{
  "mcpServers": {
    "supabase": {
      "command": "node",
      "args": ["/root/infra/scripts/supabase-mcp-server.js"],
      "env": {
        "SUPABASE_URL": "https://api.supabase.freqkflag.co",
        "SUPABASE_ANON_KEY": "your-anon-key",
        "SUPABASE_SERVICE_KEY": "your-service-key",
        "POSTGRES_PASSWORD": "your-db-password"
      }
    }
  }
}
```

**Note:** For self-hosted instances, you can also load these from your `.workspace/.env` file:

```json
{
  "mcpServers": {
    "supabase": {
      "command": "bash",
      "args": [
        "-c",
        "source /root/infra/.workspace/.env && export ANON_KEY SERVICE_ROLE_KEY POSTGRES_PASSWORD && node /root/infra/scripts/supabase-mcp-server.js"
      ]
    }
  }
}
```

**Important:** The `export` command is required to make the variables available to the Node.js process after sourcing the `.env` file.

## Available Tools

### Database Information

#### `get_project_info`
Get Supabase project information and status.

**Example:**
```json
{
  "name": "get_project_info"
}
```

#### `list_tables`
List all tables in a schema.

**Parameters:**
- `schema` (string, optional) - Schema name (default: "public")

**Example:**
```json
{
  "name": "list_tables",
  "arguments": {
    "schema": "public"
  }
}
```

#### `describe_table`
Get table structure and columns.

**Parameters:**
- `table_name` (string, required) - Table name
- `schema` (string, optional) - Schema name (default: "public")

**Example:**
```json
{
  "name": "describe_table",
  "arguments": {
    "table_name": "users",
    "schema": "public"
  }
}
```

### SQL Operations

#### `execute_query`
Execute a SQL SELECT query (read-only for safety).

**Parameters:**
- `query` (string, required) - SQL SELECT query

**Example:**
```json
{
  "name": "execute_query",
  "arguments": {
    "query": "SELECT COUNT(*) FROM users;"
  }
}
```

**Note:** Only SELECT queries are allowed for safety. Use REST API for mutations.

### Extension Management

#### `list_extensions`
List all installed PostgreSQL extensions.

**Parameters:**
- `schema` (string, optional) - Filter by schema (e.g., "extensions")

**Example:**
```json
{
  "name": "list_extensions",
  "arguments": {
    "schema": "extensions"
  }
}
```

#### `enable_extension`
Enable a PostgreSQL extension.

**Parameters:**
- `extension_name` (string, required) - Extension name (e.g., "pg_trgm")
- `schema` (string, optional) - Schema to install in (default: "extensions")

**Example:**
```json
{
  "name": "enable_extension",
  "arguments": {
    "extension_name": "pg_trgm",
    "schema": "extensions"
  }
}
```

### Function Management

#### `list_functions`
List all database functions.

**Parameters:**
- `schema` (string, optional) - Schema name (default: "public")

**Example:**
```json
{
  "name": "list_functions",
  "arguments": {
    "schema": "public"
  }
}
```

### REST API Operations

#### `rest_query`
Query a table via Supabase REST API.

**Parameters:**
- `table` (string, required) - Table name
- `select` (string, optional) - Columns to select (default: "*")
- `filter` (string, optional) - PostgREST filter (e.g., "id.eq.1")
- `limit` (number, optional) - Limit number of results
- `order` (string, optional) - Order by column (e.g., "id.asc")

**Example:**
```json
{
  "name": "rest_query",
  "arguments": {
    "table": "users",
    "select": "id,name,email",
    "filter": "active.eq.true",
    "limit": 10,
    "order": "created_at.desc"
  }
}
```

#### `rest_insert`
Insert data into a table via REST API.

**Parameters:**
- `table` (string, required) - Table name
- `data` (object, required) - Data to insert (JSON object)

**Example:**
```json
{
  "name": "rest_insert",
  "arguments": {
    "table": "users",
    "data": {
      "name": "John Doe",
      "email": "john@example.com"
    }
  }
}
```

#### `rest_update`
Update data in a table via REST API.

**Parameters:**
- `table` (string, required) - Table name
- `filter` (string, required) - PostgREST filter (e.g., "id.eq.1")
- `data` (object, required) - Data to update (JSON object)

**Example:**
```json
{
  "name": "rest_update",
  "arguments": {
    "table": "users",
    "filter": "id.eq.1",
    "data": {
      "name": "Jane Doe"
    }
  }
}
```

#### `rest_delete`
Delete data from a table via REST API.

**Parameters:**
- `table` (string, required) - Table name
- `filter` (string, required) - PostgREST filter (e.g., "id.eq.1")

**Example:**
```json
{
  "name": "rest_delete",
  "arguments": {
    "table": "users",
    "filter": "id.eq.1"
  }
}
```

## Usage Examples

### List all tables
```
Use the supabase list_tables tool to see all tables in the public schema
```

### Describe a table
```
Use the supabase describe_table tool to get the structure of the users table
```

### Query data via REST API
```
Use the supabase rest_query tool to get the first 10 active users ordered by created_at
```

### Insert data
```
Use the supabase rest_insert tool to add a new user with name "John" and email "john@example.com"
```

### List extensions
```
Use the supabase list_extensions tool to see all installed PostgreSQL extensions
```

## Testing

### Test Supabase MCP Server

```bash
cd /root/infra/scripts
export SUPABASE_URL="https://api.supabase.freqkflag.co"
export SUPABASE_ANON_KEY="your-anon-key"
export SUPABASE_SERVICE_KEY="your-service-key"
export POSTGRES_PASSWORD="your-db-password"
node supabase-mcp-server.js
```

## Security Notes

- The `execute_query` tool only allows SELECT queries for safety
- Use REST API tools for mutations (insert, update, delete)
- Service role key has full access - use with caution
- Anon key has restricted access based on RLS policies
- Database password is required for direct SQL operations
- Never commit API keys or passwords to version control

## Troubleshooting

### Server won't start
- Check environment variables are set correctly
- Verify API keys are valid
- Check Node.js version (requires 18+)
- Ensure Supabase services are running

### Database connection errors
- Verify `POSTGRES_PASSWORD` is correct
- Check database container is running: `docker compose -f /root/infra/supabase/docker-compose.yml ps`
- Ensure database is accessible from the host

### REST API errors
- Verify `SUPABASE_URL` is correct
- Check API keys have proper permissions
- Review Supabase Kong logs for detailed errors
- Ensure RLS policies allow the operation

## Related Documentation

- [Supabase README](../../supabase/README.md)
- [Supabase Extensions](../../supabase/EXTENSIONS.md)
- [MCP Protocol Specification](https://modelcontextprotocol.io)
- [Supabase REST API Documentation](https://supabase.com/docs/reference/javascript/introduction)
- [PostgREST API Reference](https://postgrest.org/en/stable/api.html)

