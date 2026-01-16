<template>
  <div class="admin-container">
    <!-- Loading state during auth check -->
    <AdminLoadingState v-if="!isAuthLoaded" />

    <!-- Admin Access Check -->
    <div v-else-if="!hasAdminAccess" class="admin-content">
      <div class="admin-header">
        <h1>⚠️ Admin Access Required</h1>
        <p class="admin-subtitle">You need administrator privileges to manage learning resources.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- Learning Resources Management with Tabs -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>📖 Learning Resources & Skills</h1>
          <p class="admin-subtitle">Content and skill tagging system - enhances competency-based assessments</p>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>Learning Resources</span>
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
          <span class="tab-count">{{ tab.count }}</span>
        </button>
      </div>

      <!-- Tab Content -->
      <div class="tab-content">
        <!-- Learning Resources Tab -->
        <div v-show="activeTab === 'learning_resources'" class="table-section">
          <div class="section-header">
            <div>
              <h2>Learning Resources</h2>
              <p class="section-description">Articles, videos, guides linked to competencies - content to enhance learning</p>
            </div>
            <ActionButton @click="addResource" icon="➕">Add Resource</ActionButton>
          </div>

          <div class="filter-bar">
            <select v-model="resourceFilters.type" class="filter-select">
              <option value="">All Types</option>
              <option value="article">Articles</option>
              <option value="video">Videos</option>
              <option value="guide">Guides</option>
              <option value="tool">Tools</option>
              <option value="exercise">Exercises</option>
            </select>
            <select v-model="resourceFilters.analysisType" class="filter-select">
              <option value="">All Analysis Types</option>
              <option v-for="analysisType in uniqueAnalysisTypes" :key="analysisType" :value="analysisType">
                {{ analysisType }}
              </option>
            </select>
            <select v-model="resourceFilters.difficulty" class="filter-select">
              <option value="">All Levels</option>
              <option value="beginner">Beginner</option>
              <option value="intermediate">Intermediate</option>
              <option value="advanced">Advanced</option>
            </select>
          </div>

          <AdminTableHeader :columns="tableConfigs.learning_resources">
            
            <div v-for="item in filteredResources" :key="item.id" class="table-row">
              <div class="col-name">
                <div class="item-main">{{ item.title }}</div>
                <div class="item-description">{{ truncate(item.description, 60) }}</div>
                <div v-if="item.url" class="item-url">
                  <a :href="item.url" target="_blank" rel="noopener">{{ truncateUrl(item.url) }}</a>
                </div>
              </div>
              <div class="col-type">
                <span class="type-badge">
                  {{ item.resource_types?.name || 'N/A' }}
                </span>
              </div>
              <div class="col-analysis-type">
                <span class="analysis-type-badge">
                  {{ item.analysis_types?.name || 'N/A' }}
                </span>
              </div>
              <div class="col-level">
                <span class="level-badge" :class="getLevelClass(item.assessment_levels?.level_name)">
                  {{ item.assessment_levels?.level_name || 'N/A' }}
                </span>
              </div>
              <div class="col-status">
                <span class="status-badge" :class="{ active: item.is_active }">
                  {{ item.is_active ? 'Active' : 'Inactive' }}
                </span>
              </div>
              <div class="col-actions">
                <button @click="editItem('learning_resources', item)" class="action-btn">Edit</button>
                <button @click="deleteItem('learning_resources', item)" class="action-btn danger">Delete</button>
              </div>
            </div>
          </AdminTableHeader>
        </div>

        <!-- Skill Tags Tab -->
        <div v-show="activeTab === 'skill_tags'" class="table-section">
          <div class="section-header">
            <div>
              <h2>Skill Tags</h2>
              <p class="section-description">Categorization system for competencies and skills - improves discovery</p>
            </div>
            <ActionButton @click="addSkillTag" icon="➕">Add Skill Tag</ActionButton>
          </div>

          <div class="data-table">
            <div class="table-header">
              <div class="col-name">Tag Name</div>
              <div class="col-text">Description</div>
              <div class="col-category">Category</div>
              <div class="col-color">Color</div>
              <div class="col-status">Status</div>
              <div class="col-actions">Actions</div>
            </div>
            
            <div v-for="item in skillTags" :key="item.id" class="table-row">
              <div class="col-name">
                <div class="tag-display">
                  <span class="tag-preview" :style="{ backgroundColor: item.color || '#ccc' }"></span>
                  {{ item.name }}
                </div>
              </div>
              <div class="col-text">{{ truncate(item.description, 50) }}</div>
              <div class="col-category">{{ item.category || 'N/A' }}</div>
              <div class="col-color">
                <div class="color-swatch" :style="{ backgroundColor: item.color || '#ccc' }">
                  {{ item.color || 'N/A' }}
                </div>
              </div>
              <div class="col-status">
                <span class="status-badge" :class="{ active: item.is_active }">
                  {{ item.is_active ? 'Active' : 'Inactive' }}
                </span>
              </div>
              <div class="col-actions">
                <button @click="editItem('skill_tags', item)" class="action-btn">Edit</button>
              </div>
            </div>
          </div>
        </div>

        <!-- Tag Insights Tab -->
        <div v-show="activeTab === 'tag_insights'" class="table-section">
          <div class="section-header">
            <div>
              <h2>Tag Insights</h2>
              <p class="section-description">Insights and guidance linked to skill tags</p>
            </div>
            <ActionButton @click="addTagInsight" icon="➕">Add Insight</ActionButton>
          </div>

          <div class="data-table">
            <div class="table-header">
              <div class="col-name">Tag</div>
              <div class="col-text">Insight Text</div>
              <div class="col-type">Insight Type</div>
              <div class="col-status">Status</div>
              <div class="col-actions">Actions</div>
            </div>
            
            <div v-for="item in tagInsights" :key="item.id" class="table-row">
              <div class="col-name">{{ getTagName(item.tag_id) }}</div>
              <div class="col-text">{{ truncate(item.insight_text, 80) }}</div>
              <div class="col-type">
                <span class="type-badge">{{ item.insight_type || 'General' }}</span>
              </div>
              <div class="col-status">
                <span class="status-badge" :class="{ active: item.is_active }">
                  {{ item.is_active ? 'Active' : 'Inactive' }}
                </span>
              </div>
              <div class="col-actions">
                <button @click="editItem('tag_insights', item)" class="action-btn">Edit</button>
              </div>
            </div>
          </div>
        </div>

        <!-- Tag Actions Tab -->
        <div v-show="activeTab === 'tag_actions'" class="table-section">
          <div class="section-header">
            <div>
              <h2>Tag Actions</h2>
              <p class="section-description">Recommended actions and next steps linked to skill tags</p>
            </div>
            <ActionButton @click="addTagAction" icon="➕">Add Action</ActionButton>
          </div>

          <div class="data-table">
            <div class="table-header">
              <div class="col-name">Tag</div>
              <div class="col-text">Action Description</div>
              <div class="col-priority">Priority</div>
              <div class="col-type">Action Type</div>
              <div class="col-actions">Actions</div>
            </div>
            
            <div v-for="item in tagActions" :key="item.id" class="table-row">
              <div class="col-name">{{ getTagName(item.tag_id) }}</div>
              <div class="col-text">{{ truncate(item.action_description, 70) }}</div>
              <div class="col-priority">
                <span class="priority-badge" :class="item.priority">
                  {{ item.priority || 'Medium' }}
                </span>
              </div>
              <div class="col-type">
                <span class="type-badge">{{ item.action_type || 'General' }}</span>
              </div>
              <div class="col-actions">
                <button @click="editItem('tag_actions', item)" class="action-btn">Edit</button>
              </div>
            </div>
          </div>
        </div>

        <!-- Learning Logs Tab -->
        <div v-show="activeTab === 'learning_logs'" class="table-section">
          <div class="section-header">
            <div>
              <h2>Learning Logs</h2>
              <p class="section-description">User learning activity tracking and progress logs</p>
            </div>
          </div>

          <div class="filter-bar">
            <input 
              v-model="logFilters.userId" 
              type="text" 
              class="filter-input"
              placeholder="Search by User ID..."
            >
            <select v-model="logFilters.activity" class="filter-select">
              <option value="">All Activities</option>
              <option value="resource_viewed">Resource Viewed</option>
              <option value="assessment_completed">Assessment Completed</option>
              <option value="skill_practiced">Skill Practiced</option>
              <option value="goal_set">Goal Set</option>
            </select>
          </div>

          <div class="data-table">
            <div class="table-header">
              <div class="col-id">User ID</div>
              <div class="col-type">Activity</div>
              <div class="col-text">Description</div>
              <div class="col-date">Date</div>
              <div class="col-actions">Actions</div>
            </div>
            
            <div v-for="item in filteredLogs" :key="item.id" class="table-row">
              <div class="col-id">{{ truncateId(item.user_id) }}</div>
              <div class="col-type">
                <span class="type-badge">{{ item.activity_type }}</span>
              </div>
              <div class="col-text">{{ truncate(item.description, 60) }}</div>
              <div class="col-date">{{ formatDate(item.created_at) }}</div>
              <div class="col-actions">
                <button @click="viewLogDetails(item)" class="action-btn">View</button>
              </div>
            </div>
          </div>
        </div>

        <!-- Learning Path Categories Tab -->
        <div v-show="activeTab === 'path_categories'" class="table-section">
          <div class="section-header">
            <div>
              <h2>Learning Path Categories</h2>
              <p class="section-description">Categories for organizing learning paths and resources</p>
            </div>
            <ActionButton @click="addPathCategory" icon="➕">Add Category</ActionButton>
          </div>

          <div class="data-table">
            <div class="table-header">
              <div class="col-name">Category Name</div>
              <div class="col-text">Description</div>
              <div class="col-stats">Resource Count</div>
              <div class="col-status">Status</div>
              <div class="col-actions">Actions</div>
            </div>
            
            <div v-for="item in pathCategories" :key="item.id" class="table-row">
              <div class="col-name">{{ item.name }}</div>
              <div class="col-text">{{ truncate(item.description, 60) }}</div>
              <div class="col-stats">{{ getResourceCount(item.id) }}</div>
              <div class="col-status">
                <span class="status-badge" :class="{ active: item.is_active }">
                  {{ item.is_active ? 'Active' : 'Inactive' }}
                </span>
              </div>
              <div class="col-actions">
                <button @click="editItem('path_categories', item)" class="action-btn">Edit</button>
              </div>
            </div>
          </div>
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

const { hasAdminAccess } = useAdminSession()
const { adminSupabase } = useAdminSupabase()

// Authentication loading state
const isAuthLoaded = ref(false)

// Active tab
const activeTab = ref('learning_resources')

// Data
const learningResources = ref([])
const skillTags = ref([])
const tagInsights = ref([])
const tagActions = ref([])
const learningLogs = ref([])
const pathCategories = ref([])

// Table configurations for AdminTableHeader
const tableConfigs = {
  learning_resources: [
    { label: 'Resource & Description', width: '3fr' },
    { label: 'Type', width: '1fr' },
    { label: 'Analysis Type', width: '1.3fr' },
    { label: 'Level', width: '1.3fr' },
    { label: 'Status', width: '90px' },
    { label: 'Actions', width: '160px' }
  ],
  skill_tags: [
    { label: 'Tag Name', width: '2fr' },
    { label: 'Description', width: '2fr' },
    { label: 'Category', width: '1fr' },
    { label: 'Color', width: '1fr' },
    { label: 'Status', width: '100px' },
    { label: 'Actions', width: '140px' }
  ],
  tag_insights: [
    { label: 'Tag', width: '1fr' },
    { label: 'Insight Text', width: '3fr' },
    { label: 'Insight Type', width: '1fr' },
    { label: 'Status', width: '100px' },
    { label: 'Actions', width: '140px' }
  ],
  tag_actions: [
    { label: 'Tag', width: '1fr' },
    { label: 'Action Description', width: '3fr' },
    { label: 'Priority', width: '1fr' },
    { label: 'Action Type', width: '1fr' },
    { label: 'Actions', width: '140px' }
  ],
  learning_logs: [
    { label: 'User', width: '1fr' },
    { label: 'Activity', width: '2fr' },
    { label: 'Resource', width: '2fr' },
    { label: 'Timestamp', width: '1fr' },
    { label: 'Status', width: '100px' },
    { label: 'Actions', width: '140px' }
  ],
  path_categories: [
    { label: 'Category', width: '2fr' },
    { label: 'Description', width: '2fr' },
    { label: 'Resources', width: '1fr' },
    { label: 'Level', width: '1fr' },
    { label: 'Status', width: '100px' },
    { label: 'Actions', width: '140px' }
  ]
}

// Filters
const resourceFilters = ref({
  type: '',
  analysisType: '',
  difficulty: ''
})

const logFilters = ref({
  userId: '',
  activity: ''
})

// Table tabs configuration
const tableTabs = computed(() => [
  {
    id: 'learning_resources',
    label: 'Learning Resources',
    icon: '📖',
    count: learningResources.value.length,
    description: 'Content library'
  },
  {
    id: 'skill_tags',
    label: 'Skill Tags',
    icon: '🏷️',
    count: skillTags.value.length,
    description: 'Categorization system'
  },
  {
    id: 'tag_insights',
    label: 'Tag Insights',
    icon: '💡',
    count: tagInsights.value.length,
    description: 'Tag-based guidance'
  },
  {
    id: 'tag_actions',
    label: 'Tag Actions',
    icon: '🎯',
    count: tagActions.value.length,
    description: 'Recommended actions'
  },
  {
    id: 'learning_logs',
    label: 'Learning Logs',
    icon: '📝',
    count: learningLogs.value.length,
    description: 'User activity tracking'
  },
  {
    id: 'path_categories',
    label: 'Path Categories',
    icon: '📂',
    count: pathCategories.value.length,
    description: 'Learning path organization'
  }
])

// Computed
const uniqueAnalysisTypes = computed(() => {
  const analysisTypes = learningResources.value.map(r => r.analysis_types?.name).filter(Boolean)
  return [...new Set(analysisTypes)].sort()
})

const filteredResources = computed(() => {
  let filtered = learningResources.value
  
  if (resourceFilters.value.type) {
    filtered = filtered.filter(r => r.resource_type === resourceFilters.value.type)
  }
  
  if (resourceFilters.value.analysisType) {
    filtered = filtered.filter(r => r.analysis_types?.name === resourceFilters.value.analysisType)
  }
  
  if (resourceFilters.value.difficulty) {
    filtered = filtered.filter(r => r.difficulty_level === resourceFilters.value.difficulty)
  }
  
  return filtered
})

const filteredLogs = computed(() => {
  let filtered = learningLogs.value
  
  if (logFilters.value.userId) {
    const searchTerm = logFilters.value.userId.toLowerCase()
    filtered = filtered.filter(l => 
      l.user_id?.toLowerCase().includes(searchTerm)
    )
  }
  
  if (logFilters.value.activity) {
    filtered = filtered.filter(l => l.activity_type === logFilters.value.activity)
  }
  
  return filtered.sort((a, b) => 
    new Date(b.created_at) - new Date(a.created_at)
  )
})

// Methods
const truncate = (text, length) => {
  if (!text) return ''
  return text.length > length ? text.substring(0, length) + '...' : text
}

const truncateId = (id) => {
  if (!id) return ''
  return id.length > 8 ? id.substring(0, 8) + '...' : id
}

const truncateUrl = (url) => {
  if (!url) return ''
  try {
    const domain = new URL(url).hostname
    return domain.length > 30 ? domain.substring(0, 30) + '...' : domain
  } catch {
    return url.length > 30 ? url.substring(0, 30) + '...' : url
  }
}

const formatType = (type) => {
  if (!type) return 'N/A'
  return type.charAt(0).toUpperCase() + type.slice(1)
}

const getLevelClass = (levelName) => {
  if (!levelName) return 'unknown'
  if (levelName.toLowerCase().includes('beginner')) return 'beginner'
  if (levelName.toLowerCase().includes('intermediate')) return 'intermediate'
  if (levelName.toLowerCase().includes('advanced')) return 'advanced'
  return 'unknown'
}

const deleteItem = (table, item) => {
  if (confirm(`Are you sure you want to delete this ${table.replace('_', ' ')}?`)) {
    alert(`Delete functionality for ${table} coming soon`)
  }
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString() + ' ' + 
         new Date(dateString).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
}

const getTagName = (tagId) => {
  const tag = skillTags.value.find(t => t.id === tagId)
  return tag?.name || 'Unknown Tag'
}

const getResourceCount = (categoryId) => {
  return learningResources.value.filter(r => r.category_id === categoryId).length
}

const loadAllData = async () => {
  if (!adminSupabase) return

  try {
    // Load learning resources with related data using simple join syntax
    const { data: resourcesData, error: resourcesError } = await adminSupabase
      .from('learning_resources')
      .select(`
        *,
        resource_types(name),
        assessment_levels(level_name),
        frameworks(name),
        analysis_types(name)
      `)
      .order('created_at', { ascending: false })
    
    if (resourcesError) {
      console.error('Error loading learning resources:', resourcesError)
    } else {
      learningResources.value = resourcesData || []
    }

    // Load skill tags
    const { data: tagsData } = await adminSupabase
      .from('skill_tags')
      .select('*')
      .order('name')
    skillTags.value = tagsData || []

    // Load tag insights
    const { data: insightsData } = await adminSupabase
      .from('tag_insights')
      .select('*')
      .order('created_at', { ascending: false })
    tagInsights.value = insightsData || []

    // Load tag actions
    const { data: actionsData } = await adminSupabase
      .from('tag_actions')
      .select('*')
      .order('priority, created_at')
    tagActions.value = actionsData || []

    // Load learning logs
    const { data: logsData } = await adminSupabase
      .from('learning_logs')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(200) // Limit for performance
    learningLogs.value = logsData || []

    // Load learning path categories
    const { data: categoriesData } = await adminSupabase
      .from('learning_path_categories')
      .select('*')
      .order('name')
    pathCategories.value = categoriesData || []
  } catch (error) {
    console.error('Error loading data:', error)
  }
}

const addResource = () => {
  alert('Learning Resource editor coming soon')
}

const addSkillTag = () => {
  alert('Skill Tag editor coming soon')
}

const addTagInsight = () => {
  alert('Tag Insight editor coming soon')
}

const addTagAction = () => {
  alert('Tag Action editor coming soon')
}

const addPathCategory = () => {
  alert('Path Category editor coming soon')
}

const editItem = (table, item) => {
  alert(`Edit ${table} coming soon`)
}

const viewLogDetails = (log) => {
  alert(`Learning Log Details:\n\nUser: ${log.user_id}\nActivity: ${log.activity_type}\nDescription: ${log.description}\nDate: ${formatDate(log.created_at)}\n\n(Detailed view coming soon)`)
}

onMounted(() => {
  isAuthLoaded.value = true
  loadAllData()
})
</script>

<style scoped>
/* Reuse the same base styles as other tabbed interfaces */
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
  gap: 6px;
  padding: 8px 12px;
  background: transparent;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  white-space: nowrap;
  transition: all 0.2s;
  color: var(--vp-c-text-2);
  font-size: 12px;
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
  font-size: 14px;
}

.tab-label {
  font-size: 12px;
}

.tab-count {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand);
  padding: 2px 6px;
  border-radius: 8px;
  font-size: 10px;
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

/* Filter Bar */
.filter-bar {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.filter-select,
.filter-input {
  padding: 8px 12px;
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  background: var(--vp-c-bg);
  font-size: 14px;
}

.filter-input {
  min-width: 200px;
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
  grid-template-columns: 3fr 1fr 1.3fr 1.3fr 90px 160px;
  padding: 12px 16px;
  background: var(--vp-c-bg-soft);
  border-bottom: 1px solid var(--vp-c-border);
  font-weight: 600;
  font-size: 12px;
  text-transform: uppercase;
  color: var(--vp-c-text-2);
  gap: 8px;
}

.table-row {
  display: grid;
  grid-template-columns: 3fr 1fr 1.3fr 1.3fr 90px 160px;
  padding: 14px 16px;
  border-bottom: 1px solid var(--vp-c-divider);
  align-items: center;
  transition: background 0.2s;
  font-size: 14px;
  gap: 8px;
}

.table-row:hover {
  background: var(--vp-c-bg-soft);
}

.table-row:last-child {
  border-bottom: none;
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

.item-url a {
  font-size: 11px;
  color: var(--vp-c-brand);
  text-decoration: none;
}

.item-url a:hover {
  text-decoration: underline;
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

.col-type,
.col-analysis-type,
.col-level,
.col-category,
.col-priority,
.col-status,
.col-stats,
.col-date {
  display: flex;
  align-items: center;
  font-size: 13px;
}

.col-actions {
  display: flex;
  gap: 6px;
}

/* Special Styles */
.tag-display {
  display: flex;
  align-items: center;
  gap: 8px;
}

.tag-preview {
  width: 12px;
  height: 12px;
  border-radius: 2px;
  border: 1px solid var(--vp-c-border);
}

.color-swatch {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 60px;
  height: 24px;
  border-radius: 4px;
  font-size: 10px;
  color: white;
  text-shadow: 1px 1px 1px rgba(0, 0, 0, 0.5);
  border: 1px solid var(--vp-c-border);
}

/* Badges */
.type-badge {
  display: inline-block;
  padding: 3px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 500;
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-2);
}

.type-badge {
  white-space: nowrap;
}

.type-badge.article,
.type-badge.Articles {
  background: var(--vp-c-blue-soft);
  color: var(--vp-c-blue);
}

.type-badge.video,
.type-badge.Videos {
  background: var(--vp-c-red-soft);
  color: var(--vp-c-red);
}

.type-badge.guide,
.type-badge.Guides {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
}

.type-badge.tool,
.type-badge.Tools {
  background: var(--vp-c-purple-soft);
  color: var(--vp-c-purple);
}

.type-badge.Books {
  background: var(--vp-c-yellow-soft);
  color: var(--vp-c-yellow-darker);
}

.type-badge.Courses {
  background: var(--vp-c-indigo-soft);
  color: var(--vp-c-indigo);
}

.level-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 500;
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-2);
  white-space: nowrap;
}

.level-badge.beginner {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
}

.level-badge.intermediate {
  background: var(--vp-c-yellow-soft);
  color: var(--vp-c-yellow-darker);
}

.level-badge.advanced {
  background: var(--vp-c-red-soft);
  color: var(--vp-c-red);
}

.level-badge.unknown {
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-3);
}

.analysis-type-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 500;
  background: var(--vp-c-purple-soft);
  color: var(--vp-c-purple);
  white-space: nowrap;
}

.action-btn.danger {
  background: var(--vp-c-danger-soft);
  color: var(--vp-c-danger);
}

.action-btn.danger:hover {
  background: var(--vp-c-danger);
  color: white;
}

.priority-badge {
  display: inline-block;
  padding: 3px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 500;
  text-transform: capitalize;
}

.priority-badge.high {
  background: var(--vp-c-danger-soft);
  color: var(--vp-c-danger);
}

.priority-badge.medium {
  background: var(--vp-c-yellow-soft);
  color: var(--vp-c-yellow-darker);
}

.priority-badge.low {
  background: var(--vp-c-blue-soft);
  color: var(--vp-c-blue);
}

.status-badge {
  display: inline-block;
  padding: 3px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 500;
  background: var(--vp-c-danger-soft);
  color: var(--vp-c-danger);
}

.status-badge.active {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
}

/* Actions */
.action-btn {
  padding: 4px 12px;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand);
  border: none;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.action-btn:hover {
  background: var(--vp-c-brand);
  color: white;
}
</style>