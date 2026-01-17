<template>
  <div class="protected-content">
    <!-- Show loading state while auth is initializing -->
    <div v-if="!authInitialized" class="auth-loading">
      <div class="loading-spinner"></div>
      <p>Loading...</p>
    </div>

    <!-- Show teaser when not authenticated -->
    <ContentTeaser
      v-else-if="!user"
      :title="title"
      :description="description"
    >
      <template #preview v-if="$slots.preview">
        <slot name="preview" />
      </template>
    </ContentTeaser>

    <!-- Show full content when authenticated -->
    <div v-else class="full-content">
      <slot />
    </div>
  </div>
</template>

<script setup>
import { useData } from 'vitepress'
import { useAuth } from '../composables/useAuth.js'
import ContentTeaser from './ContentTeaser.vue'

const props = defineProps({
  // Allow overriding title/description from props
  // Otherwise will use frontmatter
  title: {
    type: String,
    default: ''
  },
  description: {
    type: String,
    default: ''
  }
})

// Get user auth state and initialization status
const { user, authInitialized } = useAuth()

// Get frontmatter data
const { frontmatter } = useData()

// Use prop values if provided, otherwise use frontmatter
const title = props.title || frontmatter.value.title || 'Premium Content'
const description = props.description || frontmatter.value.description || ''
</script>

<style scoped>
.protected-content {
  width: 100%;
  max-width: 100%;
}

.full-content {
  width: 100%;
}

.auth-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 200px;
  color: var(--vp-c-text-2);
}

.auth-loading p {
  margin-top: var(--space-4);
  font-size: var(--font-size-sm);
}

.loading-spinner {
  width: 32px;
  height: 32px;
  border: 3px solid var(--vp-c-divider);
  border-top-color: var(--vp-c-brand-1);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
</style>

