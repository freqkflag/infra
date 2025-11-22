#!/bin/bash
#
# Agent and MCP Server Inventory
# Lists all registered agents and MCP servers for A2A protocol
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$(cd "$SCRIPT_DIR/../agents" && pwd)"
INFRA_DIR="/root/infra"
REGISTRY_FILE="${INFRA_DIR}/.cursor/agents/registry.json"

echo "=========================================="
echo "Agent and MCP Server Inventory"
echo "Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
echo "=========================================="
echo ""

# Virtual Agents (ai.engine)
echo "=== Virtual Agents (ai.engine) ==="
echo ""
for agent_file in "$AGENTS_DIR"/*-agent.md; do
    if [ -f "$agent_file" ]; then
        agent_name=$(basename "$agent_file" -agent.md)
        echo "  • $agent_name"
        echo "    File: $agent_file"
        echo "    Type: virtual"
        echo ""
    fi
done

# Registered Agents (.cursor/agents)
echo "=== Registered Agents (.cursor/agents) ==="
echo ""
if [ -f "$REGISTRY_FILE" ]; then
    # Extract agent names from registry
    jq -r '.agents | to_entries[] | "  • \(.key)\n    Module: \(.value.module_path // .value.module)\n    Class: \(.value.class)\n    Description: \(.value.description)\n    Allowed Hosts: \(.value.allowed_hosts | join(", "))\n    Tags: \(.value.tags | join(", "))\n"' "$REGISTRY_FILE" 2>/dev/null || {
        echo "  (Registry file exists but could not parse JSON)"
        echo ""
    }
else
    echo "  (No registry file found at $REGISTRY_FILE)"
    echo ""
fi

# MCP Servers
echo "=== MCP Servers ==="
echo ""
echo "  • Infisical MCP"
echo "    Location: /root/infra/infisical-mcp/"
echo "    Package: @infisical/mcp"
echo "    Tools: list-secrets, get-secret, create-secret, update-secret, delete-secret, list-projects, create-project, create-environment, create-folder, invite-members-to-project"
echo ""

echo "  • Cloudflare MCP"
echo "    Location: /root/infra/scripts/cloudflare-mcp-server.js"
echo "    Tools: list_zones, get_dns_records, create_dns_record, update_dns_record, delete_dns_record"
echo ""

echo "  • WikiJS MCP"
echo "    Location: /root/infra/scripts/wikijs-mcp-server.js"
echo "    Tools: list_pages, get_page, create_page, update_page, delete_page, search_pages"
echo ""

echo "  • GitHub MCP"
echo "    Location: /root/infra/scripts/github-mcp-server.js"
echo "    Tools: list_repositories, get_repository, search_repositories, list_issues, get_issue, create_issue, update_issue, list_pull_requests, get_pull_request, create_pull_request, list_branches, get_file_contents"
echo ""

echo "  • GitHub Admin MCP"
echo "    Location: /root/infra/scripts/github-admin-mcp-server.js"
echo "    Tools: 62 administrative tools (GitHub Apps, OAuth Apps, Organizations, Teams, Webhooks, Actions, Runners, Repositories, Branch Protection)"
echo ""

echo "  • Kong Admin MCP"
echo "    Location: /root/infra/scripts/kong-mcp-server.js"
echo "    Tools: list_services, list_routes, apply_service_patch, sync_plugin, reload"
echo ""

echo "  • Docker/Compose MCP"
echo "    Location: /root/infra/scripts/docker-compose-mcp-server.js"
echo "    Tools: list_containers, compose_up, compose_down, compose_logs, health_report"
echo ""

echo "  • Monitoring MCP"
echo "    Location: /root/infra/scripts/monitoring-mcp-server.js"
echo "    Tools: prom_query, grafana_dashboard, alertmanager_list, ack_alert"
echo ""

echo "  • GitLab MCP"
echo "    Location: /root/infra/scripts/gitlab-mcp-server.js"
echo "    Tools: list_projects, get_pipeline_status, create_issue, update_variable"
echo ""

echo "  • Browser MCP (Cursor IDE)"
echo "    Location: Built-in Cursor IDE"
echo "    Tools: navigate, snapshot, click, type, hover, select_option, press_key, wait_for, navigate_back, resize, console_messages, network_requests, take_screenshot"
echo ""

echo "=========================================="
echo "Total Counts:"
echo "  Virtual Agents: $(find "$AGENTS_DIR" -name "*-agent.md" | wc -l)"
echo "  Registered Agents: $(jq -r '.agents | length' "$REGISTRY_FILE" 2>/dev/null || echo "0")"
echo "  MCP Servers: 9"
echo "=========================================="

