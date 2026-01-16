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

    <!-- Competency Management with Tabs -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>🎖️ Competency Management</h1>
          <p class="admin-subtitle">Foundation of the assessment system - everything starts here</p>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>Competencies</span>
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
        <!-- Display Names Tab -->
        <div v-show="activeTab === 'display_names'" class="table-section">
          <div class="section-header">
            <div>
              <h2>Competency Display Names</h2>
              <p class="section-description">Core competency definitions - name, description, framework</p>
            </div>
            <ActionButton @click="addCompetency" icon="➕">Add Competency</ActionButton>
          </div>

          <!-- Filters -->
          <div class="filter-bar">
            <input 
              v-model="filters.display_names.search"
              type="text" 
              placeholder="Search competencies..."
              class="filter-input"
            >
            <select v-model="filters.display_names.framework" class="filter-select">
              <option value="">All Frameworks</option>
              <option v-for="framework in uniqueFrameworks" :key="framework.id" :value="framework.id">
                {{ framework.name }} ({{ framework.code }})
              </option>
            </select>
            <select v-model="filters.display_names.status" class="filter-select">
              <option value="">All Status</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>

          <AdminTableHeader :columns="tableConfigs.display_names">
            <div v-for="item in filteredDisplayNames" :key="item.id" class="table-row display-names-grid">
              <div class="col-name">
                <div class="competency-name">{{ item.display_name }}</div>
                <div class="competency-key">{{ item.competency_key }}</div>
              </div>
              <div class="col-text">{{ truncate(item.description, 80) }}</div>
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
                <button @click="editItem('display_names', item)" class="action-btn edit">Edit</button>
                <button @click="deleteItem('display_names', item)" class="action-btn delete">Delete</button>
              </div>
            </div>
            
            <div v-if="filteredDisplayNames.length === 0" class="empty-state">
              <p>{{ filters.display_names.search || filters.display_names.framework || filters.display_names.status ? 'No competencies match the current filters.' : 'No competencies found.' }}</p>
            </div>
          </AdminTableHeader>
        </div>

        <!-- Rich Insights Tab -->
        <div v-show="activeTab === 'rich_insights'" class="table-section">
          <div class="section-header">
            <div>
              <h2>Rich Insights (PDF)</h2>
              <p class="section-description">Detailed performance insights shown in PDF reports - 9 fields per performance level</p>
            </div>
            <ActionButton @click="addInsight" icon="➕">Add Insight</ActionButton>
          </div>

          <!-- Filters -->
          <div class="filter-bar">
            <input 
              v-model="filters.rich_insights.search"
              type="text" 
              placeholder="Search insights..."
              class="filter-input"
            >
            <select v-model="filters.rich_insights.competency" class="filter-select">
              <option value="">All Competencies</option>
              <option v-for="comp in uniqueCompetencies" :key="comp.id" :value="comp.id">
                {{ comp.display_name }}
              </option>
            </select>
            <select v-model="filters.rich_insights.framework" class="filter-select">
              <option value="">All Frameworks</option>
              <option v-for="framework in uniqueFrameworks" :key="framework.id" :value="framework.id">
                {{ framework.name }}
              </option>
            </select>
            <select v-model="filters.rich_insights.level" class="filter-select">
              <option value="">All Levels</option>
              <option v-for="level in uniqueLevels" :key="level.id" :value="level.id">
                {{ level.level_name }}
              </option>
            </select>
            <select v-model="filters.rich_insights.analysisType" class="filter-select">
              <option value="">All Analysis Types</option>
              <option v-for="analysisType in uniqueAnalysisTypes" :key="analysisType.id" :value="analysisType.id">
                {{ analysisType.name }}
              </option>
            </select>
            <select v-model="filters.rich_insights.status" class="filter-select">
              <option value="">All Status</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>

          <AdminTableHeader :columns="tableConfigs.rich_insights">
            <div v-for="item in filteredInsights" :key="item.id" class="table-row rich-insights-grid">
              <div class="col-competency">
                <div class="competency-name">{{ item.competency_display_names?.display_name || 'Unknown' }}</div>
                <div class="insight-text">{{ truncate(item.performance_insight, 100) }}</div>
              </div>
              <div class="col-level">
                <span class="level-badge" :class="getLevelClass(item.assessment_levels?.level_name)">
                  {{ item.assessment_levels?.level_name || 'All Levels' }}
                </span>
              </div>
              <div class="col-framework">
                <span class="framework-badge" :class="item.frameworks?.code?.toLowerCase()">
                  {{ item.frameworks?.code || 'N/A' }}
                </span>
              </div>
              <div class="col-analysis-type">
                <span class="analysis-type-badge" :class="getAnalysisTypeClass(item.analysis_types?.name)">
                  {{ item.analysis_types?.name || 'N/A' }}
                </span>
              </div>
              <div class="col-fields">
                <span class="field-count">{{ countFilledFields(item) }}/3</span>
              </div>
              <div class="col-status">
                <span class="status-badge" :class="{ active: item.is_active }">
                  {{ item.is_active ? 'Active' : 'Inactive' }}
                </span>
              </div>
              <div class="col-actions">
                <button @click="editItem('rich_insights', item)" class="action-btn edit">Edit</button>
                <button @click="deleteItem('rich_insights', item)" class="action-btn delete">Delete</button>
              </div>
            </div>
            
            <div v-if="filteredInsights.length === 0" class="empty-state">
              <p>{{ Object.values(filters.rich_insights).some(f => f) ? 'No insights match the current filters.' : 'No insights found.' }}</p>
            </div>
          </AdminTableHeader>
        </div>

        <!-- Performance Analysis Tab -->
        <div v-show="activeTab === 'performance_analysis'" class="table-section">
          <div class="section-header">
            <div>
              <h2>Performance Analysis</h2>
              <p class="section-description">Scoring ranges and strength level definitions (0-100% ranges)</p>
            </div>
            <ActionButton @click="addAnalysis" icon="➕">Add Analysis</ActionButton>
          </div>

          <!-- Filters -->
          <div class="filter-bar">
            <input 
              v-model="filters.performance_analysis.search"
              type="text" 
              placeholder="Search analysis..."
              class="filter-input"
            >
            <select v-model="filters.performance_analysis.competency" class="filter-select">
              <option value="">All Competencies</option>
              <option v-for="comp in uniqueCompetencies" :key="comp.id" :value="comp.id">
                {{ comp.display_name }}
              </option>
            </select>
            <select v-model="filters.performance_analysis.framework" class="filter-select">
              <option value="">All Frameworks</option>
              <option v-for="framework in uniqueFrameworks" :key="framework.id" :value="framework.id">
                {{ framework.name }}
              </option>
            </select>
            <select v-model="filters.performance_analysis.level" class="filter-select">
              <option value="">All Levels</option>
              <option v-for="level in uniqueLevels" :key="level.id" :value="level.id">
                {{ level.level_name }}
              </option>
            </select>
            <select v-model="filters.performance_analysis.scoringTier" class="filter-select">
              <option value="">All Scoring Tiers</option>
              <option v-for="tier in uniqueScoringTiers" :key="tier.id" :value="tier.id">
                {{ tier.tier_name }} ({{ tier.score_min }}-{{ tier.score_max }}%)
              </option>
            </select>
            <select v-model="filters.performance_analysis.status" class="filter-select">
              <option value="">All Status</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>

          <AdminTableHeader :columns="tableConfigs.performance_analysis">
            <div v-for="item in filteredPerformanceAnalysis" :key="item.id" class="table-row performance-analysis-grid">
              <div class="col-competency">
                <div class="competency-name">{{ item.competency_display_names?.display_name || 'Unknown' }}</div>
                <div class="analysis-text">{{ truncate(item.analysis_text, 100) }}</div>
              </div>
              <div class="col-tier">
                <span v-if="item.scoring_tiers" class="tier-badge" :class="item.scoring_tiers.tier_code">
                  {{ item.scoring_tiers.tier_name }} ({{ item.scoring_tiers.score_min }}-{{ item.scoring_tiers.score_max }}%)
                </span>
                <span v-else class="tier-badge">No Tier</span>
              </div>
              <div class="col-level">
                <span class="level-badge" :class="getLevelClass(item.assessment_levels?.level_name)">
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
                <button @click="editItem('performance_analysis', item)" class="action-btn edit">Edit</button>
                <button @click="deleteItem('performance_analysis', item)" class="action-btn delete">Delete</button>
              </div>
            </div>
            
            <div v-if="filteredPerformanceAnalysis.length === 0" class="empty-state">
              <p>{{ Object.values(filters.performance_analysis).some(f => f) ? 'No analysis match the current filters.' : 'No performance analysis found.' }}</p>
            </div>
          </AdminTableHeader>
        </div>

        <!-- Strategic Actions Tab -->
        <div v-show="activeTab === 'strategic_actions'" class="table-section">
          <div class="section-header">
            <div>
              <h2>Strategic Actions</h2>
              <p class="section-description">Recommended actions for competency improvement</p>
            </div>
            <ActionButton @click="addAction" icon="➕">Add Action</ActionButton>
          </div>

          <!-- Filters -->
          <div class="filter-bar">
            <input 
              v-model="filters.strategic_actions.search"
              type="text" 
              placeholder="Search actions..."
              class="filter-input"
            >
            <select v-model="filters.strategic_actions.competency" class="filter-select">
              <option value="">All Competencies</option>
              <option v-for="comp in uniqueCompetencies" :key="comp.id" :value="comp.id">
                {{ comp.display_name }}
              </option>
            </select>
            <select v-model="filters.strategic_actions.framework" class="filter-select">
              <option value="">All Frameworks</option>
              <option v-for="framework in uniqueFrameworks" :key="framework.id" :value="framework.id">
                {{ framework.name }}
              </option>
            </select>
            <select v-model="filters.strategic_actions.level" class="filter-select">
              <option value="">All Levels</option>
              <option v-for="level in uniqueLevels" :key="level.id" :value="level.id">
                {{ level.level_name }}
              </option>
            </select>
            <select v-model="filters.strategic_actions.scoringTier" class="filter-select">
              <option value="">All Scoring Tiers</option>
              <option v-for="tier in uniqueScoringTiers" :key="tier.id" :value="tier.id">
                {{ tier.tier_name }} ({{ tier.score_min }}-{{ tier.score_max }}%)
              </option>
            </select>
            <select v-model="filters.strategic_actions.status" class="filter-select">
              <option value="">All Status</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>

          <AdminTableHeader :columns="tableConfigs.strategic_actions">
            <div v-for="item in filteredStrategicActions" :key="item.id" class="table-row strategic-actions-grid">
              <div class="col-competency">
                <div class="competency-name">{{ item.competency_display_names?.display_name || 'Unknown' }}</div>
                <div class="action-text">{{ truncate(item.action_text, 100) }}</div>
              </div>
              <div class="col-tier">
                <span v-if="item.scoring_tiers" class="tier-badge" :class="item.scoring_tiers.tier_code">
                  {{ item.scoring_tiers.tier_name }} ({{ item.scoring_tiers.score_min }}-{{ item.scoring_tiers.score_max }}%)
                </span>
                <span v-else class="tier-badge">No Tier</span>
              </div>
              <div class="col-level">
                <span class="level-badge" :class="getLevelClass(item.assessment_levels?.level_name)">
                  {{ item.assessment_levels?.level_name || 'N/A' }}
                </span>
              </div>
              <div class="col-framework">
                <span class="framework-badge" :class="item.frameworks?.code?.toLowerCase()">
                  {{ item.frameworks?.code || 'N/A' }}
                </span>
              </div>
              <div class="col-priority">
                <span class="priority-badge">{{ item.priority_order || 'N/A' }}</span>
              </div>
              <div class="col-status">
                <span class="status-badge" :class="{ active: item.is_active }">
                  {{ item.is_active ? 'Active' : 'Inactive' }}
                </span>
              </div>
              <div class="col-actions">
                <button @click="editItem('strategic_actions', item)" class="action-btn edit">Edit</button>
                <button @click="deleteItem('strategic_actions', item)" class="action-btn delete">Delete</button>
              </div>
            </div>
            
            <div v-if="filteredStrategicActions.length === 0" class="empty-state">
              <p>{{ Object.values(filters.strategic_actions).some(f => f) ? 'No actions match the current filters.' : 'No strategic actions found.' }}</p>
            </div>
          </AdminTableHeader>
        </div>

        <!-- Leverage Strengths Tab -->
        <div v-show="activeTab === 'leverage_strengths'" class="table-section">
          <div class="section-header">
            <div>
              <h2>Leverage Strengths</h2>
              <p class="section-description">How to leverage competency strengths in practice</p>
            </div>
            <ActionButton @click="addStrength" icon="➕">Add Strength</ActionButton>
          </div>

          <!-- Filters -->
          <div class="filter-bar">
            <input 
              v-model="filters.leverage_strengths.search"
              type="text" 
              placeholder="Search strengths..."
              class="filter-input"
            >
            <select v-model="filters.leverage_strengths.competency" class="filter-select">
              <option value="">All Competencies</option>
              <option v-for="comp in uniqueCompetencies" :key="comp.id" :value="comp.id">
                {{ comp.display_name }}
              </option>
            </select>
            <select v-model="filters.leverage_strengths.framework" class="filter-select">
              <option value="">All Frameworks</option>
              <option v-for="framework in uniqueFrameworks" :key="framework.id" :value="framework.id">
                {{ framework.name }}
              </option>
            </select>
            <select v-model="filters.leverage_strengths.level" class="filter-select">
              <option value="">All Levels</option>
              <option v-for="level in uniqueLevels" :key="level.id" :value="level.id">
                {{ level.level_name }}
              </option>
            </select>
            <select v-model="filters.leverage_strengths.scoringTier" class="filter-select">
              <option value="">All Scoring Tiers</option>
              <option v-for="tier in uniqueScoringTiers" :key="tier.id" :value="tier.id">
                {{ tier.tier_name }} ({{ tier.score_min }}-{{ tier.score_max }}%)
              </option>
            </select>
            <select v-model="filters.leverage_strengths.status" class="filter-select">
              <option value="">All Status</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>

          <AdminTableHeader :columns="tableConfigs.leverage_strengths">
            <div v-for="item in filteredLeverageStrengths" :key="item.id" class="table-row leverage-strengths-grid">
              <div class="col-competency">
                <div class="competency-name">{{ item.competency_display_names?.display_name || 'Unknown' }}</div>
                <div class="leverage-text">{{ truncate(item.strategy_text, 100) }}</div>
              </div>
              <div class="col-scoring-tier">
                <span v-if="item.scoring_tiers" class="tier-badge" :class="getTierClass(item.scoring_tiers.tier_code)">
                  {{ item.scoring_tiers.tier_name }}
                </span>
                <span v-else class="tier-badge tier-none">No Tier</span>
              </div>
              <div class="col-level">
                <span class="level-badge" :class="getLevelClass(item.assessment_levels?.level_name)">
                  {{ item.frameworks?.code }} - {{ item.assessment_levels?.level_name }}
                </span>
              </div>
              <div class="col-framework">
                <span class="framework-badge" :class="item.frameworks?.code?.toLowerCase()">
                  {{ item.frameworks?.code || 'N/A' }}
                </span>
              </div>
              <div class="col-priority">
                <span class="priority-badge">{{ item.priority_order || 'N/A' }}</span>
              </div>
              <div class="col-status">
                <span class="status-badge" :class="{ active: item.is_active }">
                  {{ item.is_active ? 'Active' : 'Inactive' }}
                </span>
              </div>
              <div class="col-actions">
                <button @click="editItem('leverage_strengths', item)" class="action-btn edit">Edit</button>
                <button @click="deleteItem('leverage_strengths', item)" class="action-btn delete">Delete</button>
              </div>
            </div>
            
            <div v-if="filteredLeverageStrengths.length === 0" class="empty-state">
              <p>{{ Object.values(filters.leverage_strengths).some(f => f) ? 'No strengths match the current filters.' : 'No leverage strengths found.' }}</p>
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

const { hasAdminAccess } = useAdminSession()
const { adminSupabase } = useAdminSupabase()
const { getLevelClass, getAnalysisTypeClass, getTierClass, injectBadgeStyles } = useBadges()

// Authentication loading state
const isAuthLoaded = ref(false)

// Active tab
const activeTab = ref('display_names')

// Data
const displayNames = ref([])
const richInsights = ref([])
const performanceAnalysis = ref([])
const strategicActions = ref([])
const leverageStrengths = ref([])

// Table configurations for AdminTableHeader
const tableConfigs = {
  display_names: [
    { label: 'Competency Name', width: '2fr' },
    { label: 'Description', width: '2.5fr' },
    { label: 'Framework', width: '120px' },
    { label: 'Status', width: '100px' },
    { label: 'Actions', width: '140px' }
  ],
  rich_insights: [
    { label: 'Competency & Insight', width: '3fr' },
    { label: 'Level', width: '120px' },
    { label: 'Framework', width: '120px' },
    { label: 'Analysis Type', width: '120px' },
    { label: 'Fields', width: '80px' },
    { label: 'Status', width: '100px' },
    { label: 'Actions', width: '140px' }
  ],
  performance_analysis: [
    { label: 'Competency & Analysis', width: '3fr' },
    { label: 'Scoring Tier', width: '120px' },
    { label: 'Level', width: '120px' },
    { label: 'Framework', width: '120px' },
    { label: 'Status', width: '100px' },
    { label: 'Actions', width: '140px' }
  ],
  strategic_actions: [
    { label: 'Competency & Action', width: '3fr' },
    { label: 'Scoring Tier', width: '185px' },
    { label: 'Level', width: '150px' },
    { label: 'Framework', width: '110px' },
    { label: 'Priority', width: '85px' },
    { label: 'Status', width: '85px' },
    { label: 'Actions', width: '155px' }
  ],
  leverage_strengths: [
    { label: 'Competency & Leverage Strategy', width: '3fr' },
    { label: 'Scoring Tier', width: '185px' },
    { label: 'Level', width: '150px' },
    { label: 'Framework', width: '110px' },
    { label: 'Priority', width: '85px' },
    { label: 'Status', width: '85px' },
    { label: 'Actions', width: '155px' }
  ]
}

// Filters for all tabs
const filters = ref({
  display_names: {
    framework: '',
    status: '',
    search: ''
  },
  rich_insights: {
    competency: '',
    framework: '',
    level: '',
    analysisType: '',
    status: '',
    search: ''
  },
  performance_analysis: {
    competency: '',
    framework: '',
    level: '',
    scoringTier: '',
    status: '',
    search: ''
  },
  strategic_actions: {
    competency: '',
    framework: '',
    level: '',
    scoringTier: '',
    status: '',
    search: ''
  },
  leverage_strengths: {
    competency: '',
    framework: '',
    level: '',
    scoringTier: '',
    status: '',
    search: ''
  }
})

// Table tabs configuration
const tableTabs = computed(() => [
  {
    id: 'display_names',
    label: 'Display Names',
    icon: '📋',
    count: filteredDisplayNames.value.length,
    total: displayNames.value.length,
    description: 'Core competency definitions'
  },
  {
    id: 'rich_insights',
    label: 'Rich Insights',
    icon: '💡',
    count: filteredInsights.value.length,
    total: richInsights.value.length,
    description: 'PDF report insights'
  },
  {
    id: 'performance_analysis',
    label: 'Performance Analysis',
    icon: '📊',
    count: filteredPerformanceAnalysis.value.length,
    total: performanceAnalysis.value.length,
    description: 'Scoring ranges'
  },
  {
    id: 'strategic_actions',
    label: 'Strategic Actions',
    icon: '🎯',
    count: filteredStrategicActions.value.length,
    total: strategicActions.value.length,
    description: 'Improvement actions'
  },
  {
    id: 'leverage_strengths',
    label: 'Leverage Strengths',
    icon: '💪',
    count: filteredLeverageStrengths.value.length,
    total: leverageStrengths.value.length,
    description: 'Strength strategies'
  }
])

// Computed - Reference data for filters
const uniqueCompetencies = computed(() => {
  return displayNames.value
})

const uniqueFrameworks = computed(() => {
  const frameworks = new Map()
  displayNames.value.forEach(item => {
    if (item.frameworks) {
      frameworks.set(item.frameworks.id, item.frameworks)
    }
  })
  return Array.from(frameworks.values())
})

const uniqueLevels = computed(() => {
  const levels = new Map()
  ;[...richInsights.value, ...performanceAnalysis.value, ...strategicActions.value, ...leverageStrengths.value].forEach(item => {
    if (item.assessment_levels) {
      levels.set(item.assessment_levels.id, item.assessment_levels)
    }
  })
  return Array.from(levels.values())
})

const uniqueAnalysisTypes = computed(() => {
  const analysisTypes = new Map()
  richInsights.value.forEach(item => {
    if (item.analysis_types) {
      analysisTypes.set(item.analysis_types.id, item.analysis_types)
    }
  })
  return Array.from(analysisTypes.values())
})

const uniqueScoringTiers = computed(() => {
  const scoringTiers = new Map()
  
  performanceAnalysis.value.forEach(item => {
    if (item.scoring_tiers) {
      scoringTiers.set(item.scoring_tiers.id, item.scoring_tiers)
    }
  })
  
  strategicActions.value.forEach(item => {
    if (item.scoring_tiers) {
      scoringTiers.set(item.scoring_tiers.id, item.scoring_tiers)
    }
  })
  
  leverageStrengths.value.forEach(item => {
    if (item.scoring_tiers) {
      scoringTiers.set(item.scoring_tiers.id, item.scoring_tiers)
    }
  })
  
  return Array.from(scoringTiers.values()).sort((a, b) => a.score_min - b.score_min)
})

// Filtered data for each tab
const filteredDisplayNames = computed(() => {
  let filtered = displayNames.value
  const f = filters.value.display_names
  
  if (f.framework) {
    filtered = filtered.filter(i => i.frameworks?.id === f.framework)
  }
  if (f.status) {
    const isActive = f.status === 'active'
    filtered = filtered.filter(i => i.is_active === isActive)
  }
  if (f.search) {
    const search = f.search.toLowerCase()
    filtered = filtered.filter(i => 
      i.display_name?.toLowerCase().includes(search) ||
      i.description?.toLowerCase().includes(search)
    )
  }
  
  return filtered
})

const filteredInsights = computed(() => {
  let filtered = richInsights.value
  const f = filters.value.rich_insights
  
  if (f.competency) {
    filtered = filtered.filter(i => i.competency_id === f.competency)
  }
  if (f.framework) {
    filtered = filtered.filter(i => i.framework_id === f.framework)
  }
  if (f.level) {
    filtered = filtered.filter(i => i.assessment_level_id === f.level)
  }
  if (f.analysisType) {
    filtered = filtered.filter(i => i.analysis_type_id === f.analysisType)
  }
  if (f.status) {
    const isActive = f.status === 'active'
    filtered = filtered.filter(i => i.is_active === isActive)
  }
  if (f.search) {
    const search = f.search.toLowerCase()
    filtered = filtered.filter(i => 
      i.performance_insight?.toLowerCase().includes(search) ||
      i.competency_display_names?.display_name?.toLowerCase().includes(search)
    )
  }
  
  return filtered
})

const filteredPerformanceAnalysis = computed(() => {
  let filtered = performanceAnalysis.value
  const f = filters.value.performance_analysis
  
  if (f.competency) {
    filtered = filtered.filter(i => i.competency_id === f.competency)
  }
  if (f.framework) {
    filtered = filtered.filter(i => i.framework_id === f.framework)
  }
  if (f.level) {
    filtered = filtered.filter(i => i.assessment_level_id === f.level)
  }
  if (f.scoringTier) {
    filtered = filtered.filter(i => i.scoring_tier_id === f.scoringTier)
  }
  if (f.status) {
    const isActive = f.status === 'active'
    filtered = filtered.filter(i => i.is_active === isActive)
  }
  if (f.search) {
    const search = f.search.toLowerCase()
    filtered = filtered.filter(i => 
      i.analysis_text?.toLowerCase().includes(search) ||
      i.competency_display_names?.display_name?.toLowerCase().includes(search)
    )
  }
  
  return filtered
})

const filteredStrategicActions = computed(() => {
  let filtered = strategicActions.value
  const f = filters.value.strategic_actions
  
  if (f.competency) {
    filtered = filtered.filter(i => i.competency_id === f.competency)
  }
  if (f.framework) {
    filtered = filtered.filter(i => i.framework_id === f.framework)
  }
  if (f.level) {
    filtered = filtered.filter(i => i.assessment_level_id === f.level)
  }
  if (f.scoringTier) {
    filtered = filtered.filter(i => i.scoring_tier_id === f.scoringTier)
  }
  if (f.status) {
    const isActive = f.status === 'active'
    filtered = filtered.filter(i => i.is_active === isActive)
  }
  if (f.search) {
    const search = f.search.toLowerCase()
    filtered = filtered.filter(i => 
      i.action_text?.toLowerCase().includes(search) ||
      i.competency_display_names?.display_name?.toLowerCase().includes(search)
    )
  }
  
  return filtered
})

const filteredLeverageStrengths = computed(() => {
  let filtered = leverageStrengths.value
  const f = filters.value.leverage_strengths
  
  if (f.competency) {
    filtered = filtered.filter(i => i.competency_id === f.competency)
  }
  if (f.framework) {
    filtered = filtered.filter(i => i.framework_id === f.framework)
  }
  if (f.level) {
    filtered = filtered.filter(i => i.assessment_level_id === f.level)
  }
  if (f.scoringTier) {
    filtered = filtered.filter(i => i.scoring_tier_id === f.scoringTier)
  }
  if (f.status) {
    const isActive = f.status === 'active'
    filtered = filtered.filter(i => i.is_active === isActive)
  }
  if (f.search) {
    const search = f.search.toLowerCase()
    filtered = filtered.filter(i => 
      i.strategy_text?.toLowerCase().includes(search) ||
      i.competency_display_names?.display_name?.toLowerCase().includes(search)
    )
  }
  
  return filtered
})

// Methods
const truncate = (text, length) => {
  if (!text) return ''
  return text.length > length ? text.substring(0, length) + '...' : text
}

// Removed getCompetencyName - now using relational data from joins

const countFilledFields = (insight) => {
  const fields = [
    'performance_insight',
    'development_focus', 
    'practical_application'
  ]
  return fields.filter(f => insight[f] && insight[f].trim()).length
}

const loadAllData = async () => {
  if (!adminSupabase) {
    console.warn('AdminSupabase not available')
    return
  }

  try {
    console.log('Loading competency management data...')
    
    // Load display names with framework information
    const { data: names, error: namesError } = await adminSupabase
      .from('competency_display_names')
      .select(`
        *,
        frameworks!framework_id (
          id,
          name,
          code
        )
      `)
      .order('display_name')
    
    if (namesError) {
      console.error('Error loading display names:', namesError)
    } else {
      displayNames.value = names || []
      console.log('Loaded display names:', displayNames.value.length)
    }

    // Load rich insights with competency, framework, level, and analysis type information
    const { data: insights, error: insightsError } = await adminSupabase
      .from('competency_consolidated_insights')
      .select(`
        *,
        competency_display_names (
          id,
          display_name
        ),
        frameworks (
          id,
          name,
          code
        ),
        assessment_levels (
          id,
          level_name,
          level_code
        ),
        analysis_types (
          id,
          name
        )
      `)
      .order('competency_id, created_at')
    
    if (insightsError) {
      console.error('Error loading rich insights:', insightsError)
    } else {
      richInsights.value = insights || []
      console.log('Loaded rich insights:', richInsights.value.length)
    }

    // Load performance analysis with competency, framework, level, and scoring tier information
    const { data: analysis, error: analysisError } = await adminSupabase
      .from('competency_performance_analysis')
      .select(`
        *,
        competency_display_names!competency_id (
          id,
          display_name
        ),
        frameworks!framework_id (
          id,
          name,
          code
        ),
        assessment_levels!assessment_level_id (
          id,
          level_name,
          level_code
        ),
        scoring_tiers!scoring_tier_id (
          id,
          tier_code,
          tier_name,
          score_min,
          score_max
        )
      `)
      .order('competency_id, framework_id, assessment_level_id')
    
    if (analysisError) {
      console.error('Error loading performance analysis:', analysisError)
    } else {
      performanceAnalysis.value = analysis || []
      console.log('Loaded performance analysis:', performanceAnalysis.value.length)
    }

    // Load strategic actions with competency, framework, level, and scoring tier information
    const { data: actions, error: actionsError } = await adminSupabase
      .from('competency_strategic_actions')
      .select(`
        *,
        competency_display_names!competency_id (
          id,
          display_name
        ),
        frameworks!framework_id (
          id,
          name,
          code
        ),
        assessment_levels!assessment_level_id (
          id,
          level_name,
          level_code
        ),
        scoring_tiers!scoring_tier_id (
          id,
          tier_code,
          tier_name,
          score_min,
          score_max
        )
      `)
      .order('competency_id, priority_order')
    
    if (actionsError) {
      console.error('Error loading strategic actions:', actionsError)
    } else {
      strategicActions.value = actions || []
      console.log('Loaded strategic actions:', strategicActions.value.length)
    }

    // Load leverage strengths with competency, framework, level, and scoring tier information
    const { data: strengths, error: strengthsError } = await adminSupabase
      .from('competency_leverage_strengths')
      .select(`
        *,
        competency_display_names!competency_id (
          id,
          display_name
        ),
        frameworks!framework_id (
          id,
          name,
          code
        ),
        assessment_levels!assessment_level_id (
          id,
          level_name,
          level_code
        ),
        scoring_tiers!scoring_tier_id (
          id,
          tier_code,
          tier_name,
          score_min,
          score_max
        )
      `)
      .order('competency_id, priority_order')
    
    if (strengthsError) {
      console.error('Error loading leverage strengths:', strengthsError)
    } else {
      leverageStrengths.value = strengths || []
      console.log('Loaded leverage strengths:', leverageStrengths.value.length)
    }

    console.log('All competency data loaded')
  } catch (error) {
    console.error('Error loading competency data:', error)
  }
}

const addCompetency = () => {
  window.location.href = '/docs/admin/competencies/edit'
}

const addInsight = () => {
  window.location.href = '/docs/admin/competencies/rich-insights'
}

const addAnalysis = () => {
  window.location.href = '/docs/admin/competencies/performance-analysis'
}

const addAction = () => {
  window.location.href = '/docs/admin/competencies/strategic-actions'
}

const addStrength = () => {
  window.location.href = '/docs/admin/competencies/leverage-strengths'
}

const editItem = (table, item) => {
  // Navigate to appropriate editor based on table
  switch (table) {
    case 'display_names':
      window.location.href = `/docs/admin/competencies/edit?id=${item.id}`
      break
    case 'rich_insights':
      window.location.href = `/docs/admin/competencies/rich-insights?id=${item.id}`
      break
    case 'performance_analysis':
      window.location.href = `/docs/admin/competencies/performance-analysis?id=${item.id}`
      break
    case 'strategic_actions':
      window.location.href = `/docs/admin/competencies/strategic-actions?id=${item.id}`
      break
    case 'leverage_strengths':
      window.location.href = `/docs/admin/competencies/leverage-strengths?id=${item.id}`
      break
    default:
      alert(`Editor for ${table} not found`)
  }
}

const deleteItem = async (table, item) => {
  const itemName = item.display_name || item.competency_display_names?.display_name || 'this item'
  
  if (!confirm(`Are you sure you want to delete "${itemName}"?\n\nThis action cannot be undone.`)) {
    return
  }

  if (!adminSupabase) {
    alert('Database connection not available')
    return
  }

  try {
    const tableMap = {
      'display_names': 'competency_display_names',
      'rich_insights': 'competency_consolidated_insights',
      'performance_analysis': 'competency_performance_analysis', 
      'strategic_actions': 'competency_strategic_actions',
      'leverage_strengths': 'competency_leverage_strengths'
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
    switch (table) {
      case 'display_names':
        displayNames.value = displayNames.value.filter(i => i.id !== item.id)
        break
      case 'rich_insights':
        richInsights.value = richInsights.value.filter(i => i.id !== item.id)
        break
      case 'performance_analysis':
        performanceAnalysis.value = performanceAnalysis.value.filter(i => i.id !== item.id)
        break
      case 'strategic_actions':
        strategicActions.value = strategicActions.value.filter(i => i.id !== item.id)
        break
      case 'leverage_strengths':
        leverageStrengths.value = leverageStrengths.value.filter(i => i.id !== item.id)
        break
    }

    alert(`Successfully deleted "${itemName}"`)
  } catch (error) {
    console.error('Delete error:', error)
    alert('Failed to delete item')
  }
}

onMounted(() => {
  isAuthLoaded.value = true
  injectBadgeStyles()
  loadAllData()
})
</script>

<style scoped>
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
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.tab-count.filtered {
  background: var(--vp-c-yellow-soft);
  color: var(--vp-c-yellow-darker);
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

/* Grid layouts for different tabs */
.display-names-grid {
  grid-template-columns: 2fr 2.5fr 120px 100px 140px;
}

.rich-insights-grid {
  grid-template-columns: 3fr 160px 100px 145px 60px 105px 140px;
}

.performance-analysis-grid {
  grid-template-columns: 3fr 185px 150px 110px 85px 155px;
}

.strategic-actions-grid {
  grid-template-columns: 3fr 185px 150px 110px 85px 85px 155px;
}

.leverage-strengths-grid {
  grid-template-columns: 3fr 120px 120px 100px 100px 140px;
}

/* Column Styles */
.col-name {
  font-weight: 500;
  color: var(--vp-c-text-1);
}

.col-text {
  color: var(--vp-c-text-2);
  font-size: 14px;
}

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

.competency-key {
  font-size: 12px;
  color: var(--vp-c-text-3);
  font-family: monospace;
  background: var(--vp-c-bg-mute);
  padding: 2px 6px;
  border-radius: 3px;
  width: fit-content;
}

.insight-text,
.analysis-text,
.action-text,
.leverage-text {
  color: var(--vp-c-text-2);
  font-size: 13px;
  line-height: 1.4;
}

.col-framework,
.col-level,
.col-range,
.col-status,
.col-priority {
  display: flex;
  align-items: center;
}

/* Badges now handled by shared useBadges composable */


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

/* Empty State */
.empty-state {
  padding: 60px 20px;
  text-align: center;
  color: var(--vp-c-text-2);
}

/* Responsive Design */
@media (max-width: 1200px) {
  .display-names-grid {
    grid-template-columns: 2fr 2fr 100px 90px 130px;
  }
  
  .rich-insights-grid {
    grid-template-columns: 2.5fr 140px 90px 120px 50px 90px 120px;
  }
  
  .performance-analysis-grid {
    grid-template-columns: 2.5fr 140px 90px 120px 50px 90px 120px;
  }
  
  .strategic-actions-grid,
  .leverage-strengths-grid {
    grid-template-columns: 2.5fr 100px 100px 80px 90px 130px;
  }
}

@media (max-width: 968px) {
  .admin-container {
    padding: 16px;
  }
  
  .filter-bar {
    flex-direction: column;
    gap: 8px;
  }
  
  .filter-input,
  .filter-select {
    width: 100%;
    min-width: unset;
  }
  
  .display-names-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }
  
  .rich-insights-grid,
  .performance-analysis-grid,
  .strategic-actions-grid,
  .leverage-strengths-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }
  
  .table-header {
    display: none;
  }
  
  .table-row {
    display: block;
    padding: 16px;
    border: 1px solid var(--vp-c-border);
    border-radius: 8px;
    margin-bottom: 12px;
  }
  
  .col-competency {
    margin-bottom: 12px;
  }
  
  .col-actions {
    margin-top: 12px;
    padding-top: 12px;
    border-top: 1px solid var(--vp-c-divider);
  }
}
</style>