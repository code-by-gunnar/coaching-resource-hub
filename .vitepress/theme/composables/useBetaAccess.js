import { computed } from 'vue'

export function useBetaAccess(user) {
  // Check if user has beta access via raw_user_meta_data
  const hasBetaAccess = computed(() => {
    if (!user.value) return false
    
    // Check for beta_user flag in raw_user_meta_data
    const metaData = user.value.raw_user_meta_data || user.value.user_metadata || {}
    return metaData.beta_user === true
  })

  const betaAccessMessage = {
    title: "Assessment System - In Beta",
    message: `Our assessment system is currently in private beta testing. 
    
If you're interested in early access, please contact us at hello@forwardfocus-coaching.co.uk and we'll be happy to include you in our beta program.

Thank you for your interest!`,
    contactEmail: "hello@forwardfocus-coaching.co.uk"
  }

  return {
    hasBetaAccess,
    betaAccessMessage
  }
}