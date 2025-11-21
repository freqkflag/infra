<?php
/**
 * Manual Setup Script - Run directly via PHP CLI
 * This script creates all pages and ensures content is set up correctly
 */

// Load WordPress
require_once('/var/www/html/wp-load.php');

echo "=== Cult of Joey Manual Setup ===\n\n";

// 1. Create/Update Pages
echo "1. Creating Pages...\n";

$pages_data = array(
    array(
        'title' => 'Workshops',
        'slug' => 'workshops',
        'content' => '<p>Documentation of physical and digital fabrication. Building armor to survive the world, and servers to host the new one.</p>',
        'template' => 'page-workshops.php'
    ),
    array(
        'title' => 'Gallery',
        'slug' => 'gallery',
        'content' => '<p>Snapshots of the journey.</p>',
        'template' => 'page-gallery.php'
    ),
    array(
        'title' => 'RV Life',
        'slug' => 'rv-life',
        'content' => '<p>Leaving the static grid for a life on wheels. Chasing reliable 5G signals and solitude across the North American continent.</p>',
        'template' => 'page-rv-life.php'
    ),
    array(
        'title' => 'Contact',
        'slug' => 'contact',
        'content' => '<p>Get in touch for collaborations, questions, or just to say hi.</p>',
        'template' => 'page-contact.php'
    ),
);

foreach ($pages_data as $page_data) {
    $page = get_page_by_path($page_data['slug']);
    
    if (!$page) {
        $page_id = wp_insert_post(array(
            'post_title' => $page_data['title'],
            'post_name' => $page_data['slug'],
            'post_content' => $page_data['content'],
            'post_status' => 'publish',
            'post_type' => 'page',
        ));
        
        if ($page_id && !is_wp_error($page_id)) {
            if (isset($page_data['template'])) {
                update_post_meta($page_id, '_wp_page_template', $page_data['template']);
            }
            echo "  ✓ Created page: {$page_data['title']} (ID: {$page_id})\n";
        } else {
            echo "  ✗ Failed to create page: {$page_data['title']}\n";
        }
    } else {
        // Update existing page with template
        if (isset($page_data['template'])) {
            update_post_meta($page->ID, '_wp_page_template', $page_data['template']);
            echo "  ✓ Updated page: {$page_data['title']} (ID: {$page->ID}) with template {$page_data['template']}\n";
        } else {
            echo "  - Page {$page_data['title']} already exists (ID: {$page->ID})\n";
        }
    }
}

// 2. Verify Posts exist
echo "\n2. Verifying Journal Posts...\n";
$required_posts = array(
    'signal-in-the-static',
    'neon-scars-eva-foam',
    '3am-k8s-migrations',
    'quiet-mornings-desert'
);

foreach ($required_posts as $slug) {
    $post = get_page_by_path($slug, OBJECT, 'post');
    if ($post) {
        echo "  ✓ Post exists: {$slug} (ID: {$post->ID})\n";
    } else {
        echo "  ✗ Post missing: {$slug}\n";
    }
}

// 3. Verify Workshops
echo "\n3. Verifying Workshops...\n";
$workshops = get_posts(array(
    'post_type' => 'workshop',
    'posts_per_page' => -1,
    'post_status' => 'publish'
));
echo "  Found " . count($workshops) . " workshops\n";
foreach ($workshops as $workshop) {
    echo "  - {$workshop->post_title} (ID: {$workshop->ID})\n";
}

// 4. Verify Gallery Items
echo "\n4. Verifying Gallery Items...\n";
$gallery_items = get_posts(array(
    'post_type' => 'gallery_item',
    'posts_per_page' => -1,
    'post_status' => 'publish'
));
echo "  Found " . count($gallery_items) . " gallery items\n";
foreach ($gallery_items as $item) {
    echo "  - {$item->post_title} (ID: {$item->ID})\n";
}

// 5. Verify Timeline Events
echo "\n5. Verifying Timeline Events...\n";
$timeline_events = get_posts(array(
    'post_type' => 'timeline_event',
    'posts_per_page' => -1,
    'post_status' => 'publish'
));
echo "  Found " . count($timeline_events) . " timeline events\n";
foreach ($timeline_events as $event) {
    echo "  - {$event->post_title} (ID: {$event->ID})\n";
}

// 6. Flush rewrite rules
echo "\n6. Flushing rewrite rules...\n";
flush_rewrite_rules();
echo "  ✓ Rewrite rules flushed\n";

echo "\n=== Setup Complete ===\n";
echo "\nNext steps:\n";
echo "1. Activate the Cult of Joey theme (Appearance > Themes)\n";
echo "2. Set homepage (Settings > Reading)\n";
echo "3. Add featured images to posts, workshops, and gallery items\n";

