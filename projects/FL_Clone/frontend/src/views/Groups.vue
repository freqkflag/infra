<template>
  <div>
    <NavBar />
    <div class="container mx-auto px-4 py-8">
      <div class="flex items-center justify-between mb-8">
        <h1 class="text-3xl font-display font-bold text-primary">Groups</h1>
        <Button @click="showCreateModal = true">Create Group</Button>
      </div>
      
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <Card v-for="group in groups" :key="group.id">
          <h3 class="font-heading font-semibold text-lg mb-2">{{ group.name }}</h3>
          <p class="text-sm text-muted mb-4">{{ group.description }}</p>
          <KinkTagDisplay v-if="group.kink_tags" :tags="group.kink_tags" />
        </Card>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import type { Group } from '@/types'
import NavBar from '@/components/NavBar.vue'
import Card from '@/components/Card.vue'
import Button from '@/components/Button.vue'
import KinkTagDisplay from '@/components/KinkTagDisplay.vue'

const groups = ref<Group[]>([])
const showCreateModal = ref(false)

onMounted(async () => {
  try {
    const response = await api.get('/groups')
    groups.value = response.data
  } catch (error) {
    console.error('Failed to load groups:', error)
  }
})
</script>

