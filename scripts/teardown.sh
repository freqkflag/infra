#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <vps.host|home.macmini|home.linux> [service ...]" >&2
  exit 1
fi

TARGET="$1"
shift

case "$TARGET" in
  vps.host)
    COMPOSE_FILE="docker-compose/vps.host.yml"
    ENVIRONMENT="production"
    ;;
  home.macmini)
    COMPOSE_FILE="docker-compose/home.macmini.yml"
    ENVIRONMENT="development"
    ;;
  home.linux)
    COMPOSE_FILE="docker-compose/home.linux.yml"
    ENVIRONMENT="homelab"
    ;;
  *)
    echo "Unknown target: $TARGET" >&2
    exit 1
    ;;
esac

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "Compose file not found: $COMPOSE_FILE" >&2
  exit 1
fi

run_compose() {
  infisical run --env="$ENVIRONMENT" -- docker compose -f "$COMPOSE_FILE" "$@"
}

if [ $# -eq 0 ]; then
  echo "[teardown] stopping complete stack for $TARGET"
  run_compose down --remove-orphans
else
  echo "[teardown] stopping selected services on $TARGET: $*"
  run_compose stop "$@"
  run_compose rm -f "$@"
fi
