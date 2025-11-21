#!/bin/bash
# Fix .env file permissions across all services
# Ensures all .env files have 600 permissions (owner read/write only)

set -e

echo "Fixing .env file permissions..."

find /root/infra -name ".env" -type f -exec chmod 600 {} \;

echo "✓ Fixed permissions for all .env files"
echo ""
echo "Verifying permissions:"
find /root/infra -name ".env" -type f -exec ls -l {} \;

