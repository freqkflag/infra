<?php
/**
 * Create Home and Journal Pages
 * Run this script to create the Home and Journal pages
 */

// Load WordPress
require_once('/var/www/html/wp-load.php');

echo "=== Creating Home and Journal Pages ===\n\n";

// 1. Create Home Page
echo "1. Creating Home page...\n";
$home_page = get_page_by_path('home');

if (!$home_page) {
    $home_page_id = wp_insert_post(array(
        'post_title' => 'Home',
        'post_name' => 'home',
        'post_content' => '<p>Welcome to Cult of Joey - A digital sanctuary for queer resilience, homelab mysticism, and creative survival.</p>',
        'post_status' => 'publish',
        'post_type' => 'page',
    ));
    
    if ($home_page_id && !is_wp_error($home_page_id)) {
        update_post_meta($home_page_id, '_wp_page_template', 'page-home.php');
        echo "  ✓ Created Home page (ID: {$home_page_id}) with template page-home.php\n";
        
        // Optionally set as front page
        // update_option('show_on_front', 'page');
        // update_option('page_on_front', $home_page_id);
    } else {
        echo "  ✗ Failed to create Home page\n";
    }
} else {
    update_post_meta($home_page->ID, '_wp_page_template', 'page-home.php');
    echo "  ✓ Updated existing Home page (ID: {$home_page->ID}) with template page-home.php\n";
}

// 2. Create Journal Page
echo "\n2. Creating Journal page...\n";
$journal_page = get_page_by_path('journal');

if (!$journal_page) {
    $journal_page_id = wp_insert_post(array(
        'post_title' => 'Journal',
        'post_name' => 'journal',
        'post_content' => '<p>A raw, unencrypted log of mental states, technical breakthroughs, and the quiet moments in between.</p>',
        'post_status' => 'publish',
        'post_type' => 'page',
    ));
    
    if ($journal_page_id && !is_wp_error($journal_page_id)) {
        update_post_meta($journal_page_id, '_wp_page_template', 'page-journal.php');
        echo "  ✓ Created Journal page (ID: {$journal_page_id}) with template page-journal.php\n";
        
        // Set as posts page
        update_option('page_for_posts', $journal_page_id);
        echo "  ✓ Set Journal page as the Posts page\n";
    } else {
        echo "  ✗ Failed to create Journal page\n";
    }
} else {
    update_post_meta($journal_page->ID, '_wp_page_template', 'page-journal.php');
    update_option('page_for_posts', $journal_page->ID);
    echo "  ✓ Updated existing Journal page (ID: {$journal_page->ID}) with template page-journal.php\n";
    echo "  ✓ Set Journal page as the Posts page\n";
}

// Flush rewrite rules
echo "\n3. Flushing rewrite rules...\n";
flush_rewrite_rules();
echo "  ✓ Rewrite rules flushed\n";

echo "\n=== Setup Complete ===\n";
echo "\nNext steps:\n";
echo "1. Go to Settings > Reading\n";
echo "2. Set 'Front page displays' to 'A static page'\n";
echo "3. Select 'Home' as your Front page\n";
echo "4. Select 'Journal' as your Posts page\n";
echo "5. Click 'Save Changes'\n";

