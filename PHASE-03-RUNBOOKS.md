# Phase 3: Per-Service Runbooks & Templates

**Date:** 2025-11-21  
**Status:** ✅ Complete

## Goal

Every service has a README/runbook with exact commands, context, and common fixes.

## Completed Tasks

### 1. Runbook Template ✅

Created `/root/infra/runbooks/TEMPLATE_SERVICE_RUNBOOK.md` with standardized fields:

- Purpose and URLs
- Quick start/stop commands
- Health checks
- Configuration details
- Common issues and fixes
- Backup/restore procedures
- Troubleshooting guides
- Security notes

### 2. Generated Runbooks for All Services ✅

Created individual runbooks for each service:

**Infrastructure Services:**
- `traefik-runbook.md` - Reverse proxy and SSL termination
- `infisical-runbook.md` - Secrets management
- `wikijs-runbook.md` - Documentation wiki
- `n8n-runbook.md` - Workflow automation
- `nodered-runbook.md` - Flow-based programming
- `adminer-runbook.md` - Database management
- `supabase-runbook.md` - Backend-as-a-Service
- `mailu-runbook.md` - Email server
- `monitoring-runbook.md` - Prometheus + Grafana
- `logging-runbook.md` - Loki + Promtail
- `backup-runbook.md` - Backup system

**Application Services:**
- `wordpress-runbook.md` - Personal brand website
- `linkstack-runbook.md` - Link-in-bio page
- `mastadon-runbook.md` - Social network instance

### 3. WikiJS Integration ✅

Created `/root/infra/runbooks/WIKIJS_INDEX.md` as the master index page for WikiJS.

**To import into WikiJS:**
1. Log into WikiJS at `https://wiki.freqkflag.co`
2. Create a new page: "Infrastructure Runbooks"
3. Copy content from `runbooks/WIKIJS_INDEX.md`
4. Link individual runbooks as needed

**Index Features:**
- Categorized by service type
- Quick command reference
- Links to all runbooks
- Service management commands

## Runbook Structure

Each runbook includes:

1. **Quick Reference** - Start/stop/restart commands
2. **Health Checks** - How to verify service is working
3. **Configuration** - Environment variables, volumes, networks
4. **Common Issues** - Known problems and fixes
5. **Backup & Restore** - Data protection procedures
6. **Updates & Maintenance** - How to keep services current
7. **Monitoring** - Key metrics and log locations
8. **Troubleshooting** - Step-by-step problem resolution
9. **Security** - Access control and secrets management

## Usage

### Access Runbooks

**From filesystem:**
```bash
cd /root/infra/runbooks
cat <service-id>-runbook.md
```

**From WikiJS:**
- Navigate to "Infrastructure Runbooks" page
- Click on service name to view runbook

### Update Runbooks

1. Edit the runbook file: `/root/infra/runbooks/<service-id>-runbook.md`
2. Update WikiJS page if imported
3. Update "Last Updated" date in runbook

### Generate New Runbooks

```bash
cd /root/infra
python3 scripts/generate-runbooks.py
```

## Done Criteria ✅

- ✅ Every service folder has a runbook that provides complete operational context
- ✅ WikiJS index page created as "Infra Manual" index
- ✅ Template available for future services
- ✅ All runbooks follow consistent structure

## Next Steps

- Import WikiJS index into WikiJS
- Link runbooks from Infrastructure Cookbook
- Add runbook links to service READMEs
- Create automated runbook validation

---

**Last Updated:** 2025-11-21

