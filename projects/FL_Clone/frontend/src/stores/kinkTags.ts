import { defineStore } from 'pinia'
import { ref } from 'vue'
import api from '@/services/api'
import type { KinkTag } from '@/types'

export const useKinkTagsStore = defineStore('kinkTags', () => {
  const tags = ref<KinkTag[]>([])
  const categories = ref<string[]>([])
  const popularTags = ref<KinkTag[]>([])
  
  async function fetchTags() {
    try {
      const response = await api.get('/kink_tags')
      tags.value = response.data
      return { success: true }
    } catch (error) {
      return { success: false, error }
    }
  }
  
  async function fetchPopularTags() {
    try {
      const response = await api.get('/kink_tags/popular')
      popularTags.value = response.data
      return { success: true }
    } catch (error) {
      return { success: false, error }
    }
  }
  
  async function fetchCategories() {
    try {
      const response = await api.get('/kink_tags/categories')
      categories.value = response.data.categories
      return { success: true }
    } catch (error) {
      return { success: false, error }
    }
  }
  
  async function searchTags(query: string) {
    try {
      const response = await api.get(`/kink_tags?q=${encodeURIComponent(query)}`)
      return { success: true, data: response.data }
    } catch (error) {
      return { success: false, error }
    }
  }
  
  return {
    tags,
    categories,
    popularTags,
    fetchTags,
    fetchPopularTags,
    fetchCategories,
    searchTags,
  }
})

