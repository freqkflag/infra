#!/bin/bash
# Environment Variable Loading Validation Script
# Purpose: Validate environment variable loading in compose files
# Usage: ./scripts/validate-env-loading.sh [service-path]

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

ERRORS=0
WARNINGS=0

# Function to check if file exists
check_file() {
    local file=$1
    if [ ! -f "$file" ]; then
        echo -e "${RED}ERROR: $file not found${NC}"
        ((ERRORS++))
        return 1
    fi
    return 0
}

# Function to validate env_file path
validate_env_file_path() {
    local compose_file=$1
    local env_file_path=$2
    local compose_dir=$(dirname "$compose_file")
    
    # Resolve relative path
    local resolved_path=$(cd "$compose_dir" && cd "$(dirname "$env_file_path")" && pwd)/$(basename "$env_file_path")
    
    if [ ! -f "$resolved_path" ]; then
        echo -e "${RED}ERROR: env_file path not found: $env_file_path (resolved: $resolved_path)${NC}"
        ((ERRORS++))
        return 1
    fi
    
    return 0
}

# Function to check required variables in .env file
check_required_vars() {
    local compose_file=$1
    local env_file="$INFRA_DIR/.workspace/.env"
    
    if [ ! -f "$env_file" ]; then
        echo -e "${RED}ERROR: .workspace/.env not found${NC}"
        echo "  Run Infisical Agent or sync secrets: infisical export --env prod --path /prod --format env > .workspace/.env"
        ((ERRORS++))
        return 1
    fi
    
    # Extract variable references from compose file
    local required_vars=$(grep -oE '\$\{[A-Z_][A-Z0-9_]*\}' "$compose_file" 2>/dev/null | sed 's/\${//;s/}//' | sort -u)
    
    if [ -z "$required_vars" ]; then
        return 0
    fi
    
    local missing_vars=()
    for var in $required_vars; do
        if ! grep -q "^${var}=" "$env_file" 2>/dev/null; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -gt 0 ]; then
        echo -e "${YELLOW}WARNING: Missing variables in .workspace/.env:${NC}"
        for var in "${missing_vars[@]}"; do
            echo "  - $var"
        done
        ((WARNINGS++))
    fi
    
    return 0
}

# Function to validate compose file
validate_compose_file() {
    local compose_file=$1
    
    if [ ! -f "$compose_file" ]; then
        echo -e "${RED}ERROR: Compose file not found: $compose_file${NC}"
        ((ERRORS++))
        return 1
    fi
    
    echo -e "${BLUE}Validating: $compose_file${NC}"
    
    # Check if env_file is used
    if grep -q "env_file:" "$compose_file"; then
        # Extract env_file paths
        local env_files=$(grep "env_file:" -A 1 "$compose_file" | grep -v "env_file:" | sed 's/^[[:space:]]*-[[:space:]]*//' | sed 's/^[[:space:]]*//')
        
        for env_file in $env_files; do
            # Remove quotes if present
            env_file=$(echo "$env_file" | sed "s/^['\"]//;s/['\"]$//")
            
            echo "  Checking env_file: $env_file"
            validate_env_file_path "$compose_file" "$env_file"
        done
    else
        echo -e "${YELLOW}  WARNING: No env_file directive found${NC}"
        echo "    This compose file may require environment variables in shell or --env-file flag"
        ((WARNINGS++))
    fi
    
    # Check for variable references
    if grep -qE '\$\{[A-Z_][A-Z0-9_]*\}' "$compose_file"; then
        echo "  Checking required variables..."
        check_required_vars "$compose_file"
    fi
    
    # Validate compose syntax
    if command -v docker &> /dev/null; then
        if docker compose -f "$compose_file" config > /dev/null 2>&1; then
            echo -e "${GREEN}  ✓ Compose syntax valid${NC}"
        else
            echo -e "${RED}  ✗ Compose syntax invalid${NC}"
            docker compose -f "$compose_file" config 2>&1 | head -10
            ((ERRORS++))
        fi
    fi
    
    echo ""
}

# Main validation
echo "=========================================="
echo "Environment Variable Loading Validation"
echo "Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
echo "=========================================="
echo ""

# Check if .workspace/.env exists
if [ ! -f ".workspace/.env" ]; then
    echo -e "${RED}ERROR: .workspace/.env not found${NC}"
    echo "  This file is required for environment variable loading"
    echo "  Run Infisical Agent or sync secrets:"
    echo "    infisical export --env prod --path /prod --format env > .workspace/.env"
    echo ""
    ((ERRORS++))
else
    echo -e "${GREEN}✓ .workspace/.env found${NC}"
    ENV_VAR_COUNT=$(grep -c "^[A-Z_].*=" .workspace/.env 2>/dev/null || echo "0")
    echo "  Variables in file: $ENV_VAR_COUNT"
    echo ""
fi

# Validate specific service or all services
if [ $# -gt 0 ]; then
    # Validate specific service
    SERVICE_PATH="$1"
    if [ -f "$SERVICE_PATH" ]; then
        validate_compose_file "$SERVICE_PATH"
    elif [ -f "$SERVICE_PATH/compose.yml" ]; then
        validate_compose_file "$SERVICE_PATH/compose.yml"
    elif [ -f "$SERVICE_PATH/docker-compose.yml" ]; then
        validate_compose_file "$SERVICE_PATH/docker-compose.yml"
    else
        echo -e "${RED}ERROR: Compose file not found for: $SERVICE_PATH${NC}"
        ((ERRORS++))
    fi
else
    # Validate all compose files
    echo "Scanning for compose files..."
    echo ""
    
    find . -name "compose.yml" -o -name "docker-compose.yml" | grep -v ".git" | sort | while read -r compose_file; do
        # Skip node_modules and other excluded directories
        if [[ "$compose_file" == *"node_modules"* ]] || [[ "$compose_file" == *".git"* ]]; then
            continue
        fi
        
        validate_compose_file "$compose_file"
    done
fi

# Summary
echo "=========================================="
echo "Validation Summary"
echo "=========================================="
echo -e "Errors: ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All validations passed${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Validation completed with warnings${NC}"
    exit 0
else
    echo -e "${RED}✗ Validation failed with errors${NC}"
    exit 1
fi

