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

    <!-- Assessment Management with Tabs -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>📝 Assessment Management</h1>
          <p class="admin-subtitle">Manage assessments and questions - user data is in User Management</p>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>Assessments</span>
      </nav>

      <!-- Database Table Tabs -->
      <div class="table-tabs">
        <button 
          v-for="tab in tableTabs" 
          :key="tab.id"
          @click="activeTab = tab.id"
          :class="['tab', { active: activeTab === tab.id }]"
        >
          <span class="tab-icon">{{ tab.icon }}</span>
          <span class="tab-label">{{ tab.label }}</span>
          <span class="tab-count" :class="{ filtered: tab.count !== tab.total }">
            {{ tab.count }}{{ tab.count !== tab.total ? `/${tab.total}` : '' }}
          </span>
        </button>
      </div>

      <!-- Tab Content -->
      <div class="tab-content">
        <!-- Assessments Tab -->
        <div v-show="activeTab === 'assessments'" class="table-section">
          <div class="section-header">
            <div>
              <h2>Assessments</h2>
              <p class="section-description">Main assessment configurations - select competencies to test</p>
            </div>
            <ActionButton @click="addAssessment" icon="➕">Create Assessment</ActionButton>
          </div>

          <!-- Filters -->
          <div class="filter-bar">
            <input 
              v-model="filters.assessments.search"
              type="text" 
              placeholder="Search assessments..."
              class="filter-input"
            >
            <select v-model="filters.assessments.framework" class="filter-select">
              <option value="">All Frameworks</option>
              <option v-for="framework in uniqueFrameworks" :key="framework.id" :value="framework.id">
                {{ framework.name }}
              </option>
            </select>
            <select v-model="filters.assessments.level" class="filter-select">
              <option value="">All Levels</option>
              <option v-for="level in uniqueLevels" :key="level.id" :value="level.id">
                {{ level.level_name }}
              </option>
            </select>
            <select v-model="filters.assessments.status" class="filter-select">
              <option value="">All Status</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>

          <AdminTableHeader :columns="tableConfigs.assessments">
            <div v-for="item in filteredAssessments" :key="item.id" class="table-row assessments-grid">
              <div class="col-competency">
                <div class="competency-name">{{ item.title }}</div>
                <div class="insight-text">{{ truncate(item.description, 100) }}</div>
              </div>
              <div class="col-level">
                <span v-if="item.assessment_levels" class="level-badge" :class="item.assessment_levels?.level_code?.toLowerCase()">
                  {{ item.assessment_levels.level_name }}
                </span>
                <span v-else class="level-badge">All Levels</span>
              </div>
              <div class="col-framework">
                <span v-if="item.frameworks" class="framework-badge" :class="item.frameworks?.code?.toLowerCase()">
                  {{ item.frameworks.code || 'N/A' }}
                </span>
                <span v-else class="framework-badge">N/A</span>
              </div>
              <div class="col-status">
                <span class="status-badge" :class="{ active: item.is_active }">
                  {{ item.is_active ? 'Active' : 'Inactive' }}
                </span>
              </div>
              <div class="col-actions">
                <button @click="editItem('assessments', item)" class="action-btn edit">Edit</button>
                <button @click="deleteItem('assessments', item)" class="action-btn delete">Delete</button>
              </div>
            </div>
            
            <div v-if="filteredAssessments.length === 0" class="empty-state">
              <p>{{ filters.assessments.search || filters.assessments.framework || filters.assessments.level || filters.assessments.status ? 'No assessments match the current filters.' : 'No assessments found.' }}</p>
            </div>
          </AdminTableHeader>
        </div>

        <!-- Assessment Questions Tab -->
        <div v-show="activeTab === 'questions'" class="table-section">
          <div class="section-header">
            <div>
              <h2>Assessment Questions</h2>
              <p class="section-description">All questions linked to assessments and competencies</p>
            </div>
            <div class="header-actions">
              <ActionButton @click="exportQuestions" variant="secondary" icon="📥">Export CSV</ActionButton>
              <ActionButton @click="importQuestions" variant="secondary" icon="📤">Import CSV</ActionButton>
              <ActionButton @click="addQuestion" icon="➕">Add Question</ActionButton>
            </div>
          </div>

          <!-- Filters -->
          <div class="filter-bar">
            <input 
              v-model="filters.questions.search"
              type="text" 
              placeholder="Search questions..."
              class="filter-input"
            >
            <select v-model="filters.questions.assessment" class="filter-select">
              <option value="">All Assessments</option>
              <option v-for="assessment in assessments" :key="assessment.id" :value="assessment.id">
                {{ assessment.title }}
              </option>
            </select>
            <select v-model="filters.questions.competency" class="filter-select">
              <option value="">All Competencies</option>
              <option v-for="comp in uniqueCompetencies" :key="comp.id" :value="comp.id">
                {{ comp.display_name }}
              </option>
            </select>
          </div>

          <AdminTableHeader :columns="tableConfigs.questions">
            <div v-for="item in filteredQuestions" :key="item.id" class="table-row questions-grid">
              <div class="col-competency">
                <div class="competency-name">{{ item.competency_display_names?.display_name || 'No Competency' }}</div>
                <div class="insight-text">{{ truncate(item.question, 100) }}</div>
              </div>
              <div class="col-level">
                <span class="level-badge">{{ getAssessmentLevel(item.assessment_id) }}</span>
              </div>
              <div class="col-framework">
                <span class="framework-badge">{{ getAssessmentFramework(item.assessment_id) }}</span>
              </div>
              <div class="col-answer">
                <span class="answer-badge">{{ item.correct_answer }}</span>
              </div>
              <div class="col-status">
                <button 
                  class="status-badge" 
                  :class="{ 'active': item.is_active, 'inactive': !item.is_active }"
                  @click="toggleQuestionStatus(item)"
                  :title="`Click to ${item.is_active ? 'deactivate' : 'activate'} this question`"
                >
                  {{ item.is_active ? 'Active' : 'Inactive' }}
                </button>
              </div>
              <div class="col-actions">
                <button @click="editItem('questions', item)" class="action-btn edit">Edit</button>
                <button @click="deleteItem('questions', item)" class="action-btn delete">Delete</button>
              </div>
            </div>
            
            <div v-if="filteredQuestions.length === 0" class="empty-state">
              <p>{{ filters.questions.search || filters.questions.assessment || filters.questions.competency ? 'No questions match the current filters.' : 'No questions found.' }}</p>
            </div>
          </AdminTableHeader>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAdminSession } from '../composables/useAdminSession'
import { useAdminSupabase } from '../composables/useAdminSupabase'
import ActionButton from './shared/ActionButton.vue'
import AdminLoadingState from './shared/AdminLoadingState.vue'
import AdminTableHeader from './shared/AdminTableHeader.vue'

const { hasAdminAccess, createSession } = useAdminSession()
const { adminSupabase } = useAdminSupabase()

// Authentication loading state
const isAuthLoaded = ref(false)

// Initialize admin session on component mount
onMounted(async () => {
  isAuthLoaded.value = true
  await createSession()
})

// Active tab
const activeTab = ref('assessments')

// Data - focused on assessment management
const assessments = ref([])
const assessmentQuestions = ref([])

// Table configurations for AdminTableHeader
const tableConfigs = {
  assessments: [
    { label: 'Assessment & Description', width: '3fr' },
    { label: 'Level', width: '120px' },
    { label: 'Framework', width: '120px' },
    { label: 'Status', width: '100px' },
    { label: 'Actions', width: '140px' }
  ],
  questions: [
    { label: 'Competency & Question', width: '3fr' },
    { label: 'Level', width: '120px' },
    { label: 'Framework', width: '120px' },
    { label: 'Answer', width: '80px' },
    { label: 'Status', width: '100px' },
    { label: 'Actions', width: '140px' }
  ]
}

// Filters - enhanced with search and multiple filter options
const filters = ref({
  assessments: {
    search: '',
    framework: '',
    level: '',
    status: ''
  },
  questions: {
    search: '',
    assessment: '',
    competency: ''
  }
})

// Table tabs configuration - with filtered counts
const tableTabs = computed(() => [
  {
    id: 'assessments',
    label: 'Assessments',
    icon: '📝',
    count: filteredAssessments.value.length,
    total: assessments.value.length,
    description: 'Main configurations'
  },
  {
    id: 'questions',
    label: 'Questions',
    icon: '❓',
    count: filteredQuestions.value.length,
    total: assessmentQuestions.value.length,
    description: 'Linked to assessments'
  }
])

// Computed - unique values for filters
const uniqueFrameworks = computed(() => {
  const frameworks = assessments.value
    .map(a => a.frameworks)
    .filter(Boolean)
  // Remove duplicates by id
  const uniqueFw = []
  const seenIds = new Set()
  for (const fw of frameworks) {
    if (!seenIds.has(fw.id)) {
      seenIds.add(fw.id)
      uniqueFw.push(fw)
    }
  }
  return uniqueFw.sort((a, b) => a.name.localeCompare(b.name))
})

const uniqueLevels = computed(() => {
  const levels = assessments.value
    .map(a => a.assessment_levels)
    .filter(Boolean)
  // Remove duplicates by id
  const uniqueLvl = []
  const seenIds = new Set()
  for (const lvl of levels) {
    if (!seenIds.has(lvl.id)) {
      seenIds.add(lvl.id)
      uniqueLvl.push(lvl)
    }
  }
  return uniqueLvl.sort((a, b) => a.level_name.localeCompare(b.level_name))
})

const uniqueCompetencies = computed(() => {
  const competencies = assessmentQuestions.value
    .map(q => q.competency_display_names)
    .filter(Boolean)
  // Remove duplicates by id
  const uniqueComp = []
  const seenIds = new Set()
  for (const comp of competencies) {
    if (!seenIds.has(comp.id)) {
      seenIds.add(comp.id)
      uniqueComp.push(comp)
    }
  }
  return uniqueComp.sort((a, b) => a.display_name.localeCompare(b.display_name))
})

const filteredAssessments = computed(() => {
  let filtered = assessments.value
  
  // Search filter
  if (filters.value.assessments.search) {
    const search = filters.value.assessments.search.toLowerCase()
    filtered = filtered.filter(a => 
      a.title?.toLowerCase().includes(search) ||
      a.description?.toLowerCase().includes(search) ||
      a.slug?.toLowerCase().includes(search)
    )
  }
  
  // Framework filter
  if (filters.value.assessments.framework) {
    filtered = filtered.filter(a => a.frameworks?.id === filters.value.assessments.framework)
  }
  
  // Level filter
  if (filters.value.assessments.level) {
    filtered = filtered.filter(a => a.assessment_levels?.id === filters.value.assessments.level)
  }
  
  // Status filter
  if (filters.value.assessments.status) {
    const isActive = filters.value.assessments.status === 'active'
    filtered = filtered.filter(a => a.is_active === isActive)
  }
  
  return filtered
})

const filteredQuestions = computed(() => {
  let filtered = assessmentQuestions.value
  
  // Search filter
  if (filters.value.questions.search) {
    const search = filters.value.questions.search.toLowerCase()
    filtered = filtered.filter(q => 
      q.question?.toLowerCase().includes(search)
    )
  }
  
  // Assessment filter
  if (filters.value.questions.assessment) {
    filtered = filtered.filter(q => q.assessment_id === filters.value.questions.assessment)
  }
  
  // Competency filter
  if (filters.value.questions.competency) {
    filtered = filtered.filter(q => q.competency_display_names?.id === filters.value.questions.competency)
  }
  
  return filtered
})


// Methods
const truncate = (text, length) => {
  if (!text) return ''
  return text.length > length ? text.substring(0, length) + '...' : text
}

const getAssessmentName = (assessmentId) => {
  const assessment = assessments.value.find(a => a.id === assessmentId)
  return assessment?.title || 'Unknown'
}

const getAssessmentLevel = (assessmentId) => {
  const assessment = assessments.value.find(a => a.id === assessmentId)
  return assessment?.assessment_levels?.level_name || 'N/A'
}

const getAssessmentFramework = (assessmentId) => {
  const assessment = assessments.value.find(a => a.id === assessmentId)
  return assessment?.frameworks?.code || 'N/A'
}

const getQuestionCount = (assessmentId) => {
  return assessmentQuestions.value.filter(q => q.assessment_id === assessmentId).length
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString() + ' ' + 
         new Date(dateString).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
}

const loadAllData = async () => {
  if (!adminSupabase) return

  try {
    console.log('Loading assessments with relational data...')
    
    // Load assessments with framework and assessment level relationships
    const { data: assessmentsData, error: assessmentsError } = await adminSupabase
      .from('assessments')
      .select(`
        *,
        frameworks!framework_id (
          id, name, code
        ),
        assessment_levels!assessment_level_id (
          id, level_code, level_name
        )
      `)
      .order('sort_order', { ascending: true })

    if (assessmentsError) {
      console.error('Error loading assessments:', assessmentsError)
    } else {
      assessments.value = assessmentsData || []
      console.log('Loaded assessments:', assessments.value.length)
    }

    // Load assessment questions with competency relationships
    const { data: questionsData, error: questionsError } = await adminSupabase
      .from('assessment_questions')
      .select(`
        *,
        competency_display_names!competency_id (
          id, display_name
        ),
        assessment_levels!assessment_level_id (
          id, level_code, level_name
        )
      `)
      .order('assessment_id, question_order')

    if (questionsError) {
      console.error('Error loading questions:', questionsError)
    } else {
      assessmentQuestions.value = questionsData || []
      console.log('Loaded questions:', assessmentQuestions.value.length)
    }


  } catch (error) {
    console.error('Error loading data:', error)
  }
}

const addAssessment = () => {
  window.location.href = '/docs/admin/assessments/edit'
}

const addQuestion = () => {
  window.location.href = '/docs/admin/assessments/question/edit'
}

const importQuestions = () => {
  window.location.href = '/docs/admin/import-questions'
}

const editItem = (table, item) => {
  if (table === 'assessments') {
    window.location.href = `/docs/admin/assessments/edit?id=${item.id}`
  } else if (table === 'questions') {
    window.location.href = `/docs/admin/assessments/question/edit?id=${item.id}`
  } else {
    alert(`Edit ${table} coming soon`)
  }
}

const toggleQuestionStatus = async (question) => {
  if (!adminSupabase) {
    alert('Database connection not available')
    return
  }

  try {
    const newStatus = !question.is_active
    const { error } = await adminSupabase
      .from('assessment_questions')
      .update({ is_active: newStatus })
      .eq('id', question.id)

    if (error) {
      console.error('Error toggling question status:', error)
      alert('Failed to update question status: ' + error.message)
      return
    }

    // Update the local data
    question.is_active = newStatus
    
    // Show feedback
    const status = newStatus ? 'activated' : 'deactivated'
    console.log(`Question ${status} successfully`)
    
  } catch (error) {
    console.error('Error toggling question status:', error)
    alert('Failed to update question status: ' + error.message)
  }
}

const deleteItem = async (table, item) => {
  const itemName = table === 'assessments' ? item.title : 'this question'
  
  if (!confirm(`Are you sure you want to delete "${itemName}"?\n\nThis action cannot be undone.`)) {
    return
  }

  if (!adminSupabase) {
    alert('Database connection not available')
    return
  }

  try {
    const tableMap = {
      'assessments': 'assessments',
      'questions': 'assessment_questions'
    }

    const dbTable = tableMap[table]
    if (!dbTable) {
      alert(`Unknown table: ${table}`)
      return
    }

    const { error } = await adminSupabase
      .from(dbTable)
      .delete()
      .eq('id', item.id)

    if (error) {
      console.error('Delete error:', error)
      alert(`Failed to delete item: ${error.message}`)
      return
    }

    // Remove from local data
    if (table === 'assessments') {
      assessments.value = assessments.value.filter(i => i.id !== item.id)
    } else if (table === 'questions') {
      assessmentQuestions.value = assessmentQuestions.value.filter(i => i.id !== item.id)
    }

    alert('Item deleted successfully')
  } catch (error) {
    console.error('Error deleting item:', error)
    alert('Failed to delete item: ' + error.message)
  }
}

// CSV Export for Questions
const exportQuestions = () => {
  if (filteredQuestions.value.length === 0) {
    alert('No questions to export. Please adjust your filters or load data first.')
    return
  }

  const data = filteredQuestions.value.map((q, index) => ({
    id: q.id || '',
    assessment_id: q.assessment_id || '',
    question_order: q.question_order || '',
    scenario: q.scenario || '',
    question: q.question || '',
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
  const filterSuffix = filters.value.questions.assessment || filters.value.questions.competency || filters.value.questions.search
    ? '_filtered' : ''
  a.download = `assessment_questions_${timestamp}${filterSuffix}.csv`
  
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
  
  // Show success message
  alert(`Successfully exported ${data.length} questions to CSV file!`)
}

onMounted(() => {
  loadAllData()
})
</script>

<style scoped>
/* Reuse the same styles as AdminCompetenciesTabs */
.admin-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
}

.admin-header {
  margin-bottom: 30px;
}

.header-main h1 {
  font-size: 32px;
  margin-bottom: 8px;
}

.admin-subtitle {
  color: var(--vp-c-text-2);
}

.breadcrumb {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 24px;
  padding: 12px;
  background: var(--vp-c-bg-soft);
  border-radius: 6px;
}

.breadcrumb-separator {
  color: var(--vp-c-text-3);
}

/* Table Tabs */
.table-tabs {
  display: flex;
  gap: 4px;
  background: var(--vp-c-bg-soft);
  padding: 4px;
  border-radius: 8px;
  margin-bottom: 24px;
  overflow-x: auto;
}

.tab {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  background: transparent;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  white-space: nowrap;
  transition: all 0.2s;
  color: var(--vp-c-text-2);
}

.tab:hover {
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
}

.tab.active {
  background: var(--vp-c-bg);
  color: var(--vp-c-brand);
  font-weight: 500;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.tab-icon {
  font-size: 18px;
}

.tab-label {
  font-size: 14px;
}

.tab-count {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand);
  padding: 2px 6px;
  border-radius: 10px;
  font-size: 11px;
  font-weight: 600;
}

/* Tab Content */
.tab-content {
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
  padding: 24px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: start;
  margin-bottom: 24px;
}

.header-actions {
  display: flex;
  gap: 12px;
  align-items: center;
}

.section-header h2 {
  font-size: 24px;
  margin-bottom: 4px;
}

.section-description {
  color: var(--vp-c-text-2);
  font-size: 14px;
}

.header-stats {
  display: flex;
  gap: 12px;
}

.stat-badge {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand);
  padding: 4px 12px;
  border-radius: 16px;
  font-size: 12px;
  font-weight: 600;
}

/* Filter Bar */
.filter-bar {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.filter-input {
  flex: 1;
  min-width: 200px;
  padding: 8px 12px;
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  background: var(--vp-c-bg);
  font-size: 14px;
}

.filter-input:focus {
  outline: none;
  border-color: var(--vp-c-brand);
}

.filter-select {
  padding: 8px 12px;
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  background: var(--vp-c-bg);
  font-size: 14px;
  min-width: 150px;
}

.filter-select:focus {
  outline: none;
  border-color: var(--vp-c-brand);
}

/* Data Table */
.data-table {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  overflow: hidden;
}

.table-header {
  display: grid;
  padding: 16px;
  background: var(--vp-c-bg-soft);
  border-bottom: 1px solid var(--vp-c-border);
  font-weight: 600;
  font-size: 12px;
  text-transform: uppercase;
  color: var(--vp-c-text-2);
  gap: 16px;
}

.table-row {
  display: grid;
  padding: 20px 16px;
  border-bottom: 1px solid var(--vp-c-divider);
  align-items: start;
  transition: background 0.2s;
  gap: 16px;
}

.table-row:hover {
  background: var(--vp-c-bg-soft);
}

.table-row:last-child {
  border-bottom: none;
}

/* Special grids for different tabs */
[v-show="activeTab === 'questions'"] .table-header,
[v-show="activeTab === 'questions'"] .table-row {
  grid-template-columns: 3fr 1.5fr 1fr 80px 60px 80px;
}

[v-show="activeTab === 'attempts'"] .table-header,
[v-show="activeTab === 'attempts'"] .table-row {
  grid-template-columns: 120px 2fr 80px 140px 60px 80px;
}

/* Column Styles */
.col-name {
  font-weight: 500;
  color: var(--vp-c-text-1);
}

.item-main {
  font-weight: 500;
  margin-bottom: 2px;
}

.item-description {
  font-size: 12px;
  color: var(--vp-c-text-2);
  margin-bottom: 2px;
}

.item-slug {
  font-size: 11px;
  color: var(--vp-c-text-3);
  font-family: monospace;
  background: var(--vp-c-bg-mute);
  padding: 1px 4px;
  border-radius: 3px;
  display: inline-block;
}

.no-competency {
  font-style: italic;
  color: var(--vp-c-text-3);
  font-size: 12px;
}

.col-text {
  color: var(--vp-c-text-2);
  font-size: 13px;
}

.col-id {
  font-family: monospace;
  font-size: 12px;
  color: var(--vp-c-text-2);
}

.user-id {
  background: var(--vp-c-bg-soft);
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 11px;
}

.col-framework,
.col-level,
.col-stats,
.col-status,
.col-date,
.col-time {
  display: flex;
  align-items: center;
  font-size: 13px;
}

/* Badges - match competencies exactly */
.framework-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
}

.framework-badge.core {
  background: var(--vp-c-purple-soft);
  color: var(--vp-c-purple);
}

.framework-badge.icf {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
}

.framework-badge.ac {
  background: var(--vp-c-blue-soft);
  color: var(--vp-c-blue);
}

.level-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.level-badge.foundational {
  background: var(--vp-c-blue-soft);
  color: var(--vp-c-blue);
}

.level-badge.developing {
  background: var(--vp-c-yellow-soft);
  color: var(--vp-c-yellow-darker);
}

.level-badge.advanced {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
}

.answer-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  background: var(--vp-c-indigo-soft);
  color: var(--vp-c-indigo);
  font-family: monospace;
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
  font-family: inherit;
}

.status-badge:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.status-badge.active {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
  border-color: var(--vp-c-green-soft);
}

.status-badge.active:hover {
  background: var(--vp-c-green);
  color: white;
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

.score-badge {
  display: inline-block;
  padding: 3px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 600;
}

.score-badge.high {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
}

.score-badge.medium {
  background: var(--vp-c-yellow-soft);
  color: var(--vp-c-yellow-darker);
}

.score-badge.low {
  background: var(--vp-c-danger-soft);
  color: var(--vp-c-danger);
}

.status-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  background: var(--vp-c-danger-soft);
  color: var(--vp-c-danger);
}

.status-badge.active {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
}

.stat-number {
  font-weight: 600;
  color: var(--vp-c-text-1);
}

/* Actions - match competencies exactly */
.col-actions {
  display: flex;
  gap: 8px;
  align-items: center;
}

.action-btn {
  padding: 6px 12px;
  border: none;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  white-space: nowrap;
}

.action-btn.edit {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand);
}

.action-btn.edit:hover {
  background: var(--vp-c-brand);
  color: white;
}

.action-btn.delete {
  background: var(--vp-c-danger-soft);
  color: var(--vp-c-danger);
}

.action-btn.delete:hover {
  background: var(--vp-c-danger);
  color: white;
}

/* Column Styles - match rich insights pattern exactly */
.col-competency {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.competency-name {
  font-weight: 600;
  color: var(--vp-c-text-1);
  font-size: 15px;
}

.insight-text {
  color: var(--vp-c-text-2);
  font-size: 13px;
  line-height: 1.4;
}

.col-framework,
.col-level,
.col-status,
.col-assessment,
.col-answer,
.col-weight {
  display: flex;
  align-items: center;
}

.assessment-name {
  color: var(--vp-c-text-2);
  font-size: 13px;
}

.weight-value {
  font-family: monospace;
  font-size: 13px;
  color: var(--vp-c-text-2);
}

.no-data {
  font-style: italic;
  color: var(--vp-c-text-3);
  font-size: 13px;
}

/* Empty State - match competencies */
.empty-state {
  padding: 60px 20px;
  text-align: center;
  color: var(--vp-c-text-2);
}


.tab-count.filtered {
  background: var(--vp-c-yellow-soft);
  color: var(--vp-c-yellow-darker);
}

/* Grid layouts for different tabs - match rich insights pattern */
.assessments-grid {
  grid-template-columns: 3fr 120px 120px 100px 140px;
}

.questions-grid {
  grid-template-columns: 3fr 120px 120px 80px 100px 140px;
}

/* Level badge colors */
.level-badge.beginner,
.level-badge.foundational {
  background: var(--vp-c-blue-soft);
  color: var(--vp-c-blue);
}

.level-badge.intermediate,
.level-badge.developing {
  background: var(--vp-c-yellow-soft);
  color: var(--vp-c-yellow-darker);
}

.level-badge.advanced {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
}

/* Responsive Design - match rich insights pattern */
@media (max-width: 1200px) {
  .assessments-grid {
    grid-template-columns: 3fr 100px 100px 90px 130px;
  }
  
  .questions-grid {
    grid-template-columns: 3fr 100px 90px 70px 90px 120px;
  }
}

@media (max-width: 768px) {
  .admin-container {
    padding: 12px;
  }
  
  .table-row,
  .table-header {
    font-size: 12px;
    padding: 10px;
  }
  
  .filter-bar {
    flex-direction: column;
  }
  
  .filter-select,
  .filter-input {
    width: 100%;
  }
  
  .assessments-grid,
  .questions-grid {
    grid-template-columns: 1fr;
    gap: 8px;
  }
  
  .table-header {
    display: none;
  }
}
</style>