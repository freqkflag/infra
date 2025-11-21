#!/bin/bash
# Script to import FL Clone documentation to WikiJS using the MCP server
# This script uses the WikiJS MCP server to create the page programmatically

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOC_FILE="$SCRIPT_DIR/WIKIJS_DOCUMENTATION.md"
MCP_SERVER="/root/infra/scripts/wikijs-mcp-server.js"

if [ ! -f "$DOC_FILE" ]; then
    echo "Error: Documentation file not found: $DOC_FILE"
    exit 1
fi

if [ ! -f "$MCP_SERVER" ]; then
    echo "Error: MCP server not found: $MCP_SERVER"
    exit 1
fi

# Load environment variables
if [ -f /root/.env ]; then
    export $(grep -v '^#' /root/.env | xargs)
fi

if [ -z "$WIKIJS_API_KEY" ]; then
    echo "Error: WIKIJS_API_KEY not found in /root/.env"
    exit 1
fi

echo "=========================================="
echo "Importing FL Clone Documentation to WikiJS"
echo "=========================================="
echo ""

# Read documentation content
CONTENT=$(cat "$DOC_FILE")

# Create JSON payload for MCP tool call
JSON_PAYLOAD=$(cat <<EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "create_page",
    "arguments": {
      "title": "FL Clone - Building Process Documentation",
      "path": "projects/fl-clone-building-process",
      "content": $(echo "$CONTENT" | jq -Rs .),
      "description": "Complete documentation of the FL Clone social platform build process, architecture, and deployment",
      "editor": "markdown",
      "isPublished": true,
      "tags": ["fl-clone", "rails", "vue", "social-platform", "twist3dkinkst3r", "kink-tagging"]
    }
  }
}
EOF
)

echo "Creating page in WikiJS..."
echo ""

# Use Node.js to call the MCP server
node -e "
import('$MCP_SERVER').then(async (module) => {
  // This is a simplified approach - in practice, you'd use the MCP client
  console.log('Note: This script requires MCP client integration');
  console.log('For now, please use the manual import method or configure MCP in your client');
}).catch(err => {
  console.error('Error:', err.message);
  process.exit(1);
});
" 2>/dev/null || {
    echo "Note: Direct MCP server execution requires MCP client setup."
    echo ""
    echo "To use the MCP server:"
    echo "1. Configure it in your MCP client (e.g., Cursor)"
    echo "2. Use the create_page tool with the content from: $DOC_FILE"
    echo ""
    echo "Or use manual import:"
    echo "1. Go to https://wiki.freqkflag.co"
    echo "2. Create new page"
    echo "3. Copy content from: $DOC_FILE"
    echo ""
    echo "Content file: $DOC_FILE"
}

echo ""
echo "=========================================="
echo "Documentation file: $DOC_FILE"
echo "WikiJS URL: ${WIKIJS_API_URL:-https://wiki.freqkflag.co}"
echo "=========================================="

