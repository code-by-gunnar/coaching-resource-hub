<template>
  <div class="admin-container">
    <!-- Loading state during auth check -->
    <AdminLoadingState v-if="!isAuthLoaded" />

    <!-- Admin Access Check -->
    <div v-else-if="!hasAdminAccess" class="admin-content">
      <div class="admin-header">
        <h1>⚠️ Admin Access Required</h1>
        <p class="admin-subtitle">You need administrator privileges to manage users.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- User Management with Tabs -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>👥 User Management</h1>
          <p class="admin-subtitle">User account management and assessment attempt tracking</p>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>Users</span>
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
        <!-- User Accounts Tab -->
        <div v-show="activeTab === 'users'" class="table-section">
          <div class="section-header">
            <div>
              <h2>User Accounts</h2>
              <p class="section-description">User registration and account management</p>
            </div>
            <div class="header-stats">
              <span class="stat-badge">Total Users: {{ users.length }}</span>
              <span class="stat-badge">Beta Users: {{ betaUsersCount }}</span>
            </div>
          </div>

          <div class="filter-bar">
            <input 
              v-model="userFilters.search" 
              type="text" 
              class="filter-input"
              placeholder="Search users by email..."
            >
            <select v-model="userFilters.betaStatus" class="filter-select">
              <option value="">All Users</option>
              <option value="beta">Beta Users Only</option>
              <option value="regular">Regular Users Only</option>
            </select>
            <select v-model="userFilters.dateRange" class="filter-select">
              <option value="">All Time</option>
              <option value="today">Joined Today</option>
              <option value="week">This Week</option>
              <option value="month">This Month</option>
            </select>
          </div>

          <AdminTableHeader :columns="userTableColumns">

            <div v-for="user in filteredUsers" :key="user.id" class="table-row user-accounts-grid">
              <div class="col-user">
                <div class="user-email">{{ user.email }}</div>
                <div class="user-status">{{ user.email_confirmed_at ? 'Confirmed' : 'Unconfirmed' }}</div>
              </div>
              <div class="col-joined">{{ formatDate(user.created_at) }}</div>
              <div class="col-last-signin">{{ formatDate(user.last_sign_in_at) }}</div>
              <div class="col-tests">{{ getUserAssessmentCount(user.id) }}</div>
              <div class="col-admin">
                <button 
                  @click="toggleAdminStatus(user)" 
                  class="admin-toggle"
                  :class="{ active: user.is_admin_user }"
                  :title="user.is_admin_user ? 'Click to remove admin access' : 'Click to grant admin access'"
                >
                  {{ user.is_admin_user ? '👑' : '—' }}
                </button>
              </div>
              <div class="col-beta">
                <button 
                  @click="toggleBetaStatus(user)" 
                  class="beta-toggle"
                  :class="{ active: user.is_beta_user }"
                  :title="user.is_beta_user ? 'Click to remove beta access' : 'Click to grant beta access'"
                >
                  {{ user.is_beta_user ? '✓' : '—' }}
                </button>
              </div>
              <div class="col-actions">
                <button @click="editUser(user)" class="action-btn">Details</button>
              </div>
            </div>
          </AdminTableHeader>
        </div>

        <!-- User Assessment Attempts Tab -->
        <div v-show="activeTab === 'attempts'" class="table-section">
          <div class="section-header">
            <div>
              <h2>User Assessment Attempts</h2>
              <p class="section-description">Complete assessment attempts with scores, timing, and detailed results</p>
            </div>
            <div class="header-actions">
              <ActionButton @click="exportAttempts" variant="secondary" icon="📥">Export CSV</ActionButton>
            </div>
          </div>

          <div class="stats-summary">
            <div class="stat-card">
              <div class="stat-number">{{ userAttempts.length }}</div>
              <div class="stat-label">Total Attempts</div>
            </div>
            <div class="stat-card">
              <div class="stat-number">{{ completedAttempts }}</div>
              <div class="stat-label">Completed</div>
            </div>
            <div class="stat-card">
              <div class="stat-number">{{ averageScore }}%</div>
              <div class="stat-label">Avg Score</div>
            </div>
            <div class="stat-card">
              <div class="stat-number">{{ averageTimeSpent }}m</div>
              <div class="stat-label">Avg Time</div>
            </div>
          </div>

          <div class="filter-bar">
            <input 
              v-model="attemptFilters.userSearch" 
              type="text" 
              class="filter-input"
              placeholder="Search by user email or ID..."
            >
            <select v-model="attemptFilters.assessment" class="filter-select">
              <option value="">All Assessments</option>
              <option v-for="assessment in assessments" :key="assessment.id" :value="assessment.id">
                {{ assessment.title }}
              </option>
            </select>
            <select v-model="attemptFilters.status" class="filter-select">
              <option value="">All Status</option>
              <option value="completed">Completed</option>
              <option value="in_progress">In Progress</option>
            </select>
            <select v-model="attemptFilters.dateRange" class="filter-select">
              <option value="">All Time</option>
              <option value="today">Today</option>
              <option value="week">This Week</option>
              <option value="month">This Month</option>
            </select>
          </div>

          <AdminTableHeader :columns="attemptsTableColumns">
            <div v-for="item in filteredAttempts" :key="item.id" class="table-row attempts-grid">
              <div class="col-user">
                <div class="user-email">{{ getUserEmail(item) }}</div>
                <div class="user-id">ID: {{ truncateId(item.user_id) }}</div>
                <div class="attempt-id">Attempt: {{ truncateId(item.id) }}</div>
              </div>
              <div class="col-assessment">
                <div class="assessment-name">{{ getAssessmentName(item.assessment_id) }}</div>
                <div class="assessment-framework">{{ getAssessmentFramework(item.assessment_id) }}</div>
              </div>
              <div class="col-progress">
                <div class="progress-fraction">{{ item.correct_answers || 0 }}/{{ item.total_questions || 0 }}</div>
                <div class="progress-bar">
                  <div class="progress-fill" :style="{ width: getProgressWidth(item) }"></div>
                </div>
              </div>
              <div class="col-score">
                <span v-if="item.status === 'completed'" class="score-badge" :class="getScoreClass(item.score)">
                  {{ Math.round(item.score || 0) }}%
                </span>
                <span v-else class="status-badge in-progress">In Progress</span>
              </div>
              <div class="col-timing">
                <div class="duration">{{ formatDuration(item.time_spent) }}</div>
                <div class="completion-date">{{ formatDate(item.completed_at || item.started_at) }}</div>
              </div>
              <div class="col-status">
                <span class="status-badge" :class="item.status">
                  {{ formatStatus(item.status) }}
                </span>
              </div>
              <div class="col-actions">
                <ActionButton @click="viewAttemptDetails(item)" variant="primary" size="small">
                  {{ item.status === 'completed' ? 'View Results' : 'View Progress' }}
                </ActionButton>
              </div>
            </div>
          </AdminTableHeader>
        </div>


        <!-- Assessment Analytics Tab -->
        <div v-show="activeTab === 'results'" class="table-section">
          <div class="section-header">
            <div>
              <h2>📊 Assessment Analytics & Insights</h2>
              <p class="section-description">Aggregated performance data, trends, and user rankings</p>
            </div>
            <div class="header-actions">
              <ActionButton @click="exportAnalytics" variant="secondary" icon="📥">Export Analytics</ActionButton>
              <ActionButton @click="refreshAnalytics" variant="primary" icon="🔄">Refresh</ActionButton>
            </div>
          </div>

          <!-- Overall Performance Dashboard -->
          <div class="analytics-dashboard">
            <!-- Performance Overview -->
            <div class="analytics-overview">
              <div class="overview-card improvement">
                <div class="overview-value improvement">{{ getAverageImprovement() }}%</div>
                <div class="overview-label">Avg. Improvement</div>
              </div>
              <div class="overview-card time">
                <div class="overview-value time">{{ getAverageCompletionTime() }}</div>
                <div class="overview-label">Avg. Completion Time</div>
              </div>
              <div class="overview-card mastery">
                <div class="overview-value mastery">{{ getMasteryRate() }}%</div>
                <div class="overview-label">Mastery Rate</div>
              </div>
              <div class="overview-card retake">
                <div class="overview-value retake">{{ getRetakeRate() }}%</div>
                <div class="overview-label">Retake Rate</div>
              </div>
            </div>

            <!-- Competency Performance Analysis -->
            <div class="analytics-section">
              <h3>🎖️ Competency Performance Breakdown</h3>
              <div class="competency-item" v-for="comp in getCompetencyAnalysis()" :key="comp.id">
                <div class="competency-name">{{ comp.name }}</div>
                <div class="competency-stats">
                  <span class="score-display" :class="getScoreClass(comp.avgScore)">{{ Math.round(comp.avgScore) }}%</span>
                  <span>{{ comp.totalQuestions }} questions</span>
                  <span>{{ comp.attempts }} attempts</span>
                  <span>{{ comp.successRate }}% success</span>
                </div>
              </div>
            </div>

            <!-- User Rankings & Leaderboard -->
            <div class="analytics-section">
              <h3>🏆 Top Performers</h3>
              <div class="leaderboard-item" v-for="(user, index) in getTopPerformers()" :key="user.id">
                <div class="rank-display" :class="getRankClass(index + 1)">
                  {{ getRankDisplay(index + 1) }}
                </div>
                <div class="performer-info">
                  <div class="performer-email">{{ user.email }}</div>
                  <div class="performer-stats">
                    <span class="best-score">{{ Math.round(user.bestScore) }}%</span>
                    <span>{{ user.attempts }} attempts</span>
                    <span v-if="user.improvement > 0">+{{ user.improvement }}% improvement</span>
                    <span v-else-if="user.improvement < 0">{{ user.improvement }}% change</span>
                    <span v-else>No improvement data</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Trend Analysis -->
            <div class="analytics-section">
              <h3>📈 Performance Trends</h3>
              <div class="trends-chart">
                <div v-for="week in getWeeklyTrends()" :key="week.label" class="trend-bar" :style="{ height: Math.max(week.score, 5) + '%' }" :data-score="Math.round(week.score)">
                </div>
              </div>
              <div class="trend-labels">
                <span v-for="week in getWeeklyTrends()" :key="week.label">{{ week.label }}</span>
              </div>
            </div>
            
            <!-- Assessment Difficulty Analysis -->
            <div class="analytics-section">
              <h3>⚖️ Assessment Difficulty Analysis</h3>
              <div class="difficulty-item" v-for="assessment in getAssessmentDifficulty()" :key="assessment.id">
                <div class="difficulty-name">{{ assessment.name }}</div>
                <div class="difficulty-stats">
                  <span class="difficulty-badge" :class="assessment.difficulty">{{ assessment.difficultyLabel }}</span>
                  <span>Avg: {{ assessment.avgScore }}%</span>
                  <span>Pass: {{ assessment.passRate }}%</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
  
  <!-- Attempt Details Modal -->
  <AttemptDetailsModal
    :is-open="modalState.isOpen"
    :attempt="modalState.attempt"
    :user-email="modalState.attempt ? getUserEmail(modalState.attempt) : ''"
    :assessment-name="modalState.attempt ? getAssessmentName(modalState.attempt.assessment_id) : ''"
    size="extra-large"
    @close="modalState.isOpen = false"
  />
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAdminSession } from '../composables/useAdminSession'
import { useAdminSupabase } from '../composables/useAdminSupabase'
import ActionButton from './shared/ActionButton.vue'
import AdminLoadingState from './shared/AdminLoadingState.vue'
import AdminTableHeader from './shared/AdminTableHeader.vue'
import AttemptDetailsModal from './shared/AttemptDetailsModal.vue'

const { hasAdminAccess } = useAdminSession()
const { adminSupabase } = useAdminSupabase()

// Authentication loading state
const isAuthLoaded = ref(false)

// Active tab
const activeTab = ref('users')

// Data
const users = ref([])
const assessments = ref([])
const userAttempts = ref([])
const userAssessmentResults = ref([])
const competencyPerformanceData = ref([])

// Modal state
const modalState = ref({
  isOpen: false,
  attempt: null
})

// Additional filters
const resultFilters = ref({
  userSearch: '',
  assessment: '',
  scoreRange: '',
  dateRange: ''
})

const leaderboardFilter = ref({
  assessment: '',
  period: 'all'
})

const resultsTableColumns = [
  { label: 'User', width: '2fr' },
  { label: 'Assessment', width: '2fr' },
  { label: 'Performance', width: '140px' },
  { label: 'Score', width: '100px' },
  { label: 'Timing', width: '140px' },
  { label: 'Actions', width: '140px' }
]

// Table configuration
const userTableColumns = [
  { label: 'Email & Status', width: '3fr' },
  { label: 'Joined', width: '120px' },
  { label: 'Last Sign In', width: '120px' },
  { label: 'Tests', width: '80px' },
  { label: 'Admin', width: '80px' },
  { label: 'Beta', width: '80px' },
  { label: 'Actions', width: '120px' }
]

const attemptsTableColumns = [
  { label: 'User', width: '2fr' },
  { label: 'Assessment', width: '2fr' },
  { label: 'Progress', width: '120px' },
  { label: 'Score', width: '100px' },
  { label: 'Timing', width: '140px' },
  { label: 'Status', width: '100px' },
  { label: 'Actions', width: '140px' }
]


// Filters
const userFilters = ref({
  search: '',
  betaStatus: '',
  dateRange: ''
})

const attemptFilters = ref({
  userSearch: '',
  assessment: '',
  status: '',
  dateRange: ''
})

// Table tabs configuration
const tableTabs = computed(() => [
  {
    id: 'users',
    label: 'User Accounts',
    icon: '👤',
    count: users.value.length,
    description: 'Account management'
  },
  {
    id: 'attempts',
    label: 'Assessment Attempts',
    icon: '📝',
    count: userAttempts.value.length,
    description: 'User attempts'
  },
  {
    id: 'results',
    label: 'Analytics & Insights',
    icon: '📊',
    count: userAssessmentResults.value.length,
    description: 'Performance analytics'
  }
])

// Computed
const betaUsersCount = computed(() => {
  return users.value.filter(user => user.is_beta_user).length
})

const filteredUsers = computed(() => {
  let filtered = users.value
  
  if (userFilters.value.search) {
    const searchTerm = userFilters.value.search.toLowerCase()
    filtered = filtered.filter(user => 
      user.email?.toLowerCase().includes(searchTerm)
    )
  }
  
  if (userFilters.value.betaStatus) {
    if (userFilters.value.betaStatus === 'beta') {
      filtered = filtered.filter(user => user.is_beta_user)
    } else if (userFilters.value.betaStatus === 'regular') {
      filtered = filtered.filter(user => !user.is_beta_user)
    }
  }
  
  if (userFilters.value.dateRange) {
    const now = new Date()
    let cutoffDate
    
    switch (userFilters.value.dateRange) {
      case 'today':
        cutoffDate = new Date(now.getFullYear(), now.getMonth(), now.getDate())
        break
      case 'week':
        cutoffDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
        break
      case 'month':
        cutoffDate = new Date(now.getFullYear(), now.getMonth(), 1)
        break
    }
    
    if (cutoffDate) {
      filtered = filtered.filter(user => 
        new Date(user.created_at) >= cutoffDate
      )
    }
  }
  
  return filtered.sort((a, b) => 
    new Date(b.created_at) - new Date(a.created_at)
  )
})

const filteredAttempts = computed(() => {
  let filtered = userAttempts.value
  
  // User search filter
  if (attemptFilters.value.userSearch) {
    const searchTerm = attemptFilters.value.userSearch.toLowerCase()
    filtered = filtered.filter(a => {
      const userEmail = getUserEmail(a).toLowerCase()
      return userEmail.includes(searchTerm) || a.user_id.toLowerCase().includes(searchTerm)
    })
  }
  
  // Assessment filter
  if (attemptFilters.value.assessment) {
    filtered = filtered.filter(a => a.assessment_id === attemptFilters.value.assessment)
  }
  
  // Status filter
  if (attemptFilters.value.status) {
    filtered = filtered.filter(a => a.status === attemptFilters.value.status)
  }
  
  // Date range filter
  if (attemptFilters.value.dateRange) {
    const now = new Date()
    let cutoffDate
    
    switch (attemptFilters.value.dateRange) {
      case 'today':
        cutoffDate = new Date(now.getFullYear(), now.getMonth(), now.getDate())
        break
      case 'week':
        cutoffDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
        break
      case 'month':
        cutoffDate = new Date(now.getFullYear(), now.getMonth(), 1)
        break
    }
    
    if (cutoffDate) {
      filtered = filtered.filter(a => 
        new Date(a.completed_at || a.started_at || a.created_at) >= cutoffDate
      )
    }
  }
  
  return filtered.sort((a, b) => 
    new Date(b.completed_at || b.started_at || b.created_at) - new Date(a.completed_at || a.started_at || a.created_at)
  )
})

const averageScore = computed(() => {
  const validScores = userAttempts.value.filter(a => a.score != null).map(a => a.score)
  if (validScores.length === 0) return 0
  return Math.round(validScores.reduce((sum, score) => sum + score, 0) / validScores.length)
})

const completedAttempts = computed(() => {
  return userAttempts.value.filter(a => a.status === 'completed').length
})

const averageTimeSpent = computed(() => {
  const validTimes = userAttempts.value.filter(a => a.time_spent != null && a.time_spent > 0).map(a => a.time_spent)
  if (validTimes.length === 0) return 0
  return Math.round(validTimes.reduce((sum, time) => sum + time, 0) / validTimes.length)
})

const filteredResults = computed(() => {
  let filtered = userAssessmentResults.value
  
  // User search filter
  if (resultFilters.value.userSearch) {
    const searchTerm = resultFilters.value.userSearch.toLowerCase()
    filtered = filtered.filter(r => {
      const userEmail = getUserEmail(r).toLowerCase()
      return userEmail.includes(searchTerm) || r.user_id.toLowerCase().includes(searchTerm)
    })
  }
  
  // Assessment filter
  if (resultFilters.value.assessment) {
    filtered = filtered.filter(r => r.assessment_id === resultFilters.value.assessment)
  }
  
  // Score range filter
  if (resultFilters.value.scoreRange) {
    filtered = filtered.filter(r => {
      const score = r.score || 0
      switch (resultFilters.value.scoreRange) {
        case 'high': return score >= 80
        case 'medium': return score >= 60 && score < 80
        case 'low': return score < 60
        default: return true
      }
    })
  }
  
  // Date range filter
  if (resultFilters.value.dateRange) {
    const now = new Date()
    let cutoffDate
    
    switch (resultFilters.value.dateRange) {
      case 'today':
        cutoffDate = new Date(now.getFullYear(), now.getMonth(), now.getDate())
        break
      case 'week':
        cutoffDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
        break
      case 'month':
        cutoffDate = new Date(now.getFullYear(), now.getMonth(), 1)
        break
    }
    
    if (cutoffDate) {
      filtered = filtered.filter(r => 
        new Date(r.completed_at) >= cutoffDate
      )
    }
  }
  
  return filtered.sort((a, b) => 
    new Date(b.completed_at) - new Date(a.completed_at)
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

const getAssessmentName = (assessmentId) => {
  const assessment = assessments.value.find(a => a.id === assessmentId)
  return assessment?.title || 'Unknown'
}

const getUserEmail = (attempt) => {
  // Find the user in the loaded users array
  const user = users.value.find(u => u.id === attempt.user_id)
  return user?.email || 'Unknown'
}

const getUserAssessmentCount = (userId) => {
  return userAttempts.value.filter(a => a.user_id === userId).length
}

const getScoreClass = (score) => {
  if (score >= 80) return 'high'
  if (score >= 60) return 'medium'
  return 'low'
}

const formatDate = (dateString) => {
  if (!dateString) return 'Never'
  return new Date(dateString).toLocaleDateString() + ' ' + 
         new Date(dateString).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
}

const calculateDuration = (startDate, endDate) => {
  if (!startDate || !endDate) return 'N/A'
  const start = new Date(startDate)
  const end = new Date(endDate)
  const diffMinutes = Math.round((end - start) / (1000 * 60))
  return diffMinutes > 0 ? `${diffMinutes}m` : 'N/A'
}

const formatDuration = (timeSpentMinutes) => {
  if (!timeSpentMinutes || timeSpentMinutes <= 0) return 'N/A'
  if (timeSpentMinutes < 60) return `${timeSpentMinutes}m`
  const hours = Math.floor(timeSpentMinutes / 60)
  const minutes = timeSpentMinutes % 60
  return minutes > 0 ? `${hours}h ${minutes}m` : `${hours}h`
}

const formatStatus = (status) => {
  switch (status) {
    case 'completed': return 'Completed'
    case 'in_progress': return 'In Progress'
    case 'abandoned': return 'Abandoned'
    default: return status || 'Unknown'
  }
}

const getProgressWidth = (attempt) => {
  if (!attempt.total_questions || attempt.total_questions === 0) return '0%'
  const answered = attempt.current_question_index || attempt.correct_answers || 0
  return `${Math.min((answered / attempt.total_questions) * 100, 100)}%`
}

const getAssessmentFramework = (assessmentId) => {
  const assessment = assessments.value.find(a => a.id === assessmentId)
  return assessment?.framework || 'N/A'
}

const getScoreDistribution = () => {
  const results = userAssessmentResults.value
  return {
    high: results.filter(r => (r.score || 0) >= 80).length,
    medium: results.filter(r => (r.score || 0) >= 60 && (r.score || 0) < 80).length,
    low: results.filter(r => (r.score || 0) < 60).length
  }
}

const getHighestScore = () => {
  const scores = userAssessmentResults.value.map(r => r.score || 0)
  return scores.length > 0 ? Math.max(...scores) : 0
}

const getLowestScore = () => {
  const scores = userAssessmentResults.value.map(r => r.score || 0)
  return scores.length > 0 ? Math.min(...scores) : 0
}

const getPassRate = () => {
  const results = userAssessmentResults.value
  if (results.length === 0) return 0
  const passed = results.filter(r => (r.score || 0) >= 70).length
  return Math.round((passed / results.length) * 100)
}

const getAverageImprovement = () => {
  // Calculate improvement for users who have multiple attempts
  const userScores = {}
  userAssessmentResults.value.forEach(result => {
    const key = `${result.user_id}_${result.assessment_id}`
    if (!userScores[key]) userScores[key] = []
    userScores[key].push(result.score || 0)
  })
  
  let totalImprovement = 0
  let count = 0
  
  Object.values(userScores).forEach(scores => {
    if (scores.length > 1) {
      const improvement = scores[scores.length - 1] - scores[0]
      totalImprovement += improvement
      count++
    }
  })
  
  return count > 0 ? Math.round(totalImprovement / count) : 0
}

const getAverageCompletionTime = () => {
  const validTimes = userAssessmentResults.value
    .filter(r => r.time_spent && r.time_spent > 0)
    .map(r => r.time_spent)
  
  if (validTimes.length === 0) return '0m'
  
  const avgMinutes = Math.round(validTimes.reduce((sum, time) => sum + time, 0) / validTimes.length)
  if (avgMinutes < 60) return `${avgMinutes}m`
  const hours = Math.floor(avgMinutes / 60)
  const mins = avgMinutes % 60
  return mins > 0 ? `${hours}h ${mins}m` : `${hours}h`
}

const getMasteryRate = () => {
  const results = userAssessmentResults.value
  if (results.length === 0) return 0
  const mastered = results.filter(r => (r.score || 0) >= 85).length
  return Math.round((mastered / results.length) * 100)
}

const getRetakeRate = () => {
  const userAttemptCounts = {}
  userAssessmentResults.value.forEach(result => {
    const key = `${result.user_id}_${result.assessment_id}`
    userAttemptCounts[key] = (userAttemptCounts[key] || 0) + 1
  })
  
  const totalUsers = Object.keys(userAttemptCounts).length
  const retakers = Object.values(userAttemptCounts).filter(count => count > 1).length
  
  return totalUsers > 0 ? Math.round((retakers / totalUsers) * 100) : 0
}

const getCompetencyAnalysis = () => {
  // Use actual competency data from database
  if (competencyPerformanceData.value.length > 0) {
    return competencyPerformanceData.value
  }
  
  // Fallback message when no data is available
  return [{
    id: 'no-data',
    name: 'No competency data available',
    avgScore: 0,
    totalQuestions: 0,
    attempts: 0,
    successRate: 0
  }]
}

const getTopPerformers = () => {
  // Group results by user
  const userPerformance = {}
  
  userAssessmentResults.value.forEach(result => {
    if (!userPerformance[result.user_id]) {
      userPerformance[result.user_id] = {
        id: result.user_id,
        email: getUserEmail(result),
        scores: [],
        firstAttempt: result.completed_at,
        attempts: 0
      }
    }
    userPerformance[result.user_id].scores.push(result.score || 0)
    userPerformance[result.user_id].attempts++
  })
  
  // Calculate best score and improvement
  const performers = Object.values(userPerformance).map(user => {
    const bestScore = Math.max(...user.scores)
    const firstScore = user.scores[0]
    const lastScore = user.scores[user.scores.length - 1]
    const improvement = user.scores.length > 1 ? lastScore - firstScore : 0
    
    return {
      ...user,
      bestScore,
      improvement
    }
  })
  
  // Sort by best score and return top 10
  return performers
    .sort((a, b) => b.bestScore - a.bestScore)
    .slice(0, 10)
}

const getWeeklyTrends = () => {
  // Calculate weekly average scores for the last 4 weeks
  const now = new Date()
  const weeks = []
  
  for (let i = 3; i >= 0; i--) {
    const weekStart = new Date(now.getTime() - (i * 7 + 7) * 24 * 60 * 60 * 1000)
    const weekEnd = new Date(now.getTime() - i * 7 * 24 * 60 * 60 * 1000)
    
    const weekResults = userAssessmentResults.value.filter(r => {
      const date = new Date(r.completed_at)
      return date >= weekStart && date < weekEnd
    })
    
    const avgScore = weekResults.length > 0
      ? weekResults.reduce((sum, r) => sum + (r.score || 0), 0) / weekResults.length
      : 0
    
    weeks.push({
      label: `W${4 - i}`,
      score: avgScore
    })
  }
  
  return weeks
}

const getAssessmentDifficulty = () => {
  // Calculate difficulty based on average scores
  return assessments.value.map(assessment => {
    const results = userAssessmentResults.value.filter(r => r.assessment_id === assessment.id)
    
    if (results.length === 0) {
      return {
        id: assessment.id,
        name: assessment.title,
        avgScore: 0,
        passRate: 0,
        difficulty: 'unknown',
        difficultyLabel: 'No Data'
      }
    }
    
    const avgScore = Math.round(results.reduce((sum, r) => sum + (r.score || 0), 0) / results.length)
    const passRate = Math.round(results.filter(r => (r.score || 0) >= 70).length / results.length * 100)
    
    let difficulty, difficultyLabel
    if (avgScore >= 80) {
      difficulty = 'easy'
      difficultyLabel = 'Easy'
    } else if (avgScore >= 65) {
      difficulty = 'medium'
      difficultyLabel = 'Medium'
    } else {
      difficulty = 'hard'
      difficultyLabel = 'Hard'
    }
    
    return {
      id: assessment.id,
      name: assessment.title,
      avgScore,
      passRate,
      difficulty,
      difficultyLabel
    }
  }).sort((a, b) => a.avgScore - b.avgScore)
}

const getRankClass = (rank) => {
  if (rank === 1) return 'gold'
  if (rank === 2) return 'silver'
  if (rank === 3) return 'bronze'
  return 'regular'
}

const getRankDisplay = (rank) => {
  if (rank === 1) return '🥇'
  if (rank === 2) return '🥈'
  if (rank === 3) return '🥉'
  return `#${rank}`
}

const refreshAnalytics = async () => {
  await loadAllData()
  await loadCompetencyPerformanceData()
}

const exportAnalytics = () => {
  const analyticsData = {
    overview: {
      average_improvement: getAverageImprovement(),
      average_completion_time: getAverageCompletionTime(),
      mastery_rate: getMasteryRate(),
      retake_rate: getRetakeRate(),
      total_attempts: userAssessmentResults.value.length,
      unique_users: new Set(userAssessmentResults.value.map(r => r.user_id)).size
    },
    top_performers: getTopPerformers().map((user, index) => ({
      rank: index + 1,
      email: user.email,
      best_score: user.bestScore,
      attempts: user.attempts,
      improvement: user.improvement
    })),
    competency_performance: getCompetencyAnalysis(),
    assessment_difficulty: getAssessmentDifficulty(),
    weekly_trends: getWeeklyTrends()
  }
  
  // Convert to formatted JSON for export
  const blob = new Blob([JSON.stringify(analyticsData, null, 2)], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `assessment_analytics_${new Date().toISOString().split('T')[0]}.json`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
  
  alert('Analytics data exported successfully!')
}

const loadCompetencyPerformanceData = async () => {
  if (!adminSupabase) return

  try {
    console.log('Loading competency performance data...')
    
    // Get competency performance analysis with actual data
    const { data: competencyData, error: competencyError } = await adminSupabase
      .from('competency_display_names')
      .select(`
        id,
        display_name,
        assessment_questions!competency_id (
          id,
          user_question_responses (
            is_correct,
            attempt_id,
            user_assessment_attempts!attempt_id (
              user_id,
              status
            )
          )
        )
      `)

    if (competencyError) {
      console.error('Error loading competency data:', competencyError)
      return
    }

    // Process competency performance data
    const competencyPerformance = (competencyData || []).map(competency => {
      const questions = competency.assessment_questions || []
      const allResponses = []
      
      // Flatten all responses for this competency
      questions.forEach(question => {
        if (question.user_question_responses) {
          question.user_question_responses.forEach(response => {
            if (response.user_assessment_attempts && response.user_assessment_attempts.status === 'completed') {
              allResponses.push(response)
            }
          })
        }
      })

      const totalQuestions = questions.length
      const totalResponses = allResponses.length
      const correctResponses = allResponses.filter(r => r.is_correct).length
      const avgScore = totalResponses > 0 ? Math.round((correctResponses / totalResponses) * 100) : 0
      const successRate = totalResponses > 0 ? Math.round((correctResponses / totalResponses) * 100) : 0
      
      // Count unique attempts
      const uniqueAttempts = new Set()
      allResponses.forEach(response => {
        if (response.user_assessment_attempts) {
          uniqueAttempts.add(response.attempt_id)
        }
      })

      return {
        id: competency.id,
        name: competency.display_name,
        avgScore,
        totalQuestions,
        attempts: uniqueAttempts.size,
        successRate
      }
    }).filter(comp => comp.totalQuestions > 0) // Only include competencies with questions

    competencyPerformanceData.value = competencyPerformance
    console.log('Loaded competency performance data:', competencyPerformance.length, 'competencies')

  } catch (error) {
    console.error('Error loading competency performance data:', error)
    // Fallback to empty array on error
    competencyPerformanceData.value = []
  }
}

const loadAllData = async () => {
  if (!adminSupabase) return

  try {
    console.log('Loading user management data...')
    
    // Load users using the Auth Admin API
    const { data: { users: usersData }, error: usersError } = await adminSupabase.auth.admin.listUsers({
      page: 1,
      perPage: 500
    })

    if (usersError) {
      console.error('Error loading users:', usersError)
    } else {
      // Process user metadata for beta and admin status
      users.value = (usersData || []).map(user => {
        // Check both user_metadata and raw_user_meta_data for compatibility
        const metadata = user.user_metadata || user.raw_user_meta_data || {}
        return {
          ...user,
          is_beta_user: metadata.beta_user === true,
          is_admin_user: metadata.admin === true
        }
      })
      console.log('Loaded users:', users.value.length)
    }

    // Load assessments for reference
    const { data: assessmentsData, error: assessmentsError } = await adminSupabase
      .from('assessments')
      .select('id, title, slug')
      .eq('is_active', true)
      .order('title')

    if (assessmentsError) {
      console.error('Error loading assessments:', assessmentsError)
    } else {
      assessments.value = assessmentsData || []
      console.log('Loaded assessments:', assessments.value.length)
    }

    // Load user attempts with enhanced data
    const { data: attemptsData, error: attemptsError } = await adminSupabase
      .from('user_assessment_attempts')
      .select(`
        *,
        assessments!assessment_id (
          id, title, slug
        )
      `)
      .order('created_at', { ascending: false })
      .limit(500) // Increased limit for better data

    if (attemptsError) {
      console.error('Error loading attempts:', attemptsError)
    } else {
      userAttempts.value = attemptsData || []
      console.log('Loaded attempts:', userAttempts.value.length)
    }

    // Filter completed attempts for results view
    userAssessmentResults.value = userAttempts.value.filter(a => a.completed_at)

    // Load competency performance data
    await loadCompetencyPerformanceData()

  } catch (error) {
    console.error('Error loading user management data:', error)
  }
}

const toggleAdminStatus = async (user) => {
  if (!adminSupabase) return
  
  const newAdminStatus = !user.is_admin_user
  const confirmMessage = newAdminStatus 
    ? `⚠️ GRANT ADMIN ACCESS to ${user.email}?\n\nThis will give them full administrative privileges!` 
    : `Remove admin access from ${user.email}?`
  
  if (!confirm(confirmMessage)) return
  
  try {
    // Update user metadata to toggle admin status
    const currentMetadata = user.user_metadata || user.raw_user_meta_data || {}
    const updatedMetadata = {
      ...currentMetadata,
      admin: newAdminStatus
    }
    
    const { error } = await adminSupabase.auth.admin.updateUserById(
      user.id,
      { user_metadata: updatedMetadata }
    )
    
    if (error) {
      console.error('Error updating admin status:', error)
      alert(`Failed to update admin status: ${error.message}`)
    } else {
      // Update local state
      const userIndex = users.value.findIndex(u => u.id === user.id)
      if (userIndex !== -1) {
        users.value[userIndex] = {
          ...users.value[userIndex],
          is_admin_user: newAdminStatus,
          user_metadata: updatedMetadata
        }
      }
      console.log(`Admin status ${newAdminStatus ? 'granted' : 'removed'} for ${user.email}`)
    }
  } catch (error) {
    console.error('Error toggling admin status:', error)
    alert('Failed to update admin status. Check console for details.')
  }
}

const toggleBetaStatus = async (user) => {
  if (!adminSupabase) return
  
  const newBetaStatus = !user.is_beta_user
  const confirmMessage = newBetaStatus 
    ? `Grant beta access to ${user.email}?` 
    : `Remove beta access from ${user.email}?`
  
  if (!confirm(confirmMessage)) return
  
  try {
    // Update user metadata to toggle beta status
    const currentMetadata = user.user_metadata || user.raw_user_meta_data || {}
    const updatedMetadata = {
      ...currentMetadata,
      beta_user: newBetaStatus
    }
    
    const { error } = await adminSupabase.auth.admin.updateUserById(
      user.id,
      { user_metadata: updatedMetadata }
    )
    
    if (error) {
      console.error('Error updating beta status:', error)
      alert(`Failed to update beta status: ${error.message}`)
    } else {
      // Update local state
      const userIndex = users.value.findIndex(u => u.id === user.id)
      if (userIndex !== -1) {
        users.value[userIndex] = {
          ...users.value[userIndex],
          is_beta_user: newBetaStatus,
          user_metadata: updatedMetadata
        }
      }
      console.log(`Beta status ${newBetaStatus ? 'granted' : 'removed'} for ${user.email}`)
    }
  } catch (error) {
    console.error('Error toggling beta status:', error)
    alert('Failed to update beta status. Check console for details.')
  }
}

const editUser = (user) => {
  // Navigate to user details page
  window.location.href = `/docs/admin/users/edit?id=${user.id}`
}

const viewAttemptDetails = (attempt) => {
  modalState.value.attempt = attempt
  modalState.value.isOpen = true
}

const viewDetailedResults = (result) => {
  modalState.value.attempt = result
  modalState.value.isOpen = true
}

const exportAttempts = () => {
  if (filteredAttempts.value.length === 0) {
    alert('No attempts to export. Please adjust your filters or load data first.')
    return
  }

  const data = filteredAttempts.value.map((attempt, index) => ({
    row_number: index + 1,
    attempt_id: attempt.id,
    user_email: getUserEmail(attempt),
    user_id: attempt.user_id,
    assessment_name: getAssessmentName(attempt.assessment_id),
    assessment_id: attempt.assessment_id,
    status: formatStatus(attempt.status),
    score_percentage: attempt.status === 'completed' ? Math.round(attempt.score || 0) : '',
    correct_answers: attempt.correct_answers || 0,
    total_questions: attempt.total_questions || 0,
    accuracy_percentage: attempt.total_questions ? Math.round((attempt.correct_answers || 0) / attempt.total_questions * 100) : 0,
    time_spent_minutes: attempt.time_spent || 0,
    started_at: attempt.started_at || attempt.created_at,
    completed_at: attempt.completed_at || '',
    last_activity: attempt.last_activity_at || '',
    current_question: attempt.current_question_index || 0
  }))
  
  exportToCSV(data, 'assessment_attempts')
}

const exportResults = () => {
  if (filteredResults.value.length === 0) {
    alert('No results to export. Please adjust your filters or load data first.')
    return
  }

  const data = filteredResults.value.map((result, index) => ({
    row_number: index + 1,
    attempt_id: result.id,
    user_email: getUserEmail(result),
    user_id: result.user_id,
    assessment_name: getAssessmentName(result.assessment_id),
    assessment_id: result.assessment_id,
    final_score_percentage: Math.round(result.score || 0),
    correct_answers: result.correct_answers,
    total_questions: result.total_questions,
    accuracy_percentage: Math.round((result.correct_answers / result.total_questions) * 100),
    time_spent_minutes: result.time_spent,
    performance_level: result.score >= 80 ? 'Excellent' : result.score >= 70 ? 'Good' : result.score >= 60 ? 'Satisfactory' : 'Needs Improvement',
    completed_at: result.completed_at,
    started_at: result.started_at || result.created_at
  }))
  
  exportToCSV(data, 'assessment_results')
}

const exportToCSV = (data, filename) => {
  // Escape CSV values properly
  const escapeCsvValue = (value) => {
    if (value === null || value === undefined) return ''
    const str = String(value)
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
  
  const timestamp = new Date().toISOString().split('T')[0]
  const filterSuffix = Object.values(attemptFilters.value).some(v => v) || Object.values(resultFilters.value).some(v => v) ? '_filtered' : ''
  a.download = `${filename}_${timestamp}${filterSuffix}.csv`
  
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
  
  alert(`Successfully exported ${data.length} records to CSV file!`)
}



onMounted(() => {
  isAuthLoaded.value = true
  loadAllData()
})
</script>

<style scoped>
/* Reuse the same styles as AdminAssessmentsTabs */
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
  padding: 10px 12px;
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
  padding: 2px 6px;
  border-radius: 10px;
  font-size: 11px;
  font-weight: 600;
}

/* Tab Content - Consistent style */
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

.header-stats {
  display: flex;
  gap: 12px;
}

.header-actions {
  display: flex;
  gap: 12px;
  align-items: center;
}

.stat-badge {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand);
  padding: 4px 12px;
  border-radius: 16px;
  font-size: 12px;
  font-weight: 600;
}

/* Filter Bar - Consistent with other admin components */
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

.filter-select {
  padding: 8px 12px;
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  background: var(--vp-c-bg);
  font-size: 14px;
  min-width: 120px;
}

/* Data Table - Consistent with other admin components */
.data-table {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  border-radius: 12px;
  overflow: hidden;
  margin: 1rem 0 4rem 0;
}

.table-header {
  display: grid;
  gap: 1rem;
  padding: 1rem 1.5rem;
  background: var(--vp-c-bg);
  border-bottom: 2px solid var(--vp-c-border);
  font-weight: 600;
  font-size: 0.9rem;
  color: var(--vp-c-text-1);
}

.table-row {
  display: grid;
  gap: 1rem;
  padding: 1rem 1.5rem;
  border-bottom: 1px solid var(--vp-c-divider);
  align-items: center;
  transition: background 0.2s;
  font-size: 0.9rem;
}

.table-row:hover {
  background: var(--vp-c-bg);
}

.table-row:last-child {
  border-bottom: none;
}

/* User Accounts Grid - Simple pattern that works like resources */
.user-accounts-grid {
  grid-template-columns: 3fr 120px 120px 80px 80px 80px 120px;
}

/* Attempts Grid */
.attempts-grid {
  grid-template-columns: 2fr 2fr 120px 100px 140px 100px 140px;
}

/* Results Grid */
.results-grid {
  grid-template-columns: 2fr 2fr 140px 100px 140px 140px;
}


/* Responsive Grid Layouts */
@media (max-width: 1200px) {
  .user-accounts-grid {
    grid-template-columns: 2.5fr 100px 100px 70px 70px 70px 100px;
  }
  
  .attempts-grid {
    grid-template-columns: 1.8fr 1.8fr 110px 90px 120px 90px 120px;
  }
  
  .results-grid {
    grid-template-columns: 1.8fr 1.8fr 120px 90px 120px 120px;
  }
  
}

@media (max-width: 968px) {
  .user-accounts-grid {
    grid-template-columns: 2fr 90px 90px 60px 60px 60px 90px;
  }
  
  .attempts-grid {
    grid-template-columns: 1.5fr 1.5fr 100px 80px 110px 80px 110px;
  }
  
  .results-grid {
    grid-template-columns: 1.5fr 1.5fr 110px 80px 110px 110px;
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
}

/* Analytics Dashboard Styles */
.analytics-overview {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 20px;
  margin-bottom: 32px;
}

.overview-card {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  border-radius: 12px;
  padding: 24px;
  text-align: center;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.overview-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: var(--vp-c-bg-mute);
}

.overview-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

.overview-card.improvement::before {
  background: var(--vp-c-brand);
}

.overview-card.time::before {
  background: var(--vp-c-indigo);
}

.overview-card.mastery::before {
  background: var(--vp-c-success);
}

.overview-card.retake::before {
  background: var(--vp-c-warning);
}

.overview-value {
  font-size: 36px;
  font-weight: 800;
  color: var(--vp-c-text-1);
  margin-bottom: 8px;
  line-height: 1;
}

.overview-value.improvement {
  color: var(--vp-c-brand);
}

.overview-value.time {
  color: var(--vp-c-indigo);
}

.overview-value.mastery {
  color: var(--vp-c-success);
}

.overview-value.retake {
  color: var(--vp-c-warning);
}

.overview-label {
  font-size: 14px;
  color: var(--vp-c-text-2);
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.analytics-section {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 24px;
}

.analytics-section h3 {
  margin: 0 0 20px 0;
  font-size: 18px;
  font-weight: 600;
  color: var(--vp-c-text-1);
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.competency-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 0;
  border-bottom: 1px solid var(--vp-c-divider);
}

.competency-item:last-child {
  border-bottom: none;
}

.competency-name {
  font-weight: 500;
  color: var(--vp-c-text-1);
}

.competency-stats {
  display: flex;
  gap: 16px;
  align-items: center;
  font-size: 14px;
  color: var(--vp-c-text-2);
}

.score-display {
  font-weight: 600;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 13px;
}

.score-display.high {
  background: var(--vp-c-success-soft);
  color: var(--vp-c-success);
}

.score-display.medium {
  background: var(--vp-c-warning-soft);
  color: var(--vp-c-warning-darker);
}

.score-display.low {
  background: var(--vp-c-danger-soft);
  color: var(--vp-c-danger);
}

.leaderboard-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 0;
  border-bottom: 1px solid var(--vp-c-divider);
}

.leaderboard-item:last-child {
  border-bottom: none;
}

.rank-display {
  font-size: 20px;
  font-weight: 700;
  min-width: 40px;
  text-align: center;
}

.rank-display.gold {
  color: #ffd700;
}

.rank-display.silver {
  color: #c0c0c0;
}

.rank-display.bronze {
  color: #cd7f32;
}

.rank-display.regular {
  color: var(--vp-c-text-2);
  font-size: 16px;
}

.performer-info {
  flex: 1;
}

.performer-email {
  font-weight: 500;
  color: var(--vp-c-text-1);
  margin-bottom: 2px;
}

.performer-stats {
  font-size: 12px;
  color: var(--vp-c-text-2);
  display: flex;
  gap: 12px;
}

.best-score {
  font-weight: 600;
  padding: 2px 6px;
  border-radius: 3px;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand);
}

.trends-chart {
  display: flex;
  align-items: end;
  gap: 8px;
  height: 60px;
  margin: 16px 0;
}

.trend-bar {
  flex: 1;
  background: var(--vp-c-brand-soft);
  border-radius: 4px 4px 0 0;
  min-height: 4px;
  position: relative;
  transition: all 0.3s ease;
}

.trend-bar:hover {
  background: var(--vp-c-brand);
}

.trend-bar::after {
  content: attr(data-score) '%';
  position: absolute;
  top: -20px;
  left: 50%;
  transform: translateX(-50%);
  font-size: 10px;
  color: var(--vp-c-text-2);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.trend-bar:hover::after {
  opacity: 1;
}

.trend-labels {
  display: flex;
  justify-content: space-between;
  margin-top: 8px;
  font-size: 12px;
  color: var(--vp-c-text-2);
}

.difficulty-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 0;
  border-bottom: 1px solid var(--vp-c-divider);
}

.difficulty-item:last-child {
  border-bottom: none;
}

.difficulty-name {
  font-weight: 500;
  color: var(--vp-c-text-1);
}

.difficulty-stats {
  display: flex;
  gap: 16px;
  align-items: center;
  font-size: 14px;
}

.difficulty-badge {
  padding: 4px 12px;
  border-radius: 16px;
  font-size: 12px;
  font-weight: 600;
  text-transform: uppercase;
}

.difficulty-badge.easy {
  background: var(--vp-c-success-soft);
  color: var(--vp-c-success);
}

.difficulty-badge.medium {
  background: var(--vp-c-warning-soft);
  color: var(--vp-c-warning-darker);
}

.difficulty-badge.hard {
  background: var(--vp-c-danger-soft);
  color: var(--vp-c-danger);
}

.difficulty-badge.unknown {
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-2);
}

.refresh-button {
  padding: 6px 12px;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand);
  border: 1px solid var(--vp-c-brand);
  border-radius: 6px;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s;
}

.refresh-button:hover {
  background: var(--vp-c-brand);
  color: white;
}

@media (max-width: 768px) {
  .analytics-overview {
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
    margin-bottom: 24px;
  }
  
  .overview-card {
    padding: 20px 16px;
  }
  
  .overview-value {
    font-size: 28px;
  }
  
  .overview-label {
    font-size: 12px;
  }
  
  .analytics-section {
    padding: 20px 16px;
    margin-bottom: 16px;
  }
  
  .analytics-section h3 {
    font-size: 16px;
    margin-bottom: 16px;
  }
  
  .competency-stats,
  .performer-stats,
  .difficulty-stats {
    flex-direction: column;
    gap: 4px;
    align-items: flex-end;
  }
  
  .leaderboard-item {
    flex-wrap: wrap;
  }
  
  .performer-info {
    min-width: 0;
  }
  
  .user-accounts-grid,
  .attempts-grid,
  .results-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }
  
  .user-accounts-grid .table-header,
  .attempts-grid .table-header,
  .results-grid .table-header {
    display: none;
  }
  
  .user-accounts-grid .table-row,
  .attempts-grid .table-row,
  .results-grid .table-row {
    display: flex;
    flex-direction: column;
    gap: 8px;
    padding: 16px;
  }
  
  .user-accounts-grid .table-row > div,
  .attempts-grid .table-row > div,
  .results-grid .table-row > div {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 0;
    border-bottom: 1px solid var(--vp-c-divider);
  }
  
  .user-accounts-grid .table-row > div:last-child,
  .attempts-grid .table-row > div:last-child,
  .results-grid .table-row > div:last-child {
    border-bottom: none;
    justify-content: center;
  }
  
  /* User Accounts Labels */
  .user-accounts-grid .col-user::before { content: 'Email: '; font-weight: 600; }
  .user-accounts-grid .col-joined::before { content: 'Joined: '; font-weight: 600; }
  .user-accounts-grid .col-last-signin::before { content: 'Last Sign In: '; font-weight: 600; }
  .user-accounts-grid .col-tests::before { content: 'Tests: '; font-weight: 600; }
  .user-accounts-grid .col-admin::before { content: 'Admin: '; font-weight: 600; }
  .user-accounts-grid .col-beta::before { content: 'Beta: '; font-weight: 600; }
  
  /* Attempts Labels */
  .attempts-grid .col-user::before { content: 'User: '; font-weight: 600; }
  .attempts-grid .col-assessment::before { content: 'Assessment: '; font-weight: 600; }
  .attempts-grid .col-progress::before { content: 'Progress: '; font-weight: 600; }
  .attempts-grid .col-score::before { content: 'Score: '; font-weight: 600; }
  .attempts-grid .col-timing::before { content: 'Timing: '; font-weight: 600; }
  .attempts-grid .col-status::before { content: 'Status: '; font-weight: 600; }
  
  /* Results Labels */
  .results-grid .col-user::before { content: 'User: '; font-weight: 600; }
  .results-grid .col-assessment::before { content: 'Assessment: '; font-weight: 600; }
  .results-grid .col-performance::before { content: 'Performance: '; font-weight: 600; }
  .results-grid .col-score::before { content: 'Score: '; font-weight: 600; }
  .results-grid .col-timing::before { content: 'Timing: '; font-weight: 600; }
  
}

/* Column Styles - Consistent with admin pattern */
.col-user {
  min-width: 0;
}

.user-email {
  font-weight: 500;
  color: var(--vp-c-text-1);
  margin-bottom: 2px;
  word-break: break-word;
}

.user-status {
  font-size: 12px;
  color: var(--vp-c-text-2);
}

.col-joined,
.col-last-signin,
.col-tests {
  font-size: 13px;
  color: var(--vp-c-text-2);
}

.col-admin,
.col-beta {
  display: flex;
  justify-content: center;
}

.col-actions {
  display: flex;
  justify-content: center;
}

.status-badge {
  display: inline-block;
  padding: 3px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 500;
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-2);
}

.status-badge.active {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
}

/* Toggle Buttons - Simplified consistent style */
.admin-toggle,
.beta-toggle {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 14px;
  font-weight: 500;
  border: 1px solid var(--vp-c-border);
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-3);
  cursor: pointer;
  transition: all 0.2s;
  min-width: 32px;
  text-align: center;
}

.admin-toggle:hover {
  border-color: var(--vp-c-warning);
  background: var(--vp-c-warning-soft);
}

.admin-toggle.active {
  background: var(--vp-c-warning-soft);
  color: var(--vp-c-warning-darker);
  border-color: var(--vp-c-warning);
  font-weight: 600;
}

.admin-toggle.active:hover {
  background: var(--vp-c-danger-soft);
  color: var(--vp-c-danger);
  border-color: var(--vp-c-danger);
}

.beta-toggle:hover {
  border-color: var(--vp-c-brand);
  background: var(--vp-c-brand-soft);
}

.beta-toggle.active {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
  border-color: var(--vp-c-green);
  font-weight: 600;
}

.beta-toggle.active:hover {
  background: var(--vp-c-danger-soft);
  color: var(--vp-c-danger);
  border-color: var(--vp-c-danger);
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

/* Action Button - Consistent style */
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

/* User Email/ID Display */
.col-user {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.user-email {
  font-weight: 500;
  color: var(--vp-c-text-1);
  font-size: 0.9rem;
}

.user-id,
.attempt-id {
  font-size: 0.75rem;
  color: var(--vp-c-text-3);
  font-family: monospace;
}

.attempt-id {
  color: var(--vp-c-brand-2);
  font-size: 0.7rem;
}

/* Enhanced Column Styles */
.col-assessment {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.assessment-name {
  font-weight: 500;
  color: var(--vp-c-text-1);
  font-size: 14px;
}

.assessment-framework,
.assessment-meta {
  font-size: 12px;
  color: var(--vp-c-text-3);
}

.col-progress {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.progress-fraction {
  font-size: 12px;
  color: var(--vp-c-text-2);
  font-weight: 500;
}

.progress-bar {
  width: 100%;
  height: 6px;
  background: var(--vp-c-bg-mute);
  border-radius: 3px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: var(--vp-c-brand);
  transition: width 0.3s ease;
}

.col-performance {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.correct-answers {
  font-weight: 500;
  color: var(--vp-c-text-1);
  font-size: 13px;
}

.accuracy-rate {
  font-size: 11px;
  color: var(--vp-c-text-3);
}

.col-timing {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.duration,
.completion-time {
  font-weight: 500;
  color: var(--vp-c-text-1);
  font-size: 13px;
}

.completion-date {
  font-size: 11px;
  color: var(--vp-c-text-3);
}

.score-badge.large {
  font-size: 14px;
  padding: 6px 12px;
  font-weight: 600;
}

.status-badge.in-progress {
  background: var(--vp-c-warning-soft);
  color: var(--vp-c-warning-darker);
}

.status-badge.completed {
  background: var(--vp-c-success-soft);
  color: var(--vp-c-success);
}

.status-badge.abandoned {
  background: var(--vp-c-danger-soft);
  color: var(--vp-c-danger);
}

/* Stats Summary */
.stats-summary {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
  padding: 20px;
  background: var(--vp-c-bg);
  border-radius: 8px;
  border: 1px solid var(--vp-c-border);
}

.stat-card {
  text-align: center;
  padding: 12px;
}

.stat-number {
  font-size: 24px;
  font-weight: 700;
  color: var(--vp-c-brand);
  margin-bottom: 4px;
}

.stat-label {
  font-size: 12px;
  color: var(--vp-c-text-2);
  text-transform: uppercase;
  font-weight: 500;
}

/* Results Summary */
.results-summary {
  margin-bottom: 24px;
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
}

.summary-card {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  padding: 20px;
}

.summary-card h3 {
  margin: 0 0 16px 0;
  font-size: 16px;
  color: var(--vp-c-text-1);
}

.score-distribution {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.score-range {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  border-radius: 6px;
}

.score-range.high {
  background: var(--vp-c-success-soft);
  color: var(--vp-c-success-darker);
}

.score-range.medium {
  background: var(--vp-c-warning-soft);
  color: var(--vp-c-warning-darker);
}

.score-range.low {
  background: var(--vp-c-danger-soft);
  color: var(--vp-c-danger-darker);
}

.range-label {
  font-weight: 500;
}

.range-count {
  font-weight: 600;
  font-size: 18px;
}

.metrics-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.metric-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.metric-label {
  color: var(--vp-c-text-2);
  font-size: 14px;
}

.metric-value {
  font-weight: 600;
  color: var(--vp-c-text-1);
  font-size: 16px;
}

/* Additional Analytics Styles */
.analytics-dashboard {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.improvement.positive {
  color: var(--vp-c-success);
  font-weight: 600;
}

.improvement.negative {
  color: var(--vp-c-danger);
  font-weight: 600;
}

.improvement.neutral {
  color: var(--vp-c-text-2);
}

/* Fix missing refresh button styles */
.refresh-button {
  padding: 6px 12px;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand);
  border: 1px solid var(--vp-c-brand);
  border-radius: 6px;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s;
}

.refresh-button:hover {
  background: var(--vp-c-brand);
  color: white;
}
</style>