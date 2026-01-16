<template>
  <AdminModal
    :is-open="isOpen"
    :title="modalTitle"
    :icon="modalIcon"
    size="large"
    @close="$emit('close')"
  >
    <div v-if="attempt" class="attempt-details">
      <!-- Header Info -->
      <div class="detail-section">
        <h3 class="section-title">📋 Attempt Information</h3>
        <div class="info-grid">
          <div class="info-item">
            <span class="info-label">Attempt ID:</span>
            <code class="info-value">{{ attempt.id }}</code>
          </div>
          <div class="info-item">
            <span class="info-label">User ID:</span>
            <code class="info-value">{{ attempt.user_id }}</code>
          </div>
          <div class="info-item">
            <span class="info-label">User Email:</span>
            <span class="info-value">{{ userEmail || 'Unknown' }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">Assessment:</span>
            <span class="info-value">{{ assessmentName || 'Unknown' }}</span>
          </div>
        </div>
      </div>

      <!-- Status & Progress + Performance Metrics (Inline) -->
      <div class="detail-section">
        <h3 class="section-title">📊 Status & Performance Overview</h3>
        <div class="inline-cards-grid">
          <!-- Status Card -->
          <div class="status-card">
            <div class="status-label">Status</div>
            <div class="status-value">
              <span class="status-badge" :class="attempt.status">
                {{ formatStatus(attempt.status) }}
              </span>
            </div>
          </div>
          
          <!-- Progress Card -->
          <div class="status-card">
            <div class="status-label">Progress</div>
            <div class="status-value">
              <div class="progress-display">
                <span class="progress-text">
                  {{ attempt.current_question_index || 0 }} / {{ attempt.total_questions || 0 }}
                </span>
                <div class="progress-bar">
                  <div class="progress-fill" :style="{ width: progressWidth }"></div>
                </div>
              </div>
            </div>
          </div>
          
          <!-- Final Score Card -->
          <div v-if="attempt.status === 'completed'" class="status-card">
            <div class="status-label">Final Score</div>
            <div class="status-value">
              <span class="score-badge large" :class="getScoreClass(attempt.score)">
                {{ Math.round(attempt.score || 0) }}%
              </span>
            </div>
          </div>
          
          <!-- Performance Metrics Cards (when completed) -->
          <template v-if="attempt.status === 'completed'">
            <div class="metric-card">
              <div class="metric-label">Correct Answers</div>
              <div class="metric-value">{{ attempt.correct_answers || 0 }} / {{ attempt.total_questions || 0 }}</div>
            </div>
            
            <div class="metric-card">
              <div class="metric-label">Accuracy Rate</div>
              <div class="metric-value">{{ accuracyRate }}%</div>
            </div>
            
            <div class="metric-card">
              <div class="metric-label">Time Spent</div>
              <div class="metric-value">{{ formatDuration(attempt.time_spent) }}</div>
            </div>
            
            <div class="metric-card">
              <div class="metric-label">Avg. Time per Question</div>
              <div class="metric-value">{{ avgTimePerQuestion }}</div>
            </div>
          </template>
        </div>
      </div>

      <!-- Timing Information (Inline) -->
      <div class="detail-section">
        <h3 class="section-title">⏱️ Timing Information</h3>
        <div class="inline-info-grid">
          <div class="info-item">
            <span class="info-label">Started At:</span>
            <span class="info-value">{{ formatDate(attempt.started_at || attempt.created_at) }}</span>
          </div>
          <div v-if="attempt.completed_at" class="info-item">
            <span class="info-label">Completed At:</span>
            <span class="info-value">{{ formatDate(attempt.completed_at) }}</span>
          </div>
          <div v-if="attempt.last_activity_at" class="info-item">
            <span class="info-label">Last Activity:</span>
            <span class="info-value">{{ formatDate(attempt.last_activity_at) }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">Total Duration:</span>
            <span class="info-value">{{ totalDuration }}</span>
          </div>
        </div>
      </div>

      <!-- Enriched Data (Collapsible) -->
      <div v-if="attempt.enriched_data && Object.keys(attempt.enriched_data).length > 0" class="detail-section">
        <h3 class="section-title clickable" @click="showAdditionalData = !showAdditionalData">
          📦 Additional Data
          <span class="expand-indicator" :class="{ expanded: showAdditionalData }">
            {{ showAdditionalData ? '▼' : '▶' }}
          </span>
        </h3>
        <Transition name="collapse">
          <div v-show="showAdditionalData" class="enriched-data">
            <pre class="data-display">{{ JSON.stringify(attempt.enriched_data, null, 2) }}</pre>
          </div>
        </Transition>
      </div>

      <!-- Performance Analysis -->
      <div v-if="attempt.status === 'completed'" class="detail-section">
        <h3 class="section-title">💡 Performance Analysis</h3>
        <div class="analysis-box">
          <div class="performance-level" :class="performanceLevel.class">
            <span class="level-icon">{{ performanceLevel.icon }}</span>
            <span class="level-text">{{ performanceLevel.text }}</span>
          </div>
          <p class="analysis-text">{{ performanceAnalysis }}</p>
        </div>
      </div>
    </div>

    <template #footer>
      <ActionButton @click="exportDetails" variant="secondary" icon="📥">
        Export Details
      </ActionButton>
      <ActionButton @click="$emit('close')" variant="primary">
        Close
      </ActionButton>
    </template>
  </AdminModal>
</template>

<script setup>
import { computed, ref } from 'vue'
import AdminModal from './AdminModal.vue'
import ActionButton from './ActionButton.vue'

// Expand/collapse state
const showAdditionalData = ref(false)

const props = defineProps({
  isOpen: {
    type: Boolean,
    required: true
  },
  attempt: {
    type: Object,
    default: null
  },
  userEmail: {
    type: String,
    default: ''
  },
  assessmentName: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['close'])

// Computed properties
const modalTitle = computed(() => {
  if (!props.attempt) return 'Attempt Details'
  return props.attempt.status === 'completed' ? 'Assessment Results Report' : 'Assessment Attempt Progress'
})

const modalIcon = computed(() => {
  if (!props.attempt) return '📊'
  return props.attempt.status === 'completed' ? '🏆' : '📊'
})

const progressWidth = computed(() => {
  if (!props.attempt || !props.attempt.total_questions) return '0%'
  const progress = (props.attempt.current_question_index || props.attempt.correct_answers || 0) / props.attempt.total_questions
  return `${Math.min(progress * 100, 100)}%`
})

const accuracyRate = computed(() => {
  if (!props.attempt || !props.attempt.total_questions) return 0
  return Math.round((props.attempt.correct_answers || 0) / props.attempt.total_questions * 100)
})

const avgTimePerQuestion = computed(() => {
  if (!props.attempt || !props.attempt.time_spent || !props.attempt.total_questions) return 'N/A'
  const avgMinutes = props.attempt.time_spent / props.attempt.total_questions
  if (avgMinutes < 1) return `${Math.round(avgMinutes * 60)}s`
  return `${avgMinutes.toFixed(1)}m`
})

const totalDuration = computed(() => {
  if (!props.attempt) return 'N/A'
  if (props.attempt.time_spent) return formatDuration(props.attempt.time_spent)
  
  const start = props.attempt.started_at || props.attempt.created_at
  const end = props.attempt.completed_at || props.attempt.last_activity_at
  if (!start || !end) return 'N/A'
  
  const diffMs = new Date(end) - new Date(start)
  const diffMinutes = Math.round(diffMs / (1000 * 60))
  return formatDuration(diffMinutes)
})

const performanceLevel = computed(() => {
  if (!props.attempt || props.attempt.status !== 'completed') return { class: '', icon: '', text: '' }
  
  const score = props.attempt.score || 0
  if (score >= 90) return { class: 'excellent', icon: '🌟', text: 'Excellent Performance' }
  if (score >= 80) return { class: 'very-good', icon: '⭐', text: 'Very Good' }
  if (score >= 70) return { class: 'good', icon: '✨', text: 'Good Performance' }
  if (score >= 60) return { class: 'satisfactory', icon: '👍', text: 'Satisfactory' }
  return { class: 'needs-improvement', icon: '📚', text: 'Needs Improvement' }
})

const performanceAnalysis = computed(() => {
  if (!props.attempt || props.attempt.status !== 'completed') return ''
  
  const score = props.attempt.score || 0
  const accuracy = accuracyRate.value
  const timeSpent = props.attempt.time_spent || 0
  const avgTime = timeSpent / (props.attempt.total_questions || 1)
  
  let analysis = []
  
  // Score analysis
  if (score >= 80) {
    analysis.push('Strong overall performance with excellent understanding of the material.')
  } else if (score >= 70) {
    analysis.push('Good grasp of the concepts with room for improvement in some areas.')
  } else if (score >= 60) {
    analysis.push('Basic understanding demonstrated, additional study recommended.')
  } else {
    analysis.push('Consider reviewing the material and retaking the assessment.')
  }
  
  // Time analysis
  if (avgTime < 0.5) {
    analysis.push('Very quick completion - ensure thoughtful consideration of each question.')
  } else if (avgTime > 3) {
    analysis.push('Took time to consider answers carefully.')
  }
  
  // Accuracy analysis
  if (accuracy >= 90) {
    analysis.push('Exceptional accuracy in responses.')
  } else if (accuracy < 50) {
    analysis.push('Focus on understanding key concepts before reattempting.')
  }
  
  return analysis.join(' ')
})

// Methods
const formatStatus = (status) => {
  const statusMap = {
    'completed': 'Completed',
    'in_progress': 'In Progress',
    'abandoned': 'Abandoned'
  }
  return statusMap[status] || status || 'Unknown'
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
}

const formatDuration = (minutes) => {
  if (!minutes || minutes <= 0) return 'N/A'
  if (minutes < 60) return `${minutes}m`
  const hours = Math.floor(minutes / 60)
  const mins = minutes % 60
  return mins > 0 ? `${hours}h ${mins}m` : `${hours}h`
}

const getScoreClass = (score) => {
  if (score >= 80) return 'high'
  if (score >= 60) return 'medium'
  return 'low'
}

const exportDetails = () => {
  if (!props.attempt) return
  
  const details = {
    attempt_id: props.attempt.id,
    user_id: props.attempt.user_id,
    user_email: props.userEmail,
    assessment_name: props.assessmentName,
    status: formatStatus(props.attempt.status),
    score_percentage: props.attempt.score || 0,
    correct_answers: props.attempt.correct_answers || 0,
    total_questions: props.attempt.total_questions || 0,
    accuracy_percentage: accuracyRate.value,
    time_spent_minutes: props.attempt.time_spent || 0,
    started_at: props.attempt.started_at || props.attempt.created_at,
    completed_at: props.attempt.completed_at || '',
    last_activity_at: props.attempt.last_activity_at || '',
    current_question_index: props.attempt.current_question_index || 0,
    performance_level: performanceLevel.value.text,
    enriched_data: JSON.stringify(props.attempt.enriched_data || {})
  }
  
  // Convert to CSV
  const headers = Object.keys(details)
  const values = Object.values(details).map(v => {
    const str = String(v || '')
    return str.includes(',') || str.includes('"') || str.includes('\n') 
      ? `"${str.replace(/"/g, '""')}"` 
      : str
  })
  
  const csv = [headers.join(','), values.join(',')].join('\n')
  
  // Download
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `attempt_${props.attempt.id}_details.csv`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}
</script>

<style scoped>
.attempt-details {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.detail-section {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  padding: 20px;
}

.section-title {
  margin: 0 0 16px 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 16px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.info-label {
  font-size: 12px;
  color: var(--vp-c-text-2);
  font-weight: 500;
  text-transform: uppercase;
}

.info-value {
  font-size: 14px;
  color: var(--vp-c-text-1);
  font-weight: 500;
}

code.info-value {
  font-family: monospace;
  background: var(--vp-c-bg-mute);
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 12px;
}

.status-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
}

.status-card {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  padding: 16px;
  text-align: center;
}

.status-label {
  font-size: 12px;
  color: var(--vp-c-text-2);
  margin-bottom: 8px;
  text-transform: uppercase;
  font-weight: 500;
}

.status-value {
  font-size: 18px;
  font-weight: 600;
}

.status-badge {
  display: inline-block;
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
}

.status-badge.completed {
  background: var(--vp-c-success-soft);
  color: var(--vp-c-success);
}

.status-badge.in_progress {
  background: var(--vp-c-warning-soft);
  color: var(--vp-c-warning-darker);
}

.status-badge.abandoned {
  background: var(--vp-c-danger-soft);
  color: var(--vp-c-danger);
}

.progress-display {
  display: flex;
  flex-direction: column;
  gap: 8px;
  align-items: center;
}

.progress-text {
  font-size: 16px;
  color: var(--vp-c-text-1);
}

.progress-bar {
  width: 100%;
  height: 8px;
  background: var(--vp-c-bg-mute);
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: var(--vp-c-brand);
  transition: width 0.3s ease;
}

.score-badge {
  display: inline-block;
  padding: 8px 16px;
  border-radius: 8px;
  font-size: 20px;
  font-weight: 700;
}

.score-badge.high {
  background: var(--vp-c-success-soft);
  color: var(--vp-c-success);
}

.score-badge.medium {
  background: var(--vp-c-warning-soft);
  color: var(--vp-c-warning-darker);
}

.score-badge.low {
  background: var(--vp-c-danger-soft);
  color: var(--vp-c-danger);
}

.metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 16px;
}

.metric-card {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  padding: 12px;
  text-align: center;
}

.metric-label {
  font-size: 11px;
  color: var(--vp-c-text-2);
  margin-bottom: 4px;
  text-transform: uppercase;
}

.metric-value {
  font-size: 18px;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.enriched-data {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  padding: 12px;
}

.data-display {
  margin: 0;
  font-family: monospace;
  font-size: 12px;
  color: var(--vp-c-text-2);
  white-space: pre-wrap;
  word-break: break-word;
}

.analysis-box {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  padding: 20px;
}

.performance-level {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  border-radius: 6px;
  margin-bottom: 12px;
  font-weight: 600;
}

.performance-level.excellent {
  background: var(--vp-c-success-soft);
  color: var(--vp-c-success-darker);
}

.performance-level.very-good {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-darker);
}

.performance-level.good {
  background: var(--vp-c-indigo-soft);
  color: var(--vp-c-indigo-darker);
}

.performance-level.satisfactory {
  background: var(--vp-c-warning-soft);
  color: var(--vp-c-warning-darker);
}

.performance-level.needs-improvement {
  background: var(--vp-c-danger-soft);
  color: var(--vp-c-danger-darker);
}

.level-icon {
  font-size: 20px;
}

.level-text {
  font-size: 14px;
}

.analysis-text {
  margin: 0;
  font-size: 14px;
  line-height: 1.6;
  color: var(--vp-c-text-2);
}

.inline-info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 12px;
}

.inline-cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 16px;
}

.section-title.clickable {
  cursor: pointer;
  user-select: none;
  transition: color 0.2s;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.section-title.clickable:hover {
  color: var(--vp-c-brand);
}

.expand-indicator {
  font-size: 14px;
  transition: transform 0.2s;
  color: var(--vp-c-text-2);
}

.expand-indicator.expanded {
  transform: rotate(0deg);
}

.collapse-enter-active,
.collapse-leave-active {
  transition: all 0.3s ease;
  overflow: hidden;
}

.collapse-enter-from,
.collapse-leave-to {
  max-height: 0;
  opacity: 0;
  padding-top: 0;
  padding-bottom: 0;
}

.collapse-enter-to,
.collapse-leave-from {
  max-height: 400px;
  opacity: 1;
}

@media (max-width: 1024px) {
  .inline-cards-grid {
    grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
  }
}

@media (max-width: 768px) {
  .info-grid {
    grid-template-columns: 1fr;
  }
  
  .status-grid,
  .metrics-grid {
    grid-template-columns: 1fr;
  }
  
  .inline-info-grid {
    grid-template-columns: 1fr;
    gap: 8px;
  }
  
  .inline-cards-grid {
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: 12px;
  }
}
</style>