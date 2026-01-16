<template>
  <div class="admin-container" :data-active-tab="activeTab">
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
          <h1>📖 Learning Resources Management</h1>
          <p class="admin-subtitle">Content library system - articles, videos, guides linked to competencies</p>
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
          <span class="tab-count" :class="{ filtered: tab.count !== tab.total }">
            {{ tab.count }}{{ tab.count !== tab.total ? `/${tab.total}` : '' }}
          </span>
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

          <!-- Filters -->
          <div class="filter-bar">
            <input 
              v-model="resourceFilters.search"
              type="text" 
              placeholder="Search resources..."
              class="filter-input"
            >
            <select v-model="resourceFilters.type" class="filter-select">
              <option value="">All Types</option>
              <option v-for="type in uniqueResourceTypes" :key="type.code" :value="type.code">
                {{ type.name }}
              </option>
            </select>
            <select v-model="resourceFilters.analysisType" class="filter-select">
              <option value="">All Analysis Types</option>
              <option v-for="analysisType in uniqueAnalysisTypes" :key="analysisType" :value="analysisType">
                {{ analysisType }}
              </option>
            </select>
            <select v-model="resourceFilters.difficulty" class="filter-select">
              <option value="">All Levels</option>
              <option v-for="level in uniqueDifficultyLevels" :key="level.level_code" :value="level.level_code">
                {{ level.level_name }}
              </option>
            </select>
            <select v-model="resourceFilters.status" class="filter-select">
              <option value="">All Status</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>

          <AdminTableHeader :columns="resourceTableColumns">
            <div v-for="item in filteredResources" :key="item.id" class="table-row learning-resources-grid">
              <div class="col-resource">
                <div class="competency-name">{{ item.title }}</div>
                <div class="insight-text">
                  {{ buildResourcePreview(item) }}
                  <div v-if="item.url" class="resource-url">
                    <a :href="item.url" target="_blank" rel="noopener" class="url-link">
                      {{ truncateUrl(item.url) }}
                    </a>
                  </div>
                </div>
              </div>
              <div class="col-type">
                <span class="resource-type-text">
                  {{ item.resource_types?.name || 'Unknown' }}
                </span>
              </div>
              <div class="col-analysis-type">
                <span class="analysis-type-badge" :class="getAnalysisTypeClass(item.analysis_types?.name)">
                  {{ item.analysis_types?.name || 'N/A' }}
                </span>
              </div>
              <div class="col-level">
                <span class="level-badge" :class="item.assessment_levels?.level_code?.toLowerCase()">
                  {{ item.assessment_levels?.level_name || 'N/A' }}
                </span>
              </div>
              <div class="col-status">
                <span class="status-badge" :class="{ active: item.is_active }">
                  {{ item.is_active ? 'Active' : 'Inactive' }}
                </span>
              </div>
              <div class="col-actions">
                <button @click="editItem('learning_resources', item)" class="action-btn edit">Edit</button>
                <button @click="deleteItem('learning_resources', item)" class="action-btn delete">Delete</button>
              </div>
            </div>
            
            <div v-if="filteredResources.length === 0" class="empty-state">
              <p>{{ resourceFilters.search || resourceFilters.type || resourceFilters.competency || resourceFilters.difficulty || resourceFilters.status ? 'No resources match the current filters.' : 'No resources found.' }}</p>
            </div>
          </AdminTableHeader>
        </div>


        <!-- Learning Path Categories Tab -->
        <div v-show="activeTab === 'path_categories'" class="table-section path-categories-tab">
          <div class="section-header">
            <div>
              <h2>Learning Path Categories</h2>
              <p class="section-description">Categories for organizing learning paths and resources</p>
            </div>
            <ActionButton @click="addPathCategory" icon="➕">Add Category</ActionButton>
          </div>

          <AdminTableHeader :columns="pathCategoryTableColumns">
            <div v-for="item in pathCategories" :key="item.id" class="table-row">
              <div class="col-name">
                <div class="item-main">
                  <span class="category-icon">{{ item.category_icon }}</span>
                  {{ item.category_title }}
                </div>
              </div>
              <div class="col-text">{{ truncate(item.category_description, 60) }}</div>
              <div class="col-competencies">
                <div v-if="item.competency_areas && item.competency_areas.length" class="competency-tags">
                  <span v-for="area in item.competency_areas.slice(0, 2)" :key="area" class="competency-tag">
                    {{ area }}
                  </span>
                  <span v-if="item.competency_areas.length > 2" class="more-tag">
                    +{{ item.competency_areas.length - 2 }} more
                  </span>
                </div>
                <span v-else class="no-data">No areas</span>
              </div>
              <div class="col-level">
                <span class="level-badge" :class="item.assessment_levels?.level_code">
                  {{ item.assessment_levels?.level_name || 'N/A' }}
                </span>
              </div>
              <div class="col-status">
                <span class="status-badge" :class="{ active: item.is_active }">
                  {{ item.is_active ? 'Active' : 'Inactive' }}
                </span>
              </div>
              <div class="col-actions">
                <button @click="editItem('learning_path_categories', item)" class="action-btn edit">Edit</button>
                <button @click="deleteItem('learning_path_categories', item)" class="action-btn delete">Delete</button>
              </div>
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
import { useBadges } from '../composables/shared/useBadges'
import ActionButton from './shared/ActionButton.vue'
import AdminLoadingState from './shared/AdminLoadingState.vue'
import AdminTableHeader from './shared/AdminTableHeader.vue'

const { hasAdminAccess, createSession } = useAdminSession()
const { adminSupabase } = useAdminSupabase()
const { getLevelClass, getAnalysisTypeClass, injectBadgeStyles } = useBadges()

// Authentication loading state
const isAuthLoaded = ref(false)

// Active tab
const activeTab = ref('learning_resources')

// Data
const learningResources = ref([])
const pathCategories = ref([])

// Filters
const resourceFilters = ref({
  search: '',
  type: '',
  analysisType: '',
  difficulty: '',
  status: ''
})

// Table configurations for AdminTableHeader
const resourceTableColumns = [
  { label: 'Resource & Description', width: '3fr' },
  { label: 'Type', width: '110px' },
  { label: 'Analysis Type', width: '140px' },
  { label: 'Level', width: '140px' },
  { label: 'Status', width: '100px' },
  { label: 'Actions', width: '140px' }
]

const pathCategoryTableColumns = [
  { label: 'Category Title', width: '2fr' },
  { label: 'Description', width: '2fr' },
  { label: 'Competency Areas', width: '1.5fr' },
  { label: 'Assessment Level', width: '1fr' },
  { label: 'Status', width: '100px' },
  { label: 'Actions', width: '140px' }
]

// Table tabs configuration - with filtered counts
const tableTabs = computed(() => [
  {
    id: 'learning_resources',
    label: 'Learning Resources',
    icon: '📖',
    count: filteredResources.value.length,
    total: learningResources.value.length,
    description: 'Content library'
  },
  {
    id: 'path_categories',
    label: 'Path Categories',
    icon: '📂',
    count: pathCategories.value.length,
    total: pathCategories.value.length,
    description: 'Learning path organization'
  }
])

// Computed - using pure relational structure
const uniqueAnalysisTypes = computed(() => {
  const analysisTypes = learningResources.value
    .map(r => r.analysis_types?.name)
    .filter(Boolean)
  return [...new Set(analysisTypes)].sort()
})

const uniqueResourceTypes = computed(() => {
  const types = learningResources.value
    .map(r => r.resource_types)
    .filter(Boolean)
  // Remove duplicates by code
  const uniqueTypes = []
  const seenCodes = new Set()
  for (const type of types) {
    if (!seenCodes.has(type.code)) {
      seenCodes.add(type.code)
      uniqueTypes.push(type)
    }
  }
  return uniqueTypes.sort((a, b) => a.name.localeCompare(b.name))
})

const uniqueDifficultyLevels = computed(() => {
  const levels = learningResources.value
    .map(r => r.assessment_levels)
    .filter(Boolean)
  // Remove duplicates by level_code
  const uniqueLevels = []
  const seenCodes = new Set()
  for (const level of levels) {
    if (!seenCodes.has(level.level_code)) {
      seenCodes.add(level.level_code)
      uniqueLevels.push(level)
    }
  }
  return uniqueLevels.sort((a, b) => a.level_name.localeCompare(b.level_name))
})

const filteredResources = computed(() => {
  let filtered = learningResources.value
  
  // Search filter
  if (resourceFilters.value.search) {
    const search = resourceFilters.value.search.toLowerCase()
    filtered = filtered.filter(r => 
      r.title?.toLowerCase().includes(search) ||
      r.description?.toLowerCase().includes(search) ||
      r.url?.toLowerCase().includes(search)
    )
  }
  
  if (resourceFilters.value.type) {
    filtered = filtered.filter(r => r.resource_types?.code === resourceFilters.value.type)
  }
  
  if (resourceFilters.value.analysisType) {
    filtered = filtered.filter(r => 
      r.analysis_types?.name === resourceFilters.value.analysisType
    )
  }
  
  if (resourceFilters.value.difficulty) {
    filtered = filtered.filter(r => r.assessment_levels?.level_code === resourceFilters.value.difficulty)
  }
  
  // Status filter
  if (resourceFilters.value.status) {
    const isActive = resourceFilters.value.status === 'active'
    filtered = filtered.filter(r => r.is_active === isActive)
  }
  
  return filtered
})


// Methods
const truncate = (text, length) => {
  if (!text) return ''
  return text.length > length ? text.substring(0, length) + '...' : text
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

const buildResourcePreview = (item) => {
  // Just return description for first line
  return truncate(item.description, 100)
}

const formatType = (type) => {
  if (!type) return 'N/A'
  return type.charAt(0).toUpperCase() + type.slice(1)
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString() + ' ' + 
         new Date(dateString).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
}


const loadAllData = async () => {
  if (!adminSupabase) return

  try {
    console.log('Loading learning resources with relational data...')
    
    // Load learning resources with related tables
    const { data: resourcesData, error: resourcesError } = await adminSupabase
      .from('learning_resources')
      .select(`
        id,
        title,
        description,
        url,
        author_instructor,
        is_active,
        created_at,
        resource_types!resource_type_id (
          code,
          name
        ),
        assessment_levels!assessment_level_id (
          level_code,
          level_name
        ),
        frameworks!framework_id (
          code,
          name
        ),
        learning_path_categories!category_id (
          category_title
        ),
        analysis_types!analysis_type_id (
          code,
          name
        )
      `)
      .order('created_at', { ascending: false })
    
    if (resourcesError) {
      console.error('Error loading learning resources:', resourcesError)
      return
    }
    
    // Load competencies for all resources
    const resourceIds = resourcesData?.map(r => r.id) || []
    let competenciesMap = {}
    
    if (resourceIds.length > 0) {
      const { data: competenciesData, error: competenciesError } = await adminSupabase
        .from('learning_resource_competencies')
        .select(`
          learning_resource_id,
          competency_display_names (
            display_name
          )
        `)
        .in('learning_resource_id', resourceIds)
        
      if (!competenciesError && competenciesData) {
        console.log('Competencies data loaded:', competenciesData)
        competenciesData.forEach(item => {
          if (!competenciesMap[item.learning_resource_id]) {
            competenciesMap[item.learning_resource_id] = []
          }
          if (item.competency_display_names?.display_name) {
            competenciesMap[item.learning_resource_id].push(item.competency_display_names.display_name)
          }
        })
      } else if (competenciesError) {
        console.error('Error loading competencies:', competenciesError)
      }
    }
    
    // Store resources with their relational data
    learningResources.value = (resourcesData || []).map(resource => ({
      ...resource,
      competencies: competenciesMap[resource.id] || []
    }))
    
    console.log('Loaded resources:', learningResources.value.length)

    // Load learning path categories with assessment level relation
    const { data: categoriesData, error: categoriesError } = await adminSupabase
      .from('learning_path_categories')
      .select(`
        *,
        assessment_levels!assessment_level_id (
          level_code,
          level_name
        )
      `)
      .order('category_title')
    
    if (categoriesError) {
      console.error('Error loading path categories:', categoriesError)
    } else {
      pathCategories.value = categoriesData || []
      console.log('Loaded path categories:', pathCategories.value.length, pathCategories.value)
    }
    
  } catch (error) {
    console.error('Error loading data:', error)
  }
}

const addResource = () => {
  window.location.href = '/docs/admin/resources/edit'
}

const addPathCategory = () => {
  window.location.href = '/docs/admin/categories/edit'
}

const editItem = (table, item) => {
  if (table === 'learning_resources') {
    window.location.href = `/docs/admin/resources/edit?id=${item.id}`
  } else if (table === 'learning_path_categories') {
    window.location.href = `/docs/admin/categories/edit?id=${item.id}`
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
  const itemName = table === 'learning_resources' ? item.title : item.category_title
  const confirmMessage = `Are you sure you want to delete "${itemName}"?\n\nThis action cannot be undone.`
  
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


onMounted(async () => {
  isAuthLoaded.value = true
  injectBadgeStyles()
  await createSession()
  loadAllData()
})
</script>

<style scoped>
/* Same styles as AdminLearningResourcesTabs but focused on resources */
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

/* Filter Bar - match competencies exactly */
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

/* Data Table - using shared AdminTableHeader component */

.table-row {
  display: grid;
  padding: 1.5rem;
  border-bottom: 1px solid var(--vp-c-border);
  align-items: start;
  transition: all 0.2s ease;
  gap: 1rem;
}

.table-row:hover {
  background: var(--vp-c-bg);
  box-shadow: inset 3px 0 0 var(--vp-c-brand-1);
}

.table-row:last-child {
  border-bottom: none;
}


/* Grid layouts for different tabs - better column distribution */
.learning-resources-grid {
  grid-template-columns: 3fr 110px 140px 140px 100px 140px;
  gap: 12px;
}

/* Path categories specific grid */
.path-categories-tab .table-header,
.path-categories-tab .table-row {
  grid-template-columns: 2fr 2fr 1.5fr 1fr 100px 140px;
}

/* Column Styles - match competencies pattern */
.col-resource {
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
  margin-top: 2px;
}

.col-text {
  color: var(--vp-c-text-2);
  font-size: 13px;
}


.col-type,
.col-analysis-type,
.col-level,
.col-fields,
.col-status,
.col-stats,
.col-date {
  display: flex;
  align-items: center;
  font-size: 13px;
}

.col-level {
  min-width: fit-content;
}

.col-status {
  justify-content: flex-start;
}

/* Badges - ALL resource types get proper styling */
.learning-resources-grid .framework-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand);
}

.learning-resources-grid .framework-badge.article,
.learning-resources-grid .framework-badge.articles,
.learning-resources-grid .framework-badge.blog,
.learning-resources-grid .framework-badge.blog-post,
.learning-resources-grid .framework-badge.post,
.learning-resources-grid .framework-badge.text,
.learning-resources-grid .framework-badge.reading,
.learning-resources-grid .framework-badge.written {
  background: var(--vp-c-blue-soft);
  color: var(--vp-c-blue);
}

.learning-resources-grid .framework-badge.video,
.learning-resources-grid .framework-badge.videos {
  background: var(--vp-c-red-soft);
  color: var(--vp-c-red);
}

.learning-resources-grid .framework-badge.guide,
.learning-resources-grid .framework-badge.guides {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
}

.learning-resources-grid .framework-badge.tool,
.learning-resources-grid .framework-badge.tools {
  background: var(--vp-c-purple-soft);
  color: var(--vp-c-purple);
}

.learning-resources-grid .framework-badge.book,
.learning-resources-grid .framework-badge.books {
  background: var(--vp-c-indigo-soft);
  color: var(--vp-c-indigo);
}

.learning-resources-grid .framework-badge.podcast,
.learning-resources-grid .framework-badge.podcasts {
  background: var(--vp-c-orange-soft);
  color: var(--vp-c-orange);
}

.learning-resources-grid .framework-badge.course,
.learning-resources-grid .framework-badge.courses {
  background: var(--vp-c-yellow-soft);
  color: var(--vp-c-yellow-darker);
}

/* Article badge - testing if VitePress targets the word "article" specifically */
.framework-badge.article-type-badge {
  background: var(--vp-c-blue-soft) !important;
  color: var(--vp-c-blue) !important;
  display: inline-block !important;
  padding: 4px 8px !important;
  border-radius: 4px !important;
  font-size: 11px !important;
  font-weight: 600 !important;
  text-transform: uppercase !important;
}

/* Simple, clean resource type text - VitePress can't touch this! */
.resource-type-text {
  font-size: 13px;
  font-weight: 500;
  color: var(--vp-c-text-2);
  text-transform: capitalize;
}

.level-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  white-space: nowrap;
}

.level-badge.foundational,
.level-badge.beginner {
  background: var(--vp-c-blue-soft);
  color: var(--vp-c-blue);
}

.level-badge.developing,
.level-badge.intermediate {
  background: var(--vp-c-yellow-soft);
  color: var(--vp-c-yellow-darker);
}

.level-badge.advanced {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
}

.level-badge:not(.foundational):not(.beginner):not(.developing):not(.intermediate):not(.advanced) {
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-2);
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

.status-badge {
  display: inline-flex;
  align-items: center;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  background: var(--vp-c-danger-soft);
  color: var(--vp-c-danger);
  white-space: nowrap;
  min-width: fit-content;
}

.status-badge.active {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
}

/* Field count styling to match competencies exactly */
.col-fields {
  display: flex;
  align-items: center;
  font-size: 13px;
}

.field-count {
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-2);
  padding: 2px 6px;
  border-radius: 3px;
  font-size: 11px;
  font-weight: 600;
}

.competency-list {
  display: flex;
  align-items: center;
  gap: 4px;
}

/* URL link styling */
.resource-url {
  margin-top: 4px;
}

.url-link {
  color: var(--vp-c-brand);
  text-decoration: none;
  font-size: 12px;
  font-weight: 500;
}

.url-link:hover {
  text-decoration: underline;
}

/* Competency wrapping - allow natural wrap */
.competency-wrap {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 3px;
  max-width: 100%;
}

.competency-tag {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand);
  padding: 2px 5px;
  border-radius: 3px;
  font-size: 10px;
  font-weight: 500;
  white-space: nowrap;
  flex-shrink: 0;
}

/* Actions */
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

.empty-state {
  padding: 40px;
  text-align: center;
  color: var(--vp-c-text-2);
  font-size: 14px;
}

/* Path Categories Specific Styles */
[data-tab="path_categories"] .table-row {
  padding: 20px 16px;
  align-items: start;
  min-height: 80px;
}

[data-tab="path_categories"] .col-text {
  line-height: 1.4;
  word-wrap: break-word;
  overflow-wrap: break-word;
}

.category-icon {
  margin-right: 8px;
  font-size: 16px;
}

.competency-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  margin-top: 2px;
}

.competency-tag {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand);
  padding: 3px 8px;
  border-radius: 4px;
  font-size: 10px;
  font-weight: 500;
  white-space: nowrap;
}

.more-tag {
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-2);
  padding: 3px 8px;
  border-radius: 4px;
  font-size: 10px;
  font-style: italic;
  white-space: nowrap;
}

.competency-list {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  align-items: center;
}

.more-comp-tag {
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-2);
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 10px;
  font-style: italic;
  white-space: nowrap;
}

.no-competencies {
  color: var(--vp-c-text-3);
  font-style: italic;
  font-size: 12px;
}

.no-data {
  color: var(--vp-c-text-3);
  font-size: 12px;
  font-style: italic;
}

/* Path categories specific spacing - using class selector */
.path-categories-tab .col-text {
  padding-right: 20px !important;
  margin-right: 8px !important;
}

.path-categories-tab .col-competencies {
  padding-left: 8px !important;
  margin-left: 8px !important;
  padding-right: 4px !important;
}

/* Fallback with higher specificity */
.admin-container .tab-content .path-categories-tab .col-text {
  padding-right: 20px !important;
  margin-right: 8px !important;
}

.admin-container .tab-content .path-categories-tab .col-competencies {
  padding-left: 8px !important;
  margin-left: 8px !important;
  padding-right: 4px !important;
}

[data-tab="path_categories"] .col-name .item-main {
  display: flex;
  align-items: center;
  font-weight: 500;
  margin-bottom: 2px;
}

/* Responsive adjustments for path categories */
@media (max-width: 1200px) {
  [data-tab="path_categories"] .table-header,
  [data-tab="path_categories"] .table-row {
    grid-template-columns: 2fr 2.5fr 1.5fr 1fr 80px 120px;
    gap: 6px;
  }
  
  [data-tab="path_categories"] .table-row {
    padding: 16px 12px;
  }
}

@media (max-width: 768px) {
  [data-tab="path_categories"] .table-header,
  [data-tab="path_categories"] .table-row {
    grid-template-columns: 1fr;
    gap: 8px;
  }
  
  [data-tab="path_categories"] .table-row {
    border: 1px solid var(--vp-c-border);
    border-radius: 6px;
    margin-bottom: 12px;
    padding: 16px;
    background: var(--vp-c-bg);
  }
  
  [data-tab="path_categories"] .table-header {
    display: none;
  }
  
  [data-tab="path_categories"] .col-name::before {
    content: "Category: ";
    font-weight: 600;
    color: var(--vp-c-text-2);
  }
  
  [data-tab="path_categories"] .col-text::before {
    content: "Description: ";
    font-weight: 600;
    color: var(--vp-c-text-2);
    display: block;
    margin-top: 8px;
  }
  
  [data-tab="path_categories"] .col-competencies::before {
    content: "Competencies: ";
    font-weight: 600;
    color: var(--vp-c-text-2);
    display: block;
    margin-top: 8px;
  }
  
  [data-tab="path_categories"] .col-level::before {
    content: "Level: ";
    font-weight: 600;
    color: var(--vp-c-text-2);
    display: block;
    margin-top: 8px;
  }
  
  [data-tab="path_categories"] .col-status::before {
    content: "Status: ";
    font-weight: 600;
    color: var(--vp-c-text-2);
    display: block;
    margin-top: 8px;
  }
  
  [data-tab="path_categories"] .col-actions {
    margin-top: 12px;
    text-align: center;
  }
}

/* Responsive Design - better column distribution */
@media (max-width: 1200px) {
  .learning-resources-grid {
    grid-template-columns: 2.5fr 100px 100px 120px 110px 120px;
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
  
  .learning-resources-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }
  
  .learning-resources-grid .table-header {
    display: none;
  }
}
</style>