<template>
  <div class="admin-container">
    <!-- Loading state during auth check -->
    <div v-if="!isAuthLoaded" class="admin-content">
      <div class="admin-header">
        <h1>🔄 Loading...</h1>
        <p class="admin-subtitle">Checking administrator access...</p>
      </div>
    </div>

    <!-- Admin Access Check -->
    <div v-else-if="!hasAdminAccess" class="admin-content">
      <div class="admin-header">
        <h1>⚠️ Admin Access Required</h1>
        <p class="admin-subtitle">You need administrator privileges to edit competencies.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- Competency Display Name Editor -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>{{ competencyId ? 'Edit' : 'Create' }} Competency Display Name</h1>
          <p class="admin-subtitle">{{ competencyId ? 'Update' : 'Create' }} core competency definition in competency_display_names table</p>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <ActionButton href="/docs/admin/competencies/" variant="gray">Competencies</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>{{ competencyId ? 'Edit' : 'Create' }} Display Name</span>
      </nav>

      <!-- Editor Form -->
      <div class="editor-container">
        <div class="form-card">
          <div class="section-header">
            <div>
              <h2>📋 Display Name Fields</h2>
              <p class="section-description">Edit fields from the competency_display_names database table</p>
            </div>
            <div class="table-info">
              <span class="table-badge">competency_display_names</span>
            </div>
          </div>

          <form @submit.prevent="saveCompetency" class="editor-form">
            <!-- Display Name (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Display Name</span>
                <span class="field-info">display_name (text, required)</span>
              </label>
              <input 
                v-model="formData.display_name"
                type="text" 
                class="form-input"
                :class="{ error: errors.display_name }"
                placeholder="e.g., Active Listening"
                maxlength="255"
                required
              >
              <div v-if="errors.display_name" class="error-message">{{ errors.display_name }}</div>
              <div class="field-help">This is the user-facing name for the competency</div>
            </div>

            <!-- Competency Key (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Competency Key</span>
                <span class="field-info">competency_key (text, required, unique per framework)</span>
              </label>
              <input 
                v-model="formData.competency_key"
                type="text" 
                class="form-input"
                :class="{ error: errors.competency_key }"
                placeholder="e.g., active_listening"
                maxlength="100"
                pattern="[a-z0-9_-]+"
                title="Use lowercase letters, numbers, underscores, and hyphens only"
                required
              >
              <div v-if="errors.competency_key" class="error-message">{{ errors.competency_key }}</div>
              <div class="field-help">Internal identifier - lowercase, underscores/hyphens only</div>
            </div>

            <!-- Framework (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Framework</span>
                <span class="field-info">framework (text, required)</span>
              </label>
              <select 
                v-model="formData.framework"
                class="form-select"
                :class="{ error: errors.framework }"
                required
              >
                <option value="">Select Framework</option>
                <option value="core">Core Framework</option>
                <option value="icf">ICF Framework</option>
                <option value="ac">AC Framework</option>
              </select>
              <div v-if="errors.framework" class="error-message">{{ errors.framework }}</div>
              <div class="field-help">Which competency framework this belongs to</div>
            </div>

            <!-- Description (Optional) -->
            <div class="form-group">
              <label class="form-label">
                Description
                <span class="field-info">description (text, optional)</span>
              </label>
              <textarea 
                v-model="formData.description"
                rows="4"
                class="form-textarea"
                :class="{ error: errors.description }"
                placeholder="Describe what this competency measures and why it's important..."
                maxlength="1000"
              ></textarea>
              <div class="char-count">{{ (formData.description || '').length }}/1000</div>
              <div v-if="errors.description" class="error-message">{{ errors.description }}</div>
              <div class="field-help">Optional detailed description of the competency</div>
            </div>

            <!-- Is Active (Boolean) -->
            <div class="form-group">
              <label class="form-checkbox">
                <input 
                  type="checkbox" 
                  v-model="formData.is_active"
                  class="checkbox-input"
                >
                <span class="checkbox-label">
                  Active
                  <span class="field-info">is_active (boolean, default: true)</span>
                </span>
              </label>
              <div class="field-help">Whether this competency is available for use in assessments</div>
            </div>

            <!-- Metadata (Read-only) -->
            <div v-if="competencyId" class="form-group metadata-group">
              <label class="form-label">Metadata</label>
              <div class="metadata-display">
                <div class="metadata-item">
                  <span class="metadata-label">ID:</span>
                  <code class="metadata-value">{{ formData.id }}</code>
                </div>
                <div class="metadata-item">
                  <span class="metadata-label">Created:</span>
                  <span class="metadata-value">{{ formatDate(formData.created_at) }}</span>
                </div>
              </div>
            </div>

            <!-- Form Actions -->
            <div class="form-actions">
              <ActionButton 
                @click="goBack" 
                variant="secondary"
              >
                Cancel
              </ActionButton>
              
              <button 
                type="submit" 
                class="btn-primary"
                :disabled="saving || !isFormValid"
              >
                <span v-if="saving" class="spinner"></span>
                <span v-else>{{ competencyId ? 'Update' : 'Create' }} Display Name</span>
              </button>
            </div>
          </form>
        </div>

        <!-- Related Data Notice -->
        <div class="info-card">
          <div class="info-header">
            <span class="info-icon">💡</span>
            <h3>Related Data</h3>
          </div>
          <div class="info-content">
            <p>This editor only manages the <strong>competency_display_names</strong> table. To edit related data:</p>
            <ul class="related-links">
              <li><strong>Rich Insights</strong> → Use the "Rich Insights" tab in the main competencies interface</li>
              <li><strong>Performance Analysis</strong> → Use the "Performance Analysis" tab</li>
              <li><strong>Strategic Actions</strong> → Use the "Strategic Actions" tab</li>
              <li><strong>Leverage Strengths</strong> → Use the "Leverage Strengths" tab</li>
            </ul>
            <p class="info-note">Each tab manages its own database table with dedicated editors.</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAdminSession } from '../composables/useAdminSession'
import { useAdminSupabase } from '../composables/useAdminSupabase'
import ActionButton from './shared/ActionButton.vue'

const { hasAdminAccess } = useAdminSession()
const { adminSupabase } = useAdminSupabase()

// Authentication loading state
const isAuthLoaded = ref(false)

// Get competency ID from URL params using client-side approach
const competencyId = computed(() => {
  if (typeof window !== 'undefined') {
    const urlParams = new URLSearchParams(window.location.search)
    return urlParams.get('id')
  }
  return null
})

// Form state
const saving = ref(false)
const errors = ref({})

// Form data - only fields from competency_display_names table
const formData = ref({
  id: '',
  competency_key: '',
  display_name: '',
  framework: '',
  description: '',
  is_active: true,
  created_at: ''
})

// Computed
const isFormValid = computed(() => {
  return formData.value.display_name && 
         formData.value.competency_key && 
         formData.value.framework &&
         Object.keys(errors.value).length === 0
})

// Methods
const validateField = (field) => {
  errors.value = { ...errors.value }
  delete errors.value[field]
  
  switch (field) {
    case 'display_name':
      if (!formData.value.display_name?.trim()) {
        errors.value.display_name = 'Display name is required'
      }
      break
      
    case 'competency_key':
      const key = formData.value.competency_key?.trim()
      if (!key) {
        errors.value.competency_key = 'Competency key is required'
      } else if (!/^[a-z0-9_-]+$/.test(key)) {
        errors.value.competency_key = 'Use only lowercase letters, numbers, underscores, and hyphens'
      }
      break
      
    case 'framework':
      if (!formData.value.framework) {
        errors.value.framework = 'Framework is required'
      }
      break
  }
}

const validateForm = () => {
  validateField('display_name')
  validateField('competency_key')  
  validateField('framework')
  return Object.keys(errors.value).length === 0
}

const loadCompetency = async () => {
  if (!competencyId.value || !adminSupabase) return

  try {
    const { data, error } = await adminSupabase
      .from('competency_display_names')
      .select('*')
      .eq('id', competencyId.value)
      .single()

    if (error) {
      console.error('Error loading competency:', error)
      alert('Error loading competency: ' + error.message)
      return
    }

    if (data) {
      formData.value = {
        id: data.id,
        competency_key: data.competency_key || '',
        display_name: data.display_name || '',
        framework: data.framework || '',
        description: data.description || '',
        is_active: data.is_active !== false,
        created_at: data.created_at
      }
    }
  } catch (error) {
    console.error('Error loading competency:', error)
    alert('Failed to load competency')
  }
}

const saveCompetency = async () => {
  if (!adminSupabase || saving.value) return
  
  // Validate form
  if (!validateForm()) {
    alert('Please fix the errors before saving')
    return
  }

  saving.value = true

  try {
    // Prepare data for database (only include actual table fields)
    const dbData = {
      competency_key: formData.value.competency_key.trim(),
      display_name: formData.value.display_name.trim(),
      framework: formData.value.framework,
      description: formData.value.description?.trim() || null,
      is_active: formData.value.is_active
    }

    let result
    if (competencyId.value) {
      // Update existing
      const { data, error } = await adminSupabase
        .from('competency_display_names')
        .update(dbData)
        .eq('id', competencyId.value)
        .select()

      if (error) throw error
      result = data
    } else {
      // Create new
      const { data, error } = await adminSupabase
        .from('competency_display_names')
        .insert(dbData)
        .select()

      if (error) throw error
      result = data
    }

    alert('Competency display name saved successfully!')
    goBack()
  } catch (error) {
    console.error('Error saving competency:', error)
    
    // Handle specific database errors
    if (error.code === '23505') {
      errors.value.competency_key = 'This competency key already exists for this framework'
    } else {
      alert('Failed to save competency: ' + error.message)
    }
  } finally {
    saving.value = false
  }
}

const goBack = () => {
  window.location.href = '/docs/admin/competencies/'
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString() + ' ' + 
         new Date(dateString).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
}

// Auto-generate competency key from display name
const autoGenerateKey = () => {
  if (formData.value.display_name && !formData.value.competency_key) {
    formData.value.competency_key = formData.value.display_name
      .toLowerCase()
      .replace(/[^a-z0-9\s]/g, '')
      .replace(/\s+/g, '_')
      .substring(0, 50)
  }
}

// Watch display name changes to auto-generate key for new competencies
const watchDisplayName = () => {
  if (!competencyId.value) {
    autoGenerateKey()
  }
}

onMounted(() => {
  isAuthLoaded.value = true
  if (competencyId.value) {
    loadCompetency()
  }
})
</script>

<style scoped>
.admin-container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 20px;
}

.admin-header {
  margin-bottom: 30px;
}

.header-main h1 {
  font-size: 28px;
  margin-bottom: 8px;
}

.admin-subtitle {
  color: var(--vp-c-text-2);
  font-size: 14px;
}

.breadcrumb {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 32px;
  padding: 12px;
  background: var(--vp-c-bg-soft);
  border-radius: 6px;
}

.breadcrumb-separator {
  color: var(--vp-c-text-3);
}

.editor-container {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 24px;
}

.form-card {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  padding: 32px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: start;
  margin-bottom: 32px;
}

.section-header h2 {
  font-size: 22px;
  margin-bottom: 4px;
}

.section-description {
  color: var(--vp-c-text-2);
  font-size: 14px;
}

.table-badge {
  background: var(--vp-c-purple-soft);
  color: var(--vp-c-purple);
  padding: 4px 12px;
  border-radius: 16px;
  font-size: 11px;
  font-weight: 600;
  font-family: monospace;
}

.editor-form {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-label {
  font-weight: 500;
  color: var(--vp-c-text-1);
  display: flex;
  flex-direction: column;
  gap: 4px;
}

/* Required field styling - now using inline styles for simplicity */

.field-info {
  font-size: 11px;
  color: var(--vp-c-text-3);
  font-weight: 400;
  font-family: monospace;
  background: var(--vp-c-bg-mute);
  padding: 2px 6px;
  border-radius: 3px;
}

.form-input,
.form-select,
.form-textarea {
  padding: 10px 14px;
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  background: var(--vp-c-bg);
  font-size: 14px;
  transition: border-color 0.2s;
}

.form-input:focus,
.form-select:focus,
.form-textarea:focus {
  outline: none;
  border-color: var(--vp-c-brand);
}

.form-input.error,
.form-select.error,
.form-textarea.error {
  border-color: var(--vp-c-danger);
}

.form-textarea {
  resize: vertical;
  min-height: 100px;
}

.char-count {
  font-size: 11px;
  color: var(--vp-c-text-3);
  text-align: right;
  margin-top: -4px;
}

.error-message {
  color: var(--vp-c-danger);
  font-size: 12px;
}

.field-help {
  font-size: 12px;
  color: var(--vp-c-text-2);
}

.form-checkbox {
  display: flex;
  align-items: start;
  gap: 12px;
  cursor: pointer;
}

.checkbox-input {
  width: auto;
  margin: 0;
}

.checkbox-label {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.metadata-group {
  border-top: 1px solid var(--vp-c-border);
  padding-top: 24px;
}

.metadata-display {
  display: flex;
  flex-direction: column;
  gap: 8px;
  background: var(--vp-c-bg-mute);
  padding: 16px;
  border-radius: 6px;
}

.metadata-item {
  display: flex;
  gap: 12px;
}

.metadata-label {
  font-weight: 500;
  min-width: 80px;
  color: var(--vp-c-text-2);
}

.metadata-value {
  font-family: monospace;
  font-size: 12px;
  background: var(--vp-c-bg-soft);
  padding: 2px 6px;
  border-radius: 3px;
}

.form-actions {
  display: flex;
  gap: 16px;
  justify-content: flex-end;
  padding-top: 24px;
  border-top: 1px solid var(--vp-c-border);
}

.btn-primary {
  background: var(--vp-c-brand);
  color: white;
  border: none;
  padding: 10px 24px;
  border-radius: 6px;
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: background 0.2s;
}

.btn-primary:hover:not(:disabled) {
  background: var(--vp-c-brand-dark);
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top: 2px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.info-card {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  padding: 24px;
  height: fit-content;
}

.info-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.info-icon {
  font-size: 20px;
}

.info-header h3 {
  margin: 0;
  font-size: 16px;
}

.info-content {
  color: var(--vp-c-text-2);
  font-size: 14px;
  line-height: 1.6;
}

.related-links {
  margin: 12px 0;
  padding-left: 20px;
}

.related-links li {
  margin-bottom: 8px;
}

.info-note {
  font-style: italic;
  color: var(--vp-c-text-3);
  font-size: 12px;
}

@media (max-width: 768px) {
  .editor-container {
    grid-template-columns: 1fr;
    gap: 16px;
  }
  
  .form-card {
    padding: 24px;
  }
  
  .form-actions {
    flex-direction: column;
  }
}
</style>