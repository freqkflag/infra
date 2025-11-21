# Infrastructure Monitoring

**Last Updated:** 2025-11-21

This page provides quick access to all monitoring and observability tools for the infrastructure.

## Grafana Dashboards

### Infrastructure Overview Dashboard
**URL:** [https://grafana.freqkflag.co/d/infra-overview](https://grafana.freqkflag.co/d/infra-overview)

**What it shows:**
- Host CPU, Memory, and Disk usage
- Traefik request rate and error rates (4xx/5xx)
- Service status (up/down)
- Recent errors from Loki logs

**Access:** Direct link above or navigate to Grafana → Dashboards → Infrastructure Overview

## Log Exploration

### Loki Log Explorer
**URL:** [https://grafana.freqkflag.co/explore?orgId=1&left=%5B%22now-1h%22,%22now%22,%22Loki%22%5D](https://grafana.freqkflag.co/explore?orgId=1&left=%5B%22now-1h%22,%22now%22,%22Loki%22%5D)

**Query Examples:**
```
# All errors
{job="docker"} |= "error" | |= "ERROR"

# Traefik logs
{container="traefik"}

# Service-specific logs
{service="wikijs"}
{service="wordpress"}

# Recent errors by service
{job="docker"} |= "error" | line_format "{{.service}}: {{.message}}"
```

## Direct Service Access

### Grafana
- **URL:** [https://grafana.freqkflag.co](https://grafana.freqkflag.co)
- **Default credentials:** admin/admin (change on first login!)
- **Purpose:** Dashboards, metrics visualization, log exploration

### Prometheus
- **URL:** [https://prometheus.freqkflag.co](https://prometheus.freqkflag.co)
- **Purpose:** Metrics storage and query interface
- **Use cases:** Custom queries, alerting rules

### Loki
- **URL:** [https://loki.freqkflag.co](https://loki.freqkflag.co)
- **Purpose:** Log aggregation and storage
- **Access:** Primarily via Grafana Explore view

## Quick Health Check

**Answer "Is anything on fire right now?"**

1. Open [Infrastructure Overview Dashboard](https://grafana.freqkflag.co/d/infra-overview)
2. Check:
   - **Host resources** (CPU/Memory/Disk) - should be < 90%
   - **Traefik errors** - should be minimal
   - **Service status** - all should be "up"
   - **Recent errors** - review any critical errors

## Service Metrics

All services are automatically instrumented with:
- **Container metrics** - CPU, memory, network via Docker
- **Traefik metrics** - Request rates, response codes, latency
- **Application logs** - Collected by Promtail and stored in Loki

## Alerting

**Current Status:** Basic monitoring active, alerting to be configured

**Planned Alerts:**
- High CPU/Memory usage (> 90%)
- Service down (container not running)
- High error rate (5xx errors > threshold)
- Disk space low (< 10% free)

## Troubleshooting

### Can't access Grafana
1. Check if Grafana container is running: `docker ps | grep grafana`
2. Check Traefik routing: `docker logs traefik | grep grafana`
3. Verify DNS: `nslookup grafana.freqkflag.co`

### No metrics showing
1. Check Prometheus targets: [https://prometheus.freqkflag.co/targets](https://prometheus.freqkflag.co/targets)
2. Verify Prometheus is scraping: Check "up" metric
3. Check Prometheus logs: `docker logs prometheus`

### No logs in Loki
1. Check Promtail is running: `docker ps | grep promtail`
2. Check Promtail logs: `docker logs promtail`
3. Verify Docker socket access: Promtail needs `/var/run/docker.sock`

## Related Documentation

- [Monitoring Stack Runbook](../runbooks/monitoring-runbook.md)
- [Logging Stack Runbook](../runbooks/logging-runbook.md)
- [Infrastructure Overview Dashboard](https://grafana.freqkflag.co/d/infra-overview)

---

**Quick Links:**
- [Grafana Dashboard](https://grafana.freqkflag.co/d/infra-overview)
- [Loki Explore](https://grafana.freqkflag.co/explore?orgId=1&left=%5B%22now-1h%22,%22now%22,%22Loki%22%5D)
- [Prometheus](https://prometheus.freqkflag.co)

