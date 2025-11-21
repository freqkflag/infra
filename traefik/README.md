# Traefik Reverse Proxy

Traefik reverse proxy with Docker provider and Let's Encrypt SSL certificates.

**Location:** `/root/infra/traefik/`

## Quick Start

```bash
cd /root/infra/traefik
docker compose up -d
```

## Configuration

### Ports
- **80**: HTTP (redirects to HTTPS)
- **443**: HTTPS
- **8080**: Traefik Dashboard

### Features
- Automatic SSL certificates via Let's Encrypt
- Docker provider for automatic service discovery
- HTTP to HTTPS redirect
- Security headers middleware
- Dashboard at `http://localhost:8080`

## Service Integration

To expose a service through Traefik, add these labels to your service:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.my-service.rule=Host(`example.com`)"
  - "traefik.http.routers.my-service.entrypoints=websecure"
  - "traefik.http.routers.my-service.tls.certresolver=letsencrypt"
  - "traefik.http.services.my-service.loadbalancer.server.port=8080"
```

### Example: Vault Integration

Vault is already configured with Traefik labels. Access it at:
- `https://vault.freqkflag.co`

## Networks

Services need to be on the `traefik-network` to be discovered:

```yaml
networks:
  traefik-network:
    external: true
    name: traefik-network
```

## SSL Certificates

Certificates are stored in `./acme/acme.json` and automatically managed by Let's Encrypt.

**Important:** Update the email address in `config/traefik.yml` for Let's Encrypt notifications.

## Management

### Start
```bash
docker compose up -d
```

### Stop
```bash
docker compose down
```

### Logs
```bash
docker compose logs -f traefik
```

### Dashboard
Access the dashboard at `http://localhost:8080`

## Dynamic Configuration

Dynamic configuration files are in `./dynamic/`:
- `middlewares.yml`: Custom middlewares (security headers, redirects, etc.)

## Troubleshooting

### Check Traefik logs
```bash
docker compose logs traefik
```

### Verify service discovery
```bash
docker inspect <container-name> | grep -A 10 Labels
```

### Test SSL certificate
```bash
curl -I https://your-domain.com
```

## Security Notes

- Dashboard is currently insecure (accessible without auth)
- For production, enable authentication for the dashboard
- Ensure `acme.json` has proper permissions (600)

