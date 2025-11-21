#!/usr/bin/env bash
#
# Common helpers for infrastructure harvest scripts.
# All functions in this file are pure shell utilities that operate in
# read-only mode against target hosts. They deliberately avoid mutating
# containers, volumes, or services.

set -o errexit
set -o pipefail
set -o nounset

HARVEST_TS="$(date -u +"%Y%m%dT%H%M%SZ")"

log() {
  local level="$1"; shift
  printf '[%s] [%s] %s\n' "${HARVEST_TS}" "${level}" "$*" >&2
}

abort() {
  log "ERROR" "$*"
  exit 1
}

require_command() {
  local cmd="$1"
  command -v "${cmd}" >/dev/null 2>&1 || abort "required command not found: ${cmd}"
}

# Configure docker CLI context if DOCKER_CONTEXT is exported by caller.
docker_cmd() {
  if [[ -n "${DOCKER_CONTEXT:-}" ]]; then
    docker --context "${DOCKER_CONTEXT}" "$@"
  else
    docker "$@"
  fi
}

docker_compose_cmd() {
  if [[ -n "${COMPOSE_FILE:-}" ]]; then
    docker_cmd compose -f "${COMPOSE_FILE}" "$@"
  else
    docker_cmd compose "$@"
  fi
}

timestamped_root() {
  local device="$1"
  local root="${HARVEST_OUTPUT_DIR:-harvest}"
  printf '%s/%s/%s' "${root}" "${device}" "${HARVEST_TS}"
}

mk_harvest_dir() {
  local path="$1"
  mkdir -p "${path}"
}

write_file() {
  local output_path="$1"; shift
  mk_harvest_dir "$(dirname "${output_path}")"
  cat > "${output_path}"
}

capture_cmd() {
  local output_path="$1"
  shift
  mk_harvest_dir "$(dirname "${output_path}")"
  log "INFO" "capture → ${output_path} :: $*"
  "$@" > "${output_path}"
}

# Redact common secret patterns while preserving key names.
redact_stream() {
  sed -E \
    -e 's/([A-Z0-9_]*(PASS|SECRET|TOKEN|KEY|PWD|PW|PASSWORD|PRIVATE|CERT)[A-Z0-9_]*=)[^",[:space:]]+/\1<redacted>/g' \
    -e 's/"(Authorization|authorization)":\s*"[^"]*"/"\1":"<redacted>"/g'
}

capture_docker_inspect() {
  local device="$1"
  local root="$2"
  local ids
  ids="$(docker_cmd ps -q)"
  if [[ -z "${ids}" ]]; then
    log "WARN" "no running containers discovered on ${device}"
    return
  fi

  while IFS= read -r cid; do
    local name
    name="$(docker_cmd inspect --format '{{ .Name }}' "${cid}" | tr -d '/')"
    local outfile="${root}/docker/inspect/${name}.json"
    mk_harvest_dir "$(dirname "${outfile}")"
    log "INFO" "docker inspect → ${outfile}"
    docker_cmd inspect "${cid}" \
      | redact_stream \
      > "${outfile}"
  done <<< "${ids}"
}

capture_docker_ps() {
  local root="$1"
  capture_cmd "${root}/docker/docker-ps.jsonl" docker_cmd ps --format '{{json .}}'
}

capture_docker_networks() {
  local root="$1"
  capture_cmd "${root}/docker/docker-network-ls.jsonl" docker_cmd network ls --format '{{json .}}'
  local names
  names="$(docker_cmd network ls --format '{{.Name}}')"
  while IFS= read -r net; do
    [[ -z "${net}" ]] && continue
    local outfile="${root}/docker/networks/${net}.json"
    mk_harvest_dir "$(dirname "${outfile}")"
    log "INFO" "docker network inspect → ${outfile}"
    docker_cmd network inspect "${net}" \
      | redact_stream \
      > "${outfile}"
  done <<< "${names}"
}

capture_docker_volumes() {
  local root="$1"
  capture_cmd "${root}/docker/docker-volume-ls.jsonl" docker_cmd volume ls --format '{{json .}}'
}

capture_compose_overview() {
  local root="$1"
  if ! docker_cmd compose ls >/dev/null 2>&1; then
    log "WARN" "docker compose ls not supported on this host/context"
    return
  fi
  capture_cmd "${root}/compose/docker-compose-ls.txt" docker_cmd compose ls
  local projects
  projects="$(docker_cmd compose ls --format '{{.Name}}' 2>/dev/null || true)"
  while IFS= read -r project; do
    [[ -z "${project}" ]] && continue
    local outfile="${root}/compose/${project}.yaml"
    mk_harvest_dir "$(dirname "${outfile}")"
    log "INFO" "docker compose convert (${project}) → ${outfile}"
    DOCKER_COMPOSE_PROJECT_OPTS=( --project-name "${project}" )
    docker_cmd compose "${DOCKER_COMPOSE_PROJECT_OPTS[@]}" config \
      | redact_stream \
      > "${outfile}"
  done <<< "${projects}"
}

capture_systemd_units() {
  local root="$1"
  if ! command -v systemctl >/dev/null 2>&1; then
    log "WARN" "systemctl not available; skipping systemd harvest"
    return
  fi
  local units outfile
  outfile="${root}/systemd/matching-units.txt"
  mk_harvest_dir "$(dirname "${outfile}")"
  log "INFO" "systemd unit inventory → ${outfile}"
  systemctl list-unit-files --type=service \
    | grep -Ei '(docker|traefik|kong|infisical|cloudflared|compose)' \
    > "${outfile}" || true

  while read -r unit _; do
    [[ -z "${unit}" ]] && continue
    local unit_file="/etc/systemd/system/${unit}"
    if [[ -f "${unit_file}" ]]; then
      local dest="${root}/systemd/units/${unit}"
      mk_harvest_dir "$(dirname "${dest}")"
      log "INFO" "capturing systemd unit → ${dest}"
      redact_stream < "${unit_file}" > "${dest}"
    fi
  done < <(cut -d' ' -f1 "${outfile}" | grep -F '.service')
}

capture_reverse_proxy() {
  local root="$1"
  local traefik_dir="/etc/traefik"
  if [[ -d "${traefik_dir}" ]]; then
    local dest="${root}/reverse-proxy/traefik"
    mk_harvest_dir "${dest}"
    log "INFO" "sync traefik config → ${dest}"
    find "${traefik_dir}" -type f \( -name '*.yml' -o -name '*.yaml' -o -name '*.toml' \) -print0 \
      | while IFS= read -r -d '' file; do
        local relative="${file#"${traefik_dir}/"}"
        mk_harvest_dir "${dest}/$(dirname "${relative}")"
        redact_stream < "${file}" > "${dest}/${relative}"
      done
  else
    log "WARN" "traefik directory not found at ${traefik_dir}"
  fi
}

archive_harvest() {
  local root="$1"
  local archive="${root}/../harvest_${HARVEST_TS}.tar.gz"
  log "INFO" "packaging harvest → ${archive}"
  tar -C "$(dirname "${root}")" -czf "${archive}" "$(basename "${root}")"
  log "INFO" "harvest archive created: ${archive}"
}

