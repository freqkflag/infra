<?php
/**
 * Create Missing Content Script
 * Adds all missing posts, workshops, gallery items, and timeline events
 */

// Load WordPress
require_once('/var/www/html/wp-load.php');

echo "=== Creating Missing Content ===\n\n";

// 1. Create missing Journal Posts
echo "1. Creating missing Journal Posts...\n";

$missing_posts = array(
    array(
        'title' => '3AM Kubernetes Migrations',
        'slug' => '3am-k8s-migrations',
        'excerpt' => 'When the mania hits, we code. Documenting the migration of the personal cloud to a new architecture.',
        'content' => '<p>3:47 AM. The mania is here. Not the destructive kind—the productive kind. The kind where ideas flow like electrons through a circuit, where every problem has a solution if you just push hard enough.</p><p>I\'m migrating the entire homelab infrastructure to Kubernetes. Why? Because I can. Because the challenge keeps the demons at bay. Because there\'s nothing quite like watching your cluster come online after a clean deployment.</p><p>Documentation? Tomorrow. Coffee? Already on pot three.</p>',
        'date' => '2023-09-10',
        'mood' => 'manic',
        'category' => 'Tech'
    ),
    array(
        'title' => 'Quiet Mornings in the Desert',
        'slug' => 'quiet-mornings-desert',
        'excerpt' => 'The RV is parked near Quartzsite. The silence here is heavy, but welcome. Coffee tastes better with dust.',
        'content' => '<p>The silence in the desert is different from the silence at home. At home, silence is absence. Here, silence is presence. The presence of wind through creosote, of solar panels humming, of my own breath.</p><p>I parked the rig near Quartzsite last night. No hookups, no neighbors, just me and the stars and the quiet hum of the battery bank.</p><p>Coffee tastes different here. Maybe it\'s the dust. Maybe it\'s the altitude. Maybe it\'s the fact that I can finally hear myself think.</p>',
        'date' => '2023-08-05',
        'mood' => 'calm',
        'category' => 'Self'
    ),
);

foreach ($missing_posts as $post_data) {
    $existing = get_page_by_path($post_data['slug'], OBJECT, 'post');
    if ($existing) {
        echo "  - Post '{$post_data['title']}' already exists (ID: {$existing->ID})\n";
        continue;
    }
    
    $post_id = wp_insert_post(array(
        'post_title' => $post_data['title'],
        'post_name' => $post_data['slug'],
        'post_content' => $post_data['content'],
        'post_excerpt' => $post_data['excerpt'],
        'post_status' => 'publish',
        'post_date' => $post_data['date'] . ' 12:00:00',
        'post_type' => 'post',
    ));
    
    if ($post_id && !is_wp_error($post_id)) {
        // Assign mood
        wp_set_object_terms($post_id, array($post_data['mood']), 'mood');
        
        // Assign category (create if doesn't exist)
        $category = get_category_by_slug(sanitize_title($post_data['category']));
        if (!$category) {
            $term = wp_insert_term($post_data['category'], 'category');
            if (!is_wp_error($term)) {
                $category_id = $term['term_id'];
            } else {
                $category_id = null;
            }
        } else {
            $category_id = $category->term_id;
        }
        if ($category_id) {
            wp_set_object_terms($post_id, array($category_id), 'category');
        }
        
        echo "  ✓ Created post: {$post_data['title']} (ID: {$post_id})\n";
    } else {
        echo "  ✗ Failed to create post: {$post_data['title']}\n";
    }
}

// 2. Create Workshops
echo "\n2. Creating Workshops...\n";

$workshops_data = array(
    array(
        'title' => 'Cyber-Samurai Armor V2',
        'excerpt' => 'Full body EVA foam armor with integrated Arduino-controlled RGB lighting.',
        'category' => 'Cosplay',
        'specs' => array('EVA Foam', 'Arduino', 'WS2812B LEDs', 'C++'),
        'date' => '2023-01-01'
    ),
    array(
        'title' => 'Homelab Rack 42U',
        'excerpt' => 'Custom managed server rack cooling solution and cable management overhaul.',
        'category' => 'Tech',
        'specs' => array('Dell R720', 'Ubiquiti', 'Docker', 'Ansible'),
        'date' => '2023-01-01'
    ),
    array(
        'title' => 'Geometric Sleeve Tattoo',
        'excerpt' => 'Design and concept art for a full sleeve exploring sacred geometry and circuit board traces.',
        'category' => 'Tattoo',
        'specs' => array('Procreate', 'Ink', 'Skin'),
        'date' => '2022-01-01'
    ),
);

foreach ($workshops_data as $workshop_data) {
    $existing = get_page_by_path(sanitize_title($workshop_data['title']), OBJECT, 'workshop');
    if ($existing) {
        echo "  - Workshop '{$workshop_data['title']}' already exists (ID: {$existing->ID})\n";
        continue;
    }
    
    $post_id = wp_insert_post(array(
        'post_title' => $workshop_data['title'],
        'post_content' => '<p>' . $workshop_data['excerpt'] . '</p>',
        'post_excerpt' => $workshop_data['excerpt'],
        'post_status' => 'publish',
        'post_date' => $workshop_data['date'] . ' 12:00:00',
        'post_type' => 'workshop',
    ));
    
    if ($post_id && !is_wp_error($post_id)) {
        // Assign category
        wp_set_object_terms($post_id, array($workshop_data['category']), 'workshop_category');
        
        // Store specs as post meta
        update_post_meta($post_id, '_workshop_specs', $workshop_data['specs']);
        
        echo "  ✓ Created workshop: {$workshop_data['title']} (ID: {$post_id})\n";
    } else {
        echo "  ✗ Failed to create workshop: {$workshop_data['title']}\n";
    }
}

// 3. Create Gallery Items
echo "\n3. Creating Gallery items...\n";

$gallery_data = array(
    array('title' => 'Neon City', 'category' => 'Photography'),
    array('title' => 'Ritual Altar', 'category' => 'Art'),
    array('title' => 'Wasteland Weekend', 'category' => 'Events'),
    array('title' => 'Self Portrait', 'category' => 'Self'),
    array('title' => 'Circuit Board Macro', 'category' => 'Photography'),
    array('title' => 'Glitch Art Experiment', 'category' => 'Art'),
);

foreach ($gallery_data as $gallery_item) {
    $existing = get_page_by_path(sanitize_title($gallery_item['title']), OBJECT, 'gallery_item');
    if ($existing) {
        echo "  - Gallery item '{$gallery_item['title']}' already exists (ID: {$existing->ID})\n";
        continue;
    }
    
    $post_id = wp_insert_post(array(
        'post_title' => $gallery_item['title'],
        'post_excerpt' => $gallery_item['title'],
        'post_status' => 'publish',
        'post_type' => 'gallery_item',
    ));
    
    if ($post_id && !is_wp_error($post_id)) {
        // Assign category
        wp_set_object_terms($post_id, array($gallery_item['category']), 'gallery_category');
        
        echo "  ✓ Created gallery item: {$gallery_item['title']} (ID: {$post_id})\n";
    } else {
        echo "  ✗ Failed to create gallery item: {$gallery_item['title']}\n";
    }
}

// 4. Create Timeline Events
echo "\n4. Creating Timeline events...\n";

$timeline_data = array(
    array(
        'title' => 'Quartzsite Gathering',
        'description' => 'Met with the nomad tech guild. Starlink tests in deep desert.',
        'date' => 'Oct 2023',
        'location' => 'Quartzsite, AZ'
    ),
    array(
        'title' => 'The Great Northern Migration',
        'description' => 'Escaping the heat. Driving the rig up the PCH towards Oregon.',
        'date' => 'Aug 2023',
        'location' => 'Big Sur, CA'
    ),
    array(
        'title' => 'Solar Upgrade',
        'description' => 'Installed 800W of solar panels. Finally fully off-grid capable.',
        'date' => 'May 2023',
        'location' => 'Mojave Desert'
    ),
    array(
        'title' => 'Departure',
        'description' => 'Sold the apartment. Moved into the rig full-time. The beginning of the new era.',
        'date' => 'Jan 2023',
        'location' => 'Seattle, WA'
    ),
);

foreach ($timeline_data as $timeline_event) {
    $existing = get_page_by_path(sanitize_title($timeline_event['title']), OBJECT, 'timeline_event');
    if ($existing) {
        echo "  - Timeline event '{$timeline_event['title']}' already exists (ID: {$existing->ID})\n";
        continue;
    }
    
    $post_id = wp_insert_post(array(
        'post_title' => $timeline_event['title'],
        'post_content' => '<p>' . $timeline_event['description'] . '</p>',
        'post_status' => 'publish',
        'post_type' => 'timeline_event',
    ));
    
    if ($post_id && !is_wp_error($post_id)) {
        // Store meta fields
        update_post_meta($post_id, '_timeline_event_date', $timeline_event['date']);
        update_post_meta($post_id, '_timeline_location', $timeline_event['location']);
        
        echo "  ✓ Created timeline event: {$timeline_event['title']} (ID: {$post_id})\n";
    } else {
        echo "  ✗ Failed to create timeline event: {$timeline_event['title']}\n";
    }
}

// Flush rewrite rules
echo "\n5. Flushing rewrite rules...\n";
flush_rewrite_rules();
echo "  ✓ Rewrite rules flushed\n";

echo "\n=== All Content Created ===\n";
echo "\nSummary:\n";
echo "- Journal Posts: " . wp_count_posts('post')->publish . " published\n";
echo "- Workshops: " . wp_count_posts('workshop')->publish . " published\n";
echo "- Gallery Items: " . wp_count_posts('gallery_item')->publish . " published\n";
echo "- Timeline Events: " . wp_count_posts('timeline_event')->publish . " published\n";
echo "- Pages: " . wp_count_posts('page')->publish . " published\n";

