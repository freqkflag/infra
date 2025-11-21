# Infrastructure Scan Summary

**Date:** 2025-11-20
**Status:** ✅ All active services are properly managed in `/root/infra/`

## ✅ Services Currently Running (All in Infra)

| Service | Container(s) | Status | Location |
|---------|-------------|--------|----------|
| Traefik | traefik | Running | `/root/infra/traefik/` |
| Vault | vault | Running | `/root/infra/vault/` |
| WordPress | wordpress, wordpress-db | Running | `/root/infra/wordpress/` |
| WikiJS | wikijs, wikijs-db | Running | `/root/infra/wikijs/` |
| LinkStack | linkstack, linkstack-db | Running | `/root/infra/linkstack/` |

## 📋 Services Configured (Ready to Deploy)

| Service | Location | Domain |
|---------|----------|--------|
| Mastodon | `/root/infra/mastadon/` | twist3dkinkst3r.com |
| n8n | `/root/infra/n8n/` | n8n.freqkflag.co |
| Mailu | `/root/infra/mailu/` | mail.freqkflag.co |
| Supabase | `/root/infra/supabase/` | supabase.freqkflag.co |
| Adminer | `/root/infra/adminer/` | adminer.freqkflag.co |

## ⚠️ External Items Found (Outside Infra)

### 1. Dokploy Remnants
**Location:** `/etc/dokploy/compose/`
- `cultofjoeycom-linkstack-n7oka4` - Old LinkStack (migrated)
- `freqkflagco-vault-7me6ws` - Old Vault (migrated)
- `freqkflagco-wikijs-dvchr8` - Old WikiJS (migrated)

**Action:** Safe to remove - services are running from infra

### 2. Ghost Production Setup
**Location:** `/root/ghost-production-compose.yml`
- Ghost CMS for cultofjoey.com
- Not currently running
- WordPress is handling cultofjoey.com now

**Action:** Decide:
- Remove if WordPress replaces Ghost
- Migrate to `/root/infra/ghost/` if Ghost is still needed

### 3. Ghost Theme Development
**Location:** `/root/cult-of-joey-ghost-theme/`
- Development environment
- Not a running service

**Action:** Keep if actively developing, archive otherwise

### 4. Orphaned Docker Resources

**Network:**
- `freqkflagco-vault-7me6ws` - Old Vault network (not in use)

**Volumes:**
- `freqkflagco-vault-7me6ws_vault-data` - Old Vault data (not in use)
- `2a0a3bd07abe467f3f49afe09d2aa8172f5d91935feefd84e3bee5d5c1e01384` - Orphaned
- `9c62e3e228fcf9638aebd0707934f719c4556230899461ed7f899a6a974b7470` - Orphaned

**Action:** Safe to remove - not in use by any containers

## 🧹 Quick Cleanup Script

```bash
#!/bin/bash
# Cleanup external services and resources

echo "Cleaning up external services..."

# Remove Dokploy remnants
echo "Removing Dokploy remnants..."
rm -rf /etc/dokploy/compose/cultofjoeycom-linkstack-n7oka4
rm -rf /etc/dokploy/compose/freqkflagco-vault-7me6ws
rm -rf /etc/dokploy/compose/freqkflagco-wikijs-dvchr8

# Remove old Docker network
echo "Removing old network..."
docker network rm freqkflagco-vault-7me6ws 2>/dev/null || echo "Network already removed"

# Remove orphaned volumes
echo "Removing orphaned volumes..."
docker volume rm freqkflagco-vault-7me6ws_vault-data 2>/dev/null || echo "Volume already removed"
docker volume rm 2a0a3bd07abe467f3f49afe09d2aa8172f5d91935feefd84e3bee5d5c1e01384 2>/dev/null || echo "Volume already removed"
docker volume rm 9c62e3e228fcf9638aebd0707934f719c4556230899461ed7f899a6a974b7470 2>/dev/null || echo "Volume already removed"

echo "Cleanup complete!"
```

## 📊 Infrastructure Overview

### Domains Managed

**Infrastructure (`freqkflag.co`):**
- `wiki.freqkflag.co` - WikiJS ✅
- `vault.freqkflag.co` - Vault ✅
- `n8n.freqkflag.co` - n8n (configured)
- `mail.freqkflag.co` - Mailu Admin (configured)
- `webmail.freqkflag.co` - Mailu Webmail (configured)
- `supabase.freqkflag.co` - Supabase Studio (configured)
- `api.supabase.freqkflag.co` - Supabase API (configured)
- `adminer.freqkflag.co` - Adminer (configured)

**Personal Brand (`cultofjoey.com`):**
- `cultofjoey.com` - WordPress ✅
- `link.cultofjoey.com` - LinkStack ✅

**Business (`twist3dkink.com`):**
- (No services currently)

**Community (`twist3dkinkst3r.com`):**
- `twist3dkinkst3r.com` - Mastodon (configured)

## ✅ Conclusion

**All active services are properly managed in `/root/infra/`**

The only external items are:
1. Old Dokploy remnants (safe to remove)
2. Ghost setup (needs decision: migrate or remove)
3. Orphaned Docker resources (safe to remove)

**Recommendation:** Run cleanup script to remove Dokploy remnants and orphaned resources. Decide on Ghost setup separately.

