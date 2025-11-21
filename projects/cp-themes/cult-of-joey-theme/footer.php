	</main><!-- #main -->
</div><!-- #page -->

<footer class="bg-background border-t border-border mt-auto relative overflow-hidden">
	<!-- Top Glow Line -->
	<div class="absolute top-0 left-0 w-full h-[1px] bg-gradient-to-r from-transparent via-primary/30 to-transparent"></div>

	<div class="container mx-auto px-6 py-12">
		<div class="grid grid-cols-1 md:grid-cols-3 gap-8 mb-12">
			<div>
				<h3 class="font-display font-bold text-xl text-white mb-4 glitch-hover">CULT OF JOEY</h3>
				<p class="text-muted text-sm max-w-xs">
					Broadcasting from the intersection of mental health recovery, queer identity, and high-voltage electronics.
				</p>
			</div>
			
			<div class="flex flex-col gap-2">
				<h4 class="font-heading font-bold text-white mb-2">Navigation</h4>
				<a href="<?php echo esc_url( get_permalink( get_option( 'page_for_posts' ) ) ?: home_url( '/' ) ); ?>" class="text-muted hover:text-accent text-sm transition-colors w-fit">Journal</a>
				<a href="<?php echo esc_url( get_permalink( get_page_by_path( 'workshops' ) ) ?: home_url( '/workshops' ) ); ?>" class="text-muted hover:text-accent text-sm transition-colors w-fit">Workshops</a>
				<a href="<?php echo esc_url( get_permalink( get_page_by_path( 'gallery' ) ) ?: home_url( '/gallery' ) ); ?>" class="text-muted hover:text-accent text-sm transition-colors w-fit">Gallery</a>
				<a href="<?php echo esc_url( get_permalink( get_page_by_path( 'rv-life' ) ) ?: home_url( '/rv-life' ) ); ?>" class="text-muted hover:text-accent text-sm transition-colors w-fit">RV Life</a>
			</div>

			<div class="flex flex-col gap-2">
				<h4 class="font-heading font-bold text-white mb-2">Connect</h4>
				<?php
				$mastodon_url = get_theme_mod( 'mastodon_url', '' );
				$github_url = get_theme_mod( 'github_url', '' );
				$instagram_url = get_theme_mod( 'instagram_url', '' );
				?>
				<?php if ( $mastodon_url ) : ?>
					<a href="<?php echo esc_url( $mastodon_url ); ?>" class="text-muted hover:text-primary text-sm transition-colors w-fit cult-of-joey-mastodon">Mastodon</a>
				<?php endif; ?>
				<?php if ( $github_url ) : ?>
					<a href="<?php echo esc_url( $github_url ); ?>" class="text-muted hover:text-primary text-sm transition-colors w-fit cult-of-joey-github">GitHub</a>
				<?php endif; ?>
				<?php if ( $instagram_url ) : ?>
					<a href="<?php echo esc_url( $instagram_url ); ?>" class="text-muted hover:text-primary text-sm transition-colors w-fit cult-of-joey-instagram">Instagram</a>
				<?php endif; ?>
			</div>
		</div>

		<div class="border-t border-border/50 pt-8 flex flex-col md:flex-row justify-between items-center gap-4">
			<p class="text-xs text-muted/50 font-mono">
				&copy; <?php echo esc_html( date( 'Y' ) ); ?> Cult of Joey. Built with silicon and anxiety.
			</p>
			
			<div class="bg-surfaceAlt px-4 py-2 rounded-md border border-primary/20 flex items-center gap-3">
				<div class="w-2 h-2 bg-warning rounded-full animate-pulse"></div>
				<span class="text-xs text-muted">
					Need immediate help? 
					<?php
					$peer_support_url = get_theme_mod( 'peer_support_url', '' );
					if ( $peer_support_url ) :
						?>
						<a href="<?php echo esc_url( $peer_support_url ); ?>" class="text-accent hover:underline">Peer Support Resources</a>
					<?php else : ?>
						<a href="#" class="text-accent hover:underline">Peer Support Resources</a>
					<?php endif; ?>
				</span>
			</div>
		</div>
	</div>
</footer>

<?php wp_footer(); ?>
</body>
</html>

