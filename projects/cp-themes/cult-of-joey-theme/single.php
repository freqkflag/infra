<?php
/**
 * The template for displaying single posts
 *
 * @package Cult_Of_Joey
 */

get_header();

while ( have_posts() ) :
	the_post();
	
	// Get mood terms
	$mood_terms = wp_get_post_terms( get_the_ID(), 'mood' );
	$mood = ! empty( $mood_terms ) ? $mood_terms[0]->slug : '';
	
	// Get related posts (same mood or category)
	$related_args = array(
		'post_type' => 'post',
		'posts_per_page' => 2,
		'post__not_in' => array( get_the_ID() ),
		'post_status' => 'publish',
	);
	
	if ( ! empty( $mood_terms ) ) {
		$related_args['tax_query'] = array(
			array(
				'taxonomy' => 'mood',
				'field' => 'slug',
				'terms' => $mood,
			),
		);
	} else {
		$categories = wp_get_post_categories( get_the_ID() );
		if ( ! empty( $categories ) ) {
			$related_args['category__in'] = $categories;
		}
	}
	
	$related_posts = new WP_Query( $related_args );
	?>

	<div class="min-h-screen pb-20">
		<!-- Header -->
		<header class="pt-20 pb-12 bg-gradient-to-b from-surface to-background border-b border-border">
			<div class="container mx-auto px-6 max-w-4xl">
				<div class="flex flex-wrap gap-4 items-center mb-6">
					<?php if ( $mood ) : ?>
						<span class="<?php echo esc_attr( cult_of_joey_get_mood_chip_classes( $mood, false ) ); ?>">
							<?php echo esc_html( $mood_terms[0]->name ); ?>
						</span>
					<?php endif; ?>
					
					<span class="text-accent font-mono text-sm"><?php echo esc_html( get_the_date( 'M j, Y' ) ); ?></span>
					<span class="text-muted text-sm">•</span>
					<span class="text-muted text-sm">
						<?php
						$read_time = ceil( str_word_count( get_the_content() ) / 200 );
						echo esc_html( $read_time . ' min read' );
						?>
					</span>
				</div>
				<h1 class="text-4xl md:text-6xl font-display font-bold text-white leading-tight mb-6 glow-text glitch-hover">
					<?php the_title(); ?>
				</h1>
				<p class="text-xl text-muted md:w-3/4 font-light leading-relaxed border-l-4 border-primary pl-6">
					<?php echo esc_html( get_the_excerpt() ); ?>
				</p>
			</div>
		</header>

		<!-- Content Body -->
		<article class="container mx-auto px-6 max-w-3xl py-12">
			<?php if ( has_post_thumbnail() ) : ?>
				<div class="mb-12 rounded-2xl overflow-hidden border border-border shadow-soft">
					<?php the_post_thumbnail( 'large', array( 'class' => 'w-full h-auto' ) ); ?>
				</div>
			<?php endif; ?>

			<div class="prose prose-invert prose-lg max-w-none font-body 
				prose-headings:font-heading prose-headings:text-white 
				prose-a:text-accent prose-a:no-underline hover:prose-a:text-white hover:prose-a:underline
				prose-blockquote:border-l-primary prose-blockquote:bg-surfaceAlt/30 prose-blockquote:p-4 prose-blockquote:italic prose-blockquote:rounded-r-lg
				prose-code:text-primarySoft prose-code:bg-surfaceAlt prose-code:px-1 prose-code:rounded prose-code:font-mono prose-p:text-text prose-li:text-text">
				<?php the_content(); ?>
			</div>
			
			<div class="mt-16 pt-8 border-t border-border flex justify-between items-center">
				<a href="<?php echo esc_url( get_permalink( get_option( 'page_for_posts' ) ) ?: home_url( '/' ) ); ?>" class="text-muted hover:text-white transition-colors font-mono">← Back to Index</a>
				<div class="flex gap-2">
					<button class="w-8 h-8 rounded-full bg-surface border border-border flex items-center justify-center text-muted hover:text-accent transition-colors" onclick="navigator.share({title: '<?php echo esc_js( get_the_title() ); ?>', url: '<?php echo esc_url( get_permalink() ); ?>'}).catch(() => {})">
						<span class="sr-only">Share</span>
						<svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
							<path d="M18 16.08c-.76 0-1.44.3-1.96.77L8.91 12.7c.05-.23.09-.46.09-.7s-.04-.47-.09-.7l7.05-4.11c.54.5 1.25.81 2.04.81 1.66 0 3-1.34 3-3s-1.34-3-3-3-3 1.34-3 3c0 .24.04.47.09.7L8.04 9.81C7.5 9.31 6.79 9 6 9c-1.66 0-3 1.34-3 3s1.34 3 3 3c.79 0 1.5-.31 2.04-.81l7.12 4.16c-.05.21-.08.43-.08.65 0 1.61 1.31 2.92 2.92 2.92 1.61 0 2.92-1.31 2.92-2.92s-1.31-2.92-2.92-2.92z"/>
						</svg>
					</button>
				</div>
			</div>
		</article>

		<!-- Related Posts -->
		<?php if ( $related_posts->have_posts() ) : ?>
			<section class="container mx-auto px-6 py-12">
				<h3 class="text-2xl font-display font-bold text-white mb-6 glitch-hover">More from this Era</h3>
				<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
					<?php while ( $related_posts->have_posts() ) : $related_posts->the_post(); ?>
						<?php
						$related_mood_terms = wp_get_post_terms( get_the_ID(), 'mood' );
						$related_mood = ! empty( $related_mood_terms ) ? $related_mood_terms[0]->slug : '';
						?>
						<a href="<?php the_permalink(); ?>" class="block group h-full">
							<article class="bg-surface h-full border border-border rounded-xl overflow-hidden transition-all duration-300 group-hover:-translate-y-1 group-hover:border-primary/40 group-hover:shadow-soft relative">
								<div class="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-transparent via-primary to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
								<div class="p-6 flex flex-col h-full">
									<div class="mb-4 flex justify-between items-start">
										<?php if ( $related_mood ) : ?>
											<span class="<?php echo esc_attr( cult_of_joey_get_mood_chip_classes( $related_mood ) ); ?>">
												<?php echo esc_html( $related_mood_terms[0]->name ); ?>
											</span>
										<?php endif; ?>
										<span class="text-xs text-muted font-mono"><?php echo esc_html( get_the_date( 'M j, Y' ) ); ?></span>
									</div>
									<h3 class="text-xl font-heading font-bold text-text mb-3 group-hover:text-primarySoft transition-colors glitch-hover">
										<?php the_title(); ?>
									</h3>
									<p class="text-muted text-sm leading-relaxed mb-6 flex-grow line-clamp-3">
										<?php echo esc_html( get_the_excerpt() ); ?>
									</p>
									<div class="flex items-center text-accent text-sm font-medium group-hover:underline underline-offset-4 decoration-accent/50">
										Read Transmission <span class="ml-2 group-hover:translate-x-1 transition-transform">→</span>
									</div>
								</div>
							</article>
						</a>
					<?php endwhile; ?>
				</div>
			</section>
			<?php wp_reset_postdata(); ?>
		<?php endif; ?>
	</div>

<?php
endwhile;
get_footer();

