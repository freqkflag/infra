# Web UI Credentials

**Date:** 2025-11-22  
**Status:** ✅ Credentials stored in Infisical

## n8n Web UI Login

**URL:** `https://n8n.freqkflag.co`

**Login Credentials:**
- **Email:** `admin@freqkflag.co`
- **Password:** `Warren7882??` (updated 2025-11-22)

**Stored in Infisical:**
- `N8N_USER`: `admin@freqkflag.co`
- `N8N_PASSWORD`: `Admin123!@#`
- `N8N_API_KEY`: `n8n_api_9a6147aa807de95a996ca3f99da1f8ffb4de87b575a944d6a49aa67816bbaea879169ab17508d79b`

**Note:** These credentials were set during initial n8n setup (2025-11-22). The password should be changed for security.

## Node-RED Web UI Login

**URL:** `https://nodered.freqkflag.co`

**Login Credentials:**
- **Username:** `admin`
- **Password:** Password hash stored in Infisical (password needs to be determined or reset)

**Stored in Infisical:**
- `NODERED_USERNAME`: `admin`
- `NODERED_PASSWORD_HASH`: `$2a$08$utTEjr8dFaZvpYJ7YsW0suAGGK1R1J0Q/lNsEqxSMgk2Gl4vFwV76`

**Note:** The password hash is stored, but the plain text password needs to be determined. If you cannot login, reset the password in Node-RED settings or via the settings.js file.

## Access Instructions

### n8n Access
1. Navigate to `https://n8n.freqkflag.co`
2. Login with:
   - Email: `admin@freqkflag.co`
   - Password: `Admin123!@#`
3. You will have access to workflows, credentials, and settings

### Node-RED Access
1. Navigate to `https://nodered.freqkflag.co`
2. Login with:
   - Username: `admin`
   - Password: Check Infisical or reset in Node-RED
3. You will have access to flows and settings

## Password Reset

### Reset n8n Password
1. Login to n8n with current credentials
2. Go to Settings → Users
3. Change password
4. Update `N8N_PASSWORD` in Infisical
5. Restart n8n container to apply changes

### Reset Node-RED Password
1. Login to Node-RED with current credentials
2. Go to Settings → Security
3. Change password
4. Generate new hash:
   ```bash
   docker exec nodered node -e "const bcrypt = require('bcryptjs'); bcrypt.hash('new-password', 8).then(hash => console.log(hash));"
   ```
5. Update `NODERED_PASSWORD_HASH` in Infisical
6. Restart Node-RED container

## Security Recommendations

1. **Change Default Passwords:**
   - n8n password is currently `Admin123!@#` - change this
   - Node-RED password should be strong

2. **Use Strong Passwords:**
   - Minimum 16 characters
   - Mix of upper/lower case, numbers, symbols
   - Don't reuse passwords

3. **Update Infisical:**
   - When passwords change, update Infisical immediately
   - Secrets will sync to `.workspace/.env` automatically

---

**Last Updated:** 2025-11-22  
**Infisical Path:** `/prod`

