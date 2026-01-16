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
        <p class="admin-subtitle">You need administrator privileges to edit learning resources.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- Learning Resource Editor -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>{{ resourceId ? 'Edit' : 'Create' }} Learning Resource</h1>
          <p class="admin-subtitle">{{ resourceId ? 'Update' : 'Create' }} learning resource in learning_resources table</p>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <ActionButton href="/docs/admin/resources/" variant="gray">Learning Resources</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>{{ resourceId ? 'Edit' : 'Create' }} Resource</span>
      </nav>

      <!-- Editor Form -->
      <div class="editor-container">
        <div class="form-card">
          <div class="section-header">
            <div>
              <h2>📖 Learning Resource Fields</h2>
              <p class="section-description">Edit fields from the learning_resources database table</p>
            </div>
            <div class="table-info">
              <span class="table-badge">learning_resources</span>
            </div>
          </div>

          <form @submit.prevent="saveResource" class="editor-form">
            <!-- Title (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Title</span>
                <span class="field-info">title (text, required)</span>
              </label>
              <input 
                v-model="formData.title"
                type="text" 
                class="form-input"
                :class="{ error: errors.title }"
                placeholder="e.g., Co-Active Coaching (Fourth Edition)"
                maxlength="255"
                required
              >
              <div v-if="errors.title" class="error-message">{{ errors.title }}</div>
              <div class="field-help">The main title of the learning resource</div>
            </div>

            <!-- Description (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Description</span>
                <span class="field-info">description (text, required)</span>
              </label>
              <textarea 
                v-model="formData.description"
                rows="4"
                class="form-textarea"
                :class="{ error: errors.description }"
                placeholder="Describe what this resource covers and its learning objectives..."
                maxlength="1000"
                required
              ></textarea>
              <div class="char-count">{{ (formData.description || '').length }}/1000</div>
              <div v-if="errors.description" class="error-message">{{ errors.description }}</div>
              <div class="field-help">Clear description of the resource content and learning outcomes</div>
            </div>

            <!-- Resource Type (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Resource Type</span>
                <span class="field-info">resource_type_id (uuid, required)</span>
              </label>
              <select 
                v-model="formData.resource_type_id"
                class="form-select"
                :class="{ error: errors.resource_type_id }"
                required
              >
                <option value="">Select Type</option>
                <option v-for="type in resourceTypes" :key="type.id" :value="type.id">
                  {{ type.name }}
                </option>
              </select>
              <div v-if="errors.resource_type_id" class="error-message">{{ errors.resource_type_id }}</div>
              <div class="field-help">Type of learning resource from resource_types table</div>
            </div>

            <!-- URL (Optional) -->
            <div class="form-group">
              <label class="form-label">
                URL
                <span class="field-info">url (text, optional)</span>
              </label>
              <input 
                v-model="formData.url"
                type="url" 
                class="form-input"
                :class="{ error: errors.url }"
                placeholder="https://example.com/resource"
                maxlength="500"
              >
              <div v-if="errors.url" class="error-message">{{ errors.url }}</div>
              <div class="field-help">Link to access the resource (if available online)</div>
            </div>

            <!-- Author/Instructor (Optional) -->
            <div class="form-group">
              <label class="form-label">
                Author/Instructor
                <span class="field-info">author_instructor (text, optional)</span>
              </label>
              <input 
                v-model="formData.author_instructor"
                type="text" 
                class="form-input"
                :class="{ error: errors.author_instructor }"
                placeholder="e.g., Laura Whitworth, Karen Kimsey-House"
                maxlength="255"
              >
              <div v-if="errors.author_instructor" class="error-message">{{ errors.author_instructor }}</div>
              <div class="field-help">Creator, author, or instructor of the resource</div>
            </div>

            <!-- Competency Areas (Optional) -->
            <div class="form-group">
              <label class="form-label">
                Competency Areas
                <span class="field-info">competency_areas (array, optional)</span>
              </label>
              <div class="competency-selector">
                <div class="available-competencies">
                  <h4>Available Competencies:</h4>
                  <div class="competency-chips">
                    <button 
                      v-for="comp in availableCompetencies" 
                      :key="comp.id"
                      type="button"
                      @click="toggleCompetency(comp.id)"
                      :class="['competency-chip', { selected: formData.selected_competencies && formData.selected_competencies.includes(comp.id) }]"
                    >
                      {{ comp.display_name }}
                      <span v-if="formData.selected_competencies && formData.selected_competencies.includes(comp.id)" class="check">✓</span>
                    </button>
                  </div>
                </div>
                <div v-if="formData.selected_competencies && formData.selected_competencies.length" class="selected-competencies">
                  <h4>Selected ({{ formData.selected_competencies.length }}):</h4>
                  <div class="selected-list">
                    <span v-for="compId in formData.selected_competencies" :key="compId" class="selected-tag">
                      {{ getCompetencyName(compId) }}
                      <button type="button" @click="removeCompetency(compId)" class="remove-btn">×</button>
                    </span>
                  </div>
                </div>
              </div>
              <div class="field-help">Which competencies this resource helps develop</div>
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
                <option value="">Select Level (Optional)</option>
                <option v-for="level in assessmentLevels" :key="level.id" :value="level.id">
                  {{ level.level_name }}
                </option>
              </select>
              <div v-if="errors.assessment_level_id" class="error-message">{{ errors.assessment_level_id }}</div>
              <div class="field-help">Target assessment level for this resource from assessment_levels table</div>
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
                <option value="">Select Framework (Optional)</option>
                <option v-for="framework in frameworks" :key="framework.id" :value="framework.id">
                  {{ framework.name }}
                </option>
              </select>
              <div v-if="errors.framework_id" class="error-message">{{ errors.framework_id }}</div>
              <div class="field-help">Coaching framework this resource relates to from frameworks table</div>
            </div>

            <!-- Scoring Tier (Optional) -->
            <div class="form-group">
              <label class="form-label">
                Scoring Tier
                <span class="field-info">analysis_type_id (uuid, optional)</span>
              </label>
              <select 
                v-model="formData.analysis_type_id"
                class="form-select"
                :class="{ error: errors.analysis_type_id }"
              >
                <option value="">Select Scoring Tier (Optional)</option>
                <option v-for="analysisType in analysisTypes" :key="analysisType.id" :value="analysisType.id">
                  {{ analysisType.name }}
                </option>
              </select>
              <div v-if="errors.analysis_type_id" class="error-message">{{ errors.analysis_type_id }}</div>
              <div class="field-help">Performance scoring tier this resource targets from analysis_types table</div>
            </div>

            <!-- Category (Optional) -->
            <div class="form-group">
              <label class="form-label">
                Category
                <span class="field-info">category_id (uuid, optional)</span>
              </label>
              <select 
                v-model="formData.category_id"
                class="form-select"
                :class="{ error: errors.category_id }"
              >
                <option value="">Select Category (Optional)</option>
                <option v-for="category in pathCategories" :key="category.id" :value="category.id">
                  {{ category.category_icon }} {{ category.category_title }}
                </option>
              </select>
              <div v-if="errors.category_id" class="error-message">{{ errors.category_id }}</div>
              <div class="field-help">Learning path category this resource belongs to</div>
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
              <div class="field-help">Whether this resource is available to users</div>
            </div>

            <!-- Metadata (Read-only) -->
            <div v-if="resourceId" class="form-group metadata-group">
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
                @click="saveResource" 
                variant="primary"
                :disabled="saving || !isFormValid"
              >
                <span v-if="saving" class="spinner"></span>
                <span v-else>{{ resourceId ? 'Update' : 'Create' }} Resource</span>
              </ActionButton>
            </div>
          </form>
        </div>

        <!-- Related Data Notice -->
        <div class="info-card">
          <div class="info-header">
            <span class="info-icon">📖</span>
            <h3>Related Data</h3>
          </div>
          <div class="info-content">
            <p>This editor only manages the <strong>learning_resources</strong> table. To edit related data:</p>
            <ul class="related-links">
              <li><strong>Path Categories</strong> → Use the "Path Categories" tab in the main resources interface</li>
              <li><strong>Competencies</strong> → Use the competencies management interface</li>
            </ul>
            <p class="info-note">Each table manages its own database structure with dedicated editors.</p>
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

// Get resource ID from URL params
const resourceId = computed(() => {
  // Check both route.query and route.params for the ID
  const id = route.query?.id || route.params?.id || new URLSearchParams(window.location.search).get('id')
  console.log('Resource ID from URL:', id)
  return id
})

// Form state
const saving = ref(false)
const errors = ref({})
const pathCategories = ref([])

// Dynamic data loaded from database
const availableCompetencies = ref([])
const resourceTypes = ref([])
const assessmentLevels = ref([])
const frameworks = ref([])
const analysisTypes = ref([])

// Form data - using proper relational structure
const formData = ref({
  id: '',
  title: '',
  description: '',
  resource_type_id: '', // Foreign key to resource_types table
  url: '',
  author_instructor: '',
  selected_competencies: [], // Array of competency IDs
  assessment_level_id: '', // Foreign key to assessment_levels table
  framework_id: '', // Foreign key to frameworks table
  category_id: '', // Foreign key to learning_path_categories table
  analysis_type_id: '', // Foreign key to analysis_types table (scoring tier)
  is_active: true,
  created_at: ''
})

// Computed
const isFormValid = computed(() => {
  return formData.value.title && 
         formData.value.description && 
         formData.value.resource_type_id &&
         Object.keys(errors.value).length === 0
})

// Methods
const validateField = (field) => {
  errors.value = { ...errors.value }
  delete errors.value[field]
  
  switch (field) {
    case 'title':
      if (!formData.value.title?.trim()) {
        errors.value.title = 'Title is required'
      }
      break
      
    case 'description':
      if (!formData.value.description?.trim()) {
        errors.value.description = 'Description is required'
      }
      break
      
    case 'resource_type_id':
      if (!formData.value.resource_type_id) {
        errors.value.resource_type_id = 'Resource type is required'
      }
      break
      
    case 'url':
      const url = formData.value.url?.trim()
      if (url && !isValidUrl(url)) {
        errors.value.url = 'Please enter a valid URL'
      }
      break
  }
}

const isValidUrl = (string) => {
  try {
    new URL(string)
    return true
  } catch (_) {
    return false
  }
}

const validateForm = () => {
  validateField('title')
  validateField('description')
  validateField('resource_type_id')
  validateField('url')
  return Object.keys(errors.value).length === 0
}

const getCompetencyName = (competencyId) => {
  const comp = availableCompetencies.value.find(c => c.id === competencyId)
  return comp ? comp.display_name : 'Unknown'
}

const toggleCompetency = (competencyId) => {
  const index = formData.value.selected_competencies.indexOf(competencyId)
  if (index > -1) {
    formData.value.selected_competencies.splice(index, 1)
  } else {
    formData.value.selected_competencies.push(competencyId)
  }
}

const removeCompetency = (competencyId) => {
  const index = formData.value.selected_competencies.indexOf(competencyId)
  if (index > -1) {
    formData.value.selected_competencies.splice(index, 1)
  }
}

const loadAllRelationalData = async () => {
  if (!adminSupabase) return

  try {
    console.log('Loading all relational data...')
    
    // Load all reference data in parallel
    const [categoriesResult, resourceTypesResult, assessmentLevelsResult, frameworksResult, competenciesResult, analysisTypesResult] = await Promise.all([
      adminSupabase.from('learning_path_categories').select('id, category_title, category_icon').eq('is_active', true).order('category_title'),
      adminSupabase.from('resource_types').select('id, code, name').eq('is_active', true).order('name'),
      adminSupabase.from('assessment_levels').select('id, level_code, level_name').eq('is_active', true).order('level_name'),
      adminSupabase.from('frameworks').select('id, code, name').eq('is_active', true).order('name'),
      adminSupabase.from('competency_display_names').select('id, display_name').eq('is_active', true).order('display_name'),
      adminSupabase.from('analysis_types').select('id, code, name').eq('is_active', true).order('name')
    ])

    // Handle results
    if (categoriesResult.error) console.error('Categories error:', categoriesResult.error)
    else pathCategories.value = categoriesResult.data || []

    if (resourceTypesResult.error) console.error('Resource types error:', resourceTypesResult.error)
    else resourceTypes.value = resourceTypesResult.data || []

    if (assessmentLevelsResult.error) console.error('Assessment levels error:', assessmentLevelsResult.error)
    else assessmentLevels.value = assessmentLevelsResult.data || []

    if (frameworksResult.error) console.error('Frameworks error:', frameworksResult.error)
    else frameworks.value = frameworksResult.data || []

    if (competenciesResult.error) console.error('Competencies error:', competenciesResult.error)
    else availableCompetencies.value = competenciesResult.data || []

    if (analysisTypesResult.error) console.error('Analysis types error:', analysisTypesResult.error)
    else analysisTypes.value = analysisTypesResult.data || []

    console.log('Loaded data counts:', {
      categories: pathCategories.value.length,
      resourceTypes: resourceTypes.value.length,
      assessmentLevels: assessmentLevels.value.length,
      frameworks: frameworks.value.length,
      competencies: availableCompetencies.value.length,
      analysisTypes: analysisTypes.value.length
    })

  } catch (error) {
    console.error('Error loading relational data:', error)
  }
}

const loadResource = async () => {
  console.log('loadResource called with resourceId:', resourceId.value)
  console.log('adminSupabase available:', !!adminSupabase)
  
  if (!resourceId.value || !adminSupabase) {
    console.log('Skipping loadResource - missing resourceId or adminSupabase')
    return
  }

  try {
    console.log('Fetching resource with ID:', resourceId.value)
    
    // Load resource with related data
    const { data, error } = await adminSupabase
      .from('learning_resources')
      .select(`
        *,
        resource_types!resource_type_id (
          id, code, name
        ),
        assessment_levels!assessment_level_id (
          id, level_code, level_name
        ),
        frameworks!framework_id (
          id, code, name
        ),
        learning_path_categories!category_id (
          id, category_title, category_icon
        ),
        analysis_types!analysis_type_id (
          id, code, name
        )
      `)
      .eq('id', resourceId.value)
      .single()

    console.log('Supabase response:', { data, error })

    if (error) {
      console.error('Error loading resource:', error)
      alert('Error loading resource: ' + error.message)
      return
    }

    if (data) {
      // Load associated competencies from junction table
      const { data: competencyData, error: competencyError } = await adminSupabase
        .from('learning_resource_competencies')
        .select(`
          competency_display_names (
            id, display_name
          )
        `)
        .eq('learning_resource_id', resourceId.value)
      
      const selectedCompetencies = competencyData?.map(item => 
        item.competency_display_names?.id
      ).filter(Boolean) || []

      console.log('Loaded competencies:', selectedCompetencies)
      console.log('Setting form data with resource:', data)
      
      formData.value = {
        id: data.id,
        title: data.title || '',
        description: data.description || '',
        resource_type_id: data.resource_type_id || '',
        url: data.url || '',
        author_instructor: data.author_instructor || '',
        selected_competencies: selectedCompetencies,
        assessment_level_id: data.assessment_level_id || '',
        framework_id: data.framework_id || '',
        category_id: data.category_id || '',
        analysis_type_id: data.analysis_type_id || '',
        is_active: data.is_active !== false,
        created_at: data.created_at
      }
      console.log('Form data set to:', formData.value)
    } else {
      console.log('No data returned from Supabase')
    }
  } catch (error) {
    console.error('Error loading resource:', error)
    alert('Failed to load resource: ' + error.message)
  }
}

const saveResource = async () => {
  if (!adminSupabase || saving.value) return
  
  if (!validateForm()) {
    alert('Please fix the errors before saving')
    return
  }

  saving.value = true

  try {
    // Prepare data for database - using relational structure
    const dbData = {
      title: formData.value.title.trim(),
      description: formData.value.description.trim(),
      resource_type_id: formData.value.resource_type_id || null,
      url: formData.value.url?.trim() || null,
      author_instructor: formData.value.author_instructor?.trim() || null,
      assessment_level_id: formData.value.assessment_level_id || null,
      framework_id: formData.value.framework_id || null,
      category_id: formData.value.category_id || null,
      analysis_type_id: formData.value.analysis_type_id || null,
      is_active: formData.value.is_active
    }

    let savedResourceId = resourceId.value
    
    if (resourceId.value) {
      // Update existing resource
      const { data, error } = await adminSupabase
        .from('learning_resources')
        .update(dbData)
        .eq('id', resourceId.value)
        .select()

      if (error) throw error
      console.log('Updated resource:', data)
    } else {
      // Create new resource
      const { data, error } = await adminSupabase
        .from('learning_resources')
        .insert(dbData)
        .select()

      if (error) throw error
      console.log('Created resource:', data)
      savedResourceId = data[0]?.id
    }

    // Handle competency associations in junction table
    if (savedResourceId && formData.value.selected_competencies) {
      // First, delete existing competency associations
      const { error: deleteError } = await adminSupabase
        .from('learning_resource_competencies')
        .delete()
        .eq('learning_resource_id', savedResourceId)
      
      if (deleteError) {
        console.error('Error deleting existing competencies:', deleteError)
        throw deleteError
      }

      // Then insert new competency associations
      if (formData.value.selected_competencies.length > 0) {
        const competencyInserts = formData.value.selected_competencies.map(competencyId => ({
          learning_resource_id: savedResourceId,
          competency_id: competencyId
        }))

        const { error: insertError } = await adminSupabase
          .from('learning_resource_competencies')
          .insert(competencyInserts)
        
        if (insertError) {
          console.error('Error inserting competencies:', insertError)
          throw insertError
        }
        
        console.log('Updated competency associations:', competencyInserts.length)
      }
    }

    alert('Learning resource saved successfully!')
    goBack()
  } catch (error) {
    console.error('Error saving resource:', error)
    alert('Failed to save resource: ' + error.message)
  } finally {
    saving.value = false
  }
}

const goBack = () => {
  window.location.href = '/docs/admin/resources/'
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
  console.log('Resource ID on mount:', resourceId.value)
  
  await loadAllRelationalData()
  
  if (resourceId.value) {
    console.log('ResourceId found, loading resource...')
    await loadResource()
  } else {
    console.log('No resourceId found, showing create form')
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

/* Competency Selector */
.competency-selector {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding: 16px;
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
}

.competency-selector h4 {
  margin: 0 0 8px 0;
  font-size: 14px;
  font-weight: 500;
}

.competency-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.competency-chip {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 6px 10px;
  border: 1px solid var(--vp-c-border);
  background: var(--vp-c-bg-soft);
  border-radius: 16px;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s;
}

.competency-chip:hover {
  border-color: var(--vp-c-brand);
}

.competency-chip.selected {
  background: var(--vp-c-brand-soft);
  border-color: var(--vp-c-brand);
  color: var(--vp-c-brand);
}

.competency-chip .check {
  font-size: 10px;
  font-weight: bold;
}

.selected-list {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.selected-tag {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 4px 8px;
  background: var(--vp-c-brand);
  color: white;
  border-radius: 4px;
  font-size: 12px;
}

.remove-btn {
  background: none;
  border: none;
  color: white;
  cursor: pointer;
  font-size: 14px;
  line-height: 1;
  padding: 0;
  margin-left: 4px;
}

.remove-btn:hover {
  opacity: 0.7;
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
  
  .competency-selector {
    padding: 12px;
  }
}
</style>