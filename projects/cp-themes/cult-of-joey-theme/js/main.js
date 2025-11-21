/**
 * Cult of Joey Theme JavaScript
 * Handles sticky header, mobile menu, lightbox, and interactive features
 */

(function() {
	'use strict';

	// Wait for DOM to be ready
	if (document.readyState === 'loading') {
		document.addEventListener('DOMContentLoaded', init);
	} else {
		init();
	}

	function init() {
		setupStickyHeader();
		setupMobileMenu();
		setupGalleryLightbox();
		setupContactForm();
	}

	/**
	 * Sticky Header Scroll Effect
	 */
	function setupStickyHeader() {
		const header = document.getElementById('masthead');
		if (!header) return;

		let scrolled = false;

		function handleScroll() {
			const shouldBeScrolled = window.scrollY > 20;
			
			if (shouldBeScrolled !== scrolled) {
				scrolled = shouldBeScrolled;
				
				if (scrolled) {
					header.classList.remove('bg-transparent', 'py-5', 'border-transparent');
					header.classList.add('bg-background/80', 'backdrop-blur-md', 'py-3', 'border-border/50');
				} else {
					header.classList.remove('bg-background/80', 'backdrop-blur-md', 'py-3', 'border-border/50');
					header.classList.add('bg-transparent', 'py-5', 'border-transparent');
				}
			}
		}

		window.addEventListener('scroll', handleScroll, { passive: true });
		handleScroll(); // Check initial state
	}

	/**
	 * Mobile Menu Toggle
	 */
	function setupMobileMenu() {
		const toggle = document.getElementById('mobile-menu-toggle');
		const menu = document.getElementById('mobile-menu');
		
		if (!toggle || !menu) return;

		toggle.addEventListener('click', function() {
			const isExpanded = toggle.getAttribute('aria-expanded') === 'true';
			
			// Toggle menu visibility
			if (isExpanded) {
				menu.classList.add('hidden');
				toggle.setAttribute('aria-expanded', 'false');
			} else {
				menu.classList.remove('hidden');
				toggle.setAttribute('aria-expanded', 'true');
			}

			// Update icon
			const svg = toggle.querySelector('svg');
			if (svg) {
				if (isExpanded) {
					// Show hamburger
					svg.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />';
				} else {
					// Show X
					svg.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />';
				}
			}
		});

		// Close menu when clicking outside
		document.addEventListener('click', function(e) {
			if (!toggle.contains(e.target) && !menu.contains(e.target)) {
				menu.classList.add('hidden');
				toggle.setAttribute('aria-expanded', 'false');
				const svg = toggle.querySelector('svg');
				if (svg) {
					svg.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />';
				}
			}
		});

		// Close menu when clicking menu links
		const menuLinks = menu.querySelectorAll('a');
		menuLinks.forEach(function(link) {
			link.addEventListener('click', function() {
				menu.classList.add('hidden');
				toggle.setAttribute('aria-expanded', 'false');
				const svg = toggle.querySelector('svg');
				if (svg) {
					svg.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />';
				}
			});
		});
	}

	/**
	 * Gallery Lightbox
	 */
	function setupGalleryLightbox() {
		const galleryItems = document.querySelectorAll('.gallery-item');
		const lightbox = document.getElementById('gallery-lightbox');
		const lightboxImage = document.getElementById('lightbox-image');
		const lightboxTitle = document.getElementById('lightbox-title');
		const lightboxCategory = document.getElementById('lightbox-category');
		const lightboxClose = document.getElementById('lightbox-close');

		if (!lightbox || !lightboxImage || !lightboxTitle || !lightboxCategory) return;

		// Open lightbox
		galleryItems.forEach(function(item) {
			item.addEventListener('click', function() {
				const imageUrl = item.getAttribute('data-image-url');
				const title = item.getAttribute('data-title');
				const category = item.getAttribute('data-category');

				if (imageUrl) {
					lightboxImage.src = imageUrl;
					lightboxImage.alt = title || '';
					lightboxTitle.textContent = title || '';
					lightboxCategory.textContent = category || '';
					lightbox.classList.remove('hidden');
					document.body.style.overflow = 'hidden'; // Prevent background scrolling
				}
			});
		});

		// Close lightbox
		function closeLightbox() {
			lightbox.classList.add('hidden');
			document.body.style.overflow = ''; // Restore scrolling
		}

		if (lightboxClose) {
			lightboxClose.addEventListener('click', closeLightbox);
		}

		// Close on background click
		lightbox.addEventListener('click', function(e) {
			if (e.target === lightbox) {
				closeLightbox();
			}
		});

		// Close on Escape key
		document.addEventListener('keydown', function(e) {
			if (e.key === 'Escape' && !lightbox.classList.contains('hidden')) {
				closeLightbox();
			}
		});
	}

	/**
	 * Contact Form Handling
	 */
	function setupContactForm() {
		const form = document.querySelector('.cult-of-joey-contact-form');
		if (!form) return;

		form.addEventListener('submit', function(e) {
			e.preventDefault();

			// Get form data
			const formData = new FormData(form);
			const name = formData.get('name');
			const email = formData.get('email');
			const message = formData.get('message');

			// Basic validation
			if (!name || !email || !message) {
				alert('Please fill in all fields.');
				return;
			}

			// Email validation
			const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
			if (!emailRegex.test(email)) {
				alert('Please enter a valid email address.');
				return;
			}

			// Log to console (for development)
			console.log('Form submission:', {
				name: name,
				email: email,
				message: message
			});

			// TODO: Integrate with ClassicPress contact form plugin or AJAX handler
			// For now, show a placeholder message
			alert('Form submitted! (This is a placeholder - integrate with your contact form plugin.)');

			// Reset form
			form.reset();
		});
	}

	/**
	 * Smooth scroll to top on route change (for hash routing)
	 */
	window.addEventListener('hashchange', function() {
		window.scrollTo(0, 0);
	});

})();

