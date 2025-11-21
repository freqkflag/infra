<template>
  <div>
    <NavBar />
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-display font-bold text-primary mb-8">Search</h1>
      
      <div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
        <div class="lg:col-span-1">
          <KinkTagFilter @update:selected="handleTagFilter" />
        </div>
        
        <div class="lg:col-span-3">
          <div class="mb-6">
            <Input
              v-model="searchQuery"
              placeholder="Search users, groups, events, posts..."
              @input="handleSearch"
            />
          </div>
          
          <div v-if="results" class="space-y-6">
            <div v-if="results.users?.length">
              <h2 class="text-xl font-heading font-semibold mb-4">Users</h2>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <Card v-for="user in results.users" :key="user.id">
                  <div class="flex items-center gap-4">
                    <div class="w-12 h-12 rounded-full bg-primary/20 flex items-center justify-center text-primary font-heading font-bold">
                      {{ user.username[0].toUpperCase() }}
                    </div>
                    <div>
                      <h3 class="font-heading font-semibold">{{ user.username }}</h3>
                      <KinkTagDisplay v-if="user.kink_tags" :tags="user.kink_tags" class="mt-1" />
                    </div>
                  </div>
                </Card>
              </div>
            </div>
            
            <div v-if="results.groups?.length">
              <h2 class="text-xl font-heading font-semibold mb-4">Groups</h2>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <Card v-for="group in results.groups" :key="group.id">
                  <h3 class="font-heading font-semibold mb-2">{{ group.name }}</h3>
                  <p class="text-sm text-muted mb-2">{{ group.description }}</p>
                  <KinkTagDisplay v-if="group.kink_tags" :tags="group.kink_tags" />
                </Card>
              </div>
            </div>
            
            <div v-if="results.events?.length">
              <h2 class="text-xl font-heading font-semibold mb-4">Events</h2>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <Card v-for="event in results.events" :key="event.id">
                  <h3 class="font-heading font-semibold mb-2">{{ event.title }}</h3>
                  <p class="text-sm text-muted mb-2">{{ event.description }}</p>
                  <KinkTagDisplay v-if="event.kink_tags" :tags="event.kink_tags" />
                </Card>
              </div>
            </div>
            
            <div v-if="results.posts?.length">
              <h2 class="text-xl font-heading font-semibold mb-4">Posts</h2>
              <div class="space-y-4">
                <Card v-for="post in results.posts" :key="post.id">
                  <div class="flex items-start gap-4">
                    <div class="w-10 h-10 rounded-full bg-primary/20 flex items-center justify-center text-primary font-heading font-bold text-sm">
                      {{ post.user.username[0].toUpperCase() }}
                    </div>
                    <div class="flex-1">
                      <p class="text-text mb-2">{{ post.content }}</p>
                      <KinkTagDisplay v-if="post.kink_tags" :tags="post.kink_tags" />
                    </div>
                  </div>
                </Card>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import api from '@/services/api'
import NavBar from '@/components/NavBar.vue'
import Card from '@/components/Card.vue'
import Input from '@/components/Input.vue'
import KinkTagDisplay from '@/components/KinkTagDisplay.vue'
import KinkTagFilter from '@/components/KinkTagFilter.vue'

const searchQuery = ref('')
const results = ref<any>(null)

const handleSearch = async () => {
  if (!searchQuery.value) {
    results.value = null
    return
  }
  
  try {
    const response = await api.get(`/search?q=${encodeURIComponent(searchQuery.value)}`)
    results.value = response.data
  } catch (error) {
    console.error('Search failed:', error)
  }
}

const handleTagFilter = async (tagIds: number[]) => {
  // Search by kink tags
  console.log('Filtering by tag IDs:', tagIds)
}
</script>

