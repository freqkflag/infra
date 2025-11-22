# CI/CD Annotations for Infrastructure Components

This document describes the CI/CD annotations added to all infrastructure components in Backstage.

## Annotations Added

All infrastructure components now include the following CI/CD annotations:

### GitLab CI/CD Annotations

```yaml
annotations:
  gitlab.com/project-slug: root/infra
  gitlab.com/instance-url: https://gitlab.freqkflag.co
```

- **`gitlab.com/project-slug`**: Points to the GitLab project `root/infra` where all infrastructure code is stored
- **`gitlab.com/instance-url`**: Points to your self-hosted GitLab instance at `https://gitlab.freqkflag.co`

### GitHub Actions Annotations

```yaml
annotations:
  github.com/project-slug: freqkflag/infra
```

- **`github.com/project-slug`**: Points to the GitHub repository `freqkflag/infra` (if using GitHub Actions)

### TechDocs Annotation

```yaml
annotations:
  backstage.io/techdocs-ref: dir:.
```

- **`backstage.io/techdocs-ref`**: Enables TechDocs for the component, referencing documentation in the same directory

## Components with CI/CD Annotations

All the following infrastructure components now have CI/CD annotations:

1. **Traefik** - Reverse proxy and load balancer
2. **Infisical** - Secrets management
3. **Supabase** - Database platform
4. **WordPress** - Content management system
5. **WikiJS** - Documentation platform
6. **n8n** - Workflow automation
7. **Node-RED** - Flow-based development
8. **LinkStack** - Link-in-bio page
9. **GitLab** - Version control
10. **Adminer** - Database management
11. **Backstage** - Developer portal

## Enabling CI/CD in Backstage

The annotations are now in place, but to see CI/CD information in Backstage, you need to install and configure the appropriate CI/CD plugin:

### For GitLab CI/CD

1. **Install GitLab CI/CD Plugin:**
   ```bash
   cd /root/infra/services/backstage/backstage
   yarn workspace app add @backstage/plugin-gitlab
   yarn workspace backend add @backstage/plugin-gitlab-backend
   ```

2. **Configure Backend:**
   
   Add to `packages/backend/src/index.ts`:
   ```typescript
   backend.add(import('@backstage/plugin-gitlab-backend'));
   ```

   Add to `app-config.production.yaml`:
   ```yaml
   gitlab:
     host: gitlab.freqkflag.co
     apiBaseUrl: https://gitlab.freqkflag.co/api/v4
     token: ${GITLAB_TOKEN}
   ```

3. **Configure Frontend:**
   
   Add to `packages/app/src/components/catalog/EntityPage.tsx`:
   ```typescript
   import { EntityGitlabPipelinesContent } from '@backstage/plugin-gitlab';
   
   // Add to serviceEntityPage:
   <EntityLayout.Route path="/pipelines" title="CI/CD">
     <EntityGitlabPipelinesContent />
   </EntityLayout.Route>
   ```

### For GitHub Actions

1. **Install GitHub Actions Plugin:**
   ```bash
   yarn workspace app add @backstage-community/plugin-github-actions
   yarn workspace backend add @backstage-community/plugin-github-actions-backend
   ```

2. **Configure Backend:**
   
   Add to `packages/backend/src/index.ts`:
   ```typescript
   backend.add(import('@backstage-community/plugin-github-actions-backend'));
   ```

   Add to `app-config.production.yaml`:
   ```yaml
   integrations:
     github:
       - host: github.com
         token: ${GITHUB_TOKEN}
   ```

3. **Configure Frontend:**
   
   Update `packages/app/src/components/catalog/EntityPage.tsx`:
   ```typescript
   import { EntityGithubActionsContent } from '@backstage-community/plugin-github-actions';
   import { isGithubActionsAvailable } from '@backstage-community/plugin-github-actions';
   
   // Update cicdContent:
   <EntitySwitch.Case if={isGithubActionsAvailable}>
     <EntityGithubActionsContent />
   </EntitySwitch.Case>
   ```

## Current Status

✅ **Annotations Added**: All infrastructure components have CI/CD annotations
✅ **GitLab Annotations**: All components reference `root/infra` project on `gitlab.freqkflag.co`
✅ **GitHub Annotations**: All components reference `freqkflag/infra` repository
⏳ **Plugin Configuration**: CI/CD plugins need to be installed and configured in Backstage

## Next Steps

1. **Install CI/CD Plugin**: Choose either GitLab or GitHub Actions plugin (or both)
2. **Configure Plugin**: Add configuration to `app-config.production.yaml`
3. **Update EntityPage**: Add CI/CD tab to entity pages
4. **Rebuild Container**: Rebuild and restart Backstage to apply changes
5. **Verify CI/CD Tab**: Check that CI/CD tab appears on component pages

## References

- [Backstage Well-Known Annotations](https://backstage.io/docs/features/software-catalog/well-known-annotations)
- [GitLab Plugin Documentation](https://backstage.io/docs/integrations/gitlab/locations)
- [GitHub Actions Plugin Documentation](https://backstage.io/docs/integrations/github/locations)

