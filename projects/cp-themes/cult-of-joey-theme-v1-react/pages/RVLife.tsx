import React from 'react';
import { TIMELINE_EVENTS } from '../services/data';

const RVLife: React.FC = () => {
  return (
    <div className="min-h-screen py-12">
      <div className="container mx-auto px-6 mb-16 text-center">
         <div className="inline-block p-2 rounded-full border border-accent/30 bg-accent/5 mb-4">
            <svg className="w-6 h-6 text-accent" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" /><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" /></svg>
         </div>
        <h1 className="text-4xl md:text-6xl font-display font-black text-white mb-6 glitch-hover">Nomad Logs</h1>
        <p className="text-xl text-muted max-w-2xl mx-auto">
          Leaving the static grid for a life on wheels. 
          Chasing reliable 5G signals and solitude across the North American continent.
        </p>
      </div>

      <div className="container mx-auto px-6 max-w-4xl relative">
        {/* Center Line */}
        <div className="absolute left-6 md:left-1/2 top-0 bottom-0 w-0.5 bg-gradient-to-b from-primary via-accent to-background md:-ml-[1px]"></div>

        {TIMELINE_EVENTS.map((event, index) => {
           const isEven = index % 2 === 0;
           return (
             <div key={event.id} className={`relative flex flex-col md:flex-row gap-8 mb-12 md:mb-24 ${isEven ? 'md:flex-row-reverse' : ''}`}>
               
               {/* Spacer for opposite side */}
               <div className="hidden md:block flex-1"></div>

               {/* Dot */}
               <div className="absolute left-6 md:left-1/2 w-4 h-4 rounded-full bg-background border-2 border-accent shadow-[0_0_10px_#00FFFF] -translate-x-1/2 mt-6 z-10"></div>

               {/* Content */}
               <div className="flex-1 pl-12 md:pl-0">
                 <div className={`bg-surface border border-border p-6 rounded-xl relative hover:border-primary/50 transition-all duration-300 group ${isEven ? 'md:mr-8' : 'md:ml-8'}`}>
                    {/* Arrow */}
                    <div className={`hidden md:block absolute top-8 w-4 h-4 bg-surface border-l border-b border-border transform rotate-45 group-hover:border-primary/50 transition-colors ${isEven ? '-right-2.5 border-r-0 border-t-0' : '-left-2.5 border-r border-t border-l-0 border-b-0'}`}></div>
                    
                    <span className="text-xs font-mono text-accent mb-2 block">{event.date}</span>
                    <h3 className="text-xl font-heading font-bold text-white mb-2 glitch-hover">{event.title}</h3>
                    <p className="text-muted text-sm mb-4">{event.description}</p>
                    <div className="flex items-center gap-1 text-xs text-muted/70">
                      <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" /></svg>
                      {event.location}
                    </div>
                 </div>
               </div>

             </div>
           );
        })}
      </div>

      {/* Map Placeholder */}
      <div className="container mx-auto px-6 py-12 mt-12 border-t border-border">
        <div className="bg-surfaceAlt rounded-xl border border-border h-64 flex items-center justify-center relative overflow-hidden group">
           <div className="absolute inset-0 opacity-20 bg-[url('https://upload.wikimedia.org/wikipedia/commons/e/ec/World_map_blank_without_borders.svg')] bg-cover bg-center"></div>
           <div className="relative z-10 text-center">
             <h3 className="text-2xl font-display font-bold text-white mb-2 glitch-hover">Current Location</h3>
             <p className="text-accent font-mono animate-pulse">Scanning Coordinates...</p>
           </div>
           <div className="absolute inset-0 border-2 border-transparent group-hover:border-primary/30 rounded-xl transition-colors pointer-events-none"></div>
        </div>
      </div>
    </div>
  );
};

export default RVLife;