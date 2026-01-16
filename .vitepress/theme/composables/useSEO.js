import { useData, useRoute } from 'vitepress'
import { computed } from 'vue'

export function useSEO() {
  const { page, frontmatter } = useData()
  const route = useRoute()

  // Generate page-specific SEO data
  const seoData = computed(() => {
    const title = frontmatter.value.title || page.value.title || 'Your Coaching Hub'
    const description = frontmatter.value.description || page.value.description || 'Professional coaching knowledge base, educational resources, and interactive assessments'
    const path = route.path
    const url = `https://www.yourcoachinghub.co.uk${path}`
    
    // Generate keywords based on path and content
    const pathKeywords = generateKeywordsFromPath(path)
    const contentKeywords = frontmatter.value.keywords || ''
    const keywords = [contentKeywords, pathKeywords].filter(Boolean).join(', ')
    
    return {
      title: `${title} | Your Coaching Hub`,
      description,
      keywords,
      url,
      path,
      ogImage: frontmatter.value.ogImage || 'https://www.yourcoachinghub.co.uk/img/og-image.jpg'
    }
  })

  return {
    seoData
  }
}

function generateKeywordsFromPath(path) {
  const keywordMap = {
    '/docs/concepts/nlp-techniques/': 'NLP techniques, neuro-linguistic programming, anchoring, reframing, coaching methods',
    '/docs/concepts/solution-focused/': 'solution-focused coaching, brief therapy, scaling questions, coaching approaches',
    '/docs/concepts/advanced-nlp/': 'advanced NLP, meta model, milton model, timeline therapy, coaching mastery',
    '/docs/concepts/foundations-connection/': 'coaching foundations, rapport building, active listening, coaching relationship',
    '/docs/business/': 'coaching business, coach marketing, pricing, business development, coaching practice',
    '/docs/training/': 'coaching education, study materials, professional development, coaching skills',
    '/docs/certification/': 'coaching standards, ICF framework, professional coaching, industry standards',
    '/docs/assessments/': 'coaching assessments, self-assessment, coaching evaluation, progress tracking'
  }
  
  // Find matching path keywords
  for (const [pathPattern, keywords] of Object.entries(keywordMap)) {
    if (path.includes(pathPattern)) {
      return keywords
    }
  }
  
  // Generate keywords from path segments
  const segments = path.split('/').filter(Boolean)
  return segments.join(', ')
}

// Generate structured data for specific page types
export function useStructuredData() {
  const { page, frontmatter } = useData()
  const route = useRoute()

  const structuredData = computed(() => {
    const path = route.path
    const title = frontmatter.value.title || page.value.title
    const description = frontmatter.value.description || page.value.description
    
    // Article/Educational structured data
    if (path.includes('/docs/concepts/') || path.includes('/docs/training/')) {
      return {
        '@context': 'https://schema.org',
        '@type': 'EducationalOccupationalProgram',
        name: title,
        description: description,
        provider: {
          '@type': 'Organization',
          name: 'Your Coaching Hub',
          url: 'https://www.yourcoachinghub.co.uk'
        },
        url: `https://www.yourcoachinghub.co.uk${path}`,
        courseMode: 'online',
        teaches: extractSkills(title, description),
        educationalLevel: 'Professional',
        audience: {
          '@type': 'Audience',
          audienceType: 'Professional Coaches'
        }
      }
    }
    
    // Business/Service structured data
    if (path.includes('/docs/business/')) {
      return {
        '@context': 'https://schema.org',
        '@type': 'Service',
        name: title,
        description: description,
        provider: {
          '@type': 'Organization',
          name: 'Your Coaching Hub',
          url: 'https://www.yourcoachinghub.co.uk'
        },
        serviceType: 'Business Coaching Resources',
        areaServed: 'Worldwide',
        url: `https://www.yourcoachinghub.co.uk${path}`
      }
    }
    
    // Assessment structured data
    if (path.includes('/docs/assessments/')) {
      return {
        '@context': 'https://schema.org',
        '@type': 'SurveyAction',
        name: title,
        description: description,
        target: `https://www.yourcoachinghub.co.uk${path}`,
        agent: {
          '@type': 'Organization',
          name: 'Your Coaching Hub'
        }
      }
    }
    
    // Default article structured data
    return {
      '@context': 'https://schema.org',
      '@type': 'Article',
      headline: title,
      description: description,
      url: `https://www.yourcoachinghub.co.uk${path}`,
      author: {
        '@type': 'Organization',
        name: 'Your Coaching Hub'
      },
      publisher: {
        '@type': 'Organization',
        name: 'Your Coaching Hub',
        logo: {
          '@type': 'ImageObject',
          url: 'https://www.yourcoachinghub.co.uk/img/logo.png'
        }
      }
    }
  })

  return {
    structuredData
  }
}

function extractSkills(title, description) {
  const skillKeywords = [
    'coaching', 'NLP', 'GROW model', 'active listening', 'questioning techniques',
    'rapport building', 'goal setting', 'solution-focused', 'reframing', 'anchoring'
  ]
  
  const content = `${title} ${description}`.toLowerCase()
  return skillKeywords.filter(skill => content.includes(skill.toLowerCase()))
}