<template>
  <div class="admin-container">
    <!-- Loading state during auth check -->
    <AdminLoadingState v-if="!isAuthLoaded" />

    <!-- Admin Access Check -->
    <div v-else-if="!hasAdminAccess" class="admin-content">
      <div class="admin-header">
        <h1>⚠️ Admin Access Required</h1>
        <p class="admin-subtitle">You need administrator privileges to manage assessments.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- Assessment Management -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>🎯 Assessment Management</h1>
          <p class="admin-subtitle">Configure and manage all assessment variations</p>
        </div>
        
        <div class="header-actions">
          <ActionButton @click="createNew" icon="➕">Create New Assessment</ActionButton>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>Assessments</span>
      </nav>

      <!-- Filter Controls -->
      <div class="filter-controls">
        <select v-model="selectedFramework" @change="filterAssessments">
          <option value="">All Frameworks</option>
          <option value="core">Core Framework</option>
          <option value="icf">ICF Framework</option>
          <option value="ac">AC Framework</option>
        </select>
        
        <select v-model="selectedLevel" @change="filterAssessments">
          <option value="">All Levels</option>
          <option value="beginner">Beginner</option>
          <option value="intermediate">Intermediate</option>
          <option value="advanced">Advanced</option>
        </select>
        
        <select v-model="selectedStatus" @change="filterAssessments">
          <option value="">All Status</option>
          <option value="active">Active</option>
          <option value="draft">Draft</option>
          <option value="archived">Archived</option>
        </select>
      </div>

      <!-- Assessment List -->
      <div v-if="loading" class="loading">
        Loading assessments...
      </div>

      <div v-else-if="filteredAssessments.length === 0" class="no-data">
        <p>No assessments found matching your filters.</p>
      </div>

      <AdminTableHeader :columns="assessmentTableColumns">
        <div v-for="assessment in filteredAssessments" :key="assessment.id" class="list-item" @click="editAssessment(assessment)">
          <div class="col-title">
            <div class="assessment-info">
              <h3 class="assessment-title">{{ assessment.title }}</h3>
              <p class="assessment-description">{{ truncateText(assessment.description, 60) }}</p>
            </div>
          </div>
          <div class="col-framework">
            <span class="framework-badge" :class="`framework-${assessment.framework_id}`">
              {{ assessment.framework_id?.toUpperCase() }}
            </span>
          </div>
          <div class="col-level">
            <span class="level-badge" :class="`level-${assessment.difficulty}`">
              {{ assessment.difficulty }}
            </span>
          </div>
          <div class="col-questions">
            <span class="stat-value">{{ assessment.question_count || 0 }}</span>
          </div>
          <div class="col-completions">
            <span class="stat-value">{{ assessment.completion_count || 0 }}</span>
          </div>
          <div class="col-avg-score">
            <span class="stat-value">{{ assessment.avg_score || 'N/A' }}{{ assessment.avg_score ? '%' : '' }}</span>
          </div>
          <div class="col-status">
            <span class="status-badge" :class="`status-${assessment.status || 'active'}`">
              {{ assessment.status || 'active' }}
            </span>
          </div>
          <div class="col-actions">
            <button @click.stop="editAssessment(assessment)" class="action-btn edit" title="Edit Assessment">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
              </svg>
            </button>
            <button @click.stop="duplicateAssessment(assessment)" class="action-btn duplicate" title="Duplicate Assessment">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
                <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
              </svg>
            </button>
            <button @click.stop="toggleStatus(assessment)" class="action-btn status" :title="assessment.status === 'active' ? 'Deactivate Assessment' : 'Activate Assessment'">
              <svg v-if="assessment.status === 'active'" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="6" y="4" width="4" height="16"></rect>
                <rect x="14" y="4" width="4" height="16"></rect>
              </svg>
              <svg v-else width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polygon points="5 3 19 12 5 21 5 3"></polygon>
              </svg>
            </button>
          </div>
        </div>
      </AdminTableHeader>
    </div>
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
const assessments = ref([])
const filteredAssessments = ref([])
const loading = ref(false)

// Filters
const selectedFramework = ref('')
const selectedLevel = ref('')
const selectedStatus = ref('')

// Table configuration for AdminTableHeader
const assessmentTableColumns = [
  { label: 'Assessment', width: '2.5fr' },
  { label: 'Framework', width: '1fr' },
  { label: 'Level', width: '1fr' },
  { label: 'Questions', width: '0.8fr' },
  { label: 'Completions', width: '0.8fr' },
  { label: 'Avg Score', width: '0.8fr' },
  { label: 'Status', width: '0.8fr' },
  { label: 'Actions', width: '1fr' }
]

// Load assessments
const loadAssessments = async () => {
  if (!supabase || !hasAdminAccess.value) return
  
  loading.value = true
  try {
    // Get assessments first
    const { data, error } = await supabase
      .from('assessments')
      .select('*')
      .order('framework', { ascending: true })
      .order('difficulty', { ascending: true })

    if (error) {
      console.error('Error loading assessments:', error)
      return
    }

    if (data) {
      // Get question counts separately
      const assessmentIds = data.map(a => a.id)
      
      // Get question counts
      const { data: questionCounts } = await supabase
        .from('assessment_questions')
        .select('assessment_id')
        .in('assessment_id', assessmentIds)
      
      // Get completion stats
      const { data: completionStats } = await supabase
        .from('user_assessment_attempts')
        .select('assessment_id, status, score')
        .in('assessment_id', assessmentIds)
        .eq('status', 'completed')
      
      // Process assessments with calculated stats
      assessments.value = data.map(assessment => {
        const questionCount = questionCounts?.filter(q => q.assessment_id === assessment.id).length || 0
        const attempts = completionStats?.filter(a => a.assessment_id === assessment.id) || []
        const avgScore = attempts.length > 0 
          ? Math.round(attempts.reduce((sum, a) => sum + (a.score || 0), 0) / attempts.length)
          : null

        return {
          ...assessment,
          question_count: questionCount,
          completion_count: attempts.length,
          avg_score: avgScore
        }
      })
    }
    
    filteredAssessments.value = assessments.value
  } catch (error) {
    console.error('Error loading assessments:', error)
  } finally {
    loading.value = false
  }
}

// Filter assessments
const filterAssessments = () => {
  filteredAssessments.value = assessments.value.filter(assessment => {
    if (selectedFramework.value && assessment.framework_id !== selectedFramework.value) return false
    if (selectedLevel.value && assessment.difficulty !== selectedLevel.value) return false
    if (selectedStatus.value && (assessment.status || 'active') !== selectedStatus.value) return false
    return true
  })
}

// Helper functions
const truncateText = (text, length) => {
  if (!text) return ''
  if (text.length <= length) return text
  return text.substring(0, length) + '...'
}

// Actions
const editAssessment = (assessment) => {
  window.location.href = `/docs/admin/assessments/edit?id=${assessment.id}`
}

const createNew = () => {
  window.location.href = '/docs/admin/assessments/create'
}

const duplicateAssessment = async (assessment) => {
  if (!confirm(`Duplicate "${assessment.title}"?`)) return
  
  try {
    // Create copy of assessment
    const newAssessment = {
      ...assessment,
      title: `${assessment.title} (Copy)`,
      status: 'draft',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }
    
    delete newAssessment.id
    delete newAssessment.questions
    delete newAssessment.user_assessments
    delete newAssessment.question_count
    delete newAssessment.completion_count
    delete newAssessment.avg_score
    
    const { data, error } = await supabase
      .from('assessments')
      .insert(newAssessment)
      .select()
      .single()
    
    if (error) {
      console.error('Error duplicating assessment:', error)
      alert('Failed to duplicate assessment')
      return
    }
    
    // Reload assessments
    await loadAssessments()
    alert(`Assessment duplicated successfully! Created "${data.title}"`)
  } catch (error) {
    console.error('Error duplicating assessment:', error)
    alert('Failed to duplicate assessment')
  }
}

const toggleStatus = async (assessment) => {
  const newStatus = assessment.status === 'active' ? 'archived' : 'active'
  
  if (!confirm(`${newStatus === 'active' ? 'Activate' : 'Deactivate'} "${assessment.title}"?`)) return
  
  try {
    const { error } = await supabase
      .from('assessments')
      .update({ status: newStatus })
      .eq('id', assessment.id)
    
    if (error) {
      console.error('Error updating assessment status:', error)
      alert('Failed to update assessment status')
      return
    }
    
    // Update local data
    assessment.status = newStatus
    filterAssessments()
  } catch (error) {
    console.error('Error updating assessment status:', error)
    alert('Failed to update assessment status')
  }
}

// Watch for admin access changes
watch(hasAdminAccess, (newValue) => {
  if (newValue) {
    loadAssessments()
  }
}, { immediate: true })

onMounted(() => {
  // Set auth loaded state to prevent flash
  isAuthLoaded.value = true
  
  if (hasAdminAccess.value) {
    loadAssessments()
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

/* Filter Controls */
.filter-controls {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  flex-wrap: wrap;
}

.filter-controls select {
  padding: 0.5rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 4px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
}

/* Assessment List */
.loading {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  color: var(--vp-c-text-2);
}

.no-data {
  text-align: center;
  padding: 3rem;
  color: var(--vp-c-text-2);
}

.list-item {
  display: grid;
  grid-template-columns: 2.5fr 1fr 1fr 0.8fr 0.8fr 0.8fr 0.8fr 1fr;
  gap: 1rem;
  padding: 1.5rem;
  border-bottom: 1px solid var(--vp-c-border);
  align-items: center;
  cursor: pointer;
  transition: all 0.2s ease;
}

.list-item:hover {
  background: var(--vp-c-bg);
  box-shadow: inset 3px 0 0 var(--vp-c-brand-1);
}

.list-item:last-child {
  border-bottom: none;
}

.assessment-info {
  min-width: 0;
}

.assessment-title {
  margin: 0 0 0.25rem 0;
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
  line-height: 1.3;
}

.assessment-description {
  margin: 0;
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
  line-height: 1.3;
}

.framework-badge {
  padding: 0.2rem 0.6rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  display: inline-block;
}

.framework-core {
  background: #e0f2fe;
  color: #0369a1;
}

.framework-icf {
  background: #f0fdf4;
  color: #15803d;
}

.framework-ac {
  background: #fef3c7;
  color: #a16207;
}

.level-badge {
  padding: 0.2rem 0.6rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: capitalize;
  display: inline-block;
}

.level-beginner {
  background: #dbeafe;
  color: #1e40af;
}

.level-intermediate {
  background: #fed7aa;
  color: #c2410c;
}

.level-advanced {
  background: #fecaca;
  color: #dc2626;
}

.stat-value {
  font-weight: 600;
  color: var(--vp-c-brand-1);
  font-size: 0.95rem;
}

.status-badge {
  padding: 0.2rem 0.6rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: capitalize;
  display: inline-block;
}

.status-active {
  background: #bbf7d0;
  color: #15803d;
}

.status-draft {
  background: #e9d5ff;
  color: #7c3aed;
}

.status-archived {
  background: #e5e7eb;
  color: #6b7280;
}

.col-actions {
  display: flex;
  gap: 0.5rem;
  justify-content: flex-start;
}

.action-btn {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  padding: 0.4rem;
  cursor: pointer;
  color: var(--vp-c-text-2);
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
}

.action-btn:hover {
  border-color: var(--vp-c-brand-1);
  color: var(--vp-c-brand-1);
  transform: translateY(-1px);
}

.action-btn.edit:hover {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
}

.action-btn.duplicate:hover {
  background: var(--vp-c-indigo-soft);
  color: var(--vp-c-indigo-1);
}

.action-btn.status:hover {
  background: var(--vp-c-warning-soft);
  color: var(--vp-c-warning-1);
  border-color: var(--vp-c-warning-1);
}

.action-btn svg {
  width: 16px;
  height: 16px;
}

.action-btn::after {
  content: attr(title);
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  white-space: nowrap;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.2s ease;
  border: 1px solid var(--vp-c-border);
  margin-bottom: 0.25rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.action-btn:hover::after {
  opacity: 1;
}

/* Responsive Design */
@media (max-width: 1024px) {
  .list-header,
  .list-item {
    grid-template-columns: 2fr 0.8fr 0.8fr 0.6fr 0.6fr 0.6fr 0.7fr 0.9fr;
    font-size: 0.85rem;
  }
  
  .assessment-title {
    font-size: 1rem;
  }
}

@media (max-width: 768px) {
  .admin-content {
    padding: 1rem 1rem 10rem 1rem;
  }
  
  .admin-header {
    flex-direction: column;
    gap: 1rem;
  }
  
  .filter-controls {
    flex-direction: column;
  }
  
  .list-header {
    display: none;
  }
  
  .list-item {
    grid-template-columns: 1fr;
    gap: 0.75rem;
    padding: 1rem;
  }
  
  .list-item > div {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  .list-item > div::before {
    content: attr(data-label);
    font-weight: 600;
    font-size: 0.8rem;
    color: var(--vp-c-text-3);
    text-transform: uppercase;
  }
  
  .col-title::before { content: 'Assessment'; }
  .col-framework::before { content: 'Framework'; }
  .col-level::before { content: 'Level'; }
  .col-questions::before { content: 'Questions'; }
  .col-completions::before { content: 'Completions'; }
  .col-avg-score::before { content: 'Avg Score'; }
  .col-status::before { content: 'Status'; }
  .col-actions::before { content: 'Actions'; }
  
  .col-title {
    flex-direction: column;
    align-items: flex-start !important;
  }
  
  .assessment-info {
    margin-top: 0.5rem;
  }
}
</style>