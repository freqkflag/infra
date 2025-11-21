import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '@/services/api'
import type { User } from '@/types'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const token = ref<string | null>(localStorage.getItem('token'))
  
  const isAuthenticated = computed(() => !!token.value && !!user.value)
  
  async function login(email: string, password: string) {
    try {
      const response = await api.post('/auth/login', { email, password })
      token.value = response.data.token
      user.value = response.data.user
      localStorage.setItem('token', response.data.token)
      return { success: true }
    } catch (error: any) {
      return { success: false, error: error.response?.data?.error || 'Login failed' }
    }
  }
  
  async function register(userData: any) {
    try {
      const response = await api.post('/auth/register', { user: userData })
      token.value = response.data.token
      user.value = response.data.user
      localStorage.setItem('token', response.data.token)
      return { success: true }
    } catch (error: any) {
      return { success: false, error: error.response?.data?.errors || 'Registration failed' }
    }
  }
  
  function logout() {
    token.value = null
    user.value = null
    localStorage.removeItem('token')
  }
  
  async function fetchCurrentUser() {
    try {
      const response = await api.get('/users/profile')
      user.value = response.data.user
      return { success: true }
    } catch (error) {
      logout()
      return { success: false }
    }
  }
  
  return {
    user,
    token,
    isAuthenticated,
    login,
    register,
    logout,
    fetchCurrentUser,
  }
})

