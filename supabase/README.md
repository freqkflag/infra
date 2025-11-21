# Supabase Self-Hosted

Self-hosted Supabase instance for backend-as-a-service functionality.

**Location:** `/root/infra/supabase/`

**Studio:** `supabase.freqkflag.co`
**API:** `api.supabase.freqkflag.co`

## Overview

Supabase provides:
- **PostgreSQL Database**: Full-featured PostgreSQL with extensions
- **Studio**: Web-based database management interface
- **REST API**: Auto-generated REST API from database schema
- **Realtime**: Real-time subscriptions (requires additional setup)
- **Auth**: Authentication service (requires additional setup)
- **Storage**: File storage service (requires additional setup)

## Quick Start

1. **Generate Secrets:**
   ```bash
   cd /root/infra/supabase
   
   # Generate JWT secret
   openssl rand -base64 32 >> .env
   # Add: JWT_SECRET=<generated_value>
   
   # Generate password
   openssl rand -base64 24 >> .env
   # Add: POSTGRES_PASSWORD=<generated_value>
   ```

2. **Configure Environment:**
   ```bash
   nano .env
   ```
   
   Update:
   - `POSTGRES_PASSWORD`: Strong database password
   - `JWT_SECRET`: Random secret for JWT tokens
   - `ORG_NAME`: Organization name
   - `PROJECT_NAME`: Project name

3. **Deploy:**
   ```bash
   docker compose up -d
   ```

4. **Access Studio:**
   - Visit `https://supabase.freqkflag.co` (once DNS is configured)
   - Login with database credentials

## Architecture

- **supabase-db**: PostgreSQL 15 database with Supabase extensions
- **supabase-studio**: Web-based database management interface
- **supabase-meta**: Metadata service for database schema
- **supabase-kong**: API Gateway for REST API

## Configuration

### Environment Variables

Key variables in `.env`:

**Database:**
- `POSTGRES_PASSWORD`: PostgreSQL admin password (**change this!**)

**JWT:**
- `JWT_SECRET`: Secret for JWT token generation (**generate random!**)
- `JWT_EXP`: JWT expiration time in seconds (default: 3600)

**Organization:**
- `ORG_NAME`: Organization name
- `PROJECT_NAME`: Project name

**Hosts:**
- `SUPABASE_HOST`: Domain for Supabase (supabase.freqkflag.co)

**Keys** (generated after setup):
- `ANON_KEY`: Anonymous/public API key
- `SERVICE_ROLE_KEY`: Service role API key

### Networking

- **supabase-network**: Internal network for Supabase services
- **traefik-network**: External network for Traefik routing

### Storage

- `./data/postgres`: PostgreSQL database files
- `./data/kong`: Kong API Gateway configuration

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

# Database only
docker compose logs -f supabase-db

# Studio only
docker compose logs -f supabase-studio
```

### Restart Services
```bash
docker compose restart
```

### Backup Database
```bash
docker compose exec supabase-db pg_dump -U supabase_admin postgres > backup_$(date +%Y%m%d).sql
```

### Restore Database
```bash
docker compose exec -T supabase-db psql -U supabase_admin postgres < backup_YYYYMMDD.sql
```

## Traefik Integration

Supabase services are automatically configured with Traefik:

- **Studio**: `https://supabase.freqkflag.co`
- **API**: `https://api.supabase.freqkflag.co`
- SSL certificates via Let's Encrypt
- Security headers middleware

## Usage

### Accessing Studio

1. Navigate to `https://supabase.freqkflag.co`
2. Login with:
   - **Database**: `postgres`
   - **User**: `supabase_admin`
   - **Password**: From `.env` file

### Creating Tables

1. Open Studio
2. Navigate to "Table Editor"
3. Click "New Table"
4. Define columns and constraints
5. Save table

### Using REST API

Once tables are created, Supabase automatically generates REST endpoints:

```
GET    https://api.supabase.freqkflag.co/rest/v1/table_name
POST   https://api.supabase.freqkflag.co/rest/v1/table_name
PATCH  https://api.supabase.freqkflag.co/rest/v1/table_name
DELETE https://api.supabase.freqkflag.co/rest/v1/table_name
```

### API Authentication

Use API keys in headers:
```
apikey: <ANON_KEY or SERVICE_ROLE_KEY>
Authorization: Bearer <JWT_TOKEN>
```

## Troubleshooting

### Check Service Status
```bash
docker compose ps
```

### Database Connection Issues
```bash
# Test database connection
docker compose exec supabase-db psql -U supabase_admin -d postgres -c "SELECT 1;"
```

### View Application Logs
```bash
docker compose logs supabase-studio --tail=100
```

### Common Issues

1. **Studio Not Loading**:
   - Check Traefik routing
   - Verify DNS configuration
   - Review studio logs

2. **API Not Working**:
   - Verify Kong is running
   - Check API endpoint URL
   - Review Kong logs

3. **Database Connection Errors**:
   - Verify database is running
   - Check database credentials
   - Review database logs

## Security Notes

- **Change default passwords** in `.env`
- **Generate strong JWT_SECRET** (use `openssl rand -base64 32`)
- **Use API keys** for authentication
- **Restrict API access** via Kong configuration
- **Keep Supabase updated**: `docker compose pull && docker compose up -d`
- **Monitor logs** for suspicious activity

## Updates

```bash
cd /root/infra/supabase
docker compose pull
docker compose up -d
```

## Domain Configuration

1. Point `supabase.freqkflag.co` DNS A record to your server IP
2. Point `api.supabase.freqkflag.co` DNS A record to your server IP
3. Wait for DNS propagation
4. Traefik will automatically obtain SSL certificates

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase GitHub](https://github.com/supabase/supabase)
- [Supabase Self-Hosting Guide](https://supabase.com/docs/guides/self-hosting)

---

**Note:** This is a basic Supabase setup. For full features (Auth, Storage, Realtime), additional services and configuration are required.

**Last Updated:** 2025-11-20

