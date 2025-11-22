# Service Consolidation Plan

**Created:** 2025-11-22  
**Last Updated:** 2025-11-22  
**Status:** Active Documentation

---

## Overview

This document provides a comprehensive audit of service locations and a migration plan to consolidate all services under the `/services/` directory structure for consistency and maintainability.

---

## Current Service Location Audit

### Services in Root Directory (`/root/infra/<service>/`)

| Service | Location | Compose File | Status | Notes |
|---------|----------|--------------|--------|-------|
| adminer | `./adminer/` | `docker-compose.yml` | ✅ Running | Should migrate to `services/adminer/` |
| gitlab | `./gitlab/` | `docker-compose.yml` | 🔄 Starting | Should migrate to `services/gitlab/` |
| infisical | `./infisical/` | `docker-compose.yml` | ✅ Running | Duplicate - also in `services/infisical/` |
| linkstack | `./linkstack/` | `docker-compose.yml` | ✅ Running | Duplicate - also in `services/linkstack/` |
| mailu | `./mailu/` | `docker-compose.yml` | ⚙️ Configured | Should migrate to `services/mailu/` |
| mastadon | `./mastadon/` | `docker-compose.yml` | ⚙️ Configured | Should migrate to `services/mastadon/` |
| n8n | `./n8n/` | `docker-compose.yml` | ✅ Running | Should migrate to `services/n8n/` |
| nodered | `./nodered/` | `docker-compose.yml` | ✅ Running | Should migrate to `services/node-red/` |
| supabase | `./supabase/` | `docker-compose.yml` | ✅ Running | Should migrate to `services/supabase/` |
| traefik | `./traefik/` | `docker-compose.yml` | ✅ Running | Duplicate - also in `services/traefik/` |
| vault | `./vault/` | `docker-compose.yml` | ⚙️ Configured | Should migrate to `services/vault/` |
| wikijs | `./wikijs/` | `docker-compose.yml` | ✅ Running | Duplicate - also in `services/wikijs/` |
| wordpress | `./wordpress/` | `docker-compose.yml` | ✅ Running | Duplicate - also in `services/wordpress/` |

### Services Already in `/services/` Directory

| Service | Location | Compose File | Status | Notes |
|---------|----------|--------------|--------|-------|
| backstage | `services/backstage/` | `compose.yml` | ✅ Running | ✅ Correct location |
| traefik | `services/traefik/` | `compose.yml` | ✅ Running | ✅ Correct location (duplicate in root) |
| infisical | `services/infisical/` | `compose.yml` | ✅ Running | ✅ Correct location (duplicate in root) |
| wikijs | `services/wikijs/` | `compose.yml` | ✅ Running | ✅ Correct location (duplicate in root) |
| wordpress | `services/wordpress/` | `compose.yml` | ✅ Running | ✅ Correct location (duplicate in root) |
| linkstack | `services/linkstack/` | `compose.yml` | ✅ Running | ✅ Correct location (duplicate in root) |
| node-red | `services/node-red/` | `compose.yml` | ✅ Running | ✅ Correct location |
| postgres | `services/postgres/` | `compose.yml` | ✅ Running | ✅ Correct location |
| mariadb | `services/mariadb/` | `compose.yml` | ✅ Running | ✅ Correct location |
| redis | `services/redis/` | `compose.yml` | ✅ Running | ✅ Correct location |
| kong | `services/kong/` | `compose.yml` | ✅ Running | ✅ Correct location |
| cloudflared | `services/cloudflared/` | `compose.yml` | ⚙️ Configured | ✅ Correct location |
| clamav | `services/clamav/` | `compose.yml` | ⚙️ Configured | ✅ Correct location |
| ghost | `services/ghost/` | `compose.yml` | ⚙️ Configured | ✅ Correct location |
| gitea | `services/gitea/` | `compose.yml` | ⚙️ Configured | ✅ Correct location |
| discourse | `services/discourse/` | `compose.yml` | ⚙️ Configured | ✅ Correct location |
| localai | `services/localai/` | `compose.yml` | ⚙️ Configured | ✅ Correct location |
| openwebui | `services/openwebui/` | `compose.yml` | ⚙️ Configured | ✅ Correct location |
| vaultwarden | `services/vaultwarden/` | `compose.yml` | ⚙️ Configured | ✅ Correct location |
| bookstack | `services/bookstack/` | `compose.yml` | ⚙️ Configured | ✅ Correct location |
| auxiliary | `services/auxiliary/` | `compose.yml` | ⚙️ Configured | ✅ Correct location |
| frontend | `services/frontend/` | `compose.yml` | ⚙️ Configured | ✅ Correct location |
| dev-tools | `services/dev-tools/` | `compose.yml` | ⚙️ Configured | ✅ Correct location |

### Special Directories (Not Services)

| Directory | Purpose | Action |
|-----------|---------|--------|
| `--help/` | Help service | Migrate to `services/help/` or remove |
| `backup/` | Backup scripts | Keep as-is (not a service) |
| `logging/` | Logging stack | Migrate to `services/logging/` |
| `monitoring/` | Monitoring stack | Migrate to `services/monitoring/` |
| `ops/` | Ops control plane | Migrate to `services/ops/` |
| `projects/` | Development projects | Keep as-is (not services) |
| `nodes/` | Node-specific configs | Keep as-is (deployment configs) |
| `.devcontainer/` | Dev container | Keep as-is (dev tooling) |

---

## Migration Strategy

### Phase 1: Document and Audit (✅ COMPLETED)

- [x] Audit all service locations
- [x] Identify duplicates
- [x] Document migration plan
- [x] Create this consolidation plan document

### Phase 2: Migrate Non-Duplicate Services

**Priority:** HIGH - Services not duplicated elsewhere

1. **adminer** → `services/adminer/compose.yml`
2. **gitlab** → `services/gitlab/compose.yml`
3. **mailu** → `services/mailu/compose.yml`
4. **mastadon** → `services/mastadon/compose.yml`
5. **n8n** → `services/n8n/compose.yml`
6. **nodered** → `services/node-red/compose.yml` (note: rename to node-red)
7. **supabase** → `services/supabase/compose.yml`
8. **vault** → `services/vault/compose.yml`

### Phase 3: Resolve Duplicates

**Priority:** MEDIUM - Services with duplicates in both locations

1. **traefik** - Keep `services/traefik/`, remove root `traefik/`
2. **infisical** - Keep `services/infisical/`, remove root `infisical/`
3. **wikijs** - Keep `services/wikijs/`, remove root `wikijs/`
4. **wordpress** - Keep `services/wordpress/`, remove root `wordpress/`
5. **linkstack** - Keep `services/linkstack/`, remove root `linkstack/`

### Phase 4: Migrate Special Directories

**Priority:** LOW - Infrastructure services

1. **logging** → `services/logging/compose.yml`
2. **monitoring** → `services/monitoring/compose.yml`
3. **ops** → `services/ops/compose.yml`
4. **--help** → `services/help/compose.yml` or remove

---

## Migration Procedure

### Step-by-Step Migration Process

1. **Stop the service** (if running):
   ```bash
   cd /root/infra/<old-location>
   docker compose down
   ```

2. **Copy service files**:
   ```bash
   mkdir -p /root/infra/services/<service-name>
   cp -r /root/infra/<old-location>/* /root/infra/services/<service-name>/
   ```

3. **Rename compose file** (if needed):
   ```bash
   cd /root/infra/services/<service-name>
   mv docker-compose.yml compose.yml  # Standardize naming
   ```

4. **Update paths in compose file**:
   - Update `env_file` paths: `../../.workspace/.env` (if needed)
   - Update volume paths (relative paths)
   - Update network references

5. **Update orchestrator references**:
   - Update `compose.orchestrator.yml` if service is referenced
   - Update any deployment scripts

6. **Test deployment**:
   ```bash
   cd /root/infra/services/<service-name>
   docker compose config  # Validate syntax
   docker compose up -d    # Test deployment
   ```

7. **Verify service health**:
   ```bash
   docker compose ps
   docker compose logs
   ```

8. **Update documentation**:
   - Update `AGENTS.md` with new location
   - Update `README.md` if needed
   - Update any service-specific documentation

9. **Remove old location** (after verification):
   ```bash
   # Backup first
   mv /root/infra/<old-location> /root/infra/<old-location>.backup
   
   # After 7 days of successful operation, remove backup
   rm -rf /root/infra/<old-location>.backup
   ```

---

## Dependencies and Considerations

### Service Dependencies

- **Database services** (postgres, mariadb, redis) must be migrated first
- **Traefik** must remain available during migration
- **Infisical** must be available for secret injection

### Network Considerations

- All services use `edge` network (external)
- Network configuration should remain unchanged
- Service discovery via container names may need updates

### Volume Considerations

- Docker volumes are named and persistent
- Volume names should remain consistent
- Data migration not required (volumes are shared)

### Environment Variables

- All services use `.workspace/.env` via `env_file`
- Path updates: `../../.workspace/.env` (from `services/<service>/`)
- No changes needed to environment variable names

---

## Migration Checklist Template

For each service migration:

- [ ] Service stopped and verified
- [ ] Files copied to `services/<service-name>/`
- [ ] Compose file renamed to `compose.yml`
- [ ] Paths updated in compose file
- [ ] Orchestrator references updated
- [ ] Compose syntax validated (`docker compose config`)
- [ ] Service deployed and tested
- [ ] Health checks verified
- [ ] Documentation updated
- [ ] Old location backed up
- [ ] Old location removed (after verification period)

---

## Risk Mitigation

### Rollback Procedure

If migration fails:

1. Stop migrated service:
   ```bash
   cd /root/infra/services/<service-name>
   docker compose down
   ```

2. Restore from old location:
   ```bash
   cd /root/infra/<old-location>
   docker compose up -d
   ```

3. Verify service restored:
   ```bash
   docker compose ps
   docker compose logs
   ```

### Backup Strategy

- Create backup before migration:
  ```bash
  cp -r /root/infra/<old-location> /root/infra/<old-location>.backup
  ```

- Keep backup for 7 days after successful migration
- Remove backup after verification period

---

## Timeline

### Immediate (Zero Cost - Documentation)

- ✅ Service location audit completed
- ✅ Migration plan documented
- ✅ This consolidation plan created

### Short Term (Low Risk Migrations)

- Week 1: Migrate non-duplicate services (adminer, gitlab, mailu, mastadon, n8n, nodered, supabase, vault)
- Week 2: Resolve duplicates (traefik, infisical, wikijs, wordpress, linkstack)

### Medium Term (Infrastructure Services)

- Week 3: Migrate special directories (logging, monitoring, ops, help)

---

## Success Criteria

- [ ] All services located in `services/` directory
- [ ] No duplicate service definitions
- [ ] All compose files named `compose.yml` (standardized)
- [ ] All services using `env_file: ../../.workspace/.env`
- [ ] All orchestrator references updated
- [ ] All documentation updated
- [ ] All services tested and verified healthy
- [ ] Old service locations removed

---

## References

- **Main Documentation:** `AGENTS.md` - Service catalog and locations
- **Remediation Plan:** `REMEDIATION_PLAN.md` - Phase 3.1 service consolidation
- **Compose Standards:** `infra-build-plan.md` - Compose file standards
- **Environment Loading:** `docs/COMPOSE_ENV_LOADING.md` - Environment variable patterns

---

**Last Updated:** 2025-11-22  
**Maintained By:** Infrastructure Team / DevOps Team

