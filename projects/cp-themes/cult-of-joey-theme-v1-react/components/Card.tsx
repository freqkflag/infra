import React from 'react';
import { Link } from 'react-router-dom';
import { Post, WorkshopProject } from '../types';
import Chip from './Chip';

interface CardProps {
  type: 'journal' | 'workshop';
  data: Post | WorkshopProject;
  className?: string;
}

const Card: React.FC<CardProps> = ({ type, data, className = '' }) => {
  if (type === 'journal') {
    const post = data as Post;
    return (
      <Link to={`/journal/${post.slug}`} className={`block group h-full ${className}`}>
        <article className="bg-surface h-full border border-border rounded-xl overflow-hidden transition-all duration-300 group-hover:-translate-y-1 group-hover:border-primary/40 group-hover:shadow-soft relative">
           {/* Top accent line */}
          <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-transparent via-primary to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
          
          <div className="p-6 flex flex-col h-full">
            <div className="mb-4 flex justify-between items-start">
              <Chip label={post.mood} variant="mood" mood={post.mood} />
              <span className="text-xs text-muted font-mono">{post.date}</span>
            </div>
            <h3 className="text-xl font-heading font-bold text-text mb-3 group-hover:text-primarySoft transition-colors glitch-hover">
              {post.title}
            </h3>
            <p className="text-muted text-sm leading-relaxed mb-6 flex-grow line-clamp-3">
              {post.excerpt}
            </p>
            <div className="flex items-center text-accent text-sm font-medium group-hover:underline underline-offset-4 decoration-accent/50">
              Read Transmission <span className="ml-2 group-hover:translate-x-1 transition-transform">→</span>
            </div>
          </div>
        </article>
      </Link>
    );
  }

  if (type === 'workshop') {
    const project = data as WorkshopProject;
    return (
      <div className={`group bg-surface rounded-xl overflow-hidden border border-border hover:border-accent/50 transition-all duration-300 hover:shadow-neon-accent/20 ${className}`}>
        <div className="relative aspect-video overflow-hidden">
          <div className="absolute inset-0 bg-gradient-to-t from-surface via-transparent to-transparent opacity-80 z-10" />
          <img 
            src={project.imageUrl} 
            alt={project.title} 
            className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110"
          />
          <div className="absolute bottom-3 left-4 z-20">
            <Chip label={project.category} variant="default" />
          </div>
        </div>
        <div className="p-5">
          <h3 className="text-xl font-heading font-bold text-text mb-2 group-hover:text-accent transition-colors glitch-hover">
            {project.title}
          </h3>
          <p className="text-sm text-muted mb-4 line-clamp-2">
            {project.summary}
          </p>
          <div className="flex flex-wrap gap-2">
            {project.specs.slice(0, 3).map(spec => (
              <Chip key={spec} label={spec} variant="tech" />
            ))}
          </div>
        </div>
      </div>
    );
  }

  return null;
};

export default Card;