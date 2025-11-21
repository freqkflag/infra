<?php
/**
 * Cult of Joey Theme Functions
 *
 * @package Cult_Of_Joey
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Theme Setup
 */
function cult_of_joey_setup() {
	// Make theme available for translation
	load_theme_textdomain( 'cult-of-joey', get_template_directory() . '/languages' );

	// Add default posts and comments RSS feed links to head
	add_theme_support( 'automatic-feed-links' );

	// Let ClassicPress manage the document title
	add_theme_support( 'title-tag' );

	// Enable support for Post Thumbnails on posts and pages
	add_theme_support( 'post-thumbnails' );

	// This theme uses wp_nav_menu() in one location
	register_nav_menus(
		array(
			'main-menu' => esc_html__( 'Main Menu', 'cult-of-joey' ),
		)
	);

	// Add theme support for selective refresh for widgets
	add_theme_support( 'customize-selective-refresh-widgets' );

	// Add support for responsive embedded content
	add_theme_support( 'responsive-embeds' );

	// Add support for custom logo
	add_theme_support( 'custom-logo', array(
		'height'      => 100,
		'width'       => 400,
		'flex-height' => true,
		'flex-width'  => true,
		'header-text' => array( 'site-title', 'site-description' ),
	) );
}
add_action( 'after_setup_theme', 'cult_of_joey_setup' );

/**
 * Register Custom Post Types
 */
function cult_of_joey_register_post_types() {
	// Workshop CPT
	register_post_type( 'workshop',
		array(
			'labels' => array(
				'name' => __( 'Workshops', 'cult-of-joey' ),
				'singular_name' => __( 'Workshop', 'cult-of-joey' ),
				'add_new' => __( 'Add New', 'cult-of-joey' ),
				'add_new_item' => __( 'Add New Workshop', 'cult-of-joey' ),
				'edit_item' => __( 'Edit Workshop', 'cult-of-joey' ),
				'new_item' => __( 'New Workshop', 'cult-of-joey' ),
				'view_item' => __( 'View Workshop', 'cult-of-joey' ),
				'search_items' => __( 'Search Workshops', 'cult-of-joey' ),
				'not_found' => __( 'No workshops found', 'cult-of-joey' ),
			),
			'public' => true,
			'has_archive' => false,
			'rewrite' => array( 'slug' => 'workshops' ),
			'supports' => array( 'title', 'editor', 'thumbnail', 'excerpt' ),
			'menu_icon' => 'dashicons-hammer',
			'show_in_rest' => true,
		)
	);

	// Gallery Item CPT
	register_post_type( 'gallery_item',
		array(
			'labels' => array(
				'name' => __( 'Gallery Items', 'cult-of-joey' ),
				'singular_name' => __( 'Gallery Item', 'cult-of-joey' ),
				'add_new' => __( 'Add New', 'cult-of-joey' ),
				'add_new_item' => __( 'Add New Gallery Item', 'cult-of-joey' ),
				'edit_item' => __( 'Edit Gallery Item', 'cult-of-joey' ),
				'new_item' => __( 'New Gallery Item', 'cult-of-joey' ),
				'view_item' => __( 'View Gallery Item', 'cult-of-joey' ),
				'search_items' => __( 'Search Gallery Items', 'cult-of-joey' ),
				'not_found' => __( 'No gallery items found', 'cult-of-joey' ),
			),
			'public' => true,
			'has_archive' => false,
			'rewrite' => array( 'slug' => 'gallery' ),
			'supports' => array( 'title', 'thumbnail', 'excerpt' ),
			'menu_icon' => 'dashicons-format-image',
			'show_in_rest' => true,
		)
	);

	// Timeline Event CPT
	register_post_type( 'timeline_event',
		array(
			'labels' => array(
				'name' => __( 'Timeline Events', 'cult-of-joey' ),
				'singular_name' => __( 'Timeline Event', 'cult-of-joey' ),
				'add_new' => __( 'Add New', 'cult-of-joey' ),
				'add_new_item' => __( 'Add New Timeline Event', 'cult-of-joey' ),
				'edit_item' => __( 'Edit Timeline Event', 'cult-of-joey' ),
				'new_item' => __( 'New Timeline Event', 'cult-of-joey' ),
				'view_item' => __( 'View Timeline Event', 'cult-of-joey' ),
				'search_items' => __( 'Search Timeline Events', 'cult-of-joey' ),
				'not_found' => __( 'No timeline events found', 'cult-of-joey' ),
			),
			'public' => true,
			'has_archive' => false,
			'rewrite' => array( 'slug' => 'timeline' ),
			'supports' => array( 'title', 'editor', 'thumbnail' ),
			'menu_icon' => 'dashicons-calendar-alt',
			'show_in_rest' => true,
		)
	);
}
add_action( 'init', 'cult_of_joey_register_post_types' );

/**
 * Register Custom Taxonomies
 */
function cult_of_joey_register_taxonomies() {
	// Mood Taxonomy for Posts
	register_taxonomy( 'mood',
		'post',
		array(
			'labels' => array(
				'name' => __( 'Moods', 'cult-of-joey' ),
				'singular_name' => __( 'Mood', 'cult-of-joey' ),
				'search_items' => __( 'Search Moods', 'cult-of-joey' ),
				'all_items' => __( 'All Moods', 'cult-of-joey' ),
				'edit_item' => __( 'Edit Mood', 'cult-of-joey' ),
				'update_item' => __( 'Update Mood', 'cult-of-joey' ),
				'add_new_item' => __( 'Add New Mood', 'cult-of-joey' ),
				'new_item_name' => __( 'New Mood Name', 'cult-of-joey' ),
			),
			'hierarchical' => false,
			'show_ui' => true,
			'show_admin_column' => true,
			'query_var' => true,
			'rewrite' => array( 'slug' => 'mood' ),
			'show_in_rest' => true,
		)
	);

	// Workshop Category Taxonomy
	register_taxonomy( 'workshop_category',
		'workshop',
		array(
			'labels' => array(
				'name' => __( 'Workshop Categories', 'cult-of-joey' ),
				'singular_name' => __( 'Workshop Category', 'cult-of-joey' ),
			),
			'hierarchical' => true,
			'show_ui' => true,
			'show_admin_column' => true,
			'query_var' => true,
			'rewrite' => array( 'slug' => 'workshop-category' ),
			'show_in_rest' => true,
		)
	);

	// Gallery Category Taxonomy
	register_taxonomy( 'gallery_category',
		'gallery_item',
		array(
			'labels' => array(
				'name' => __( 'Gallery Categories', 'cult-of-joey' ),
				'singular_name' => __( 'Gallery Category', 'cult-of-joey' ),
			),
			'hierarchical' => true,
			'show_ui' => true,
			'show_admin_column' => true,
			'query_var' => true,
			'rewrite' => array( 'slug' => 'gallery-category' ),
			'show_in_rest' => true,
		)
	);
}
add_action( 'init', 'cult_of_joey_register_taxonomies' );

/**
 * Enqueue Scripts and Styles
 */
function cult_of_joey_scripts() {
	// Google Fonts
	wp_enqueue_style( 'cult-of-joey-fonts', 'https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&family=Orbitron:wght@400;500;700;900&family=Oxanium:wght@400;600;700&family=Space+Grotesk:wght@300;400;500;600;700&display=swap', array(), null );

	// Tailwind CSS CDN
	wp_enqueue_script( 'tailwindcss', 'https://cdn.tailwindcss.com', array(), '3.4.0', false );

	// Theme JavaScript
	wp_enqueue_script( 'cult-of-joey-main', get_template_directory_uri() . '/js/main.js', array(), '1.0.0', true );

	// Customizer preview script
	if ( is_customize_preview() ) {
		wp_enqueue_script( 'cult-of-joey-customizer', get_template_directory_uri() . '/js/customizer.js', array( 'jquery', 'customize-preview' ), '1.0.0', true );
	}

	// Localize script for AJAX
	wp_localize_script( 'cult-of-joey-main', 'cultOfJoey', array(
		'ajaxurl' => admin_url( 'admin-ajax.php' ),
		'nonce' => wp_create_nonce( 'cult-of-joey-nonce' ),
	) );
}
add_action( 'wp_enqueue_scripts', 'cult_of_joey_scripts' );

/**
 * Get Customizer Color Value
 */
function cult_of_joey_get_customizer_color( $setting, $default ) {
	return get_theme_mod( $setting, $default );
}

/**
 * Add Tailwind Config and Custom Styles to Head
 */
function cult_of_joey_head_styles() {
	// Get customizer values with defaults
	$primary = cult_of_joey_get_customizer_color( 'primary_color', '#E600FF' );
	$primary_soft = cult_of_joey_get_customizer_color( 'primary_soft_color', '#FF7BFF' );
	$accent = cult_of_joey_get_customizer_color( 'accent_color', '#00FFFF' );
	$accent_soft = cult_of_joey_get_customizer_color( 'accent_soft_color', '#66FFFF' );
	$background = cult_of_joey_get_customizer_color( 'background_color', '#05040A' );
	$surface = cult_of_joey_get_customizer_color( 'surface_color', '#0E0B1A' );
	$surface_alt = cult_of_joey_get_customizer_color( 'surface_alt_color', '#151027' );
	$text = cult_of_joey_get_customizer_color( 'text_color', '#F5F5FA' );
	$muted = cult_of_joey_get_customizer_color( 'muted_color', '#9B92BB' );
	$border = cult_of_joey_get_customizer_color( 'border_color', '#2B2540' );
	$warning = cult_of_joey_get_customizer_color( 'warning_color', '#FFB347' );
	$danger = cult_of_joey_get_customizer_color( 'danger_color', '#FF3366' );

	// Convert hex to RGB for rgba values
	$primary_rgb = cult_of_joey_hex_to_rgb( $primary );
	$accent_rgb = cult_of_joey_hex_to_rgb( $accent );
	?>
	<script>
		tailwind.config = {
			theme: {
				extend: {
					colors: {
						background: '<?php echo esc_js( $background ); ?>',
						surface: '<?php echo esc_js( $surface ); ?>',
						surfaceAlt: '<?php echo esc_js( $surface_alt ); ?>',
						primary: '<?php echo esc_js( $primary ); ?>',
						primarySoft: '<?php echo esc_js( $primary_soft ); ?>',
						accent: '<?php echo esc_js( $accent ); ?>',
						accentSoft: '<?php echo esc_js( $accent_soft ); ?>',
						warning: '<?php echo esc_js( $warning ); ?>',
						danger: '<?php echo esc_js( $danger ); ?>',
						text: '<?php echo esc_js( $text ); ?>',
						muted: '<?php echo esc_js( $muted ); ?>',
						border: '<?php echo esc_js( $border ); ?>',
					},
					fontFamily: {
						display: ['Orbitron', 'sans-serif'],
						heading: ['Oxanium', 'sans-serif'],
						body: ['Space Grotesk', 'sans-serif'],
						mono: ['JetBrains Mono', 'monospace'],
					},
					boxShadow: {
						'neon-primary': '0 0 12px rgba(<?php echo esc_js( $primary_rgb ); ?>, 0.6)',
						'neon-accent': '0 0 12px rgba(<?php echo esc_js( $accent_rgb ); ?>, 0.6)',
						'soft': '0 0 18px rgba(0, 0, 0, 0.7)',
						'glow-text-p': '0 0 5px rgba(<?php echo esc_js( $primary_rgb ); ?>, 0.8)',
						'glow-text-a': '0 0 5px rgba(<?php echo esc_js( $accent_rgb ); ?>, 0.8)',
					},
					animation: {
						'pulse-slow': 'pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite',
						'float': 'float 6s ease-in-out infinite',
					},
					keyframes: {
						float: {
							'0%, 100%': { transform: 'translateY(0)' },
							'50%': { transform: 'translateY(-10px)' },
						}
					}
				}
			}
		}
	</script>
	<style>
		body {
			background-color: <?php echo esc_attr( $background ); ?>;
			color: <?php echo esc_attr( $text ); ?>;
			overflow-x: hidden;
		}
		/* Custom scrollbar */
		::-webkit-scrollbar {
			width: 8px;
		}
		::-webkit-scrollbar-track {
			background: <?php echo esc_attr( $background ); ?>; 
		}
		::-webkit-scrollbar-thumb {
			background: <?php echo esc_attr( $border ); ?>; 
			border-radius: 4px;
		}
		::-webkit-scrollbar-thumb:hover {
			background: <?php echo esc_attr( $primary ); ?>; 
		}
		.glitch-hover:hover {
			animation: glitch-skew 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94) both infinite;
		}
		@keyframes glitch-skew {
			0% { transform: skew(0deg); }
			20% { transform: skew(-2deg); }
			40% { transform: skew(2deg); }
			60% { transform: skew(-1deg); }
			80% { transform: skew(1deg); }
			100% { transform: skew(0deg); }
		}
	</style>
	<?php
}
add_action( 'wp_head', 'cult_of_joey_head_styles' );

/**
 * Helper Function: Get Mood Chip Classes
 */
function cult_of_joey_get_mood_chip_classes( $mood, $is_active = false ) {
	$base_classes = 'inline-flex items-center px-3 py-1 rounded-full text-xs font-medium uppercase tracking-wider border transition-all duration-300 ease-out select-none hover:-translate-y-0.5';
	
	$mood_styles = array(
		'calm' => array(
			'base' => 'bg-teal-950/10 text-teal-400 border-teal-800/50',
			'hover' => 'hover:border-teal-400 hover:shadow-[0_0_15px_rgba(45,212,191,0.4)] hover:text-teal-200',
			'active' => 'bg-teal-500/20 border-teal-400 text-teal-50 shadow-[0_0_20px_rgba(45,212,191,0.6)] drop-shadow-[0_0_3px_rgba(45,212,191,1)]'
		),
		'manic' => array(
			'base' => 'bg-fuchsia-950/10 text-fuchsia-400 border-fuchsia-800/50',
			'hover' => 'hover:border-fuchsia-400 hover:shadow-[0_0_15px_rgba(232,121,249,0.4)] hover:text-fuchsia-200',
			'active' => 'bg-fuchsia-500/20 border-fuchsia-400 text-fuchsia-50 shadow-[0_0_20px_rgba(232,121,249,0.6)] drop-shadow-[0_0_3px_rgba(232,121,249,1)]'
		),
		'reflective' => array(
			'base' => 'bg-indigo-950/10 text-indigo-400 border-indigo-800/50',
			'hover' => 'hover:border-indigo-400 hover:shadow-[0_0_15px_rgba(129,140,248,0.4)] hover:text-indigo-200',
			'active' => 'bg-indigo-500/20 border-indigo-400 text-indigo-50 shadow-[0_0_20px_rgba(129,140,248,0.6)] drop-shadow-[0_0_3px_rgba(129,140,248,1)]'
		),
		'defiant' => array(
			'base' => 'bg-orange-950/10 text-orange-400 border-orange-800/50',
			'hover' => 'hover:border-orange-400 hover:shadow-[0_0_15px_rgba(251,146,60,0.4)] hover:text-orange-200',
			'active' => 'bg-orange-500/20 border-orange-400 text-orange-50 shadow-[0_0_20px_rgba(251,146,60,0.6)] drop-shadow-[0_0_3px_rgba(251,146,60,1)]'
		),
	);

	if ( isset( $mood_styles[ $mood ] ) ) {
		if ( $is_active ) {
			return $base_classes . ' cursor-pointer active:scale-95 ' . $mood_styles[ $mood ]['active'];
		} else {
			return $base_classes . ' cursor-pointer active:scale-95 ' . $mood_styles[ $mood ]['base'] . ' ' . $mood_styles[ $mood ]['hover'];
		}
	}

	return $base_classes . ' bg-surfaceAlt text-muted border-border hover:border-white/50 hover:text-white hover:shadow-[0_0_10px_rgba(255,255,255,0.2)]';
}

/**
 * Helper Function: Get Workshop Specs (stored as post meta)
 */
function cult_of_joey_get_workshop_specs( $post_id ) {
	$specs = get_post_meta( $post_id, '_workshop_specs', true );
	if ( is_string( $specs ) ) {
		$specs = maybe_unserialize( $specs );
	}
	return is_array( $specs ) ? $specs : array();
}

/**
 * Helper Function: Convert Hex to RGB
 */
function cult_of_joey_hex_to_rgb( $hex ) {
	$hex = str_replace( '#', '', $hex );
	if ( strlen( $hex ) == 3 ) {
		$r = hexdec( substr( $hex, 0, 1 ) . substr( $hex, 0, 1 ) );
		$g = hexdec( substr( $hex, 1, 1 ) . substr( $hex, 1, 1 ) );
		$b = hexdec( substr( $hex, 2, 1 ) . substr( $hex, 2, 1 ) );
	} else {
		$r = hexdec( substr( $hex, 0, 2 ) );
		$g = hexdec( substr( $hex, 2, 2 ) );
		$b = hexdec( substr( $hex, 4, 2 ) );
	}
	return "$r, $g, $b";
}

/**
 * Theme Customizer Setup
 */
function cult_of_joey_customize_register( $wp_customize ) {
	// Remove default sections we don't need
	$wp_customize->remove_section( 'colors' );
	$wp_customize->remove_section( 'background_image' );

	// Add Theme Colors Section
	$wp_customize->add_section( 'cult_of_joey_colors', array(
		'title'    => __( 'Theme Colors', 'cult-of-joey' ),
		'priority' => 30,
		'description' => __( 'Customize the neon cyberpunk color scheme of your theme.', 'cult-of-joey' ),
	) );

	// Primary Color
	$wp_customize->add_setting( 'primary_color', array(
		'default'           => '#E600FF',
		'sanitize_callback' => 'sanitize_hex_color',
		'transport'         => 'postMessage',
	) );
	$wp_customize->add_control( new WP_Customize_Color_Control( $wp_customize, 'primary_color', array(
		'label'    => __( 'Primary Color', 'cult-of-joey' ),
		'section'  => 'cult_of_joey_colors',
		'settings' => 'primary_color',
		'description' => __( 'Main magenta/pink neon color', 'cult-of-joey' ),
	) ) );

	// Primary Soft Color
	$wp_customize->add_setting( 'primary_soft_color', array(
		'default'           => '#FF7BFF',
		'sanitize_callback' => 'sanitize_hex_color',
		'transport'         => 'postMessage',
	) );
	$wp_customize->add_control( new WP_Customize_Color_Control( $wp_customize, 'primary_soft_color', array(
		'label'    => __( 'Primary Soft Color', 'cult-of-joey' ),
		'section'  => 'cult_of_joey_colors',
		'settings' => 'primary_soft_color',
	) ) );

	// Accent Color
	$wp_customize->add_setting( 'accent_color', array(
		'default'           => '#00FFFF',
		'sanitize_callback' => 'sanitize_hex_color',
		'transport'         => 'postMessage',
	) );
	$wp_customize->add_control( new WP_Customize_Color_Control( $wp_customize, 'accent_color', array(
		'label'    => __( 'Accent Color', 'cult-of-joey' ),
		'section'  => 'cult_of_joey_colors',
		'settings' => 'accent_color',
		'description' => __( 'Main cyan/blue neon color', 'cult-of-joey' ),
	) ) );

	// Accent Soft Color
	$wp_customize->add_setting( 'accent_soft_color', array(
		'default'           => '#66FFFF',
		'sanitize_callback' => 'sanitize_hex_color',
		'transport'         => 'postMessage',
	) );
	$wp_customize->add_control( new WP_Customize_Color_Control( $wp_customize, 'accent_soft_color', array(
		'label'    => __( 'Accent Soft Color', 'cult-of-joey' ),
		'section'  => 'cult_of_joey_colors',
		'settings' => 'accent_soft_color',
	) ) );

	// Background Color
	$wp_customize->add_setting( 'background_color', array(
		'default'           => '#05040A',
		'sanitize_callback' => 'sanitize_hex_color',
		'transport'         => 'postMessage',
	) );
	$wp_customize->add_control( new WP_Customize_Color_Control( $wp_customize, 'background_color', array(
		'label'    => __( 'Background Color', 'cult-of-joey' ),
		'section'  => 'cult_of_joey_colors',
		'settings' => 'background_color',
	) ) );

	// Surface Color
	$wp_customize->add_setting( 'surface_color', array(
		'default'           => '#0E0B1A',
		'sanitize_callback' => 'sanitize_hex_color',
		'transport'         => 'postMessage',
	) );
	$wp_customize->add_control( new WP_Customize_Color_Control( $wp_customize, 'surface_color', array(
		'label'    => __( 'Surface Color', 'cult-of-joey' ),
		'section'  => 'cult_of_joey_colors',
		'settings' => 'surface_color',
	) ) );

	// Surface Alt Color
	$wp_customize->add_setting( 'surface_alt_color', array(
		'default'           => '#151027',
		'sanitize_callback' => 'sanitize_hex_color',
		'transport'         => 'postMessage',
	) );
	$wp_customize->add_control( new WP_Customize_Color_Control( $wp_customize, 'surface_alt_color', array(
		'label'    => __( 'Surface Alt Color', 'cult-of-joey' ),
		'section'  => 'cult_of_joey_colors',
		'settings' => 'surface_alt_color',
	) ) );

	// Text Color
	$wp_customize->add_setting( 'text_color', array(
		'default'           => '#F5F5FA',
		'sanitize_callback' => 'sanitize_hex_color',
		'transport'         => 'postMessage',
	) );
	$wp_customize->add_control( new WP_Customize_Color_Control( $wp_customize, 'text_color', array(
		'label'    => __( 'Text Color', 'cult-of-joey' ),
		'section'  => 'cult_of_joey_colors',
		'settings' => 'text_color',
	) ) );

	// Muted Color
	$wp_customize->add_setting( 'muted_color', array(
		'default'           => '#9B92BB',
		'sanitize_callback' => 'sanitize_hex_color',
		'transport'         => 'postMessage',
	) );
	$wp_customize->add_control( new WP_Customize_Color_Control( $wp_customize, 'muted_color', array(
		'label'    => __( 'Muted Text Color', 'cult-of-joey' ),
		'section'  => 'cult_of_joey_colors',
		'settings' => 'muted_color',
	) ) );

	// Border Color
	$wp_customize->add_setting( 'border_color', array(
		'default'           => '#2B2540',
		'sanitize_callback' => 'sanitize_hex_color',
		'transport'         => 'postMessage',
	) );
	$wp_customize->add_control( new WP_Customize_Color_Control( $wp_customize, 'border_color', array(
		'label'    => __( 'Border Color', 'cult-of-joey' ),
		'section'  => 'cult_of_joey_colors',
		'settings' => 'border_color',
	) ) );

	// Warning Color
	$wp_customize->add_setting( 'warning_color', array(
		'default'           => '#FFB347',
		'sanitize_callback' => 'sanitize_hex_color',
		'transport'         => 'postMessage',
	) );
	$wp_customize->add_control( new WP_Customize_Color_Control( $wp_customize, 'warning_color', array(
		'label'    => __( 'Warning Color', 'cult-of-joey' ),
		'section'  => 'cult_of_joey_colors',
		'settings' => 'warning_color',
	) ) );

	// Danger Color
	$wp_customize->add_setting( 'danger_color', array(
		'default'           => '#FF3366',
		'sanitize_callback' => 'sanitize_hex_color',
		'transport'         => 'postMessage',
	) );
	$wp_customize->add_control( new WP_Customize_Color_Control( $wp_customize, 'danger_color', array(
		'label'    => __( 'Danger Color', 'cult-of-joey' ),
		'section'  => 'cult_of_joey_colors',
		'settings' => 'danger_color',
	) ) );

	// Add Social Media Section
	$wp_customize->add_section( 'cult_of_joey_social', array(
		'title'    => __( 'Social Media Links', 'cult-of-joey' ),
		'priority' => 35,
		'description' => __( 'Add your social media links. These will appear in the footer.', 'cult-of-joey' ),
	) );

	// Mastodon
	$wp_customize->add_setting( 'mastodon_url', array(
		'default'           => '',
		'sanitize_callback' => 'esc_url_raw',
	) );
	$wp_customize->add_control( 'mastodon_url', array(
		'label'    => __( 'Mastodon URL', 'cult-of-joey' ),
		'section'  => 'cult_of_joey_social',
		'settings' => 'mastodon_url',
		'type'     => 'url',
	) );

	// GitHub
	$wp_customize->add_setting( 'github_url', array(
		'default'           => '',
		'sanitize_callback' => 'esc_url_raw',
	) );
	$wp_customize->add_control( 'github_url', array(
		'label'    => __( 'GitHub URL', 'cult-of-joey' ),
		'section'  => 'cult_of_joey_social',
		'settings' => 'github_url',
		'type'     => 'url',
	) );

	// Instagram
	$wp_customize->add_setting( 'instagram_url', array(
		'default'           => '',
		'sanitize_callback' => 'esc_url_raw',
	) );
	$wp_customize->add_control( 'instagram_url', array(
		'label'    => __( 'Instagram URL', 'cult-of-joey' ),
		'section'  => 'cult_of_joey_social',
		'settings' => 'instagram_url',
		'type'     => 'url',
	) );

	// Contact Email
	$wp_customize->add_setting( 'contact_email', array(
		'default'           => 'joey@cultofjoey.com',
		'sanitize_callback' => 'sanitize_email',
	) );
	$wp_customize->add_control( 'contact_email', array(
		'label'    => __( 'Contact Email', 'cult-of-joey' ),
		'section'  => 'cult_of_joey_social',
		'settings' => 'contact_email',
		'type'     => 'email',
		'description' => __( 'Email address shown on the Contact page', 'cult-of-joey' ),
	) );

	// Add Additional Settings Section
	$wp_customize->add_section( 'cult_of_joey_settings', array(
		'title'    => __( 'Theme Settings', 'cult-of-joey' ),
		'priority' => 40,
		'description' => __( 'Additional theme customization options.', 'cult-of-joey' ),
	) );

	// Enable Glitch Effects
	$wp_customize->add_setting( 'enable_glitch_effects', array(
		'default'           => true,
		'sanitize_callback' => function( $value ) {
			return (bool) $value;
		},
	) );
	$wp_customize->add_control( 'enable_glitch_effects', array(
		'label'    => __( 'Enable Glitch Hover Effects', 'cult-of-joey' ),
		'section'  => 'cult_of_joey_settings',
		'settings' => 'enable_glitch_effects',
		'type'     => 'checkbox',
	) );

	// Peer Support Resources URL
	$wp_customize->add_setting( 'peer_support_url', array(
		'default'           => '',
		'sanitize_callback' => 'esc_url_raw',
	) );
	$wp_customize->add_control( 'peer_support_url', array(
		'label'    => __( 'Peer Support Resources URL', 'cult-of-joey' ),
		'section'  => 'cult_of_joey_settings',
		'settings' => 'peer_support_url',
		'type'     => 'url',
		'description' => __( 'Link to mental health support resources (shown in footer)', 'cult-of-joey' ),
	) );
}
add_action( 'customize_register', 'cult_of_joey_customize_register' );

/**
 * Enqueue Customizer Preview Scripts
 */
function cult_of_joey_customize_preview_js() {
	wp_enqueue_script(
		'cult-of-joey-customizer',
		get_template_directory_uri() . '/js/customizer.js',
		array( 'customize-preview' ),
		'1.0.0',
		true
	);
}
add_action( 'customize_preview_init', 'cult_of_joey_customize_preview_js' );

