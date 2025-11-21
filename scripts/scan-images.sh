#!/bin/bash
# Trivy image vulnerability scanning script
# Scans all Docker images used in the infrastructure

set -e

TRIVY_IMAGE="aquasec/trivy:latest"
SCAN_DIR="/root/infra"
EXIT_CODE=0

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Starting image vulnerability scan..."

# Find all docker-compose.yml files
COMPOSE_FILES=$(find "$SCAN_DIR" -name "docker-compose.yml" -type f)

# Extract unique images from all compose files
IMAGES=$(grep -h "image:" $COMPOSE_FILES | sed 's/.*image: *//' | sed 's/${.*}//' | sort -u | grep -v "^$")

if [ -z "$IMAGES" ]; then
    echo "No images found to scan."
    exit 0
fi

echo "Found $(echo "$IMAGES" | wc -l) unique images to scan"
echo ""

# Scan each image
for IMAGE in $IMAGES; do
    echo "Scanning: $IMAGE"
    
    # Run Trivy scan
    if docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
        "$TRIVY_IMAGE" image --severity HIGH,CRITICAL --exit-code 1 --quiet "$IMAGE" 2>&1; then
        echo -e "${GREEN}✓${NC} $IMAGE - No high/critical vulnerabilities"
    else
        echo -e "${RED}✗${NC} $IMAGE - High/critical vulnerabilities found!"
        EXIT_CODE=1
        
        # Show detailed report
        echo "Detailed report:"
        docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
            "$TRIVY_IMAGE" image --severity HIGH,CRITICAL "$IMAGE"
    fi
    echo ""
done

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}All images passed security scan${NC}"
else
    echo -e "${RED}Some images have high/critical vulnerabilities${NC}"
    echo "Review the reports above and update images as needed."
fi

exit $EXIT_CODE

