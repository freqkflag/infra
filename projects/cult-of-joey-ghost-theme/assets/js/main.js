/**
 * Cult of Joey - Ghost Theme JavaScript
 */

(function() {
  'use strict';

  // Header scroll effect
  function initHeaderScroll() {
    const header = document.querySelector('.site-header');
    if (!header) return;

    let lastScroll = 0;
    window.addEventListener('scroll', () => {
      const currentScroll = window.pageYOffset;
      if (currentScroll > 20) {
        header.classList.add('scrolled');
      } else {
        header.classList.remove('scrolled');
      }
      lastScroll = currentScroll;
    });
  }

  // Lightbox functionality
  function initLightbox() {
    const galleryItems = document.querySelectorAll('.gallery-item');
    const lightbox = document.getElementById('lightbox');
    const lightboxImage = document.getElementById('lightbox-image');
    const lightboxCaption = document.getElementById('lightbox-caption');
    const lightboxTitle = document.getElementById('lightbox-title');
    const lightboxCategory = document.getElementById('lightbox-category');
    const lightboxClose = document.getElementById('lightbox-close');

    if (!lightbox) return;

    galleryItems.forEach(item => {
      item.addEventListener('click', (e) => {
        e.preventDefault();
        const img = item.querySelector('img');
        const title = item.dataset.title || item.querySelector('.gallery-item-title')?.textContent || '';
        const category = item.dataset.category || item.querySelector('.gallery-item-category')?.textContent || '';

        if (img) {
          lightboxImage.src = img.src;
          lightboxImage.alt = img.alt || title;
          if (lightboxTitle) lightboxTitle.textContent = title;
          if (lightboxCategory) lightboxCategory.textContent = category;
          lightbox.classList.add('active');
          document.body.style.overflow = 'hidden';
        }
      });
    });

    function closeLightbox() {
      lightbox.classList.remove('active');
      document.body.style.overflow = '';
    }

    if (lightboxClose) {
      lightboxClose.addEventListener('click', closeLightbox);
    }

    lightbox.addEventListener('click', (e) => {
      if (e.target === lightbox) {
        closeLightbox();
      }
    });

    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && lightbox.classList.contains('active')) {
        closeLightbox();
      }
    });
  }

  // Filter functionality
  function initFilters() {
    const filterChips = document.querySelectorAll('.chip[data-filter]');
    if (filterChips.length === 0) return;

    filterChips.forEach(chip => {
      chip.addEventListener('click', () => {
        const filterValue = chip.dataset.filter;
        
        // Update active state
        filterChips.forEach(c => c.classList.remove('chip-active'));
        chip.classList.add('chip-active');

        // Filter posts
        const posts = document.querySelectorAll('.post-card, .workshop-card');
        posts.forEach(post => {
          const postMood = post.dataset.mood;
          const postCategory = post.dataset.category;
          
          if (filterValue === 'all') {
            post.style.display = '';
          } else if (postMood === filterValue || postCategory === filterValue) {
            post.style.display = '';
          } else {
            post.style.display = 'none';
          }
        });
      });
    });
  }

  // Mobile menu toggle
  function initMobileMenu() {
    const menuToggle = document.getElementById('mobile-menu-toggle');
    const mobileMenu = document.getElementById('mobile-menu');
    
    if (!menuToggle || !mobileMenu) return;

    menuToggle.addEventListener('click', () => {
      mobileMenu.classList.toggle('active');
      menuToggle.classList.toggle('active');
    });

    // Close on link click
    const mobileLinks = mobileMenu.querySelectorAll('a');
    mobileLinks.forEach(link => {
      link.addEventListener('click', () => {
        mobileMenu.classList.remove('active');
        menuToggle.classList.remove('active');
      });
    });
  }

  // Smooth scroll for anchor links
  function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', function (e) {
        const href = this.getAttribute('href');
        if (href === '#') return;
        
        e.preventDefault();
        const target = document.querySelector(href);
        if (target) {
          target.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
          });
        }
      });
    });
  }

  // Initialize everything when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  function init() {
    initHeaderScroll();
    initLightbox();
    initFilters();
    initMobileMenu();
    initSmoothScroll();
  }

})();

