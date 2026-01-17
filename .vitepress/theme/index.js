// Custom theme to extend VitePress default theme
import DefaultTheme from 'vitepress/theme'
import { initSentry } from './composables/useSentry.js'
import Auth from './components/Auth.vue'
import Profile from './components/Profile.vue'
import AuthNav from './components/AuthNav.vue'
import Assessments from './components/Assessments.vue'
import AssessmentPlayer from './components/AssessmentPlayer.vue'
import AssessmentResults from './components/AssessmentResults.vue'
import AssessmentInsights from './components/AssessmentInsights.vue'
import LearningRecommendations from './components/LearningRecommendations.vue'
import AssessmentBadge from './components/shared/AssessmentBadge.vue'
import ActionButton from './components/shared/ActionButton.vue'
import InteractiveWorkbook from './pages/profile/interactive-workbook.vue'
import WorkbookSidebar from './components/workbook/WorkbookSidebar.vue'
import WorkbookSection from './components/workbook/WorkbookSection.vue'
import WorkbookListInput from './components/workbook/WorkbookListInput.vue'
import SEOHead from './components/SEOHead.vue'
import GoogleAnalytics from './components/GoogleAnalytics.vue'
import ContentTeaser from './components/ContentTeaser.vue'
import ProtectedContent from './components/ProtectedContent.vue'
import Layout from './Layout.vue'
import './tokens.css'
import './custom.css'

export default {
  extends: DefaultTheme,
  Layout,
  async enhanceApp({ app }) {
    // Suppress common browser extension warnings
    if (typeof window !== 'undefined') {
      // Suppress message port closed errors from browser extensions
      const originalError = console.error
      console.error = (...args) => {
        if (args[0]?.includes?.('message port closed') || 
            args[0]?.includes?.('lastError') ||
            args[0]?.includes?.('Extension context invalidated')) {
          return // Suppress these common extension warnings
        }
        originalError.apply(console, args)
      }
    }
    // Register components
    app.component('Auth', Auth)
    app.component('Profile', Profile)
    app.component('AuthNav', AuthNav)
    app.component('Assessments', Assessments)
    app.component('AssessmentPlayer', AssessmentPlayer)
    app.component('AssessmentResults', AssessmentResults)
    app.component('AssessmentInsights', AssessmentInsights)
    app.component('LearningRecommendations', LearningRecommendations)
    app.component('AssessmentBadge', AssessmentBadge)
    app.component('ActionButton', ActionButton)
    app.component('InteractiveWorkbook', InteractiveWorkbook)
    app.component('WorkbookSidebar', WorkbookSidebar)
    app.component('WorkbookSection', WorkbookSection)
    app.component('WorkbookListInput', WorkbookListInput)
    app.component('SEOHead', SEOHead)
    app.component('GoogleAnalytics', GoogleAnalytics)
    app.component('ContentTeaser', ContentTeaser)
    app.component('ProtectedContent', ProtectedContent)

    // Admin tools (lightweight assessment management)
    const AdminTools = await import('./components/AdminTools.vue')
    app.component('AdminTools', AdminTools.default)

    // Initialize Sentry error tracking (if configured)
    await initSentry(app)
  }
}