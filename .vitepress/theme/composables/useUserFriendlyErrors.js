/**
 * User-Friendly Error Messages System
 * Converts technical database errors into helpful user messages
 */

// Error message mappings - technical errors to user-friendly messages
const errorMappings = {
  // Database connection and caching issues
  'DB_CACHE_NOT_LOADED': {
    title: 'Connection Issue',
    message: "We're unable to connect to our servers right now. Please check your internet connection and refresh the page. If the problem continues, please contact support.",
    action: 'Refresh Page',
    severity: 'error'
  },
  
  'DATABASE_CACHE_LOADING_FAILED': {
    title: 'Loading Error',
    message: "We're having trouble loading your assessment data. Please refresh the page or try again in a few minutes. If this persists, please contact support.",
    action: 'Refresh & Retry',
    severity: 'error'
  },

  // Missing insights and actions
  'NO_INSIGHT_FOR_TAG': {
    title: 'Partial Results',
    message: "Some of your personalized feedback isn't available right now. Your scores are still accurate, but detailed insights may be temporarily unavailable.",
    action: 'Try Again Later',
    severity: 'warning'
  },

  'NO_ACTION_FOR_TAG': {
    title: 'Recommendations Unavailable', 
    message: "We couldn't load all your practice recommendations right now. Your assessment results are complete, but some action steps may be missing.",
    action: 'Contact Support',
    severity: 'warning'
  },

  // Learning resources issues
  'NO_LEARNING_RESOURCES_LOADED': {
    title: 'Learning Resources Unavailable',
    message: "We're having trouble loading your personalized learning recommendations. Your assessment results are still valid, but learning resources aren't available right now.",
    action: 'Refresh or Contact Support',
    severity: 'warning'
  },

  'COMPETENCY_MAPPING_ISSUE': {
    title: 'Recommendations Loading Error',
    message: "Your learning recommendations are temporarily unavailable due to a system issue. Your assessment scores are accurate and saved.",
    action: 'Contact Support',
    severity: 'warning'
  },

  // Assessment submission issues
  'ASSESSMENT_SUBMISSION_FAILED': {
    title: 'Submission Error',
    message: "We couldn't save your assessment right now. Please check your internet connection and try submitting again. Don't worry - your answers are saved locally.",
    action: 'Check Connection & Retry',
    severity: 'error'
  },

  'AUTHENTICATION_ERROR': {
    title: 'Sign-In Required',
    message: "You need to be signed in to save your assessment results. Please sign in and your progress will be restored.",
    action: 'Sign In',
    severity: 'warning'
  }
}

/**
 * Convert technical error to user-friendly message
 * @param {string} errorType - Technical error identifier
 * @param {string} context - Additional context (e.g., tag name, competency)
 * @returns {object} User-friendly error object
 */
export function getUserFriendlyError(errorType, context = '') {
  // Try exact match first
  if (errorMappings[errorType]) {
    return {
      ...errorMappings[errorType],
      context,
      isUserFriendly: true
    }
  }

  // Pattern matching for dynamic errors
  if (errorType.includes('NO_INSIGHT') || errorType.includes('DB ERROR: No insight')) {
    return {
      ...errorMappings['NO_INSIGHT_FOR_TAG'],
      context,
      isUserFriendly: true
    }
  }

  if (errorType.includes('NO_ACTION') || errorType.includes('DB ERROR: No action')) {
    return {
      ...errorMappings['NO_ACTION_FOR_TAG'], 
      context,
      isUserFriendly: true
    }
  }

  if (errorType.includes('DATABASE ERROR') || errorType.includes('DB ERROR')) {
    return {
      ...errorMappings['DATABASE_CACHE_LOADING_FAILED'],
      context,
      isUserFriendly: true
    }
  }

  // Fallback for unknown errors
  return {
    title: 'Something Went Wrong',
    message: "We encountered an unexpected issue. Please refresh the page or contact support if this continues.",
    action: 'Refresh or Contact Support',
    severity: 'error',
    context,
    isUserFriendly: true
  }
}

/**
 * Check if a message is already user-friendly
 * @param {string} message - Message to check
 * @returns {boolean}
 */
export function isAlreadyUserFriendly(message) {
  // If it doesn't contain technical indicators, it's probably already friendly
  const technicalIndicators = [
    '🚨 DB ERROR',
    '🚨 DB CACHE',
    'DATABASE ERROR',
    'MISMATCH:',
    'function',
    'null',
    'undefined',
    'Error:',
    'at line'
  ]
  
  return !technicalIndicators.some(indicator => 
    message.includes(indicator)
  )
}

/**
 * Format error for display in UI components
 * @param {object} error - User-friendly error object
 * @returns {object} Formatted for UI components
 */
export function formatErrorForUI(error) {
  if (!error.isUserFriendly) {
    return error // Return as-is if not processed
  }

  return {
    icon: error.severity === 'error' ? '⚠️' : '💡',
    title: error.title,
    description: error.message,
    resources: [
      `Action: ${error.action}`,
      error.context ? `Context: ${error.context}` : null,
      'If this problem persists, please contact support'
    ].filter(Boolean)
  }
}

// Export the error composable
export function useUserFriendlyErrors() {
  return {
    getUserFriendlyError,
    isAlreadyUserFriendly,
    formatErrorForUI
  }
}