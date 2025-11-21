# WordPress Deployment

WordPress is a popular content management system (CMS) for building websites and blogs.

**Location:** `/root/infra/wordpress/`

**Domain:** `cultofjoey.com`

## Quick Start

1. **Configure Environment:**
   ```bash
   cd /root/infra/wordpress
   nano .env
   ```
   
   Update the database passwords (change the defaults!)

2. **Deploy:**
   ```bash
   docker compose up -d
   ```

3. **Initial Setup:**
   - Visit `https://cultofjoey.com` (once DNS is configured)
   - Complete the WordPress installation wizard:
     - Select language
     - Create admin account
     - Configure site settings

## Architecture

- **WordPress**: Main application container (PHP/Apache)
- **MySQL 8.0**: Database for storing content, settings, and users
- **Traefik**: Reverse proxy with SSL certificates

## Configuration

### Environment Variables

Key variables in `.env`:

- **Database:**
  - `MYSQL_ROOT_PASSWORD`: MySQL root password (**change this!**)
  - `MYSQL_DATABASE`: Database name (default: wordpress)
  - `MYSQL_USER`: Database user (default: wordpress)
  - `MYSQL_PASSWORD`: Database password (**change this!**)

- **WordPress:**
  - `WORDPRESS_TABLE_PREFIX`: Database table prefix (default: wp_)
  - `WORDPRESS_DEBUG`: Debug mode (0 = off, 1 = on)
  - `TZ`: Timezone (default: America/New_York)

### Networking

- **wordpress-network**: Internal network for WordPress and MySQL communication
- **traefik-network**: External network for Traefik routing

### Storage

- `./data/mysql`: MySQL database files
- `./data/wordpress`: WordPress files, themes, plugins, and uploads

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

# WordPress only
docker compose logs -f wordpress

# Database only
docker compose logs -f wordpress-db
```

### Restart Services
```bash
docker compose restart
```

### Backup Database
```bash
docker compose exec wordpress-db mysqldump -u wordpress -p${MYSQL_PASSWORD} wordpress > backup_$(date +%Y%m%d).sql
```

### Restore Database
```bash
docker compose exec -T wordpress-db mysql -u wordpress -p${MYSQL_PASSWORD} wordpress < backup_YYYYMMDD.sql
```

### Backup WordPress Files
```bash
# Backup the entire WordPress directory
tar -czf wordpress_backup_$(date +%Y%m%d).tar.gz ./data/wordpress
```

### Full Backup (Database + Files)
```bash
# Database
docker compose exec wordpress-db mysqldump -u wordpress -p${MYSQL_PASSWORD} wordpress > wordpress_db_$(date +%Y%m%d).sql

# Files
tar -czf wordpress_files_$(date +%Y%m%d).tar.gz ./data/wordpress
```

## Initial Setup

After starting WordPress:

1. Navigate to `https://cultofjoey.com`
2. Complete the WordPress installation:
   - Select language
   - Enter site title and admin credentials
   - Configure email settings
   - Install WordPress

## Traefik Integration

WordPress is automatically configured to work with Traefik:

- SSL certificates via Let's Encrypt
- Automatic HTTP to HTTPS redirect
- Security headers middleware
- Accessible via `cultofjoey.com`

## WordPress Configuration

### Update WordPress URL

If you need to update the WordPress URL after installation:

1. Access WordPress admin: `https://cultofjoey.com/wp-admin`
2. Go to Settings → General
3. Update "WordPress Address (URL)" and "Site Address (URL)"
4. Or use WP-CLI:
   ```bash
   docker compose exec wordpress wp option update home 'https://cultofjoey.com' --allow-root
   docker compose exec wordpress wp option update siteurl 'https://cultofjoey.com' --allow-root
   ```

### WP-CLI Usage

WordPress includes WP-CLI for command-line management:

```bash
# List plugins
docker compose exec wordpress wp plugin list --allow-root

# Install a plugin
docker compose exec wordpress wp plugin install plugin-name --activate --allow-root

# Update WordPress core
docker compose exec wordpress wp core update --allow-root

# Update all plugins
docker compose exec wordpress wp plugin update --all --allow-root

# Update all themes
docker compose exec wordpress wp theme update --all --allow-root
```

## Troubleshooting

### Check Service Status
```bash
docker compose ps
```

### Database Connection Issues
```bash
# Test database connection
docker compose exec wordpress-db mysql -u wordpress -p${MYSQL_PASSWORD} wordpress -e "SELECT 1;"
```

### View Application Logs
```bash
docker compose logs wordpress --tail=100
```

### Reset Database (⚠️ Destructive)
```bash
docker compose down -v
docker compose up -d
```

### Fix File Permissions
```bash
docker compose exec wordpress chown -R www-data:www-data /var/www/html
docker compose exec wordpress chmod -R 755 /var/www/html
```

### Enable Debug Mode
Edit `.env`:
```
WORDPRESS_DEBUG=1
```
Then restart:
```bash
docker compose restart wordpress
```

## Security Notes

- **Change default passwords** in `.env` before production use
- Ensure `.env` file has proper permissions (600)
- Regularly update WordPress, themes, and plugins
- Keep database backups
- Use strong admin passwords
- Consider security plugins (Wordfence, Sucuri, etc.)
- Limit login attempts
- Use two-factor authentication

## Updates

To update WordPress:

```bash
cd /root/infra/wordpress
docker compose pull
docker compose up -d

# Update WordPress core via WP-CLI
docker compose exec wordpress wp core update --allow-root

# Update all plugins
docker compose exec wordpress wp plugin update --all --allow-root
```

## Performance Tips

- Install caching plugins (WP Super Cache, W3 Total Cache)
- Use a CDN for static assets
- Optimize images before uploading
- Use a lightweight theme
- Enable object caching (Redis/Memcached)
- Monitor database size and optimize regularly

## Domain Configuration

1. Point `cultofjoey.com` DNS A record to your server IP
2. Point `www.cultofjoey.com` DNS A record to your server IP (optional)
3. Wait for DNS propagation
4. Traefik will automatically obtain SSL certificate from Let's Encrypt
5. Access WordPress at `https://cultofjoey.com`

## Adding www Subdomain (Optional)

If you want to support both `cultofjoey.com` and `www.cultofjoey.com`:

1. Add another router label to `docker-compose.yml`:
   ```yaml
   labels:
     - "traefik.http.routers.wordpress-www.rule=Host(`www.cultofjoey.com`)"
     - "traefik.http.routers.wordpress-www.entrypoints=websecure"
     - "traefik.http.routers.wordpress-www.tls.certresolver=letsencrypt"
     - "traefik.http.routers.wordpress-www.service=wordpress"
   ```

2. Configure WordPress to handle both domains in Settings → General

