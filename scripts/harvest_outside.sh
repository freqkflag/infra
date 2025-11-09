#!/usr/bin/env bash
set -euo pipefail

DEVICE="${1:?usage: $0 <device> [repo_root] }"
REPO_ROOT="${2:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

detect_compose() {
  if docker compose version >/dev/null 2>&1; then
    echo "docker compose"
    return 0
  fi
  if docker-compose version >/dev/null 2>&1; then
    echo "docker-compose"
    return 0
  fi
  echo "[ERR] No docker compose implementation found (install docker-compose-plugin or docker-compose)." >&2
  exit 1
}

COMPOSE_CMD="$(detect_compose)"
CFGCMD="config"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUTDIR="harvest_${DEVICE}_${STAMP}"
TMP="$(mktemp -d)"

echo "[*] Harvesting outside repo into ${OUTDIR}/ (repo root = ${REPO_ROOT})"

mkdir -p "${TMP}/docker"
docker ps -aq | xargs -r docker inspect > "${TMP}/docker/containers.inspect.json"
docker network ls -q | xargs -r docker network inspect > "${TMP}/docker/networks.inspect.json"
docker volume ls -q | xargs -r docker volume inspect > "${TMP}/docker/volumes.inspect.json"

mkdir -p "${TMP}/compose"
${COMPOSE_CMD} ls --format json > "${TMP}/compose/compose-ls.json" || true

mkdir -p "${TMP}/compose/files"

search_roots=(
  /etc
  /opt
  /srv
  /root
  /home
)

find_compose_files() {
  local root="$1"
  sudo find "${root}" -xdev \
    -path "${REPO_ROOT}" -prune -o \
    -path "${REPO_ROOT}/.git" -prune -o \
    -path /var/lib/docker -prune -o \
    -path "${HOME}/.cursor" -prune -o \
    -path '*/.cursor' -prune -o \
    -path '*/.cursor/*' -prune -o \
    -path '*/node_modules' -prune -o \
    -path '*/node_modules/*' -prune -o \
    -path '*/.git/*' -prune -o \
    -type f \( -name docker-compose.yml -o -name docker-compose.yaml -o -name compose.yml -o -name compose.yaml \) \
    -print 2>/dev/null
}

for root in "${search_roots[@]}"; do
  if [[ -d "${root}" ]]; then
    find_compose_files "${root}"
  fi
done | sort -u | tee "${TMP}/compose/files/paths.txt"

while read -r compose_file; do
  [[ -z "${compose_file}" ]] && continue
  dir="$(dirname "${compose_file}")"
  safe_dir="$(echo "${dir}" | tr '/ ' '__')"
  cp "${compose_file}" "${TMP}/compose/files/${safe_dir}.yml" || true
  ( cd "${dir}" && ${COMPOSE_CMD} -f "${compose_file}" ${CFGCMD} ) > "${TMP}/compose/files/${safe_dir}.rendered.yml" || true
done < "${TMP}/compose/files/paths.txt"

mkdir -p "${TMP}/systemd"
grep -RIl -e 'docker ' -e 'docker-compose' /etc/systemd/system 2>/dev/null \
  | while read -r unit; do
      out="${TMP}/systemd/$(echo "${unit}" | tr '/ ' '__')"
      cp "${unit}" "${out}" || true
    done

mkdir -p "${TMP}/reverse-proxy"
if [[ -d /etc/traefik ]]; then
  cp -a /etc/traefik "${TMP}/reverse-proxy/traefik"
fi
if [[ -d /etc/nginx ]]; then
  cp -a /etc/nginx "${TMP}/reverse-proxy/nginx"
fi

for root in /srv /opt; do
  if [[ -d "${root}" ]]; then
    tar --exclude="${REPO_ROOT}" --exclude='*/.git/*' --exclude='*/node_modules/*' --exclude='*/.cursor/*' --exclude='/var/lib/docker/overlay2/*' \
      -C "${root}" -czf "${TMP}/${DEVICE}$(echo "${root}" | tr / _).tar.gz" . || true
  fi
done

mkdir -p "${OUTDIR}"
tar -C "${TMP}" -czf "${OUTDIR}/${OUTDIR}.tar.gz" .
echo "[+] Harvest archive written to ${OUTDIR}/${OUTDIR}.tar.gz"

exit 0
