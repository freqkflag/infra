#!/usr/bin/env node
/**
 * Supabase MCP Server
 * Provides Supabase database and API management tools via Model Context Protocol
 * For self-hosted Supabase instances
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import axios from "axios";
import { execSync } from "child_process";

// Configuration from environment
const SUPABASE_URL = process.env.SUPABASE_URL || process.env.SUPABASE_PUBLIC_URL || "https://api.supabase.freqkflag.co";
// Support multiple naming conventions
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || process.env.ANON_KEY;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY || process.env.SERVICE_ROLE_KEY;
const SUPABASE_DB_HOST = process.env.SUPABASE_DB_HOST || "supabase-db";
const SUPABASE_DB_USER = process.env.SUPABASE_DB_USER || "supabase_admin";
const SUPABASE_DB_PASSWORD = process.env.POSTGRES_PASSWORD;
const SUPABASE_DB_NAME = process.env.POSTGRES_DB || "postgres";

// Auto-map common variable names if not explicitly set
if (!SUPABASE_ANON_KEY && process.env.ANON_KEY) {
  process.env.SUPABASE_ANON_KEY = process.env.ANON_KEY;
}
if (!SUPABASE_SERVICE_KEY && process.env.SERVICE_ROLE_KEY) {
  process.env.SUPABASE_SERVICE_KEY = process.env.SERVICE_ROLE_KEY;
}

// Re-read after mapping
const FINAL_ANON_KEY = process.env.SUPABASE_ANON_KEY || process.env.ANON_KEY;
const FINAL_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY || process.env.SERVICE_ROLE_KEY;

if (!FINAL_ANON_KEY && !FINAL_SERVICE_KEY) {
  console.error("Error: SUPABASE_ANON_KEY (or ANON_KEY) or SUPABASE_SERVICE_KEY (or SERVICE_ROLE_KEY) environment variable is required");
  process.exit(1);
}

// Use service key for admin operations, anon key for public operations
const API_KEY = FINAL_SERVICE_KEY || FINAL_ANON_KEY;

const headers = {
  apikey: API_KEY,
  Authorization: `Bearer ${API_KEY}`,
  "Content-Type": "application/json",
  "Prefer": "return=representation",
};

const server = new Server(
  {
    name: "supabase",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Helper function to execute SQL via docker compose
function execSQL(sql) {
  try {
    const command = `cd /root/infra/supabase && docker compose exec -T supabase-db psql -h localhost -U ${SUPABASE_DB_USER} -d ${SUPABASE_DB_NAME} -c "${sql.replace(/"/g, '\\"')}"`;
    const result = execSync(command, { 
      encoding: 'utf-8',
      env: { ...process.env, PGPASSWORD: SUPABASE_DB_PASSWORD }
    });
    return result.trim();
  } catch (error) {
    throw new Error(`SQL execution failed: ${error.message}`);
  }
}

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "get_project_info",
        description: "Get Supabase project information and status",
        inputSchema: {
          type: "object",
          properties: {},
        },
      },
      {
        name: "list_tables",
        description: "List all tables in the database",
        inputSchema: {
          type: "object",
          properties: {
            schema: {
              type: "string",
              description: "Schema name (default: 'public')",
              default: "public",
            },
          },
        },
      },
      {
        name: "describe_table",
        description: "Get table structure and columns",
        inputSchema: {
          type: "object",
          properties: {
            table_name: {
              type: "string",
              description: "Table name",
            },
            schema: {
              type: "string",
              description: "Schema name (default: 'public')",
              default: "public",
            },
          },
          required: ["table_name"],
        },
      },
      {
        name: "execute_query",
        description: "Execute a SQL query (SELECT only for safety)",
        inputSchema: {
          type: "object",
          properties: {
            query: {
              type: "string",
              description: "SQL SELECT query to execute",
            },
          },
          required: ["query"],
        },
      },
      {
        name: "list_extensions",
        description: "List all installed PostgreSQL extensions",
        inputSchema: {
          type: "object",
          properties: {
            schema: {
              type: "string",
              description: "Filter by schema (e.g., 'extensions')",
            },
          },
        },
      },
      {
        name: "enable_extension",
        description: "Enable a PostgreSQL extension",
        inputSchema: {
          type: "object",
          properties: {
            extension_name: {
              type: "string",
              description: "Extension name (e.g., 'pg_trgm')",
            },
            schema: {
              type: "string",
              description: "Schema to install extension in (default: 'extensions')",
              default: "extensions",
            },
          },
          required: ["extension_name"],
        },
      },
      {
        name: "list_functions",
        description: "List all database functions",
        inputSchema: {
          type: "object",
          properties: {
            schema: {
              type: "string",
              description: "Schema name (default: 'public')",
              default: "public",
            },
          },
        },
      },
      {
        name: "rest_query",
        description: "Query a table via Supabase REST API",
        inputSchema: {
          type: "object",
          properties: {
            table: {
              type: "string",
              description: "Table name",
            },
            select: {
              type: "string",
              description: "Columns to select (default: '*')",
              default: "*",
            },
            filter: {
              type: "string",
              description: "PostgREST filter (e.g., 'id.eq.1')",
            },
            limit: {
              type: "number",
              description: "Limit number of results",
            },
            order: {
              type: "string",
              description: "Order by column (e.g., 'id.asc')",
            },
          },
          required: ["table"],
        },
      },
      {
        name: "rest_insert",
        description: "Insert data into a table via REST API",
        inputSchema: {
          type: "object",
          properties: {
            table: {
              type: "string",
              description: "Table name",
            },
            data: {
              type: "object",
              description: "Data to insert (JSON object)",
            },
          },
          required: ["table", "data"],
        },
      },
      {
        name: "rest_update",
        description: "Update data in a table via REST API",
        inputSchema: {
          type: "object",
          properties: {
            table: {
              type: "string",
              description: "Table name",
            },
            filter: {
              type: "string",
              description: "PostgREST filter (e.g., 'id.eq.1')",
            },
            data: {
              type: "object",
              description: "Data to update (JSON object)",
            },
          },
          required: ["table", "filter", "data"],
        },
      },
      {
        name: "rest_delete",
        description: "Delete data from a table via REST API",
        inputSchema: {
          type: "object",
          properties: {
            table: {
              type: "string",
              description: "Table name",
            },
            filter: {
              type: "string",
              description: "PostgREST filter (e.g., 'id.eq.1')",
            },
          },
          required: ["table", "filter"],
        },
      },
    ],
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "get_project_info": {
        const info = {
          url: SUPABASE_URL,
          database: SUPABASE_DB_NAME,
          has_anon_key: !!SUPABASE_ANON_KEY,
          has_service_key: !!SUPABASE_SERVICE_KEY,
          timestamp: new Date().toISOString(),
        };
        
        // Try to get database version
        try {
          const version = execSQL("SELECT version();");
          info.database_version = version.split('\n')[1]?.trim();
        } catch (e) {
          info.database_version = "Unable to retrieve";
        }
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(info, null, 2),
            },
          ],
        };
      }

      case "list_tables": {
        const schema = args.schema || "public";
        const sql = `SELECT table_name, table_type FROM information_schema.tables WHERE table_schema = '${schema}' ORDER BY table_name;`;
        const result = execSQL(sql);
        return {
          content: [
            {
              type: "text",
              text: result,
            },
          ],
        };
      }

      case "describe_table": {
        const { table_name, schema = "public" } = args;
        const sql = `SELECT column_name, data_type, is_nullable, column_default FROM information_schema.columns WHERE table_schema = '${schema}' AND table_name = '${table_name}' ORDER BY ordinal_position;`;
        const result = execSQL(sql);
        return {
          content: [
            {
              type: "text",
              text: result,
            },
          ],
        };
      }

      case "execute_query": {
        const { query } = args;
        
        // Safety check: only allow SELECT queries
        const trimmedQuery = query.trim().toUpperCase();
        if (!trimmedQuery.startsWith("SELECT")) {
          throw new Error("Only SELECT queries are allowed for safety. Use REST API for mutations.");
        }
        
        const result = execSQL(query);
        return {
          content: [
            {
              type: "text",
              text: result,
            },
          ],
        };
      }

      case "list_extensions": {
        let sql = `SELECT extname, extversion, nspname FROM pg_extension e JOIN pg_namespace n ON e.extnamespace = n.oid`;
        if (args.schema) {
          sql += ` WHERE nspname = '${args.schema}'`;
        }
        sql += ` ORDER BY extname;`;
        const result = execSQL(sql);
        return {
          content: [
            {
              type: "text",
              text: result,
            },
          ],
        };
      }

      case "enable_extension": {
        const { extension_name, schema = "extensions" } = args;
        const sql = `CREATE EXTENSION IF NOT EXISTS "${extension_name}" WITH SCHEMA ${schema};`;
        const result = execSQL(sql);
        return {
          content: [
            {
              type: "text",
              text: `Extension "${extension_name}" enabled in schema "${schema}"\n${result}`,
            },
          ],
        };
      }

      case "list_functions": {
        const schema = args.schema || "public";
        const sql = `SELECT routine_name, routine_type, data_type FROM information_schema.routines WHERE routine_schema = '${schema}' ORDER BY routine_name;`;
        const result = execSQL(sql);
        return {
          content: [
            {
              type: "text",
              text: result,
            },
          ],
        };
      }

      case "rest_query": {
        const { table, select = "*", filter, limit, order } = args;
        let url = `${SUPABASE_URL}/rest/v1/${table}?select=${select}`;
        
        if (filter) url += `&${filter}`;
        if (limit) url += `&limit=${limit}`;
        if (order) url += `&order=${order}`;
        
        const response = await axios.get(url, { headers });
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(response.data, null, 2),
            },
          ],
        };
      }

      case "rest_insert": {
        const { table, data } = args;
        const url = `${SUPABASE_URL}/rest/v1/${table}`;
        const response = await axios.post(url, data, { headers });
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(response.data, null, 2),
            },
          ],
        };
      }

      case "rest_update": {
        const { table, filter, data } = args;
        let url = `${SUPABASE_URL}/rest/v1/${table}`;
        if (filter) url += `?${filter}`;
        const response = await axios.patch(url, data, { headers });
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(response.data, null, 2),
            },
          ],
        };
      }

      case "rest_delete": {
        const { table, filter } = args;
        let url = `${SUPABASE_URL}/rest/v1/${table}`;
        if (filter) url += `?${filter}`;
        const response = await axios.delete(url, { headers });
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(response.data || { message: "Deleted successfully" }, null, 2),
            },
          ],
        };
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    return {
      content: [
        {
          type: "text",
          text: `Error: ${error.message}`,
        },
      ],
      isError: true,
    };
  }
});

// Start server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Supabase MCP server running on stdio");
}

main().catch(console.error);

