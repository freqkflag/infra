import React from 'react';
import { Link } from 'react-router-dom';

const Footer: React.FC = () => {
  return (
    <footer className="bg-background border-t border-border mt-auto relative overflow-hidden">
      {/* Top Glow Line */}
      <div className="absolute top-0 left-0 w-full h-[1px] bg-gradient-to-r from-transparent via-primary/30 to-transparent"></div>

      <div className="container mx-auto px-6 py-12">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-12">
          <div>
            <h3 className="font-display font-bold text-xl text-white mb-4 glitch-hover">CULT OF JOEY</h3>
            <p className="text-muted text-sm max-w-xs">
              Broadcasting from the intersection of mental health recovery, queer identity, and high-voltage electronics.
            </p>
          </div>
          
          <div className="flex flex-col gap-2">
            <h4 className="font-heading font-bold text-white mb-2">Navigation</h4>
            <Link to="/journal" className="text-muted hover:text-accent text-sm transition-colors w-fit">Journal</Link>
            <Link to="/workshops" className="text-muted hover:text-accent text-sm transition-colors w-fit">Workshops</Link>
            <Link to="/gallery" className="text-muted hover:text-accent text-sm transition-colors w-fit">Gallery</Link>
            <Link to="/rv-life" className="text-muted hover:text-accent text-sm transition-colors w-fit">RV Life</Link>
          </div>

          <div className="flex flex-col gap-2">
            <h4 className="font-heading font-bold text-white mb-2">Connect</h4>
            <a href="#" className="text-muted hover:text-primary text-sm transition-colors w-fit">Mastodon</a>
            <a href="#" className="text-muted hover:text-primary text-sm transition-colors w-fit">GitHub</a>
            <a href="#" className="text-muted hover:text-primary text-sm transition-colors w-fit">Instagram</a>
          </div>
        </div>

        <div className="border-t border-border/50 pt-8 flex flex-col md:flex-row justify-between items-center gap-4">
          <p className="text-xs text-muted/50 font-mono">
            © {new Date().getFullYear()} Cult of Joey. Built with silicon and anxiety.
          </p>
          
          <div className="bg-surfaceAlt px-4 py-2 rounded-md border border-primary/20 flex items-center gap-3">
            <div className="w-2 h-2 bg-warning rounded-full animate-pulse"></div>
            <span className="text-xs text-muted">
              Need immediate help? <a href="#" className="text-accent hover:underline">Peer Support Resources</a>
            </span>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;