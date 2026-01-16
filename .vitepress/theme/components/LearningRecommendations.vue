<template>
  <div class="learning-recommendations insights-section">
    <div class="section-header">
      <h3>Your Learning Path</h3>
      <p class="section-subtitle">Structured programs to accelerate your coaching development</p>
    </div>

    <!-- Loading state for tiered recommendations -->
    <div v-if="tieredLoading" class="loading-state">
      <div class="loading-spinner">⏳</div>
      <p>Loading personalized recommendations...</p>
    </div>

    <div v-else class="recommendations-list">
      <div 
        v-for="rec in recommendations" 
        :key="rec.title" 
        class="recommendation-card"
        :class="{ 'is-expanded': isExpanded(rec.title) }"
      >
        <div class="card-header" @click="toggleCard(rec.title)">
          <div class="header-content">
            <span class="rec-icon">{{ rec.icon }}</span>
            <div class="rec-info">
              <div class="title-row">
                <h4>{{ rec.title }}</h4>
                <div v-if="rec.tier" class="tier-badge" :class="`tier-${rec.tier.code}`">
                  Priority {{ rec.tier.priority }}
                </div>
              </div>
              <p class="rec-description">{{ rec.description }}</p>
              
              <!-- Show competency scores if available -->
              <div v-if="rec.competencies && rec.competencies.length > 0" class="competency-scores">
                <div class="competency-label">Based on your performance:</div>
                <div class="competency-list">
                  <span 
                    v-for="comp in rec.competencies" 
                    :key="comp.competency"
                    class="competency-score"
                    :class="`score-${comp.tier.code}`"
                  >
                    {{ comp.competency }}: {{ comp.score }}%
                  </span>
                </div>
              </div>
            </div>
          </div>
          <button class="expand-toggle" :aria-expanded="isExpanded(rec.title)">
            <span class="expand-icon">{{ isExpanded(rec.title) ? '−' : '+' }}</span>
          </button>
        </div>
        
        <div class="recommendation-content" v-show="isExpanded(rec.title)">
          <div class="resource-list" v-if="rec.resources && rec.resources.length > 0">
            <ul class="resources">
              <li v-for="resource in rec.resources" :key="resource.title || resource" class="resource-item">
                <span class="resource-icon">{{ getResourceIconFromType(resource) }}</span>
                <div class="resource-content">
                  <div class="resource-header">
                    <div class="resource-title-wrapper">
                      <div class="resource-type-label" v-if="getResourceTypeLabel(resource)">
                        {{ getResourceTypeLabel(resource) }}
                      </div>
                      <div class="resource-title">{{ formatResourceTitle(resource) }}</div>
                    </div>
                    <a v-if="getResourceUrl(resource)" 
                       :href="getResourceUrl(resource)" 
                       target="_blank" 
                       rel="noopener noreferrer"
                       class="resource-link"
                       :title="'Open ' + (getResourceTitle(resource) || 'resource')"
                    >
                      <span class="link-icon">🔗</span>
                    </a>
                  </div>
                  <div class="resource-author" v-if="getResourceAuthor(resource)">
                    by {{ getResourceAuthor(resource) }}
                  </div>
                  <div class="resource-description" v-if="getResourceDescription(resource)">
                    {{ getResourceDescription(resource) }}
                  </div>
                </div>
              </li>
            </ul>
          </div>
          
          <!-- Keep backward compatibility for practices format -->
          <div class="practice-list" v-else-if="rec.practices && rec.practices.length > 0">
            <ul class="practices">
              <li v-for="practice in rec.practices" :key="practice" class="practice-item">
                {{ practice }}
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue'
import { getUserFriendlyError, formatErrorForUI } from '../composables/useUserFriendlyErrors.js'
import { useTieredResources } from '../composables/useTieredResources.js'

// Props
const props = defineProps({
  // Legacy props kept for backward compatibility with insights display
  competencyStats: {
    type: Array,
    default: () => []
  },
  overallScore: {
    type: Number,
    default: 0
  },
  // Primary props for tiered system
  userId: {
    type: String,
    required: true
  },
  assessmentId: {
    type: String,
    required: true
  },
  attemptId: {
    type: String,
    required: false
  }
})

// Accordion state management - only one card open at a time
const expandedCard = ref(null)

// Tiered resources functionality
const { recommendations: tieredRecommendations, loading: tieredLoading, generateRecommendations } = useTieredResources()

// Load tiered recommendations 
onMounted(async () => {
  await generateRecommendations(props.userId, props.assessmentId, props.attemptId)
})

// Toggle individual card (auto-close others)
const toggleCard = (title) => {
  if (expandedCard.value === title) {
    expandedCard.value = null
  } else {
    expandedCard.value = title
  }
}

// Check if card is expanded
const isExpanded = (title) => {
  return expandedCard.value === title
}


// Resource type icon mapping using database resource_type_id values
const RESOURCE_TYPE_ICONS = {
  'b04373d5-2562-49aa-a1a9-13dfbf14caf2': { icon: '📚', label: 'Book' },
  '5dbbc2f1-a7bc-42f9-b667-7a6f003528f9': { icon: '📄', label: 'Article' },
  '3993f2c5-1929-4249-baaf-d7df8723f46f': { icon: '🎥', label: 'Course' },
  'ca796c69-15dd-4fd5-9aba-151aaa612304': { icon: '🛠️', label: 'Exercise' },
  '42f3e6ee-3335-4fd5-801a-85fdfa479cc8': { icon: '🏫', label: 'Workshop' },
  '4811da0b-cfc3-4234-8884-818170ea2643': { icon: '🎬', label: 'Video' }
}

// Get appropriate icon based on resource type
const getResourceIconFromType = (resource) => {
  // Use resource_type_id for precise mapping
  if (resource.resource_type_id && RESOURCE_TYPE_ICONS[resource.resource_type_id]) {
    return RESOURCE_TYPE_ICONS[resource.resource_type_id].icon
  }
  
  // Fallback to resource_type field
  const resourceType = resource.resource_type?.toLowerCase()
  switch (resourceType) {
    case 'book': return '📚'
    case 'course': return '🎥' 
    case 'video': return '🎬'
    case 'workshop': return '🏫'
    case 'exercise': return '🛠️'
    case 'article': return '📄'
    default: return '📚'
  }
}

// Get resource type label for display
const getResourceTypeLabel = (resource) => {
  // Use resource_type_id for precise mapping
  if (resource.resource_type_id && RESOURCE_TYPE_ICONS[resource.resource_type_id]) {
    return RESOURCE_TYPE_ICONS[resource.resource_type_id].label
  }
  
  // Fallback to resource_type field
  if (resource.resource_type) {
    return resource.resource_type.charAt(0).toUpperCase() + resource.resource_type.slice(1)
  }
  
  return 'Resource'
}

// Format resource title
const formatResourceTitle = (resource) => {
  return resource.title || 'Untitled Resource'
}

// Get resource author
const getResourceAuthor = (resource) => {
  return resource.author_instructor || resource.author || null
}

// Get resource description
const getResourceDescription = (resource) => {
  return resource.description || null
}

// Get resource URL
const getResourceUrl = (resource) => {
  return resource.url || null
}

// Get resource title
const getResourceTitle = (resource) => {
  return resource.title || null
}

// Generate recommendations - tiered system only
const recommendations = computed(() => {
  // If still loading, show empty (loading state will be displayed)
  if (tieredLoading.value) {
    return []
  }
  
  // Use tiered recommendations if available
  if (tieredRecommendations.value && tieredRecommendations.value.length > 0) {
    return convertTieredToLegacyFormat(tieredRecommendations.value)
  }
  
  // If no tiered data and no loading, show empty state
  return []
})

// Convert tiered recommendations to category-focused format for display
const convertTieredToLegacyFormat = (tieredData) => {
  return tieredData.map(tierGroup => ({
    title: tierGroup.title, // Use category title (Communication & Questioning, Presence & Awareness)
    description: tierGroup.message, // Use contextual message based on tier performance
    icon: tierGroup.icon, // Use category icon (🗣️, 🧘)
    resources: tierGroup.resources || [],
    tier: tierGroup.tier,
    competencies: tierGroup.competencies,
    priority: tierGroup.tier.priority
  }))
  .sort((a, b) => a.priority - b.priority) // Sort by priority (weakness first)
}

// Get emoji for tier
const getTierEmoji = (tierCode) => {
  const emojis = {
    weakness: '🎯',
    developing: '📈', 
    strength: '⭐'
  }
  return emojis[tierCode] || '📚'
}
</script>

<style scoped>
.learning-recommendations {
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

/* Loading state */
.loading-state {
  text-align: center;
  padding: 3rem 1rem;
  color: var(--vp-c-text-2);
}

.loading-spinner {
  font-size: 2rem;
  margin-bottom: 1rem;
  animation: pulse 1.5s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.recommendations-list {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  max-width: 900px;
  margin: 2rem auto 0;
}

.recommendation-card {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  border-left: 4px solid var(--vp-c-brand-1);
  padding: 1.5rem;
  transition: all 0.3s ease;
}

.recommendation-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
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
  transition: transform 0.3s ease;
}

.recommendation-card.is-expanded .expand-icon {
  transform: rotate(180deg);
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

/* Expanded state styles */
.recommendation-card.is-expanded .card-header {
  margin-bottom: 1rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--vp-c-divider-light);
}

.recommendation-content {
  overflow: hidden;
  transition: all 0.3s ease;
}

.recommendation-card:not(.is-expanded) .recommendation-content {
  display: none;
}


.rec-icon {
  font-size: 2rem;
  flex-shrink: 0;
  margin-top: 0.25rem;
}

.rec-info {
  flex: 1;
}

/* Title row with tier badge */
.title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  margin-bottom: 0.5rem;
}

.tier-badge {
  padding: 0.25rem 0.6rem;
  border-radius: 12px;
  font-size: 0.7rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  white-space: nowrap;
}

.tier-weakness {
  background: #fef2f2;
  color: #dc2626;
  border: 1px solid #fecaca;
}

.tier-developing {
  background: #fffbeb;
  color: #d97706;
  border: 1px solid #fed7aa;
}

.tier-strength {
  background: #ecfdf5;
  color: #059669;
  border: 1px solid #a7f3d0;
}

/* Competency scores */
.competency-scores {
  margin-top: 0.75rem;
  padding-top: 0.75rem;
  border-top: 1px solid var(--vp-c-divider-light);
}

.competency-label {
  font-size: 0.8rem;
  color: var(--vp-c-text-2);
  margin-bottom: 0.5rem;
  font-weight: 500;
}

.competency-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.competency-score {
  padding: 0.2rem 0.5rem;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 600;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
}

.score-weakness {
  background: #fef2f2;
  color: #dc2626;
  border-color: #fecaca;
}

.score-developing {
  background: #fffbeb;
  color: #d97706;
  border-color: #fed7aa;
}

.score-strength {
  background: #ecfdf5;
  color: #059669;
  border-color: #a7f3d0;
}

/* Dark mode enhancements */
.dark .tier-weakness {
  background: rgba(220, 38, 38, 0.15);
  color: #fca5a5;
  border-color: rgba(220, 38, 38, 0.3);
}

.dark .tier-developing {
  background: rgba(217, 119, 6, 0.15);
  color: #fdba74;
  border-color: rgba(217, 119, 6, 0.3);
}

.dark .tier-strength {
  background: rgba(5, 150, 105, 0.15);
  color: #6ee7b7;
  border-color: rgba(5, 150, 105, 0.3);
}

.dark .score-weakness {
  background: rgba(220, 38, 38, 0.15);
  color: #fca5a5;
  border-color: rgba(220, 38, 38, 0.3);
}

.dark .score-developing {
  background: rgba(217, 119, 6, 0.15);
  color: #fdba74;
  border-color: rgba(217, 119, 6, 0.3);
}

.dark .score-strength {
  background: rgba(5, 150, 105, 0.15);
  color: #6ee7b7;
  border-color: rgba(5, 150, 105, 0.3);
}

.dark .competency-scores {
  border-top-color: var(--vp-c-divider);
}

.dark .resource-type-label {
  color: var(--vp-c-brand-light);
}

.rec-info h4 {
  margin: 0 0 0.5rem 0;
  color: var(--vp-c-text-1);
  font-size: 1.1rem;
  font-weight: 600;
}

.rec-description {
  margin: 0;
  color: var(--vp-c-text-2);
  font-size: 0.9rem;
  line-height: 1.5;
}

.resource-list, .practice-list {
  border-top: 1px solid var(--vp-c-divider-light);
  padding-top: 1rem;
}

.resources, .practices {
  margin: 0;
  padding: 0;
  list-style: none;
}

.learning-recommendations .resource-item {
  display: flex !important;
  align-items: flex-start !important;
  gap: 0.75rem !important;
  padding: 0.75rem 0 !important;
  color: var(--vp-c-text-1) !important;
  font-size: 0.85rem !important;
  line-height: 1.3 !important;
  border-bottom: 1px solid var(--vp-c-divider-light) !important;
  position: relative !important;
  list-style: none !important;
}

.resource-content {
  flex: 1;
}

.resource-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 0.75rem;
  margin-bottom: 0.25rem;
}

.resource-title-wrapper {
  flex: 1;
}

.resource-type-label {
  font-size: 0.7rem;
  font-weight: 600;
  color: var(--vp-c-brand-1);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: 0.25rem;
}

.resource-title {
  font-weight: 600;
  color: var(--vp-c-text-1);
  line-height: 1.4;
}

.resource-link {
  color: var(--vp-c-brand-1);
  text-decoration: none;
  display: flex;
  align-items: center;
  padding: 0.25rem;
  border-radius: 4px;
  transition: all 0.2s ease;
  flex-shrink: 0;
}

.resource-link:hover {
  background-color: var(--vp-c-bg-soft);
  transform: scale(1.1);
}

.link-icon {
  font-size: 0.9rem;
  display: block;
}

.resource-author {
  color: var(--vp-c-text-2);
  font-size: 0.8rem;
  margin-bottom: 0.25rem;
  font-style: italic;
}

.resource-description {
  color: var(--vp-c-text-2);
  font-size: 0.8rem;
  line-height: 1.4;
  margin-top: 0.25rem;
}

.learning-recommendations .practice-item {
  display: flex !important;
  align-items: center !important;
  gap: 0.75rem !important;
  padding: 0.6rem 0 !important;
  color: var(--vp-c-text-1) !important;
  font-size: 0.85rem !important;
  line-height: 1.3 !important;
  border-bottom: 1px solid var(--vp-c-divider-light) !important;
  position: relative !important;
  list-style: none !important;
}

.learning-recommendations .resource-item:last-child, 
.learning-recommendations .practice-item:last-child {
  border-bottom: none !important;
}

.learning-recommendations .resource-icon {
  font-size: 1rem !important;
  flex-shrink: 0 !important;
  margin-top: 0.1rem !important;
  display: inline-block !important;
  width: 1.2rem !important;
  text-align: center !important;
}

.learning-recommendations .practice-item:before {
  content: "✓" !important;
  color: var(--vp-c-green-1) !important;
  font-weight: bold !important;
  font-size: 1rem !important;
  flex-shrink: 0 !important;
  margin-top: 0.1rem !important;
  display: inline-block !important;
  width: 1.2rem !important;
  text-align: center !important;
  position: static !important;
}


@media (max-width: 768px) {
  .learning-recommendations {
    margin-top: 0.5rem;
    padding: 0;
  }
  
  .insights-section {
    margin-bottom: 1.5rem;
  }
  
  .section-header {
    margin-bottom: 1rem;
    padding: 1rem;
  }
  
  .section-header h3 {
    font-size: 1.2rem;
  }
  
  .section-subtitle {
    font-size: 0.85rem;
  }
  
  .recommendations-list {
    gap: 1rem;
    margin-top: 1rem;
  }
  
  .recommendation-card {
    padding: 1rem;
    border-left-width: 3px;
  }
  
  .header-content {
    flex-direction: column;
    gap: 0.75rem;
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
  
  .rec-icon {
    font-size: 1.5rem;
    margin-top: 0;
  }
  
  .rec-info h4 {
    font-size: 1rem;
    margin-bottom: 0.3rem;
  }
  
  .rec-description {
    font-size: 0.85rem;
    line-height: 1.4;
  }
  
  .resource-list, .practice-list {
    padding-top: 0.75rem;
  }
  
  .learning-recommendations .resource-item, 
  .learning-recommendations .practice-item {
    font-size: 0.8rem !important;
    padding: 0.5rem 0 !important;
    gap: 0.5rem !important;
    line-height: 1.4 !important;
  }
  
  .learning-recommendations .resource-icon, 
  .learning-recommendations .practice-item:before {
    font-size: 0.9rem !important;
    width: 1rem !important;
  }
  
  /* Mobile tier features */
  .title-row {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
  
  .tier-badge {
    font-size: 0.65rem;
    padding: 0.2rem 0.5rem;
  }
  
  .competency-scores {
    margin-top: 0.5rem;
    padding-top: 0.5rem;
  }
  
  .competency-list {
    flex-direction: column;
    gap: 0.25rem;
  }
  
  .competency-score {
    font-size: 0.7rem;
    padding: 0.15rem 0.4rem;
  }
}
</style>