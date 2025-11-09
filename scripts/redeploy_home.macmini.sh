#!/usr/bin/env bash
#
# Idempotent redeploy routine for the home.macmini node.

set -o errexit
set -o nounset
set -o pipefail

DEVICE="home.macmini"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SCRIPT_DIR}/lib/redeploy-common.sh"

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] [service...]

Options:
  --context <docker-context>   Use Docker CLI context (default: local)
  --plan                       Print planned compose command then exit
  --no-health-check            Skip post-deploy health-check
  --help                       Show this message

Extra arguments are forwarded as docker compose service filters.
EOF
}

PLAN_ONLY="false"
RUN_HEALTH="true"
declare -a SERVICES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --context)
      shift
      export DOCKER_CONTEXT="${1:-}"
      ;;
    --plan)
      PLAN_ONLY="true"
      ;;
    --no-health-check)
      RUN_HEALTH="false"
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    --*)
      abort "unknown option: $1"
      ;;
    *)
      SERVICES+=("$1")
      ;;
  esac
  shift || true
done

require_command docker

COMPOSE_DIR="${ROOT_DIR}/nodes/${DEVICE}/compose"
COMPOSE_BUNDLE="${ROOT_DIR}/nodes/${DEVICE}/compose.yml"
HEALTH_CHECK="${ROOT_DIR}/nodes/${DEVICE}/health-check.sh"

declare -a COMPOSE_FILES=()
compose_args_from_dir "${COMPOSE_DIR}" COMPOSE_FILES

if [[ ${#COMPOSE_FILES[@]} -eq 0 ]]; then
  compose_args_from_bundle "${COMPOSE_BUNDLE}" COMPOSE_FILES
fi

[[ ${#COMPOSE_FILES[@]} -gt 0 ]] || abort "no compose files found for ${DEVICE}"

declare -a COMPOSE_ARGS=()
for file in "${COMPOSE_FILES[@]}"; do
  COMPOSE_ARGS+=( -f "${file}" )
done

log "INFO" "compose stack for ${DEVICE}:"
printf '  %s\n' "${COMPOSE_FILES[@]}" >&2

if [[ "${PLAN_ONLY}" == "true" ]]; then
  log "INFO" "plan mode enabled; compose command would be:"
  printf 'docker%s compose %s up -d %s\n' \
    "${DOCKER_CONTEXT:+ --context ${DOCKER_CONTEXT}}" \
    "${COMPOSE_ARGS[*]}" \
    "${SERVICES[*]}" \
    >&2
  exit 0
fi

log "INFO" "deploying ${DEVICE} via docker compose"
docker_compose_exec "${COMPOSE_ARGS[@]}" pull "${SERVICES[@]}"
docker_compose_exec "${COMPOSE_ARGS[@]}" up -d --remove-orphans "${SERVICES[@]}"

if [[ "${RUN_HEALTH}" == "true" ]]; then
  health_check_script "${HEALTH_CHECK}"
else
  log "WARN" "health check skipped by user request"
fi

log "INFO" "redeploy completed for ${DEVICE}"

