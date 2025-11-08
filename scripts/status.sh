#!/usr/bin/env bash
set -euo pipefail

echo "=== Docker Containers ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo -e "\n=== Edge Network Check ==="
docker network inspect edge --format '{{.Name}}: {{len .Containers}} containers attached' || true

echo -e "\n=== Disk Usage ==="
df -h | grep -E 'Filesystem|/home|/srv'

echo -e "\n=== Cloudflared Tunnel Logs (last 10 lines) ==="
docker logs --tail 10 cloudflared 2>/dev/null || echo "No cloudflared container found."

echo "✅ Status check complete."
exit 0
