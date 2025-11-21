#!/bin/bash
# Build Ghost Theme ZIP with version from package.json

set -e

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$THEME_DIR"

# Get version and name from package.json (only first name field, not author.name)
VERSION=$(grep '"version"' package.json | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')
THEME_NAME=$(grep '"name"' package.json | head -1 | sed 's/.*"name": *"\([^"]*\)".*/\1/')

ZIP_FILENAME="${THEME_NAME}-v${VERSION}.zip"

# Remove old zip if exists
if [ -f "$ZIP_FILENAME" ]; then
    echo "Removing old zip: $ZIP_FILENAME"
    rm -f "$ZIP_FILENAME"
fi

echo "Building $ZIP_FILENAME..."
echo "Version: $VERSION"
echo ""

# Create zip excluding dev files
zip -r "$ZIP_FILENAME" . \
    -x "*.zip" \
    -x ".git/*" \
    -x ".gitignore" \
    -x ".devcontainer/*" \
    -x "node_modules/*" \
    -x "*.log" \
    -x ".DS_Store" \
    -x "Thumbs.db" \
    -x ".vscode/*" \
    -x ".idea/*" \
    -x "validate-theme.js" \
    -x "test-theme.sh" \
    -x "docker-compose.dev.yml" \
    -x "VALIDATION-*.md" \
    -x "DEVELOPMENT.md" \
    -x "THEME-OVERVIEW.md" \
    -x "STARTER-CONTENT.md" \
    -x "INSTALLATION.md" \
    -x ".env" \
    -x ".env.local" \
    -x "build-zip.*" \
    > /dev/null 2>&1 || {
    echo "Error: zip command not found. Installing zip..."
    apt-get update -qq && apt-get install -y -qq zip
    zip -r "$ZIP_FILENAME" . \
        -x "*.zip" \
        -x ".git/*" \
        -x ".gitignore" \
        -x ".devcontainer/*" \
        -x "node_modules/*" \
        -x "*.log" \
        -x ".DS_Store" \
        -x "Thumbs.db" \
        -x ".vscode/*" \
        -x ".idea/*" \
        -x "*.md" \
        -x "validate-theme.js" \
        -x "test-theme.sh" \
        -x "docker-compose.dev.yml" \
        -x "VALIDATION-*.md" \
        -x "DEVELOPMENT.md" \
        -x "THEME-OVERVIEW.md" \
        -x "STARTER-CONTENT.md" \
        -x "INSTALLATION.md" \
        -x ".env" \
        -x ".env.local" \
        -x "build-zip.*"
}

FILE_SIZE=$(du -h "$ZIP_FILENAME" | cut -f1)

echo ""
echo "✅ Successfully created $ZIP_FILENAME ($FILE_SIZE)"
echo "   Version: $VERSION"
echo "   Location: $THEME_DIR/$ZIP_FILENAME"
echo ""

