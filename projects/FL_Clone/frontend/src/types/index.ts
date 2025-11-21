export interface User {
  id: number
  username: string
  email: string
  is_admin: boolean
  created_at: string
  profile?: Profile
  kink_tags?: KinkTag[]
}

export interface Profile {
  id: number
  bio?: string
  location?: string
  website?: string
  role?: string
  orientation?: string
  interests?: string[]
  fetishes?: string[]
  privacy_level: number
  show_location: boolean
  show_age: boolean
}

export interface Group {
  id: number
  name: string
  description?: string
  slug: string
  privacy: number
  is_active: boolean
  created_at: string
  user: User
  members?: User[]
  kink_tags?: KinkTag[]
}

export interface Event {
  id: number
  title: string
  description?: string
  start_time: string
  end_time?: string
  location?: string
  venue?: string
  latitude?: number
  longitude?: number
  privacy: number
  max_attendees?: number
  is_active: boolean
  created_at: string
  user: User
  attendees?: User[]
  kink_tags?: KinkTag[]
}

export interface Post {
  id: number
  content: string
  privacy: number
  is_pinned: boolean
  likes_count: number
  comments_count: number
  created_at: string
  user: User
  comments?: Comment[]
  tags?: Tag[]
  kink_tags?: KinkTag[]
}

export interface Comment {
  id: number
  content: string
  created_at: string
  user: User
  parent_id?: number
  replies?: Comment[]
}

export interface Message {
  id: number
  content: string
  is_read: boolean
  read_at?: string
  created_at: string
  user: User
}

export interface Conversation {
  id: number
  last_message_at: string
  created_at: string
  sender: User
  recipient: User
  messages?: Message[]
  unread_count: number
}

export interface Notification {
  id: number
  type: string
  message?: string
  is_read: boolean
  read_at?: string
  created_at: string
  notifiable?: any
}

export interface Tag {
  id: number
  name: string
  slug: string
}

export interface KinkTag {
  id: number
  name: string
  slug: string
  description?: string
  category?: 'bdsm' | 'fetish' | 'roleplay' | 'sensation' | 'edgeplay' | 'lifestyle' | 'other'
  usage_count: number
  is_nsfw: boolean
  created_at: string
}
