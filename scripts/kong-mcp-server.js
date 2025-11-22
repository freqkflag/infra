#!/usr/bin/env node
/**
 * Kong Admin MCP Server
 * Provides Kong API Gateway management tools via Model Context Protocol
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import axios from "axios";

const KONG_ADMIN_URL = process.env.KONG_ADMIN_URL || "http://kong:8001";
const KONG_ADMIN_KEY = process.env.KONG_ADMIN_KEY || "";

const server = new Server(
  {
    name: "kong-admin",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Helper function to make Kong API requests
async function kongRequest(method, path, data = null) {
  const url = `${KONG_ADMIN_URL}${path}`;
  const config = {
    method,
    url,
    headers: {
      "Content-Type": "application/json",
    },
  };
  
  if (KONG_ADMIN_KEY) {
    config.headers["Kong-Admin-Token"] = KONG_ADMIN_KEY;
  }
  
  if (data) {
    config.data = data;
  }
  
  try {
    const response = await axios(config);
    return response.data;
  } catch (error) {
    throw new Error(`Kong API error: ${error.response?.data?.message || error.message}`);
  }
}

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "list_services",
        description: "List all Kong services",
        inputSchema: {
          type: "object",
          properties: {},
        },
      },
      {
        name: "list_routes",
        description: "List all Kong routes",
        inputSchema: {
          type: "object",
          properties: {},
        },
      },
      {
        name: "apply_service_patch",
        description: "Create or update a Kong service",
        inputSchema: {
          type: "object",
          properties: {
            service_name: {
              type: "string",
              description: "Service name or ID",
            },
            url: {
              type: "string",
              description: "Service URL (e.g., http://service:port)",
            },
            path: {
              type: "string",
              description: "Service path (optional)",
            },
          },
          required: ["service_name", "url"],
        },
      },
      {
        name: "sync_plugin",
        description: "Create or update a Kong plugin",
        inputSchema: {
          type: "object",
          properties: {
            plugin_name: {
              type: "string",
              description: "Plugin name (e.g., key-auth, rate-limiting)",
            },
            service_name: {
              type: "string",
              description: "Service name (optional, for service-specific plugin)",
            },
            config: {
              type: "object",
              description: "Plugin configuration (JSON object)",
            },
          },
          required: ["plugin_name"],
        },
      },
      {
        name: "reload",
        description: "Reload Kong configuration",
        inputSchema: {
          type: "object",
          properties: {},
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
      case "list_services": {
        const services = await kongRequest("GET", "/services");
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(services.data || services, null, 2),
            },
          ],
        };
      }

      case "list_routes": {
        const routes = await kongRequest("GET", "/routes");
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(routes.data || routes, null, 2),
            },
          ],
        };
      }

      case "apply_service_patch": {
        const { service_name, url, path } = args;
        const serviceData = { name: service_name, url };
        if (path) serviceData.path = path;
        
        // Try to get existing service
        let existing;
        try {
          existing = await kongRequest("GET", `/services/${service_name}`);
        } catch (e) {
          // Service doesn't exist, create it
        }
        
        const result = existing
          ? await kongRequest("PATCH", `/services/${service_name}`, serviceData)
          : await kongRequest("POST", "/services", serviceData);
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(result, null, 2),
            },
          ],
        };
      }

      case "sync_plugin": {
        const { plugin_name, service_name, config = {} } = args;
        const pluginData = { name: plugin_name, config };
        if (service_name) {
          pluginData.service = { name: service_name };
        }
        
        const result = await kongRequest("POST", "/plugins", pluginData);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(result, null, 2),
            },
          ],
        };
      }

      case "reload": {
        const result = await kongRequest("POST", "/config?check=false");
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(result, null, 2),
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
  console.error("Kong Admin MCP server running on stdio");
}

main().catch(console.error);

