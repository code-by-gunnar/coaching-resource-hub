<template>
  <div></div>
</template>

<script setup>
import { useData } from 'vitepress'
import { useSEO, useStructuredData } from '../composables/useSEO.js'
import { onMounted, watch } from 'vue'

const { frontmatter } = useData()
const { seoData } = useSEO()
const { structuredData } = useStructuredData()

// Function to update head elements
const updateHead = () => {
  if (typeof document === 'undefined') return
  
  // Update title
  document.title = seoData.value.title
  
  // Update or create meta tags
  updateMetaTag('description', seoData.value.description)
  updateMetaTag('keywords', seoData.value.keywords)
  
  // Update canonical link
  updateCanonicalLink(seoData.value.url)
  
  // Update Open Graph tags
  updateMetaTag('og:title', seoData.value.title, 'property')
  updateMetaTag('og:description', seoData.value.description, 'property')
  updateMetaTag('og:url', seoData.value.url, 'property')
  updateMetaTag('og:image', seoData.value.ogImage, 'property')
  
  // Update Twitter Card tags
  updateMetaTag('twitter:title', seoData.value.title)
  updateMetaTag('twitter:description', seoData.value.description)
  updateMetaTag('twitter:image', seoData.value.ogImage)
  
  // Update structured data
  updateStructuredData(structuredData.value)
}

const updateMetaTag = (name, content, attribute = 'name') => {
  if (!content) return
  
  let meta = document.querySelector(`meta[${attribute}="${name}"]`)
  if (!meta) {
    meta = document.createElement('meta')
    meta.setAttribute(attribute, name)
    document.head.appendChild(meta)
  }
  meta.setAttribute('content', content)
}

const updateCanonicalLink = (url) => {
  let canonical = document.querySelector('link[rel="canonical"]')
  if (!canonical) {
    canonical = document.createElement('link')
    canonical.setAttribute('rel', 'canonical')
    document.head.appendChild(canonical)
  }
  canonical.setAttribute('href', url)
}

const updateStructuredData = (data) => {
  // Remove existing structured data
  const existing = document.querySelector('script[type="application/ld+json"][data-seo]')
  if (existing) {
    existing.remove()
  }
  
  // Add new structured data
  const script = document.createElement('script')
  script.type = 'application/ld+json'
  script.setAttribute('data-seo', 'true')
  script.textContent = JSON.stringify(data)
  document.head.appendChild(script)
}

onMounted(() => {
  updateHead()
})

// Watch for route changes
watch(seoData, () => {
  updateHead()
}, { deep: true })
</script>