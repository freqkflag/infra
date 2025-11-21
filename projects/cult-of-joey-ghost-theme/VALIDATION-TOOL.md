# Ghost Theme Validation Tool

A comprehensive validation tool for Ghost CMS themes based on official Ghost standards and best practices.

## Features

- ✅ Validates required files (package.json, default.hbs)
- ✅ Checks package.json structure and required fields
- ✅ Validates Handlebars syntax and helpers
- ✅ Detects invalid/deprecated helpers
- ✅ Checks for Koenig editor CSS classes
- ✅ Validates theme structure
- ✅ Provides detailed error and warning reports

## Usage

### As a Node.js script:

```bash
node validate-theme.js /path/to/theme
```

### As npm script (if added to package.json):

```bash
npm run validate
```

## Validation Rules

### Required Files
- `package.json` - Theme metadata
- `default.hbs` - Main template wrapper

### Package.json Requirements
- `name` - Theme name
- `engines.ghost` - Minimum Ghost version (e.g., ">=5.0.0")
- `author.email` - Required for theme distribution

### Handlebars Requirements
- `default.hbs` must include `{{ghost_head}}`
- `default.hbs` should include `{{ghost_foot}}`
- Cannot use `{{meta_description}}` in head (deprecated)
- Cannot use `{{eq}}` helper (use `{{#match}}` instead)
- `page.hbs` should use `@page.show_title_and_feature_image`

### CSS Requirements
- Must include `.kg-width-wide` class
- Must include `.kg-width-full` class
- Should support `prefers-reduced-motion` for accessibility

### Invalid Helpers
- `{{eq}}` - Not a valid Ghost helper
- `{{meta_description}}` - No longer needed in head

## Integration with GScan

For official Ghost validation, also use GScan:

```bash
npm install -g gscan
gscan /path/to/theme
```

This tool complements GScan by providing additional checks and a simpler interface for development.

