# Ghost Theme Validation & Development Setup - Summary

## What's Been Created

### 1. Theme Validation Tool
**File:** `validate-theme.js`

A comprehensive Node.js script that validates Ghost themes against official standards:

- ✅ Checks required files (package.json, default.hbs)
- ✅ Validates package.json structure and required fields
- ✅ Detects invalid/deprecated Handlebars helpers
- ✅ Checks for Koenig editor CSS classes
- ✅ Validates theme structure
- ✅ Provides detailed error/warning reports

**Usage:**
```bash
node validate-theme.js /path/to/theme
```

### 2. Docker Development Environment
**File:** `docker-compose.dev.yml`

Complete Docker Compose setup for Ghost development:

- Ghost CMS (latest)
- MySQL 8.0 database
- Volume mounting for live theme development
- Port forwarding (2368 for site, 2369 for admin)

**Usage:**
```bash
docker-compose -f docker-compose.dev.yml up -d
```

### 3. VS Code Dev Container
**Directory:** `.devcontainer/`

Pre-configured VS Code Dev Container for seamless development:

- Automatic Ghost + MySQL setup
- Node.js 20 pre-installed
- Handlebars syntax highlighting
- Port forwarding configured
- Extensions pre-installed

**Usage:**
1. Open in VS Code
2. Install "Dev Containers" extension
3. F1 → "Dev Containers: Reopen in Container"

### 4. Testing Script
**File:** `test-theme.sh`

Bash script for quick theme testing:

- Runs validation
- Checks file structure
- Provides testing checklist

**Usage:**
```bash
./test-theme.sh
```

### 5. Documentation

- **VALIDATION-TOOL.md** - How to use the validation tool
- **VALIDATION-RULES.md** - Complete reference of validation rules
- **DEVELOPMENT.md** - Development environment setup guide
- **.devcontainer/README.md** - Dev Container specific instructions

## Quick Start

### Option 1: Docker Compose (Recommended)

```bash
# Start environment
docker-compose -f docker-compose.dev.yml up -d

# Access Ghost
# Site: http://localhost:2368
# Admin: http://localhost:2368/ghost

# Validate theme
node validate-theme.js .

# View logs
docker-compose -f docker-compose.dev.yml logs -f ghost
```

### Option 2: VS Code Dev Container

1. Open folder in VS Code
2. Install "Dev Containers" extension
3. Press F1 → "Dev Containers: Reopen in Container"
4. Wait for setup
5. Access Ghost at http://localhost:2368

### Option 3: Local Ghost Installation

```bash
# Install Ghost CLI
npm install -g ghost-cli

# Install Ghost locally
ghost install local

# Copy theme to content/themes/
cp -r cult-of-joey-ghost-theme /path/to/ghost/content/themes/

# Validate
cd /path/to/ghost/content/themes/cult-of-joey-ghost-theme
node validate-theme.js .
```

## Validation Checklist

Before deploying, ensure:

- [ ] Theme passes `validate-theme.js`
- [ ] Theme passes `gscan` (official Ghost validator)
- [ ] All required files present
- [ ] package.json has author.email
- [ ] No deprecated helpers used
- [ ] Koenig editor classes in CSS
- [ ] @page.show_title_and_feature_image implemented
- [ ] Mobile responsive
- [ ] Accessibility features

## Key Validation Rules

### Required Files
- `package.json` with `engines.ghost` and `author.email`
- `default.hbs` with `{{ghost_head}}`

### Invalid Helpers
- ❌ `{{eq}}` → Use `{{#match}}` instead
- ❌ `{{meta_description}}` in head → Handled by `{{ghost_head}}`

### Required CSS
- `.kg-width-wide` for Koenig editor
- `.kg-width-full` for Koenig editor

### Page Template
- Must support `@page.show_title_and_feature_image`

## Testing Workflow

1. **Validate Theme**
   ```bash
   node validate-theme.js .
   ```

2. **Start Development Environment**
   ```bash
   docker-compose -f docker-compose.dev.yml up -d
   ```

3. **Activate Theme in Ghost**
   - Go to http://localhost:2368/ghost
   - Settings → Design
   - Activate theme

4. **Test Features**
   - Create test posts
   - Test mood filtering
   - Test responsive design
   - Test accessibility

5. **Run Official Validator**
   ```bash
   npm install -g gscan
   gscan .
   ```

## Resources

- [Ghost Theme Documentation](https://ghost.org/docs/themes/)
- [Ghost Handlebars Helpers](https://ghost.org/docs/themes/helpers/)
- [GScan Tool](https://github.com/TryGhost/gscan)
- [Ghost Theme Structure](https://ghost.org/docs/themes/structure/)

## Next Steps

1. Set up development environment (Docker or Dev Container)
2. Validate theme using `validate-theme.js`
3. Test theme in Ghost instance
4. Fix any validation errors
5. Run official GScan validator
6. Test all features and responsive design
7. Deploy to production

---

**Note:** The validation tool is based on Ghost CMS standards as of 2024-2025. Always refer to official Ghost documentation for the latest requirements.

