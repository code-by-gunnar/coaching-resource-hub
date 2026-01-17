<template>
  <div class="content-teaser">
    <!-- SEO-friendly header that's always visible -->
    <header class="teaser-header">
      <h1>{{ title }}</h1>
      <p v-if="description" class="teaser-description">{{ description }}</p>
    </header>

    <!-- Teaser preview with fade -->
    <div class="teaser-preview" v-if="$slots.preview">
      <slot name="preview" />
      <div class="teaser-fade"></div>
    </div>

    <!-- Lock card with CTA -->
    <div class="lock-card">
      <div class="lock-icon">
        <LockClosedIcon class="lock-icon-svg" aria-hidden="true" />
      </div>

      <h2>Premium Content</h2>
      <p class="lock-subtitle">Create a free account to unlock this content and more</p>

      <ul class="benefits-list">
        <li>
          <CheckCircleIcon class="benefit-icon" aria-hidden="true" />
          <span>Full training materials and techniques</span>
        </li>
        <li>
          <CheckCircleIcon class="benefit-icon" aria-hidden="true" />
          <span>Interactive coaching assessments</span>
        </li>
        <li>
          <CheckCircleIcon class="benefit-icon" aria-hidden="true" />
          <span>Professional templates and frameworks</span>
        </li>
        <li>
          <CheckCircleIcon class="benefit-icon" aria-hidden="true" />
          <span>Progress tracking and insights</span>
        </li>
      </ul>

      <div class="cta-actions">
        <a :href="signUpUrl" class="cta-btn primary">
          <span>Create Free Account</span>
          <ArrowRightIcon class="cta-arrow" aria-hidden="true" />
        </a>

        <p class="sign-in-prompt">
          Already have an account?
          <a :href="signInUrl" class="sign-in-link">Sign in</a>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useData } from 'vitepress'
import {
  LockClosedIcon,
  CheckCircleIcon,
  ArrowRightIcon
} from '@heroicons/vue/24/outline'

const props = defineProps({
  title: {
    type: String,
    default: ''
  },
  description: {
    type: String,
    default: ''
  },
  redirect: {
    type: String,
    default: ''
  }
})

// Get current page path for redirect
const { page } = useData()
const currentPath = computed(() => props.redirect || page.value.relativePath.replace(/\.md$/, ''))

// Build URLs with redirect parameter
const signUpUrl = computed(() => {
  const redirectPath = currentPath.value.startsWith('/') ? currentPath.value : `/docs/${currentPath.value}`
  return `/docs/auth/?redirect=${encodeURIComponent(redirectPath)}`
})

const signInUrl = computed(() => {
  const redirectPath = currentPath.value.startsWith('/') ? currentPath.value : `/docs/${currentPath.value}`
  return `/docs/auth/?redirect=${encodeURIComponent(redirectPath)}`
})
</script>

<style scoped>
.content-teaser {
  max-width: 800px;
  margin-left: auto;
  margin-right: auto;
  padding: var(--space-6);
  box-sizing: border-box;
}

.teaser-header {
  text-align: center;
  margin-bottom: var(--space-8);
}

.teaser-header h1 {
  font-size: var(--font-size-3xl);
  font-weight: var(--font-weight-bold);
  color: var(--vp-c-text-1);
  margin: 0 0 var(--space-3) 0;
  line-height: var(--line-height-tight);
}

.teaser-description {
  font-size: var(--font-size-lg);
  color: var(--vp-c-text-2);
  margin: 0;
  line-height: var(--line-height-relaxed);
}

/* Teaser preview with gradient fade */
.teaser-preview {
  position: relative;
  max-height: 300px;
  overflow: hidden;
  margin-bottom: var(--space-8);
  border-radius: var(--radius-xl);
  background: var(--vp-c-bg-soft);
  padding: var(--space-6);
}

.teaser-preview :deep(h2),
.teaser-preview :deep(h3) {
  margin-top: 0;
}

.teaser-fade {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 150px;
  background: linear-gradient(
    to bottom,
    transparent 0%,
    var(--vp-c-bg-soft) 70%,
    var(--vp-c-bg-soft) 100%
  );
  pointer-events: none;
}

/* Lock card */
.lock-card {
  background: linear-gradient(135deg, var(--vp-c-brand-soft) 0%, var(--vp-c-bg-soft) 50%, var(--vp-c-brand-softer) 100%);
  border: 1px solid var(--vp-c-divider);
  border-radius: var(--radius-2xl);
  padding: var(--space-10);
  text-align: center;
  position: relative;
  overflow: hidden;
}

.lock-card::before {
  content: '';
  position: absolute;
  top: -50%;
  right: -50%;
  width: 100%;
  height: 200%;
  background: radial-gradient(ellipse, rgba(102, 126, 234, 0.08) 0%, transparent 70%);
  pointer-events: none;
}

.lock-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 64px;
  height: 64px;
  background: var(--vp-c-brand-soft);
  border-radius: var(--radius-full);
  margin-bottom: var(--space-4);
}

.lock-icon-svg {
  width: 32px;
  height: 32px;
  color: var(--vp-c-brand-1);
}

.dark .lock-icon-svg {
  color: #818cf8;
}

.lock-card h2 {
  font-size: var(--font-size-2xl);
  font-weight: var(--font-weight-bold);
  color: var(--vp-c-text-1);
  margin: 0 0 var(--space-2) 0;
  border: none;
  padding: 0;
}

.lock-subtitle {
  font-size: var(--font-size-base);
  color: var(--vp-c-text-2);
  margin: 0 0 var(--space-6) 0;
}

/* Benefits list */
.benefits-list {
  list-style: none;
  padding: 0;
  margin: 0 0 var(--space-8) 0;
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  max-width: 400px;
  margin-left: auto;
  margin-right: auto;
}

.benefits-list li {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  text-align: left;
  padding: var(--space-2) var(--space-3);
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-radius: var(--radius-lg);
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.dark .benefits-list li {
  background: rgba(0, 0, 0, 0.2);
  border-color: rgba(255, 255, 255, 0.05);
}

.benefit-icon {
  width: 20px;
  height: 20px;
  color: var(--color-success);
  flex-shrink: 0;
}

.benefits-list span {
  font-size: var(--font-size-sm);
  color: var(--vp-c-text-1);
  font-weight: var(--font-weight-medium);
}

/* CTA actions */
.cta-actions {
  position: relative;
  z-index: 1;
}

.cta-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  padding: var(--space-4) var(--space-8);
  border-radius: var(--radius-full);
  font-weight: var(--font-weight-semibold);
  font-size: var(--font-size-base);
  text-decoration: none;
  transition: all var(--duration-normal) var(--ease-in-out);
}

.cta-btn.primary {
  background: linear-gradient(45deg, var(--vp-c-brand-1), var(--vp-c-brand-2));
  color: white;
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
}

.cta-btn.primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 35px rgba(102, 126, 234, 0.4);
}

.cta-arrow {
  width: 18px;
  height: 18px;
  transition: transform var(--duration-normal) var(--ease-in-out);
}

.cta-btn:hover .cta-arrow {
  transform: translateX(3px);
}

.sign-in-prompt {
  margin-top: var(--space-4);
  font-size: var(--font-size-sm);
  color: var(--vp-c-text-2);
}

.sign-in-link {
  color: var(--vp-c-brand-1);
  font-weight: var(--font-weight-medium);
  text-decoration: none;
}

.sign-in-link:hover {
  text-decoration: underline;
}

/* Mobile responsive */
@media (max-width: 768px) {
  .content-teaser {
    padding: var(--space-4);
  }

  .teaser-header h1 {
    font-size: var(--font-size-2xl);
  }

  .teaser-description {
    font-size: var(--font-size-base);
  }

  .teaser-preview {
    max-height: 200px;
    padding: var(--space-4);
  }

  .lock-card {
    padding: var(--space-6);
  }

  .lock-icon {
    width: 56px;
    height: 56px;
  }

  .lock-icon-svg {
    width: 28px;
    height: 28px;
  }

  .lock-card h2 {
    font-size: var(--font-size-xl);
  }

  .cta-btn {
    padding: var(--space-3) var(--space-6);
    font-size: var(--font-size-sm);
  }

  .benefits-list li {
    padding: var(--space-2);
  }

  .benefits-list span {
    font-size: var(--font-size-xs);
  }
}
</style>
