# Node-RED Deployment

Flow-based development tool for visual programming and automation.

**Location:** `/root/infra/nodered/`

## Quick Start

```bash
cd /root/infra/nodered
docker compose up -d
```

## Configuration

- **Domain:** `nodered.freqkflag.co`
- **Port:** 1880 (internal)
- **Data Directory:** `./data/`
- **Timezone:** America/New_York

## Access

- **Web UI:** https://nodered.freqkflag.co
- **Default:** No authentication (configure in settings)

## Features

- Visual flow editor
- Node.js-based runtime
- Extensive node library
- HTTP endpoints
- MQTT support
- Database integrations
- REST API
- Dashboard UI (with node-red-dashboard)

## Data Persistence

- Flows stored in: `./data/flows.json`
- Settings in: `./data/settings.js`
- Node modules in: `./data/node_modules/`

## Management

### Start

```bash
docker compose up -d
```

### Stop

```bash
docker compose down
```

### Restart

```bash
docker compose restart
```

### Logs

```bash
docker compose logs -f
```

### Update

```bash
docker compose pull
docker compose up -d
```

## Configuration

### Environment Variables

Set in `.env`:
- `TZ` - Timezone (default: America/New_York)

### Custom Settings

Edit `./data/settings.js` to customize:
- Authentication
- HTTP endpoints
- Node settings
- Security options

### Installing Nodes

Nodes can be installed via the UI or by adding to `package.json` in `./data/`:

```bash
cd /root/infra/nodered/data
npm install <node-name>
docker compose restart nodered
```

## Integration

### With Other Services

Node-RED can integrate with:
- **Vault** - For secrets management
- **n8n** - Alternative automation (can work alongside)
- **Mastodon** - Social media automation
- **Mailu** - Email automation
- **Databases** - PostgreSQL, MySQL connections
- **APIs** - REST/HTTP integrations

### Example: Vault Integration

```javascript
// In Node-RED function node
const vault = global.get('vault');
const secret = await vault.read('secret/env');
msg.payload = secret.data.data;
return msg;
```

## Security

### Enable Authentication

Edit `./data/settings.js`:

```javascript
adminAuth: {
    type: "credentials",
    users: [{
        username: "admin",
        password: "$2a$08$...", // bcrypt hash
        permissions: "*"
    }]
}
```

### HTTPS

Handled by Traefik with Let's Encrypt certificates.

## Backup

Node-RED data is backed up as part of the infrastructure backup system:

```bash
cd /root/infra/backup
docker compose run --rm backup
```

Backups include:
- `./data/flows.json` - Your flows
- `./data/settings.js` - Configuration
- `./data/node_modules/` - Custom nodes

## Troubleshooting

### Flows Not Saving

- Check file permissions on `./data/`
- Verify disk space: `df -h`
- Check logs: `docker compose logs nodered`

### Nodes Not Installing

- Check Node-RED logs for errors
- Verify internet connectivity
- Check disk space

### Service Won't Start

- Check logs: `docker compose logs nodered`
- Verify Traefik is running
- Check resource limits

## Resources

- **Node-RED Docs:** https://nodered.org/docs/
- **Node Library:** https://flows.nodered.org/
- **Dashboard Nodes:** https://github.com/node-red/node-red-dashboard

---

**Last Updated:** 2025-11-20

