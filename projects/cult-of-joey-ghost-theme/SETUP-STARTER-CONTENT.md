# Setup Starter Content for Cult of Joey Theme

## Issue with API Key

The API key provided appears to be invalid or the format needs adjustment. Here are alternative ways to add the starter content:

## Option 1: Manual Setup via Ghost Admin (Recommended)

Since the API authentication isn't working, you can manually add the starter content:

### Step 1: Create Tags

Go to **Ghost Admin → Tags** and create these tags:

1. **calm** - Description: "For calm, peaceful posts (teal tint)"
2. **manic** - Description: "For energetic, intense posts (magenta tint)"
3. **reflective** - Description: "For thoughtful, introspective posts (indigo tint)"
4. **defiant** - Description: "For bold, rebellious posts (orange tint)"
5. **workshop** - Description: "For workshop/project posts"
6. **gallery** - Description: "For gallery posts"
7. **Tech** - Description: "Technology and homelab content"
8. **Cosplay** - Description: "Cosplay projects"

### Step 2: Create Posts

Go to **Ghost Admin → Posts → New Post** and create:

#### Post 1: "Signal in the Static"
- **Title:** Signal in the Static
- **Slug:** signal-in-the-static
- **Tags:** reflective, Tech
- **Excerpt:** "Navigating the noise of modern existence while rebuilding a homelab from scratch. A metaphor for mental recovery."
- **Content:**
```
The hum of the server rack is a comfort. It's a consistent, white noise that drowns out the chaotic frequency of the outside world. Yesterday, I tore down the entire cluster.

Why? Because sometimes you need to burn it down to build it right. The dependencies were tangled, the legacy configurations were haunting the logs, and frankly, it just didn't feel clean anymore.

Recovery isn't a straight line. It's a recursive function with no exit condition sometimes.

Rebuilding the Kubernetes cluster felt like a ritual. Flashing the ISOs, bootstrapping the nodes, watching the pods come alive one by one. Green status lights in the dark.
```
- **Status:** Published
- **Published:** 2 days ago (set date manually)

#### Post 2: "Cyber-Samurai Armor V2"
- **Title:** Cyber-Samurai Armor V2
- **Slug:** cyber-samurai-armor-v2
- **Tags:** workshop, Cosplay
- **Excerpt:** "Full body EVA foam armor with integrated Arduino-controlled RGB lighting."
- **Content:**
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

Your process documentation here
```
- **Status:** Published
- **Published:** 7 days ago

#### Post 3: "Welcome to the Signal"
- **Title:** Welcome to the Signal
- **Slug:** welcome-to-the-signal
- **Tags:** calm
- **Featured:** Yes (check featured box)
- **Excerpt:** "Your first transmission. Welcome to the frequency."
- **Content:**
```
This is your space. A place where queer rave culture meets technical homelab energy, where mental health storytelling finds its voice, and where creative workshops come to life.

The Cult of Joey isn't a cult—it's a community. It's a frequency. It's the static between channels where the real signal lives.
```
- **Status:** Published
- **Published:** 14 days ago

### Step 3: Create Contact Page

Go to **Ghost Admin → Pages → New Page** and create:

- **Title:** Summon Me
- **Slug:** contact
- **Content:**
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
- **Status:** Published

### Step 4: Set Up Navigation

Go to **Ghost Admin → Settings → Navigation** and add:

1. **Journal** → `/tag/[choose-your-journal-tag]` or create a journal page
2. **Workshops** → `/tag/workshop`
3. **Gallery** → `/tag/gallery`
4. **Contact** → `/contact`

## Option 2: Fix API Key and Use Script

If you want to use the automated script, you'll need to:

1. Go to **Ghost Admin → Settings → Integrations**
2. Create a new Custom Integration
3. Copy the **Admin API Key** (should be in format `id:secret`)
4. Update the API key in `/root/.env` file
5. Run: `cd /root/cult-of-joey-ghost-theme && ./import-content.sh`

## Troubleshooting

- **API Key Invalid:** Make sure you're using the Admin API Key (not Content API Key) from Ghost Admin → Settings → Integrations
- **No Content Showing:** Make sure posts are published (not draft) and have the correct tags
- **Theme Not Showing:** Make sure the theme is activated in Ghost Admin → Settings → Design

## Quick Checklist

- [ ] Created all 8 tags
- [ ] Created 3 posts (Signal in the Static, Cyber-Samurai Armor V2, Welcome to the Signal)
- [ ] Created Contact page
- [ ] Set up navigation menu
- [ ] Verified theme is activated
- [ ] Checked posts are published (not draft)

