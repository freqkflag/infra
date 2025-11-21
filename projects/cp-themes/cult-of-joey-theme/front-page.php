<?php
/**
 * The front page template file
 *
 * @package Cult_Of_Joey
 */

get_header();

// Get Latest Post
$latest_post_query = new WP_Query( array(
	'posts_per_page' => 1,
	'post_status' => 'publish',
) );

// Get Recent Posts (excluding latest)
$recent_posts_query = new WP_Query( array(
	'posts_per_page' => 3,
	'offset' => 1,
	'post_status' => 'publish',
) );

// Get Featured Workshops
$workshops_query = new WP_Query( array(
	'post_type' => 'workshop',
	'posts_per_page' => 2,
	'post_status' => 'publish',
) );

// Get Gallery Items
$gallery_query = new WP_Query( array(
	'post_type' => 'gallery_item',
	'posts_per_page' => 6,
	'post_status' => 'publish',
) );
?>

<div class="w-full">
	<!-- HERO SECTION -->
	<section class="relative min-h-[90vh] flex items-center justify-center overflow-hidden pt-10">
		<!-- Background Gradient -->
		<div class="absolute inset-0 bg-gradient-to-br from-background via-surface to-[#1a0b2e] z-0"></div>
		<!-- Decorative Grid -->
		<div class="absolute inset-0 bg-[linear-gradient(rgba(43,37,64,0.2)_1px,transparent_1px),linear-gradient(90deg,rgba(43,37,64,0.2)_1px,transparent_1px)] bg-[size:40px_40px] [mask-image:radial-gradient(ellipse_at_center,black,transparent)] z-0 pointer-events-none"></div>

		<div class="container mx-auto px-6 relative z-10 grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
			
			<!-- Left Content -->
			<div class="lg:col-span-7 flex flex-col gap-6">
				<div class="inline-flex items-center gap-2 text-accent font-mono text-xs uppercase tracking-[0.2em]">
					<span class="w-2 h-2 bg-accent rounded-full shadow-[0_0_10px_#00FFFF]"></span>
					Signal Online
				</div>
				
				<h1 class="text-5xl md:text-7xl font-display font-black leading-tight text-white drop-shadow-lg glitch-hover">
					WE ARE THE <br />
					<span class="text-transparent bg-clip-text bg-gradient-to-r from-primary to-accent relative inline-block">
						GLITCH
						<span class="absolute inset-0 blur-lg opacity-50 bg-gradient-to-r from-primary to-accent -z-10"></span>
					</span> 
					<br /> IN THE SYSTEM.
				</h1>
				
				<p class="text-lg md:text-xl text-muted max-w-xl leading-relaxed">
					A digital sanctuary for queer resilience, homelab mysticism, and creative survival. Welcome to the Cult.
				</p>

				<div class="flex flex-wrap gap-4 mt-4">
					<a href="<?php echo esc_url( get_permalink( get_option( 'page_for_posts' ) ) ?: home_url( '/' ) ); ?>" class="font-heading font-semibold text-lg px-8 py-3.5 bg-primary text-background rounded-full hover:bg-primarySoft hover:shadow-neon-primary transition-all duration-200 ease-out active:scale-95">
						Enter the Archive
					</a>
					<a href="<?php echo esc_url( get_permalink( get_page_by_path( 'workshops' ) ) ?: home_url( '/workshops' ) ); ?>" class="font-heading font-semibold text-lg px-8 py-3.5 bg-transparent text-accent border border-accent rounded-full hover:bg-accent/10 hover:shadow-neon-accent transition-all duration-200 ease-out active:scale-95">
						View Projects
					</a>
				</div>
			</div>

			<!-- Right Card: Now Broadcasting -->
			<?php if ( $latest_post_query->have_posts() ) : ?>
				<?php $latest_post_query->the_post(); ?>
				<div class="lg:col-span-5">
					<div class="relative group">
						<div class="absolute -inset-1 bg-gradient-to-r from-primary via-accent to-primary rounded-2xl blur opacity-20 group-hover:opacity-50 transition duration-1000"></div>
						<div class="relative bg-surfaceAlt border border-border p-6 rounded-2xl">
							<div class="flex items-center justify-between mb-4 border-b border-border pb-2">
								<span class="text-xs font-mono text-primary animate-pulse">● LIVE TRANSMISSION</span>
								<span class="text-xs text-muted font-mono"><?php echo esc_html( get_the_date( 'M j, Y' ) ); ?></span>
							</div>
							<h3 class="text-2xl font-display font-bold text-white mb-3 glitch-hover"><?php the_title(); ?></h3>
							<p class="text-muted mb-6 line-clamp-3"><?php echo esc_html( get_the_excerpt() ); ?></p>
							<a href="<?php the_permalink(); ?>" class="font-heading font-semibold text-sm px-3 py-1.5 bg-transparent border border-primarySoft/50 text-primarySoft rounded-md hover:border-primary hover:text-primary hover:shadow-neon-primary transition-all duration-200 ease-out active:scale-95 block text-center w-full">
								Read Full Transmission
							</a>
						</div>
					</div>
				</div>
				<?php wp_reset_postdata(); ?>
			<?php endif; ?>
		</div>
	</section>

	<!-- JOURNAL STRIP -->
	<?php if ( $recent_posts_query->have_posts() ) : ?>
		<section class="py-20 bg-background border-t border-border">
			<div class="container mx-auto px-6">
				<div class="flex justify-between items-end mb-12">
					<div>
						<h2 class="text-3xl md:text-4xl font-display font-bold text-white mb-2 glitch-hover">Recent Signals</h2>
						<p class="text-muted">Lore from the recovery arc.</p>
					</div>
					<a href="<?php echo esc_url( get_permalink( get_option( 'page_for_posts' ) ) ?: home_url( '/' ) ); ?>" class="hidden md:block text-accent hover:text-white transition-colors font-heading">View All →</a>
				</div>

				<div class="grid grid-cols-1 md:grid-cols-3 gap-6">
					<?php while ( $recent_posts_query->have_posts() ) : $recent_posts_query->the_post(); ?>
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
				
				<div class="mt-8 md:hidden text-center">
					<a href="<?php echo esc_url( get_permalink( get_option( 'page_for_posts' ) ) ?: home_url( '/' ) ); ?>" class="text-accent font-heading">View All Signals →</a>
				</div>
			</div>
		</section>
		<?php wp_reset_postdata(); ?>
	<?php endif; ?>

	<!-- WORKSHOP STRIP -->
	<?php if ( $workshops_query->have_posts() ) : ?>
		<section class="py-20 bg-surface relative overflow-hidden">
			<!-- Angled Background Accent -->
			<div class="absolute top-0 right-0 w-2/3 h-full bg-surfaceAlt/30 -skew-x-12 z-0 pointer-events-none"></div>

			<div class="container mx-auto px-6 relative z-10">
				<div class="flex flex-col md:flex-row gap-12 items-center">
					<div class="md:w-1/3">
						<h2 class="text-3xl md:text-4xl font-display font-bold text-white mb-6 glitch-hover">The Workshop</h2>
						<p class="text-muted mb-8 leading-relaxed">
							Where silicon meets skin. Explore the fabrication logs, from 42U server racks to EVA foam armor and geometric ink.
						</p>
						<a href="<?php echo esc_url( get_permalink( get_page_by_path( 'workshops' ) ) ?: home_url( '/workshops' ) ); ?>" class="font-heading font-semibold text-base px-6 py-2.5 bg-transparent border border-primarySoft/50 text-primarySoft rounded-md hover:border-primary hover:text-primary hover:shadow-neon-primary transition-all duration-200 ease-out active:scale-95 inline-block">
							Explore Projects
						</a>
					</div>
					<div class="md:w-2/3 grid grid-cols-1 md:grid-cols-2 gap-6">
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
				</div>
			</div>
		</section>
		<?php wp_reset_postdata(); ?>
	<?php endif; ?>

	<!-- GALLERY BAND -->
	<?php if ( $gallery_query->have_posts() ) : ?>
		<section class="py-12 bg-background">
			<div class="container mx-auto px-6 mb-6">
				<h2 class="text-2xl font-display font-bold text-white glitch-hover">Visual Database</h2>
			</div>
			<div class="grid grid-cols-2 md:grid-cols-6 h-48 md:h-64 w-full">
				<?php while ( $gallery_query->have_posts() ) : $gallery_query->the_post(); ?>
					<?php
					$gallery_cats = wp_get_post_terms( get_the_ID(), 'gallery_category' );
					$category = ! empty( $gallery_cats ) ? $gallery_cats[0]->name : '';
					?>
					<a href="<?php echo esc_url( get_permalink( get_page_by_path( 'gallery' ) ) ?: home_url( '/gallery' ) ); ?>" class="relative group overflow-hidden block h-full w-full">
						<?php if ( has_post_thumbnail() ) : ?>
							<?php the_post_thumbnail( 'medium', array( 'class' => 'w-full h-full object-cover transition-transform duration-500 group-hover:scale-110' ) ); ?>
							<div class="absolute inset-0 bg-primary/20 opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-center justify-center">
								<?php if ( $category ) : ?>
									<span class="text-white font-heading font-bold text-sm tracking-widest uppercase drop-shadow-md"><?php echo esc_html( $category ); ?></span>
								<?php endif; ?>
							</div>
						<?php endif; ?>
					</a>
				<?php endwhile; ?>
			</div>
		</section>
		<?php wp_reset_postdata(); ?>
	<?php endif; ?>
</div>

<?php
get_footer();

