<template>
  <Teleport to="body">
    <div
      v-if="modelValue"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
      @click.self="$emit('update:modelValue', false)"
    >
      <div class="bg-surface border border-border rounded-lg shadow-soft max-w-2xl w-full mx-4 p-6">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-xl font-heading font-bold text-text">{{ title }}</h2>
          <button
            @click="$emit('update:modelValue', false)"
            class="text-muted hover:text-accent transition-colors"
          >
            ✕
          </button>
        </div>
        <slot />
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
interface Props {
  modelValue: boolean
  title?: string
}

defineProps<Props>()

defineEmits<{
  'update:modelValue': [value: boolean]
}>()
</script>

