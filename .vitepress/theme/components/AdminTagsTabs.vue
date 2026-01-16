<template>
  <div class="admin-container">
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

    <!-- Skill Tags Management with Tabs -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>🏷️ Skill Tags & Insights Management</h1>
          <p class="admin-subtitle">Categorization and tagging system - improves competency discovery and organization</p>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>Skill Tags</span>
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
        <!-- Skill Tags Tab -->
        <div v-show="activeTab === 'skill_tags'" class="table-section">
          <div class="section-header">
            <div>
              <h2>Skill Tags</h2>
              <p class="section-description">Categorization system for competencies and skills - improves discovery</p>
            </div>
            <ActionButton @click="addSkillTag" icon="➕">Add Skill Tag</ActionButton>
          </div>

          <div class="filter-bar">
            <select v-model="tagFilters.category" class="filter-select">
              <option value="">All Categories</option>
              <option v-for="cat in uniqueCategories" :key="cat" :value="cat">
                {{ cat }}
              </option>
            </select>
            <select v-model="tagFilters.status" class="filter-select">
              <option value="">All Statuses</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>

          <AdminTableHeader :columns="tableConfigs.skill_tags">
            <div v-for="item in filteredTags" :key="item.id" class="table-row">
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
          </AdminTableHeader>
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

          <div class="filter-bar">
            <select v-model="insightFilters.tag" class="filter-select">
              <option value="">All Tags</option>
              <option v-for="tag in skillTags" :key="tag.id" :value="tag.id">
                {{ tag.name }}
              </option>
            </select>
            <select v-model="insightFilters.type" class="filter-select">
              <option value="">All Types</option>
              <option value="general">General</option>
              <option value="coaching">Coaching</option>
              <option value="development">Development</option>
              <option value="assessment">Assessment</option>
            </select>
          </div>

          <AdminTableHeader :columns="tableConfigs.tag_insights">
            <div v-for="item in filteredInsights" :key="item.id" class="table-row">
              <div class="col-name">
                <div class="tag-reference">
                  <span class="tag-color" :style="{ backgroundColor: getTagColor(item.tag_id) }"></span>
                  {{ getTagName(item.tag_id) }}
                </div>
              </div>
              <div class="col-text">{{ truncate(item.insight_text, 80) }}</div>
              <div class="col-type">
                <span class="type-badge" :class="item.insight_type">{{ item.insight_type || 'General' }}</span>
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
          </AdminTableHeader>
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

          <div class="filter-bar">
            <select v-model="actionFilters.tag" class="filter-select">
              <option value="">All Tags</option>
              <option v-for="tag in skillTags" :key="tag.id" :value="tag.id">
                {{ tag.name }}
              </option>
            </select>
            <select v-model="actionFilters.priority" class="filter-select">
              <option value="">All Priorities</option>
              <option value="high">High</option>
              <option value="medium">Medium</option>
              <option value="low">Low</option>
            </select>
          </div>

          <AdminTableHeader :columns="tableConfigs.tag_actions">
            <div v-for="item in filteredActions" :key="item.id" class="table-row">
              <div class="col-name">
                <div class="tag-reference">
                  <span class="tag-color" :style="{ backgroundColor: getTagColor(item.tag_id) }"></span>
                  {{ getTagName(item.tag_id) }}
                </div>
              </div>
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

const { hasAdminAccess } = useAdminSession()
const { adminSupabase } = useAdminSupabase()

// Authentication loading state
const isAuthLoaded = ref(false)

// Active tab
const activeTab = ref('skill_tags')

// Data
const skillTags = ref([])
const tagInsights = ref([])
const tagActions = ref([])

// Table configurations for AdminTableHeader
const tableConfigs = {
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
  ]
}

// Filters
const tagFilters = ref({
  category: '',
  status: ''
})

const insightFilters = ref({
  tag: '',
  type: ''
})

const actionFilters = ref({
  tag: '',
  priority: ''
})

// Table tabs configuration - TAGS FOCUSED
const tableTabs = computed(() => [
  {
    id: 'skill_tags',
    label: 'Skill Tags',
    icon: '🏷️',
    count: skillTags.value.length,
    description: 'Tag definitions'
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
  }
])

// Computed
const uniqueCategories = computed(() => {
  const categories = skillTags.value.map(t => t.category).filter(Boolean)
  return [...new Set(categories)].sort()
})

const filteredTags = computed(() => {
  let filtered = skillTags.value
  
  if (tagFilters.value.category) {
    filtered = filtered.filter(t => t.category === tagFilters.value.category)
  }
  
  if (tagFilters.value.status) {
    const isActive = tagFilters.value.status === 'active'
    filtered = filtered.filter(t => t.is_active === isActive)
  }
  
  return filtered
})

const filteredInsights = computed(() => {
  let filtered = tagInsights.value
  
  if (insightFilters.value.tag) {
    filtered = filtered.filter(i => i.tag_id === insightFilters.value.tag)
  }
  
  if (insightFilters.value.type) {
    filtered = filtered.filter(i => i.insight_type === insightFilters.value.type)
  }
  
  return filtered
})

const filteredActions = computed(() => {
  let filtered = tagActions.value
  
  if (actionFilters.value.tag) {
    filtered = filtered.filter(a => a.tag_id === actionFilters.value.tag)
  }
  
  if (actionFilters.value.priority) {
    filtered = filtered.filter(a => a.priority === actionFilters.value.priority)
  }
  
  return filtered
})

// Methods
const truncate = (text, length) => {
  if (!text) return ''
  return text.length > length ? text.substring(0, length) + '...' : text
}

const getTagName = (tagId) => {
  const tag = skillTags.value.find(t => t.id === tagId)
  return tag?.name || 'Unknown Tag'
}

const getTagColor = (tagId) => {
  const tag = skillTags.value.find(t => t.id === tagId)
  return tag?.color || '#ccc'
}

const loadAllData = async () => {
  if (!adminSupabase) return

  try {
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
  } catch (error) {
    console.error('Error loading data:', error)
  }
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

const editItem = (table, item) => {
  alert(`Edit ${table} coming soon`)
}

onMounted(() => {
  isAuthLoaded.value = true
  loadAllData()
})
</script>

<style scoped>
/* Same base styles as other admin interfaces but focused on tags */
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

/* Filter Bar */
.filter-bar {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.filter-select {
  padding: 8px 12px;
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  background: var(--vp-c-bg);
  font-size: 14px;
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
  grid-template-columns: 2fr 3fr 1fr 1fr 1fr 100px;
  padding: 12px 16px;
  background: var(--vp-c-bg-soft);
  border-bottom: 1px solid var(--vp-c-border);
  font-weight: 600;
  font-size: 12px;
  text-transform: uppercase;
  color: var(--vp-c-text-2);
}

.table-row {
  display: grid;
  grid-template-columns: 2fr 3fr 1fr 1fr 1fr 100px;
  padding: 14px 16px;
  border-bottom: 1px solid var(--vp-c-divider);
  align-items: center;
  transition: background 0.2s;
  font-size: 14px;
}

.table-row:hover {
  background: var(--vp-c-bg-soft);
}

.table-row:last-child {
  border-bottom: none;
}

/* Adjust grids for different tabs */
[data-tab="tag_insights"] .table-header,
[data-tab="tag_insights"] .table-row {
  grid-template-columns: 1.5fr 4fr 1fr 1fr 100px;
}

[data-tab="tag_actions"] .table-header,
[data-tab="tag_actions"] .table-row {
  grid-template-columns: 1.5fr 3fr 1fr 1fr 100px;
}

/* Column Styles */
.col-name {
  font-weight: 500;
  color: var(--vp-c-text-1);
}

.col-text {
  color: var(--vp-c-text-2);
  font-size: 13px;
}

.col-category,
.col-type,
.col-priority,
.col-status {
  display: flex;
  align-items: center;
  font-size: 13px;
}

/* Tag-specific Styles */
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

.tag-reference {
  display: flex;
  align-items: center;
  gap: 6px;
}

.tag-color {
  width: 8px;
  height: 8px;
  border-radius: 50%;
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

.type-badge.general {
  background: var(--vp-c-blue-soft);
  color: var(--vp-c-blue);
}

.type-badge.coaching {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
}

.type-badge.development {
  background: var(--vp-c-purple-soft);
  color: var(--vp-c-purple);
}

.type-badge.assessment {
  background: var(--vp-c-yellow-soft);
  color: var(--vp-c-yellow-darker);
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