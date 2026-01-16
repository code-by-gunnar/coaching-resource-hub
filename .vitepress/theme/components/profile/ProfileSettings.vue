<template>
  <div class="profile-settings-view">
    <ViewHeader 
      title="Account Settings"
      :description="`Manage your account preferences and data for ${user?.email}`"
      :show-export="false"
      @back="$emit('navigate', 'dashboard')"
    />
    
    <div v-if="loading" class="loading-state">
      <p>Loading settings...</p>
    </div>
    
    <div v-else class="settings-sections">
      <!-- Change Password Section -->
      <div class="settings-section">
        <h3>Change Password</h3>
        <form @submit.prevent="handlePasswordChange" class="settings-form">
          <div class="form-group">
            <label for="current-password">Current Password</label>
            <input 
              id="current-password"
              v-model="currentPassword" 
              type="password" 
              required 
              placeholder="••••••••"
            />
          </div>
          <div class="form-group">
            <label for="new-password">New Password</label>
            <input 
              id="new-password"
              v-model="newPassword" 
              type="password" 
              required 
              minlength="6"
              placeholder="••••••••"
              @input="validatePasswords"
            />
            <small class="field-hint">Minimum 6 characters</small>
          </div>
          <div class="form-group">
            <label for="confirm-password">Confirm New Password</label>
            <input 
              id="confirm-password"
              v-model="confirmPassword" 
              type="password" 
              required 
              minlength="6"
              placeholder="••••••••"
              @input="validatePasswords"
              :class="{ 'input-error': passwordValidationError }"
            />
            <div v-if="passwordValidationError" class="validation-error">
              {{ passwordValidationError }}
            </div>
            <div v-else-if="confirmPassword && passwordsMatch" class="validation-success">
              ✅ Passwords match
            </div>
          </div>
          <button 
            type="submit" 
            class="settings-btn password-update-btn" 
            :disabled="passwordLoading || !!passwordValidationError || (!newPassword && !confirmPassword)"
          >
            {{ passwordLoading ? 'Updating...' : 'Update Password' }}
          </button>
        </form>
      </div>

      <!-- Export Data Section -->
      <div class="settings-section">
        <h3>Export Your Data</h3>
        <p class="section-description">Download all your study logs and learning reflections as a document.</p>
        <button @click="exportData('all')" class="settings-btn secondary" :disabled="exportLoading">
          {{ exportLoading ? 'Exporting...' : 'Export All Data' }}
        </button>
      </div>

      <!-- Account Deletion Section -->
      <div class="settings-section danger-section">
        <h3>Delete Account</h3>
        <p class="section-description">
          Permanently delete your account and all associated data. This action cannot be undone.
        </p>
        
        <button 
          v-if="!showDeleteConfirm" 
          @click="showDeleteConfirm = true" 
          class="settings-btn danger"
        >
          Delete Account
        </button>

        <div v-if="showDeleteConfirm" class="delete-confirmation">
          <p><strong>Are you absolutely sure?</strong></p>
          <p>Type your email address to confirm account deletion:</p>
          <input 
            v-model="deleteConfirmEmail" 
            type="email" 
            :placeholder="user?.email || 'your@email.com'"
            class="delete-confirm-input"
            :class="{ 'email-valid': isEmailValid, 'email-invalid': deleteConfirmEmail && !isEmailValid }"
          />
          <div v-if="deleteConfirmEmail" class="email-validation-status">
            <span v-if="isEmailValid" class="validation-success">✅ Email matches</span>
            <span v-else class="validation-error">❌ Email does not match</span>
          </div>
          <div class="delete-actions">
            <button 
              @click="handleAccountDeletion" 
              class="settings-btn danger" 
              :disabled="deleteLoading || !isEmailValid"
            >
              {{ deleteLoading ? 'Deleting...' : 'Yes, Delete My Account' }}
            </button>
            <button 
              @click="cancelAccountDeletion" 
              class="settings-btn secondary"
            >
              Cancel
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Status Messages -->
    <div v-if="successMessage" class="success-message">
      {{ successMessage }}
    </div>
    <div v-if="errorMessage" class="error-message">
      {{ errorMessage }}
    </div>
  </div>
</template>

<script setup>
import { inject, onMounted, computed, ref } from 'vue'
import { useProfileSettings } from '../../composables/useProfileSettings.js'
import ViewHeader from './shared/ViewHeader.vue'

// Get user from parent context
const user = inject('user')

const { 
  loading,
  currentPassword,
  newPassword,
  confirmPassword,
  passwordLoading,
  exportLoading,
  deleteLoading,
  showDeleteConfirm,
  deleteConfirmEmail,
  successMessage,
  errorMessage,
  handlePasswordChange,
  exportData,
  handleAccountDeletion,
  cancelAccountDeletion
} = useProfileSettings(user)

// Password validation state
const passwordValidationError = ref('')

// Validate passwords match
const validatePasswords = () => {
  if (newPassword.value && confirmPassword.value) {
    if (newPassword.value !== confirmPassword.value) {
      passwordValidationError.value = 'Passwords do not match'
    } else if (newPassword.value.length < 6) {
      passwordValidationError.value = 'Password must be at least 6 characters'
    } else {
      passwordValidationError.value = ''
    }
  } else {
    passwordValidationError.value = ''
  }
}

// Computed property for password match
const passwordsMatch = computed(() => {
  return newPassword.value && confirmPassword.value && 
         newPassword.value === confirmPassword.value && 
         newPassword.value.length >= 6
})

// Computed property for email validation
const isEmailValid = computed(() => {
  if (!user?.value?.email || !deleteConfirmEmail.value) return false
  const userEmail = user.value.email.toLowerCase().trim()
  const confirmEmail = deleteConfirmEmail.value.toLowerCase().trim()
  return confirmEmail === userEmail
})

defineEmits(['navigate', 'accountDeleted'])

onMounted(() => {
  loading.value = false
})
</script>

<style scoped>
.loading-state {
  text-align: center;
  padding: 2rem;
}

.settings-sections {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.settings-section {
  padding: 1.5rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  background: var(--vp-c-bg-soft);
}

.settings-section h3 {
  margin: 0 0 1rem 0;
  color: var(--vp-c-text-1);
}

.section-description {
  margin: 0 0 1rem 0;
  color: var(--vp-c-text-2);
  font-size: 0.9rem;
}

.settings-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group label {
  margin-bottom: 0.5rem;
  color: var(--vp-c-text-1);
  font-weight: 500;
}

.form-group input, .delete-confirm-input {
  padding: 12px;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  font-size: 1rem;
}

.form-group input:focus, .delete-confirm-input:focus {
  outline: none;
  border-color: var(--vp-c-brand);
}

.form-group input.input-error {
  border-color: #ef4444;
}

.field-hint {
  display: block;
  margin-top: 0.25rem;
  color: var(--vp-c-text-3);
  font-size: 0.85rem;
}

.validation-error {
  margin-top: 0.5rem;
  color: #ef4444;
  font-size: 0.875rem;
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.validation-success {
  margin-top: 0.5rem;
  color: #10b981;
  font-size: 0.875rem;
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.settings-btn {
  padding: 12px 24px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 500;
  transition: all 0.3s ease;
}

.settings-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* Primary button (default) */
.settings-btn {
  background: #3b82f6;
  color: white;
  border-color: #3b82f6;
}

.settings-btn:hover:not(:disabled) {
  background: #2563eb;
  border-color: #2563eb;
}

/* Secondary button */
.settings-btn.secondary {
  background: #10b981;
  color: white;
  border-color: #10b981;
}

.settings-btn.secondary:hover:not(:disabled) {
  background: #059669;
  border-color: #059669;
}

/* Danger button */
.settings-btn.danger {
  background: #dc2626;
  color: white;
  border-color: #dc2626;
}

.settings-btn.danger:hover:not(:disabled) {
  background: #b91c1c;
  border-color: #b91c1c;
}

.danger-section {
  border: 2px solid #fee2e2;
  background: #fef2f2;
}

.danger-section h3 {
  color: #dc2626;
}

.danger-section .section-description {
  color: #7f1d1d;
}

.delete-confirmation {
  margin-top: 1rem;
  padding: 1.5rem;
  background: #fee2e2;
  border: 1px solid #fca5a5;
  border-radius: 8px;
}

.delete-confirmation strong {
  color: #991b1b;
}

.delete-confirmation p {
  margin: 0.5rem 0;
  color: var(--vp-c-text-1);
}

.delete-confirm-input {
  width: 100%;
  margin: 1rem 0;
  transition: border-color 0.3s ease, box-shadow 0.3s ease;
}

.delete-confirm-input.email-valid {
  border-color: #22c55e;
  box-shadow: 0 0 0 3px rgba(34, 197, 94, 0.1);
}

.delete-confirm-input.email-invalid {
  border-color: #ef4444;
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
}

.email-validation-status {
  margin-top: -0.5rem;
  margin-bottom: 1rem;
  font-size: 0.9rem;
  font-weight: 500;
}

.email-validation-status .validation-success {
  color: #16a34a;
}

.email-validation-status .validation-error {
  color: #dc2626;
}

.delete-actions {
  display: flex;
  gap: 1rem;
  margin-top: 1rem;
}

.success-message {
  margin-top: 1rem;
  padding: 12px;
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green-darker);
  border: 1px solid var(--vp-c-green-light);
  border-radius: 6px;
  font-size: 0.9rem;
}

.error-message {
  margin-top: 1rem;
  padding: 12px;
  background: var(--vp-c-red-soft);
  color: var(--vp-c-red-darker);
  border-radius: 6px;
  font-size: 0.9rem;
}

.password-update-btn {
  max-width: 200px;
  background: #3b82f6;
  color: white;
  border-color: #3b82f6;
}

.password-update-btn:hover:not(:disabled) {
  background: #2563eb;
  border-color: #2563eb;
}

/* Dark mode styles */
.dark .danger-section {
  background: rgba(220, 38, 38, 0.1);
  border-color: rgba(220, 38, 38, 0.3);
}

.dark .danger-section h3 {
  color: #f87171;
}

.dark .danger-section .section-description {
  color: #fca5a5;
}

.dark .delete-confirmation {
  background: rgba(220, 38, 38, 0.15);
  border-color: rgba(220, 38, 38, 0.4);
}

.dark .delete-confirmation strong {
  color: #f87171;
}

.dark .delete-confirmation p {
  color: var(--vp-c-text-1);
}

.dark .delete-confirm-input.email-valid {
  border-color: #22c55e;
  box-shadow: 0 0 0 3px rgba(34, 197, 94, 0.2);
}

.dark .delete-confirm-input.email-invalid {
  border-color: #ef4444;
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.2);
}

.dark .email-validation-status .validation-success {
  color: #4ade80;
}

.dark .email-validation-status .validation-error {
  color: #f87171;
}

.dark .settings-btn.danger {
  background: #dc2626;
  color: white;
  border-color: #dc2626;
}

.dark .settings-btn.danger:hover:not(:disabled) {
  background: #ef4444;
  border-color: #ef4444;
}

@media (max-width: 768px) {
  .delete-actions {
    flex-direction: column;
  }
  
  .password-update-btn {
    max-width: 100%;
  }
}
</style>