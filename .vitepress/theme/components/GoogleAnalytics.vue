<template>
  <div></div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useRoute } from 'vitepress'
import { useAnalytics } from '../composables/useAnalytics.js'

const route = useRoute()

// Replace with your actual GA4 Measurement ID
const GA_MEASUREMENT_ID = 'G-XXXXXXXXXX'

onMounted(() => {
  // Initialize Google Analytics
  if (typeof window !== 'undefined' && !window.gtag) {
    // Load Google Analytics script
    const script = document.createElement('script')
    script.async = true
    script.src = `https://www.googletagmanager.com/gtag/js?id=${GA_MEASUREMENT_ID}`
    document.head.appendChild(script)
    
    // Initialize gtag
    window.dataLayer = window.dataLayer || []
    window.gtag = function() {
      window.dataLayer.push(arguments)
    }
    window.gtag('js', new Date())
    window.gtag('config', GA_MEASUREMENT_ID, {
      // Enhanced ecommerce and user engagement
      send_page_view: true,
      cookie_domain: 'www.yourcoachinghub.co.uk',
      cookie_flags: 'SameSite=Strict;Secure',
      // Custom parameters for coaching site
      custom_map: {
        dimension1: 'page_category',
        dimension2: 'content_type'
      }
    })
    
    // Track page category based on URL
    const pageCategory = getPageCategory(route.path)
    window.gtag('event', 'page_view', {
      page_category: pageCategory,
      content_type: getContentType(route.path)
    })
  }
})

// Get analytics composable
const { trackEvent } = useAnalytics()

// Watch for route changes to track page views
if (typeof window !== 'undefined') {
  // Listen for route changes
  window.addEventListener('popstate', () => {
    if (window.gtag) {
      const pageCategory = getPageCategory(route.path)
      trackEvent('page_view', {
        page_location: window.location.href,
        page_category: pageCategory,
        content_type: getContentType(route.path)
      })
    }
  })
}

function getPageCategory(path) {
  if (path.includes('/docs/concepts/')) return 'concepts'
  if (path.includes('/docs/business/')) return 'business'
  if (path.includes('/docs/training/')) return 'training'
  if (path.includes('/docs/certification/')) return 'certification'
  if (path.includes('/docs/assessments/')) return 'assessments'
  if (path.includes('/docs/resources/')) return 'resources'
  return 'general'
}

function getContentType(path) {
  if (path.includes('/nlp-techniques/')) return 'nlp'
  if (path.includes('/solution-focused/')) return 'solution_focused'
  if (path.includes('/advanced-nlp/')) return 'advanced_nlp'
  if (path.includes('/foundations-connection/')) return 'foundations'
  return 'page'
}
</script>