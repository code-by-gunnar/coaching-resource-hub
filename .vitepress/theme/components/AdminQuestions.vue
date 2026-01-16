<template>
  <div class="admin-container">
    <!-- Loading state during auth check -->
    <AdminLoadingState v-if="!isAuthLoaded" />

    <!-- Admin Access Check -->
    <div v-else-if="!hasAdminAccess" class="admin-content">
      <div class="admin-header">
        <h1>⚠️ Admin Access Required</h1>
        <p class="admin-subtitle">You need administrator privileges to manage questions.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- Question Bank -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>❓ Question Bank</h1>
          <p class="admin-subtitle">Central repository of all assessment questions</p>
        </div>
        
        <div class="header-actions">
          <ActionButton @click="exportQuestions" variant="secondary" icon="📥">Export CSV</ActionButton>
          <ActionButton @click="importQuestions" variant="secondary" icon="📤">Import</ActionButton>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>Question Bank</span>
      </nav>

      <!-- Filters -->
      <div class="filter-bar">
        <input 
          v-model="searchQuery" 
          type="text" 
          placeholder="Search questions..."
          class="search-input"
        />
        
        <select v-model="filterAssessment" @change="filterQuestions">
          <option value="">All Assessments</option>
          <option 
            v-for="assessment in assessments" 
            :key="assessment.id"
            :value="assessment.id"
          >
            {{ assessment.title }}
          </option>
        </select>
        
        <select v-model="filterCompetency" @change="filterQuestions">
          <option value="">All Competencies</option>
          <option 
            v-for="comp in competencies" 
            :key="comp.id"
            :value="comp.id"
          >
            {{ comp.name }}
          </option>
        </select>
        
        <select v-model="filterCategory" @change="filterQuestions">
          <option value="">All Categories</option>
          <option 
            v-for="cat in categories" 
            :key="cat"
            :value="cat"
          >
            {{ cat }}
          </option>
        </select>
      </div>

      <!-- Stats Bar -->
      <div class="stats-bar">
        <div class="stat">
          <span class="stat-value">{{ filteredQuestions.length }}</span>
          <span class="stat-label">Questions</span>
        </div>
        <div class="stat">
          <span class="stat-value">{{ assessments.length }}</span>
          <span class="stat-label">Assessments</span>
        </div>
        <div class="stat">
          <span class="stat-value">{{ uniqueCompetencies }}</span>
          <span class="stat-label">Competencies</span>
        </div>
        <div class="stat">
          <span class="stat-value">{{ averageOptions }}</span>
          <span class="stat-label">Avg Options</span>
        </div>
      </div>

      <!-- Questions List -->
      <div v-if="loading" class="loading">
        Loading questions...
      </div>

      <div v-else-if="filteredQuestions.length === 0" class="no-data">
        <p>No questions found matching your filters.</p>
      </div>

      <div v-else class="questions-list">
        <div class="list-header">
          <div class="col-question" @click="sortBy('question_text')">
            Question
            <span class="sort-indicator" v-if="sortField === 'question_text'">
              {{ sortOrder === 'asc' ? '↑' : '↓' }}
            </span>
          </div>
          <div class="col-assessment" @click="sortBy('assessment_title')">
            Assessment
            <span class="sort-indicator" v-if="sortField === 'assessment_title'">
              {{ sortOrder === 'asc' ? '↑' : '↓' }}
            </span>
          </div>
          <div class="col-competency" @click="sortBy('competency_name')">
            Competency
            <span class="sort-indicator" v-if="sortField === 'competency_name'">
              {{ sortOrder === 'asc' ? '↑' : '↓' }}
            </span>
          </div>
          <div class="col-level" @click="sortBy('category')">
            Level
            <span class="sort-indicator" v-if="sortField === 'category'">
              {{ sortOrder === 'asc' ? '↑' : '↓' }}
            </span>
          </div>
          <div class="col-options">Options</div>
          <div class="col-status" @click="sortBy('is_active')">
            Status
            <span class="sort-indicator" v-if="sortField === 'is_active'">
              {{ sortOrder === 'asc' ? '↑' : '↓' }}
            </span>
          </div>
          <div class="col-actions">Actions</div>
        </div>
        
        <div class="list-items">
          <div v-for="question in paginatedQuestions" :key="question.id" class="list-item">
            <div class="col-question">
              <div class="question-content">
                <span class="question-text" :title="question.question_text">
                  {{ truncateText(question.question_text, 100) }}
                </span>
              </div>
            </div>
            <div class="col-assessment">
              <span class="assessment-badge" :class="`assessment-${question.assessments?.framework?.toLowerCase()}`">
                {{ question.assessment_title }}
              </span>
            </div>
            <div class="col-competency">
              <span class="competency-text">{{ question.competency_area || '-' }}</span>
            </div>
            <div class="col-level">
              <span class="level-badge" :class="`level-${question.assessment_level?.toLowerCase()}`">
                {{ question.assessment_level || '-' }}
              </span>
            </div>
            <div class="col-options">
              <span class="options-count">{{ question.options?.length || 0 }}</span>
            </div>
            <div class="col-status">
              <button 
                class="status-badge" 
                :class="{ 'active': question.is_active !== false, 'inactive': question.is_active === false }"
                @click="toggleQuestionStatus(question)"
                :title="`Click to ${question.is_active !== false ? 'deactivate' : 'activate'} this question`"
              >
                {{ question.is_active !== false ? 'Active' : 'Inactive' }}
              </button>
            </div>
            <div class="col-actions">
              <button @click="editQuestion(question)" class="action-btn edit" title="Edit Question">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                  <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                </svg>
              </button>
              <button @click="duplicateQuestion(question)" class="action-btn duplicate" title="Duplicate Question">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
                  <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
                </svg>
              </button>
              <button @click="deleteQuestion(question)" class="action-btn delete" title="Delete Question">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <polyline points="3 6 5 6 21 6"></polyline>
                  <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                  <line x1="10" y1="11" x2="10" y2="17"></line>
                  <line x1="14" y1="11" x2="14" y2="17"></line>
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Pagination -->
      <div v-if="totalPages > 1" class="pagination">
        <button 
          @click="currentPage--" 
          :disabled="currentPage === 1"
          class="page-btn"
        >
          ← Previous
        </button>
        <span class="page-info">
          Page {{ currentPage }} of {{ totalPages }}
        </span>
        <button 
          @click="currentPage++" 
          :disabled="currentPage === totalPages"
          class="page-btn"
        >
          Next →
        </button>
      </div>
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

const { user } = useAuth()
const { supabase } = useSupabase()
const { hasAdminAccess } = useAdminSession()

// Authentication loading state
const isAuthLoaded = ref(false)

// Data
const questions = ref([])
const filteredQuestions = ref([])
const assessments = ref([])
const competencies = ref([])
const categories = ref([])
const loading = ref(false)

// Filters
const searchQuery = ref('')
const filterAssessment = ref('')
const filterCompetency = ref('')
const filterCategory = ref('')

// Pagination
const currentPage = ref(1)
const itemsPerPage = 20

// Sorting
const sortField = ref('question_text')
const sortOrder = ref('asc')

// Computed
const paginatedQuestions = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return filteredQuestions.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(filteredQuestions.value.length / itemsPerPage)
})

const uniqueCompetencies = computed(() => {
  const unique = new Set(questions.value.map(q => q.competency_id).filter(Boolean))
  return unique.size
})

const averageOptions = computed(() => {
  if (questions.value.length === 0) return 0
  const total = questions.value.reduce((sum, q) => sum + (q.options?.length || 0), 0)
  return Math.round(total / questions.value.length)
})

// Load data
const loadQuestions = async () => {
  if (!supabase || !hasAdminAccess.value) return
  
  loading.value = true
  try {
    // Load questions with assessment info from assessment_questions
    const { data: questionsData, error } = await supabase
      .from('assessment_questions')
      .select(`
        *,
        assessments (
          id,
          title,
          framework,
          difficulty
        )
      `)
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Error loading questions:', error)
      return
    }

    // Process questions
    questions.value = questionsData.map(q => ({
      ...q,
      question_text: q.question,
      options: [q.option_a, q.option_b, q.option_c, q.option_d],
      assessment_title: q.assessments?.title || 'Unknown',
      competency_name: q.competency_area || null,
      category: q.assessment_level
    }))

    // Extract unique categories from assessment_level
    const uniqueCategories = [...new Set(questions.value.map(q => q.assessment_level).filter(Boolean))]
    categories.value = uniqueCategories.sort()

    // Load assessments for filter
    const { data: assessmentsData } = await supabase
      .from('assessments')
      .select('id, title')
      .order('title')
    
    if (assessmentsData) {
      assessments.value = assessmentsData
    }

    // Load competencies from competency_display_names
    const { data: competenciesData } = await supabase
      .from('competency_display_names')
      .select('competency_key, display_name, framework')
      .order('display_name')
    
    if (competenciesData) {
      competencies.value = competenciesData.map(c => ({
        id: c.competency_key,
        name: c.display_name
      }))
    }

    filterQuestions()
  } catch (error) {
    console.error('Error loading questions:', error)
  } finally {
    loading.value = false
  }
}

// Filter questions
const filterQuestions = () => {
  let filtered = [...questions.value]

  // Search filter
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(q => 
      q.question_text.toLowerCase().includes(query) ||
      q.category?.toLowerCase().includes(query) ||
      q.assessment_title.toLowerCase().includes(query)
    )
  }

  // Assessment filter
  if (filterAssessment.value) {
    filtered = filtered.filter(q => q.assessment_id === filterAssessment.value)
  }

  // Competency filter
  if (filterCompetency.value) {
    filtered = filtered.filter(q => q.competency_area === filterCompetency.value)
  }

  // Category filter
  if (filterCategory.value) {
    filtered = filtered.filter(q => q.assessment_level === filterCategory.value)
  }

  // Apply sorting
  filtered.sort((a, b) => {
    const aVal = a[sortField.value] || ''
    const bVal = b[sortField.value] || ''
    
    if (sortOrder.value === 'asc') {
      return aVal > bVal ? 1 : -1
    } else {
      return aVal < bVal ? 1 : -1
    }
  })

  filteredQuestions.value = filtered
  currentPage.value = 1
}

// Sort by field
const sortBy = (field) => {
  if (sortField.value === field) {
    sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc'
  } else {
    sortField.value = field
    sortOrder.value = 'asc'
  }
  filterQuestions()
}

// Truncate text
const truncateText = (text, length) => {
  if (!text) return ''
  if (text.length <= length) return text
  return text.substring(0, length) + '...'
}

// Actions
const editQuestion = (question) => {
  window.location.href = `/docs/admin/assessments/edit?id=${question.assessment_id}#question-${question.id}`
}

const duplicateQuestion = async (question) => {
  if (!confirm('Duplicate this question?')) return
  
  try {
    const newQuestion = {
      ...question,
      question_text: `${question.question_text} (Copy)`,
      created_at: new Date().toISOString()
    }
    
    delete newQuestion.id
    delete newQuestion.assessments
    delete newQuestion.competencies
    delete newQuestion.assessment_title
    delete newQuestion.competency_name
    
    const { error } = await supabase
      .from('assessment_questions')
      .insert(newQuestion)
    
    if (error) {
      console.error('Error duplicating question:', error)
      alert('Failed to duplicate question')
      return
    }
    
    await loadQuestions()
    alert('Question duplicated successfully!')
  } catch (error) {
    console.error('Error duplicating question:', error)
  }
}

const deleteQuestion = async (question) => {
  if (!confirm(`Delete this question?\n\n"${truncateText(question.question_text, 50)}"`)) return
  
  try {
    const { error } = await supabase
      .from('assessment_questions')
      .delete()
      .eq('id', question.id)
    
    if (error) {
      console.error('Error deleting question:', error)
      alert('Failed to delete question')
      return
    }
    
    await loadQuestions()
  } catch (error) {
    console.error('Error deleting question:', error)
  }
}

const toggleQuestionStatus = async (question) => {
  const newStatus = !question.is_active
  
  try {
    const { error } = await supabase
      .from('assessment_questions')
      .update({ is_active: newStatus })
      .eq('id', question.id)
    
    if (error) {
      console.error('Error updating question status:', error)
      alert('Failed to update question status')
      return
    }
    
    // Update local state immediately for better UX
    question.is_active = newStatus
  } catch (error) {
    console.error('Error updating question status:', error)
    alert('Failed to update question status')
  }
}

const exportQuestions = () => {
  if (filteredQuestions.value.length === 0) {
    alert('No questions to export. Please adjust your filters or load data first.')
    return
  }

  const data = filteredQuestions.value.map((q, index) => ({
    id: q.id || '',
    assessment_id: q.assessment_id || '',
    question_order: q.question_order || index + 1,
    scenario: q.scenario || '',
    question: q.question || q.question_text || '',
    option_a: q.option_a || '',
    option_b: q.option_b || '',
    option_c: q.option_c || '',
    option_d: q.option_d || '',
    correct_answer: q.correct_answer || '',
    explanation: q.explanation || '',
    competency_id: q.competency_id || '',
    assessment_level_id: q.assessment_level_id || '',
    difficulty_weight: q.difficulty_weight || 1.0,
    is_active: q.is_active !== false,
    created_at: q.created_at || '',
    updated_at: q.updated_at || ''
  }))
  
  // Escape CSV values properly
  const escapeCsvValue = (value) => {
    if (value === null || value === undefined) return ''
    const str = String(value)
    // Escape quotes and wrap in quotes if contains comma, quote, or newline
    if (str.includes(',') || str.includes('"') || str.includes('\n')) {
      return '"' + str.replace(/"/g, '""') + '"'
    }
    return str
  }
  
  const headers = Object.keys(data[0])
  const csv = [
    headers.join(','),
    ...data.map(row => headers.map(header => escapeCsvValue(row[header])).join(','))
  ].join('\n')
  
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  
  // Generate descriptive filename
  const timestamp = new Date().toISOString().split('T')[0]
  const filterSuffix = filterAssessment.value || filterCategory.value || filterCompetency.value 
    ? `_filtered` : ''
  a.download = `assessment_questions_${timestamp}${filterSuffix}.csv`
  
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
  
  // Show success message
  alert(`Successfully exported ${data.length} questions to CSV file!`)
}

const importQuestions = () => {
  window.location.href = '/docs/admin/import-questions'
}

// Watch search query
watch(searchQuery, () => {
  filterQuestions()
})

// Watch for admin access changes
watch(hasAdminAccess, (newValue) => {
  if (newValue) {
    loadQuestions()
  }
}, { immediate: true })

onMounted(() => {
  isAuthLoaded.value = true
  if (hasAdminAccess.value) {
    loadQuestions()
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

.filter-bar {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  padding: 1.5rem;
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
}

.search-input {
  flex: 1;
  padding: 0.75rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  font-size: 1rem;
}

.filter-bar select {
  padding: 0.75rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  font-size: 0.95rem;
}

.stats-bar {
  display: flex;
  gap: 3rem;
  margin-bottom: 2rem;
  padding: 1rem;
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
}

.stat {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--vp-c-brand-1);
}

.stat-label {
  font-size: 0.9rem;
  opacity: 0.7;
}

.loading,
.no-data {
  text-align: center;
  padding: 4rem;
  opacity: 0.7;
}

.questions-list {
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
  overflow: hidden;
  margin: 1rem 0 4rem 0;
  border: 1px solid var(--vp-c-border);
}

.list-header {
  display: grid;
  grid-template-columns: 2.5fr 1.5fr 1.2fr 0.8fr 0.6fr 0.8fr 0.8fr;
  gap: 1rem;
  padding: 1rem 1.5rem;
  background: var(--vp-c-bg);
  border-bottom: 2px solid var(--vp-c-border);
  font-weight: 600;
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
}

.list-header > div {
  cursor: pointer;
  user-select: none;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  transition: color 0.2s ease;
}

.list-header > div:hover {
  color: var(--vp-c-brand-1);
}

.sort-indicator {
  color: var(--vp-c-brand-1);
  font-size: 0.8rem;
}

.list-items {
  background: var(--vp-c-bg);
}

.list-item {
  display: grid;
  grid-template-columns: 2.5fr 1.5fr 1.2fr 0.8fr 0.6fr 0.8fr 0.8fr;
  gap: 1rem;
  padding: 1rem 1.5rem;
  border-bottom: 1px solid var(--vp-c-divider);
  align-items: center;
  transition: background 0.2s ease;
}

.list-item:hover {
  background: var(--vp-c-bg-soft);
}

.list-item:last-child {
  border-bottom: none;
}

.col-question {
  min-width: 0;
}

.question-content {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.question-text {
  color: var(--vp-c-text-1);
  font-size: 0.95rem;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.assessment-badge {
  padding: 0.2rem 0.6rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 600;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
  display: inline-block;
}

.assessment-core {
  background: #e0f2fe;
  color: #0369a1;
}

.assessment-icf {
  background: #f0fdf4;
  color: #15803d;
}

.assessment-ac {
  background: #fef3c7;
  color: #a16207;
}

.competency-text {
  color: var(--vp-c-text-2);
  font-size: 0.9rem;
}

.level-badge {
  padding: 0.15rem 0.5rem;
  border-radius: 10px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: capitalize;
  background: var(--vp-c-gray-soft);
  color: var(--vp-c-text-2);
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

.options-count {
  font-weight: 600;
  color: var(--vp-c-brand-1);
  font-size: 0.95rem;
}

.status-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-2);
  border: 1px solid var(--vp-c-border);
  cursor: pointer;
  transition: all 0.2s ease;
}

.status-badge:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.status-badge.active {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
  border-color: var(--vp-c-green-soft);
}

.status-badge.active:hover {
  background: var(--vp-c-green);
  color: white;
  border-color: var(--vp-c-green);
}

.status-badge.inactive {
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-3);
  border-color: var(--vp-c-border);
}

.status-badge.inactive:hover {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
  border-color: var(--vp-c-green-soft);
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

.action-btn.delete:hover {
  background: var(--vp-c-danger-soft);
  color: var(--vp-c-danger-1);
  border-color: var(--vp-c-danger-1);
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

.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 2rem;
  margin-top: 2rem;
  padding: 1rem;
}

.page-btn {
  padding: 0.5rem 1rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  background: var(--vp-c-bg-soft);
  cursor: pointer;
}

.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-info {
  font-weight: 600;
}

/* Responsive Design */
@media (max-width: 1024px) {
  .list-header,
  .list-item {
    grid-template-columns: 2fr 1.2fr 1fr 0.7fr 0.5fr 0.7fr 0.8fr;
    font-size: 0.85rem;
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
  
  .filter-bar {
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
  
  .col-question::before { content: 'Question'; }
  .col-assessment::before { content: 'Assessment'; }
  .col-competency::before { content: 'Competency'; }
  .col-level::before { content: 'Level'; }
  .col-options::before { content: 'Options'; }
  .col-actions::before { content: 'Actions'; }
  
  .col-question {
    flex-direction: column;
    align-items: flex-start !important;
  }
  
  .question-text {
    margin-top: 0.5rem;
  }
}
</style>