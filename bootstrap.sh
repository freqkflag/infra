#!/usr/bin/env bash
set -euo pipefail

echo "=== Bootstrapping Joey Infra ==="

# Install prerequisites
sudo apt update
sudo apt install -y docker.io docker-compose git curl jq

# Clone or pull latest infra repo
if [[ ! -d ~/infra ]]; then
  git clone https://github.com/freqkflag/infra.git ~/infra
else
  cd ~/infra && git pull
fi

# Prepare environment
if [[ ! -f ~/.workspace/.env ]]; then
  echo "❌ Missing environment file (~/.workspace/.env)."
  echo "Copy infra/.env.example and fill it out before rerunning."
  exit 1
fi

# Deploy using existing scripts
cd ~/infra/scripts
./preflight.sh
./backup.sh
./status.sh

echo "✅ Infra bootstrap complete. Ready for deployment."
