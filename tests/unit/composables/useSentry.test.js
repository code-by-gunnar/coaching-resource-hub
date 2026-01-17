import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'

// Test the functions' behavior rather than module-level constants
// since isSentryConfigured is evaluated at module load time

describe('useSentry', () => {
  let originalWindow

  beforeEach(() => {
    vi.resetModules()
    originalWindow = global.window
    // Define window for browser environment tests
    global.window = {}
  })

  afterEach(() => {
    global.window = originalWindow
    vi.unstubAllEnvs()
  })

  describe('initSentry', () => {
    it('should return early and log when DSN is not configured', async () => {
      vi.stubEnv('VITE_SENTRY_DSN', '')
      const consoleSpy = vi.spyOn(console, 'log').mockImplementation(() => {})

      const { initSentry } = await import(
        '../../../.vitepress/theme/composables/useSentry.js'
      )

      const mockApp = {}
      await initSentry(mockApp)

      expect(consoleSpy).toHaveBeenCalledWith(
        'Sentry: Not configured (VITE_SENTRY_DSN not set)'
      )

      consoleSpy.mockRestore()
    })

    it('should return early in non-browser environment', async () => {
      vi.stubEnv('VITE_SENTRY_DSN', 'https://abc123@sentry.io/123')
      global.window = undefined

      const { initSentry } = await import(
        '../../../.vitepress/theme/composables/useSentry.js'
      )

      const mockApp = {}
      // Should not throw, just return early
      const result = await initSentry(mockApp)
      expect(result).toBeUndefined()
    })
  })

  describe('captureError', () => {
    it('should log error to console when Sentry is not configured', async () => {
      vi.stubEnv('VITE_SENTRY_DSN', '')
      const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {})

      const { captureError } = await import(
        '../../../.vitepress/theme/composables/useSentry.js'
      )

      const testError = new Error('Test error')
      await captureError(testError, { context: 'test' })

      expect(consoleSpy).toHaveBeenCalledWith('Error:', testError, {
        context: 'test'
      })

      consoleSpy.mockRestore()
    })

    it('should handle errors without context', async () => {
      vi.stubEnv('VITE_SENTRY_DSN', '')
      const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {})

      const { captureError } = await import(
        '../../../.vitepress/theme/composables/useSentry.js'
      )

      const testError = new Error('Test error')
      await captureError(testError)

      expect(consoleSpy).toHaveBeenCalledWith('Error:', testError, {})

      consoleSpy.mockRestore()
    })
  })

  describe('setUser', () => {
    it('should return early when Sentry is not configured', async () => {
      vi.stubEnv('VITE_SENTRY_DSN', '')

      const { setUser } = await import(
        '../../../.vitepress/theme/composables/useSentry.js'
      )

      // Should not throw, just return early
      const result = await setUser({ id: '123', email: 'test@example.com' })
      expect(result).toBeUndefined()
    })

    it('should return early in non-browser environment', async () => {
      vi.stubEnv('VITE_SENTRY_DSN', 'https://abc123@sentry.io/123')
      global.window = undefined

      const { setUser } = await import(
        '../../../.vitepress/theme/composables/useSentry.js'
      )

      // Should not throw
      const result = await setUser({ id: '123', email: 'test@example.com' })
      expect(result).toBeUndefined()
    })
  })

  describe('isSentryConfigured export', () => {
    it('should be falsy when DSN is empty', async () => {
      vi.stubEnv('VITE_SENTRY_DSN', '')

      const { isSentryConfigured } = await import(
        '../../../.vitepress/theme/composables/useSentry.js'
      )

      expect(isSentryConfigured).toBeFalsy()
    })

    it('should be falsy when DSN is invalid', async () => {
      vi.stubEnv('VITE_SENTRY_DSN', 'not-a-valid-url')

      const { isSentryConfigured } = await import(
        '../../../.vitepress/theme/composables/useSentry.js'
      )

      expect(isSentryConfigured).toBeFalsy()
    })

    it('should be true when DSN is a valid https URL', async () => {
      vi.stubEnv('VITE_SENTRY_DSN', 'https://abc123@sentry.io/123')

      const { isSentryConfigured } = await import(
        '../../../.vitepress/theme/composables/useSentry.js'
      )

      expect(isSentryConfigured).toBe(true)
    })
  })
})
