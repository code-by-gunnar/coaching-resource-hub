import { describe, it, expect, vi, beforeEach } from 'vitest'

// Use vi.hoisted to avoid TDZ issues with mock hoisting
const { mockGetSession } = vi.hoisted(() => ({
  mockGetSession: vi.fn()
}))

// Mock useSupabase before importing useAuth
vi.mock('../../../.vitepress/theme/composables/useSupabase.js', () => ({
  useSupabase: () => ({
    supabase: {
      auth: {
        getSession: mockGetSession
      }
    }
  })
}))

// Mock Vue's onMounted to avoid lifecycle warnings in tests
vi.mock('vue', async () => {
  const actual = await vi.importActual('vue')
  return {
    ...actual,
    onMounted: vi.fn((cb) => cb()) // Execute callback immediately
  }
})

// Import after mocks are set up
import { useAuth } from '../../../.vitepress/theme/composables/useAuth.js'

describe('useAuth', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    // Reset to default behavior
    mockGetSession.mockResolvedValue({ data: { session: null } })
  })

  it('should return user, authInitialized, and checkAuth', () => {
    const { user, authInitialized, checkAuth } = useAuth()

    expect(user).toBeDefined()
    expect(authInitialized).toBeDefined()
    expect(checkAuth).toBeDefined()
    expect(typeof checkAuth).toBe('function')
  })

  it('should set user when session exists with confirmed email', async () => {
    const mockUser = {
      id: '123',
      email: 'test@example.com',
      email_confirmed_at: '2024-01-01T00:00:00Z'
    }

    mockGetSession.mockResolvedValue({
      data: { session: { user: mockUser } }
    })

    const { user, authInitialized, checkAuth } = useAuth()
    await checkAuth()

    expect(user.value).toEqual(mockUser)
    expect(authInitialized.value).toBe(true)
  })

  it('should set user to null when no session exists', async () => {
    mockGetSession.mockResolvedValue({
      data: { session: null }
    })

    const { user, authInitialized, checkAuth } = useAuth()
    await checkAuth()

    expect(user.value).toBe(null)
    expect(authInitialized.value).toBe(true)
  })

  it('should set user to null when email not confirmed', async () => {
    const mockUser = {
      id: '123',
      email: 'test@example.com',
      email_confirmed_at: null
    }

    mockGetSession.mockResolvedValue({
      data: { session: { user: mockUser } }
    })

    const { user, authInitialized, checkAuth } = useAuth()
    await checkAuth()

    expect(user.value).toBe(null)
    expect(authInitialized.value).toBe(true)
  })

  it('should handle auth check errors gracefully', async () => {
    const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {})
    mockGetSession.mockRejectedValue(new Error('Network error'))

    const { user, authInitialized, checkAuth } = useAuth()
    await checkAuth()

    expect(user.value).toBe(null)
    expect(authInitialized.value).toBe(true)
    expect(consoleSpy).toHaveBeenCalled()

    consoleSpy.mockRestore()
  })
})
