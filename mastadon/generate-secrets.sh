#!/bin/bash
# Generate Mastodon secrets for .env file

echo "Generating Mastodon secrets..."
echo ""
echo "# Add these to your .env file:"
echo ""

# Generate secrets using openssl
echo "ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=$(openssl rand -hex 32)"
echo "ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=$(openssl rand -hex 32)"
echo "ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=$(openssl rand -hex 32)"
echo "SECRET_KEY_BASE=$(openssl rand -hex 64)"
echo "OTP_SECRET=$(openssl rand -hex 32)"

# Generate VAPID keys using openssl
echo ""
echo "# VAPID Keys (for push notifications):"
VAPID_PRIVATE=$(openssl ecparam -genkey -name prime256v1 -noout -outform DER | openssl base64 | tr -d '\n')
VAPID_PUBLIC=$(openssl ec -in <(echo "$VAPID_PRIVATE" | openssl base64 -d) -pubout -outform DER 2>/dev/null | openssl base64 | tr -d '\n' || echo "Run: docker compose run --rm mastodon-web bundle exec rake mastodon:webpush:generate_vapid_key")

echo "VAPID_PRIVATE_KEY=$VAPID_PRIVATE"
echo "VAPID_PUBLIC_KEY=$VAPID_PUBLIC"

echo ""
echo "Note: VAPID keys may need to be generated inside the container after first start."
echo "Run: docker compose run --rm mastodon-web bundle exec rake mastodon:webpush:generate_vapid_key"

