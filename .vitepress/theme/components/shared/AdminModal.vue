<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="isOpen" class="modal-overlay" @click="handleOverlayClick">
        <div class="modal-container" :data-size="size" @click.stop>
          <!-- Modal Header -->
          <div class="modal-header">
            <h2 class="modal-title">
              <span v-if="icon" class="modal-icon">{{ icon }}</span>
              {{ title }}
            </h2>
            <button @click="close" class="modal-close" aria-label="Close modal">
              ✕
            </button>
          </div>

          <!-- Modal Body -->
          <div class="modal-body">
            <slot>
              <!-- Default slot for content -->
            </slot>
          </div>

          <!-- Modal Footer (optional) -->
          <div v-if="$slots.footer || showDefaultFooter" class="modal-footer">
            <slot name="footer">
              <ActionButton v-if="showDefaultFooter" @click="close" variant="secondary">
                Close
              </ActionButton>
            </slot>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { watch, onMounted, onUnmounted } from 'vue'
import ActionButton from './ActionButton.vue'

const props = defineProps({
  isOpen: {
    type: Boolean,
    required: true
  },
  title: {
    type: String,
    default: 'Details'
  },
  icon: {
    type: String,
    default: ''
  },
  closeOnOverlay: {
    type: Boolean,
    default: true
  },
  showDefaultFooter: {
    type: Boolean,
    default: false
  },
  size: {
    type: String,
    default: 'medium',
    validator: (value) => ['small', 'medium', 'large', 'extra-large', 'full'].includes(value)
  }
})

const emit = defineEmits(['close'])

const close = () => {
  emit('close')
}

const handleOverlayClick = () => {
  if (props.closeOnOverlay) {
    close()
  }
}

// Handle escape key
const handleEscape = (e) => {
  if (e.key === 'Escape' && props.isOpen) {
    close()
  }
}

// Prevent body scroll when modal is open
watch(() => props.isOpen, (newValue) => {
  if (newValue) {
    document.body.style.overflow = 'hidden'
  } else {
    document.body.style.overflow = ''
  }
})

onMounted(() => {
  document.addEventListener('keydown', handleEscape)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleEscape)
  document.body.style.overflow = ''
})
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(2px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  padding: 20px;
}

.modal-container {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-border);
  border-radius: 12px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  display: flex;
  flex-direction: column;
  max-height: 90vh;
  position: relative;
  width: 100%;
}

/* Size variants */
.modal-container {
  max-width: 600px; /* Default medium */
}

.modal-overlay:has(.modal-container[data-size="small"]) .modal-container {
  max-width: 400px;
}

.modal-overlay:has(.modal-container[data-size="large"]) .modal-container {
  max-width: 900px;
}

.modal-overlay:has(.modal-container[data-size="extra-large"]) .modal-container {
  max-width: 1200px;
  max-height: 95vh;
}

.modal-overlay:has(.modal-container[data-size="full"]) .modal-container {
  max-width: 95%;
  max-height: 95vh;
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 24px;
  border-bottom: 1px solid var(--vp-c-border);
}

.modal-title {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: var(--vp-c-text-1);
  display: flex;
  align-items: center;
  gap: 8px;
}

.modal-icon {
  font-size: 24px;
}

.modal-close {
  background: none;
  border: none;
  color: var(--vp-c-text-2);
  cursor: pointer;
  font-size: 20px;
  padding: 4px 8px;
  border-radius: 4px;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
}

.modal-close:hover {
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
}

.modal-body {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
}

.modal-footer {
  padding: 16px 24px;
  border-top: 1px solid var(--vp-c-border);
  display: flex;
  gap: 12px;
  justify-content: flex-end;
}

/* Transition animations */
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.2s ease;
}

.modal-enter-active .modal-container,
.modal-leave-active .modal-container {
  transition: transform 0.2s ease, opacity 0.2s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-from .modal-container,
.modal-leave-to .modal-container {
  transform: scale(0.9);
  opacity: 0;
}

/* Responsive */
@media (max-width: 768px) {
  .modal-overlay {
    padding: 10px;
  }

  .modal-container {
    max-width: 100%;
    max-height: 100%;
    margin: 0;
  }

  .modal-header {
    padding: 16px 20px;
  }

  .modal-body {
    padding: 20px;
  }

  .modal-title {
    font-size: 18px;
  }
}
</style>