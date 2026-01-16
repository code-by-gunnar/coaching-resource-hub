<template>
  <div class="assessment-player">
    <div v-if="!user" class="auth-required">
      <div class="auth-message">
        <h2><ClipboardDocumentCheckIcon class="heading-icon" aria-hidden="true" /> Assessment Player</h2>
        <p>Please <a href="/docs/auth/">sign in</a> to take assessments.</p>
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

    <!-- Loading Modal -->
    <div v-if="loading" class="loading-modal-overlay">
      <div class="loading-modal">
        <div class="loading-spinner">
          <ClockIcon class="spinner-icon" aria-hidden="true" />
        </div>
        <h3 v-if="currentAssessment">{{ currentAssessment.title }}</h3>
        <h3 v-else>Loading Assessment</h3>
        <p v-if="currentAssessment">Initializing...</p>
        <p v-else>Loading data...</p>
      </div>
    </div>

    <!-- Inactivity Warning Dialog -->
    <div v-if="showInactivityDialog" class="resume-dialog-overlay">
      <div class="resume-dialog inactivity-dialog">
        <div class="resume-header">
          <h3>Assessment Paused</h3>
          <div class="resume-icon">
            <PauseCircleIcon class="pause-icon" aria-hidden="true" />
          </div>
        </div>
        
        <div class="resume-content">
          <p>Your assessment has been paused due to inactivity.</p>
          <p>You can resume later from where you left off.</p>
        </div>
        
        <div class="resume-actions">
          <ActionButton @click="handleInactivityOk" variant="primary" full-width>
            OK
          </ActionButton>
        </div>
      </div>
    </div>

    <!-- Exit Confirmation Dialog -->
    <div v-if="showExitDialog" class="resume-dialog-overlay">
      <div class="resume-dialog exit-dialog">
        <div class="resume-header">
          <h3>Exit Assessment?</h3>
          <div class="resume-icon">
            <ArrowRightStartOnRectangleIcon class="exit-dialog-icon" aria-hidden="true" />
          </div>
        </div>
        
        <div class="resume-content">
          <p>Are you sure you want to exit?</p>
          <p>Your progress will be saved and you can resume later.</p>
        </div>
        
        <div class="resume-actions">
          <ActionButton @click="confirmExit" variant="primary" full-width>
            Yes, Exit
          </ActionButton>
          <ActionButton @click="cancelExit" variant="secondary" full-width>
            Continue Assessment
          </ActionButton>
        </div>
      </div>
    </div>


    <div v-else-if="started && !completed" class="assessment-active">
      <div class="assessment-progress">
        <div class="progress-header">
          <div class="progress-info">
            <span class="question-number">Question {{ currentQuestionIndex + 1 }} of {{ questions.length }}</span>
            <div class="progress-bar">
              <div 
                class="progress-fill mobile-progress-fill" 
                :style="{ 
                  width: ((currentQuestionIndex + 1) / questions.length) * 100 + '%',
                  backgroundColor: '#3b82f6',
                  height: '100%'
                }"
              ></div>
            </div>
          </div>
        </div>
      </div>

      <div class="question-container">
        <div class="question-content">
          <div v-if="currentQuestion.scenario" class="scenario-box">
            <h4>Scenario:</h4>
            <p>{{ currentQuestion.scenario }}</p>
          </div>
          
          <div class="question-text">
            <h3>{{ currentQuestion.question }}</h3>
          </div>

          <div class="answer-options">
            <div 
              v-for="(option, index) in currentQuestion.options" 
              :key="index"
              class="answer-option"
              :class="{ selected: selectedAnswer === String.fromCharCode(65 + index) }"
              @click="selectAnswer(index)"
            >
              <div class="option-marker">{{ String.fromCharCode(65 + index) }}</div>
              <div class="option-text">{{ option.text }}</div>
            </div>
          </div>

          <div class="question-actions">
            <ActionButton @click="exitAssessment" variant="gray" size="small" title="Save and Exit">
              <XMarkIcon class="exit-icon" aria-hidden="true" />
              <span class="exit-text">Exit</span>
            </ActionButton>
            <ActionButton 
              @click="submitAnswer" 
              :disabled="selectedAnswer === null"
              variant="primary"
              size="large"
            >
              {{ currentQuestionIndex === questions.length - 1 ? 'Finish Assessment' : 'Next Question' }}
            </ActionButton>
          </div>
        </div>
      </div>
    </div>

    <div v-else-if="completed" class="assessment-completed">
      <div class="results-content">
        <div class="results-header">
          <div class="score-circle">
            <span class="score-number">{{ finalScore }}%</span>
          </div>
          <h2>Assessment Complete!</h2>
          <p class="score-description">{{ getScoreDescription(finalScore) }}</p>
        </div>

        <div class="results-breakdown">
          <div class="breakdown-header">
            <h3>Question Review</h3>
            <div class="review-summary">
              <span class="total-questions">{{ questionResults.length }} Questions</span>
              <span class="correct-count">{{ questionResults.filter(r => r.correct).length }} Correct</span>
              <span class="incorrect-count" v-if="questionResults.filter(r => !r.correct).length > 0">
                {{ questionResults.filter(r => !r.correct).length }} Incorrect
              </span>
            </div>
          </div>
          
          <!-- Review controls with items per page selector -->
          <div class="review-controls" v-if="showReviewPagination">
            <div class="review-controls-summary">
              <span class="summary-text">
                Showing {{ (reviewCurrentPage - 1) * reviewQuestionsPerPage + 1 }}-{{ Math.min(reviewCurrentPage * reviewQuestionsPerPage, questionResults.length) }} 
                of {{ questionResults.length }} questions
              </span>
            </div>
            
            <div class="items-per-page">
              <label for="review-items-per-page">Show:</label>
              <select 
                id="review-items-per-page" 
                :value="reviewQuestionsPerPage" 
                @change="changeReviewItemsPerPage(Number($event.target.value))"
                class="items-select"
              >
                <option value="5">5</option>
                <option value="10">10</option>
                <option value="20">20</option>
              </select>
            </div>
          </div>
          
          <div class="question-reviews">
            <div 
              v-for="(result, resultIndex) in paginatedQuestionResults" 
              :key="resultIndex"
              :class="['question-review', { correct: result.correct, incorrect: result.correct === false }]"
            >
              <div class="review-header">
                <span class="question-num">Q{{ ((reviewCurrentPage - 1) * reviewQuestionsPerPage) + resultIndex + 1 }}</span>
                <span class="result-icon" aria-hidden="true">
                  <CheckCircleIcon v-if="result.correct === true" class="icon-correct" />
                  <XCircleIcon v-else-if="result.correct === false" class="icon-incorrect" />
                  <ClockIcon v-else class="icon-pending" />
                </span>
              </div>
              <div class="review-content" v-if="paginatedDisplayQuestions[resultIndex]">
                <p class="review-question">{{ paginatedDisplayQuestions[resultIndex].question }}</p>
                <div class="review-answers">
                  <p><strong>Your answer:</strong> {{ paginatedDisplayQuestions[resultIndex].options[result.selectedAnswer.charCodeAt(0) - 65]?.text || 'N/A' }}</p>
                  <p><strong>Best answer:</strong> {{ paginatedDisplayQuestions[resultIndex].options[paginatedDisplayQuestions[resultIndex].correctAnswer - 1]?.text || 'N/A' }}</p>
                </div>
                <div class="explanation">
                  <strong>Explanation:</strong>
                  <p>{{ paginatedDisplayQuestions[resultIndex].explanation }}</p>
                </div>
              </div>
            </div>
          </div>

          <div class="pagination-controls" v-if="totalReviewPages > 1">
            <div class="pagination-left">
              <ActionButton 
                v-if="reviewCurrentPage > 1"
                @click="prevReviewPage" 
                variant="secondary"
                size="small"
                class="prev-btn"
              >
                ← Previous
              </ActionButton>
            </div>
            
            <div class="pagination-center">
              <div class="pagination-info">
                <span class="page-numbers">
                  <button
                    v-for="page in totalReviewPages"
                    :key="page"
                    @click="goToReviewPage(page)"
                    class="page-btn"
                    :class="{ active: reviewCurrentPage === page }"
                  >
                    {{ page }}
                  </button>
                </span>
                <span class="page-info">
                  Page {{ reviewCurrentPage }} of {{ totalReviewPages }}
                </span>
              </div>
            </div>
            
            <div class="pagination-right">
              <ActionButton 
                v-if="reviewCurrentPage < totalReviewPages"
                @click="nextReviewPage" 
                variant="secondary"
                size="small"
                class="next-btn"
              >
                Next →
              </ActionButton>
            </div>
          </div>
        </div>

        <div class="results-actions">
          <ActionButton @click="viewDetailedResults" variant="primary" size="large">
            View Detailed Results
          </ActionButton>
          <ActionButton @click="goToAssessments" variant="gray" size="medium">
            Back to Assessments
          </ActionButton>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useAuth } from '../composables/useAuth.js'
import { useAssessments, useAssessmentAttempts } from '../composables/useAssessments.js'
import { useBetaAccess } from '../composables/useBetaAccess.js'
import { useSupabase } from '../composables/useSupabase.js'
import ActionButton from './shared/ActionButton.vue'
import {
  XMarkIcon,
  CheckCircleIcon,
  XCircleIcon,
  ClockIcon,
  PauseCircleIcon,
  ClipboardDocumentCheckIcon,
  ArrowRightStartOnRectangleIcon
} from '@heroicons/vue/24/solid'

// Composables
const { user } = useAuth()
const { supabase } = useSupabase()
const { getAssessmentBySlug, getAssessmentQuestions } = useAssessments()
const { startAttempt, saveResponse, completeAttempt, abandonAttempt } = useAssessmentAttempts()
const { hasBetaAccess, betaAccessMessage } = useBetaAccess(user)

// Reactive state
const loading = ref(false)  // Will be triggered from assessments page
const started = ref(false)
const completed = ref(false)
const currentQuestionIndex = ref(0)
const selectedAnswer = ref(null)
const questionResults = ref([])
const currentAssessment = ref(null)
const questions = ref([])
const currentAttemptId = ref(null)
const assessmentStartTime = ref(null)
const resumeData = ref(null)
const completedScore = ref(0) // Store final score to persist after session cleanup

// Pagination for question review
const reviewCurrentPage = ref(1)
const reviewQuestionsPerPage = ref(5) // Start with 5 questions per page

// Session management
const showInactivityDialog = ref(false)
const showExitDialog = ref(false)
const autoSaveInterval = ref(null)
const idleTimer = ref(null)
const lastActivity = ref(Date.now())

// Computed properties
const currentQuestion = computed(() => {
  if (currentQuestionIndex.value < questions.value.length) {
    const q = questions.value[currentQuestionIndex.value]
    // Transform database format to component format
    return {
      scenario: q.scenario,
      question: q.question,
      options: [
        { text: q.option_a },
        { text: q.option_b },
        { text: q.option_c },
        { text: q.option_d }
      ],
      correctAnswer: q.correct_answer,
      explanation: q.explanation,
      id: q.id
    }
  }
  return null
})

const finalScore = computed(() => {
  // 🔥 PURGED: No more frontend score calculation!
  // Always use database-calculated score from the completed attempt
  if (completed.value && completedScore.value > 0) {
    return completedScore.value
  }
  
  // For ongoing assessments, show 0 until completion (database will calculate final score)
  return 0
})

// Transform database questions to display format for results
const displayQuestions = computed(() => {
  return questions.value.map(q => ({
    question: q.question,
    options: [
      { text: q.option_a },
      { text: q.option_b },
      { text: q.option_c },
      { text: q.option_d }
    ],
    correctAnswer: q.correct_answer,
    explanation: q.explanation
  }))
})

// Pagination computed properties
const totalReviewPages = computed(() => {
  return Math.ceil(questionResults.value.length / reviewQuestionsPerPage.value)
})

const paginatedQuestionResults = computed(() => {
  const start = (reviewCurrentPage.value - 1) * reviewQuestionsPerPage.value
  const end = start + reviewQuestionsPerPage.value
  return questionResults.value.slice(start, end)
})

const paginatedDisplayQuestions = computed(() => {
  const start = (reviewCurrentPage.value - 1) * reviewQuestionsPerPage.value
  const end = start + reviewQuestionsPerPage.value
  return displayQuestions.value.slice(start, end)
})

const showReviewPagination = computed(() => {
  return questionResults.value.length > reviewQuestionsPerPage.value
})


// Methods
const getFrameworkName = (framework) => {
  const names = {
    icf: 'ICF Core Competencies',
    ac: 'Association for Coaching',
    universal: 'Core Fundamentals'
  }
  return names[framework] || framework.toUpperCase()
}

// Updated for 3-tier system: strength (70-100%), developing (50-69%), weakness (0-49%)
const getScoreDescription = (score) => {
  if (score >= 90) return "Outstanding! You demonstrate mastery of coaching competencies."
  if (score >= 80) return "Excellent work! Your coaching skills are well-developed."
  if (score >= 70) return "Good job! You show solid understanding with room for growth." // Strength tier
  if (score >= 50) return "Developing well! Focus on consistency to reach strength level." // Developing tier
  return "This indicates areas for significant development. Consider additional training." // Weakness tier
}

const changeReviewItemsPerPage = (itemsCount) => {
  reviewQuestionsPerPage.value = itemsCount
  reviewCurrentPage.value = 1 // Reset to first page when changing page size
}

const getAssessmentCompetencies = () => {
  if (!currentAssessment.value) return []
  
  // Define specific competencies for each assessment
  const competencyMap = {
    'core-fundamentals': [
      'Active Listening & Presence',
      'Powerful Questioning Techniques', 
      'Present-Moment Awareness',
      'Creating Safe Coaching Space',
      'Building Trust & Rapport',
      'Exploring Client Perspectives',
      'Supporting Client Self-Discovery'
    ],
    'icf-core-competencies': [
      'Demonstrates Ethical Practice',
      'Embodies a Coaching Mindset',
      'Establishes and Maintains Agreements',
      'Cultivates Trust and Safety',
      'Maintains Presence',
      'Listens Actively',
      'Evokes Awareness',
      'Facilitates Client Growth'
    ],
    'ac-competency-framework': [
      'Self-Awareness and Ongoing Development',
      'Understanding of Coaching Theory',
      'Ability to Form Effective Relationships',
      'Solution Focus and Outcome Orientation',
      'Responsive and Flexible Coaching',
      'Use of Models, Techniques, and Skills'
    ]
  }
  
  return competencyMap[currentAssessment.value.slug] || []
}

const startAssessment = async () => {
  try {
    // Start database attempt
    const attempt = await startAttempt(user.value.id, currentAssessment.value.id, questions.value.length)
    currentAttemptId.value = attempt.id
    assessmentStartTime.value = Date.now()
    
    // Reset UI state
    started.value = true
    currentQuestionIndex.value = 0
    selectedAnswer.value = null
    questionResults.value = []
    completedScore.value = 0 // Reset completed score for new assessment
    
    // Update current_question_index in database to track they're viewing question 1
    try {
      
      await supabase
        .from('user_assessment_attempts')
        .update({ 
          current_question_index: 1,  // They're now viewing question 1
          last_activity_at: new Date().toISOString(),
          status: 'in_progress'  // Mark as in_progress when they start viewing questions
        })
        .eq('id', currentAttemptId.value)
        
      console.log('Set current_question_index to 1 (viewing first question)')
    } catch (error) {
      console.error('Error setting initial current question index:', error)
      // Don't fail the whole flow if this update fails
    }
    
    // Start session management
    startAutoSave()
    startIdleMonitoring()
    saveSessionState()
    
    console.log('Assessment started with session management')
  } catch (error) {
    console.error('Error starting assessment:', error)
    alert('Failed to start assessment. Please try again.')
  }
}

const selectAnswer = (index) => {
  // Convert index to letter (0->A, 1->B, 2->C, 3->D)
  selectedAnswer.value = String.fromCharCode(65 + index)
}

const submitAnswer = async () => {
  if (selectedAnswer.value === null) return
  
  // Prevent double submission
  if (questionResults.value.some(r => r.questionIndex === currentQuestionIndex.value)) {
    console.log('Question already answered, skipping...')
    return
  }
  
  const questionStartTime = Date.now() - (questionResults.value.length === 0 ? assessmentStartTime.value : questionResults.value[questionResults.value.length - 1]?.timestamp || assessmentStartTime.value)
  const responseTime = Math.round(questionStartTime / 1000) // Convert to seconds
  
  try {
    // 🔥 PURGED: No more frontend answer validation!
    // Database triggers will determine correctness based on proper answer_options relationships
    console.log('🔍 ANSWER SUBMISSION - Database will validate correctness:')
    console.log('  - Question:', currentQuestionIndex.value + 1)
    console.log('  - Selected answer letter:', selectedAnswer.value)
    console.log('  - Database will determine correctness via triggers')
    
    // We don't know if it's correct yet - database will tell us
    const isCorrect = null // Database will determine this
    
    // Save response to database (database trigger will set correctness)
    await saveResponse(
      currentAttemptId.value,
      currentQuestion.value.id,
      selectedAnswer.value,
      isCorrect, // This parameter is ignored - kept for compatibility
      responseTime
    )
    
    // Fetch the database-determined correctness immediately
    const { data: dbResponse } = await supabase
      .from('user_question_responses')
      .select('is_correct')
      .eq('attempt_id', currentAttemptId.value)
      .eq('question_id', currentQuestion.value.id)
      .single()
    
    console.log('🎯 Database determined correctness:', dbResponse?.is_correct)
    
    // Record the result locally with database-determined correctness
    questionResults.value.push({
      selectedAnswer: selectedAnswer.value,
      correct: dbResponse?.is_correct || false,
      timestamp: Date.now(),
      questionIndex: currentQuestionIndex.value
    })

    // Move to next question or complete
    if (currentQuestionIndex.value < questions.value.length - 1) {
      currentQuestionIndex.value++
      selectedAnswer.value = null
      
      // Update current_question_index in database to store the question they're now viewing
      try {
        const { data, error } = await supabase
          .from('user_assessment_attempts')
          .update({ 
            current_question_index: currentQuestionIndex.value + 1,  // Store as 1-based (question they're currently viewing)
            last_activity_at: new Date().toISOString(),
            status: 'in_progress'  // Mark as in_progress once they've answered questions
          })
          .eq('id', currentAttemptId.value)
          .select()
          
        if (error) {
          console.error('Supabase error updating current question index:', error)
          // Check if attempt doesn't exist
          if (error.message?.includes('0 rows') || error.code === 'PGRST116') {
            console.warn('Assessment attempt no longer exists, clearing stale state')
            // Clear stale state and redirect to assessments
            currentAttemptId.value = null
            window.location.href = '/docs/assessments/'
            return
          }
        } else {
          console.log(`Updated current_question_index to ${currentQuestionIndex.value + 1} (viewing question ${currentQuestionIndex.value + 1})`)
        }
      } catch (error) {
        console.error('Error updating current question index:', error)
        // Don't fail the whole flow if this update fails
      }
    } else {
      // Complete assessment
      try {
        const totalTime = Math.round((Date.now() - assessmentStartTime.value) / 1000)
        console.log('About to complete assessment with total time:', totalTime)
        console.log('Current attempt ID:', currentAttemptId.value)
        console.log('Questions answered:', questionResults.value.length)
        
        // 🔥 PURGED: No more frontend score calculation!
        // The database will calculate the correct score via triggers
        console.log('🔍 FRONTEND CALCULATION PURGED - Database will handle scoring')
        
        const result = await completeAttempt(currentAttemptId.value, totalTime)
        console.log('Complete attempt returned:', result)
        console.log('🔍 DATABASE SCORE (source of truth):', result?.score)
        
        // Store the database-calculated score for immediate display
        completedScore.value = result?.score || 0
        
        // 🎯 Database trigger check_answer_correctness_v4 handles correctness automatically!
        
        // Clear session data on completion (but keep currentAttemptId for detailed results)
        clearSessionData()
        
        completed.value = true
        // Don't clear currentAttemptId - we need it for detailed results button
        console.log('Assessment completed successfully! completed.value is now:', completed.value)
      } catch (completionError) {
        console.error('Error completing assessment:', completionError)
        console.error('Completion error details:', JSON.stringify(completionError, null, 2))
        alert('Failed to complete assessment. Please try again.')
        return // Don't proceed if completion fails
      }
    }
  } catch (error) {
    console.error('Error submitting answer:', error)
    alert('Failed to save answer. Please try again.')
  }
}

const viewDetailedResults = () => {
  console.log('viewDetailedResults called with currentAttemptId:', currentAttemptId.value)
  if (currentAttemptId.value) {
    const resultsUrl = `/docs/assessments/results?attempt=${currentAttemptId.value}`
    console.log('Redirecting to:', resultsUrl)
    window.location.href = resultsUrl
  } else {
    console.error('No currentAttemptId available for detailed results')
  }
}

const goToAssessments = async () => {
  // Auto-abandon if user hasn't answered any questions yet
  if (currentAttemptId.value && questionResults.value.length === 0) {
    try {
      console.log('Auto-abandoning empty attempt:', currentAttemptId.value)
      await abandonAttempt(currentAttemptId.value)
    } catch (error) {
      console.error('Error auto-abandoning attempt:', error)
    }
  }
  window.location.href = '/docs/assessments/'
}

// Pagination methods
const goToReviewPage = (page) => {
  reviewCurrentPage.value = page
}

const nextReviewPage = () => {
  if (reviewCurrentPage.value < totalReviewPages.value) {
    reviewCurrentPage.value++
  }
}

const prevReviewPage = () => {
  if (reviewCurrentPage.value > 1) {
    reviewCurrentPage.value--
  }
}

// Session Management Functions
const checkForIncompleteAssessment = async () => {
  if (!user.value || !currentAssessment.value) return false
  
  try {
    // Check for in-progress attempt for this assessment
    const { data: incompleteAttempts, error } = await supabase
      .from('user_assessment_attempts')
      .select('*, user_question_responses(*)')
      .eq('user_id', user.value.id)
      .eq('assessment_id', currentAssessment.value.id)
      .eq('status', 'in_progress')
      .order('started_at', { ascending: false })
      .limit(1)
    
    if (error) {
      console.error('Error checking incomplete assessments:', error)
      return false
    }
    
    if (incompleteAttempts && incompleteAttempts.length > 0) {
      const attempt = incompleteAttempts[0]
      resumeData.value = {
        attemptId: attempt.id,
        completedQuestions: attempt.user_question_responses?.length || 0,
        startedAt: attempt.started_at,
        totalQuestions: attempt.total_questions
      }
      return true
    }
    
    return false
  } catch (error) {
    console.error('Error checking incomplete assessments:', error)
    return false
  }
}

const resumeAssessment = async () => {
  try {
    // This function is now only called when action=continue
    
    // Get the most recent incomplete attempt
    const { data: incompleteAttempts, error: fetchError } = await supabase
      .from('user_assessment_attempts')
      .select('*, user_question_responses(*)')
      .eq('user_id', user.value.id)
      .eq('assessment_id', currentAssessment.value.id)
      .eq('status', 'in_progress')
      .order('started_at', { ascending: false })
      .limit(1)
    
    if (fetchError) throw fetchError
    
    if (!incompleteAttempts || incompleteAttempts.length === 0) {
      // No incomplete assessment found, start fresh
      console.log('No incomplete assessment found, starting fresh...')
      await startAssessment()
      return
    }
    
    const attempt = incompleteAttempts[0]
    currentAttemptId.value = attempt.id
    assessmentStartTime.value = new Date(attempt.started_at).getTime()
    
    // Reconstruct questionResults from saved responses
    questionResults.value = attempt.user_question_responses.map((response, index) => ({
      questionIndex: index,
      selectedAnswer: response.selected_answer,
      correct: response.is_correct,
      timestamp: Date.now()
    }))
    
    // Use the stored current_question_index for precise navigation
    currentQuestionIndex.value = attempt.current_question_index !== null 
      ? attempt.current_question_index - 1  // Convert from 1-based to 0-based
      : attempt.user_question_responses.length
      
    console.log(`Resuming at question ${currentQuestionIndex.value + 1}`)
    
    // Start the assessment UI at the correct question
    started.value = true
    selectedAnswer.value = null
    completedScore.value = 0 // Reset completed score for resumed assessment
    
    // Start auto-save and idle monitoring
    startAutoSave()
    startIdleMonitoring()
    
    console.log('Assessment resumed successfully')
  } catch (error) {
    console.error('Error resuming assessment:', error)
    // If resume fails, start fresh
    await startAssessment()
  }
}


const markAttemptAbandoned = async (attemptId) => {
  try {
    await supabase
      .from('user_assessment_attempts')
      .update({ status: 'abandoned' })
      .eq('id', attemptId)
  } catch (error) {
    console.error('Error marking attempt as abandoned:', error)
  }
}

const saveSessionState = () => {
  const sessionKey = `assessment_${currentAssessment.value?.id}_${user.value?.id}`
  const sessionData = {
    attemptId: currentAttemptId.value,
    questionIndex: currentQuestionIndex.value,
    selectedAnswer: selectedAnswer.value,
    startTime: assessmentStartTime.value,
    lastSaved: Date.now()
  }
  
  try {
    localStorage.setItem(sessionKey, JSON.stringify(sessionData))
  } catch (error) {
    console.error('Error saving session state:', error)
  }
}


const clearSessionData = () => {
  if (!currentAssessment.value || !user.value) return
  
  const sessionKey = `assessment_${currentAssessment.value.id}_${user.value.id}`
  try {
    localStorage.removeItem(sessionKey)
  } catch (error) {
    console.error('Error clearing session data:', error)
  }
  
  // Clear intervals
  if (autoSaveInterval.value) {
    clearInterval(autoSaveInterval.value)
    autoSaveInterval.value = null
  }
  if (idleTimer.value) {
    clearTimeout(idleTimer.value)
    idleTimer.value = null
  }
}

const startAutoSave = () => {
  // Auto-save every 30 seconds
  autoSaveInterval.value = setInterval(() => {
    saveSessionState()
  }, 30000)
}

const startIdleMonitoring = () => {
  const checkIdle = () => {
    const idleTime = Date.now() - lastActivity.value
    const idleLimit = 30 * 60 * 1000 // 30 minutes
    
    if (idleTime > idleLimit && started.value && !completed.value) {
      // Mark as abandoned and redirect
      if (currentAttemptId.value) {
        markAttemptAbandoned(currentAttemptId.value)
      }
      clearSessionData()
      // Show inactivity dialog instead of browser alert
      showInactivityDialog.value = true
    }
  }
  
  // Check every 5 minutes
  idleTimer.value = setInterval(checkIdle, 5 * 60 * 1000)
  
  // Track activity
  const updateActivity = () => {
    lastActivity.value = Date.now()
  }
  
  // Listen for user activity
  document.addEventListener('click', updateActivity)
  document.addEventListener('keypress', updateActivity)
  document.addEventListener('scroll', updateActivity)
}


const handleInactivityOk = () => {
  // Close the inactivity dialog and redirect to assessments
  showInactivityDialog.value = false
  window.location.href = '/docs/assessments/'
}

const exitAssessment = () => {
  // Show exit confirmation dialog instead of browser confirm
  showExitDialog.value = true
}

const confirmExit = async () => {
  // Auto-abandon if user hasn't answered any questions yet
  if (currentAttemptId.value && questionResults.value.length === 0) {
    try {
      console.log('Auto-abandoning empty attempt on exit:', currentAttemptId.value)
      await abandonAttempt(currentAttemptId.value)
    } catch (error) {
      console.error('Error auto-abandoning attempt on exit:', error)
    }
  } else {
    // User has answered questions - save current state for resumption
    saveSessionState()
  }
  
  // Clear timers but keep session data
  if (autoSaveInterval.value) {
    clearInterval(autoSaveInterval.value)
    autoSaveInterval.value = null
  }
  if (idleTimer.value) {
    clearTimeout(idleTimer.value) 
    idleTimer.value = null
  }
  
  // Close dialog and redirect to assessments page
  showExitDialog.value = false
  window.location.href = '/docs/assessments/'
}

const cancelExit = () => {
  // User cancelled exit - just close the dialog
  showExitDialog.value = false
}

// Load assessment from URL hash
onMounted(async () => {
  const hash = window.location.hash.substring(1)
  const urlParams = new URLSearchParams(window.location.search)
  const action = urlParams.get('action') // 'take', 'continue', 'retake'
  
  if (hash) {
    // Show loading modal
    loading.value = true
    
    try {
      // Load assessment data from database
      const assessment = await getAssessmentBySlug(hash)
      if (!assessment) {
        console.error('Assessment not found:', hash)
        return
      }
      
      currentAssessment.value = assessment
      
      // Load questions for this assessment
      const assessmentQuestions = await getAssessmentQuestions(assessment.id)
      questions.value = assessmentQuestions
      
      console.log('Loaded assessment:', assessment.title, 'with', assessmentQuestions.length, 'questions')
      console.log('Action parameter:', action)
      
      if (user.value && hasBetaAccess.value && !completed.value) {
        // Handle different actions based on URL parameter
        if (action === 'continue') {
          // User wants to continue - check for incomplete assessment
          const hasIncomplete = await checkForIncompleteAssessment()
          if (hasIncomplete) {
            // Auto-resume without showing dialog
            console.log('Auto-resuming assessment...')
            await resumeAssessment()
          } else {
            // No incomplete assessment found, start new one
            console.log('No incomplete assessment found, starting new one...')
            await startAssessment()
          }
        } else if (action === 'retake') {
          // User wants to retake - start fresh assessment immediately
          console.log('Starting retake assessment...')
          await startAssessment()
        } else if (action === 'take') {
          // User wants to take assessment - always start fresh with take action
          console.log('Starting new assessment with take action...')
          await startAssessment()
        } else {
          // No action parameter - start new assessment directly 
          console.log('No action parameter - starting new assessment')
          await startAssessment()
        }
      } else if (!user.value) {
        // User not authenticated - redirect to auth page
        console.log('User not authenticated - redirecting to auth page')
        window.location.href = '/docs/auth/'
        return
      } else if (user.value && !hasBetaAccess.value) {
        // User authenticated but no beta access - show beta message
        console.log('User authenticated but no beta access')
      } else if (completed.value) {
        // Assessment already completed
        console.log('Assessment already completed')
      }
      
    } catch (error) {
      console.error('Error loading assessment:', error)
    }
  } else {
    // No hash in URL - check if user needs to authenticate first
    if (!user.value) {
      console.log('No assessment selected and user not authenticated - redirecting to auth page')
      window.location.href = '/docs/auth/'
      return
    }
    // User authenticated but no assessment selected - redirect to assessments page
    console.log('No assessment hash in URL - redirecting to assessments page')
    window.location.href = '/docs/assessments/'
    return
  }
  
  // Assessment loading complete
  loading.value = false
  
  // Add beforeunload handler for auto-abandon on page close/navigation
  const handleBeforeUnload = async () => {
    if (currentAttemptId.value && questionResults.value.length === 0) {
      try {
        console.log('Auto-abandoning empty attempt on page unload:', currentAttemptId.value)
        // Use sendBeacon for reliable execution during page unload
        const abandonData = {
          action: 'abandon',
          attemptId: currentAttemptId.value
        }
        
        // Try to abandon the attempt quickly
        await abandonAttempt(currentAttemptId.value)
      } catch (error) {
        console.error('Error auto-abandoning attempt on unload:', error)
      }
    }
  }
  
  window.addEventListener('beforeunload', handleBeforeUnload)
  
  // Cleanup on component unmount
  onUnmounted(() => {
    window.removeEventListener('beforeunload', handleBeforeUnload)
  })
})
</script>

<style scoped>
.assessment-player {
  max-width: 1000px;
  margin: 0 auto;
  padding: 2rem;
}

.auth-required {
  text-align: center;
  padding: 4rem 2rem;
}

.auth-message {
  max-width: 600px;
  margin: 0 auto;
}

.auth-message h2 {
  color: var(--vp-c-text-1);
  margin-bottom: 1rem;
}

.auth-message p {
  color: var(--vp-c-text-2);
}

.auth-message a {
  color: var(--vp-c-brand-1);
  text-decoration: none;
  font-weight: 600;
}

/* Beta access styling */
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

/* Assessment Intro */
.assessment-intro {
  max-width: 800px;
  margin: 0 auto;
}

.assessment-header {
  display: flex;
  gap: 1.5rem;
  align-items: center;
  margin-bottom: 2rem;
  padding: 2rem;
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
}

.assessment-logo-container {
  width: 120px;
  height: 80px;
  background: white;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(0, 0, 0, 0.05);
  flex-shrink: 0;
}

.assessment-logo {
  width: 100%;
  height: 100%;
  object-fit: contain;
  border-radius: 12px;
}

.assessment-framework-badge {
  font-size: 1rem;
  font-weight: 600;
  width: 80px;
  height: 80px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--vp-c-brand-soft);
  border-radius: 16px;
  color: var(--vp-c-brand-1);
}

.assessment-info h1 {
  color: var(--vp-c-text-1);
  margin: 0 0 1rem 0;
  font-size: 2rem;
  font-weight: 700;
}

.assessment-info p {
  color: var(--vp-c-text-2);
  margin: 0;
  font-size: 1rem;
}

.assessment-meta {
  display: flex;
  justify-content: space-between;
  align-items: stretch;
  margin: 0 auto 2rem auto;
  padding: 1.5rem;
  background: var(--vp-c-bg-alt);
  border-radius: 8px;
  max-width: 600px;
  width: 100%;
}

.meta-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 0.25rem;
  flex: 1;
  min-width: 0;
}

.meta-label {
  font-size: 0.8rem;
  color: var(--vp-c-text-3);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  min-height: 1.2em;
  display: flex;
  align-items: center;
  justify-content: center;
}

.meta-value {
  font-weight: 600;
  color: var(--vp-c-text-1);
  display: flex;
  align-items: center;
  justify-content: center;
}

.difficulty-badge {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 600;
}

.difficulty-badge.beginner {
  background: #dcfce7;
  color: #166534;
}

.difficulty-badge.intermediate {
  background: #fef3c7;
  color: #92400e;
}

.difficulty-badge.advanced {
  background: #fee2e2;
  color: #991b1b;
}

/* Dark mode difficulty badges */
.dark .difficulty-badge.beginner {
  background: rgba(34, 197, 94, 0.2);
  color: #4ade80;
}

.dark .difficulty-badge.intermediate {
  background: rgba(245, 158, 11, 0.2);
  color: #fbbf24;
}

.dark .difficulty-badge.advanced {
  background: rgba(239, 68, 68, 0.2);
  color: #f87171;
}

.competencies-section {
  margin-bottom: 2rem;
}

.competencies-section h3 {
  color: var(--vp-c-text-1);
  margin-bottom: 1rem;
  font-size: 1.2rem;
  font-weight: 600;
}

.competencies-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 0.75rem;
}

.competency-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem;
  background: var(--vp-c-brand-soft);
  border-radius: 8px;
  color: var(--vp-c-text-1);
  font-weight: 500;
  font-size: 0.9rem;
}

.competency-icon {
  color: var(--vp-c-brand-1);
  font-weight: 600;
  flex-shrink: 0;
}

.instructions {
  margin-bottom: 2rem;
  padding: 1rem;
  background: var(--vp-c-bg-alt);
  border: 1px solid var(--vp-c-divider-light);
  border-radius: 6px;
}

.instructions-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.instructions-icon {
  font-size: 0.9rem;
}

.instructions-title {
  color: var(--vp-c-text-1);
  font-size: 1rem;
  font-weight: 600;
}

.instructions-content {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.instructions-content span {
  color: var(--vp-c-text-2);
  font-size: 0.8rem;
  line-height: 1.3;
}

.start-section {
  text-align: center;
}

.start-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

/* Exit/Inactivity Dialog Overlay */
.resume-dialog-overlay, .loading-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
}

.resume-dialog, .loading-modal {
  background: var(--vp-c-bg);
  border-radius: 16px;
  padding: 2rem;
  max-width: 500px;
  width: 90%;
  border: 1px solid var(--vp-c-divider);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
}

.loading-modal {
  max-width: 300px;
  text-align: center;
  padding: 1.5rem;
}

.loading-spinner {
  margin-bottom: 1rem;
  animation: spin 2s linear infinite;
}

.spinner-icon {
  width: 2.5rem;
  height: 2.5rem;
  color: var(--color-brand-primary, #3b82f6);
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.loading-modal h3 {
  color: var(--vp-c-text-1);
  margin: 0 0 0.5rem 0;
  font-size: 1.1rem;
}

.loading-modal p {
  color: var(--vp-c-text-2);
  margin: 0;
  font-size: 0.9rem;
}

.resume-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1.5rem;
}

.resume-header h3 {
  color: var(--vp-c-text-1);
  margin: 0;
  font-size: 1.3rem;
}

.resume-icon {
  opacity: 0.8;
}

.pause-icon {
  width: 2rem;
  height: 2rem;
  color: var(--color-warning, #f59e0b);
}

.heading-icon {
  width: 1.5rem;
  height: 1.5rem;
  display: inline-block;
  vertical-align: middle;
  margin-right: 0.5rem;
  color: var(--vp-c-brand-1);
}

.exit-dialog-icon {
  width: 2rem;
  height: 2rem;
  color: var(--color-warning, #f59e0b);
}

.exit-icon {
  width: 1rem;
  height: 1rem;
}

/* Dark mode icon styles */
.dark .heading-icon {
  color: #818cf8;
}

.dark .spinner-icon {
  color: #818cf8;
}

.dark .pause-icon {
  color: #fbbf24;
}

.dark .exit-dialog-icon {
  color: #fbbf24;
}

.resume-content p {
  color: var(--vp-c-text-2);
  margin: 0 0 1.5rem 0;
  line-height: 1.5;
}

.resume-actions {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}


/* Assessment Active */
.assessment-progress {
  margin-bottom: 2rem;
  padding: 1rem;
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
}

.progress-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
}

.progress-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  flex: 1;
}

/* Exit button now uses ActionButton component */

.question-number {
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.progress-bar {
  flex: 1;
  height: 8px;
  background: var(--vp-c-bg-alt);
  border-radius: 4px;
  margin-left: 2rem;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: var(--vp-c-brand-1);
  border-radius: 4px;
  transition: width 0.3s ease;
}

.question-container {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  padding: 2rem;
}

.scenario-box {
  background: var(--vp-c-bg-soft);
  padding: 1.5rem;
  border-radius: 8px;
  margin-bottom: 1.5rem;
  border-left: 4px solid var(--vp-c-brand-1);
}

.scenario-box h4 {
  color: var(--vp-c-text-1);
  margin: 0 0 1rem 0;
  font-size: 1rem;
}

.scenario-box p {
  color: var(--vp-c-text-2);
  margin: 0;
  line-height: 1.6;
}

.question-text h3 {
  color: var(--vp-c-text-1);
  margin: 0 0 2rem 0;
  font-size: 1.3rem;
  line-height: 1.4;
}

.answer-options {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-bottom: 2rem;
}

.answer-option {
  display: flex;
  gap: 1rem;
  padding: 1rem;
  border: 2px solid var(--vp-c-divider);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
}

.answer-option:hover {
  border-color: var(--vp-c-brand-light);
  background: var(--vp-c-bg-soft);
}

.answer-option.selected {
  border-color: var(--vp-c-brand-1);
  background: var(--vp-c-brand-soft);
}

.option-marker {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: var(--vp-c-bg-alt);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  color: var(--vp-c-text-1);
  flex-shrink: 0;
}

.answer-option.selected .option-marker {
  background: var(--vp-c-brand-1);
  color: white;
}

.option-text {
  color: var(--vp-c-text-1);
  line-height: 1.5;
  flex: 1;
}

.question-actions {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  width: 100%;
}

/* Submit button now uses ActionButton component */

/* Assessment Completed - Desktop */
.results-content {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}

.results-header {
  text-align: center;
  margin-bottom: 4rem;
  background: var(--vp-c-bg-soft);
  padding: 3rem 2rem;
  border-radius: 16px;
  border: 1px solid var(--vp-c-divider-light);
}

.score-circle {
  width: 150px;
  height: 150px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--vp-c-brand-1), var(--vp-c-brand-2));
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 2rem;
  box-shadow: 0 8px 32px rgba(102, 126, 234, 0.3);
  border: 4px solid white;
}

.score-number {
  color: white;
  font-size: 2.5rem;
  font-weight: 800;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.results-header h2 {
  color: var(--vp-c-text-1);
  margin: 0 0 1.5rem 0;
  font-size: 2.2rem;
  font-weight: 700;
}

.score-description {
  color: var(--vp-c-text-2);
  font-size: 1.3rem;
  line-height: 1.6;
  max-width: 600px;
  margin: 0 auto;
}

.results-breakdown {
  background: var(--vp-c-bg);
  border-radius: 12px;
  padding: 2rem;
  margin-bottom: 3rem;
  border: 1px solid var(--vp-c-divider-light);
}

.results-breakdown h3 {
  color: var(--vp-c-text-1);
  margin-bottom: 2rem;
  font-size: 1.8rem;
  font-weight: 600;
  text-align: center;
}

.question-reviews {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.question-review {
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  padding: 2rem;
  background: var(--vp-c-bg-soft);
  transition: all 0.2s ease;
}

.question-review:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transform: translateY(-1px);
}

.question-review.correct {
  border-left: 5px solid #10b981;
  background: linear-gradient(to right, rgba(16, 185, 129, 0.02), var(--vp-c-bg-soft));
}

.question-review.incorrect {
  border-left: 5px solid #ef4444;
  background: linear-gradient(to right, rgba(239, 68, 68, 0.02), var(--vp-c-bg-soft));
}

.review-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--vp-c-divider-light);
}

.question-num {
  font-weight: 700;
  color: var(--vp-c-text-1);
  font-size: 1.1rem;
}

.result-icon {
  display: flex;
  align-items: center;
}

.result-icon svg {
  width: 1.5rem;
  height: 1.5rem;
}

.icon-correct {
  color: var(--color-success, #10b981);
}

.icon-incorrect {
  color: var(--color-error, #ef4444);
}

.icon-pending {
  color: var(--color-warning, #f59e0b);
}

.review-question {
  color: var(--vp-c-text-1);
  font-weight: 600;
  margin-bottom: 1.5rem;
  font-size: 1.1rem;
  line-height: 1.5;
}

.review-answers {
  margin-bottom: 1.5rem;
  background: var(--vp-c-bg-alt);
  padding: 1.5rem;
  border-radius: 8px;
}

.review-answers p {
  color: var(--vp-c-text-2);
  margin: 0.75rem 0;
  line-height: 1.5;
}

.review-answers strong {
  color: var(--vp-c-text-1);
  font-weight: 600;
}

.explanation {
  background: var(--vp-c-brand-softer);
  padding: 1.5rem;
  border-radius: 8px;
  border-left: 4px solid var(--vp-c-brand-1);
}

.explanation strong {
  color: var(--vp-c-text-1);
  font-weight: 600;
  font-size: 1.05rem;
}

.explanation p {
  color: var(--vp-c-text-2);
  line-height: 1.6;
  margin: 0.75rem 0 0 0;
  font-size: 1rem;
}

.breakdown-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.review-summary {
  display: flex;
  gap: 1rem;
  font-size: 0.9rem;
}

.total-questions {
  color: var(--vp-c-text-2);
}

.correct-count {
  color: var(--vp-c-green-1);
  font-weight: 600;
}

.incorrect-count {
  color: var(--vp-c-red-1);
  font-weight: 600;
}

.review-note {
  margin: 0.5rem 0 0 0;
  color: var(--vp-c-text-2);
  font-size: 0.85rem;
  font-style: italic;
}

.pagination-controls {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  align-items: center;
  margin-top: 2rem;
  padding: 1.5rem;
  background: var(--vp-c-bg-alt);
  border-radius: 8px;
}

.pagination-left {
  display: flex;
  justify-content: flex-start;
  align-items: center;
}

.pagination-center {
  display: flex;
  justify-content: center;
  align-items: center;
}

.pagination-right {
  display: flex;
  justify-content: flex-end;
  align-items: center;
}

.pagination-info {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
}

.page-numbers {
  display: flex;
  gap: 0.5rem;
}

.page-btn {
  width: 36px;
  height: 36px;
  border: 1px solid var(--vp-c-divider);
  background: var(--vp-c-bg);
  color: var(--vp-c-text-2);
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s ease;
  font-weight: 500;
}

.page-btn:hover {
  border-color: var(--vp-c-brand-1);
  color: var(--vp-c-brand-1);
}

.page-btn.active {
  background: var(--vp-c-brand-1);
  color: white;
  border-color: var(--vp-c-brand-1);
}

.page-info {
  font-size: 0.85rem;
  color: var(--vp-c-text-3);
}

.results-actions {
  display: flex;
  gap: 1.5rem;
  justify-content: center;
  margin-top: 4rem;
  padding: 2rem;
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
}

.results-btn, .retake-btn, .back-btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.results-btn {
  background: var(--vp-c-green-1);
  color: white;
}

.retake-btn {
  background: var(--vp-c-brand-1);
  color: white;
}

.back-btn {
  background: var(--vp-c-bg-alt);
  color: var(--vp-c-text-1);
  border: 1px solid var(--vp-c-divider);
}

.results-btn:hover, .retake-btn:hover, .back-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

@media (max-width: 768px) {
  /* Container improvements */
  .assessment-player {
    padding: 0.5rem;
  }

  /* Auth required state */
  .auth-required {
    padding: 2rem 1rem;
  }

  /* Assessment intro page mobile improvements */
  .assessment-intro {
    max-width: none;
  }

  .intro-content {
    padding: 0;
  }

  .assessment-header {
    flex-direction: column;
    text-align: center;
    padding: 1.5rem;
    gap: 1rem;
  }

  .assessment-logo-container {
    width: 100px;
    height: 60px;
    margin: 0 auto;
    padding: 8px;
  }

  .assessment-info h1 {
    font-size: 1.5rem;
    margin-bottom: 0.75rem;
  }

  .assessment-info p {
    font-size: 0.9rem;
    line-height: 1.4;
  }

  .assessment-meta {
    flex-direction: row;
    padding: 0.75rem;
    margin: 0 auto 1rem auto;
    justify-content: space-around;
    max-width: 100%;
    width: 100%;
    background: var(--vp-c-bg-soft);
    border-radius: 8px;
  }

  .meta-item {
    align-items: center;
    gap: 0.2rem;
    flex: 1;
    min-width: 0;
    padding: 0 0.25rem;
  }

  .meta-label {
    font-size: 0.65rem;
    letter-spacing: 0.3px;
  }

  .meta-value {
    font-size: 0.85rem;
    font-weight: 600;
  }

  .difficulty-badge {
    font-size: 0.7rem;
    padding: 0.2rem 0.4rem;
  }

  /* Competencies section mobile */
  .competencies-section {
    margin-bottom: 1.5rem;
  }

  .competencies-section h3 {
    font-size: 1.1rem;
    text-align: center;
  }

  .competencies-grid {
    grid-template-columns: 1fr;
    gap: 0.5rem;
  }

  .competency-item {
    padding: 0.5rem 0.75rem;
    font-size: 0.8rem;
  }

  /* Instructions mobile */
  .instructions {
    padding: 0.75rem;
    margin-bottom: 1.5rem;
  }

  .instructions-content span {
    font-size: 0.75rem;
  }

  /* Start actions mobile */
  .start-actions {
    flex-direction: column;
    gap: 0.75rem;
    max-width: 280px;
    margin: 0 auto;
  }

  /* Resume dialog mobile */
  .resume-dialog {
    width: 95%;
    padding: 1.5rem;
    margin: 1rem;
  }

  .resume-header h3 {
    font-size: 1.1rem;
  }

  .resume-details {
    padding: 1rem;
  }

  .resume-assessment {
    font-size: 1rem;
  }

  /* Assessment active state mobile */
  .assessment-progress {
    padding: 1rem;
    margin-bottom: 1rem;
  }

  .progress-header {
    flex-direction: column;
    gap: 1rem;
  }

  .progress-info {
    flex-direction: column;
    gap: 1rem;
    margin-bottom: 0;
    width: 100%;
  }

  .assessment-active .progress-bar {
    margin-left: 0 !important;
    height: 10px !important;
    width: 100% !important;
    background: #f3f4f6 !important;
    border-radius: 5px !important;
    overflow: hidden !important;
    border: 2px solid #d1d5db !important;
    display: block !important;
  }

  .assessment-active .progress-fill {
    height: 100% !important;
    background: #3b82f6 !important;
    border-radius: 3px !important;
    transition: width 0.3s ease !important;
    min-width: 2px !important;
    display: block !important;
  }

  /* Dark mode progress colors with higher specificity */
  .dark .assessment-active .progress-bar {
    background: #374151 !important;
    border-color: #6b7280 !important;
  }

  .dark .assessment-active .progress-fill {
    background: #60a5fa !important;
  }

  /* Ultra-specific mobile progress fill */
  .mobile-progress-fill {
    background-color: #3b82f6 !important;
    height: 100% !important;
    display: block !important;
    min-height: 10px !important;
  }

  .dark .mobile-progress-fill {
    background-color: #60a5fa !important;
  }

  .question-number {
    font-size: 1.1rem;
    text-align: center;
    font-weight: 600;
    color: var(--vp-c-text-1);
  }

  /* Exit button mobile styles handled by ActionButton component */

  /* Question container mobile */
  .question-container {
    padding: 1rem;
    margin: 0;
  }

  .scenario-box {
    padding: 1rem;
    margin-bottom: 1rem;
  }

  .scenario-box h4 {
    font-size: 0.9rem;
    margin-bottom: 0.75rem;
  }

  .scenario-box p {
    font-size: 0.85rem;
    line-height: 1.5;
  }

  .question-text h3 {
    font-size: 1.1rem;
    margin-bottom: 1.5rem;
    line-height: 1.3;
  }

  /* Answer options mobile */
  .answer-options {
    gap: 0.75rem;
    margin-bottom: 1.5rem;
  }

  .answer-option {
    padding: 0.75rem;
    gap: 0.75rem;
  }

  .option-marker {
    width: 28px;
    height: 28px;
    font-size: 0.9rem;
  }

  .option-text {
    font-size: 0.85rem;
    line-height: 1.4;
  }

  /* Question actions mobile */
  .question-actions {
    flex-direction: column-reverse;
    gap: 0.75rem;
    align-items: stretch;
    max-width: none;
    margin: 0;
  }
  
  .question-actions .action-button {
    width: 100% !important;
  }

  /* Results completion mobile */
  .results-content {
    max-width: none;
    padding: 0.75rem;
  }

  .results-header {
    margin-bottom: 2.5rem;
    text-align: center;
    padding: 2rem 1rem;
  }

  .score-circle {
    width: 120px;
    height: 120px;
    margin: 0 auto 1.5rem auto;
  }

  .score-number {
    font-size: 1.8rem;
    font-weight: 700;
  }

  .results-header h2 {
    font-size: 1.5rem;
    margin-bottom: 1rem;
  }

  .score-description {
    font-size: 1.1rem;
    line-height: 1.4;
    padding: 0 1rem;
  }

  .results-breakdown {
    margin-bottom: 2.5rem;
    padding: 0.75rem;
  }

  .results-breakdown h3 {
    font-size: 1.3rem;
    text-align: center;
    margin-bottom: 2rem;
  }

  .question-reviews {
    gap: 1.5rem;
  }

  .question-review {
    padding: 1rem;
    border-radius: 8px;
    margin-bottom: 1.25rem;
  }

  .review-header {
    margin-bottom: 1.25rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-bottom: 0.75rem;
    border-bottom: 1px solid var(--vp-c-divider-light);
  }

  .question-num {
    font-size: 1rem;
    font-weight: 700;
  }

  .result-icon {
    font-size: 1.4rem;
  }

  .review-question {
    font-size: 1.05rem;
    font-weight: 600;
    margin-bottom: 1.25rem;
    line-height: 1.5;
  }

  .review-answers {
    margin-bottom: 1rem;
    padding: 0.75rem;
    border-radius: 6px;
  }

  .review-answers p {
    font-size: 0.95rem;
    margin: 0.75rem 0;
    line-height: 1.5;
  }

  .explanation {
    font-size: 0.95rem;
    line-height: 1.6;
    padding: 0.75rem;
  }

  .explanation strong {
    font-size: 1rem;
    margin-bottom: 0.5rem;
    display: block;
  }

  .explanation p {
    margin-top: 0.75rem;
    line-height: 1.6;
  }

  .results-actions {
    flex-direction: column;
    gap: 1rem;
    margin-top: 2rem;
    align-items: stretch;
  }

  .results-actions .action-button {
    width: 100% !important;
    justify-content: center;
  }

  /* Pagination mobile styles */
  .breakdown-header {
    flex-direction: column;
    gap: 1rem;
    align-items: center;
  }

  .review-summary {
    justify-content: center;
  }

  .pagination-controls {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    padding: 1rem;
  }

  .pagination-left,
  .pagination-center,
  .pagination-right {
    justify-content: center;
  }

  .pagination-right {
    order: 1;
  }

  .pagination-left {
    order: 2;
  }

  .pagination-center {
    order: 3;
  }

  .pagination-info {
    align-items: center;
  }

  .pagination-controls .action-button {
    width: auto !important;
    min-width: 100px;
  }

  .page-numbers {
    flex-wrap: wrap;
    justify-content: center;
  }

  .page-btn {
    width: 32px;
    height: 32px;
    font-size: 0.8rem;
  }
}

/* Review controls styles */
.review-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  margin-bottom: 1.5rem;
}

.review-controls-summary {
  display: flex;
  align-items: center;
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

.items-per-page label {
  font-weight: 500;
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

.items-select:focus {
  outline: none;
  border-color: var(--vp-c-brand-1);
  box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.15);
}

@media (max-width: 768px) {
  .review-controls {
    flex-direction: column;
    gap: 1rem;
    text-align: center;
  }
}
</style>