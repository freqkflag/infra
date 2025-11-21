import React, { useState } from 'react';
import { GALLERY_ITEMS } from '../services/data';
import { GalleryItem } from '../types';

const Gallery: React.FC = () => {
  const [selectedImage, setSelectedImage] = useState<GalleryItem | null>(null);

  return (
    <div className="min-h-screen py-12">
      <div className="container mx-auto px-6 mb-12">
        <h1 className="text-4xl md:text-6xl font-display font-black text-white mb-4 glitch-hover">Visual Database</h1>
        <p className="text-muted">Snapshots of the journey.</p>
      </div>

      {/* Masonry-ish Grid */}
      <div className="container mx-auto px-6 grid grid-cols-1 md:grid-cols-3 gap-4">
        {GALLERY_ITEMS.map((item) => (
          <div 
            key={item.id} 
            className="relative group cursor-pointer overflow-hidden rounded-lg break-inside-avoid"
            onClick={() => setSelectedImage(item)}
          >
            <img 
              src={item.imageUrl} 
              alt={item.title} 
              className="w-full h-64 md:h-80 object-cover transition-transform duration-500 group-hover:scale-105 filter grayscale-[30%] group-hover:grayscale-0" 
            />
            <div className="absolute inset-0 bg-gradient-to-t from-background via-transparent to-transparent opacity-60 md:opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex flex-col justify-end p-6">
              <span className="text-accent font-mono text-xs uppercase mb-1">{item.category}</span>
              <h3 className="text-white font-heading font-bold text-lg glitch-hover">{item.title}</h3>
            </div>
          </div>
        ))}
      </div>

      {/* Lightbox Modal */}
      {selectedImage && (
        <div 
          className="fixed inset-0 z-[100] bg-black/90 backdrop-blur-md flex items-center justify-center p-4"
          onClick={() => setSelectedImage(null)}
        >
          <button className="absolute top-6 right-6 text-white hover:text-accent">
             <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" /></svg>
          </button>
          <div className="max-w-5xl w-full max-h-[90vh] flex flex-col items-center" onClick={e => e.stopPropagation()}>
            <img src={selectedImage.imageUrl} alt={selectedImage.title} className="max-h-[80vh] w-auto rounded-md shadow-[0_0_30px_rgba(0,0,0,0.5)]" />
            <div className="mt-4 text-center">
               <h2 className="text-2xl font-display font-bold text-white glitch-hover">{selectedImage.title}</h2>
               <span className="text-accent font-mono text-sm">{selectedImage.category}</span>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Gallery;