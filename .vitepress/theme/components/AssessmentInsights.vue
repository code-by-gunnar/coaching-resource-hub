<template>
  <div class="insights-container">
    <!-- Development Areas -->
    <div v-if="smartInsights.weakAreas.length > 0" class="insights-section">
      <div class="section-header">
        <div class="section-icon">
          <ClipboardDocumentCheckIcon class="section-icon-svg development" aria-hidden="true" />
        </div>
        <h3>Your Development Areas</h3>
        <p class="section-subtitle">Focus on these skills to accelerate your coaching effectiveness</p>
      </div>
      
      <div class="insights-list">
        <div 
          v-for="comp in smartInsights.weakAreas" 
          :key="comp.area"
          class="insight-card development"
          :class="{ 'is-expanded': isExpanded(comp.area) }"
        >
          <div class="card-header" @click="toggleCard(comp.area)">
            <div class="header-content">
              <AssessmentBadge 
                :framework="assessmentFramework" 
                :skill="mapCompetencyToSkill(comp.area)"
                size="small"
              />
              <div class="competency-info">
                <h4>{{ comp.displayName }}</h4>
                <div class="score-indicator">
                  <span class="score-value">{{ comp.percentage }}%</span>
                  <div class="progress-bar">
                    <div 
                      class="progress-fill development"
                      :style="{ width: comp.percentage + '%' }"
                    ></div>
                  </div>
                </div>
                <!-- Show description as preview when collapsed -->
                <p v-if="!isExpanded(comp.area) && comp.description" class="preview-text">
                  {{ comp.description }}
                </p>
                <!-- Fallback to first insight if no description -->
                <p v-else-if="!isExpanded(comp.area) && comp.insights?.length > 0" class="preview-text">
                  {{ comp.insights[0] }}
                </p>
              </div>
            </div>
            <button class="expand-toggle" :aria-expanded="isExpanded(comp.area)">
              <span class="expand-icon">{{ isExpanded(comp.area) ? '−' : '+' }}</span>
            </button>
          </div>
          
          <div class="insight-content" v-show="isExpanded(comp.area)">
            <!-- Show skill tags only when expanded -->
            <div class="skill-tags">
              <span 
                v-for="tag in getSkillTags(comp.area)" 
                :key="tag"
                class="skill-tag development"
              >
                {{ tag }}
              </span>
            </div>
            <!-- Personalized insights -->
            <div v-if="comp.insights?.length > 0" class="personalized-insights">
              <div class="insight-section">
                <h5>Performance Analysis</h5>
                <div class="insight-items">
                  <p v-for="insight in comp.insights" :key="insight" class="insight-text personalized">
                    {{ insight }}
                  </p>
                </div>
              </div>
              
              <div v-if="comp.actions?.length > 0" class="action-section">
                <h5>Strategic Actions</h5>
                <div class="action-items">
                  <p v-for="action in comp.actions" :key="action" class="action-text personalized">
                    {{ action }}
                  </p>
                </div>
              </div>

              <!-- Skill Tag Analysis - ALWAYS SHOW THIS SECTION -->
              <div class="skill-tag-analysis">
                <h5>Specific Skills to Practice</h5>
                
                <!-- Show skill tags if available -->
                <div v-if="comp.skillTagAnalysis?.length > 0" class="tag-analysis-items">
                  <div v-for="tagData in comp.skillTagAnalysis" :key="tagData.tag" class="tag-analysis-item">
                    <div class="tag-header">
                      <span class="tag-name">{{ tagData.tag }}</span>
                      <span class="tag-priority" :class="getPriorityClass(tagData.priority)">
                        {{ getPriorityLabel(tagData.priority) }}
                      </span>
                    </div>
                    <p class="tag-insight">{{ tagData.insight }}</p>
                    <p class="tag-action">{{ tagData.action }}</p>
                  </div>
                </div>
                
                <!-- Show no data message when skills aren't available -->
                <div v-else class="no-skill-data">
                  <p class="no-data-message">
                    <ExclamationTriangleIcon class="warning-icon-svg" aria-hidden="true" />
                    No skill tag data available for {{ comp.area }}
                  </p>
                  <p class="mismatch-hint">
                    This may indicate a database mismatch between assessment questions and skill tags.
                  </p>
                </div>
              </div>

              <!-- Question analysis summary -->
              <div v-if="comp.questionAnalysis?.incorrectQuestions?.length > 0" class="question-analysis">
                <h5>Questions Missed ({{ comp.questionAnalysis.incorrect }}/{{ comp.questionAnalysis.total }})</h5>
                <div class="missed-questions">
                  <details class="question-details">
                    <summary>View specific questions</summary>
                    <div class="question-list">
                      <div v-for="q in comp.questionAnalysis.incorrectQuestions" :key="q.question" class="missed-question">
                        <p class="question-text">{{ q.question }}</p>
                        <p v-if="q.explanation" class="question-explanation">{{ q.explanation }}</p>
                      </div>
                    </div>
                  </details>
                </div>
              </div>
            </div>
            
            <!-- No insights fallback -->
            <div v-else class="no-insights-available">
              <p>No personalized insights available</p>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Strengths -->
    <div v-if="smartInsights.strengths.length > 0" class="insights-section">
      <div class="section-header">
        <div class="section-icon">
          <SparklesIcon class="section-icon-svg strength" aria-hidden="true" />
        </div>
        <h3>Your Coaching Strengths</h3>
        <p class="section-subtitle">Build on these established competencies</p>
      </div>
      
      <div class="strengths-list">
        <div 
          v-for="comp in smartInsights.strengths" 
          :key="comp.area"
          class="insight-card strength"
          :class="{ 'is-expanded': isExpanded(comp.area) }"
        >
          <div class="card-header" @click="toggleCard(comp.area)">
            <div class="header-content">
              <AssessmentBadge 
                :framework="assessmentFramework" 
                :skill="mapCompetencyToSkill(comp.area)"
                size="small"
              />
              <div class="competency-info">
                <h4>{{ comp.displayName }}</h4>
                <div class="score-indicator">
                  <span class="score-value strong">{{ comp.percentage }}%</span>
                  <div class="progress-bar">
                    <div 
                      class="progress-fill strength"
                      :style="{ width: comp.percentage + '%' }"
                    ></div>
                  </div>
                </div>
                <!-- Show message preview when collapsed -->
                <p v-if="!isExpanded(comp.area)" class="preview-text strength-preview">
                  {{ comp.message }}
                </p>
              </div>
            </div>
            <button class="expand-toggle" :aria-expanded="isExpanded(comp.area)">
              <span class="expand-icon">{{ isExpanded(comp.area) ? '−' : '+' }}</span>
            </button>
          </div>
          
          <div class="insight-content" v-show="isExpanded(comp.area)">
            <!-- Show skill tags only when expanded -->
            <div class="skill-tags">
              <span 
                v-for="tag in getSkillTags(comp.area)" 
                :key="tag"
                class="skill-tag strength"
              >
                {{ tag }}
              </span>
            </div>
            <!-- Show any additional insights if available -->
            <div v-if="comp.insights?.length > 0" class="personalized-insights">
              <div class="insight-section">
                <h5>Leverage These Strengths</h5>
                <div class="insight-items">
                  <p v-for="insight in comp.insights" :key="insight" class="insight-text personalized">
                    {{ insight }}
                  </p>
                </div>
              </div>
            </div>
            
            <!-- Show strength actions if available -->
            <div v-if="comp.actions?.length > 0" class="personalized-insights">
              <div class="action-section">
                <h5>How to Maximize This Strength</h5>
                <div class="action-items">
                  <p v-for="action in comp.actions" :key="action" class="action-text personalized">
                    {{ action }}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- No insights message -->
    <div v-if="smartInsights.weakAreas.length === 0 && smartInsights.strengths.length === 0" class="no-insights">
      <div class="empty-state">
        <div class="empty-icon">
          <ChartBarSquareIcon class="empty-icon-svg" aria-hidden="true" />
        </div>
        <h3>No insights available</h3>
        <p>Complete an assessment to get personalized coaching insights and recommendations.</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useAssessmentInsights } from '../composables/useAssessmentInsights.js'
import {
  ClipboardDocumentCheckIcon,
  ExclamationTriangleIcon,
  SparklesIcon,
  ChartBarSquareIcon
} from '@heroicons/vue/24/outline'

// Props
const props = defineProps({
  competencyStats: {
    type: Array,
    default: () => []
  },
  personalizedAnalysis: {
    type: Array,
    default: () => []
  },
  assessmentFramework: {
    type: String,
    default: 'core'
  }
})

// Accordion state management - only one card open at a time
const expandedCard = ref(null)

// Toggle individual card (auto-close others)
const toggleCard = (competencyArea) => {
  if (expandedCard.value === competencyArea) {
    expandedCard.value = null
  } else {
    expandedCard.value = competencyArea
  }
}

// Check if card is expanded
const isExpanded = (competencyArea) => {
  return expandedCard.value === competencyArea
}

// Use insights composable for fallback
const {
  getSmartInsights,
  mapCompetencyToSkill,
  getSkillTags,
  getTagInsight,
  getTagActionableStep
} = useAssessmentInsights(
  computed(() => props.competencyStats),
  props.assessmentFramework
)

// Determine if we have personalized insights
const hasPersonalizedInsights = computed(() => {
  return props.personalizedAnalysis && props.personalizedAnalysis.length > 0 
    && props.personalizedAnalysis.some(comp => comp.personalizedInsights?.length > 0)
})

// Build insights structure - ONLY use personalized analysis
const smartInsights = computed(() => {
  // If we have personalized analysis, use it
  if (props.personalizedAnalysis && props.personalizedAnalysis.length > 0) {
    const weakAreas = props.personalizedAnalysis
      .filter(comp => comp.percentage < 70)
      .sort((a, b) => a.percentage - b.percentage)
      .map(comp => ({
        ...comp,
        message: comp.personalizedInsights?.[0] || `You scored ${comp.percentage}% on ${comp.area}`,
        insights: comp.personalizedInsights || [],
        actions: comp.personalizedActions || [],
        skillTagAnalysis: comp.skillTagAnalysis || [],
        questionAnalysis: comp.questionAnalysis || {},
        description: comp.description || null
      }))
    
    // Use 3-tier system: strength = 70-100%, developing = 50-69%, weakness = 0-49%
    const strengths = props.personalizedAnalysis
      .filter(comp => comp.percentage >= 70)
      .sort((a, b) => b.percentage - a.percentage)
      .map(comp => ({
        ...comp,
        message: comp.personalizedInsights?.[0] || `Strong performance in ${comp.area} (${comp.percentage}%)`,
        insights: comp.personalizedInsights || [],
        actions: comp.personalizedActions || [],
        skillTagAnalysis: comp.skillTagAnalysis || [],
        questionAnalysis: comp.questionAnalysis || {},
        description: comp.description || null
      }))
    
    return { weakAreas, strengths }
  }
  
  // If no personalized analysis, use competency stats as basic fallback
  if (props.competencyStats && props.competencyStats.length > 0) {
    const weakAreas = props.competencyStats
      .filter(comp => comp.percentage < 70)
      .sort((a, b) => a.percentage - b.percentage)
      .map(comp => ({
        ...comp,
        displayName: comp.area,
        message: `You scored ${comp.percentage}% on ${comp.area} (${comp.correct}/${comp.total} correct)`,
        insights: [`You scored ${comp.percentage}% on ${comp.area} - ${comp.correct} out of ${comp.total} questions correct.`],
        actions: [],
        skillTagAnalysis: [],
        questionAnalysis: {},
        description: null // No description for fallback case
      }))
    
    // Use 3-tier system: strength = 70-100%, developing = 50-69%, weakness = 0-49%
    const strengths = props.competencyStats
      .filter(comp => comp.percentage >= 70)
      .sort((a, b) => b.percentage - a.percentage)
      .map(comp => ({
        ...comp,
        displayName: comp.area,
        message: `Strong performance in ${comp.area} (${comp.percentage}%)`,
        insights: [`You scored ${comp.percentage}% on ${comp.area} - ${comp.correct} out of ${comp.total} questions correct.`],
        actions: [],
        skillTagAnalysis: [],
        questionAnalysis: {},
        description: null // No description for fallback case
      }))
    
    return { weakAreas, strengths }
  }
  
  // No data available
  return { weakAreas: [], strengths: [] }
})

// Helper methods for skill tag display
const getPriorityClass = (priority) => {
  if (priority >= 80) return 'priority-critical'
  if (priority >= 60) return 'priority-high'
  if (priority >= 40) return 'priority-medium'
  return 'priority-low'
}

const getPriorityLabel = (priority) => {
  if (priority >= 80) return 'Critical'
  if (priority >= 60) return 'High'
  if (priority >= 40) return 'Medium'
  return 'Low'
}

</script>

<style scoped>
.insights-container {
  max-width: 1000px;
  margin: 0 auto;
}

.insights-section {
  margin-bottom: 3rem;
}

.section-header {
  text-align: center;
  margin-bottom: 2rem;
  padding: 1.5rem;
  background: var(--vp-c-bg-soft, rgba(0, 0, 0, 0.04));
  border-radius: 12px;
  border: 1px solid var(--vp-c-divider);
}

/* Ensure light mode visibility */
html:not(.dark) .section-header {
  background: rgba(0, 0, 0, 0.04);
  border: 1px solid rgba(0, 0, 0, 0.1);
}

.section-icon {
  margin-bottom: 0.5rem;
}

.section-icon-svg {
  width: 2.5rem;
  height: 2.5rem;
}

.section-icon-svg.development {
  color: var(--vp-c-orange-1);
}

.section-icon-svg.strength {
  color: var(--vp-c-green-1);
}

/* Dark mode icon styles */
.dark .section-icon-svg.development {
  color: #fb923c;
}

.dark .section-icon-svg.strength {
  color: #4ade80;
}

.dark .warning-icon-svg {
  color: #fbbf24;
}

.dark .empty-icon-svg {
  color: #818cf8;
}

.section-header h3 {
  color: var(--vp-c-text-1);
  margin: 0 0 0.5rem 0;
  font-size: 1.5rem;
  font-weight: 600;
}

.section-subtitle {
  color: var(--vp-c-text-2);
  margin: 0;
  font-size: 0.95rem;
}

.insights-list {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  max-width: 900px;
  margin: 2rem auto 0;
}

.strengths-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  max-width: 900px;
  margin: 2rem auto 0;
}

.insight-card {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  padding: 1.5rem;
  transition: all 0.3s ease;
}

.insight-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.insight-card.development {
  border-left: 4px solid var(--vp-c-orange-1);
}

.insight-card.strength {
  border-left: 4px solid var(--vp-c-green-1);
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  cursor: pointer;
  user-select: none;
  transition: background-color 0.2s ease;
  padding: 0.5rem;
  margin: -0.5rem;
  border-radius: 8px;
}

.card-header:hover {
  background-color: var(--vp-c-bg-soft);
}

.header-content {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  flex: 1;
}

.expand-toggle {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 50%;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s ease;
  flex-shrink: 0;
}

.expand-toggle:hover {
  background: var(--vp-c-bg-alt);
}

.expand-icon {
  font-size: 1.2rem;
  font-weight: 600;
  color: var(--vp-c-text-2);
  line-height: 1;
}

.preview-text {
  margin: 0.5rem 0 0 0;
  color: var(--vp-c-text-2);
  font-size: 0.9rem;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}

.preview-text.strength-preview {
  color: var(--vp-c-green-2);
  font-style: italic;
}

/* Expanded state styles */
.insight-card.is-expanded .card-header {
  margin-bottom: 1rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--vp-c-divider-light);
}

.insight-content {
  overflow: hidden;
  transition: all 0.3s ease;
}

.insight-card:not(.is-expanded) .insight-content {
  display: none;
}

/* Smooth transition for expand icon */
.expand-icon {
  transition: transform 0.3s ease;
}

.insight-card.is-expanded .expand-icon {
  transform: rotate(180deg);
}


.competency-info {
  flex: 1;
}

.competency-info h4 {
  color: var(--vp-c-text-1);
  margin: 0 0 0.5rem 0;
  font-size: 1rem;
  font-weight: 600;
}

.skill-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.25rem;
  margin-bottom: 0.75rem;
}

/* Skills tags inside expanded content */
.insight-content .skill-tags {
  margin: 0 0 1rem 0;
}

.skill-tag {
  padding: 0.15rem 0.4rem;
  border-radius: 10px;
  font-size: 0.7rem;
  font-weight: 500;
  text-transform: capitalize;
  border: 1px solid;
  background: transparent;
}

.skill-tag.development {
  color: var(--vp-c-orange-1);
  border-color: var(--vp-c-orange-1);
  background: rgba(245, 158, 11, 0.1);
}

.skill-tag.strength {
  color: var(--vp-c-green-1);
  border-color: var(--vp-c-green-1);
  background: rgba(34, 197, 94, 0.1);
}

.score-indicator {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.score-value {
  font-weight: 600;
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
  min-width: 35px;
}

.score-value.strong {
  color: var(--vp-c-green-1);
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
  border-radius: 3px;
  transition: width 0.3s ease;
}

.progress-fill.development {
  background: linear-gradient(90deg, var(--vp-c-orange-1), var(--vp-c-orange-2));
}

.progress-fill.strength {
  background: linear-gradient(90deg, var(--vp-c-green-1), var(--vp-c-green-2));
}

.insight-content {
  border-top: 1px solid var(--vp-c-divider-light);
  padding-top: 1rem;
}

.tag-specific-insights {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.tag-insight-item {
  padding: 0.75rem;
  background: var(--vp-c-bg-alt);
  border-radius: 8px;
  border-left: 3px solid var(--vp-c-orange-1);
}

.tag-insight-header {
  margin-bottom: 0.5rem;
}

.insight-tag {
  font-weight: 600;
  font-size: 0.8rem;
  color: var(--vp-c-orange-1);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.tag-insight-text {
  color: var(--vp-c-text-2);
  font-size: 0.85rem;
  line-height: 1.5;
  margin: 0 0 0.5rem 0;
  font-style: italic;
}

.tag-action-text {
  color: var(--vp-c-text-1);
  font-size: 0.85rem;
  line-height: 1.5;
  margin: 0;
  font-weight: 500;
}

.insight-section {
  margin-bottom: 1rem;
}

.insight-section:last-child {
  margin-bottom: 0;
}

.insight-section h5 {
  color: var(--vp-c-text-1);
  margin: 0 0 0.5rem 0;
  font-size: 0.85rem;
  font-weight: 600;
}

.insight-list,
.action-list {
  margin: 0;
  padding-left: 1rem;
  color: var(--vp-c-text-2);
  font-size: 0.85rem;
  line-height: 1.5;
}

.insight-list li,
.action-list li {
  margin-bottom: 0.25rem;
}

.action-list {
  color: var(--vp-c-text-1);
}

.strength-message {
  color: var(--vp-c-text-2);
  font-size: 0.9rem;
  line-height: 1.5;
  margin: 0;
  font-style: italic;
}

/* No skill data styles */
.no-skill-data {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-yellow-dimmer);
  border-radius: 8px;
  padding: 1rem;
  margin-top: 0.5rem;
}

.no-data-message {
  color: var(--vp-c-text-1);
  margin: 0 0 0.5rem 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 500;
}

.warning-icon-svg {
  width: 1.25rem;
  height: 1.25rem;
  color: var(--vp-c-yellow-1);
  flex-shrink: 0;
}

.mismatch-hint {
  color: var(--vp-c-text-2);
  font-size: 0.85rem;
  margin: 0;
  font-style: italic;
}

.no-insights {
  text-align: center;
  padding: 3rem 2rem;
}

.empty-state {
  max-width: 400px;
  margin: 0 auto;
}

.empty-icon {
  margin-bottom: 1rem;
  opacity: 0.5;
}

.empty-icon-svg {
  width: 3rem;
  height: 3rem;
  color: var(--vp-c-text-3);
}

.empty-state h3 {
  color: var(--vp-c-text-1);
  margin: 0 0 0.5rem 0;
  font-size: 1.2rem;
}

.empty-state p {
  color: var(--vp-c-text-2);
  margin: 0;
  line-height: 1.6;
}

.no-insights-available {
  padding: 1rem;
  text-align: center;
  color: var(--vp-c-text-3);
  font-style: italic;
}

/* Personalized insights styles */
.personalized-insights {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.insight-section, .action-section, .question-analysis, .skill-tag-analysis {
  padding: 1rem;
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
  border-left: 3px solid var(--vp-c-brand-1);
}

.insight-section h5, .action-section h5, .question-analysis h5, .skill-tag-analysis h5 {
  margin: 0 0 0.75rem 0;
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--vp-c-brand-1);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.insight-text.personalized, .action-text.personalized {
  margin: 0 0 0.75rem 0;
  padding: 0.75rem;
  background: var(--vp-c-bg);
  border-radius: 6px;
  line-height: 1.5;
  font-size: 0.9rem;
  border-left: 2px solid var(--vp-c-divider);
}

.insight-text.personalized:last-child, .action-text.personalized:last-child {
  margin-bottom: 0;
}

.insight-text.personalized {
  color: var(--vp-c-text-1);
  border-left-color: var(--vp-c-yellow-1);
}

.action-text.personalized {
  color: var(--vp-c-text-1);
  border-left-color: var(--vp-c-green-1);
}

/* Question analysis styles */
.question-analysis {
  border-left-color: var(--vp-c-red-1);
}

.question-details {
  margin-top: 0.5rem;
}

.question-details summary {
  cursor: pointer;
  font-weight: 500;
  color: var(--vp-c-text-2);
  padding: 0.5rem 0;
  border-bottom: 1px solid var(--vp-c-divider-light);
}

.question-details summary:hover {
  color: var(--vp-c-text-1);
}

.question-list {
  margin-top: 0.75rem;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.missed-question {
  padding: 0.75rem;
  background: var(--vp-c-bg);
  border-radius: 6px;
  border-left: 2px solid var(--vp-c-red-1);
}

.question-text {
  margin: 0 0 0.5rem 0;
  font-weight: 500;
  color: var(--vp-c-text-1);
  line-height: 1.4;
}

.question-explanation {
  margin: 0;
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
  line-height: 1.4;
  font-style: italic;
}

/* Skill tag analysis styles */
.skill-tag-analysis {
  border-left-color: var(--vp-c-purple-1);
}

.tag-analysis-items {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.tag-analysis-item {
  padding: 0.75rem;
  background: var(--vp-c-bg);
  border-radius: 6px;
  border-left: 2px solid var(--vp-c-purple-1);
}

.tag-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.tag-name {
  font-weight: 600;
  color: var(--vp-c-text-1);
  font-size: 0.9rem;
}

.tag-priority {
  padding: 0.2rem 0.5rem;
  border-radius: 12px;
  font-size: 0.7rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.3px;
}

.priority-critical {
  background: var(--vp-c-red-soft);
  color: var(--vp-c-red-1);
}

.priority-high {
  background: var(--vp-c-yellow-soft);
  color: var(--vp-c-yellow-1);
}

.priority-medium {
  background: var(--vp-c-blue-soft);
  color: var(--vp-c-blue-1);
}

.priority-low {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green-1);
}

.tag-insight {
  margin: 0 0 0.5rem 0;
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
  line-height: 1.4;
}

.tag-action {
  margin: 0;
  font-size: 0.85rem;
  color: var(--vp-c-text-1);
  line-height: 1.4;
  font-weight: 500;
}

@media (max-width: 768px) {
  .insights-list,
  .strengths-list {
    gap: 1rem;
    margin-top: 1rem;
  }
  
  .header-content {
    flex-direction: column;
    gap: 0.75rem;
  }
  
  .score-indicator {
    gap: 0.5rem;
  }
  
  .insight-card {
    padding: 1rem;
  }
  
  .expand-toggle {
    width: 28px;
    height: 28px;
  }
  
  .expand-icon {
    font-size: 1rem;
  }
  
  .preview-text {
    font-size: 0.85rem;
  }
}
</style>