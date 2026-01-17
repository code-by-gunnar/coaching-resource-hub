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

        <!-- Competency Breakdown Card - Moved to top -->
        <div v-if="competencyStats.length > 0" class="competency-breakdown-card">
          <div class="breakdown-card-header">
            <span class="card-icon">📊</span>
            <h3>Competency Breakdown</h3>
          </div>
          <div class="competency-grid">
            <div
              v-for="stat in competencyStats"
              :key="stat.area"
              class="competency-card"
              :class="getCompetencyClass(stat.percentage)"
            >
              <div class="competency-card-header">
                <span class="competency-name">{{ stat.area }}</span>
                <span class="competency-badge" :class="getCompetencyClass(stat.percentage)">
                  {{ stat.percentage }}%
                </span>
              </div>
              <div class="competency-bar">
                <div class="competency-fill" :style="{ width: stat.percentage + '%' }"></div>
              </div>
              <div class="competency-stats">
                <span class="correct-count">{{ stat.correct }}/{{ stat.total }} correct</span>
                <span class="status-label">{{ getCompetencyLabel(stat.percentage) }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Results Overview Note -->
        <div class="results-note">
          <p>
            <ChartBarSquareIcon class="inline-icon" aria-hidden="true" /> <strong>Results Summary:</strong> This page provides an overview of your performance.
            Generate your AI-powered analysis below for personalized insights, then download your complete PDF report.
          </p>
        </div>

        <!-- AI-Generated Analysis Report -->
        <div class="ai-report-section">
          <div class="ai-report-header">
            <h3>AI-Powered Analysis</h3>
            <p v-if="!aiReport">Get personalized insights and recommendations based on your specific answers.</p>
          </div>

          <!-- Generate Report Button -->
          <div v-if="!aiReport && !aiReportLoading" class="generate-report-action">
            <button @click="handleGenerateReport" class="generate-report-btn">
              Generate AI Report
            </button>
          </div>

          <!-- Loading State -->
          <div v-if="aiReportLoading" class="ai-report-loading">
            <div class="loading-spinner"></div>
            <p>Analyzing your responses and generating personalized insights...</p>
          </div>

          <!-- Error State -->
          <div v-if="aiReportError && !aiReportLoading" class="ai-report-error">
            <p>{{ aiReportError }}</p>
            <button @click="handleGenerateReport" class="retry-btn">Try Again</button>
          </div>

          <!-- AI Report Content - Card-Based Layout -->
          <div v-if="aiReport && !aiReportLoading" class="ai-report-content">
            <div class="report-metadata">
              <span v-if="aiReport.cached" class="report-cached-badge">Previously generated report</span>
              <span v-if="aiReport.fallback" class="report-fallback-badge">Basic Report</span>
            </div>

            <!-- Structured Report Cards -->
            <div v-if="hasParsedSections" class="report-sections">
              <!-- Overall Assessment -->
              <div v-if="parsedReport.overall" class="report-card overall-card">
                <div class="card-header">
                  <span class="card-icon">📊</span>
                  <h4>Overall Assessment</h4>
                </div>
                <div class="card-content" v-html="formatReportContent(parsedReport.overall)"></div>
              </div>

              <!-- Strength Areas -->
              <div v-if="parsedReport.strengths" class="report-card strengths-card">
                <div class="card-header">
                  <span class="card-icon">✨</span>
                  <h4>Strength Areas</h4>
                </div>
                <div class="card-content" v-html="formatReportContent(parsedReport.strengths)"></div>
              </div>

              <!-- Development Areas -->
              <div v-if="parsedReport.development" class="report-card development-card">
                <div class="card-header">
                  <span class="card-icon">🎯</span>
                  <h4>Development Areas</h4>
                </div>
                <div class="card-content" v-html="formatReportContent(parsedReport.development)"></div>
              </div>

              <!-- Cross-Competency Insights -->
              <div v-if="parsedReport.crossCompetency" class="report-card insights-card">
                <div class="card-header">
                  <span class="card-icon">🔗</span>
                  <h4>Cross-Competency Insights</h4>
                </div>
                <div class="card-content" v-html="formatReportContent(parsedReport.crossCompetency)"></div>
              </div>

              <!-- Progress Notes -->
              <div v-if="parsedReport.progress" class="report-card progress-card">
                <div class="card-header">
                  <span class="card-icon">📈</span>
                  <h4>Progress Notes</h4>
                </div>
                <div class="card-content" v-html="formatReportContent(parsedReport.progress)"></div>
              </div>

              <!-- Priority Focus -->
              <div v-if="parsedReport.priority" class="report-card priority-card">
                <div class="card-header">
                  <span class="card-icon">🚀</span>
                  <h4>Priority Focus</h4>
                </div>
                <div class="card-content" v-html="formatReportContent(parsedReport.priority)"></div>
              </div>
            </div>

            <!-- Fallback: Raw markdown if parsing fails -->
            <div v-else class="report-fallback">
              <div class="fallback-notice">
                <span>📄</span> Report content
              </div>
              <div class="report-markdown" v-html="renderMarkdown(aiReport.content)"></div>
            </div>
          </div>
        </div>

      </div>

      <!-- Next Steps Section -->
      <div class="next-steps-section">
        <div class="simple-actions">
          <ActionButton
            v-if="aiReport"
            @click="downloadPdfReport"
            variant="primary"
            icon="📄"
            :loading="pdfGenerating"
          >
            {{ pdfGenerating ? 'Generating PDF...' : 'Download PDF Report' }}
          </ActionButton>
          <ActionButton
            v-else
            @click="emailAssessmentPDF"
            variant="secondary"
            icon="📧"
            :loading="emailLoading"
          >
            {{ emailLoading ? 'Sending...' : 'Email Assessment' }}
          </ActionButton>
        </div>

        <!-- PDF Error Notification -->
        <div v-if="pdfError" class="email-notification error">
          <div class="notification-content">
            <XCircleIcon class="notification-icon-svg error" aria-hidden="true" />
            <span class="notification-message">{{ pdfError }}</span>
            <button @click="pdfError = null" class="notification-close">×</button>
          </div>
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
          <p>Manage your assessments, continue in-progress tests, and review detailed results with AI-powered analysis.</p>
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
            class="assessment-card"
            :class="{ 'in-progress': attempt.status !== 'completed' }"
          >
            <div class="card-top">
              <AssessmentBadge
                :framework="attempt.framework"
                :difficulty="attempt.difficulty"
                size="small"
              />
              <span class="card-date">{{ formatDate(attempt.status === 'completed' ? attempt.completed_at : attempt.started_at) }}</span>
            </div>

            <div class="card-body">
              <h4 class="card-title">{{ attempt.assessment_title }}</h4>
              <p class="card-framework">{{ attempt.framework_name }}</p>
            </div>

            <div class="card-footer">
              <div v-if="attempt.status === 'completed'" class="score-display" :class="getScoreClass(attempt.score)">
                <div class="score-info">
                  <div class="score-value">
                    <span class="score-number">{{ Math.round(attempt.score ?? 0) }}</span>
                    <span class="score-percent">%</span>
                  </div>
                  <span class="score-label">{{ getScoreLabel(attempt.score ?? 0) }}</span>
                </div>
                <div class="score-bar-container">
                  <div class="score-bar" :style="{ width: `${Math.round(attempt.score ?? 0)}%` }"></div>
                </div>
              </div>
              <div v-else class="progress-display">
                <span class="progress-text">In Progress</span>
                <span class="progress-detail">Question {{ attempt.current_question_index || 1 }}/{{ attempt.total_questions }}</span>
              </div>

              <button v-if="attempt.status === 'completed'" @click="selectAttempt(attempt.id)" class="view-results-btn">
                View Results
              </button>
              <button v-else @click="continueAssessment(attempt)" class="continue-btn">
                Continue
              </button>
            </div>
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
import { ref, computed, onMounted, watch } from 'vue'
import {
  ClipboardDocumentCheckIcon,
  ChartBarSquareIcon,
  ArrowTrendingUpIcon,
  CheckCircleIcon,
  XCircleIcon
} from '@heroicons/vue/24/outline'
import { useAuth } from '../composables/useAuth.js'
import { useSupabase } from '../composables/useSupabase.js'
import { useAiAssessmentAttempts, useAiAssessmentResults } from '../composables/useAiAssessments.js'
import { useBetaAccess } from '../composables/useBetaAccess.js'
import { usePdfReport } from '../composables/usePdfReport.js'

// Composables
const { user } = useAuth()
const { supabase } = useSupabase()
const { getUserAttempts } = useAiAssessmentAttempts()
const { getAttemptResults, generateAiReport, getCachedReport, clearAiReport, aiReport, aiReportLoading, aiReportError } = useAiAssessmentResults()
const { hasBetaAccess, betaAccessMessage } = useBetaAccess(user)
const { generating: pdfGenerating, error: pdfError, generatePdf } = usePdfReport()

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

// Load user's assessment attempts from AI system
const loadUserAttempts = async () => {
  if (!user.value) return

  loading.value = true

  try {
    // Use AI composable to get attempts
    const attemptsData = await getUserAttempts(user.value.id)

    // Transform AI attempt data to expected format
    userAttempts.value = (attemptsData || []).map(attempt => ({
      id: attempt.id,
      assessment_id: attempt.level_id,
      assessment_title: attempt.level?.name || 'Assessment',
      framework_name: attempt.level?.framework?.name || 'Core Coaching',
      assessment_slug: `${attempt.level?.framework?.code || 'core'}-${attempt.level?.level_code || 'beginner'}`,
      framework: attempt.level?.framework?.code || 'core',
      difficulty: attempt.level?.level_code || 'beginner',  // Use level_code for badge (beginner/intermediate/advanced)
      status: attempt.completed_at ? 'completed' : 'in_progress',
      score: attempt.score_percentage,
      completed_at: attempt.completed_at,
      started_at: attempt.started_at,
      time_spent: null, // AI system doesn't track time_spent
      current_question_index: attempt.answers ? Object.keys(attempt.answers).length : 0,
      total_questions: attempt.questions_served?.length || 0,
      attempt_number: 1
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

  // Clear any previous AI report when switching attempts
  clearAiReport()

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

    // Auto-load cached AI report if available for this specific attempt
    try {
      await getCachedReport(attemptId)
    } catch (e) {
      // Ignore errors - user can manually generate report
    }
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
  // First, check if we have competency_scores from the AI system
  const aiCompetencyScores = selectedAttempt.value?.attempt?.competency_scores ||
                            selectedAttempt.value?.competency_scores ||
                            selectedAttempt.value?.competencyScores

  if (aiCompetencyScores && Object.keys(aiCompetencyScores).length > 0) {
    // Use pre-calculated scores from AI system
    return Object.entries(aiCompetencyScores)
      .map(([area, stats]) => ({
        area,
        correct: stats.correct || 0,
        total: stats.total || 0,
        percentage: Math.round(stats.percentage || 0)
      }))
      .sort((a, b) => b.percentage - a.percentage)
  }

  // Fallback: Calculate from responses (legacy system)
  if (!selectedAttempt.value?.responses) return []

  const competencies = {}
  selectedAttempt.value.responses.forEach(response => {
    // AI system uses response.question.competency_area
    const area = response.question?.competency_area
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

// For AI system, we use AI-generated reports instead of frontend insights
const personalizedCompetencyAnalysis = ref([])

// Assessment framework computed
const assessmentFramework = computed(() => {
  return selectedAttempt.value?.attempt?.assessments?.framework || selectedAttempt.value?.assessments?.framework || 'core'
})

// Question detail methods
const toggleQuestionDetail = (questionId) => {
  const index = expandedQuestions.value.indexOf(questionId)
  if (index > -1) {
    expandedQuestions.value.splice(index, 1)
  } else {
    expandedQuestions.value.push(questionId)
  }
}

// AI system uses AI-generated reports - no frontend insights capture needed


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

// PDF Download functionality
const downloadPdfReport = async () => {
  if (!selectedAttempt.value || !aiReport.value) {
    return
  }

  const attempt = selectedAttempt.value.attempt || selectedAttempt.value
  const assessment = attempt?.assessments || selectedAttempt.value.assessments

  await generatePdf({
    assessmentTitle: assessment?.title || 'Coaching Assessment',
    framework: assessment?.framework || 'Core',
    difficulty: assessment?.difficulty || 'Beginner',
    score: attempt?.score ?? selectedAttempt.value.score ?? 0,
    correctAnswers: attempt?.correct_answers ?? selectedAttempt.value.correct_answers,
    totalQuestions: attempt?.total_questions ?? selectedAttempt.value.total_questions,
    timeSpent: attempt?.time_spent || selectedAttempt.value.time_spent,
    completedAt: attempt?.completed_at || selectedAttempt.value.completed_at,
    competencyStats: competencyStats.value,
    aiReport: aiReport.value,
    parsedReport: parsedReport.value
  })
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

// AI Report functions
const handleGenerateReport = async () => {
  const attemptId = selectedAttempt.value?.attempt?.id || selectedAttempt.value?.id
  if (!attemptId) return

  try {
    // First check for cached report
    const cached = await getCachedReport(attemptId)
    if (cached) {
      console.log('Using cached AI report')
      return
    }

    // Generate new report
    await generateAiReport(attemptId)
  } catch (err) {
    console.error('Error generating AI report:', err)
  }
}

// Simple markdown to HTML renderer for AI reports (legacy fallback)
const renderMarkdown = (markdown) => {
  if (!markdown) return ''

  return markdown
    // Headers
    .replace(/^### (.*$)/gim, '<h4>$1</h4>')
    .replace(/^## (.*$)/gim, '<h3>$1</h3>')
    .replace(/^# (.*$)/gim, '<h2>$1</h2>')
    // Bold
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    // Italic
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    // Lists
    .replace(/^\s*[-*]\s+(.*$)/gim, '<li>$1</li>')
    .replace(/(<li>.*<\/li>)/s, '<ul>$1</ul>')
    // Numbered lists
    .replace(/^\s*\d+\.\s+(.*$)/gim, '<li>$1</li>')
    // Paragraphs (double newlines)
    .replace(/\n\n/g, '</p><p>')
    // Single newlines to breaks
    .replace(/\n/g, '<br>')
    // Wrap in paragraph
    .replace(/^(.*)$/s, '<p>$1</p>')
    // Clean up empty paragraphs
    .replace(/<p><\/p>/g, '')
    .replace(/<p><br><\/p>/g, '')
}

// Enhanced markdown content formatter for card-based display
const formatReportContent = (text) => {
  if (!text) return ''

  const lines = text.split('\n')
  let html = ''
  let inList = false

  for (let line of lines) {
    line = line.trim()
    if (!line) {
      if (inList) {
        html += '</ul>'
        inList = false
      }
      continue
    }

    // Bold competency headers like **Active Listening (0%)**
    if (line.startsWith('**') && line.endsWith('**')) {
      if (inList) {
        html += '</ul>'
        inList = false
      }
      const content = line.slice(2, -2)
      html += `<h5 class="competency-header">${content}</h5>`
      continue
    }

    // List items
    if (line.startsWith('- ') || line.startsWith('* ')) {
      if (!inList) {
        html += '<ul>'
        inList = true
      }
      const content = line.slice(2)
      html += `<li>${formatInlineMarkdown(content)}</li>`
      continue
    }

    // Regular paragraph
    if (inList) {
      html += '</ul>'
      inList = false
    }
    html += `<p>${formatInlineMarkdown(line)}</p>`
  }

  if (inList) {
    html += '</ul>'
  }

  return html
}

// Format inline markdown (bold, italic, quotes)
const formatInlineMarkdown = (text) => {
  return text
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    .replace(/"([^"]+)"/g, '<span class="quote">"$1"</span>')
}

// Parse AI report into structured sections for card display
const parseReport = (content) => {
  if (!content) return {}

  const sections = {
    overall: '',
    strengths: '',
    development: '',
    crossCompetency: '',
    progress: '',
    priority: ''
  }

  // Use regex to extract sections more reliably

  // Extract Overall Score section (## Overall Score: X% or ## Overall Assessment)
  const overallMatch = content.match(/## Overall[^\n]*\n([\s\S]*?)(?=\n## |\n---|\n\*Basic|$)/i)
  if (overallMatch) {
    sections.overall = overallMatch[1].trim()
  }

  // Extract Strength Areas (### Strength Areas or ## Strength Areas)
  const strengthMatch = content.match(/###?\s*Strength[s]?\s*(?:Areas?)?\n([\s\S]*?)(?=\n###?\s|\n## |\n---|\n\*Basic|$)/i)
  if (strengthMatch) {
    sections.strengths = strengthMatch[1].trim()
  }

  // Extract Development Areas (### Development Areas or ## Development Areas)
  const developmentMatch = content.match(/###?\s*Development\s*(?:Areas?)?\n([\s\S]*?)(?=\n###?\s|\n## |\n---|\n\*Basic|$)/i)
  if (developmentMatch) {
    sections.development = developmentMatch[1].trim()
  }

  // Extract Cross-Competency Insights
  const crossCompMatch = content.match(/###?\s*Cross[- ]?Competency[^\n]*\n([\s\S]*?)(?=\n###?\s|\n## |\n---|\n\*Basic|$)/i)
  if (crossCompMatch) {
    sections.crossCompetency = crossCompMatch[1].trim()
  }

  // Extract Progress/Comparison section
  const progressMatch = content.match(/###?\s*(?:Progress|Comparison|Previous)[^\n]*\n([\s\S]*?)(?=\n###?\s|\n## |\n---|\n\*Basic|$)/i)
  if (progressMatch) {
    sections.progress = progressMatch[1].trim()
  }

  // Extract Priority/Recommendations section
  const priorityMatch = content.match(/###?\s*(?:Priority|Recommendation|Focus|Next\s*Step)[^\n]*\n([\s\S]*?)(?=\n###?\s|\n## |\n---|\n\*Basic|$)/i)
  if (priorityMatch) {
    sections.priority = priorityMatch[1].trim()
  }

  return sections
}

// Computed: parsed AI report sections
const parsedReport = computed(() => {
  if (!aiReport.value?.content) return {}
  return parseReport(aiReport.value.content)
})

// Computed: check if any sections were parsed
const hasParsedSections = computed(() => {
  const report = parsedReport.value
  return report.overall || report.strengths || report.development ||
         report.crossCompetency || report.progress || report.priority
})

// Get CSS class for competency based on percentage
const getCompetencyClass = (percentage) => {
  if (percentage >= 80) return 'excellent'
  if (percentage >= 60) return 'good'
  if (percentage >= 40) return 'developing'
  return 'needs-work'
}

// Get label for competency based on percentage
const getCompetencyLabel = (percentage) => {
  if (percentage >= 80) return 'Excellent'
  if (percentage >= 60) return 'Good'
  if (percentage >= 40) return 'Developing'
  return 'Needs Work'
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
  // Navigate to AI assessment player with continue action
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

/* Enhanced Assessment Card Grid */
.attempts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 1.25rem;
  max-width: 1000px;
  margin: 0 auto;
}

.assessment-card {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  padding: 1.25rem;
  transition: all 0.3s ease;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.assessment-card:hover {
  border-color: var(--vp-c-brand-1);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.assessment-card.in-progress {
  border-left: 4px solid #10b981;
}

.card-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
}

.card-date {
  color: var(--vp-c-text-3);
  font-size: 0.8rem;
  white-space: nowrap;
}

.card-body {
  flex: 1;
}

.card-title {
  margin: 0 0 0.25rem 0;
  color: var(--vp-c-text-1);
  font-size: 1.1rem;
  font-weight: 600;
}

.card-framework {
  margin: 0;
  color: var(--vp-c-text-3);
  font-size: 0.8rem;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.25rem 0 0;
  margin-top: auto;
  border-top: 1px solid var(--vp-c-divider);
  gap: 1rem;
}

.score-display {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  flex: 1;
  min-width: 0;
}

.score-info {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
}

.score-value {
  display: flex;
  align-items: baseline;
  gap: 1px;
}

.score-number {
  font-size: 1.5rem;
  font-weight: 700;
  line-height: 1;
}

.score-percent {
  font-size: 0.9rem;
  font-weight: 600;
}

.score-label {
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.02em;
}

.score-bar-container {
  width: 100%;
  height: 6px;
  background: var(--vp-c-bg-soft);
  border-radius: 3px;
  overflow: hidden;
}

.score-bar {
  height: 100%;
  border-radius: 3px;
  background: currentColor;
  transition: width 0.3s ease;
}

.score-display.excellent { color: #22c55e; }
.score-display.good { color: #3b82f6; }
.score-display.fair { color: #f59e0b; }
.score-display.needs-improvement { color: #ef4444; }

.view-results-btn {
  flex-shrink: 0;
}

.progress-display {
  display: flex;
  flex-direction: column;
}

.progress-text {
  color: #10b981;
  font-size: 1rem;
  font-weight: 600;
}

.progress-detail {
  color: var(--vp-c-text-3);
  font-size: 0.8rem;
}

.view-results-btn {
  padding: 0.6rem 1.25rem;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 8px;
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
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
}

.continue-btn {
  padding: 0.6rem 1.25rem;
  background: #10b981;
  color: white;
  border: none;
  border-radius: 8px;
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
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

/* Dark mode card adjustments */
.dark .assessment-card {
  background: var(--vp-c-bg-soft);
}

.dark .assessment-card:hover {
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
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

.attempt-card.enhanced .card-footer {
  padding: 1.25rem 1.25rem 1.25rem 1.25rem;
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
  
  /* Assessment cards mobile */
  .attempts-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }

  .assessment-card {
    padding: 1rem;
  }

  .card-title {
    font-size: 1rem;
  }

  .card-footer {
    flex-direction: column;
    align-items: stretch;
    gap: 0.75rem;
  }

  .score-display {
    width: 100%;
  }

  .score-number {
    font-size: 1.3rem;
  }

  .score-percent {
    font-size: 0.8rem;
  }

  .score-label {
    font-size: 0.7rem;
  }

  .view-results-btn, .continue-btn {
    padding: 0.6rem 1rem;
    font-size: 0.85rem;
    width: 100%;
    text-align: center;
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

/* AI Report Section */
.ai-report-section {
  margin: 2rem 0;
  padding: 1.5rem;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
}

.ai-report-header {
  text-align: center;
  margin-bottom: 1.5rem;
}

.ai-report-header h3 {
  margin: 0 0 0.5rem 0;
  color: var(--vp-c-text-1);
  font-size: 1.25rem;
}

.ai-report-header p {
  margin: 0;
  color: var(--vp-c-text-2);
  font-size: 0.9rem;
}

.generate-report-action {
  text-align: center;
}

.generate-report-btn {
  padding: 12px 24px;
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 600;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
}

.generate-report-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(99, 102, 241, 0.4);
}

.ai-report-loading {
  text-align: center;
  padding: 2rem;
}

.ai-report-loading p {
  margin-top: 1rem;
  color: var(--vp-c-text-2);
}

.ai-report-error {
  text-align: center;
  padding: 1.5rem;
  background: #fef2f2;
  border-radius: 8px;
  color: #dc2626;
}

.retry-btn {
  margin-top: 1rem;
  padding: 8px 16px;
  background: #dc2626;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
}

.ai-report-content {
  margin-top: 1.5rem;
}

.report-cached-badge {
  display: inline-block;
  padding: 4px 12px;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
  border-radius: 16px;
  font-size: 0.75rem;
  font-weight: 500;
  margin-bottom: 1rem;
}

.report-markdown {
  background: var(--vp-c-bg);
  padding: 1.5rem;
  border-radius: 8px;
  border: 1px solid var(--vp-c-divider);
  line-height: 1.7;
  color: var(--vp-c-text-1);
}

.report-markdown h2 {
  margin: 1.5rem 0 1rem 0;
  color: var(--vp-c-text-1);
  font-size: 1.3rem;
  border-bottom: 1px solid var(--vp-c-divider);
  padding-bottom: 0.5rem;
}

.report-markdown h3 {
  margin: 1.25rem 0 0.75rem 0;
  color: var(--vp-c-text-1);
  font-size: 1.1rem;
}

.report-markdown h4 {
  margin: 1rem 0 0.5rem 0;
  color: var(--vp-c-text-2);
  font-size: 1rem;
}

.report-markdown ul {
  margin: 0.5rem 0;
  padding-left: 1.5rem;
}

.report-markdown li {
  margin-bottom: 0.5rem;
}

.report-markdown p {
  margin: 0.75rem 0;
}

.report-markdown strong {
  color: var(--vp-c-brand-1);
}

/* Report Metadata */
.report-metadata {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.report-fallback-badge {
  display: inline-block;
  padding: 4px 12px;
  background: #fef3c7;
  color: #92400e;
  border-radius: 16px;
  font-size: 0.75rem;
  font-weight: 500;
}

/* Report Cards Layout */
.report-sections {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.report-card {
  background: var(--vp-c-bg);
  border-radius: 12px;
  border: 1px solid var(--vp-c-divider);
  overflow: hidden;
}

.report-card .card-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem 1.25rem;
  border-bottom: 1px solid var(--vp-c-divider);
}

.report-card .card-icon {
  font-size: 1.25rem;
}

.report-card .card-header h4 {
  margin: 0;
  font-size: 1rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.report-card .card-content {
  padding: 1.25rem;
  line-height: 1.7;
  color: var(--vp-c-text-2);
}

.report-card .card-content :deep(p) {
  margin: 0 0 1rem 0;
}

.report-card .card-content :deep(p:last-child) {
  margin-bottom: 0;
}

.report-card .card-content :deep(h5.competency-header) {
  margin: 1.25rem 0 0.75rem 0;
  padding: 0.5rem 0.75rem;
  background: var(--vp-c-bg-soft);
  border-radius: 6px;
  font-size: 0.95rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.report-card .card-content :deep(h5.competency-header:first-child) {
  margin-top: 0;
}

.report-card .card-content :deep(ul) {
  margin: 0.75rem 0;
  padding-left: 1.25rem;
}

.report-card .card-content :deep(li) {
  margin-bottom: 0.5rem;
  color: var(--vp-c-text-2);
}

.report-card .card-content :deep(strong) {
  color: var(--vp-c-text-1);
  font-weight: 600;
}

.report-card .card-content :deep(.quote) {
  color: var(--vp-c-text-1);
  font-style: italic;
  background: var(--vp-c-bg-soft);
  padding: 0.1rem 0.3rem;
  border-radius: 3px;
}

/* Card Variants - Light Mode */
.overall-card .card-header {
  background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
  border-bottom-color: #bae6fd;
}
.overall-card .card-header h4 { color: #0369a1; }

.strengths-card .card-header {
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
  border-bottom-color: #bbf7d0;
}
.strengths-card .card-header h4 { color: #15803d; }

.development-card .card-header {
  background: linear-gradient(135deg, #fffbeb 0%, #fef3c7 100%);
  border-bottom-color: #fde68a;
}
.development-card .card-header h4 { color: #b45309; }

.insights-card .card-header {
  background: linear-gradient(135deg, #faf5ff 0%, #f3e8ff 100%);
  border-bottom-color: #e9d5ff;
}
.insights-card .card-header h4 { color: #7c3aed; }

.progress-card .card-header {
  background: linear-gradient(135deg, #ecfeff 0%, #cffafe 100%);
  border-bottom-color: #a5f3fc;
}
.progress-card .card-header h4 { color: #0891b2; }

.priority-card .card-header {
  background: linear-gradient(135deg, #fef2f2 0%, #fee2e2 100%);
  border-bottom-color: #fecaca;
}
.priority-card .card-header h4 { color: #dc2626; }

/* Card Variants - Dark Mode */
.dark .overall-card .card-header {
  background: linear-gradient(135deg, #0c4a6e 0%, #075985 100%);
  border-bottom-color: #0369a1;
}
.dark .overall-card .card-header h4 { color: #7dd3fc; }

.dark .strengths-card .card-header {
  background: linear-gradient(135deg, #14532d 0%, #166534 100%);
  border-bottom-color: #15803d;
}
.dark .strengths-card .card-header h4 { color: #86efac; }

.dark .development-card .card-header {
  background: linear-gradient(135deg, #78350f 0%, #92400e 100%);
  border-bottom-color: #b45309;
}
.dark .development-card .card-header h4 { color: #fcd34d; }

.dark .insights-card .card-header {
  background: linear-gradient(135deg, #4c1d95 0%, #5b21b6 100%);
  border-bottom-color: #7c3aed;
}
.dark .insights-card .card-header h4 { color: #c4b5fd; }

.dark .progress-card .card-header {
  background: linear-gradient(135deg, #164e63 0%, #155e75 100%);
  border-bottom-color: #0891b2;
}
.dark .progress-card .card-header h4 { color: #67e8f9; }

.dark .priority-card .card-header {
  background: linear-gradient(135deg, #7f1d1d 0%, #991b1b 100%);
  border-bottom-color: #dc2626;
}
.dark .priority-card .card-header h4 { color: #fca5a5; }

/* Fallback Raw Content */
.report-fallback {
  background: var(--vp-c-bg);
  border-radius: 12px;
  border: 1px solid var(--vp-c-divider);
  overflow: hidden;
}

.fallback-notice {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  background: var(--vp-c-bg-soft);
  border-bottom: 1px solid var(--vp-c-divider);
  font-size: 0.85rem;
  color: var(--vp-c-text-3);
}

/* Competency Breakdown Card - Top Section */
.competency-breakdown-card {
  margin: 1.5rem 0;
  padding: 1.5rem;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
}

.breakdown-card-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 1.25rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--vp-c-divider);
}

.breakdown-card-header .card-icon {
  font-size: 1.25rem;
}

.breakdown-card-header h3 {
  margin: 0;
  color: var(--vp-c-text-1);
  font-size: 1.1rem;
  font-weight: 600;
}

.competency-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1rem;
}

.competency-card {
  padding: 1rem;
  background: var(--vp-c-bg);
  border-radius: 10px;
  border: 1px solid var(--vp-c-divider);
  border-left: 4px solid;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.competency-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.competency-card.excellent {
  border-left-color: #22c55e;
  background: linear-gradient(to right, rgba(34, 197, 94, 0.05), transparent);
}

.competency-card.good {
  border-left-color: #3b82f6;
  background: linear-gradient(to right, rgba(59, 130, 246, 0.05), transparent);
}

.competency-card.developing {
  border-left-color: #f59e0b;
  background: linear-gradient(to right, rgba(245, 158, 11, 0.05), transparent);
}

.competency-card.needs-work {
  border-left-color: #ef4444;
  background: linear-gradient(to right, rgba(239, 68, 68, 0.05), transparent);
}

.competency-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
}

.competency-card .competency-name {
  font-weight: 600;
  color: var(--vp-c-text-1);
  font-size: 0.95rem;
}

.competency-badge {
  padding: 0.25rem 0.6rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 700;
  color: white;
}

.competency-badge.excellent {
  background: #22c55e;
}

.competency-badge.good {
  background: #3b82f6;
}

.competency-badge.developing {
  background: #f59e0b;
}

.competency-badge.needs-work {
  background: #ef4444;
}

.competency-card .competency-bar {
  height: 8px;
  background: var(--vp-c-divider);
  border-radius: 4px;
  overflow: hidden;
  margin-bottom: 0.75rem;
}

.competency-card .competency-fill {
  height: 100%;
  border-radius: 4px;
  transition: width 0.5s ease;
}

.competency-card.excellent .competency-fill {
  background: linear-gradient(90deg, #22c55e, #4ade80);
}

.competency-card.good .competency-fill {
  background: linear-gradient(90deg, #3b82f6, #60a5fa);
}

.competency-card.developing .competency-fill {
  background: linear-gradient(90deg, #f59e0b, #fbbf24);
}

.competency-card.needs-work .competency-fill {
  background: linear-gradient(90deg, #ef4444, #f87171);
}

.competency-stats {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.85rem;
}

.correct-count {
  color: var(--vp-c-text-2);
}

.status-label {
  font-weight: 500;
}

.competency-card.excellent .status-label {
  color: #22c55e;
}

.competency-card.good .status-label {
  color: #3b82f6;
}

.competency-card.developing .status-label {
  color: #f59e0b;
}

.competency-card.needs-work .status-label {
  color: #ef4444;
}

/* Dark mode adjustments for competency cards */
.dark .competency-card {
  border-color: var(--vp-c-divider);
}

.dark .competency-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

.dark .competency-card.excellent {
  background: linear-gradient(to right, rgba(34, 197, 94, 0.1), transparent);
}

.dark .competency-card.good {
  background: linear-gradient(to right, rgba(59, 130, 246, 0.1), transparent);
}

.dark .competency-card.developing {
  background: linear-gradient(to right, rgba(245, 158, 11, 0.1), transparent);
}

.dark .competency-card.needs-work {
  background: linear-gradient(to right, rgba(239, 68, 68, 0.1), transparent);
}

@media (max-width: 640px) {
  .competency-grid {
    grid-template-columns: 1fr;
  }
}

/* Dark mode AI Report */
.dark .ai-report-error {
  background: rgba(239, 68, 68, 0.1);
}

.dark .report-markdown {
  background: var(--vp-c-bg-alt);
}
</style>