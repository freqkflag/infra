# Backstage Service

**Domain:** `backstage.freqkflag.co`  
**Location:** `/root/infra/services/backstage/`  
**Status:** ⚙️ Configured (not running)  
**Purpose:** Developer portal and software catalog

## Overview

Backstage is an open-source platform for building developer portals. This instance is configured with:

- PostgreSQL database for persistent storage
- Infisical plugin for secrets management integration
- Traefik reverse proxy with SSL/TLS termination
- Guest authentication (can be extended with other providers)

## Services

- **Backstage Application:** Main application container
- **PostgreSQL Database:** Dedicated database for Backstage

## Configuration

### Environment Variables

Required environment variables (set in `.workspace/.env`):

```bash
BACKSTAGE_DOMAIN=backstage.freqkflag.co
BACKSTAGE_DB_NAME=backstage
BACKSTAGE_DB_USER=backstage
BACKSTAGE_DB_PASSWORD=<generated_password>

# Infisical integration
INFISICAL_PUBLIC_URL=https://infisical.freqkflag.co
INFISICAL_CLIENT_ID=<client_id>
INFISICAL_CLIENT_SECRET=<client_secret>
```

### Infisical Plugin Configuration

The Infisical plugin is pre-configured and allows Backstage entities to link to Infisical projects for secrets management.

**Configuration Location:**
- Backend: `packages/backend/src/index.ts`
- Frontend: `packages/app/src/App.tsx`
- Config: `app-config.production.yaml`

## Using the Infisical Plugin

### Linking Entities to Infisical Projects

To link a Backstage entity to an Infisical project, add the `infisical/projectId` annotation to your entity's `catalog-info.yaml`:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-service
  annotations:
    infisical/projectId: <your-infisical-project-id>
spec:
  type: service
  lifecycle: production
  owner: team-name
```

### Accessing Secrets in Backstage

Once an entity is linked to an Infisical project:

1. Navigate to the entity page in Backstage
2. Click on the **"Secrets"** tab
3. View and manage secrets from the linked Infisical project

### Finding Your Infisical Project ID

1. Log into Infisical at `https://infisical.freqkflag.co`
2. Navigate to your project
3. The project ID is visible in the URL or project settings

## Building and Deployment

### Build Process

The Docker build process handles:
1. Installing all dependencies (including Infisical plugins)
2. Building the frontend application
3. Building the backend application
4. Creating the production image

### Starting the Service

```bash
cd /root/infra/services/backstage
docker compose up -d
```

### Viewing Logs

```bash
docker compose logs -f backstage
```

### Health Check

The service includes a health check that verifies the Node.js backend process is running.

## Database

Backstage uses PostgreSQL 16 for persistent storage. The database is automatically initialized on first startup.

### Database Backup

```bash
docker exec backstage-db pg_dump -U backstage backstage > backstage_backup.sql
```

### Database Restore

```bash
docker exec -i backstage-db psql -U backstage backstage < backstage_backup.sql
```

## Troubleshooting

### Build Issues

If the Docker build fails:
1. Check that all required environment variables are set
2. Verify network connectivity for downloading dependencies
3. Review build logs: `docker compose build backstage 2>&1 | tee build.log`

### Plugin Not Appearing

If the Infisical plugin doesn't appear:
1. Verify the plugin packages are in `package.json` files
2. Check that the plugin is imported in `App.tsx` and `index.ts`
3. Rebuild the Docker image: `docker compose build --no-cache backstage`

### Database Connection Issues

If Backstage can't connect to the database:
1. Verify `backstage-db` container is running: `docker compose ps`
2. Check database logs: `docker compose logs backstage-db`
3. Verify environment variables are correct

## Development

### Local Development

For local development (outside Docker):

```bash
cd /root/infra/services/backstage/backstage
yarn install
yarn start
```

### Adding New Plugins

1. Install the plugin package:
   ```bash
   yarn workspace app add <plugin-package>  # for frontend
   yarn workspace backend add <plugin-package>  # for backend
   ```

2. Register the plugin in the appropriate file:
   - Frontend: `packages/app/src/App.tsx`
   - Backend: `packages/backend/src/index.ts`

3. Rebuild the Docker image

## Security Notes

- All secrets should be stored in Infisical, not in Backstage configuration
- Use the Infisical plugin to access secrets from within Backstage
- Guest authentication is enabled by default; consider adding other auth providers for production

## References

- [Backstage Documentation](https://backstage.io/docs)
- [Infisical Backstage Plugin](https://infisical.com/docs/integrations/external/backstage)
- [Backstage Entity Annotations](https://backstage.io/docs/features/software-catalog/well-known-annotations)

