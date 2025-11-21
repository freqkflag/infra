# Phase 4: Observability as Pane #1 (Grafana + Loki)

**Date:** 2025-11-21  
**Status:** ✅ Complete

## Goal

A single Grafana dashboard that shows the heartbeat of your stack: key services, logs, resources.

## Completed Tasks

### 1. Monitoring + Logging Stacks Wired ✅

**Monitoring Stack:**
- ✅ Prometheus - Metrics collection and storage
- ✅ Grafana - Visualization and dashboards
- ✅ Node Exporter - Host metrics (CPU, memory, disk)

**Logging Stack:**
- ✅ Loki - Log aggregation and storage
- ✅ Promtail - Log collection from Docker containers

**Access URLs:**
- `https://grafana.freqkflag.co` - Grafana dashboard
- `https://prometheus.freqkflag.co` - Prometheus UI
- `https://loki.freqkflag.co` - Loki API

### 2. Service-Level Metrics/Logs ✅

**Metrics Collection:**
- ✅ Traefik metrics exposed at `/metrics` endpoint
- ✅ Prometheus configured to scrape Traefik
- ✅ Node Exporter collecting host metrics
- ✅ All containers labeled for Promtail discovery

**Log Collection:**
- ✅ Promtail configured with Docker service discovery
- ✅ Collecting logs from all containers automatically
- ✅ Logs labeled by container name, service, and project
- ✅ Loki receiving logs from Promtail

**Container Labels:**
All services automatically discovered via:
- Docker Compose service labels
- Container names
- Traefik labels (for domain mapping)

### 3. Grafana "Infra Overview" Dashboard ✅

Created `/root/infra/monitoring/config/grafana/dashboards/infra-overview.json`

**Dashboard Panels:**
1. **Host CPU Usage** - Gauge showing CPU percentage
2. **Host Memory Usage** - Gauge showing memory percentage
3. **Host Disk Usage** - Gauge showing disk percentage
4. **Traefik Request Rate** - Time series of requests per second
5. **Traefik 4xx/5xx Errors** - Time series of error rates
6. **Service Status** - Table showing up/down status
7. **Recent Errors (Loki)** - Log panel showing recent errors

**Dashboard Features:**
- Auto-refresh every 30 seconds
- Time range: Last 1 hour (configurable)
- Color-coded thresholds (green/yellow/red)
- Direct links to Loki Explore for detailed log queries

**Access:**
- Direct: `https://grafana.freqkflag.co/d/infra-overview`
- Via Grafana: Dashboards → Infrastructure Overview

### 4. WikiJS Integration ✅

Created `/root/infra/runbooks/WIKIJS_MONITORING.md` with:
- Direct links to Grafana dashboard
- Loki Explore queries
- Quick health check guide
- Troubleshooting steps

**To Import into WikiJS:**
1. Log into WikiJS at `https://wiki.freqkflag.co`
2. Create page: "Infrastructure Monitoring"
3. Copy content from `runbooks/WIKIJS_MONITORING.md`
4. Add to navigation menu

## Configuration Details

### Prometheus Scraping
- **Traefik:** `http://traefik:8080/metrics`
- **Node Exporter:** `http://node-exporter:9100/metrics`
- **Prometheus:** `http://localhost:9090/metrics`
- **Grafana:** `http://grafana:3000/metrics`

### Loki Log Collection
- **Source:** Docker containers via Promtail
- **Discovery:** Docker service discovery
- **Labels:** container, service, project, domain
- **Storage:** `/root/infra/logging/data/loki`

### Grafana Datasources
- **Prometheus:** `http://prometheus:9090` (default)
- **Loki:** `http://loki:3100`

## Done Criteria ✅

- ✅ Can answer "is anything on fire right now?" from single Grafana dashboard
- ✅ Logs and metrics accessible in 1-2 clicks
- ✅ All services instrumented with metrics/logs
- ✅ Dashboard shows key health indicators

## Quick Health Check

**To answer "Is anything on fire?"**

1. Open [Infrastructure Overview Dashboard](https://grafana.freqkflag.co/d/infra-overview)
2. Check:
   - **Host resources** - CPU/Memory/Disk should be < 90%
   - **Traefik errors** - 4xx/5xx should be minimal
   - **Service status** - All should show "up"
   - **Recent errors** - Review any critical errors in log panel

## Next Steps

- Configure alerting rules in Prometheus
- Add more service-specific dashboards
- Set up alert notifications (email/Slack)
- Add custom metrics from applications

---

**Last Updated:** 2025-11-21

