# GitHub Actions Workflows

CI/CD pipelines for infrastructure management.

## Workflows

### CI Pipeline (`ci.yml`)

Runs on every push and pull request:
- **Lint:** Validates YAML syntax and docker-compose configurations
- **Security:** Scans for vulnerabilities using Trivy
- **Test:** Validates health checks and resource limits

### Configuration Validation (`test.yml`)

Validates all docker-compose.yml files:
- Syntax validation
- Required files check
- Environment variable validation

### Security Scan (`security-scan.yml`)

Weekly security scanning:
- Scans all Docker images
- Reports HIGH and CRITICAL vulnerabilities
- Uploads results to GitHub Security

### Deploy (`deploy.yml`)

Deployment workflow:
- Validates configurations
- Runs security scans
- Prepares for deployment
- Manual or SSH deployment (configure as needed)

### Update Images (`update-images.yml`)

Weekly image update check:
- Checks for outdated images
- Creates issues for manual review

## Usage

### Manual Triggers

All workflows can be manually triggered from the GitHub Actions tab.

### Secrets Required

For SSH deployment (if configured):
- `SSH_HOST` - Server hostname
- `SSH_USER` - SSH username
- `SSH_KEY` - SSH private key

## Local Testing

Test workflows locally using [act](https://github.com/nektos/act):

```bash
# Install act
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Run CI pipeline
act -j lint
act -j security
act -j test
```

## Customization

Edit workflow files to:
- Add deployment steps
- Configure notification channels
- Adjust scan schedules
- Add custom validation steps

