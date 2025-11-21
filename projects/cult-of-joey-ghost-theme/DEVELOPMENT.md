# Ghost Theme Development Guide

This guide helps you set up a development environment for testing and debugging Ghost themes.

## Quick Start with Docker

### Prerequisites
- Docker and Docker Compose installed
- Ports 2368 and 2369 available

### Start Development Environment

```bash
# Start Ghost and database
docker-compose -f docker-compose.dev.yml up -d

# View logs
docker-compose -f docker-compose.dev.yml logs -f ghost

# Stop environment
docker-compose -f docker-compose.dev.yml down
```

### Access Ghost
- **Site**: http://localhost:2368
- **Admin**: http://localhost:2368/ghost
  - Default credentials: Create account on first visit

## Using VS Code Dev Container

1. Open VS Code
2. Install "Dev Containers" extension
3. Open Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
4. Select "Dev Containers: Reopen in Container"
5. VS Code will build and start the container

## Theme Development Workflow

### 1. Validate Theme

```bash
# Using our custom validator
node validate-theme.js .

# Or using official GScan
gscan .
```

### 2. Activate Theme in Ghost

1. Access Ghost Admin: http://localhost:2368/ghost
2. Go to Settings → Design
3. Upload or activate your theme
4. Preview changes

### 3. Live Development

The theme directory is mounted as a volume, so changes are reflected immediately. However, you may need to:

- Clear Ghost cache: Restart the container
- Hard refresh browser: Ctrl+Shift+R / Cmd+Shift+R

### 4. Test Theme Features

- Create test posts with different tags
- Test mood filtering (calm, manic, reflective, defiant)
- Test workshop posts (tag with "workshop")
- Test gallery posts (tag with "gallery")
- Test page features (@page.show_title_and_feature_image)

## Validation Checklist

Before deploying, ensure:

- [ ] Theme passes `validate-theme.js`
- [ ] Theme passes `gscan`
- [ ] All required files present
- [ ] package.json has author.email
- [ ] No deprecated helpers used
- [ ] Koenig editor classes present in CSS
- [ ] @page.show_title_and_feature_image implemented
- [ ] Mobile responsive
- [ ] Accessibility features (reduced motion)

## Common Issues

### Theme Not Appearing
- Check theme folder name matches exactly
- Verify package.json exists and is valid
- Check Ghost logs: `docker-compose logs ghost`

### Changes Not Reflecting
- Restart Ghost container: `docker-compose restart ghost`
- Clear browser cache
- Check file permissions

### Validation Errors
- Run validator: `node validate-theme.js .`
- Fix errors one by one
- Re-validate after each fix

## Useful Commands

```bash
# View Ghost logs
docker-compose -f docker-compose.dev.yml logs -f ghost

# Restart Ghost
docker-compose -f docker-compose.dev.yml restart ghost

# Access Ghost container shell
docker exec -it ghost-dev bash

# Validate theme
node validate-theme.js .

# Run GScan
gscan .

# Check Ghost version
docker exec ghost-dev ghost --version
```

## Theme Testing Checklist

### Content Types
- [ ] Regular blog posts
- [ ] Posts with featured images
- [ ] Posts with different moods (tags)
- [ ] Workshop posts
- [ ] Gallery posts
- [ ] Static pages
- [ ] Tag archive pages
- [ ] Author archive pages

### Features
- [ ] Navigation menu
- [ ] Mobile menu
- [ ] Filtering (mood, category)
- [ ] Lightbox gallery
- [ ] Pagination
- [ ] Related posts
- [ ] Social sharing
- [ ] Newsletter signup (if implemented)

### Responsive
- [ ] Mobile (< 768px)
- [ ] Tablet (768px - 1024px)
- [ ] Desktop (> 1024px)

### Accessibility
- [ ] Keyboard navigation
- [ ] Screen reader compatibility
- [ ] Reduced motion support
- [ ] Color contrast
- [ ] Focus states

## Resources

- [Ghost Theme Documentation](https://ghost.org/docs/themes/)
- [Ghost Handlebars Helpers](https://ghost.org/docs/themes/helpers/)
- [GScan Tool](https://github.com/TryGhost/gscan)
- [Ghost Theme Structure](https://ghost.org/docs/themes/structure/)

