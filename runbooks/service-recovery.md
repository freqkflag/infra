# Service Recovery Procedures

Step-by-step procedures for recovering individual services.

## General Recovery Process

1. **Identify Issue**
   - Check service status
   - Review logs
   - Check health

2. **Stop Service**
   ```bash
   cd /root/infra/<service>
   docker compose down
   ```

3. **Restore Data** (if needed)
   - Restore database
   - Restore volumes

4. **Start Service**
   ```bash
   docker compose up -d
   ```

5. **Verify**
   - Check health
   - Test functionality
   - Monitor logs

## Service-Specific Procedures

### Traefik

**Recovery:**
```bash
cd /root/infra/traefik
docker compose down
docker compose up -d
docker compose logs -f
```

**Verify:**
```bash
curl http://localhost:8080/ping
docker ps | grep traefik
```

### Vault

**Recovery:**
```bash
cd /root/infra/vault
docker compose down
# Restore data if needed
docker compose up -d
```

**Verify:**
```bash
curl http://localhost:8200/v1/sys/health
```

### WikiJS

**Recovery:**
```bash
cd /root/infra/wikijs
docker compose down
# Restore database if needed
docker compose up -d
```

**Verify:**
```bash
curl -I https://wiki.freqkflag.co
docker compose ps
```

### WordPress

**Recovery:**
```bash
cd /root/infra/wordpress
docker compose down
# Restore database and volumes if needed
docker compose up -d
```

**Verify:**
```bash
curl -I https://cultofjoey.com
docker compose ps
```

### LinkStack

**Recovery:**
```bash
cd /root/infra/linkstack
docker compose down
# Restore database if needed
docker compose up -d
```

**Verify:**
```bash
curl -I https://link.cultofjoey.com
```

### n8n

**Recovery:**
```bash
cd /root/infra/n8n
docker compose down
# Restore database if needed
docker compose up -d
```

**Verify:**
```bash
curl -I https://n8n.freqkflag.co
```

### Mastodon

**Recovery:**
```bash
cd /root/infra/mastadon
docker compose down
# Restore database and volumes if needed
docker compose up -d
```

**Verify:**
```bash
curl -I https://twist3dkinkst3r.com
docker compose ps
```

## Database Recovery

See [DISASTER_RECOVERY.md](../DISASTER_RECOVERY.md) for detailed database recovery procedures.

## Common Issues

### Service Won't Start

1. Check logs: `docker compose logs`
2. Check dependencies
3. Verify configuration
4. Check resources
5. Try recreate: `docker compose up -d --force-recreate`

### Health Check Failing

1. Check service logs
2. Verify health endpoint
3. Check dependencies
4. Review health check configuration
5. Restart service

### Port Conflicts

1. Check for conflicting services
2. Verify port mappings
3. Change port if needed
4. Restart service

## Verification Checklist

After recovery, verify:

- [ ] Service is running
- [ ] Health checks passing
- [ ] Service accessible
- [ ] No errors in logs
- [ ] Functionality works
- [ ] Monitoring shows normal

