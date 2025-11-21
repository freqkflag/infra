<?php
/**
 * Starter Content Setup Script
 * 
 * Run this script once to populate ClassicPress with starter content
 * Access via: http://yoursite.com/wp-content/themes/cult-of-joey-theme/setup-starter-content.php
 * Or run via WP-CLI: wp eval-file wp-content/themes/cult-of-joey-theme/setup-starter-content.php
 */

// Load WordPress
if (file_exists(__DIR__ . '/../../../../wp-load.php')) {
    require_once(__DIR__ . '/../../../../wp-load.php');
} elseif (file_exists(__DIR__ . '/../../../wp-load.php')) {
    require_once(__DIR__ . '/../../../wp-load.php');
} else {
    // Try absolute path
    require_once('/var/www/html/wp-load.php');
}

if (!current_user_can('manage_options')) {
    die('Permission denied. You must be logged in as an administrator.');
}

echo "<h1>Setting up Cult of Joey Starter Content...</h1><pre>";

// 1. Create Mood Taxonomy Terms
echo "Creating Mood taxonomy terms...\n";
$moods = array('calm', 'manic', 'reflective', 'defiant');
foreach ($moods as $mood) {
    if (!term_exists($mood, 'mood')) {
        wp_insert_term(ucfirst($mood), 'mood', array('slug' => $mood));
        echo "  - Created mood: {$mood}\n";
    } else {
        echo "  - Mood {$mood} already exists\n";
    }
}

// 2. Create Workshop Categories
echo "\nCreating Workshop categories...\n";
$workshop_categories = array('Cosplay', 'Tech', 'Tattoo', 'DIY');
foreach ($workshop_categories as $cat) {
    if (!term_exists($cat, 'workshop_category')) {
        wp_insert_term($cat, 'workshop_category', array('slug' => strtolower($cat)));
        echo "  - Created category: {$cat}\n";
    } else {
        echo "  - Category {$cat} already exists\n";
    }
}

// 3. Create Gallery Categories
echo "\nCreating Gallery categories...\n";
$gallery_categories = array('Photography', 'Art', 'Events', 'Self');
foreach ($gallery_categories as $cat) {
    if (!term_exists($cat, 'gallery_category')) {
        wp_insert_term($cat, 'gallery_category', array('slug' => strtolower($cat)));
        echo "  - Created category: {$cat}\n";
    } else {
        echo "  - Category {$cat} already exists\n";
    }
}

// 4. Create Posts (Journal entries)
echo "\nCreating Journal posts...\n";
$posts_data = array(
    array(
        'title' => 'Signal in the Static',
        'slug' => 'signal-in-the-static',
        'excerpt' => 'Navigating the noise of modern existence while rebuilding a homelab from scratch. A metaphor for mental recovery.',
        'content' => '<p>The hum of the server rack is a comfort. It\'s a consistent, white noise that drowns out the chaotic frequency of the outside world. Yesterday, I tore down the entire cluster.</p><p>Why? Because sometimes you need to burn it down to build it right. The dependencies were tangled, the legacy configurations were haunting the logs, and frankly, it just didn\'t feel clean anymore.</p><blockquote>Recovery isn\'t a straight line. It\'s a recursive function with no exit condition sometimes.</blockquote><p>Rebuilding the Kubernetes cluster felt like a ritual. Flashing the ISOs, bootstrapping the nodes, watching the pods come alive one by one. Green status lights in the dark.</p>',
        'date' => '2023-10-14',
        'mood' => 'reflective',
        'category' => 'Tech'
    ),
    array(
        'title' => 'Neon Scars & EVA Foam',
        'slug' => 'neon-scars-eva-foam',
        'excerpt' => 'Crafting armor for a body that has fought too many battles. Cosplay as a form of somatic therapy.',
        'content' => '<p>Sometimes the best way to heal is to create something beautiful from the broken pieces. My latest project: a full-body armor set made from EVA foam, layered with RGB LEDs that pulse in sync with my heartbeat.</p><p>There\'s something deeply therapeutic about the process of crafting. The cutting, the sanding, the heat-forming. Each step requires focus, presence. No room for the noise in my head.</p>',
        'date' => '2023-09-28',
        'mood' => 'defiant',
        'category' => 'Cosplay'
    ),
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

foreach ($posts_data as $post_data) {
    $post_id = wp_insert_post(array(
        'post_title' => $post_data['title'],
        'post_name' => $post_data['slug'],
        'post_content' => $post_data['content'],
        'post_excerpt' => $post_data['excerpt'],
        'post_status' => 'publish',
        'post_date' => $post_data['date'] . ' 12:00:00',
        'post_type' => 'post',
    ));
    
    if ($post_id) {
        // Assign mood
        wp_set_object_terms($post_id, array($post_data['mood']), 'mood');
        
        // Assign category (create if doesn't exist)
        $category_id = wp_create_category($post_data['category']);
        wp_set_object_terms($post_id, array($category_id), 'category');
        
        echo "  - Created post: {$post_data['title']} (ID: {$post_id})\n";
    }
}

// 5. Create Workshop Posts
echo "\nCreating Workshop posts...\n";
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
    $post_id = wp_insert_post(array(
        'post_title' => $workshop_data['title'],
        'post_content' => '<p>' . $workshop_data['excerpt'] . '</p>',
        'post_excerpt' => $workshop_data['excerpt'],
        'post_status' => 'publish',
        'post_date' => $workshop_data['date'] . ' 12:00:00',
        'post_type' => 'workshop',
    ));
    
    if ($post_id) {
        // Assign category
        wp_set_object_terms($post_id, array($workshop_data['category']), 'workshop_category');
        
        // Store specs as post meta
        update_post_meta($post_id, '_workshop_specs', $workshop_data['specs']);
        
        echo "  - Created workshop: {$workshop_data['title']} (ID: {$post_id})\n";
    }
}

// 6. Create Gallery Items
echo "\nCreating Gallery items...\n";
$gallery_data = array(
    array('title' => 'Neon City', 'category' => 'Photography'),
    array('title' => 'Ritual Altar', 'category' => 'Art'),
    array('title' => 'Wasteland Weekend', 'category' => 'Events'),
    array('title' => 'Self Portrait', 'category' => 'Self'),
    array('title' => 'Circuit Board Macro', 'category' => 'Photography'),
    array('title' => 'Glitch Art Experiment', 'category' => 'Art'),
);

foreach ($gallery_data as $gallery_item) {
    $post_id = wp_insert_post(array(
        'post_title' => $gallery_item['title'],
        'post_excerpt' => $gallery_item['title'],
        'post_status' => 'publish',
        'post_type' => 'gallery_item',
    ));
    
    if ($post_id) {
        // Assign category
        wp_set_object_terms($post_id, array($gallery_item['category']), 'gallery_category');
        
        echo "  - Created gallery item: {$gallery_item['title']} (ID: {$post_id})\n";
    }
}

// 7. Create Timeline Events
echo "\nCreating Timeline events...\n";
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
    $post_id = wp_insert_post(array(
        'post_title' => $timeline_event['title'],
        'post_content' => '<p>' . $timeline_event['description'] . '</p>',
        'post_status' => 'publish',
        'post_type' => 'timeline_event',
    ));
    
    if ($post_id) {
        // Store meta fields
        update_post_meta($post_id, '_timeline_event_date', $timeline_event['date']);
        update_post_meta($post_id, '_timeline_location', $timeline_event['location']);
        
        echo "  - Created timeline event: {$timeline_event['title']} (ID: {$post_id})\n";
    }
}

// 8. Create Pages
echo "\nCreating Pages...\n";
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
        
        if ($page_id && isset($page_data['template'])) {
            update_post_meta($page_id, '_wp_page_template', $page_data['template']);
            echo "  - Created page: {$page_data['title']} (ID: {$page_id}) with template {$page_data['template']}\n";
        }
    } else {
        // Update existing page with template
        if (isset($page_data['template'])) {
            update_post_meta($page->ID, '_wp_page_template', $page_data['template']);
            echo "  - Updated existing page: {$page_data['title']} (ID: {$page->ID}) with template {$page_data['template']}\n";
        } else {
            echo "  - Page {$page_data['title']} already exists (ID: {$page->ID})\n";
        }
    }
}

echo "\n\n✅ Starter content setup complete!\n";
echo "\nNext steps:\n";
echo "1. Set a page as your homepage (Settings > Reading)\n";
echo "2. Set a page for blog posts (Settings > Reading > Posts page)\n";
echo "3. Add featured images to posts, workshops, and gallery items\n";
echo "4. Activate the theme if you haven't already\n";
echo "</pre>";

