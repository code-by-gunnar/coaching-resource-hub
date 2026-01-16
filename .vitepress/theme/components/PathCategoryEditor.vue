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
        <p class="admin-subtitle">You need administrator privileges to edit path categories.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- Path Category Editor -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>{{ categoryId ? 'Edit' : 'Create' }} Path Category</h1>
          <p class="admin-subtitle">{{ categoryId ? 'Update' : 'Create' }} learning path category in learning_path_categories table</p>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <ActionButton href="/docs/admin/resources/" variant="gray">Learning Resources</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>{{ categoryId ? 'Edit' : 'Create' }} Category</span>
      </nav>

      <!-- Editor Form -->
      <div class="editor-container">
        <div class="form-card">
          <div class="section-header">
            <div>
              <h2>📂 Path Category Fields</h2>
              <p class="section-description">Edit fields from the learning_path_categories database table</p>
            </div>
            <div class="table-info">
              <span class="table-badge">learning_path_categories</span>
            </div>
          </div>

          <form @submit.prevent="saveCategory" class="editor-form">
            <!-- Category Title (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Category Title</span>
                <span class="field-info">category_title (text, required)</span>
              </label>
              <input 
                v-model="formData.category_title"
                type="text" 
                class="form-input"
                :class="{ error: errors.category_title }"
                placeholder="e.g., Core Coaching Skills"
                maxlength="255"
                required
              >
              <div v-if="errors.category_title" class="error-message">{{ errors.category_title }}</div>
              <div class="field-help">The main title of the learning path category</div>
            </div>

            <!-- Category Description (Optional) -->
            <div class="form-group">
              <label class="form-label">
                Description
                <span class="field-info">category_description (text, optional)</span>
              </label>
              <textarea 
                v-model="formData.category_description"
                rows="4"
                class="form-textarea"
                :class="{ error: errors.category_description }"
                placeholder="Describe what this category covers and its learning objectives..."
                maxlength="1000"
              ></textarea>
              <div class="char-count">{{ (formData.category_description || '').length }}/1000</div>
              <div v-if="errors.category_description" class="error-message">{{ errors.category_description }}</div>
              <div class="field-help">Clear description of the category content and purpose</div>
            </div>

            <!-- Category Icon (Optional) -->
            <div class="form-group">
              <label class="form-label">
                Icon
                <span class="field-info">category_icon (text, optional)</span>
              </label>
              
              <div class="icon-selector-container">
                <!-- Current icon display -->
                <div class="current-selection">
                  <div class="current-icon-display">
                    {{ formData.category_icon || '❓' }}
                  </div>
                  <div class="current-icon-info">
                    <span class="selected-label">Selected Icon</span>
                    <span class="selected-name">
                      {{ getIconName(formData.category_icon) || 'Click an icon below to select' }}
                    </span>
                  </div>
                </div>

                <!-- Icon picker grid -->
                <div class="icon-picker">
                  <div class="icon-grid">
                    <button 
                      v-for="icon in commonIcons" 
                      :key="icon.emoji"
                      type="button"
                      @click="selectIcon(icon.emoji)"
                      :class="['icon-option', { selected: formData.category_icon === icon.emoji }]"
                      :title="icon.name"
                    >
                      {{ icon.emoji }}
                    </button>
                  </div>
                </div>
              </div>

              <div v-if="errors.category_icon" class="error-message">{{ errors.category_icon }}</div>
              <div class="field-help">Choose an icon to represent this category visually</div>
            </div>

            <!-- Competency Areas (Optional) -->
            <div class="form-group">
              <label class="form-label">
                Competency Areas
                <span class="field-info">competency_areas (text[], optional)</span>
              </label>
              <div class="competency-selector">
                <div class="available-competencies">
                  <h4>Available Competencies:</h4>
                  <div class="competency-chips">
                    <button 
                      v-for="comp in availableCompetencies" 
                      :key="comp.id"
                      type="button"
                      @click="toggleCompetency(comp.display_name)"
                      :class="['competency-chip', { selected: formData.competency_areas && formData.competency_areas.includes(comp.display_name) }]"
                    >
                      {{ comp.display_name }}
                      <span v-if="formData.competency_areas && formData.competency_areas.includes(comp.display_name)" class="check">✓</span>
                    </button>
                  </div>
                </div>
                <div v-if="formData.competency_areas && formData.competency_areas.length" class="selected-competencies">
                  <h4>Selected ({{ formData.competency_areas.length }}):</h4>
                  <div class="selected-list">
                    <span v-for="compName in formData.competency_areas" :key="compName" class="selected-tag">
                      {{ compName }}
                      <button type="button" @click="removeCompetency(compName)" class="remove-btn">×</button>
                    </span>
                  </div>
                </div>
              </div>
              <div class="field-help">Which competency areas this category focuses on</div>
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
              <div class="field-help">Target assessment level for this category from assessment_levels table</div>
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
                class="form-input"
                :class="{ error: errors.priority_order }"
                placeholder="0"
                min="0"
                max="999"
              >
              <div v-if="errors.priority_order" class="error-message">{{ errors.priority_order }}</div>
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
              <div class="field-help">Whether this category is available to users</div>
            </div>

            <!-- Metadata (Read-only) -->
            <div v-if="categoryId" class="form-group metadata-group">
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
                @click="saveCategory" 
                variant="primary"
                :disabled="saving || !isFormValid"
              >
                <span v-if="saving" class="spinner"></span>
                <span v-else>{{ categoryId ? 'Update' : 'Create' }} Category</span>
              </ActionButton>
            </div>
          </form>
        </div>

        <!-- Related Data Notice -->
        <div class="info-card">
          <div class="info-header">
            <span class="info-icon">📂</span>
            <h3>Category Management</h3>
          </div>
          <div class="info-content">
            <p>Path categories organize learning resources into logical groups for easier navigation.</p>
            <ul class="related-links">
              <li><strong>Learning Resources</strong> → Reference this category via category_id</li>
              <li><strong>Competency Areas</strong> → Use display names from competency_display_names table</li>
            </ul>
            <p class="info-note">Categories help users find relevant content based on their learning path.</p>
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

// Get category ID from URL params
const categoryId = computed(() => {
  const id = route.query?.id || route.params?.id || new URLSearchParams(window.location.search).get('id')
  console.log('Category ID from URL:', id)
  return id
})

// Form state
const saving = ref(false)
const errors = ref({})

// Dynamic data loaded from database
const availableCompetencies = ref([])
const assessmentLevels = ref([])

// Common icons for categories
const commonIcons = [
  { emoji: '📚', name: 'Books/Learning' },
  { emoji: '🗣️', name: 'Communication' },
  { emoji: '🧘', name: 'Mindfulness/Presence' },
  { emoji: '💬', name: 'Conversation' },
  { emoji: '👂', name: 'Listening' },
  { emoji: '❓', name: 'Questions' },
  { emoji: '🎯', name: 'Goals/Focus' },
  { emoji: '🔍', name: 'Discovery/Exploration' },
  { emoji: '💡', name: 'Ideas/Insight' },
  { emoji: '🌟', name: 'Excellence/Growth' },
  { emoji: '🤝', name: 'Partnership' },
  { emoji: '⚖️', name: 'Balance' },
  { emoji: '🚀', name: 'Action/Progress' },
  { emoji: '🧠', name: 'Thinking/Mind' },
  { emoji: '❤️', name: 'Heart/Emotion' },
  { emoji: '🎨', name: 'Creativity' },
  { emoji: '⭐', name: 'Star/Quality' },
  { emoji: '🔑', name: 'Key/Essential' },
  { emoji: '🌱', name: 'Growth/Development' },
  { emoji: '🏆', name: 'Achievement' }
]

// Form data - using database structure
const formData = ref({
  id: '',
  category_title: '',
  category_description: '',
  category_icon: '',
  competency_areas: [], // Array of competency display names
  assessment_level_id: '', // Foreign key to assessment_levels table
  priority_order: 0,
  is_active: true,
  created_at: ''
})

// Computed
const isFormValid = computed(() => {
  return formData.value.category_title && 
         Object.keys(errors.value).length === 0
})

// Methods
const validateField = (field) => {
  errors.value = { ...errors.value }
  delete errors.value[field]
  
  switch (field) {
    case 'category_title':
      if (!formData.value.category_title?.trim()) {
        errors.value.category_title = 'Category title is required'
      }
      break
      
    case 'priority_order':
      const order = formData.value.priority_order
      if (order !== null && order !== undefined && (order < 0 || order > 999)) {
        errors.value.priority_order = 'Priority order must be between 0 and 999'
      }
      break
  }
}

const validateForm = () => {
  validateField('category_title')
  validateField('priority_order')
  return Object.keys(errors.value).length === 0
}

const toggleCompetency = (competencyName) => {
  if (!formData.value.competency_areas) {
    formData.value.competency_areas = []
  }
  const index = formData.value.competency_areas.indexOf(competencyName)
  if (index > -1) {
    formData.value.competency_areas.splice(index, 1)
  } else {
    formData.value.competency_areas.push(competencyName)
  }
}

const removeCompetency = (competencyName) => {
  const index = formData.value.competency_areas.indexOf(competencyName)
  if (index > -1) {
    formData.value.competency_areas.splice(index, 1)
  }
}

const selectIcon = (emoji) => {
  formData.value.category_icon = emoji
}

const getIconName = (emoji) => {
  const icon = commonIcons.find(icon => icon.emoji === emoji)
  return icon ? icon.name : null
}

const loadReferenceData = async () => {
  if (!adminSupabase) return

  try {
    console.log('Loading reference data...')
    
    // Load competencies and assessment levels in parallel
    const [competenciesResult, levelsResult] = await Promise.all([
      adminSupabase
        .from('competency_display_names')
        .select('id, display_name')
        .eq('is_active', true)
        .order('display_name'),
      adminSupabase
        .from('assessment_levels')
        .select('id, level_code, level_name')
        .eq('is_active', true)
        .order('level_name')
    ])

    if (competenciesResult.error) {
      console.error('Error loading competencies:', competenciesResult.error)
    } else {
      availableCompetencies.value = competenciesResult.data || []
      console.log('Loaded competencies:', availableCompetencies.value.length)
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

const loadCategory = async () => {
  console.log('loadCategory called with categoryId:', categoryId.value)
  
  if (!categoryId.value || !adminSupabase) {
    console.log('Skipping loadCategory - missing categoryId or adminSupabase')
    return
  }

  try {
    console.log('Fetching category with ID:', categoryId.value)
    
    const { data, error } = await adminSupabase
      .from('learning_path_categories')
      .select(`
        *,
        assessment_levels!assessment_level_id (
          id, level_code, level_name
        )
      `)
      .eq('id', categoryId.value)
      .single()

    console.log('Supabase response:', { data, error })

    if (error) {
      console.error('Error loading category:', error)
      alert('Error loading category: ' + error.message)
      return
    }

    if (data) {
      console.log('Setting form data with category:', data)
      
      formData.value = {
        id: data.id,
        category_title: data.category_title || '',
        category_description: data.category_description || '',
        category_icon: data.category_icon || '',
        competency_areas: Array.isArray(data.competency_areas) ? data.competency_areas : [],
        assessment_level_id: data.assessment_level_id || '',
        priority_order: data.priority_order || 0,
        is_active: data.is_active !== false,
        created_at: data.created_at
      }
      console.log('Form data set to:', formData.value)
    } else {
      console.log('No data returned from Supabase')
    }
  } catch (error) {
    console.error('Error loading category:', error)
    alert('Failed to load category: ' + error.message)
  }
}

const saveCategory = async () => {
  if (!adminSupabase || saving.value) return
  
  if (!validateForm()) {
    alert('Please fix the errors before saving')
    return
  }

  saving.value = true

  try {
    // Prepare data for database
    const dbData = {
      category_title: formData.value.category_title.trim(),
      category_description: formData.value.category_description?.trim() || null,
      category_icon: formData.value.category_icon?.trim() || null,
      competency_areas: formData.value.competency_areas.length > 0 ? formData.value.competency_areas : null,
      assessment_level_id: formData.value.assessment_level_id || null,
      priority_order: formData.value.priority_order || 0,
      is_active: formData.value.is_active
    }

    if (categoryId.value) {
      // Update existing category
      const { data, error } = await adminSupabase
        .from('learning_path_categories')
        .update(dbData)
        .eq('id', categoryId.value)
        .select()

      if (error) throw error
      console.log('Updated category:', data)
    } else {
      // Create new category
      const { data, error } = await adminSupabase
        .from('learning_path_categories')
        .insert(dbData)
        .select()

      if (error) throw error
      console.log('Created category:', data)
    }

    alert('Path category saved successfully!')
    goBack()
  } catch (error) {
    console.error('Error saving category:', error)
    alert('Failed to save category: ' + error.message)
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
  console.log('Category ID on mount:', categoryId.value)
  
  await loadReferenceData()
  
  if (categoryId.value) {
    console.log('CategoryId found, loading category...')
    await loadCategory()
  } else {
    console.log('No categoryId found, showing create form')
  }
})
</script>

<style scoped>
/* Use same styles as LearningResourceEditor.vue */
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

/* Icon Selector */
.icon-selector-container {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.current-selection {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 12px;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
}

.current-icon-display {
  width: 56px;
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  background: var(--vp-c-bg);
  border: 2px solid var(--vp-c-border);
  border-radius: 8px;
  flex-shrink: 0;
}

.current-icon-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.selected-label {
  font-size: 12px;
  font-weight: 500;
  color: var(--vp-c-text-2);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.selected-name {
  font-size: 14px;
  color: var(--vp-c-text-1);
  font-weight: 500;
}

.icon-picker {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  padding: 16px;
}

.icon-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(48px, 1fr));
  gap: 8px;
  max-height: 200px;
  overflow-y: auto;
}

.icon-option {
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  background: var(--vp-c-bg-soft);
  border: 2px solid var(--vp-c-border);
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
}

.icon-option:hover {
  background: var(--vp-c-brand-soft);
  border-color: var(--vp-c-brand);
  transform: scale(1.05);
}

.icon-option.selected {
  background: var(--vp-c-brand);
  border-color: var(--vp-c-brand);
  color: white;
  transform: scale(1.1);
}

.icon-option:active {
  transform: scale(0.95);
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