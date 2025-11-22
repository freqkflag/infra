#!/usr/bin/env node
/**
 * Monitoring MCP Server
 * Provides Prometheus, Grafana, and Alertmanager query tools via Model Context Protocol
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import axios from "axios";

const PROMETHEUS_URL = process.env.PROMETHEUS_URL || "https://prometheus.freqkflag.co";
const GRAFANA_URL = process.env.GRAFANA_URL || "https://grafana.freqkflag.co";
const ALERTMANAGER_URL = process.env.ALERTMANAGER_URL || "https://alertmanager.freqkflag.co";
const GRAFANA_API_KEY = process.env.GRAFANA_API_KEY || "";

const server = new Server(
  {
    name: "monitoring",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Helper function to make API requests
async function apiRequest(method, url, data = null, headers = {}) {
  const config = {
    method,
    url,
    headers: {
      "Content-Type": "application/json",
      ...headers,
    },
  };
  
  if (data) {
    config.data = data;
  }
  
  try {
    const response = await axios(config);
    return response.data;
  } catch (error) {
    throw new Error(`API error: ${error.response?.data?.message || error.message}`);
  }
}

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "prom_query",
        description: "Execute a PromQL query against Prometheus",
        inputSchema: {
          type: "object",
          properties: {
            query: {
              type: "string",
              description: "PromQL query string",
            },
          },
          required: ["query"],
        },
      },
      {
        name: "grafana_dashboard",
        description: "Get Grafana dashboard by UID",
        inputSchema: {
          type: "object",
          properties: {
            uid: {
              type: "string",
              description: "Dashboard UID",
            },
          },
          required: ["uid"],
        },
      },
      {
        name: "alertmanager_list",
        description: "List all active alerts from Alertmanager",
        inputSchema: {
          type: "object",
          properties: {},
        },
      },
      {
        name: "ack_alert",
        description: "Acknowledge/silence an alert in Alertmanager",
        inputSchema: {
          type: "object",
          properties: {
            alert_name: {
              type: "string",
              description: "Alert name or label",
            },
            duration: {
              type: "number",
              description: "Silence duration in seconds",
              default: 3600,
            },
            comment: {
              type: "string",
              description: "Silence comment",
            },
          },
          required: ["alert_name"],
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
      case "prom_query": {
        const { query } = args;
        const result = await apiRequest(
          "POST",
          `${PROMETHEUS_URL}/api/v1/query`,
          { query }
        );
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(result, null, 2),
            },
          ],
        };
      }

      case "grafana_dashboard": {
        const { uid } = args;
        const headers = GRAFANA_API_KEY ? { Authorization: `Bearer ${GRAFANA_API_KEY}` } : {};
        const result = await apiRequest(
          "GET",
          `${GRAFANA_URL}/api/dashboards/uid/${uid}`,
          null,
          headers
        );
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(result, null, 2),
            },
          ],
        };
      }

      case "alertmanager_list": {
        const result = await apiRequest("GET", `${ALERTMANAGER_URL}/api/v2/alerts`);
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(result, null, 2),
            },
          ],
        };
      }

      case "ack_alert": {
        const { alert_name, duration = 3600, comment = "Acknowledged via MCP" } = args;
        const silenceData = {
          matchers: [{ name: "alertname", value: alert_name, isRegex: false }],
          startsAt: new Date().toISOString(),
          endsAt: new Date(Date.now() + duration * 1000).toISOString(),
          comment,
        };
        
        const result = await apiRequest(
          "POST",
          `${ALERTMANAGER_URL}/api/v2/silences`,
          silenceData
        );
        
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
  console.error("Monitoring MCP server running on stdio");
}

main().catch(console.error);

