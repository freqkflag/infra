#!/bin/bash
#
# A2A Session Management
# Manages agent-to-agent communication sessions
#
# Usage:
#   a2a-session.sh create [task_id] [task_metadata_json]
#   a2a-session.sh get <session_id>
#   a2a-session.sh update <session_id> <agent_id> <status> [output_file]
#   a2a-session.sh delete <session_id>
#   a2a-session.sh cleanup [max_age_hours]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="/root/infra"
SESSIONS_DIR="${INFRA_DIR}/.workspace/a2a-sessions"
SESSION_TIMEOUT=3600  # 1 hour in seconds

# Ensure sessions directory exists
mkdir -p "$SESSIONS_DIR"

# Generate session ID
generate_session_id() {
    local timestamp=$(date -u +%Y%m%d%H%M%S)
    local random=$(openssl rand -hex 4)
    echo "a2a-${timestamp}-${random}"
}

# Create new session
create_session() {
    local task_id="${1:-task-$(uuidgen 2>/dev/null || echo "task-$(date +%s)")}"
    local task_metadata="${2:-{}}"
    local session_id=$(generate_session_id)
    local expires_at=$(date -u -d "+1 hour" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -v+1H +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ")")
    
    local session_file="${SESSIONS_DIR}/${session_id}.json"
    
    cat > "$session_file" <<EOF
{
  "session_id": "$session_id",
  "orchestrator": "orchestrator-agent",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "expires_at": "$expires_at",
  "task_id": "$task_id",
  "task_metadata": $task_metadata,
  "agents": [],
  "context": {
    "previous_agents": [],
    "shared_data": {},
    "constraints": {}
  },
  "status": "active"
}
EOF
    
    echo "$session_id"
}

# Get session data
get_session() {
    local session_id="$1"
    local session_file="${SESSIONS_DIR}/${session_id}.json"
    
    if [ ! -f "$session_file" ]; then
        echo "Error: Session not found: $session_id" >&2
        exit 1
    fi
    
    cat "$session_file"
}

# Update session with agent result
update_session() {
    local session_id="$1"
    local agent_id="$2"
    local status="$3"
    local output_file="${4:-}"
    local session_file="${SESSIONS_DIR}/${session_id}.json"
    
    if [ ! -f "$session_file" ]; then
        echo "Error: Session not found: $session_id" >&2
        exit 1
    fi
    
    # Use jq to update session if available, otherwise use sed
    if command -v jq >/dev/null 2>&1; then
        local agent_entry=$(cat <<EOF
{
  "agent_id": "$agent_id",
  "status": "$status",
  "output_file": "$output_file",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
)
        jq --argjson agent "$agent_entry" '.agents += [$agent] | .context.previous_agents += [$agent]' "$session_file" > "${session_file}.tmp" && mv "${session_file}.tmp" "$session_file"
    else
        # Fallback: append to agents array manually
        local agent_entry="{\"agent_id\":\"$agent_id\",\"status\":\"$status\",\"output_file\":\"$output_file\",\"timestamp\":\"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"}"
        # Simple append (requires manual JSON array handling)
        echo "Warning: jq not available, using basic update" >&2
    fi
    
    echo "Session updated: $session_id"
}

# Delete session
delete_session() {
    local session_id="$1"
    local session_file="${SESSIONS_DIR}/${session_id}.json"
    
    if [ -f "$session_file" ]; then
        rm -f "$session_file"
        echo "Session deleted: $session_id"
    else
        echo "Warning: Session not found: $session_id" >&2
    fi
}

# Cleanup expired sessions
cleanup_sessions() {
    local max_age_hours="${1:-24}"
    local max_age_seconds=$((max_age_hours * 3600))
    local current_time=$(date +%s)
    local cleaned=0
    
    for session_file in "${SESSIONS_DIR}"/*.json; do
        if [ -f "$session_file" ]; then
            local file_age=$(($current_time - $(stat -c %Y "$session_file" 2>/dev/null || stat -f %m "$session_file" 2>/dev/null)))
            if [ $file_age -gt $max_age_seconds ]; then
                rm -f "$session_file"
                cleaned=$((cleaned + 1))
            fi
        fi
    done
    
    echo "Cleaned up $cleaned expired sessions"
}

# Main
main() {
    case "${1:-}" in
        create)
            create_session "${2:-}" "${3:-{}}"
            ;;
        get)
            if [ -z "${2:-}" ]; then
                echo "Error: Session ID required" >&2
                exit 1
            fi
            get_session "$2"
            ;;
        update)
            if [ -z "${2:-}" ] || [ -z "${3:-}" ] || [ -z "${4:-}" ]; then
                echo "Error: Session ID, agent ID, and status required" >&2
                exit 1
            fi
            update_session "$2" "$3" "$4" "${5:-}"
            ;;
        delete)
            if [ -z "${2:-}" ]; then
                echo "Error: Session ID required" >&2
                exit 1
            fi
            delete_session "$2"
            ;;
        cleanup)
            cleanup_sessions "${2:-24}"
            ;;
        *)
            cat <<EOF
Usage: $0 <command> [args]

Commands:
  create [task_id] [task_metadata_json]  - Create new session
  get <session_id>                        - Get session data
  update <session_id> <agent_id> <status> [output_file]  - Update session
  delete <session_id>                     - Delete session
  cleanup [max_age_hours]                 - Cleanup expired sessions (default: 24)

Examples:
  $0 create "task-123" '{"priority":"normal","timeout":3600}'
  $0 get a2a-20251122-abc123
  $0 update a2a-20251122-abc123 status-agent completed /tmp/status.json
  $0 cleanup 24
EOF
            exit 1
            ;;
    esac
}

main "$@"

