<template>
  <div class="admin-container">
    <!-- Loading state during auth check -->
    <div v-if="!isAuthLoaded" class="admin-content">
      <div class="admin-header">
        <h1>🔄 Loading...</h1>
        <p class="admin-subtitle">Checking administrator access...</p>
      </div>
    </div>

    <!-- Admin Access Check -->
    <div v-else-if="!hasAdminAccess" class="admin-content">
      <div class="admin-header">
        <h1>⚠️ Admin Access Required</h1>
        <p class="admin-subtitle">You need administrator privileges to manage user accounts.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- User Account Editor -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>User Account Details</h1>
          <p class="admin-subtitle">View and manage individual user account</p>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <ActionButton href="/docs/admin/users/" variant="gray">Users</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>User Details</span>
      </nav>

      <!-- Loading State -->
      <div v-if="loading" class="loading-container">
        <div class="spinner"></div>
        <p>Loading user data...</p>
      </div>

      <!-- User Details -->
      <div v-else-if="userData" class="user-details-container">
        <!-- User Info Card -->
        <div class="info-card">
          <!-- Admin Badge removed -->
          
          <div class="card-header">
            <h2>👤 User Information</h2>
            <div class="status-badges">
              <span v-if="userData.is_admin_user" class="user-status admin">
                👑 Admin
              </span>
              <span v-if="userData.is_beta_user" class="user-status beta">
                ✓ Beta
              </span>
              <span v-if="!userData.is_admin_user && !userData.is_beta_user" class="user-status regular">
                Regular
              </span>
            </div>
          </div>
          
          <div class="info-grid">
            <div class="info-item">
              <label>Email</label>
              <div class="info-value">{{ userData.email }}</div>
            </div>
            
            <div class="info-item">
              <label>User ID</label>
              <div class="info-value">
                <code>{{ userData.id }}</code>
              </div>
            </div>
            
            <div class="info-item">
              <label>Email Verified</label>
              <div class="info-value">
                <span class="status-badge" :class="{ active: userData.email_confirmed_at }">
                  {{ userData.email_confirmed_at ? 'Verified' : 'Unverified' }}
                </span>
              </div>
            </div>
            
            <div class="info-item">
              <label>Account Created</label>
              <div class="info-value">{{ formatDate(userData.created_at) }}</div>
            </div>
            
            <div class="info-item">
              <label>Last Sign In</label>
              <div class="info-value">{{ formatDate(userData.last_sign_in_at) || 'Never' }}</div>
            </div>
            
            <div class="info-item">
              <label>Total Assessments</label>
              <div class="info-value">{{ userStats.totalAssessments }}</div>
            </div>
          </div>

          <div class="card-actions">
            <button @click="toggleAdminStatus" class="action-btn" :class="{ warning: !userData.is_admin_user, danger: userData.is_admin_user }">
              {{ userData.is_admin_user ? '👑 Remove Admin' : '👑 Grant Admin' }}
            </button>
            <button @click="toggleBetaStatus" class="action-btn" :class="{ success: !userData.is_beta_user, secondary: userData.is_beta_user }">
              {{ userData.is_beta_user ? '✓ Remove Beta' : '✓ Grant Beta' }}
            </button>
            <button @click="sendPasswordReset" class="action-btn secondary">
              🔑 Password Reset
            </button>
          </div>
        </div>

        <!-- Assessment History -->
        <div class="info-card">
          <div class="card-header">
            <h2>📝 Assessment History</h2>
            <span class="stat-badge">{{ userAssessments.length }} Attempts</span>
          </div>

          <div v-if="userAssessments.length > 0" class="assessment-list">
            <div class="list-header">
              <div>Assessment</div>
              <div>Score</div>
              <div>Completed</div>
              <div>Duration</div>
              <div>Actions</div>
            </div>
            
            <div v-for="assessment in userAssessments" :key="assessment.id" class="list-item">
              <div class="assessment-name">{{ getAssessmentName(assessment.assessment_id) }}</div>
              <div>
                <span class="score-badge" :class="getScoreClass(assessment.score)">
                  {{ Math.round(assessment.score || 0) }}%
                </span>
              </div>
              <div class="date-text">{{ formatDate(assessment.completed_at) }}</div>
              <div>{{ calculateDuration(assessment.created_at, assessment.completed_at) }}</div>
              <div>
                <button @click="viewAssessmentDetails(assessment)" class="action-btn small">
                  View
                </button>
              </div>
            </div>
          </div>
          
          <div v-else class="empty-state">
            <p>No assessment attempts yet</p>
          </div>
        </div>

        <!-- User Statistics -->
        <div class="stats-grid">
          <div class="stat-card">
            <div class="stat-icon">📊</div>
            <div class="stat-content">
              <div class="stat-value">{{ userStats.averageScore }}%</div>
              <div class="stat-label">Average Score</div>
            </div>
          </div>
          
          <div class="stat-card">
            <div class="stat-icon">✅</div>
            <div class="stat-content">
              <div class="stat-value">{{ userStats.completedAssessments }}</div>
              <div class="stat-label">Completed</div>
            </div>
          </div>
          
          <div class="stat-card">
            <div class="stat-icon">⏱️</div>
            <div class="stat-content">
              <div class="stat-value">{{ userStats.averageDuration }}</div>
              <div class="stat-label">Avg Duration</div>
            </div>
          </div>
          
          <div class="stat-card">
            <div class="stat-icon">🎯</div>
            <div class="stat-content">
              <div class="stat-value">{{ userStats.bestScore }}%</div>
              <div class="stat-label">Best Score</div>
            </div>
          </div>
        </div>

        <!-- Admin Actions -->
        <div class="admin-actions-card">
          <h3>⚙️ Admin Actions</h3>
          <div class="action-buttons">
            <button @click="exportUserData" class="action-btn">
              📥 Export User Data
            </button>
            <button @click="deleteAllAttempts" class="action-btn danger">
              🗑️ Delete All Attempts
            </button>
          </div>
        </div>
      </div>

      <!-- No User Found -->
      <div v-else class="empty-state">
        <h2>User Not Found</h2>
        <p>The requested user could not be found.</p>
        <ActionButton href="/docs/admin/users/" variant="secondary">Back to Users</ActionButton>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vitepress'
import { useAdminSession } from '../composables/useAdminSession'
import { useAdminSupabase } from '../composables/useAdminSupabase'
import ActionButton from './shared/ActionButton.vue'

const { hasAdminAccess } = useAdminSession()
const { adminSupabase } = useAdminSupabase()

// Authentication loading state
const isAuthLoaded = ref(false)
const route = useRoute()

// Get user ID from URL params
const userId = computed(() => {
  const id = route.query?.id || route.params?.id || new URLSearchParams(window.location.search).get('id')
  console.log('User ID from URL:', id)
  return id
})

// State
const loading = ref(true)
const userData = ref(null)
const userAssessments = ref([])
const assessments = ref([])

// Computed stats
const userStats = computed(() => {
  const attempts = userAssessments.value
  
  if (attempts.length === 0) {
    return {
      totalAssessments: 0,
      completedAssessments: 0,
      averageScore: 0,
      bestScore: 0,
      averageDuration: '0m'
    }
  }
  
  const completed = attempts.filter(a => a.completed_at)
  const scores = completed.map(a => a.score || 0)
  const avgScore = scores.length > 0 
    ? Math.round(scores.reduce((sum, s) => sum + s, 0) / scores.length)
    : 0
  
  const durations = completed.map(a => {
    const start = new Date(a.created_at)
    const end = new Date(a.completed_at)
    return (end - start) / (1000 * 60) // minutes
  })
  
  const avgDuration = durations.length > 0
    ? Math.round(durations.reduce((sum, d) => sum + d, 0) / durations.length)
    : 0
  
  return {
    totalAssessments: attempts.length,
    completedAssessments: completed.length,
    averageScore: avgScore,
    bestScore: scores.length > 0 ? Math.round(Math.max(...scores)) : 0,
    averageDuration: `${avgDuration}m`
  }
})

// Methods
const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
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

const getAssessmentName = (assessmentId) => {
  const assessment = assessments.value.find(a => a.id === assessmentId)
  return assessment?.title || 'Unknown Assessment'
}

const getScoreClass = (score) => {
  if (score >= 80) return 'high'
  if (score >= 60) return 'medium'
  return 'low'
}

const loadUserData = async () => {
  if (!userId.value || !adminSupabase) {
    loading.value = false
    return
  }

  try {
    // Load user data using Auth Admin API
    const { data: { user }, error: userError } = await adminSupabase.auth.admin.getUserById(userId.value)

    if (userError) {
      console.error('Error loading user:', userError)
    } else if (user) {
      userData.value = {
        ...user,
        is_beta_user: user.user_metadata?.beta_user === true,
        is_admin_user: user.user_metadata?.admin === true
      }
    }

    // Load assessments for reference
    const { data: assessmentsData, error: assessmentsError } = await adminSupabase
      .from('assessments')
      .select('id, title, slug')
      .eq('is_active', true)

    if (assessmentsError) {
      console.error('Error loading assessments:', assessmentsError)
    } else {
      assessments.value = assessmentsData || []
    }

    // Load user's assessment attempts
    const { data: attempts, error: attemptsError } = await adminSupabase
      .from('user_assessment_attempts')
      .select('*')
      .eq('user_id', userId.value)
      .order('completed_at', { ascending: false })

    if (attemptsError) {
      console.error('Error loading user attempts:', attemptsError)
    } else {
      userAssessments.value = attempts || []
    }

  } catch (error) {
    console.error('Error loading user data:', error)
  } finally {
    loading.value = false
  }
}

const toggleAdminStatus = async () => {
  if (!adminSupabase || !userData.value) return
  
  const newAdminStatus = !userData.value.is_admin_user
  const confirmMessage = newAdminStatus 
    ? `⚠️ GRANT ADMIN ACCESS to ${userData.value.email}?\n\nThis will give them full administrative privileges!` 
    : `Remove admin access from ${userData.value.email}?`
  
  if (!confirm(confirmMessage)) return
  
  try {
    const updatedMetadata = {
      ...(userData.value.user_metadata || {}),
      admin: newAdminStatus
    }
    
    const { error } = await adminSupabase.auth.admin.updateUserById(
      userData.value.id,
      { user_metadata: updatedMetadata }
    )
    
    if (error) {
      alert(`Failed to update admin status: ${error.message}`)
    } else {
      userData.value.is_admin_user = newAdminStatus
      userData.value.user_metadata = updatedMetadata
      alert(`Admin status ${newAdminStatus ? 'granted' : 'removed'} successfully!`)
    }
  } catch (error) {
    console.error('Error toggling admin status:', error)
    alert('Failed to update admin status.')
  }
}

const toggleBetaStatus = async () => {
  if (!adminSupabase || !userData.value) return
  
  const newBetaStatus = !userData.value.is_beta_user
  const confirmMessage = newBetaStatus 
    ? `Grant beta access to ${userData.value.email}?` 
    : `Remove beta access from ${userData.value.email}?`
  
  if (!confirm(confirmMessage)) return
  
  try {
    const updatedMetadata = {
      ...(userData.value.user_metadata || {}),
      beta_user: newBetaStatus
    }
    
    const { error } = await adminSupabase.auth.admin.updateUserById(
      userData.value.id,
      { user_metadata: updatedMetadata }
    )
    
    if (error) {
      alert(`Failed to update beta status: ${error.message}`)
    } else {
      userData.value.is_beta_user = newBetaStatus
      userData.value.user_metadata = updatedMetadata
      alert(`Beta status ${newBetaStatus ? 'granted' : 'removed'} successfully!`)
    }
  } catch (error) {
    console.error('Error toggling beta status:', error)
    alert('Failed to update beta status.')
  }
}

const sendPasswordReset = async () => {
  if (!adminSupabase || !userData.value) return
  
  if (!confirm(`Send password reset email to ${userData.value.email}?`)) return
  
  try {
    const { error } = await adminSupabase.auth.resetPasswordForEmail(userData.value.email)
    
    if (error) {
      alert(`Failed to send password reset: ${error.message}`)
    } else {
      alert('Password reset email sent successfully!')
    }
  } catch (error) {
    console.error('Error sending password reset:', error)
    alert('Failed to send password reset.')
  }
}

const viewAssessmentDetails = (assessment) => {
  alert(`Assessment details viewer coming soon for attempt ${assessment.id}`)
}

const exportUserData = () => {
  const data = {
    user: userData.value,
    assessments: userAssessments.value,
    statistics: userStats.value
  }
  
  const json = JSON.stringify(data, null, 2)
  const blob = new Blob([json], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `user-${userId.value}-data.json`
  a.click()
  URL.revokeObjectURL(url)
}

const deleteAllAttempts = async () => {
  if (!adminSupabase || !userData.value) return
  
  if (!confirm(`⚠️ DELETE all assessment attempts for ${userData.value.email}?\n\nThis cannot be undone!`)) return
  
  try {
    const { error } = await adminSupabase
      .from('user_assessment_attempts')
      .delete()
      .eq('user_id', userId.value)
    
    if (error) {
      alert(`Failed to delete attempts: ${error.message}`)
    } else {
      userAssessments.value = []
      alert('All assessment attempts deleted successfully!')
    }
  } catch (error) {
    console.error('Error deleting attempts:', error)
    alert('Failed to delete attempts.')
  }
}

onMounted(() => {
  isAuthLoaded.value = true
  loadUserData()
})
</script>

<style scoped>
.admin-container {
  max-width: 1200px;
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

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px;
  gap: 20px;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 3px solid var(--vp-c-border);
  border-top: 3px solid var(--vp-c-brand);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.user-details-container {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.info-card {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  padding: 24px;
  position: relative;
}

/* Admin Badge - Top Right Corner */
.admin-badge {
  position: absolute;
  top: -1px;
  right: -1px;
  background: var(--vp-c-warning);
  color: white;
  padding: 6px 12px;
  border-radius: 0 8px 0 16px;
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  box-shadow: 0 2px 8px rgba(255, 193, 7, 0.3);
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.85; }
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.card-header h2 {
  font-size: 20px;
  margin: 0;
}

.status-badges {
  display: flex;
  gap: 8px;
  align-items: center;
}

.user-status {
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-2);
}

.user-status.admin {
  background: var(--vp-c-warning-soft);
  color: var(--vp-c-warning-darker);
  font-weight: 700;
}

.user-status.beta {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green);
}

.user-status.regular {
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-2);
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 24px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.info-item label {
  font-size: 12px;
  font-weight: 600;
  text-transform: uppercase;
  color: var(--vp-c-text-3);
}

.info-value {
  font-size: 14px;
  color: var(--vp-c-text-1);
}

.info-value code {
  font-family: monospace;
  font-size: 12px;
  background: var(--vp-c-bg-mute);
  padding: 2px 6px;
  border-radius: 3px;
}

.card-actions {
  display: flex;
  gap: 12px;
  padding-top: 20px;
  border-top: 1px solid var(--vp-c-border);
}

.assessment-list {
  display: flex;
  flex-direction: column;
  gap: 1px;
  background: var(--vp-c-border);
  border-radius: 6px;
  overflow: hidden;
}

.list-header {
  display: grid;
  grid-template-columns: 2fr 80px 140px 80px 80px;
  padding: 12px 16px;
  background: var(--vp-c-bg-mute);
  font-weight: 600;
  font-size: 12px;
  text-transform: uppercase;
  color: var(--vp-c-text-2);
}

.list-item {
  display: grid;
  grid-template-columns: 2fr 80px 140px 80px 80px;
  padding: 12px 16px;
  background: var(--vp-c-bg);
  align-items: center;
  font-size: 14px;
}

.list-item:hover {
  background: var(--vp-c-bg-soft);
}

.assessment-name {
  font-weight: 500;
}

.date-text {
  font-size: 13px;
  color: var(--vp-c-text-2);
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
}

.stat-card {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon {
  font-size: 24px;
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 24px;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.stat-label {
  font-size: 12px;
  color: var(--vp-c-text-2);
  text-transform: uppercase;
}

.admin-actions-card {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  padding: 24px;
}

.admin-actions-card h3 {
  font-size: 18px;
  margin-bottom: 16px;
}

.action-buttons {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.action-btn {
  padding: 8px 16px;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand);
  border: none;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.action-btn:hover {
  background: var(--vp-c-brand);
  color: white;
}

.action-btn.secondary {
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-1);
}

.action-btn.secondary:hover {
  background: var(--vp-c-bg-soft);
}

.action-btn.warning {
  background: var(--vp-c-warning-soft);
  color: var(--vp-c-warning-darker);
  font-weight: 600;
}

.action-btn.warning:hover {
  background: var(--vp-c-warning);
  color: white;
}

.action-btn.success {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green-darker);
}

.action-btn.success:hover {
  background: var(--vp-c-green);
  color: white;
}

.action-btn.danger {
  background: var(--vp-c-danger-soft);
  color: var(--vp-c-danger);
}

.action-btn.danger:hover {
  background: var(--vp-c-danger);
  color: white;
}

.action-btn.small {
  padding: 4px 10px;
  font-size: 12px;
}

.stat-badge {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand);
  padding: 4px 12px;
  border-radius: 16px;
  font-size: 12px;
  font-weight: 600;
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

.empty-state {
  text-align: center;
  padding: 40px;
  color: var(--vp-c-text-2);
}

.empty-state h2 {
  margin-bottom: 12px;
}

@media (max-width: 768px) {
  .info-grid {
    grid-template-columns: 1fr;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .list-header,
  .list-item {
    grid-template-columns: 1fr;
    gap: 8px;
  }
  
  .list-header > *,
  .list-item > * {
    display: flex;
    justify-content: space-between;
  }
  
  .list-header > *::before,
  .list-item > *::before {
    content: attr(data-label);
    font-weight: 600;
  }
}
</style>