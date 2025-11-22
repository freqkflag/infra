# Database Instance Management

**Created:** 2025-11-22  
**Last Updated:** 2025-11-22  
**Status:** Active Documentation

---

## Overview

This document provides a comprehensive inventory of all database instances in the infrastructure, their purposes, versions, network assignments, and service dependencies.

---

## Database Instance Inventory

### PostgreSQL Instances

#### 1. Main PostgreSQL (orchestrator)
- **Container Name:** `postgres-postgres-1` (when using `services/postgres/compose.yml`)
- **Image:** `postgres:16-alpine`
- **Version:** PostgreSQL 16
- **Network:** `edge`
- **Volume:** `postgres_data`
- **Purpose:** Primary PostgreSQL instance for infrastructure services
- **Authentication:** `scram-sha-256`
- **Services Using:**
  - WikiJS
  - n8n
  - Infisical (via connection string)
  - Kong
  - GitLab (shared instance)
  - Backstage (if using shared instance)
- **Compose File:** `services/postgres/compose.yml`
- **Environment Variables:**
  - `POSTGRES_DB` (from `.workspace/.env`)
  - `POSTGRES_USER` (from `.workspace/.env`)
  - `POSTGRES_PASSWORD` (from `.workspace/.env`)
  - `POSTGRES_HOST_AUTH_METHOD: scram-sha-256`

#### 2. Supabase PostgreSQL
- **Container Name:** `supabase-db`
- **Image:** `supabase/postgres:15.1.0.147`
- **Version:** PostgreSQL 15.1.0.147 (with Supabase extensions)
- **Network:** `supabase-network` (isolated)
- **Volume:** `./data/postgres` (relative to `supabase/`)
- **Purpose:** Authoritative database platform for Supabase-based applications
- **Authentication:** `scram-sha-256`
- **Services Using:**
  - Supabase Studio
  - Supabase Meta
  - Supabase Kong (API gateway)
  - Supabase-based applications
- **Compose File:** `supabase/docker-compose.yml`
- **Environment Variables:**
  - `POSTGRES_USER: supabase_admin`
  - `POSTGRES_PASSWORD` (from `.workspace/.env`)
  - `JWT_SECRET` (from `.workspace/.env`)
  - `POSTGRES_HOST_AUTH_METHOD: scram-sha-256`
- **Access:** Via Supabase Studio at `https://supabase.freqkflag.co`

#### 3. Backstage PostgreSQL
- **Container Name:** `backstage-db` (when using `services/backstage/compose.yml`)
- **Image:** `postgres:16-alpine`
- **Version:** PostgreSQL 16
- **Network:** `edge` (or service-specific network)
- **Volume:** `backstage_postgres_data`
- **Purpose:** Dedicated database for Backstage developer portal
- **Authentication:** `scram-sha-256`
- **Services Using:**
  - Backstage (developer portal)
- **Compose File:** `services/backstage/compose.yml`
- **Environment Variables:**
  - `POSTGRES_DB: backstage_plugin_catalog`
  - `POSTGRES_USER: backstage`
  - `POSTGRES_PASSWORD` (from `.workspace/.env` as `BACKSTAGE_DB_PASSWORD`)
  - `POSTGRES_HOST_AUTH_METHOD: scram-sha-256`
- **Note:** Can use shared PostgreSQL instance or dedicated instance

#### 4. Infisical PostgreSQL
- **Container Name:** `infisical-db` (when using `infisical/docker-compose.yml`)
- **Image:** `postgres:15-alpine` (or version specified in compose)
- **Version:** PostgreSQL 15
- **Network:** `edge` (or service-specific network)
- **Volume:** `infisical_postgres_data`
- **Purpose:** Dedicated database for Infisical secrets management
- **Authentication:** `scram-sha-256`
- **Services Using:**
  - Infisical (secrets management)
- **Compose File:** `infisical/docker-compose.yml` (if using dedicated instance)
- **Note:** Infisical can use shared PostgreSQL instance via connection string (`INFISICAL_DB_CONNECTION`)

### MySQL/MariaDB Instances

#### 1. Main MariaDB (orchestrator)
- **Container Name:** `mariadb-mariadb-1` (when using `services/mariadb/compose.yml`)
- **Image:** `mariadb:latest` (or version specified)
- **Version:** MariaDB 10.x or MySQL 8.0
- **Network:** `edge`
- **Volume:** `mariadb_data`
- **Purpose:** Primary MySQL/MariaDB instance for infrastructure services
- **Services Using:**
  - WordPress
  - LinkStack
  - Ghost (if using MySQL)
- **Compose File:** `services/mariadb/compose.yml`
- **Environment Variables:**
  - `MARIADB_ROOT_PASSWORD` (from `.workspace/.env`)
  - `MARIADB_DATABASE` (from `.workspace/.env`)
  - `MARIADB_USER` (from `.workspace/.env`)
  - `MARIADB_PASSWORD` (from `.workspace/.env`)

### Redis Instances

#### 1. Main Redis (orchestrator)
- **Container Name:** `redis-redis-1` (when using `services/redis/compose.yml`)
- **Image:** `redis:alpine` (or version specified)
- **Version:** Redis 7.x
- **Network:** `edge`
- **Volume:** `redis_data`
- **Purpose:** Primary Redis instance for caching and session storage
- **Services Using:**
  - Infisical (session storage)
  - GitLab (cache/queue)
  - n8n (optional caching)
  - Other services requiring Redis
- **Compose File:** `services/redis/compose.yml`
- **Environment Variables:**
  - `REDIS_PASSWORD` (from `.workspace/.env`, if authentication enabled)

---

## Service-to-Database Mappings

### Services Using PostgreSQL

| Service | Database Instance | Connection Method | Notes |
|---------|------------------|-------------------|-------|
| WikiJS | Main PostgreSQL | Container name: `postgres` | Uses `WIKIJS_DB_HOST=postgres` |
| n8n | Main PostgreSQL | Container name: `postgres` | Uses `DB_POSTGRESDB_HOST=postgres` |
| Infisical | Main PostgreSQL (or dedicated) | Connection string: `INFISICAL_DB_CONNECTION` | Can use shared or dedicated instance |
| Kong | Main PostgreSQL | Container name: `postgres` | Uses `KONG_DATABASE=postgres` |
| GitLab | Main PostgreSQL | Container name: `postgres` | Uses `GITLAB_DB_HOST=postgres` |
| Backstage | Backstage PostgreSQL (or main) | Container name: `backstage-db` or `postgres` | Can use shared or dedicated instance |
| Supabase Studio | Supabase PostgreSQL | Container name: `supabase-db` | Isolated network: `supabase-network` |
| Supabase Meta | Supabase PostgreSQL | Container name: `supabase-db` | Isolated network: `supabase-network` |

### Services Using MySQL/MariaDB

| Service | Database Instance | Connection Method | Notes |
|---------|------------------|-------------------|-------|
| WordPress | Main MariaDB | Container name: `mariadb` | Uses `WORDPRESS_DB_HOST=mariadb` |
| LinkStack | Main MariaDB | Container name: `mariadb` | Uses `DB_HOST=${MARIADB_HOST}` |
| Ghost | Main MariaDB | Container name: `mariadb` | Uses `database__connection__host=${MARIADB_HOST}` |

### Services Using Redis

| Service | Database Instance | Connection Method | Notes |
|---------|------------------|-------------------|-------|
| Infisical | Main Redis | Connection string: `INFISICAL_REDIS_URL` | Uses `redis://redis:6379` |
| GitLab | Main Redis | Container name: `redis` | Uses `GITLAB_REDIS_HOST=redis` |

---

## Database Naming Conventions

### Standard Naming Pattern
- **Orchestrator Services:** `<service>-<service>-1` (e.g., `postgres-postgres-1`)
- **Service-Level Services:** `<service>-<dbtype>-1` (e.g., `backstage-db-1`)
- **Dedicated Instances:** `<service>-db` (e.g., `supabase-db`, `infisical-db`)

### Best Practices
1. **Use explicit container names** when multiple instances exist
2. **Document service-to-database mappings** in service README files
3. **Use consistent network assignments** (prefer `edge` network for shared instances)
4. **Isolate sensitive databases** (e.g., Supabase uses `supabase-network`)
5. **Version consistency:** Use same PostgreSQL version across shared instances

---

## Database Instance Management

### Audit Script
Use `scripts/audit-database-instances.sh` to:
- List all database containers
- Show version information
- Display network assignments
- Identify orphaned instances
- Verify service connections

### Connection Verification
```bash
# Test PostgreSQL connection
docker exec <container-name> psql -U <user> -d <database> -c 'SELECT version();'

# Test MySQL/MariaDB connection
docker exec <container-name> mysql -u <user> -p<password> -e 'SELECT VERSION();'

# Test Redis connection
docker exec <container-name> redis-cli -a <password> PING
```

### Service Discovery
When deploying new services:
1. Check existing database instances using audit script
2. Determine if shared or dedicated instance is appropriate
3. Use explicit container names in service configuration
4. Verify network connectivity before deployment
5. Test database connections during health checks

---

## Orphaned Instance Detection

### Criteria for Orphaned Instances
- Container exists but no services reference it
- Container not part of any active compose file
- Container not listed in service-to-database mappings
- Container version mismatches with service requirements

### Cleanup Procedure
1. Identify orphaned instances using audit script
2. Verify no services depend on the instance
3. Backup data if needed
4. Remove container: `docker rm -f <container-name>`
5. Remove volume if not needed: `docker volume rm <volume-name>`
6. Update documentation

---

## Version Management

### PostgreSQL Versions
- **Main Instance:** PostgreSQL 16 (latest stable)
- **Supabase:** PostgreSQL 15.1.0.147 (with Supabase extensions)
- **Legacy Services:** PostgreSQL 14 or 15 (if required)

### MySQL/MariaDB Versions
- **Main Instance:** MariaDB 10.x or MySQL 8.0 (latest stable)

### Redis Versions
- **Main Instance:** Redis 7.x (latest stable)

### Upgrade Procedures
1. Review service compatibility requirements
2. Test upgrades in staging environment
3. Backup all databases before upgrade
4. Coordinate service restarts
5. Verify service health after upgrade
6. Update documentation

---

## Network Isolation

### Shared Network (`edge`)
- Main PostgreSQL, MariaDB, Redis instances
- Most application services
- Allows service-to-service communication

### Isolated Networks
- **`supabase-network`:** Supabase services (database, studio, meta, kong)
- **Service-specific networks:** For services requiring isolation

### Network Best Practices
1. Use `edge` network for shared infrastructure databases
2. Use isolated networks for sensitive or multi-tenant databases
3. Document network assignments in service configurations
4. Verify network connectivity in health checks

---

## Access and Management

### Authoritative Management Tools

#### Adminer
- **URL:** `https://adminer.freqkflag.co`
- **Purpose:** Web-based database administration for all infrastructure databases
- **Supports:** PostgreSQL, MySQL, MariaDB, SQLite
- **Authentication:** Uses credentials from `.workspace/.env`
- **Connection:** Use container names as server hostnames

#### Supabase Studio
- **URL:** `https://supabase.freqkflag.co`
- **Purpose:** Database management for Supabase instance
- **Supports:** PostgreSQL with Supabase extensions
- **Authentication:** Uses Supabase admin credentials

### CLI Access
```bash
# PostgreSQL
docker exec -it <container-name> psql -U <user> -d <database>

# MySQL/MariaDB
docker exec -it <container-name> mysql -u <user> -p

# Redis
docker exec -it <container-name> redis-cli -a <password>
```

---

## Backup and Recovery

### Backup Procedures
- **Automated Backups:** Configured via backup scripts
- **Manual Backups:** Use `docker exec` to export databases
- **Volume Backups:** Backup Docker volumes directly

### Recovery Procedures
1. Stop affected services
2. Restore database from backup
3. Verify data integrity
4. Restart services
5. Verify service health

---

## Security Considerations

### Authentication
- **PostgreSQL:** `scram-sha-256` authentication enforced
- **MySQL/MariaDB:** Root password required
- **Redis:** Password authentication (if enabled)

### Network Security
- Isolated networks for sensitive databases
- Firewall rules for external access
- VPN or SSH tunneling for remote access

### Credential Management
- All database passwords stored in Infisical `/prod` path
- Credentials loaded via `.workspace/.env` (generated by Infisical Agent)
- No hardcoded credentials in compose files

---

## Monitoring and Health Checks

### Health Check Standards
- **PostgreSQL:** `pg_isready -U <user> -d <database>`
- **MySQL/MariaDB:** `mysqladmin ping -u <user> -p<password>`
- **Redis:** `redis-cli PING`

### Monitoring Tools
- **Prometheus:** Database metrics via exporters
- **Grafana:** Database performance dashboards
- **Alertmanager:** Database health alerts

---

## References

- **Main Documentation:** `AGENTS.md` - Service overview and database dependencies
- **Remediation Plan:** `REMEDIATION_PLAN.md` - Phase 1.5 database instance management
- **Compose Standards:** `infra-build-plan.md` - Compose file standards and patterns
- **Service Documentation:** Individual service README files

---

**Last Updated:** 2025-11-22  
**Maintained By:** Infrastructure Team / DevOps Team

