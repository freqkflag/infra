#!/usr/bin/env node
/**
 * GitLab MCP Server
 * Provides GitLab API management tools via Model Context Protocol
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import axios from "axios";

const GITLAB_URL = process.env.GITLAB_URL || "https://gitlab.freqkflag.co";
const GITLAB_PAT = process.env.GITLAB_PAT || "";

if (!GITLAB_PAT) {
  console.error("Warning: GITLAB_PAT not set. Some operations may fail.");
}

const GITLAB_API_BASE = `${GITLAB_URL}/api/v4`;

const server = new Server(
  {
    name: "gitlab",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Helper function to make GitLab API requests
async function gitlabRequest(method, path, data = null) {
  const url = `${GITLAB_API_BASE}${path}`;
  const config = {
    method,
    url,
    headers: {
      "PRIVATE-TOKEN": GITLAB_PAT,
      "Content-Type": "application/json",
    },
  };
  
  if (data) {
    config.data = data;
  }
  
  try {
    const response = await axios(config);
    return response.data;
  } catch (error) {
    throw new Error(`GitLab API error: ${error.response?.data?.message || error.message}`);
  }
}

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "list_projects",
        description: "List all GitLab projects",
        inputSchema: {
          type: "object",
          properties: {},
        },
      },
      {
        name: "get_pipeline_status",
        description: "Get status of a GitLab pipeline",
        inputSchema: {
          type: "object",
          properties: {
            project_id: {
              type: "string",
              description: "Project ID or path",
            },
            pipeline_id: {
              type: "number",
              description: "Pipeline ID",
            },
          },
          required: ["project_id", "pipeline_id"],
        },
      },
      {
        name: "create_issue",
        description: "Create a new GitLab issue",
        inputSchema: {
          type: "object",
          properties: {
            project_id: {
              type: "string",
              description: "Project ID or path",
            },
            title: {
              type: "string",
              description: "Issue title",
            },
            description: {
              type: "string",
              description: "Issue description",
            },
            labels: {
              type: "array",
              items: { type: "string" },
              description: "Issue labels",
            },
          },
          required: ["project_id", "title"],
        },
      },
      {
        name: "update_variable",
        description: "Update a GitLab CI/CD variable",
        inputSchema: {
          type: "object",
          properties: {
            project_id: {
              type: "string",
              description: "Project ID or path",
            },
            key: {
              type: "string",
              description: "Variable key",
            },
            value: {
              type: "string",
              description: "Variable value",
            },
            protected: {
              type: "boolean",
              description: "Protect variable",
              default: false,
            },
          },
          required: ["project_id", "key", "value"],
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
      case "list_projects": {
        const projects = await gitlabRequest("GET", "/projects");
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(projects, null, 2),
            },
          ],
        };
      }

      case "get_pipeline_status": {
        const { project_id, pipeline_id } = args;
        const pipeline = await gitlabRequest(
          "GET",
          `/projects/${encodeURIComponent(project_id)}/pipelines/${pipeline_id}`
        );
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(pipeline, null, 2),
            },
          ],
        };
      }

      case "create_issue": {
        const { project_id, title, description = "", labels = [] } = args;
        const issue = await gitlabRequest(
          "POST",
          `/projects/${encodeURIComponent(project_id)}/issues`,
          { title, description, labels }
        );
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(issue, null, 2),
            },
          ],
        };
      }

      case "update_variable": {
        const { project_id, key, value, protected: isProtected = false } = args;
        const variable = await gitlabRequest(
          "PUT",
          `/projects/${encodeURIComponent(project_id)}/variables/${key}`,
          { value, protected: isProtected }
        );
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(variable, null, 2),
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
  console.error("GitLab MCP server running on stdio");
}

main().catch(console.error);

