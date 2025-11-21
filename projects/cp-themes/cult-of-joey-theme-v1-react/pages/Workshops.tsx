import React, { useState } from 'react';
import { WORKSHOPS } from '../services/data';
import Card from '../components/Card';
import { Category } from '../types';

const Workshops: React.FC = () => {
  const [filter, setFilter] = useState<Category | 'All'>('All');
  
  const categories: Category[] = ['Cosplay', 'Tech', 'Tattoo', 'DIY'];

  const filtered = filter === 'All' ? WORKSHOPS : WORKSHOPS.filter(w => w.category === filter);

  return (
    <div className="min-h-screen bg-background py-12">
      <div className="container mx-auto px-6">
        <div className="flex flex-col md:flex-row justify-between items-end mb-12 gap-6">
          <div>
            <h1 className="text-4xl md:text-6xl font-display font-black text-white mb-4 glitch-hover">The Workshop</h1>
            <p className="text-muted max-w-xl">
              Documentation of physical and digital fabrication. 
              Building armor to survive the world, and servers to host the new one.
            </p>
          </div>
          
          {/* Filters */}
          <div className="flex flex-wrap gap-2">
            <button 
              onClick={() => setFilter('All')}
              className={`px-4 py-2 rounded-md text-sm font-mono border transition-all ${filter === 'All' ? 'border-accent text-accent bg-accent/10' : 'border-border text-muted hover:border-white hover:text-white'}`}
            >
              ALL
            </button>
            {categories.map(cat => (
               <button 
               key={cat}
               onClick={() => setFilter(cat)}
               className={`px-4 py-2 rounded-md text-sm font-mono border transition-all ${filter === cat ? 'border-accent text-accent bg-accent/10' : 'border-border text-muted hover:border-white hover:text-white'}`}
             >
               {cat.toUpperCase()}
             </button>
            ))}
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {filtered.map(project => (
            <Card key={project.id} type="workshop" data={project} />
          ))}
        </div>
      </div>
    </div>
  );
};

export default Workshops;