# Starter Content Installation Guide

## Overview

The theme includes a starter content installation script that populates your ClassicPress site with sample content based on the original React application data.

## What It Creates

### Taxonomies
- **Mood terms**: calm, manic, reflective, defiant (for posts)
- **Workshop categories**: Cosplay, Tech, Tattoo, DIY
- **Gallery categories**: Photography, Art, Events, Self

### Content
- **4 Journal Posts** (with mood taxonomy)
  - Signal in the Static (reflective, Tech)
  - Neon Scars & EVA Foam (defiant, Cosplay)
  - 3AM Kubernetes Migrations (manic, Tech)
  - Quiet Mornings in the Desert (calm, Self)

- **3 Workshop Posts** (with categories and specs)
  - Cyber-Samurai Armor V2 (Cosplay)
  - Homelab Rack 42U (Tech)
  - Geometric Sleeve Tattoo (Tattoo)

- **6 Gallery Items** (with categories)
  - Neon City (Photography)
  - Ritual Altar (Art)
  - Wasteland Weekend (Events)
  - Self Portrait (Self)
  - Circuit Board Macro (Photography)
  - Glitch Art Experiment (Art)

- **4 Timeline Events** (with dates and locations)
  - Quartzsite Gathering (Oct 2023)
  - The Great Northern Migration (Aug 2023)
  - Solar Upgrade (May 2023)
  - Departure (Jan 2023)

- **4 Pages** (with templates assigned)
  - Workshops (page-workshops.php)
  - Gallery (page-gallery.php)
  - RV Life (page-rv-life.php)
  - Contact (page-contact.php)

## How to Install

### Option 1: Via Browser (Recommended)

1. **Log into ClassicPress Admin** as an administrator
2. **Navigate to**: `http://cultofjoey.com/wp-content/themes/cult-of-joey-theme/install-starter-content.php`
3. The script will run and display progress
4. You'll see a success message when complete

### Option 2: Via WP-CLI (if available)

```bash
wp eval-file wp-content/themes/cult-of-joey-theme/install-starter-content.php
```

### Option 3: Via Docker (if running in container)

```bash
docker exec -it [container-name] php -r "require '/var/www/html/wp-load.php'; require '/var/www/html/wp-content/themes/cult-of-joey-theme/install-starter-content.php';"
```

## After Installation

1. **Activate the theme** (if not already active)
   - Go to Appearance > Themes
   - Activate "Cult of Joey"

2. **Flush rewrite rules** (if needed)
   - Go to Settings > Permalinks
   - Click "Save Changes"

3. **Set homepage** (optional)
   - Go to Settings > Reading
   - Choose "A static page" and select a page

4. **Set blog page** (optional)
   - Go to Settings > Reading
   - Set "Posts page" to a page showing blog posts

5. **Add featured images**
   - Edit posts, workshops, and gallery items
   - Add featured images for better visual presentation

## Security Note

The installation script includes a security check - only administrators can run it. After installation, it marks itself as complete to prevent accidental re-running.

To re-run the installation script:
- Delete the option `cult_of_joey_starter_content_installed` from the database
- Or access the script URL again after deleting the option

## Troubleshooting

- **"Permission denied"**: Make sure you're logged in as an administrator
- **"Content already exists"**: The script checks for existing content and won't duplicate it
- **Pages not showing**: Check that the page templates are assigned correctly in the page editor
- **Custom Post Types not visible**: Make sure the theme is activated and flush rewrite rules

