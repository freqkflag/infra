# Operational Guide

Day-to-day operations and management procedures for the infrastructure.

## Quick Reference

### Service Management

```bash
# Start a service
cd /root/infra/<service-name>
docker compose up -d

# Stop a service
docker compose down

# View logs
docker compose logs -f

# Restart a service
docker compose restart

# Check status
docker compose ps
```

### Service Status

```bash
# All services
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Specific service
docker ps --filter "name=<service-name>"
```

### Health Checks

```bash
# Check service health
docker inspect <container-name> | jq '.[0].State.Health'

# View health check logs
docker inspect <container-name> | jq '.[0].State.Health.Log'
```

## Common Tasks

### Update a Service

```bash
cd /root/infra/<service-name>
docker compose pull
docker compose up -d
docker compose logs -f  # Monitor startup
```

### View Service Logs

```bash
# Recent logs
docker compose logs --tail=100

# Follow logs
docker compose logs -f

# Logs for specific service
docker compose logs <service-name>
```

### Access Service Shell

```bash
# Exec into container
docker exec -it <container-name> /bin/sh
# or
docker exec -it <container-name> /bin/bash
```

### Database Access

```bash
# PostgreSQL
docker exec -it <db-container> psql -U <user> -d <database>

# MySQL
docker exec -it <db-container> mysql -u <user> -p <database>
```

## Monitoring

### Grafana

- URL: https://grafana.freqkflag.co
- Default credentials: See `monitoring/.env`

### Prometheus

- URL: https://prometheus.freqkflag.co
- Metrics endpoint: http://prometheus:9090/metrics

### Logs (Loki)

- Access via Grafana Explore
- Query logs using LogQL

## Troubleshooting

### Service Won't Start

1. Check logs: `docker compose logs <service>`
2. Verify health: `docker compose ps`
3. Check resources: `docker stats`
4. Verify network: `docker network ls`
5. Check dependencies: Ensure dependent services are running

### High Resource Usage

1. Check resource limits in docker-compose.yml
2. Monitor with `docker stats`
3. Review service logs for errors
4. Consider scaling or optimization

### Network Issues

1. Verify Traefik is running: `docker ps | grep traefik`
2. Check network: `docker network inspect traefik-network`
3. Verify service labels for Traefik routing
4. Check SSL certificates: `docker logs traefik`

### Database Issues

1. Check database health: `docker compose ps <db-service>`
2. Verify connections: Check application logs
3. Check disk space: `df -h`
4. Review database logs: `docker compose logs <db-service>`

## Maintenance Windows

### Weekly Maintenance

- Review service logs
- Check disk usage
- Verify backups
- Update documentation

### Monthly Maintenance

- Update Docker images
- Review security scans
- Capacity planning
- Performance review

## Emergency Procedures

See [runbooks/incident-response.md](./runbooks/incident-response.md) for detailed procedures.

### Service Down

1. Check service status
2. Review logs
3. Restart service
4. Verify health
5. Document incident

### Data Loss

1. Stop affected service
2. Assess damage
3. Restore from backup
4. Verify data integrity
5. Resume service

## Best Practices

1. **Always check logs** before making changes
2. **Test in staging** before production changes
3. **Document changes** in commit messages
4. **Monitor after changes** for at least 15 minutes
5. **Have rollback plan** ready
6. **Backup before major changes**

## Support

- Documentation: See service-specific README files
- Runbooks: `/root/infra/runbooks/`
- Security: See `SECURITY.md`
- Disaster Recovery: See `DISASTER_RECOVERY.md`

