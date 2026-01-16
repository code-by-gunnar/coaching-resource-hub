<template>
  <div class="profile-container">
    <div class="profile-content">
      <div class="profile-header">
        <div class="avatar-section">
          <div class="avatar">
            {{ user?.email?.charAt(0)?.toUpperCase() || 'U' }}
          </div>
          <div class="user-info">
            <h1>Welcome back!</h1>
            <p class="user-email">{{ user?.email || 'Loading...' }}</p>
          </div>
        </div>
        <div class="header-actions">
          <ActionButton 
            @click="toggleSettings" 
            :variant="currentView === 'settings' ? 'primary' : 'gray'" 
            icon="⚙️"
            class="settings-action-btn"
            title="Account Settings"
          />
          <button @click="signOut" class="signout-btn">Sign Out</button>
        </div>
      </div>

      <!-- Dashboard View -->
      <ProfileDashboard 
        v-if="currentView === 'dashboard'"
        :total-hours="totalHours"
        :study-sessions="studyLogs.length"
        :learning-logs="learningLogs.length"
        :assessment-stats="assessmentStats"
        @navigate="handleNavigation"
      />

      <!-- Study Logs View -->
      <StudyLogs 
        v-else-if="currentView === 'logs'"
        @navigate="handleNavigation"
      />

      <!-- Learning Logs View -->
      <LearningLogs 
        v-else-if="currentView === 'learningLogs'"
        @navigate="handleNavigation"
      />

      <!-- Settings View -->
      <ProfileSettings 
        v-else-if="currentView === 'settings'"
        @navigate="handleNavigation"
        @accountDeleted="handleAccountDeleted"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, provide } from 'vue'
import { useSupabase } from '../composables/useSupabase.js'
import ProfileDashboard from './profile/ProfileDashboard.vue'
import StudyLogs from './profile/StudyLogs.vue'
import LearningLogs from './profile/LearningLogs.vue'
import ProfileSettings from './profile/ProfileSettings.vue'

// Supabase client
const { supabase } = useSupabase()

// Reactive state  
const user = ref(null)
const currentView = ref('dashboard')
const studyLogs = ref([])
const learningLogs = ref([])
const userAssessmentAttempts = ref([])

const totalHours = computed(() => {
  return studyLogs.value.reduce((sum, log) => sum + (log.hours || 0), 0)
})

// Assessment stats computed from loaded data
const assessmentStats = computed(() => {
  const completedAttempts = userAssessmentAttempts.value.filter(attempt => attempt.status === 'completed')
  const inProgressAttempts = userAssessmentAttempts.value.filter(attempt => attempt.status === 'in_progress')
  const totalCompleted = completedAttempts.length
  const totalInProgress = inProgressAttempts.length
  const averageScore = totalCompleted > 0 
    ? Math.round(completedAttempts.reduce((sum, attempt) => sum + (attempt.score || 0), 0) / totalCompleted)
    : 0
  
  return { 
    completed: totalCompleted,
    inProgress: totalInProgress,
    averageScore 
  }
})

// Function to refresh all profile data
const refreshData = async () => {
  if (!user.value?.id) return
  
  console.log('🔄 Refreshing profile data...')
  await Promise.all([
    loadStudyLogs(),
    loadLearningLogs(), 
    loadAssessmentAttempts()
  ])
  console.log('✅ Profile data refreshed')
}

// Provide user and refresh function to child components
provide('user', user)
provide('refreshData', refreshData)

// Navigation handler with data refresh
const handleNavigation = async (view) => {
  currentView.value = view
  
  // Refresh data when navigating back to dashboard
  if (view === 'dashboard') {
    await refreshData()
  }
}

const toggleSettings = () => {
  if (currentView.value === 'settings') {
    currentView.value = 'dashboard'
  } else {
    currentView.value = 'settings'
  }
}

// Account deletion handler
const handleAccountDeleted = () => {
  window.location.href = '/'
}

// Sign out handler
const signOut = async () => {
  try {
    // Clear localStorage immediately to prevent flash
    const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
    const projectRef = supabaseUrl.split('//')[1].split('.')[0]
    localStorage.removeItem('sb-' + projectRef + '-auth-token')
    
    await supabase.auth.signOut()
    window.location.href = '/'
  } catch (err) {
    console.error('Sign out error:', err)
    // Still redirect even if sign out fails
    window.location.href = '/'
  }
}

// Data loading functions
const loadStudyLogs = async () => {
  try {
    console.log('Loading study logs for user:', user.value.id)
    
    const { data, error } = await supabase
      .from('self_study')
      .select('*')
      .eq('user_id', user.value.id)
      .order('date', { ascending: false })
    
    if (error) {
      console.error('Study logs query error:', error)
      throw error
    }
    
    console.log('User study logs loaded:', data)
    studyLogs.value = data || []
  } catch (error) {
    console.error('Error loading study logs:', error)
  }
}

const loadLearningLogs = async () => {
  try {
    console.log('Loading learning logs for user:', user.value.id)
    
    const { data, error } = await supabase
      .from('learning_logs')
      .select('*')
      .eq('user_id', user.value.id)
      .order('date', { ascending: false })
    
    if (error) {
      console.error('Learning logs query error:', error)
      throw error
    }
    
    console.log('User learning logs loaded:', data)
    learningLogs.value = data || []
  } catch (error) {
    console.error('Error loading learning logs:', error)
  }
}

const loadAssessmentAttempts = async () => {
  try {
    console.log('Loading assessment attempts for user:', user.value.id)
    
    const { data, error } = await supabase
      .from('user_assessment_attempts')
      .select('id, status, score, completed_at')
      .eq('user_id', user.value.id)
      .order('completed_at', { ascending: false })
    
    if (error) {
      console.error('Assessment attempts query error:', error)
      throw error
    }
    
    console.log('User assessment attempts loaded:', data)
    userAssessmentAttempts.value = data || []
  } catch (error) {
    console.error('Error loading assessment attempts:', error)
  }
}


// Check auth and redirect if needed
onMounted(async () => {
  try {
    // Check for recovery token in URL first
    const hashParams = new URLSearchParams(window.location.hash.substring(1))
    const type = hashParams.get('type')
    const accessToken = hashParams.get('access_token')
    
    if (type === 'recovery' && accessToken) {
      console.log('Recovery token detected, redirecting to reset password page')
      // Preserve the full hash for the reset password page
      window.location.href = '/docs/auth/reset-password' + window.location.hash
      return
    }
    
    const { data: { session } } = await supabase.auth.getSession()
    console.log('Session data:', session)
    
    // Check if this is a recovery session (user came here with recovery token)
    // Recovery sessions should not grant profile access
    const isRecoverySession = session?.user?.aud === 'authenticated' && 
                             (session?.user?.recovery_sent_at || 
                              session?.access_token?.includes('recovery'))
    
    if (isRecoverySession) {
      console.log('Recovery session detected in profile, redirecting to reset password')
      window.location.href = '/docs/auth/reset-password'
      return
    }
    
    if (session && session.user && session.user.email_confirmed_at) {
      user.value = session.user
      console.log('User authenticated:', user.value)
      
      // Load user data
      console.log('Starting to load user data...')
      await Promise.all([
        loadStudyLogs(),
        loadLearningLogs(),
        loadAssessmentAttempts()
      ])
      console.log('Data loading completed')
    } else {
      console.log('No valid session, redirecting to auth')
      // Redirect to auth if not logged in
      window.location.href = '/docs/auth/'
    }
  } catch (err) {
    console.error('Session check error:', err)
    window.location.href = '/docs/auth/'
  }
})
</script>

<style scoped>
.profile-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.profile-content {
  animation: fadeIn 0.5s ease-in;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.profile-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  padding: 2rem;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
}

.avatar-section {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.avatar {
  width: 60px;
  height: 60px;
  background: var(--vp-c-brand-1);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  font-weight: bold;
}

.user-info h1 {
  margin: 0 0 0.5rem 0;
  color: var(--vp-c-text-1);
  font-size: 1.5rem;
}

.user-email {
  margin: 0;
  color: var(--vp-c-text-2);
  font-size: 0.9rem;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

/* Custom styling for settings ActionButton in header */
.header-actions .settings-action-btn {
  min-width: 40px;
  width: 40px;
  height: 40px;
  padding: 8px;
  font-size: 1.1rem;
}

.signout-btn {
  padding: 8px 16px;
  background: #ef4444;
  color: white;
  border: 1px solid #ef4444;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 500;
  transition: all 0.3s ease;
}

.signout-btn:hover {
  background: #dc2626;
  border-color: #dc2626;
}

@media (max-width: 768px) {
  .profile-container {
    padding: 1rem;
  }
  
  .profile-header {
    flex-direction: column;
    gap: 1rem;
    text-align: center;
  }
  
  .avatar-section {
    flex-direction: column;
    gap: 0.5rem;
  }
}
</style>