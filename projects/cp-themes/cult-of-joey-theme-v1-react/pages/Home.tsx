import React from 'react';
import { Link } from 'react-router-dom';
import Button from '../components/Button';
import Card from '../components/Card';
import { POSTS, WORKSHOPS, GALLERY_ITEMS } from '../services/data';

const Home: React.FC = () => {
  const latestPost = POSTS[0];
  const recentPosts = POSTS.slice(1, 4);
  const featuredWorkshops = WORKSHOPS.slice(0, 2);

  return (
    <div className="w-full">
      {/* HERO SECTION */}
      <section className="relative min-h-[90vh] flex items-center justify-center overflow-hidden pt-10">
        {/* Background Gradient */}
        <div className="absolute inset-0 bg-gradient-to-br from-background via-surface to-[#1a0b2e] z-0"></div>
        {/* Decorative Grid */}
        <div className="absolute inset-0 bg-[linear-gradient(rgba(43,37,64,0.2)_1px,transparent_1px),linear-gradient(90deg,rgba(43,37,64,0.2)_1px,transparent_1px)] bg-[size:40px_40px] [mask-image:radial-gradient(ellipse_at_center,black,transparent)] z-0 pointer-events-none"></div>

        <div className="container mx-auto px-6 relative z-10 grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          
          {/* Left Content */}
          <div className="lg:col-span-7 flex flex-col gap-6">
            <div className="inline-flex items-center gap-2 text-accent font-mono text-xs uppercase tracking-[0.2em] animate-fade-in">
              <span className="w-2 h-2 bg-accent rounded-full shadow-[0_0_10px_#00FFFF]"></span>
              Signal Online
            </div>
            
            <h1 className="text-5xl md:text-7xl font-display font-black leading-tight text-white drop-shadow-lg glitch-hover">
              WE ARE THE <br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-primary to-accent relative inline-block">
                GLITCH
                <span className="absolute inset-0 blur-lg opacity-50 bg-gradient-to-r from-primary to-accent -z-10"></span>
              </span> 
              <br /> IN THE SYSTEM.
            </h1>
            
            <p className="text-lg md:text-xl text-muted max-w-xl leading-relaxed">
              A digital sanctuary for queer resilience, homelab mysticism, and creative survival. Welcome to the Cult.
            </p>

            <div className="flex flex-wrap gap-4 mt-4">
              <Link to="/journal">
                <Button variant="primary" size="lg">Enter the Archive</Button>
              </Link>
              <Link to="/workshops">
                <Button variant="secondary" size="lg">View Projects</Button>
              </Link>
            </div>
          </div>

          {/* Right Card: Now Broadcasting */}
          <div className="lg:col-span-5">
            <div className="relative group">
              <div className="absolute -inset-1 bg-gradient-to-r from-primary via-accent to-primary rounded-2xl blur opacity-20 group-hover:opacity-50 transition duration-1000"></div>
              <div className="relative bg-surfaceAlt border border-border p-6 rounded-2xl">
                <div className="flex items-center justify-between mb-4 border-b border-border pb-2">
                  <span className="text-xs font-mono text-primary animate-pulse">● LIVE TRANSMISSION</span>
                  <span className="text-xs text-muted font-mono">{latestPost.date}</span>
                </div>
                <h3 className="text-2xl font-display font-bold text-white mb-3 glitch-hover">{latestPost.title}</h3>
                <p className="text-muted mb-6 line-clamp-3">{latestPost.excerpt}</p>
                <Link to={`/journal/${latestPost.slug}`}>
                  <Button variant="outline" size="sm" className="w-full">Read Full Transmission</Button>
                </Link>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* JOURNAL STRIP */}
      <section className="py-20 bg-background border-t border-border">
        <div className="container mx-auto px-6">
          <div className="flex justify-between items-end mb-12">
            <div>
              <h2 className="text-3xl md:text-4xl font-display font-bold text-white mb-2 glitch-hover">Recent Signals</h2>
              <p className="text-muted">Lore from the recovery arc.</p>
            </div>
            <Link to="/journal" className="hidden md:block text-accent hover:text-white transition-colors font-heading">View All →</Link>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {recentPosts.map(post => (
              <Card key={post.id} type="journal" data={post} />
            ))}
          </div>
          
          <div className="mt-8 md:hidden text-center">
             <Link to="/journal" className="text-accent font-heading">View All Signals →</Link>
          </div>
        </div>
      </section>

      {/* WORKSHOP STRIP */}
      <section className="py-20 bg-surface relative overflow-hidden">
        {/* Angled Background Accent */}
        <div className="absolute top-0 right-0 w-2/3 h-full bg-surfaceAlt/30 -skew-x-12 z-0 pointer-events-none"></div>

        <div className="container mx-auto px-6 relative z-10">
          <div className="flex flex-col md:flex-row gap-12 items-center">
            <div className="md:w-1/3">
              <h2 className="text-3xl md:text-4xl font-display font-bold text-white mb-6 glitch-hover">The Workshop</h2>
              <p className="text-muted mb-8 leading-relaxed">
                Where silicon meets skin. Explore the fabrication logs, from 42U server racks to EVA foam armor and geometric ink.
              </p>
              <Link to="/workshops">
                <Button variant="outline">Explore Projects</Button>
              </Link>
            </div>
            <div className="md:w-2/3 grid grid-cols-1 md:grid-cols-2 gap-6">
              {featuredWorkshops.map(project => (
                <Card key={project.id} type="workshop" data={project} />
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* GALLERY BAND */}
      <section className="py-12 bg-background">
        <div className="container mx-auto px-6 mb-6">
          <h2 className="text-2xl font-display font-bold text-white glitch-hover">Visual Database</h2>
        </div>
        <div className="grid grid-cols-2 md:grid-cols-6 h-48 md:h-64 w-full">
          {GALLERY_ITEMS.slice(0, 6).map((item, idx) => (
            <Link to="/gallery" key={item.id} className="relative group overflow-hidden block h-full w-full">
              <img src={item.imageUrl} alt={item.title} className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110" />
              <div className="absolute inset-0 bg-primary/20 opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-center justify-center">
                 <span className="text-white font-heading font-bold text-sm tracking-widest uppercase drop-shadow-md">{item.category}</span>
              </div>
            </Link>
          ))}
        </div>
      </section>
    </div>
  );
};

export default Home;