// Analytics tracking composable
export function useAnalytics() {
  
  // Generic event tracking
  const trackEvent = (eventName, parameters = {}) => {
    if (typeof window !== 'undefined' && window.gtag) {
      window.gtag('event', eventName, parameters)
    }
  }

  // File download tracking
  const trackDownload = (fileName) => {
    trackEvent('file_download', {
      file_name: fileName,
      event_category: 'downloads'
    })
  }

  // Assessment tracking
  const trackAssessmentStart = (assessmentType) => {
    trackEvent('assessment_start', {
      assessment_type: assessmentType,
      event_category: 'assessments'
    })
  }

  const trackAssessmentComplete = (assessmentType, score) => {
    trackEvent('assessment_complete', {
      assessment_type: assessmentType,
      score: score,
      event_category: 'assessments'
    })
  }

  // Business action tracking
  const trackBusinessAction = (action, details = {}) => {
    trackEvent('business_action', {
      action: action,
      event_category: 'business',
      ...details
    })
  }

  // Content engagement tracking
  const trackContentEngagement = (contentType, action, details = {}) => {
    trackEvent('content_engagement', {
      content_type: contentType,
      action: action,
      event_category: 'engagement',
      ...details
    })
  }

  return {
    trackEvent,
    trackDownload,
    trackAssessmentStart,
    trackAssessmentComplete,
    trackBusinessAction,
    trackContentEngagement
  }
}