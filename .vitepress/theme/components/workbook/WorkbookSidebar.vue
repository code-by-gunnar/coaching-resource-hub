<template>
  <div class="workbook-sidebar">
    <div class="sidebar-header">
      <div class="sidebar-header-content">
        <div class="sidebar-title-area">
          <h3>Sections</h3>
          <div class="completion-summary">
            {{ completedSections }}/{{ totalSections }} completed
          </div>
        </div>
        <button 
          class="mobile-close-btn"
          @click="$emit('close-sidebar')"
          aria-label="Close navigation"
        >
          ✕
        </button>
      </div>
    </div>

    <nav class="section-nav">
      <button
        v-for="(section, index) in sections"
        :key="section.section_number"
        @click="$emit('section-change', index + 1)"
        :class="[
          'section-item',
          `section-${section.section_number}`,
          {
            'active': currentSection === index + 1,
            'completed': section.progress_percent === 100,
            'in-progress': section.progress_percent > 0 && section.progress_percent < 100,
            'not-started': section.progress_percent === 0
          }
        ]"
      >
        <div class="section-info">
          <div class="section-header">
            <span class="section-number">{{ section.display_number || section.section_number }}</span>
            <div class="section-status">
              <CheckCircleIcon v-if="section.progress_percent === 100" class="status-icon completed" />
              <div v-else-if="section.progress_percent > 0" class="status-icon in-progress">
                <div class="progress-ring">
                  <svg class="progress-circle" viewBox="0 0 24 24">
                    <circle
                      cx="12"
                      cy="12"
                      r="10"
                      fill="none"
                      stroke="#e2e8f0"
                      stroke-width="2"
                    />
                    <circle
                      cx="12"
                      cy="12"
                      r="10"
                      fill="none"
                      stroke="#3b82f6"
                      stroke-width="2"
                      :stroke-dasharray="circumference"
                      :stroke-dashoffset="circumference - (section.progress_percent / 100) * circumference"
                      stroke-linecap="round"
                      transform="rotate(-90 12 12)"
                    />
                  </svg>
                </div>
              </div>
              <div v-else class="status-icon not-started"></div>
            </div>
          </div>
          <h4 class="section-title">{{ section.display_title || section.section_title }}</h4>
          <div class="progress-info">
            <div class="progress-bar">
              <div 
                class="progress-fill" 
                :style="{ width: `${section.progress_percent}%` }"
              ></div>
            </div>
            <span class="progress-text">{{ section.progress_percent }}%</span>
          </div>
          <div v-if="section.completed_at" class="completion-date">
            Completed {{ formatDate(section.completed_at) }}
          </div>
        </div>
      </button>
    </nav>

    <div class="sidebar-footer">
      <div class="overall-stats">
        <h4>Your Progress</h4>
        <div class="stat-item">
          <span class="stat-label">Overall Completion</span>
          <span class="stat-value">{{ overallProgress }}%</span>
        </div>
        <div class="stat-item">
          <span class="stat-label">Last Activity</span>
          <span class="stat-value">{{ formatDate(lastActivity) }}</span>
        </div>
        <div class="stat-item">
          <span class="stat-label">Time Invested</span>
          <span class="stat-value">{{ timeSpent }}</span>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { CheckCircleIcon } from '@heroicons/vue/24/solid'

const props = defineProps({
  sections: {
    type: Array,
    required: true
  },
  currentSection: {
    type: Number,
    required: true
  }
})

defineEmits(['section-change', 'close-sidebar'])

// Constants
const circumference = 2 * Math.PI * 10 // radius = 10

// Computed properties
const totalSections = computed(() => props.sections.length)

const completedSections = computed(() => 
  props.sections.filter(s => s.progress_percent === 100).length
)

const overallProgress = computed(() => {
  if (!props.sections.length) return 0
  const totalProgress = props.sections.reduce((sum, section) => sum + section.progress_percent, 0)
  return Math.round(totalProgress / props.sections.length)
})

const lastActivity = computed(() => {
  if (!props.sections.length) return null
  const dates = props.sections
    .map(s => s.last_updated)
    .filter(Boolean)
    .sort((a, b) => new Date(b) - new Date(a))
  return dates[0] || null
})

const allCompleted = computed(() => 
  props.sections.length > 0 && props.sections.every(s => s.progress_percent === 100)
)

const timeSpent = computed(() => {
  // Calculate rough time spent based on activity
  // This is a simplified calculation - could be enhanced with actual time tracking
  const completedFields = props.sections.reduce((sum, section) => {
    return sum + Math.round((section.progress_percent / 100) * 8) // Assume ~8 fields per section average
  }, 0)
  
  const estimatedMinutes = completedFields * 3 // ~3 minutes per field
  
  if (estimatedMinutes < 60) return `${estimatedMinutes}m`
  const hours = Math.floor(estimatedMinutes / 60)
  const minutes = estimatedMinutes % 60
  return `${hours}h ${minutes}m`
})

// Methods
const formatDate = (dateString) => {
  if (!dateString) return 'Not yet'
  
  const date = new Date(dateString)
  const now = new Date()
  const diffMs = now - date
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))
  
  if (diffDays === 0) return 'Today'
  if (diffDays === 1) return 'Yesterday'
  if (diffDays < 7) return `${diffDays} days ago`
  
  return date.toLocaleDateString()
}
</script>

<style scoped>
.workbook-sidebar {
  background: var(--vp-c-bg-soft);
  border-right: 1px solid var(--vp-c-divider);
  height: 100%;
  display: flex;
  flex-direction: column;
  box-shadow: 2px 0 4px var(--vp-c-shadow-1);
  border-radius: 12px;
  overflow: hidden;
}

/* Mobile-specific sidebar adjustments */
@media (max-width: 768px) {
  .workbook-sidebar {
    border-radius: 0;
    border-right: none;
    box-shadow: none;
    height: 100vh;
  }
  
  .sidebar-header {
    padding: 1rem;
    position: sticky;
    top: 0;
    background: var(--vp-c-bg-soft);
    z-index: 10;
    border-bottom: 2px solid var(--vp-c-divider);
  }
  
  .sidebar-header h3 {
    font-size: 1.2rem;
    margin-bottom: 0.25rem;
  }
  
  .completion-summary {
    font-size: 0.9rem;
    color: var(--vp-c-brand-1);
    font-weight: 600;
  }
  
  .section-nav {
    overflow-y: auto;
    flex: 1;
    padding: 0.5rem;
  }
  
  .section-item {
    margin-bottom: 0.75rem;
    border-radius: 12px;
    border-left-width: 4px;
  }
  
  .section-item:hover {
    transform: none;
    background: var(--section-accent-light, var(--vp-c-bg-alt));
  }
  
  .section-item.active {
    background: var(--section-accent-light, var(--vp-c-bg-alt));
    border-left-width: 4px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }
  
  .section-title {
    font-size: 0.95rem;
    line-height: 1.4;
  }
  
  .progress-info {
    margin-top: 0.5rem;
  }
  
  .sidebar-footer {
    padding: 1rem;
    background: var(--vp-c-bg);
    border-top: 2px solid var(--vp-c-divider);
  }
  
  .overall-stats h4 {
    font-size: 1rem;
    margin-bottom: 0.75rem;
  }
  
  .stat-item {
    margin-bottom: 0.75rem;
    padding: 0.5rem 0;
    border-bottom: 1px solid var(--vp-c-divider-light);
  }
  
  .stat-item:last-child {
    border-bottom: none;
  }
  
  .stat-label {
    font-size: 0.85rem;
  }
  
  .stat-value {
    font-size: 0.85rem;
    font-weight: 700;
  }
  
  .quick-actions {
    margin-top: 1rem;
  }
  
  .action-btn {
    padding: 0.75rem 1rem;
    font-size: 0.9rem;
    border-radius: 8px;
  }
}

.sidebar-header {
  padding: 1.5rem;
  border-bottom: 1px solid var(--vp-c-divider-light);
}

.sidebar-header-content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.sidebar-title-area {
  flex: 1;
}

.sidebar-header h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.completion-summary {
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
  font-weight: 500;
}

.mobile-close-btn {
  display: none;
  background: transparent;
  border: none;
  font-size: 1.5rem;
  color: var(--vp-c-text-2);
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 4px;
  transition: all 0.2s;
  line-height: 1;
  width: 32px;
  height: 32px;
  align-items: center;
  justify-content: center;
}

@media (max-width: 768px) {
  .mobile-close-btn {
    display: flex;
  }
}

.mobile-close-btn:hover {
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-1);
}

.section-nav {
  flex: 1;
  padding: 1rem;
}

.section-item {
  width: 100%;
  padding: 1rem 1.5rem;
  border: 1px solid var(--vp-c-divider);
  border-left: 3px solid var(--vp-c-divider);
  background: var(--vp-c-bg);
  text-align: left;
  cursor: pointer;
  transition: all 0.2s;
  margin-bottom: 0.5rem;
  border-radius: 8px;
}

.section-item:hover {
  background: var(--vp-c-bg-mute);
  transform: translateX(2px);
}

.section-item.active {
  background: var(--vp-c-bg-alt);
  border-left-color: var(--vp-c-brand-1);
  border-left-width: 3px;
  box-shadow: 0 2px 4px var(--vp-c-shadow-1);
}

.section-item.completed {
  border-left-color: var(--vp-c-green-1);
  border-left-width: 3px;
}

.section-item.in-progress {
  border-left-color: var(--vp-c-yellow-1);
  border-left-width: 3px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.section-number {
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-2);
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.8rem;
  font-weight: 600;
}

.section-item.active .section-number {
  background: var(--vp-c-brand-1);
  color: var(--vp-c-white);
}

.section-item.completed .section-number {
  background: var(--vp-c-green-1);
  color: var(--vp-c-white);
}

.status-icon {
  width: 20px;
  height: 20px;
}

.status-icon.completed {
  color: var(--vp-c-green-1);
}

.status-icon.not-started {
  width: 8px;
  height: 8px;
  background: var(--vp-c-divider);
  border-radius: 50%;
  margin: 6px;
}

.progress-ring {
  width: 20px;
  height: 20px;
}

.progress-circle {
  width: 100%;
  height: 100%;
  transform: rotate(-90deg);
}

.section-title {
  margin: 0 0 0.5rem 0;
  font-size: 0.9rem;
  font-weight: 500;
  color: var(--vp-c-text-1);
  line-height: 1.3;
}

.progress-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.progress-bar {
  flex: 1;
  height: 6px;
  background: var(--vp-c-bg-mute);
  border: 1px solid var(--vp-c-divider);
  border-radius: 3px;
  overflow: hidden;
  box-shadow: inset 0 1px 2px var(--vp-c-shadow-1);
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--vp-c-brand-1) 0%, var(--vp-c-brand-2) 100%);
  transition: width 0.3s ease;
}

.section-item.completed .progress-fill {
  background: linear-gradient(90deg, var(--vp-c-green-1) 0%, var(--vp-c-green-2) 100%);
}

.progress-text {
  font-size: 0.75rem;
  color: var(--vp-c-text-1);
  font-weight: 600;
  min-width: 35px;
  padding: 2px 6px;
  background: var(--vp-c-bg-alt);
  border: 1px solid var(--vp-c-divider-light);
  border-radius: 4px;
}

.completion-date {
  font-size: 0.75rem;
  color: var(--vp-c-green-1);
  margin-top: 0.25rem;
  font-weight: 500;
}

.sidebar-footer {
  border-top: 1px solid var(--vp-c-divider-light);
  padding: 1.5rem;
  background: var(--vp-c-bg-soft);
}

.overall-stats h4 {
  margin: 0 0 1rem 0;
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.stat-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.stat-label {
  font-size: 0.8rem;
  color: var(--vp-c-text-2);
}

.stat-value {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.quick-actions {
  margin-top: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.action-btn {
  padding: 0.5rem 1rem;
  border-radius: 6px;
  font-size: 0.85rem;
  font-weight: 500;
  border: none;
  cursor: pointer;
  transition: all 0.2s;
}

.action-btn.primary {
  background: var(--vp-c-brand-1);
  color: var(--vp-c-white);
}

.action-btn.primary:hover {
  background: var(--vp-c-brand-2);
}

.action-btn.secondary {
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  border: 1px solid var(--vp-c-divider);
}

.action-btn.secondary:hover {
  background: var(--vp-c-bg-mute);
}

/* Scrollbar styling */
.section-nav::-webkit-scrollbar {
  width: 4px;
}

.section-nav::-webkit-scrollbar-track {
  background: var(--vp-c-bg-mute);
}

.section-nav::-webkit-scrollbar-thumb {
  background: var(--vp-c-divider);
  border-radius: 2px;
}

.section-nav::-webkit-scrollbar-thumb:hover {
  background: var(--vp-c-divider-light);
}

/* Subtle color variations for each section */
.section-1 {
  --section-accent: #8b5cf6; /* Purple - identity/branding */
  --section-accent-soft: rgba(139, 92, 246, 0.1);
  --section-accent-light: rgba(139, 92, 246, 0.2);
}

.section-2 {
  --section-accent: #a855f7; /* Light Purple - identity deep dive (Part B) */
  --section-accent-soft: rgba(168, 85, 247, 0.1);
  --section-accent-light: rgba(168, 85, 247, 0.2);
}

.section-3 {
  --section-accent: #f59e0b; /* Amber - targeting clients */
  --section-accent-soft: rgba(245, 158, 11, 0.1);
  --section-accent-light: rgba(245, 158, 11, 0.2);
}

.section-4 {
  --section-accent: #ef4444; /* Red - branding */
  --section-accent-soft: rgba(239, 68, 68, 0.1);
  --section-accent-light: rgba(239, 68, 68, 0.2);
}

.section-5 {
  --section-accent: #06b6d4; /* Cyan - visual identity */
  --section-accent-soft: rgba(6, 182, 212, 0.1);
  --section-accent-light: rgba(6, 182, 212, 0.2);
}

.section-6 {
  --section-accent: #84cc16; /* Lime - products/pricing */
  --section-accent-soft: rgba(132, 204, 22, 0.1);
  --section-accent-light: rgba(132, 204, 22, 0.2);
}

.section-7 {
  --section-accent: #f97316; /* Orange - funnels */
  --section-accent-soft: rgba(249, 115, 22, 0.1);
  --section-accent-light: rgba(249, 115, 22, 0.2);
}

.section-8 {
  --section-accent: #3b82f6; /* Blue - marketing */
  --section-accent-soft: rgba(59, 130, 246, 0.1);
  --section-accent-light: rgba(59, 130, 246, 0.2);
}

.section-9 {
  --section-accent: #ec4899; /* Pink - social/networking */
  --section-accent-soft: rgba(236, 72, 153, 0.1);
  --section-accent-light: rgba(236, 72, 153, 0.2);
}

/* Apply subtle background tinting */
.section-item:hover {
  background: var(--section-accent-soft, var(--vp-c-bg-mute));
}

.section-item.active {
  background: var(--section-accent-light, var(--vp-c-bg-alt));
  border-left-color: var(--section-accent, var(--vp-c-brand-1));
}

.section-item.completed {
  border-left-color: var(--section-accent, var(--vp-c-green-1));
}

.section-item.in-progress {
  border-left-color: var(--section-accent, var(--vp-c-yellow-1));
}

/* Update section number colors to match theme */
.section-item.active .section-number {
  background: var(--section-accent, var(--vp-c-brand-1));
  color: var(--vp-c-white);
}

.section-item.completed .section-number {
  background: var(--section-accent, var(--vp-c-green-1));
  color: var(--vp-c-white);
}

/* Update progress fill colors to match section theme */
.section-item .progress-fill {
  background: linear-gradient(90deg, var(--section-accent, var(--vp-c-brand-1)) 0%, var(--section-accent, var(--vp-c-brand-2)) 100%);
}

.section-item.completed .progress-fill {
  background: linear-gradient(90deg, var(--section-accent, var(--vp-c-green-1)) 0%, var(--section-accent, var(--vp-c-green-2)) 100%);
}
</style>