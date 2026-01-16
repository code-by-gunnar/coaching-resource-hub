<template>
  <div class="assessments-container">
    <div v-if="!user" class="auth-required">
      <div class="auth-hero">
        <div class="auth-hero-content">
          <div class="auth-icon">
            <ClipboardDocumentCheckIcon class="auth-icon-svg" aria-hidden="true" />
          </div>
          <h1>Professional Coaching Assessments</h1>
          <p class="auth-subtitle">Comprehensive Prometric-style coaching competency assessments</p>
          
          <div class="auth-features-grid">
            <div class="auth-feature">
              <div class="auth-feature-icon">
                <PuzzlePieceIcon class="feature-icon-svg" aria-hidden="true" />
              </div>
              <h3>Prometric-Style Questions</h3>
              <p>Complex scenarios where one answer is "more correct" - just like professional certification exams</p>
            </div>
            <div class="auth-feature">
              <div class="auth-feature-icon">
                <ChartBarSquareIcon class="feature-icon-svg" aria-hidden="true" />
              </div>
              <h3>Detailed Analytics</h3>
              <p>Track your progress across competencies with comprehensive performance insights</p>
            </div>
            <div class="auth-feature">
              <div class="auth-feature-icon">
                <TrophyIcon class="feature-icon-svg" aria-hidden="true" />
              </div>
              <h3>Industry Frameworks</h3>
              <p>ICF, AC, and Core coaching competencies all in one comprehensive platform</p>
            </div>
            <div class="auth-feature">
              <div class="auth-feature-icon">
                <RocketLaunchIcon class="feature-icon-svg" aria-hidden="true" />
              </div>
              <h3>Skill Development</h3>
              <p>Real-world coaching scenarios designed to elevate your professional practice</p>
            </div>
          </div>
          
          <div class="auth-cta-section">
            <a href="/docs/auth/?redirect=/docs/assessments/" class="auth-cta-btn">
              <span>Get Started Now</span>
              <span class="auth-cta-arrow">→</span>
            </a>
            <p class="auth-cta-note">Start your coaching development journey</p>
          </div>
        </div>
        
        <div class="auth-preview">
          <div class="preview-card">
            <div class="preview-header">
              <div class="preview-icon">
                <AssessmentBadge framework="core" difficulty="Beginner" size="medium" />
              </div>
              <div class="preview-info">
                <h4>CORE I - Fundamentals</h4>
                <span>3 questions • 20 min • Beginner</span>
              </div>
            </div>
            <div class="preview-progress">
              <div class="progress-bar">
                <div class="progress-fill" style="width: 0%"></div>
              </div>
              <span>Ready to start</span>
            </div>
          </div>
          
          <div class="preview-card">
            <div class="preview-header">
              <div class="preview-icon">
                <AssessmentBadge framework="core" difficulty="Intermediate" size="medium" />
              </div>
              <div class="preview-info">
                <h4>CORE II - Intermediate Skills</h4>
                <span>Not Available • 30 min • Intermediate</span>
              </div>
            </div>
            <div class="preview-progress">
              <div class="progress-bar">
                <div class="progress-fill" style="width: 0%"></div>
              </div>
              <span>Not Available</span>
            </div>
          </div>
          
          <div class="preview-stats">
            <div class="stat">
              <span class="stat-number">9</span>
              <span class="stat-label">Assessments</span>
            </div>
            <div class="stat">
              <span class="stat-number">3</span>
              <span class="stat-label">Frameworks</span>
            </div>
            <div class="stat">
              <span class="stat-number">100+</span>
              <span class="stat-label">Questions</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-else class="assessments-content">
      <div class="assessments-header">
        <div class="hero-content">
          <h1><ClipboardDocumentCheckIcon class="heading-icon" aria-hidden="true" /> Coaching Assessments</h1>
          <p class="header-description">
            Professional-grade assessments designed to test real-world coaching competencies
          </p>
          <div class="hero-features">
            <div class="feature-item">
              <PuzzlePieceIcon class="feature-icon-svg" aria-hidden="true" />
              <span>Prometric-Style Questions</span>
            </div>
            <div class="feature-item">
              <ChartBarSquareIcon class="feature-icon-svg" aria-hidden="true" />
              <span>Detailed Progress Tracking</span>
            </div>
            <div class="feature-item">
              <TrophyIcon class="feature-icon-svg" aria-hidden="true" />
              <span>Industry-Standard Frameworks</span>
            </div>
          </div>
        </div>
      </div>

      <div class="framework-selector">
        <h3>Choose Your Framework</h3>
        <p class="framework-description">Select a coaching framework to begin your assessment journey. Each framework offers 3 progressive levels: Foundation, Intermediate, and Advanced.</p>
        <div class="framework-options">
          <button 
            @click="selectedFramework = 'core'" 
            :class="{ active: selectedFramework === 'core' }"
            class="framework-btn"
          >
            <div class="framework-card">
              <div class="framework-logo-container">
                <img src="/img/core-logo.png" alt="Core Fundamentals Logo" class="framework-logo" />
              </div>
              <div class="framework-content">
                <h4>Core Fundamentals</h4>
                <p class="framework-subtitle">Essential coaching competencies across all frameworks</p>
                <div class="framework-stats">
                  <span class="stat-item">✓ 3 Progressive Levels</span>
                  <span class="stat-item">✓ Foundation to Advanced</span>
                </div>
              </div>
            </div>
          </button>
          
          <button 
            @click="selectedFramework = 'icf'" 
            :class="{ active: selectedFramework === 'icf' }"
            class="framework-btn"
          >
            <div class="framework-card">
              <div class="framework-logo-container">
                <img src="/img/icf-logo.png" alt="ICF Logo" class="framework-logo" />
              </div>
              <div class="framework-content">
                <h4>International Coaching Federation</h4>
                <p class="framework-subtitle">Global coaching standard with professional credentials</p>
                <div class="framework-stats">
                  <span class="stat-item">✓ 11 Core Competencies</span>
                  <span class="stat-item">✓ 3 Progressive Levels</span>
                </div>
              </div>
            </div>
          </button>
          
          <button 
            @click="selectedFramework = 'ac'" 
            :class="{ active: selectedFramework === 'ac' }"
            class="framework-btn"
          >
            <div class="framework-card">
              <div class="framework-logo-container">
                <img src="/img/ac-logo.png" alt="AC Logo" class="framework-logo" />
              </div>
              <div class="framework-content">
                <h4>Association for Coaching</h4>
                <p class="framework-subtitle">Leading UK coaching body with European focus</p>
                <div class="framework-stats">
                  <span class="stat-item">✓ 8 Competency Areas</span>
                  <span class="stat-item">✓ 3 Progressive Levels</span>
                </div>
              </div>
            </div>
          </button>
        </div>
      </div>

      <div class="assessments-grid">
        <div 
          v-for="assessment in getAssessmentsByFramework()" 
          :key="assessment.id"
          class="assessment-card"
          :class="{ 'coming-soon': !assessment.is_active }"
        >
          <div class="assessment-header">
            <AssessmentBadge 
              :framework="assessment.framework" 
              :difficulty="assessment.difficulty"
              size="medium"
            />
            <div class="assessment-info">
              <h3>{{ assessment.title }}</h3>
              <p>{{ assessment.description }}</p>
            </div>
          </div>
          
          <div class="assessment-bottom">
            <div class="assessment-meta">
              <div class="meta-item">
                <span class="meta-label">Questions</span>
                <span class="meta-value">{{ assessment.questionCount }}</span>
              </div>
              <div class="meta-item">
                <span class="meta-label">Duration</span>
                <span class="meta-value">{{ assessment.duration }}</span>
              </div>
              <div class="meta-item">
                <span class="meta-label">Difficulty</span>
                <span class="difficulty-badge" :class="assessment.difficulty.toLowerCase()">
                  {{ assessment.difficulty }}
                </span>
              </div>
            </div>

            <div v-if="assessment.lastScore" class="last-score">
              <span class="score-label">Last Score:</span>
              <span class="score-value">{{ assessment.lastScore }}%</span>
            </div>

            <div class="assessment-actions">
              <ActionButton
                v-if="assessment.is_active"
                @click="startAssessment(assessment)"
                :variant="assessment.hasIncompleteAttempt ? 'primary' : (assessment.lastScore ? 'secondary' : 'primary')"
                :disabled="!hasBetaAccess"
                full-width
              >
                {{ getButtonText(assessment) }}
              </ActionButton>
              <ActionButton
                v-else
                :disabled="true"
                variant="gray"
                full-width
              >
                Not Available
              </ActionButton>
            </div>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuth } from '../composables/useAuth.js'
import { useSupabase } from '../composables/useSupabase.js'
import { useAssessments, useAssessmentAttempts } from '../composables/useAssessments.js'
import { useBetaAccess } from '../composables/useBetaAccess.js'
import AssessmentBadge from './shared/AssessmentBadge.vue'
import ActionButton from './shared/ActionButton.vue'
import {
  ClipboardDocumentCheckIcon,
  PuzzlePieceIcon,
  ChartBarSquareIcon,
  TrophyIcon,
  RocketLaunchIcon
} from '@heroicons/vue/24/outline'

// Composables
const { user } = useAuth()
const { supabase } = useSupabase()
const { assessments, loading, error, loadAssessments, getAssessmentsByFramework: getByFramework } = useAssessments()
const { getUserBestScore } = useAssessmentAttempts()
const { hasBetaAccess } = useBetaAccess(user)

// Reactive state
const selectedFramework = ref('core')
const userScores = ref({})
const incompleteAttempts = ref({})

// Load user's best scores for each assessment
const loadUserScores = async () => {
  if (!user.value) return
  
  const scores = {}
  for (const assessment of assessments.value) {
    try {
      const bestScore = await getUserBestScore(user.value.id, assessment.id)
      scores[assessment.id] = bestScore > 0 ? bestScore : null
    } catch (err) {
      console.error('Error loading score for assessment:', assessment.id, err)
    }
  }
  userScores.value = scores
}

// Load incomplete attempts for each assessment
const loadIncompleteAttempts = async () => {
  if (!user.value) return
  
  try {
    
    const { data: attempts, error } = await supabase
      .from('user_assessment_attempts')
      .select('assessment_id, status, started_at')
      .eq('user_id', user.value.id)
      .in('status', ['started', 'in_progress'])
      .order('started_at', { ascending: false })
    
    if (error) throw error
    
    // Create map of assessment_id -> incomplete attempt
    const attemptsMap = {}
    attempts?.forEach(attempt => {
      if (!attemptsMap[attempt.assessment_id]) {
        attemptsMap[attempt.assessment_id] = attempt
      }
    })
    
    incompleteAttempts.value = attemptsMap
    console.log('Incomplete attempts loaded:', incompleteAttempts.value)
  } catch (error) {
    console.error('Error loading incomplete attempts:', error)
  }
}

// Computed properties
const getAssessmentsByFramework = () => {
  return getByFramework(selectedFramework.value).map(assessment => ({
    ...assessment,
    lastScore: userScores.value[assessment.id] || null,
    hasIncompleteAttempt: !!incompleteAttempts.value[assessment.id],
    incompleteStatus: incompleteAttempts.value[assessment.id]?.status,
    questionCount: assessment.question_count || 'TBD',
    duration: `${assessment.estimated_duration} min`,
    // Use database is_active field to determine availability
    comingSoon: !assessment.is_active
  })).sort((a, b) => {
    // Sort by difficulty level (I, II, III progression)
    const difficultyOrder = { 'Beginner': 1, 'Intermediate': 2, 'Advanced': 3 }
    return difficultyOrder[a.difficulty] - difficultyOrder[b.difficulty]
  })
}

// Updated for 3-tier system: strength (70-100%), developing (50-69%), weakness (0-49%)
const getScoreClass = (score) => {
  if (score >= 80) return 'excellent'
  if (score >= 70) return 'good' // Strength tier
  if (score >= 50) return 'developing' // Developing tier
  return 'needs-improvement' // Weakness tier
}

// Updated for 3-tier system: strength (70-100%), developing (50-69%), weakness (0-49%)
const getScoreGrade = (score) => {
  if (score >= 90) return 'Excellent'
  if (score >= 80) return 'Very Good'
  if (score >= 70) return 'Good' // Strength tier
  if (score >= 50) return 'Developing' // Developing tier
  return 'Needs Improvement' // Weakness tier
}

const getProgressText = (assessment) => {
  // TODO: Get actual progress from database
  return '2 of 3 questions'
}

const getProgressPercentage = (assessment) => {
  // TODO: Calculate actual progress percentage
  return '66%'
}

const formatLastActivity = (assessment) => {
  // TODO: Format actual last activity date
  return '2 hours ago'
}

const formatScoreDate = (assessment) => {
  // TODO: Format actual completion date
  return '3 days ago'
}

const getButtonText = (assessment) => {
  // Check beta access first
  if (!hasBetaAccess.value) {
    return 'Beta Access Required'
  }
  
  if (assessment.hasIncompleteAttempt) {
    return 'Continue Assessment'
  }
  if (assessment.lastScore) {
    return 'Retake Assessment'
  }
  return 'Take Assessment'
}


// Methods
const startAssessment = (assessment) => {
  // Safety check: prevent navigation for non-beta users
  if (!hasBetaAccess.value) {
    console.log('Beta access required - navigation blocked')
    return
  }
  
  let action = 'take'
  
  if (assessment.hasIncompleteAttempt) {
    action = 'continue'
  } else if (assessment.lastScore) {
    action = 'retake' 
  }
  
  // Navigate to assessment player with assessment slug and action
  window.location.href = `/docs/assessments/take?action=${action}#${assessment.slug}`
}

onMounted(async () => {
  console.log('Assessments component mounted')
  
  // Load assessments from database
  await loadAssessments()
  
  // Load user scores if authenticated
  if (user.value) {
    await loadUserScores()
    await loadIncompleteAttempts()
  }
})
</script>

<style scoped>
.assessments-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.auth-required {
  padding: 0;
  min-height: 80vh;
}

.auth-hero {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4rem;
  align-items: center;
  padding: 4rem 2rem;
  background: linear-gradient(135deg, var(--vp-c-brand-soft) 0%, var(--vp-c-bg-soft) 50%, var(--vp-c-brand-softer) 100%);
  border-radius: 20px;
  position: relative;
  overflow: hidden;
}

.auth-hero::before {
  content: '';
  position: absolute;
  top: -50%;
  right: -50%;
  width: 100%;
  height: 200%;
  background: radial-gradient(ellipse, rgba(102, 126, 234, 0.1) 0%, transparent 70%);
  pointer-events: none;
  animation: float 20s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translate(0, 0) rotate(0deg); }
  33% { transform: translate(30px, -30px) rotate(120deg); }
  66% { transform: translate(-20px, 20px) rotate(240deg); }
}

.auth-hero-content {
  position: relative;
  z-index: 2;
}

.auth-icon {
  margin-bottom: 1rem;
}

.auth-icon-svg {
  width: 4rem;
  height: 4rem;
  color: var(--vp-c-brand-1);
}

.dark .auth-icon-svg {
  color: #818cf8;
}

.auth-hero h1 {
  font-size: 3rem;
  font-weight: 800;
  color: var(--vp-c-text-1);
  margin-bottom: 1rem;
  line-height: 1.1;
}

.auth-subtitle {
  font-size: 1.2rem;
  color: var(--vp-c-text-2);
  margin-bottom: 3rem;
  line-height: 1.6;
}

.auth-features-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
  margin-bottom: 3rem;
}

.auth-feature {
  padding: 1rem;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.auth-feature-icon {
  margin-bottom: 0.5rem;
}

.auth-feature-icon .feature-icon-svg {
  width: 1.5rem;
  height: 1.5rem;
  color: var(--vp-c-brand-1);
}

.dark .auth-feature-icon .feature-icon-svg {
  color: #818cf8;
}

.auth-feature h3 {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
  margin-bottom: 0.5rem;
}

.auth-feature p {
  font-size: 0.8rem;
  color: var(--vp-c-text-2);
  line-height: 1.4;
  margin: 0;
}

.auth-cta-section {
  text-align: center;
}

.auth-cta-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 1rem 2rem;
  background: linear-gradient(45deg, var(--vp-c-brand-1), var(--vp-c-brand-2));
  color: white;
  text-decoration: none;
  border-radius: 50px;
  font-weight: 600;
  font-size: 1.1rem;
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
  transition: all 0.3s ease;
}

.auth-cta-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 35px rgba(102, 126, 234, 0.4);
}

.auth-cta-arrow {
  font-size: 1.2rem;
  transition: transform 0.3s ease;
}

.auth-cta-btn:hover .auth-cta-arrow {
  transform: translateX(3px);
}

.auth-cta-note {
  margin-top: 1rem;
  color: var(--vp-c-text-3);
  font-size: 0.9rem;
}

.auth-preview {
  position: relative;
  z-index: 2;
}

.preview-card {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  padding: 1.5rem;
  margin-bottom: 1rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.preview-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}

.preview-icon {
  width: 50px;
  height: 50px;
  background: var(--vp-c-brand-soft);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.preview-info h4 {
  color: var(--vp-c-text-1);
  margin: 0 0 0.25rem 0;
  font-size: 1rem;
}

.preview-info span {
  color: var(--vp-c-text-2);
  font-size: 0.8rem;
}

.preview-progress {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.progress-bar {
  flex: 1;
  height: 6px;
  background: var(--vp-c-divider-light);
  border-radius: 3px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--vp-c-brand-1), var(--vp-c-brand-2));
  border-radius: 3px;
  transition: width 0.3s ease;
}

.preview-progress span {
  font-size: 0.8rem;
  color: var(--vp-c-text-2);
  white-space: nowrap;
}

.preview-stats {
  display: flex;
  justify-content: space-around;
  padding: 1.5rem;
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
  border: 1px solid var(--vp-c-divider);
}

.stat {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.25rem;
}

.stat-number {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--vp-c-brand-1);
}

.stat-label {
  font-size: 0.7rem;
  color: var(--vp-c-text-2);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.assessments-header {
  text-align: center;
  margin-bottom: 4rem;
  padding: 3rem 2rem;
  background: linear-gradient(135deg, var(--vp-c-brand-soft) 0%, var(--vp-c-bg-soft) 100%);
  border-radius: 16px;
  position: relative;
  overflow: hidden;
}

.assessments-header::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: url('data:image/svg+xml,<svg width="60" height="60" viewBox="0 0 60 60" xmlns="http://www.w3.org/2000/svg"><g fill="none" fill-rule="evenodd"><g fill="%23667eea" fill-opacity="0.03"><circle cx="30" cy="30" r="2"/></g></svg>');
  pointer-events: none;
}

.hero-content {
  position: relative;
  z-index: 1;
}

.assessments-header h1 {
  color: var(--vp-c-text-1);
  margin-bottom: 1rem;
  font-size: 2.5rem;
  font-weight: 700;
}

.header-description {
  color: var(--vp-c-text-2);
  font-size: 1.2rem;
  margin-bottom: 2rem;
  max-width: 600px;
  margin-left: auto;
  margin-right: auto;
}

.hero-features {
  display: flex;
  justify-content: center;
  gap: 2rem;
  flex-wrap: wrap;
}

.feature-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-radius: 25px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  font-weight: 500;
  color: var(--vp-c-text-1);
  font-size: 0.9rem;
}

.feature-icon-svg {
  width: 1.25rem;
  height: 1.25rem;
  color: var(--vp-c-brand-1);
  flex-shrink: 0;
}

.dark .feature-icon-svg {
  color: #818cf8;
}

.heading-icon {
  width: 2rem;
  height: 2rem;
  display: inline-block;
  vertical-align: middle;
  margin-right: 0.5rem;
  color: var(--vp-c-brand-1);
}

.dark .heading-icon {
  color: #818cf8;
}

.framework-selector {
  margin-bottom: 3rem;
}

.framework-selector h3 {
  color: var(--vp-c-text-1);
  margin-bottom: 0.5rem;
  text-align: center;
  font-size: 1.5rem;
}

.framework-description {
  color: var(--vp-c-text-2);
  text-align: center;
  margin-bottom: 2rem;
  font-size: 1rem;
  max-width: 500px;
  margin-left: auto;
  margin-right: auto;
}

.framework-options {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
  max-width: 1000px;
  margin: 0 auto;
}

.framework-btn {
  padding: 0;
  border: 2px solid var(--vp-c-divider);
  border-radius: 16px;
  background: var(--vp-c-bg);
  cursor: pointer;
  transition: all 0.3s ease;
  overflow: hidden;
}

.framework-btn:hover {
  border-color: var(--vp-c-brand-1);
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.15);
}

.framework-btn.active {
  border-color: var(--vp-c-brand-1);
  background: var(--vp-c-brand-softer);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.2);
}

.framework-card {
  padding: 2rem;
  text-align: center;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.5rem;
}

.framework-logo-container {
  width: 180px;
  height: 120px;
  background: white;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.framework-logo {
  width: 100%;
  height: 100%;
  object-fit: contain;
  max-width: none;
  max-height: none;
}

.framework-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
}

.framework-content h4 {
  color: var(--vp-c-text-1);
  font-size: 1.1rem;
  font-weight: 600;
  margin: 0;
  line-height: 1.3;
}

.framework-subtitle {
  color: var(--vp-c-text-2);
  font-size: 0.9rem;
  margin: 0 0 1rem 0;
  line-height: 1.4;
}

.framework-stats {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  width: 100%;
}

.stat-item {
  color: var(--vp-c-text-2);
  font-size: 0.85rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.5rem;
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
  font-weight: 500;
}

.framework-btn.active .stat-item {
  background: rgba(255, 255, 255, 0.5);
  color: var(--vp-c-text-1);
}

.assessments-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 1.5rem;
  margin-bottom: 3rem;
  justify-content: center;
  max-width: 1200px;
  margin-left: auto;
  margin-right: auto;
}

/* Level Progression Layout */
.assessments-list {
  margin-top: 2rem;
}

.framework-assessments {
  max-width: 1000px;
  margin: 0 auto;
}

.level-progression {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.assessment-level-card {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  padding: 1.5rem;
  transition: all 0.3s ease;
}

.assessment-level-card:hover:not(.coming-soon) {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.assessment-level-card.coming-soon {
  opacity: 0.7;
  background: var(--vp-c-bg-soft);
}

.assessment-level-card .assessment-header {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  margin-bottom: 1rem;
  position: relative;
}

.assessment-level-card .assessment-info {
  flex: 1;
}

.coming-soon-badge {
  position: absolute;
  top: 0;
  right: 0;
  background: var(--vp-c-yellow-1);
  color: white;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 600;
}

.meta-row {
  display: flex;
  gap: 2rem;
  margin-bottom: 0.5rem;
}

.level-badge {
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
}

.level-badge.beginner {
  background: #dcfce7;
  color: #166534;
}

.level-badge.intermediate {
  background: #fef3c7;
  color: #92400e;
}

.level-badge.advanced {
  background: #fee2e2;
  color: #991b1b;
}

.score-display {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  background: var(--vp-c-bg-soft);
  border-radius: 6px;
  margin-top: 0.5rem;
}

.score-value.excellent { color: #166534; }
.score-value.good { color: #3b82f6; }
.score-value.fair { color: #f59e0b; }
.score-value.needs-improvement { color: #ef4444; }

.assessment-btn {
  width: 100% !important;
}

.assessment-card {
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  padding: 1.5rem;
  background: var(--vp-c-bg-soft);
  transition: all 0.3s;
  flex: 0 0 350px;
  max-width: 450px;
  position: relative;
  display: flex;
  flex-direction: column;
  min-height: 340px;
}

.assessment-card.coming-soon {
  opacity: 0.8;
}

.assessment-card:hover {
  border-color: var(--vp-c-brand-1);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.assessment-header {
  display: flex;
  gap: 1rem;
  margin-bottom: 1.5rem;
  flex: 1;
}

.assessment-bottom {
  margin-top: auto;
}

/* 3-Column Card Layout */
.assessment-main {
  display: grid;
  grid-template-columns: 1fr 220px 250px;
  gap: 2rem;
  padding: 2rem;
  align-items: center;
}

/* Left Column: Badge + Title + Description */
.assessment-left-col {
  display: flex;
  gap: 1rem;
  align-items: flex-start;
  flex: 1;
}

.assessment-content {
  flex: 1;
}

.assessment-content h3 {
  color: var(--vp-c-text-1);
  margin: 0 0 0.5rem 0;
  font-size: 1.25rem;
  font-weight: 600;
  line-height: 1.3;
}

.assessment-description {
  color: var(--vp-c-text-2);
  margin: 0;
  font-size: 0.95rem;
  line-height: 1.5;
}

/* Middle Column: Stats - More spacious */
.assessment-middle-col {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  align-items: stretch;
  padding: 1.25rem;
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
  border: 1px solid var(--vp-c-divider-light);
  width: 220px;
}

.assessment-middle-col .stat-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  width: 100%;
  justify-content: flex-start;
  padding: 0.5rem;
  border-radius: 8px;
  transition: background-color 0.2s ease;
}

.assessment-middle-col .stat-item:hover {
  background: var(--vp-c-bg-alt);
}

.assessment-middle-col .stat-icon {
  font-size: 1.25rem;
  width: 24px;
  text-align: center;
  color: var(--vp-c-brand-1);
}

.assessment-middle-col .stat-content {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
  flex: 1;
}

.assessment-middle-col .stat-value {
  font-weight: 600;
  color: var(--vp-c-text-1);
  font-size: 1rem;
  line-height: 1.2;
}

.assessment-middle-col .stat-label {
  font-size: 0.75rem;
  color: var(--vp-c-text-3);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  line-height: 1;
}

/* Right Column: Progress/Score + Button */
.assessment-right-col {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  align-items: stretch;
  min-width: 250px;
}

.assessment-actions {
  margin: 0;
}

.score-icon {
  font-size: 1.5rem;
  margin-right: 0.5rem;
}

.score-content {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}


.assessment-info h3 {
  color: var(--vp-c-text-1);
  margin: 0 0 0.5rem 0;
  font-size: 1.1rem;
}

.assessment-info p {
  color: var(--vp-c-text-2);
  margin: 0;
  font-size: 0.9rem;
  line-height: 1.4;
}

.assessment-meta {
  display: flex;
  justify-content: space-between;
  align-items: stretch;
  margin: 0 auto 1rem auto;
  max-width: 400px;
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

.last-score {
  margin-bottom: 1rem;
  padding: 0.75rem;
  background: var(--vp-c-brand-soft);
  border-radius: 8px;
  display: flex;
  justify-content: space-between;
}

.score-label {
  color: var(--vp-c-text-2);
}

.score-value {
  font-weight: 600;
  color: var(--vp-c-brand-1);
}

.assessment-actions {
  display: flex;
  margin-top: 1rem;
}

.start-btn {
  padding: 0.75rem 1rem;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s;
  width: 100%;
}

.start-btn.start {
  background: var(--vp-c-brand-1);
  color: white;
}

.start-btn.retake {
  background: var(--vp-c-green-1);
  color: white;
}

.start-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

@media (max-width: 768px) {
  /* Container improvements */
  .assessments-container {
    padding: 1rem;
  }
  
  /* Auth required state */
  .auth-hero {
    grid-template-columns: 1fr;
    gap: 2rem;
    padding: 2rem 1rem;
  }
  
  .auth-hero h1 {
    font-size: 2rem;
  }
  
  .auth-subtitle {
    font-size: 1rem;
    margin-bottom: 2rem;
  }
  
  .auth-features-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
    margin-bottom: 2rem;
  }
  
  .auth-feature {
    padding: 0.75rem;
  }
  
  .auth-feature h3 {
    font-size: 0.8rem;
  }
  
  .auth-feature p {
    font-size: 0.7rem;
  }
  
  .auth-cta-btn {
    padding: 0.75rem 1.5rem;
    font-size: 1rem;
  }
  
  .preview-card {
    padding: 1rem;
  }
  
  .preview-stats {
    padding: 1rem;
  }
  
  .stat-number {
    font-size: 1.2rem;
  }

  /* Main assessments page */
  .assessments-header {
    padding: 2rem 1rem;
    margin-bottom: 2rem;
  }
  
  .assessments-header h1 {
    font-size: 2rem;
  }
  
  .header-description {
    font-size: 1rem;
  }
  
  .hero-features {
    flex-direction: column;
    align-items: center;
    gap: 1rem;
  }
  
  .feature-item {
    font-size: 0.8rem;
    padding: 0.5rem 0.75rem;
  }
  
  /* Framework selector mobile improvements */
  .framework-selector {
    margin-bottom: 2rem;
    padding: 0 1rem;
  }
  
  .framework-selector h3 {
    font-size: 1.3rem;
  }
  
  .framework-description {
    font-size: 0.9rem;
  }
  
  .framework-options {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .framework-card {
    padding: 1.5rem;
    gap: 1rem;
  }
  
  .framework-logo-container {
    width: 60px;
    height: 40px;
    padding: 8px;
  }
  
  .framework-content h4 {
    font-size: 1rem;
  }
  
  .framework-subtitle {
    font-size: 0.8rem;
  }
  
  /* Assessment cards mobile improvements */
  .assessments-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
    padding: 0 1rem;
  }
  
  .assessment-card {
    min-height: auto;
    padding: 1rem;
    margin: 0;
  }
  
  .assessment-header {
    gap: 0.75rem;
    margin-bottom: 1rem;
  }
  
  .assessment-info h3 {
    font-size: 1rem;
  }
  
  .assessment-info p {
    font-size: 0.85rem;
    line-height: 1.3;
  }
  
  .assessment-meta {
    flex-direction: row;
    margin: 0 auto 1rem auto;
    justify-content: space-around;
    max-width: 100%;
    width: 100%;
    padding: 0.75rem;
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
  
  .last-score {
    margin-bottom: 1rem;
    padding: 0.5rem;
  }
  
  .assessment-actions {
    margin-top: 0.5rem;
  }
  
  /* 3-Column layout mobile responsive */
  .assessment-main {
    grid-template-columns: 1fr;
    gap: 1.5rem;
    padding: 1.5rem;
  }
  
  .assessment-left-col {
    gap: 0.75rem;
  }
  
  .assessment-content h3 {
    font-size: 1.1rem;
  }
  
  .assessment-description {
    font-size: 0.9rem;
  }
  
  .assessment-middle-col {
    padding: 0.75rem;
    min-width: auto;
  }
  
  .assessment-middle-col .stat-item {
    justify-content: flex-start;
  }
  
  .assessment-middle-col .stat-icon {
    font-size: 1rem;
    width: 18px;
  }
  
  .assessment-middle-col .stat-value {
    font-size: 0.85rem;
  }
  
  .assessment-middle-col .stat-label {
    font-size: 0.65rem;
  }
  
  .assessment-right-col {
    min-width: auto;
  }
  
  .progress-section,
  .score-section {
    padding: 0.75rem;
  }
  
  .score-main {
    align-items: flex-start;
    gap: 0.5rem;
  }
}

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
</style>