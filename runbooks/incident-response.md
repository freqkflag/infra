# Incident Response Runbook

Procedures for responding to infrastructure incidents.

## Incident Severity Levels

### Critical (P1)
- Complete service outage
- Data loss or corruption
- Security breach
- **Response Time:** Immediate

### High (P2)
- Partial service outage
- Performance degradation
- Security vulnerability
- **Response Time:** 1 hour

### Medium (P3)
- Minor service issues
- Non-critical errors
- **Response Time:** 4 hours

### Low (P4)
- Cosmetic issues
- Documentation updates
- **Response Time:** Next business day

## Response Workflow

### 1. Detection

**Sources:**
- Monitoring alerts (Grafana/Prometheus)
- User reports
- Log analysis
- Health check failures

**Actions:**
- Acknowledge alert
- Assess severity
- Gather initial information

### 2. Assessment

**Information to Gather:**
- Affected services
- Error messages
- Recent changes
- Service logs
- Resource usage

**Commands:**
```bash
# Service status
docker ps -a
docker compose ps

# Recent logs
docker compose logs --tail=100

# Resource usage
docker stats --no-stream

# Network status
docker network inspect traefik-network
```

### 3. Containment

**Immediate Actions:**
- Stop affected service if necessary
- Isolate affected systems
- Preserve logs and evidence
- Document current state

### 4. Resolution

**Common Fixes:**

**Service Won't Start:**
```bash
# Check logs
docker compose logs <service>

# Restart service
docker compose restart <service>

# Recreate if needed
docker compose up -d --force-recreate
```

**High Resource Usage:**
```bash
# Check resource limits
docker stats

# Restart service
docker compose restart <service>

# Scale if needed (if supported)
docker compose up -d --scale <service>=2
```

**Database Issues:**
```bash
# Check database health
docker compose ps <db>

# Check connections
docker compose logs <db>

# Restart database
docker compose restart <db>
```

**Network Issues:**
```bash
# Check Traefik
docker ps | grep traefik
docker logs traefik

# Restart Traefik
cd /root/infra/traefik
docker compose restart
```

### 5. Verification

**Checklist:**
- [ ] Service is running
- [ ] Health checks passing
- [ ] No errors in logs
- [ ] Functionality verified
- [ ] Monitoring shows normal

### 6. Documentation

**Post-Incident:**
- Document incident timeline
- Root cause analysis
- Actions taken
- Prevention measures
- Update runbooks if needed

## Common Incidents

### Service Down

**Symptoms:**
- Health check failing
- 502/503 errors
- Service unreachable

**Steps:**
1. Check service status: `docker compose ps`
2. Review logs: `docker compose logs`
3. Check dependencies
4. Restart service
5. Verify health

### Database Connection Issues

**Symptoms:**
- Application errors
- Connection timeouts
- Database unreachable

**Steps:**
1. Check database health
2. Verify network connectivity
3. Check credentials
4. Review database logs
5. Restart if needed

### High CPU/Memory Usage

**Symptoms:**
- Slow response times
- Service timeouts
- Resource alerts

**Steps:**
1. Check resource usage: `docker stats`
2. Identify resource-intensive processes
3. Review service logs
4. Check for loops or leaks
5. Restart or scale service

### SSL Certificate Issues

**Symptoms:**
- SSL errors
- Certificate expired
- Traefik errors

**Steps:**
1. Check Traefik logs
2. Verify Let's Encrypt status
3. Check domain DNS
4. Restart Traefik
5. Force certificate renewal if needed

### Backup Failures

**Symptoms:**
- Backup script errors
- Missing backups
- Backup alerts

**Steps:**
1. Check backup logs
2. Verify disk space
3. Check database connectivity
4. Test backup manually
5. Fix issues and rerun

## Escalation

### When to Escalate

- Critical severity incidents
- Unable to resolve within SLA
- Need additional expertise
- Security incidents
- Data loss

### Escalation Path

1. **Level 1:** Primary maintainer
2. **Level 2:** Secondary administrator
3. **Level 3:** External support (hosting provider)

## Communication

### During Incident

- Update status page (if available)
- Notify stakeholders
- Provide regular updates
- Document all actions

### Post-Incident

- Incident report
- Root cause analysis
- Prevention measures
- Lessons learned

## Prevention

### Proactive Measures

- Regular health checks
- Monitoring and alerting
- Regular backups
- Security scanning
- Capacity planning
- Regular updates

### Best Practices

- Test changes in staging
- Have rollback plans
- Document procedures
- Regular DR drills
- Keep runbooks updated

## Contact Information

- **Primary:** [Your contact]
- **Backup:** [Backup contact]
- **Emergency:** [Emergency contact]

## Tools and Resources

- **Monitoring:** Grafana, Prometheus
- **Logs:** Loki, Grafana
- **Backups:** `/root/infra/backup/`
- **Documentation:** Service READMEs
- **Scripts:** `/root/infra/scripts/`

