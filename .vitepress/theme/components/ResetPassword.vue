<template>
  <div class="reset-password-container">
    <div class="reset-card">
      <div v-if="!isValidToken && !passwordUpdated" class="error-container">
        <div class="error-icon-wrapper">
          <svg class="error-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none">
            <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/>
            <path d="M12 7v6m0 4h.01" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          </svg>
        </div>
        <h2 class="error-title">Invalid or Expired Link</h2>
        <p class="error-description">
          This password reset link is invalid or has expired. Password reset links are only valid for 1 hour for security reasons.
        </p>
        <p class="error-instruction">Please request a new password reset link from the sign-in page.</p>
        <a href="/docs/auth/" class="error-btn">
          <span class="btn-icon">←</span>
          Back to Sign In
        </a>
      </div>

      <div v-else-if="passwordUpdated" class="success-container">
        <div class="success-icon-wrapper">
          <svg class="success-checkmark" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 52">
            <circle class="success-checkmark-circle" cx="26" cy="26" r="25" fill="none"/>
            <path class="success-checkmark-check" fill="none" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>
          </svg>
        </div>
        <h2 class="success-title">Password Updated Successfully!</h2>
        <p class="success-message">Your password has been changed. You can now sign in with your new password.</p>
        <a href="/docs/auth/" class="success-btn">
          <span class="btn-icon">→</span>
          Go to Sign In
        </a>
      </div>

      <div v-else>
        <h2>Set Your New Password</h2>
        <p class="reset-description">Enter your new password below</p>

        <form @submit.prevent="handlePasswordUpdate" class="reset-form">
          <div class="form-group">
            <label for="new-password">New Password</label>
            <input 
              id="new-password"
              v-model="newPassword" 
              type="password" 
              required 
              placeholder="Enter new password"
              minlength="6"
              @input="validatePasswords"
            />
            <small class="field-hint">Minimum 6 characters</small>
          </div>

          <div class="form-group">
            <label for="confirm-password">Confirm Password</label>
            <input 
              id="confirm-password"
              v-model="confirmPassword" 
              type="password" 
              required 
              placeholder="Confirm new password"
              @input="validatePasswords"
            />
          </div>

          <div v-if="validationError" class="validation-error">
            {{ validationError }}
          </div>

          <button 
            type="submit" 
            class="update-password-btn" 
            :disabled="loading || !!validationError"
          >
            {{ loading ? 'Updating...' : 'Update Password' }}
          </button>
        </form>

        <div v-if="error" class="error-message">
          {{ error }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useSupabase } from '../composables/useSupabase.js'

// Supabase client
const { supabase } = useSupabase()

// Reactive state
const newPassword = ref('')
const confirmPassword = ref('')
const loading = ref(false)
const error = ref('')
const validationError = ref('')
const passwordUpdated = ref(false)
const isValidToken = ref(false)

// Validate passwords match
const validatePasswords = () => {
  if (newPassword.value && confirmPassword.value) {
    if (newPassword.value !== confirmPassword.value) {
      validationError.value = 'Passwords do not match'
    } else if (newPassword.value.length < 6) {
      validationError.value = 'Password must be at least 6 characters'
    } else {
      validationError.value = ''
    }
  } else {
    validationError.value = ''
  }
}

// Handle password update
const handlePasswordUpdate = async () => {
  loading.value = true
  error.value = ''

  // Final validation
  if (newPassword.value !== confirmPassword.value) {
    error.value = 'Passwords do not match'
    loading.value = false
    return
  }

  if (newPassword.value.length < 6) {
    error.value = 'Password must be at least 6 characters'
    loading.value = false
    return
  }

  try {
    console.log('Updating password...')
    
    const { error: updateError } = await supabase.auth.updateUser({
      password: newPassword.value
    })

    if (updateError) throw updateError

    console.log('Password updated successfully')
    passwordUpdated.value = true

    // Sign out to ensure clean state
    await supabase.auth.signOut()
    
  } catch (err) {
    console.error('Password update error:', err)
    error.value = err.message || 'Failed to update password. Please try again.'
  } finally {
    loading.value = false
  }
}

// Check for valid recovery token on mount
onMounted(async () => {
  console.log('Checking for password reset session...')
  
  // First check URL for recovery token
  const hashParams = new URLSearchParams(window.location.hash.substring(1))
  const accessToken = hashParams.get('access_token')
  const type = hashParams.get('type')
  
  if (!accessToken || type !== 'recovery') {
    console.log('No valid recovery token in URL')
    isValidToken.value = false
    return
  }

  // We have a recovery token, verify it's valid
  try {
    console.log('Verifying recovery token...')
    
    // Exchange the recovery token for a session to verify it
    const { data, error } = await supabase.auth.setSession({
      access_token: accessToken,
      refresh_token: hashParams.get('refresh_token') || ''
    })
    
    if (error || !data.session) {
      console.error('Invalid recovery token:', error)
      isValidToken.value = false
      return
    }
    
    // Valid recovery token confirmed
    console.log('Valid recovery token confirmed')
    isValidToken.value = true
    
    // Clear the hash from URL immediately to prevent token reuse
    window.history.replaceState(null, '', window.location.pathname)
    
    // IMPORTANT: Store the session for password update but prevent it from 
    // being used as a regular auth session in other tabs
    // The session is needed to call updateUser but shouldn't grant app access
    
  } catch (err) {
    console.error('Error verifying recovery token:', err)
    isValidToken.value = false
  }
})
</script>

<style scoped>
.reset-password-container {
  min-height: calc(100vh - 200px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
}

.reset-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  padding: 2.5rem;
  width: 100%;
  max-width: 450px;
}

.reset-card h2 {
  color: #1a1a1a;
  margin: 0 0 0.5rem 0;
  text-align: center;
  font-size: 1.75rem;
}

.reset-description {
  color: #666;
  text-align: center;
  margin-bottom: 2rem;
}

/* Success state styles */
.success-container {
  text-align: center;
  padding: 1rem 0;
}

.success-icon-wrapper {
  width: 80px;
  height: 80px;
  margin: 0 auto 1.5rem;
  position: relative;
}

.success-checkmark {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  display: block;
  stroke-width: 2;
  stroke: #4caf50;
  stroke-miterlimit: 10;
  animation: scale 0.3s ease-in-out 0.5s both;
}

.success-checkmark-circle {
  stroke-dasharray: 166;
  stroke-dashoffset: 166;
  stroke-width: 2;
  stroke-miterlimit: 10;
  stroke: #4caf50;
  fill: #f0f9f0;
  animation: stroke 0.6s cubic-bezier(0.65, 0, 0.45, 1) forwards;
}

.success-checkmark-check {
  transform-origin: 50% 50%;
  stroke-dasharray: 48;
  stroke-dashoffset: 48;
  stroke: #4caf50;
  animation: stroke 0.3s cubic-bezier(0.65, 0, 0.45, 1) 0.6s forwards;
}

@keyframes stroke {
  100% {
    stroke-dashoffset: 0;
  }
}

@keyframes scale {
  0%, 100% {
    transform: none;
  }
  50% {
    transform: scale3d(1.1, 1.1, 1);
  }
}

.success-title {
  color: #2d3748;
  font-size: 1.75rem;
  margin: 0 0 1rem 0;
  font-weight: 600;
}

.success-message {
  color: #64748b;
  font-size: 1.05rem;
  line-height: 1.6;
  margin: 0 0 2rem 0;
  max-width: 360px;
  margin-left: auto;
  margin-right: auto;
}

.success-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.875rem 2rem;
  background: linear-gradient(135deg, #3451b2 0%, #4c63d2 100%);
  color: white;
  text-decoration: none;
  border-radius: 8px;
  font-weight: 600;
  font-size: 1rem;
  transition: all 0.3s;
  box-shadow: 0 4px 14px 0 rgba(52, 81, 178, 0.25);
}

.success-btn:hover {
  background: linear-gradient(135deg, #2940a0 0%, #3a51c0 100%);
  transform: translateY(-2px);
  box-shadow: 0 6px 20px 0 rgba(52, 81, 178, 0.35);
}

.btn-icon {
  font-size: 1.2rem;
  transition: transform 0.3s;
}

.success-btn:hover .btn-icon {
  transform: translateX(3px);
}

/* Error state styles */
.error-container {
  text-align: center;
  padding: 1rem 0;
}

.error-icon-wrapper {
  width: 80px;
  height: 80px;
  margin: 0 auto 1.5rem;
  position: relative;
  color: #ef4444;
}

.error-icon {
  width: 100%;
  height: 100%;
  animation: fadeIn 0.5s ease-in-out;
}

.error-title {
  color: #2d3748;
  font-size: 1.75rem;
  margin: 0 0 1rem 0;
  font-weight: 600;
}

.error-description {
  color: #64748b;
  font-size: 1.05rem;
  line-height: 1.6;
  margin: 0 0 0.5rem 0;
  max-width: 380px;
  margin-left: auto;
  margin-right: auto;
}

.error-instruction {
  color: #64748b;
  font-size: 1rem;
  margin: 0 0 2rem 0;
}

.error-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.875rem 2rem;
  background: linear-gradient(135deg, #3451b2 0%, #4c63d2 100%);
  color: white;
  text-decoration: none;
  border-radius: 8px;
  font-weight: 600;
  font-size: 1rem;
  transition: all 0.3s;
  box-shadow: 0 4px 14px 0 rgba(52, 81, 178, 0.25);
}

.error-btn:hover {
  background: linear-gradient(135deg, #2940a0 0%, #3a51c0 100%);
  transform: translateY(-2px);
  box-shadow: 0 6px 20px 0 rgba(52, 81, 178, 0.35);
}

.error-btn:hover .btn-icon {
  transform: translateX(-3px);
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: scale(0.9);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.reset-form {
  margin-top: 2rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  color: #333;
  font-weight: 500;
  font-size: 0.95rem;
}

.form-group input {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 1rem;
  transition: border-color 0.3s;
}

.form-group input:focus {
  outline: none;
  border-color: #3451b2;
  box-shadow: 0 0 0 3px rgba(52, 81, 178, 0.1);
}

.field-hint {
  display: block;
  margin-top: 0.25rem;
  color: #888;
  font-size: 0.85rem;
}

.validation-error {
  background: #fff5f5;
  border: 1px solid #feb2b2;
  color: #c53030;
  padding: 0.75rem;
  border-radius: 6px;
  margin-bottom: 1rem;
  font-size: 0.9rem;
}

.update-password-btn {
  width: 100%;
  padding: 0.875rem;
  background: #3451b2;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.update-password-btn:hover:not(:disabled) {
  background: #2940a0;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(52, 81, 178, 0.3);
}

.update-password-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}


.error-message {
  background: #fff5f5;
  border: 1px solid #feb2b2;
  color: #c53030;
  padding: 1rem;
  border-radius: 6px;
  margin: 1rem 0;
}

/* Dark mode support */
.dark .reset-card {
  background: #1a1a1a;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
}

.dark .reset-card h2 {
  color: #f0f0f0;
}

.dark .reset-description {
  color: #aaa;
}

.dark .success-title {
  color: #f0f0f0;
}

.dark .success-message {
  color: #94a3b8;
}

.dark .success-checkmark-circle {
  fill: #1a2f1a;
}

.dark .success-btn {
  background: linear-gradient(135deg, #4c63d2 0%, #5b7ee5 100%);
  box-shadow: 0 4px 14px 0 rgba(76, 99, 210, 0.3);
}

.dark .success-btn:hover {
  background: linear-gradient(135deg, #3a51c0 0%, #4c63d2 100%);
  box-shadow: 0 6px 20px 0 rgba(76, 99, 210, 0.4);
}

.dark .error-title {
  color: #f0f0f0;
}

.dark .error-description,
.dark .error-instruction {
  color: #94a3b8;
}

.dark .error-icon-wrapper {
  color: #f87171;
}

.dark .error-btn {
  background: linear-gradient(135deg, #4c63d2 0%, #5b7ee5 100%);
  box-shadow: 0 4px 14px 0 rgba(76, 99, 210, 0.3);
}

.dark .error-btn:hover {
  background: linear-gradient(135deg, #3a51c0 0%, #4c63d2 100%);
  box-shadow: 0 6px 20px 0 rgba(76, 99, 210, 0.4);
}

.dark .form-group label {
  color: #e0e0e0;
}

.dark .form-group input {
  background: #2a2a2a;
  border-color: #444;
  color: #f0f0f0;
}

.dark .form-group input:focus {
  border-color: #5b7ee5;
  box-shadow: 0 0 0 3px rgba(91, 126, 229, 0.2);
}

.dark .field-hint {
  color: #999;
}

@media (max-width: 640px) {
  .reset-password-container {
    padding: 1rem;
  }

  .reset-card {
    padding: 1.5rem;
  }

  .reset-card h2 {
    font-size: 1.5rem;
  }
}
</style>