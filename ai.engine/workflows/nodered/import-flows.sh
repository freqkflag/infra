#!/bin/bash
#
# Import Node-RED flows for AI Engine automation
#
# Usage: ./import-flows.sh [nodered-url]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NODERED_URL="${1:-http://nodered:1880}"
NODERED_USER="${NODERED_USERNAME:-admin}"
NODERED_PASS="${NODERED_PASSWORD:-nodered-infra-2025}"

echo "🚀 Importing Node-RED flows for AI Engine automation..."
echo "📍 Node-RED URL: $NODERED_URL"

# Check if Node-RED is accessible
if ! curl -s -f -u "${NODERED_USER}:${NODERED_PASS}" "${NODERED_URL}/flows" > /dev/null 2>&1; then
    echo "❌ Cannot access Node-RED at $NODERED_URL"
    echo "💡 Make sure Node-RED is running and accessible"
    exit 1
fi

# Get current flows
echo "📥 Fetching current flows..."
CURRENT_FLOWS=$(curl -s -u "${NODERED_USER}:${NODERED_PASS}" "${NODERED_URL}/flows")

# Import each flow
for flow_file in "${SCRIPT_DIR}"/*.json; do
    if [[ "$flow_file" == *"import-flows"* ]] || [[ "$flow_file" == *"README"* ]]; then
        continue
    fi
    
    flow_name=$(basename "$flow_file" .json)
    echo "📦 Importing: $flow_name"
    
    # Read flow JSON
    flow_json=$(cat "$flow_file")
    
    # Merge with existing flows (append to current flows array)
    if [ "$CURRENT_FLOWS" != "[]" ] && [ -n "$CURRENT_FLOWS" ]; then
        # Merge flows
        merged_flows=$(echo "$CURRENT_FLOWS" | jq ". + $flow_json")
    else
        merged_flows="$flow_json"
    fi
    
    # Deploy flows
    response=$(curl -s -w "\n%{http_code}" -X POST \
        -u "${NODERED_USER}:${NODERED_PASS}" \
        -H "Content-Type: application/json" \
        -d "$merged_flows" \
        "${NODERED_URL}/flows")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n-1)
    
    if [ "$http_code" = "200" ] || [ "$http_code" = "204" ]; then
        echo "✅ Successfully imported: $flow_name"
    else
        echo "❌ Failed to import $flow_name (HTTP $http_code)"
        echo "Response: $body"
    fi
done

echo ""
echo "✅ Flow import complete!"
echo "💡 Access Node-RED at $NODERED_URL to view and manage flows"

