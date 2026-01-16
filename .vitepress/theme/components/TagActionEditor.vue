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
        <p class="admin-subtitle">You need administrator privileges to edit tag actions.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- Tag Action Editor -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>{{ tagActionId ? 'Edit' : 'Create' }} Tag Action</h1>
          <p class="admin-subtitle">{{ tagActionId ? 'Update' : 'Create' }} tag action in tag_actions table</p>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <ActionButton href="/docs/admin/tags/" variant="gray">Skill Tags</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>{{ tagActionId ? 'Edit' : 'Create' }} Action</span>
      </nav>

      <!-- Editor Form -->
      <div class="editor-container">
        <div class="form-card">
          <div class="section-header">
            <div>
              <h2>🎯 Tag Action Fields</h2>
              <p class="section-description">Edit fields from the tag_actions database table</p>
            </div>
            <div class="table-info">
              <span class="table-badge">tag_actions</span>
            </div>
          </div>

          <form @submit.prevent="saveTagAction" class="editor-form">
            <!-- Skill Tag (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Skill Tag</span>
                <span class="field-info">skill_tag_id (uuid, required)</span>
              </label>
              <select 
                v-model="formData.skill_tag_id"
                class="form-select"
                :class="{ error: errors.skill_tag_id }"
                required
              >
                <option value="">Select Skill Tag</option>
                <option v-for="tag in skillTags" :key="tag.id" :value="tag.id">
                  {{ tag.name }}
                </option>
              </select>
              <div v-if="errors.skill_tag_id" class="error-message">{{ errors.skill_tag_id }}</div>
              <div class="field-help">Which skill tag this action belongs to (unique per skill tag)</div>
            </div>

            <!-- Action Text (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Action Text</span>
                <span class="field-info">action_text (text, required)</span>
              </label>
              <textarea 
                v-model="formData.action_text"
                class="form-textarea"
                :class="{ error: errors.action_text }"
                placeholder="Provide specific actionable steps for developing this skill..."
                rows="8"
                maxlength="2000"
                required
              ></textarea>
              <div class="char-count">{{ formData.action_text?.length || 0 }}/2000 characters</div>
              <div v-if="errors.action_text" class="error-message">{{ errors.action_text }}</div>
              <div class="field-help">Actionable development steps that will be shown to users in assessment results</div>
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
              <div class="field-help">Whether this action is available for assessment results</div>
            </div>

            <!-- Metadata (Read-only) -->
            <div v-if="tagActionId" class="form-group metadata-group">
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
                @click="saveTagAction" 
                variant="primary"
                :disabled="saving || !isFormValid"
              >
                <span v-if="saving" class="spinner"></span>
                <span v-else>{{ tagActionId ? 'Update' : 'Create' }} Tag Action</span>
              </ActionButton>
            </div>
          </form>
        </div>

        <!-- Related Data Notice -->
        <div class="info-card">
          <div class="info-header">
            <span class="info-icon">🎯</span>
            <h3>Tag Action Management</h3>
          </div>
          <div class="info-content">
            <p>Tag actions provide specific, actionable development steps for individual skills in assessment results.</p>
            <ul class="related-links">
              <li><strong>One per skill tag</strong> → Each skill tag has exactly one action (unique constraint)</li>
              <li><strong>Actionable steps</strong> → Specific recommendations users can take to improve</li>
              <li><strong>Development focused</strong> → Practical guidance for skill development</li>
            </ul>
            <p class="info-note">Each action should be specific, measurable, and directly applicable to developing the associated skill.</p>
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

// Get tag action ID from URL params
const tagActionId = computed(() => {
  const id = route.query?.id || route.params?.id || new URLSearchParams(window.location.search).get('id')
  console.log('Tag Action ID from URL:', id)
  return id
})

// Form state
const saving = ref(false)
const errors = ref({})

// Reference data
const skillTags = ref([])

// Form data - using database structure
const formData = ref({
  id: '',
  skill_tag_id: '',
  action_text: '',
  is_active: true,
  created_at: ''
})

// Computed
const isFormValid = computed(() => {
  return formData.value.skill_tag_id && 
         formData.value.action_text?.trim() &&
         Object.keys(errors.value).length === 0
})

// Methods
const validateField = (field) => {
  errors.value = { ...errors.value }
  delete errors.value[field]
  
  switch (field) {
    case 'skill_tag_id':
      if (!formData.value.skill_tag_id) {
        errors.value.skill_tag_id = 'Skill tag is required'
      }
      break
      
    case 'action_text':
      if (!formData.value.action_text?.trim()) {
        errors.value.action_text = 'Action text is required'
      } else if (formData.value.action_text.length > 2000) {
        errors.value.action_text = 'Action text cannot exceed 2000 characters'
      }
      break
  }
}

const validateForm = () => {
  validateField('skill_tag_id')
  validateField('action_text')
  return Object.keys(errors.value).length === 0
}

const loadReferenceData = async () => {
  if (!adminSupabase) return

  try {
    console.log('Loading skill tags...')
    
    const { data: skillTagsData, error: skillTagsError } = await adminSupabase
      .from('skill_tags')
      .select(`
        id, name,
        frameworks!framework_id (
          id, name
        ),
        assessment_levels!assessment_level_id (
          id, level_name
        )
      `)
      .eq('is_active', true)
      .order('name')

    if (skillTagsError) {
      console.error('Error loading skill tags:', skillTagsError)
    } else {
      skillTags.value = skillTagsData || []
      console.log('Loaded skill tags:', skillTags.value.length)
    }

  } catch (error) {
    console.error('Error loading reference data:', error)
  }
}

const loadTagAction = async () => {
  console.log('loadTagAction called with tagActionId:', tagActionId.value)
  
  if (!tagActionId.value || !adminSupabase) {
    console.log('Skipping loadTagAction - missing tagActionId or adminSupabase')
    return
  }

  try {
    console.log('Fetching tag action with ID:', tagActionId.value)
    
    const { data, error } = await adminSupabase
      .from('tag_actions')
      .select(`
        *,
        skill_tags!skill_tag_id (
          id, name
        )
      `)
      .eq('id', tagActionId.value)
      .single()

    console.log('Supabase response:', { data, error })

    if (error) {
      console.error('Error loading tag action:', error)
      alert('Error loading tag action: ' + error.message)
      return
    }

    if (data) {
      console.log('Setting form data with tag action:', data)
      
      formData.value = {
        id: data.id,
        skill_tag_id: data.skill_tag_id || '',
        action_text: data.action_text || '',
        is_active: data.is_active !== false,
        created_at: data.created_at
      }
      console.log('Form data set to:', formData.value)
    } else {
      console.log('No data returned from Supabase')
    }
  } catch (error) {
    console.error('Error loading tag action:', error)
    alert('Failed to load tag action: ' + error.message)
  }
}

const saveTagAction = async () => {
  if (!adminSupabase || saving.value) return
  
  if (!validateForm()) {
    alert('Please fix the errors before saving')
    return
  }

  saving.value = true

  try {
    // Prepare data for database
    const dbData = {
      skill_tag_id: formData.value.skill_tag_id,
      action_text: formData.value.action_text.trim(),
      is_active: formData.value.is_active
    }

    if (tagActionId.value) {
      // Update existing tag action
      const { data, error } = await adminSupabase
        .from('tag_actions')
        .update(dbData)
        .eq('id', tagActionId.value)
        .select()

      if (error) throw error
      console.log('Updated tag action:', data)
    } else {
      // Create new tag action
      const { data, error } = await adminSupabase
        .from('tag_actions')
        .insert(dbData)
        .select()

      if (error) throw error
      console.log('Created tag action:', data)
    }

    alert('Tag action saved successfully!')
    goBack()
  } catch (error) {
    console.error('Error saving tag action:', error)
    
    // Handle unique constraint violation
    if (error.code === '23505' && error.message.includes('tag_actions_skill_tag_id_key')) {
      alert('A tag action already exists for this skill tag. Each skill tag can only have one action.')
    } else {
      alert('Failed to save tag action: ' + error.message)
    }
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
  console.log('Tag Action ID on mount:', tagActionId.value)
  
  await loadReferenceData()
  
  if (tagActionId.value) {
    console.log('TagActionId found, loading tag action...')
    await loadTagAction()
  } else {
    console.log('No tagActionId found, showing create form')
  }
})
</script>

<style scoped>
/* Use same styles as TagInsightEditor with adjustments */
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

.form-label.required {
  color: var(--vp-c-danger);
  font-weight: 600;
}

.form-label.required::after {
  content: '';
}

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
  min-height: 160px;
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
  
  .form-actions {
    flex-direction: column;
  }
}
</style>