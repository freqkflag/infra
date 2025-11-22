# Node-RED Access Guide

**Status:** Infrastructure-Only Service (No Public Access)

## Access Methods

### 1. SSH Tunnel (Recommended for Remote Access)

```bash
# Create SSH tunnel to Node-RED
ssh -L 1880:localhost:1880 root@62.72.26.113

# Then access in browser:
# http://localhost:1880
```

### 2. Direct Container Access

```bash
# Access Node-RED container directly
docker exec -it nodered sh

# Or access via port forwarding
docker port nodered
```

### 3. From Other Containers (Internal Network)

```bash
# From any container on the 'edge' network:
curl http://nodered:1880

# Or use in Node-RED flows:
# HTTP Request node → http://nodered:1880/api/...
```

### 4. Port Forwarding (Docker)

```bash
# Add port mapping to docker-compose.yml if needed:
ports:
  - "1880:1880"  # Only for local development
```

## Security Notes

- **No Public Access:** Node-RED is not exposed via Traefik
- **Internal Network Only:** Accessible only on `edge` network
- **Authentication Required:** Login with credentials from Infisical
- **No HTTPS:** Internal network only (no SSL needed)

## Network Configuration

- **Network:** `edge` (shared infrastructure network)
- **Container Name:** `nodered`
- **Internal IP:** 172.31.0.9/16
- **Port:** 1880

## Troubleshooting

### Can't Access from Browser
- Use SSH tunnel method (see above)
- Verify container is running: `docker ps | grep nodered`
- Check network: `docker network inspect edge | grep nodered`

### Can't Access from Other Containers
- Verify both containers are on `edge` network
- Use container name: `http://nodered:1880` (not IP)
- Check firewall rules if applicable

### Authentication Issues
- See `/root/infra/nodered/CONFIGURATION.md` for credentials
- Check Infisical secrets: `NODERED_USERNAME`, `NODERED_PASSWORD_HASH`

---

**Last Updated:** 2025-11-22

