<template>
  <div class="min-h-screen flex items-center justify-center bg-background px-4 py-8">
    <div class="w-full max-w-md">
      <Card>
        <h1 class="text-2xl font-display font-bold text-primary mb-6 text-center">Create Account</h1>
        
        <form @submit.prevent="handleRegister" class="space-y-4">
          <Input
            id="username"
            v-model="username"
            label="Username"
            placeholder="username"
            :error="errors.username"
          />
          
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
          
          <Input
            id="password_confirmation"
            v-model="passwordConfirmation"
            label="Confirm Password"
            type="password"
            placeholder="••••••••"
            :error="errors.password_confirmation"
          />
          
          <Input
            id="birth_date"
            v-model="birthDate"
            label="Birth Date (must be 18+)"
            type="date"
            :error="errors.birth_date"
          />
          
          <KinkTagSelector v-model="selectedKinkTags" />
          
          <Button type="submit" :disabled="loading" class="w-full">
            {{ loading ? 'Creating account...' : 'Register' }}
          </Button>
        </form>
        
        <p class="mt-4 text-center text-sm text-muted">
          Already have an account?
          <router-link to="/login" class="text-accent hover:text-accentSoft">
            Login
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
import KinkTagSelector from '@/components/KinkTagSelector.vue'
import type { KinkTag } from '@/types'

const router = useRouter()
const authStore = useAuthStore()

const username = ref('')
const email = ref('')
const password = ref('')
const passwordConfirmation = ref('')
const birthDate = ref('')
const selectedKinkTags = ref<KinkTag[]>([])
const loading = ref(false)
const errors = ref<Record<string, string>>({})

const handleRegister = async () => {
  errors.value = {}
  loading.value = true
  
  const result = await authStore.register({
    username: username.value,
    email: email.value,
    password: password.value,
    password_confirmation: passwordConfirmation.value,
    birth_date: birthDate.value,
    kink_tags: selectedKinkTags.value.map(t => t.slug),
  })
  
  if (result.success) {
    router.push('/')
  } else {
    if (Array.isArray(result.error)) {
      result.error.forEach((err: string) => {
        const [field, message] = err.split(' ')
        errors.value[field] = message
      })
    } else {
      errors.value.general = result.error || 'Registration failed'
    }
  }
  
  loading.value = false
}
</script>

