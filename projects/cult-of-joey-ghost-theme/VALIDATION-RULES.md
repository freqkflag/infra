# Ghost Theme Validation Rules

Complete reference of validation rules based on Ghost CMS standards.

## Required Files

### package.json
- **Required fields:**
  - `name` - Theme identifier
  - `engines.ghost` - Minimum Ghost version (e.g., ">=5.0.0")
  - `author` - Author object
  - `author.email` - Required for theme distribution

### default.hbs
- Must include `{{ghost_head}}` in `<head>`
- Should include `{{ghost_foot}}` before `</body>`
- Must not include `{{meta_description}}` in head (deprecated)

## Invalid Handlebars Helpers

These helpers are **not valid** in Ghost and will cause errors:

- `{{eq}}` - Use `{{#match}}` instead
- `{{meta_description}}` - No longer needed, handled by `{{ghost_head}}`

## Required CSS Classes

For Koenig editor support, CSS must include:

```css
.kg-width-wide {
  /* Wide image styling */
}

.kg-width-full {
  /* Full-width image styling */
}
```

## Page Template Requirements

### page.hbs
Must support `@page.show_title_and_feature_image`:

```handlebars
{{#if @page.show_title_and_feature_image}}
  <h1>{{title}}</h1>
  {{#if feature_image}}
    <img src="{{img_url feature_image}}" alt="{{title}}">
  {{/if}}
{{/if}}
```

## Valid Handlebars Helpers

### Content Helpers
- `{{title}}`, `{{content}}`, `{{excerpt}}`
- `{{url}}`, `{{slug}}`
- `{{date}}`, `{{updated_at}}`, `{{published_at}}`
- `{{reading_time}}`
- `{{feature_image}}`, `{{img_url}}`
- `{{tags}}`, `{{authors}}`
- `{{primary_tag}}`, `{{primary_author}}`

### Site Helpers
- `{{@site.title}}`, `{{@site.description}}`
- `{{@site.url}}`, `{{@site.locale}}`
- `{{@site.navigation}}`

### Page Helpers
- `{{@page.show_title_and_feature_image}}`

### Navigation
- `{{navigation}}`

### Ghost Helpers
- `{{ghost_head}}` - Required in default.hbs
- `{{ghost_foot}}` - Recommended in default.hbs
- `{{asset}}` - For theme assets

### Conditionals
- `{{#if}}`, `{{#unless}}`
- `{{#foreach}}`, `{{#get}}`
- `{{#match}}` - Use instead of `{{eq}}`
- `{{#has}}`, `{{#is}}`

### Utilities
- `{{plural}}`
- `{{pagination}}`

## Custom Theme Settings

If you define custom settings in `package.json`:

```json
{
  "config": {
    "custom": {
      "setting_name": {
        "type": "select",
        "options": ["option1", "option2"],
        "default": "option1"
      }
    }
  }
}
```

**Important:** These settings must be used in at least one template file, otherwise Ghost will show an error.

## Accessibility Requirements

### Reduced Motion
Support `prefers-reduced-motion`:

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

### Semantic HTML
- Use semantic HTML elements
- Proper heading hierarchy (h1 → h2 → h3)
- ARIA labels where appropriate
- Keyboard navigation support

## Theme Structure Best Practices

```
theme-name/
├── package.json          # Required
├── default.hbs           # Required
├── index.hbs            # Optional
├── home.hbs             # Optional
├── post.hbs             # Optional
├── page.hbs             # Optional
├── tag.hbs              # Optional
├── author.hbs           # Optional
├── error.hbs            # Optional
├── partials/            # Recommended
│   ├── header.hbs
│   ├── footer.hbs
│   └── ...
└── assets/              # Recommended
    ├── css/
    ├── js/
    └── images/
```

## Common Validation Errors

### Fatal Errors (Theme won't activate)
1. Missing `package.json`
2. Missing `default.hbs`
3. Invalid JSON in `package.json`
4. Missing `{{ghost_head}}` in `default.hbs`
5. Using invalid helpers like `{{eq}}`

### Errors (Theme activates but has issues)
1. Missing `author.email` in `package.json`
2. Missing `{{ghost_foot}}` in `default.hbs`
3. Using `{{meta_description}}` in head
4. Missing Koenig editor CSS classes
5. Unused custom theme settings

### Warnings (Theme works but could be improved)
1. No CSS files found
2. No reduced motion support
3. Missing optional templates
4. No assets directory

## Testing Checklist

Before deploying your theme:

- [ ] Run `validate-theme.js`
- [ ] Run `gscan`
- [ ] Test all template files
- [ ] Test with different content types
- [ ] Test responsive design
- [ ] Test accessibility features
- [ ] Test in latest Ghost version
- [ ] Check browser console for errors
- [ ] Validate HTML output
- [ ] Test with different Ghost settings

## Resources

- [Ghost Theme Documentation](https://ghost.org/docs/themes/)
- [Ghost Handlebars Helpers](https://ghost.org/docs/themes/helpers/)
- [GScan GitHub](https://github.com/TryGhost/gscan)
- [Ghost Theme Structure](https://ghost.org/docs/themes/structure/)

