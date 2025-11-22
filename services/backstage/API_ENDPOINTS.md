# Backstage API Endpoints

**Base URL:** `https://backstage.freqkflag.co`  
**Backend Port:** `7007`  
**API Base:** `https://backstage.freqkflag.co/api`

This document lists all API endpoints available in the Scaffolded Backstage App for tracking components and managing the software catalog.

---

## Authentication

All API endpoints require authentication via GitHub OAuth. Include the authentication token in requests:

```bash
Authorization: Bearer <github-oauth-token>
```

Or use session cookies if accessing via browser.

---

## Catalog Location API

### Add Location (Register Component)

**POST** `/api/catalog/locations`

Register a new location for Backstage to track. This is the primary endpoint for "Start tracking your component".

**Request Body:**
```json
{
  "type": "url",
  "target": "https://github.com/owner/repo/blob/main/catalog-info.yaml"
}
```

**Example:**
```bash
curl -X POST https://backstage.freqkflag.co/api/catalog/locations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "type": "url",
    "target": "https://github.com/owner/repo/blob/main/catalog-info.yaml"
  }'
```

**Supported Location Types:**
- `url` - GitHub, GitLab, or other Git repository URL
- `file` - Local file path (relative to backend process)
- `github` - GitHub repository (requires GitHub integration configured)

**Response:**
```json
{
  "location": {
    "id": "generated-id",
    "type": "url",
    "target": "https://github.com/owner/repo/blob/main/catalog-info.yaml"
  },
  "entities": [
    {
      "metadata": {
        "name": "component-name",
        "namespace": "default"
      },
      "kind": "Component"
    }
  ]
}
```

### List Locations

**GET** `/api/catalog/locations`

List all registered catalog locations.

**Example:**
```bash
curl https://backstage.freqkflag.co/api/catalog/locations \
  -H "Authorization: Bearer <token>"
```

### Get Location

**GET** `/api/catalog/locations/{id}`

Get details about a specific location.

**Example:**
```bash
curl https://backstage.freqkflag.co/api/catalog/locations/<location-id> \
  -H "Authorization: Bearer <token>"
```

### Delete Location

**DELETE** `/api/catalog/locations/{id}`

Remove a location from the catalog (stops tracking).

**Example:**
```bash
curl -X DELETE https://backstage.freqkflag.co/api/catalog/locations/<location-id> \
  -H "Authorization: Bearer <token>"
```

---

## Catalog Import API

### Analyze Repository

**POST** `/api/catalog-import/analyze`

Analyze a repository URL to check if it contains a `catalog-info.yaml` file and what entities it would import.

**Request Body:**
```json
{
  "repoUrl": "https://github.com/owner/repo"
}
```

**Example:**
```bash
curl -X POST https://backstage.freqkflag.co/api/catalog-import/analyze \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "repoUrl": "https://github.com/owner/repo"
  }'
```

**Response:**
```json
{
  "locations": [
    {
      "target": "https://github.com/owner/repo/blob/main/catalog-info.yaml",
      "entities": [
        {
          "kind": "Component",
          "metadata": {
            "name": "my-service"
          }
        }
      ]
    }
  ],
  "type": "repository",
  "url": "https://github.com/owner/repo"
}
```

### Import Repository

**POST** `/api/catalog-import`

Import a repository and register its entities in the catalog.

**Request Body:**
```json
{
  "repoUrl": "https://github.com/owner/repo",
  "catalogInfoPath": "/catalog-info.yaml"
}
```

**Example:**
```bash
curl -X POST https://backstage.freqkflag.co/api/catalog-import \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "repoUrl": "https://github.com/owner/repo",
    "catalogInfoPath": "/catalog-info.yaml"
  }'
```

---

## Catalog Entities API

### List Entities

**GET** `/api/catalog/entities`

List all entities in the catalog with optional filtering.

**Query Parameters:**
- `filter` - Filter entities (e.g., `kind=Component,metadata.namespace=default`)
- `fields` - Specify fields to return
- `limit` - Maximum number of results
- `offset` - Pagination offset

**Example:**
```bash
curl "https://backstage.freqkflag.co/api/catalog/entities?filter=kind=Component" \
  -H "Authorization: Bearer <token>"
```

### Get Entity by Name

**GET** `/api/catalog/entities/by-name/{kind}/{namespace}/{name}`

Get a specific entity by its kind, namespace, and name.

**Example:**
```bash
curl https://backstage.freqkflag.co/api/catalog/entities/by-name/Component/default/my-service \
  -H "Authorization: Bearer <token>"
```

### Get Entities by Reference

**GET** `/api/catalog/entities/by-ref`

Get entities by their reference strings.

**Query Parameters:**
- `filter` - Entity references (e.g., `component:default/my-service`)

**Example:**
```bash
curl "https://backstage.freqkflag.co/api/catalog/entities/by-ref?filter=component:default/my-service" \
  -H "Authorization: Bearer <token>"
```

---

## Scaffolder API

### List Templates

**GET** `/api/scaffolder/templates`

List all available scaffolder templates.

**Example:**
```bash
curl https://backstage.freqkflag.co/api/scaffolder/templates \
  -H "Authorization: Bearer <token>"
```

### Get Template

**GET** `/api/scaffolder/templates/{namespace}/{name}`

Get details about a specific template.

**Example:**
```bash
curl https://backstage.freqkflag.co/api/scaffolder/templates/default/example-nodejs-template \
  -H "Authorization: Bearer <token>"
```

### Execute Template (Create Task)

**POST** `/api/scaffolder/v2/tasks`

Create a new scaffolding task to generate a component from a template.

**Request Body:**
```json
{
  "templateRef": "template:default/example-nodejs-template",
  "values": {
    "name": "my-new-service",
    "repoUrl": "https://github.com/owner/my-new-service"
  }
}
```

**Example:**
```bash
curl -X POST https://backstage.freqkflag.co/api/scaffolder/v2/tasks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "templateRef": "template:default/example-nodejs-template",
    "values": {
      "name": "my-new-service",
      "repoUrl": "https://github.com/owner/my-new-service"
    }
  }'
```

**Response:**
```json
{
  "id": "task-id"
}
```

### Get Task Status

**GET** `/api/scaffolder/v2/tasks/{taskId}`

Get the status of a scaffolding task.

**Example:**
```bash
curl https://backstage.freqkflag.co/api/scaffolder/v2/tasks/<task-id> \
  -H "Authorization: Bearer <token>"
```

### Get Task Event Stream

**GET** `/api/scaffolder/v2/tasks/{taskId}/eventstream`

Stream events from a running scaffolding task (SSE format).

**Example:**
```bash
curl https://backstage.freqkflag.co/api/scaffolder/v2/tasks/<task-id>/eventstream \
  -H "Authorization: Bearer <token>"
```

---

## Authentication API

### GitHub OAuth Callback

**GET** `/api/auth/github/handler/frame`

GitHub OAuth callback endpoint (used by OAuth flow).

**Configuration:**
- **OAuth App Homepage:** `https://backstage.freqkflag.co`
- **Callback URL:** `https://backstage.freqkflag.co/api/auth/github/handler/frame`

---

## Health & Status

### Health Check

**GET** `/api/health`

Check if the backend is running.

**Example:**
```bash
curl https://backstage.freqkflag.co/api/health
```

---

## Quick Reference: Start Tracking a Component

To "Start tracking your component in Scaffolded Backstage App", use one of these approaches:

### Option 1: Add Location Directly (Recommended)

```bash
curl -X POST https://backstage.freqkflag.co/api/catalog/locations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "type": "url",
    "target": "https://github.com/owner/repo/blob/main/catalog-info.yaml"
  }'
```

### Option 2: Use Catalog Import (Web UI)

1. Navigate to `https://backstage.freqkflag.co/catalog-import`
2. Enter repository URL
3. Click "Analyze" then "Import"

### Option 3: Use Scaffolder Template

1. Use the scaffolder template to create a new component
2. The template automatically registers the component via `catalog:register` action
3. Template location: `/api/scaffolder/templates/default/example-nodejs-template`

---

## Configuration

**Current Configuration:**
- **Backend Base URL:** `https://backstage.freqkflag.co`
- **Backend Listen Port:** `7007` (internal)
- **App Base URL:** `https://backstage.freqkflag.co`
- **Catalog Import Entity Filename:** `catalog-info.yaml` (default)
- **Catalog Import PR Branch:** `backstage-integration` (default)

**See:** `/root/infra/services/backstage/backstage/app-config.production.yaml` for full configuration.

---

## Examples

### Example 1: Track Existing GitHub Repository

```bash
# 1. Analyze repository
curl -X POST https://backstage.freqkflag.co/api/catalog-import/analyze \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"repoUrl": "https://github.com/owner/my-service"}'

# 2. Add location if catalog-info.yaml found
curl -X POST https://backstage.freqkflag.co/api/catalog/locations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "type": "url",
    "target": "https://github.com/owner/my-service/blob/main/catalog-info.yaml"
  }'
```

### Example 2: Create New Component via Scaffolder

```bash
# 1. List available templates
curl https://backstage.freqkflag.co/api/scaffolder/templates \
  -H "Authorization: Bearer <token>"

# 2. Execute template
curl -X POST https://backstage.freqkflag.co/api/scaffolder/v2/tasks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "templateRef": "template:default/example-nodejs-template",
    "values": {
      "name": "my-new-service",
      "repoUrl": "https://github.com/owner/my-new-service"
    }
  }'

# 3. Monitor task
curl https://backstage.freqkflag.co/api/scaffolder/v2/tasks/<task-id>/eventstream \
  -H "Authorization: Bearer <token>"
```

---

## References

- [Backstage Catalog API Documentation](https://backstage.io/docs/features/software-catalog/)
- [Backstage Catalog Import Plugin](https://backstage.io/docs/integrations/catalog-import/)
- [Backstage Scaffolder API](https://backstage.io/docs/features/software-templates/)
- [Backstage Entity Descriptor Format](https://backstage.io/docs/features/software-catalog/descriptor-format)

