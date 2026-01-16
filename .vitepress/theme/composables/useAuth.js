import { ref, onMounted } from 'vue'
import { useSupabase } from './useSupabase.js'

const user = ref(null)
const { supabase } = useSupabase()

export function useAuth() {
  const checkAuth = async () => {
    try {
      const { data: { session } } = await supabase.auth.getSession()
      
      if (session && session.user && session.user.email_confirmed_at) {
        user.value = session.user
        console.log('User authenticated:', user.value)
      } else {
        user.value = null
      }
    } catch (err) {
      console.error('Auth check error:', err)
      user.value = null
    }
  }

  // Auto-check auth on mount if not already done
  onMounted(() => {
    if (user.value === null) {
      checkAuth()
    }
  })

  return {
    user,
    checkAuth
  }
}