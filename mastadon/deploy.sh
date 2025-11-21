#!/bin/bash

# Mastodon Deployment Script for twist3dkinkst3r.com
# This script initializes the database and deploys Mastodon using Docker Compose

set -e

echo "🚀 Starting Mastodon deployment for twist3dkinkst3r.com"

# Load environment variables
if [ -f ".env.mastodon" ]; then
    export $(grep -v '^#' .env.mastodon | xargs)
fi

# Database is automatically initialized by the PostgreSQL service
echo "📊 Database service will be initialized automatically"

# Create necessary directories
echo "📁 Creating data directories..."
mkdir -p data/redis
mkdir -p data/config

# Start Mastodon services
echo "🐳 Starting Mastodon services..."
docker-compose up -d

echo "⏳ Waiting for services to be ready..."
sleep 30

# Run database migrations
echo "🔄 Running database migrations..."
docker-compose exec mastodon-web rails db:migrate

# Create admin user (optional - uncomment and modify as needed)
# echo "👤 Creating admin user..."
# docker-compose exec mastodon-web bin/tootctl accounts create admin --email admin@twist3dkinkst3r.com --confirmed --role admin

echo "🎉 Mastodon deployment completed!"
echo "🌐 Access your instance at: https://twist3dkinkst3r.com"
echo ""
echo "📋 Next steps:"
echo "1. Configure DNS to point to your server"
echo "2. Set up SSL certificates (Let's Encrypt recommended)"
echo "3. Configure SMTP settings in .env.mastodon"
echo "4. Create your admin account: docker-compose exec mastodon-web bin/tootctl accounts create <username> --email <email> --confirmed --role admin"
echo "5. Set up Cloudflare R2 bucket 'twist3dkinkst3r' if using S3 storage"
