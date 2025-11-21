import { Post, WorkshopProject, GalleryItem, TimelineEvent } from '../types';

export const POSTS: Post[] = [
  {
    id: '1',
    title: 'Signal in the Static',
    slug: 'signal-in-the-static',
    excerpt: 'Navigating the noise of modern existence while rebuilding a homelab from scratch. A metaphor for mental recovery.',
    date: 'Oct 14, 2023',
    readTime: '5 min read',
    mood: 'reflective',
    category: 'Tech',
    imageUrl: 'https://picsum.photos/800/600?random=1',
    content: `
      <p>The hum of the server rack is a comfort. It's a consistent, white noise that drowns out the chaotic frequency of the outside world. Yesterday, I tore down the entire cluster.</p>
      <p>Why? Because sometimes you need to burn it down to build it right. The dependencies were tangled, the legacy configurations were haunting the logs, and frankly, it just didn't feel clean anymore.</p>
      <blockquote>Recovery isn't a straight line. It's a recursive function with no exit condition sometimes.</blockquote>
      <p>Rebuilding the Kubernetes cluster felt like a ritual. Flashing the ISOs, bootstrapping the nodes, watching the pods come alive one by one. Green status lights in the dark.</p>
    `
  },
  {
    id: '2',
    title: 'Neon Scars & EVA Foam',
    slug: 'neon-scars-eva-foam',
    excerpt: 'Crafting armor for a body that has fought too many battles. Cosplay as a form of somatic therapy.',
    date: 'Sep 28, 2023',
    readTime: '8 min read',
    mood: 'defiant',
    category: 'Cosplay',
    imageUrl: 'https://picsum.photos/800/600?random=2'
  },
  {
    id: '3',
    title: '3AM Kubernetes Migrations',
    slug: '3am-k8s-migrations',
    excerpt: 'When the mania hits, we code. Documenting the migration of the personal cloud to a new architecture.',
    date: 'Sep 10, 2023',
    readTime: '12 min read',
    mood: 'manic',
    category: 'Tech',
    imageUrl: 'https://picsum.photos/800/600?random=3'
  },
  {
    id: '4',
    title: 'Quiet Mornings in the Desert',
    slug: 'quiet-mornings-desert',
    excerpt: 'The RV is parked near Quartzsite. The silence here is heavy, but welcome. Coffee tastes better with dust.',
    date: 'Aug 05, 2023',
    readTime: '4 min read',
    mood: 'calm',
    category: 'Self',
    imageUrl: 'https://picsum.photos/800/600?random=4'
  }
];

export const WORKSHOPS: WorkshopProject[] = [
  {
    id: 'w1',
    title: 'Cyber-Samurai Armor V2',
    summary: 'Full body EVA foam armor with integrated Arduino-controlled RGB lighting.',
    category: 'Cosplay',
    specs: ['EVA Foam', 'Arduino', 'WS2812B LEDs', 'C++'],
    imageUrl: 'https://picsum.photos/600/400?random=10',
    date: '2023'
  },
  {
    id: 'w2',
    title: 'Homelab Rack 42U',
    summary: 'Custom managed server rack cooling solution and cable management overhaul.',
    category: 'Tech',
    specs: ['Dell R720', 'Ubiquiti', 'Docker', 'Ansible'],
    imageUrl: 'https://picsum.photos/600/400?random=11',
    date: '2023'
  },
  {
    id: 'w3',
    title: 'Geometric Sleeve Tattoo',
    summary: 'Design and concept art for a full sleeve exploring sacred geometry and circuit board traces.',
    category: 'Tattoo',
    specs: ['Procreate', 'Ink', 'Skin'],
    imageUrl: 'https://picsum.photos/600/400?random=12',
    date: '2022'
  }
];

export const GALLERY_ITEMS: GalleryItem[] = [
  { id: 'g1', title: 'Neon City', category: 'Photography', imageUrl: 'https://picsum.photos/800/800?random=20' },
  { id: 'g2', title: 'Ritual Altar', category: 'Art', imageUrl: 'https://picsum.photos/800/800?random=21' },
  { id: 'g3', title: 'Wasteland Weekend', category: 'Events', imageUrl: 'https://picsum.photos/800/800?random=22' },
  { id: 'g4', title: 'Self Portrait', category: 'Self', imageUrl: 'https://picsum.photos/800/800?random=23' },
  { id: 'g5', title: 'Circuit Board Macro', category: 'Photography', imageUrl: 'https://picsum.photos/800/800?random=24' },
  { id: 'g6', title: 'Glitch Art Experiment', category: 'Art', imageUrl: 'https://picsum.photos/800/800?random=25' },
];

export const TIMELINE_EVENTS: TimelineEvent[] = [
  {
    id: 't1',
    date: 'Oct 2023',
    title: 'Quartzsite Gathering',
    description: 'Met with the nomad tech guild. Starlink tests in deep desert.',
    location: 'Quartzsite, AZ'
  },
  {
    id: 't2',
    date: 'Aug 2023',
    title: 'The Great Northern Migration',
    description: 'Escaping the heat. Driving the rig up the PCH towards Oregon.',
    location: 'Big Sur, CA'
  },
  {
    id: 't3',
    date: 'May 2023',
    title: 'Solar Upgrade',
    description: 'Installed 800W of solar panels. Finally fully off-grid capable.',
    location: 'Mojave Desert'
  },
  {
    id: 't4',
    date: 'Jan 2023',
    title: 'Departure',
    description: 'Sold the apartment. Moved into the rig full-time. The beginning of the new era.',
    location: 'Seattle, WA'
  }
];