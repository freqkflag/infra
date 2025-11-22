#!/usr/bin/env node
/**
 * GitHub Admin MCP Server
 * Provides comprehensive GitHub administrative tools via Model Context Protocol
 * Includes: GitHub Apps, OAuth Apps, Organizations, Teams, Webhooks, Actions, and more
 * 
 * Reference: https://docs.github.com/en/rest?apiVersion=2022-11-28
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
  "User-Agent": "GitHub-Admin-MCP-Server/2.0.0",
};

const server = new Server(
  {
    name: "github-admin",
    version: "2.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Helper function to make API requests
async function apiRequest(method, endpoint, data = null, params = {}) {
  try {
    const config = {
      method,
      url: `${GITHUB_API_BASE}${endpoint}`,
      headers,
      params,
    };
    if (data) {
      config.data = data;
    }
    const response = await axios(config);
    return response.data;
  } catch (error) {
    throw new Error(
      error.response?.data?.message || error.message || "API request failed"
    );
  }
}

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      // ===== GITHUB APPS MANAGEMENT =====
      {
        name: "list_github_apps",
        description: "List GitHub Apps for the authenticated user or organization",
        inputSchema: {
          type: "object",
          properties: {
            org: {
              type: "string",
              description: "Organization name (optional, lists user apps if not provided)",
            },
          },
        },
      },
      {
        name: "get_github_app",
        description: "Get a specific GitHub App",
        inputSchema: {
          type: "object",
          properties: {
            app_slug: {
              type: "string",
              description: "GitHub App slug",
            },
          },
          required: ["app_slug"],
        },
      },
      {
        name: "create_github_app",
        description: "Create a new GitHub App",
        inputSchema: {
          type: "object",
          properties: {
            name: {
              type: "string",
              description: "App name",
            },
            description: {
              type: "string",
              description: "App description",
            },
            url: {
              type: "string",
              description: "App homepage URL",
            },
            callback_url: {
              type: "string",
              description: "App callback URL",
            },
            webhook_url: {
              type: "string",
              description: "Webhook URL",
            },
            webhook_secret: {
              type: "string",
              description: "Webhook secret",
            },
            permissions: {
              type: "object",
              description: "App permissions (JSON object)",
            },
            events: {
              type: "array",
              items: { type: "string" },
              description: "Webhook events to subscribe to",
            },
          },
          required: ["name", "url"],
        },
      },
      {
        name: "update_github_app",
        description: "Update a GitHub App",
        inputSchema: {
          type: "object",
          properties: {
            app_slug: {
              type: "string",
              description: "GitHub App slug",
            },
            name: {
              type: "string",
              description: "App name",
            },
            description: {
              type: "string",
              description: "App description",
            },
            url: {
              type: "string",
              description: "App homepage URL",
            },
            callback_url: {
              type: "string",
              description: "App callback URL",
            },
            webhook_url: {
              type: "string",
              description: "Webhook URL",
            },
            webhook_secret: {
              type: "string",
              description: "Webhook secret",
            },
            permissions: {
              type: "object",
              description: "App permissions",
            },
            events: {
              type: "array",
              items: { type: "string" },
              description: "Webhook events",
            },
          },
          required: ["app_slug"],
        },
      },
      {
        name: "delete_github_app",
        description: "Delete a GitHub App",
        inputSchema: {
          type: "object",
          properties: {
            app_slug: {
              type: "string",
              description: "GitHub App slug",
            },
          },
          required: ["app_slug"],
        },
      },
      {
        name: "list_app_installations",
        description: "List installations for a GitHub App",
        inputSchema: {
          type: "object",
          properties: {
            app_slug: {
              type: "string",
              description: "GitHub App slug",
            },
            per_page: {
              type: "number",
              description: "Results per page",
              default: 30,
            },
            page: {
              type: "number",
              description: "Page number",
              default: 1,
            },
          },
          required: ["app_slug"],
        },
      },
      {
        name: "get_app_installation",
        description: "Get a specific app installation",
        inputSchema: {
          type: "object",
          properties: {
            installation_id: {
              type: "number",
              description: "Installation ID",
            },
          },
          required: ["installation_id"],
        },
      },
      {
        name: "delete_app_installation",
        description: "Delete an app installation",
        inputSchema: {
          type: "object",
          properties: {
            installation_id: {
              type: "number",
              description: "Installation ID",
            },
          },
          required: ["installation_id"],
        },
      },

      // ===== OAUTH APPS MANAGEMENT =====
      {
        name: "list_oauth_apps",
        description: "List OAuth Apps for the authenticated user or organization",
        inputSchema: {
          type: "object",
          properties: {
            org: {
              type: "string",
              description: "Organization name (optional, lists user apps if not provided)",
            },
          },
        },
      },
      {
        name: "get_oauth_app",
        description: "Get a specific OAuth App",
        inputSchema: {
          type: "object",
          properties: {
            client_id: {
              type: "string",
              description: "OAuth App client ID",
            },
          },
          required: ["client_id"],
        },
      },
      {
        name: "create_oauth_app",
        description: "Create a new OAuth App",
        inputSchema: {
          type: "object",
          properties: {
            name: {
              type: "string",
              description: "App name",
            },
            url: {
              type: "string",
              description: "App homepage URL",
            },
            description: {
              type: "string",
              description: "App description",
            },
            callback_url: {
              type: "string",
              description: "Authorization callback URL",
            },
          },
          required: ["name", "url", "callback_url"],
        },
      },
      {
        name: "update_oauth_app",
        description: "Update an OAuth App",
        inputSchema: {
          type: "object",
          properties: {
            client_id: {
              type: "string",
              description: "OAuth App client ID",
            },
            name: {
              type: "string",
              description: "App name",
            },
            url: {
              type: "string",
              description: "App homepage URL",
            },
            description: {
              type: "string",
              description: "App description",
            },
            callback_url: {
              type: "string",
              description: "Authorization callback URL",
            },
          },
          required: ["client_id"],
        },
      },
      {
        name: "delete_oauth_app",
        description: "Delete an OAuth App",
        inputSchema: {
          type: "object",
          properties: {
            client_id: {
              type: "string",
              description: "OAuth App client ID",
            },
          },
          required: ["client_id"],
        },
      },
      {
        name: "reset_oauth_app_token",
        description: "Reset an OAuth App token",
        inputSchema: {
          type: "object",
          properties: {
            client_id: {
              type: "string",
              description: "OAuth App client ID",
            },
          },
          required: ["client_id"],
        },
      },

      // ===== ORGANIZATIONS MANAGEMENT =====
      {
        name: "list_organizations",
        description: "List organizations for the authenticated user",
        inputSchema: {
          type: "object",
          properties: {
            per_page: {
              type: "number",
              default: 30,
            },
            page: {
              type: "number",
              default: 1,
            },
          },
        },
      },
      {
        name: "get_organization",
        description: "Get organization information",
        inputSchema: {
          type: "object",
          properties: {
            org: {
              type: "string",
              description: "Organization name",
            },
          },
          required: ["org"],
        },
      },
      {
        name: "update_organization",
        description: "Update organization settings",
        inputSchema: {
          type: "object",
          properties: {
            org: {
              type: "string",
              description: "Organization name",
            },
            billing_email: {
              type: "string",
              description: "Billing email",
            },
            company: {
              type: "string",
              description: "Company name",
            },
            email: {
              type: "string",
              description: "Email",
            },
            location: {
              type: "string",
              description: "Location",
            },
            name: {
              type: "string",
              description: "Organization name",
            },
            description: {
              type: "string",
              description: "Description",
            },
            has_organization_projects: {
              type: "boolean",
              description: "Enable organization projects",
            },
            has_repository_projects: {
              type: "boolean",
              description: "Enable repository projects",
            },
            default_repository_permission: {
              type: "string",
              enum: ["read", "write", "admin", "none"],
              description: "Default repository permission",
            },
            members_can_create_repositories: {
              type: "boolean",
              description: "Allow members to create repositories",
            },
            members_can_create_internal_repositories: {
              type: "boolean",
              description: "Allow members to create internal repositories",
            },
            members_can_create_private_repositories: {
              type: "boolean",
              description: "Allow members to create private repositories",
            },
            members_can_create_public_repositories: {
              type: "boolean",
              description: "Allow members to create public repositories",
            },
          },
          required: ["org"],
        },
      },
      {
        name: "list_organization_members",
        description: "List organization members",
        inputSchema: {
          type: "object",
          properties: {
            org: {
              type: "string",
              description: "Organization name",
            },
            filter: {
              type: "string",
              enum: ["2fa_disabled", "all"],
              default: "all",
            },
            role: {
              type: "string",
              enum: ["all", "admin", "member"],
              default: "all",
            },
            per_page: {
              type: "number",
              default: 30,
            },
            page: {
              type: "number",
              default: 1,
            },
          },
          required: ["org"],
        },
      },
      {
        name: "add_organization_member",
        description: "Add a member to an organization",
        inputSchema: {
          type: "object",
          properties: {
            org: {
              type: "string",
              description: "Organization name",
            },
            username: {
              type: "string",
              description: "Username to add",
            },
            role: {
              type: "string",
              enum: ["admin", "direct_member", "billing_manager"],
              default: "direct_member",
            },
          },
          required: ["org", "username"],
        },
      },
      {
        name: "remove_organization_member",
        description: "Remove a member from an organization",
        inputSchema: {
          type: "object",
          properties: {
            org: {
              type: "string",
              description: "Organization name",
            },
            username: {
              type: "string",
              description: "Username to remove",
            },
          },
          required: ["org", "username"],
        },
      },

      // ===== TEAMS MANAGEMENT =====
      {
        name: "list_teams",
        description: "List teams in an organization",
        inputSchema: {
          type: "object",
          properties: {
            org: {
              type: "string",
              description: "Organization name",
            },
            per_page: {
              type: "number",
              default: 30,
            },
            page: {
              type: "number",
              default: 1,
            },
          },
          required: ["org"],
        },
      },
      {
        name: "get_team",
        description: "Get team information",
        inputSchema: {
          type: "object",
          properties: {
            team_id: {
              type: "number",
              description: "Team ID",
            },
          },
          required: ["team_id"],
        },
      },
      {
        name: "create_team",
        description: "Create a new team",
        inputSchema: {
          type: "object",
          properties: {
            org: {
              type: "string",
              description: "Organization name",
            },
            name: {
              type: "string",
              description: "Team name",
            },
            description: {
              type: "string",
              description: "Team description",
            },
            privacy: {
              type: "string",
              enum: ["secret", "closed"],
              default: "secret",
            },
            permission: {
              type: "string",
              enum: ["pull", "push", "admin"],
              default: "pull",
            },
            parent_team_id: {
              type: "number",
              description: "Parent team ID (for nested teams)",
            },
          },
          required: ["org", "name"],
        },
      },
      {
        name: "update_team",
        description: "Update a team",
        inputSchema: {
          type: "object",
          properties: {
            team_id: {
              type: "number",
              description: "Team ID",
            },
            name: {
              type: "string",
              description: "Team name",
            },
            description: {
              type: "string",
              description: "Team description",
            },
            privacy: {
              type: "string",
              enum: ["secret", "closed"],
            },
            permission: {
              type: "string",
              enum: ["pull", "push", "admin"],
            },
            parent_team_id: {
              type: "number",
              description: "Parent team ID",
            },
          },
          required: ["team_id"],
        },
      },
      {
        name: "delete_team",
        description: "Delete a team",
        inputSchema: {
          type: "object",
          properties: {
            team_id: {
              type: "number",
              description: "Team ID",
            },
          },
          required: ["team_id"],
        },
      },
      {
        name: "list_team_members",
        description: "List team members",
        inputSchema: {
          type: "object",
          properties: {
            team_id: {
              type: "number",
              description: "Team ID",
            },
            role: {
              type: "string",
              enum: ["member", "maintainer", "all"],
              default: "all",
            },
            per_page: {
              type: "number",
              default: 30,
            },
            page: {
              type: "number",
              default: 1,
            },
          },
          required: ["team_id"],
        },
      },
      {
        name: "add_team_member",
        description: "Add a member to a team",
        inputSchema: {
          type: "object",
          properties: {
            team_id: {
              type: "number",
              description: "Team ID",
            },
            username: {
              type: "string",
              description: "Username to add",
            },
            role: {
              type: "string",
              enum: ["member", "maintainer"],
              default: "member",
            },
          },
          required: ["team_id", "username"],
        },
      },
      {
        name: "remove_team_member",
        description: "Remove a member from a team",
        inputSchema: {
          type: "object",
          properties: {
            team_id: {
              type: "number",
              description: "Team ID",
            },
            username: {
              type: "string",
              description: "Username to remove",
            },
          },
          required: ["team_id", "username"],
        },
      },

      // ===== WEBHOOKS MANAGEMENT =====
      {
        name: "list_org_webhooks",
        description: "List organization webhooks",
        inputSchema: {
          type: "object",
          properties: {
            org: {
              type: "string",
              description: "Organization name",
            },
            per_page: {
              type: "number",
              default: 30,
            },
            page: {
              type: "number",
              default: 1,
            },
          },
          required: ["org"],
        },
      },
      {
        name: "create_org_webhook",
        description: "Create an organization webhook",
        inputSchema: {
          type: "object",
          properties: {
            org: {
              type: "string",
              description: "Organization name",
            },
            name: {
              type: "string",
              description: "Webhook name",
              default: "web",
            },
            config: {
              type: "object",
              description: "Webhook configuration (url, content_type, secret, etc.)",
            },
            events: {
              type: "array",
              items: { type: "string" },
              description: "Events to subscribe to",
            },
            active: {
              type: "boolean",
              description: "Whether webhook is active",
              default: true,
            },
          },
          required: ["org", "config"],
        },
      },
      {
        name: "get_org_webhook",
        description: "Get an organization webhook",
        inputSchema: {
          type: "object",
          properties: {
            org: {
              type: "string",
              description: "Organization name",
            },
            hook_id: {
              type: "number",
              description: "Webhook ID",
            },
          },
          required: ["org", "hook_id"],
        },
      },
      {
        name: "update_org_webhook",
        description: "Update an organization webhook",
        inputSchema: {
          type: "object",
          properties: {
            org: {
              type: "string",
              description: "Organization name",
            },
            hook_id: {
              type: "number",
              description: "Webhook ID",
            },
            config: {
              type: "object",
              description: "Webhook configuration",
            },
            events: {
              type: "array",
              items: { type: "string" },
              description: "Events to subscribe to",
            },
            active: {
              type: "boolean",
              description: "Whether webhook is active",
            },
          },
          required: ["org", "hook_id"],
        },
      },
      {
        name: "delete_org_webhook",
        description: "Delete an organization webhook",
        inputSchema: {
          type: "object",
          properties: {
            org: {
              type: "string",
              description: "Organization name",
            },
            hook_id: {
              type: "number",
              description: "Webhook ID",
            },
          },
          required: ["org", "hook_id"],
        },
      },
      {
        name: "list_repo_webhooks",
        description: "List repository webhooks",
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
            per_page: {
              type: "number",
              default: 30,
            },
            page: {
              type: "number",
              default: 1,
            },
          },
          required: ["owner", "repo"],
        },
      },
      {
        name: "create_repo_webhook",
        description: "Create a repository webhook",
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
            name: {
              type: "string",
              description: "Webhook name",
              default: "web",
            },
            config: {
              type: "object",
              description: "Webhook configuration",
            },
            events: {
              type: "array",
              items: { type: "string" },
              description: "Events to subscribe to",
            },
            active: {
              type: "boolean",
              description: "Whether webhook is active",
              default: true,
            },
          },
          required: ["owner", "repo", "config"],
        },
      },
      {
        name: "get_repo_webhook",
        description: "Get a repository webhook",
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
            hook_id: {
              type: "number",
              description: "Webhook ID",
            },
          },
          required: ["owner", "repo", "hook_id"],
        },
      },
      {
        name: "update_repo_webhook",
        description: "Update a repository webhook",
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
            hook_id: {
              type: "number",
              description: "Webhook ID",
            },
            config: {
              type: "object",
              description: "Webhook configuration",
            },
            events: {
              type: "array",
              items: { type: "string" },
              description: "Events to subscribe to",
            },
            active: {
              type: "boolean",
              description: "Whether webhook is active",
            },
          },
          required: ["owner", "repo", "hook_id"],
        },
      },
      {
        name: "delete_repo_webhook",
        description: "Delete a repository webhook",
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
            hook_id: {
              type: "number",
              description: "Webhook ID",
            },
          },
          required: ["owner", "repo", "hook_id"],
        },
      },

      // ===== GITHUB ACTIONS SECRETS & VARIABLES =====
      {
        name: "list_repo_secrets",
        description: "List repository secrets",
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
            per_page: {
              type: "number",
              default: 30,
            },
            page: {
              type: "number",
              default: 1,
            },
          },
          required: ["owner", "repo"],
        },
      },
      {
        name: "get_repo_secret",
        description: "Get a repository secret (public key for encryption)",
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
            secret_name: {
              type: "string",
              description: "Secret name",
            },
          },
          required: ["owner", "repo", "secret_name"],
        },
      },
      {
        name: "create_or_update_repo_secret",
        description: "Create or update a repository secret (requires encrypted_value)",
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
            secret_name: {
              type: "string",
              description: "Secret name",
            },
            encrypted_value: {
              type: "string",
              description: "Encrypted secret value (use get_repo_public_key first)",
            },
            key_id: {
              type: "string",
              description: "Key ID from public key",
            },
          },
          required: ["owner", "repo", "secret_name", "encrypted_value", "key_id"],
        },
      },
      {
        name: "delete_repo_secret",
        description: "Delete a repository secret",
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
            secret_name: {
              type: "string",
              description: "Secret name",
            },
          },
          required: ["owner", "repo", "secret_name"],
        },
      },
      {
        name: "get_repo_public_key",
        description: "Get repository public key for encrypting secrets",
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
          },
          required: ["owner", "repo"],
        },
      },
      {
        name: "list_org_secrets",
        description: "List organization secrets",
        inputSchema: {
          type: "object",
          properties: {
            org: {
              type: "string",
              description: "Organization name",
            },
            per_page: {
              type: "number",
              default: 30,
            },
            page: {
              type: "number",
              default: 1,
            },
          },
          required: ["org"],
        },
      },
      {
        name: "get_org_public_key",
        description: "Get organization public key for encrypting secrets",
        inputSchema: {
          type: "object",
          properties: {
            org: {
              type: "string",
              description: "Organization name",
            },
          },
          required: ["org"],
        },
      },
      {
        name: "list_repo_variables",
        description: "List repository variables",
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
            per_page: {
              type: "number",
              default: 30,
            },
            page: {
              type: "number",
              default: 1,
            },
          },
          required: ["owner", "repo"],
        },
      },
      {
        name: "create_repo_variable",
        description: "Create a repository variable",
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
            name: {
              type: "string",
              description: "Variable name",
            },
            value: {
              type: "string",
              description: "Variable value",
            },
          },
          required: ["owner", "repo", "name", "value"],
        },
      },
      {
        name: "update_repo_variable",
        description: "Update a repository variable",
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
            name: {
              type: "string",
              description: "Variable name",
            },
            value: {
              type: "string",
              description: "Variable value",
            },
          },
          required: ["owner", "repo", "name", "value"],
        },
      },
      {
        name: "delete_repo_variable",
        description: "Delete a repository variable",
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
            name: {
              type: "string",
              description: "Variable name",
            },
          },
          required: ["owner", "repo", "name"],
        },
      },

      // ===== SELF-HOSTED RUNNERS =====
      {
        name: "list_org_runners",
        description: "List organization self-hosted runners",
        inputSchema: {
          type: "object",
          properties: {
            org: {
              type: "string",
              description: "Organization name",
            },
            per_page: {
              type: "number",
              default: 30,
            },
            page: {
              type: "number",
              default: 1,
            },
          },
          required: ["org"],
        },
      },
      {
        name: "list_repo_runners",
        description: "List repository self-hosted runners",
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
            per_page: {
              type: "number",
              default: 30,
            },
            page: {
              type: "number",
              default: 1,
            },
          },
          required: ["owner", "repo"],
        },
      },
      {
        name: "get_runner",
        description: "Get a self-hosted runner",
        inputSchema: {
          type: "object",
          properties: {
            owner: {
              type: "string",
              description: "Repository owner or organization name",
            },
            repo: {
              type: "string",
              description: "Repository name (optional for org runners)",
            },
            runner_id: {
              type: "number",
              description: "Runner ID",
            },
          },
          required: ["owner", "runner_id"],
        },
      },
      {
        name: "delete_runner",
        description: "Delete a self-hosted runner",
        inputSchema: {
          type: "object",
          properties: {
            owner: {
              type: "string",
              description: "Repository owner or organization name",
            },
            repo: {
              type: "string",
              description: "Repository name (optional for org runners)",
            },
            runner_id: {
              type: "number",
              description: "Runner ID",
            },
          },
          required: ["owner", "runner_id"],
        },
      },

      // ===== REPOSITORY MANAGEMENT (Enhanced) =====
      {
        name: "create_repository",
        description: "Create a new repository",
        inputSchema: {
          type: "object",
          properties: {
            name: {
              type: "string",
              description: "Repository name",
            },
            org: {
              type: "string",
              description: "Organization name (optional, creates under user if not provided)",
            },
            description: {
              type: "string",
              description: "Repository description",
            },
            private: {
              type: "boolean",
              description: "Whether repository is private",
              default: false,
            },
            has_issues: {
              type: "boolean",
              description: "Enable issues",
              default: true,
            },
            has_projects: {
              type: "boolean",
              description: "Enable projects",
              default: true,
            },
            has_wiki: {
              type: "boolean",
              description: "Enable wiki",
              default: true,
            },
            has_downloads: {
              type: "boolean",
              description: "Enable downloads",
              default: true,
            },
            auto_init: {
              type: "boolean",
              description: "Initialize with README",
              default: false,
            },
            gitignore_template: {
              type: "string",
              description: "Gitignore template",
            },
            license_template: {
              type: "string",
              description: "License template",
            },
          },
          required: ["name"],
        },
      },
      {
        name: "update_repository",
        description: "Update repository settings",
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
            name: {
              type: "string",
              description: "New repository name",
            },
            description: {
              type: "string",
              description: "Repository description",
            },
            private: {
              type: "boolean",
              description: "Whether repository is private",
            },
            has_issues: {
              type: "boolean",
              description: "Enable issues",
            },
            has_projects: {
              type: "boolean",
              description: "Enable projects",
            },
            has_wiki: {
              type: "boolean",
              description: "Enable wiki",
            },
            has_downloads: {
              type: "boolean",
              description: "Enable downloads",
            },
            default_branch: {
              type: "string",
              description: "Default branch name",
            },
            archived: {
              type: "boolean",
              description: "Archive repository",
            },
          },
          required: ["owner", "repo"],
        },
      },
      {
        name: "delete_repository",
        description: "Delete a repository",
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
          },
          required: ["owner", "repo"],
        },
      },
      {
        name: "transfer_repository",
        description: "Transfer a repository to another user or organization",
        inputSchema: {
          type: "object",
          properties: {
            owner: {
              type: "string",
              description: "Current repository owner",
            },
            repo: {
              type: "string",
              description: "Repository name",
            },
            new_owner: {
              type: "string",
              description: "New owner (user or organization)",
            },
            team_ids: {
              type: "array",
              items: { type: "number" },
              description: "Team IDs to grant access",
            },
          },
          required: ["owner", "repo", "new_owner"],
        },
      },

      // ===== COLLABORATORS MANAGEMENT =====
      {
        name: "list_collaborators",
        description: "List repository collaborators",
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
            affiliation: {
              type: "string",
              enum: ["outside", "direct", "all"],
              default: "all",
            },
            per_page: {
              type: "number",
              default: 30,
            },
            page: {
              type: "number",
              default: 1,
            },
          },
          required: ["owner", "repo"],
        },
      },
      {
        name: "add_collaborator",
        description: "Add a collaborator to a repository",
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
            username: {
              type: "string",
              description: "Username to add",
            },
            permission: {
              type: "string",
              enum: ["pull", "push", "admin", "maintain", "triage"],
              default: "push",
            },
          },
          required: ["owner", "repo", "username"],
        },
      },
      {
        name: "remove_collaborator",
        description: "Remove a collaborator from a repository",
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
            username: {
              type: "string",
              description: "Username to remove",
            },
          },
          required: ["owner", "repo", "username"],
        },
      },

      // ===== BRANCH PROTECTION =====
      {
        name: "get_branch_protection",
        description: "Get branch protection rules",
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
            branch: {
              type: "string",
              description: "Branch name",
            },
          },
          required: ["owner", "repo", "branch"],
        },
      },
      {
        name: "update_branch_protection",
        description: "Update branch protection rules",
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
            branch: {
              type: "string",
              description: "Branch name",
            },
            required_status_checks: {
              type: "object",
              description: "Required status checks configuration",
            },
            enforce_admins: {
              type: "boolean",
              description: "Enforce admins",
            },
            required_pull_request_reviews: {
              type: "object",
              description: "Required PR reviews configuration",
            },
            restrictions: {
              type: "object",
              description: "Restrictions configuration",
            },
            required_linear_history: {
              type: "boolean",
              description: "Require linear history",
            },
            allow_force_pushes: {
              type: "boolean",
              description: "Allow force pushes",
            },
            allow_deletions: {
              type: "boolean",
              description: "Allow deletions",
            },
            block_creations: {
              type: "boolean",
              description: "Block creations",
            },
            required_conversation_resolution: {
              type: "boolean",
              description: "Require conversation resolution",
            },
            lock_branch: {
              type: "boolean",
              description: "Lock branch",
            },
            allow_fork_syncing: {
              type: "boolean",
              description: "Allow fork syncing",
            },
          },
          required: ["owner", "repo", "branch"],
        },
      },
      {
        name: "delete_branch_protection",
        description: "Delete branch protection rules",
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
            branch: {
              type: "string",
              description: "Branch name",
            },
          },
          required: ["owner", "repo", "branch"],
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
      // ===== GITHUB APPS =====
      case "list_github_apps": {
        const endpoint = args.org
          ? `/orgs/${args.org}/github-apps`
          : "/user/github-apps";
        const data = await apiRequest("GET", endpoint);
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "get_github_app": {
        const data = await apiRequest("GET", `/apps/${args.app_slug}`);
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "create_github_app": {
        const payload = {
          name: args.name,
          url: args.url,
          description: args.description,
          callback_url: args.callback_url,
          webhook_url: args.webhook_url,
          webhook_secret: args.webhook_secret,
          permissions: args.permissions,
          events: args.events,
        };
        const data = await apiRequest("POST", "/user/github-apps", payload);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "GitHub App created", app: data },
                null,
                2
              ),
            },
          ],
        };
      }

      case "update_github_app": {
        const payload = {};
        if (args.name) payload.name = args.name;
        if (args.description) payload.description = args.description;
        if (args.url) payload.url = args.url;
        if (args.callback_url) payload.callback_url = args.callback_url;
        if (args.webhook_url) payload.webhook_url = args.webhook_url;
        if (args.webhook_secret) payload.webhook_secret = args.webhook_secret;
        if (args.permissions) payload.permissions = args.permissions;
        if (args.events) payload.events = args.events;

        const data = await apiRequest(
          "PATCH",
          `/user/github-apps/${args.app_slug}`,
          payload
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "GitHub App updated", app: data },
                null,
                2
              ),
            },
          ],
        };
      }

      case "delete_github_app": {
        await apiRequest("DELETE", `/user/github-apps/${args.app_slug}`);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "GitHub App deleted" },
                null,
                2
              ),
            },
          ],
        };
      }

      case "list_app_installations": {
        const data = await apiRequest(
          "GET",
          `/app/installations`,
          null,
          { per_page: args.per_page || 30, page: args.page || 1 }
        );
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "get_app_installation": {
        const data = await apiRequest(
          "GET",
          `/app/installations/${args.installation_id}`
        );
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "delete_app_installation": {
        await apiRequest(
          "DELETE",
          `/app/installations/${args.installation_id}`
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Installation deleted" },
                null,
                2
              ),
            },
          ],
        };
      }

      // ===== OAUTH APPS =====
      case "list_oauth_apps": {
        const endpoint = args.org
          ? `/orgs/${args.org}/oauth-applications`
          : "/user/oauth-applications";
        const data = await apiRequest("GET", endpoint);
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "get_oauth_app": {
        const data = await apiRequest("GET", `/applications/${args.client_id}`);
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "create_oauth_app": {
        const payload = {
          name: args.name,
          url: args.url,
          description: args.description,
          callback_url: args.callback_url,
        };
        const endpoint = args.org
          ? `/orgs/${args.org}/oauth-applications`
          : "/user/oauth-applications";
        const data = await apiRequest("POST", endpoint, payload);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "OAuth App created", app: data },
                null,
                2
              ),
            },
          ],
        };
      }

      case "update_oauth_app": {
        const payload = {};
        if (args.name) payload.name = args.name;
        if (args.url) payload.url = args.url;
        if (args.description) payload.description = args.description;
        if (args.callback_url) payload.callback_url = args.callback_url;

        const data = await apiRequest(
          "PATCH",
          `/applications/${args.client_id}`,
          payload
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "OAuth App updated", app: data },
                null,
                2
              ),
            },
          ],
        };
      }

      case "delete_oauth_app": {
        await apiRequest("DELETE", `/applications/${args.client_id}`);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "OAuth App deleted" },
                null,
                2
              ),
            },
          ],
        };
      }

      case "reset_oauth_app_token": {
        const data = await apiRequest(
          "POST",
          `/applications/${args.client_id}/token`,
          {}
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "OAuth App token reset", data },
                null,
                2
              ),
            },
          ],
        };
      }

      // ===== ORGANIZATIONS =====
      case "list_organizations": {
        const data = await apiRequest("GET", "/user/orgs", null, {
          per_page: args.per_page || 30,
          page: args.page || 1,
        });
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "get_organization": {
        const data = await apiRequest("GET", `/orgs/${args.org}`);
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "update_organization": {
        const payload = {};
        Object.keys(args).forEach((key) => {
          if (key !== "org" && args[key] !== undefined) {
            payload[key] = args[key];
          }
        });
        const data = await apiRequest("PATCH", `/orgs/${args.org}`, payload);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Organization updated", org: data },
                null,
                2
              ),
            },
          ],
        };
      }

      case "list_organization_members": {
        const data = await apiRequest(
          "GET",
          `/orgs/${args.org}/members`,
          null,
          {
            filter: args.filter || "all",
            role: args.role || "all",
            per_page: args.per_page || 30,
            page: args.page || 1,
          }
        );
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "add_organization_member": {
        await apiRequest("PUT", `/orgs/${args.org}/memberships/${args.username}`, {
          role: args.role || "direct_member",
        });
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Member added to organization" },
                null,
                2
              ),
            },
          ],
        };
      }

      case "remove_organization_member": {
        await apiRequest("DELETE", `/orgs/${args.org}/members/${args.username}`);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Member removed from organization" },
                null,
                2
              ),
            },
          ],
        };
      }

      // ===== TEAMS =====
      case "list_teams": {
        const data = await apiRequest("GET", `/orgs/${args.org}/teams`, null, {
          per_page: args.per_page || 30,
          page: args.page || 1,
        });
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "get_team": {
        const data = await apiRequest("GET", `/teams/${args.team_id}`);
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "create_team": {
        const payload = {
          name: args.name,
          description: args.description,
          privacy: args.privacy || "secret",
          permission: args.permission || "pull",
        };
        if (args.parent_team_id) payload.parent_team_id = args.parent_team_id;
        const data = await apiRequest("POST", `/orgs/${args.org}/teams`, payload);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Team created", team: data },
                null,
                2
              ),
            },
          ],
        };
      }

      case "update_team": {
        const payload = {};
        if (args.name) payload.name = args.name;
        if (args.description !== undefined) payload.description = args.description;
        if (args.privacy) payload.privacy = args.privacy;
        if (args.permission) payload.permission = args.permission;
        if (args.parent_team_id !== undefined)
          payload.parent_team_id = args.parent_team_id;

        const data = await apiRequest("PATCH", `/teams/${args.team_id}`, payload);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Team updated", team: data },
                null,
                2
              ),
            },
          ],
        };
      }

      case "delete_team": {
        await apiRequest("DELETE", `/teams/${args.team_id}`);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Team deleted" },
                null,
                2
              ),
            },
          ],
        };
      }

      case "list_team_members": {
        const data = await apiRequest(
          "GET",
          `/teams/${args.team_id}/members`,
          null,
          {
            role: args.role || "all",
            per_page: args.per_page || 30,
            page: args.page || 1,
          }
        );
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "add_team_member": {
        await apiRequest("PUT", `/teams/${args.team_id}/memberships/${args.username}`, {
          role: args.role || "member",
        });
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Member added to team" },
                null,
                2
              ),
            },
          ],
        };
      }

      case "remove_team_member": {
        await apiRequest("DELETE", `/teams/${args.team_id}/members/${args.username}`);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Member removed from team" },
                null,
                2
              ),
            },
          ],
        };
      }

      // ===== WEBHOOKS =====
      case "list_org_webhooks": {
        const data = await apiRequest("GET", `/orgs/${args.org}/hooks`, null, {
          per_page: args.per_page || 30,
          page: args.page || 1,
        });
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "create_org_webhook": {
        const payload = {
          name: args.name || "web",
          config: args.config,
          events: args.events || ["push"],
          active: args.active !== false,
        };
        const data = await apiRequest("POST", `/orgs/${args.org}/hooks`, payload);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Webhook created", webhook: data },
                null,
                2
              ),
            },
          ],
        };
      }

      case "get_org_webhook": {
        const data = await apiRequest("GET", `/orgs/${args.org}/hooks/${args.hook_id}`);
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "update_org_webhook": {
        const payload = {};
        if (args.config) payload.config = args.config;
        if (args.events) payload.events = args.events;
        if (args.active !== undefined) payload.active = args.active;

        const data = await apiRequest(
          "PATCH",
          `/orgs/${args.org}/hooks/${args.hook_id}`,
          payload
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Webhook updated", webhook: data },
                null,
                2
              ),
            },
          ],
        };
      }

      case "delete_org_webhook": {
        await apiRequest("DELETE", `/orgs/${args.org}/hooks/${args.hook_id}`);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Webhook deleted" },
                null,
                2
              ),
            },
          ],
        };
      }

      case "list_repo_webhooks": {
        const data = await apiRequest(
          "GET",
          `/repos/${args.owner}/${args.repo}/hooks`,
          null,
          { per_page: args.per_page || 30, page: args.page || 1 }
        );
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "create_repo_webhook": {
        const payload = {
          name: args.name || "web",
          config: args.config,
          events: args.events || ["push"],
          active: args.active !== false,
        };
        const data = await apiRequest(
          "POST",
          `/repos/${args.owner}/${args.repo}/hooks`,
          payload
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Webhook created", webhook: data },
                null,
                2
              ),
            },
          ],
        };
      }

      case "get_repo_webhook": {
        const data = await apiRequest(
          "GET",
          `/repos/${args.owner}/${args.repo}/hooks/${args.hook_id}`
        );
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "update_repo_webhook": {
        const payload = {};
        if (args.config) payload.config = args.config;
        if (args.events) payload.events = args.events;
        if (args.active !== undefined) payload.active = args.active;

        const data = await apiRequest(
          "PATCH",
          `/repos/${args.owner}/${args.repo}/hooks/${args.hook_id}`,
          payload
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Webhook updated", webhook: data },
                null,
                2
              ),
            },
          ],
        };
      }

      case "delete_repo_webhook": {
        await apiRequest(
          "DELETE",
          `/repos/${args.owner}/${args.repo}/hooks/${args.hook_id}`
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Webhook deleted" },
                null,
                2
              ),
            },
          ],
        };
      }

      // ===== ACTIONS SECRETS & VARIABLES =====
      case "list_repo_secrets": {
        const data = await apiRequest(
          "GET",
          `/repos/${args.owner}/${args.repo}/actions/secrets`,
          null,
          { per_page: args.per_page || 30, page: args.page || 1 }
        );
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "get_repo_public_key": {
        const data = await apiRequest(
          "GET",
          `/repos/${args.owner}/${args.repo}/actions/secrets/public-key`
        );
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "create_or_update_repo_secret": {
        const payload = {
          encrypted_value: args.encrypted_value,
          key_id: args.key_id,
        };
        const data = await apiRequest(
          "PUT",
          `/repos/${args.owner}/${args.repo}/actions/secrets/${args.secret_name}`,
          payload
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Secret created/updated", data },
                null,
                2
              ),
            },
          ],
        };
      }

      case "delete_repo_secret": {
        await apiRequest(
          "DELETE",
          `/repos/${args.owner}/${args.repo}/actions/secrets/${args.secret_name}`
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Secret deleted" },
                null,
                2
              ),
            },
          ],
        };
      }

      case "list_org_secrets": {
        const data = await apiRequest(
          "GET",
          `/orgs/${args.org}/actions/secrets`,
          null,
          { per_page: args.per_page || 30, page: args.page || 1 }
        );
        return {
          content: [{ type: "text", text: JSON.stringify(data, null,2) }],
        };
      }

      case "get_org_public_key": {
        const data = await apiRequest(
          "GET",
          `/orgs/${args.org}/actions/secrets/public-key`
        );
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "list_repo_variables": {
        const data = await apiRequest(
          "GET",
          `/repos/${args.owner}/${args.repo}/actions/variables`,
          null,
          { per_page: args.per_page || 30, page: args.page || 1 }
        );
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "create_repo_variable": {
        const payload = {
          name: args.name,
          value: args.value,
        };
        const data = await apiRequest(
          "POST",
          `/repos/${args.owner}/${args.repo}/actions/variables`,
          payload
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Variable created", variable: data },
                null,
                2
              ),
            },
          ],
        };
      }

      case "update_repo_variable": {
        const payload = {
          name: args.name,
          value: args.value,
        };
        const data = await apiRequest(
          "PATCH",
          `/repos/${args.owner}/${args.repo}/actions/variables/${args.name}`,
          payload
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Variable updated", variable: data },
                null,
                2
              ),
            },
          ],
        };
      }

      case "delete_repo_variable": {
        await apiRequest(
          "DELETE",
          `/repos/${args.owner}/${args.repo}/actions/variables/${args.name}`
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Variable deleted" },
                null,
                2
              ),
            },
          ],
        };
      }

      // ===== RUNNERS =====
      case "list_org_runners": {
        const data = await apiRequest(
          "GET",
          `/orgs/${args.org}/actions/runners`,
          null,
          { per_page: args.per_page || 30, page: args.page || 1 }
        );
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "list_repo_runners": {
        const data = await apiRequest(
          "GET",
          `/repos/${args.owner}/${args.repo}/actions/runners`,
          null,
          { per_page: args.per_page || 30, page: args.page || 1 }
        );
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "get_runner": {
        const endpoint = args.repo
          ? `/repos/${args.owner}/${args.repo}/actions/runners/${args.runner_id}`
          : `/orgs/${args.owner}/actions/runners/${args.runner_id}`;
        const data = await apiRequest("GET", endpoint);
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "delete_runner": {
        const endpoint = args.repo
          ? `/repos/${args.owner}/${args.repo}/actions/runners/${args.runner_id}`
          : `/orgs/${args.owner}/actions/runners/${args.runner_id}`;
        await apiRequest("DELETE", endpoint);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Runner deleted" },
                null,
                2
              ),
            },
          ],
        };
      }

      // ===== REPOSITORY MANAGEMENT =====
      case "create_repository": {
        const payload = {
          name: args.name,
          description: args.description,
          private: args.private || false,
          has_issues: args.has_issues !== false,
          has_projects: args.has_projects !== false,
          has_wiki: args.has_wiki !== false,
          has_downloads: args.has_downloads !== false,
          auto_init: args.auto_init || false,
        };
        if (args.gitignore_template) payload.gitignore_template = args.gitignore_template;
        if (args.license_template) payload.license_template = args.license_template;

        const endpoint = args.org
          ? `/orgs/${args.org}/repos`
          : "/user/repos";
        const data = await apiRequest("POST", endpoint, payload);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Repository created", repo: data },
                null,
                2
              ),
            },
          ],
        };
      }

      case "update_repository": {
        const payload = {};
        Object.keys(args).forEach((key) => {
          if (!["owner", "repo"].includes(key) && args[key] !== undefined) {
            payload[key] = args[key];
          }
        });
        const data = await apiRequest(
          "PATCH",
          `/repos/${args.owner}/${args.repo}`,
          payload
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Repository updated", repo: data },
                null,
                2
              ),
            },
          ],
        };
      }

      case "delete_repository": {
        await apiRequest("DELETE", `/repos/${args.owner}/${args.repo}`);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Repository deleted" },
                null,
                2
              ),
            },
          ],
        };
      }

      case "transfer_repository": {
        const payload = {
          new_owner: args.new_owner,
        };
        if (args.team_ids) payload.team_ids = args.team_ids;
        const data = await apiRequest(
          "POST",
          `/repos/${args.owner}/${args.repo}/transfer`,
          payload
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Repository transferred", repo: data },
                null,
                2
              ),
            },
          ],
        };
      }

      // ===== COLLABORATORS =====
      case "list_collaborators": {
        const data = await apiRequest(
          "GET",
          `/repos/${args.owner}/${args.repo}/collaborators`,
          null,
          {
            affiliation: args.affiliation || "all",
            per_page: args.per_page || 30,
            page: args.page || 1,
          }
        );
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "add_collaborator": {
        await apiRequest(
          "PUT",
          `/repos/${args.owner}/${args.repo}/collaborators/${args.username}`,
          { permission: args.permission || "push" }
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Collaborator added" },
                null,
                2
              ),
            },
          ],
        };
      }

      case "remove_collaborator": {
        await apiRequest(
          "DELETE",
          `/repos/${args.owner}/${args.repo}/collaborators/${args.username}`
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Collaborator removed" },
                null,
                2
              ),
            },
          ],
        };
      }

      // ===== BRANCH PROTECTION =====
      case "get_branch_protection": {
        const data = await apiRequest(
          "GET",
          `/repos/${args.owner}/${args.repo}/branches/${args.branch}/protection`
        );
        return {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
        };
      }

      case "update_branch_protection": {
        const payload = {};
        if (args.required_status_checks)
          payload.required_status_checks = args.required_status_checks;
        if (args.enforce_admins !== undefined)
          payload.enforce_admins = args.enforce_admins;
        if (args.required_pull_request_reviews)
          payload.required_pull_request_reviews = args.required_pull_request_reviews;
        if (args.restrictions) payload.restrictions = args.restrictions;
        if (args.required_linear_history !== undefined)
          payload.required_linear_history = args.required_linear_history;
        if (args.allow_force_pushes !== undefined)
          payload.allow_force_pushes = args.allow_force_pushes;
        if (args.allow_deletions !== undefined)
          payload.allow_deletions = args.allow_deletions;
        if (args.block_creations !== undefined)
          payload.block_creations = args.block_creations;
        if (args.required_conversation_resolution !== undefined)
          payload.required_conversation_resolution = args.required_conversation_resolution;
        if (args.lock_branch !== undefined) payload.lock_branch = args.lock_branch;
        if (args.allow_fork_syncing !== undefined)
          payload.allow_fork_syncing = args.allow_fork_syncing;

        const data = await apiRequest(
          "PUT",
          `/repos/${args.owner}/${args.repo}/branches/${args.branch}/protection`,
          payload
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Branch protection updated", data },
                null,
                2
              ),
            },
          ],
        };
      }

      case "delete_branch_protection": {
        await apiRequest(
          "DELETE",
          `/repos/${args.owner}/${args.repo}/branches/${args.branch}/protection`
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { success: true, message: "Branch protection deleted" },
                null,
                2
              ),
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
  console.error("GitHub Admin MCP server running on stdio");
}

main().catch(console.error);

