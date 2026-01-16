<template>
  <div class="admin-container" :data-active-tab="activeTab">
    <!-- Loading state during auth check -->
    <AdminLoadingState v-if="!isAuthLoaded" />

    <!-- Admin Access Check -->
    <div v-else-if="!hasAdminAccess" class="admin-content">
      <div class="admin-header">
        <h1>⚠️ Admin Access Required</h1>
        <p class="admin-subtitle">You need administrator privileges to manage skill tags.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- Skill Tags Management -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>🏷️ Skill Tags Management</h1>
          <p class="admin-subtitle">Manage skill tags, insights, and actions for assessments</p>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>Skill Tags</span>
      </nav>

      <!-- Tab Navigation -->
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
        <!-- Skill Tags Tab -->
        <div v-show="activeTab === 'skill_tags'" class="table-section">
          <div class="section-header">
            <div>
              <h2>Skill Tags</h2>
              <p class="section-description">Core skill definitions linked to competencies and frameworks</p>
            </div>
            <ActionButton @click="addSkillTag" icon="➕">Add Skill Tag</ActionButton>
          </div>

          <!-- Filters -->
          <div class="filter-bar">
            <input 
              v-model="skillTagFilters.search"
              type="text" 
              placeholder="Search skill tags..."
              class="filter-input"
            >
            <select v-model="skillTagFilters.framework" class="filter-select">
              <option value="">All Frameworks</option>
              <option v-for="framework in uniqueFrameworks" :key="framework.id" :value="framework.id">
                {{ framework.name }}
              </option>
            </select>
            <select v-model="skillTagFilters.competency" class="filter-select">
              <option value="">All Competencies</option>
              <option v-for="comp in uniqueCompetencies" :key="comp.id" :value="comp.id">
                {{ comp.display_name }}
              </option>
            </select>
            <select v-model="skillTagFilters.level" class="filter-select">
              <option value="">All Levels</option>
              <option v-for="level in uniqueLevels" :key="level.id" :value="level.id">
                {{ level.level_name }}
              </option>
            </select>
            <select v-model="skillTagFilters.status" class="filter-select">
              <option value="">All Status</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>

          <AdminTableHeader :columns="tableConfigs.skill_tags">
            <div v-for="item in filteredSkillTags" :key="item.id" class="table-row skill-tags-grid">
              <div class="col-competency">
                <div class="competency-name">{{ item.name }}</div>
                <div class="insight-text">
                  {{ item.competency_display_names?.display_name || 'No competency assigned' }}
                </div>
              </div>
              <div class="col-level">
                <span class="level-badge" :class="item.assessment_levels?.level_code?.toLowerCase()">
                  {{ item.assessment_levels?.level_name || 'N/A' }}
                </span>
              </div>
              <div class="col-framework">
                <span class="framework-badge" :class="item.frameworks?.code?.toLowerCase()">
                  {{ item.frameworks?.code || 'N/A' }}
                </span>
              </div>
              <div class="col-status">
                <span class="status-badge" :class="{ active: item.is_active }">
                  {{ item.is_active ? 'Active' : 'Inactive' }}
                </span>
              </div>
              <div class="col-actions">
                <button @click="editItem('skill_tags', item)" class="action-btn edit">Edit</button>
                <button @click="deleteItem('skill_tags', item)" class="action-btn delete">Delete</button>
              </div>
            </div>
          </AdminTableHeader>
        </div>

        <!-- Tag Insights Tab -->
        <div v-show="activeTab === 'tag_insights'" class="table-section">
          <div class="section-header">
            <div>
              <h2>Tag Insights</h2>
              <p class="section-description">Weakness and strength insights for each skill tag</p>
            </div>
            <div class="header-actions">
              <ActionButton @click="exportTagInsights" variant="secondary" icon="📥">Export CSV</ActionButton>
              <ActionButton @click="addTagInsight" icon="➕">Add Insight</ActionButton>
            </div>
          </div>

          <!-- Filters -->
          <div class="filter-bar">
            <input 
              v-model="insightsFilters.search"
              type="text" 
              placeholder="Search insights..."
              class="filter-input"
            >
            <select v-model="insightsFilters.skillTag" class="filter-select">
              <option value="">All Skill Tags</option>
              <option v-for="tag in skillTags" :key="tag.id" :value="tag.id">
                {{ tag.name }}
              </option>
            </select>
            <select v-model="insightsFilters.level" class="filter-select">
              <option value="">All Levels</option>
              <option v-for="level in uniqueLevels" :key="level.id" :value="level.id">
                {{ level.level_name }}
              </option>
            </select>
            <select v-model="insightsFilters.framework" class="filter-select">
              <option value="">All Frameworks</option>
              <option v-for="framework in uniqueFrameworks" :key="framework.id" :value="framework.id">
                {{ framework.name }}
              </option>
            </select>
            <select v-model="insightsFilters.type" class="filter-select">
              <option value="">All Types</option>
              <option v-for="type in analysisTypes" :key="type.id" :value="type.id">
                {{ type.name }}
              </option>
            </select>
          </div>

          <AdminTableHeader :columns="tableConfigs.tag_insights">
            <div v-for="item in filteredTagInsights" :key="item.id" class="table-row insights-grid">
              <div class="col-competency">
                <div class="competency-name">{{ item.skill_tags?.name || 'Unknown Skill' }}</div>
                <div class="insight-text">{{ truncateText(item.insight_text, 120) }}</div>
              </div>
              <div class="col-level">
                <span class="level-badge" :class="item.skill_tags?.assessment_levels?.level_code?.toLowerCase()">
                  {{ item.skill_tags?.assessment_levels?.level_name || 'N/A' }}
                </span>
              </div>
              <div class="col-framework">
                <span class="framework-badge" :class="item.skill_tags?.frameworks?.code?.toLowerCase()">
                  {{ item.skill_tags?.frameworks?.code || 'N/A' }}
                </span>
              </div>
              <div class="col-type">
                <span class="type-badge" :class="item.analysis_types?.code?.toLowerCase()">
                  {{ item.analysis_types?.name || 'N/A' }}
                </span>
              </div>
              <div class="col-actions">
                <button @click="editItem('tag_insights', item)" class="action-btn edit">Edit</button>
                <button @click="deleteItem('tag_insights', item)" class="action-btn delete">Delete</button>
              </div>
            </div>
          </AdminTableHeader>
        </div>

        <!-- Tag Actions Tab -->
        <div v-show="activeTab === 'tag_actions'" class="table-section">
          <div class="section-header">
            <div>
              <h2>Tag Actions</h2>
              <p class="section-description">Actionable development steps for each skill tag</p>
            </div>
            <div class="header-actions">
              <ActionButton @click="exportTagActions" variant="secondary" icon="📥">Export CSV</ActionButton>
              <ActionButton @click="addTagAction" icon="➕">Add Action</ActionButton>
            </div>
          </div>

          <!-- Filters -->
          <div class="filter-bar">
            <input 
              v-model="actionsFilters.search"
              type="text" 
              placeholder="Search actions..."
              class="filter-input"
            >
            <select v-model="actionsFilters.skillTag" class="filter-select">
              <option value="">All Skill Tags</option>
              <option v-for="tag in skillTags" :key="tag.id" :value="tag.id">
                {{ tag.name }}
              </option>
            </select>
            <select v-model="actionsFilters.level" class="filter-select">
              <option value="">All Levels</option>
              <option v-for="level in uniqueLevels" :key="level.id" :value="level.id">
                {{ level.level_name }}
              </option>
            </select>
            <select v-model="actionsFilters.framework" class="filter-select">
              <option value="">All Frameworks</option>
              <option v-for="framework in uniqueFrameworks" :key="framework.id" :value="framework.id">
                {{ framework.name }}
              </option>
            </select>
            <select v-model="actionsFilters.status" class="filter-select">
              <option value="">All Status</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>

          <AdminTableHeader :columns="tableConfigs.tag_actions">
            <div v-for="item in filteredTagActions" :key="item.id" class="table-row actions-grid">
              <div class="col-competency">
                <div class="competency-name">{{ item.skill_tags?.name || 'Unknown Skill' }}</div>
                <div class="insight-text">{{ truncateText(item.action_text, 120) }}</div>
              </div>
              <div class="col-level">
                <span class="level-badge" :class="item.skill_tags?.assessment_levels?.level_code?.toLowerCase()">
                  {{ item.skill_tags?.assessment_levels?.level_name || 'N/A' }}
                </span>
              </div>
              <div class="col-framework">
                <span class="framework-badge" :class="item.skill_tags?.frameworks?.code?.toLowerCase()">
                  {{ item.skill_tags?.frameworks?.code || 'N/A' }}
                </span>
              </div>
              <div class="col-status">
                <span class="status-badge" :class="{ active: item.is_active }">
                  {{ item.is_active ? 'Active' : 'Inactive' }}
                </span>
              </div>
              <div class="col-actions">
                <button @click="editItem('tag_actions', item)" class="action-btn edit">Edit</button>
                <button @click="deleteItem('tag_actions', item)" class="action-btn delete">Delete</button>
              </div>
            </div>
          </AdminTableHeader>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useAdminSession } from '../composables/useAdminSession'
import { useAdminSupabase } from '../composables/useAdminSupabase'
import ActionButton from './shared/ActionButton.vue'
import AdminLoadingState from './shared/AdminLoadingState.vue'
import AdminTableHeader from './shared/AdminTableHeader.vue'

const { hasAdminAccess, createSession } = useAdminSession()
const { adminSupabase } = useAdminSupabase()

// Authentication loading state
const isAuthLoaded = ref(false)

// Active tab
const activeTab = ref('skill_tags')

// Data
const skillTags = ref([])
const tagInsights = ref([])
const tagActions = ref([])

// Reference data for dropdowns
const frameworks = ref([])
const competencies = ref([])
const levels = ref([])
const analysisTypes = ref([])

// Table configurations for AdminTableHeader
const tableConfigs = {
  skill_tags: [
    { label: 'Skill Tag & Competency', width: '3fr' },
    { label: 'Level', width: '120px' },
    { label: 'Framework', width: '120px' },
    { label: 'Status', width: '100px' },
    { label: 'Actions', width: '140px' }
  ],
  tag_insights: [
    { label: 'Skill Tag & Insight', width: '3fr' },
    { label: 'Level', width: '120px' },
    { label: 'Framework', width: '120px' },
    { label: 'Type', width: '100px' },
    { label: 'Actions', width: '140px' }
  ],
  tag_actions: [
    { label: 'Skill Tag & Action', width: '3fr' },
    { label: 'Level', width: '120px' },
    { label: 'Framework', width: '120px' },
    { label: 'Status', width: '100px' },
    { label: 'Actions', width: '140px' }
  ]
}

// Filters
const skillTagFilters = ref({
  search: '',
  framework: '',
  competency: '',
  level: '',
  status: ''
})

const insightsFilters = ref({
  search: '',
  skillTag: '',
  level: '',
  framework: '',
  type: ''
})

const actionsFilters = ref({
  search: '',
  skillTag: '',
  level: '',
  framework: '',
  status: ''
})

// Table tabs configuration
// Table tabs - with filtered counts
const tableTabs = computed(() => [
  {
    id: 'skill_tags',
    label: 'Skill Tags',
    icon: '🏷️',
    count: filteredSkillTags.value.length,
    total: skillTags.value.length
  },
  {
    id: 'tag_insights',
    label: 'Tag Insights',
    icon: '💡',
    count: filteredTagInsights.value.length,
    total: tagInsights.value.length
  },
  {
    id: 'tag_actions',
    label: 'Tag Actions',
    icon: '🎯',
    count: filteredTagActions.value.length,
    total: tagActions.value.length
  }
])

// Filter computed properties
const uniqueFrameworks = computed(() => frameworks.value)
const uniqueCompetencies = computed(() => competencies.value)
const uniqueLevels = computed(() => levels.value)

const filteredSkillTags = computed(() => {
  let filtered = skillTags.value

  // Search filter
  if (skillTagFilters.value.search) {
    const search = skillTagFilters.value.search.toLowerCase()
    filtered = filtered.filter(t => 
      t.name?.toLowerCase().includes(search) ||
      t.competency_display_names?.display_name?.toLowerCase().includes(search)
    )
  }
  
  if (skillTagFilters.value.framework) {
    filtered = filtered.filter(item => item.framework_id === skillTagFilters.value.framework)
  }
  if (skillTagFilters.value.competency) {
    filtered = filtered.filter(item => item.competency_id === skillTagFilters.value.competency)
  }
  if (skillTagFilters.value.level) {
    filtered = filtered.filter(item => item.assessment_level_id === skillTagFilters.value.level)
  }
  
  // Status filter
  if (skillTagFilters.value.status) {
    const isActive = skillTagFilters.value.status === 'active'
    filtered = filtered.filter(t => t.is_active === isActive)
  }

  return filtered.sort((a, b) => (a.sort_order || 0) - (b.sort_order || 0))
})

const filteredTagInsights = computed(() => {
  let filtered = [...tagInsights.value]

  // Search filter
  if (insightsFilters.value.search) {
    const search = insightsFilters.value.search.toLowerCase()
    filtered = filtered.filter(i => 
      i.insight_text?.toLowerCase().includes(search) ||
      i.skill_tags?.name?.toLowerCase().includes(search)
    )
  }
  
  // Skill tag filter - match by ID
  if (insightsFilters.value.skillTag) {
    filtered = filtered.filter(i => String(i.skill_tag_id) === String(insightsFilters.value.skillTag))
  }
  
  // Type filter - match by ID
  if (insightsFilters.value.type) {
    filtered = filtered.filter(i => String(i.analysis_type_id) === String(insightsFilters.value.type))
  }
  
  // Level filter - only through skill tag relationship (no direct assessment_level_id on tag_insights)
  if (insightsFilters.value.level) {
    filtered = filtered.filter(i => String(i.skill_tags?.assessment_levels?.id) === String(insightsFilters.value.level))
  }
  
  // Framework filter - through skill tag relationship
  if (insightsFilters.value.framework) {
    filtered = filtered.filter(i => String(i.skill_tags?.frameworks?.id) === String(insightsFilters.value.framework))
  }

  return filtered.sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
})

const filteredTagActions = computed(() => {
  let filtered = [...tagActions.value]

  // Search filter
  if (actionsFilters.value.search) {
    const search = actionsFilters.value.search.toLowerCase()
    filtered = filtered.filter(a => 
      a.action_text?.toLowerCase().includes(search) ||
      a.skill_tags?.name?.toLowerCase().includes(search)
    )
  }
  
  // Skill tag filter - match by ID
  if (actionsFilters.value.skillTag) {
    filtered = filtered.filter(a => String(a.skill_tag_id) === String(actionsFilters.value.skillTag))
  }
  
  // Level filter - through skill tag relationship (nested object structure)
  if (actionsFilters.value.level) {
    filtered = filtered.filter(a => String(a.skill_tags?.assessment_levels?.id) === String(actionsFilters.value.level))
  }
  
  // Framework filter - through skill tag relationship (nested object structure)
  if (actionsFilters.value.framework) {
    filtered = filtered.filter(a => String(a.skill_tags?.frameworks?.id) === String(actionsFilters.value.framework))
  }
  
  // Status filter - exact boolean comparison
  if (actionsFilters.value.status) {
    const isActive = actionsFilters.value.status === 'active'
    filtered = filtered.filter(a => Boolean(a.is_active) === isActive)
  }

  return filtered.sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
})

// Methods

const loadAllData = async () => {
  if (!adminSupabase) return

  try {
    console.log('Loading skill tags and reference data...')
    
    // Load all data in parallel
    const [skillTagsResult, tagInsightsResult, tagActionsResult, frameworksResult, competenciesResult, levelsResult, analysisTypesResult] = await Promise.all([
      // Skill tags with relationships
      adminSupabase
        .from('skill_tags')
        .select(`
          *,
          competency_display_names!competency_id (
            id, display_name
          ),
          frameworks!framework_id (
            id, name, code
          ),
          assessment_levels!assessment_level_id (
            id, level_code, level_name
          )
        `)
        .order('sort_order'),
      
      // Tag insights with relationships
      adminSupabase
        .from('tag_insights')
        .select(`
          *,
          skill_tags!skill_tag_id (
            id, name,
            competency_display_names!competency_id (
              id, display_name
            ),
            frameworks!framework_id (
              id, name, code
            ),
            assessment_levels!assessment_level_id (
              id, level_code, level_name
            )
          ),
          analysis_types!analysis_type_id (
            id, code, name
          )
        `)
        .order('created_at', { ascending: false }),
      
      // Tag actions with relationships
      adminSupabase
        .from('tag_actions')
        .select(`
          *,
          skill_tags!skill_tag_id (
            id, name,
            competency_display_names!competency_id (
              id, display_name
            ),
            frameworks!framework_id (
              id, name, code
            ),
            assessment_levels!assessment_level_id (
              id, level_code, level_name
            )
          )
        `)
        .order('created_at', { ascending: false }),
      
      // Reference data
      adminSupabase
        .from('frameworks')
        .select('id, name, code')
        .eq('is_active', true)
        .order('name'),
      
      adminSupabase
        .from('competency_display_names')
        .select('id, display_name')
        .eq('is_active', true)
        .order('display_name'),
      
      adminSupabase
        .from('assessment_levels')
        .select('id, level_code, level_name')
        .eq('is_active', true)
        .order('level_name'),
      
      adminSupabase
        .from('analysis_types')
        .select('id, code, name')
        .eq('is_active', true)
        .order('name')
    ])

    if (skillTagsResult.error) {
      console.error('Error loading skill tags:', skillTagsResult.error)
    } else {
      skillTags.value = skillTagsResult.data || []
      console.log('Loaded skill tags:', skillTags.value.length)
    }

    if (tagInsightsResult.error) {
      console.error('Error loading tag insights:', tagInsightsResult.error)
    } else {
      tagInsights.value = tagInsightsResult.data || []
    }

    if (tagActionsResult.error) {
      console.error('Error loading tag actions:', tagActionsResult.error)
    } else {
      tagActions.value = tagActionsResult.data || []
    }

    if (frameworksResult.error) {
      console.error('Error loading frameworks:', frameworksResult.error)
    } else {
      frameworks.value = frameworksResult.data || []
    }

    if (competenciesResult.error) {
      console.error('Error loading competencies:', competenciesResult.error)
    } else {
      competencies.value = competenciesResult.data || []
    }

    if (levelsResult.error) {
      console.error('Error loading levels:', levelsResult.error)
    } else {
      levels.value = levelsResult.data || []
    }

    if (analysisTypesResult.error) {
      console.error('Error loading analysis types:', analysisTypesResult.error)
    } else {
      analysisTypes.value = analysisTypesResult.data || []
    }

  } catch (error) {
    console.error('Error loading data:', error)
  }
}

const addSkillTag = () => {
  window.location.href = '/docs/admin/tags/edit'
}

const addTagInsight = () => {
  window.location.href = '/docs/admin/tags/insight-edit'
}

const addTagAction = () => {
  window.location.href = '/docs/admin/tags/action-edit'
}

const truncateText = (text, length) => {
  if (!text) return ''
  return text.length > length ? text.substring(0, length) + '...' : text
}

const editItem = (table, item) => {
  if (table === 'skill_tags') {
    window.location.href = `/docs/admin/tags/edit?id=${item.id}`
  } else if (table === 'tag_insights') {
    window.location.href = `/docs/admin/tags/insight-edit?id=${item.id}`
  } else if (table === 'tag_actions') {
    window.location.href = `/docs/admin/tags/action-edit?id=${item.id}`
  } else {
    alert(`Edit ${table} coming soon`)
  }
}

const deleteItem = async (table, item) => {
  if (!adminSupabase) {
    alert('Database connection not available')
    return
  }

  // Confirm deletion
  let itemName, confirmMessage
  
  if (table === 'skill_tags') {
    itemName = item.name
    confirmMessage = `Are you sure you want to delete "${itemName}"?\n\nThis will also delete all related insights and actions.\nThis action cannot be undone.`
  } else if (table === 'tag_insights') {
    itemName = `insight for ${item.skill_tags?.name || 'unknown skill'}`
    confirmMessage = `Are you sure you want to delete this ${itemName}?\n\nThis action cannot be undone.`
  } else if (table === 'tag_actions') {
    itemName = `action for ${item.skill_tags?.name || 'unknown skill'}`
    confirmMessage = `Are you sure you want to delete this ${itemName}?\n\nThis action cannot be undone.`
  } else {
    itemName = item.name || item.title || 'item'
    confirmMessage = `Are you sure you want to delete "${itemName}"?\n\nThis action cannot be undone.`
  }
  
  if (!confirm(confirmMessage)) {
    return
  }

  try {
    console.log(`Deleting ${table} item:`, item.id)
    
    const { error } = await adminSupabase
      .from(table)
      .delete()
      .eq('id', item.id)

    if (error) {
      console.error(`Error deleting ${table} item:`, error)
      alert(`Failed to delete item: ${error.message}`)
      return
    }

    console.log(`Successfully deleted ${table} item`)
    alert('Item deleted successfully!')
    
    // Reload data to reflect changes
    await loadAllData()
  } catch (error) {
    console.error(`Error deleting ${table} item:`, error)
    alert('Failed to delete item: ' + error.message)
  }
}

const exportTagInsights = () => {
  if (filteredTagInsights.value.length === 0) {
    alert('No insights to export. Please adjust your filters or load data first.')
    return
  }

  const data = filteredTagInsights.value.map((item, index) => ({
    id: item.id || '',
    skill_tag_id: item.skill_tag_id || '',
    skill_tag_name: item.skill_tags?.name || '',
    competency_name: item.skill_tags?.competency_display_names?.display_name || '',
    framework_name: item.skill_tags?.frameworks?.name || '',
    framework_code: item.skill_tags?.frameworks?.code || '',
    assessment_level: item.skill_tags?.assessment_levels?.level_name || '',
    analysis_type: item.analysis_types?.name || '',
    analysis_type_code: item.analysis_types?.code || '',
    insight_text: item.insight_text || '',
    sort_order: item.sort_order || 0,
    is_active: item.is_active !== false,
    created_at: item.created_at || '',
    updated_at: item.updated_at || ''
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
  const filterSuffix = insightsFilters.value.skillTag || insightsFilters.value.framework || insightsFilters.value.type 
    ? `_filtered` : ''
  a.download = `tag_insights_${timestamp}${filterSuffix}.csv`
  
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
  
  // Show success message
  alert(`Successfully exported ${data.length} tag insights to CSV file!`)
}

const exportTagActions = () => {
  if (filteredTagActions.value.length === 0) {
    alert('No actions to export. Please adjust your filters or load data first.')
    return
  }

  const data = filteredTagActions.value.map((item, index) => ({
    id: item.id || '',
    skill_tag_id: item.skill_tag_id || '',
    skill_tag_name: item.skill_tags?.name || '',
    competency_name: item.skill_tags?.competency_display_names?.display_name || '',
    framework_name: item.skill_tags?.frameworks?.name || '',
    framework_code: item.skill_tags?.frameworks?.code || '',
    assessment_level: item.skill_tags?.assessment_levels?.level_name || '',
    action_text: item.action_text || '',
    sort_order: item.sort_order || 0,
    is_active: item.is_active !== false,
    created_at: item.created_at || '',
    updated_at: item.updated_at || ''
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
  const filterSuffix = actionsFilters.value.skillTag || actionsFilters.value.framework 
    ? `_filtered` : ''
  a.download = `tag_actions_${timestamp}${filterSuffix}.csv`
  
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
  
  // Show success message
  alert(`Successfully exported ${data.length} tag actions to CSV file!`)
}

onMounted(async () => {
  isAuthLoaded.value = true
  await createSession()
  loadAllData()
})
</script>

<style scoped>
/* Use same base styles as AdminResourcesTabs */
.admin-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
}

.admin-header {
  margin-bottom: 30px;
}

.header-main h1 {
  font-size: 28px;
  margin-bottom: 8px;
}

.admin-subtitle {
  color: var(--vp-c-text-2);
  font-size: 14px;
}

.breadcrumb {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 32px;
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
  font-size: 13px;
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
  font-size: 16px;
}

.tab-label {
  font-size: 13px;
}

.tab-count {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand);
  padding: 2px 8px;
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

.section-header h2 {
  font-size: 24px;
  margin-bottom: 4px;
}

.section-description {
  color: var(--vp-c-text-2);
  font-size: 14px;
}

.header-actions {
  display: flex;
  gap: 1rem;
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
  gap: 20px;
}

.table-row {
  display: grid;
  padding: 20px 16px;
  border-bottom: 1px solid var(--vp-c-divider);
  align-items: start;
  transition: background 0.2s;
  gap: 20px;
}

.table-row:hover {
  background: var(--vp-c-bg-soft);
}

.table-row:last-child {
  border-bottom: none;
}

/* Grid layouts - optimized to prevent level wrapping */
.skill-tags-grid {
  grid-template-columns: 3fr 140px 100px 110px 140px;
}

.insights-grid {
  grid-template-columns: 3fr 140px 100px 120px 140px;
}

.actions-grid {
  grid-template-columns: 3fr 140px 100px 120px 140px;
}

/* Column Styles - Rich Insights pattern */
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
.col-actions {
  display: flex;
  align-items: center;
}

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

.level-badge,
.insights-grid .level-badge,
.actions-grid .level-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  white-space: nowrap;
}

.level-badge.foundational,
.level-badge.beginner,
.level-badge.core-beginner,
.level-badge.icf-beginner,
.level-badge.ac-beginner,
.insights-grid .level-badge.foundational,
.insights-grid .level-badge.beginner,
.insights-grid .level-badge.core-beginner,
.insights-grid .level-badge.icf-beginner,
.insights-grid .level-badge.ac-beginner,
.actions-grid .level-badge.foundational,
.actions-grid .level-badge.beginner,
.actions-grid .level-badge.core-beginner,
.actions-grid .level-badge.icf-beginner,
.actions-grid .level-badge.ac-beginner {
  background: var(--vp-c-blue-soft);
  color: var(--vp-c-blue);
}

.level-badge.developing,
.level-badge.intermediate,
.level-badge.core-intermediate,
.level-badge.icf-intermediate,
.level-badge.ac-intermediate,
.insights-grid .level-badge.developing,
.insights-grid .level-badge.intermediate,
.insights-grid .level-badge.core-intermediate,
.insights-grid .level-badge.icf-intermediate,
.insights-grid .level-badge.ac-intermediate,
.actions-grid .level-badge.developing,
.actions-grid .level-badge.intermediate,
.actions-grid .level-badge.core-intermediate,
.actions-grid .level-badge.icf-intermediate,
.actions-grid .level-badge.ac-intermediate {
  background: var(--vp-c-yellow-soft);
  color: var(--vp-c-yellow-darker);
}

.level-badge.advanced,
.level-badge.core-advanced,
.level-badge.icf-advanced,
.level-badge.ac-advanced,
.insights-grid .level-badge.advanced,
.insights-grid .level-badge.core-advanced,
.insights-grid .level-badge.icf-advanced,
.insights-grid .level-badge.ac-advanced,
.actions-grid .level-badge.advanced,
.actions-grid .level-badge.core-advanced,
.actions-grid .level-badge.icf-advanced,
.actions-grid .level-badge.ac-advanced {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
}

.level-badge:not(.foundational):not(.beginner):not(.developing):not(.intermediate):not(.advanced):not(.core-beginner):not(.icf-beginner):not(.ac-beginner):not(.core-intermediate):not(.icf-intermediate):not(.ac-intermediate):not(.core-advanced):not(.icf-advanced):not(.ac-advanced) {
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-2);
}

.type-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  white-space: nowrap;
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-2);
}

.type-badge.weakness {
  background: var(--vp-c-red-soft);
  color: var(--vp-c-red);
}

.type-badge.strength {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
}

.type-badge.curious,
.type-badge.curiosity {
  background: var(--vp-c-indigo-soft);
  color: var(--vp-c-indigo);
}

.type-badge.insight,
.type-badge.observation {
  background: var(--vp-c-blue-soft);
  color: var(--vp-c-blue);
}

.type-badge.opportunity,
.type-badge.growth {
  background: var(--vp-c-purple-soft);
  color: var(--vp-c-purple);
}

.skill-name {
  font-weight: 500;
  color: var(--vp-c-text-1);
}

.insight-text,
.action-text {
  color: var(--vp-c-text-2);
  line-height: 1.4;
}

.status-badge {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 500;
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-3);
}

.status-badge.active {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
}

/* Action Buttons - match pattern exactly */
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

/* Specific table layouts - removed old overrides */

@media (max-width: 1200px) {
  .skill-tags-grid {
    grid-template-columns: 3fr 130px 90px 90px 120px;
  }
  
  .insights-grid {
    grid-template-columns: 3fr 120px 90px 100px 120px;
  }
  
  .actions-grid {
    grid-template-columns: 3fr 120px 90px 100px 120px;
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
  
  .skill-tags-grid,
  .insights-grid,
  .actions-grid {
    grid-template-columns: 1fr;
    gap: 8px;
  }
  
  .table-header {
    display: none;
  }
  
  .table-row {
    grid-template-columns: 1fr;
    gap: 8px;
    border: 1px solid var(--vp-c-border);
    border-radius: 6px;
    margin-bottom: 12px;
    padding: 16px;
  }
  
  .table-row::before {
    content: "Skill Tag";
    font-weight: 600;
    color: var(--vp-c-text-2);
    font-size: 12px;
    text-transform: uppercase;
  }
  
  .col-name::before {
    content: "Name: ";
    font-weight: 600;
    color: var(--vp-c-text-2);
  }
  
  .col-competency::before {
    content: "Competency: ";
    font-weight: 600;
    color: var(--vp-c-text-2);
  }
  
  .col-framework::before {
    content: "Framework: ";
    font-weight: 600;
    color: var(--vp-c-text-2);
  }
  
  .col-level::before {
    content: "Level: ";
    font-weight: 600;
    color: var(--vp-c-text-2);
  }
  
  .col-order::before {
    content: "Order: ";
    font-weight: 600;
    color: var(--vp-c-text-2);
  }
  
  .col-status::before {
    content: "Status: ";
    font-weight: 600;
    color: var(--vp-c-text-2);
  }
  
  .col-insight::before {
    content: "Insight: ";
    font-weight: 600;
    color: var(--vp-c-text-2);
  }
  
  .col-action::before {
    content: "Action: ";
    font-weight: 600;
    color: var(--vp-c-text-2);
  }
  
  .col-type::before {
    content: "Type: ";
    font-weight: 600;
    color: var(--vp-c-text-2);
  }
  
  .col-skill::before {
    content: "Skill: ";
    font-weight: 600;
    color: var(--vp-c-text-2);
  }
}
</style>