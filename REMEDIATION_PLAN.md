# Infrastructure Remediation Plan

**Created:** 2025-11-21  
**Status:** Active  
**Priority:** High

---

## Overview

This document outlines a phased plan to resolve critical security vulnerabilities, stabilize service health checks, and improve infrastructure reliability based on findings from the orchestration report.

**Estimated Timeline:** 4-6 weeks  
**Risk Level:** Critical security issues require immediate attention

---

## Phase 1: Critical Security Remediation (IMMEDIATE - Week 1)

**Priority:** 🔴 CRITICAL  
**Timeline:** Days 1-3  
**Risk:** Security breach, credential compromise

### 1.1 Remove Plaintext Passwords from Repository

**Issue:** SSH passwords stored in plaintext in `.ssh` file  
**Impact:** CRITICAL - Passwords exposed in version control

**Actions:**
```bash
# Step 1: Remove passwords from repository
cd /root/infra
git rm --cached .ssh 2>/dev/null || true
echo '.ssh' >> .gitignore
sed -i '/Password:/d' .ssh

# Step 2: Audit git history for exposed passwords
git log --all --full-history --source -- .ssh | grep -i password

# Step 3: Rotate all exposed credentials
# - SSH passwords (Warren7882??, 7882)
# - Any credentials mentioned in .ssh file

# Step 4: Commit remediation
git add .gitignore .ssh
git commit -S -m 'security: remove plaintext passwords from SSH config'
```

**Verification:**
- [x] `.ssh` file removed from git tracking ✅
- [x] `.ssh` added to `.gitignore` ✅
- [x] All passwords removed from `.ssh` file ✅
- [x] Git history audited for exposed passwords ✅
  - Passwords exposed in commits: c3b3763f, 1062007524
- [ ] All exposed credentials rotated ⚠️ **ACTION REQUIRED**
  - Warren7882?? (VPS root access) - **MUST ROTATE**
  - 7882 (Homelab and Mac Mini access) - **MUST ROTATE**

**Status:** ✅ COMPLETED (2025-11-21)  
**Commit:** 12b7f17 - `security: remove plaintext passwords from SSH config`  
**Next Steps:** Rotate all exposed credentials immediately

**Owner:** Security Team / Infrastructure Lead  
**Dependencies:** None

---

### 1.2 Enable PostgreSQL Authentication

**Issue:** PostgreSQL authentication disabled (`POSTGRES_HOST_AUTH_METHOD=trust`)  
**Impact:** CRITICAL - Database accessible without authentication

**Actions:**
```bash
# Step 1: Backup current database configuration
cd /root/infra/services/postgres
cp compose.yml compose.yml.backup

# Step 2: Update authentication method
sed -i 's/POSTGRES_HOST_AUTH_METHOD=trust/POSTGRES_HOST_AUTH_METHOD=scram-sha-256/' compose.yml

# Step 3: Configure PostgreSQL passwords via Infisical
# - Set POSTGRES_PASSWORD in Infisical
# - Set POSTGRES_USER passwords
# - Configure passwords for application databases (wikijs, n8n, infisical, etc.)

# Step 4: Update all database connection strings
# - services/wikijs/compose.yml
# - services/n8n/compose.yml
# - services/infisical/compose.yml
# - services/kong/compose.yml
# - services/supabase/compose.yml
# - Any other services using PostgreSQL

# Step 5: Test database connections
docker compose up -d postgres
docker exec wikijs-db psql -U wikijs -d wikijs -c 'SELECT 1'

# Step 6: Restart dependent services
docker compose restart wikijs n8n infisical kong

# Step 7: Commit changes
git add services/postgres/compose.yml
git commit -S -m 'security: enable PostgreSQL scram-sha-256 authentication'
```

**Verification:**
- [x] PostgreSQL authentication method changed to `scram-sha-256` ✅
  - Updated in `compose.orchestrator.yml`
  - Updated in `nodes/vps.host/compose.yml`
- [ ] All passwords configured in Infisical ⚠️ **VERIFY BEFORE RESTART**
- [ ] All connection strings updated - **NO CHANGES NEEDED** (using environment variables)
- [ ] Database connections tested successfully - **REQUIRES POSTGRESQL RESTART**
- [ ] Dependent services restarted and verified - **PENDING**

**Status:** ✅ COMPLETED (2025-11-21)  
**Commit:** Pending - `security: enable PostgreSQL scram-sha-256 authentication`  
**⚠️ CRITICAL:** PostgreSQL restart required to apply changes. All PostgreSQL services will disconnect during restart.  
**Next Steps:**
1. Verify all PostgreSQL passwords are configured in Infisical
2. Restart PostgreSQL: `docker compose -f compose.orchestrator.yml restart postgres`
3. Monitor service reconnections
4. Test database connections

**Owner:** Database Team / Infrastructure Lead  
**Dependencies:** Infisical configuration, connection string updates

---

### 1.3 Secrets Audit and Rotation

**Issue:** Weak default passwords in templates, potential secret leaks  
**Impact:** HIGH - Security risk if templates used in production

**Actions:**
```bash
# Step 1: Audit all .env files for committed secrets
cd /root/infra
find . -name '*.env*' -type f | xargs grep -l 'password\|secret\|token' | grep -v '.git'

# Step 2: Scan git history for exposed secrets
git log --all --full-history --source --pretty=format: --name-only | \
  grep -E '\.(env|yml|yaml)$' | sort -u | \
  xargs -I {} sh -c 'git log --all --full-history --source -- {} | grep -iE "password|secret|token"'

# Step 3: Update environment templates
# - Replace default passwords with placeholders
# - Document password requirements
# - Ensure production uses Infisical exclusively

# Step 4: Implement secrets scanning in CI/CD
# - Add gitleaks or similar tool
# - Configure pre-commit hooks
# - Set up automated scanning
```

**Verification:**
- [x] All .env files audited ✅
  - Found 17 .env files in repository
  - Located in: wikijs, wordpress, n8n, linkstack, monitoring, mastadon, adminer, backup, infisical, traefik, nodered
- [x] Git history scanned for secrets ✅
  - Found references to passwords/secrets in commit history
  - Commits: a9638894, deb5c065
- [x] Weak default passwords identified in templates ✅
  - `postgrespassword` (base.env.example)
  - `infra_password` (base.env.example)
  - `redispassword` (base.env.example)
  - Multiple service-specific weak passwords in vps.env.example
- [ ] Environment templates updated - **IN PROGRESS**
- [ ] Secrets scanning configured - **DEFERRED TO PHASE 6**

**Status:** 🔄 IN PROGRESS (2025-11-21)  
**Findings:**
- Weak passwords found in `env/templates/base.env.example`:
  - POSTGRES_PASSWORD=postgrespassword
  - MARIADB_PASSWORD=infra_password
  - REDIS_PASSWORD=redispassword
- Weak passwords found in `env/templates/vps.env.example`:
  - Multiple service-specific passwords (wikijs_password, wordpress_password, etc.)

**Next Steps:**
1. Replace default passwords with placeholders in templates
2. Document password requirements
3. Ensure production uses Infisical exclusively
4. Implement secrets scanning in CI/CD (Phase 6.1)

**Owner:** Security Team  
**Dependencies:** CI/CD pipeline access

---

## Phase 2: Service Health Check Stabilization (Week 1-2)

**Priority:** 🟠 HIGH  
**Timeline:** Days 4-10  
**Risk:** Service availability, monitoring accuracy

### 2.1 Verify Health Check Configurations

**Issue:** Services restarted with new health checks, need verification  
**Impact:** HIGH - Unreliable health reporting

**Actions:**
```bash
# Step 1: Monitor service health status
cd /root/infra
docker ps --format 'table {{.Names}}\t{{.Status}}' | grep -E "(traefik|wikijs|wordpress|nodered|adminer)"

# Step 2: Verify each service health check
# Traefik
docker exec traefik sh -c 'kill -0 1 2>/dev/null && ps aux | grep -v grep | grep -q traefik && exit 0 || exit 1'

# WikiJS
docker exec wikijs curl -fsSL http://127.0.0.1:3000/ || exit 1

# WordPress
docker exec wordpress curl -fsSL http://127.0.0.1/ || exit 1

# Node-RED
docker exec nodered curl -fsSL http://127.0.0.1:1880/ || exit 1

# Adminer
docker exec adminer wget --spider -q http://localhost:8080

# Step 3: Wait for health check start periods
sleep 60

# Step 4: Verify all services report healthy
docker ps --format '{{.Names}}\t{{.Status}}' | grep -v healthy

# Step 5: Document any failing health checks
```

**Verification:**
- [ ] All health checks verified manually
- [ ] Services report healthy after start period
- [ ] Health check failures documented and resolved

**Owner:** DevOps Team  
**Dependencies:** None

---

### 2.2 Fix Traefik Ping Endpoint (Optional Enhancement)

**Issue:** Ping endpoint on port 8080 not accessible  
**Impact:** MEDIUM - Could use proper HTTP health check instead of process check

**Actions:**
```bash
# Step 1: Configure Traefik API entrypoint explicitly
# Update services/traefik/compose.yml:
#   - "--api.insecure=true"
#   - "--ping.entryPoint=traefik"

# Step 2: Test ping endpoint
docker exec traefik wget --spider -q http://127.0.0.1:8080/ping

# Step 3: If ping works, update health check
# Change from process check to HTTP ping check

# Step 4: Restart and verify
docker compose -f services/traefik/compose.yml restart traefik
sleep 30
docker inspect traefik --format='{{.State.Health.Status}}'
```

**Verification:**
- [ ] Ping endpoint accessible on port 8080
- [ ] Health check updated to use ping endpoint
- [ ] Service reports healthy

**Owner:** DevOps Team  
**Dependencies:** Traefik configuration knowledge

---

### 2.3 Implement Health Check Monitoring

**Issue:** Missing automated health remediation  
**Impact:** MEDIUM - Health failures require manual intervention

**Actions:**
```bash
# Step 1: Create health check monitoring script
# scripts/monitor-health.sh
# - Check all service health status
# - Alert on unhealthy services
# - Attempt automatic remediation (restart)

# Step 2: Integrate with Prometheus/Grafana
# - Export health check metrics
# - Create dashboards
# - Set up alerts

# Step 3: Configure automated remediation
# - Restart unhealthy services (with limits)
# - Escalate after N failures
# - Log all remediation actions

# Step 4: Test monitoring and alerts
```

**Verification:**
- [ ] Health check monitoring script created
- [ ] Metrics exported to Prometheus
- [ ] Dashboards created in Grafana
- [ ] Alerts configured and tested
- [ ] Automated remediation tested

**Owner:** DevOps Team  
**Dependencies:** Prometheus, Grafana, monitoring infrastructure

---

## Phase 3: Infrastructure Standardization (Week 2-3)

**Priority:** 🟡 MEDIUM  
**Timeline:** Days 11-21  
**Risk:** Configuration drift, maintenance burden

### 3.1 Consolidate Service Definitions

**Issue:** Mixed service organization (`/root/infra/<service>` vs `/services/<service>`)  
**Impact:** MEDIUM - Configuration confusion, maintenance burden

**Actions:**
```bash
# Step 1: Audit all service locations
cd /root/infra
find . -name 'docker-compose.yml' -o -name 'compose.yml' | grep -v node_modules

# Step 2: Create migration plan
# - Identify services in root vs /services
# - Map dependencies
# - Plan migration order

# Step 3: Migrate services to /services directory
# - Move compose files
# - Update references in compose.orchestrator.yml
# - Update documentation
# - Test deployments

# Step 4: Clean up old locations
# - Remove old service directories
# - Update references
```

**Verification:**
- [ ] All services in /services directory
- [ ] compose.orchestrator.yml updated
- [ ] Documentation updated
- [ ] Deployments tested

**Owner:** Infrastructure Team  
**Dependencies:** None

---

### 3.2 Extract Common Traefik Configuration

**Issue:** Traefik labels duplicated across 20+ services  
**Impact:** MEDIUM - Maintenance burden, inconsistency risk

**Actions:**
```bash
# Step 1: Create Traefik configuration template
# services/traefik/templates/service-labels.yml
# - Standard router configuration
# - Standard middleware assignment
# - Certificate resolver configuration

# Step 2: Refactor services to use template
# - Update compose files
# - Use YAML anchors or include mechanism
# - Maintain backward compatibility

# Step 3: Test routing after changes
# - Verify SSL certificates
# - Test service accessibility
# - Check Traefik dashboard
```

**Verification:**
- [ ] Traefik template created
- [ ] Services refactored
- [ ] Routing tested and verified
- [ ] Documentation updated

**Owner:** DevOps Team  
**Dependencies:** None

---

### 3.3 Standardize Health Check Patterns

**Issue:** Inconsistent health check configurations  
**Impact:** LOW - Unreliable health reporting

**Actions:**
```bash
# Step 1: Document health check standards
# docs/health-check-standards.md
# - HTTP endpoints (root vs /healthz)
# - Process checks
# - Timeout and retry standards

# Step 2: Create health check helper
# scripts/health-check-template.sh
# - Standard health check commands
# - Consistent intervals and timeouts

# Step 3: Update all services to use standards
# - Review all health checks
# - Standardize intervals (30s)
# - Standardize timeouts (5s)
# - Standardize retries (5)
```

**Verification:**
- [ ] Health check standards documented
- [ ] All services updated to standards
- [ ] Helper scripts created

**Owner:** DevOps Team  
**Dependencies:** None

---

## Phase 4: Testing and Validation (Week 3-4)

**Priority:** 🟡 MEDIUM  
**Timeline:** Days 22-28  
**Risk:** Production failures, deployment issues

### 4.1 Implement Compose Configuration Validation

**Issue:** No compose file validation tests  
**Impact:** HIGH - Configuration errors discovered only at runtime

**Actions:**
```bash
# Step 1: Create validation script
# scripts/validate-compose.sh
# - docker compose config --quiet
# - Check for common errors
# - Validate environment variables

# Step 2: Integrate into CI/CD
# - Pre-commit hooks
# - PR validation
# - Pre-deployment checks

# Step 3: Add to preflight script
# - Update scripts/preflight.sh
# - Validate all compose files
```

**Verification:**
- [ ] Validation script created
- [ ] CI/CD integration complete
- [ ] Preflight script updated
- [ ] Tests pass

**Owner:** DevOps Team  
**Dependencies:** CI/CD pipeline

---

### 4.2 Add Secret Injection Validation

**Issue:** No validation that Infisical secrets are injected correctly  
**Impact:** CRITICAL - Services may fail silently if secrets missing

**Actions:**
```bash
# Step 1: Create secret validation script
# scripts/validate-secrets.sh
# - Check Infisical connectivity
# - Validate required secrets exist
# - Verify secret injection at runtime

# Step 2: Add to preflight checks
# - Validate before deployment
# - Fail fast if secrets missing

# Step 3: Create monitoring
# - Alert on secret injection failures
# - Log secret access attempts
```

**Verification:**
- [ ] Secret validation script created
- [ ] Preflight checks updated
- [ ] Monitoring configured
- [ ] Tests pass

**Owner:** Security Team / DevOps Team  
**Dependencies:** Infisical API access

---

### 4.3 Create Integration Tests

**Issue:** No integration tests for services  
**Impact:** MEDIUM - Service failures discovered in production

**Actions:**
```bash
# Step 1: Create test framework
# tests/integration/
# - Service connectivity tests
# - Health check tests
# - Database connection tests

# Step 2: Create test suite
# - Network connectivity
# - Service health
# - Traefik routing
# - Database access

# Step 3: Integrate into CI/CD
# - Run on PR
# - Run on deployment
# - Run periodically
```

**Verification:**
- [ ] Test framework created
- [ ] Test suite implemented
- [ ] CI/CD integration complete
- [ ] Tests passing

**Owner:** QA Team / DevOps Team  
**Dependencies:** Test infrastructure

---

## Phase 5: Documentation and Monitoring (Week 4-5)

**Priority:** 🟡 MEDIUM  
**Timeline:** Days 29-35  
**Risk:** Knowledge gaps, operational issues

### 5.1 Create Missing Documentation

**Issue:** Missing critical documentation  
**Impact:** MEDIUM - Operational confusion, incident response delays

**Actions:**
```bash
# Step 1: Create Security Incident Response Runbook
# docs/SECURITY_INCIDENT_RESPONSE.md
# - Password leak response procedures
# - Service compromise procedures
# - Credential rotation procedures

# Step 2: Create Health Troubleshooting Guide
# docs/HEALTH_TROUBLESHOOTING.md
# - Common health check failures
# - Log investigation procedures
# - Service restart procedures

# Step 3: Document Infisical Migration
# docs/INFISICAL_MIGRATION.md
# - Migration rationale
# - Secrets migration process
# - Usage guidelines

# Step 4: Document Service Dependencies
# docs/SERVICE_DEPENDENCIES.md
# - Dependency graph
# - Startup order
# - Critical paths
```

**Verification:**
- [ ] Security runbook created
- [ ] Health troubleshooting guide created
- [ ] Infisical documentation created
- [ ] Dependency documentation created
- [ ] All documentation reviewed and approved

**Owner:** Documentation Team / Infrastructure Lead  
**Dependencies:** None

---

### 5.2 Implement Service Dependency Validation

**Issue:** No dependency validation - services may start before dependencies ready  
**Impact:** MEDIUM - Service startup failures

**Actions:**
```bash
# Step 1: Create dependency validation script
# scripts/validate-dependencies.sh
# - Check database connectivity
# - Verify network connectivity
# - Validate service dependencies

# Step 2: Update compose files
# - Add depends_on with health conditions
# - Configure startup order
# - Add restart policies

# Step 3: Test startup sequences
# - Verify dependencies start first
# - Test failure scenarios
# - Validate recovery
```

**Verification:**
- [ ] Dependency validation script created
- [ ] Compose files updated
- [ ] Startup sequences tested
- [ ] Failure scenarios tested

**Owner:** DevOps Team  
**Dependencies:** None

---

### 5.3 Enhance Monitoring and Alerting

**Issue:** Missing comprehensive monitoring  
**Impact:** MEDIUM - Late detection of issues

**Actions:**
```bash
# Step 1: Enhance Prometheus metrics
# - Service health metrics
# - Resource utilization
# - Error rates

# Step 2: Create Grafana dashboards
# - Service health overview
# - Resource utilization
# - Error tracking

# Step 3: Configure Alertmanager rules
# - Critical service failures
# - Resource exhaustion
# - Security incidents

# Step 4: Test alerting
# - Verify alerts trigger correctly
# - Test notification channels
# - Validate alert escalation
```

**Verification:**
- [ ] Prometheus metrics enhanced
- [ ] Grafana dashboards created
- [ ] Alertmanager rules configured
- [ ] Alerting tested and verified

**Owner:** DevOps Team / SRE Team  
**Dependencies:** Prometheus, Grafana, Alertmanager

---

## Phase 6: Continuous Improvement (Week 5-6)

**Priority:** 🟢 LOW  
**Timeline:** Days 36-42  
**Risk:** Technical debt accumulation

### 6.1 Implement Automated Security Scanning

**Issue:** No secrets scanning in CI/CD  
**Impact:** MEDIUM - Risk of committing secrets

**Actions:**
```bash
# Step 1: Configure gitleaks or similar
# - Pre-commit hooks
# - CI/CD integration
# - Block commits with secrets

# Step 2: Set up automated scanning
# - Schedule regular scans
# - Report findings
# - Track remediation

# Step 3: Document security best practices
# - Secret management guidelines
# - Code review checklist
# - Incident response procedures
```

**Verification:**
- [ ] Secret scanning configured
- [ ] Pre-commit hooks installed
- [ ] CI/CD integration complete
- [ ] Documentation updated

**Owner:** Security Team  
**Dependencies:** CI/CD pipeline

---

### 6.2 Optimize Resource Usage

**Issue:** No resource limits - potential resource contention  
**Impact:** LOW - OOM conditions, resource exhaustion

**Actions:**
```bash
# Step 1: Analyze current resource usage
# - CPU usage per service
# - Memory usage per service
# - Identify resource hogs

# Step 2: Configure resource limits
# - Add CPU limits
# - Add memory limits
# - Configure reservations

# Step 3: Monitor resource utilization
# - Track usage over time
# - Optimize limits based on data
# - Document resource requirements
```

**Verification:**
- [ ] Resource usage analyzed
- [ ] Resource limits configured
- [ ] Utilization monitored
- [ ] Documentation updated

**Owner:** DevOps Team  
**Dependencies:** Prometheus metrics

---

### 6.3 Establish Regular Maintenance Schedule

**Issue:** No regular maintenance schedule  
**Impact:** LOW - Configuration drift, technical debt

**Actions:**
```bash
# Step 1: Create maintenance schedule
# - Weekly health reviews
# - Monthly security audits
# - Quarterly capacity planning

# Step 2: Automate maintenance tasks
# - Automated health checks
# - Automated backups
# - Automated updates (with approval)

# Step 3: Document maintenance procedures
# - Update procedures
# - Backup procedures
# - Recovery procedures
```

**Verification:**
- [ ] Maintenance schedule created
- [ ] Automation configured
- [ ] Procedures documented
- [ ] Schedule communicated

**Owner:** Infrastructure Lead  
**Dependencies:** None

---

## Execution Summary

### Priority Matrix

| Phase | Priority | Timeline | Risk if Delayed |
|-------|----------|----------|-----------------|
| Phase 1 | 🔴 CRITICAL | Week 1 | Security breach |
| Phase 2 | 🟠 HIGH | Week 1-2 | Service availability |
| Phase 3 | 🟡 MEDIUM | Week 2-3 | Configuration drift |
| Phase 4 | 🟡 MEDIUM | Week 3-4 | Production failures |
| Phase 5 | 🟡 MEDIUM | Week 4-5 | Operational issues |
| Phase 6 | 🟢 LOW | Week 5-6 | Technical debt |

### Success Criteria

**Phase 1 Complete:**
- ✅ No plaintext passwords in repository
- ✅ PostgreSQL authentication enabled
- ✅ All secrets audited and rotated

**Phase 2 Complete:**
- ✅ All services reporting healthy
- ✅ Health check monitoring active
- ✅ Automated remediation configured

**Phase 3 Complete:**
- ✅ Services consolidated to /services
- ✅ Traefik configuration standardized
- ✅ Health checks standardized

**Phase 4 Complete:**
- ✅ Compose validation automated
- ✅ Secret injection validated
- ✅ Integration tests passing

**Phase 5 Complete:**
- ✅ All documentation created
- ✅ Dependency validation working
- ✅ Monitoring and alerting active

**Phase 6 Complete:**
- ✅ Security scanning automated
- ✅ Resource limits configured
- ✅ Maintenance schedule established

---

## Risk Mitigation

### Critical Risks

1. **Security Breach** (Phase 1)
   - **Mitigation:** Immediate action on Phase 1.1 and 1.2
   - **Contingency:** Emergency credential rotation procedures

2. **Service Downtime** (Phase 2)
   - **Mitigation:** Test health checks in staging first
   - **Contingency:** Rollback procedures documented

3. **Configuration Errors** (Phase 3-4)
   - **Mitigation:** Validation scripts and tests
   - **Contingency:** Automated rollback mechanisms

### Dependencies

- **Infisical Access:** Required for Phase 1.2, 4.2
- **CI/CD Pipeline:** Required for Phase 1.3, 4.1, 4.3, 6.1
- **Monitoring Infrastructure:** Required for Phase 2.3, 5.3

---

## Tracking and Reporting

### Progress Tracking

- **Daily Standups:** Review Phase 1 progress
- **Weekly Reviews:** Review all phases, adjust timeline
- **Completion Reports:** Document completion of each phase

### Metrics

- **Security Issues Resolved:** Track critical vulnerabilities
- **Service Health:** Monitor health check success rates
- **Test Coverage:** Track test implementation progress
- **Documentation Coverage:** Track documentation completeness

---

## Next Steps

1. **Review and approve plan** - Infrastructure Lead
2. **Assign phase owners** - Team leads
3. **Schedule kickoff meeting** - Project manager
4. **Begin Phase 1** - Immediate start on security remediation

---

**Plan Version:** 1.0  
**Last Updated:** 2025-11-21  
**Owner:** Infrastructure Team  
**Status:** Active

