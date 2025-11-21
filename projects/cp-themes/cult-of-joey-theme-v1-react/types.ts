export type Mood = 'calm' | 'manic' | 'reflective' | 'defiant';
export type Category = 'Cosplay' | 'Tech' | 'Tattoo' | 'DIY' | 'Photography' | 'Art' | 'Events' | 'Self';

export interface Post {
  id: string;
  title: string;
  slug: string;
  excerpt: string;
  date: string;
  readTime: string;
  mood: Mood;
  category: Category;
  imageUrl?: string;
  content?: string;
}

export interface WorkshopProject {
  id: string;
  title: string;
  summary: string;
  category: Category;
  specs: string[];
  imageUrl: string;
  date: string;
}

export interface GalleryItem {
  id: string;
  title: string;
  category: Category;
  imageUrl: string;
  description?: string;
}

export interface TimelineEvent {
  id: string;
  date: string;
  title: string;
  description: string;
  location?: string;
  imageUrl?: string;
}