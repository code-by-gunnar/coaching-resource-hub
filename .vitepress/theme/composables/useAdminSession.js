import { ref, computed, watch } from 'vue'
import { useAuth } from './useAuth'

// Session configuration
const ADMIN_SESSION_KEY = 'coach-admin-session'
const SESSION_DURATION = 2 * 60 * 60 * 1000 // 2 hours in milliseconds
const CHECK_INTERVAL = 5 * 60 * 1000 // Check every 5 minutes

// Global state
const adminSessionCache = ref(null)
const sessionCheckInterval = ref(null)
const lastActivityTime = ref(Date.now())

// Admin session structure
const createSessionData = (user, isAdmin) => ({
  userId: user.id,
  email: user.email,
  isAdmin,
  createdAt: Date.now(),
  lastActivity: Date.now(),
  expiresAt: Date.now() + SESSION_DURATION
})

// Local storage helpers
const saveSession = (sessionData) => {
  if (typeof window === 'undefined') return
  try {
    localStorage.setItem(ADMIN_SESSION_KEY, JSON.stringify(sessionData))
    adminSessionCache.value = sessionData
  } catch (error) {
    console.warn('Failed to save admin session:', error)
  }
}

const loadSession = () => {
  if (typeof window === 'undefined') return null
  try {
    const stored = localStorage.getItem(ADMIN_SESSION_KEY)
    if (stored) {
      const sessionData = JSON.parse(stored)
      
      // Check if session is expired
      if (Date.now() > sessionData.expiresAt) {
        clearSession()
        return null
      }
      
      adminSessionCache.value = sessionData
      return sessionData
    }
  } catch (error) {
    console.warn('Failed to load admin session:', error)
    clearSession()
  }
  return null
}

const clearSession = () => {
  if (typeof window === 'undefined') return
  try {
    localStorage.removeItem(ADMIN_SESSION_KEY)
    adminSessionCache.value = null
  } catch (error) {
    console.warn('Failed to clear admin session:', error)
  }
}

const updateActivity = () => {
  const session = adminSessionCache.value
  if (session) {
    session.lastActivity = Date.now()
    lastActivityTime.value = Date.now()
    saveSession(session)
  }
}

// Check if user has admin privileges
const checkAdminAccess = (user) => {
  if (!user) return false
  
  // Debug user object structure
  console.log('Admin access check for user:', {
    email: user.email,
    raw_user_meta_data: user.raw_user_meta_data,
    user_metadata: user.user_metadata
  })
  
  const metaData = user.raw_user_meta_data || user.user_metadata || {}
  const isDeveloper = user.email === 'gunnar.finkeldeh@gmail.com'
  const isTestAdmin = user.email === 'test@coaching-hub.local'
  const hasAdminFlag = metaData.admin === true
  
  // Check both possible locations for admin flag
  const hasAdminInRawMeta = user.raw_user_meta_data?.admin === true
  const hasAdminInUserMeta = user.user_metadata?.admin === true
  
  console.log('Admin access check results:', {
    isDeveloper,
    isTestAdmin,
    hasAdminFlag,
    hasAdminInRawMeta,
    hasAdminInUserMeta,
    finalResult: isDeveloper || isTestAdmin || hasAdminFlag || hasAdminInRawMeta || hasAdminInUserMeta
  })
  
  return isDeveloper || isTestAdmin || hasAdminFlag || hasAdminInRawMeta || hasAdminInUserMeta
}

// Session cleanup
const cleanupSession = () => {
  if (sessionCheckInterval.value) {
    clearInterval(sessionCheckInterval.value)
    sessionCheckInterval.value = null
  }
}

export function useAdminSession() {
  const { user, signOut } = useAuth()
  
  // Load existing session on initialization (client-side only)
  if (!adminSessionCache.value && typeof window !== 'undefined') {
    loadSession()
  }
  
  // Computed admin access state
  const hasAdminAccess = computed(() => {
    const session = adminSessionCache.value
    
    // If no session, try to load from localStorage (client-side only)
    if (!session && typeof window !== 'undefined') {
      loadSession()
    }
    
    const currentSession = adminSessionCache.value
    const now = Date.now()
    const isExpired = !currentSession || now > currentSession.expiresAt
    
    if (isExpired) {
      return false
    }
    
    // Verify current user matches session
    if (user.value && user.value.id === currentSession.userId) {
      return currentSession.isAdmin
    }
    
    // If we have a session but no user yet, still return admin status
    // This handles the timing issue during page load
    if (!user.value && currentSession.isAdmin) {
      return true
    }
    
    return false
  })
  
  // Session status
  const sessionStatus = computed(() => {
    const session = adminSessionCache.value
    if (!session) return 'none'
    if (Date.now() > session.expiresAt) return 'expired'
    return 'active'
  })
  
  // Time until session expires
  const timeUntilExpiry = computed(() => {
    const session = adminSessionCache.value
    if (!session) return 0
    return Math.max(0, session.expiresAt - Date.now())
  })
  
  // Create or refresh admin session
  const createSession = async (forceRefresh = false) => {
    if (!user.value) {
      clearSession()
      return false
    }
    
    // Check if we have a valid cached session
    const existingSession = adminSessionCache.value
    if (!forceRefresh && existingSession && 
        existingSession.userId === user.value.id && 
        Date.now() < existingSession.expiresAt) {
      updateActivity()
      return existingSession.isAdmin
    }
    
    // Verify admin access
    const isAdmin = checkAdminAccess(user.value)
    
    if (isAdmin) {
      const sessionData = createSessionData(user.value, true)
      saveSession(sessionData)
      console.log('Admin session created:', {
        email: user.value.email,
        expiresIn: Math.round(SESSION_DURATION / 1000 / 60) + ' minutes'
      })
      return true
    } else {
      clearSession()
      return false
    }
  }
  
  // Extend session if activity detected
  const extendSession = () => {
    const session = adminSessionCache.value
    if (session && Date.now() < session.expiresAt) {
      // Extend session if more than half the duration has passed
      const halfDuration = SESSION_DURATION / 2
      if (Date.now() - session.createdAt > halfDuration) {
        session.expiresAt = Date.now() + SESSION_DURATION
        session.createdAt = Date.now()
        saveSession(session)
        console.log('Admin session extended')
      } else {
        updateActivity()
      }
    }
  }
  
  // Handle session expiry
  const handleSessionExpiry = async () => {
    console.warn('Admin session expired - signing out')
    clearSession()
    
    // Sign out user if they're still logged in
    if (user.value) {
      await signOut()
    }
    
    // Redirect to admin login
    if (typeof window !== 'undefined') {
      window.location.href = '/docs/admin/'
    }
  }
  
  // Start session monitoring
  const startSessionMonitoring = () => {
    if (sessionCheckInterval.value) {
      clearInterval(sessionCheckInterval.value)
    }
    
    sessionCheckInterval.value = setInterval(() => {
      const session = adminSessionCache.value
      if (session) {
        if (Date.now() > session.expiresAt) {
          handleSessionExpiry()
        } else {
          // Check for inactivity (30 minutes)
          const inactivityLimit = 30 * 60 * 1000
          if (Date.now() - session.lastActivity > inactivityLimit) {
            console.warn('Admin session inactive - extending session')
            extendSession()
          }
        }
      }
    }, CHECK_INTERVAL)
  }
  
  // Watch user changes
  watch(user, async (newUser, oldUser) => {
    if (newUser) {
      // Only create new session if user changed or no existing session
      const existingSession = adminSessionCache.value
      if (!existingSession || !oldUser || newUser.id !== oldUser.id) {
        const hasAccess = await createSession()
        if (hasAccess) {
          startSessionMonitoring()
        }
      } else {
        // User is the same, just refresh activity
        updateActivity()
      }
    } else {
      clearSession()
      cleanupSession()
    }
  }, { immediate: true })
  
  // Activity tracking
  const trackActivity = () => {
    updateActivity()
    extendSession()
  }
  
  // Cleanup on page unload
  if (typeof window !== 'undefined') {
    window.addEventListener('beforeunload', cleanupSession)
    
    // Track user activity
    const activityEvents = ['click', 'keydown', 'scroll', 'mousemove']
    let activityTimeout = null
    
    const debouncedActivity = () => {
      if (activityTimeout) clearTimeout(activityTimeout)
      activityTimeout = setTimeout(trackActivity, 1000) // Debounce activity tracking
    }
    
    activityEvents.forEach(event => {
      window.addEventListener(event, debouncedActivity, { passive: true })
    })
  }
  
  return {
    // State
    hasAdminAccess,
    sessionStatus,
    timeUntilExpiry,
    lastActivityTime: computed(() => lastActivityTime.value),
    
    // Methods
    createSession,
    extendSession,
    clearSession,
    trackActivity,
    
    // Utils
    formatTimeRemaining: computed(() => {
      const ms = timeUntilExpiry.value
      if (ms <= 0) return 'Expired'
      
      const minutes = Math.floor(ms / 60000)
      const hours = Math.floor(minutes / 60)
      
      if (hours > 0) {
        return `${hours}h ${minutes % 60}m`
      } else {
        return `${minutes}m`
      }
    })
  }
}