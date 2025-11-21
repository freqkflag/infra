# Installation Instructions

## Quick Start

1. **Download the theme**
   ```bash
   # If you have the theme folder, copy it to your Ghost themes directory
   cp -r cult-of-joey-ghost-theme /path/to/ghost/content/themes/
   ```

2. **Restart Ghost**
   ```bash
   # If using Ghost-CLI
   ghost restart
   
   # Or restart your Ghost service
   sudo systemctl restart ghost
   ```

3. **Activate the theme**
   - Go to Ghost Admin → Settings → Design
   - Find "Cult of Joey" in the themes list
   - Click "Activate"

## Manual Installation

1. Navigate to your Ghost installation directory
2. Go to `content/themes/`
3. Place the `cult-of-joey-ghost-theme` folder here
4. Ensure the folder name matches exactly (Ghost is case-sensitive)
5. Restart Ghost
6. Activate in Ghost Admin

## Verification

After installation, check:

- [ ] Theme appears in Ghost Admin → Settings → Design
- [ ] Theme can be activated without errors
- [ ] Site loads with the new theme
- [ ] Navigation menu works
- [ ] Posts display correctly
- [ ] Mobile menu works on mobile devices

## Troubleshooting

### Theme not appearing
- Check folder name matches exactly
- Ensure all files are present (check `package.json` exists)
- Check Ghost logs: `ghost log`
- Verify Ghost version is 5.0 or higher

### Styling issues
- Clear browser cache
- Check browser console for errors
- Verify CSS files are loading (check Network tab)
- Ensure fonts are loading from Google Fonts

### JavaScript not working
- Check browser console for errors
- Verify `main.js` is loading
- Check that jQuery/other dependencies aren't conflicting

## Requirements

- **Ghost Version:** 5.0.0 or higher
- **Node.js:** As required by your Ghost version
- **Browser Support:** Modern browsers (Chrome, Firefox, Safari, Edge)

## Next Steps

1. Set up navigation (see STARTER-CONTENT.md)
2. Create tags for mood filtering
3. Add your first posts
4. Customize colors/fonts if desired
5. Configure social links

For content setup, see `STARTER-CONTENT.md`.

