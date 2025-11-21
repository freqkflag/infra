<template>
  <span :class="chipClasses">
    <slot />
  </span>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  variant?: 'default' | 'calm' | 'manic' | 'reflective' | 'defiant'
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'default',
})

const chipClasses = computed(() => {
  const base = 'inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-surfaceAlt text-muted'
  
  const variants = {
    default: '',
    calm: 'bg-teal-500/20 text-teal-300',
    manic: 'bg-primary/20 text-primarySoft',
    reflective: 'bg-indigo-500/20 text-indigo-300',
    defiant: 'bg-warning/20 text-warning',
  }
  
  return `${base} ${variants[props.variant]}`
})
</script>

