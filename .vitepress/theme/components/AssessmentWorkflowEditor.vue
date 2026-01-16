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
        <p class="admin-subtitle">You need administrator privileges to manage assessments.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- Assessment Editor -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>{{ assessmentId ? 'Edit' : 'Create' }} Assessment</h1>
          <p class="admin-subtitle">{{ assessmentId ? 'Update' : 'Create' }} assessment configuration</p>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <ActionButton href="/docs/admin/assessments/" variant="gray">Assessments</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>{{ assessmentId ? 'Edit' : 'Create' }} Assessment</span>
      </nav>

      <!-- Editor Form -->
      <div class="editor-container">
        <div class="form-card">
          <div class="section-header">
            <div>
              <h2>📝 Assessment Configuration</h2>
              <p class="section-description">Basic assessment setup and metadata</p>
            </div>
            <div class="table-info">
              <span class="table-badge">assessments</span>
            </div>
          </div>

          <form @submit.prevent="saveAssessment" class="editor-form">
            <!-- Assessment Title (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Assessment Title</span>
                <span class="field-info">title (text, required)</span>
              </label>
              <input 
                v-model="formData.title"
                type="text" 
                class="form-input"
                :class="{ error: errors.title }"
                placeholder="e.g., CORE I - Fundamentals"
                maxlength="255"
                required
              >
              <div v-if="errors.title" class="error-message">{{ errors.title }}</div>
              <div class="field-help">Display name for the assessment</div>
            </div>

            <!-- Assessment Slug (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Assessment Slug</span>
                <span class="field-info">slug (text, required, unique)</span>
              </label>
              <input 
                v-model="formData.slug"
                type="text" 
                class="form-input"
                :class="{ error: errors.slug }"
                placeholder="e.g., core-fundamentals-i"
                maxlength="100"
                required
              >
              <div v-if="errors.slug" class="error-message">{{ errors.slug }}</div>
              <div class="field-help">URL-friendly identifier (lowercase, dashes only)</div>
            </div>

            <!-- Framework (Optional) -->
            <div class="form-group">
              <label class="form-label">
                Framework
                <span class="field-info">framework_id (uuid, optional)</span>
              </label>
              <select 
                v-model="formData.framework_id"
                class="form-select"
                :class="{ error: errors.framework_id }"
              >
                <option value="">No Framework</option>
                <option v-for="framework in frameworks" :key="framework.id" :value="framework.id">
                  {{ framework.name }}
                </option>
              </select>
              <div v-if="errors.framework_id" class="error-message">{{ errors.framework_id }}</div>
              <div class="field-help">Which coaching framework this assessment belongs to</div>
            </div>

            <!-- Assessment Level (Optional) -->
            <div class="form-group">
              <label class="form-label">
                Assessment Level
                <span class="field-info">assessment_level_id (uuid, optional)</span>
              </label>
              <select 
                v-model="formData.assessment_level_id"
                class="form-select"
                :class="{ error: errors.assessment_level_id }"
              >
                <option value="">Any Level</option>
                <option v-for="level in assessmentLevels" :key="level.id" :value="level.id">
                  {{ level.level_name }}
                </option>
              </select>
              <div v-if="errors.assessment_level_id" class="error-message">{{ errors.assessment_level_id }}</div>
              <div class="field-help">Target difficulty level for this assessment</div>
            </div>

            <!-- Description -->
            <div class="form-group">
              <label class="form-label">
                Description
                <span class="field-info">description (text, optional)</span>
              </label>
              <textarea 
                v-model="formData.description"
                class="form-textarea"
                :class="{ error: errors.description }"
                placeholder="Describe what this assessment covers..."
                rows="4"
                maxlength="1000"
              ></textarea>
              <div class="char-count">{{ formData.description?.length || 0 }}/1000 characters</div>
              <div v-if="errors.description" class="error-message">{{ errors.description }}</div>
              <div class="field-help">Optional description for administrators</div>
            </div>

            <!-- Assessment Settings Row -->
            <div class="form-row">
              <!-- Estimated Duration -->
              <div class="form-group">
                <label class="form-label">
                  Estimated Duration (minutes)
                  <span class="field-info">estimated_duration (integer)</span>
                </label>
                <input 
                  v-model.number="formData.estimated_duration"
                  type="number" 
                  class="form-input"
                  :class="{ error: errors.estimated_duration }"
                  placeholder="30"
                  min="5"
                  max="180"
                >
                <div v-if="errors.estimated_duration" class="error-message">{{ errors.estimated_duration }}</div>
              </div>

              <!-- Sort Order -->
              <div class="form-group">
                <label class="form-label">
                  Sort Order
                  <span class="field-info">sort_order (integer)</span>
                </label>
                <input 
                  v-model.number="formData.sort_order"
                  type="number" 
                  class="form-input"
                  :class="{ error: errors.sort_order }"
                  placeholder="0"
                  min="0"
                  max="999"
                >
                <div v-if="errors.sort_order" class="error-message">{{ errors.sort_order }}</div>
              </div>

              <!-- Icon -->
              <div class="form-group">
                <label class="form-label">
                  Icon
                  <span class="field-info">icon (text)</span>
                </label>
                <input 
                  v-model="formData.icon"
                  type="text" 
                  class="form-input"
                  :class="{ error: errors.icon }"
                  placeholder="📋"
                  maxlength="10"
                >
                <div v-if="errors.icon" class="error-message">{{ errors.icon }}</div>
              </div>
            </div>

            <!-- Is Active -->
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
              <div class="field-help">Whether this assessment is available to users</div>
            </div>

            <!-- Metadata (Read-only) -->
            <div v-if="assessmentId" class="form-group metadata-group">
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
                <div class="metadata-item">
                  <span class="metadata-label">Updated:</span>
                  <span class="metadata-value">{{ formatDate(formData.updated_at) }}</span>
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
              
              <ActionButton 
                @click="saveAssessment" 
                variant="primary"
                :disabled="saving || !isFormValid"
              >
                <span v-if="saving" class="spinner"></span>
                <span v-else>{{ assessmentId ? 'Update' : 'Create' }} Assessment</span>
              </ActionButton>
            </div>
          </form>
        </div>

        <!-- Quick Info Card -->
        <div class="info-card">
          <div class="info-header">
            <span class="info-icon">📝</span>
            <h3>Assessment Management</h3>
          </div>
          <div class="info-content">
            <p>Assessments test users' knowledge across competency areas using multiple-choice questions.</p>
            <ul class="related-links">
              <li><strong>Questions</strong> → Add questions after creating the assessment</li>
              <li><strong>Competencies</strong> → Link questions to specific competency areas</li>
              <li><strong>Results</strong> → Users receive scores and personalized insights</li>
            </ul>
            <p class="info-note">Create the assessment first, then add questions through the Questions tab in the main assessments interface.</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vitepress'
import { useAdminSession } from '../composables/useAdminSession'
import { useAdminSupabase } from '../composables/useAdminSupabase'
import ActionButton from './shared/ActionButton.vue'

const { hasAdminAccess } = useAdminSession()
const { adminSupabase } = useAdminSupabase()

// Authentication loading state
const isAuthLoaded = ref(false)
const route = useRoute()

// Get assessment ID from URL params
const assessmentId = computed(() => {
  const id = route.query?.id || route.params?.id || new URLSearchParams(window.location.search).get('id')
  console.log('Assessment ID from URL:', id)
  return id
})

// Form state
const saving = ref(false)
const errors = ref({})

// Reference data
const frameworks = ref([])
const assessmentLevels = ref([])

// Form data - using database structure
const formData = ref({
  id: '',
  slug: '',
  title: '',
  description: '',
  estimated_duration: 30,
  icon: '📋',
  is_active: true,
  sort_order: 0,
  framework_id: '',
  assessment_level_id: '',
  created_at: '',
  updated_at: ''
})

// Computed
const isFormValid = computed(() => {
  return formData.value.title?.trim() && 
         formData.value.slug?.trim() &&
         Object.keys(errors.value).length === 0
})

// Methods
const validateField = (field) => {
  errors.value = { ...errors.value }
  delete errors.value[field]
  
  switch (field) {
    case 'title':
      if (!formData.value.title?.trim()) {
        errors.value.title = 'Assessment title is required'
      }
      break
      
    case 'slug':
      if (!formData.value.slug?.trim()) {
        errors.value.slug = 'Assessment slug is required'
      } else if (!/^[a-z0-9-]+$/.test(formData.value.slug)) {
        errors.value.slug = 'Slug must contain only lowercase letters, numbers, and dashes'
      }
      break
      
    case 'estimated_duration':
      const duration = formData.value.estimated_duration
      if (duration !== null && duration !== undefined && (duration < 5 || duration > 180)) {
        errors.value.estimated_duration = 'Duration must be between 5 and 180 minutes'
      }
      break
      
    case 'sort_order':
      const order = formData.value.sort_order
      if (order !== null && order !== undefined && (order < 0 || order > 999)) {
        errors.value.sort_order = 'Sort order must be between 0 and 999'
      }
      break
  }
}

const validateForm = () => {
  validateField('title')
  validateField('slug')
  validateField('estimated_duration')
  validateField('sort_order')
  return Object.keys(errors.value).length === 0
}

const loadReferenceData = async () => {
  if (!adminSupabase) return

  try {
    console.log('Loading reference data...')
    
    // Load reference data in parallel
    const [frameworksResult, levelsResult] = await Promise.all([
      adminSupabase
        .from('frameworks')
        .select('id, name, code')
        .eq('is_active', true)
        .order('name'),
      adminSupabase
        .from('assessment_levels')
        .select('id, level_code, level_name')
        .eq('is_active', true)
        .order('level_name')
    ])

    if (frameworksResult.error) {
      console.error('Error loading frameworks:', frameworksResult.error)
    } else {
      frameworks.value = frameworksResult.data || []
      console.log('Loaded frameworks:', frameworks.value.length)
    }

    if (levelsResult.error) {
      console.error('Error loading assessment levels:', levelsResult.error)
    } else {
      assessmentLevels.value = levelsResult.data || []
      console.log('Loaded assessment levels:', assessmentLevels.value.length)
    }

  } catch (error) {
    console.error('Error loading reference data:', error)
  }
}

const loadAssessment = async () => {
  console.log('loadAssessment called with assessmentId:', assessmentId.value)
  
  if (!assessmentId.value || !adminSupabase) {
    console.log('Skipping loadAssessment - missing assessmentId or adminSupabase')
    return
  }

  try {
    console.log('Fetching assessment with ID:', assessmentId.value)
    
    const { data, error } = await adminSupabase
      .from('assessments')
      .select(`
        *,
        frameworks!framework_id (
          id, name, code
        ),
        assessment_levels!assessment_level_id (
          id, level_code, level_name
        )
      `)
      .eq('id', assessmentId.value)
      .single()

    console.log('Supabase response:', { data, error })

    if (error) {
      console.error('Error loading assessment:', error)
      alert('Error loading assessment: ' + error.message)
      return
    }

    if (data) {
      console.log('Setting form data with assessment:', data)
      
      formData.value = {
        id: data.id,
        slug: data.slug || '',
        title: data.title || '',
        description: data.description || '',
        estimated_duration: data.estimated_duration || 30,
        icon: data.icon || '📋',
        is_active: data.is_active !== false,
        sort_order: data.sort_order || 0,
        framework_id: data.framework_id || '',
        assessment_level_id: data.assessment_level_id || '',
        created_at: data.created_at,
        updated_at: data.updated_at
      }
      console.log('Form data set to:', formData.value)
    } else {
      console.log('No data returned from Supabase')
    }
  } catch (error) {
    console.error('Error loading assessment:', error)
    alert('Failed to load assessment: ' + error.message)
  }
}

const saveAssessment = async () => {
  if (!adminSupabase || saving.value) return
  
  if (!validateForm()) {
    alert('Please fix the errors before saving')
    return
  }

  saving.value = true

  try {
    // Prepare data for database
    const dbData = {
      slug: formData.value.slug.trim().toLowerCase(),
      title: formData.value.title.trim(),
      description: formData.value.description?.trim() || null,
      estimated_duration: formData.value.estimated_duration || 30,
      icon: formData.value.icon?.trim() || '📋',
      is_active: formData.value.is_active,
      sort_order: formData.value.sort_order || 0,
      framework_id: formData.value.framework_id || null,
      assessment_level_id: formData.value.assessment_level_id || null
    }

    if (assessmentId.value) {
      // Update existing assessment
      const { data, error } = await adminSupabase
        .from('assessments')
        .update(dbData)
        .eq('id', assessmentId.value)
        .select()

      if (error) throw error
      console.log('Updated assessment:', data)
    } else {
      // Create new assessment
      const { data, error } = await adminSupabase
        .from('assessments')
        .insert(dbData)
        .select()

      if (error) throw error
      console.log('Created assessment:', data)
    }

    alert('Assessment saved successfully!')
    goBack()
  } catch (error) {
    console.error('Error saving assessment:', error)
    
    // Handle unique constraint violation
    if (error.code === '23505' && error.message.includes('assessments_slug_key')) {
      alert('An assessment with this slug already exists. Please use a different slug.')
    } else {
      alert('Failed to save assessment: ' + error.message)
    }
  } finally {
    saving.value = false
  }
}

const goBack = () => {
  window.location.href = '/docs/admin/assessments/'
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString() + ' ' + 
         new Date(dateString).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
}

onMounted(async () => {
  isAuthLoaded.value = true
  console.log('Component mounted')
  console.log('Current URL:', window.location.href)
  console.log('Route object:', route)
  console.log('Assessment ID on mount:', assessmentId.value)
  
  await loadReferenceData()
  
  if (assessmentId.value) {
    console.log('AssessmentId found, loading assessment...')
    await loadAssessment()
  } else {
    console.log('No assessmentId found, showing create form')
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

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 16px;
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
  font-family: inherit;
}

.form-textarea {
  resize: vertical;
  min-height: 100px;
  line-height: 1.5;
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

.char-count {
  font-size: 11px;
  color: var(--vp-c-text-3);
  text-align: right;
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
  
  .form-row {
    grid-template-columns: 1fr;
    gap: 16px;
  }
  
  .form-actions {
    flex-direction: column;
  }
}
</style>