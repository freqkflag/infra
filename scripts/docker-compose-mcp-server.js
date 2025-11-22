#!/usr/bin/env node
/**
 * Docker/Compose MCP Server
 * Provides Docker and Docker Compose management tools via Model Context Protocol
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { exec } from "child_process";
import { promisify } from "util";

const execAsync = promisify(exec);
const WORKSPACE = process.env.DEVTOOLS_WORKSPACE || "/root/infra";

const server = new Server(
  {
    name: "docker-compose",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Helper function to execute shell commands
async function execCommand(command, cwd = WORKSPACE) {
  try {
    const { stdout, stderr } = await execAsync(command, { cwd });
    return { stdout, stderr, success: true };
  } catch (error) {
    return {
      stdout: error.stdout || "",
      stderr: error.stderr || error.message,
      success: false,
    };
  }
}

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "list_containers",
        description: "List all Docker containers with status and health",
        inputSchema: {
          type: "object",
          properties: {
            all: {
              type: "boolean",
              description: "Include stopped containers",
              default: false,
            },
          },
        },
      },
      {
        name: "compose_up",
        description: "Start services using docker compose",
        inputSchema: {
          type: "object",
          properties: {
            compose_file: {
              type: "string",
              description: "Compose file path (relative to workspace)",
              default: "compose.orchestrator.yml",
            },
            services: {
              type: "array",
              items: { type: "string" },
              description: "Specific services to start (optional)",
            },
          },
        },
      },
      {
        name: "compose_down",
        description: "Stop services using docker compose",
        inputSchema: {
          type: "object",
          properties: {
            compose_file: {
              type: "string",
              description: "Compose file path (relative to workspace)",
              default: "compose.orchestrator.yml",
            },
            services: {
              type: "array",
              items: { type: "string" },
              description: "Specific services to stop (optional)",
            },
          },
        },
      },
      {
        name: "compose_logs",
        description: "Get logs from docker compose services",
        inputSchema: {
          type: "object",
          properties: {
            compose_file: {
              type: "string",
              description: "Compose file path (relative to workspace)",
              default: "compose.orchestrator.yml",
            },
            services: {
              type: "array",
              items: { type: "string" },
              description: "Specific services to get logs from (optional)",
            },
            tail: {
              type: "number",
              description: "Number of lines to show",
              default: 100,
            },
          },
        },
      },
      {
        name: "health_report",
        description: "Get aggregated health status of all containers",
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
      case "list_containers": {
        const { all = false } = args || {};
        const command = all
          ? "docker ps -a --format json"
          : "docker ps --format json";
        const result = await execCommand(command);
        
        if (!result.success) {
          throw new Error(result.stderr);
        }
        
        const containers = result.stdout
          .trim()
          .split("\n")
          .filter((line) => line.trim())
          .map((line) => JSON.parse(line));
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(containers, null, 2),
            },
          ],
        };
      }

      case "compose_up": {
        const { compose_file = "compose.orchestrator.yml", services = [] } = args || {};
        const serviceArgs = services.length > 0 ? services.join(" ") : "";
        const command = `docker compose -f ${compose_file} up -d ${serviceArgs}`.trim();
        const result = await execCommand(command);
        
        return {
          content: [
            {
              type: "text",
              text: result.success
                ? `Success: ${result.stdout}`
                : `Error: ${result.stderr}`,
            },
          ],
          isError: !result.success,
        };
      }

      case "compose_down": {
        const { compose_file = "compose.orchestrator.yml", services = [] } = args || {};
        const serviceArgs = services.length > 0 ? services.join(" ") : "";
        const command = `docker compose -f ${compose_file} down ${serviceArgs}`.trim();
        const result = await execCommand(command);
        
        return {
          content: [
            {
              type: "text",
              text: result.success
                ? `Success: ${result.stdout}`
                : `Error: ${result.stderr}`,
            },
          ],
          isError: !result.success,
        };
      }

      case "compose_logs": {
        const { compose_file = "compose.orchestrator.yml", services = [], tail = 100 } = args || {};
        const serviceArgs = services.length > 0 ? services.join(" ") : "";
        const command = `docker compose -f ${compose_file} logs --tail=${tail} ${serviceArgs}`.trim();
        const result = await execCommand(command);
        
        return {
          content: [
            {
              type: "text",
              text: result.stdout || result.stderr,
            },
          ],
        };
      }

      case "health_report": {
        const command = "docker ps --format '{{.Names}}\t{{.Status}}'";
        const result = await execCommand(command);
        
        if (!result.success) {
          throw new Error(result.stderr);
        }
        
        const lines = result.stdout.trim().split("\n");
        const healthStatus = lines.map((line) => {
          const [name, ...statusParts] = line.split("\t");
          const status = statusParts.join("\t");
          return {
            name: name.trim(),
            status: status.trim(),
            healthy: status.includes("healthy"),
            unhealthy: status.includes("unhealthy"),
          };
        });
        
        const summary = {
          total: healthStatus.length,
          healthy: healthStatus.filter((s) => s.healthy).length,
          unhealthy: healthStatus.filter((s) => s.unhealthy).length,
          containers: healthStatus,
        };
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(summary, null, 2),
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
  console.error("Docker/Compose MCP server running on stdio");
}

main().catch(console.error);

