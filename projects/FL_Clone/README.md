# FL Clone - FetLife-Inspired Social Platform

A Ruby on Rails + Vue.js social platform clone inspired by FetLife's framework and operations, featuring deep kink tagging integration and a dark neon cyberpunk design system.

## Features

- **User Authentication & Profiles** - JWT-based auth with comprehensive user profiles
- **Groups & Discussions** - Community groups with discussion topics
- **Events Management** - Event creation, RSVP system, and calendar
- **Content Sharing** - Posts with privacy controls, comments, and likes
- **Private Messaging** - Real-time messaging with ActionCable
- **Deep Kink Tagging System** - Comprehensive tagging for users, posts, groups, and events
- **Search** - Full-text search with kink tag filtering
- **Dark Neon Design** - Cyberpunk aesthetic with neon accents

## Technology Stack

### Backend
- Ruby on Rails 7.1 (API mode)
- PostgreSQL 15
- Redis (Sidekiq, ActionCable)
- JWT authentication
- Active Storage (media uploads)
- pg_search (full-text search)

### Frontend
- Vue 3 + TypeScript
- Vite
- Vue Router
- Pinia (state management)
- Tailwind CSS
- Axios

## Project Structure

```
FL_Clone/
├── backend/          # Rails API
├── frontend/         # Vue.js frontend
├── docker-compose.yml
└── .env
```

## Setup

### Prerequisites
- Docker & Docker Compose
- Node.js 20+ (for local frontend development)
- Ruby 3.2+ (for local backend development)

### Docker Setup

1. Copy environment file:
```bash
cp .env.example .env
```

2. Edit `.env` and set your passwords and secrets:
```bash
POSTGRES_PASSWORD=your_secure_password
SECRET_KEY_BASE=$(rails secret)
```

3. Start services:
```bash
docker compose up -d
```

4. Run database migrations:
```bash
docker compose exec fl-clone-backend rails db:create db:migrate
```

5. Access the application:
- Frontend: http://localhost:5173
- Backend API: http://localhost:3000

### Local Development

#### Backend
```bash
cd backend
bundle install
rails db:create db:migrate
rails server
```

#### Frontend
```bash
cd frontend
npm install
npm run dev
```

## Kink Tagging System

The platform features deep integration with a kink tagging system:

- **Tag Categories**: BDSM, Fetish, Roleplay, Sensation, Edgeplay, Lifestyle, Other
- **Tag Associations**: Users, Posts, Groups, Events can all have kink tags
- **Search & Filtering**: Filter content by kink tags
- **Popular Tags**: Track most-used tags
- **Tag Management**: Create, browse, and manage tags

### Using Kink Tags

**Backend API:**
- `GET /api/v1/kink_tags` - List all tags
- `GET /api/v1/kink_tags/popular` - Get popular tags
- `GET /api/v1/kink_tags/categories` - Get tag categories
- `POST /api/v1/kink_tags` - Create new tag

**Frontend Components:**
- `<KinkTagSelector>` - Select tags for posts/profiles
- `<KinkTagDisplay>` - Display tags with links
- `<KinkTagFilter>` - Filter content by tags

## API Documentation

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login
- `POST /api/v1/auth/refresh` - Refresh token
- `DELETE /api/v1/auth/logout` - Logout

### Users
- `GET /api/v1/users` - List users
- `GET /api/v1/users/:id` - Get user
- `GET /api/v1/users/:id/profile` - Get user profile
- `PATCH /api/v1/users/:id/profile` - Update profile

### Posts
- `GET /api/v1/posts` - List posts
- `POST /api/v1/posts` - Create post (with kink_tags)
- `GET /api/v1/posts/:id` - Get post
- `POST /api/v1/posts/:id/like` - Like post

### Groups
- `GET /api/v1/groups` - List groups
- `POST /api/v1/groups` - Create group (with kink_tags)
- `POST /api/v1/groups/:id/join` - Join group

### Events
- `GET /api/v1/events` - List events
- `POST /api/v1/events` - Create event (with kink_tags)
- `POST /api/v1/events/:id/rsvp` - RSVP to event

### Search
- `GET /api/v1/search?q=query` - Search all content
- `GET /api/v1/search?kink_tag=slug` - Search by kink tag

## Deployment

### For twist3dkinkst3r.com

The docker-compose.yml includes Traefik labels for automatic SSL and routing:

- Domain: `twist3dkinkst3r.com`
- Frontend: Root path
- Backend API: `/api` path

Ensure Traefik network is available:
```bash
docker network create traefik-network
```

## Design System

The platform uses a dark neon cyberpunk design system:

- **Colors**: Primary magenta (#E600FF), Accent cyan (#00FFFF)
- **Typography**: Orbitron (display), Oxanium (headings), Space Grotesk (body)
- **Effects**: Neon glows, smooth transitions, cyberpunk easing

## Background Jobs

Sidekiq handles:
- Email notifications
- Image processing
- Search indexing

## Security

- JWT token authentication
- Password hashing with bcrypt
- Age verification (18+)
- Privacy controls on all content
- Content moderation tools

## License

Private project for twist3dkinkst3r.com

