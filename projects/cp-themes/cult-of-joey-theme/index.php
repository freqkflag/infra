<?php
/**
 * The main template file for Journal/Blog listing
 *
 * @package Cult_Of_Joey
 */

get_header();

// Get active mood filter from URL
$active_mood = isset( $_GET['mood'] ) ? sanitize_text_field( $_GET['mood'] ) : 'all';

// Build query args
$query_args = array(
	'post_type' => 'post',
	'posts_per_page' => get_option( 'posts_per_page', 10 ),
	'post_status' => 'publish',
);

// Add mood filter if not 'all'
if ( $active_mood !== 'all' && term_exists( $active_mood, 'mood' ) ) {
	$query_args['tax_query'] = array(
		array(
			'taxonomy' => 'mood',
			'field' => 'slug',
			'terms' => $active_mood,
		),
	);
}

$journal_query = new WP_Query( $query_args );

// Get all mood terms
$moods = get_terms( array(
	'taxonomy' => 'mood',
	'hide_empty' => true,
) );
?>

<div class="container mx-auto px-6 py-12 min-h-screen">
	<div class="max-w-3xl mb-12">
		<h1 class="text-4xl md:text-6xl font-display font-black text-white mb-6 glitch-hover">The Book of Joey</h1>
		<p class="text-xl text-muted leading-relaxed">
			A raw, unencrypted log of mental states, technical breakthroughs, and the quiet moments in between. 
			Filter by the emotional frequency of the transmission.
		</p>
	</div>

	<!-- Filter Bar: Mood Chips Pattern -->
	<div class="mb-12">
		<div class="flex flex-wrap items-center gap-3 pb-6 border-b border-border/30">
			<span class="text-xs font-mono text-muted uppercase tracking-widest mr-2">Filter Frequency:</span>
			
			<!-- 'All' Filter -->
			<a 
				href="<?php echo esc_url( remove_query_arg( 'mood' ) ); ?>"
				class="<?php echo $active_mood === 'all' ? 'bg-white/10 text-white border-white shadow-[0_0_15px_rgba(255,255,255,0.5)] drop-shadow-[0_0_5px_rgba(255,255,255,0.8)]' : 'bg-surfaceAlt text-muted border-border hover:border-white/50 hover:text-white hover:shadow-[0_0_10px_rgba(255,255,255,0.2)]'; ?> inline-flex items-center px-3 py-1 rounded-full text-xs font-medium uppercase tracking-wider border transition-all duration-300 ease-out select-none hover:-translate-y-0.5 cursor-pointer active:scale-95"
			>
				All Signals
			</a>

			<!-- Mood Chips -->
			<?php if ( ! empty( $moods ) && ! is_wp_error( $moods ) ) : ?>
				<?php foreach ( $moods as $mood_term ) : ?>
					<a 
						href="<?php echo esc_url( add_query_arg( 'mood', $mood_term->slug ) ); ?>"
						class="<?php echo esc_attr( cult_of_joey_get_mood_chip_classes( $mood_term->slug, $active_mood === $mood_term->slug ) ); ?>"
					>
						<?php echo esc_html( $mood_term->name ); ?>
					</a>
				<?php endforeach; ?>
			<?php endif; ?>
		</div>
	</div>

	<!-- Grid -->
	<?php if ( $journal_query->have_posts() ) : ?>
		<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
			<?php while ( $journal_query->have_posts() ) : $journal_query->the_post(); ?>
				<?php
				$mood_terms = wp_get_post_terms( get_the_ID(), 'mood' );
				$mood = ! empty( $mood_terms ) ? $mood_terms[0]->slug : '';
				?>
				<a href="<?php the_permalink(); ?>" class="block group h-full">
					<article class="bg-surface h-full border border-border rounded-xl overflow-hidden transition-all duration-300 group-hover:-translate-y-1 group-hover:border-primary/40 group-hover:shadow-soft relative">
						<!-- Top accent line -->
						<div class="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-transparent via-primary to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
						
						<div class="p-6 flex flex-col h-full">
							<div class="mb-4 flex justify-between items-start">
								<?php if ( $mood ) : ?>
									<span class="<?php echo esc_attr( cult_of_joey_get_mood_chip_classes( $mood ) ); ?>">
										<?php echo esc_html( $mood_terms[0]->name ); ?>
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

		<!-- Pagination -->
		<?php
		$pagination = paginate_links( array(
			'total' => $journal_query->max_num_pages,
			'prev_text' => '← Previous',
			'next_text' => 'Next →',
			'type' => 'list',
		) );
		
		if ( $pagination ) :
			?>
			<div class="mt-12 flex justify-center">
				<?php echo $pagination; ?>
			</div>
		<?php endif; ?>
	<?php else : ?>
		<div class="text-center py-20 border border-dashed border-border rounded-xl bg-surface/50">
			<p class="text-muted font-mono mb-2">No signals found on this frequency.</p>
			<a href="<?php echo esc_url( remove_query_arg( 'mood' ) ); ?>" class="text-accent text-sm hover:underline">
				Reset Filters
			</a>
		</div>
	<?php endif; ?>

	<?php wp_reset_postdata(); ?>
</div>

<?php
get_footer();

