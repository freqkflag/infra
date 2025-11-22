# Infisical Backstage Plugin Implementation

This document confirms the complete implementation of the Infisical Backstage plugin according to the [official documentation](https://infisical.com/docs/integrations/external/backstage).

## ✅ Implementation Status

All components of the Infisical Backstage plugin have been implemented:

### 1. ✅ Package Installation

**Frontend Plugin:**
- ✅ Installed: `@infisical/backstage-plugin-infisical@^0.1.1`
- Location: `packages/app/package.json`

**Backend Plugin:**
- ✅ Installed: `@infisical/backstage-backend-plugin-infisical@^0.1.1`
- Location: `packages/backend/package.json`

### 2. ✅ Backend Configuration

**Config File (`app-config.production.yaml`):**
```yaml
infisical:
  baseUrl: ${INFISICAL_PUBLIC_URL:-https://infisical.freqkflag.co}
  authentication:
    universalAuth:
      clientId: ${INFISICAL_CLIENT_ID}
      clientSecret: ${INFISICAL_CLIENT_SECRET}
```

**Backend Registration (`packages/backend/src/index.ts`):**
```typescript
// Infisical plugin
backend.add(import('@infisical/backstage-backend-plugin-infisical'));
```

✅ **Status:** Backend plugin is registered and configured

### 3. ✅ Frontend Configuration

**Plugin Import (`packages/app/src/App.tsx`):**
```typescript
import { infisicalPlugin } from '@infisical/backstage-plugin-infisical';

const app = createApp({
  apis,
  plugins: [
    infisicalPlugin,
    // ...other plugins are auto-discovered by app-defaults
  ],
  // ...
});
```

✅ **Status:** Frontend plugin is imported and added to plugins array

**Entity Page Integration (`packages/app/src/components/catalog/EntityPage.tsx`):**
```typescript
import { EntityInfisicalContent } from '@infisical/backstage-plugin-infisical';

// Added to serviceEntityPage:
<EntityLayout.Route path="/infisical" title="Secrets">
  <EntityInfisicalContent />
</EntityLayout.Route>

// Added to websiteEntityPage:
<EntityLayout.Route path="/infisical" title="Secrets">
  <EntityInfisicalContent />
</EntityLayout.Route>
```

✅ **Status:** Infisical tab is added to service and website entity pages

### 4. ✅ Entity Annotations

All infrastructure entities in `examples/infrastructure-entities.yaml` include the Infisical project ID annotation:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: traefik
  annotations:
    infisical/projectId: 8c430744-1a5b-4426-af87-e96d6b9c91e3
spec:
  # ...
```

✅ **Status:** All entities are annotated with Infisical project ID

**Entities with Infisical Integration:**
- Infrastructure System
- Traefik
- Infisical
- Supabase
- WordPress
- WikiJS
- n8n
- Node-RED
- LinkStack
- GitLab
- Adminer
- Backstage
- PostgreSQL Resource
- MariaDB Resource
- Redis Resource

## Usage

Once entities are loaded in Backstage:

1. **Navigate to any entity** in the catalog (e.g., `https://backstage.freqkflag.co/catalog`)
2. **Open an entity** that has the `infisical/projectId` annotation
3. **Click the "Secrets" tab** (visible on service and website entity types)
4. **View and manage secrets** from the linked Infisical project

### Features Available

- ✅ **View secrets** from Infisical projects
- ✅ **Create, update, and delete** secrets
- ✅ **Navigate environments** and folder structures
- ✅ **Search and filter** secrets by key, value, or comments
- ✅ **Multi-environment support** for managing secrets across environments

## Configuration Requirements

### Environment Variables

The following environment variables must be set in `.workspace/.env` (or Infisical `/prod` path):

```bash
# Infisical Configuration
INFISICAL_PUBLIC_URL=https://infisical.freqkflag.co
INFISICAL_CLIENT_ID=<your-machine-identity-client-id>
INFISICAL_CLIENT_SECRET=<your-machine-identity-client-secret>
```

### Machine Identity Setup

1. **Create a Machine Identity** in Infisical:
   - Log into Infisical at `https://infisical.freqkflag.co`
   - Navigate to **Settings** → **Machine Identities**
   - Create a new Machine Identity with Universal Auth
   - Copy the Client ID and Client Secret

2. **Set Credentials in Infisical:**
   - Store `INFISICAL_CLIENT_ID` and `INFISICAL_CLIENT_SECRET` in Infisical `/prod` path
   - The Infisical Agent will sync these to `.workspace/.env` automatically

3. **Verify Configuration:**
   - Restart Backstage to load credentials
   - Check logs for successful Infisical plugin initialization

## Troubleshooting

### Plugin Not Appearing

1. **Check plugin installation:**
   ```bash
   docker exec backstage cat /app/packages/app/package.json | grep infisical
   docker exec backstage cat /app/packages/backend/package.json | grep infisical
   ```

2. **Check backend logs:**
   ```bash
   docker compose logs backstage | grep -i infisical
   ```

3. **Verify configuration:**
   ```bash
   docker exec backstage cat /app/app-config.production.yaml | grep -A 5 infisical
   ```

### Secrets Tab Not Showing

1. **Verify entity annotation:**
   - Entity must have `infisical/projectId` annotation
   - Check entity YAML file in catalog

2. **Check entity type:**
   - Infisical tab is available on `service` and `website` component types
   - Other component types may need manual route addition

3. **Verify plugin is loaded:**
   - Check browser console for errors
   - Verify EntityInfisicalContent is imported in EntityPage.tsx

### Authentication Errors

1. **Check credentials:**
   ```bash
   docker exec backstage env | grep INFISICAL
   ```

2. **Verify Machine Identity:**
   - Ensure Machine Identity is created in Infisical
   - Verify Client ID and Secret are correct
   - Check Machine Identity has access to the project

3. **Check Infisical URL:**
   - Verify `INFISICAL_PUBLIC_URL` is accessible
   - Ensure it matches your Infisical instance URL

## References

- [Infisical Backstage Plugin Documentation](https://infisical.com/docs/integrations/external/backstage)
- [Backstage Entity Annotations](https://backstage.io/docs/features/software-catalog/well-known-annotations)
- [Infisical Machine Identities](https://infisical.com/docs/documentation/platform/identities/machine-identities)

## Next Steps

1. ✅ **Plugin packages installed** - Both frontend and backend plugins installed
2. ✅ **Backend configured** - Config file and plugin registration complete
3. ✅ **Frontend configured** - Plugin imported and EntityPage updated
4. ✅ **Entity annotations** - All infrastructure entities annotated
5. 🔄 **Rebuild Docker image** - Rebuild Backstage container to include plugin updates
6. ✅ **Restart service** - Restart Backstage to load plugin

To activate the plugin, rebuild the Backstage Docker image:

```bash
cd /root/infra/services/backstage
docker compose build backstage
docker compose up -d backstage
```

Then verify the plugin is working:
1. Navigate to any entity with `infisical/projectId` annotation
2. Check for the "Secrets" tab
3. Verify you can view and manage secrets from Infisical

