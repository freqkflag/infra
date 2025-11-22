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

## runme-dispatch.sh

Command dispatcher for routing commands to local shell execution or Cursor agent prompt generation.

**Usage:**
```bash
echo 'docker ps' | ./scripts/runme-dispatch.sh
cat commands.txt | ./scripts/runme-dispatch.sh
```

**What it does:**
- Reads commands from stdin
- Prompts for execution target (local shell vs Cursor agent)
- For local execution: runs commands directly with service context detection
- For agent execution: generates ready-to-paste agent prompt with service metadata

**Features:**
- Automatic service context detection from command patterns (e.g., `cd /root/infra/wikijs`, `./wikijs/docker-compose.yml`)
- Service metadata extraction from `SERVICES.yml`
- Multi-line command execution support
- Interactive execution target selection

**Execution Targets:**
1. **Local shell** - Executes commands directly in the appropriate directory context
2. **Cursor agent** - Generates a formatted agent prompt with service metadata ready to paste

**Requirements:**
- Bash 4.0+
- `SERVICES.yml` for service metadata (optional, script handles missing file gracefully)
- `yq` (optional) for YAML parsing, falls back to grep-based extraction

**Example:**
```bash
# Generate agent prompt for wikijs commands
echo 'cd wikijs && docker compose ps' | ./scripts/runme-dispatch.sh
# Select option 2 (Cursor agent) to get formatted prompt with service metadata
```

## Other Scripts

Additional utility scripts will be added here as needed.

