/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        background: '#05040A',
        surface: '#0E0B1A',
        surfaceAlt: '#151027',
        primary: '#E600FF',
        primarySoft: '#FF7BFF',
        accent: '#00FFFF',
        accentSoft: '#66FFFF',
        warning: '#FFB347',
        danger: '#FF3366',
        text: '#F5F5FA',
        muted: '#9B92BB',
        border: '#2B2540',
        glow: '#7D3CFF',
      },
      fontFamily: {
        display: ['Orbitron', 'system-ui', 'sans-serif'],
        heading: ['Oxanium', 'system-ui', 'sans-serif'],
        body: ['Space Grotesk', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      fontSize: {
        xs: 'clamp(0.75rem, 0.7rem + 0.2vw, 0.8rem)',
        sm: 'clamp(0.85rem, 0.8rem + 0.3vw, 0.95rem)',
        md: 'clamp(1rem, 0.95rem + 0.3vw, 1.1rem)',
        lg: 'clamp(1.3rem, 1.1rem + 0.6vw, 1.6rem)',
        xl: 'clamp(1.6rem, 1.4rem + 0.8vw, 2rem)',
        '2xl': 'clamp(2.3rem, 2rem + 1.3vw, 3rem)',
        hero: 'clamp(2.8rem, 2.4rem + 2vw, 3.8rem)',
      },
      boxShadow: {
        'neon-primary': '0 0 12px rgba(230, 0, 255, 0.6), 0 0 22px rgba(0, 255, 255, 0.4)',
        'neon-accent': '0 0 12px rgba(0, 255, 255, 0.6)',
        'soft': '0 0 18px rgba(0, 0, 0, 0.7)',
      },
      transitionTimingFunction: {
        'cyberpunk': 'cubic-bezier(0.18, 0.89, 0.32, 1.28)',
      },
    },
  },
  plugins: [],
}

