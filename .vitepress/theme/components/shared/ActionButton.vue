<template>
  <component 
    :is="tag"
    :href="href"
    :to="to"
    :type="tag === 'button' ? type : undefined"
    :disabled="disabled || undefined"
    :aria-disabled="disabled || undefined"
    :aria-label="ariaLabel"
    @click="handleClick"
    :class="['action-button', variant, { 'full-width': fullWidth, 'disabled': disabled }]"
  >
    <span v-if="icon" class="button-icon" aria-hidden="true">{{ icon }}</span>
    <slot />
  </component>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  // Variant styling
  variant: {
    type: String,
    default: 'primary',
    validator: (value) => ['primary', 'secondary', 'gray', 'success', 'active', 'inactive'].includes(value)
  },
  
  // Link props
  href: String,
  to: String,
  
  // Button type (submit, button, reset)
  type: {
    type: String,
    default: 'button'
  },
  
  // Icon (emoji or text)
  icon: String,
  
  // Layout
  fullWidth: {
    type: Boolean,
    default: false
  },
  
  // Disabled state
  disabled: {
    type: Boolean,
    default: false
  },
  
  // Accessibility
  ariaLabel: String
})

const emit = defineEmits(['click'])

// Determine component tag
const tag = computed(() => {
  if (props.href) return 'a'
  if (props.to) return 'router-link'
  return 'button'
})

const handleClick = (event) => {
  if (!props.disabled) {
    emit('click', event)
  } else {
    event.preventDefault()
  }
}
</script>

<style scoped>
.action-button {
  padding: var(--space-3, 12px);
  background: var(--color-brand-primary, #3b82f6);
  color: white;
  border: none;
  border-radius: var(--radius-md, 6px);
  cursor: pointer;
  font-size: var(--font-size-sm, 0.9rem);
  font-weight: var(--font-weight-medium, 500);
  transition: var(--transition-all, all 0.3s ease);
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2, 0.5rem);
  text-align: center;
  min-width: 140px;
}

.action-button:hover:not(.disabled) {
  background: var(--color-brand-primary-hover, #2563eb);
  transform: translateY(-1px);
}

.action-button:focus-visible {
  outline: var(--focus-ring, 2px solid var(--color-brand-primary));
  outline-offset: var(--focus-ring-offset, 2px);
}

.action-button.secondary {
  background: var(--color-gray-500, #6b7280);
}

.action-button.secondary:hover:not(.disabled) {
  background: var(--color-gray-600, #4b5563);
}

.action-button.gray {
  background: var(--color-gray-500, #6b7280);
}

.action-button.gray:hover:not(.disabled) {
  background: var(--color-gray-600, #4b5563);
}

.action-button.success {
  background: var(--color-success, #10b981);
}

.action-button.success:hover:not(.disabled) {
  background: var(--color-success-hover, #059669);
}

.action-button.active {
  background: var(--color-success-bg, var(--vp-c-green-soft));
  color: var(--color-success, var(--vp-c-green));
  border: 1px solid var(--color-success, var(--vp-c-green));
}

.action-button.active:hover:not(.disabled) {
  background: var(--color-success, var(--vp-c-green));
  color: white;
}

.action-button.inactive {
  background: var(--color-error-bg, var(--vp-c-danger-soft));
  color: var(--color-error, var(--vp-c-danger));
  border: 1px solid var(--color-error, var(--vp-c-danger));
}

.action-button.inactive:hover:not(.disabled) {
  background: var(--color-error, var(--vp-c-danger));
  color: white;
}

.action-button.full-width {
  width: 100%;
}

.action-button.disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none !important;
}

.button-icon {
  font-size: 1rem;
}

/* Ensure consistent styling in VitePress */
.action-button:visited {
  color: white;
}
</style>
