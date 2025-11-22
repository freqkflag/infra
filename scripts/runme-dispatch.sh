#!/usr/bin/env bash
set -euo pipefail

# runme-dispatch.sh - Dispatcher script for command execution routing
# Reads stdin, prompts for execution target (local shell vs Cursor agent),
# and either runs commands locally or emits a ready-to-paste agent prompt.

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly INFRA_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly SERVICES_YML="${INFRA_ROOT}/SERVICES.yml"

log() {
  printf '%s\n' "$@"
}

fail() {
  printf '❌ %s\n' "$@" >&2
  exit 1
}

# Read stdin into commands variable
read_stdin() {
  if [[ -t 0 ]]; then
    # No stdin provided (terminal input)
    log "No stdin detected. Provide commands via pipe or redirect."
    log "Example: echo 'docker ps' | $0"
    return 1
  fi
  
  # Read stdin
  local input
  input="$(cat)"
  
  if [[ -z "${input:-}" ]]; then
    log "Empty input detected."
    return 1
  fi
  
  printf '%s\n' "${input}"
}

# Parse SERVICES.yml to extract service metadata
get_service_metadata() {
  local service_id="${1:-}"
  
  if [[ ! -f "${SERVICES_YML}" ]]; then
    log "⚠️  SERVICES.yml not found at ${SERVICES_YML}"
    return 0
  fi
  
  # Use yq if available, otherwise return basic info
  if command -v yq >/dev/null 2>&1; then
    yq eval ".services[] | select(.id == \"${service_id}\")" "${SERVICES_YML}" 2>/dev/null || true
  else
    # Fallback: basic grep-based extraction
    if grep -q "id: ${service_id}" "${SERVICES_YML}" 2>/dev/null; then
      log "Service: ${service_id}" >&2
      grep -A 20 "id: ${service_id}" "${SERVICES_YML}" | head -20 || true
    fi
  fi
}

# Detect service context from commands
detect_service_context() {
  local commands="$1"
  local detected=""
  
  # Look for service directory patterns
  while IFS= read -r line; do
    # Match patterns like "cd /root/infra/wikijs" or "./wikijs/..."
    if [[ "$line" =~ /([a-z0-9-]+)/docker-compose\.yml ]] || \
       [[ "$line" =~ cd.*/([a-z0-9-]+) ]] || \
       [[ "$line" =~ \./([a-z0-9-]+)/.*docker ]]; then
      detected="${BASH_REMATCH[1]}"
      break
    fi
  done <<< "$commands"
  
  printf '%s\n' "${detected}"
}

# Generate agent prompt with service metadata
generate_agent_prompt() {
  local commands="$1"
  local service_id="${2:-}"
  
  cat <<EOF
Act as Automator. Execute the following commands:

\`\`\`bash
${commands}
\`\`\`

EOF

  if [[ -n "${service_id:-}" ]]; then
    local metadata
    metadata="$(get_service_metadata "${service_id}")"
    if [[ -n "${metadata:-}" ]]; then
      cat <<EOF
**Service Context:**
\`\`\`yaml
${metadata}
\`\`\`

EOF
    fi
  fi
  
  cat <<EOF
**Execution Requirements:**
- Execute commands in the appropriate directory context
- Verify all operational functions are working correctly after execution
- Report status and any errors encountered
- Update documentation if configuration changes were made

**Expected Outcome:**
- Commands executed successfully
- Service status verified
- Any configuration changes documented
EOF
}

# Execute commands locally
execute_local() {
  local commands="$1"
  local service_id="${2:-}"
  
  log "=== Executing Commands Locally ==="
  
  # Change to service directory if detected
  if [[ -n "${service_id:-}" ]]; then
    local service_dir="${INFRA_ROOT}/${service_id}"
    if [[ -d "${service_dir}" ]]; then
      log "📁 Changing to service directory: ${service_dir}"
      cd "${service_dir}"
    fi
  fi
  
  # Execute commands
  log ""
  log "📋 Commands to execute:"
  log "---"
  printf '%s\n' "${commands}"
  log "---"
  log ""
  
  # Execute commands line by line for better error handling
  while IFS= read -r cmd; do
    [[ -z "${cmd:-}" ]] && continue  # Skip empty lines
    [[ "${cmd}" =~ ^[[:space:]]*# ]] && continue  # Skip comments
    log "▶️  Executing: ${cmd}"
    eval "${cmd}" || {
      log "❌ Command failed: ${cmd}"
      exit 1
    }
  done <<< "${commands}"
}

# Prompt user for execution target
prompt_execution_target() {
  while true; do
    log "" >&2
    log "Select execution target:" >&2
    log "  1) Local shell (execute commands directly)" >&2
    log "  2) Cursor agent (generate ready-to-paste prompt)" >&2
    log "" >&2
    read -r -p "Enter choice [1-2]: " choice
    
    case "${choice:-}" in
      1)
        printf '%s\n' "local"
        return 0
        ;;
      2)
        printf '%s\n' "agent"
        return 0
        ;;
      *)
        log "❌ Invalid choice. Please enter 1 or 2." >&2
        ;;
    esac
  done
}

# Main execution
main() {
  local commands
  commands="$(read_stdin)" || exit 1
  
  local target
  target="$(prompt_execution_target)"
  
  local service_id
  service_id="$(detect_service_context "${commands}")"
  
  if [[ -n "${service_id:-}" ]]; then
    log "🔍 Detected service context: ${service_id}"
  fi
  
  case "${target}" in
    local)
      execute_local "${commands}" "${service_id:-}"
      ;;
    agent)
      log ""
      log "=== Ready-to-Paste Agent Prompt ==="
      log ""
      generate_agent_prompt "${commands}" "${service_id:-}"
      log ""
      ;;
    *)
      fail "Invalid execution target: ${target}"
      ;;
  esac
}

main "$@"

