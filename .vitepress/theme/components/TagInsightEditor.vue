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
        <p class="admin-subtitle">You need administrator privileges to edit tag insights.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- Tag Insight Editor -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>{{ tagInsightId ? 'Edit' : 'Create' }} Tag Insight</h1>
          <p class="admin-subtitle">{{ tagInsightId ? 'Update' : 'Create' }} tag insight in tag_insights table</p>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <ActionButton href="/docs/admin/tags/" variant="gray">Skill Tags</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>{{ tagInsightId ? 'Edit' : 'Create' }} Insight</span>
      </nav>

      <!-- Editor Form -->
      <div class="editor-container">
        <div class="form-card">
          <div class="section-header">
            <div>
              <h2>💡 Tag Insight Fields</h2>
              <p class="section-description">Edit fields from the tag_insights database table</p>
            </div>
            <div class="table-info">
              <span class="table-badge">tag_insights</span>
            </div>
          </div>

          <form @submit.prevent="saveTagInsight" class="editor-form">
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
              <div class="field-help">Which skill tag this insight belongs to</div>
            </div>

            <!-- Analysis Type (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Analysis Type</span>
                <span class="field-info">analysis_type_id (uuid, required)</span>
              </label>
              <select 
                v-model="formData.analysis_type_id"
                class="form-select"
                :class="{ error: errors.analysis_type_id }"
                required
              >
                <option value="">Select Analysis Type</option>
                <option v-for="type in analysisTypes" :key="type.id" :value="type.id">
                  {{ type.name }}
                </option>
              </select>
              <div v-if="errors.analysis_type_id" class="error-message">{{ errors.analysis_type_id }}</div>
              <div class="field-help">Whether this is a strength or weakness analysis</div>
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
              <div class="field-help">Specific assessment level this insight applies to (optional)</div>
            </div>

            <!-- Insight Text (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Insight Text</span>
                <span class="field-info">insight_text (text, required)</span>
              </label>
              <textarea 
                v-model="formData.insight_text"
                class="form-textarea"
                :class="{ error: errors.insight_text }"
                placeholder="Provide specific insight text for this skill analysis..."
                rows="6"
                maxlength="2000"
                required
              ></textarea>
              <div class="char-count">{{ formData.insight_text?.length || 0 }}/2000 characters</div>
              <div v-if="errors.insight_text" class="error-message">{{ errors.insight_text }}</div>
              <div class="field-help">The insight text that will be shown to users in assessment results</div>
            </div>

            <!-- Metadata (Read-only) -->
            <div v-if="tagInsightId" class="form-group metadata-group">
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
                @click="saveTagInsight" 
                variant="primary"
                :disabled="saving || !isFormValid"
              >
                <span v-if="saving" class="spinner"></span>
                <span v-else>{{ tagInsightId ? 'Update' : 'Create' }} Tag Insight</span>
              </ActionButton>
            </div>
          </form>
        </div>

        <!-- Related Data Notice -->
        <div class="info-card">
          <div class="info-header">
            <span class="info-icon">💡</span>
            <h3>Tag Insight Management</h3>
          </div>
          <div class="info-content">
            <p>Tag insights provide analysis-specific feedback for individual skills in assessment results.</p>
            <ul class="related-links">
              <li><strong>Strength Analysis</strong> → Positive feedback highlighting what users do well</li>
              <li><strong>Weakness Analysis</strong> → Constructive feedback on areas for improvement</li>
              <li><strong>Assessment Levels</strong> → Can be level-specific or apply to all levels</li>
            </ul>
            <p class="info-note">Each insight should be specific, actionable, and relevant to the selected skill tag and analysis type.</p>
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

// Get tag insight ID from URL params
const tagInsightId = computed(() => {
  const id = route.query?.id || route.params?.id || new URLSearchParams(window.location.search).get('id')
  console.log('Tag Insight ID from URL:', id)
  return id
})

// Form state
const saving = ref(false)
const errors = ref({})

// Reference data
const skillTags = ref([])
const analysisTypes = ref([])
const assessmentLevels = ref([])

// Form data - using database structure
const formData = ref({
  id: '',
  skill_tag_id: '',
  analysis_type_id: '',
  assessment_level_id: '',
  insight_text: '',
  created_at: ''
})

// Computed
const isFormValid = computed(() => {
  return formData.value.skill_tag_id && 
         formData.value.analysis_type_id &&
         formData.value.insight_text?.trim() &&
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
      
    case 'analysis_type_id':
      if (!formData.value.analysis_type_id) {
        errors.value.analysis_type_id = 'Analysis type is required'
      }
      break
      
    case 'insight_text':
      if (!formData.value.insight_text?.trim()) {
        errors.value.insight_text = 'Insight text is required'
      } else if (formData.value.insight_text.length > 2000) {
        errors.value.insight_text = 'Insight text cannot exceed 2000 characters'
      }
      break
  }
}

const validateForm = () => {
  validateField('skill_tag_id')
  validateField('analysis_type_id')
  validateField('insight_text')
  return Object.keys(errors.value).length === 0
}

const loadReferenceData = async () => {
  if (!adminSupabase) return

  try {
    console.log('Loading reference data...')
    
    // Load reference data in parallel
    const [skillTagsResult, analysisTypesResult, levelsResult] = await Promise.all([
      adminSupabase
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
        .order('name'),
      adminSupabase
        .from('analysis_types')
        .select('id, code, name')
        .eq('is_active', true)
        .order('name'),
      adminSupabase
        .from('assessment_levels')
        .select('id, level_code, level_name')
        .eq('is_active', true)
        .order('level_name')
    ])

    if (skillTagsResult.error) {
      console.error('Error loading skill tags:', skillTagsResult.error)
    } else {
      skillTags.value = skillTagsResult.data || []
      console.log('Loaded skill tags:', skillTags.value.length)
    }

    if (analysisTypesResult.error) {
      console.error('Error loading analysis types:', analysisTypesResult.error)
    } else {
      analysisTypes.value = analysisTypesResult.data || []
      console.log('Loaded analysis types:', analysisTypes.value.length)
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

const loadTagInsight = async () => {
  console.log('loadTagInsight called with tagInsightId:', tagInsightId.value)
  
  if (!tagInsightId.value || !adminSupabase) {
    console.log('Skipping loadTagInsight - missing tagInsightId or adminSupabase')
    return
  }

  try {
    console.log('Fetching tag insight with ID:', tagInsightId.value)
    
    const { data, error } = await adminSupabase
      .from('tag_insights')
      .select(`
        *,
        skill_tags!skill_tag_id (
          id, name
        ),
        analysis_types!analysis_type_id (
          id, code, name
        ),
        assessment_levels!assessment_level_id (
          id, level_code, level_name
        )
      `)
      .eq('id', tagInsightId.value)
      .single()

    console.log('Supabase response:', { data, error })

    if (error) {
      console.error('Error loading tag insight:', error)
      alert('Error loading tag insight: ' + error.message)
      return
    }

    if (data) {
      console.log('Setting form data with tag insight:', data)
      
      formData.value = {
        id: data.id,
        skill_tag_id: data.skill_tag_id || '',
        analysis_type_id: data.analysis_type_id || '',
        assessment_level_id: data.assessment_level_id || '',
        insight_text: data.insight_text || '',
        created_at: data.created_at
      }
      console.log('Form data set to:', formData.value)
    } else {
      console.log('No data returned from Supabase')
    }
  } catch (error) {
    console.error('Error loading tag insight:', error)
    alert('Failed to load tag insight: ' + error.message)
  }
}

const saveTagInsight = async () => {
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
      analysis_type_id: formData.value.analysis_type_id,
      assessment_level_id: formData.value.assessment_level_id || null,
      insight_text: formData.value.insight_text.trim()
    }

    if (tagInsightId.value) {
      // Update existing tag insight
      const { data, error } = await adminSupabase
        .from('tag_insights')
        .update(dbData)
        .eq('id', tagInsightId.value)
        .select()

      if (error) throw error
      console.log('Updated tag insight:', data)
    } else {
      // Create new tag insight
      const { data, error } = await adminSupabase
        .from('tag_insights')
        .insert(dbData)
        .select()

      if (error) throw error
      console.log('Created tag insight:', data)
    }

    alert('Tag insight saved successfully!')
    goBack()
  } catch (error) {
    console.error('Error saving tag insight:', error)
    alert('Failed to save tag insight: ' + error.message)
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
  console.log('Tag Insight ID on mount:', tagInsightId.value)
  
  await loadReferenceData()
  
  if (tagInsightId.value) {
    console.log('TagInsightId found, loading tag insight...')
    await loadTagInsight()
  } else {
    console.log('No tagInsightId found, showing create form')
  }
})
</script>

<style scoped>
/* Use same styles as SkillTagEditor with adjustments for text area */
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
  min-height: 120px;
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