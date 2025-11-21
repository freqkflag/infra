# Disaster Recovery Procedures

Comprehensive disaster recovery plan for infrastructure services.

## Recovery Objectives

- **RTO (Recovery Time Objective):** 4 hours
- **RPO (Recovery Point Objective):** 24 hours (daily backups)

## Backup Strategy

### Daily Backups

- All databases (PostgreSQL, MySQL)
- Retention: 30 days
- Location: `/root/infra/backup/data/daily/`

### Weekly Backups

- Critical data volumes
- Retention: 12 weeks
- Location: `/root/infra/backup/data/weekly/`

### Backup Verification

```bash
# List backups
ls -lh /root/infra/backup/data/daily/
ls -lh /root/infra/backup/data/weekly/

# Verify backup integrity
gunzip -t <backup-file>.gz
```

## Recovery Procedures

### Full Infrastructure Recovery

#### 1. Prerequisites

- Fresh server with Docker installed
- Access to backup storage
- All service `.env` files
- SSL certificates (or Let's Encrypt access)

#### 2. Restore Process

```bash
# 1. Clone infrastructure
git clone <repo-url> /root/infra
cd /root/infra

# 2. Restore Traefik first
cd traefik
docker compose up -d

# 3. Restore Vault
cd ../vault
# Restore Vault data from backup
tar -xzf <vault-backup>.tar.gz -C ./data/
docker compose up -d

# 4. Restore databases
# See database-specific restore procedures below

# 5. Restore services
cd ../<service-name>
docker compose up -d

# 6. Verify services
docker ps
curl -I https://<service-domain>
```

### Database Recovery

#### PostgreSQL

```bash
# 1. Stop service
cd /root/infra/<service>
docker compose stop <service>

# 2. Restore database
gunzip <backup-file>.dump.gz
docker exec -i <db-container> pg_restore \
  -U <user> -d <database> --clean --if-exists < <backup-file>.dump

# 3. Verify
docker exec -it <db-container> psql -U <user> -d <database> -c "\dt"

# 4. Restart service
docker compose start <service>
```

#### MySQL

```bash
# 1. Stop service
cd /root/infra/<service>
docker compose stop <service>

# 2. Restore database
gunzip <backup-file>.sql.gz
docker exec -i <db-container> mysql -u <user> -p <database> < <backup-file>.sql

# 3. Verify
docker exec -it <db-container> mysql -u <user> -p <database> -e "SHOW TABLES;"

# 4. Restart service
docker compose start <service>
```

### Volume Recovery

```bash
# 1. Stop service
cd /root/infra/<service>
docker compose down

# 2. Restore volume
tar -xzf <volume-backup>.tar.gz -C ./

# 3. Verify data
ls -la ./data/

# 4. Start service
docker compose up -d
```

## Service-Specific Recovery

### Traefik

**Critical:** Must be restored first

```bash
cd /root/infra/traefik
docker compose up -d
# Verify: curl http://localhost:8080/ping
```

### Vault

**Critical:** Required for secrets

```bash
cd /root/infra/vault
# Restore data directory
tar -xzf vault_volume_<date>.tar.gz -C ./
docker compose up -d
# Verify unseal if in production mode
```

### Databases

Restore in order:
1. PostgreSQL databases
2. MySQL databases
3. Redis (if needed)

### Applications

Restore after databases:
1. WikiJS
2. WordPress
3. LinkStack
4. n8n
5. Mastodon
6. Other services

## Partial Recovery Scenarios

### Single Service Failure

1. Identify failed service
2. Check service logs
3. Restore from most recent backup
4. Verify service health
5. Monitor for stability

### Database Corruption

1. Stop affected service
2. Restore database from backup
3. Verify data integrity
4. Restart service
5. Monitor for issues

### Data Loss

1. Stop service immediately
2. Assess scope of loss
3. Restore from backup
4. Verify data completeness
5. Resume service

## Testing Recovery Procedures

### Quarterly DR Tests

1. **Test Backup Restoration**
   - Restore one service to test environment
   - Verify data integrity
   - Document results

2. **Test Full Recovery**
   - Simulate complete failure
   - Execute full recovery procedure
   - Measure recovery time
   - Document improvements

3. **Test Backup Integrity**
   - Verify backup files
   - Test restore process
   - Validate data

## Recovery Contacts

- **Primary:** Infrastructure maintainer
- **Backup:** Secondary administrator
- **Emergency:** Hosting provider support

## Recovery Checklist

### Pre-Recovery

- [ ] Assess scope of disaster
- [ ] Identify affected services
- [ ] Locate latest backups
- [ ] Prepare recovery environment
- [ ] Notify stakeholders

### During Recovery

- [ ] Restore Traefik
- [ ] Restore Vault
- [ ] Restore databases
- [ ] Restore volumes
- [ ] Restore services
- [ ] Verify each service

### Post-Recovery

- [ ] Verify all services operational
- [ ] Test critical functionality
- [ ] Monitor for 24 hours
- [ ] Document recovery process
- [ ] Conduct post-mortem
- [ ] Update procedures if needed

## Prevention

### Regular Backups

- Automated daily backups
- Weekly volume backups
- Verify backup integrity
- Test restore procedures

### Monitoring

- Health checks on all services
- Alert on service failures
- Monitor disk space
- Track backup success

### Documentation

- Keep procedures updated
- Document all changes
- Maintain runbooks
- Regular DR drills

## Recovery Time Estimates

| Service | Recovery Time | Dependencies |
|---------|--------------|--------------|
| Traefik | 5 minutes | None |
| Vault | 10 minutes | None |
| Database | 15-30 minutes | None |
| Application | 10-20 minutes | Database |
| Full Infrastructure | 2-4 hours | All services |

## Notes

- Always test backups before relying on them
- Keep multiple backup copies
- Document all recovery actions
- Learn from each incident
- Continuously improve procedures

