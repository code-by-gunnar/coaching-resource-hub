// Custom theme to extend VitePress default theme
import DefaultTheme from 'vitepress/theme'
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
    
    // Register admin components for production (essential management tool)
    try {
      console.log('Loading admin components for production...')
      
      // Core admin components
      const AdminHub = await import('./components/AdminHub.vue')
      app.component('AdminHub', AdminHub.default)
      
      const AdminAssessments = await import('./components/AdminAssessments.vue')
      app.component('AdminAssessments', AdminAssessments.default)
      
      const AdminAssessmentEditor = await import('./components/AdminAssessmentEditor.vue')
      app.component('AdminAssessmentEditor', AdminAssessmentEditor.default)
      
      const AdminQuestions = await import('./components/AdminQuestions.vue')
      app.component('AdminQuestions', AdminQuestions.default)
      
      const AdminCompetencies = await import('./components/AdminCompetencies.vue')
      app.component('AdminCompetencies', AdminCompetencies.default)
      
      const AdminInsights = await import('./components/AdminInsights.vue')
      app.component('AdminInsights', AdminInsights.default)
      
      const AdminUsers = await import('./components/AdminUsers.vue')
      app.component('AdminUsers', AdminUsers.default)
      
      // Learning Resources Management
      const AdminResourcesTabs = await import('./components/AdminResourcesTabs.vue')
      app.component('AdminResourcesTabs', AdminResourcesTabs.default)
      
      const LearningResourceEditor = await import('./components/LearningResourceEditor.vue')
      app.component('LearningResourceEditor', LearningResourceEditor.default)
      
      const PathCategoryEditor = await import('./components/PathCategoryEditor.vue')
      app.component('PathCategoryEditor', PathCategoryEditor.default)
      
      // Competency Management
      const CompetencyEditor = await import('./components/CompetencyEditor.vue')
      app.component('CompetencyEditor', CompetencyEditor.default)
      
      const CompetencyDisplayNameEditor = await import('./components/CompetencyDisplayNameEditor.vue')
      app.component('CompetencyDisplayNameEditor', CompetencyDisplayNameEditor.default)
      
      const CompetencyRichInsightsEditor = await import('./components/CompetencyRichInsightsEditor.vue')
      app.component('CompetencyRichInsightsEditor', CompetencyRichInsightsEditor.default)
      
      const CompetencyStrategicActionsEditor = await import('./components/CompetencyStrategicActionsEditor.vue')
      app.component('CompetencyStrategicActionsEditor', CompetencyStrategicActionsEditor.default)
      
      const CompetencyLeverageStrengthsEditor = await import('./components/CompetencyLeverageStrengthsEditor.vue')
      app.component('CompetencyLeverageStrengthsEditor', CompetencyLeverageStrengthsEditor.default)
      
      const CompetencyPerformanceAnalysisEditor = await import('./components/CompetencyPerformanceAnalysisEditor.vue')
      app.component('CompetencyPerformanceAnalysisEditor', CompetencyPerformanceAnalysisEditor.default)
      
      // Skills and Tags Management
      const SkillTagEditor = await import('./components/SkillTagEditor.vue')
      app.component('SkillTagEditor', SkillTagEditor.default)
      
      const TagInsightEditor = await import('./components/TagInsightEditor.vue')
      app.component('TagInsightEditor', TagInsightEditor.default)
      
      const TagActionEditor = await import('./components/TagActionEditor.vue')
      app.component('TagActionEditor', TagActionEditor.default)
      
      // Assessment Workflow Management
      const AssessmentWorkflowEditor = await import('./components/AssessmentWorkflowEditor.vue')
      app.component('AssessmentWorkflowEditor', AssessmentWorkflowEditor.default)
      
      // User Management
      const UserAccountEditor = await import('./components/UserAccountEditor.vue')
      app.component('UserAccountEditor', UserAccountEditor.default)
      
      const AssessmentQuestionEditor = await import('./components/AssessmentQuestionEditor.vue')
      app.component('AssessmentQuestionEditor', AssessmentQuestionEditor.default)
      
      const AdminQuestionImporter = await import('./components/AdminQuestionImporter.vue')
      app.component('AdminQuestionImporter', AdminQuestionImporter.default)
      
      console.log('Admin components registered successfully for production')
    } catch (error) {
      console.error('Failed to load admin components:', error)
    }
    
    // Development-only components (file uploaders, etc.)
    if (import.meta.env.DEV) {
      try {
        console.log('Loading development-only components...')
        
        // Admin Content Uploader (file upload with proper auth)
        const AdminContentUploader = await import('./components/AdminContentUploader.vue')
        app.component('AdminContentUploader', AdminContentUploader.default)
        
        const AdminAssessmentCreator = await import('./components/AdminAssessmentCreator.vue')
        app.component('AdminAssessmentCreator', AdminAssessmentCreator.default)
        
        console.log('Development components registered successfully')
      } catch (error) {
        console.error('Failed to load development components:', error)
      }
    }
  }
}