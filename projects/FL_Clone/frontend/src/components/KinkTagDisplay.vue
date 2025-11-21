<template>
  <div class="flex flex-wrap gap-2">
    <router-link
      v-for="tag in tags"
      :key="tag.id"
      :to="`/search?kink_tag=${tag.slug}`"
      :class="[
        'inline-flex items-center px-3 py-1 rounded-full text-xs font-medium transition-all duration-200',
        'bg-primary/20 text-primarySoft border border-primary/30',
        'hover:bg-primary/30 hover:border-primary/50 hover:shadow-neon-primary'
      ]"
    >
      {{ tag.name }}
      <span v-if="showCount" class="ml-2 text-xs opacity-70">
        ({{ tag.usage_count }})
      </span>
    </router-link>
  </div>
</template>

<script setup lang="ts">
import type { KinkTag } from '@/types'

interface Props {
  tags: KinkTag[]
  showCount?: boolean
}

withDefaults(defineProps<Props>(), {
  showCount: false,
})
</script>

