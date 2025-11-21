# Cult of Joey - ClassicPress Theme

A dark-neon cyberpunk personal brand hub theme for ClassicPress 2.5.0, converted from a React SPA to traditional PHP templates.

## Features

- **Dark Neon Cyberpunk Aesthetic**: Custom Tailwind CSS configuration with neon glows and glitch effects
- **Custom Post Types**: Workshops, Gallery Items, Timeline Events
- **Custom Taxonomies**: Mood (for posts), Workshop Categories, Gallery Categories
- **Responsive Design**: Mobile-first design with hamburger menu
- **Interactive Elements**: Sticky header, lightbox gallery, mood filtering

## Installation

1. Upload the `cult-of-joey-theme` folder to `/wp-content/themes/` on your ClassicPress installation
2. Activate the theme through the ClassicPress admin panel (Appearance > Themes)
3. Go to Settings > Permalinks and click "Save Changes" to flush rewrite rules

## Theme Structure

```
cult-of-joey-theme/
├── style.css              # Theme header (required)
├── functions.php          # Theme functions, CPTs, taxonomies, enqueues
├── header.php             # Header template with navigation
├── footer.php             # Footer template
├── front-page.php         # Homepage template
├── index.php              # Journal/blog listing with mood filters
├── single.php             # Single post template
├── page-workshops.php     # Workshops page template
├── page-gallery.php       # Gallery page template
├── page-rv-life.php       # RV Life timeline template
├── page-contact.php       # Contact page template
├── js/
│   └── main.js           # Theme JavaScript (sticky header, mobile menu, lightbox)
└── README.md             # This file
```

## Custom Post Types

### Workshop
- **Post Type**: `workshop`
- **Taxonomy**: `workshop_category`
- **Custom Fields**: `_workshop_specs` (array of strings stored as post meta)

### Gallery Item
- **Post Type**: `gallery_item`
- **Taxonomy**: `gallery_category`
- Uses Featured Image for display

### Timeline Event
- **Post Type**: `timeline_event`
- **Custom Fields**:
  - `_timeline_event_date` (string - e.g., "Oct 2023")
  - `_timeline_location` (string - location name)

## Custom Taxonomies

### Mood
- **Taxonomy**: `mood`
- **Applied to**: Posts
- **Terms**: calm, manic, reflective, defiant
- Each mood has custom styling with specific color schemes

## Page Templates

To use the custom page templates, create pages in ClassicPress admin and assign the template:

1. **Workshops Page**: Create a page with slug `workshops` or assign template "Workshops"
2. **Gallery Page**: Create a page with slug `gallery` or assign template "Gallery"
3. **RV Life Page**: Create a page with slug `rv-life` or assign template "RV Life"
4. **Contact Page**: Create a page with slug `contact` or assign template "Contact"

## Styling

The theme uses **Tailwind CSS via CDN** with a custom configuration including:

- Custom color palette (background, surface, primary, accent, etc.)
- Custom fonts (Orbitron, Oxanium, Space Grotesk, JetBrains Mono)
- Custom animations (glitch effects, neon glows)
- Custom scrollbar styling

All Tailwind configuration is in the `<head>` section via `cult_of_joey_head_styles()` function.

## JavaScript Features

The theme includes vanilla JavaScript for:

- **Sticky Header**: Transforms on scroll
- **Mobile Menu**: Hamburger menu toggle
- **Gallery Lightbox**: Click images to view in modal
- **Contact Form**: Basic form validation (integrate with your contact form plugin)

## Data Migration from React App

The React app used hardcoded data in `services/data.ts`. In ClassicPress:

- **Posts** → Use standard WordPress Posts with `mood` taxonomy
- **Workshops** → Use `workshop` CPT with `workshop_category` taxonomy
- **Gallery Items** → Use `gallery_item` CPT with `gallery_category` taxonomy
- **Timeline Events** → Use `timeline_event` CPT with meta fields

## Helper Functions

### `cult_of_joey_get_mood_chip_classes( $mood, $is_active = false )`
Returns CSS classes for mood chips based on the mood term slug.

### `cult_of_joey_get_workshop_specs( $post_id )`
Retrieves workshop specs array from post meta.

## Custom Fields Setup

For Timeline Events, use a plugin like Advanced Custom Fields or add custom meta boxes to edit:

- `_timeline_event_date`: Event date (e.g., "Oct 2023")
- `_timeline_location`: Location name (e.g., "Quartzsite, AZ")

For Workshops, store specs as post meta `_workshop_specs` (serialized array).

## Browser Support

- Modern browsers (Chrome, Firefox, Safari, Edge)
- IE11 not supported (uses modern JavaScript)

## Requirements

- ClassicPress 2.5.0 or higher
- PHP 8.0 or higher

## Credits

Original React application design by Cult of Joey.
Converted to ClassicPress theme by AI Assistant.

## License

GPL v2 or later

