#!/bin/bash
# Service Location Audit Script
# Purpose: Audit all service locations and identify consolidation opportunities
# Usage: ./scripts/audit-service-locations.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$INFRA_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Service Location Audit"
echo "Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
echo "=========================================="
echo ""

# Find all compose files
echo "=== All Compose Files ==="
echo ""
find . -name 'docker-compose.yml' -o -name 'compose.yml' | grep -v node_modules | grep -v ".git" | sort | while read -r compose_file; do
    echo "$compose_file"
done

echo ""
echo "=== Services in Root Directory ==="
echo ""
ROOT_SERVICES=$(find . -maxdepth 2 -name 'docker-compose.yml' -o -name 'compose.yml' | grep -v node_modules | grep -v ".git" | grep -v "services/" | grep -v "nodes/" | grep -v ".devcontainer/" | sort)

if [ -z "$ROOT_SERVICES" ]; then
    echo -e "${GREEN}No services in root directory${NC}"
else
    printf "%-40s %-20s %-15s\n" "SERVICE" "LOCATION" "COMPOSE FILE"
    printf "%-40s %-20s %-15s\n" "----------------------------------------" "--------------------" "---------------"
    
    for compose_file in $ROOT_SERVICES; do
        service_dir=$(dirname "$compose_file")
        service_name=$(basename "$service_dir")
        compose_name=$(basename "$compose_file")
        
        # Check if duplicate exists in services/
        if [ -f "services/${service_name}/compose.yml" ] || [ -f "services/${service_name}/docker-compose.yml" ]; then
            status="${YELLOW}DUPLICATE${NC}"
        else
            status="${RED}ROOT ONLY${NC}"
        fi
        
        printf "%-40s %-20s %-15s %s\n" "$service_name" "$service_dir" "$compose_name" "$status"
    done
fi

echo ""
echo "=== Services in /services Directory ==="
echo ""
SERVICES_DIR=$(find ./services -name 'compose.yml' -o -name 'docker-compose.yml' | sort)

if [ -z "$SERVICES_DIR" ]; then
    echo -e "${YELLOW}No services in /services directory${NC}"
else
    printf "%-40s %-20s %-15s\n" "SERVICE" "LOCATION" "COMPOSE FILE"
    printf "%-40s %-20s %-15s\n" "----------------------------------------" "--------------------" "---------------"
    
    for compose_file in $SERVICES_DIR; do
        service_dir=$(dirname "$compose_file")
        service_name=$(basename "$service_dir")
        compose_name=$(basename "$compose_file")
        
        # Check if duplicate exists in root
        root_compose=$(find . -maxdepth 2 -path "./${service_name}/docker-compose.yml" -o -path "./${service_name}/compose.yml" 2>/dev/null | head -1)
        if [ -n "$root_compose" ]; then
            status="${YELLOW}DUPLICATE${NC}"
        else
            status="${GREEN}CORRECT${NC}"
        fi
        
        printf "%-40s %-20s %-15s %s\n" "$service_name" "$service_dir" "$compose_name" "$status"
    done
fi

echo ""
echo "=== Duplicate Services ==="
echo ""
DUPLICATES=$(comm -12 <(find . -maxdepth 2 -name 'docker-compose.yml' -o -name 'compose.yml' | grep -v node_modules | grep -v ".git" | grep -v "services/" | grep -v "nodes/" | xargs -I {} basename $(dirname {}) | sort -u) <(find ./services -name 'compose.yml' -o -name 'docker-compose.yml' | xargs -I {} basename $(dirname {}) | sort -u))

if [ -z "$DUPLICATES" ]; then
    echo -e "${GREEN}No duplicate services found${NC}"
else
    echo -e "${YELLOW}Found duplicate services:${NC}"
    for service in $DUPLICATES; do
        echo "  - $service (root: ./${service}/, services: ./services/${service}/)"
    done
fi

echo ""
echo "=== Summary ==="
echo ""
ROOT_COUNT=$(echo "$ROOT_SERVICES" | wc -l)
SERVICES_COUNT=$(echo "$SERVICES_DIR" | wc -l)
DUPLICATE_COUNT=$(echo "$DUPLICATES" | wc -l)

echo "Services in root directory: $ROOT_COUNT"
echo "Services in /services directory: $SERVICES_COUNT"
echo "Duplicate services: $DUPLICATE_COUNT"
echo ""
echo "For detailed migration plan, see: docs/SERVICE_CONSOLIDATION_PLAN.md"
echo ""

