# Infisical Setup Issues

**Date:** 2025-11-20  
**Status:** ⚠️ Configuration Issues

## Current Issues

### 1. Database Connection ✅ FIXED
- **Issue:** Password with special characters (`/` and `=`) breaking URL parsing
- **Fix:** URL-encoded password in connection string
- **Status:** ✅ Resolved

### 2. GitHub OAuth/SSO Not Configured ⚠️ LOW PRIORITY
- **Issue:** Error when attempting GitHub login: "Unknown authentication strategy github, no strategy with this name has been registered"
- **Error:** HTTP 500 when accessing `/api/v1/sso/redirect/github`
- **Status:** ⚠️ Non-critical - Email/password login works fine
- **Impact:** LOW - Users cannot use GitHub OAuth login, but standard login works
- **Options:**
  1. **Configure GitHub OAuth** (if you want GitHub login):
     - Create GitHub OAuth App: https://github.com/settings/developers
     - Add environment variables to `docker-compose.yml`:
       - `GITHUB_CLIENT_ID`
       - `GITHUB_CLIENT_SECRET`
       - `GITHUB_OAUTH_ENABLED=true`
     - Restart Infisical
  2. **Disable GitHub Login Button** (if not needed):
     - Disable in Infisical UI settings
     - Or leave as-is (button will show error if clicked)
- **Note:** This is a feature configuration issue, not a critical bug. The service is fully functional without GitHub OAuth.

### 3. Encryption Key Length ✅ FIXED
- **Issue:** "Invalid key length" error during migration
- **Error:** `RangeError: Invalid key length` in KMS encryption
- **Attempted Fixes:**
  - ✅ Tried base64 format (44 chars = 32 bytes) - Still fails
  - ✅ Tried hex format (64 chars = 32 bytes) - Still fails
  - ✅ Verified key generation produces correct lengths
- **Current Status:** Issue persists with both formats
- **Possible Causes:**
  - Infisical version bug (using `latest` tag)
  - Wrong environment variable names or format expectations
  - Missing required environment variables
  - Infisical expecting keys in a different encoding
- **Next Steps:**
  - Check Infisical GitHub repository for known issues
  - Try specific version tag instead of `latest`
  - Review official Infisical docker-compose.yml for correct format
  - Consider using Infisical's official setup as base

### 3. Service Not Starting
- **Issue:** Container starts but fails during migration
- **Symptom:** 404 errors, connection refused
- **Root Cause:** Migration failures prevent service from starting

## Next Steps

1. **Check Official Infisical Docker Compose**
   - Review official repository for correct environment variables
   - Verify required variables and formats

2. **Alternative: Use Official Docker Compose**
   - Download official docker-compose.yml from Infisical
   - Adapt to our Traefik setup

3. **Check Infisical Version**
   - Current: `infisical/infisical:latest`
   - Try specific version tag
   - Check if latest has breaking changes

## Temporary Workaround

For now, Infisical is configured but not running due to encryption key issues. 

**Options:**
1. Wait for official documentation/clarification on key requirements
2. Try different key formats (hex, raw bytes, different lengths)
3. Use Infisical's official docker-compose as base

## Files Created

- ✅ `docker-compose.yml` - Service definition
- ✅ `.env` - Environment variables (needs key format fix)
- ✅ `generate-secrets.sh` - Secret generation (updated to use hex format)
- ✅ `fix-encryption-keys.sh` - Script to regenerate keys in correct format
- ✅ `migrate-from-vault.sh` - Migration script
- ✅ `README.md` - Documentation

