#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <vps.host|home.macmini|home.linux>" >&2
  exit 1
fi

TARGET="$1"
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

echo "[health-check] evaluating $TARGET using $COMPOSE_FILE"

SERVICES=$(docker compose -f "$COMPOSE_FILE" config --services)
EXIT_CODE=0

for SERVICE in $SERVICES; do
  CONTAINERS=$(docker compose -f "$COMPOSE_FILE" ps -q "$SERVICE" || true)
  if [ -z "$CONTAINERS" ]; then
    echo "- $SERVICE: not running"
    EXIT_CODE=1
    continue
  fi
  while IFS= read -r CONTAINER; do
    if [ -z "$CONTAINER" ]; then
      continue
    fi
    HEALTH=$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$CONTAINER" 2>/dev/null || echo "unknown")
    echo "- $SERVICE ($CONTAINER): $HEALTH"
    if [ "$HEALTH" != "healthy" ] && [ "$HEALTH" != "running" ]; then
      EXIT_CODE=1
    fi
  done <<EOF2
$CONTAINERS
EOF2
done

exit $EXIT_CODE
