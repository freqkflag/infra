<?php
/**
 * Template Name: Workshops
 * The template for displaying the Workshops page
 *
 * @package Cult_Of_Joey
 */

get_header();

// Get active filter from URL
$active_filter = isset( $_GET['category'] ) ? sanitize_text_field( $_GET['category'] ) : 'all';

// Build query args
$query_args = array(
	'post_type' => 'workshop',
	'posts_per_page' => -1,
	'post_status' => 'publish',
);

// Add category filter if not 'all'
if ( $active_filter !== 'all' && term_exists( $active_filter, 'workshop_category' ) ) {
	$query_args['tax_query'] = array(
		array(
			'taxonomy' => 'workshop_category',
			'field' => 'slug',
			'terms' => $active_filter,
		),
	);
}

$workshops_query = new WP_Query( $query_args );

// Get all workshop categories
$categories = get_terms( array(
	'taxonomy' => 'workshop_category',
	'hide_empty' => true,
) );
?>

<div class="min-h-screen bg-background py-12">
	<div class="container mx-auto px-6">
		<div class="flex flex-col md:flex-row justify-between items-end mb-12 gap-6">
			<div>
				<h1 class="text-4xl md:text-6xl font-display font-black text-white mb-4 glitch-hover">The Workshop</h1>
				<p class="text-muted max-w-xl">
					Documentation of physical and digital fabrication. 
					Building armor to survive the world, and servers to host the new one.
				</p>
			</div>
			
			<!-- Filters -->
			<div class="flex flex-wrap gap-2">
				<a 
					href="<?php echo esc_url( remove_query_arg( 'category' ) ); ?>"
					class="px-4 py-2 rounded-md text-sm font-mono border transition-all <?php echo $active_filter === 'all' ? 'border-accent text-accent bg-accent/10' : 'border-border text-muted hover:border-white hover:text-white'; ?>"
				>
					ALL
				</a>
				<?php if ( ! empty( $categories ) && ! is_wp_error( $categories ) ) : ?>
					<?php foreach ( $categories as $category ) : ?>
						<a 
							href="<?php echo esc_url( add_query_arg( 'category', $category->slug ) ); ?>"
							class="px-4 py-2 rounded-md text-sm font-mono border transition-all <?php echo $active_filter === $category->slug ? 'border-accent text-accent bg-accent/10' : 'border-border text-muted hover:border-white hover:text-white'; ?>"
						>
							<?php echo esc_html( strtoupper( $category->name ) ); ?>
						</a>
					<?php endforeach; ?>
				<?php endif; ?>
			</div>
		</div>

		<?php if ( $workshops_query->have_posts() ) : ?>
			<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
				<?php while ( $workshops_query->have_posts() ) : $workshops_query->the_post(); ?>
					<?php
					$workshop_cats = wp_get_post_terms( get_the_ID(), 'workshop_category' );
					$category = ! empty( $workshop_cats ) ? $workshop_cats[0]->name : '';
					$specs = cult_of_joey_get_workshop_specs( get_the_ID() );
					?>
					<div class="group bg-surface rounded-xl overflow-hidden border border-border hover:border-accent/50 transition-all duration-300 hover:shadow-neon-accent/20">
						<?php if ( has_post_thumbnail() ) : ?>
							<div class="relative aspect-video overflow-hidden">
								<div class="absolute inset-0 bg-gradient-to-t from-surface via-transparent to-transparent opacity-80 z-10" />
								<?php the_post_thumbnail( 'large', array( 'class' => 'w-full h-full object-cover transition-transform duration-700 group-hover:scale-110' ) ); ?>
								<?php if ( $category ) : ?>
									<div class="absolute bottom-3 left-4 z-20">
										<span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium uppercase tracking-wider border bg-white/10 text-white border-white shadow-[0_0_15px_rgba(255,255,255,0.5)]">
											<?php echo esc_html( $category ); ?>
										</span>
									</div>
								<?php endif; ?>
							</div>
						<?php endif; ?>
						<div class="p-5">
							<h3 class="text-xl font-heading font-bold text-text mb-2 group-hover:text-accent transition-colors glitch-hover">
								<?php the_title(); ?>
							</h3>
							<p class="text-sm text-muted mb-4 line-clamp-2">
								<?php echo esc_html( get_the_excerpt() ); ?>
							</p>
							<?php if ( ! empty( $specs ) ) : ?>
								<div class="flex flex-wrap gap-2">
									<?php foreach ( array_slice( $specs, 0, 3 ) as $spec ) : ?>
										<span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium uppercase tracking-wider border bg-surface text-accentSoft border-accent/20 font-mono hover:border-accent/60 hover:shadow-[0_0_12px_rgba(0,255,255,0.3)] hover:text-accent transition-all duration-300">
											<?php echo esc_html( $spec ); ?>
										</span>
									<?php endforeach; ?>
								</div>
							<?php endif; ?>
						</div>
					</div>
				<?php endwhile; ?>
			</div>
		<?php else : ?>
			<div class="text-center py-20 border border-dashed border-border rounded-xl bg-surface/50">
				<p class="text-muted font-mono">No workshops found in this category.</p>
			</div>
		<?php endif; ?>

		<?php wp_reset_postdata(); ?>
	</div>
</div>

<?php
get_footer();

