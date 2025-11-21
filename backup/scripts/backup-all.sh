#!/bin/sh
# Unified backup script for all infrastructure services
# Backs up databases and data volumes

set -e

BACKUP_DIR="/backups"
INFRA_DIR="/infra"
RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-30}
RETENTION_WEEKS=${BACKUP_RETENTION_WEEKS:-12}
DATE=$(date +%Y%m%d_%H%M%S)
WEEK=$(date +%Y-W%V)

# Install required tools
apk add --no-cache postgresql-client mysql-client tar gzip

# Create backup directories
mkdir -p "$BACKUP_DIR/daily"
mkdir -p "$BACKUP_DIR/weekly"
mkdir -p "$BACKUP_DIR/logs"

LOG_FILE="$BACKUP_DIR/logs/backup_${DATE}.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

backup_postgres() {
    local service=$1
    local db_name=$2
    local db_user=$3
    local db_password=$4
    local container=$5
    
    log "Backing up PostgreSQL: $service"
    
    PGPASSWORD="$db_password" pg_dump -h "$container" -U "$db_user" -d "$db_name" \
        -F c -f "$BACKUP_DIR/daily/${service}_${DATE}.dump" 2>&1 | tee -a "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
        log "✓ PostgreSQL backup completed: $service"
        # Compress
        gzip "$BACKUP_DIR/daily/${service}_${DATE}.dump"
    else
        log "✗ PostgreSQL backup failed: $service"
        return 1
    fi
}

backup_mysql() {
    local service=$1
    local db_name=$2
    local db_user=$3
    local db_password=$4
    local container=$5
    
    log "Backing up MySQL: $service"
    
    mysqldump -h "$container" -u "$db_user" -p"$db_password" "$db_name" \
        > "$BACKUP_DIR/daily/${service}_${DATE}.sql" 2>&1 | tee -a "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
        log "✓ MySQL backup completed: $service"
        # Compress
        gzip "$BACKUP_DIR/daily/${service}_${DATE}.sql"
    else
        log "✗ MySQL backup failed: $service"
        return 1
    fi
}

backup_volume() {
    local service=$1
    local volume_path=$2
    
    log "Backing up volume: $service from $volume_path"
    
    if [ -d "$volume_path" ]; then
        tar -czf "$BACKUP_DIR/daily/${service}_volume_${DATE}.tar.gz" \
            -C "$INFRA_DIR/$service" data/ 2>&1 | tee -a "$LOG_FILE"
        
        if [ $? -eq 0 ]; then
            log "✓ Volume backup completed: $service"
        else
            log "✗ Volume backup failed: $service"
            return 1
        fi
    else
        log "⚠ Volume path not found: $volume_path"
    fi
}

# Backup PostgreSQL databases
if docker ps --format '{{.Names}}' | grep -q 'wikijs-db'; then
    backup_postgres "wikijs" "wiki" "wikijs" "${WIKIJS_DB_PASSWORD:-}" "wikijs-db" || true
fi

if docker ps --format '{{.Names}}' | grep -q 'n8n-db'; then
    backup_postgres "n8n" "n8n" "n8n" "${N8N_DB_PASSWORD:-}" "n8n-db" || true
fi

if docker ps --format '{{.Names}}' | grep -q 'mastodon-db'; then
    backup_postgres "mastodon" "mastodon" "mastodon" "${MASTODON_DB_PASSWORD:-}" "mastodon-db" || true
fi

if docker ps --format '{{.Names}}' | grep -q 'supabase-db'; then
    backup_postgres "supabase" "postgres" "supabase_admin" "${SUPABASE_DB_PASSWORD:-}" "supabase-db" || true
fi

# Backup MySQL databases
if docker ps --format '{{.Names}}' | grep -q 'wordpress-db'; then
    backup_mysql "wordpress" "${WORDPRESS_DB_NAME:-wordpress}" "${WORDPRESS_DB_USER:-wordpress}" \
        "${WORDPRESS_DB_PASSWORD:-}" "wordpress-db" || true
fi

if docker ps --format '{{.Names}}' | grep -q 'linkstack-db'; then
    backup_mysql "linkstack" "${LINKSTACK_DB_NAME:-linkstack}" "${LINKSTACK_DB_USER:-linkstack}" \
        "${LINKSTACK_DB_PASSWORD:-}" "linkstack-db" || true
fi

# Backup important volumes (weekly only to save space)
if [ "$(date +%u)" -eq 1 ]; then  # Monday
    log "Weekly volume backups..."
    backup_volume "vault" "$INFRA_DIR/vault/data" || true
    backup_volume "wikijs" "$INFRA_DIR/wikijs/data" || true
    backup_volume "wordpress" "$INFRA_DIR/wordpress/data" || true
fi

# Create weekly archive on Monday
if [ "$(date +%u)" -eq 1 ]; then
    log "Creating weekly archive..."
    mkdir -p "$BACKUP_DIR/weekly"
    tar -czf "$BACKUP_DIR/weekly/weekly_${WEEK}.tar.gz" \
        -C "$BACKUP_DIR/daily" . 2>&1 | tee -a "$LOG_FILE"
    log "Weekly archive created: weekly_${WEEK}.tar.gz"
fi

# Cleanup old backups
log "Cleaning up old backups..."
find "$BACKUP_DIR/daily" -type f -mtime +$RETENTION_DAYS -delete
find "$BACKUP_DIR/weekly" -type f -mtime +$((RETENTION_WEEKS * 7)) -delete
find "$BACKUP_DIR/logs" -type f -mtime +30 -delete
log "Cleanup completed"

log "Backup process completed"

