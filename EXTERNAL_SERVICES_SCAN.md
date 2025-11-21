# External Services Scan Report

**Date:** 2025-11-20
**Scan Location:** System-wide scan for services outside `/root/infra/`

## Summary

Found several services and configurations outside the infra directory that need attention.

## Findings

### 1. Dokploy Remnants (`/etc/dokploy/compose/`)

**Location:** `/etc/dokploy/compose/`

**Found directories:**
- `cultofjoeycom-linkstack-n7oka4` - Old LinkStack deployment
- `freqkflagco-vault-7me6ws` - Old Vault deployment (migrated to infra)
- `freqkflagco-wikijs-dvchr8` - Old WikiJS deployment (migrated to infra)

**Status:** These are old Dokploy-managed deployments that have been migrated to infra.
**Action:** Can be safely removed after verifying services are running from infra.

### 2. Ghost Production Setup (`/root/ghost-production-compose.yml`)

**Location:** `/root/ghost-production-compose.yml`

**Details:**
- Ghost CMS deployment for `cultofjoey.com`
- Uses MySQL database
- Has Traefik labels configured
- References external volumes: `cult-of-joey-ghost-theme_ghost-data`, `cult-of-joey-ghost-theme_db-data`
- References external networks: `cult-of-joey-ghost-theme_ghost-network`, `dokploy-network`

**Status:** Currently not running (no containers found)
**Action:** 
- Option 1: Migrate to infra directory if Ghost is still needed
- Option 2: Remove if WordPress is replacing Ghost for cultofjoey.com

### 3. Ghost Theme Development (`/root/cult-of-joey-ghost-theme/`)

**Location:** `/root/cult-of-joey-ghost-theme/`

**Details:**
- Contains `docker-compose.dev.yml` for development
- Theme development directory
- Has documentation files

**Status:** Development environment, not a running service
**Action:** Keep if still developing Ghost theme, otherwise can archive

### 4. Orphaned Docker Volumes

**Volumes:**
- `2a0a3bd07abe467f3f49afe09d2aa8172f5d91935feefd84e3bee5d5c1e01384`
- `9c62e3e228fcf9638aebd0707934f719c4556230899461ed7f899a6a974b7470`

**Status:** Created Nov 20, 2025 - Likely from old Vault setup
**Action:** Can be removed if not in use (verify first)

### 5. System Services

**Port 53:** Systemd-resolved (local DNS resolver) - Normal system service, no action needed

## Current Running Services (All in Infra)

✅ All currently running services are properly managed in `/root/infra/`:
- traefik
- vault
- wordpress / wordpress-db
- wikijs / wikijs-db
- linkstack / linkstack-db

## Recommendations

### Immediate Actions

1. **Clean up Dokploy remnants:**
   ```bash
   # Verify services are running from infra first
   docker ps
   
   # Then remove old Dokploy directories
   rm -rf /etc/dokploy/compose/cultofjoeycom-linkstack-n7oka4
   rm -rf /etc/dokploy/compose/freqkflagco-vault-7me6ws
   rm -rf /etc/dokploy/compose/freqkflagco-wikijs-dvchr8
   ```

2. **Handle Ghost setup:**
   - If Ghost is still needed: Migrate to `/root/infra/ghost/`
   - If WordPress replaces Ghost: Remove Ghost compose file and volumes

3. **Clean up orphaned volumes:**
   ```bash
   # Check if volumes are in use
   docker volume inspect <volume-id>
   
   # Remove if not in use
   docker volume rm <volume-id>
   ```

### Optional Actions

1. **Archive Ghost theme development:**
   - Move to archive location if not actively developing
   - Or keep if still working on Ghost theme

2. **Remove Dokploy completely:**
   ```bash
   # If Dokploy is no longer used
   rm -rf /etc/dokploy
   ```

## Services Status

### ✅ Properly Managed in Infra
- Traefik
- Vault
- WordPress
- WikiJS
- LinkStack
- Mastodon (configured, not running)
- n8n (configured, not running)
- Mailu (configured, not running)
- Supabase (configured, not running)
- Adminer (configured, not running)

### ⚠️ Outside Infra (Needs Attention)
- Ghost production setup (`/root/ghost-production-compose.yml`)
- Dokploy remnants (`/etc/dokploy/`)
- Orphaned Docker volumes

### 📁 Development/Archive
- Ghost theme development (`/root/cult-of-joey-ghost-theme/`)

---

**Next Steps:** Review findings and decide on cleanup actions.

