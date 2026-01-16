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
        <p class="admin-subtitle">You need administrator privileges to edit leverage strengths.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- Competency Leverage Strengths Editor -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>{{ strengthId ? 'Edit' : 'Create' }} Leverage Strengths</h1>
          <p class="admin-subtitle">{{ strengthId ? 'Update' : 'Create' }} competency leverage strengths in leverage_strengths table</p>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <ActionButton href="/docs/admin/competencies/" variant="gray">Competencies</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>{{ strengthId ? 'Edit' : 'Create' }} Leverage Strengths</span>
      </nav>

      <!-- Editor Form -->
      <div class="editor-container">
        <div class="form-card">
          <div class="section-header">
            <div>
              <h2>💪 Leverage Strengths Fields</h2>
              <p class="section-description">Edit fields from the leverage_strengths database table</p>
            </div>
            <div class="table-info">
              <span class="table-badge">competency_leverage_strengths</span>
            </div>
          </div>

          <form @submit.prevent="saveStrength" class="editor-form">
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
              <div class="field-help">Which competency this strength belongs to</div>
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
              <div class="field-help">Assessment level this strength applies to</div>
            </div>

            <!-- Strategy Text (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Strategy Text</span>
                <span class="field-info">strategy_text (text, required)</span>
              </label>
              <textarea 
                v-model="formData.strategy_text"
                rows="6"
                class="form-textarea"
                :class="{ error: errors.strategy_text }"
                placeholder="Describe the leverage strength strategy..."
                required
              ></textarea>
              <div v-if="errors.strategy_text" class="error-message">{{ errors.strategy_text }}</div>
              <div class="field-help">Detailed strategy text for leveraging this strength</div>
            </div>

            <!-- Scoring Tier Selection (Optional) -->
            <div class="form-group">
              <label class="form-label">
                Scoring Tier
                <span class="field-info">scoring_tier_id (foreign key to scoring_tiers, optional)</span>
              </label>
              <select 
                v-model="formData.scoring_tier_id"
                class="form-select"
                :class="{ error: errors.scoring_tier_id }"
              >
                <option value="">Select Scoring Tier (Optional)</option>
                <option v-for="tier in scoringTiers" :key="tier.id" :value="tier.id">
                  {{ tier.tier_name }} ({{ tier.score_min }}-{{ tier.score_max }}%)
                </option>
              </select>
              <div v-if="errors.scoring_tier_id" class="error-message">{{ errors.scoring_tier_id }}</div>
              <div class="field-help">Performance scoring tier for this strength (optional)</div>
            </div>

            <!-- Priority Order (Optional) -->
            <div class="form-group">
              <label class="form-label">
                Priority Order
                <span class="field-info">priority_order (integer, optional)</span>
              </label>
              <input 
                v-model.number="formData.priority_order"
                type="number" 
                min="0"
                max="100"
                class="form-input"
                placeholder="Priority order (0-100)"
              >
              <div class="field-help">Priority order for this strength (0 = highest priority)</div>
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
              <div class="field-help">Whether this strength is shown in assessments</div>
            </div>

            <!-- Metadata (Read-only) -->
            <div v-if="strengthId" class="form-group metadata-group">
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
                @click="saveStrength"
                variant="primary"
                :disabled="saving || !isFormValid"
                :loading="saving"
              >
                {{ strengthId ? 'Update' : 'Create' }} Leverage Strength
              </ActionButton>
            </div>
          </form>
        </div>

        <!-- Related Data Notice -->
        <div class="info-card">
          <div class="info-header">
            <span class="info-icon">💪</span>
            <h3>Related Data</h3>
          </div>
          <div class="info-content">
            <p>This editor only manages the <strong>competency_leverage_strengths</strong> table. To edit related data:</p>
            <ul class="related-links">
              <li><strong>Display Names</strong> → Use the "Display Names" tab in the main competencies interface</li>
              <li><strong>Rich Insights</strong> → Use the "Rich Insights" tab</li>
              <li><strong>Performance Analysis</strong> → Use the "Performance Analysis" tab</li>
              <li><strong>Strategic Actions</strong> → Use the "Strategic Actions" tab</li>
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

// Get strength ID from URL params using client-side approach
const strengthId = computed(() => {
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
const scoringTiers = ref([])

// Form data - matches exact competency_leverage_strengths table schema
const formData = ref({
  id: '',
  competency_id: '',
  framework_id: '',
  assessment_level_id: '',
  scoring_tier_id: '',
  strategy_text: '',
  priority_order: 1,
  sort_order: 1,
  is_active: true,
  created_at: ''
})

// Computed
const isFormValid = computed(() => {
  return formData.value.competency_id && 
         formData.value.framework_id && 
         formData.value.assessment_level_id &&
         formData.value.strategy_text?.trim() &&
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
      
    case 'strategy_text':
      if (!formData.value.strategy_text?.trim()) {
        errors.value.strategy_text = 'Strategy text is required'
      }
      break
  }
}

const validateForm = () => {
  validateField('competency_id')
  validateField('framework_id')
  validateField('assessment_level_id')
  validateField('strategy_text')
  return Object.keys(errors.value).length === 0
}

const loadReferenceData = async () => {
  if (!adminSupabase) return

  try {
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
    }

    // Load scoring tiers
    const { data: tierData, error: tierError } = await adminSupabase
      .from('scoring_tiers')
      .select('id, tier_code, tier_name, score_min, score_max')
      .eq('is_active', true)
      .order('score_min')

    if (tierError) {
      console.error('Error loading scoring tiers:', tierError)
    } else {
      scoringTiers.value = tierData || []
    }
  } catch (error) {
    console.error('Error loading reference data:', error)
  }
}

const loadStrength = async () => {
  if (!strengthId.value || !adminSupabase) return

  try {
    const { data, error } = await adminSupabase
      .from('competency_leverage_strengths')
      .select('*')
      .eq('id', strengthId.value)
      .single()

    if (error) {
      console.error('Error loading strength:', error)
      alert('Error loading strength: ' + error.message)
      return
    }

    if (data) {
      formData.value = {
        id: data.id,
        competency_id: data.competency_id || '',
        framework_id: data.framework_id || '',
        assessment_level_id: data.assessment_level_id || '',
        scoring_tier_id: data.scoring_tier_id || '',
        strategy_text: data.strategy_text || '',
        priority_order: data.priority_order || 1,
        sort_order: data.sort_order || 1,
        is_active: data.is_active !== false,
        created_at: data.created_at
      }
    }
  } catch (error) {
    console.error('Error loading strength:', error)
    alert('Failed to load strength')
  }
}

const saveStrength = async () => {
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
      scoring_tier_id: formData.value.scoring_tier_id || null,
      strategy_text: formData.value.strategy_text.trim(),
      priority_order: formData.value.priority_order || 1,
      sort_order: formData.value.sort_order || 1,
      is_active: formData.value.is_active
    }

    let result
    if (strengthId.value) {
      // Update existing
      const { data, error } = await adminSupabase
        .from('competency_leverage_strengths')
        .update(dbData)
        .eq('id', strengthId.value)
        .select()

      if (error) throw error
      result = data
    } else {
      // Create new
      const { data, error } = await adminSupabase
        .from('competency_leverage_strengths')
        .insert(dbData)
        .select()

      if (error) throw error
      result = data
    }

    alert('Leverage strength saved successfully!')
    goBack()
  } catch (error) {
    console.error('Error saving strength:', error)
    alert('Failed to save strength: ' + error.message)
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
  await loadReferenceData()
  if (strengthId.value) {
    await loadStrength()
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
  min-height: 150px;
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