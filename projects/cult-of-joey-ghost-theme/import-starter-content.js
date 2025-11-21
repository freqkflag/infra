#!/usr/bin/env node
/**
 * Import Starter Content into Ghost
 * 
 * This script creates starter content via Ghost Admin API
 * 
 * Usage:
 *   GHOST_URL=http://localhost:2368 GHOST_ADMIN_API_KEY=your-key node import-starter-content.js
 */

const https = require('https');
const http = require('http');

const GHOST_URL = process.env.GHOST_URL || 'http://localhost:2368';
const GHOST_ADMIN_API_KEY = process.env.GHOST_ADMIN_API_KEY || '';
const CONTENT_API_KEY = process.env.GHOST_CONTENT_API_KEY || '';

if (!GHOST_ADMIN_API_KEY) {
  console.error('❌ Error: GHOST_ADMIN_API_KEY environment variable is required');
  console.error('   Usage: GHOST_URL=http://localhost:2368 GHOST_ADMIN_API_KEY=your-key node import-starter-content.js');
  process.exit(1);
}

// Helper to make API requests
function makeRequest(url, method = 'GET', data = null) {
  return new Promise((resolve, reject) => {
    const isHttps = url.startsWith('https');
    const client = isHttps ? https : http;
    
    const urlObj = new URL(url);
    const options = {
      hostname: urlObj.hostname,
      port: urlObj.port || (isHttps ? 443 : 80),
      path: urlObj.pathname + urlObj.search,
      method: method,
      headers: {
        'Authorization': `Ghost ${GHOST_ADMIN_API_KEY}`,
        'Content-Type': 'application/json',
        'Accept-Version': 'v5.0'
      }
    };

    if (data) {
      const jsonData = JSON.stringify(data);
      options.headers['Content-Length'] = Buffer.byteLength(jsonData);
    }

    const req = client.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => { body += chunk; });
      res.on('end', () => {
        try {
          const parsed = JSON.parse(body);
          if (res.statusCode >= 200 && res.statusCode < 300) {
            resolve(parsed);
          } else {
            reject(new Error(`API Error (${res.statusCode}): ${parsed.errors?.[0]?.message || body}`));
          }
        } catch (e) {
          reject(new Error(`Parse error: ${body}`));
        }
      });
    });

    req.on('error', reject);
    
    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
}

// Create or get tag
async function ensureTag(name, slug, description = '') {
  try {
    // Try to get existing tag
    const existing = await makeRequest(`${GHOST_URL}/ghost/api/admin/tags/slug/${slug}/`);
    console.log(`✅ Tag "${name}" already exists`);
    return existing.tags[0];
  } catch (e) {
    // Tag doesn't exist, create it
    try {
      const created = await makeRequest(`${GHOST_URL}/ghost/api/admin/tags/`, 'POST', {
        tags: [{
          name,
          slug,
          description
        }]
      });
      console.log(`✅ Created tag: "${name}"`);
      return created.tags[0];
    } catch (createError) {
      console.error(`❌ Failed to create tag "${name}":`, createError.message);
      throw createError;
    }
  }
}

// Create post
async function createPost(postData) {
  try {
    const result = await makeRequest(`${GHOST_URL}/ghost/api/admin/posts/`, 'POST', {
      posts: [postData]
    });
    console.log(`✅ Created post: "${postData.title}"`);
    return result.posts[0];
  } catch (error) {
    console.error(`❌ Failed to create post "${postData.title}":`, error.message);
    throw error;
  }
}

// Create page
async function createPage(pageData) {
  try {
    const result = await makeRequest(`${GHOST_URL}/ghost/api/admin/pages/`, 'POST', {
      pages: [pageData]
    });
    console.log(`✅ Created page: "${pageData.title}"`);
    return result.pages[0];
  } catch (error) {
    console.error(`❌ Failed to create page "${pageData.title}":`, error.message);
    throw error;
  }
}

// Main import function
async function importStarterContent() {
  console.log('🚀 Starting Ghost starter content import...\n');
  console.log(`📍 Ghost URL: ${GHOST_URL}\n`);

  try {
    // Step 1: Create tags
    console.log('📋 Creating tags...');
    await ensureTag('calm', 'calm', 'For calm, peaceful posts (teal tint)');
    await ensureTag('manic', 'manic', 'For energetic, intense posts (magenta tint)');
    await ensureTag('reflective', 'reflective', 'For thoughtful, introspective posts (indigo tint)');
    await ensureTag('defiant', 'defiant', 'For bold, rebellious posts (orange tint)');
    await ensureTag('workshop', 'workshop', 'For workshop/project posts');
    await ensureTag('gallery', 'gallery', 'For gallery posts');
    await ensureTag('Tech', 'tech', 'Technology and homelab content');
    await ensureTag('Cosplay', 'cosplay', 'Cosplay projects');
    console.log('');

    // Step 2: Create posts
    console.log('📝 Creating posts...');
    
    await createPost({
      title: 'Signal in the Static',
      slug: 'signal-in-the-static',
      mobiledoc: JSON.stringify({
        version: '0.3.1',
        atoms: [],
        cards: [],
        markups: [],
        sections: [
          [1, 'p', [[0, [], 0, "The hum of the server rack is a comfort. It's a consistent, white noise that drowns out the chaotic frequency of the outside world. Yesterday, I tore down the entire cluster."]]],
          [1, 'p', [[0, [], 0, "Why? Because sometimes you need to burn it down to build it right. The dependencies were tangled, the legacy configurations were haunting the logs, and frankly, it just didn't feel clean anymore."]]],
          [1, 'p', [[0, [], 0, "Recovery isn't a straight line. It's a recursive function with no exit condition sometimes."]]],
          [1, 'p', [[0, [], 0, 'Rebuilding the Kubernetes cluster felt like a ritual. Flashing the ISOs, bootstrapping the nodes, watching the pods come alive one by one. Green status lights in the dark.']]]
        ]
      }),
      status: 'published',
      custom_excerpt: 'Navigating the noise of modern existence while rebuilding a homelab from scratch. A metaphor for mental recovery.',
      tags: [{name: 'reflective'}, {name: 'Tech'}],
      published_at: new Date(Date.now() - 86400000 * 2).toISOString() // 2 days ago
    });

    await createPost({
      title: 'Cyber-Samurai Armor V2',
      slug: 'cyber-samurai-armor-v2',
      mobiledoc: JSON.stringify({
        version: '0.3.1',
        atoms: [],
        cards: [],
        markups: [],
        sections: [
          [1, 'h2', [[0, [], 0, 'Summary']]],
          [1, 'p', [[0, [], 0, 'This project combines traditional cosplay fabrication with modern electronics to create a fully illuminated armor set.']]],
          [1, 'h2', [[0, [], 0, 'Specs']]],
          [1, 'ul', [
            [[0, [], 0, 'EVA Foam base structure']],
            [[0, [], 0, 'Arduino Nano for control']],
            [[0, [], 0, 'WS2812B LED strips']],
            [[0, [], 0, 'Custom C++ firmware']],
            [[0, [], 0, 'Battery-powered for portability']]
          ]],
          [1, 'h2', [[0, [], 0, 'Process']]],
          [1, 'p', [[0, [], 0, 'Your process documentation here']]]
        ]
      }),
      status: 'published',
      custom_excerpt: 'Full body EVA foam armor with integrated Arduino-controlled RGB lighting.',
      tags: [{name: 'workshop'}, {name: 'Cosplay'}],
      published_at: new Date(Date.now() - 86400000 * 7).toISOString() // 7 days ago
    });

    await createPost({
      title: 'Welcome to the Signal',
      slug: 'welcome-to-the-signal',
      mobiledoc: JSON.stringify({
        version: '0.3.1',
        atoms: [],
        cards: [],
        markups: [],
        sections: [
          [1, 'p', [[0, [], 0, "This is your space. A place where queer rave culture meets technical homelab energy, where mental health storytelling finds its voice, and where creative workshops come to life."]]],
          [1, 'p', [[0, [], 0, "The Cult of Joey isn't a cult—it's a community. It's a frequency. It's the static between channels where the real signal lives."]]]
        ]
      }),
      status: 'published',
      custom_excerpt: 'Your first transmission. Welcome to the frequency.',
      featured: true,
      tags: [{name: 'calm'}],
      published_at: new Date(Date.now() - 86400000 * 14).toISOString() // 14 days ago
    });

    console.log('');

    // Step 3: Create pages
    console.log('📄 Creating pages...');
    
    await createPage({
      title: 'Summon Me',
      slug: 'contact',
      mobiledoc: JSON.stringify({
        version: '0.3.1',
        atoms: [],
        cards: [],
        markups: [],
        sections: [
          [1, 'h2', [[0, [], 0, 'SUMMON ME']]],
          [1, 'p', [[0, [], 0, 'Open for collaborations on:']]],
          [1, 'ul', [
            [[0, [], 0, 'Creative Coding / Web Dev']],
            [[0, [], 0, 'Cosplay fabrication advice']],
            [[0, [], 0, 'Homelab architecture']],
            [[0, [], 0, 'Speaking on mental health & tech']]
          ]],
          [1, 'h3', [[0, [], 0, 'SECURE CHANNEL:']]],
          [1, 'p', [[0, [], 0, 'joey@cultofjoey.com']]]
        ]
      }),
      status: 'published'
    });

    console.log('');
    console.log('✅ Starter content imported successfully!');
    console.log('');
    console.log('📋 Next steps:');
    console.log('   1. Go to Ghost Admin → Settings → Navigation');
    console.log('   2. Add menu items: Journal, Workshops, Gallery, Contact');
    console.log('   3. Customize your content as needed');
    console.log('');

  } catch (error) {
    console.error('\n❌ Import failed:', error.message);
    process.exit(1);
  }
}

// Run import
if (require.main === module) {
  importStarterContent();
}

module.exports = { importStarterContent };

