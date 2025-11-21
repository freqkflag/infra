# Ops Control Plane - Enhanced Deployment Guide

**Version:** 2.0.0  
**Status:** ✅ Ready for Deployment

## Quick Start

### 1. Install Dependencies

```bash
cd /root/infra/ops
npm install
```

### 2. Update Files

```bash
# Backup current files
cp server.js server.js.backup
cp public/index.html public/index.html.backup

# Deploy enhanced versions
cp server-enhanced.js server.js
cp package-enhanced.json package.json
cp public/index-enhanced.html public/index.html

# Ensure orchestration directory exists
mkdir -p /root/infra/orchestration
```

### 3. Configure Environment Variables

Update `.env` or `docker-compose.yml`:

```bash
# Basic Auth (default - still works)
OPS_AUTH_USER=admin
OPS_AUTH_PASS=your-secure-password

# OAuth (optional - for production)
OPS_OAUTH_ENABLED=false
OPS_OAUTH_PROVIDER=github
OPS_OAUTH_CLIENT_ID=your-client-id
OPS_OAUTH_CLIENT_SECRET=your-client-secret
OPS_OAUTH_CALLBACK_URL=https://ops.freqkflag.co/auth/callback
OPS_SESSION_SECRET=generate-a-random-secret-here
```

### 4. Rebuild and Restart

```bash
cd /root/infra/ops
docker compose down
docker compose build
docker compose up -d
```

### 5. Test Endpoints

```bash
./test-endpoints.sh admin your-secure-password
```

## Features Added

### ✅ Enhanced UI
- Tab-based interface
- Agent chat interface
- Task management panel
- Orchestrator control panel
- Command execution panel
- Infrastructure overview

### ✅ API Endpoints
- Agent communication (`/api/agents/*`)
- Task management (`/api/tasks/*`)
- Orchestrator execution (`/api/orchestrator/*`)
- Infrastructure commands (`/api/infra/*`)
- Real-time updates (SSE)

### ✅ Security
- Basic Auth (current)
- OAuth ready (structure in place)
- Command restrictions
- Input validation

## Configuration

### Basic Auth (Current)
```yaml
environment:
  OPS_AUTH_USER: admin
  OPS_AUTH_PASS: changeme  # CHANGE THIS!
```

### OAuth (Production)
1. Set up OAuth app with provider (GitHub, Google, etc.)
2. Configure environment variables
3. Update `server-enhanced.js` to enable OAuth middleware
4. Test authentication flow

## Testing

### Manual Testing

```bash
# Health check
curl https://ops.freqkflag.co/health

# List agents
curl -u admin:password https://ops.freqkflag.co/api/agents

# List services
curl -u admin:password https://ops.freqkflag.co/api/services
```

### Automated Testing

```bash
cd /root/infra/ops
./test-endpoints.sh admin password
```

## Rollback

If issues occur:

```bash
cd /root/infra/ops
docker compose down
cp server.js.backup server.js
cp public/index.html.backup public/index.html
docker compose up -d
```

## Troubleshooting

### Issue: "Cannot find module 'uuid'"
**Solution:** Run `npm install` in the ops directory

### Issue: "orchestration directory not found"
**Solution:** Create directory: `mkdir -p /root/infra/orchestration`

### Issue: "Authentication failed"
**Solution:** Check `OPS_AUTH_USER` and `OPS_AUTH_PASS` environment variables

### Issue: "Command not allowed"
**Solution:** Check command restrictions in `server-enhanced.js` - only infra and docker commands allowed

## Next Steps

1. ✅ Enhanced UI created
2. ✅ API endpoints tested
3. ⏭️ OAuth provider configuration (optional)
4. ⏭️ Production deployment
5. ⏭️ Monitoring and alerts

---

**Deployed:** 2025-11-21  
**Status:** ✅ Ready

