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
        <p class="admin-subtitle">You need administrator privileges to edit competency insights.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- Competency Rich Insights Editor -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>{{ insightId ? 'Edit' : 'Create' }} Rich Insights</h1>
          <p class="admin-subtitle">{{ insightId ? 'Update' : 'Create' }} detailed competency insights</p>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <ActionButton href="/docs/admin/competencies/" variant="gray">Competencies</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>{{ insightId ? 'Edit' : 'Create' }} Rich Insights</span>
      </nav>

      <!-- Editor Form -->
      <div class="editor-container">
        <div class="form-card">
          <div class="section-header">
            <div>
              <h2>💡 Rich Insights Fields</h2>
              <p class="section-description">Competency insight data from relational database</p>
            </div>
            <div class="table-info">
              <span class="table-badge">competency_consolidated_insights</span>
            </div>
          </div>

          <form @submit.prevent="saveInsight" class="editor-form">
            <!-- Competency Selection (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Competency</span>
                <span class="field-info">competency_id (foreign key to competency_display_names)</span>
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
              <div class="field-help">Which competency this insight belongs to</div>
            </div>

            <!-- Framework Selection (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Framework</span>
                <span class="field-info">framework_id (foreign key to frameworks)</span>
              </label>
              <select 
                v-model="formData.framework_id"
                class="form-select"
                :class="{ error: errors.framework_id }"
                required
              >
                <option value="">Select Framework</option>
                <option v-for="framework in frameworks" :key="framework.id" :value="framework.id">
                  {{ framework.name }} ({{ framework.code }})
                </option>
              </select>
              <div v-if="errors.framework_id" class="error-message">{{ errors.framework_id }}</div>
              <div class="field-help">Which competency framework this belongs to</div>
            </div>

            <!-- Assessment Level Selection (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Assessment Level</span>
                <span class="field-info">assessment_level_id (foreign key to assessment_levels)</span>
              </label>
              <select 
                v-model="formData.assessment_level_id"
                class="form-select"
                :class="{ error: errors.assessment_level_id }"
                required
              >
                <option value="">Select Assessment Level</option>
                <option v-for="level in assessmentLevels" :key="level.id" :value="level.id">
                  {{ level.level_name }} ({{ level.level_code }})
                </option>
              </select>
              <div v-if="errors.assessment_level_id" class="error-message">{{ errors.assessment_level_id }}</div>
              <div class="field-help">Assessment level this insight applies to</div>
            </div>

            <!-- Analysis Type Selection (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Analysis Type</span>
                <span class="field-info">analysis_type_id (foreign key to analysis_types)</span>
              </label>
              <select 
                v-model="formData.analysis_type_id"
                class="form-select"
                :class="{ error: errors.analysis_type_id }"
                required
              >
                <option value="">Select Analysis Type</option>
                <option v-for="analysisType in analysisTypes" :key="analysisType.id" :value="analysisType.id">
                  {{ analysisType.name }}
                </option>
              </select>
              <div v-if="errors.analysis_type_id" class="error-message">{{ errors.analysis_type_id }}</div>
              <div class="field-help">Performance analysis tier this insight targets</div>
            </div>

            <!-- Performance Insight (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Performance Insight</span>
                <span class="field-info">performance_insight (text, required)</span>
              </label>
              <textarea 
                v-model="formData.performance_insight"
                rows="4"
                class="form-textarea"
                :class="{ error: errors.performance_insight }"
                placeholder="Write the performance insight about this competency level..."
                required
              ></textarea>
              <div v-if="errors.performance_insight" class="error-message">{{ errors.performance_insight }}</div>
              <div class="field-help">Main performance insight text for this competency at this level</div>
            </div>

            <!-- Development Focus (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Development Focus</span>
                <span class="field-info">development_focus (text, required)</span>
              </label>
              <textarea 
                v-model="formData.development_focus"
                rows="3"
                class="form-textarea"
                :class="{ error: errors.development_focus }"
                placeholder="Areas for development focus..."
                required
              ></textarea>
              <div v-if="errors.development_focus" class="error-message">{{ errors.development_focus }}</div>
              <div class="field-help">Key areas for development and growth</div>
            </div>

            <!-- Practical Application (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Practical Application</span>
                <span class="field-info">practical_application (text, required)</span>
              </label>
              <textarea 
                v-model="formData.practical_application"
                rows="3"
                class="form-textarea"
                :class="{ error: errors.practical_application }"
                placeholder="Real-world application examples..."
                required
              ></textarea>
              <div v-if="errors.practical_application" class="error-message">{{ errors.practical_application }}</div>
              <div class="field-help">Practical examples and applications</div>
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
              <div class="field-help">Whether this insight is shown in assessments</div>
            </div>

            <!-- Metadata (Read-only) -->
            <div v-if="insightId" class="form-group metadata-group">
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
                type="submit" 
                variant="primary"
                :disabled="saving || !isFormValid"
                :icon="saving ? '⏳' : (insightId ? '💾' : '➕')"
              >
                <span v-if="saving">Saving...</span>
                <span v-else>{{ insightId ? 'Update' : 'Create' }} Rich Insight</span>
              </ActionButton>
            </div>
          </form>
        </div>

        <!-- Related Data Notice -->
        <div class="info-card">
          <div class="info-header">
            <span class="info-icon">💡</span>
            <h3>Database Structure</h3>
          </div>
          <div class="info-content">
            <p>This editor uses the relational database structure:</p>
            <ul class="related-links">
              <li><strong>competency_consolidated_insights</strong> → Main table</li>
              <li><strong>competency_display_names</strong> → Competency lookup</li>
              <li><strong>frameworks</strong> → Framework lookup</li>
              <li><strong>assessment_levels</strong> → Level lookup</li>
            </ul>
            <p class="info-note">All data is loaded dynamically from foreign key relationships</p>
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

// Get insight ID from URL params using client-side approach
const insightId = computed(() => {
  if (typeof window !== 'undefined') {
    const urlParams = new URLSearchParams(window.location.search)
    return urlParams.get('id')
  }
  return null
})

// Form state
const saving = ref(false)
const errors = ref({})
const competencies = ref([])
const frameworks = ref([])
const assessmentLevels = ref([])
const analysisTypes = ref([])

// Form data - matches exact database schema
const formData = ref({
  id: '',
  competency_id: '',
  framework_id: '',
  assessment_level_id: '',
  analysis_type_id: '',
  performance_insight: '',
  development_focus: '',
  practical_application: '',
  is_active: true,
  created_at: ''
})

// Computed
const isFormValid = computed(() => {
  return formData.value.competency_id && 
         formData.value.framework_id && 
         formData.value.assessment_level_id &&
         formData.value.analysis_type_id &&
         formData.value.performance_insight &&
         formData.value.development_focus &&
         formData.value.practical_application &&
         Object.keys(errors.value).length === 0
})

// Methods
const validateField = (field) => {
  errors.value = { ...errors.value }
  delete errors.value[field]
  
  switch (field) {
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
      
    case 'analysis_type_id':
      if (!formData.value.analysis_type_id) {
        errors.value.analysis_type_id = 'Analysis type is required'
      }
      break
      
    case 'performance_insight':
      if (!formData.value.performance_insight?.trim()) {
        errors.value.performance_insight = 'Performance insight is required'
      }
      break

    case 'development_focus':
      if (!formData.value.development_focus?.trim()) {
        errors.value.development_focus = 'Development focus is required'
      }
      break

    case 'practical_application':
      if (!formData.value.practical_application?.trim()) {
        errors.value.practical_application = 'Practical application is required'
      }
      break
  }
}

const validateForm = () => {
  errors.value = {}
  validateField('competency_id')
  validateField('framework_id')
  validateField('assessment_level_id')
  validateField('analysis_type_id')
  validateField('performance_insight')
  validateField('development_focus')
  validateField('practical_application')
  return Object.keys(errors.value).length === 0
}

const loadReferenceData = async () => {
  if (!adminSupabase) {
    console.warn('AdminSupabase not available')
    return
  }

  try {
    console.log('Loading reference data...')
    
    // Load competencies
    const { data: compData, error: compError } = await adminSupabase
      .from('competency_display_names')
      .select('id, display_name, framework_id')
      .eq('is_active', true)
      .order('display_name')

    if (compError) {
      console.error('Error loading competencies:', compError)
    } else {
      competencies.value = compData || []
      console.log('Loaded competencies:', competencies.value.length, competencies.value)
    }

    // Load frameworks
    const { data: frameworkData, error: frameworkError } = await adminSupabase
      .from('frameworks')
      .select('id, name, code')
      .eq('is_active', true)
      .order('name')

    if (frameworkError) {
      console.error('Error loading frameworks:', frameworkError)
    } else {
      frameworks.value = frameworkData || []
      console.log('Loaded frameworks:', frameworks.value.length, frameworks.value)
    }

    // Load assessment levels
    const { data: levelData, error: levelError } = await adminSupabase
      .from('assessment_levels')
      .select('id, level_name, level_code')
      .eq('is_active', true)
      .order('level_name')

    if (levelError) {
      console.error('Error loading assessment levels:', levelError)
    } else {
      assessmentLevels.value = levelData || []
      console.log('Loaded assessment levels:', assessmentLevels.value.length, assessmentLevels.value)
    }

    // Load analysis types
    const { data: analysisData, error: analysisError } = await adminSupabase
      .from('analysis_types')
      .select('id, name, code')
      .eq('is_active', true)
      .order('name')

    if (analysisError) {
      console.error('Error loading analysis types:', analysisError)
    } else {
      analysisTypes.value = analysisData || []
      console.log('Loaded analysis types:', analysisTypes.value.length, analysisTypes.value)
    }
  } catch (error) {
    console.error('Error loading reference data:', error)
  }
}

const loadInsight = async () => {
  if (!insightId.value || !adminSupabase) return

  try {
    console.log('Loading insight with ID:', insightId.value)
    
    const { data, error } = await adminSupabase
      .from('competency_consolidated_insights')
      .select('*')
      .eq('id', insightId.value)
      .single()

    if (error) {
      console.error('Error loading insight:', error)
      alert('Error loading insight: ' + error.message)
      return
    }

    if (data) {
      console.log('Raw insight data from database:', data)
      
      formData.value = {
        id: data.id,
        competency_id: data.competency_id || '',
        framework_id: data.framework_id || '',
        assessment_level_id: data.assessment_level_id || '',
        analysis_type_id: data.analysis_type_id || '',
        performance_insight: data.performance_insight || '',
        development_focus: data.development_focus || '',
        practical_application: data.practical_application || '',
        is_active: data.is_active !== false,
        created_at: data.created_at
      }
      
      console.log('Loaded insight data into form:', formData.value)
    } else {
      console.log('No data returned for insight ID:', insightId.value)
    }
  } catch (error) {
    console.error('Error loading insight:', error)
    alert('Failed to load insight')
  }
}

const saveInsight = async () => {
  if (!adminSupabase || saving.value) return
  
  if (!validateForm()) {
    alert('Please fix the errors before saving')
    return
  }

  saving.value = true

  try {
    // Prepare data for database - exact schema match
    const dbData = {
      competency_id: formData.value.competency_id,
      framework_id: formData.value.framework_id,
      assessment_level_id: formData.value.assessment_level_id,
      analysis_type_id: formData.value.analysis_type_id,
      performance_insight: formData.value.performance_insight.trim(),
      development_focus: formData.value.development_focus.trim(),
      practical_application: formData.value.practical_application.trim(),
      is_active: formData.value.is_active
    }

    let result
    if (insightId.value) {
      // Update existing
      const { data, error } = await adminSupabase
        .from('competency_consolidated_insights')
        .update(dbData)
        .eq('id', insightId.value)
        .select()

      if (error) throw error
      result = data
    } else {
      // Create new
      const { data, error } = await adminSupabase
        .from('competency_consolidated_insights')
        .insert(dbData)
        .select()

      if (error) throw error
      result = data
    }

    alert('Rich insight saved successfully!')
    goBack()
  } catch (error) {
    console.error('Error saving insight:', error)
    alert('Failed to save insight: ' + error.message)
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

onMounted(async () => {
  isAuthLoaded.value = true
  console.log('CompetencyRichInsightsEditor mounted')
  console.log('Window location search:', window.location.search)
  console.log('Insight ID computed:', insightId.value)
  console.log('Admin Supabase available:', !!adminSupabase)
  
  await loadReferenceData()
  
  if (insightId.value) {
    console.log('Loading insight because ID is present:', insightId.value)
    await loadInsight()
  } else {
    console.log('No insight ID found, not loading insight data')
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
  min-height: 80px;
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