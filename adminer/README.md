# Adminer Database Management

Lightweight web-based database management tool.

**Location:** `/root/infra/adminer/`

**URL:** `adminer.freqkflag.co`

## Overview

Adminer is a single-file PHP application for managing databases. It supports:
- **PostgreSQL**
- **MySQL/MariaDB**
- **SQLite**
- **MS SQL**
- **Oracle**
- **MongoDB** (via plugin)

## Quick Start

1. **Deploy:**
   ```bash
   cd /root/infra/adminer
   docker compose up -d
   ```

2. **Access Adminer:**
   - Visit `https://adminer.freqkflag.co` (once DNS is configured)
   - Enter database connection details
   - Login

## Features

- **Multi-database support**: Connect to various database types
- **Lightweight**: Single container, minimal resources
- **Web-based**: Access from any browser
- **Secure**: HTTPS via Traefik
- **No configuration needed**: Just connect and use

## Usage

### Connecting to Databases

1. **Open Adminer**: Navigate to `https://adminer.freqkflag.co`

2. **Select Database System**: Choose from dropdown (PostgreSQL, MySQL, etc.)

3. **Enter Connection Details**:
   - **Server**: Database hostname or IP
     - For services in infra: Use container name (e.g., `wordpress-db`, `wikijs-db`)
     - For external: Use hostname or IP
   - **Username**: Database username
   - **Password**: Database password
   - **Database**: Database name

4. **Login**: Click "Login"

### Common Connections

**WordPress Database:**
- System: MySQL
- Server: `wordpress-db`
- Username: `wordpress`
- Password: From `/root/infra/wordpress/.env`
- Database: `wordpress`

**WikiJS Database:**
- System: PostgreSQL
- Server: `wikijs-db`
- Username: `wikijs`
- Password: From `/root/infra/wikijs/.env`
- Database: `wiki`

**LinkStack Database:**
- System: MySQL
- Server: `linkstack-db`
- Username: `linkstack`
- Password: From `/root/infra/linkstack/.env`
- Database: `linkstack`

**Mastodon Database:**
- System: PostgreSQL
- Server: `mastodon-db`
- Username: `mastodon`
- Password: From `/root/infra/mastadon/.env`
- Database: `mastodon`

**n8n Database:**
- System: PostgreSQL
- Server: `n8n-db`
- Username: `n8n`
- Password: From `/root/infra/n8n/.env`
- Database: `n8n`

**Supabase Database:**
- System: PostgreSQL
- Server: `supabase-db` (requires Supabase to be running and Adminer on `supabase-network)
- Username: `supabase_admin`
- Password: From `.workspace/.env` (loaded from Infisical `/prod` path)
- Database: `postgres`
- **Note:** Adminer is configured to access Supabase database via `supabase-network` when Supabase is running

### Database Operations

Once connected, you can:
- **Browse tables**: View and edit data
- **Run SQL queries**: Execute custom SQL
- **Import/Export**: Import SQL files or export data
- **Manage structure**: Create/edit tables, indexes, etc.
- **View users**: Manage database users and permissions

## Management

### Start Service
```bash
docker compose up -d
```

### Stop Service
```bash
docker compose down
```

### View Logs
```bash
docker compose logs -f adminer
```

### Restart Service
```bash
docker compose restart
```

## Traefik Integration

Adminer is automatically configured with Traefik:

- SSL certificates via Let's Encrypt
- Automatic HTTP to HTTPS redirect
- Security headers middleware
- Accessible via `adminer.freqkflag.co`

## Security Notes

- **Use HTTPS only**: Access via Traefik (HTTPS)
- **Strong passwords**: Use strong database passwords
- **Network access**: Adminer can only access databases on the same Docker network
- **No persistent storage**: Adminer doesn't store connection details
- **Keep updated**: `docker compose pull && docker compose up -d`

## Troubleshooting

### Can't Connect to Database

1. **Check Database Container**:
   ```bash
   docker ps | grep <database-container>
   ```

2. **Verify Network**:
   - Database must be on same Docker network
   - Use container name as server hostname

3. **Check Credentials**:
   - Verify username and password in service `.env` files
   - Ensure database exists

### Adminer Not Loading

1. **Check Traefik**:
   ```bash
   docker logs traefik | grep adminer
   ```

2. **Verify DNS**:
   - Ensure `adminer.freqkflag.co` points to server IP

3. **Check Container**:
   ```bash
   docker compose ps
   docker compose logs adminer
   ```

## Updates

```bash
cd /root/infra/adminer
docker compose pull
docker compose up -d
```

## Domain Configuration

1. Point `adminer.freqkflag.co` DNS A record to your server IP
2. Wait for DNS propagation
3. Traefik will automatically obtain SSL certificate from Let's Encrypt
4. Access Adminer at `https://adminer.freqkflag.co`

## Additional Resources

- [Adminer Website](https://www.adminer.org/)
- [Adminer GitHub](https://github.com/vrana/adminer)
- [Adminer Documentation](https://www.adminer.org/en/documentation/)

---

**Last Updated:** 2025-11-20

