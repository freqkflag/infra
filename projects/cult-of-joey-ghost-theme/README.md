# Cult of Joey - Ghost Theme

A dark-neon cyberpunk personal brand hub blending queer rave culture, mental-health storytelling, technical homelab/IT energy, and creative workshops.

## Features

- **Dark Neon Cyberpunk Aesthetic** - Custom color palette with magenta and cyan accents
- **Responsive Design** - Mobile-first approach with breakpoints for all devices
- **Mood-Based Filtering** - Filter posts by emotional frequency (calm, manic, reflective, defiant)
- **Lightbox Gallery** - Full-screen image viewing with smooth transitions
- **Custom Typography** - Orbitron, Oxanium, Space Grotesk, and JetBrains Mono fonts
- **Accessibility** - Respects `prefers-reduced-motion` and includes semantic HTML
- **Ghost 5.0+ Compatible** - Built for the latest Ghost version

## Installation

1. Download or clone this theme
2. Upload the theme folder to your Ghost installation's `content/themes/` directory
3. Restart Ghost
4. Go to Ghost Admin → Settings → Design → Themes
5. Activate "Cult of Joey"

## Validation & Testing

### Validate Theme

Before uploading, validate your theme:

```bash
# Using the included validator
node validate-theme.js .

# Or using official GScan (install first: npm install -g gscan)
gscan .
```

### Development Environment

For local development and testing, use Docker:

```bash
# Start Ghost development environment
docker-compose -f docker-compose.dev.yml up -d

# Access Ghost at http://localhost:2368
# Admin at http://localhost:2368/ghost
```

See [DEVELOPMENT.md](DEVELOPMENT.md) for complete setup instructions.

### VS Code Dev Container

This theme includes VS Code Dev Container configuration:

1. Open in VS Code
2. Install "Dev Containers" extension
3. Press F1 → "Dev Containers: Reopen in Container"
4. Start developing!

See [.devcontainer/README.md](.devcontainer/README.md) for details.

## Customization

### Colors

All colors are defined as CSS variables in `assets/css/main.css`. Modify the `:root` variables to customize:

```css
--c-primary: #E600FF;        /* Magenta */
--c-accent: #00FFFF;         /* Cyan */
--c-background: #05040A;     /* Dark background */
```

### Typography

Fonts are loaded from Google Fonts. To change fonts, update the font links in `default.hbs` and the CSS variables.

### Navigation

Navigation is handled through Ghost's built-in navigation system. Configure it in Ghost Admin → Settings → Navigation.

## Content Structure

### Tags for Mood Filtering

Create tags with these exact names to enable mood-based filtering:
- `calm` - Teal tint
- `manic` - Magenta tint
- `reflective` - Indigo tint
- `defiant` - Orange tint

### Workshop Posts

Tag posts with `workshop` to display them in the workshop section. Use additional tags for categories (Cosplay, Tech, Tattoo, DIY).

### Gallery Posts

Tag posts with `gallery` to include them in the gallery band on the homepage.

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## License

MIT

## Credits

- Design inspired by cyberpunk aesthetics and queer rave culture
- Built with Ghost CMS
- Fonts: Orbitron, Oxanium, Space Grotesk, JetBrains Mono

