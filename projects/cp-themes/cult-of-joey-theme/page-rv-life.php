<?php
/**
 * Template Name: RV Life
 * The template for displaying the RV Life timeline page
 *
 * @package Cult_Of_Joey
 */

get_header();

$timeline_query = new WP_Query( array(
	'post_type' => 'timeline_event',
	'posts_per_page' => -1,
	'post_status' => 'publish',
	'meta_key' => '_timeline_event_date',
	'orderby' => 'meta_value',
	'order' => 'DESC',
) );
?>

<div class="min-h-screen py-12">
	<div class="container mx-auto px-6 mb-16 text-center">
		<div class="inline-block p-2 rounded-full border border-accent/30 bg-accent/5 mb-4">
			<svg class="w-6 h-6 text-accent" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
			</svg>
		</div>
		<h1 class="text-4xl md:text-6xl font-display font-black text-white mb-6 glitch-hover">Nomad Logs</h1>
		<p class="text-xl text-muted max-w-2xl mx-auto">
			Leaving the static grid for a life on wheels. 
			Chasing reliable 5G signals and solitude across the North American continent.
		</p>
	</div>

	<?php if ( $timeline_query->have_posts() ) : ?>
		<div class="container mx-auto px-6 max-w-4xl relative">
			<!-- Center Line -->
			<div class="absolute left-6 md:left-1/2 top-0 bottom-0 w-0.5 bg-gradient-to-b from-primary via-accent to-background md:-ml-[1px]"></div>

			<?php
			$index = 0;
			while ( $timeline_query->have_posts() ) :
				$timeline_query->the_post();
				$is_even = $index % 2 === 0;
				$event_date = get_post_meta( get_the_ID(), '_timeline_event_date', true );
				$location = get_post_meta( get_the_ID(), '_timeline_location', true );
				$index++;
				?>
				<div class="relative flex flex-col md:flex-row gap-8 mb-12 md:mb-24 <?php echo $is_even ? 'md:flex-row-reverse' : ''; ?>">
					
					<!-- Spacer for opposite side -->
					<div class="hidden md:block flex-1"></div>

					<!-- Dot -->
					<div class="absolute left-6 md:left-1/2 w-4 h-4 rounded-full bg-background border-2 border-accent shadow-[0_0_10px_#00FFFF] -translate-x-1/2 mt-6 z-10"></div>

					<!-- Content -->
					<div class="flex-1 pl-12 md:pl-0">
						<div class="bg-surface border border-border p-6 rounded-xl relative hover:border-primary/50 transition-all duration-300 group <?php echo $is_even ? 'md:mr-8' : 'md:ml-8'; ?>">
							<!-- Arrow -->
							<div class="hidden md:block absolute top-8 w-4 h-4 bg-surface border-l border-b border-border transform rotate-45 group-hover:border-primary/50 transition-colors <?php echo $is_even ? '-right-2.5 border-r-0 border-t-0' : '-left-2.5 border-r border-t border-l-0 border-b-0'; ?>"></div>
							
							<?php if ( $event_date ) : ?>
								<span class="text-xs font-mono text-accent mb-2 block"><?php echo esc_html( $event_date ); ?></span>
							<?php endif; ?>
							<h3 class="text-xl font-heading font-bold text-white mb-2 glitch-hover"><?php the_title(); ?></h3>
							<p class="text-muted text-sm mb-4"><?php the_content(); ?></p>
							<?php if ( $location ) : ?>
								<div class="flex items-center gap-1 text-xs text-muted/70">
									<svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
									</svg>
									<?php echo esc_html( $location ); ?>
								</div>
							<?php endif; ?>
						</div>
					</div>
				</div>
			<?php endwhile; ?>
		</div>
	<?php endif; ?>

	<?php wp_reset_postdata(); ?>

	<!-- Map Placeholder -->
	<div class="container mx-auto px-6 py-12 mt-12 border-t border-border">
		<div class="bg-surfaceAlt rounded-xl border border-border h-64 flex items-center justify-center relative overflow-hidden group">
			<div class="absolute inset-0 opacity-20 bg-[url('https://upload.wikimedia.org/wikipedia/commons/e/ec/World_map_blank_without_borders.svg')] bg-cover bg-center"></div>
			<div class="relative z-10 text-center">
				<h3 class="text-2xl font-display font-bold text-white mb-2 glitch-hover">Current Location</h3>
				<p class="text-accent font-mono animate-pulse">Scanning Coordinates...</p>
			</div>
			<div class="absolute inset-0 border-2 border-transparent group-hover:border-primary/30 rounded-xl transition-colors pointer-events-none"></div>
		</div>
	</div>
</div>

<?php
get_footer();

