<template>
  <div>
    <NavBar />
    <div class="container mx-auto px-4 py-8">
      <Card>
        <div class="flex items-start gap-6 mb-6">
          <div class="w-24 h-24 rounded-full bg-primary/20 flex items-center justify-center text-primary font-display font-bold text-3xl">
            {{ user?.username[0].toUpperCase() }}
          </div>
          <div class="flex-1">
            <h1 class="text-3xl font-display font-bold text-primary mb-2">{{ user?.username }}</h1>
            <p v-if="user?.profile?.bio" class="text-muted mb-4">{{ user.profile.bio }}</p>
            <KinkTagDisplay v-if="user?.kink_tags" :tags="user.kink_tags" />
          </div>
        </div>
      </Card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import api from '@/services/api'
import type { User } from '@/types'
import NavBar from '@/components/NavBar.vue'
import Card from '@/components/Card.vue'
import KinkTagDisplay from '@/components/KinkTagDisplay.vue'

const route = useRoute()
const user = ref<User | null>(null)

onMounted(async () => {
  try {
    const userId = route.params.id || 'profile'
    const response = await api.get(`/users/${userId}/profile`)
    user.value = response.data.user
  } catch (error) {
    console.error('Failed to load profile:', error)
  }
})
</script>

