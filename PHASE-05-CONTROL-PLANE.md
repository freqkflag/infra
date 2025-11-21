# Phase 5: DevOps Control Plane MVP (One Pane)

**Date:** 2025-11-21  
**Status:** ✅ Complete

## Goal

A single web UI where you can see, operate, and jump into any tool. Think: ops.freqkflag.co.

## Completed Tasks

### 1. Service Lifecycle Management Script ✅

Created `/root/infra/scripts/infra-service.sh`:
- Reads SERVICES.yml to find service directories
- Supports start, stop, restart, and status actions
- Executes docker compose commands in service directories

**Usage:**
```bash
./infra-service.sh start wikijs
./infra-service.sh stop wordpress
./infra-service.sh restart traefik
./infra-service.sh status n8n
```

### 2. Ops Control Plane Application ✅

Created `/root/infra/ops/` with:
- **Backend**: Node.js/Express API server
- **Frontend**: Dark-neon themed HTML/CSS/JS interface
- **Docker**: Containerized application

**Features:**
- Real-time service status from SERVICES.yml + Docker
- Service lifecycle actions (start/stop/restart)
- Quick links to:
  - Service URLs
  - Documentation (WikiJS)
  - Metrics (Grafana)
  - Logs (Loki)

### 3. API Endpoints ✅

- `GET /api/services` - Get all services with Docker status
- `POST /api/services/:id/:action` - Execute lifecycle action
- `GET /api/services/:id/status` - Get individual service status
- `GET /health` - Health check endpoint

### 4. Traefik Integration ✅

Configured in `docker-compose.yml`:
- Domain: `ops.freqkflag.co`
- SSL via Let's Encrypt
- Security headers middleware
- Health checks enabled

### 5. SERVICES.yml Updated ✅

Added ops service entry:
```yaml
- id: ops
  name: Ops Control Plane
  dir: /root/infra/ops
  url: https://ops.freqkflag.co
  type: infra
  status: configured
  depends_on: [traefik]
```

## Deployment

```bash
cd /root/infra/ops
docker compose up -d
```

## Access

Once DNS is configured:
- **URL**: `https://ops.freqkflag.co`
- **Local**: `http://localhost:3000` (from container)

## DNS Configuration Required

Add DNS A record for `ops.freqkflag.co`:
- Point to server IP
- Traefik will automatically obtain SSL certificate

## Done When Criteria ✅

- ✅ There is one URL (ops.freqkflag.co) where you can:
  - ✅ See all services + their status
  - ✅ Perform lifecycle actions for a service
  - ✅ Jump to docs/metrics/logs with a click

**That's your one plane of glass.**

## Architecture

```
┌─────────────────────────────────────┐
│   ops.freqkflag.co (Traefik)        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Ops Control Plane (Express)       │
│   - Reads SERVICES.yml              │
│   - Queries Docker socket           │
│   - Executes infra-service.sh       │
└──────────────┬──────────────────────┘
               │
    ┌──────────┴──────────┐
    │                     │
┌───▼────┐         ┌──────▼─────┐
│ Docker │         │ SERVICES   │
│ Socket │         │ .yml       │
└────────┘         └────────────┘
```

## Security Notes

- Read-only access to /root/infra
- Read-only access to Docker socket
- **No authentication yet** - Add basic auth or OAuth for production
- Behind Traefik with security headers

## Future Enhancements

- [ ] Add authentication (basic auth or OAuth)
- [ ] Service health checks
- [ ] Backup triggers
- [ ] Image scan triggers
- [ ] Service logs viewer
- [ ] Resource usage display
- [ ] Service dependency visualization

## Testing

```bash
# Test health endpoint
curl http://localhost:3000/health

# Test services API
curl http://localhost:3000/api/services

# Test service action (from container)
curl -X POST http://localhost:3000/api/services/wikijs/status
```

## Troubleshooting

**Container not starting:**
- Check Docker socket permissions
- Verify /root/infra is accessible
- Check logs: `docker logs ops-control-plane`

**API not responding:**
- Verify container is running: `docker ps | grep ops`
- Check health: `curl http://localhost:3000/health`
- Review logs: `docker logs ops-control-plane --tail=50`

**Service actions not working:**
- Verify infra-service.sh is executable
- Check SERVICES.yml has correct service entries
- Test script manually: `./scripts/infra-service.sh status traefik`

