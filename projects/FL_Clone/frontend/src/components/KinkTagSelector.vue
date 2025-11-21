<template>
  <div class="flex flex-col gap-4">
    <div class="flex items-center justify-between">
      <label class="text-sm font-heading text-muted">Kink Tags</label>
      <button
        @click="showSelector = !showSelector"
        class="text-xs text-accent hover:text-accentSoft transition-colors"
      >
        {{ showSelector ? 'Hide' : 'Browse Tags' }}
      </button>
    </div>
    
    <div v-if="showSelector" class="bg-surfaceAlt border border-border rounded-lg p-4 max-h-64 overflow-y-auto">
      <div class="flex flex-wrap gap-2 mb-4">
        <button
          v-for="category in categories"
          :key="category"
          @click="selectedCategory = selectedCategory === category ? null : category"
          :class="[
            'px-3 py-1 rounded-full text-xs font-medium transition-colors',
            selectedCategory === category
              ? 'bg-primary text-background'
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
            isSelected(tag)
              ? 'bg-primary text-background shadow-neon-primary'
              : 'bg-surfaceAlt text-muted hover:bg-surface hover:text-text'
          ]"
        >
          {{ tag.name }}
        </button>
      </div>
      
      <div v-if="filteredTags.length === 0" class="text-center text-muted text-sm py-4">
        No tags found
      </div>
    </div>
    
    <div v-if="selectedTags.length > 0" class="flex flex-wrap gap-2">
      <span
        v-for="tag in selectedTags"
        :key="tag.id"
        class="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-medium bg-primary/20 text-primarySoft border border-primary/30"
      >
        {{ tag.name }}
        <button
          @click="removeTag(tag)"
          class="hover:text-primary transition-colors"
        >
          ×
        </button>
      </span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import type { KinkTag } from '@/types'
import api from '@/services/api'

interface Props {
  modelValue: KinkTag[]
}

const props = defineProps<Props>()
const emit = defineEmits<{
  'update:modelValue': [tags: KinkTag[]]
}>()

const showSelector = ref(false)
const selectedCategory = ref<string | null>(null)
const allTags = ref<KinkTag[]>([])
const categories = ref<string[]>([])

const selectedTags = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value),
})

const filteredTags = computed(() => {
  let tags = allTags.value
  
  if (selectedCategory.value) {
    tags = tags.filter(t => t.category === selectedCategory.value)
  }
  
  return tags.sort((a, b) => b.usage_count - a.usage_count)
})

const isSelected = (tag: KinkTag) => {
  return selectedTags.value.some(t => t.id === tag.id)
}

const toggleTag = (tag: KinkTag) => {
  if (isSelected(tag)) {
    removeTag(tag)
  } else {
    addTag(tag)
  }
}

const addTag = (tag: KinkTag) => {
  if (!isSelected(tag)) {
    selectedTags.value = [...selectedTags.value, tag]
  }
}

const removeTag = (tag: KinkTag) => {
  selectedTags.value = selectedTags.value.filter(t => t.id !== tag.id)
}

onMounted(async () => {
  try {
    const [tagsRes, categoriesRes] = await Promise.all([
      api.get('/kink_tags'),
      api.get('/kink_tags/categories'),
    ])
    allTags.value = tagsRes.data
    categories.value = categoriesRes.data.categories
  } catch (error) {
    console.error('Failed to load kink tags:', error)
  }
})
</script>

