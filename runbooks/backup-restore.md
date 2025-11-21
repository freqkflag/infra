# Backup and Restore Procedures

Detailed procedures for backing up and restoring infrastructure data.

## Backup Overview

- **Frequency:** Daily (databases), Weekly (volumes)
- **Location:** `/root/infra/backup/data/`
- **Retention:** 30 days daily, 12 weeks weekly
- **Format:** Compressed dumps

## Manual Backup

### Run Backup

```bash
cd /root/infra/backup
docker compose run --rm backup
```

### Verify Backup

```bash
# List backups
ls -lh /root/infra/backup/data/daily/
ls -lh /root/infra/backup/data/weekly/

# Check backup integrity
gunzip -t <backup-file>.gz
```

## Restore Procedures

### PostgreSQL Database

```bash
# 1. Stop service
cd /root/infra/<service>
docker compose stop <app-service>

# 2. Extract backup
gunzip <backup-file>.dump.gz

# 3. Restore
docker exec -i <db-container> pg_restore \
  -U <user> -d <database> --clean --if-exists < <backup-file>.dump

# 4. Verify
docker exec -it <db-container> psql -U <user> -d <database> -c "\dt"

# 5. Start service
docker compose start <app-service>
```

### MySQL Database

```bash
# 1. Stop service
cd /root/infra/<service>
docker compose stop <app-service>

# 2. Extract backup
gunzip <backup-file>.sql.gz

# 3. Restore
docker exec -i <db-container> mysql -u <user> -p <database> < <backup-file>.sql

# 4. Verify
docker exec -it <db-container> mysql -u <user> -p <database> -e "SHOW TABLES;"

# 5. Start service
docker compose start <app-service>
```

### Volume Restore

```bash
# 1. Stop service
cd /root/infra/<service>
docker compose down

# 2. Restore volume
tar -xzf <volume-backup>.tar.gz -C ./

# 3. Verify
ls -la ./data/

# 4. Start service
docker compose up -d
```

## Service-Specific Restores

### WikiJS

```bash
# Database
cd /root/infra/wikijs
docker compose stop wikijs
gunzip wiki_wikijs_*.dump.gz
docker exec -i wikijs-db pg_restore -U wikijs -d wiki --clean < wiki_wikijs_*.dump
docker compose start wikijs
```

### WordPress

```bash
# Database
cd /root/infra/wordpress
docker compose stop wordpress
gunzip wordpress_*.sql.gz
docker exec -i wordpress-db mysql -u wordpress -p wordpress < wordpress_*.sql
docker compose start wordpress
```

### Vault

```bash
# Volume
cd /root/infra/vault
docker compose down
tar -xzf vault_volume_*.tar.gz -C ./
docker compose up -d
```

## Backup Verification

### Test Restore

Regularly test restore procedures:

1. Create test environment
2. Restore from backup
3. Verify data integrity
4. Test functionality
5. Document results

### Backup Integrity

```bash
# Check file integrity
gunzip -t <backup-file>.gz

# Verify file size
ls -lh <backup-file>

# Check backup age
stat <backup-file>
```

## Troubleshooting

### Backup Fails

1. Check disk space: `df -h`
2. Check database connectivity
3. Review backup logs
4. Verify permissions
5. Retry backup

### Restore Fails

1. Verify backup file integrity
2. Check database connectivity
3. Verify credentials
4. Check disk space
5. Review error messages

## Best Practices

1. **Test Backups Regularly**
   - Monthly restore tests
   - Verify data integrity
   - Document results

2. **Multiple Copies**
   - Local backups
   - Remote backups (recommended)
   - Off-site storage

3. **Documentation**
   - Document all backups
   - Keep restore procedures updated
   - Maintain backup logs

4. **Monitoring**
   - Monitor backup success
   - Alert on failures
   - Track backup sizes

## Automation

### Scheduled Backups

See [backup/README.md](../backup/README.md) for automation setup.

### Systemd Timer

```bash
# Enable backup timer
sudo systemctl enable infra-backup.timer
sudo systemctl start infra-backup.timer

# Check status
sudo systemctl status infra-backup.timer
```

## Recovery Time Estimates

| Service | Backup Size | Restore Time |
|---------|-------------|--------------|
| WikiJS DB | ~100MB | 5-10 min |
| WordPress DB | ~500MB | 10-15 min |
| Vault Volume | ~50MB | 2-5 min |
| Full Infrastructure | ~2GB | 30-60 min |

