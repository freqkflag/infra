# Centralized Logging Stack

Loki + Promtail for centralized log aggregation and analysis.

## Services

- **Loki** - Log aggregation system (Grafana Loki)
- **Promtail** - Log shipper that collects and ships logs to Loki

## Quick Start

```bash
cd /root/infra/logging
docker compose up -d
```

## Access

- **Loki API:** https://loki.freqkflag.co
- **Grafana Logs:** Access via Grafana at https://grafana.freqkflag.co (Loki datasource)

## Configuration

### Loki

Configuration file: `config/loki/loki-config.yml`

- Retention: 30 days (720 hours)
- Storage: Filesystem-based
- Query limits configured for performance

### Promtail

Configuration file: `config/promtail/promtail-config.yml`

- Collects logs from:
  - Docker containers (via Docker socket)
  - System logs (`/var/log/syslog`)
  - Traefik access logs
  - Application logs from mounted volumes

## Log Labels

Logs are automatically labeled with:
- `container` - Container name
- `service` - Docker Compose service name
- `project` - Docker Compose project name
- `domain` - Traefik domain (if applicable)
- `stream` - Log stream (stdout/stderr)

## Querying Logs

### In Grafana

1. Go to Explore
2. Select Loki datasource
3. Use LogQL queries:

```logql
# All logs from a service
{service="wikijs"}

# Logs from a specific container
{container="wikijs"}

# Logs containing an error
{service="wordpress"} |= "error"

# Logs from a specific domain
{domain="cultofjoey.com"}
```

### Via Loki API

```bash
# Query logs
curl -G -s "http://loki:3100/loki/api/v1/query_range" \
  --data-urlencode 'query={service="wikijs"}' \
  --data-urlencode 'start=1234567890000000000' \
  --data-urlencode 'end=1234567891000000000'
```

## Log Rotation

Configure Docker log rotation:

```bash
cd /root/infra/logging
./scripts/log-rotation.sh configure
sudo systemctl restart docker
```

Clean old logs:

```bash
./scripts/log-rotation.sh clean
```

## Retention

- **Default:** 30 days
- **Configurable:** Edit `config/loki/loki-config.yml`
- **Compaction:** Automatic every 10 minutes

## Data Persistence

- Loki data: `./data/loki/`
- Positions: `/tmp/positions.yaml` (in container)

## Management

```bash
# View logs
docker compose logs -f loki
docker compose logs -f promtail

# Restart services
docker compose restart

# Check Promtail targets
curl http://localhost:9080/targets
```

## Integration with Services

All Docker containers are automatically discovered and logged by Promtail via the Docker socket.

To add custom log collection:

1. Mount log directory to Promtail
2. Add scrape config to `config/promtail/promtail-config.yml`
3. Restart Promtail

## Security Notes

- Loki API accessible via Traefik with SSL/TLS
- Consider authentication for production use
- Log data stored locally in `./data/loki/`

