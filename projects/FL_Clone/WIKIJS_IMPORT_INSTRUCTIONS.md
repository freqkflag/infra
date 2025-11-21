# WikiJS Page Import Instructions

## Quick Import Guide

The FL Clone building process documentation has been prepared in markdown format and is ready to import into WikiJS.

### File Location
- **Documentation File:** `/root/infra/projects/FL_Clone/WIKIJS_DOCUMENTATION.md`
- **Helper Script:** `/root/infra/projects/FL_Clone/create-wikijs-page.sh`

### Method 1: Manual Import (Recommended)

1. **Access WikiJS:**
   - Navigate to: https://wiki.freqkflag.co
   - Log in with your admin credentials

2. **Create New Page:**
   - Click "Create" in the top navigation
   - Select "Page"

3. **Page Settings:**
   - **Title:** `FL Clone - Building Process Documentation`
   - **Path:** `projects/fl-clone-building-process`
   - **Description:** `Complete documentation of the FL Clone social platform build process, architecture, and deployment`
   - **Editor:** Markdown

4. **Add Content:**
   - Open the documentation file:
     ```bash
     cat /root/infra/projects/FL_Clone/WIKIJS_DOCUMENTATION.md
     ```
   - Copy the entire content
   - Paste into the WikiJS editor

5. **Page Properties:**
   - **Category:** Projects
   - **Tags:** `fl-clone`, `rails`, `vue`, `social-platform`, `twist3dkinkst3r`, `kink-tagging`
   - **Visibility:** Public (or as needed)

6. **Publish:**
   - Click "Save" or "Publish"
   - Verify the page is accessible

### Method 2: Using Helper Script

Run the helper script for step-by-step instructions:

```bash
cd /root/infra/projects/FL_Clone
./create-wikijs-page.sh
```

### Method 3: WikiJS API (Advanced)

If you have API access configured, you can use the WikiJS API:

```bash
# Get authentication token first
TOKEN=$(curl -X POST https://wiki.freqkflag.co/api/authenticate \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"your-password"}' | jq -r '.token')

# Create page via API
curl -X POST https://wiki.freqkflag.co/api/pages \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d @- << EOF
{
  "title": "FL Clone - Building Process Documentation",
  "path": "projects/fl-clone-building-process",
  "description": "Complete documentation of the FL Clone social platform build process",
  "content": "$(cat WIKIJS_DOCUMENTATION.md | jq -Rs .)",
  "editor": "markdown",
  "isPublished": true,
  "tags": ["fl-clone", "rails", "vue", "social-platform"]
}
EOF
```

### Content Preview

The documentation includes:
- ✅ Project overview and features
- ✅ Complete architecture documentation
- ✅ Step-by-step building process
- ✅ Database schema details
- ✅ Backend implementation guide
- ✅ Frontend implementation guide
- ✅ Deep kink tagging system integration
- ✅ Docker and infrastructure setup
- ✅ Deployment process
- ✅ Security and privacy features
- ✅ Troubleshooting guide

### Verification

After importing, verify:
1. Page is accessible at: `https://wiki.freqkflag.co/projects/fl-clone-building-process`
2. All markdown formatting renders correctly
3. Code blocks are properly formatted
4. Links work correctly
5. Images (if any) display properly

### Updating the Page

To update the documentation:
1. Edit `/root/infra/projects/FL_Clone/WIKIJS_DOCUMENTATION.md`
2. Copy updated content to WikiJS
3. Update the page in WikiJS editor
4. Save changes

---

**Note:** The documentation is comprehensive and covers the entire building process from initial setup through deployment. It's designed to be a complete reference for understanding and maintaining the FL Clone platform.

