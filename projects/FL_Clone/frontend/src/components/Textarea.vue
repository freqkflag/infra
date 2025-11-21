<template>
  <div class="flex flex-col gap-2">
    <label v-if="label" :for="id" class="text-sm text-muted">
      {{ label }}
    </label>
    <textarea
      :id="id"
      :value="modelValue"
      :placeholder="placeholder"
      :disabled="disabled"
      :rows="rows"
      :class="textareaClasses"
      @input="$emit('update:modelValue', ($event.target as HTMLTextAreaElement).value)"
    />
    <span v-if="error" class="text-xs text-danger">{{ error }}</span>
  </div>
</template>

<script setup lang="ts">
interface Props {
  id?: string
  label?: string
  modelValue: string
  placeholder?: string
  disabled?: boolean
  rows?: number
  error?: string
}

withDefaults(defineProps<Props>(), {
  rows: 4,
  disabled: false,
})

defineEmits<{
  'update:modelValue': [value: string]
}>()

const textareaClasses = 'bg-surfaceAlt border border-border rounded-md px-4 py-2 text-text focus:outline-none focus:border-accent focus:ring-2 focus:ring-accent/20 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed resize-y'
</script>

