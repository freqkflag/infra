# Node-RED Infrastructure Configuration

**Last Updated:** 2025-11-22  
**Status:** ✅ Configured as Infrastructure-Only Service

## Configuration Summary

Node-RED has been configured as an **infrastructure-only service** - accessible only within the internal network, not publicly exposed.

### ✅ Access Configuration
- **Public Access:** ❌ Disabled (no Traefik routing)
- **Internal Access:** ✅ Enabled (via `edge` network)
- **Network:** Connected to `edge` network (IP: 172.31.0.9)
- **Port:** 1880 (internal only)
- **Access Method:** Direct container access or via SSH tunnel

### ✅ Authentication
- **Status:** Enabled
- **Username:** `admin` (configurable via `NODERED_USERNAME`)
- **Password Hash:** Stored in Infisical as `NODERED_PASSWORD_HASH`
- **Default Password:** `nodered-infra-2025` (change immediately after first login)

### ✅ Credential Encryption
- **Status:** Enabled
- **Secret:** Stored in Infisical as `NODERED_CREDENTIAL_SECRET`
- **Purpose:** Encrypts flow credentials in storage

### ✅ Infrastructure Integration

#### Global Context Access
Node-RED has access to infrastructure services via global context:

```javascript
// PostgreSQL
const postgres = global.get("postgres");
// Access: host, port, database, user, password

// MySQL/MariaDB
const mysql = global.get("mysql");
// Access: host, port, database, user, password

// Redis
const redis = global.get("redis");
// Access: host, port, password

// Infisical
const infisical = global.get("infisical");
// Access: url, projectId, clientId, clientSecret
```

#### Environment Variables
All infrastructure environment variables are available via `process.env`:
- `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`
- `MARIADB_HOST`, `MARIADB_PORT`, `MARIADB_DATABASE`, `MARIADB_USER`, `MARIADB_PASSWORD`
- `REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD`
- `INFISICAL_*` variables

### ✅ Network Access
- **Connected Networks:**
  - `nodered-network` (internal)
  - `traefik-network` (reverse proxy)
  - `edge` (infrastructure services)
- **Service Access:** Can reach all services on `edge` network (postgres, mariadb, redis, infisical, etc.)

### ✅ Package Manager
- **Status:** Enabled
- **Auto-install:** Enabled
- **Install via UI:** Menu → Manage palette → Install
- **Recommended Packages:**
  - `node-red-node-postgres` - PostgreSQL integration
  - `node-red-node-mysql` - MySQL/MariaDB integration
  - `node-red-contrib-redis` - Redis integration
  - `node-red-dashboard` - Dashboard UI
  - `node-red-contrib-cron-plus` - Scheduled tasks

## Secrets Management

### Infisical Secrets
The following secrets are stored in Infisical `/prod` path:

- `NODERED_USERNAME` - Admin username (default: `admin`)
- `NODERED_PASSWORD_HASH` - bcrypt password hash
- `NODERED_CREDENTIAL_SECRET` - Credential encryption key

**Note:** Secrets are synced to `.workspace/.env` by Infisical Agent every 60 seconds.

### First Login
1. Navigate to https://nodered.freqkflag.co
2. Login with:
   - **Username:** `admin`
   - **Password:** `nodered-infra-2025`
3. **IMPORTANT:** Change password immediately after first login

## Usage Examples

### Connect to PostgreSQL
```javascript
// In Function node
const postgres = global.get("postgres");
// Use postgres.host, postgres.port, etc. to configure PostgreSQL node
```

### Connect to Redis
```javascript
// In Function node
const redis = global.get("redis");
// Use redis.host, redis.port, etc. to configure Redis node
```

### Access Infisical API
```javascript
// In Function node
const infisical = global.get("infisical");
// Use infisical.url, infisical.clientId, etc. for API calls
```

## Configuration Files

- **Settings:** `/root/infra/nodered/data/settings.js`
- **Package.json:** `/root/infra/nodered/data/package.json`
- **Docker Compose:** `/root/infra/nodered/docker-compose.yml`
- **Flows:** `/root/infra/nodered/data/flows.json`

## Next Steps

1. **Change Default Password** - Login and update password hash in Infisical
2. **Install Packages** - Use Manage palette to install database nodes
3. **Create Flows** - Build automation workflows for infrastructure
4. **Backup Flows** - Export flows regularly for backup

## Troubleshooting

### Authentication Not Working
- Check `.workspace/.env` has `NODERED_USERNAME` and `NODERED_PASSWORD_HASH`
- Verify Infisical Agent is running and syncing secrets
- Restart Node-RED: `docker compose restart`

### Can't Access Services
- Verify `edge` network connection: `docker network inspect edge | grep nodered`
- Check service names match (postgres, mariadb, redis)
- Verify environment variables are loaded: `docker exec nodered env | grep POSTGRES`

### Packages Not Installing
- Check Node-RED logs: `docker logs nodered`
- Verify internet connectivity in container
- Try installing via UI: Menu → Manage palette → Install

---

**Configuration Complete:** Node-RED is ready for infrastructure automation workflows.

