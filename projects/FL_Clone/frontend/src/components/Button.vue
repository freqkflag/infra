<template>
  <button
    :class="buttonClasses"
    :disabled="disabled"
    @click="$emit('click', $event)"
  >
    <slot />
  </button>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  variant?: 'primary' | 'secondary' | 'ghost' | 'outline'
  size?: 'sm' | 'md' | 'lg'
  disabled?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
  disabled: false,
})

const buttonClasses = computed(() => {
  const base = 'font-heading font-semibold transition-all duration-200 ease-out flex items-center justify-center gap-2 active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed'
  
  const variants = {
    primary: 'bg-primary text-background rounded-full hover:bg-primarySoft hover:shadow-neon-primary',
    secondary: 'bg-transparent text-accent border border-accent rounded-full hover:bg-accent/10 hover:shadow-neon-accent',
    outline: 'bg-transparent border border-primarySoft/50 text-primarySoft hover:border-primary hover:text-primary hover:shadow-neon-primary rounded-md',
    ghost: 'bg-transparent text-muted hover:text-accent relative underline-animation',
  }
  
  const sizes = {
    sm: 'text-sm px-3 py-1.5',
    md: 'text-base px-6 py-2.5',
    lg: 'text-lg px-8 py-3.5',
  }
  
  return `${base} ${variants[props.variant]} ${sizes[props.size]}`
})
</script>

