#!/usr/bin/env node
/**
 * Cloudflare MCP Server
 * Provides DNS management tools via Model Context Protocol
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import axios from "axios";

const CLOUDFLARE_API_TOKEN = process.env.CLOUDFLARE_API_TOKEN || process.env.CF_API_TOKEN;
const CLOUDFLARE_API_BASE = "https://api.cloudflare.com/client/v4";

if (!CLOUDFLARE_API_TOKEN) {
  console.error("Error: CLOUDFLARE_API_TOKEN or CF_API_TOKEN environment variable is required");
  process.exit(1);
}

const headers = {
  Authorization: `Bearer ${CLOUDFLARE_API_TOKEN}`,
  "Content-Type": "application/json",
};

const server = new Server(
  {
    name: "cloudflare-dns",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "list_zones",
        description: "List all Cloudflare zones (domains)",
        inputSchema: {
          type: "object",
          properties: {},
        },
      },
      {
        name: "get_dns_records",
        description: "Get DNS records for a zone",
        inputSchema: {
          type: "object",
          properties: {
            zone_name: {
              type: "string",
              description: "Zone name (e.g., 'freqkflag.co')",
            },
          },
          required: ["zone_name"],
        },
      },
      {
        name: "create_dns_record",
        description: "Create a DNS record (A, CNAME, etc.)",
        inputSchema: {
          type: "object",
          properties: {
            zone_name: {
              type: "string",
              description: "Zone name (e.g., 'freqkflag.co')",
            },
            type: {
              type: "string",
              description: "Record type (A, CNAME, TXT, etc.)",
              enum: ["A", "AAAA", "CNAME", "TXT", "MX", "NS"],
            },
            name: {
              type: "string",
              description: "Record name (e.g., 'infisical' for infisical.freqkflag.co)",
            },
            content: {
              type: "string",
              description: "Record content (IP for A, domain for CNAME, etc.)",
            },
            proxied: {
              type: "boolean",
              description: "Enable Cloudflare proxy (orange cloud)",
              default: true,
            },
          },
          required: ["zone_name", "type", "name", "content"],
        },
      },
      {
        name: "update_dns_record",
        description: "Update an existing DNS record",
        inputSchema: {
          type: "object",
          properties: {
            zone_name: {
              type: "string",
              description: "Zone name",
            },
            record_id: {
              type: "string",
              description: "DNS record ID",
            },
            type: {
              type: "string",
              description: "Record type",
            },
            name: {
              type: "string",
              description: "Record name",
            },
            content: {
              type: "string",
              description: "Record content",
            },
            proxied: {
              type: "boolean",
              description: "Enable Cloudflare proxy",
            },
          },
          required: ["zone_name", "record_id", "type", "name", "content"],
        },
      },
      {
        name: "delete_dns_record",
        description: "Delete a DNS record",
        inputSchema: {
          type: "object",
          properties: {
            zone_name: {
              type: "string",
              description: "Zone name",
            },
            record_id: {
              type: "string",
              description: "DNS record ID",
            },
          },
          required: ["zone_name", "record_id"],
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
      case "list_zones": {
        const response = await axios.get(`${CLOUDFLARE_API_BASE}/zones`, { headers });
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(response.data.result, null, 2),
            },
          ],
        };
      }

      case "get_dns_records": {
        const { zone_name } = args;
        // Get zone ID first
        const zonesResponse = await axios.get(`${CLOUDFLARE_API_BASE}/zones?name=${zone_name}`, { headers });
        if (!zonesResponse.data.result || zonesResponse.data.result.length === 0) {
          throw new Error(`Zone not found: ${zone_name}`);
        }
        const zoneId = zonesResponse.data.result[0].id;
        
        const recordsResponse = await axios.get(`${CLOUDFLARE_API_BASE}/zones/${zoneId}/dns_records`, { headers });
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(recordsResponse.data.result, null, 2),
            },
          ],
        };
      }

      case "create_dns_record": {
        const { zone_name, type, name, content, proxied = true } = args;
        // Get zone ID
        const zonesResponse = await axios.get(`${CLOUDFLARE_API_BASE}/zones?name=${zone_name}`, { headers });
        if (!zonesResponse.data.result || zonesResponse.data.result.length === 0) {
          throw new Error(`Zone not found: ${zone_name}`);
        }
        const zoneId = zonesResponse.data.result[0].id;
        
        const createResponse = await axios.post(
          `${CLOUDFLARE_API_BASE}/zones/${zoneId}/dns_records`,
          {
            type,
            name,
            content,
            proxied,
          },
          { headers }
        );
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(createResponse.data.result, null, 2),
            },
          ],
        };
      }

      case "update_dns_record": {
        const { zone_name, record_id, type, name, content, proxied = true } = args;
        // Get zone ID
        const zonesResponse = await axios.get(`${CLOUDFLARE_API_BASE}/zones?name=${zone_name}`, { headers });
        if (!zonesResponse.data.result || zonesResponse.data.result.length === 0) {
          throw new Error(`Zone not found: ${zone_name}`);
        }
        const zoneId = zonesResponse.data.result[0].id;
        
        const updateResponse = await axios.put(
          `${CLOUDFLARE_API_BASE}/zones/${zoneId}/dns_records/${record_id}`,
          {
            type,
            name,
            content,
            proxied,
          },
          { headers }
        );
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(updateResponse.data.result, null, 2),
            },
          ],
        };
      }

      case "delete_dns_record": {
        const { zone_name, record_id } = args;
        // Get zone ID
        const zonesResponse = await axios.get(`${CLOUDFLARE_API_BASE}/zones?name=${zone_name}`, { headers });
        if (!zonesResponse.data.result || zonesResponse.data.result.length === 0) {
          throw new Error(`Zone not found: ${zone_name}`);
        }
        const zoneId = zonesResponse.data.result[0].id;
        
        const deleteResponse = await axios.delete(
          `${CLOUDFLARE_API_BASE}/zones/${zoneId}/dns_records/${record_id}`,
          { headers }
        );
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(deleteResponse.data, null, 2),
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
  console.error("Cloudflare MCP server running on stdio");
}

main().catch(console.error);


