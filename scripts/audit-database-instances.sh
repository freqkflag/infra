#!/bin/bash
# Database Instance Audit Script
# Purpose: List all database instances, show versions, networks, and identify orphaned instances
# Usage: ./scripts/audit-database-instances.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$INFRA_DIR"

echo "=========================================="
echo "Database Instance Audit"
echo "Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if container is running
is_running() {
    local container=$1
    docker ps --format "{{.Names}}" | grep -q "^${container}$" && echo "running" || echo "stopped"
}

# Function to get container image version
get_version() {
    local container=$1
    local image=$(docker inspect --format='{{.Config.Image}}' "$container" 2>/dev/null || echo "N/A")
    echo "$image"
}

# Function to get container networks
get_networks() {
    local container=$1
    docker inspect --format='{{range $key, $value := .NetworkSettings.Networks}}{{$key}} {{end}}' "$container" 2>/dev/null | tr -d '\n' || echo "N/A"
}

# Function to get container volumes
get_volumes() {
    local container=$1
    docker inspect --format='{{range .Mounts}}{{.Name}} {{end}}' "$container" 2>/dev/null | tr -d '\n' || echo "N/A"
}

echo "=== PostgreSQL Instances ==="
echo ""
POSTGRES_CONTAINERS=$(docker ps -a --filter "name=postgres" --format "{{.Names}}" | sort -u)

if [ -z "$POSTGRES_CONTAINERS" ]; then
    echo -e "${YELLOW}No PostgreSQL containers found${NC}"
else
    printf "%-30s %-40s %-15s %-30s %-30s\n" "CONTAINER" "IMAGE" "STATUS" "NETWORKS" "VOLUMES"
    printf "%-30s %-40s %-15s %-30s %-30s\n" "------------------------------" "----------------------------------------" "---------------" "------------------------------" "------------------------------"
    
    for container in $POSTGRES_CONTAINERS; do
        status=$(is_running "$container")
        image=$(get_version "$container")
        networks=$(get_networks "$container")
        volumes=$(get_volumes "$container")
        
        if [ "$status" = "running" ]; then
            status_color="${GREEN}running${NC}"
        else
            status_color="${RED}stopped${NC}"
        fi
        
        printf "%-30s %-40s %-15s %-30s %-30s\n" "$container" "$image" "$status_color" "$networks" "$volumes"
    done
fi

echo ""
echo "=== MySQL/MariaDB Instances ==="
echo ""
MYSQL_CONTAINERS=$(docker ps -a --filter "name=mysql\|mariadb" --format "{{.Names}}" | sort -u)

if [ -z "$MYSQL_CONTAINERS" ]; then
    echo -e "${YELLOW}No MySQL/MariaDB containers found${NC}"
else
    printf "%-30s %-40s %-15s %-30s %-30s\n" "CONTAINER" "IMAGE" "STATUS" "NETWORKS" "VOLUMES"
    printf "%-30s %-40s %-15s %-30s %-30s\n" "------------------------------" "----------------------------------------" "---------------" "------------------------------" "------------------------------"
    
    for container in $MYSQL_CONTAINERS; do
        status=$(is_running "$container")
        image=$(get_version "$container")
        networks=$(get_networks "$container")
        volumes=$(get_volumes "$container")
        
        if [ "$status" = "running" ]; then
            status_color="${GREEN}running${NC}"
        else
            status_color="${RED}stopped${NC}"
        fi
        
        printf "%-30s %-40s %-15s %-30s %-30s\n" "$container" "$image" "$status_color" "$networks" "$volumes"
    done
fi

echo ""
echo "=== Redis Instances ==="
echo ""
REDIS_CONTAINERS=$(docker ps -a --filter "name=redis" --format "{{.Names}}" | sort -u)

if [ -z "$REDIS_CONTAINERS" ]; then
    echo -e "${YELLOW}No Redis containers found${NC}"
else
    printf "%-30s %-40s %-15s %-30s %-30s\n" "CONTAINER" "IMAGE" "STATUS" "NETWORKS" "VOLUMES"
    printf "%-30s %-40s %-15s %-30s %-30s\n" "------------------------------" "----------------------------------------" "---------------" "------------------------------" "------------------------------"
    
    for container in $REDIS_CONTAINERS; do
        status=$(is_running "$container")
        image=$(get_version "$container")
        networks=$(get_networks "$container")
        volumes=$(get_volumes "$container")
        
        if [ "$status" = "running" ]; then
            status_color="${GREEN}running${NC}"
        else
            status_color="${RED}stopped${NC}"
        fi
        
        printf "%-30s %-40s %-15s %-30s %-30s\n" "$container" "$image" "$status_color" "$networks" "$volumes"
    done
fi

echo ""
echo "=== Service-to-Database Mappings ==="
echo ""
echo "Checking service configurations for database connections..."
echo ""

# Check compose files for database connections
find . -name "compose.yml" -o -name "docker-compose.yml" | while read -r compose_file; do
    if grep -q "DB_HOST\|POSTGRES\|MYSQL\|MARIADB\|REDIS" "$compose_file" 2>/dev/null; then
        service_dir=$(dirname "$compose_file")
        echo -e "${BLUE}Service: $service_dir${NC}"
        
        # Extract database host references
        if grep -q "DB_HOST\|POSTGRES.*HOST\|MYSQL.*HOST\|MARIADB.*HOST\|REDIS.*HOST" "$compose_file"; then
            grep -h "DB_HOST\|POSTGRES.*HOST\|MYSQL.*HOST\|MARIADB.*HOST\|REDIS.*HOST" "$compose_file" | head -5
        fi
        echo ""
    fi
done

echo ""
echo "=== Orphaned Instance Detection ==="
echo ""
echo "Checking for containers not referenced in compose files..."
echo ""

ALL_DB_CONTAINERS=$(docker ps -a --filter "name=postgres\|mysql\|mariadb\|redis" --format "{{.Names}}")

for container in $ALL_DB_CONTAINERS; do
    # Check if container is referenced in any compose file
    if ! grep -r "$container" --include="*.yml" --include="*.yaml" . 2>/dev/null | grep -v ".git" | grep -q .; then
        echo -e "${YELLOW}Potential orphaned container: $container${NC}"
        echo "  Not found in any compose file"
    fi
done

echo ""
echo "=== Summary ==="
echo ""
POSTGRES_COUNT=$(echo "$POSTGRES_CONTAINERS" | wc -l)
MYSQL_COUNT=$(echo "$MYSQL_CONTAINERS" | wc -l)
REDIS_COUNT=$(echo "$REDIS_CONTAINERS" | wc -l)

echo "PostgreSQL instances: $POSTGRES_COUNT"
echo "MySQL/MariaDB instances: $MYSQL_COUNT"
echo "Redis instances: $REDIS_COUNT"
echo ""
echo "For detailed documentation, see: docs/DATABASE_INSTANCES.md"
echo ""

