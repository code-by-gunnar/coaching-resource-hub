<template>
  <div class="admin-container">
    <!-- Loading state during hydration -->
    <AdminLoadingState v-if="!isHydrated" 
      title="Loading Admin Hub" 
      subtitle="Authenticating access..." />

    <!-- Admin Authentication Check -->
    <div v-else-if="!user" class="admin-content">
      <div class="admin-header">
        <h1>🔐 Admin Access Required</h1>
        <p class="admin-subtitle">Please sign in to access the admin hub.</p>
      </div>
      <Auth />
    </div>

    <!-- Admin Access Check -->
    <div v-else-if="user && !hasAdminAccess" class="admin-content">
      <div class="admin-header">
        <h1>⚠️ Admin Access Denied</h1>
        <p class="admin-subtitle">You do not have administrator privileges.</p>
        <p>Contact the system administrator for access.</p>
      </div>
    </div>

    <!-- Admin Hub Dashboard -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>🛠️ Admin Hub</h1>
          <p class="admin-subtitle">Development Administration Interface</p>
        </div>
        
        <div class="header-info">
          <div class="info-card">
            <h3>Admin Session</h3>
            <p>Welcome, {{ user.email }}!</p>
            <div class="session-status">
              <span class="status-indicator" :class="sessionStatus">{{ sessionStatus }}</span>
              <span v-if="sessionStatus === 'active'" class="session-time">{{ formatTimeRemaining }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Core Assessment System -->
      <div class="admin-section">
        <h2>🎯 Assessment System</h2>
        <p class="section-description">Core assessment engine - Everything flows from competencies</p>
      </div>

      <div class="admin-grid">
        <div class="admin-card primary" @click="navigateTo('competencies')">
          <div class="card-badge">Foundation</div>
          <h3>🎖️ Competencies</h3>
          <p>Foundation of everything - 5 interconnected tables</p>
          <p><strong>{{ competencyStats.total }}</strong> competencies across frameworks</p>
          <ul class="card-features">
            <li>Display Names - Core definitions</li>
            <li>Rich Insights - PDF report content</li>
            <li>Performance Analysis - Scoring</li>
            <li>Strategic Actions - Improvements</li>
            <li>Leverage Strengths - Best practices</li>
          </ul>
        </div>

        <div class="admin-card" @click="navigateTo('assessments')">
          <div class="card-badge">Workflow</div>
          <h3>📝 Assessments & Questions</h3>
          <p>Complete assessment system - 6 related tables</p>
          <p><strong>{{ assessmentStats.total }}</strong> assessments, <strong>{{ questionStats.total }}</strong> questions</p>
          <ul class="card-features">
            <li>Assessments - Main configurations</li>
            <li>Questions - Linked to assessments</li>
            <li>User Attempts - Tracking</li>
            <li>User Progress - Completion status</li>
          </ul>
        </div>
      </div>

      <!-- Independent Modules -->
      <div class="admin-section">
        <h2>📚 Supporting Resources</h2>
        <p class="section-description">Enhance assessments with additional content</p>
      </div>

      <div class="admin-grid">
        <div class="admin-card" @click="navigateTo('resources')">
          <h3>📖 Learning Resources</h3>
          <p>Articles, videos, and guides linked to competencies</p>
          <p>Skill development materials</p>
        </div>

        <div class="admin-card" @click="navigateTo('tags')">
          <h3>🏷️ Skill Tags</h3>
          <p>Categorize and tag competencies</p>
          <p>Improve resource discovery</p>
        </div>
      </div>

      <!-- System Administration -->
      <div class="admin-section">
        <h2>⚙️ System Administration</h2>
        <p class="section-description">User management and system tools</p>
      </div>

      <div class="admin-grid">
        <div class="admin-card" @click="navigateTo('users')">
          <h3>👥 User Management</h3>
          <p>User accounts, beta access, and assessment attempts</p>
          <p><strong>{{ userStats.total }}</strong> registered users</p>
        </div>

        <div class="admin-card" @click="navigateTo('content-uploader')">
          <h3>📤 Content Uploader</h3>
          <p>Upload files to organized folders</p>
          <p>Bulk upload with URL generation</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useAuth } from '../composables/useAuth'
import { useSupabase } from '../composables/useSupabase'
import { useAdminSession } from '../composables/useAdminSession'
import AdminLoadingState from './shared/AdminLoadingState.vue'

const { user } = useAuth()
const { supabase } = useSupabase()
const { hasAdminAccess, sessionStatus, formatTimeRemaining, createSession } = useAdminSession()

// Hydration state to prevent SSR mismatches
const isHydrated = ref(false)

// Debug admin access
console.log('AdminHub debug:', {
  user: user.value,
  hasAdminAccess: hasAdminAccess.value,
  sessionStatus: sessionStatus.value,
  isHydrated: isHydrated.value
})

// Watch for changes
watch([user, hasAdminAccess], ([newUser, newAccess]) => {
  console.log('AdminHub watch update:', {
    user: newUser,
    hasAdminAccess: newAccess,
    sessionStatus: sessionStatus.value,
    isHydrated: isHydrated.value
  })
})

// Admin access is now managed by useAdminSession composable

// Stats
const assessmentStats = ref({ total: 0 })
const questionStats = ref({ total: 0 })
const competencyStats = ref({ total: 0 })
const insightStats = ref({ total: 0 })
const userStats = ref({ total: 0 })
const totalAssessmentsTaken = ref(0)
const betaUserCount = ref(0)
const completionRate = ref(0)

// Load dashboard stats
const loadStats = async () => {
  if (!supabase || !hasAdminAccess.value) return

  try {
    // Assessment count
    const { count: assessmentCount } = await supabase
      .from('assessments')
      .select('*', { count: 'exact', head: true })
    assessmentStats.value.total = assessmentCount || 0

    // Question count  
    const { count: questionCount } = await supabase
      .from('assessment_questions')
      .select('*', { count: 'exact', head: true })
    questionStats.value.total = questionCount || 0

    // Competency count
    const { count: competencyCount } = await supabase
      .from('competency_display_names')
      .select('*', { count: 'exact', head: true })
    competencyStats.value.total = competencyCount || 0

    // User stats - Use estimate from public data
    // Note: Actual user count requires service role key
    try {
      const { count: attemptUsersCount } = await supabase
        .from('user_assessment_attempts')
        .select('user_id', { count: 'exact', head: true })
      userStats.value.total = Math.max(attemptUsersCount || 0, 1) // At least 1 (current user)
    } catch (error) {
      console.warn('Could not fetch user count estimate:', error)
      userStats.value.total = 1
    }

    // Assessment attempts
    const { count: attemptCount } = await supabase
      .from('user_assessment_attempts')
      .select('*', { count: 'exact', head: true })
    totalAssessmentsTaken.value = attemptCount || 0

    // Beta user count - Use estimate from assessment activity
    // Note: Exact count requires service role key
    try {
      const { count: betaAttempts } = await supabase
        .from('user_assessment_attempts')
        .select('user_id', { count: 'exact', head: true })
      // Estimate: users who have taken assessments are likely beta users
      betaUserCount.value = Math.min(betaAttempts || 0, userStats.value.total)
    } catch (error) {
      console.warn('Could not fetch beta user count estimate:', error)
      betaUserCount.value = 0
    }

    // Calculate completion rate
    const { count: completedCount } = await supabase
      .from('user_assessment_attempts')
      .select('*', { count: 'exact', head: true })
      .eq('status', 'completed')
    
    if (totalAssessmentsTaken.value > 0) {
      completionRate.value = Math.round((completedCount / totalAssessmentsTaken.value) * 100)
    }

  } catch (error) {
    console.error('Error loading admin stats:', error)
  }
}

// Navigation
const navigateTo = (section) => {
  window.location.href = `/docs/admin/${section}/`
}

// Watch for admin access changes
watch(hasAdminAccess, (newValue) => {
  if (newValue) {
    loadStats()
  }
}, { immediate: true })

onMounted(async () => {
  // Set hydration complete on client side
  isHydrated.value = true
  
  console.log('AdminHub mounted, hydration complete')
  
  // Force session refresh on page load
  if (user.value) {
    console.log('User found, creating session...')
    await createSession(true)
  }
  
  if (hasAdminAccess.value) {
    console.log('Admin access confirmed, loading stats...')
    loadStats()
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

.header-info {
  flex-shrink: 0;
  min-width: 300px;
}

.info-card {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  padding: 1rem;
}

.info-card h3 {
  margin: 0 0 0.5rem 0;
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--vp-c-brand-1);
}

.info-card p {
  margin: 0;
  font-size: 0.85rem;
  line-height: 1.4;
}

.session-status {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-top: 0.5rem;
}

.status-indicator {
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
}

.status-indicator.active {
  background: #e8f5e8;
  color: #2e7d32;
}

.status-indicator.expired {
  background: #ffebee;
  color: #c62828;
}

.status-indicator.none {
  background: #f5f5f5;
  color: #666;
}

.session-time {
  font-size: 0.75rem;
  color: var(--vp-c-text-2);
  font-weight: 500;
}

/* Admin Sections */
.admin-section {
  margin-bottom: 1rem;
  margin-top: 2rem;
}

.admin-section h2 {
  font-size: 1.5rem;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.section-description {
  color: var(--vp-c-text-2);
  font-size: 14px;
  margin: 0 0 1rem 0;
}

/* Admin Grid */
.admin-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
  margin: 1rem 0 4rem 0; /* Extra bottom margin for footer clearance */
}

.admin-card {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  padding: 1.5rem;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
}

.admin-card.primary {
  border: 2px solid var(--vp-c-brand-1);
  background: linear-gradient(135deg, var(--vp-c-bg-soft) 0%, var(--vp-c-brand-soft) 100%);
}

.admin-card:hover {
  border-color: var(--vp-c-brand-1);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.card-badge {
  position: absolute;
  top: 10px;
  right: 10px;
  background: var(--vp-c-brand);
  color: white;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
}

.card-features {
  margin-top: 12px;
  padding-left: 20px;
  font-size: 13px;
  color: var(--vp-c-text-2);
  list-style: none;
}

.card-features li {
  position: relative;
  margin-bottom: 4px;
}

.card-features li::before {
  content: '→';
  position: absolute;
  left: -15px;
  color: var(--vp-c-brand);
}

.admin-card h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.admin-card p {
  margin: 0.5rem 0 0 0;
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
  line-height: 1.4;
}

.admin-card p:last-child {
  margin-top: 0.75rem;
  font-weight: 500;
  color: var(--vp-c-brand-1);
}

/* Responsive Design */
@media (max-width: 768px) {
  .admin-content {
    padding: 1rem 1rem 10rem 1rem; /* Increased bottom padding on mobile */
  }
  
  .admin-header {
    flex-direction: column;
    gap: 1rem;
  }
  
  .header-info {
    min-width: auto;
    width: 100%;
  }
  
  .admin-grid {
    grid-template-columns: 1fr;
  }
}
</style>