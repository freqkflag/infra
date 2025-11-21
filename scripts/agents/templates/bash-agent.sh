#!/usr/bin/env bash
set -euo pipefail

# Skeleton for a bash-based infra agent.
# Replace occurrences of template-agent with the new agent name.

AGENT_NAME="template-agent"
LOG_FILE="${LOG_FILE:-$HOME/infra/server-changelog.md}"

timestamp() {
  python -c 'from datetime import datetime; print(datetime.now().astimezone().isoformat())'
}

log() {
  printf "%s %s %s\n" "$(timestamp)" "$AGENT_NAME" "$1" >> "$LOG_FILE"
}

log "start"

# TODO: implement agent actions here.

log "done"

