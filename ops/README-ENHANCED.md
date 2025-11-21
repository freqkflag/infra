# Ops Control Plane - Enhanced Version

**Version:** 2.0.0  
**Domain:** `ops.freqkflag.co`  
**Status:** ✅ **READY FOR DEPLOYMENT**

## What's New

### Enhanced Features
- ✅ **Agent Communication** - Chat with all virtual agents through web interface
- ✅ **Task Management** - View, filter, and track tasks across all agents
- ✅ **Orchestrator Control** - Execute full analysis or individual agents
- ✅ **Command Execution** - Safe infrastructure command execution
- ✅ **Infrastructure Overview** - Real-time health metrics and statistics
- ✅ **OAuth Authentication** - GitHub OAuth support (Basic Auth fallback)

### Enhanced UI
- Tab-based interface (Dashboard, Agents, Tasks, Orchestrator, Commands)
- Real-time updates every 30 seconds
- Dark neon theme with improved UX
- Mobile-responsive design

### Enhanced API
- 25+ new API endpoints
- Agent communication endpoints
- Task management endpoints
- Orchestrator execution endpoints
- Infrastructure command endpoints
- Real-time SSE support (structure ready)

## Configuration

### OAuth Configuration (Active)

OAuth is now **enabled and configured** with GitHub:

```yaml
OPS_OAUTH_ENABLED: true
OPS_OAUTH_PROVIDER: github
OPS_OAUTH_CLIENT_ID: Ov23limlVzKVg7zjVrek
OPS_OAUTH_CLIENT_SECRET: 440c697fde6d0a2632831c4863fb6932934f53dc
OPS_OAUTH_CALLBACK_URL: https://ops.freqkflag.co/auth/callback
OPS_SESSION_SECRET: c7d53fae681e91b1a66bfd83a7441a60b09c8d04b02f29f0e856365ff06b327a
```

### Authentication Flow

1. **User visits** `https://ops.freqkflag.co`
2. **Redirected to GitHub** for OAuth login (`/auth/github`)
3. **GitHub callback** processes authentication (`/auth/callback`)
4. **Session created** and user redirected to dashboard
5. **Logout** available at `/auth/logout`

**Fallback:** Basic Auth still works for API calls

## Deployment

### Quick Deploy

```bash
cd /root/infra/ops

# 1. Install dependencies (already done)
npm install

# 2. Deploy enhanced files
cp server-enhanced.js server.js
cp public/index-enhanced.html public/index.html

# 3. Ensure orchestration directory exists
mkdir -p /root/infra/orchestration

# 4. Rebuild and restart
docker compose down
docker compose build
docker compose up -d

# 5. Check logs
docker logs ops-control-plane -f

# Look for: "OAuth authentication enabled with github"
```

### Verify Deployment

```bash
# Test health endpoint
curl https://ops.freqkflag.co/health

# Test OAuth redirect (should redirect to GitHub)
curl -I https://ops.freqkflag.co

# Check container status
docker ps | grep ops-control-plane
```

## Usage

### Accessing the Control Plane

1. **Visit:** `https://ops.freqkflag.co`
2. **Authenticate:** You'll be redirected to GitHub for OAuth login
3. **Access Dashboard:** After authentication, you'll see the enhanced dashboard

### Features

#### Dashboard Tab
- Service status table
- Health metrics
- Recent incidents
- Infrastructure overview
- Auto-refresh every 30 seconds

#### Agents Tab
- Select agent from dropdown
- Send messages to agents
- View chat history
- Real-time agent responses

#### Tasks Tab
- View all tasks
- Filter by status or agent
- Task details and results
- Auto-refresh

#### Orchestrator Tab
- Run full orchestrator analysis
- Run individual agents
- View orchestrator reports
- Download report JSON files

#### Commands Tab
- Execute infrastructure commands
- View command output
- Quick command buttons
- Command history

## API Endpoints

### Agent Communication
- `GET /api/agents` - List all agents
- `GET /api/agents/:id` - Get agent definition
- `POST /api/agents/:id/chat` - Send message to agent
- `GET /api/chat/history` - Get chat history

### Task Management
- `GET /api/tasks` - List all tasks (filterable)
- `GET /api/tasks/:id` - Get task details
- `POST /api/tasks` - Create task
- `PUT /api/tasks/:id` - Update task
- `DELETE /api/tasks/:id` - Cancel task

### Orchestrator
- `POST /api/orchestrator/execute` - Execute orchestrator command
- `GET /api/orchestrator/reports` - List reports
- `GET /api/orchestrator/reports/:name` - Get report content

### Infrastructure
- `POST /api/infra/command` - Execute command
- `GET /api/infra/overview` - Get infrastructure overview

### Services (Existing)
- `GET /api/services` - List all services
- `POST /api/services/:id/:action` - Service actions (start/stop/restart)
- `GET /api/services/:id/status` - Get service status

### Authentication
- `GET /auth/github` - GitHub OAuth login
- `GET /auth/callback` - OAuth callback
- `GET /auth/logout` - Logout

## Testing

### Test Script

```bash
cd /root/infra/ops
./test-endpoints.sh admin password
```

### Manual Testing

```bash
# Health check (no auth required)
curl https://ops.freqkflag.co/health

# Services (requires auth - will redirect to GitHub)
curl -L https://ops.freqkflag.co/api/services

# Agents (requires auth)
curl -L https://ops.freqkflag.co/api/agents
```

## Troubleshooting

### Issue: OAuth not working
**Check:**
1. Container logs: `docker logs ops-control-plane | grep -i oauth`
2. OAuth packages installed: `npm list passport express-session`
3. Environment variables set correctly in docker-compose.yml
4. Callback URL matches GitHub configuration exactly

### Issue: Redirect loop
**Solution:** Ensure callback URL is exactly `https://ops.freqkflag.co/auth/callback`

### Issue: Session not persisting
**Solution:** Ensure HTTPS is enabled (secure cookies require HTTPS)

### Issue: Container won't start
**Check:**
1. OAuth packages installed: `cd /root/infra/ops && npm install`
2. Server file exists: `ls -la server-enhanced.js`
3. Docker compose syntax: `docker compose config`

## Security

### OAuth Security
- Client secret stored in environment variables
- Secure session cookies (HTTPS required)
- HttpOnly cookies (XSS protection)
- 24-hour session expiration

### Command Security
- Only allows commands in `/root/infra` or docker commands
- Blocks dangerous commands (rm -rf, mkfs, dd, shutdown, reboot)
- Command timeout (30s default)
- Max output buffer (10MB)

### Basic Auth Fallback
- Still available for API calls
- Can be disabled by removing `OPS_AUTH_USER`/`OPS_AUTH_PASS`

## Files Modified

- ✅ `docker-compose.yml` - OAuth configuration added
- ✅ `package.json` - OAuth dependencies added
- ✅ `server-enhanced.js` - OAuth routes and middleware
- ✅ `public/index-enhanced.html` - Enhanced UI
- ✅ `public/app-enhanced.js` - JavaScript implementation

## Files Created

- ✅ `OAUTH_CONFIGURED.md` - OAuth configuration documentation
- ✅ `ENHANCED_FEATURES.md` - Feature documentation
- ✅ `OPS_AGENT_SUMMARY.md` - Usage guide
- ✅ `DEPLOYMENT.md` - Deployment guide
- ✅ `test-endpoints.sh` - Test script
- ✅ `FINAL_STATUS.md` - Implementation status

## Next Steps

1. ✅ OAuth configured
2. ✅ Dependencies installed
3. ✅ Server updated
4. ✅ UI enhanced
5. ⏭️ **Deploy to production** (rebuild container)
6. ⏭️ **Test OAuth flow** (visit ops.freqkflag.co)
7. ⏭️ **Verify all features** (test each tab)

---

**Configuration Complete:** ✅  
**Ready for Deployment:** ✅  
**Last Updated:** 2025-11-21

