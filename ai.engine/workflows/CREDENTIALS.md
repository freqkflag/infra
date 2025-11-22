# Automation Credentials

**Date:** 2025-11-22  
**Location:** Infisical `/prod` path

## n8n Credentials

**Web UI Login:**
- **Email/Username:** `admin@freqkflag.co`
- **Password:** `Warren7882??` (updated 2025-11-22)

**API Access:**
- **API Key:** `n8n_api_9a6147aa807de95a996ca3f99da1f8ffb4de87b575a944d6a49aa67816bbaea879169ab17508d79b`

**Basic Auth (for Traefik):**
- **Username:** `admin` (from `${N8N_USER:-admin}`)
- **Password:** Same as `N8N_PASSWORD` above

**Infisical Secrets:**
- `N8N_USER`: `admin@freqkflag.co`
- `N8N_PASSWORD`: `Warren7882??` (updated 2025-11-22)
- `N8N_API_KEY`: `n8n_api_9a6147aa807de95a996ca3f99da1f8ffb4de87b575a944d6a49aa67816bbaea879169ab17508d79b`

**Access URLs:**
- Web UI: `https://n8n.freqkflag.co`
- API: `https://n8n.freqkflag.co/api/v1/`
- Webhook: `https://n8n.freqkflag.co/webhook/{path}`

## Node-RED Credentials

**Web UI Login:**
- **Username:** `admin` (default, from Infisical `NODERED_USERNAME`)
- **Password Hash:** Stored as `NODERED_PASSWORD_HASH` in Infisical

**Infisical Secrets:**
- `NODERED_USERNAME`: `admin` (already in Infisical)
- `NODERED_PASSWORD_HASH`: `$2a$08$utTEjr8dFaZvpYJ7YsW0suAGGK1R1J0Q/lNsEqxSMgk2Gl4vFwV76` (already in Infisical)

**Note:** The password hash is for the default password. The actual password can be derived from the hash or reset in Node-RED settings.

**Access URLs:**
- Web UI: `https://nodered.freqkflag.co`
- API: `https://nodered.freqkflag.co/` (REST API)

## Password Reset Instructions

### n8n Password Reset

If you need to reset the n8n password:

1. **Via n8n UI:**
   - Login with current credentials
   - Go to Settings → Users
   - Change password

2. **Via Database (if UI not accessible):**
   ```bash
   docker exec -it n8n-db psql -U n8n -d n8n
   # Then update user password in database
   ```

3. **Update in Infisical:**
   - Update `N8N_PASSWORD` secret in Infisical
   - Update `.workspace/.env` (auto-synced by Infisical Agent)

### Node-RED Password Reset

1. **Via Node-RED UI:**
   - Login to Node-RED
   - Go to Settings → Security
   - Change password

2. **Generate New Hash:**
   ```bash
   # In Node-RED container
   docker exec nodered node -e "const bcrypt = require('bcryptjs'); bcrypt.hash('new-password', 8).then(hash => console.log(hash));"
   ```

3. **Update in Infisical:**
   - Update `NODERED_PASSWORD_HASH` secret in Infisical
   - Restart Node-RED container

## Security Recommendations

1. **Change Default Passwords:**
   - n8n password is currently `Admin123!@#` - consider changing
   - Node-RED password hash is default - consider changing

2. **Use Strong Passwords:**
   - Minimum 16 characters
   - Mix of upper/lower case, numbers, symbols
   - Don't reuse passwords

3. **Rotate Credentials:**
   - Change passwords regularly
   - Update in Infisical when changed
   - Keep credentials synchronized

## Current Status

✅ **n8n Credentials:**
- User: `admin@freqkflag.co`
- Password: `Admin123!@#` (stored in Infisical)
- API Key: Stored in Infisical

✅ **Node-RED Credentials:**
- Username: `admin` (stored in Infisical)
- Password Hash: Stored in Infisical

**Note:** These credentials are now stored in Infisical at `/prod` path and will be automatically synced to `.workspace/.env` via Infisical Agent.

