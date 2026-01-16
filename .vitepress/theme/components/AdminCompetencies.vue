<template>
  <div class="admin-container">
    <!-- Loading state during auth check -->
    <AdminLoadingState v-if="!isAuthLoaded" />

    <!-- Admin Access Check -->
    <div v-else-if="!hasAdminAccess" class="admin-content">
      <div class="admin-header">
        <h1>⚠️ Admin Access Required</h1>
        <p class="admin-subtitle">You need administrator privileges to manage competencies.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- Competency Management -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>🎖️ Competency Management</h1>
          <p class="admin-subtitle">Configure coaching competencies and personalized insights</p>
        </div>
        
        <div class="header-actions">
          <ActionButton @click="addCompetency" icon="➕">Add Competency</ActionButton>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>Competencies</span>
      </nav>

      <!-- Framework Tabs -->
      <div class="framework-tabs">
        <button 
          v-for="framework in frameworks" 
          :key="framework.id"
          @click="activeFramework = framework.id"
          :class="['tab', { active: activeFramework === framework.id }]"
        >
          {{ framework.name }}
        </button>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="loading">
        Loading competencies...
      </div>

      <!-- Competencies List -->
      <div v-else-if="filteredCompetencies.length > 0">
        <AdminTableHeader :columns="competencyTableColumns">
        
        <div 
          v-for="competency in filteredCompetencies" 
          :key="competency.id"
          class="competency-row"
        >
          <div class="col-name">
            <div class="competency-info">
              <h3>{{ competency.name }}</h3>
              <p class="description">{{ competency.description }}</p>
              <div class="competency-meta">
                <span class="framework-badge" :class="competency.framework_id">
                  {{ competency.framework_id?.toUpperCase() }}
                </span>
                <span class="score-ranges-inline">
                  <span class="range-item poor">Poor: 0-{{ competency.poor_threshold || 25 }}%</span>
                  <span class="range-item developing">Dev: {{ (competency.poor_threshold || 25) + 1 }}-{{ competency.good_threshold || 75 }}%</span>
                  <span class="range-item strong">Strong: {{ (competency.good_threshold || 75) + 1 }}-100%</span>
                </span>
              </div>
            </div>
          </div>
          
          <div class="col-stats">
            <div class="stat-display">
              <span class="stat-number">{{ getQuestionCount(competency) }}</span>
            </div>
          </div>
          
          <div class="col-stats">
            <div class="stat-display">
              <span class="stat-number">{{ getInsightCount(competency) }}</span>
            </div>
          </div>
          
          <div class="col-status">
            <span class="status-badge" :class="{ active: competency.is_active }">
              {{ competency.is_active ? 'Active' : 'Inactive' }}
            </span>
          </div>
          
          <div class="col-actions">
            <div class="action-group">
              <button @click="editCompetency(competency)" class="action-btn edit" title="Edit Competency">
                <svg class="icon-svg" width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                  <path d="M12.146.146a.5.5 0 0 1 .708 0l3 3a.5.5 0 0 1 0 .708l-10 10a.5.5 0 0 1-.168.11l-5 2a.5.5 0 0 1-.65-.65l2-5a.5.5 0 0 1 .11-.168l10-10zM11.207 2.5 13.5 4.793 14.793 3.5 12.5 1.207 11.207 2.5zm1.586 3L10.5 3.207 4 9.707V10h.5a.5.5 0 0 1 .5.5v.5h.5a.5.5 0 0 1 .5.5v.5h.293l6.5-6.5zm-9.761 5.175-.106.106-1.528 3.821 3.821-1.528.106-.106A.5.5 0 0 1 5 12.5V12h-.5a.5.5 0 0 1-.5-.5V11h-.5a.5.5 0 0 1-.468-.325z"/>
                </svg>
                <span class="label">Edit</span>
              </button>
              <button @click="deleteCompetency(competency)" class="action-btn delete" title="Delete Competency">
                <svg class="icon-svg" width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                  <path d="M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0V6z"/>
                  <path fill-rule="evenodd" d="M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1v1zM4.118 4 4 4.059V13a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4H4.118zM2.5 3V2h11v1h-11z"/>
                </svg>
                <span class="label">Delete</span>
              </button>
            </div>
          </div>
        </div>
        </AdminTableHeader>
      </div>

      <!-- No Competencies -->
      <div v-else class="no-data">
        <p>No competencies found for {{ getFrameworkName(activeFramework) }}.</p>
        <p class="help-text">Use the "Add Competency" button above to create your first competency.</p>
      </div>
    </div>

    <!-- Modal removed - using dedicated page at /docs/admin/competencies/edit -->
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useAuth } from '../composables/useAuth'
import { useSupabase } from '../composables/useSupabase'
import { useAdminSession } from '../composables/useAdminSession'
import ActionButton from './shared/ActionButton.vue'
import AdminLoadingState from './shared/AdminLoadingState.vue'
import AdminTableHeader from './shared/AdminTableHeader.vue'

const { user } = useAuth()
const { supabase } = useSupabase()
const { hasAdminAccess } = useAdminSession()

// Auth state to prevent flash
const isAuthLoaded = ref(false)

// Data
const competencies = ref([])
const insights = ref([])
const questionCounts = ref({})
const loading = ref(false)
const saving = ref(false)

// UI State
const activeFramework = ref('core')
const showEditModal = ref(false)
const editingCompetency = ref({})
const editingInsights = ref({})
const activeTab = ref('basic')
const validationErrors = ref({})

// Frameworks
const frameworks = [
  { id: 'core', name: 'Core Framework' },
  { id: 'icf', name: 'ICF Framework' },
  { id: 'ac', name: 'AC Framework' }
]

// Table configuration for AdminTableHeader
const competencyTableColumns = [
  { label: 'Competency', width: '1fr' },
  { label: 'Questions', width: '80px' },
  { label: 'Insights', width: '80px' },
  { label: 'Status', width: '100px' },
  { label: 'Actions', width: '160px' }
]

// Computed
const filteredCompetencies = computed(() => {
  return competencies.value.filter(c => c.framework_id === activeFramework.value)
})

const isFormValid = computed(() => {
  return editingCompetency.value.name && 
         editingCompetency.value.description && 
         editingCompetency.value.framework_id &&
         !Object.keys(validationErrors.value).length
})

// Load data
const loadCompetencies = async () => {
  if (!supabase) return
  
  loading.value = true
  try {
    // Load competencies from competency_display_names
    const { data: competenciesData } = await supabase
      .from('competency_display_names')
      .select('*')
      .order('framework')
      .order('display_name')
    
    if (competenciesData) {
      // Map to expected structure
      competencies.value = competenciesData.map(c => ({
        id: c.id,
        name: c.display_name,
        description: c.description || '',
        framework_id: c.framework,
        competency_key: c.competency_key,
        display_order: 0,
        poor_threshold: 25,
        good_threshold: 75,
        is_active: c.is_active
      }))
    }

    // Load insights from competency_rich_insights
    const { data: insightsData } = await supabase
      .from('competency_rich_insights')
      .select('*')
    
    if (insightsData) {
      // Map to expected structure
      insights.value = insightsData.map(i => ({
        id: i.id,
        competency_id: i.competency_area,
        performance_level: i.performance_level,
        insight_text: i.primary_insight || i.key_observation || '',
        is_active: i.is_active
      }))
    }

    // Load question counts from assessment_questions
    const { data: questionData } = await supabase
      .from('assessment_questions')
      .select('competency_area')
      .not('competency_area', 'is', null)
    
    if (questionData) {
      const counts = {}
      questionData.forEach(q => {
        counts[q.competency_area] = (counts[q.competency_area] || 0) + 1
      })
      questionCounts.value = counts
    }

  } catch (error) {
    console.error('Error loading competencies:', error)
  } finally {
    loading.value = false
  }
}

// Helper functions
const getFrameworkName = (frameworkId) => {
  return frameworks.find(f => f.id === frameworkId)?.name || frameworkId
}

const getQuestionCount = (competency) => {
  const key = competency.competency_key || competency.id
  return questionCounts.value[key] || 0
}

const getInsightCount = (competency) => {
  const key = competency.competency_key || competency.id
  return insights.value.filter(i => i.competency_id === key).length
}

const getInsightText = (competency, level) => {
  const key = competency.competency_key || competency.id
  const insight = insights.value.find(i => 
    i.competency_id === key && i.performance_level === level
  )
  return insight?.insight_text || `No ${level} insight configured`
}

const truncateText = (text, length) => {
  if (!text || text.length <= length) return text
  return text.substring(0, length) + '...'
}

// Actions
const addCompetency = () => {
  window.location.href = '/docs/admin/competencies/edit'
}

const editCompetency = (competency) => {
  window.location.href = `/docs/admin/competencies/edit?id=${competency.id}`
}

const saveCompetency = async () => {
  if (!editingCompetency.value.name || !editingCompetency.value.description) {
    alert('Please fill in required fields')
    return
  }
  
  saving.value = true
  try {
    let competencyId = editingCompetency.value.id

    if (competencyId) {
      // Update existing competency
      const { error } = await supabase
        .from('competencies')
        .update({
          name: editingCompetency.value.name,
          description: editingCompetency.value.description,
          framework_id: editingCompetency.value.framework_id,
          display_order: editingCompetency.value.display_order,
          poor_threshold: editingCompetency.value.poor_threshold,
          good_threshold: editingCompetency.value.good_threshold,
          updated_at: new Date().toISOString()
        })
        .eq('id', competencyId)
      
      if (error) throw error
    } else {
      // Create new competency
      const { data, error } = await supabase
        .from('competencies')
        .insert({
          ...editingCompetency.value,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        })
        .select()
        .single()
      
      if (error) throw error
      competencyId = data.id
    }

    // Update insights
    for (const [level, text] of Object.entries(editingInsights.value)) {
      if (!text.trim()) continue

      const existingInsight = insights.value.find(i => 
        i.competency_id === competencyId && i.performance_level === level
      )

      if (existingInsight) {
        await supabase
          .from('competency_insights')
          .update({
            insight_text: text,
            updated_at: new Date().toISOString()
          })
          .eq('id', existingInsight.id)
      } else {
        await supabase
          .from('competency_insights')
          .insert({
            competency_id: competencyId,
            performance_level: level,
            insight_text: text,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
          })
      }
    }

    await loadCompetencies()
    closeModal()
    alert('Competency saved successfully!')

  } catch (error) {
    console.error('Error saving competency:', error)
    alert('Failed to save competency')
  } finally {
    saving.value = false
  }
}

const deleteCompetency = async (competency) => {
  if (!confirm(`Delete "${competency.name}"?\n\nThis will also remove all associated insights.`)) return

  try {
    // Delete insights first
    await supabase
      .from('competency_insights')
      .delete()
      .eq('competency_id', competency.id)

    // Delete competency
    const { error } = await supabase
      .from('competencies')
      .delete()
      .eq('id', competency.id)

    if (error) throw error

    await loadCompetencies()
    alert('Competency deleted successfully')

  } catch (error) {
    console.error('Error deleting competency:', error)
    alert('Failed to delete competency')
  }
}

const closeModal = () => {
  showEditModal.value = false
  editingCompetency.value = {}
  editingInsights.value = {}
  validationErrors.value = {}
  activeTab.value = 'basic'
}

// Form validation
const validateField = (field) => {
  if (field === 'name') {
    if (!editingCompetency.value.name) {
      validationErrors.value.name = 'Competency name is required'
    } else if (editingCompetency.value.name.length < 3) {
      validationErrors.value.name = 'Name must be at least 3 characters'
    } else {
      delete validationErrors.value.name
    }
  }
  
  if (field === 'description') {
    if (!editingCompetency.value.description) {
      validationErrors.value.description = 'Description is required'
    } else if (editingCompetency.value.description.length < 10) {
      validationErrors.value.description = 'Description must be at least 10 characters'
    } else if (editingCompetency.value.description.length > 500) {
      validationErrors.value.description = 'Description must not exceed 500 characters'
    } else {
      delete validationErrors.value.description
    }
  }
}

// Tab navigation
const nextTab = () => {
  if (activeTab.value === 'basic') {
    validateField('name')
    validateField('description')
    if (!validationErrors.value.name && !validationErrors.value.description) {
      activeTab.value = 'scoring'
    }
  } else if (activeTab.value === 'scoring') {
    activeTab.value = 'insights'
  }
}

const previousTab = () => {
  if (activeTab.value === 'insights') {
    activeTab.value = 'scoring'
  } else if (activeTab.value === 'scoring') {
    activeTab.value = 'basic'
  }
}

// Watch for admin access changes
watch(hasAdminAccess, (newValue) => {
  if (newValue) {
    loadCompetencies()
  }
}, { immediate: true })

onMounted(() => {
  // Set auth loaded state to prevent flash
  isAuthLoaded.value = true
  
  if (hasAdminAccess.value) {
    loadCompetencies()
  }
})
</script>

<style scoped>
/* Base Admin Container */
.admin-container {
  position: fixed;
  top: var(--vp-nav-height);
  left: 0;
  right: 0;
  bottom: 0;
  background: var(--vp-c-bg);
  overflow-y: auto;
}


.admin-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 2rem 12rem 2rem; /* Extra bottom padding for footer */
  min-height: calc(100vh - var(--vp-nav-height) - 8rem); /* Ensure minimum height */
}

/* Admin Header */
.admin-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 2rem;
  gap: 2rem;
}

.header-main h1 {
  font-size: 2rem;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.admin-subtitle {
  font-size: 1rem;
  opacity: 0.7;
  margin: 0;
  color: var(--vp-c-text-2);
}

.header-actions {
  display: flex;
  gap: 1rem;
}

/* Breadcrumb */
.breadcrumb {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 2rem;
}

.breadcrumb-separator {
  color: var(--vp-c-text-3);
  font-size: 0.9rem;
}

/* Framework Tabs */
.framework-tabs {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 2rem;
  border-bottom: 2px solid var(--vp-c-border);
}

.tab {
  padding: 0.75rem 1.5rem;
  background: none;
  border: none;
  color: var(--vp-c-text-2);
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.2s ease;
  border-bottom: 2px solid transparent;
  margin-bottom: -2px;
}

.tab:hover {
  color: var(--vp-c-text-1);
}

.tab.active {
  color: var(--vp-c-brand-1);
  border-bottom-color: var(--vp-c-brand-1);
}

.loading,
.no-data {
  text-align: center;
  padding: 3rem;
  color: var(--vp-c-text-2);
}

.help-text {
  font-size: 0.9rem;
  color: var(--vp-c-text-3);
  margin-top: 0.5rem;
}

/* Competencies List Layout */
.competencies-list {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  border-radius: 12px;
  overflow: hidden;
  margin: 1rem 0 4rem 0; /* Extra bottom margin for footer clearance */
}

.list-header {
  display: grid;
  grid-template-columns: 1fr 80px 80px 100px 160px;
  gap: 1rem;
  padding: 1rem 1.5rem;
  background: var(--vp-c-bg);
  border-bottom: 2px solid var(--vp-c-border);
  font-weight: 600;
  font-size: 0.9rem;
  color: var(--vp-c-text-1);
}

.competency-row {
  display: grid;
  grid-template-columns: 1fr 80px 80px 100px 160px;
  gap: 1rem;
  padding: 1.5rem;
  border-bottom: 1px solid var(--vp-c-border);
  align-items: center;
  transition: all 0.2s ease;
  position: relative;
}

.competency-row:hover {
  background: var(--vp-c-bg);
  box-shadow: inset 3px 0 0 var(--vp-c-brand-1);
}

.competency-row:hover .action-btn {
  opacity: 1;
}

.competency-row:last-child {
  border-bottom: none;
}

.col-name {
  min-width: 0; /* Allow text to wrap */
}

.competency-info h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
  line-height: 1.3;
}

.competency-info .description {
  margin: 0 0 0.75rem 0;
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
  line-height: 1.4;
}

.competency-meta {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.framework-badge {
  display: inline-block;
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  font-size: 0.7rem;
  font-weight: 600;
  text-transform: uppercase;
  width: fit-content;
}

.framework-badge.core { background: #e1f5fe; color: #0277bd; }
.framework-badge.icf { background: #f3e5f5; color: #7b1fa2; }
.framework-badge.ac { background: #e8f5e8; color: #2e7d32; }

.score-ranges-inline {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.range-item {
  font-size: 0.7rem;
  padding: 0.1rem 0.4rem;
  border-radius: 3px;
  white-space: nowrap;
}

.range-item.poor { background: #ffebee; color: #c62828; }
.range-item.developing { background: #fff8e1; color: #f57c00; }
.range-item.strong { background: #e8f5e8; color: #2e7d32; }

.col-stats {
  text-align: center;
}

.stat-display {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.stat-number {
  font-size: 1.2rem;
  font-weight: 600;
  color: var(--vp-c-brand-1);
}

.col-status {
  text-align: center;
}

.status-badge {
  padding: 0.3rem 0.7rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-2);
}

.status-badge.active {
  background: #e8f5e8;
  color: #2e7d32;
}

.col-actions {
  display: flex;
  justify-content: center;
  align-items: center;
}

.action-group {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

/* Action Buttons */
.action-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  padding: 0.45rem 0.75rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  font-size: 0.8rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  white-space: nowrap;
  font-family: inherit;
  opacity: 0.8;
  position: relative;
}

.icon-svg {
  width: 14px;
  height: 14px;
  flex-shrink: 0;
}

.action-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  opacity: 1;
}

.action-btn .icon {
  font-size: 0.95rem;
  display: inline-flex;
}

.action-btn .label {
  display: inline-flex;
}

/* Edit Button */
.action-btn.edit {
  background: var(--vp-c-bg);
  border-color: var(--vp-c-brand-1);
  color: var(--vp-c-brand-1);
}

.action-btn.edit:hover {
  background: var(--vp-c-brand-soft);
  border-color: var(--vp-c-brand-2);
  color: var(--vp-c-brand-2);
}

/* Delete Button */
.action-btn.delete {
  background: var(--vp-c-bg);
  border-color: var(--vp-c-text-3);
  color: var(--vp-c-text-2);
}

.action-btn.delete:hover {
  background: #fee;
  border-color: #dc2626;
  color: #dc2626;
}

/* Compact Mode - Icon Only on Desktop */
@media (min-width: 1024px) {
  .action-btn .label {
    display: none;
  }
  
  .action-btn {
    padding: 0.6rem;
    min-width: 36px;
    justify-content: center;
  }
  
  .icon-svg {
    width: 16px;
    height: 16px;
  }
  
  /* Tooltip on hover */
  .action-btn::after {
    content: attr(title);
    position: absolute;
    bottom: calc(100% + 8px);
    left: 50%;
    transform: translateX(-50%) scale(0);
    background: rgba(0, 0, 0, 0.8);
    color: white;
    padding: 0.4rem 0.6rem;
    border-radius: 4px;
    font-size: 0.75rem;
    white-space: nowrap;
    pointer-events: none;
    transition: transform 0.2s ease;
    z-index: 10;
  }
  
  .action-btn:hover::after {
    transform: translateX(-50%) scale(1);
  }
}

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: calc(var(--vp-nav-height) + 2rem);
  left: 0;
  right: 0;
  bottom: 8rem; /* Consistent footer clearance */
  background: rgba(0, 0, 0, 0.75);
  z-index: 1000;
  display: flex;
  align-items: flex-start;
  justify-content: center;
  padding: 2rem;
  backdrop-filter: blur(6px);
  overflow-y: auto;
}

.modal {
  background: var(--vp-c-bg);
  border-radius: 16px;
  max-width: 1200px; /* Wider for desktop */
  width: 100%;
  max-height: 100%; /* Use full available height */
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  box-shadow: 0 24px 64px rgba(0, 0, 0, 0.35);
  border: 1px solid var(--vp-c-border);
  position: relative;
}

/* Modal Header */
.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem 3rem; /* Optimized height */
  border-bottom: 2px solid var(--vp-c-divider);
  background: var(--vp-c-bg-soft);
  border-radius: 16px 16px 0 0;
  flex-shrink: 0;
}

.modal-title {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.modal-icon {
  font-size: 1.5rem;
}

.modal-title h2 {
  margin: 0;
  font-size: 1.4rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.btn-close {
  background: transparent;
  border: none;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 8px;
  transition: all 0.2s ease;
  color: var(--vp-c-text-2);
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-close:hover {
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-1);
}

/* Modal Body */
.modal-body {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  min-height: 0; /* Important for flex children scrolling */
}

/* Progress Indicator */
.form-progress {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1.25rem 3rem; /* More compact */
  background: var(--vp-c-bg-soft);
  border-bottom: 1px solid var(--vp-c-border);
  flex-shrink: 0;
  gap: 2.5rem; /* Wider spacing for progress steps */
}

.progress-step {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  transition: all 0.2s ease;
  opacity: 0.5;
}

.progress-step.active {
  opacity: 1;
}

.step-number {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: var(--vp-c-bg);
  border: 2px solid var(--vp-c-border);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  font-size: 0.9rem;
  transition: all 0.2s ease;
}

.progress-step.active .step-number {
  background: var(--vp-c-brand-1);
  color: white;
  border-color: var(--vp-c-brand-1);
}

.step-label {
  font-size: 0.85rem;
  font-weight: 500;
  color: var(--vp-c-text-2);
}

.progress-step.active .step-label {
  color: var(--vp-c-text-1);
}

.progress-line {
  width: 60px;
  height: 2px;
  background: var(--vp-c-border);
  margin: 0 0.5rem;
  margin-bottom: 1.5rem;
}

/* Modal Content */
.modal-content {
  flex: 1;
  overflow-y: auto;
  padding: 2rem 3rem; /* Balanced spacing */
}

.tab-content {
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.form-section {
  max-width: 700px;
  margin: 0 auto;
}

.section-title {
  font-size: 1.2rem;
  font-weight: 600;
  margin: 0 0 0.25rem 0;
  color: var(--vp-c-text-1);
}

.section-description {
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
  margin: 0 0 1.25rem 0;
}

/* Form Elements */
.form-group {
  margin-bottom: 1.75rem; /* Optimized spacing */
}

/* Advanced Form Layouts for Desktop */
.section-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 2rem;
}

.section-subtitle {
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
  margin: 0.5rem 0 0 0;
  line-height: 1.4;
}

.form-grid-wide {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 3rem;
  align-items: flex-start;
  margin-bottom: 2rem;
}

.form-group.main-field {
  margin-bottom: 0;
}

.form-group-compact {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
}

.form-group-compact .form-group {
  margin-bottom: 0;
}

.input-field.compact {
  padding: 0.75rem 1rem;
}

.description-field {
  grid-column: 1 / -1;
  margin-top: 1rem;
}

.helper-text {
  font-size: 0.8rem;
  color: var(--vp-c-text-3);
  margin-left: 0.5rem;
}

.field-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 0.5rem;
}

.char-count {
  font-size: 0.8rem;
  color: var(--vp-c-text-3);
}

.error-message {
  color: var(--vp-c-danger-1);
  font-size: 0.85rem;
}

.form-group label {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
  font-size: 0.9rem;
}

.label-text {
  flex: 1;
}

.required {
  color: #dc2626;
  font-size: 1rem;
}

.info-icon {
  cursor: help;
  font-size: 0.85rem;
  opacity: 0.6;
}

.form-group input,
.form-group textarea,
.form-group select {
  width: 100%;
  padding: 0.625rem 0.875rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  font-size: 0.95rem;
  transition: all 0.2s ease;
  font-family: inherit;
}

.form-group input:focus,
.form-group textarea:focus,
.form-group select:focus {
  outline: none;
  border-color: var(--vp-c-brand-1);
  background: var(--vp-c-bg-soft);
}

.form-group input.has-error,
.form-group textarea.has-error {
  border-color: #dc2626;
}

.error-message {
  display: block;
  margin-top: 0.5rem;
  color: #dc2626;
  font-size: 0.85rem;
}

.char-count {
  display: block;
  text-align: right;
  margin-top: 0.25rem;
  font-size: 0.75rem;
  color: var(--vp-c-text-3);
}

.form-group textarea {
  resize: vertical;
  min-height: 80px;
}

.form-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
}

/* Select Wrapper */
.select-wrapper {
  position: relative;
}

.select-wrapper select {
  appearance: none;
  padding-right: 2.5rem;
}

.select-icon {
  position: absolute;
  right: 1rem;
  top: 50%;
  transform: translateY(-50%);
  pointer-events: none;
  color: var(--vp-c-text-2);
}

/* Toggle Switch */
.toggle-wrapper {
  display: flex;
  align-items: center;
}

.toggle-input {
  display: none;
}

.toggle-label {
  position: relative;
  display: flex;
  align-items: center;
  cursor: pointer;
  user-select: none;
}

.toggle-slider {
  width: 48px;
  height: 24px;
  background: var(--vp-c-border);
  border-radius: 12px;
  transition: background 0.3s ease;
  margin-right: 0.75rem;
  position: relative;
}

.toggle-slider::after {
  content: '';
  position: absolute;
  width: 20px;
  height: 20px;
  background: white;
  border-radius: 50%;
  top: 2px;
  left: 2px;
  transition: transform 0.3s ease;
}

.toggle-input:checked + .toggle-label .toggle-slider {
  background: var(--vp-c-brand-1);
}

.toggle-input:checked + .toggle-label .toggle-slider::after {
  transform: translateX(24px);
}

.toggle-text {
  font-size: 0.9rem;
  font-weight: 500;
}

/* Input with Unit */
.input-with-unit {
  position: relative;
  display: flex;
  align-items: center;
}

.input-with-unit input {
  padding-right: 3rem;
}

.input-with-unit .unit {
  position: absolute;
  right: 1rem;
  color: var(--vp-c-text-2);
  font-weight: 500;
}

/* Threshold Visual */
.threshold-visual {
  margin: 2rem 0;
  padding: 1.5rem;
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
  border: 1px solid var(--vp-c-border);
}

.threshold-bar {
  display: flex;
  height: 60px;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.threshold-segment {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 500;
  position: relative;
  transition: all 0.3s ease;
}

.threshold-segment.poor {
  background: linear-gradient(135deg, #ef4444, #dc2626);
}

.threshold-segment.developing {
  background: linear-gradient(135deg, #f59e0b, #d97706);
}

.threshold-segment.strong {
  background: linear-gradient(135deg, #10b981, #059669);
}

.threshold-label {
  font-size: 0.75rem;
  text-transform: uppercase;
  opacity: 0.9;
}

.threshold-value {
  font-size: 0.95rem;
  font-weight: 600;
}

/* Insight Groups */
/* Insights Layout Optimization */
.insights-grid-layout {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2.5rem;
  align-items: flex-start;
}

.insights-column {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.insight-group {
  margin-bottom: 0;
  padding: 1.5rem;
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
  border: 2px solid var(--vp-c-border);
}

.insight-textarea {
  width: 100%;
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  padding: 0.75rem;
  background: var(--vp-c-bg);
  font-family: inherit;
  font-size: 0.95rem;
  line-height: 1.5;
  resize: vertical;
  min-height: 80px;
}

.insight-footer {
  display: flex;
  justify-content: flex-end;
  margin-top: 0.5rem;
}

.insight-tips-box {
  background: linear-gradient(135deg, var(--vp-c-brand-soft) 0%, var(--vp-c-bg-soft) 100%);
  border: 1px solid var(--vp-c-brand-1);
  border-radius: 12px;
  padding: 1.5rem;
  margin-top: 0.5rem;
}

.insight-tips-box h4 {
  margin: 0 0 1rem 0;
  font-size: 1rem;
  color: var(--vp-c-text-1);
}

.tips-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.tips-list li {
  padding: 0.4rem 0;
  font-size: 0.85rem;
  line-height: 1.4;
  color: var(--vp-c-text-2);
}

.insights-tips {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.85rem;
  color: var(--vp-c-text-3);
}

.tip-icon {
  font-size: 1rem;
}

.preview-label {
  font-size: 0.8rem;
  color: var(--vp-c-brand-1);
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

/* Threshold Section Optimization */
.threshold-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2rem;
  margin-bottom: 2rem;
}

.threshold-input-group {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.threshold-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  font-size: 0.9rem;
}

.threshold-color {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  flex-shrink: 0;
}

.poor-label .threshold-color {
  background: #dc2626;
}

.developing-label .threshold-color {
  background: #f59e0b;
}

.excellent-label .threshold-color {
  background: #059669;
}

.threshold-input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.threshold-input {
  padding-right: 2rem;
  text-align: center;
  font-weight: 600;
}

.input-suffix {
  position: absolute;
  right: 0.75rem;
  color: var(--vp-c-text-3);
  font-size: 0.9rem;
  pointer-events: none;
}

.range-display {
  font-size: 0.8rem;
  color: var(--vp-c-text-2);
  text-align: center;
  background: var(--vp-c-bg);
  padding: 0.5rem;
  border-radius: 4px;
  border: 1px solid var(--vp-c-border);
}

.insight-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.insight-icon {
  font-size: 1.25rem;
}

.insight-header label {
  margin: 0;
  font-size: 1rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.insight-group textarea {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-border);
}

.poor-insight {
  border-left: 3px solid #dc2626;
}

.developing-insight {
  border-left: 3px solid #f59e0b;
}

.strong-insight {
  border-left: 3px solid #10b981;
}

/* Modal Footer */
.modal-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.25rem 3rem; /* More compact footer */
  border-top: 2px solid var(--vp-c-divider);
  background: var(--vp-c-bg-soft);
  border-radius: 0 0 16px 16px;
  flex-shrink: 0;
  margin-top: auto;
}

.footer-left,
.footer-right {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.btn-nav,
.btn-next,
.btn-save,
.btn-cancel {
  padding: 0.75rem 1.5rem; /* More compact buttons */
  border-radius: 8px;
  font-size: 0.95rem;
  font-weight: 600;
  cursor: pointer;
  border: none;
  transition: all 0.2s ease;
  font-family: inherit;
  min-height: 40px; /* Smaller consistent height */
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.btn-nav {
  background: transparent;
  color: var(--vp-c-text-2);
  border: 1px solid var(--vp-c-border);
}

.btn-nav:hover {
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-1);
}

.btn-next {
  background: var(--vp-c-brand-1);
  color: white;
}

.btn-next:hover {
  background: var(--vp-c-brand-2);
  transform: translateX(2px);
}

.btn-save {
  background: var(--vp-c-brand-1);
  color: white;
  min-width: 140px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.btn-save:hover:not(:disabled) {
  background: var(--vp-c-brand-2);
  transform: translateY(-1px);
}

.btn-save:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-cancel {
  background: transparent;
  color: var(--vp-c-text-1);
  border: 1px solid var(--vp-c-border);
}

.btn-cancel:hover {
  background: var(--vp-c-bg-mute);
  border-color: var(--vp-c-text-3);
}

/* Spinner */
.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Framework Tabs and other specific styles remain unchanged */

/* Responsive Design */
@media (max-width: 768px) {
  .admin-content {
    padding: 1rem 1rem 10rem 1rem; /* Increased bottom padding on mobile */
  }
  
  .admin-header {
    flex-direction: column;
    gap: 1rem;
  }
  
  .framework-tabs {
    flex-wrap: wrap;
    gap: 0.5rem;
  }
  
  .list-header,
  .competency-row {
    grid-template-columns: 1fr 60px 60px 80px 120px;
    gap: 0.5rem;
    padding: 1rem;
    font-size: 0.9rem;
  }
  
  .competency-info h3 {
    font-size: 1rem;
  }
  
  .competency-info .description {
    font-size: 0.85rem;
  }
  
  .score-ranges-inline {
    flex-direction: column;
    gap: 0.25rem;
  }
  
  .range-item {
    font-size: 0.65rem;
  }
  
  .framework-badge {
    font-size: 0.6rem;
  }
  
  .col-actions {
    flex-direction: row;
    gap: 0.3rem;
  }
  
  .action-btn {
    padding: 0.4rem;
    font-size: 0.75rem;
  }
  
  .action-btn .label {
    display: none;
  }
  
  .action-btn .icon {
    font-size: 0.9rem;
  }
  
  .modal-overlay {
    padding: 1rem;
    top: var(--vp-nav-height);
    align-items: flex-start;
  }
  
  .modal {
    margin: 1rem auto;
    max-height: calc(100vh - var(--vp-nav-height) - 2rem);
    width: calc(100% - 2rem);
  }
  
  .modal-header {
    padding: 1.25rem;
  }
  
  .modal-content {
    padding: 1.25rem;
  }
  
  .form-progress {
    padding: 1rem;
    flex-wrap: wrap;
  }
  
  .progress-line {
    width: 30px;
    margin: 0 0.25rem;
  }
  
  .step-label {
    font-size: 0.75rem;
  }
  
  .form-row {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .modal-footer {
    padding: 1rem 1.25rem;
    flex-direction: column;
    gap: 1rem;
  }
  
  .footer-left,
  .footer-right {
    width: 100%;
    justify-content: center;
  }
  
  .footer-right {
    flex-direction: column-reverse;
  }
  
  .btn-nav,
  .btn-next,
  .btn-save,
  .btn-cancel {
    width: 100%;
    justify-content: center;
  }
}
</style>