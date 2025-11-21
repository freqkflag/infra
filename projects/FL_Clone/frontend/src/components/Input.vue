<template>
  <div class="flex flex-col gap-2">
    <label v-if="label" :for="id" class="text-sm text-muted">
      {{ label }}
    </label>
    <input
      :id="id"
      :type="type"
      :value="modelValue"
      :placeholder="placeholder"
      :disabled="disabled"
      :class="inputClasses"
      @input="$emit('update:modelValue', ($event.target as HTMLInputElement).value)"
    />
    <span v-if="error" class="text-xs text-danger">{{ error }}</span>
  </div>
</template>

<script setup lang="ts">
interface Props {
  id?: string
  label?: string
  type?: string
  modelValue: string | number
  placeholder?: string
  disabled?: boolean
  error?: string
}

withDefaults(defineProps<Props>(), {
  type: 'text',
  disabled: false,
})

defineEmits<{
  'update:modelValue': [value: string | number]
}>()

const inputClasses = 'bg-surfaceAlt border border-border rounded-md px-4 py-2 text-text focus:outline-none focus:border-accent focus:ring-2 focus:ring-accent/20 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed'
</script>

