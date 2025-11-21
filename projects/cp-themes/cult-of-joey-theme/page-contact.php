<?php
/**
 * Template Name: Contact
 * The template for displaying the Contact page
 *
 * @package Cult_Of_Joey
 */

get_header();
?>

<div class="min-h-screen py-12 flex items-center">
	<div class="container mx-auto px-6">
		<div class="max-w-4xl mx-auto bg-surface border border-border rounded-2xl overflow-hidden shadow-2xl relative">
			
			<!-- Decorative gradient top -->
			<div class="h-2 w-full bg-gradient-to-r from-primary via-accent to-primary"></div>

			<div class="p-8 md:p-12 grid grid-cols-1 md:grid-cols-2 gap-12">
				<div>
					<h1 class="text-4xl md:text-5xl font-display font-black text-white mb-6 glitch-hover">
						SUMMON <span class="text-primary">ME</span>
					</h1>
					<p class="text-muted mb-8 leading-relaxed">
						Open for collaborations on:
						<ul class="list-disc list-inside mt-4 space-y-2 marker:text-accent">
							<li>Creative Coding / Web Dev</li>
							<li>Cosplay fabrication advice</li>
							<li>Homelab architecture</li>
							<li>Speaking on mental health & tech</li>
						</ul>
					</p>
					
					<div class="mt-auto pt-8 border-t border-border">
						<p class="text-xs text-muted/60 mb-2">SECURE CHANNEL:</p>
						<p class="font-mono text-accent text-lg cult-of-joey-contact-email">
							<?php echo esc_html( get_theme_mod( 'contact_email', 'joey@cultofjoey.com' ) ); ?>
						</p>
					</div>
				</div>

				<form class="cult-of-joey-contact-form flex flex-col gap-6" action="#" method="post">
					<div>
						<label for="contact-name" class="block text-sm font-heading font-bold text-muted mb-2">Identity</label>
						<input 
							type="text" 
							id="contact-name"
							name="name"
							class="w-full bg-surfaceAlt border border-border rounded-md px-4 py-3 text-white focus:outline-none focus:border-accent focus:ring-1 focus:ring-accent transition-all"
							placeholder="Callsign or Name"
							required
						/>
					</div>
					
					<div>
						<label for="contact-email" class="block text-sm font-heading font-bold text-muted mb-2">Frequency</label>
						<input 
							type="email" 
							id="contact-email"
							name="email"
							class="w-full bg-surfaceAlt border border-border rounded-md px-4 py-3 text-white focus:outline-none focus:border-accent focus:ring-1 focus:ring-accent transition-all"
							placeholder="email@domain.com"
							required
						/>
					</div>

					<div>
						<label for="contact-message" class="block text-sm font-heading font-bold text-muted mb-2">Transmission</label>
						<textarea 
							id="contact-message"
							name="message"
							rows="4"
							class="w-full bg-surfaceAlt border border-border rounded-md px-4 py-3 text-white focus:outline-none focus:border-accent focus:ring-1 focus:ring-accent transition-all"
							placeholder="Message content..."
							required
						></textarea>
					</div>

					<button type="submit" class="font-heading font-semibold text-lg px-8 py-3.5 bg-primary text-background rounded-full hover:bg-primarySoft hover:shadow-neon-primary transition-all duration-200 ease-out active:scale-95 w-full mt-2">
						Send Transmission
					</button>

					<p class="text-[10px] text-muted text-center mt-2 opacity-60">
						* This form sends a signal to the void (mockup). In reality, integrate with your contact form plugin.
					</p>
				</form>
			</div>
		</div>

		<div class="max-w-2xl mx-auto mt-12 text-center">
			<div class="bg-surfaceAlt/50 border border-warning/20 rounded-lg p-4">
				<p class="text-sm text-muted">
					<strong class="text-warning block mb-1">SAFETY NOTICE</strong>
					This site discusses mental health themes including recovery and survival. 
					If you are in crisis, please do not use this form. <a href="#" class="text-accent underline">Click here for immediate resources.</a>
				</p>
			</div>
		</div>
	</div>
</div>

<?php
get_footer();

