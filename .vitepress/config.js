import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: 'Your Coaching Hub',
  description: 'Coaching Made Simple - Professional coaching knowledge base, educational resources, and interactive assessment tools all in one place',
  
  // SEO and URL configuration
  cleanUrls: true,
  sitemap: {
    hostname: 'https://www.yourcoachinghub.co.uk',
    transformItems: (items) => {
      // Filter out any development documentation or unwanted pages
      return items.filter(item => {
        const url = item.url
        // Only include docs pages and main site pages
        return url === '/' || 
               url.startsWith('/docs/') || 
               (!url.includes('/scripts/') && 
                !url.includes('/tests/') &&
                !url.includes('README') &&
                !url.includes('SEO_SETUP') &&
                !url.includes('CLAUDE') &&
                !url.includes('.json') &&
                !url.includes('node_modules') &&
                !url.includes('playwright-report') &&
                !url.includes('test-results'))
      })
    }
  },
  
  // Comprehensive head configuration for SEO
  head: [
    // Favicon and icons
    ['link', { rel: 'icon', href: '/favicon.ico' }],
    ['link', { rel: 'apple-touch-icon', sizes: '180x180', href: '/apple-touch-icon.png' }],
    
    // SEO Meta Tags
    ['meta', { name: 'theme-color', content: '#667eea' }],
    ['meta', { name: 'author', content: 'Your Coaching Hub' }],
    ['meta', { name: 'keywords', content: 'coaching resources, coaching knowledge base, GROW model, NLP techniques, coaching assessments, coaching study materials, business coaching resources, life coaching education, executive coaching insights, coaching workbook' }],
    ['meta', { name: 'robots', content: 'index, follow' }],
    
    // Open Graph / Facebook
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:site_name', content: 'Your Coaching Hub' }],
    ['meta', { property: 'og:title', content: 'Your Coaching Hub - Professional Coaching Knowledge Base & Resources' }],
    ['meta', { property: 'og:description', content: 'Comprehensive coaching knowledge base and educational resources. Study NLP techniques, GROW model, assessments, and business development tools.' }],
    ['meta', { property: 'og:image', content: 'https://www.yourcoachinghub.co.uk/img/og-image.jpg' }],
    ['meta', { property: 'og:url', content: 'https://www.yourcoachinghub.co.uk' }],
    
    // Twitter Card
    ['meta', { name: 'twitter:card', content: 'summary_large_image' }],
    ['meta', { name: 'twitter:title', content: 'Your Coaching Hub - Professional Coaching Knowledge Base & Resources' }],
    ['meta', { name: 'twitter:description', content: 'Comprehensive coaching knowledge base and educational resources. Study NLP techniques, GROW model, assessments, and business development tools.' }],
    ['meta', { name: 'twitter:image', content: 'https://www.yourcoachinghub.co.uk/img/og-image.jpg' }],
    
    // Schema.org structured data
    ['script', { type: 'application/ld+json' }, JSON.stringify({
      '@context': 'https://schema.org',
      '@type': 'EducationalOrganization',
      name: 'Your Coaching Hub',
      description: 'Professional coaching knowledge base, educational resources, and interactive assessment tools',
      url: 'https://www.yourcoachinghub.co.uk',
      logo: 'https://www.yourcoachinghub.co.uk/img/logo.png',
      sameAs: [
        'https://forwardfocus-coaching.co.uk'
      ],
      offers: {
        '@type': 'EducationalOccupationalProgram',
        name: 'Coaching Knowledge & Assessment Resources',
        description: 'Comprehensive coaching study materials, interactive assessments, and business development workbook',
        provider: {
          '@type': 'Organization',
          name: 'Your Coaching Hub'
        }
      }
    })],
    
    // Google Analytics - Configured via VITE_GA_MEASUREMENT_ID env variable
    // See GoogleAnalytics.vue component for implementation
    
    // Additional SEO enhancements
    ['meta', { name: 'viewport', content: 'width=device-width, initial-scale=1.0' }],
    ['link', { rel: 'canonical', href: 'https://www.yourcoachinghub.co.uk' }]
  ],

  // Theme configuration
  themeConfig: {
    // Site logo with light/dark mode support
    logo: {
      light: '/img/logo.png',
      dark: '/img/logo.png'
    },
    
    // Navigation - sophisticated nested structure with beautiful emojis
    nav: [
      {
        text: '📚 Learn',
        items: [
          { text: 'Get Started', link: '/docs/getting-started/' },
          {
            text: 'Training',
            items: [
              { text: 'Coaching Basics', link: '/docs/training/basics' },
              { text: 'Advanced Methods', link: '/docs/training/advanced' },
              { text: 'Interventions', link: '/docs/training/interventions/' },
              { text: 'Ethics in Practice', link: '/docs/training/ethics/' },
              { text: 'Techniques', link: '/docs/training/techniques' }
            ]
          },
          {
            text: 'Concepts',
            items: [
              { text: 'Reference Guide', link: '/docs/concepts/' },
              { text: 'Foundations & Connection', link: '/docs/concepts/foundations-connection/' },
              { text: 'NLP Techniques', link: '/docs/concepts/nlp-techniques/' },
              { text: 'Solution-Focused Approaches', link: '/docs/concepts/solution-focused/' },
              { text: 'Advanced NLP & Meta Models', link: '/docs/concepts/advanced-nlp/' }
            ]
          }
        ]
      },
      {
        text: '🎯 Practice',
        items: [
          { text: 'Assessments', link: '/docs/assessments/' }
        ]
      },
      {
        text: '🏆 Certification',
        items: [
          { text: 'Overview', link: '/docs/certification/overview' },
          { text: 'Requirements', link: '/docs/certification/requirements' },
          { text: 'Assessment', link: '/docs/certification/assessment' }
        ]
      },
      {
        text: '🛠️ Resources',
        items: [
          { text: 'Tools', link: '/docs/resources/tools' },
          { text: 'Templates', link: '/docs/resources/templates' },
          { text: 'Frameworks', link: '/docs/resources/frameworks' },
          { text: 'Forms', link: '/docs/resources/forms' },
          { text: 'Reading List', link: '/docs/resources/reading-list' }
        ]
      },
      {
        text: '🚀 Grow',
        items: [
          {
            text: 'Getting Started',
            items: [
              { text: 'Business Overview', link: '/docs/business/' },
              { text: 'Interactive Workbook', link: '/docs/profile/interactive-workbook' }
            ]
          },
          {
            text: 'Marketing & Brand',
            items: [
              { text: 'Marketing Guide', link: '/docs/business/marketing' },
              { text: 'Branding Guide', link: '/docs/business/branding' }
            ]
          },
          {
            text: 'Operations',
            items: [
              { text: 'Pricing Guide', link: '/docs/business/pricing' },
              { text: 'Platforms & Tools', link: '/docs/business/platforms' }
            ]
          }
        ]
      }
    ],

    // Use VitePress default outline (table of contents)
    outline: {
      level: [2, 3],
      label: 'On this page'
    },

    // Built-in search (this replaces your 850-line Algolia setup!)
    search: {
      provider: 'local',
      options: {
        placeholder: 'Search Your Coaching Hub...',
        translations: {
          button: {
            buttonText: 'Search',
            buttonAriaLabel: 'Search Your Coaching Hub'
          },
          modal: {
            noResultsText: 'No results for',
            resetButtonTitle: 'Clear search',
            footer: {
              selectText: 'to select',
              navigateText: 'to navigate',
              closeText: 'to close'
            }
          }
        }
      }
    },


    // Footer
    footer: {
      message: 'Built with ❤️ for the coaching community | Maintained by <a href="https://forwardfocus-coaching.co.uk/" target="_blank" rel="noopener">Forward Focus Coaching</a> | Created with <a href="https://claude.ai" target="_blank" rel="noopener">Claude.ai</a>',
      copyright: 'Copyright © 2026 Your Coaching Hub. Educational resources for coaching professionals.<br><strong>AI Content Disclaimer:</strong> This content was created using AI and may contain errors or inaccuracies. Please report any issues to <a href="mailto:hello@forwardfocus-coaching.co.uk">hello@forwardfocus-coaching.co.uk</a>'
    },


    // Last updated
    lastUpdated: {
      text: 'Last updated',
      formatOptions: {
        dateStyle: 'short',
        timeStyle: 'short'
      }
    }
  },

  // Markdown configuration
  markdown: {
    lineNumbers: true,
    container: {
      tipLabel: '💡 Tip',
      warningLabel: '⚠️ Warning',
      dangerLabel: '🚨 Important',
      infoLabel: 'ℹ️ Info',
      detailsLabel: 'Details'
    }
  },

  // Build configuration
  vite: {
    server: {
      port: 5173,
      strictPort: true, // Exit if port is already in use instead of trying next available
      host: true // Allow external connections
    },
    preview: {
      port: 5173,
      strictPort: true
    }
  },

  // Exclude development files and documentation from build and sitemap
  srcExclude: [
    '**/supabase/**',
    '**/scripts/**',
    '**/tests/**',
    '**/test-results/**',
    '**/playwright-report/**',
    'README.md',
    'SEO_SETUP.md',
    'CLAUDE.md',
    'package.json',
    'package-lock.json',
    '**/.git/**',
    '**/.github/**',
    '**/node_modules/**',
    '**/dist/**'
  ],

  // Temporarily ignore dead links while we fix remaining issues
  ignoreDeadLinks: true
})