<template>
  <div class="bg-surfaceAlt border border-border rounded-lg p-4">
    <h3 class="text-sm font-heading font-semibold text-text mb-3">Filter by Kink Tags</h3>
    
    <div class="flex flex-wrap gap-2 mb-4">
      <button
        v-for="category in categories"
        :key="category"
        @click="toggleCategory(category)"
        :class="[
          'px-3 py-1 rounded-full text-xs font-medium transition-colors',
          selectedCategories.includes(category)
            ? 'bg-accent text-background'
            : 'bg-surface text-muted hover:bg-surfaceAlt'
        ]"
      >
        {{ category }}
      </button>
    </div>
    
    <div class="flex flex-wrap gap-2">
      <button
        v-for="tag in filteredTags"
        :key="tag.id"
        @click="toggleTag(tag)"
        :class="[
          'px-3 py-1 rounded-full text-xs font-medium transition-all duration-200',
          selectedTags.includes(tag.id)
            ? 'bg-primary text-background shadow-neon-primary'
            : 'bg-surface text-muted hover:bg-surfaceAlt hover:text-text'
        ]"
      >
        {{ tag.name }}
      </button>
    </div>
    
    <div v-if="selectedTags.length > 0" class="mt-4 pt-4 border-t border-border">
      <div class="flex items-center justify-between">
        <span class="text-sm text-muted">{{ selectedTags.length }} tag(s) selected</span>
        <button
          @click="clearFilters"
          class="text-xs text-accent hover:text-accentSoft transition-colors"
        >
          Clear All
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import type { KinkTag } from '@/types'
import api from '@/services/api'

const emit = defineEmits<{
  'update:selected': [tagIds: number[]]
}>()

const allTags = ref<KinkTag[]>([])
const categories = ref<string[]>([])
const selectedCategories = ref<string[]>([])
const selectedTags = ref<number[]>([])

const filteredTags = computed(() => {
  let tags = allTags.value
  
  if (selectedCategories.value.length > 0) {
    tags = tags.filter(t => t.category && selectedCategories.value.includes(t.category))
  }
  
  return tags.sort((a, b) => b.usage_count - a.usage_count).slice(0, 50)
})

const toggleCategory = (category: string) => {
  const index = selectedCategories.value.indexOf(category)
  if (index > -1) {
    selectedCategories.value.splice(index, 1)
  } else {
    selectedCategories.value.push(category)
  }
}

const toggleTag = (tag: KinkTag) => {
  const index = selectedTags.value.indexOf(tag.id)
  if (index > -1) {
    selectedTags.value.splice(index, 1)
  } else {
    selectedTags.value.push(tag.id)
  }
  emit('update:selected', [...selectedTags.value])
}

const clearFilters = () => {
  selectedCategories.value = []
  selectedTags.value = []
  emit('update:selected', [])
}

onMounted(async () => {
  try {
    const [tagsRes, categoriesRes] = await Promise.all([
      api.get('/kink_tags?popular=true'),
      api.get('/kink_tags/categories'),
    ])
    allTags.value = tagsRes.data
    categories.value = categoriesRes.data.categories
  } catch (error) {
    console.error('Failed to load kink tags:', error)
  }
})
</script>

