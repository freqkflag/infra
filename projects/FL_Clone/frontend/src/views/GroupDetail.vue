<template>
  <div>
    <NavBar />
    <div class="container mx-auto px-4 py-8">
      <Card v-if="group">
        <h1 class="text-3xl font-display font-bold text-primary mb-4">{{ group.name }}</h1>
        <p class="text-muted mb-4">{{ group.description }}</p>
        <KinkTagDisplay v-if="group.kink_tags" :tags="group.kink_tags" />
      </Card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import api from '@/services/api'
import type { Group } from '@/types'
import NavBar from '@/components/NavBar.vue'
import Card from '@/components/Card.vue'
import KinkTagDisplay from '@/components/KinkTagDisplay.vue'

const route = useRoute()
const group = ref<Group | null>(null)

onMounted(async () => {
  try {
    const response = await api.get(`/groups/${route.params.id}`)
    group.value = response.data
  } catch (error) {
    console.error('Failed to load group:', error)
  }
})
</script>

