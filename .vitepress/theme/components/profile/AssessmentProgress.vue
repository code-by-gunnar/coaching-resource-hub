<template>
  <div class="assessment-progress">
    <div class="section-header">
      <h3>🎯 Recent Assessment Progress</h3>
      <a href="/docs/assessments/" class="view-all-btn">View All Assessments</a>
    </div>
    
    <div class="assessment-list">
      <div 
        v-for="attempt in recentAttempts" 
        :key="attempt.assessment_id"
        class="assessment-item"
        :class="getScoreClass(attempt.score)"
        @click="viewResults(attempt)"
      >
        <div class="assessment-info">
          <div class="assessment-title">{{ attempt.assessment_title }}</div>
          <div class="assessment-meta">
            <span class="framework-badge" :class="attempt.framework">{{ getFrameworkName(attempt.framework) }}</span>
            <span class="completion-date">{{ formatDate(attempt.completed_at) }}</span>
          </div>
        </div>
        
        <div class="assessment-score">
          <div class="score-circle" :class="getScoreClass(attempt.score)">
            <span class="score-number">{{ attempt.score || 0 }}%</span>
          </div>
          <div class="score-label">{{ getScoreLabel(attempt.score) }}</div>
        </div>
      </div>
    </div>

    <div v-if="assessmentAttempts.length === 0" class="no-assessments">
      <div class="no-assessments-icon">🎯</div>
      <h4>No assessments taken yet</h4>
      <p>Start your coaching competency journey with our revolutionary Prometric-style assessments</p>
      <a href="/docs/assessments/" class="start-assessments-btn">Take Your First Assessment</a>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  assessmentAttempts: {
    type: Array,
    default: () => []
  }
})

// Show only the most recent attempt for each assessment (up to 5)
const recentAttempts = computed(() => {
  const uniqueAssessments = new Map()
  
  // Get the most recent attempt for each assessment
  props.assessmentAttempts
    .filter(attempt => attempt.status === 'completed' && attempt.attempt_number === 1)
    .forEach(attempt => {
      if (!uniqueAssessments.has(attempt.assessment_id)) {
        uniqueAssessments.set(attempt.assessment_id, attempt)
      }
    })
  
  return Array.from(uniqueAssessments.values()).slice(0, 5)
})

const getFrameworkName = (framework) => {
  const names = {
    icf: 'ICF',
    ac: 'AC',
    universal: 'Core'
  }
  return names[framework] || framework.toUpperCase()
}

const getScoreClass = (score) => {
  if (score >= 90) return 'excellent'
  if (score >= 80) return 'good'
  if (score >= 70) return 'fair'
  return 'needs-improvement'
}

const getScoreLabel = (score) => {
  if (score >= 90) return 'Excellent'
  if (score >= 80) return 'Good'
  if (score >= 70) return 'Fair'
  return 'Needs Work'
}

const formatDate = (dateString) => {
  if (!dateString) return 'Unknown'
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { 
    month: 'short', 
    day: 'numeric', 
    year: 'numeric' 
  })
}

const viewResults = (attempt) => {
  // Navigate to results page with specific attempt
  window.location.href = `/docs/assessments/results?attempt=${attempt.id}`
}
</script>

<style scoped>
.assessment-progress {
  margin-bottom: 2rem;
  padding: 2rem;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.section-header h3 {
  margin: 0;
  color: var(--vp-c-text-1);
  font-size: 1.3rem;
}

.view-all-btn {
  color: var(--vp-c-brand-1);
  text-decoration: none;
  font-weight: 500;
  font-size: 0.9rem;
  transition: color 0.3s ease;
}

.view-all-btn:hover {
  color: var(--vp-c-brand-dark);
}

.assessment-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.assessment-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  transition: all 0.3s ease;
  cursor: pointer;
}

.assessment-item:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.assessment-info {
  flex: 1;
}

.assessment-title {
  font-weight: 600;
  color: var(--vp-c-text-1);
  font-size: 1.1rem;
  margin-bottom: 0.5rem;
}

.assessment-meta {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.framework-badge {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 500;
}

.framework-badge.icf {
  background: #dbeafe;
  color: #1e40af;
}

.framework-badge.ac {
  background: #fef3c7;
  color: #92400e;
}

.framework-badge.core {
  background: #f3e8ff;
  color: #7c3aed;
}

.completion-date {
  color: var(--vp-c-text-2);
  font-size: 0.9rem;
}

.assessment-score {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
}

.score-circle {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}

.score-circle.excellent {
  background: #dcfce7;
  color: #166534;
}

.score-circle.good {
  background: #dbeafe;
  color: #1e40af;
}

.score-circle.fair {
  background: #fef3c7;
  color: #92400e;
}

.score-circle.needs-improvement {
  background: #fee2e2;
  color: #991b1b;
}

.score-number {
  font-size: 0.9rem;
}

.score-label {
  font-size: 0.8rem;
  color: var(--vp-c-text-2);
  font-weight: 500;
}

.no-assessments {
  text-align: center;
  padding: 3rem 2rem;
}

.no-assessments-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.no-assessments h4 {
  color: var(--vp-c-text-1);
  margin-bottom: 0.5rem;
}

.no-assessments p {
  color: var(--vp-c-text-2);
  margin-bottom: 2rem;
  line-height: 1.6;
}

.start-assessments-btn {
  display: inline-block;
  padding: 0.75rem 1.5rem;
  background: var(--vp-c-brand-1);
  color: white;
  text-decoration: none;
  border-radius: 6px;
  font-weight: 500;
  transition: all 0.3s ease;
}

.start-assessments-btn:hover {
  background: var(--vp-c-brand-dark);
  transform: translateY(-1px);
}

@media (max-width: 768px) {
  .section-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }
  
  .assessment-item {
    flex-direction: column;
    text-align: center;
    gap: 1rem;
  }
  
  .assessment-meta {
    justify-content: center;
  }
}
</style>