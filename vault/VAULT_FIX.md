# Vault Restart Issue - Fixed

**Date:** 2025-11-20  
**Issue:** Vault container was in a restart loop with "address already in use" error

## Root Cause

The issue was caused by how the `command` was specified in `docker-compose.yml`. Using a string format:
```yaml
command: server -config=/vault/config/vault.hcl
```

This was causing Vault's entrypoint script to not properly handle the command, leading to port binding conflicts during restart attempts.

## Solution

Changed the command specification to use array format with explicit entrypoint:

```yaml
entrypoint: ["/usr/local/bin/docker-entrypoint.sh"]
command: ["server", "-config=/vault/config/vault.hcl"]
```

This ensures the Docker entrypoint script properly processes the command and prevents port binding conflicts.

## Additional Fixes

1. **Config syntax:** Changed `tls_disable = 1` to `tls_disable = "true"` for proper HCL syntax
2. **Restart policy:** Restored `restart: unless-stopped` after confirming fix works

## Verification

After the fix:
- ✅ Vault container starts successfully
- ✅ No restart loops
- ✅ Container is on `traefik-network`
- ✅ Health endpoint accessible via Traefik
- ✅ Routing check script shows Vault as accessible

## Status

**RESOLVED** - Vault is now running stably in production mode.

