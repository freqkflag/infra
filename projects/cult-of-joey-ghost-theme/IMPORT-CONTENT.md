# Import Starter Content

This theme includes starter content to help you get started quickly. There are two ways to import it:

## Method 1: Using the Import Script (Recommended)

The import script uses Ghost's Admin API to create content automatically.

### Prerequisites

1. Your Ghost site must be running
2. You need an Admin API key from Ghost
   - Go to Ghost Admin → Settings → Integrations
   - Create a new Custom Integration
   - Copy the Admin API Key

### Run the Import

```bash
GHOST_URL=http://your-ghost-url.com GHOST_ADMIN_API_KEY=your-admin-api-key node import-starter-content.js
```

Or via npm:
```bash
GHOST_URL=http://your-ghost-url.com GHOST_ADMIN_API_KEY=your-admin-api-key npm run import-content
```

**Example:**
```bash
GHOST_URL=http://localhost:2368 GHOST_ADMIN_API_KEY=1234567890abcdef node import-starter-content.js
```

### What Gets Created

- **Tags:** calm, manic, reflective, defiant, workshop, gallery, Tech, Cosplay
- **Posts:**
  - "Signal in the Static" - A reflective journal post about rebuilding a homelab
  - "Cyber-Samurai Armor V2" - A workshop post about cosplay armor
  - "Welcome to the Signal" - A welcome post (featured)
- **Pages:**
  - "Summon Me" (Contact page at `/contact`)

## Method 2: Manual Creation via Ghost Admin

If you prefer to create content manually, follow the guide in `STARTER-CONTENT.md`.

### Quick Setup Checklist

1. ✅ Run the import script (Method 1) OR manually create content (Method 2)
2. ⚙️ Go to Ghost Admin → Settings → Navigation
3. 📋 Add menu items:
   - **Journal** → Link to `/tag/[your-journal-tag]` or create a page
   - **Workshops** → Link to `/tag/workshop`
   - **Gallery** → Link to `/tag/gallery`
   - **Contact** → Link to `/contact`
4. 🎨 Customize colors/fonts in `assets/css/main.css` if desired
5. 📝 Start creating your own content!

## Troubleshooting

### API Key Issues
- Make sure you're using the **Admin API Key**, not the Content API Key
- Check that your Ghost URL is correct and accessible
- Verify the API key has the correct permissions

### Content Not Showing
- Check that posts are published (not draft)
- Verify tags are created correctly
- Make sure the theme is activated
- Check Ghost Admin → Labs → Content API to ensure it's enabled

### Need Help?
- Check Ghost documentation: https://ghost.org/docs/admin-api/
- Review `STARTER-CONTENT.md` for detailed content structure
- Check theme README.md for theme-specific setup

