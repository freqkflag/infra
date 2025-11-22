#!/usr/bin/env node
/**
 * GitHub MCP Server
 * Provides GitHub repository and issue management tools via Model Context Protocol
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import axios from "axios";

const GITHUB_TOKEN = process.env.GITHUB_TOKEN || process.env.GH_TOKEN;
const GITHUB_API_BASE = process.env.GITHUB_API_URL || "https://api.github.com";

if (!GITHUB_TOKEN) {
  console.error("Error: GITHUB_TOKEN or GH_TOKEN environment variable is required");
  process.exit(1);
}

const headers = {
  Authorization: `Bearer ${GITHUB_TOKEN}`,
  Accept: "application/vnd.github.v3+json",
  "Content-Type": "application/json",
  "User-Agent": "GitHub-MCP-Server/1.0.0",
};

const server = new Server(
  {
    name: "github",
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
        name: "list_repositories",
        description: "List repositories for the authenticated user or organization",
        inputSchema: {
          type: "object",
          properties: {
            owner: {
              type: "string",
              description: "Organization or user name (optional, defaults to authenticated user)",
            },
            type: {
              type: "string",
              description: "Repository type filter",
              enum: ["all", "owner", "member", "public", "private"],
              default: "all",
            },
            sort: {
              type: "string",
              description: "Sort order",
              enum: ["created", "updated", "pushed", "full_name"],
              default: "updated",
            },
            direction: {
              type: "string",
              description: "Sort direction",
              enum: ["asc", "desc"],
              default: "desc",
            },
          },
        },
      },
      {
        name: "get_repository",
        description: "Get repository information",
        inputSchema: {
          type: "object",
          properties: {
            owner: {
              type: "string",
              description: "Repository owner (user or organization)",
            },
            repo: {
              type: "string",
              description: "Repository name",
            },
          },
          required: ["owner", "repo"],
        },
      },
      {
        name: "list_issues",
        description: "List issues for a repository",
        inputSchema: {
          type: "object",
          properties: {
            owner: {
              type: "string",
              description: "Repository owner",
            },
            repo: {
              type: "string",
              description: "Repository name",
            },
            state: {
              type: "string",
              description: "Issue state filter",
              enum: ["open", "closed", "all"],
              default: "open",
            },
            labels: {
              type: "string",
              description: "Comma-separated list of label names",
            },
            sort: {
              type: "string",
              description: "Sort order",
              enum: ["created", "updated", "comments"],
              default: "updated",
            },
            direction: {
              type: "string",
              description: "Sort direction",
              enum: ["asc", "desc"],
              default: "desc",
            },
          },
          required: ["owner", "repo"],
        },
      },
      {
        name: "get_issue",
        description: "Get a specific issue",
        inputSchema: {
          type: "object",
          properties: {
            owner: {
              type: "string",
              description: "Repository owner",
            },
            repo: {
              type: "string",
              description: "Repository name",
            },
            issue_number: {
              type: "number",
              description: "Issue number",
            },
          },
          required: ["owner", "repo", "issue_number"],
        },
      },
      {
        name: "create_issue",
        description: "Create a new issue",
        inputSchema: {
          type: "object",
          properties: {
            owner: {
              type: "string",
              description: "Repository owner",
            },
            repo: {
              type: "string",
              description: "Repository name",
            },
            title: {
              type: "string",
              description: "Issue title",
            },
            body: {
              type: "string",
              description: "Issue body (markdown)",
            },
            labels: {
              type: "array",
              items: { type: "string" },
              description: "Issue labels",
            },
            assignees: {
              type: "array",
              items: { type: "string" },
              description: "Issue assignees (usernames)",
            },
          },
          required: ["owner", "repo", "title"],
        },
      },
      {
        name: "update_issue",
        description: "Update an existing issue",
        inputSchema: {
          type: "object",
          properties: {
            owner: {
              type: "string",
              description: "Repository owner",
            },
            repo: {
              type: "string",
              description: "Repository name",
            },
            issue_number: {
              type: "number",
              description: "Issue number",
            },
            title: {
              type: "string",
              description: "Issue title",
            },
            body: {
              type: "string",
              description: "Issue body (markdown)",
            },
            state: {
              type: "string",
              description: "Issue state",
              enum: ["open", "closed"],
            },
            labels: {
              type: "array",
              items: { type: "string" },
              description: "Issue labels",
            },
            assignees: {
              type: "array",
              items: { type: "string" },
              description: "Issue assignees (usernames)",
            },
          },
          required: ["owner", "repo", "issue_number"],
        },
      },
      {
        name: "list_pull_requests",
        description: "List pull requests for a repository",
        inputSchema: {
          type: "object",
          properties: {
            owner: {
              type: "string",
              description: "Repository owner",
            },
            repo: {
              type: "string",
              description: "Repository name",
            },
            state: {
              type: "string",
              description: "PR state filter",
              enum: ["open", "closed", "all"],
              default: "open",
            },
            sort: {
              type: "string",
              description: "Sort order",
              enum: ["created", "updated", "popularity"],
              default: "updated",
            },
            direction: {
              type: "string",
              description: "Sort direction",
              enum: ["asc", "desc"],
              default: "desc",
            },
          },
          required: ["owner", "repo"],
        },
      },
      {
        name: "get_pull_request",
        description: "Get a specific pull request",
        inputSchema: {
          type: "object",
          properties: {
            owner: {
              type: "string",
              description: "Repository owner",
            },
            repo: {
              type: "string",
              description: "Repository name",
            },
            pull_number: {
              type: "number",
              description: "Pull request number",
            },
          },
          required: ["owner", "repo", "pull_number"],
        },
      },
      {
        name: "create_pull_request",
        description: "Create a new pull request",
        inputSchema: {
          type: "object",
          properties: {
            owner: {
              type: "string",
              description: "Repository owner",
            },
            repo: {
              type: "string",
              description: "Repository name",
            },
            title: {
              type: "string",
              description: "Pull request title",
            },
            body: {
              type: "string",
              description: "Pull request body (markdown)",
            },
            head: {
              type: "string",
              description: "Branch name to merge from",
            },
            base: {
              type: "string",
              description: "Branch name to merge into",
              default: "main",
            },
            draft: {
              type: "boolean",
              description: "Create as draft PR",
              default: false,
            },
          },
          required: ["owner", "repo", "title", "head"],
        },
      },
      {
        name: "list_branches",
        description: "List branches for a repository",
        inputSchema: {
          type: "object",
          properties: {
            owner: {
              type: "string",
              description: "Repository owner",
            },
            repo: {
              type: "string",
              description: "Repository name",
            },
            protected: {
              type: "boolean",
              description: "Filter by protected status",
            },
          },
          required: ["owner", "repo"],
        },
      },
      {
        name: "get_file_contents",
        description: "Get file contents from a repository",
        inputSchema: {
          type: "object",
          properties: {
            owner: {
              type: "string",
              description: "Repository owner",
            },
            repo: {
              type: "string",
              description: "Repository name",
            },
            path: {
              type: "string",
              description: "File path in repository",
            },
            ref: {
              type: "string",
              description: "Branch, tag, or commit SHA",
              default: "main",
            },
          },
          required: ["owner", "repo", "path"],
        },
      },
      {
        name: "search_repositories",
        description: "Search repositories",
        inputSchema: {
          type: "object",
          properties: {
            q: {
              type: "string",
              description: "Search query (e.g., 'language:javascript stars:>100')",
            },
            sort: {
              type: "string",
              description: "Sort order",
              enum: ["stars", "forks", "help-wanted-issues", "updated"],
              default: "stars",
            },
            order: {
              type: "string",
              description: "Sort direction",
              enum: ["asc", "desc"],
              default: "desc",
            },
          },
          required: ["q"],
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
      case "list_repositories": {
        const url = args.owner
          ? `${GITHUB_API_BASE}/orgs/${args.owner}/repos`
          : `${GITHUB_API_BASE}/user/repos`;
        const params = {
          type: args.type || "all",
          sort: args.sort || "updated",
          direction: args.direction || "desc",
          per_page: 100,
        };
        const response = await axios.get(url, { headers, params });
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(response.data, null, 2),
            },
          ],
        };
      }

      case "get_repository": {
        const { owner, repo } = args;
        const response = await axios.get(
          `${GITHUB_API_BASE}/repos/${owner}/${repo}`,
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

      case "list_issues": {
        const { owner, repo } = args;
        const params = {
          state: args.state || "open",
          labels: args.labels,
          sort: args.sort || "updated",
          direction: args.direction || "desc",
          per_page: 100,
        };
        const response = await axios.get(
          `${GITHUB_API_BASE}/repos/${owner}/${repo}/issues`,
          { headers, params }
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

      case "get_issue": {
        const { owner, repo, issue_number } = args;
        const response = await axios.get(
          `${GITHUB_API_BASE}/repos/${owner}/${repo}/issues/${issue_number}`,
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

      case "create_issue": {
        const { owner, repo, title, body, labels, assignees } = args;
        const response = await axios.post(
          `${GITHUB_API_BASE}/repos/${owner}/${repo}/issues`,
          {
            title,
            body,
            labels,
            assignees,
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
                  message: "Issue created successfully",
                  issue: response.data,
                },
                null,
                2
              ),
            },
          ],
        };
      }

      case "update_issue": {
        const { owner, repo, issue_number, title, body, state, labels, assignees } = args;
        const updateData = {};
        if (title) updateData.title = title;
        if (body) updateData.body = body;
        if (state) updateData.state = state;
        if (labels) updateData.labels = labels;
        if (assignees) updateData.assignees = assignees;

        const response = await axios.patch(
          `${GITHUB_API_BASE}/repos/${owner}/${repo}/issues/${issue_number}`,
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
                  message: "Issue updated successfully",
                  issue: response.data,
                },
                null,
                2
              ),
            },
          ],
        };
      }

      case "list_pull_requests": {
        const { owner, repo } = args;
        const params = {
          state: args.state || "open",
          sort: args.sort || "updated",
          direction: args.direction || "desc",
          per_page: 100,
        };
        const response = await axios.get(
          `${GITHUB_API_BASE}/repos/${owner}/${repo}/pulls`,
          { headers, params }
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

      case "get_pull_request": {
        const { owner, repo, pull_number } = args;
        const response = await axios.get(
          `${GITHUB_API_BASE}/repos/${owner}/${repo}/pulls/${pull_number}`,
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

      case "create_pull_request": {
        const { owner, repo, title, body, head, base, draft } = args;
        const response = await axios.post(
          `${GITHUB_API_BASE}/repos/${owner}/${repo}/pulls`,
          {
            title,
            body,
            head,
            base: base || "main",
            draft: draft || false,
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
                  message: "Pull request created successfully",
                  pull_request: response.data,
                },
                null,
                2
              ),
            },
          ],
        };
      }

      case "list_branches": {
        const { owner, repo } = args;
        const params = {};
        if (args.protected !== undefined) {
          params.protected = args.protected;
        }
        const response = await axios.get(
          `${GITHUB_API_BASE}/repos/${owner}/${repo}/branches`,
          { headers, params }
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

      case "get_file_contents": {
        const { owner, repo, path, ref } = args;
        const response = await axios.get(
          `${GITHUB_API_BASE}/repos/${owner}/${repo}/contents/${path}`,
          { headers, params: { ref: ref || "main" } }
        );
        // Decode base64 content if present
        if (response.data.content && response.data.encoding === "base64") {
          response.data.decoded_content = Buffer.from(
            response.data.content,
            "base64"
          ).toString("utf-8");
        }
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(response.data, null, 2),
            },
          ],
        };
      }

      case "search_repositories": {
        const { q, sort, order } = args;
        const params = {
          q,
          sort: sort || "stars",
          order: order || "desc",
          per_page: 100,
        };
        const response = await axios.get(`${GITHUB_API_BASE}/search/repositories`, {
          headers,
          params,
        });
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
  console.error("GitHub MCP server running on stdio");
}

main().catch(console.error);

