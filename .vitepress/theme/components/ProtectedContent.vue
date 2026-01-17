<template>
  <div class="protected-content">
    <!-- Show teaser when not authenticated -->
    <ContentTeaser
      v-if="!user"
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

// Get user auth state
const { user } = useAuth()

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
</style>

