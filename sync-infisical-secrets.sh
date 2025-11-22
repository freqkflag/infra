#!/bin/bash
# Sync secrets from Infisical to .env file using service token from .env

cd /root/infra
source .workspace/.env

export INFISICAL_API_URL="https://infisical.freqkflag.co/api"
API_URL="https://infisical.freqkflag.co/api/v3/secrets?environment=dev&workspaceId=8c430744-1a5b-4597-af87-e96d6b9c81e3&path=/prod"

# Fetch secrets from API
response=$(curl -s -H "Authorization: Bearer $INFISICAL_SERVICE_TOKEN" "$API_URL")

if echo "$response" | grep -q "error"; then
    echo "API Error: $response"
    exit 1
fi

# Parse JSON and convert to .env format
echo "$response" | python3 -c "
import json
import sys

try:
    data = json.load(sys.stdin)
    if 'secrets' in data:
        for secret in data['secrets']:
            key = secret.get('secretKey', '')
            value = secret.get('secretValue', '')
            if key:
                print(f'{key}={value}')
    else:
        print('# No secrets found', file=sys.stderr)
except Exception as e:
    print(f'# Error parsing JSON: {e}', file=sys.stderr)
    sys.exit(1)
" > /root/infra/.workspace/.env.new

if [ $? -eq 0 ]; then
    mv /root/infra/.workspace/.env.new /root/infra/.workspace/.env
    echo "✅ Secrets synced successfully to /root/infra/.workspace/.env"
    wc -l /root/infra/.workspace/.env
else
    echo "❌ Failed to sync secrets"
    exit 1
fi
