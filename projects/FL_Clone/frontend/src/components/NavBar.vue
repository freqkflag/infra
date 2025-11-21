<template>
  <nav class="sticky top-0 z-50 bg-surface/80 backdrop-blur-md border-b border-border">
    <div class="container mx-auto px-4 py-4">
      <div class="flex items-center justify-between">
        <router-link to="/" class="text-2xl font-display font-bold text-primary hover:text-primarySoft transition-colors">
          FL Clone
        </router-link>
        
        <div class="hidden md:flex items-center gap-6">
          <router-link
            v-for="link in links"
            :key="link.to"
            :to="link.to"
            class="text-muted hover:text-accent transition-colors underline-animation"
          >
            {{ link.label }}
          </router-link>
        </div>
        
        <div class="flex items-center gap-4">
          <button
            v-if="authStore.isAuthenticated"
            @click="handleLogout"
            class="text-muted hover:text-accent transition-colors"
          >
            Logout
          </button>
          <router-link
            v-else
            to="/login"
            class="text-muted hover:text-accent transition-colors"
          >
            Login
          </router-link>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup lang="ts">
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'

const authStore = useAuthStore()
const router = useRouter()

const links = [
  { to: '/', label: 'Home' },
  { to: '/groups', label: 'Groups' },
  { to: '/events', label: 'Events' },
  { to: '/messages', label: 'Messages' },
  { to: '/search', label: 'Search' },
]

const handleLogout = () => {
  authStore.logout()
  router.push('/login')
}
</script>

