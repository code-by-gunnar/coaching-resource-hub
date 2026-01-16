<script setup>
import DefaultTheme from 'vitepress/theme'
import AuthNav from './components/AuthNav.vue'
import SEOHead from './components/SEOHead.vue'
import GoogleAnalytics from './components/GoogleAnalytics.vue'

const { Layout } = DefaultTheme
</script>

<template>
  <!-- Skip link for keyboard navigation (accessibility) -->
  <a href="#VPContent" class="skip-link" aria-label="Skip to main content">
    Skip to main content
  </a>

  <SEOHead />
  <GoogleAnalytics />
  <Layout>
    <!-- Desktop auth nav -->
    <template #nav-bar-content-after>
      <div class="auth-nav-wrapper desktop-only" role="navigation" aria-label="User navigation">
        <AuthNav />
      </div>
    </template>
    
    <!-- Mobile menu with auth at top -->
    <template #nav-screen-content-before>
      <div class="mobile-auth-nav" role="navigation" aria-label="User navigation">
        <AuthNav />
      </div>
    </template>
  </Layout>
</template>

<style scoped>
.auth-nav-wrapper {
  margin-left: var(--space-4, 1rem);
}

.desktop-only {
  display: block;
}

.mobile-auth-nav {
  padding: var(--space-3, 0.75rem) var(--space-4, 1rem);
  border-bottom: 1px solid var(--vp-c-divider);
  background: var(--vp-c-bg-soft);
}

@media (max-width: 768px) {
  .desktop-only {
    display: none;
  }
}

@media (min-width: 769px) {
  .mobile-auth-nav {
    display: none;
  }
}
</style>

<style>
/* Global fix for content being hidden under navbar */
.VPContent {
  padding-top: calc(var(--vp-nav-height) + 24px) !important;
}

/* Adjust for different page types */
.VPDoc .VPContent,
.VPHome .VPContent {
  padding-top: var(--vp-nav-height) !important;
}

/* Fix for home page hero */
.VPHero {
  padding-top: calc(var(--vp-nav-height) + 48px) !important;
}

@media (max-width: 768px) {
  .VPContent {
    padding-top: calc(var(--vp-nav-height) + 16px) !important;
  }
  
  .VPHero {
    padding-top: calc(var(--vp-nav-height) + 32px) !important;
  }
}
</style>
