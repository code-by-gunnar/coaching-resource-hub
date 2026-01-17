/**
 * Sentry Error Tracking Composable
 * Initializes Sentry for Vue applications
 * Only activates when VITE_SENTRY_DSN is configured
 */

// Get Sentry DSN from environment variable
const SENTRY_DSN = import.meta.env.VITE_SENTRY_DSN || ''

// Check if Sentry is properly configured
const isSentryConfigured = SENTRY_DSN && SENTRY_DSN.startsWith('https://')

/**
 * Initialize Sentry error tracking
 * @param {Object} app - Vue app instance
 * @param {Object} router - Vue router instance (optional)
 */
export async function initSentry(app, router = null) {
  if (!isSentryConfigured) {
    console.log('Sentry: Not configured (VITE_SENTRY_DSN not set)')
    return
  }

  // Only initialize in browser environment
  if (typeof window === 'undefined') {
    return
  }

  try {
    // @vite-ignore tells Vite to skip static analysis - package is optional
    const Sentry = await import(/* @vite-ignore */ '@sentry/vue')

    Sentry.init({
      app,
      dsn: SENTRY_DSN,
      environment: import.meta.env.MODE || 'development',

      // Performance monitoring
      tracesSampleRate: import.meta.env.PROD ? 0.1 : 1.0,

      // Session replay for debugging
      replaysSessionSampleRate: 0.1,
      replaysOnErrorSampleRate: 1.0,

      // Integration options
      integrations: [
        Sentry.browserTracingIntegration({
          router
        }),
        Sentry.replayIntegration({
          maskAllText: false,
          blockAllMedia: false
        })
      ],

      // Filter out common non-actionable errors
      beforeSend(event, hint) {
        const error = hint.originalException

        // Filter out browser extension errors
        if (error?.message?.includes('Extension context invalidated')) {
          return null
        }
        if (error?.message?.includes('message port closed')) {
          return null
        }

        // Filter out network errors that aren't actionable
        if (error?.message?.includes('Failed to fetch')) {
          // Still send, but tag as network error
          event.tags = { ...event.tags, category: 'network' }
        }

        return event
      }
    })

    console.log('Sentry: Initialized successfully')
  } catch (err) {
    console.error('Sentry: Failed to initialize', err)
  }
}

/**
 * Capture a custom error with Sentry
 * @param {Error} error - Error to capture
 * @param {Object} context - Additional context
 */
export async function captureError(error, context = {}) {
  if (!isSentryConfigured || typeof window === 'undefined') {
    console.error('Error:', error, context)
    return
  }

  try {
    const Sentry = await import(/* @vite-ignore */ '@sentry/vue')
    Sentry.captureException(error, { extra: context })
  } catch (err) {
    console.error('Failed to capture error with Sentry:', err)
  }
}

/**
 * Set user context for Sentry
 * @param {Object} user - User object with id, email, etc.
 */
export async function setUser(user) {
  if (!isSentryConfigured || typeof window === 'undefined') {
    return
  }

  try {
    const Sentry = await import(/* @vite-ignore */ '@sentry/vue')
    if (user) {
      Sentry.setUser({
        id: user.id,
        email: user.email
      })
    } else {
      Sentry.setUser(null)
    }
  } catch (err) {
    console.error('Failed to set Sentry user:', err)
  }
}

export { isSentryConfigured }
