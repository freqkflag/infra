# Monitoring Stack

Prometheus + Grafana monitoring infrastructure for all services.

## Services

- **Prometheus** - Metrics collection and storage
- **Grafana** - Visualization and dashboards
- **Node Exporter** - Host system metrics

## Quick Start

```bash
cd /root/infra/monitoring
cp .env.example .env  # Edit with your credentials
docker compose up -d
```

## Access

- **Grafana:** https://grafana.freqkflag.co
- **Prometheus:** https://prometheus.freqkflag.co

Default Grafana credentials are configured in `.env` file.

## Configuration

### Prometheus

Configuration file: `config/prometheus/prometheus.yml`

- Scrape interval: 15 seconds
- Retention: 30 days
- Monitors: Traefik, Node Exporter, Docker, databases, applications

### Grafana

- Datasources: Auto-provisioned from `config/grafana/datasources/`
- Dashboards: Auto-provisioned from `config/grafana/dashboards/`

## Adding Service Metrics

To add a new service to monitoring:

1. Add Prometheus labels to service docker-compose.yml:
```yaml
labels:
  - "prometheus.io/scrape=true"
  - "prometheus.io/port=8080"
```

2. Add scrape config to `config/prometheus/prometheus.yml`

3. Restart Prometheus:
```bash
docker compose restart prometheus
```

## Metrics Endpoints

- **Traefik:** `http://traefik:8080/metrics`
- **Prometheus:** `http://prometheus:9090/metrics`
- **Grafana:** `http://grafana:3000/metrics`
- **Node Exporter:** `http://node-exporter:9100/metrics`

## Data Persistence

- Prometheus data: `./data/prometheus/`
- Grafana data: `./data/grafana/`

## Management

```bash
# View logs
docker compose logs -f

# Restart services
docker compose restart

# Update configuration
# Edit config files, then restart:
docker compose restart prometheus grafana
```

## Security Notes

- Change default Grafana admin password
- Access restricted via Traefik with SSL/TLS
- Consider enabling Grafana authentication for production

