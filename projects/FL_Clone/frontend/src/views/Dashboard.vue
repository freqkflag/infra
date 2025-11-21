<template>
  <div>
    <NavBar />
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-display font-bold text-primary mb-8">Dashboard</h1>
      
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div class="lg:col-span-2 space-y-6">
          <Card v-for="post in posts" :key="post.id">
            <div class="flex items-start gap-4 mb-4">
              <div class="w-12 h-12 rounded-full bg-primary/20 flex items-center justify-center text-primary font-heading font-bold">
                {{ post.user.username[0].toUpperCase() }}
              </div>
              <div class="flex-1">
                <div class="flex items-center gap-2 mb-1">
                  <span class="font-heading font-semibold text-text">{{ post.user.username }}</span>
                  <span class="text-xs text-muted">{{ formatDate(post.created_at) }}</span>
                </div>
                <p class="text-text">{{ post.content }}</p>
                <KinkTagDisplay v-if="post.kink_tags" :tags="post.kink_tags" class="mt-2" />
                <div class="flex items-center gap-4 mt-4">
                  <button class="text-muted hover:text-primary transition-colors">
                    Like ({{ post.likes_count }})
                  </button>
                  <button class="text-muted hover:text-accent transition-colors">
                    Comment ({{ post.comments_count }})
                  </button>
                </div>
              </div>
            </div>
          </Card>
        </div>
        
        <div class="space-y-6">
          <Card>
            <h2 class="font-heading font-semibold text-lg mb-4">Popular Kink Tags</h2>
            <KinkTagFilter @update:selected="handleTagFilter" />
          </Card>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import type { Post } from '@/types'
import NavBar from '@/components/NavBar.vue'
import Card from '@/components/Card.vue'
import KinkTagDisplay from '@/components/KinkTagDisplay.vue'
import KinkTagFilter from '@/components/KinkTagFilter.vue'

const posts = ref<Post[]>([])

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString()
}

const handleTagFilter = (tagIds: number[]) => {
  // Filter posts by selected tags
  console.log('Filtering by tags:', tagIds)
}

onMounted(async () => {
  try {
    const response = await api.get('/posts')
    posts.value = response.data
  } catch (error) {
    console.error('Failed to load posts:', error)
  }
})
</script>

