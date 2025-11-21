<?php
/**
 * ClassicPress Dark Neon Glitch Theme Functions
 *
 * @package ClassicPress_Dark_Neon_Glitch
 */

if ( ! function_exists( 'cult_of_joey_setup' ) ) :
	/**
	 * Sets up theme defaults and registers support for various ClassicPress features.
	 */
	function cult_of_joey_setup() {
		// Make theme available for translation
		load_theme_textdomain( 'classicpress-dark-neon-glitch', get_template_directory() . '/languages' );

		// Add default posts and comments RSS feed links to head
		add_theme_support( 'automatic-feed-links' );

		// Let ClassicPress manage the document title
		add_theme_support( 'title-tag' );

		// Enable support for Post Thumbnails on posts and pages
		add_theme_support( 'post-thumbnails' );

		// This theme uses wp_nav_menu() in one location
		register_nav_menus(
			array(
				'main-menu' => esc_html__( 'Main Menu', 'classicpress-dark-neon-glitch' ),
			)
		);

		// Add theme support for selective refresh for widgets
		add_theme_support( 'customize-selective-refresh-widgets' );

		// Add support for responsive embedded content
		add_theme_support( 'responsive-embeds' );
	}
endif;
add_action( 'after_setup_theme', 'cult_of_joey_setup' );

/**
 * Enqueue scripts and styles.
 */
function cult_of_joey_scripts() {
	// Check if built assets exist (dist folder after vite build)
	$theme_dir = get_template_directory_uri();
	$build_dir = $theme_dir . '/dist';
	
	// Enqueue the built CSS if it exists
	if ( file_exists( get_template_directory() . '/dist/index.css' ) ) {
		wp_enqueue_style( 'cult-of-joey-style', $build_dir . '/index.css', array(), '1.0.0' );
	}
	
	// Enqueue the built JS if it exists
	if ( file_exists( get_template_directory() . '/dist/index.js' ) ) {
		wp_enqueue_script( 'cult-of-joey-app', $build_dir . '/index.js', array(), '1.0.0', true );
	}
	
	// Fallback: If no build exists, the index.php will handle loading the dev version
}
add_action( 'wp_enqueue_scripts', 'cult_of_joey_scripts' );

/**
 * Add custom body classes
 */
function cult_of_joey_body_classes( $classes ) {
	// Add a class for when the React app is loaded
	$classes[] = 'cult-of-joey-theme';
	return $classes;
}
add_filter( 'body_class', 'cult_of_joey_body_classes' );

