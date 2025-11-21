/**
 * Theme Customizer Live Preview
 */
(function( $ ) {
	'use strict';

	// Color settings with live preview
	var colorSettings = [
		'primary_color',
		'primary_soft_color',
		'accent_color',
		'accent_soft_color',
		'background_color',
		'surface_color',
		'surface_alt_color',
		'text_color',
		'muted_color',
		'border_color',
		'warning_color',
		'danger_color'
	];

	// Update Tailwind config when colors change
	wp.customize.bind( 'ready', function() {
		colorSettings.forEach( function( setting ) {
			wp.customize( setting, function( value ) {
				value.bind( function( newval ) {
					// Trigger page reload for color changes
					// Tailwind config needs to be regenerated
					setTimeout( function() {
						location.reload();
					}, 100 );
				} );
			} );
		} );
	} );

	// Update contact email in real-time
	wp.customize( 'contact_email', function( value ) {
		value.bind( function( newval ) {
			$( '.cult-of-joey-contact-email' ).text( newval );
		} );
	} );

	// Update social links in real-time
	wp.customize( 'mastodon_url', function( value ) {
		value.bind( function( newval ) {
			$( '.cult-of-joey-mastodon' ).attr( 'href', newval || '#' );
		} );
	} );

	wp.customize( 'github_url', function( value ) {
		value.bind( function( newval ) {
			$( '.cult-of-joey-github' ).attr( 'href', newval || '#' );
		} );
	} );

	wp.customize( 'instagram_url', function( value ) {
		value.bind( function( newval ) {
			$( '.cult-of-joey-instagram' ).attr( 'href', newval || '#' );
		} );
	} );

})( jQuery );

