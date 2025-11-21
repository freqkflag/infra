# n8n Workflow Automation

n8n is a workflow automation tool that allows you to connect different services and automate tasks.

**Location:** `/root/infra/n8n/`

**Domain:** `n8n.freqkflag.co`

## Overview

n8n is a self-hosted workflow automation platform similar to Zapier or Make.com. It allows you to:
- Automate workflows between different services
- Create complex automation chains
- Integrate APIs and webhooks
- Schedule recurring tasks
- Process and transform data

## Quick Start

1. **Configure Environment:**
   ```bash
   cd /root/infra/n8n
   nano .env
   ```
   
   Update:
   - Database password
   - Admin username and password
   - Other settings as needed

2. **Deploy:**
   ```bash
   docker compose up -d
   ```

3. **Access n8n:**
   - Visit `https://n8n.freqkflag.co` (once DNS is configured)
   - Login with credentials from `.env`

## Architecture

- **n8n**: Main application (Node.js)
- **PostgreSQL 15**: Database for storing workflows and execution data
- **Traefik**: Reverse proxy with SSL certificates

## Configuration

### Environment Variables

Key variables in `.env`:

**Database:**
- `POSTGRES_DB`: Database name (default: n8n)
- `POSTGRES_USER`: Database user (default: n8n)
- `POSTGRES_PASSWORD`: Database password (**change this!**)

**Authentication:**
- `N8N_USER`: Admin username (default: admin)
- `N8N_PASSWORD`: Admin password (**change this!**)

**Application:**
- `N8N_HOST`: Domain name (n8n.freqkflag.co)
- `TZ`: Timezone (default: America/New_York)
- `LOG_LEVEL`: Logging level (info, debug, etc.)

**Execution Data:**
- `EXECUTIONS_DATA_MAX_AGE`: Retention period in hours (default: 168 = 7 days)

### Networking

- **n8n-network**: Internal network for n8n and PostgreSQL communication
- **traefik-network**: External network for Traefik routing

### Storage

- `./data/n8n`: n8n workflows, credentials, and configuration
- `./data/postgres`: PostgreSQL database files

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

# n8n only
docker compose logs -f n8n

# Database only
docker compose logs -f n8n-db
```

### Restart Services
```bash
docker compose restart
```

### Backup

**Backup Database:**
```bash
docker compose exec n8n-db pg_dump -U n8n n8n > backup_$(date +%Y%m%d).sql
```

**Backup Workflows:**
```bash
# Export workflows from n8n UI or backup data directory
tar -czf n8n_backup_$(date +%Y%m%d).tar.gz ./data/n8n
```

**Full Backup:**
```bash
# Database
docker compose exec n8n-db pg_dump -U n8n n8n > n8n_db_$(date +%Y%m%d).sql

# Data directory
tar -czf n8n_data_$(date +%Y%m%d).tar.gz ./data/n8n
```

## Traefik Integration

n8n is automatically configured with Traefik:

- SSL certificates via Let's Encrypt
- Automatic HTTP to HTTPS redirect
- Security headers middleware
- Accessible via `n8n.freqkflag.co`

## Usage

### Creating Workflows

1. Log into n8n at `https://n8n.freqkflag.co`
2. Click "New Workflow"
3. Add nodes and connect them
4. Configure each node
5. Test and activate the workflow

### Common Use Cases

- **API Integrations**: Connect different APIs together
- **Data Processing**: Transform and process data between services
- **Scheduled Tasks**: Run workflows on a schedule (cron)
- **Webhooks**: Trigger workflows via HTTP requests
- **Email Automation**: Send emails based on triggers
- **Database Operations**: Read/write to databases
- **File Operations**: Process files and uploads

### Example Workflows

**Simple Webhook to Email:**
1. Webhook node (receives data)
2. Email node (sends email via SMTP)

**Scheduled Data Sync:**
1. Cron node (runs daily)
2. HTTP Request node (fetches data)
3. Database node (saves data)

**API to Database:**
1. HTTP Request node (API call)
2. Function node (transform data)
3. PostgreSQL node (save to database)

## Integration with Infrastructure Services

### Connect to Vault
Use HTTP Request node to call Vault API:
- URL: `http://vault:8200/v1/secret/data/path`
- Headers: `X-Vault-Token: your_token`

### Connect to Mailu
Use SMTP node with Mailu settings:
- Host: `mail.freqkflag.co`
- Port: `587`
- User: `noreply@freqkflag.co`
- Password: Mailu mailbox password

### Connect to Mastodon
Use HTTP Request node for Mastodon API:
- Base URL: `https://twist3dkinkst3r.com/api/v1`
- Authentication: Bearer token

### Webhook Endpoints

n8n provides webhook URLs for triggering workflows:
- Format: `https://n8n.freqkflag.co/webhook/<workflow-id>`
- Use in other services to trigger n8n workflows

## Troubleshooting

### Check Service Status
```bash
docker compose ps
```

### Database Connection Issues
```bash
# Test database connection
docker compose exec n8n-db psql -U n8n -d n8n -c "SELECT 1;"
```

### View Application Logs
```bash
docker compose logs n8n --tail=100
```

### Reset Admin Password
```bash
# Stop n8n
docker compose stop n8n

# Run password reset
docker compose run --rm n8n n8n user:reset --email=admin@example.com

# Start n8n
docker compose start n8n
```

### Common Issues

1. **Workflows Not Executing**:
   - Check workflow is activated
   - Verify cron schedule (if scheduled)
   - Check execution logs in n8n UI

2. **Database Connection Errors**:
   - Verify database is running: `docker compose ps n8n-db`
   - Check database credentials in `.env`
   - Review database logs

3. **Webhook Not Receiving Data**:
   - Verify webhook URL is correct
   - Check Traefik routing
   - Review n8n logs for incoming requests

## Security Notes

- **Change default passwords** in `.env` before production use
- **Use strong passwords** for admin account
- **Enable 2FA** in n8n settings (recommended)
- **Restrict access** via firewall if possible
- **Keep n8n updated**: `docker compose pull && docker compose up -d`
- **Review workflow credentials** regularly
- **Monitor execution logs** for suspicious activity

## Updates

```bash
cd /root/infra/n8n
docker compose pull
docker compose up -d
```

**Note:** n8n will automatically run migrations on startup if needed.

## Performance Tuning

- **Execution Data Retention**: Adjust `EXECUTIONS_DATA_MAX_AGE` to control database size
- **Database Optimization**: Regularly clean old execution data
- **Resource Limits**: Set Docker resource limits if needed
- **Concurrent Executions**: Configure in n8n settings based on server resources

## Domain Configuration

1. Point `n8n.freqkflag.co` DNS A record to your server IP
2. Wait for DNS propagation
3. Traefik will automatically obtain SSL certificate from Let's Encrypt
4. Access n8n at `https://n8n.freqkflag.co`

## Additional Resources

- [n8n Documentation](https://docs.n8n.io/)
- [n8n GitHub](https://github.com/n8n-io/n8n)
- [n8n Community Forum](https://community.n8n.io/)
- [n8n Workflow Templates](https://n8n.io/workflows/)

---

**Last Updated:** 2025-11-20

