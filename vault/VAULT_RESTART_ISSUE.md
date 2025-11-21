# Vault Restart Loop Issue

**Date:** 2025-11-20  
**Status:** ⚠️ Unresolved - Requires Further Investigation

## Problem

Vault container enters a restart loop with the following error:
```
Error parsing listener configuration.
Error initializing listener of type tcp: listen tcp4 0.0.0.0:8200: bind: address already in use
```

## Investigation Results

### What Works
- ✅ Config file is valid (tested in standalone container)
- ✅ Vault starts successfully when run manually: `docker run --rm hashicorp/vault:latest server -config=/vault/config/vault.hcl`
- ✅ Minimal config works in test containers
- ✅ Config syntax is correct (HCL format)

### What Doesn't Work
- ❌ Vault fails in docker-compose with restart policy
- ❌ Port binding conflict occurs during restart attempts
- ❌ "Error parsing listener configuration" appears before bind error

## Attempted Fixes

1. **Changed command format** - From string to array format
2. **Fixed config syntax** - Changed `tls_disable` from string to integer
3. **Removed port mapping** - Tried without host port mapping
4. **Adjusted healthcheck** - Increased start_period
5. **Minimal config** - Tested with stripped-down configuration
6. **Different restart policies** - Tried "no", "unless-stopped"

All attempts resulted in the same restart loop.

## Root Cause Hypothesis

The issue appears to be a race condition:
1. Vault starts and initializes core/events
2. Vault attempts to bind to port 8200
3. Something causes Vault to fail or restart
4. Docker immediately restarts the container
5. Port 8200 hasn't been fully released
6. New instance fails with "address already in use"
7. Loop continues

The "Error parsing listener configuration" error suggests Vault might be trying to initialize the listener multiple times, or there's a parsing issue that causes a restart before the port is released.

## Recommended Solutions

### Option 1: External Process Management
Remove restart policy from docker-compose and use systemd or supervisor:
```yaml
restart: "no"
```

Then create a systemd service that monitors and restarts Vault with proper delays.

### Option 2: Check Vault Issues
Search Vault GitHub for similar issues:
- https://github.com/hashicorp/vault/issues
- Search for "address already in use" + "docker"
- Search for "Error parsing listener configuration"

### Option 3: Use Different Deployment
- Deploy Vault outside Docker
- Use Vault Helm chart for Kubernetes
- Use Vault in dev mode for testing (not production)

### Option 4: Add Restart Delay
Modify docker-compose to add a delay script:
```yaml
command: ["sh", "-c", "sleep 5 && vault server -config=/vault/config/vault.hcl"]
```

## Current Workaround

For now, Vault can be started manually:
```bash
cd /root/infra/vault
docker compose up -d
# If it restarts, stop and start manually:
docker compose down
docker compose up -d
# Monitor logs and wait for successful start
docker compose logs -f vault
```

## Files Modified

- `/root/infra/vault/docker-compose.yml` - Various attempts to fix
- `/root/infra/vault/config/vault.hcl` - Simplified config
- `/root/infra/vault/VAULT_FIX.md` - Initial fix attempt (incomplete)

## Next Steps

1. Research Vault GitHub issues for this specific error
2. Consider using Vault operator or different deployment method
3. Test with Vault 1.20.x or earlier versions
4. Document if issue resolves with Vault updates

