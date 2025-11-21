<template>
  <div>
    <NavBar />
    <div class="container mx-auto px-4 py-8">
      <div class="flex items-center justify-between mb-8">
        <h1 class="text-3xl font-display font-bold text-primary">Events</h1>
        <Button @click="showCreateModal = true">Create Event</Button>
      </div>
      
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <Card v-for="event in events" :key="event.id">
          <h3 class="font-heading font-semibold text-lg mb-2">{{ event.title }}</h3>
          <p class="text-sm text-muted mb-2">{{ event.description }}</p>
          <p class="text-xs text-muted mb-4">{{ formatDate(event.start_time) }}</p>
          <KinkTagDisplay v-if="event.kink_tags" :tags="event.kink_tags" />
        </Card>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import type { Event } from '@/types'
import NavBar from '@/components/NavBar.vue'
import Card from '@/components/Card.vue'
import Button from '@/components/Button.vue'
import KinkTagDisplay from '@/components/KinkTagDisplay.vue'

const events = ref<Event[]>([])
const showCreateModal = ref(false)

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString()
}

onMounted(async () => {
  try {
    const response = await api.get('/events?upcoming=true')
    events.value = response.data
  } catch (error) {
    console.error('Failed to load events:', error)
  }
})
</script>

