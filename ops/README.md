# Ops Control Plane

**Domain:** `ops.freqkflag.co`

**Purpose:** Single web UI to see, operate, and jump into any infrastructure service.

## Features

- **Service Status**: Real-time view of all services from SERVICES.yml with Docker container status
- **Lifecycle Actions**: Start, stop, and restart services via infra-service.sh
- **Quick Links**: Direct links to:
  - Service URLs
  - Documentation (WikiJS)
  - Metrics (Grafana)
  - Logs (Loki)

## Architecture

- **Backend**: Node.js/Express API
- **Frontend**: Simple HTML/CSS/JS (dark-neon theme)
- **Data Source**: Reads SERVICES.yml
- **Actions**: Executes infra-service.sh script
- **Status**: Queries Docker socket for container status

## API Endpoints

- `GET /api/services` - Get all services with status
- `POST /api/services/:id/:action` - Execute action (start/stop/restart)
- `GET /api/services/:id/status` - Get service status
- `GET /health` - Health check

## Deployment

```bash
cd /root/infra/ops
docker compose up -d
```

## Security Notes

- Read-only access to /root/infra
- Read-only access to Docker socket
- No authentication (add basic auth or OAuth for production)
- Behind Traefik with security headers

## Future Enhancements

- Add authentication (basic auth or OAuth)
- Service health checks
- Backup triggers
- Image scan triggers
- Service logs viewer
- Resource usage display

