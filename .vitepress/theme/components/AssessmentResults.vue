<template>
  <div class="assessment-results-container">
    <div v-if="!user" class="auth-required">
      <div class="auth-message">
        <h2><ClipboardDocumentCheckIcon class="heading-icon" aria-hidden="true" /> Assessments Overview</h2>
        <p>Please <a href="/docs/auth/">sign in</a> to view your assessments.</p>
      </div>
    </div>

    <!-- Beta Access Check -->
    <div v-else-if="user && !hasBetaAccess" class="beta-access-required">
      <div class="beta-message">
        <h2>{{ betaAccessMessage.title }}</h2>
        <div class="beta-content">
          <p>{{ betaAccessMessage.message }}</p>
          <div class="contact-info">
            <ActionButton 
              :href="`mailto:${betaAccessMessage.contactEmail}?subject=Assessment Beta Access Request`"
              variant="primary"
            >
              Request Beta Access
            </ActionButton>
          </div>
        </div>
      </div>
    </div>

    <div v-else-if="loading || processingUrlParam" class="loading-state">
      <div class="loading-spinner"></div>
      <p>{{ processingUrlParam ? 'Loading detailed results...' : 'Loading your assessments...' }}</p>
    </div>

    <div v-else-if="selectedAttempt && (selectedAttempt.attempt || selectedAttempt.score !== undefined)" class="results-content">
      <!-- Results Header -->
      <div class="results-header">
        <div class="header-info">
          <div class="header-main">
            <AssessmentBadge 
              :framework="selectedAttempt.attempt?.assessments?.framework || selectedAttempt.assessments?.framework" 
              :difficulty="selectedAttempt.attempt?.assessments?.difficulty || selectedAttempt.assessments?.difficulty || 'Beginner'"
              size="small"
            />
            <div class="header-text">
              <h1>{{ selectedAttempt.attempt?.assessments?.title || selectedAttempt.assessments?.title }}</h1>
              <span class="completion-date">Completed {{ formatDate(selectedAttempt.attempt?.completed_at || selectedAttempt.completed_at) }}</span>
            </div>
          </div>
        </div>
        <button @click="goBack" class="back-nav-btn">← Back to Assessments</button>
      </div>

      <!-- Performance Overview - User-Focused -->
      <div class="performance-overview">
        <!-- Key Insights Section -->
        <div class="key-insights">
          <h2>Assessment Results</h2>
          <div class="overall-performance">
            <div class="score-badge" :class="getScoreClass(selectedAttempt.attempt?.score ?? selectedAttempt.score ?? 0)">
              <span class="score-value">{{ selectedAttempt.attempt?.score ?? selectedAttempt.score ?? 0 }}%</span>
              <span class="score-label">Overall Score</span>
            </div>
            <div class="performance-summary">
              <h3>{{ getScoreLabel(selectedAttempt.attempt?.score ?? selectedAttempt.score ?? 0) }}</h3>
              <p class="summary-stats">
                You correctly answered <strong>{{ selectedAttempt.attempt?.correct_answers ?? selectedAttempt.correct_answers }} out of {{ selectedAttempt.attempt?.total_questions ?? selectedAttempt.total_questions }}</strong> questions
                in {{ formatTime(selectedAttempt.attempt?.time_spent || selectedAttempt.time_spent) }}
              </p>
              <p class="performance-message" v-if="(selectedAttempt.attempt?.score ?? selectedAttempt.score ?? 0) < 20">
                You're just getting started! Focus on building foundational coaching knowledge through structured learning and supervised practice.
              </p>
              <p class="performance-message" v-else-if="(selectedAttempt.attempt?.score ?? selectedAttempt.score ?? 0) < 40">
                Work on developing core coaching fundamentals. Consider intensive training programs and mentorship to build essential skills.
              </p>
              <p class="performance-message" v-else-if="(selectedAttempt.attempt?.score ?? selectedAttempt.score ?? 0) < 60">
                You're building important coaching skills! Focus on consistent practice and targeted development in your weaker areas below.
              </p>
              <p class="performance-message" v-else-if="(selectedAttempt.attempt?.score ?? selectedAttempt.score ?? 0) < 70">
                Good progress in your coaching development! Address the specific areas below to reach proficiency level.
              </p>
              <p class="performance-message" v-else-if="(selectedAttempt.attempt?.score ?? selectedAttempt.score ?? 0) < 80">
                Solid coaching competency! Fine-tune the areas below to move from good to strong performance.
              </p>
              <p class="performance-message" v-else-if="(selectedAttempt.attempt?.score ?? selectedAttempt.score ?? 0) < 90">
                Strong coaching performance! Polish the areas below to achieve coaching excellence and mastery.
              </p>
              <p class="performance-message" v-else>
                Outstanding coaching mastery! You've demonstrated exceptional competency. Consider advanced development and mentoring others.
              </p>
            </div>
          </div>
        </div>

        <!-- Results Overview Note -->
        <div class="results-note">
          <p>
            <ChartBarSquareIcon class="inline-icon" aria-hidden="true" /> <strong>Results Summary:</strong> This page provides an overview of your performance. 
            For comprehensive analysis including detailed question breakdowns, coaching scenarios, and personalized development plans, 
            <strong>download your full PDF report using the email button above.</strong>
          </p>
        </div>

        <!-- Smart Skills Analysis -->
        <AssessmentInsights 
          :competency-stats="competencyStats"
          :personalized-analysis="personalizedCompetencyAnalysis"
          :assessment-framework="selectedAttempt.attempt?.assessments?.framework || selectedAttempt.assessments?.framework"
        />

        <!-- Tiered Learning Recommendations -->
        <div class="learning-path-section">
          <LearningRecommendations 
            :competency-stats="competencyStats"
            :overall-score="selectedAttempt.attempt?.score ?? selectedAttempt.score ?? 0"
            :user-id="user?.id"
            :assessment-id="selectedAttempt.attempt?.assessment_id || selectedAttempt.assessment_id"
            :attempt-id="selectedAttempt.attempt?.id || selectedAttempt.id"
          />
        </div>
      </div>

      <!-- Next Steps Section -->
      <div class="next-steps-section">
        <div class="simple-actions">
          <ActionButton @click="emailAssessmentPDF" variant="primary" icon="📧" :loading="emailLoading">
            {{ emailLoading ? 'Sending...' : 'Email Assessment' }}
          </ActionButton>
        </div>
        
        <!-- Email Status Notification -->
        <div v-if="emailStatus" :class="['email-notification', emailStatus]">
          <div class="notification-content">
            <CheckCircleIcon v-if="emailStatus === 'success'" class="notification-icon-svg success" aria-hidden="true" />
            <XCircleIcon v-else class="notification-icon-svg error" aria-hidden="true" />
            <span class="notification-message">{{ emailMessage }}</span>
            <button @click="emailStatus = null" class="notification-close">×</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Assessment Selection -->
    <div v-else class="assessment-selection">
      <div class="page-header">
        <div class="page-title">
          <h1><ClipboardDocumentCheckIcon class="heading-icon" aria-hidden="true" /> Assessments Overview</h1>
          <p>Manage your assessments, continue in-progress tests, and review detailed results. <strong>For comprehensive analysis, download your PDF report via email.</strong></p>
        </div>
      </div>

      <!-- Results Content - Only show if user has assessments -->
      <div v-if="userAttempts.length > 0">
        <!-- Stats Overview -->
        <div class="results-overview">
          <div class="overview-card">
            <div class="overview-header">
              <h3>Your Progress Summary</h3>
              <ActionButton href="/docs/profile/" variant="gray" icon="←">
                Back to Profile
              </ActionButton>
            </div>
            <div class="overview-stats">
              <div class="overview-stat">
                <span class="stat-number">{{ completedCount }}</span>
                <span class="stat-label">Completed</span>
              </div>
              <div class="overview-stat" v-if="inProgressCount > 0">
                <span class="stat-number stat-in-progress">{{ inProgressCount }}</span>
                <span class="stat-label">In Progress</span>
              </div>
              <div class="overview-stat">
                <span class="stat-number">{{ overallStats.averageScore }}%</span>
                <span class="stat-label">Average Score</span>
              </div>
              <div class="overview-stat">
                <span class="stat-number">{{ overallStats.highestScore }}%</span>
                <span class="stat-label">Highest Score</span>
              </div>
              <div class="overview-stat">
                <span class="stat-number">{{ overallStats.totalTime }}</span>
                <span class="stat-label">Total Study Time</span>
              </div>
            </div>
          </div>
        </div>

        <div class="section-divider">
          <h3>Your Assessments</h3>
          <p>Continue in-progress assessments or view detailed results and question-by-question analysis</p>
          
          <!-- Results summary with items per page selector -->
          <div class="results-controls" v-if="showHistoryPagination">
            <div class="results-summary">
              <span class="summary-text">
                Showing {{ (historyCurrentPage - 1) * historyItemsPerPage + 1 }}-{{ Math.min(historyCurrentPage * historyItemsPerPage, userAttempts.length) }} 
                of {{ userAttempts.length }} assessments
              </span>
            </div>
            
            <div class="items-per-page">
              <label for="items-per-page">Show:</label>
              <select 
                id="items-per-page" 
                :value="historyItemsPerPage" 
                @change="changeItemsPerPage(Number($event.target.value))"
                class="items-select"
              >
                <option value="5">5</option>
                <option value="10">10</option>
                <option value="20">20</option>
              </select>
              <span>per page</span>
            </div>
          </div>
        </div>

        <div class="attempts-grid">
          <div 
            v-for="attempt in paginatedUserAttempts" 
            :key="attempt.id"
            class="history-item"
          >
            <div class="item-header">
              <AssessmentBadge 
                :framework="attempt.framework" 
                :difficulty="attempt.difficulty"
                size="mini"
              />
              <div class="item-title">{{ attempt.assessment_title }}</div>
            </div>
            <div class="item-info-group">
              <div class="item-date">{{ formatDate(attempt.status === 'completed' ? attempt.completed_at : attempt.started_at) }}</div>
              <div v-if="attempt.status === 'completed'" class="item-result" :class="getScoreClass(attempt.score)">
                {{ attempt.score ?? 0 }}% • {{ getScoreLabel(attempt.score ?? 0) }}
              </div>
              <div v-else class="item-result in-progress">
                In Progress • Question {{ attempt.current_question_index || 1 }} of {{ attempt.total_questions }}
              </div>
            </div>
            <button v-if="attempt.status === 'completed'" @click="selectAttempt(attempt.id)" class="view-results-btn">View Results</button>
            <button v-else @click="continueAssessment(attempt)" class="continue-btn">Continue</button>
          </div>
        </div>
        
        <!-- Pagination Controls -->
        <div class="pagination-wrapper" v-if="showHistoryPagination">
          <div class="pagination">
            <button 
              @click="previousHistoryPage" 
              :disabled="historyCurrentPage === 1"
              class="pagination-btn"
              :class="{ 'disabled': historyCurrentPage === 1 }"
            >
              ← Previous
            </button>
            
            <div class="page-numbers">
              <button
                v-for="page in historyTotalPages"
                :key="page"
                @click="goToHistoryPage(page)"
                class="page-number"
                :class="{ 'active': page === historyCurrentPage }"
                v-show="page === 1 || page === historyTotalPages || Math.abs(page - historyCurrentPage) <= 2"
              >
                {{ page }}
              </button>
            </div>
            
            <button 
              @click="nextHistoryPage" 
              :disabled="historyCurrentPage === historyTotalPages"
              class="pagination-btn"
              :class="{ 'disabled': historyCurrentPage === historyTotalPages }"
            >
              Next →
            </button>
          </div>
        </div>
      </div>

      <!-- Empty State - Only show if no assessments -->
      <div v-else class="no-results">
        <!-- Empty State Content -->
        <div class="empty-state-content">
          <div class="empty-state-header">
            <ActionButton href="/docs/profile/" variant="gray" icon="←">
              Back to Profile
            </ActionButton>
          </div>
          <div class="empty-state-hero">
            <h2>No Assessments Yet</h2>
            <p class="empty-description">
              Start your first assessment to unlock detailed performance analytics, 
              competency insights, and personalized learning recommendations.
            </p>
          </div>

          <div class="empty-features">
            <div class="feature-preview">
              <div class="feature-icon">
                <ChartBarSquareIcon class="feature-icon-svg" aria-hidden="true" />
              </div>
              <h3>Detailed Analytics</h3>
              <p>Track your performance across all coaching competencies</p>
            </div>
            <div class="feature-preview">
              <div class="feature-icon">
                <ClipboardDocumentCheckIcon class="feature-icon-svg" aria-hidden="true" />
              </div>
              <h3>Personalized Insights</h3>
              <p>Get targeted recommendations for skill development</p>
            </div>
            <div class="feature-preview">
              <div class="feature-icon">
                <ArrowTrendingUpIcon class="feature-icon-svg" aria-hidden="true" />
              </div>
              <h3>Progress Tracking</h3>
              <p>Monitor your growth over multiple assessment attempts</p>
            </div>
          </div>

          <div class="empty-actions">
            <ActionButton href="/docs/assessments/" variant="primary" size="large">
              Take Your First Assessment
            </ActionButton>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch, watchEffect } from 'vue'
import {
  ClipboardDocumentCheckIcon,
  ChartBarSquareIcon,
  ArrowTrendingUpIcon,
  CheckCircleIcon,
  XCircleIcon
} from '@heroicons/vue/24/outline'
import { useAuth } from '../composables/useAuth.js'
import { useSupabase } from '../composables/useSupabase.js'
import { useAssessmentResults } from '../composables/useAssessments.js'
import { useAssessmentInsights } from '../composables/useAssessmentInsights.js'
import { useFrontendInsightsCapture } from '../composables/useFrontendInsightsCapture.js'
import { usePersonalizedInsights } from '../composables/usePersonalizedInsights.js'
import { useBetaAccess } from '../composables/useBetaAccess.js'
import { getUserFriendlyError, formatErrorForUI } from '../composables/useUserFriendlyErrors.js'

// Composables
const { user } = useAuth()
const { supabase } = useSupabase()
const { getAttemptResults } = useAssessmentResults()
const { captureAndStoreFrontendInsights } = useFrontendInsightsCapture()
const { generatePersonalizedCompetencyAnalysis } = usePersonalizedInsights()
const { hasBetaAccess, betaAccessMessage } = useBetaAccess(user)

// Reactive state
const loading = ref(false)
const userAttempts = ref([])
const selectedAttempt = ref(null)
const processingUrlParam = ref(false)
const showQuickReview = ref(false)
const questionFilter = ref('all')
const currentPage = ref(1)
const expandedQuestions = ref([])
const questionsPerPage = 10

// Assessment history pagination
const historyCurrentPage = ref(1)
const historyItemsPerPage = ref(5) // Start with 5 items per page for compact display

// Load user's assessment attempts
const loadUserAttempts = async () => {
  if (!user.value) return
  
  loading.value = true
  
  try {
    const { useSupabase } = await import('../composables/useSupabase.js')
    const { supabase } = useSupabase()

    const { data: attemptsData, error: attemptsError } = await supabase
      .from('user_assessment_attempts')
      .select(`
        id, 
        assessment_id, 
        status, 
        score, 
        completed_at, 
        started_at, 
        time_spent, 
        enriched_data, 
        current_question_index, 
        total_questions, 
        assessments!inner(
          title, 
          slug, 
          framework_id,
          assessment_level_id,
          frameworks(code),
          assessment_levels(level_code)
        )
      `)
      .eq('user_id', user.value.id)
      .in('status', ['completed', 'in_progress'])
      .order('started_at', { ascending: false })
    
    if (attemptsError) {
      console.error('Error loading assessment results:', attemptsError)
      throw attemptsError
    }
    
    // Transform data to expected format
    userAttempts.value = (attemptsData || []).map(attempt => ({
      id: attempt.id,
      assessment_id: attempt.assessment_id,
      assessment_title: attempt.assessments?.title || 'Unknown Assessment',
      assessment_slug: attempt.assessments?.slug || '',
      framework: attempt.assessments?.frameworks?.code || 'core',
      difficulty: attempt.assessments?.assessment_levels?.level_code || 'beginner',
      status: attempt.status,
      score: attempt.score,
      completed_at: attempt.completed_at,
      started_at: attempt.started_at,
      time_spent: attempt.time_spent,
      current_question_index: attempt.current_question_index,
      total_questions: attempt.total_questions || 0,
      attempt_number: 1 // Since we're getting the most recent
    }))
    
  } catch (err) {
    console.error('Error loading user attempts:', err)
  } finally {
    loading.value = false
  }
}

// Select and load detailed attempt results
const selectAttempt = async (attemptId) => {
  loading.value = true
  try {
    console.log('🔍 selectAttempt called with attemptId:', attemptId)
    const results = await getAttemptResults(attemptId)
    console.log('🔍 getAttemptResults returned:', results)
    console.log('🔍 results.attempt:', results.attempt)
    console.log('🔍 results.attempt.score:', results.attempt?.score)
    selectedAttempt.value = results
    console.log('🔍 selectedAttempt.value set to:', selectedAttempt.value)
    
    // Update URL to include attempt parameter for refresh preservation
    const currentUrl = new URL(window.location)
    currentUrl.searchParams.set('attempt', attemptId)
    window.history.pushState({}, '', currentUrl)
  } catch (err) {
    console.error('Error loading attempt results:', err)
  } finally {
    loading.value = false
  }
}

// Computed properties for question filtering and pagination
const incorrectCount = computed(() => {
  if (!selectedAttempt.value?.responses) return 0
  return selectedAttempt.value.responses.filter(r => !r.is_correct).length
})

const filteredResponses = computed(() => {
  if (!selectedAttempt.value?.responses) return []
  
  let responses = selectedAttempt.value.responses
  
  if (questionFilter.value === 'incorrect') {
    responses = responses.filter(r => !r.is_correct)
  }
  
  // Pagination
  const startIndex = (currentPage.value - 1) * questionsPerPage
  const endIndex = startIndex + questionsPerPage
  
  return responses.slice(startIndex, endIndex)
})

const totalPages = computed(() => {
  if (!selectedAttempt.value?.responses) return 1
  
  let totalQuestions = selectedAttempt.value.responses.length
  if (questionFilter.value === 'incorrect') {
    totalQuestions = incorrectCount.value
  }
  
  return Math.ceil(totalQuestions / questionsPerPage)
})

const competencyStats = computed(() => {
  if (!selectedAttempt.value?.responses) return []
  
  const competencies = {}
  selectedAttempt.value.responses.forEach(response => {
    const area = response.assessment_questions.competency_area
    if (!area) return
    
    if (!competencies[area]) {
      competencies[area] = { correct: 0, total: 0 }
    }
    
    competencies[area].total++
    if (response.is_correct) {
      competencies[area].correct++
    }
  })
  
  return Object.entries(competencies)
    .map(([area, stats]) => ({
      area,
      correct: stats.correct,
      total: stats.total,
      percentage: Math.round((stats.correct / stats.total) * 100)
    }))
    .sort((a, b) => b.percentage - a.percentage)
})

// Personalized competency analysis with detailed insights based on actual performance
const personalizedCompetencyAnalysis = ref([])

// Watch for changes and update analysis asynchronously
watchEffect(async () => {
  if (!selectedAttempt.value?.responses || !competencyStats.value?.length) {
    personalizedCompetencyAnalysis.value = []
    return
  }
  
  try {
    // CRITICAL: Ensure database cache is loaded before generating analysis
    console.log('🔄 Ensuring database cache is loaded before generating personalized analysis...')
    const cacheLoaded = await ensureCacheLoaded()
    
    if (!cacheLoaded) {
      console.error('❌ Database cache failed to load - personalized analysis will be limited')
      personalizedCompetencyAnalysis.value = []
      return
    }
    
    console.log('✅ Database cache confirmed loaded - proceeding with personalized analysis')
    const difficulty = selectedAttempt.value?.attempt?.assessments?.difficulty || 'Beginner'
    const analysis = await generatePersonalizedCompetencyAnalysis(
      competencyStats.value,
      selectedAttempt.value.responses,
      assessmentFramework.value,
      difficulty,
      getSkillTags,
      getTagInsight,
      getTagActionableStep
    )
    personalizedCompetencyAnalysis.value = analysis
  } catch (error) {
    console.error('Error generating personalized analysis:', error)
    personalizedCompetencyAnalysis.value = []
  }
})


// Use insights composable for helper functions
const assessmentFramework = computed(() => {
  return selectedAttempt.value?.attempt?.assessments?.framework || selectedAttempt.value?.assessments?.framework || 'core'
})

const { mapCompetencyToSkill, getKeyConceptFromQuestion, getLessonFromMistake, getSkillTags, getTagInsight, getTagActionableStep, ensureCacheLoaded } = useAssessmentInsights(
  competencyStats,
  assessmentFramework
)

// Question detail methods
const toggleQuestionDetail = (questionId) => {
  const index = expandedQuestions.value.indexOf(questionId)
  if (index > -1) {
    expandedQuestions.value.splice(index, 1)
  } else {
    expandedQuestions.value.push(questionId)
  }
}

// Capture frontend insights when data is available
const insightsCaptureCalled = ref(false)
watch([selectedAttempt, competencyStats, assessmentFramework], async ([attempt, stats, framework]) => {
  // Only capture if we have all the data, user is logged in, and we haven't already captured
  if (
    attempt && 
    stats && stats.length > 0 && 
    framework && 
    user.value && 
    !insightsCaptureCalled.value
  ) {
    try {
      insightsCaptureCalled.value = true
      console.log('🎯 Capturing frontend-generated insights...')
      
      await captureAndStoreFrontendInsights(
        selectedAttempt.value.attempt?.id || selectedAttempt.value.id,
        { value: stats },
        { value: framework },
        { value: attempt }
      )
      
      console.log('✅ Frontend insights captured and stored')
      
    } catch (error) {
      console.error('🚨 Failed to capture frontend insights:', error)
      // Don't block the UI if insights capture fails
    }
  }
}, { deep: true })


// Overall statistics for the main results page
const overallStats = computed(() => {
  if (!userAttempts.value.length) return { averageScore: 0, highestScore: 0, totalTime: '0m' }
  
  const scores = userAttempts.value.map(attempt => attempt.score ?? 0)
  const averageScore = Math.round(scores.reduce((sum, score) => sum + score, 0) / scores.length)
  const highestScore = Math.max(...scores)
  
  const totalSeconds = userAttempts.value.reduce((sum, attempt) => sum + (attempt.time_spent || 0), 0)
  const totalMinutes = Math.round(totalSeconds / 60)
  const totalTime = totalMinutes > 60 
    ? `${Math.floor(totalMinutes / 60)}h ${totalMinutes % 60}m`
    : `${totalMinutes}m`
  
  return { averageScore, highestScore, totalTime }
})

// Computed counts for completed vs in-progress assessments
const completedCount = computed(() => {
  return userAttempts.value.filter(attempt => attempt.status === 'completed').length
})

const inProgressCount = computed(() => {
  return userAttempts.value.filter(attempt => attempt.status === 'in_progress').length
})

// Paginated assessment history
const paginatedUserAttempts = computed(() => {
  const start = (historyCurrentPage.value - 1) * historyItemsPerPage.value
  const end = start + historyItemsPerPage.value
  return userAttempts.value.slice(start, end)
})

const historyTotalPages = computed(() => {
  return Math.ceil(userAttempts.value.length / historyItemsPerPage.value)
})

const showHistoryPagination = computed(() => {
  return userAttempts.value.length > historyItemsPerPage.value
})


// Email functionality
const emailLoading = ref(false)
const emailStatus = ref(null) // 'success', 'error', or null
const emailMessage = ref('')

const emailAssessmentPDF = async () => {
  if (!selectedAttempt.value || !user.value?.email) {
    emailStatus.value = 'error'
    emailMessage.value = 'Unable to send email: Missing required data or user email'
    return
  }

  emailLoading.value = true
  emailStatus.value = null
  
  try {
    // Call Edge Function to send email with PDF
    // Pass the attempt ID - the Edge Function will get the enriched_data from the database
    const requestBody = {
      email: user.value.email,
      attemptId: selectedAttempt.value.attempt?.id || selectedAttempt.value.id,
      userProfile: {
        full_name: user.value.user_metadata?.full_name || user.value.user_metadata?.name,
        email: user.value.email
      }
    }
    
    console.log('📤 Sending request to Edge Function:', requestBody)
    
    const { data, error } = await supabase.functions.invoke('email-assessment-report', {
      body: requestBody
    })

    if (error) throw error

    // Show success message
    emailStatus.value = 'success'
    emailMessage.value = `Assessment report sent successfully to ${user.value.email}! Check your inbox (and spam folder) for the download link.`
    
    // Auto-dismiss success notification after 5 seconds
    setTimeout(() => {
      if (emailStatus.value === 'success') {
        emailStatus.value = null
      }
    }, 5000)
    
  } catch (error) {
    console.error('Email sending error:', error)
    emailStatus.value = 'error'
    emailMessage.value = `Failed to send assessment report: ${error.message}. Please try again later.`
  } finally {
    emailLoading.value = false
  }
}

// Utility functions
const getFrameworkName = (framework) => {
  const names = { icf: 'ICF', ac: 'AC', universal: 'Core' }
  return names[framework] || framework.toUpperCase()
}


const getScoreClass = (score) => {
  if (score >= 90) return 'excellent'
  if (score >= 80) return 'good'  
  if (score >= 70) return 'fair'
  return 'needs-improvement'
}

const getScoreLabel = (score) => {
  if (score >= 90) return 'Outstanding Performance'
  if (score >= 80) return 'Strong Performance'
  if (score >= 70) return 'Good Performance'
  if (score >= 60) return 'Developing Performance'
  if (score >= 40) return 'Building Performance'
  if (score >= 20) return 'Foundation Performance'
  return 'Beginning Performance'
}

const formatDate = (dateString) => {
  if (!dateString) return 'Unknown'
  return new Date(dateString).toLocaleDateString('en-US', { 
    year: 'numeric', month: 'long', day: 'numeric' 
  })
}

const formatTime = (seconds) => {
  if (!seconds) return '0m 0s'
  const minutes = Math.floor(seconds / 60)
  const remainingSeconds = seconds % 60
  return `${minutes}m ${remainingSeconds}s`
}

const getQuestionOptions = (question) => {
  return [
    question.option_a,
    question.option_b, 
    question.option_c,
    question.option_d
  ]
}

// Watch for filter changes to reset pagination
watch(questionFilter, () => {
  currentPage.value = 1
  expandedQuestions.value = []
})

// Actions
const goBack = () => {
  selectedAttempt.value = null
  questionFilter.value = 'all'
  currentPage.value = 1
  expandedQuestions.value = []
  
  // Remove attempt parameter from URL
  const currentUrl = new URL(window.location)
  currentUrl.searchParams.delete('attempt')
  window.history.pushState({}, '', currentUrl)
}


const goToAssessments = () => {
  window.location.href = '/docs/assessments/'
}

const continueAssessment = (attempt) => {
  // Navigate to assessment player with continue action
  window.location.href = `/docs/assessments/take?action=continue#${attempt.assessment_slug}`
}

// Pagination controls
const goToHistoryPage = (page) => {
  historyCurrentPage.value = page
}

const previousHistoryPage = () => {
  if (historyCurrentPage.value > 1) {
    historyCurrentPage.value--
  }
}

const nextHistoryPage = () => {
  if (historyCurrentPage.value < historyTotalPages.value) {
    historyCurrentPage.value++
  }
}

const changeItemsPerPage = (itemsCount) => {
  historyItemsPerPage.value = itemsCount
  historyCurrentPage.value = 1 // Reset to first page when changing page size
}

// Watch for user changes and load data accordingly
watch(user, async (newUser) => {
  if (newUser) {
    // Check for URL parameters before loading
    const urlParams = new URLSearchParams(window.location.search)
    const attemptId = urlParams.get('attempt')
    
    // Set processing flag if we have an attempt ID to load
    if (attemptId) {
      processingUrlParam.value = true
    }
    
    await loadUserAttempts()
    
    // Check for specific attempt ID in URL
    if (attemptId && userAttempts.value.some(a => a.id === attemptId)) {
      await selectAttempt(attemptId)
    }
    
    // Clear processing flag once done
    processingUrlParam.value = false
  }
}, { immediate: true })

// Load data on mount if user is already available
onMounted(async () => {
  if (user.value) {
    // Check for URL parameters before loading
    const urlParams = new URLSearchParams(window.location.search)
    const attemptId = urlParams.get('attempt')
    
    // Set processing flag if we have an attempt ID to load
    if (attemptId) {
      processingUrlParam.value = true
    }
    
    await loadUserAttempts()
    
    // Check URL parameters immediately after loading attempts
    if (attemptId && userAttempts.value.some(a => a.id === attemptId)) {
      await selectAttempt(attemptId)
    }
    
    // Clear processing flag once done
    processingUrlParam.value = false
  }
})
</script>

<style scoped>
.assessment-results-container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 1.5rem;
}

/* Results Overview Note */
.results-note {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  padding: 15px;
  border-radius: 8px;
  margin: 30px 0;
}

.results-note p {
  margin: 0;
  font-size: 14px;
  color: var(--vp-c-text-1);
}

/* Auth Required */
.auth-required {
  text-align: center;
  padding: 4rem 2rem;
}

.auth-message h2 {
  color: var(--vp-c-text-1);
  margin-bottom: 1rem;
}

.auth-message a {
  color: var(--vp-c-brand-1);
  text-decoration: none;
}

/* Beta Access */
.beta-access-required {
  text-align: center;
  padding: 4rem 2rem;
}

.beta-message {
  max-width: 600px;
  margin: 0 auto;
}

.beta-message h2 {
  color: var(--vp-c-text-1);
  margin-bottom: 1.5rem;
}

.beta-content p {
  color: var(--vp-c-text-2);
  line-height: 1.6;
  margin-bottom: 2rem;
  white-space: pre-line;
}

.contact-info {
  margin-top: 2rem;
}

/* Loading */
.loading-state {
  text-align: center;
  padding: 4rem 2rem;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid var(--vp-c-divider);
  border-top: 3px solid var(--vp-c-brand-1);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Results Header - Compact */
.results-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 1rem;
  padding: 0.75rem;
  background: var(--vp-c-bg-soft);
  border-radius: 6px;
}

.header-info {
  flex: 1;
}

.header-main {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.header-text h1 {
  margin: 0 0 0.2rem 0;
  color: var(--vp-c-text-1);
  font-size: 1.1rem;
  font-weight: 600;
}

.completion-date {
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
}

.framework-badge {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 500;
}

.framework-badge.icf { background: #dbeafe; color: #1e40af; }
.framework-badge.ac { background: #fef3c7; color: #92400e; }
.framework-badge.core { background: #f3e8ff; color: #7c3aed; }

/* Performance Overview - User-Focused */
.performance-overview {
  margin-bottom: 1rem;
}

.key-insights {
  margin-bottom: 2rem;
}

.key-insights h2 {
  color: var(--vp-c-text-1);
  font-size: 1.5rem;
  margin-bottom: 1.5rem;
  text-align: center;
}

.overall-performance {
  display: flex;
  gap: 2rem;
  align-items: flex-start;
  padding: 1.5rem;
  background: var(--vp-c-bg-soft, rgba(0, 0, 0, 0.04));
  border-radius: 12px;
  border: 1px solid var(--vp-c-divider);
}

.score-badge {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-width: 120px;
  padding: 1rem;
  border-radius: 12px;
  border: 2px solid;
  text-align: center;
}

.score-badge.excellent {
  background: linear-gradient(135deg, #dcfce7 0%, #bbf7d0 100%);
  border-color: #22c55e;
}

.score-badge.good {
  background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
  border-color: #3b82f6;
}

.score-badge.fair {
  background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
  border-color: #f59e0b;
}

.score-badge.needs-improvement {
  background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%);
  border-color: #ef4444;
}

.score-value {
  font-size: 2rem;
  font-weight: 700;
  line-height: 1;
  color: var(--vp-c-text-1);
}

.score-label {
  font-size: 0.8rem;
  font-weight: 500;
  margin-top: 0.25rem;
  color: var(--vp-c-text-2);
}

.performance-summary {
  flex: 1;
}

.performance-summary h3 {
  margin: 0 0 0.75rem 0;
  color: var(--vp-c-text-1);
  font-size: 1.2rem;
}

.summary-stats {
  margin: 0 0 1rem 0;
  color: var(--vp-c-text-2);
  font-size: 0.95rem;
  line-height: 1.5;
}

.summary-stats strong {
  color: var(--vp-c-text-1);
  font-weight: 600;
}

.performance-message {
  padding: 0.75rem;
  background: var(--vp-c-bg-alt, rgba(0, 0, 0, 0.06));
  border-radius: 8px;
  border-left: 3px solid var(--vp-c-brand-1);
  font-size: 0.9rem;
  color: var(--vp-c-text-1);
  margin: 0;
}

/* Skills Analysis Section */
.skills-analysis {
  margin-bottom: 2rem;
}

.skills-analysis h3 {
  color: var(--vp-c-text-1);
  font-size: 1.1rem;
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.section-title {
  margin-top: 2rem !important;
}

.skills-priority {
  margin-bottom: 2rem;
}

.skill-focus-item {
  padding: 1rem;
  background: var(--vp-c-bg-soft, rgba(0, 0, 0, 0.04));
  border: 1px solid var(--vp-c-divider);
  border-left: 3px solid #ef4444;
  border-radius: 8px;
  margin-bottom: 1rem;
}

.skill-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.skill-name {
  font-weight: 600;
  color: var(--vp-c-text-1);
  font-size: 0.95rem;
}

.skill-score {
  font-weight: 600;
  font-size: 0.9rem;
}

.skill-score.critical {
  color: #ef4444;
}

.skill-score.good {
  color: #22c55e;
}

.skill-bar {
  height: 8px;
  background: var(--vp-c-divider-light);
  border-radius: 4px;
  overflow: hidden;
  margin-bottom: 0.75rem;
}

.skill-bar.mini {
  height: 6px;
  margin-bottom: 0;
}

.bar-fill {
  height: 100%;
  border-radius: 4px;
  transition: width 0.3s ease;
}

.bar-fill.critical {
  background: linear-gradient(90deg, #ef4444, #dc2626);
}

.bar-fill.good {
  background: linear-gradient(90deg, #22c55e, #16a34a);
}

.skill-action {
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
  padding: 0.5rem;
  background: rgba(239, 68, 68, 0.05);
  border-radius: 4px;
  margin-top: 0.5rem;
}

.skill-strength-item {
  padding: 0.75rem;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-left: 3px solid #22c55e;
  border-radius: 6px;
  margin-bottom: 0.75rem;
}

/* Smart Skills Analysis Styles */
.skill-insights {
  margin-top: 0.75rem;
  padding: 1rem;
  background: var(--vp-c-bg-alt);
  border-radius: 6px;
}

.insight-title {
  font-weight: 600;
  color: var(--vp-c-text-1);
  margin: 0 0 0.5rem 0;
  font-size: 0.9rem;
}

.insight-list {
  margin: 0 0 1rem 0;
  padding-left: 1rem;
}

.insight-list li {
  color: var(--vp-c-text-2);
  font-size: 0.85rem;
  line-height: 1.4;
  margin-bottom: 0.25rem;
}

.skill-actions {
  border-top: 1px solid var(--vp-c-divider);
  padding-top: 0.75rem;
  margin-top: 0.75rem;
}

.action-title {
  font-weight: 600;
  color: var(--vp-c-brand-1);
  margin: 0 0 0.5rem 0;
  font-size: 0.9rem;
}

.action-list {
  margin: 0;
  padding-left: 1rem;
}

.action-list li {
  color: var(--vp-c-text-1);
  font-size: 0.85rem;
  line-height: 1.4;
  margin-bottom: 0.3rem;
  font-weight: 500;
}

.strength-message {
  margin: 0.5rem 0 0 0;
  color: var(--vp-c-text-2);
  font-size: 0.85rem;
  font-style: italic;
}


/* Next Steps Section */
.next-steps-section {
  max-width: 1000px;
  margin: 1rem auto;
}

.simple-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
  padding: 0.75rem;
}

.action-btn {
  padding: 12px;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 500;
  transition: all 0.3s ease;
  text-decoration: none;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  min-width: 180px;
  justify-content: center;
}

.action-btn:hover {
  background: #2563eb;
  transform: translateY(-1px);
}

.download-btn {
  background: #6b7280 !important;
}

.download-btn:hover {
  background: #4b5563 !important;
  transform: translateY(-1px);
}

.retake-btn {
  background: #3b82f6 !important;
}

.retake-btn:hover {
  background: #2563eb !important;
  transform: translateY(-1px);
}

.btn-icon {
  font-size: 1rem;
}

/* Quick Review */
.quick-review {
  margin-top: 1.5rem;
  padding: 1.5rem;
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
}

.quick-review h4 {
  color: var(--vp-c-text-1);
  margin: 0 0 1rem 0;
  font-size: 1rem;
}

.missed-item {
  padding: 1rem;
  background: var(--vp-c-bg-soft);
  border-left: 3px solid #ef4444;
  border-radius: 6px;
  margin-bottom: 1rem;
}

.missed-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.question-num {
  font-weight: 600;
  color: var(--vp-c-text-1);
  font-size: 0.85rem;
}

.competency-tag {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 500;
}

.missed-concept {
  color: var(--vp-c-text-2);
  font-size: 0.85rem;
  margin: 0 0 0.5rem 0;
}

.missed-lesson {
  color: var(--vp-c-text-1);
  font-size: 0.85rem;
  font-weight: 500;
  margin: 0;
}

.more-questions {
  text-align: center;
  color: var(--vp-c-text-2);
  font-style: italic;
  margin: 1rem 0 0 0;
}


/* Question Filters */
.question-filters {
  margin-bottom: 1rem;
}

.filter-tabs {
  display: flex;
  gap: 0.5rem;
  border-bottom: 1px solid var(--vp-c-divider);
}

.filter-tab {
  padding: 0.5rem 1rem;
  background: none;
  border: none;
  border-bottom: 2px solid transparent;
  color: var(--vp-c-text-2);
  cursor: pointer;
  font-weight: 500;
  font-size: 0.9rem;
  transition: all 0.2s ease;
}

.filter-tab:hover {
  color: var(--vp-c-text-1);
  background: var(--vp-c-bg-soft);
}

.filter-tab.active {
  color: var(--vp-c-brand-1);
  border-bottom-color: var(--vp-c-brand-1);
}

/* Question Review */
.question-review {
  margin-bottom: 2rem;
}

/* Super Compact Question Rows */
.questions-compact {
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
}

.question-row {
  border: 1px solid var(--vp-c-divider);
  border-radius: 4px;
  font-size: 0.9rem;
}

.question-row.correct {
  border-left: 3px solid #22c55e;
}

.question-row.incorrect {
  border-left: 3px solid #ef4444;
}

.question-compact {
  padding: 0.5rem;
}

.question-line {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.3rem;
}

.question-info {
  display: flex;
  align-items: center;
  gap: 0.4rem;
}

.q-num {
  font-weight: 600;
  color: var(--vp-c-text-1);
  font-size: 0.85rem;
  min-width: 1.8rem;
}

.q-result {
  font-size: 0.9rem;
}

.q-competency {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
  padding: 0.1rem 0.3rem;
  border-radius: 3px;
  font-size: 0.75rem;
  font-weight: 500;
}

.expand-toggle {
  width: 20px;
  height: 20px;
  border: 1px solid var(--vp-c-divider);
  background: var(--vp-c-bg);
  border-radius: 3px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 0.8rem;
  font-weight: bold;
  color: var(--vp-c-text-2);
}

.expand-toggle:hover {
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-brand-1);
}

.answers-compact {
  margin-bottom: 0.3rem;
}

.answer-line {
  display: flex;
  align-items: flex-start;
  gap: 0.4rem;
  margin-bottom: 0.2rem;
  padding: 0.3rem;
  border-radius: 3px;
  font-size: 0.85rem;
  line-height: 1.3;
}

.answer-line.wrong {
  background: #fef2f2;
  border-left: 2px solid #ef4444;
}

.answer-line.correct {
  background: #f0fdf4;
  border-left: 2px solid #22c55e;
}

.ans-label {
  font-weight: 600;
  min-width: 2rem;
  flex-shrink: 0;
  font-size: 0.8rem;
}

.answer-line.wrong .ans-label {
  color: #dc2626;
}

.answer-line.correct .ans-label {
  color: #166534;
}

.ans-text {
  color: var(--vp-c-text-1);
}

.explanation-line {
  background: var(--vp-c-bg-soft);
  padding: 0.4rem;
  border-radius: 3px;
  border-left: 2px solid var(--vp-c-brand-1);
  font-size: 0.85rem;
  line-height: 1.4;
  margin-top: 0.3rem;
}

.question-expanded {
  margin-top: 0.5rem;
  padding-top: 0.5rem;
  border-top: 1px solid var(--vp-c-divider);
}

.scenario-compact, .question-compact-text {
  background: var(--vp-c-bg-alt);
  padding: 0.4rem;
  border-radius: 3px;
  font-size: 0.85rem;
  line-height: 1.4;
  margin-bottom: 0.3rem;
}

/* Pagination */
.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 0.75rem;
  margin-top: 1rem;
  padding: 0.75rem;
  border-top: 1px solid var(--vp-c-divider);
}

.page-btn {
  padding: 0.4rem 0.8rem;
  background: var(--vp-c-brand-1);
  color: white;
  border: none;
  border-radius: 3px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 500;
  transition: all 0.2s ease;
}

.page-btn:hover:not(:disabled) {
  background: var(--vp-c-brand-dark);
}

.page-btn:disabled {
  background: var(--vp-c-bg-alt);
  color: var(--vp-c-text-3);
  cursor: not-allowed;
}

.page-info {
  color: var(--vp-c-text-2);
  font-size: 0.9rem;
  font-weight: 500;
}

/* Assessment History Pagination */
.section-divider h3 {
  margin: 0 0 0.5rem 0;
  color: var(--vp-c-text-1);
}

.section-divider p {
  margin: 0 0 1rem 0;
  color: var(--vp-c-text-2);
  font-size: 0.9rem;
}

.results-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  padding: 0.75rem;
  background: var(--vp-c-bg-soft);
  border-radius: 6px;
  margin-top: 1rem;
}

.results-summary {
  flex: 1;
  text-align: center;
}

.summary-text {
  color: var(--vp-c-text-2);
  font-size: 0.9rem;
}

.items-per-page {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
}

.items-select {
  padding: 0.25rem 0.5rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 4px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  font-size: 0.9rem;
  cursor: pointer;
}

.items-select:hover {
  border-color: var(--vp-c-brand-1);
}

.pagination-wrapper {
  display: flex;
  justify-content: center;
  margin: 2rem 0;
}

.pagination {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.pagination-btn {
  padding: 0.5rem 1rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.2s ease;
}

.pagination-btn:hover:not(.disabled) {
  background: var(--vp-c-bg-soft);
  border-color: var(--vp-c-brand-1);
}

.pagination-btn.disabled {
  color: var(--vp-c-text-3);
  cursor: not-allowed;
  opacity: 0.5;
}

.page-numbers {
  display: flex;
  gap: 0.25rem;
  margin: 0 0.5rem;
}

.page-number {
  width: 2.5rem;
  height: 2.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.2s ease;
}

.page-number:hover {
  background: var(--vp-c-bg-soft);
  border-color: var(--vp-c-brand-1);
}

.page-number.active {
  background: var(--vp-c-brand-1);
  color: white;
  border-color: var(--vp-c-brand-1);
}

/* Results Actions */
.results-actions {
  display: flex;
  gap: 0.75rem;
  justify-content: center;
  margin-top: 1.5rem;
}

.action-btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  transition: all 0.3s ease;
  font-size: 0.85rem;
}

.retake-btn {
  background: var(--vp-c-brand-1);
  color: white;
}

.retake-btn:hover {
  background: var(--vp-c-brand-dark);
}

.back-btn {
  background: var(--vp-c-bg-alt);
  color: var(--vp-c-text-1);
  border: 1px solid var(--vp-c-divider);
}

/* Page Headers - Consistent UX Pattern */
.page-header {
  margin-bottom: 2rem;
}

.page-title {
  text-align: center;
  margin-top: 1.5rem;
}

.page-title h1 {
  color: var(--vp-c-text-1);
  margin-bottom: 1.5rem;
  font-size: 2.5rem;
  font-weight: 700;
}

.page-title h2 {
  color: var(--vp-c-text-1);
  margin-bottom: 0.5rem;
}

.page-title p {
  color: var(--vp-c-text-2);
  font-size: 1rem;
}

/* Consistent Back Navigation Button */
.back-nav-btn {
  padding: 12px;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 500;
  transition: all 0.3s ease;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  margin-bottom: 0.5rem;
}

.back-nav-btn:hover {
  background: #2563eb;
  transform: translateY(-1px);
}

/* Results Overview Stats */
.results-overview {
  margin-bottom: 3rem;
}

.overview-card {
  padding: 1.5rem;
  background: var(--vp-c-bg-soft, rgba(0, 0, 0, 0.04));
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
}

.overview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--vp-c-divider);
}

.overview-header h3 {
  margin: 0;
  color: var(--vp-c-text-1);
  font-size: 1.2rem;
  font-weight: 600;
}

.overview-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 0.75rem;
}

.overview-stat {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  padding: 0.25rem;
}

.overview-stat .stat-number {
  font-size: 1.6rem;
  font-weight: 600;
  color: var(--vp-c-brand-1);
  line-height: 1;
  margin-bottom: 0.5rem;
}

.overview-stat .stat-in-progress {
  color: var(--vp-c-yellow-1, #fbbf24);
}

.overview-stat .stat-label {
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
  font-weight: 500;
}

/* Section Divider */
.section-divider {
  margin: 2rem 0 1.5rem 0;
  text-align: center;
}

.section-divider h3 {
  color: var(--vp-c-text-1);
  margin-bottom: 0.5rem;
  font-size: 1.2rem;
}

.section-divider p {
  color: var(--vp-c-text-2);
  font-size: 1rem;
}

/* Enhanced Assessment Grid */
.attempts-grid {
  display: flex;
  flex-direction: column;
  gap: 2px;
  max-width: 900px;
  margin: 0 auto;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  overflow: hidden;
}

.history-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  padding: 0.75rem 1rem;
  background: var(--vp-c-bg);
  border-bottom: 1px solid var(--vp-c-divider);
  transition: background 0.2s ease;
}

.history-item:last-child {
  border-bottom: none;
}

.history-item:hover {
  background: var(--vp-c-bg-soft);
}

.item-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex: 1;
}

.item-info-group {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.item-title {
  color: var(--vp-c-text-1);
  font-size: 0.9rem;
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.item-date {
  color: var(--vp-c-text-2);
  font-size: 0.8rem;
  white-space: nowrap;
}

.item-result {
  font-size: 0.8rem;
  font-weight: 600;
  white-space: nowrap;
}

.item-result.excellent { color: #22c55e; }
.item-result.good { color: #3b82f6; }
.item-result.fair { color: #f59e0b; }
.item-result.needs-improvement { color: #ef4444; }

.view-results-btn {
  padding: 12px;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 500;
  transition: all 0.3s ease;
  text-decoration: none;
  display: inline-block;
  text-align: center;
  white-space: nowrap;
}

.view-results-btn:hover {
  background: #2563eb;
  transform: translateY(-1px);
}

.continue-btn {
  padding: 12px;
  background: #10b981;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 500;
  transition: all 0.3s ease;
  text-decoration: none;
  display: inline-block;
  text-align: center;
  white-space: nowrap;
}

.continue-btn:hover {
  background: #059669;
  transform: translateY(-1px);
}

.item-result.in-progress {
  color: #10b981;
  font-weight: 600;
}


.attempt-score-badge {
  position: relative;
}

.card-content {
  padding: 1rem 1.25rem;
}

.card-content h3 {
  margin: 0 0 0.75rem 0;
  color: var(--vp-c-text-1);
  font-size: 1.1rem;
  font-weight: 600;
}

.attempt-meta {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}

.performance-indicator {
  margin-top: 1rem;
}

.performance-bar {
  width: 100%;
  height: 6px;
  background: var(--vp-c-divider-light);
  border-radius: 3px;
  overflow: hidden;
  margin-bottom: 0.5rem;
}

.performance-fill {
  height: 100%;
  border-radius: 3px;
  transition: width 0.3s ease;
}

.performance-fill.excellent { background: #22c55e; }
.performance-fill.good { background: #3b82f6; }
.performance-fill.fair { background: #f59e0b; }
.performance-fill.needs-improvement { background: #ef4444; }

.performance-label {
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
  font-weight: 500;
}

.card-footer {
  padding: 0 1.25rem 1.25rem 1.25rem;
  text-align: center;
}

.view-details {
  color: var(--vp-c-brand-1);
  font-size: 0.9rem;
  font-weight: 500;
  opacity: 0.8;
  transition: opacity 0.3s ease;
}

.attempt-card.enhanced:hover .view-details {
  opacity: 1;
}

/* Legacy styles for backwards compatibility */
.attempts-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.attempt-card:not(.enhanced) {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.attempt-card:not(.enhanced):hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-1px);
}

.attempt-info h3 {
  margin: 0 0 0.5rem 0;
  color: var(--vp-c-text-1);
}

.no-results {
  padding: 0;
}

.empty-state-content {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
}

.empty-state-header {
  display: flex;
  justify-content: flex-end;
  margin-bottom: 2rem;
}

.empty-state-hero {
  text-align: center;
  margin-bottom: 3rem;
}


.empty-state-hero h2 {
  color: var(--vp-c-text-1);
  font-size: 1.5rem;
  font-weight: 600;
  margin: 0 0 1rem 0;
}

.empty-description {
  color: var(--vp-c-text-2);
  font-size: 0.95rem;
  line-height: 1.5;
  max-width: 600px;
  margin: 0 auto;
}

.empty-features {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2rem;
  margin-bottom: 3rem;
}

@media (max-width: 768px) {
  .empty-features {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 1024px) and (min-width: 769px) {
  .empty-features {
    grid-template-columns: repeat(2, 1fr);
  }
}

.feature-preview {
  text-align: center;
  padding: 2rem 1.5rem;
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
  border: 1px solid var(--vp-c-divider);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.feature-preview:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

.feature-icon {
  margin-bottom: 1rem;
}

.feature-icon-svg {
  width: 2.5rem;
  height: 2.5rem;
  color: var(--vp-c-brand-1);
}

.heading-icon {
  width: 2rem;
  height: 2rem;
  display: inline-block;
  vertical-align: middle;
  margin-right: 0.5rem;
  color: var(--vp-c-brand-1);
}

.inline-icon {
  width: 1.25rem;
  height: 1.25rem;
  display: inline-block;
  vertical-align: middle;
  margin-right: 0.25rem;
  color: var(--vp-c-brand-1);
}

.notification-icon-svg {
  width: 1.5rem;
  height: 1.5rem;
  flex-shrink: 0;
}

.notification-icon-svg.success {
  color: #22c55e;
}

.notification-icon-svg.error {
  color: #ef4444;
}

/* Dark mode icon styles */
.dark .feature-icon-svg {
  color: #818cf8;
}

.dark .heading-icon {
  color: #818cf8;
}

.dark .inline-icon {
  color: #818cf8;
}

.feature-preview h3 {
  color: var(--vp-c-text-1);
  font-size: 1rem;
  font-weight: 600;
  margin: 0 0 0.5rem 0;
}

.feature-preview p {
  color: var(--vp-c-text-2);
  font-size: 0.85rem;
  line-height: 1.4;
  margin: 0;
}

.empty-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}


.start-btn {
  padding: 12px;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 500;
  transition: all 0.3s ease;
  text-decoration: none;
  display: inline-block;
  text-align: center;
}

.start-btn:hover {
  background: #2563eb;
  transform: translateY(-1px);
}

/* Dark mode fixes for answer lines */
.dark .answer-line.wrong {
  background: rgba(239, 68, 68, 0.1);
  border-left-color: #ef4444;
}

.dark .answer-line.correct {
  background: rgba(34, 197, 94, 0.1);
  border-left-color: #22c55e;
}

.dark .answer-line.wrong .ans-label {
  color: #f87171;
}

.dark .answer-line.correct .ans-label {
  color: #4ade80;
}

/* Dark mode adjustments */
.dark .score-badge.excellent {
  background: linear-gradient(135deg, rgba(34, 197, 94, 0.15) 0%, rgba(34, 197, 94, 0.25) 100%);
  border-color: #22c55e;
}

.dark .score-badge.good {
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.15) 0%, rgba(59, 130, 246, 0.25) 100%);
  border-color: #3b82f6;
}

.dark .score-badge.fair {
  background: linear-gradient(135deg, rgba(245, 158, 11, 0.15) 0%, rgba(245, 158, 11, 0.25) 100%);
  border-color: #f59e0b;
}

.dark .score-badge.needs-improvement {
  background: linear-gradient(135deg, rgba(239, 68, 68, 0.15) 0%, rgba(239, 68, 68, 0.25) 100%);
  border-color: #ef4444;
}

.dark .skill-action {
  background: rgba(239, 68, 68, 0.1);
}

.dark .skill-focus-item {
  border-left-color: #ef4444;
}

.dark .skill-strength-item {
  border-left-color: #22c55e;
}

/* Ensure light mode visibility for all soft backgrounds */
html:not(.dark) .overall-performance,
html:not(.dark) .skill-focus-item,
html:not(.dark) .overview-card,
html:not(.dark) .performance-message {
  background: rgba(0, 0, 0, 0.04) !important;
  border: 1px solid rgba(0, 0, 0, 0.1) !important;
}

@media (max-width: 768px) {
  /* Container improvements */
  .assessment-results-container {
    padding: 1rem;
  }
  
  /* Page header mobile */
  .page-header {
    padding: 1rem;
    margin-bottom: 1.5rem;
  }
  
  .page-title h1 {
    font-size: 1.6rem;
    margin-bottom: 0.5rem;
  }
  
  .page-title p {
    font-size: 0.9rem;
  }
  
  /* Pagination responsive styles */
  .results-controls {
    flex-direction: column;
    gap: 0.75rem;
    padding: 0.75rem;
    text-align: center;
  }
  
  .items-per-page {
    justify-content: center;
  }
  
  .pagination {
    flex-wrap: wrap;
    justify-content: center;
    gap: 0.5rem;
  }
  
  .pagination-btn {
    padding: 0.4rem 0.8rem;
    font-size: 0.85rem;
  }
  
  .page-numbers {
    flex-wrap: wrap;
    gap: 0.25rem;
  }
  
  .page-number {
    width: 2rem;
    height: 2rem;
    font-size: 0.8rem;
  }
  
  /* Results header mobile */
  .results-header {
    flex-direction: column;
    padding: 1.5rem 1rem;
    margin-bottom: 1.5rem;
    text-align: center;
    align-items: center;
  }
  
  .header-info {
    margin-bottom: 1.5rem;
    width: 100%;
  }
  
  .header-main {
    flex-direction: column;
    gap: 1.5rem;
    text-align: center;
    align-items: center;
    justify-content: center;
    width: 100%;
  }
  
  .header-text {
    text-align: center;
    width: 100%;
  }
  
  .header-text h1 {
    font-size: 1.5rem;
    margin-bottom: 0.75rem;
    font-weight: 700;
    line-height: 1.3;
    text-align: center;
  }
  
  .completion-date {
    font-size: 0.85rem;
    color: var(--vp-c-text-3);
    text-align: center;
    display: block;
  }
  
  .back-nav-btn {
    width: auto;
    max-width: 200px;
    margin: 0 auto;
    display: block;
    text-align: center;
    padding: 0.6rem 1rem;
    font-size: 0.85rem;
    border-radius: 6px;
    background: var(--vp-c-brand-1);
    color: white;
    border: none;
    cursor: pointer;
  }
  
  /* Performance overview mobile */
  .performance-overview {
    grid-template-columns: 1fr;
    gap: 0.5rem;
    padding: 0;
    margin-bottom: 0.5rem;
  }
  
  .key-insights {
    padding: 1rem;
    text-align: center;
    margin-bottom: 1rem;
  }
  
  .key-insights h2 {
    font-size: 1.6rem;
    font-weight: 600;
    margin-bottom: 1.5rem;
    color: var(--vp-c-text-1);
  }
  
  .overall-performance {
    flex-direction: column;
    text-align: center;
    gap: 1.5rem;
    align-items: center;
  }
  
  .score-badge {
    margin: 0 auto;
    width: 120px;
    height: 120px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
  }
  
  .score-value {
    font-size: 2.2rem;
    font-weight: 700;
    line-height: 1;
  }
  
  .score-label {
    font-size: 0.8rem;
    margin-top: 0.4rem;
    font-weight: 500;
  }
  
  .performance-summary {
    max-width: 100%;
  }
  
  .performance-summary h3 {
    font-size: 1.3rem;
    font-weight: 600;
    margin-bottom: 1rem;
    color: var(--vp-c-text-1);
    line-height: 1.3;
  }
  
  .summary-stats {
    font-size: 1rem;
    line-height: 1.5;
    margin-bottom: 1.5rem;
    color: var(--vp-c-text-2);
  }
  
  .performance-message {
    font-size: 1rem;
    line-height: 1.5;
    color: var(--vp-c-text-2);
    background: var(--vp-c-bg-soft, rgba(0, 0, 0, 0.04));
    padding: 1rem;
    border-radius: 8px;
    border-left: 4px solid var(--vp-c-brand-1);
  }
  
  /* Learning path section mobile */
  .learning-path-section {
    padding: 0;
    background: transparent;
    margin: 0;
    border-radius: 0;
  }

  
  /* Next steps section mobile */
  .next-steps-section {
    padding: 0;
    text-align: center;
    margin: 0 auto;
  }
  
  .next-steps-section h2 {
    font-size: 1.6rem;
    font-weight: 600;
    margin-bottom: 1.5rem;
    color: var(--vp-c-text-1);
  }
  
  .simple-actions {
    flex-direction: column;
    gap: 0.75rem;
    max-width: 320px;
    margin: 0.5rem auto 0;
    padding: 0;
  }
  
  .simple-actions .action-button {
    width: 100% !important;
    justify-content: center;
    padding: 1rem 1.5rem;
    font-size: 1rem;
    border-radius: 8px;
  }
  
  /* Assessment selection mobile */
  .results-overview {
    margin-bottom: 1.5rem;
  }
  
  .overview-card {
    grid-template-columns: repeat(2, 1fr);
    padding: 1rem;
    gap: 1rem;
    background: var(--vp-c-bg-soft);
    border-radius: 8px;
  }
  
  .overview-stat {
    padding: 0.5rem;
    text-align: center;
  }
  
  .overview-stat .stat-number {
    font-size: 1.25rem;
    font-weight: 600;
    margin-bottom: 0.25rem;
  }
  
  .overview-stat .stat-label {
    font-size: 0.65rem;
    color: var(--vp-c-text-2);
    line-height: 1.2;
    font-weight: 500;
    text-transform: uppercase;
    letter-spacing: 0.3px;
  }
  
  /* History list mobile */
  .attempts-grid {
    gap: 0;
    border-radius: 8px;
  }
  
  .history-item {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    padding: 1rem;
    border-bottom: 1px solid var(--vp-c-divider);
  }
  
  .history-item:last-child {
    border-bottom: none;
  }
  
  .history-item:hover {
    background: var(--vp-c-bg-soft);
  }
  
  .item-header {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
    width: 100%;
    flex: none;
  }
  
  .item-info-group {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0.25rem;
  }
  
  .item-title {
    font-size: 0.9rem;
    font-weight: 600;
    white-space: normal;
    overflow: visible;
    text-overflow: initial;
    text-align: center;
    line-height: 1.3;
  }
  
  .item-date {
    display: block;
    font-size: 0.75rem;
    color: var(--vp-c-text-3);
    text-align: center;
  }
  
  .item-result {
    font-size: 0.85rem;
    font-weight: 600;
    text-align: center;
  }
  
  .view-results-btn, .continue-btn {
    width: 100%;
    padding: 0.75rem;
    font-size: 0.85rem;
    text-align: center;
    margin-top: 0.5rem;
  }
  
  /* Card styling mobile */
  .card-header {
    padding: 1rem 1rem 0.5rem 1rem;
  }
  
  .card-header h2 {
    font-size: 1.2rem;
  }
  
  .card-content {
    padding: 0.75rem 1rem;
  }
  
  .card-footer {
    padding: 0.5rem 1rem 1rem 1rem;
  }
  
  /* Empty state mobile */
  .empty-state {
    padding: 2rem 1rem;
  }
  
  .empty-state-hero h2 {
    font-size: 1.4rem;
  }
  
  .empty-description {
    font-size: 0.9rem;
  }
  
  .empty-features {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .feature-preview {
    padding: 1.5rem;
  }
  
  .feature-icon {
    margin-bottom: 0.75rem;
  }

  .feature-icon-svg {
    width: 2rem;
    height: 2rem;
  }
  
  .feature-preview h3 {
    font-size: 0.95rem;
  }
  
  .feature-preview p {
    font-size: 0.8rem;
  }
  
  .empty-actions {
    flex-direction: column;
    gap: 0.75rem;
    max-width: 280px;
    margin: 0 auto;
  }
  
  .empty-actions .action-button {
    width: 100% !important;
  }
  
  .score-section {
    flex-direction: column;
    text-align: center;
  }
  
  .results-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }
  
  .results-actions {
    flex-direction: column;
  }
  
  .attempt-card:not(.enhanced) {
    flex-direction: column;
    text-align: center;
    gap: 1rem;
  }
}

@media (max-width: 480px) {
  .overview-card {
    grid-template-columns: repeat(2, 1fr);
    padding: 0.75rem;
    gap: 0.5rem;
  }
  
  .overview-stat {
    padding: 0.5rem 0.25rem;
  }
  
  .overview-stat .stat-number {
    font-size: 1.1rem;
  }
  
  .overview-stat .stat-label {
    font-size: 0.6rem;
  }
  
  .page-title h1 {
    font-size: 1.5rem;
  }
  
  .attempts-grid {
    grid-template-columns: 1fr;
  }
}

/* Email Notification Styles */
.email-notification {
  margin-top: 1rem;
  padding: 1rem;
  border-radius: 8px;
  border-left: 4px solid;
  animation: slideDown 0.3s ease-out;
}

.email-notification.success {
  background-color: #f0f9f0;
  border-left-color: #22c55e;
  color: #166534;
}

.email-notification.error {
  background-color: #fef2f2;
  border-left-color: #ef4444;
  color: #dc2626;
}

.notification-content {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.notification-icon {
  font-size: 1.2rem;
  flex-shrink: 0;
}

.notification-message {
  flex: 1;
  font-size: 0.9rem;
  line-height: 1.4;
}

.notification-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 4px;
  opacity: 0.6;
  transition: opacity 0.2s;
}

.notification-close:hover {
  opacity: 1;
  background-color: rgba(0, 0, 0, 0.1);
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>