# Infrastructure Scripts

Utility scripts for infrastructure management.

## scan-images.sh

Trivy-based Docker image vulnerability scanning.

**Usage:**
```bash
./scripts/scan-images.sh
```

**What it does:**
- Scans all Docker images used in docker-compose.yml files
- Reports HIGH and CRITICAL vulnerabilities
- Exits with code 1 if vulnerabilities found

**Requirements:**
- Docker
- Trivy (automatically pulled as Docker image)

**Output:**
- Green checkmark for clean images
- Red X and detailed report for vulnerable images

## Other Scripts

Additional utility scripts will be added here as needed.

