# FL Clone - Building Process Documentation

**Project:** FetLife-Inspired Social Platform Clone  
**Domain:** twist3dkinkst3r.com  
**Status:** Development Complete  
**Last Updated:** 2025-01-20

---

## Overview

FL Clone is a comprehensive social platform inspired by FetLife's framework and operations, built with Ruby on Rails and Vue.js. The platform features deep kink tagging integration, a dark neon cyberpunk design system, and is designed for deployment to twist3dkinkst3r.com.

### Key Features

- **User Authentication & Profiles** - JWT-based authentication with comprehensive user profiles
- **Groups & Discussions** - Community groups with discussion topics and moderation
- **Events Management** - Event creation, RSVP system, and calendar functionality
- **Content Sharing** - Posts with privacy controls, comments, likes, and media uploads
- **Private Messaging** - Real-time messaging with ActionCable WebSocket support
- **Deep Kink Tagging System** - Comprehensive tagging for users, posts, groups, and events
- **Advanced Search** - Full-text search with kink tag filtering
- **Dark Neon Design** - Cyberpunk aesthetic with neon accents matching cultofjoey design system

---

## Architecture

### Technology Stack

#### Backend
- **Framework:** Ruby on Rails 7.1 (API mode)
- **Database:** PostgreSQL 15
- **Cache/Queue:** Redis 7 (Sidekiq, ActionCable)
- **Authentication:** JWT tokens
- **File Storage:** Active Storage (local/S3)
- **Search:** pg_search (PostgreSQL full-text search)
- **Background Jobs:** Sidekiq

#### Frontend
- **Framework:** Vue 3 + TypeScript
- **Build Tool:** Vite
- **Routing:** Vue Router
- **State Management:** Pinia
- **HTTP Client:** Axios
- **Styling:** Tailwind CSS with custom design tokens
- **Fonts:** Orbitron (display), Oxanium (headings), Space Grotesk (body)

### Project Structure

```
FL_Clone/
├── backend/              # Rails API
│   ├── app/
│   │   ├── models/       # ActiveRecord models
│   │   ├── controllers/  # API controllers
│   │   ├── serializers/  # JSON serializers
│   │   ├── jobs/         # Background jobs
│   │   └── channels/     # ActionCable channels
│   ├── config/           # Rails configuration
│   ├── db/
│   │   └── migrate/      # Database migrations
│   └── Gemfile           # Ruby dependencies
├── frontend/             # Vue.js application
│   ├── src/
│   │   ├── components/   # Vue components
│   │   ├── views/        # Page views
│   │   ├── stores/       # Pinia stores
│   │   ├── styles/       # CSS and design tokens
│   │   └── services/     # API services
│   └── package.json      # Node dependencies
├── docker-compose.yml    # Service orchestration
├── .env.example          # Environment template
└── README.md             # Project documentation
```

---

## Building Process

### Phase 1: Project Setup

#### 1.1 Directory Structure
```bash
mkdir -p /root/infra/projects/FL_Clone/{backend,frontend}
```

#### 1.2 Backend Initialization
- Created Rails 7 API application structure
- Configured PostgreSQL adapter
- Set up JWT authentication
- Configured Active Storage for media uploads
- Set up Sidekiq for background jobs
- Configured ActionCable for WebSocket support

**Key Files Created:**
- `backend/Gemfile` - Ruby dependencies
- `backend/config/application.rb` - Rails configuration
- `backend/config/database.yml` - Database configuration
- `backend/config/routes.rb` - API routes

#### 1.3 Frontend Initialization
- Created Vue 3 + TypeScript project structure
- Configured Vite build tool
- Set up Vue Router for navigation
- Configured Pinia for state management
- Set up Tailwind CSS with custom configuration
- Integrated Axios for API communication

**Key Files Created:**
- `frontend/package.json` - Node dependencies
- `frontend/vite.config.ts` - Vite configuration
- `frontend/tailwind.config.js` - Tailwind configuration
- `frontend/tsconfig.json` - TypeScript configuration

---

### Phase 2: Database Schema

#### 2.1 Core Models
Created comprehensive database schema with 20 migrations:

**User Management:**
- `users` - Authentication and basic user data
- `profiles` - Extended user information (bio, location, interests, fetishes, privacy settings)

**Social Features:**
- `groups` - Community groups/forums
- `group_memberships` - User-group relationships with roles
- `group_topics` - Discussion topics within groups
- `events` - Community events, workshops, meetups
- `event_rsvps` - Event attendance tracking
- `posts` - User-generated content
- `comments` - Threaded comments on posts and topics
- `likes` - Like system for posts and comments
- `relationships` - Follow/friend connections between users

**Communication:**
- `conversations` - Private message threads
- `messages` - Individual messages within conversations
- `notifications` - User notifications

**Content Management:**
- `tags` - General content tags
- `taggings` - Tag associations
- `media` - Photo/video uploads with privacy controls
- `reports` - Content moderation reports

**Kink Tagging System:**
- `kink_tags` - Kink-specific tags with categories
- `kink_taggings` - Kink tag associations (polymorphic)

#### 2.2 Key Relationships
- Users have one Profile
- Users can join multiple Groups
- Users can create/attend Events
- Users can create Posts (with privacy levels)
- Users can send/receive Messages
- Users can follow/connect with other Users
- **All major models support kink tags** (users, posts, groups, events)

---

### Phase 3: Backend Implementation

#### 3.1 Models
Implemented all ActiveRecord models with:
- Associations and validations
- Privacy controls
- Search integration (pg_search)
- Kink tag associations

**Key Models:**
- `User` - Authentication, age verification (18+), JWT generation
- `Profile` - Extended user information with privacy levels
- `Group` - Community groups with privacy settings
- `Event` - Events with location, RSVP system
- `Post` - Content sharing with privacy controls
- `KinkTag` - Comprehensive kink tagging with categories
- `Message` - Real-time messaging support

#### 3.2 Controllers
Built RESTful API controllers:

**Authentication:**
- `Api::V1::AuthController` - Register, login, refresh, logout

**Resources:**
- `Api::V1::UsersController` - User CRUD, profile management
- `Api::V1::GroupsController` - Group management, membership
- `Api::V1::EventsController` - Event management, RSVP
- `Api::V1::PostsController` - Post creation, likes, comments
- `Api::V1::MessagesController` - Private messaging
- `Api::V1::ConversationsController` - Conversation management
- `Api::V1::SearchController` - Unified search with kink tag filtering
- `Api::V1::KinkTagsController` - Kink tag management

**Features:**
- JWT authentication middleware
- Authorization checks
- Error handling
- Kink tag integration in all relevant controllers

#### 3.3 Serializers
Created JSON serializers for consistent API responses:
- `UserSerializer` - User data with profile and kink tags
- `ProfileSerializer` - Profile information
- `GroupSerializer` - Group data with members and kink tags
- `EventSerializer` - Event data with attendees and kink tags
- `PostSerializer` - Post data with comments, tags, and kink tags
- `KinkTagSerializer` - Kink tag information

#### 3.4 Background Jobs
Implemented Sidekiq jobs:
- `EmailNotificationJob` - Send email notifications
- `ImageProcessingJob` - Process image variants
- `SearchIndexJob` - Index content for search

#### 3.5 Real-time Features
- ActionCable configuration
- `MessageChannel` - Real-time messaging updates
- WebSocket authentication via JWT

---

### Phase 4: Frontend Implementation

#### 4.1 Design System
Implemented dark neon cyberpunk design system:

**Color Tokens:**
- Background: `#05040A`
- Surface: `#0E0B1A`
- Primary: `#E600FF` (magenta)
- Accent: `#00FFFF` (cyan)
- Text: `#F5F5FA`
- Muted: `#9B92BB`

**Typography:**
- Display: Orbitron (700-900 weight)
- Headings: Oxanium (600-800 weight)
- Body: Space Grotesk (400-500 weight)
- Mono: JetBrains Mono

**Effects:**
- Neon glow shadows
- Smooth transitions with cyberpunk easing
- Hover effects with scale and glow

#### 4.2 Components
Built reusable Vue components:

**Core Components:**
- `Button` - Primary, secondary, ghost, outline variants
- `Card` - Container with neon styling
- `Chip` - Tag/chip component with variants
- `Input` - Form input with neon focus states
- `Textarea` - Text area input
- `Modal` - Modal dialog component
- `NavBar` - Navigation bar with routing

**Kink Tag Components:**
- `KinkTagSelector` - Browse and select kink tags
- `KinkTagDisplay` - Display tags with links to search
- `KinkTagFilter` - Filter content by kink tags

#### 4.3 Views
Created main application views:
- `Login.vue` - User login
- `Register.vue` - User registration with kink tag selection
- `Dashboard.vue` - Activity feed with kink tag filtering
- `Profile.vue` - User profile display
- `Groups.vue` - Group listing
- `GroupDetail.vue` - Group detail page
- `Events.vue` - Event listing
- `EventDetail.vue` - Event detail page
- `Messages.vue` - Messaging interface
- `Search.vue` - Unified search with kink tag filtering

#### 4.4 State Management
Implemented Pinia stores:
- `authStore` - Authentication state and methods
- `kinkTagsStore` - Kink tag data and methods

#### 4.5 API Integration
- Axios instance with interceptors
- JWT token management
- Error handling
- Automatic token refresh

---

### Phase 5: Kink Tagging System Integration

#### 5.1 Backend Integration

**Database:**
- `kink_tags` table with categories (BDSM, Fetish, Roleplay, Sensation, Edgeplay, Lifestyle, Other)
- `kink_taggings` polymorphic association table
- Usage count tracking

**Models:**
- `KinkTag` model with search, categories, popularity
- `KinkTagging` model with automatic usage tracking
- Associations added to User, Post, Group, Event models

**Controllers:**
- `KinkTagsController` - CRUD operations, popular tags, categories
- Integration in Users, Posts, Groups, Events controllers
- Search controller enhanced with kink tag filtering

**Serializers:**
- `KinkTagSerializer` - Tag data with usage counts
- Kink tags included in all relevant serializers

#### 5.2 Frontend Integration

**Components:**
- `KinkTagSelector` - Browse by category, search, select tags
- `KinkTagDisplay` - Display tags with links to filtered search
- `KinkTagFilter` - Filter content by tags and categories

**Views:**
- Registration includes kink tag selection
- Profiles display kink tags
- Posts, groups, events display kink tags
- Search page includes kink tag filtering

**Store:**
- `kinkTagsStore` - Fetch tags, categories, popular tags, search

---

### Phase 6: Docker & Infrastructure

#### 6.1 Docker Compose
Created comprehensive docker-compose.yml:

**Services:**
- `fl-clone-db` - PostgreSQL 15 database
- `fl-clone-redis` - Redis for Sidekiq and ActionCable
- `fl-clone-backend` - Rails API server
- `fl-clone-sidekiq` - Background job processor
- `fl-clone-frontend` - Vue.js development server

**Networks:**
- `fl-clone-network` - Internal communication
- `traefik-network` - External routing

**Volumes:**
- PostgreSQL data
- Redis data
- Active Storage files

#### 6.2 Traefik Integration
Configured Traefik labels for twist3dkinkst3r.com:
- Frontend: Root path with SSL
- Backend API: `/api` path with SSL
- Automatic Let's Encrypt certificates

#### 6.3 Dockerfiles
- `backend/Dockerfile` - Ruby 3.2.0 with Rails dependencies
- `frontend/Dockerfile` - Node 20 with Vue.js dependencies

---

### Phase 7: Security & Privacy

#### 7.1 Authentication
- JWT token-based authentication
- Password hashing with bcrypt
- Token expiration and refresh
- Age verification (18+)

#### 7.2 Privacy Controls
- Granular privacy levels (public, friends, private, hidden)
- Per-content privacy settings
- Profile visibility controls
- Location and age visibility toggles

#### 7.3 Content Moderation
- User reporting system
- Admin moderation tools
- Content flagging
- Block/mute functionality

---

## Deployment Process

### Prerequisites
- Docker & Docker Compose installed
- Traefik network available
- Domain DNS configured (twist3dkinkst3r.com)

### Steps

1. **Environment Setup:**
```bash
cd /root/infra/projects/FL_Clone
cp .env.example .env
# Edit .env with secure passwords and secrets
```

2. **Database Initialization:**
```bash
docker compose up -d fl-clone-db
sleep 10
docker compose exec fl-clone-backend rails db:create db:migrate
```

3. **Start Services:**
```bash
docker compose up -d
```

4. **Verify:**
- Frontend: https://twist3dkinkst3r.com
- Backend API: https://twist3dkinkst3r.com/api/v1

### Production Considerations
- Set strong `SECRET_KEY_BASE`
- Use secure `POSTGRES_PASSWORD`
- Configure Active Storage for S3 (optional)
- Set up email service for notifications
- Configure backup strategy
- Monitor resource usage

---

## Key Features Deep Dive

### Kink Tagging System

The kink tagging system is deeply integrated throughout the platform:

**Tag Categories:**
- BDSM
- Fetish
- Roleplay
- Sensation
- Edgeplay
- Lifestyle
- Other

**Usage:**
- Users can tag their profiles
- Posts can have kink tags
- Groups can be tagged
- Events can be tagged
- Search filters by kink tags
- Popular tags tracked by usage count

**API Endpoints:**
- `GET /api/v1/kink_tags` - List all tags
- `GET /api/v1/kink_tags/popular` - Get popular tags
- `GET /api/v1/kink_tags/categories` - Get categories
- `POST /api/v1/kink_tags` - Create new tag
- `GET /api/v1/search?kink_tag=slug` - Search by tag

### Search System

Full-text search with multiple filters:
- Search users, groups, events, posts
- Filter by kink tags
- Category-based filtering
- Location-based filtering (future)

### Real-time Messaging

ActionCable WebSocket support:
- Real-time message delivery
- Read receipts
- Typing indicators (future)
- Online status (future)

---

## Development Workflow

### Local Development

**Backend:**
```bash
cd backend
bundle install
rails db:create db:migrate
rails server
```

**Frontend:**
```bash
cd frontend
npm install
npm run dev
```

### Testing
- Backend: RSpec (configured)
- Frontend: Vitest (configured)
- E2E: Playwright (optional)

### Code Structure
- Follow Rails conventions
- Vue 3 Composition API
- TypeScript strict mode
- Component-based architecture

---

## Maintenance

### Updates
```bash
cd /root/infra/projects/FL_Clone
docker compose pull
docker compose up -d
```

### Backups
- Database: Daily PostgreSQL dumps
- Storage: Active Storage files
- Configuration: `.env` file

### Monitoring
- Container health checks
- Application logs
- Database performance
- Redis usage

---

## Troubleshooting

### Common Issues

**Database Connection:**
- Verify PostgreSQL container running
- Check credentials in `.env`
- Test connection: `docker compose exec fl-clone-db psql -U postgres`

**Frontend Not Loading:**
- Check Vite dev server logs
- Verify API proxy configuration
- Check browser console for errors

**Background Jobs Not Processing:**
- Verify Sidekiq container running
- Check Redis connection
- Review Sidekiq dashboard

**Kink Tags Not Appearing:**
- Verify kink_tags table exists
- Check associations in models
- Review API responses

---

## Future Enhancements

- Elasticsearch integration for advanced search
- Image optimization pipeline
- Video upload support
- Mobile app (React Native)
- Advanced analytics
- Recommendation engine based on kink tags
- Group moderation tools
- Event calendar improvements
- Notification preferences

---

## Related Documentation

- [FL Clone README](../FL_Clone/README.md)
- [Infrastructure Runbooks](../../runbooks/)
- [Service Registry](../../SERVICES.yml)

---

**Last Updated:** 2025-01-20  
**Maintained By:** Infrastructure Team  
**Project Location:** `/root/infra/projects/FL_Clone`

