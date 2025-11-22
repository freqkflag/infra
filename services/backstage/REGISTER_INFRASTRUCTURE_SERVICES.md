# Register Infrastructure Services in Backstage

This guide explains how to register infrastructure services (WordPress, Supabase, Traefik, etc.) in Backstage for tracking and management.

---

## Quick Start

The infrastructure services are already configured in Backstage! They will be automatically loaded from the `infrastructure-entities.yaml` file when Backstage starts.

### Automatic Registration (Already Configured)

The infrastructure entities are defined in:
- **File:** `/root/infra/services/backstage/backstage/examples/infrastructure-entities.yaml`
- **Config:** Already added to `app-config.production.yaml`

**To activate:**
1. Restart Backstage to load the new entities:
   ```bash
   cd /root/infra/services/backstage
   docker compose restart backstage
   ```

2. Check the catalog in Backstage:
   - Navigate to `https://backstage.freqkflag.co/catalog`
   - All infrastructure services should appear under the "infrastructure" system

---

## Registered Services

The following infrastructure services are configured:

### Infrastructure Components
- **Traefik** - Reverse proxy and load balancer
- **Infisical** - Secrets management platform
- **Supabase** - Database platform (BaaS)
- **WordPress** - Content management system (cultofjoey.com)
- **WikiJS** - Documentation platform
- **n8n** - Workflow automation
- **Node-RED** - Flow-based development
- **LinkStack** - Link-in-bio page
- **GitLab** - Version control platform
- **Adminer** - Database management tool
- **Backstage** - Developer portal (this service)

### Resources
- **PostgreSQL** - Database cluster
- **MariaDB** - Database cluster
- **Redis** - Cache service

### APIs
- **Infisical API** - Secrets management API
- **Supabase API** - REST API for Supabase

---

## Manual Registration via API

If you need to register services manually or add new ones via API:

### Option 1: Add Location Directly

```bash
curl -X POST https://backstage.freqkflag.co/api/catalog/locations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <github-oauth-token>" \
  -d '{
    "type": "file",
    "target": "./examples/infrastructure-entities.yaml"
  }'
```

### Option 2: Register Individual Service

Create a `catalog-info.yaml` file for a new service:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-new-service
  description: Description of the service
  annotations:
    backstage.io/view-url: https://my-service.freqkflag.co
    infisical/projectId: 8c430744-1a5b-4426-af87-e96d6b9c91e3
spec:
  type: service
  lifecycle: production
  owner: platform-team
  system: infrastructure
  dependsOn:
    - resource:postgres
```

Then add it to Backstage:

```bash
# If stored in GitHub repo
curl -X POST https://backstage.freqkflag.co/api/catalog/locations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "type": "url",
    "target": "https://github.com/owner/repo/blob/main/catalog-info.yaml"
  }'
```

---

## Adding New Services to Infrastructure Catalog

To add a new infrastructure service:

1. **Edit the infrastructure entities file:**
   ```bash
   vim /root/infra/services/backstage/backstage/examples/infrastructure-entities.yaml
   ```

2. **Add your service component:**
   ```yaml
   ---
   # My New Service
   apiVersion: backstage.io/v1alpha1
   kind: Component
   metadata:
     name: my-new-service
     description: Description of my new service
     annotations:
       backstage.io/view-url: https://my-new-service.freqkflag.co
       infisical/projectId: 8c430744-1a5b-4426-af87-e96d6b9c91e3
       github.com/project-slug: freqkflag/infra
   spec:
     type: service
     lifecycle: production
     owner: platform-team
     system: infrastructure
     dependsOn:
       - resource:postgres
   ```

3. **Restart Backstage:**
   ```bash
   cd /root/infra/services/backstage
   docker compose restart backstage
   ```

4. **Verify in Backstage:**
   - Navigate to `https://backstage.freqkflag.co/catalog`
   - Find your new service under the "infrastructure" system

---

## Service Metadata Reference

### Component Types
- `infrastructure` - Core infrastructure services (Traefik, Infisical)
- `service` - Application services (WordPress, WikiJS, n8n)
- `website` - Public-facing websites (WordPress, LinkStack)
- `tool` - Development/admin tools (Adminer, Backstage)

### Lifecycle Stages
- `production` - Live production services
- `experimental` - Experimental/testing services
- `deprecated` - Services being phased out

### Dependencies
- `dependsOn` - Services this component depends on
- `providesApis` - APIs this component provides

### Annotations
- `backstage.io/view-url` - Direct link to service UI
- `infisical/projectId` - Link to Infisical project for secrets
- `github.com/project-slug` - GitHub repository link

---

## Viewing Services in Backstage

Once registered, you can:

1. **Browse the catalog:**
   - Go to `https://backstage.freqkflag.co/catalog`
   - Filter by system: "infrastructure"
   - Filter by type: Component, Resource, API

2. **View service details:**
   - Click on any service to see:
     - Dependencies graph
     - API documentation
     - Infisical secrets (if linked)
     - Health status
     - Owner information

3. **Search services:**
   - Use the search bar at the top
   - Search by name, type, or owner

---

## Troubleshooting

### Services Not Appearing

1. **Check Backstage logs:**
   ```bash
   docker compose logs backstage | grep -i catalog
   ```

2. **Verify configuration:**
   ```bash
   # Check if location is configured
   docker exec backstage cat /app/app-config.production.yaml | grep infrastructure
   ```

3. **Check file path:**
   ```bash
   # Verify file exists in container
   docker exec backstage ls -la /app/examples/infrastructure-entities.yaml
   ```

### Entities Not Loading

1. **Restart Backstage:**
   ```bash
   docker compose restart backstage
   ```

2. **Check entity validation:**
   - Go to `https://backstage.freqkflag.co/catalog`
   - Check for validation errors on entities

3. **Verify YAML syntax:**
   ```bash
   # Test YAML syntax
   docker exec backstage cat /app/examples/infrastructure-entities.yaml | grep -v "^---$" | head -20
   ```

---

## API Endpoints Reference

See `/root/infra/services/backstage/API_ENDPOINTS.md` for complete API documentation.

### Quick Commands

```bash
# List all catalog locations
curl https://backstage.freqkflag.co/api/catalog/locations \
  -H "Authorization: Bearer <token>"

# List all entities
curl "https://backstage.freqkflag.co/api/catalog/entities?filter=system=infrastructure" \
  -H "Authorization: Bearer <token>"

# Get specific entity
curl https://backstage.freqkflag.co/api/catalog/entities/by-name/Component/default/wordpress \
  -H "Authorization: Bearer <token>"
```

---

## Next Steps

1. ✅ **Infrastructure services registered** - All services are in `infrastructure-entities.yaml`
2. ✅ **Configuration updated** - Location added to `app-config.production.yaml`
3. 🔄 **Restart Backstage** - Restart to load entities
4. ✅ **Verify in UI** - Check catalog at `https://backstage.freqkflag.co/catalog`

For more information, see:
- [Backstage Catalog Documentation](https://backstage.io/docs/features/software-catalog/)
- [Entity Descriptor Format](https://backstage.io/docs/features/software-catalog/descriptor-format)
- [API Endpoints Reference](./API_ENDPOINTS.md)

