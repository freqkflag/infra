# Monitoring Gaps & Automation Plan

**Generated:** 2025-11-22  
**Status Agent Report:** See `/root/infra/ai.engine/reports/status-report-*.json`

## Current Monitoring Status

### ✅ Operational Components
- **Prometheus:** Running, scraping node-exporter, Traefik, Grafana
- **Grafana:** Running, configured with Prometheus and Loki datasources
- **Alertmanager:** Running, configured with alert rules
- **Loki/Promtail:** Running, collecting container logs
- **Node Exporter:** Running, collecting host metrics

### ❌ Missing Components

#### 1. Container Metrics Exporters
**Gap:** No cAdvisor or Docker metrics exporter deployed
- **Impact:** Cannot monitor container CPU, memory, network, disk usage
- **Prometheus Config:** Configured to scrape `host.docker.internal:9323` but Docker metrics API not enabled
- **Solution:** Deploy cAdvisor container or enable Docker metrics API

#### 2. Database Metrics Exporters
**Gap:** No postgres_exporter or mysqld_exporter deployed
- **Impact:** Cannot monitor database performance, connections, query metrics
- **Prometheus Config:** Configured to scrape database targets but exporters missing
- **Affected Databases:**
  - PostgreSQL: wikijs-db, n8n-db, supabase-db, postgres-postgres-1, backstage-db, infisical-db
  - MySQL/MariaDB: wordpress-db, linkstack-db
- **Solution:** Deploy postgres_exporter and mysqld_exporter sidecar containers

#### 3. Redis Metrics Exporter
**Gap:** No redis_exporter deployed
- **Impact:** Cannot monitor Redis performance, memory usage, connections
- **Prometheus Config:** Configured to scrape Redis targets but exporter missing
- **Affected Instances:** infra-redis-1, infisical-redis
- **Solution:** Deploy redis_exporter sidecar containers

#### 4. Service-Specific Metrics
**Gap:** Limited application-level metrics
- **Current:** Only Traefik, n8n, Grafana expose metrics
- **Missing:** Infisical, WikiJS, WordPress, Node-RED, Backstage, GitLab metrics
- **Solution:** Configure services to expose Prometheus metrics endpoints

#### 5. Health Check Automation
**Gap:** Health checks are manual, not automated
- **Current:** `scripts/health-check.sh` exists but requires manual execution
- **Impact:** No automated alerting on service failures
- **Solution:** Integrate health checks into Prometheus alerts or cron job

#### 6. Alertmanager SMTP Configuration
**Gap:** Email notifications not configured
- **Current:** Alertmanager configured but SMTP not set up
- **Impact:** Alerts not delivered via email
- **Solution:** Configure SMTP settings in Alertmanager or use webhook notifications

## Automation Steps

### Phase 1: Deploy Metrics Exporters (Priority: High)

#### 1.1 Deploy cAdvisor for Container Metrics
```yaml
# Add to monitoring/docker-compose.yml
cadvisor:
  image: gcr.io/cadvisor/cadvisor:v0.47.0
  container_name: cadvisor
  restart: unless-stopped
  privileged: true
  devices:
    - /dev/kmsg
  volumes:
    - /:/rootfs:ro
    - /var/run:/var/run:ro
    - /sys:/sys:ro
    - /var/lib/docker/:/var/lib/docker:ro
    - /dev/disk/:/dev/disk:ro
  networks:
    - monitoring-network
  deploy:
    resources:
      limits:
        cpus: '0.5'
        memory: 512M
  labels:
    - "prometheus.io/scrape=true"
    - "prometheus.io/port=8080"
```

**Update Prometheus config:**
```yaml
# monitoring/config/prometheus/prometheus.yml
- job_name: 'cadvisor'
  static_configs:
    - targets: ['cadvisor:8080']
  metrics_path: '/metrics'
```

#### 1.2 Deploy PostgreSQL Exporter
```yaml
# Add to services/postgres/compose.yml or create services/postgres-exporter/compose.yml
postgres-exporter:
  image: prometheuscommunity/postgres-exporter:latest
  container_name: postgres-exporter
  restart: unless-stopped
  env_file:
    - ../../.workspace/.env
  environment:
    DATA_SOURCE_NAME: "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}?sslmode=disable"
  networks:
    - edge
    - monitoring-network
  depends_on:
    - postgres
  labels:
    - "prometheus.io/scrape=true"
    - "prometheus.io/port=9187"
```

**Update Prometheus config:**
```yaml
- job_name: 'postgres-exporter'
  static_configs:
    - targets:
        - 'postgres-exporter:9187'
        - 'wikijs-db-exporter:9187'
        - 'n8n-db-exporter:9187'
        - 'supabase-db-exporter:9187'
        - 'backstage-db-exporter:9187'
        - 'infisical-db-exporter:9187'
```

#### 1.3 Deploy MySQL Exporter
```yaml
# Add to services/mariadb/compose.yml or create services/mysql-exporter/compose.yml
mysql-exporter:
  image: prom/mysqld-exporter:latest
  container_name: mysql-exporter
  restart: unless-stopped
  env_file:
    - ../../.workspace/.env
  environment:
    DATA_SOURCE_NAME: "${MYSQL_EXPORTER_USER}:${MYSQL_EXPORTER_PASSWORD}@(wordpress-db:3306,linkstack-db:3306)/"
  networks:
    - edge
    - monitoring-network
  depends_on:
    - mariadb
  labels:
    - "prometheus.io/scrape=true"
    - "prometheus.io/port=9104"
```

#### 1.4 Deploy Redis Exporter
```yaml
# Add to services/redis/compose.yml or create services/redis-exporter/compose.yml
redis-exporter:
  image: oliver006/redis_exporter:latest
  container_name: redis-exporter
  restart: unless-stopped
  env_file:
    - ../../.workspace/.env
  environment:
    REDIS_ADDR: "redis://redis:6379"
    REDIS_PASSWORD: "${REDIS_PASSWORD}"
  networks:
    - edge
    - monitoring-network
  depends_on:
    - redis
  labels:
    - "prometheus.io/scrape=true"
    - "prometheus.io/port=9121"
```

### Phase 2: Enhance Alert Rules (Priority: Medium)

#### 2.1 Add Container Health Alerts
```yaml
# Add to monitoring/config/prometheus/alerts.yml
- alert: ContainerDown
  expr: up{job="cadvisor"} == 0
  for: 2m
  labels:
    severity: critical
  annotations:
    summary: "Container {{ $labels.name }} is down"
    description: "Container {{ $labels.name }} has been down for more than 2 minutes."

- alert: ContainerHighMemory
  expr: container_memory_usage_bytes{name!=""} / container_spec_memory_limit_bytes{name!=""} > 0.9
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Container {{ $labels.name }} memory usage high"
    description: "Container {{ $labels.name }} is using more than 90% of its memory limit."

- alert: ContainerHighCPU
  expr: rate(container_cpu_usage_seconds_total{name!=""}[5m]) > 0.8
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Container {{ $labels.name }} CPU usage high"
    description: "Container {{ $labels.name }} CPU usage is above 80% for 5 minutes."
```

#### 2.2 Add Database Alerts
```yaml
- alert: DatabaseDown
  expr: up{job=~"postgres-exporter|mysql-exporter"} == 0
  for: 2m
  labels:
    severity: critical
  annotations:
    summary: "Database {{ $labels.instance }} is down"
    description: "Database exporter for {{ $labels.instance }} is not responding."

- alert: DatabaseHighConnections
  expr: pg_stat_database_numbackends{datname!~"template.*"} > 80
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High database connections on {{ $labels.instance }}"
    description: "Database {{ $labels.datname }} has more than 80 active connections."
```

#### 2.3 Add Service Health Check Alerts
```yaml
- alert: ServiceHealthCheckFailed
  expr: docker_container_health_status{status="unhealthy"} == 1
  for: 2m
  labels:
    severity: critical
  annotations:
    summary: "Service {{ $labels.name }} health check failed"
    description: "Docker health check for {{ $labels.name }} is reporting unhealthy."
```

### Phase 3: Automate Health Checks (Priority: Medium)

#### 3.1 Create Automated Health Check Script
```bash
#!/usr/bin/env bash
# scripts/automated-health-check.sh
# Run via cron every 5 minutes

set -euo pipefail

LOG_FILE="/var/log/infra/health-check.log"
ALERT_WEBHOOK="${ALERT_WEBHOOK_URL:-}"

# Check all services
FAILED_SERVICES=$(docker ps --format "{{.Names}}\t{{.Status}}" | grep -E "(unhealthy|Restarting)" || true)

if [ -n "$FAILED_SERVICES" ]; then
  echo "$(date): Health check failed - $FAILED_SERVICES" >> "$LOG_FILE"
  
  # Send alert via webhook if configured
  if [ -n "$ALERT_WEBHOOK" ]; then
    curl -X POST "$ALERT_WEBHOOK" \
      -H "Content-Type: application/json" \
      -d "{\"text\": \"Health check failed: $FAILED_SERVICES\"}"
  fi
  
  exit 1
fi

echo "$(date): All services healthy" >> "$LOG_FILE"
exit 0
```

#### 3.2 Add Cron Job
```bash
# Add to crontab or systemd timer
*/5 * * * * /root/infra/scripts/automated-health-check.sh
```

#### 3.3 Integrate with Prometheus
Create a custom exporter that exposes Docker health status:
```python
# scripts/docker-health-exporter.py
# Exposes Docker container health as Prometheus metrics
```

### Phase 4: Configure Alertmanager Notifications (Priority: Low)

#### 4.1 Configure SMTP (if Mailu available)
```yaml
# Update monitoring/config/alertmanager/alertmanager.yml
global:
  smtp_smarthost: 'mail.freqkflag.co:587'
  smtp_from: 'alertmanager@freqkflag.co'
  smtp_auth_username: 'alertmanager@freqkflag.co'
  smtp_auth_password: '${ALERTMANAGER_SMTP_PASSWORD}'
```

#### 4.2 Configure Webhook Notifications
```yaml
# Add to receivers in alertmanager.yml
- name: 'webhook-alerts'
  webhook_configs:
    - url: 'https://n8n.freqkflag.co/webhook/alerts'
      http_config:
        bearer_token: '${N8N_WEBHOOK_TOKEN}'
```

### Phase 5: Service-Specific Metrics (Priority: Low)

#### 5.1 Enable Metrics in Services
- **Infisical:** Check if metrics endpoint available
- **WikiJS:** Enable metrics export if available
- **WordPress:** Deploy WordPress Prometheus exporter
- **Node-RED:** Already exposes metrics at `/metrics`
- **Backstage:** Check for metrics plugin
- **GitLab:** Already exposes metrics at `/-/metrics`

#### 5.2 Update Prometheus Scrape Configs
```yaml
- job_name: 'infisical'
  static_configs:
    - targets: ['infisical:8080']
  metrics_path: '/api/metrics'

- job_name: 'gitlab'
  static_configs:
    - targets: ['gitlab:80']
  metrics_path: '/-/metrics'
  scrape_interval: 30s
```

## Implementation Priority

1. **Immediate (Week 1):**
   - Deploy cAdvisor for container metrics
   - Deploy postgres_exporter for database metrics
   - Add container health alerts

2. **Short-term (Week 2-3):**
   - Deploy mysql_exporter and redis_exporter
   - Automate health check script
   - Configure Alertmanager SMTP/webhooks

3. **Long-term (Month 1+):**
   - Enable service-specific metrics
   - Create custom Grafana dashboards
   - Implement log-based alerting via Loki

## Validation Commands

```bash
# Verify exporters are running
docker ps | grep -E "(cadvisor|postgres-exporter|mysql-exporter|redis-exporter)"

# Check Prometheus targets
curl http://prometheus:9090/api/v1/targets | jq '.data.activeTargets[] | select(.health != "up")'

# Test alert rules
curl http://prometheus:9090/api/v1/rules | jq '.data.groups[].rules[] | select(.state != "ok")'

# Verify Alertmanager configuration
curl http://alertmanager:9093/api/v1/status/config
```

## Next Steps

1. **Deploy cAdvisor** - Add to `monitoring/docker-compose.yml`
2. **Deploy database exporters** - Create exporter services for each database
3. **Update Prometheus config** - Add scrape configs for new exporters
4. **Add alert rules** - Enhance `monitoring/config/prometheus/alerts.yml`
5. **Automate health checks** - Create cron job or Prometheus-based monitoring
6. **Configure notifications** - Set up SMTP or webhook alerts

