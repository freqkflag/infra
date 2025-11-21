# Services Registry

Machine-readable service registry for infrastructure automation and tooling.

## Registry File

**Location:** `/root/infra/SERVICES.yml`

This YAML file contains the complete service catalog with:
- Service IDs and names
- Directory paths
- URLs and domains
- Service types (infra/app/db)
- Dependencies
- Status information

## Usage

### Query Services

```bash
# List all services
yq '.services[].id' SERVICES.yml

# List running services
yq '.services[] | select(.status == "running") | .id' SERVICES.yml

# List services by type
yq '.services[] | select(.type == "app") | .id' SERVICES.yml

# Get service dependencies
yq '.services[] | select(.id == "wikijs") | .depends_on' SERVICES.yml
```

### Validate Registry

```bash
# Check YAML syntax
python3 -c "import yaml; yaml.safe_load(open('SERVICES.yml'))"

# Verify all services exist
for service in $(yq '.services[].id' SERVICES.yml); do
  if [ -d "/root/infra/$service" ]; then
    echo "✓ $service"
  else
    echo "✗ $service missing"
  fi
done
```

## Service Types

- **infra** - Infrastructure services (Traefik, Vault, monitoring, etc.)
- **app** - Application services (WikiJS, WordPress, etc.)
- **db** - Database services (PostgreSQL, MySQL, Redis)

## Status Values

- **running** - Service is currently active
- **configured** - Service is configured but not running

## Dependencies

Dependencies are listed as service IDs. Common dependencies:
- `traefik` - Required by all web-accessible services
- `postgres` - PostgreSQL database
- `mysql` - MySQL database
- `redis` - Redis cache

## Updating the Registry

When adding a new service:

1. Add entry to `SERVICES.yml`
2. Include: id, name, dir, url, type, status, depends_on
3. Verify YAML syntax
4. Update this documentation if needed

---

**See:** [SERVICES.yml](./SERVICES.yml) for the complete registry

