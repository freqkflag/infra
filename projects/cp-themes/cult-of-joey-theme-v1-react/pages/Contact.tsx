import React from 'react';
import Button from '../components/Button';

const Contact: React.FC = () => {
  return (
    <div className="min-h-screen py-12 flex items-center">
      <div className="container mx-auto px-6">
        <div className="max-w-4xl mx-auto bg-surface border border-border rounded-2xl overflow-hidden shadow-2xl relative">
          
          {/* Decorative gradient top */}
          <div className="h-2 w-full bg-gradient-to-r from-primary via-accent to-primary"></div>

          <div className="p-8 md:p-12 grid grid-cols-1 md:grid-cols-2 gap-12">
            <div>
              <h1 className="text-4xl md:text-5xl font-display font-black text-white mb-6 glitch-hover">
                SUMMON <span className="text-primary">ME</span>
              </h1>
              <p className="text-muted mb-8 leading-relaxed">
                Open for collaborations on:
                <ul className="list-disc list-inside mt-4 space-y-2 marker:text-accent">
                  <li>Creative Coding / Web Dev</li>
                  <li>Cosplay fabrication advice</li>
                  <li>Homelab architecture</li>
                  <li>Speaking on mental health & tech</li>
                </ul>
              </p>
              
              <div className="mt-auto pt-8 border-t border-border">
                <p className="text-xs text-muted/60 mb-2">SECURE CHANNEL:</p>
                <p className="font-mono text-accent text-lg">joey@cultofjoey.com</p>
              </div>
            </div>

            <form className="flex flex-col gap-6" onSubmit={(e) => e.preventDefault()}>
              <div>
                <label htmlFor="name" className="block text-sm font-heading font-bold text-muted mb-2">Identity</label>
                <input 
                  type="text" 
                  id="name" 
                  className="w-full bg-surfaceAlt border border-border rounded-md px-4 py-3 text-white focus:outline-none focus:border-accent focus:ring-1 focus:ring-accent transition-all"
                  placeholder="Callsign or Name"
                />
              </div>
              
              <div>
                <label htmlFor="email" className="block text-sm font-heading font-bold text-muted mb-2">Frequency</label>
                <input 
                  type="email" 
                  id="email" 
                  className="w-full bg-surfaceAlt border border-border rounded-md px-4 py-3 text-white focus:outline-none focus:border-accent focus:ring-1 focus:ring-accent transition-all"
                  placeholder="email@domain.com"
                />
              </div>

              <div>
                <label htmlFor="message" className="block text-sm font-heading font-bold text-muted mb-2">Transmission</label>
                <textarea 
                  id="message" 
                  rows={4}
                  className="w-full bg-surfaceAlt border border-border rounded-md px-4 py-3 text-white focus:outline-none focus:border-accent focus:ring-1 focus:ring-accent transition-all"
                  placeholder="Message content..."
                ></textarea>
              </div>

              <Button variant="primary" size="lg" className="w-full mt-2">
                Send Transmission
              </Button>

              <p className="text-[10px] text-muted text-center mt-2 opacity-60">
                * This form sends a signal to the void (mockup). In reality, check your console.
              </p>
            </form>
          </div>
        </div>

        <div className="max-w-2xl mx-auto mt-12 text-center">
           <div className="bg-surfaceAlt/50 border border-warning/20 rounded-lg p-4">
             <p className="text-sm text-muted">
               <strong className="text-warning block mb-1">SAFETY NOTICE</strong>
               This site discusses mental health themes including recovery and survival. 
               If you are in crisis, please do not use this form. <a href="#" className="text-accent underline">Click here for immediate resources.</a>
             </p>
           </div>
        </div>
      </div>
    </div>
  );
};

export default Contact;