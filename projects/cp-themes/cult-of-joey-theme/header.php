<!DOCTYPE html>
<html <?php language_attributes(); ?> class="scroll-smooth">
<head>
	<meta charset="<?php bloginfo( 'charset' ); ?>">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<link rel="profile" href="https://gmpg.org/xfn/11">
	<?php wp_head(); ?>
</head>
<body <?php body_class( 'cult-of-joey-theme' ); ?>>
<?php wp_body_open(); ?>

<header id="masthead" class="fixed top-0 left-0 right-0 z-50 transition-all duration-300 border-b bg-transparent py-5 border-transparent" role="banner">
	<div class="container mx-auto px-6 flex justify-between items-center">
		<?php
		$custom_logo_id = get_theme_mod( 'custom_logo' );
		if ( $custom_logo_id ) {
			$logo = wp_get_attachment_image_src( $custom_logo_id, 'full' );
			$logo_url = $logo[0];
			?>
			<a href="<?php echo esc_url( home_url( '/' ) ); ?>" class="group relative">
				<img src="<?php echo esc_url( $logo_url ); ?>" alt="<?php echo esc_attr( get_bloginfo( 'name' ) ); ?>" class="h-10 w-auto" />
			</a>
			<?php
		} else {
			?>
			<a href="<?php echo esc_url( home_url( '/' ) ); ?>" class="font-display font-black text-2xl tracking-tighter text-white group relative">
				<span class="group-hover:text-primary transition-colors">CULT</span>
				<span class="text-primary group-hover:text-white transition-colors">OF</span>
				<span class="group-hover:text-accent transition-colors">JOEY</span>
				<span class="absolute -bottom-1 left-0 w-0 h-0.5 bg-accent group-hover:w-full transition-all duration-300"></span>
			</a>
			<?php
		}
		?>

		<!-- Desktop Nav -->
		<nav class="hidden md:flex items-center gap-8" role="navigation" aria-label="<?php esc_attr_e( 'Main Menu', 'cult-of-joey' ); ?>">
			<?php
			$menu_items = array(
				array( 'label' => 'Journal', 'url' => get_permalink( get_option( 'page_for_posts' ) ) ?: home_url( '/' ) ),
				array( 'label' => 'Workshops', 'url' => get_permalink( get_page_by_path( 'workshops' ) ) ?: home_url( '/workshops' ) ),
				array( 'label' => 'Gallery', 'url' => get_permalink( get_page_by_path( 'gallery' ) ) ?: home_url( '/gallery' ) ),
				array( 'label' => 'RV Life', 'url' => get_permalink( get_page_by_path( 'rv-life' ) ) ?: home_url( '/rv-life' ) ),
			);

			foreach ( $menu_items as $item ) :
				$current = ( is_page() && get_permalink() === $item['url'] ) || ( is_home() && $item['url'] === get_permalink( get_option( 'page_for_posts' ) ) );
				?>
				<a 
					href="<?php echo esc_url( $item['url'] ); ?>"
					class="font-heading font-medium text-sm uppercase tracking-wide relative transition-colors hover:text-accent <?php echo $current ? 'text-accent' : 'text-muted'; ?>"
				>
					<?php echo esc_html( $item['label'] ); ?>
					<?php if ( $current ) : ?>
						<span class="absolute -bottom-1 left-0 right-0 h-[2px] bg-accent shadow-[0_0_8px_#00FFFF]"></span>
					<?php endif; ?>
				</a>
			<?php endforeach; ?>
			
			<a href="<?php echo esc_url( get_permalink( get_page_by_path( 'contact' ) ) ?: home_url( '/contact' ) ); ?>" class="font-heading font-semibold text-sm px-3 py-1.5 bg-primary text-background rounded-full hover:bg-primarySoft hover:shadow-neon-primary transition-all duration-200 ease-out active:scale-95">
				Summon Me
			</a>
		</nav>

		<!-- Mobile Toggle -->
		<button 
			id="mobile-menu-toggle"
			class="md:hidden text-white focus:outline-none"
			aria-label="<?php esc_attr_e( 'Toggle mobile menu', 'cult-of-joey' ); ?>"
			aria-expanded="false"
		>
			<svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
			</svg>
		</button>
	</div>

	<!-- Mobile Menu -->
	<div id="mobile-menu" class="md:hidden hidden absolute top-full left-0 w-full bg-surface border-b border-border p-6 flex flex-col gap-4 shadow-2xl">
		<?php foreach ( $menu_items as $item ) : ?>
			<a 
				href="<?php echo esc_url( $item['url'] ); ?>"
				class="font-heading text-lg text-muted hover:text-primary transition-colors"
			>
				<?php echo esc_html( $item['label'] ); ?>
			</a>
		<?php endforeach; ?>
		<a 
			href="<?php echo esc_url( get_permalink( get_page_by_path( 'contact' ) ) ?: home_url( '/contact' ) ); ?>"
			class="font-heading font-semibold text-base px-6 py-2.5 bg-primary text-background rounded-full hover:bg-primarySoft hover:shadow-neon-primary transition-all duration-200 ease-out active:scale-95 text-center"
		>
			Summon Me
		</a>
	</div>
</header>

<div id="page" class="site">
	<main id="main" class="site-main flex-grow pt-20">

