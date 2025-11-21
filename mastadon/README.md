# Mastodon Deployment for twist3dkinkst3r.com

Mastodon instance for the PNP-friendly LGBT+ KINK PWA Community.

**Location:** `/root/infra/mastadon/`

**Domain:** `twist3dkinkst3r.com`

## Architecture

- **Web Service**: Main Mastodon application (Rails/Puma)
- **Sidekiq Service**: Background job processor
- **Redis**: Caching and session storage
- **PostgreSQL**: Dedicated database for Mastodon
- **Cloudflare R2**: File storage (S3-compatible)
- **Traefik**: Reverse proxy with SSL certificates

## Prerequisites

1. **Domain**: `twist3dkinkst3r.com` configured with DNS pointing to your server
2. **SSL Certificate**: Automatically handled by Traefik/Let's Encrypt
3. **Email**: SMTP credentials for notifications
4. **Cloudflare R2**: Bucket `twist3dkinkst3r-mastodon` created (optional but recommended)

## Quick Deployment

1. **Generate Secrets**:
   ```bash
   cd /root/infra/mastadon
   ./generate-secrets.sh >> .env
   ```

2. **Configure Environment**:
   ```bash
   nano .env
   ```
   
   Update:
   - Database password
   - SMTP credentials
   - Cloudflare R2 credentials (if using)
   - All generated secrets

3. **Deploy**:
   ```bash
   docker compose up -d
   ```

4. **Run Database Migrations**:
   ```bash
   docker compose exec mastodon-web rails db:migrate
   ```

5. **Create Admin User**:
   ```bash
   docker compose exec mastodon-web bin/tootctl accounts create admin \
     --email admin@twist3dkinkst3r.com \
     --confirmed \
     --role admin
   ```

6. **Access**:
   - Visit `https://twist3dkinkst3r.com` (once DNS is configured)
   - Complete the initial setup

## Configuration

### Environment Variables

Key variables in `.env`:

**Database:**
- `POSTGRES_USER`: Database user (default: mastodon)
- `POSTGRES_PASSWORD`: Database password (**change this!**)
- `POSTGRES_DB`: Database name (default: mastodon)

**Application:**
- `LOCAL_DOMAIN`: Mastodon domain (twist3dkinkst3r.com)
- `WEB_DOMAIN`: Web domain (twist3dkinkst3r.com)
- `TZ`: Timezone (default: America/New_York)

**Secrets** (generate with `./generate-secrets.sh`):
- `ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY`
- `ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY`
- `ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT`
- `SECRET_KEY_BASE`
- `OTP_SECRET`
- `VAPID_PRIVATE_KEY`
- `VAPID_PUBLIC_KEY`

**SMTP:**
- `SMTP_SERVER`: SMTP server (default: smtp.gmail.com)
- `SMTP_PORT`: SMTP port (default: 587)
- `SMTP_LOGIN`: SMTP username
- `SMTP_PASSWORD`: SMTP password
- `SMTP_FROM_ADDRESS`: From address

**Cloudflare R2 (S3-compatible):**
- `S3_ENABLED`: Enable S3 storage (default: true)
- `S3_BUCKET`: R2 bucket name
- `AWS_ACCESS_KEY_ID`: R2 access key
- `AWS_SECRET_ACCESS_KEY`: R2 secret key
- `S3_ENDPOINT`: R2 endpoint URL
- `S3_ALIAS_HOST`: CDN hostname (files.twist3dkinkst3r.com)

### Networking

- **mastodon-network**: Internal network for service communication
- **traefik-network**: External network for Traefik routing

### Storage

- `./data/postgres`: PostgreSQL database files
- `./data/redis`: Redis data
- `./data/config`: Mastodon configuration and uploads
- **Cloudflare R2**: Media files (if enabled)

## Traefik Integration

Mastodon is automatically configured with Traefik:

- SSL certificates via Let's Encrypt
- Automatic HTTP to HTTPS redirect
- Security headers middleware
- Accessible via `twist3dkinkst3r.com`

## Management

### Start Services
```bash
docker compose up -d
```

### Stop Services
```bash
docker compose down
```

### View Logs
```bash
# All services
docker compose logs -f

# Web service only
docker compose logs -f mastodon-web

# Sidekiq only
docker compose logs -f mastodon-sidekiq

# Database only
docker compose logs -f mastodon-db
```

### Restart Services
```bash
docker compose restart
```

### Run Database Migrations
```bash
docker compose exec mastodon-web rails db:migrate
```

### Create Admin User
```bash
docker compose exec mastodon-web bin/tootctl accounts create <username> \
  --email <email> \
  --confirmed \
  --role admin
```

### Reset Admin Password
```bash
docker compose exec mastodon-web bin/tootctl accounts modify <username> \
  --reset-password
```

## Backup

### Database Backup
```bash
docker compose exec mastodon-db pg_dump -U mastodon mastodon > backup_$(date +%Y%m%d).sql
```

### Restore Database
```bash
docker compose exec -T mastodon-db psql -U mastodon mastodon < backup_YYYYMMDD.sql
```

### Config Backup
```bash
tar -czf mastodon_config_backup_$(date +%Y%m%d).tar.gz ./data/config
```

## Maintenance

### Updates
```bash
cd /root/infra/mastadon
docker compose pull
docker compose up -d
docker compose exec mastodon-web rails db:migrate
```

### Precompile Assets
```bash
docker compose exec mastodon-web rails assets:precompile
```

### Clear Cache
```bash
docker compose exec mastodon-web rails cache:clear
```

### Run Maintenance Tasks
```bash
# Remove old media
docker compose exec mastodon-web bin/tootctl media remove --days 7

# Remove old statuses
docker compose exec mastodon-web bin/tootctl statuses remove --days 30

# Refresh counters
docker compose exec mastodon-web bin/tootctl accounts refresh
```

## Troubleshooting

### Check Service Status
```bash
docker compose ps
```

### Database Connection Issues
```bash
# Test database connection
docker compose exec mastodon-db psql -U mastodon -d mastodon -c "SELECT 1;"
```

### Redis Connection Issues
```bash
# Test Redis connection
docker compose exec mastodon-redis redis-cli ping
```

### View Application Logs
```bash
docker compose logs mastodon-web --tail=100
```

### Check Rails Console
```bash
docker compose exec mastodon-web rails console
```

### Common Issues

1. **Database Migration Errors**:
   ```bash
   docker compose exec mastodon-web rails db:migrate:status
   docker compose exec mastodon-web rails db:migrate
   ```

2. **SMTP Issues**:
   - Verify SMTP credentials in `.env`
   - Test SMTP connection
   - Check firewall rules

3. **File Upload Issues**:
   - Verify Cloudflare R2 bucket exists
   - Check R2 credentials
   - Verify S3_ENDPOINT is correct

4. **Traefik Routing Issues**:
   - Check Traefik logs: `docker compose logs traefik`
   - Verify container is on traefik-network
   - Check Traefik dashboard: http://localhost:8080

## Vault Integration

Cloudflare R2 credentials can be stored in HashiCorp Vault:

```bash
# Get credentials from Vault
./get-vault-secrets.sh

# Or manually
export VAULT_ADDR=http://vault:8200
export VAULT_TOKEN=your_token
vault kv get secret/cloudflare/r2
```

## Security Notes

- **Change default passwords** in `.env`
- **Generate strong secrets** using `./generate-secrets.sh`
- **Use Cloudflare R2** for media storage (recommended)
- **Configure firewall** to restrict access
- **Keep services updated** regularly
- **Monitor logs** for suspicious activity
- **Use Vault** for sensitive credentials

## Performance Tuning

- Adjust `SIDEKIQ_THREADS` based on server resources
- Adjust `DB_POOL` to match database connections
- Enable Elasticsearch for better search (set `ES_ENABLED=true`)
- Use Cloudflare R2 CDN for media delivery
- Monitor resource usage and scale accordingly

## Domain Configuration

1. Point `twist3dkinkst3r.com` DNS A record to your server IP
2. Point `files.twist3dkinkst3r.com` DNS CNAME to your Cloudflare R2 bucket (if using)
3. Wait for DNS propagation
4. Traefik will automatically obtain SSL certificate from Let's Encrypt
5. Access Mastodon at `https://twist3dkinkst3r.com`

## Additional Resources

- [Mastodon Documentation](https://docs.joinmastodon.org/)
- [Mastodon GitHub](https://github.com/mastodon/mastodon)
- [LinuxServer.io Mastodon Image](https://hub.docker.com/r/lscr.io/linuxserver/mastodon)

---

**Last Updated:** 2025-11-20
