# VS Code Dev Container Setup

This directory contains configuration for developing Ghost themes in a VS Code Dev Container.

## What's Included

- **devcontainer.json**: VS Code Dev Container configuration
- **docker-compose.dev.yml**: Docker Compose setup for Ghost + MySQL

## Features

- Pre-configured Ghost CMS instance
- MySQL database
- Node.js 20
- Git support
- VS Code extensions for Handlebars, JSON, TypeScript
- Port forwarding (2368 for site, 2369 for admin)

## Setup

1. Open VS Code
2. Install "Dev Containers" extension
3. Open this folder in VS Code
4. Press F1 → "Dev Containers: Reopen in Container"
5. Wait for container to build and start
6. Access Ghost at http://localhost:2368

## First Time Setup

When Ghost starts for the first time:
1. Go to http://localhost:2368/ghost
2. Create your admin account
3. Go to Settings → Design
4. Activate your theme

## Development

Your theme files are mounted as a volume, so changes are reflected immediately. You may need to restart Ghost or clear cache for some changes.

## Validation

Run theme validation:

```bash
node validate-theme.js .
```

Or use official GScan:

```bash
gscan .
```

