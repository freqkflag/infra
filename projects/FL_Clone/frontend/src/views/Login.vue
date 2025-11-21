<template>
  <div class="min-h-screen flex items-center justify-center bg-background px-4">
    <div class="w-full max-w-md">
      <Card>
        <h1 class="text-2xl font-display font-bold text-primary mb-6 text-center">Login</h1>
        
        <form @submit.prevent="handleLogin" class="space-y-4">
          <Input
            id="email"
            v-model="email"
            label="Email"
            type="email"
            placeholder="your@email.com"
            :error="errors.email"
          />
          
          <Input
            id="password"
            v-model="password"
            label="Password"
            type="password"
            placeholder="••••••••"
            :error="errors.password"
          />
          
          <Button type="submit" :disabled="loading" class="w-full">
            {{ loading ? 'Logging in...' : 'Login' }}
          </Button>
        </form>
        
        <p class="mt-4 text-center text-sm text-muted">
          Don't have an account?
          <router-link to="/register" class="text-accent hover:text-accentSoft">
            Register
          </router-link>
        </p>
      </Card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import Card from '@/components/Card.vue'
import Button from '@/components/Button.vue'
import Input from '@/components/Input.vue'

const router = useRouter()
const authStore = useAuthStore()

const email = ref('')
const password = ref('')
const loading = ref(false)
const errors = ref<Record<string, string>>({})

const handleLogin = async () => {
  errors.value = {}
  loading.value = true
  
  const result = await authStore.login(email.value, password.value)
  
  if (result.success) {
    router.push('/')
  } else {
    errors.value.general = result.error || 'Login failed'
  }
  
  loading.value = false
}
</script>

