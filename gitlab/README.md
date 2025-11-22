# GitLab Community Edition Deployment

GitLab CE is a complete DevOps platform, delivered as a single application.

**Location:** `/root/infra/gitlab/`

**Domain:** `gitlab.freqkflag.co`

## Quick Start

1. **Configure Secrets in Infisical:**
   - Add GitLab secrets to Infisical `/prod` environment:
     - `GITLAB_DOMAIN`: `gitlab.freqkflag.co`
     - `GITLAB_DB_HOST`: PostgreSQL host (e.g., `postgres` from shared service)
     - `GITLAB_DB_PORT`: `5432`
     - `GITLAB_DB_USER`: Database user
     - `GITLAB_DB_PASSWORD`: Database password
     - `GITLAB_DB_NAME`: Database name (e.g., `gitlab`)
     - `GITLAB_REDIS_HOST`: Redis host (e.g., `redis` from shared service)
     - `GITLAB_REDIS_PORT`: `6379`
     - `GITLAB_REDIS_PASSWORD`: Redis password (if set)
     - `GITLAB_ROOT_PASSWORD`: Initial root password (change after first login!)
     - `GITLAB_SSH_PORT`: SSH port for git clone (default: `2224`)

2. **Create Database:**
   ```bash
   # Connect to PostgreSQL and create database
   docker exec -it postgres psql -U ${POSTGRES_USER} -d postgres
   CREATE DATABASE gitlab;
   CREATE USER gitlab WITH PASSWORD 'your_password';
   GRANT ALL PRIVILEGES ON DATABASE gitlab TO gitlab;
   \q
   ```

3. **Deploy:**
   ```bash
   cd /root/infra/gitlab
   DEVTOOLS_WORKSPACE=/root/infra docker compose up -d
   ```

4. **Initial Setup:**
   - Wait for GitLab to initialize (first boot takes 5-10 minutes)
   - Visit `https://gitlab.freqkflag.co`
   - Login with username `root` and the password from `GITLAB_ROOT_PASSWORD`
   - **IMPORTANT:** Change the root password immediately after first login
   - Configure SMTP settings (optional, via Admin Area → Settings → Email)

## Architecture

- **GitLab CE**: Main application container (Omnibus package)
- **PostgreSQL**: Database for GitLab data (uses shared postgres service)
- **Redis**: Cache and job queue (uses shared redis service)
- **Traefik**: Reverse proxy with SSL certificates

## Configuration

### Environment Variables

All configuration is managed through Infisical secrets loaded via `.workspace/.env`:

- **Domain:**
  - `GITLAB_DOMAIN`: Full domain name (e.g., `gitlab.freqkflag.co`)

- **Database:**
  - `GITLAB_DB_HOST`: PostgreSQL hostname
  - `GITLAB_DB_PORT`: PostgreSQL port (default: `5432`)
  - `GITLAB_DB_USER`: Database user
  - `GITLAB_DB_PASSWORD`: Database password
  - `GITLAB_DB_NAME`: Database name

- **Redis:**
  - `GITLAB_REDIS_HOST`: Redis hostname
  - `GITLAB_REDIS_PORT`: Redis port (default: `6379`)
  - `GITLAB_REDIS_PASSWORD`: Redis password (optional)

- **Security:**
  - `GITLAB_ROOT_PASSWORD`: Initial root password (**change after first login!**)

- **SSH:**
  - `GITLAB_SSH_PORT`: SSH port for git clone operations (default: `2224`)

### GitLab Omnibus Configuration

GitLab is configured via `GITLAB_OMNIBUS_CONFIG` environment variable. Key settings:

- External URL: `https://gitlab.freqkflag.co`
- PostgreSQL: External database (shared postgres service)
- Redis: External Redis (shared redis service)
- Worker processes: 2 (adjust based on resources)
- Sidekiq concurrency: 10 (adjust based on resources)
- Log rotation: 200MB, 30 rotations, gzip compression

### Persistent Data

GitLab stores data in three volumes:

- `./data/config`: GitLab configuration files
- `./data/logs`: Application logs
- `./data/data`: Application data (repositories, uploads, etc.)

## Management Commands

### View Logs
```bash
docker compose logs -f gitlab
```

### Execute GitLab Commands
```bash
docker exec -it gitlab gitlab-ctl <command>
```

### Common GitLab Commands
```bash
# Check status
docker exec -it gitlab gitlab-ctl status

# Reconfigure GitLab
docker exec -it gitlab gitlab-ctl reconfigure

# Restart GitLab
docker exec -it gitlab gitlab-ctl restart

# View logs
docker exec -it gitlab gitlab-ctl tail

# Backup
docker exec -it gitlab gitlab-backup create

# Restore
docker exec -it gitlab gitlab-backup restore BACKUP=timestamp
```

### Backup GitLab

```bash
# Create backup
docker exec -it gitlab gitlab-backup create

# Backups are stored in: ./data/data/backups/
```

### Restore GitLab

```bash
# List available backups
ls -la ./data/data/backups/

# Restore from backup
docker exec -it gitlab gitlab-backup restore BACKUP=timestamp
```

## Health Checks

GitLab health check verifies that the `gitlab-workhorse` service is running. The check runs every 60 seconds with a 10-minute start period to allow for initial configuration.

## Performance Tuning

Default resource limits:
- CPU: 4 cores (limit), 1 core (reservation)
- Memory: 4GB (limit), 2GB (reservation)

Adjust these values in `docker-compose.yml` based on your server resources and usage patterns.

## Security Notes

- **Change root password** immediately after first login
- **Configure SMTP** for password resets and notifications
- **Enable 2FA** for all users (Admin Area → Settings → General → Sign-in restrictions)
- **Regular backups** are essential
- **Keep GitLab updated** regularly
- **Review security settings** in Admin Area → Settings → General → Security

## Troubleshooting

### GitLab Not Starting

1. Check logs: `docker compose logs gitlab`
2. Verify database connection: `docker exec -it gitlab gitlab-rake gitlab:check`
3. Check disk space: `df -h`
4. Verify secrets are loaded: `docker exec -it gitlab env | grep GITLAB`

### Database Connection Issues

1. Verify PostgreSQL is running: `docker ps | grep postgres`
2. Test connection: `docker exec -it postgres psql -U gitlab -d gitlab`
3. Check database credentials in Infisical

### Redis Connection Issues

1. Verify Redis is running: `docker ps | grep redis`
2. Test connection: `docker exec -it redis redis-cli ping`
3. Check Redis credentials in Infisical

### Performance Issues

1. Check resource usage: `docker stats gitlab`
2. Review logs for errors: `docker compose logs gitlab | grep -i error`
3. Adjust worker processes and concurrency in `GITLAB_OMNIBUS_CONFIG`
4. Consider increasing resource limits

## Updates

```bash
cd /root/infra/gitlab
docker compose pull
docker compose up -d
```

**Note:** GitLab updates may require database migrations. Check the [GitLab upgrade documentation](https://docs.gitlab.com/ee/update/) before upgrading.

## Integration with Other Services

- **Traefik**: Automatic SSL certificates and reverse proxy
- **PostgreSQL**: Shared database service
- **Redis**: Shared cache/job queue service
- **Infisical**: Secrets management

## References

- [GitLab CE Documentation](https://docs.gitlab.com/ce/)
- [GitLab Omnibus Configuration](https://docs.gitlab.com/omnibus/settings/configuration.html)
- [GitLab Backup and Restore](https://docs.gitlab.com/ce/raketasks/backup_restore.html)

---

**Last Updated:** 2025-11-22
