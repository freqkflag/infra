#!/usr/bin/env bash
set -euo pipefail

# === CONFIGURATION ===
LOG_FILE="$HOME/infra/server-changelog.md"
SCRIPTS_DIR="$HOME/infra/scripts"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

echo "=== Sync Run @ $TIMESTAMP ==="

# Ensure changelog exists
if [[ ! -f "$LOG_FILE" ]]; then
  echo "# Server Changelog" > "$LOG_FILE"
  echo "" >> "$LOG_FILE"
  echo "Initialized $(date)" >> "$LOG_FILE"
  echo "" >> "$LOG_FILE"
fi

# Function to run a script and append its output to the changelog
run_and_log() {
  local script_name=$1
  local header="## [$TIMESTAMP] $script_name"

  echo -e "\n$header\n" >> "$LOG_FILE"
  if bash "$SCRIPTS_DIR/$script_name" >> "$LOG_FILE" 2>&1; then
    echo "✅ $script_name completed successfully."
  else
    echo "❌ $script_name encountered an error. Check changelog."
  fi
}

# === EXECUTION ===
run_and_log "preflight.sh"
run_and_log "backup.sh"
run_and_log "status.sh"

echo -e "\n✅ Sync cycle complete at $TIMESTAMP.\n" | tee -a "$LOG_FILE"
exit 0
