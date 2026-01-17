<template>
  <div class="auth-container">
    <div class="auth-card">
      <h2>Welcome to Your Coaching Hub</h2>
      <p class="auth-description">Sign in to access your profile and coaching resources</p>

      <div>
        <!-- Social Login Buttons -->
        <div class="social-login">
          <button @click="signInWithGoogle" class="social-btn google-btn" :disabled="loading">
            <svg class="social-icon" viewBox="0 0 24 24" aria-hidden="true">
              <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
              <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
              <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
              <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
            </svg>
            <span>Continue with Google</span>
          </button>

          <!-- Facebook login - uncomment when Facebook OAuth is configured
          <button @click="signInWithFacebook" class="social-btn facebook-btn" :disabled="loading">
            <svg class="social-icon" viewBox="0 0 24 24" aria-hidden="true">
              <path fill="#1877F2" d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
            </svg>
            <span>Continue with Facebook</span>
          </button>
          -->
        </div>

        <div class="divider">
          <span>or</span>
        </div>

        <div class="auth-tabs">
          <button
            @click="authMode = 'signin'"
            :class="{ active: authMode === 'signin' }"
            class="auth-tab"
          >
            Sign In
          </button>
          <button
            @click="authMode = 'signup'"
            :class="{ active: authMode === 'signup' }"
            class="auth-tab"
          >
            Sign Up
          </button>
        </div>

        <!-- Signup Success Message -->
        <div v-if="signupSuccess" class="signup-success">
          <div class="success-icon">
            <CheckCircleIcon class="success-icon-svg" aria-hidden="true" />
          </div>
          <h3>Account Created Successfully!</h3>
          <p>We've sent a confirmation email to:</p>
          <p class="signup-email">{{ signupEmail }}</p>
          <div class="success-instructions">
            <p><strong>Next steps:</strong></p>
            <ol>
              <li>Check your email inbox (and spam folder)</li>
              <li>Click the confirmation link in the email</li>
              <li>Return here and sign in with your credentials</li>
            </ol>
          </div>
          <div class="success-actions">
            <button @click="backToSignIn" class="back-to-signin-btn">
              ← Back to Sign In
            </button>
          </div>
        </div>

        <div v-if="error && !signupSuccess" class="error-message">
          {{ error }}
        </div>

        <form @submit.prevent="handleAuth" class="auth-form" v-if="authMode !== 'reset' && !signupSuccess">
          <div class="form-group">
            <label for="email">Email</label>
            <input 
              id="email"
              v-model="email" 
              type="email" 
              required 
              placeholder="your@email.com"
            />
          </div>

          <div class="form-group">
            <label for="password">Password</label>
            <input 
              id="password"
              v-model="password" 
              type="password" 
              required 
              placeholder="••••••••"
              :minlength="authMode === 'signup' ? 6 : 0"
            />
          </div>

          <button type="submit" class="auth-btn" :disabled="loading">
            {{ loading ? 'Loading...' : (authMode === 'signin' ? 'Sign In' : 'Sign Up') }}
          </button>

          <div v-if="authMode === 'signin'" class="forgot-password">
            <button type="button" @click="authMode = 'reset'" class="forgot-link">
              Forgot your password?
            </button>
          </div>
        </form>

        <form @submit.prevent="handlePasswordReset" class="auth-form" v-if="authMode === 'reset' && !signupSuccess">
          <div class="form-group">
            <label for="reset-email">Email</label>
            <input 
              id="reset-email"
              v-model="email" 
              type="email" 
              required 
              placeholder="your@email.com"
            />
          </div>

          <button type="submit" class="auth-btn" :disabled="loading">
            {{ loading ? 'Sending...' : 'Send Reset Link' }}
          </button>

          <div class="back-to-signin">
            <button type="button" @click="authMode = 'signin'" class="back-link">
              Back to Sign In
            </button>
          </div>
        </form>


        <div v-if="!signupSuccess" class="privacy-notice">
          <p class="privacy-header"><LockClosedIcon class="privacy-icon-svg" aria-hidden="true" /><strong>Your Privacy Matters</strong></p>
          <p>We use your email solely to save your personal progress. No marketing emails, no data sharing - just your private space.</p>
          <p class="privacy-link">
            <a href="/docs/privacy-policy">View Privacy Policy</a>
          </p>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useSupabase } from '../composables/useSupabase.js'
import { CheckCircleIcon, LockClosedIcon } from '@heroicons/vue/24/solid'

// Supabase client
const { supabase } = useSupabase()

console.log('Supabase client initialized:', {
  url: import.meta.env.VITE_SUPABASE_URL,
  hasAnonKey: !!import.meta.env.VITE_SUPABASE_ANON_KEY
})

// Reactive state
const authMode = ref('signin')
const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')
const signupSuccess = ref(false)
const signupEmail = ref('')

// Methods
const handleAuth = async () => {
  loading.value = true
  error.value = ''

  // Basic validation
  if (!email.value || !password.value) {
    error.value = 'Please enter both email and password'
    loading.value = false
    return
  }

  if (password.value.length < 6) {
    error.value = 'Password must be at least 6 characters long'
    loading.value = false
    return
  }

  console.log('Starting authentication:', {
    mode: authMode.value,
    email: email.value,
    hasPassword: !!password.value
  })

  try {
    let result
    if (authMode.value === 'signin') {
      console.log('Attempting sign in...')
      result = await supabase.auth.signInWithPassword({
        email: email.value.trim(),
        password: password.value
      })
    } else {
      console.log('Attempting sign up...')
      result = await supabase.auth.signUp({
        email: email.value.trim(),
        password: password.value,
        options: {
          emailRedirectTo: `${window.location.origin}${getRedirectUrl()}`
        }
      })
      
      // Check if this email is already registered
      // Supabase returns user object even for existing users but with specific indicators
      if (result.data?.user && !result.data?.session && authMode.value === 'signup') {
        // Check if identities array is empty (indicates user already exists)
        if (result.data.user.identities && result.data.user.identities.length === 0) {
          console.log('User already exists - identities array is empty')
          // Don't show success screen
          signupSuccess.value = false
          // Show error
          throw new Error('An account with this email already exists. Please sign in instead.')
        }
      }
    }

    console.log('Auth result:', {
      error: result.error,
      user: result.data?.user,
      emailConfirmed: result.data?.user?.email_confirmed_at
    })

    if (result.error) throw result.error

    if (result.data.user) {
      // Redirect to specified URL if email is confirmed
      if (result.data.user.email_confirmed_at) {
        const redirectUrl = getRedirectUrl()
        console.log('Email confirmed, redirecting to:', redirectUrl)
        window.location.href = redirectUrl
      } else if (authMode.value === 'signup') {
        console.log('Sign up successful, waiting for email confirmation')
        signupSuccess.value = true
        signupEmail.value = email.value
        email.value = ''
        password.value = ''
      } else {
        console.log('Sign in successful but email not confirmed')
        error.value = 'Please check your email and click the confirmation link to activate your account.'
      }
    }
  } catch (err) {
    console.error('Auth error:', err)
    error.value = err.message
  } finally {
    loading.value = false
  }
}

const backToSignIn = () => {
  signupSuccess.value = false
  authMode.value = 'signin'
  signupEmail.value = ''
  error.value = ''
}


const handlePasswordReset = async () => {
  loading.value = true
  error.value = ''

  if (!email.value) {
    error.value = 'Please enter your email address'
    loading.value = false
    return
  }

  console.log('Attempting password reset for:', email.value)

  try {
    const { error: resetError } = await supabase.auth.resetPasswordForEmail(email.value.trim(), {
      redirectTo: `${window.location.origin}/docs/auth/reset-password`
    })

    console.log('Password reset result:', { error: resetError })

    if (resetError) throw resetError

    error.value = 'Password reset link sent! Check your email (including spam folder).'
    email.value = ''
    setTimeout(() => {
      authMode.value = 'signin'
      error.value = ''
    }, 5000)

  } catch (err) {
    console.error('Password reset error:', err)
    error.value = err.message
  } finally {
    loading.value = false
  }
}

// Social login methods
const signInWithGoogle = async () => {
  loading.value = true
  error.value = ''

  try {
    const redirectUrl = getRedirectUrl()
    const { error: oauthError } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}${redirectUrl}`
      }
    })

    if (oauthError) throw oauthError
  } catch (err) {
    console.error('Google sign in error:', err)
    error.value = err.message
    loading.value = false
  }
}

const signInWithFacebook = async () => {
  loading.value = true
  error.value = ''

  try {
    const redirectUrl = getRedirectUrl()
    const { error: oauthError } = await supabase.auth.signInWithOAuth({
      provider: 'facebook',
      options: {
        redirectTo: `${window.location.origin}${redirectUrl}`
      }
    })

    if (oauthError) throw oauthError
  } catch (err) {
    console.error('Facebook sign in error:', err)
    error.value = err.message
    loading.value = false
  }
}



// Get redirect URL from query parameters
const getRedirectUrl = () => {
  const urlParams = new URLSearchParams(window.location.search)
  return urlParams.get('redirect') || '/docs/profile/'
}

// Only listen for auth changes, don't check existing session
onMounted(async () => {
  // Check if we already have a recovery session - if so, don't auto-redirect
  const { data: { session: currentSession } } = await supabase.auth.getSession()
  
  // Check if current session is a recovery session
  const hashParams = new URLSearchParams(window.location.hash.substring(1))
  const isRecoveryInUrl = hashParams.get('type') === 'recovery'
  
  // Listen for auth changes for redirects only
  supabase.auth.onAuthStateChange((event, session) => {
    console.log('Auth state change:', event, session?.user?.aud)
    
    // Don't auto-redirect if this is a recovery/password reset event
    if (event === 'PASSWORD_RECOVERY') {
      console.log('Password recovery event detected, not redirecting')
      return
    }
    
    // Only handle successful sign in/up for redirects (not recovery sessions)
    if (event === 'SIGNED_IN' && session?.user?.email_confirmed_at && !isRecoveryInUrl) {
      // Double-check this isn't a recovery session
      if (session.user.aud === 'authenticated' && !session.user.recovery_sent_at) {
        const redirectUrl = getRedirectUrl()
        window.location.href = redirectUrl
      }
    }
  })
})
</script>

<style scoped>
.auth-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 60vh;
  padding: 2rem;
}

.auth-card {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  padding: 2rem;
  max-width: 400px;
  width: 100%;
  text-align: center;
}

.auth-card h2 {
  margin: 0 0 0.5rem 0;
  color: var(--vp-c-text-1);
}

.auth-description {
  margin: 0 0 1.5rem 0;
  color: var(--vp-c-text-2);
}

.auth-tabs {
  display: flex;
  background: var(--vp-c-bg);
  border-radius: 6px;
  padding: 4px;
  margin-bottom: 1.5rem;
}

.auth-tab {
  flex: 1;
  padding: 8px 16px;
  border: none;
  background: transparent;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s ease;
  color: var(--vp-c-text-2);
}

.auth-tab.active {
  background: #3451b2;
  color: white;
}

.auth-form {
  text-align: left;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  color: var(--vp-c-text-1);
  font-weight: 500;
}

.form-group input {
  width: 100%;
  padding: 12px;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  font-size: 1rem;
}

.form-group input:focus {
  outline: none;
  border-color: #3451b2;
}

.auth-btn, .signout-btn {
  width: 100%;
  padding: 12px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 500;
  transition: all 0.3s ease;
  margin-bottom: 0.5rem;
}

.auth-btn {
  background: #3451b2;
  color: white;
  margin-top: 1rem;
}

.auth-btn:hover:not(:disabled) {
  background: #2940a0;
}





.email-confirmation {
  text-align: center;
  padding: 1.5rem;
  background: var(--vp-c-yellow-soft);
  border: 1px solid var(--vp-c-yellow-light);
  border-radius: 8px;
}

.email-confirmation h3 {
  margin: 0 0 1rem 0;
  color: var(--vp-c-text-1);
}

.email-confirmation p {
  margin: 0 0 1rem 0;
  color: var(--vp-c-text-2);
}

.confirmation-actions {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-top: 1.5rem;
}

.signout-btn {
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  border: 1px solid var(--vp-c-divider);
  margin-bottom: 0;
}

.signout-btn:hover {
  background: var(--vp-c-bg-soft);
}

.auth-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.privacy-notice {
  margin-top: 1.5rem;
  padding: 1rem;
  background: var(--vp-c-bg-alt);
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  text-align: center;
}

.privacy-notice p {
  margin: 0;
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
  line-height: 1.5;
}

.privacy-notice p:first-child {
  margin-bottom: 0.5rem;
  color: var(--vp-c-text-1);
}

.privacy-link {
  margin-top: 0.75rem !important;
  font-size: 0.8rem;
}

.privacy-link a {
  color: #3451b2;
  text-decoration: none;
  font-weight: 500;
}

.privacy-link a:hover {
  text-decoration: underline;
}

.forgot-password, .back-to-signin {
  text-align: center;
  margin-top: 1rem;
}

.forgot-link, .back-link {
  background: none;
  border: none;
  color: #3451b2;
  cursor: pointer;
  font-size: 0.9rem;
  text-decoration: underline;
  padding: 0;
}

.forgot-link:hover, .back-link:hover {
  color: #2940a0;
}

.error-message {
  margin: 1rem 0;
  padding: 12px 16px;
  background: #fee2e2;
  color: #dc2626;
  border: 1px solid #fca5a5;
  border-radius: 6px;
  font-size: 0.9rem;
  font-weight: 500;
  text-align: center;
}

.dark .error-message {
  background: rgba(220, 38, 38, 0.15);
  color: #f87171;
  border-color: rgba(220, 38, 38, 0.3);
}

.signup-success {
  text-align: center;
  padding: 2rem 1rem;
  background: var(--vp-c-green-light);
  border: 2px solid var(--vp-c-green);
  border-radius: 12px;
  margin: 1rem 0;
}

.success-icon {
  margin-bottom: 1rem;
}

.success-icon-svg {
  width: 3rem;
  height: 3rem;
  color: var(--vp-c-green-1);
}

.dark .success-icon-svg {
  color: #4ade80;
}

.privacy-header {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.privacy-icon-svg {
  width: 1.25rem;
  height: 1.25rem;
  color: var(--vp-c-brand-1);
}

.dark .privacy-icon-svg {
  color: #818cf8;
}

.signup-success h3 {
  color: var(--vp-c-green-dark);
  margin: 0 0 1rem 0;
  font-size: 1.3rem;
}

.signup-success p {
  color: var(--vp-c-text-1);
  margin: 0.5rem 0;
  font-size: 0.95rem;
}

.signup-email {
  font-weight: 600;
  color: var(--vp-c-green-dark);
  font-size: 1rem;
  padding: 0.75rem;
  background: var(--vp-c-bg);
  border-radius: 6px;
  border: 1px solid var(--vp-c-green);
  margin: 1rem 0 !important;
}

.success-instructions {
  text-align: left;
  margin: 1.5rem 0;
  padding: 1rem;
  background: var(--vp-c-bg);
  border-radius: 8px;
  border: 1px solid var(--vp-c-divider);
}

.success-instructions p {
  margin: 0 0 0.5rem 0;
  color: var(--vp-c-text-1);
  font-weight: 500;
  font-size: 0.95rem;
}

.success-instructions ol {
  margin: 0.5rem 0 0 0;
  padding-left: 1.5rem;
  color: var(--vp-c-text-2);
  font-size: 0.9rem;
}

.success-instructions li {
  margin: 0.5rem 0;
  line-height: 1.5;
}

.success-actions {
  margin-top: 2rem;
}

.back-to-signin-btn {
  background: var(--vp-c-brand-1);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.95rem;
  font-weight: 500;
  transition: background 0.3s ease;
}

.back-to-signin-btn:hover {
  background: var(--vp-c-brand-dark);
}

/* Social Login Styles */
.social-login {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin-bottom: 1.5rem;
}

.social-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
  width: 100%;
  padding: 12px 16px;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  font-size: 0.95rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.social-btn:hover:not(:disabled) {
  background: var(--vp-c-bg-soft);
  border-color: var(--vp-c-divider-dark);
}

.social-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.social-icon {
  width: 20px;
  height: 20px;
  flex-shrink: 0;
}

.google-btn:hover:not(:disabled) {
  border-color: #4285F4;
}

.facebook-btn:hover:not(:disabled) {
  border-color: #1877F2;
}

/* Divider */
.divider {
  display: flex;
  align-items: center;
  margin: 1.5rem 0;
}

.divider::before,
.divider::after {
  content: '';
  flex: 1;
  height: 1px;
  background: var(--vp-c-divider);
}

.divider span {
  padding: 0 1rem;
  color: var(--vp-c-text-3);
  font-size: 0.85rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
</style>