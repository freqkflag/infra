import React from 'react';
import { useParams, Link } from 'react-router-dom';
import { POSTS } from '../services/data';
import Chip from '../components/Chip';
import Card from '../components/Card';

const SinglePost: React.FC = () => {
  const { slug } = useParams();
  const post = POSTS.find(p => p.slug === slug);

  if (!post) {
    return <div className="text-center text-white py-20">Signal lost. Post not found.</div>;
  }

  const relatedPosts = POSTS.filter(p => p.id !== post.id).slice(0, 2);

  return (
    <div className="min-h-screen pb-20">
      {/* Header */}
      <header className="pt-20 pb-12 bg-gradient-to-b from-surface to-background border-b border-border">
        <div className="container mx-auto px-6 max-w-4xl">
          <div className="flex flex-wrap gap-4 items-center mb-6">
            {/* Static Mood Chip */}
            <Chip label={post.mood} variant="mood" mood={post.mood} isActive={false} />
            
            <span className="text-accent font-mono text-sm">{post.date}</span>
            <span className="text-muted text-sm">•</span>
            <span className="text-muted text-sm">{post.readTime}</span>
          </div>
          <h1 className="text-4xl md:text-6xl font-display font-bold text-white leading-tight mb-6 glow-text glitch-hover">
            {post.title}
          </h1>
          <p className="text-xl text-muted md:w-3/4 font-light leading-relaxed border-l-4 border-primary pl-6">
            {post.excerpt}
          </p>
        </div>
      </header>

      {/* Content Body */}
      <article className="container mx-auto px-6 max-w-3xl py-12">
        {/* Image */}
        {post.imageUrl && (
          <div className="mb-12 rounded-2xl overflow-hidden border border-border shadow-soft">
            <img src={post.imageUrl} alt={post.title} className="w-full h-auto" />
          </div>
        )}

        <div 
          className="prose prose-invert prose-lg max-w-none font-body 
            prose-headings:font-heading prose-headings:text-white 
            prose-a:text-accent prose-a:no-underline hover:prose-a:text-white hover:prose-a:underline
            prose-blockquote:border-l-primary prose-blockquote:bg-surfaceAlt/30 prose-blockquote:p-4 prose-blockquote:italic prose-blockquote:rounded-r-lg
            prose-code:text-primarySoft prose-code:bg-surfaceAlt prose-code:px-1 prose-code:rounded prose-code:font-mono"
          dangerouslySetInnerHTML={{ __html: post.content || '<p>Content transmission incomplete...</p>' }} 
        />
        
        <div className="mt-16 pt-8 border-t border-border flex justify-between items-center">
          <Link to="/journal" className="text-muted hover:text-white transition-colors font-mono">← Back to Index</Link>
          <div className="flex gap-2">
             {/* Placeholder share buttons */}
             <button className="w-8 h-8 rounded-full bg-surface border border-border flex items-center justify-center text-muted hover:text-accent transition-colors">
               <span className="sr-only">Share</span>
               <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24"><path d="M18 16.08c-.76 0-1.44.3-1.96.77L8.91 12.7c.05-.23.09-.46.09-.7s-.04-.47-.09-.7l7.05-4.11c.54.5 1.25.81 2.04.81 1.66 0 3-1.34 3-3s-1.34-3-3-3-3 1.34-3 3c0 .24.04.47.09.7L8.04 9.81C7.5 9.31 6.79 9 6 9c-1.66 0-3 1.34-3 3s1.34 3 3 3c.79 0 1.5-.31 2.04-.81l7.12 4.16c-.05.21-.08.43-.08.65 0 1.61 1.31 2.92 2.92 2.92 1.61 0 2.92-1.31 2.92-2.92s-1.31-2.92-2.92-2.92z"/></svg>
             </button>
          </div>
        </div>
      </article>

      {/* Related */}
      <section className="container mx-auto px-6 py-12">
        <h3 className="text-2xl font-display font-bold text-white mb-6 glitch-hover">More from this Era</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
           {relatedPosts.map(p => <Card key={p.id} type="journal" data={p} />)}
        </div>
      </section>
    </div>
  );
};

export default SinglePost;