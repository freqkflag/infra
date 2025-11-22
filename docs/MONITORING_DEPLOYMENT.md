# Monitoring Exporters Deployment Guide

**Deployed:** 2025-11-22  
**Status:** Configuration complete, ready for deployment

## Changes Made

### 1. ✅ cAdvisor Added
- **File:** `monitoring/docker-compose.yml`
- **Purpose:** Container metrics (CPU, memory, network, disk)
- **Port:** 8080
- **Network:** monitoring-network

### 2. ✅ PostgreSQL Exporter Added
- **File:** `services/postgres/compose.yml`
- **Purpose:** PostgreSQL database metrics
- **Port:** 9187
- **Networks:** edge, monitoring-network
- **Depends on:** postgres service

### 3. ✅ MySQL Exporter Added
- **File:** `services/mariadb/compose.yml`
- **Purpose:** MySQL/MariaDB database metrics
- **Port:** 9104
- **Networks:** edge, monitoring-network
- **Depends on:** mariadb service

### 4. ✅ Redis Exporter Added
- **File:** `services/redis/compose.yml`
- **Purpose:** Redis metrics
- **Port:** 9121
- **Networks:** edge, monitoring-network
- **Depends on:** redis service

### 5. ✅ Prometheus Configuration Updated
- **File:** `monitoring/config/prometheus/prometheus.yml`
- **Changes:**
  - Added cAdvisor scrape config
  - Replaced database direct targets with exporter targets
  - Added redis-exporter scrape config
  - Removed Docker metrics endpoint (replaced with cAdvisor)

### 6. ✅ Automated Health Check Cron Job
- **Script:** `scripts/automated-health-check.sh`
- **Schedule:** Every 5 minutes (`*/5 * * * *`)
- **Log:** `/var/log/infra/health-check.log`

## Deployment Steps

### Step 1: Start cAdvisor
```bash
cd /root/infra/monitoring
docker compose up -d cadvisor
```

### Step 2: Start Database Exporters
```bash
# PostgreSQL exporter
cd /root/infra/services/postgres
docker compose up -d postgres-exporter

# MySQL exporter
cd /root/infra/services/mariadb
docker compose up -d mysql-exporter

# Redis exporter
cd /root/infra/services/redis
docker compose up -d redis-exporter
```

### Step 3: Reload Prometheus Configuration
```bash
# Option 1: Restart Prometheus (recommended for first deployment)
cd /root/infra/monitoring
docker compose restart prometheus

# Option 2: Reload via API (if lifecycle enabled)
curl -X POST http://prometheus:9090/-/reload
```

### Step 4: Verify Deployment

#### Check Containers
```bash
docker ps | grep -E "(cadvisor|postgres-exporter|mysql-exporter|redis-exporter)"
```

#### Check Prometheus Targets
```bash
# Via API
curl -s http://prometheus:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health, lastError: .lastError}'

# Or visit in browser
# http://prometheus:9090/targets
```

#### Check Metrics Endpoints
```bash
# cAdvisor
curl http://cadvisor:8080/metrics | head -20

# PostgreSQL exporter
curl http://postgres-exporter:9187/metrics | head -20

# MySQL exporter
curl http://mysql-exporter:9104/metrics | head -20

# Redis exporter
curl http://redis-exporter:9121/metrics | head -20
```

#### Check Health Check Logs
```bash
tail -f /var/log/infra/health-check.log
```

## Network Configuration

All exporters are connected to:
- **edge network:** For service communication
- **monitoring-network:** For Prometheus scraping

The `monitoring-network` is created automatically by the monitoring stack. Exporters connect to it as an external network.

## Resource Limits

All exporters have resource limits configured:
- **CPU:** 0.25 limit, 0.05 reservation
- **Memory:** 128M limit, 32M reservation

## Troubleshooting

### Exporter Not Scraping

1. **Check container is running:**
   ```bash
   docker ps | grep <exporter-name>
   ```

2. **Check network connectivity:**
   ```bash
   docker exec prometheus ping -c 2 <exporter-name>
   ```

3. **Check metrics endpoint:**
   ```bash
   docker exec prometheus wget -qO- http://<exporter-name>:<port>/metrics | head -10
   ```

4. **Check Prometheus logs:**
   ```bash
   docker logs prometheus | grep -i error
   ```

### Health Check Script Issues

1. **Check cron job:**
   ```bash
   crontab -l | grep automated-health-check
   ```

2. **Test script manually:**
   ```bash
   /root/infra/scripts/automated-health-check.sh
   ```

3. **Check log directory permissions:**
   ```bash
   ls -ld /var/log/infra
   ```

## Expected Metrics

After deployment, you should see:

### cAdvisor Metrics
- `container_cpu_usage_seconds_total`
- `container_memory_usage_bytes`
- `container_network_receive_bytes_total`
- `container_network_transmit_bytes_total`

### PostgreSQL Metrics
- `pg_stat_database_numbackends`
- `pg_stat_database_xact_commit`
- `pg_stat_database_xact_rollback`
- `pg_stat_database_blks_read`

### MySQL Metrics
- `mysql_global_status_connections`
- `mysql_global_status_threads_connected`
- `mysql_global_status_queries`
- `mysql_global_status_slow_queries`

### Redis Metrics
- `redis_connected_clients`
- `redis_used_memory_bytes`
- `redis_commands_processed_total`
- `redis_keyspace_keys`

## Next Steps

1. **Create Grafana Dashboards** for the new metrics
2. **Add Alert Rules** for container and database metrics (see `docs/MONITORING_GAPS.md`)
3. **Configure Alertmanager** SMTP/webhook notifications
4. **Monitor Resource Usage** of exporters themselves

## Rollback

If issues occur, you can remove exporters:

```bash
# Stop and remove exporters
cd /root/infra/services/postgres && docker compose stop postgres-exporter && docker compose rm -f postgres-exporter
cd /root/infra/services/mariadb && docker compose stop mysql-exporter && docker compose rm -f mysql-exporter
cd /root/infra/services/redis && docker compose stop redis-exporter && docker compose rm -f redis-exporter
cd /root/infra/monitoring && docker compose stop cadvisor && docker compose rm -f cadvisor

# Restore Prometheus config
git checkout monitoring/config/prometheus/prometheus.yml
docker compose restart prometheus
```

