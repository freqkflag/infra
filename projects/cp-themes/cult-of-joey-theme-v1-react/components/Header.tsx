import React, { useState, useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';
import Button from './Button';

const Header: React.FC = () => {
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const location = useLocation();

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 20);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const navLinks = [
    { name: 'Journal', path: '/journal' },
    { name: 'Workshops', path: '/workshops' },
    { name: 'Gallery', path: '/gallery' },
    { name: 'RV Life', path: '/rv-life' },
  ];

  const isActive = (path: string) => location.pathname === path;

  return (
    <header 
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 border-b ${
        scrolled ? 'bg-background/80 backdrop-blur-md py-3 border-border/50' : 'bg-transparent py-5 border-transparent'
      }`}
    >
      <div className="container mx-auto px-6 flex justify-between items-center">
        <Link to="/" className="font-display font-black text-2xl tracking-tighter text-white group relative">
          <span className="group-hover:text-primary transition-colors">CULT</span>
          <span className="text-primary group-hover:text-white transition-colors">OF</span>
          <span className="group-hover:text-accent transition-colors">JOEY</span>
          <span className="absolute -bottom-1 left-0 w-0 h-0.5 bg-accent group-hover:w-full transition-all duration-300"></span>
        </Link>

        {/* Desktop Nav */}
        <nav className="hidden md:flex items-center gap-8">
          {navLinks.map((link) => (
            <Link 
              key={link.name} 
              to={link.path}
              className={`font-heading font-medium text-sm uppercase tracking-wide relative transition-colors hover:text-accent ${
                isActive(link.path) ? 'text-accent' : 'text-muted'
              }`}
            >
              {link.name}
              {isActive(link.path) && (
                <span className="absolute -bottom-1 left-0 right-0 h-[2px] bg-accent shadow-[0_0_8px_#00FFFF]"></span>
              )}
            </Link>
          ))}
          <Link to="/contact">
            <Button variant="primary" size="sm">Summon Me</Button>
          </Link>
        </nav>

        {/* Mobile Toggle */}
        <button 
          className="md:hidden text-white focus:outline-none"
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
        >
          <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            {mobileMenuOpen ? (
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            ) : (
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            )}
          </svg>
        </button>
      </div>

      {/* Mobile Menu */}
      {mobileMenuOpen && (
        <div className="md:hidden absolute top-full left-0 w-full bg-surface border-b border-border p-6 flex flex-col gap-4 shadow-2xl">
          {navLinks.map((link) => (
            <Link 
              key={link.name} 
              to={link.path}
              className="font-heading text-lg text-muted hover:text-primary"
              onClick={() => setMobileMenuOpen(false)}
            >
              {link.name}
            </Link>
          ))}
          <Link to="/contact" onClick={() => setMobileMenuOpen(false)}>
            <Button variant="primary" className="w-full">Summon Me</Button>
          </Link>
        </div>
      )}
    </header>
  );
};

export default Header;