#!/usr/bin/env bash
#
# Common utilities for redeploy scripts. Encapsulates logic to assemble compose
# file lists, perform health checks, and provide consistent logging.

set -o errexit
set -o pipefail
set -o nounset

REDEPLOY_TS="$(date -u +"%Y%m%dT%H%M%SZ")"

log() {
  local level="$1"; shift
  printf '[%s] [%s] %s\n' "${REDEPLOY_TS}" "${level}" "$*" >&2
}

abort() {
  log "ERROR" "$*"
  exit 1
}

require_command() {
  local cmd="$1"
  command -v "${cmd}" >/dev/null 2>&1 || abort "missing required command: ${cmd}"
}

compose_args_from_dir() {
  local compose_dir="$1"
  local -n __result="$2"
  if [[ -d "${compose_dir}" ]]; then
    mapfile -t __result < <(find "${compose_dir}" -maxdepth 1 -type f -name '*.yml' -o -name '*.yaml' | sort)
  fi
}

compose_args_from_bundle() {
  local bundle_file="$1"
  local -n __result="$2"
  if [[ -f "${bundle_file}" ]]; then
    __result=("${bundle_file}")
  fi
}

docker_compose_exec() {
  if [[ -n "${DOCKER_CONTEXT:-}" ]]; then
    docker --context "${DOCKER_CONTEXT}" compose "$@"
  else
    docker compose "$@"
  fi
}

health_check_script() {
  local script_path="$1"
  if [[ -x "${script_path}" ]]; then
    log "INFO" "running health check: ${script_path}"
    "${script_path}"
  else
    log "WARN" "health check script not executable: ${script_path}"
  fi
}

wait_for_containers() {
  local services_file="$1"
  while IFS= read -r service; do
    [[ -z "${service}" ]] && continue
    log "INFO" "ensuring service healthy: ${service}"
    docker_compose_exec ps "${service}"
  done < "${services_file}"
}

