<template>
  <div :class="cardClasses">
    <slot />
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  variant?: 'default' | 'journal' | 'workshop' | 'gallery'
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'default',
})

const cardClasses = computed(() => {
  const base = 'bg-surface rounded-lg border border-border shadow-soft p-6 transition-all duration-300 hover:border-primarySoft hover:shadow-neon-primary'
  
  return base
})
</script>

