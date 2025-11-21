<template>
  <div>
    <NavBar />
    <div class="container mx-auto px-4 py-8">
      <Card v-if="event">
        <h1 class="text-3xl font-display font-bold text-primary mb-4">{{ event.title }}</h1>
        <p class="text-muted mb-4">{{ event.description }}</p>
        <p class="text-sm text-muted mb-4">{{ formatDate(event.start_time) }}</p>
        <KinkTagDisplay v-if="event.kink_tags" :tags="event.kink_tags" />
      </Card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import api from '@/services/api'
import type { Event } from '@/types'
import NavBar from '@/components/NavBar.vue'
import Card from '@/components/Card.vue'
import KinkTagDisplay from '@/components/KinkTagDisplay.vue'

const route = useRoute()
const event = ref<Event | null>(null)

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString()
}

onMounted(async () => {
  try {
    const response = await api.get(`/events/${route.params.id}`)
    event.value = response.data
  } catch (error) {
    console.error('Failed to load event:', error)
  }
})
</script>

