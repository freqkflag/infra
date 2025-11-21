<?php
/**
 * The main template file
 *
 * This template loads the React SPA application
 *
 * @package ClassicPress_Dark_Neon_Glitch
 */

// Check if built assets exist
$theme_dir = get_template_directory();
$theme_uri = get_template_directory_uri();
$build_exists = file_exists( $theme_dir . '/dist/index.html' );

?><!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
	<meta charset="<?php bloginfo( 'charset' ); ?>">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<link rel="profile" href="https://gmpg.org/xfn/11">
	
	<?php if ( $build_exists ) : ?>
		<?php
		// Load the built Vite app HTML
		$build_html = file_get_contents( $theme_dir . '/dist/index.html' );
		
		// Extract and output head content, replacing asset paths
		preg_match( '/<head>(.*?)<\/head>/is', $build_html, $head_matches );
		if ( ! empty( $head_matches[1] ) ) {
			$head_content = $head_matches[1];
			// Fix asset paths to be relative to theme directory
			$head_content = str_replace( 'href="/', 'href="' . $theme_uri . '/dist/', $head_content );
			$head_content = str_replace( 'src="/', 'src="' . $theme_uri . '/dist/', $head_content );
			$head_content = str_replace( '"assets/', '"' . $theme_uri . '/dist/assets/', $head_content );
			echo $head_content;
		}
		?>
	<?php else : ?>
		<!-- Development Mode: Load from source -->
		<title><?php wp_title( '|', true, 'right' ); ?></title>
		<link rel="preconnect" href="https://fonts.googleapis.com">
		<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
		<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&family=Orbitron:wght@400;500;700;900&family=Oxanium:wght@400;600;700&family=Space+Grotesk:wght@300;400;500;600;700&display=swap" rel="stylesheet">
		<script src="https://cdn.tailwindcss.com"></script>
		<script>
			tailwind.config = {
				theme: {
					extend: {
						colors: {
							background: '#05040A',
							surface: '#0E0B1A',
							surfaceAlt: '#151027',
							primary: '#E600FF',
							primarySoft: '#FF7BFF',
							accent: '#00FFFF',
							accentSoft: '#66FFFF',
							warning: '#FFB347',
							danger: '#FF3366',
							text: '#F5F5FA',
							muted: '#9B92BB',
							border: '#2B2540',
						},
						fontFamily: {
							display: ['Orbitron', 'sans-serif'],
							heading: ['Oxanium', 'sans-serif'],
							body: ['Space Grotesk', 'sans-serif'],
							mono: ['JetBrains Mono', 'monospace'],
						},
						boxShadow: {
							'neon-primary': '0 0 12px rgba(230, 0, 255, 0.6)',
							'neon-accent': '0 0 12px rgba(0, 255, 255, 0.6)',
							'soft': '0 0 18px rgba(0, 0, 0, 0.7)',
							'glow-text-p': '0 0 5px rgba(230, 0, 255, 0.8)',
							'glow-text-a': '0 0 5px rgba(0, 255, 255, 0.8)',
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
				background-color: #05040A;
				color: #F5F5FA;
				overflow-x: hidden;
			}
			::-webkit-scrollbar {
				width: 8px;
			}
			::-webkit-scrollbar-track {
				background: #05040A; 
			}
			::-webkit-scrollbar-thumb {
				background: #2B2540; 
				border-radius: 4px;
			}
			::-webkit-scrollbar-thumb:hover {
				background: #E600FF; 
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
		<script type="importmap">
		{
			"imports": {
				"react-router-dom": "https://aistudiocdn.com/react-router-dom@^7.9.6",
				"react/": "https://aistudiocdn.com/react@^19.2.0/",
				"react": "https://aistudiocdn.com/react@^19.2.0",
				"react-dom/": "https://aistudiocdn.com/react-dom@^19.2.0/"
			}
		}
		</script>
	<?php endif; ?>
	
	<?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>
	<?php wp_body_open(); ?>
	
	<?php if ( $build_exists ) : ?>
		<?php
		// Load and output the built app body
		preg_match( '/<body[^>]*>(.*?)<\/body>/is', $build_html, $body_matches );
		if ( ! empty( $body_matches[1] ) ) {
			$body_content = $body_matches[1];
			// Fix asset paths
			$body_content = str_replace( 'src="/', 'src="' . $theme_uri . '/dist/', $body_content );
			$body_content = str_replace( '"assets/', '"' . $theme_uri . '/dist/assets/', $body_content );
			echo $body_content;
		}
		
		// Extract and output scripts from the HTML
		preg_match_all( '/<script([^>]*)>(.*?)<\/script>/is', $build_html, $script_matches, PREG_SET_ORDER );
		foreach ( $script_matches as $script_match ) {
			$script_attrs = $script_match[1];
			$script_content = $script_match[2];
			
			// Fix src attributes
			if ( preg_match( '/src=["\']([^"\']+)["\']/', $script_attrs, $src_match ) ) {
				$src = $src_match[1];
				if ( strpos( $src, 'http' ) !== 0 ) {
					// Relative path, make it absolute
					if ( $src[0] === '/' ) {
						$src = $theme_uri . '/dist' . $src;
					} else {
						$src = $theme_uri . '/dist/' . $src;
					}
					$script_attrs = str_replace( $src_match[0], 'src="' . $src . '"', $script_attrs );
				}
			}
			
			echo '<script' . $script_attrs . '>' . $script_content . '</script>';
		}
		?>
	<?php else : ?>
		<!-- Development Mode: Load React app from source via Vite -->
		<!-- Note: For dev mode to work, you need Vite dev server running or build the app first -->
		<div id="root"></div>
		<link rel="stylesheet" href="<?php echo $theme_uri; ?>/index.css">
		<script type="module" src="<?php echo $theme_uri; ?>/index.tsx"></script>
	<?php endif; ?>
	
	<?php wp_footer(); ?>
</body>
</html>

