# Backup System

Automated backup system for all infrastructure services.

## Overview

- **Daily backups:** All databases
- **Weekly backups:** Critical data volumes
- **Retention:** 30 days daily, 12 weeks weekly
- **Format:** Compressed dumps (PostgreSQL) and SQL files (MySQL)

## Quick Start

### Manual Backup

```bash
cd /root/infra/backup
docker compose run --rm backup
```

### Automated Backups (Cron)

Add to crontab:

```bash
# Daily backups at 2 AM
0 2 * * * cd /root/infra/backup && docker compose run --rm backup

# Or use systemd timer (recommended)
```

### Systemd Timer (Recommended)

Create `/etc/systemd/system/infra-backup.service`:

```ini
[Unit]
Description=Infrastructure Backup
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
WorkingDirectory=/root/infra/backup
ExecStart=/usr/bin/docker compose run --rm backup
EnvironmentFile=/root/infra/backup/.env
```

Create `/etc/systemd/system/infra-backup.timer`:

```ini
[Unit]
Description=Daily Infrastructure Backup
Requires=infra-backup.service

[Timer]
OnCalendar=daily
OnCalendar=02:00
Persistent=true

[Install]
WantedBy=timers.target
```

Enable and start:

```bash
sudo systemctl enable infra-backup.timer
sudo systemctl start infra-backup.timer
sudo systemctl status infra-backup.timer
```

## Backup Locations

- **Daily backups:** `./data/daily/`
- **Weekly archives:** `./data/weekly/`
- **Logs:** `./data/logs/`

## What Gets Backed Up

### Databases (Daily)
- WikiJS (PostgreSQL)
- n8n (PostgreSQL)
- Mastodon (PostgreSQL)
- Supabase (PostgreSQL)
- WordPress (MySQL)
- LinkStack (MySQL)

### Volumes (Weekly - Monday)
- Vault data
- WikiJS data
- WordPress data

## Restore Procedures

### PostgreSQL

```bash
# Extract and restore
gunzip wikijs_20231120_020000.dump.gz
docker exec -i wikijs-db pg_restore -U wikijs -d wiki < wikijs_20231120_020000.dump
```

### MySQL

```bash
# Extract and restore
gunzip wordpress_20231120_020000.sql.gz
docker exec -i wordpress-db mysql -u wordpress -p wordpress < wordpress_20231120_020000.sql
```

### Volumes

```bash
# Extract volume backup
tar -xzf vault_volume_20231120_020000.tar.gz
# Copy to service directory
cp -r data/* /root/infra/vault/data/
```

## Configuration

Edit `config/backup-config.yml` to:
- Add/remove services
- Change retention policies
- Configure backup schedules

Environment variables in `.env`:
- `BACKUP_RETENTION_DAYS` - Daily backup retention (default: 30)
- `BACKUP_RETENTION_WEEKS` - Weekly backup retention (default: 12)

## Monitoring

Check backup logs:

```bash
tail -f /root/infra/backup/data/logs/backup_*.log
```

Verify backups:

```bash
ls -lh /root/infra/backup/data/daily/
ls -lh /root/infra/backup/data/weekly/
```

## Security Notes

- Database passwords required in environment
- Backups stored locally (consider remote storage for production)
- Backup files contain sensitive data - secure appropriately
- Consider encryption for off-site backups

## Remote Backup (Optional)

To add remote backup storage:

1. Mount remote storage to backup container
2. Modify `backup-all.sh` to copy to remote after local backup
3. Consider using rclone, rsync, or cloud storage tools

