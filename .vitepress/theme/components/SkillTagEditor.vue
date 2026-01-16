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
        <p class="admin-subtitle">You need administrator privileges to edit skill tags.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- Skill Tag Editor -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>{{ skillTagId ? 'Edit' : 'Create' }} Skill Tag</h1>
          <p class="admin-subtitle">{{ skillTagId ? 'Update' : 'Create' }} skill tag in skill_tags table</p>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <ActionButton href="/docs/admin/tags/" variant="gray">Skill Tags</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>{{ skillTagId ? 'Edit' : 'Create' }} Tag</span>
      </nav>

      <!-- Editor Form -->
      <div class="editor-container">
        <div class="form-card">
          <div class="section-header">
            <div>
              <h2>🏷️ Skill Tag Fields</h2>
              <p class="section-description">Edit fields from the skill_tags database table</p>
            </div>
            <div class="table-info">
              <span class="table-badge">skill_tags</span>
            </div>
          </div>

          <form @submit.prevent="saveSkillTag" class="editor-form">
            <!-- Skill Tag Name (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Skill Tag Name</span>
                <span class="field-info">name (text, required)</span>
              </label>
              <input 
                v-model="formData.name"
                type="text" 
                class="form-input"
                :class="{ error: errors.name }"
                placeholder="e.g., Deep Listening"
                maxlength="255"
                required
              >
              <div v-if="errors.name" class="error-message">{{ errors.name }}</div>
              <div class="field-help">The name of the specific skill being assessed</div>
            </div>

            <!-- Competency (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Competency</span>
                <span class="field-info">competency_id (uuid, required)</span>
              </label>
              <select 
                v-model="formData.competency_id"
                class="form-select"
                :class="{ error: errors.competency_id }"
                required
              >
                <option value="">Select Competency</option>
                <option v-for="comp in competencies" :key="comp.id" :value="comp.id">
                  {{ comp.display_name }}
                </option>
              </select>
              <div v-if="errors.competency_id" class="error-message">{{ errors.competency_id }}</div>
              <div class="field-help">Which competency area this skill belongs to</div>
            </div>

            <!-- Framework (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Framework</span>
                <span class="field-info">framework_id (uuid, required)</span>
              </label>
              <select 
                v-model="formData.framework_id"
                class="form-select"
                :class="{ error: errors.framework_id }"
                required
              >
                <option value="">Select Framework</option>
                <option v-for="framework in frameworks" :key="framework.id" :value="framework.id">
                  {{ framework.name }}
                </option>
              </select>
              <div v-if="errors.framework_id" class="error-message">{{ errors.framework_id }}</div>
              <div class="field-help">Which coaching framework this skill belongs to</div>
            </div>

            <!-- Assessment Level (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Assessment Level</span>
                <span class="field-info">assessment_level_id (uuid, required)</span>
              </label>
              <select 
                v-model="formData.assessment_level_id"
                class="form-select"
                :class="{ error: errors.assessment_level_id }"
                required
              >
                <option value="">Select Level</option>
                <option v-for="level in assessmentLevels" :key="level.id" :value="level.id">
                  {{ level.level_name }}
                </option>
              </select>
              <div v-if="errors.assessment_level_id" class="error-message">{{ errors.assessment_level_id }}</div>
              <div class="field-help">Target assessment level for this skill from assessment_levels table</div>
            </div>

            <!-- Sort Order -->
            <div class="form-group">
              <label class="form-label">
                Sort Order
                <span class="field-info">sort_order (integer, optional)</span>
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
              <div class="field-help">Display order (lower numbers appear first)</div>
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
              <div class="field-help">Whether this skill tag is available for assessments</div>
            </div>

            <!-- Metadata (Read-only) -->
            <div v-if="skillTagId" class="form-group metadata-group">
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
              
              <ActionButton 
                @click="saveSkillTag" 
                variant="primary"
                :disabled="saving || !isFormValid"
              >
                <span v-if="saving" class="spinner"></span>
                <span v-else>{{ skillTagId ? 'Update' : 'Create' }} Skill Tag</span>
              </ActionButton>
            </div>
          </form>
        </div>

        <!-- Related Data Notice -->
        <div class="info-card">
          <div class="info-header">
            <span class="info-icon">🏷️</span>
            <h3>Skill Tag Management</h3>
          </div>
          <div class="info-content">
            <p>Skill tags define specific skills that are assessed within competency areas.</p>
            <ul class="related-links">
              <li><strong>Tag Insights</strong> → Weakness and strength insights for this skill</li>
              <li><strong>Tag Actions</strong> → Actionable development steps for this skill</li>
              <li><strong>Assessment Questions</strong> → Questions that assess this skill</li>
            </ul>
            <p class="info-note">Each skill tag should have corresponding insights and actions for complete assessment results.</p>
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

// Get skill tag ID from URL params
const skillTagId = computed(() => {
  const id = route.query?.id || route.params?.id || new URLSearchParams(window.location.search).get('id')
  console.log('Skill Tag ID from URL:', id)
  return id
})

// Form state
const saving = ref(false)
const errors = ref({})

// Reference data
const competencies = ref([])
const frameworks = ref([])
const assessmentLevels = ref([])

// Form data - using database structure
const formData = ref({
  id: '',
  name: '',
  competency_id: '',
  framework_id: '',
  assessment_level_id: '',
  sort_order: 0,
  is_active: true,
  created_at: ''
})

// Computed
const isFormValid = computed(() => {
  return formData.value.name && 
         formData.value.competency_id &&
         formData.value.framework_id &&
         formData.value.assessment_level_id &&
         Object.keys(errors.value).length === 0
})

// Methods
const validateField = (field) => {
  errors.value = { ...errors.value }
  delete errors.value[field]
  
  switch (field) {
    case 'name':
      if (!formData.value.name?.trim()) {
        errors.value.name = 'Skill tag name is required'
      }
      break
      
    case 'competency_id':
      if (!formData.value.competency_id) {
        errors.value.competency_id = 'Competency is required'
      }
      break
      
    case 'framework_id':
      if (!formData.value.framework_id) {
        errors.value.framework_id = 'Framework is required'
      }
      break
      
    case 'assessment_level_id':
      if (!formData.value.assessment_level_id) {
        errors.value.assessment_level_id = 'Assessment level is required'
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
  validateField('name')
  validateField('competency_id')
  validateField('framework_id')
  validateField('assessment_level_id')
  validateField('sort_order')
  return Object.keys(errors.value).length === 0
}

const loadReferenceData = async () => {
  if (!adminSupabase) return

  try {
    console.log('Loading reference data...')
    
    // Load reference data in parallel
    const [competenciesResult, frameworksResult, levelsResult] = await Promise.all([
      adminSupabase
        .from('competency_display_names')
        .select('id, display_name')
        .eq('is_active', true)
        .order('display_name'),
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

    if (competenciesResult.error) {
      console.error('Error loading competencies:', competenciesResult.error)
    } else {
      competencies.value = competenciesResult.data || []
      console.log('Loaded competencies:', competencies.value.length)
    }

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

const loadSkillTag = async () => {
  console.log('loadSkillTag called with skillTagId:', skillTagId.value)
  
  if (!skillTagId.value || !adminSupabase) {
    console.log('Skipping loadSkillTag - missing skillTagId or adminSupabase')
    return
  }

  try {
    console.log('Fetching skill tag with ID:', skillTagId.value)
    
    const { data, error } = await adminSupabase
      .from('skill_tags')
      .select(`
        *,
        competency_display_names!competency_id (
          id, display_name
        ),
        frameworks!framework_id (
          id, name, code
        ),
        assessment_levels!assessment_level_id (
          id, level_code, level_name
        )
      `)
      .eq('id', skillTagId.value)
      .single()

    console.log('Supabase response:', { data, error })

    if (error) {
      console.error('Error loading skill tag:', error)
      alert('Error loading skill tag: ' + error.message)
      return
    }

    if (data) {
      console.log('Setting form data with skill tag:', data)
      
      formData.value = {
        id: data.id,
        name: data.name || '',
        competency_id: data.competency_id || '',
        framework_id: data.framework_id || '',
        assessment_level_id: data.assessment_level_id || '',
        sort_order: data.sort_order || 0,
        is_active: data.is_active !== false,
        created_at: data.created_at
      }
      console.log('Form data set to:', formData.value)
    } else {
      console.log('No data returned from Supabase')
    }
  } catch (error) {
    console.error('Error loading skill tag:', error)
    alert('Failed to load skill tag: ' + error.message)
  }
}

const saveSkillTag = async () => {
  if (!adminSupabase || saving.value) return
  
  if (!validateForm()) {
    alert('Please fix the errors before saving')
    return
  }

  saving.value = true

  try {
    // Prepare data for database
    const dbData = {
      name: formData.value.name.trim(),
      competency_id: formData.value.competency_id,
      framework_id: formData.value.framework_id,
      assessment_level_id: formData.value.assessment_level_id,
      sort_order: formData.value.sort_order || 0,
      is_active: formData.value.is_active
    }

    if (skillTagId.value) {
      // Update existing skill tag
      const { data, error } = await adminSupabase
        .from('skill_tags')
        .update(dbData)
        .eq('id', skillTagId.value)
        .select()

      if (error) throw error
      console.log('Updated skill tag:', data)
    } else {
      // Create new skill tag
      const { data, error } = await adminSupabase
        .from('skill_tags')
        .insert(dbData)
        .select()

      if (error) throw error
      console.log('Created skill tag:', data)
    }

    alert('Skill tag saved successfully!')
    goBack()
  } catch (error) {
    console.error('Error saving skill tag:', error)
    alert('Failed to save skill tag: ' + error.message)
  } finally {
    saving.value = false
  }
}

const goBack = () => {
  window.location.href = '/docs/admin/tags/'
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
  console.log('Skill Tag ID on mount:', skillTagId.value)
  
  await loadReferenceData()
  
  if (skillTagId.value) {
    console.log('SkillTagId found, loading skill tag...')
    await loadSkillTag()
  } else {
    console.log('No skillTagId found, showing create form')
  }
})
</script>

<style scoped>
/* Use same styles as other editor components */
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

/* Required field styling - now using inline styles for consistency */

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
.form-select {
  padding: 10px 14px;
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  background: var(--vp-c-bg);
  font-size: 14px;
  transition: border-color 0.2s;
}

.form-input:focus,
.form-select:focus {
  outline: none;
  border-color: var(--vp-c-brand);
}

.form-input.error,
.form-select.error {
  border-color: var(--vp-c-danger);
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
  
  .form-actions {
    flex-direction: column;
  }
}
</style>