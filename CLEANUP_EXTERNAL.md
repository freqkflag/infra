# Cleanup External Services

## Summary of External Services Found

### 1. Dokploy Remnants
**Location:** `/etc/dokploy/compose/`
- Old LinkStack deployment
- Old Vault deployment (migrated)
- Old WikiJS deployment (migrated)

### 2. Ghost Production Setup
**Location:** `/root/ghost-production-compose.yml`
- Ghost CMS for cultofjoey.com
- Not currently running
- WordPress is now handling cultofjoey.com

### 3. Orphaned Docker Resources
- Old network: `freqkflagco-vault-7me6ws`
- 2 orphaned volumes (from old Vault setup)

## Cleanup Commands

### Remove Dokploy Remnants
```bash
# Verify services are running from infra
docker ps

# Remove old Dokploy compose directories
rm -rf /etc/dokploy/compose/cultofjoeycom-linkstack-n7oka4
rm -rf /etc/dokploy/compose/freqkflagco-vault-7me6ws
rm -rf /etc/dokploy/compose/freqkflagco-wikijs-dvchr8
```

### Remove Old Docker Network
```bash
docker network rm freqkflagco-vault-7me6ws
```

### Remove Orphaned Volumes
```bash
# Check volumes first
docker volume inspect 2a0a3bd07abe467f3f49afe09d2aa8172f5d91935feefd84e3bee5d5c1e01384
docker volume inspect 9c62e3e228fcf9638aebd0707934f719c4556230899461ed7f899a6a974b7470

# Remove if not in use
docker volume rm 2a0a3bd07abe467f3f49afe09d2aa8172f5d91935feefd84e3bee5d5c1e01384
docker volume rm 9c62e3e228fcf9638aebd0707934f719c4556230899461ed7f899a6a974b7470
```

### Handle Ghost Setup
```bash
# Option 1: Remove if WordPress replaces Ghost
rm /root/ghost-production-compose.yml

# Option 2: Migrate to infra if Ghost is still needed
mkdir -p /root/infra/ghost
mv /root/ghost-production-compose.yml /root/infra/ghost/docker-compose.yml
```

## Current Status

✅ **All active services are in `/root/infra/`:**
- traefik
- vault
- wordpress / wordpress-db
- wikijs / wikijs-db
- linkstack / linkstack-db

✅ **All configured services (ready to deploy):**
- mastadon
- n8n
- mailu
- supabase
- adminer

⚠️ **External items found:**
- Dokploy remnants (safe to remove)
- Ghost setup (decide: migrate or remove)
- Orphaned volumes (safe to remove if not in use)
- Old network (safe to remove)

