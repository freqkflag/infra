#!/usr/bin/env node
/**
 * WikiJS MCP Server
 * Provides WikiJS page management tools via Model Context Protocol
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import axios from "axios";

const WIKIJS_API_KEY = process.env.WIKIJS_API_KEY;
const WIKIJS_API_URL = process.env.WIKIJS_API_URL || "https://wiki.freqkflag.co";

if (!WIKIJS_API_KEY) {
  console.error("Error: WIKIJS_API_KEY environment variable is required");
  process.exit(1);
}

const headers = {
  Authorization: `Bearer ${WIKIJS_API_KEY}`,
  "Content-Type": "application/json",
};

const server = new Server(
  {
    name: "wikijs",
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
        name: "list_pages",
        description: "List all pages in WikiJS",
        inputSchema: {
          type: "object",
          properties: {
            limit: {
              type: "number",
              description: "Maximum number of pages to return",
              default: 50,
            },
            offset: {
              type: "number",
              description: "Offset for pagination",
              default: 0,
            },
          },
        },
      },
      {
        name: "get_page",
        description: "Get a specific page by path or ID",
        inputSchema: {
          type: "object",
          properties: {
            path: {
              type: "string",
              description: "Page path (e.g., 'projects/fl-clone-building-process')",
            },
            id: {
              type: "number",
              description: "Page ID",
            },
          },
          required: [],
        },
      },
      {
        name: "create_page",
        description: "Create a new page in WikiJS",
        inputSchema: {
          type: "object",
          properties: {
            title: {
              type: "string",
              description: "Page title",
            },
            path: {
              type: "string",
              description: "Page path (e.g., 'projects/my-page')",
            },
            content: {
              type: "string",
              description: "Page content (markdown)",
            },
            description: {
              type: "string",
              description: "Page description",
            },
            editor: {
              type: "string",
              description: "Editor type",
              enum: ["markdown", "wysiwyg"],
              default: "markdown",
            },
            isPublished: {
              type: "boolean",
              description: "Whether to publish immediately",
              default: true,
            },
            tags: {
              type: "array",
              items: { type: "string" },
              description: "Page tags",
            },
          },
          required: ["title", "path", "content"],
        },
      },
      {
        name: "update_page",
        description: "Update an existing page",
        inputSchema: {
          type: "object",
          properties: {
            id: {
              type: "number",
              description: "Page ID",
            },
            path: {
              type: "string",
              description: "Page path",
            },
            title: {
              type: "string",
              description: "Page title",
            },
            content: {
              type: "string",
              description: "Page content (markdown)",
            },
            description: {
              type: "string",
              description: "Page description",
            },
            tags: {
              type: "array",
              items: { type: "string" },
              description: "Page tags",
            },
          },
          required: [],
        },
      },
      {
        name: "delete_page",
        description: "Delete a page",
        inputSchema: {
          type: "object",
          properties: {
            id: {
              type: "number",
              description: "Page ID",
            },
            path: {
              type: "string",
              description: "Page path",
            },
          },
          required: [],
        },
      },
      {
        name: "search_pages",
        description: "Search pages by query",
        inputSchema: {
          type: "object",
          properties: {
            query: {
              type: "string",
              description: "Search query",
            },
            limit: {
              type: "number",
              description: "Maximum results",
              default: 20,
            },
          },
          required: ["query"],
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
      case "list_pages": {
        const limit = args?.limit || 50;
        const offset = args?.offset || 0;
        const response = await axios.get(
          `${WIKIJS_API_URL}/api/pages`,
          {
            headers,
            params: { limit, offset },
          }
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(response.data, null, 2),
            },
          ],
        };
      }

      case "get_page": {
        let pageId = args?.id;
        const path = args?.path;

        if (!pageId && path) {
          // Get page by path
          const listResponse = await axios.get(
            `${WIKIJS_API_URL}/api/pages`,
            { headers, params: { path } }
          );
          if (listResponse.data.length === 0) {
            throw new Error(`Page not found: ${path}`);
          }
          pageId = listResponse.data[0].id;
        }

        if (!pageId) {
          throw new Error("Either id or path must be provided");
        }

        const response = await axios.get(
          `${WIKIJS_API_URL}/api/pages/${pageId}`,
          { headers }
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(response.data, null, 2),
            },
          ],
        };
      }

      case "create_page": {
        const response = await axios.post(
          `${WIKIJS_API_URL}/api/pages`,
          {
            title: args.title,
            path: args.path,
            content: args.content,
            description: args.description,
            editor: args.editor || "markdown",
            isPublished: args.isPublished !== false,
            tags: args.tags || [],
          },
          { headers }
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                {
                  success: true,
                  message: "Page created successfully",
                  page: response.data,
                },
                null,
                2
              ),
            },
          ],
        };
      }

      case "update_page": {
        let pageId = args?.id;
        const path = args?.path;

        if (!pageId && path) {
          // Get page by path
          const listResponse = await axios.get(
            `${WIKIJS_API_URL}/api/pages`,
            { headers, params: { path } }
          );
          if (listResponse.data.length === 0) {
            throw new Error(`Page not found: ${path}`);
          }
          pageId = listResponse.data[0].id;
        }

        if (!pageId) {
          throw new Error("Either id or path must be provided");
        }

        const updateData = {};
        if (args.title) updateData.title = args.title;
        if (args.content) updateData.content = args.content;
        if (args.description) updateData.description = args.description;
        if (args.tags) updateData.tags = args.tags;

        const response = await axios.put(
          `${WIKIJS_API_URL}/api/pages/${pageId}`,
          updateData,
          { headers }
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                {
                  success: true,
                  message: "Page updated successfully",
                  page: response.data,
                },
                null,
                2
              ),
            },
          ],
        };
      }

      case "delete_page": {
        let pageId = args?.id;
        const path = args?.path;

        if (!pageId && path) {
          // Get page by path
          const listResponse = await axios.get(
            `${WIKIJS_API_URL}/api/pages`,
            { headers, params: { path } }
          );
          if (listResponse.data.length === 0) {
            throw new Error(`Page not found: ${path}`);
          }
          pageId = listResponse.data[0].id;
        }

        if (!pageId) {
          throw new Error("Either id or path must be provided");
        }

        await axios.delete(`${WIKIJS_API_URL}/api/pages/${pageId}`, {
          headers,
        });
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                {
                  success: true,
                  message: "Page deleted successfully",
                },
                null,
                2
              ),
            },
          ],
        };
      }

      case "search_pages": {
        const query = args.query;
        const limit = args.limit || 20;
        const response = await axios.get(
          `${WIKIJS_API_URL}/api/search`,
          {
            headers,
            params: { q: query, limit },
          }
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(response.data, null, 2),
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
          text: JSON.stringify(
            {
              error: error.message,
              details: error.response?.data || error.stack,
            },
            null,
            2
          ),
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
  console.error("WikiJS MCP server running on stdio");
}

main().catch(console.error);

