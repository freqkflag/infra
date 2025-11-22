# Infrastructure Remediation Plan

**Created:** 2025-11-21  
**Last Updated:** 2025-11-22 (Reviewed for current infra status and agent prompts)  
**Status:** Active - Phase 1 nearly complete (pending Infisical capture), Phase 2 validated, Phases 3-6 pending execution  
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

**Current Progress:**  
- [x] Secrets removal, audit, and documentation mostly complete; Infisical ingestion pending.  
- [x] PostgreSQL auth now scram-sha-256 and connected services healthy (Phase 1.2).  
- [x] Secrets audit flagged weak passwords still in templates (Phase 1.3) and next-phase actions queued.  

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
- [x] New strong passwords generated ✅
  - VPS root: New 32-character base64 password generated
  - Homelab/Mac Mini: New 32-character base64 password generated
- [x] Scripts updated to remove hardcoded passwords ✅
  - `reset-ghost-password.js` updated to require password argument
- [x] Rotation documentation created ✅
  - `docs/CREDENTIAL_ROTATION.md` created with full rotation procedure
- [ ] Passwords stored in Infisical ⚠️ **ACTION REQUIRED**
- [ ] Passwords rotated on systems ⚠️ **MANUAL ACTION REQUIRED**
  - VPS root password rotation - **PENDING MANUAL UPDATE**
  - Homelab password rotation - **PENDING MANUAL UPDATE**
  - Mac Mini password rotation - **PENDING MANUAL UPDATE**

**Status:** 🔄 IN PROGRESS (2025-11-21)  
**Commit:** 12b7f17 - `security: remove plaintext passwords from SSH config`  
**New Passwords Generated:** 2025-11-21  
**Documentation:** See `docs/CREDENTIAL_ROTATION.md` for rotation procedure  
**Next Steps:** 
1. Store new passwords in Infisical (via web UI or CLI)
2. Rotate passwords on each system (VPS, Homelab, Mac Mini) using rotation guide
3. Verify old passwords no longer work
4. Update remediation plan once rotation complete

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
- [x] PostgreSQL restarted to apply changes ✅ (2025-11-21)
- [x] All connection strings updated - **NO CHANGES NEEDED** (using environment variables) ✅
- [x] Database connections tested successfully ✅
  - Services reconnected successfully after restart
  - n8n, WikiJS, Infisical, and other PostgreSQL-dependent services are healthy
- [x] Dependent services restarted and verified ✅
  - All PostgreSQL-dependent services (n8n, WikiJS, Infisical) are running and healthy

**Status:** ✅ COMPLETED (2025-11-21)  
**Commits:** 
- `05a0970` - `security: enable PostgreSQL scram-sha-256 authentication`
- `a1f0d13` - `security: enable PostgreSQL scram-sha-256 authentication`  
**Action Taken:** PostgreSQL was restarted on 2025-11-21 via `DEVTOOLS_WORKSPACE=/root/infra docker compose -f compose.orchestrator.yml restart postgres`  
**Result:** ✅ Authentication enforcement active; all services reconnected successfully

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
  - Commits: a9638894, deb5c065, c3b3763f, 1062007524
- [x] Weak default passwords identified in templates ✅
  - `postgrespassword` (base.env.example)
  - `infra_password` (base.env.example)
  - `redispassword` (base.env.example)
  - Multiple service-specific weak passwords in vps.env.example
- [x] Environment templates update started ✅
  - Commit: `aa6b031` - `security: replace weak default passwords with placeholders in templates`
  - **⚠️ ACTION REQUIRED:** Templates still contain weak passwords and need to be fully replaced with placeholders
- [ ] Secrets scanning configured - **DEFERRED TO PHASE 6**

**Status:** 🔄 IN PROGRESS (2025-11-21)  
**Findings:**
- Weak passwords still present in `env/templates/base.env.example`:
  - POSTGRES_PASSWORD=postgrespassword
  - MARIADB_PASSWORD=infra_password
  - REDIS_PASSWORD=redispassword
- Weak passwords still present in `env/templates/vps.env.example`:
  - Multiple service-specific passwords (ghost_password, wordpress_password, wikijs_password, discourse_password, linkstack_password, gitea_password, etc.)

**Next Steps:**
1. **URGENT:** Complete replacement of weak passwords with placeholders (e.g., `POSTGRES_PASSWORD=CHANGE_ME_STRONG_PASSWORD`, `MARIADB_PASSWORD=CHANGE_ME_STRONG_PASSWORD`)
2. Document password requirements and complexity rules
3. Ensure production uses Infisical exclusively (verify no services use template passwords)
4. Implement secrets scanning in CI/CD (Phase 6.1)

**Owner:** Security Team  
**Dependencies:** CI/CD pipeline access

**Phase 1 Agent Prompt:**  
`Act as ai.engine security-agent. Validate Phase 1 credentials/Infisical coverage and secrets audit gaps, then update REMEDIATION_PLAN.md with findings. Command: cd /root/infra/ai.engine/scripts && ./invoke-agent.sh security`

---

## Phase 2: Service Health Check Stabilization (Week 1-2)

**Priority:** 🟠 HIGH  
**Timeline:** Days 4-10  
**Risk:** Service availability, monitoring accuracy

**Current Progress:**  
- [x] Health checks reconfigured and verified (Traefik, WikiJS, WordPress, Node-RED, Adminer, Infisical, n8n) as of 2025-11-21.  
- [ ] Traefik ping endpoint fix pending - process check still in use.  
- [ ] Health monitoring automation (metrics, alerts, remediation script) not yet implemented.

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
- [x] All health checks verified manually ✅
  - Traefik: ✅ Healthy (process-based check)
  - WikiJS: ✅ Healthy (HTTP check)
  - WordPress: ✅ Healthy (HTTP check)
  - Node-RED: ✅ Healthy (HTTP check)
  - Adminer: ✅ Healthy (process-based check)
  - Infisical: ✅ Healthy (HTTP check `/api/status`)
  - n8n: ✅ Healthy (process-based check)
- [x] Services report healthy after start period ✅
  - All services confirmed healthy as of 2025-11-21
- [x] Health check failures documented and resolved ✅
  - Health checks fixed in commits: `a298d08`, `5f58b64`
  - All services now using appropriate health check methods

**Status:** ✅ COMPLETED (2025-11-21)  
**Commits:**
- `a298d08` - `docs: update AGENTS.md and orchestration-report.md with health check remediation details`
- `5f58b64` - `Update: Modify healthcheck commands in docker-compose.yml and various service compose files for improved reliability`

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

**Phase 2 Agent Prompt:**  
`Act as ai.engine status-agent. Confirm all health checks remain healthy, document monitoring gaps, and propose automation steps for metrics/alerts. Command: cd /root/infra/ai.engine/scripts && ./invoke-agent.sh status`

---

## Phase 3: Infrastructure Standardization (Week 2-3)

**Priority:** 🟡 MEDIUM  
**Timeline:** Days 11-21  
**Risk:** Configuration drift, maintenance burden

**Current Progress:**  
- [x] Backstage service skeleton deployed under `/root/infra/services/backstage/` with Traefik, PostgreSQL, and Infisical integration (per `server-changelog.md` entry); Docker build currently running but requires path adjustments before artifact creation.  
- [ ] Backstage database container repeatedly restarts because `.workspace/.env` lacks `BACKSTAGE_DB_PASSWORD`, `INFISICAL_CLIENT_ID`, and `INFISICAL_CLIENT_SECRET`; Infisical wiring must inject these secrets before the build can finish.  
- [ ] Service location audit and consolidation plan not started yet; existing root-level services still in place.  
- [ ] Traefik configuration deduplication and health-check standardization work queued.

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

**Phase 3 Agent Prompt:**  
`Act as ai.engine compose-engineer. Audit service locations (including Backstage), capture drift, and recommend consolidation steps plus Traefik label templating updates. Command: cd /root/infra/ai.engine/scripts && ./invoke-agent.sh compose-engineer`

---

## Phase 4: Testing and Validation (Week 3-4)

**Priority:** 🟡 MEDIUM  
**Timeline:** Days 22-28  
**Risk:** Production failures, deployment issues

**Current Progress:**  
- [ ] Compose validation script not yet created; preflight remains unchanged.  
- [ ] Secret injection validation still pending; Infisical service coverage needs automated proof.  
- [ ] Integration test suite unstarted; service interplay verification still manual.

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

**Phase 4 Agent Prompt:**  
`Act as ai.engine tests-agent. Evaluate current validation gaps, propose compose/integration tests and secret injection checks, then document findings in REMEDIATION_PLAN.md. Command: cd /root/infra/ai.engine/scripts && ./invoke-agent.sh tests`

---

## Phase 5: Documentation and Monitoring (Week 4-5)

**Priority:** 🟡 MEDIUM  
**Timeline:** Days 29-35  
**Risk:** Knowledge gaps, operational issues

**Current Progress:**  
- [x] Backstage README and config docs created (per `services/backstage/README.md`); shares Infisical usage instructions with sample `entities-with-infisical.yaml`.  
- [ ] Security runbook, health troubleshooting, and dependency documents still missing.  
- [ ] Monitoring enhancements (Prometheus/Grafana) not yet configured beyond existing dashboards.

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

**Phase 5 Agent Prompt:**  
`Act as ai.engine docs-agent. Capture documentation gaps (security runbook, health guide, dependencies), annotate Backstage references, and recommend monitoring artifacts updates in REMEDIATION_PLAN.md. Command: cd /root/infra/ai.engine/scripts && ./invoke-agent.sh docs`

---

## Phase 6: Continuous Improvement (Week 5-6)

**Priority:** 🟢 LOW  
**Timeline:** Days 36-42  
**Risk:** Technical debt accumulation

**Current Progress:**  
- [ ] Automated security scanning not configured; gitleaks integration absent.  
- [ ] Resource limits and monitoring continue at defaults.  
- [ ] Maintenance schedule still informal; rely on manual checklists.

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

**Phase 6 Agent Prompt:**  
`Act as ai.engine orchestrator-agent. Review continuous-improvement backlog, note missing automation/maintenance tasks, and update REMEDIATION_PLAN.md with recommended next actions. Command: cd /root/infra/ai.engine/scripts && ./invoke-agent.sh orchestrator`

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
- ✅ No plaintext passwords in repository - **COMPLETED** (2025-11-21)
- ✅ PostgreSQL authentication enabled - **COMPLETED** (2025-11-21) ✅ **RESTARTED AND VERIFIED**
- 🔄 All secrets audited and rotated - **IN PROGRESS** (template update incomplete, credentials rotation pending)

**Phase 2 Complete:**
- ✅ All services reporting healthy - **COMPLETED** (2025-11-21)
- 📋 Health check monitoring active - **DEFERRED TO PHASE 5**
- 📋 Automated remediation configured - **DEFERRED TO PHASE 5**

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

### Immediate Actions (Phase 1 - URGENT)

1. **🟠 HIGH: Complete credential rotation** ⚠️ **IN PROGRESS**
   - ✅ New strong passwords generated (2025-11-21)
   - ✅ Scripts updated (reset-ghost-password.js)
   - ✅ Rotation documentation created (`docs/CREDENTIAL_ROTATION.md`)
   - ⚠️ **ACTION REQUIRED:** 
     - Store new passwords in Infisical (via web UI: https://infisical.freqkflag.co)
     - Rotate VPS root password: `passwd root` on 62.72.26.113
     - Rotate Homelab password: `passwd` for user freqkflag on 192.168.12.102
     - Rotate Mac Mini password: `passwd` for user freqkflag on maclab.twist3dkink.online
   - **Security Risk:** HIGH - Old credentials still active until rotation complete
   - **Reference:** See `docs/CREDENTIAL_ROTATION.md` for detailed procedure

2. **🟠 HIGH: Complete template password replacement** ⚠️ **IN PROGRESS**
   - Replace all weak passwords in `env/templates/base.env.example`:
     - `POSTGRES_PASSWORD=postgrespassword` → `POSTGRES_PASSWORD=CHANGE_ME_STRONG_PASSWORD`
     - `MARIADB_PASSWORD=infra_password` → `MARIADB_PASSWORD=CHANGE_ME_STRONG_PASSWORD`
     - `REDIS_PASSWORD=redispassword` → `REDIS_PASSWORD=CHANGE_ME_STRONG_PASSWORD`
   - Replace all weak passwords in `env/templates/vps.env.example`:
     - All service-specific passwords (ghost_password, wordpress_password, etc.) → `CHANGE_ME_STRONG_PASSWORD`
   - Document password requirements (complexity rules, length, special characters)
   - Verify production does not use template passwords

3. **✅ COMPLETED: Restart PostgreSQL** ✅ **DONE** (2025-11-21)
   - PostgreSQL restarted successfully
   - All services reconnected and verified healthy

### Ongoing Actions

4. **Begin Phase 3** - Infrastructure standardization (services consolidation, Traefik config standardization)
5. **Plan Phase 5** - Health check monitoring integration with Prometheus/Grafana
6. **Review and approve plan** - Infrastructure Lead
7. **Assign phase owners** - Team leads

---

## Phase 1 Progress Summary

**Status:** 🔄 IN PROGRESS (2025-11-21)  
**Completion:** 2.5/3 tasks completed

### Completed Tasks ✅
1. **Phase 1.1: Remove Plaintext Passwords** - 🔄 IN PROGRESS (4/6 tasks)
   - Commit: `12b7f17` - `security: remove plaintext passwords from SSH config`
   - Passwords removed, .ssh added to .gitignore ✅
   - Git history audited ✅
   - New strong passwords generated ✅
   - Scripts updated (reset-ghost-password.js) ✅
   - Rotation documentation created ✅
   - **⚠️ ACTION REQUIRED:** 
     - Store passwords in Infisical
     - Rotate passwords on systems (VPS, Homelab, Mac Mini)
   - **Reference:** See `docs/CREDENTIAL_ROTATION.md`

2. **Phase 1.2: Enable PostgreSQL Authentication** - ✅ COMPLETED
   - Commits: `05a0970`, `a1f0d13` - `security: enable PostgreSQL scram-sha-256 authentication`
   - Authentication method changed to scram-sha-256
   - PostgreSQL restarted successfully (2025-11-21)
   - All services reconnected and verified healthy

### In Progress Tasks 🔄
3. **Phase 1.3: Secrets Audit and Rotation** - 🔄 IN PROGRESS
   - Environment files audited ✅
   - Git history scanned ✅
   - Weak passwords identified in templates ✅
   - Template update started (commit: `aa6b031`) but **NOT COMPLETE**
   - **Action Required:** 
     - Complete replacement of weak passwords with placeholders in templates
     - Document password requirements
     - Rotate exposed credentials (Warren7882??, 7882)

## Phase 2 Progress Summary

**Status:** ✅ COMPLETED (2025-11-21)  
**Completion:** 1/3 tasks completed

### Completed Tasks ✅
1. **Phase 2.1: Verify Health Check Configurations** - ✅ COMPLETED
   - All services verified healthy
   - Health check configurations fixed and working
   - Commits: `a298d08`, `5f58b64`

### Pending Tasks 📋
2. **Phase 2.2: Fix Traefik Ping Endpoint** - 📋 OPTIONAL ENHANCEMENT
   - Low priority, current process-based check working
   
3. **Phase 2.3: Implement Health Check Monitoring** - 📋 DEFERRED
   - Planned for Phase 5 integration with Prometheus/Grafana

---

**Plan Version:** 1.2  
**Last Updated:** 2025-11-21 (Phase 1 & 2 Status Update)  
**Owner:** Infrastructure Team  
**Status:** Active - Phase 1 in progress (2.5/3 tasks), Phase 2 completed (1/3 tasks)

### Recent Updates (2025-11-21)
- ✅ Phase 1.2 completed: PostgreSQL authentication enabled and restarted, all services verified healthy
- ✅ Phase 2.1 completed: All service health checks verified and working correctly
- 🔄 Phase 1.3 in progress: Template password replacement started but needs completion
- 🔄 Phase 1.1 in progress: New passwords generated, documentation created, manual rotation required
- ⚠️ CRITICAL: System password rotation pending (see `docs/CREDENTIAL_ROTATION.md`)
