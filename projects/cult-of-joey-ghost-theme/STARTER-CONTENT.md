# Starter Content Guide for Cult of Joey Theme

This guide will help you set up your Ghost site with content that showcases the theme's features.

## Navigation Setup

In Ghost Admin → Settings → Navigation, create these menu items:

1. **Journal** → `/journal` (or create a page with slug `journal`)
2. **Workshops** → `/tag/workshop` (or create a page)
3. **Gallery** → `/tag/gallery` (or create a page)
4. **RV Life** → `/tag/rv-life` (or create a page)
5. **Contact** → `/contact` (create a page with slug `contact`)

## Tags for Mood Filtering

Create these tags in Ghost Admin → Tags:

- **calm** - For calm, peaceful posts (teal tint)
- **manic** - For energetic, intense posts (magenta tint)
- **reflective** - For thoughtful, introspective posts (indigo tint)
- **defiant** - For bold, rebellious posts (orange tint)

## Content Categories

Create tags for different content types:

- **workshop** - For workshop/project posts (shows in workshop section)
- **gallery** - For gallery posts (shows in gallery band)
- **Cosplay**, **Tech**, **Tattoo**, **DIY** - For workshop categories

## Sample Post Structure

### Journal Post Example

**Title:** Signal in the Static

**Tags:** `reflective`, `Tech`

**Excerpt:** Navigating the noise of modern existence while rebuilding a homelab from scratch. A metaphor for mental recovery.

**Content:**
```
The hum of the server rack is a comfort. It's a consistent, white noise that drowns out the chaotic frequency of the outside world. Yesterday, I tore down the entire cluster.

Why? Because sometimes you need to burn it down to build it right. The dependencies were tangled, the legacy configurations were haunting the logs, and frankly, it just didn't feel clean anymore.

> Recovery isn't a straight line. It's a recursive function with no exit condition sometimes.

Rebuilding the Kubernetes cluster felt like a ritual. Flashing the ISOs, bootstrapping the nodes, watching the pods come alive one by one. Green status lights in the dark.
```

### Workshop Post Example

**Title:** Cyber-Samurai Armor V2

**Tags:** `workshop`, `Cosplay`, `EVA Foam`, `Arduino`, `WS2812B LEDs`

**Excerpt:** Full body EVA foam armor with integrated Arduino-controlled RGB lighting.

**Content:**
```
## Summary

This project combines traditional cosplay fabrication with modern electronics to create a fully illuminated armor set.

## Specs

- EVA Foam base structure
- Arduino Nano for control
- WS2812B LED strips
- Custom C++ firmware
- Battery-powered for portability

## Process

[Your process documentation here]
```

## Homepage Setup

1. Go to Ghost Admin → Settings → General
2. Set your site title to "Cult of Joey"
3. Set your site description
4. Upload a site logo if desired

## Custom Pages

### Contact Page

Create a page with slug `contact`:

**Title:** Summon Me

**Content:**
```
## SUMMON ME

Open for collaborations on:

- Creative Coding / Web Dev
- Cosplay fabrication advice
- Homelab architecture
- Speaking on mental health & tech

### SECURE CHANNEL:

joey@cultofjoey.com
```

### Journal Index Page (Optional)

Create a page with slug `journal` that lists all posts, or use the default tag page.

## Featured Images

Make sure to add featured images to your posts:
- **Journal posts:** 1200x630px recommended
- **Workshop posts:** 1200x675px (16:9) recommended
- **Gallery posts:** Square or portrait orientation works best

## Social Links

In Ghost Admin → Settings → General → Social Accounts, add:
- Twitter/X
- Facebook
- GitHub
- Mastodon (add manually in footer.hbs if needed)

## Tips

1. Use the mood tags (`calm`, `manic`, `reflective`, `defiant`) as primary tags for journal posts to enable filtering
2. Tag workshop posts with `workshop` to show them in the workshop section
3. Use custom excerpts for better control over post previews
4. The theme automatically handles post formatting, but you can use Ghost's built-in formatting tools
5. For the gallery band on homepage, tag posts with `gallery` and ensure they have featured images

## Color Customization

To customize colors, edit `assets/css/main.css` and modify the CSS variables in the `:root` section:

```css
:root {
  --c-primary: #E600FF;        /* Magenta */
  --c-accent: #00FFFF;         /* Cyan */
  --c-background: #05040A;     /* Dark background */
  /* ... etc */
}
```

## Font Customization

Fonts are loaded from Google Fonts in `default.hbs`. To change fonts:

1. Update the Google Fonts link
2. Modify the CSS variables in `main.css`:

```css
--font-display: 'Orbitron', sans-serif;
--font-heading: 'Oxanium', sans-serif;
--font-body: 'Space Grotesk', sans-serif;
--font-mono: 'JetBrains Mono', monospace;
```

