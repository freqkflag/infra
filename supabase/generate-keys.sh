#!/bin/bash
# Generate Supabase API keys from JWT secret

set -e

JWT_SECRET="${1:-$(openssl rand -base64 32)}"

echo "JWT_SECRET: $JWT_SECRET"
echo ""

# Generate ANON_KEY (JWT token with anon role)
# Payload: { "role": "anon", "iss": "supabase", "aud": "authenticated" }
ANON_PAYLOAD='{"role":"anon","iss":"supabase","aud":"authenticated"}'
ANON_KEY=$(echo -n "$ANON_PAYLOAD" | openssl dgst -sha256 -hmac "$JWT_SECRET" -binary | base64 | tr -d '\n' | sed 's/+/-/g' | sed 's/\//_/g' | sed 's/=//g')
ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.$(echo -n "$ANON_PAYLOAD" | base64 | tr -d '\n' | sed 's/+/-/g' | sed 's/\//_/g' | sed 's/=//g').$ANON_KEY"

# Generate SERVICE_ROLE_KEY (JWT token with service_role)
# Payload: { "role": "service_role", "iss": "supabase", "aud": "authenticated" }
SERVICE_PAYLOAD='{"role":"service_role","iss":"supabase","aud":"authenticated"}'
SERVICE_KEY=$(echo -n "$SERVICE_PAYLOAD" | openssl dgst -sha256 -hmac "$JWT_SECRET" -binary | base64 | tr -d '\n' | sed 's/+/-/g' | sed 's/\//_/g' | sed 's/=//g')
SERVICE_ROLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.$(echo -n "$SERVICE_PAYLOAD" | base64 | tr -d '\n' | sed 's/+/-/g' | sed 's/\//_/g' | sed 's/=//g').$SERVICE_KEY"

echo "ANON_KEY: $ANON_KEY"
echo ""
echo "SERVICE_ROLE_KEY: $SERVICE_ROLE_KEY"
echo ""
echo "Add these to your .env file:"
echo "JWT_SECRET=$JWT_SECRET"
echo "ANON_KEY=$ANON_KEY"
echo "SERVICE_ROLE_KEY=$SERVICE_ROLE_KEY"

