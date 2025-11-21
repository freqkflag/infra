# LinkStack Deployment

LinkStack is a link-in-bio platform that allows you to create a customizable landing page with all your important links.

**Location:** `/root/infra/linkstack/`

## Quick Start

1. **Configure Environment:**
   ```bash
   cd /root/infra/linkstack
   nano .env
   ```
   
   Update:
   - `HTTP_SERVER_NAME` and `HTTPS_SERVER_NAME` with your domain
   - `SERVER_ADMIN` with your email
   - Database passwords (change defaults!)
   - Timezone (`TZ`)

2. **Deploy:**
   ```bash
   docker compose up -d
   ```

3. **Access:**
   - Visit `https://your-domain.com` (once DNS is configured)
   - Complete the initial setup wizard

## Architecture

- **LinkStack**: Main application container
- **MySQL 8.0**: Database for storing links and settings
- **Traefik**: Reverse proxy with SSL certificates

## Configuration

### Environment Variables

Key variables in `.env`:

- **Database:**
  - `MYSQL_ROOT_PASSWORD`: MySQL root password
  - `MYSQL_DATABASE`: Database name (default: linkstack)
  - `MYSQL_USER`: Database user
  - `MYSQL_PASSWORD`: Database password

- **Application:**
  - `HTTP_SERVER_NAME`: Domain name for HTTP
  - `HTTPS_SERVER_NAME`: Domain name for HTTPS
  - `SERVER_ADMIN`: Admin email address
  - `TZ`: Timezone (e.g., America/New_York)

- **PHP:**
  - `PHP_MEMORY_LIMIT`: PHP memory limit (default: 256M)
  - `UPLOAD_MAX_FILESIZE`: Max upload size (default: 8M)
  - `LOG_LEVEL`: Logging level (default: info)

### Networking

- **linkstack-network**: Internal network for LinkStack and MySQL communication
- **traefik-network**: External network for Traefik routing

### Storage

- `./data/mysql`: MySQL database files
- `./data/linkstack`: LinkStack application data and uploads

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

# LinkStack only
docker compose logs -f linkstack

# Database only
docker compose logs -f linkstack-db
```

### Restart Services
```bash
docker compose restart
```

### Backup Database
```bash
docker compose exec linkstack-db mysqldump -u linkstack -p${MYSQL_PASSWORD} linkstack > backup_$(date +%Y%m%d).sql
```

### Restore Database
```bash
docker compose exec -T linkstack-db mysql -u linkstack -p${MYSQL_PASSWORD} linkstack < backup_YYYYMMDD.sql
```

## Initial Setup

After starting LinkStack:

1. Navigate to your domain (e.g., `https://links.example.com`)
2. Complete the setup wizard:
   - Create admin account
   - Configure site settings
   - Add your links

## Traefik Integration

LinkStack is automatically configured to work with Traefik:

- SSL certificates via Let's Encrypt
- Automatic HTTP to HTTPS redirect
- Security headers middleware
- Accessible via configured domain

## Troubleshooting

### Check Service Status
```bash
docker compose ps
```

### Database Connection Issues
```bash
# Test database connection
docker compose exec linkstack-db mysql -u linkstack -p${MYSQL_PASSWORD} linkstack -e "SELECT 1;"
```

### View Application Logs
```bash
docker compose logs linkstack --tail=100
```

### Reset Database (⚠️ Destructive)
```bash
docker compose down -v
docker compose up -d
```

## Security Notes

- **Change default passwords** in `.env` before production use
- Ensure `.env` file has proper permissions (600)
- Regularly update the LinkStack image: `docker compose pull`
- Keep database backups

## Updates

To update LinkStack:

```bash
cd /root/infra/linkstack
docker compose pull
docker compose up -d
```

## Domain Configuration

1. Point your domain's DNS A record to your server IP
2. Wait for DNS propagation
3. Traefik will automatically obtain SSL certificate from Let's Encrypt
4. Access LinkStack at `https://your-domain.com`

