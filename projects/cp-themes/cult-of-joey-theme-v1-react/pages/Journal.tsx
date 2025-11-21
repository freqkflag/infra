import React, { useState } from 'react';
import { POSTS } from '../services/data';
import Card from '../components/Card';
import Chip from '../components/Chip';
import { Mood } from '../types';

const Journal: React.FC = () => {
  const [activeFilter, setActiveFilter] = useState<Mood | 'all'>('all');

  const filters: Mood[] = ['calm', 'manic', 'reflective', 'defiant'];

  const filteredPosts = activeFilter === 'all' 
    ? POSTS 
    : POSTS.filter(p => p.mood === activeFilter);

  return (
    <div className="container mx-auto px-6 py-12 min-h-screen">
      <div className="max-w-3xl mb-12">
        <h1 className="text-4xl md:text-6xl font-display font-black text-white mb-6 glitch-hover">The Book of Joey</h1>
        <p className="text-xl text-muted leading-relaxed">
          A raw, unencrypted log of mental states, technical breakthroughs, and the quiet moments in between. 
          Filter by the emotional frequency of the transmission.
        </p>
      </div>

      {/* Filter Bar: Mood Chips Pattern */}
      <div className="mb-12">
        <div className="flex flex-wrap items-center gap-3 pb-6 border-b border-border/30">
          <span className="text-xs font-mono text-muted uppercase tracking-widest mr-2">Filter Frequency:</span>
          
          {/* 'All' Filter acting as a base chip */}
          <Chip 
            label="All Signals"
            variant="default"
            isActive={activeFilter === 'all'}
            onClick={() => setActiveFilter('all')}
          />

          {/* Mood Chips */}
          {filters.map(mood => (
            <Chip 
              key={mood}
              label={mood} 
              variant="mood" 
              mood={mood}
              isActive={activeFilter === mood}
              onClick={() => setActiveFilter(mood)}
            />
          ))}
        </div>
      </div>

      {/* Grid */}
      <div 
        key={activeFilter} 
        className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 animate-fade-in"
      >
        {filteredPosts.map(post => (
          <Card key={post.id} type="journal" data={post} />
        ))}
      </div>

      {filteredPosts.length === 0 && (
        <div className="text-center py-20 border border-dashed border-border rounded-xl bg-surface/50">
          <p className="text-muted font-mono mb-2">No signals found on this frequency.</p>
          <button 
            onClick={() => setActiveFilter('all')}
            className="text-accent text-sm hover:underline"
          >
            Reset Filters
          </button>
        </div>
      )}
    </div>
  );
};

export default Journal;