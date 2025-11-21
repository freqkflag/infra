<?php
/**
 * Template Name: Gallery
 * The template for displaying the Gallery page
 *
 * @package Cult_Of_Joey
 */

get_header();

$gallery_query = new WP_Query( array(
	'post_type' => 'gallery_item',
	'posts_per_page' => -1,
	'post_status' => 'publish',
) );
?>

<div class="min-h-screen py-12">
	<div class="container mx-auto px-6 mb-12">
		<h1 class="text-4xl md:text-6xl font-display font-black text-white mb-4 glitch-hover">Visual Database</h1>
		<p class="text-muted">Snapshots of the journey.</p>
	</div>

	<?php if ( $gallery_query->have_posts() ) : ?>
		<!-- Masonry-ish Grid -->
		<div class="container mx-auto px-6 grid grid-cols-1 md:grid-cols-3 gap-4" id="gallery-grid">
			<?php while ( $gallery_query->have_posts() ) : $gallery_query->the_post(); ?>
				<?php
				$gallery_cats = wp_get_post_terms( get_the_ID(), 'gallery_category' );
				$category = ! empty( $gallery_cats ) ? $gallery_cats[0]->name : '';
				?>
				<div 
					class="gallery-item relative group cursor-pointer overflow-hidden rounded-lg break-inside-avoid"
					data-image-url="<?php echo esc_url( get_the_post_thumbnail_url( get_the_ID(), 'full' ) ); ?>"
					data-title="<?php echo esc_attr( get_the_title() ); ?>"
					data-category="<?php echo esc_attr( $category ); ?>"
				>
					<?php if ( has_post_thumbnail() ) : ?>
						<?php the_post_thumbnail( 'medium_large', array( 'class' => 'w-full h-64 md:h-80 object-cover transition-transform duration-500 group-hover:scale-105 filter grayscale-[30%] group-hover:grayscale-0' ) ); ?>
						<div class="absolute inset-0 bg-gradient-to-t from-background via-transparent to-transparent opacity-60 md:opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex flex-col justify-end p-6">
							<?php if ( $category ) : ?>
								<span class="text-accent font-mono text-xs uppercase mb-1"><?php echo esc_html( $category ); ?></span>
							<?php endif; ?>
							<h3 class="text-white font-heading font-bold text-lg glitch-hover"><?php the_title(); ?></h3>
						</div>
					<?php endif; ?>
				</div>
			<?php endwhile; ?>
		</div>
	<?php else : ?>
		<div class="text-center py-20 border border-dashed border-border rounded-xl bg-surface/50">
			<p class="text-muted font-mono">No gallery items found.</p>
		</div>
	<?php endif; ?>

	<?php wp_reset_postdata(); ?>

	<!-- Lightbox Modal -->
	<div id="gallery-lightbox" class="fixed inset-0 z-[100] bg-black/90 backdrop-blur-md flex items-center justify-center p-4 hidden">
		<button id="lightbox-close" class="absolute top-6 right-6 text-white hover:text-accent">
			<svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
			</svg>
		</button>
		<div class="max-w-5xl w-full max-h-[90vh] flex flex-col items-center">
			<img id="lightbox-image" src="" alt="" class="max-h-[80vh] w-auto rounded-md shadow-[0_0_30px_rgba(0,0,0,0.5)]" />
			<div class="mt-4 text-center">
				<h2 id="lightbox-title" class="text-2xl font-display font-bold text-white glitch-hover"></h2>
				<span id="lightbox-category" class="text-accent font-mono text-sm"></span>
			</div>
		</div>
	</div>
</div>

<?php
get_footer();

