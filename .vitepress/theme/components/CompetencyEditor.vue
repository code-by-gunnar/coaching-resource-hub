<template>
  <div class="competency-editor">
    <!-- Admin Access Check -->
    <div v-if="!hasAdminAccess" class="admin-access-required">
      <div class="access-message">
        <h1>⚠️ Admin Access Required</h1>
        <p>You need administrator privileges to edit competencies.</p>
        <a href="/docs/admin/" class="back-link">← Back to Admin Hub</a>
      </div>
    </div>

    <!-- Loading State -->
    <div v-else-if="isInitializing" class="loading-state">
      <div class="loading-content">
        <div class="spinner"></div>
        <p>Loading competency editor...</p>
      </div>
    </div>

    <!-- Main Editor -->
    <div v-else>
      <!-- Page Header -->
      <div class="page-header">
        <div class="page-title-section">
          <nav class="breadcrumb">
            <a href="/docs/admin/" class="breadcrumb-link">Admin Hub</a>
            <span class="breadcrumb-separator">→</span>
            <a href="/docs/admin/competencies/" class="breadcrumb-link">Competencies</a>
            <span class="breadcrumb-separator">→</span>
            <span class="breadcrumb-current">{{ competencyId ? 'Edit' : 'Create' }} Competency</span>
          </nav>
          
          <div class="title-group">
            <h1 class="page-title">
              <span class="title-icon">{{ competencyId ? '✏️' : '➕' }}</span>
              {{ competencyId ? 'Edit' : 'Create New' }} Competency
            </h1>
            <p class="page-subtitle">
              {{ competencyId ? 'Modify competency details, scoring thresholds, and performance insights' : 'Define a new competency with scoring criteria and feedback messages' }}
            </p>
          </div>
        </div>

        <div class="page-actions">
          <button @click="goBack" class="btn-secondary">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M19 12H6m6-6-6 6 6 6"/>
            </svg>
            Cancel
          </button>
          <button @click="() => { console.log('BUTTON CLICKED!'); saveCompetency(); }" class="btn-primary" :disabled="saving || !isFormValid">
            <span v-if="saving" class="spinner"></span>
            <svg v-else width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/>
              <polyline points="17,21 17,13 7,13 7,21"/>
              <polyline points="7,3 7,8 15,8"/>
            </svg>
            {{ saving ? 'Saving...' : 'Save Competency' }}
          </button>
        </div>
      </div>

      <!-- Main Content -->
      <div class="page-content">
        <!-- Tab Navigation -->
        <div class="tab-navigation">
          <button 
            v-for="tab in tabs" 
            :key="tab.id"
            @click="activeTab = tab.id"
            class="tab-button"
            :class="{ active: activeTab === tab.id }"
          >
            <span class="tab-icon">{{ tab.icon }}</span>
            <span class="tab-label">{{ tab.label }}</span>
            <span v-if="hasTabErrors(tab.id)" class="tab-error">!</span>
          </button>
        </div>

        <!-- Tab Content -->
        <div class="tab-content-container">
          <!-- Basic Information Tab -->
          <div v-show="activeTab === 'basic'" class="tab-content">
            <div class="content-section">
              <div class="section-header">
                <h2 class="section-title">Basic Information</h2>
                <p class="section-description">Define the fundamental details of this competency</p>
              </div>

              <div class="form-layout">
                <div class="form-row">
                  <div class="form-group">
                    <label for="comp-name" class="form-label">
                      <span style="color: #dc2626; font-weight: 600;">Competency Name</span>
                    </label>
                    <input 
                      id="comp-name"
                      v-model="editingCompetency.name" 
                      type="text" 
                      class="form-input" 
                      :class="{ error: validationErrors.name }"
                      placeholder="Enter competency name..."
                      @blur="validateField('name')"
                    >
                    <div v-if="validationErrors.name" class="error-message">{{ validationErrors.name }}</div>
                  </div>

                  <div class="form-group">
                    <label for="comp-framework" class="form-label">
                      <span style="color: #dc2626; font-weight: 600;">Framework</span>
                    </label>
                    <select 
                      id="comp-framework" 
                      v-model="editingCompetency.framework_id" 
                      class="form-select"
                      @change="validateField('framework_id')"
                    >
                      <option value="">Select framework...</option>
                      <option v-for="framework in frameworks" :key="framework.id" :value="framework.id">
                        {{ framework.name }}
                      </option>
                    </select>
                    <div v-if="validationErrors.framework_id" class="error-message">{{ validationErrors.framework_id }}</div>
                  </div>
                </div>

                <div class="form-row">
                  <div class="form-group">
                    <label for="comp-order" class="form-label">
                      Display Order
                      <span class="help-icon" title="Future feature: Controls the order in which competencies appear in lists">ℹ️</span>
                    </label>
                    <input 
                      id="comp-order"
                      v-model.number="editingCompetency.display_order" 
                      type="number" 
                      class="form-input"
                      min="0"
                      placeholder="0"
                    >
                  </div>

                  <div class="form-group">
                    <label class="form-label">Status</label>
                    <div class="toggle-group">
                      <label class="toggle-option" :class="{ active: editingCompetency.is_active }">
                        <input 
                          v-model="editingCompetency.is_active" 
                          type="radio" 
                          :value="true"
                          name="status"
                        >
                        <span class="toggle-text">Active</span>
                      </label>
                      <label class="toggle-option" :class="{ active: !editingCompetency.is_active }">
                        <input 
                          v-model="editingCompetency.is_active" 
                          type="radio" 
                          :value="false"
                          name="status"
                        >
                        <span class="toggle-text">Inactive</span>
                      </label>
                    </div>
                  </div>
                </div>

                <div class="form-group full-width">
                  <label for="comp-description" class="form-label">
                    <span style="color: #dc2626; font-weight: 600;">Description</span>
                  </label>
                  <textarea 
                    id="comp-description"
                    v-model="editingCompetency.description" 
                    rows="4"
                    class="form-textarea" 
                    :class="{ error: validationErrors.description }"
                    placeholder="Describe this competency and what it measures..."
                    @blur="validateField('description')"
                  ></textarea>
                  <div class="field-footer">
                    <div class="char-count">{{ editingCompetency.description?.length || 0 }} / 500</div>
                    <div v-if="validationErrors.description" class="error-message">{{ validationErrors.description }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Rich Insights Tab (PDF) -->
          <div v-show="activeTab === 'insights'" class="tab-content">
            <div class="content-section">
              <div class="section-header">
                <h2 class="section-title">Performance Insights</h2>
                <p class="section-description">Create personalized feedback messages for each performance level</p>
              </div>

              <!-- Nested Tab Navigation for Performance Levels -->
              <div class="insight-tab-navigation">
                <button 
                  @click="activeInsightTab = 'foundational'"
                  class="insight-tab-button"
                  :class="{ active: activeInsightTab === 'foundational' }"
                >
                  <span class="insight-tab-icon">🔵</span>
                  <span class="insight-tab-label">Foundational</span>
                </button>
                <button 
                  @click="activeInsightTab = 'developing'"
                  class="insight-tab-button"
                  :class="{ active: activeInsightTab === 'developing' }"
                >
                  <span class="insight-tab-icon">🟡</span>
                  <span class="insight-tab-label">Developing</span>
                </button>
                <button 
                  @click="activeInsightTab = 'advanced'"
                  class="insight-tab-button"
                  :class="{ active: activeInsightTab === 'advanced' }"
                >
                  <span class="insight-tab-icon">🟢</span>
                  <span class="insight-tab-label">Advanced</span>
                </button>
              </div>

              <!-- Insight Content for Each Performance Level -->
              <div class="insight-level-content">
                <!-- Foundational Level -->
                <div v-show="activeInsightTab === 'foundational'" class="insight-form">
                  <div class="insight-form-grid">
                    <div class="form-group">
                      <label class="form-label">
                        <span style="color: #dc2626; font-weight: 600;">Primary Insight</span>
                      </label>
                      <textarea 
                        v-model="editingInsights.foundational.primary_insight"
                        rows="3"
                        class="form-textarea"
                        placeholder="The main insight or message for foundational level performance..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Coaching Impact</label>
                      <textarea 
                        v-model="editingInsights.foundational.coaching_impact"
                        rows="3"
                        class="form-textarea"
                        placeholder="How this performance level impacts coaching effectiveness..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Key Observation</label>
                      <textarea 
                        v-model="editingInsights.foundational.key_observation"
                        rows="3"
                        class="form-textarea"
                        placeholder="Key behavioral patterns or observations at this level..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Development Focus</label>
                      <textarea 
                        v-model="editingInsights.foundational.development_focus"
                        rows="3"
                        class="form-textarea"
                        placeholder="Primary areas to focus development efforts..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Practice Recommendation</label>
                      <textarea 
                        v-model="editingInsights.foundational.practice_recommendation"
                        rows="3"
                        class="form-textarea"
                        placeholder="Specific exercises or practices to improve..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Growth Pathway</label>
                      <textarea 
                        v-model="editingInsights.foundational.growth_pathway"
                        rows="3"
                        class="form-textarea"
                        placeholder="Suggested progression path to next level..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Practical Application</label>
                      <textarea 
                        v-model="editingInsights.foundational.practical_application"
                        rows="3"
                        class="form-textarea"
                        placeholder="Real-world application tips and scenarios..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Supervision Focus</label>
                      <textarea 
                        v-model="editingInsights.foundational.supervision_focus"
                        rows="3"
                        class="form-textarea"
                        placeholder="What supervisors should focus on for this level..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Learning Approach</label>
                      <textarea 
                        v-model="editingInsights.foundational.learning_approach"
                        rows="3"
                        class="form-textarea"
                        placeholder="Recommended learning methods and resources..."
                      ></textarea>
                    </div>
                  </div>
                </div>

                <!-- Developing Level -->
                <div v-show="activeInsightTab === 'developing'" class="insight-form">
                  <div class="insight-form-grid">
                    <div class="form-group">
                      <label class="form-label">
                        <span style="color: #dc2626; font-weight: 600;">Primary Insight</span>
                      </label>
                      <textarea 
                        v-model="editingInsights.developing.primary_insight"
                        rows="3"
                        class="form-textarea"
                        placeholder="The main insight or message for developing level performance..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Coaching Impact</label>
                      <textarea 
                        v-model="editingInsights.developing.coaching_impact"
                        rows="3"
                        class="form-textarea"
                        placeholder="How this performance level impacts coaching effectiveness..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Key Observation</label>
                      <textarea 
                        v-model="editingInsights.developing.key_observation"
                        rows="3"
                        class="form-textarea"
                        placeholder="Key behavioral patterns or observations at this level..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Development Focus</label>
                      <textarea 
                        v-model="editingInsights.developing.development_focus"
                        rows="3"
                        class="form-textarea"
                        placeholder="Primary areas to focus development efforts..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Practice Recommendation</label>
                      <textarea 
                        v-model="editingInsights.developing.practice_recommendation"
                        rows="3"
                        class="form-textarea"
                        placeholder="Specific exercises or practices to improve..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Growth Pathway</label>
                      <textarea 
                        v-model="editingInsights.developing.growth_pathway"
                        rows="3"
                        class="form-textarea"
                        placeholder="Suggested progression path to next level..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Practical Application</label>
                      <textarea 
                        v-model="editingInsights.developing.practical_application"
                        rows="3"
                        class="form-textarea"
                        placeholder="Real-world application tips and scenarios..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Supervision Focus</label>
                      <textarea 
                        v-model="editingInsights.developing.supervision_focus"
                        rows="3"
                        class="form-textarea"
                        placeholder="What supervisors should focus on for this level..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Learning Approach</label>
                      <textarea 
                        v-model="editingInsights.developing.learning_approach"
                        rows="3"
                        class="form-textarea"
                        placeholder="Recommended learning methods and resources..."
                      ></textarea>
                    </div>
                  </div>
                </div>

                <!-- Advanced Level -->
                <div v-show="activeInsightTab === 'advanced'" class="insight-form">
                  <div class="insight-form-grid">
                    <div class="form-group">
                      <label class="form-label">
                        <span style="color: #dc2626; font-weight: 600;">Primary Insight</span>
                      </label>
                      <textarea 
                        v-model="editingInsights.advanced.primary_insight"
                        rows="3"
                        class="form-textarea"
                        placeholder="The main insight or message for advanced level performance..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Coaching Impact</label>
                      <textarea 
                        v-model="editingInsights.advanced.coaching_impact"
                        rows="3"
                        class="form-textarea"
                        placeholder="How this performance level impacts coaching effectiveness..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Key Observation</label>
                      <textarea 
                        v-model="editingInsights.advanced.key_observation"
                        rows="3"
                        class="form-textarea"
                        placeholder="Key behavioral patterns or observations at this level..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Development Focus</label>
                      <textarea 
                        v-model="editingInsights.advanced.development_focus"
                        rows="3"
                        class="form-textarea"
                        placeholder="Primary areas to focus development efforts..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Practice Recommendation</label>
                      <textarea 
                        v-model="editingInsights.advanced.practice_recommendation"
                        rows="3"
                        class="form-textarea"
                        placeholder="Specific exercises or practices to improve..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Growth Pathway</label>
                      <textarea 
                        v-model="editingInsights.advanced.growth_pathway"
                        rows="3"
                        class="form-textarea"
                        placeholder="Suggested progression path to mastery..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Practical Application</label>
                      <textarea 
                        v-model="editingInsights.advanced.practical_application"
                        rows="3"
                        class="form-textarea"
                        placeholder="Real-world application tips and scenarios..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Supervision Focus</label>
                      <textarea 
                        v-model="editingInsights.advanced.supervision_focus"
                        rows="3"
                        class="form-textarea"
                        placeholder="What supervisors should focus on for this level..."
                      ></textarea>
                    </div>

                    <div class="form-group">
                      <label class="form-label">Learning Approach</label>
                      <textarea 
                        v-model="editingInsights.advanced.learning_approach"
                        rows="3"
                        class="form-textarea"
                        placeholder="Recommended learning methods and resources..."
                      ></textarea>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Tips Section -->
              <div class="tips-section">
                <h3 class="tips-title">💡 Writing Effective Insights</h3>
                <div class="tips-grid">
                  <div class="tip-item">
                    <strong>Be Specific:</strong> Reference exact behaviors, skills, or knowledge areas
                  </div>
                  <div class="tip-item">
                    <strong>Be Actionable:</strong> Provide concrete next steps and improvement strategies
                  </div>
                  <div class="tip-item">
                    <strong>Be Encouraging:</strong> Focus on growth mindset and development opportunities
                  </div>
                  <div class="tip-item">
                    <strong>Be Level-Appropriate:</strong> Match the tone and expectations to the performance level
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuth } from '../composables/useAuth'
import { useSupabase } from '../composables/useSupabase'
import { useAdminSupabase } from '../composables/useAdminSupabase'
import { useAdminSession } from '../composables/useAdminSession'

const { user } = useAuth()
const { supabase } = useSupabase()
const { adminSupabase } = useAdminSupabase()
const { hasAdminAccess } = useAdminSession()

// Get competency ID from URL
const competencyId = ref(null)
const isInitializing = ref(true)

// Try to get ID from URL params
if (typeof window !== 'undefined') {
  const urlParams = new URLSearchParams(window.location.search)
  competencyId.value = urlParams.get('id')
}

// Data
const editingCompetency = ref({
  name: '',
  description: '',
  framework_id: '',
  display_order: 0,
  is_active: true
})

const editingInsights = ref({
  foundational: {
    primary_insight: '',
    coaching_impact: '',
    key_observation: '',
    development_focus: '',
    practice_recommendation: '',
    growth_pathway: '',
    practical_application: '',
    supervision_focus: '',
    learning_approach: ''
  },
  developing: {
    primary_insight: '',
    coaching_impact: '',
    key_observation: '',
    development_focus: '',
    practice_recommendation: '',
    growth_pathway: '',
    practical_application: '',
    supervision_focus: '',
    learning_approach: ''
  },
  advanced: {
    primary_insight: '',
    coaching_impact: '',
    key_observation: '',
    development_focus: '',
    practice_recommendation: '',
    growth_pathway: '',
    practical_application: '',
    supervision_focus: '',
    learning_approach: ''
  }
})

const frameworks = ref([
  { id: 'core', name: 'Core Framework' },
  { id: 'icf', name: 'ICF Framework' },
  { id: 'ac', name: 'AC Framework' }
])

// UI State
const activeTab = ref('basic')
const activeInsightTab = ref('foundational')
const saving = ref(false)
const validationErrors = ref({})

const tabs = [
  { id: 'basic', label: 'Basic Info', icon: 'ℹ️' },
  { id: 'insights', label: 'Rich Insights (PDF)', icon: '💬' }
]

// Computed
const isFormValid = computed(() => {
  return editingCompetency.value.name && 
         editingCompetency.value.description && 
         editingCompetency.value.framework_id &&
         !Object.keys(validationErrors.value).length
})

// Methods
const hasTabErrors = (tabId) => {
  if (tabId === 'basic') {
    return validationErrors.value.name || validationErrors.value.description || validationErrors.value.framework_id
  }
  return false
}

const validateField = (fieldName) => {
  validationErrors.value = { ...validationErrors.value }
  
  if (fieldName === 'name') {
    if (!editingCompetency.value.name) {
      validationErrors.value.name = 'Name is required'
    } else if (editingCompetency.value.name.length < 3) {
      validationErrors.value.name = 'Name must be at least 3 characters'
    } else {
      delete validationErrors.value.name
    }
  }
  
  if (fieldName === 'description') {
    if (!editingCompetency.value.description) {
      validationErrors.value.description = 'Description is required'
    } else if (editingCompetency.value.description.length < 10) {
      validationErrors.value.description = 'Description must be at least 10 characters'
    } else {
      delete validationErrors.value.description
    }
  }

  if (fieldName === 'framework_id') {
    if (!editingCompetency.value.framework_id) {
      validationErrors.value.framework_id = 'Framework is required'
    } else {
      delete validationErrors.value.framework_id
    }
  }
}

const loadCompetency = async () => {
  if (!competencyId.value || !adminSupabase) {
    return
  }

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
      editingCompetency.value = {
        name: data.display_name || '',
        description: data.description || '',
        framework_id: data.framework || '',
        display_order: data.display_order || 0, // Future feature - not in DB yet
        is_active: data.is_active !== false
      }
      console.log('Loaded competency data:', editingCompetency.value)
    }

    // Load insights using proper UUID foreign key relationship
    if (data?.id) {
      console.log('Loading insights for competency ID:', data.id)
      
      const { data: insights, error: insightsError } = await adminSupabase
        .from('competency_rich_insights')
        .select('*')
        .eq('competency_id', data.id)

      if (insightsError) {
        console.warn('Error loading insights:', insightsError)
      } else if (insights && insights.length > 0) {
        console.log('Found insights:', insights.length)
        
        insights.forEach(insight => {
          if (insight.performance_level) {
            const level = insight.performance_level
            if (editingInsights.value[level]) {
              editingInsights.value[level] = {
                primary_insight: insight.primary_insight || '',
                coaching_impact: insight.coaching_impact || '',
                key_observation: insight.key_observation || '',
                development_focus: insight.development_focus || '',
                practice_recommendation: insight.practice_recommendation || '',
                growth_pathway: insight.growth_pathway || '',
                practical_application: insight.practical_application || '',
                supervision_focus: insight.supervision_focus || '',
                learning_approach: insight.learning_approach || ''
              }
            }
          }
        })
        
        console.log('Loaded insights:', editingInsights.value)
      } else {
        console.log('No insights found for competency')
      }
    }

  } catch (error) {
    console.error('Error loading competency:', error)
    alert('Failed to load competency: ' + error.message)
  }
}

const saveCompetency = async () => {
  console.log('🔥 saveCompetency called!')
  console.log('Pre-checks:', { 
    supabase: !!supabase, 
    saving: saving.value, 
    isFormValid: isFormValid.value,
    competencyId: competencyId.value,
    editingCompetency: editingCompetency.value
  })
  
  if (!adminSupabase || saving.value || !isFormValid.value) {
    console.log('❌ Early return due to pre-check failure')
    return
  }
  
  // Validate all fields
  validateField('name')
  validateField('description')  
  validateField('framework_id')
  
  if (!isFormValid.value) {
    console.log('❌ Form validation failed:', validationErrors.value)
    return
  }

  console.log('✅ Starting save process...')
  saving.value = true
  
  try {
    let competencyData
    
    // Map our form data to actual database columns
    const dbData = {
      display_name: editingCompetency.value.name,
      description: editingCompetency.value.description,
      framework: editingCompetency.value.framework_id,
      is_active: editingCompetency.value.is_active
      // Note: display_order not in DB yet
    }
    
    if (competencyId.value) {
      // Update existing competency
      console.log('Attempting to update competency ID:', competencyId.value)
      console.log('Update data:', dbData)
      
      // First, verify the record exists
      const { data: existingRecord, error: readError } = await adminSupabase
        .from('competency_display_names')
        .select('*')
        .eq('id', competencyId.value)
        .single()
      
      if (readError || !existingRecord) {
        throw new Error(`Competency with ID ${competencyId.value} not found`)
      }
      
      // Now update it
      const { data: updateResult, error: updateError } = await adminSupabase
        .from('competency_display_names')
        .update(dbData)
        .eq('id', competencyId.value)
        .select()
      
      console.log('Update result:', { updateResult, updateError })
      
      if (updateError) {
        console.error('Update error details:', updateError)
        throw updateError
      }
      
      // Return the updated record (use the actual result from database)
      competencyData = updateResult && updateResult.length > 0 ? updateResult[0] : { ...existingRecord, ...dbData }
      console.log('Final competency data:', competencyData)
    } else {
      // Create new competency - need to generate competency_key
      const competency_key = editingCompetency.value.name.toLowerCase()
        .replace(/[^a-z0-9\s]/g, '')  // Remove special chars
        .replace(/\s+/g, '_')         // Replace spaces with underscores
        .substring(0, 50)             // Limit length
      
      const createData = {
        ...dbData,
        competency_key: competency_key
      }
      
      const { data, error } = await adminSupabase
        .from('competency_display_names')
        .insert(createData)
        .select()
      
      if (error) throw error
      if (!data || data.length === 0) {
        throw new Error('Failed to create competency')
      }
      competencyData = data[0]  // Get first result instead of using .single()
      console.log('Created competency:', competencyData)
    }

    // Save insights using proper UUID foreign key relationship
    const levels = ['foundational', 'developing', 'advanced']
    
    for (const level of levels) {
      const levelInsights = editingInsights.value[level]
      
      const insightData = {
        competency_id: competencyData.id,  // Use UUID instead of text!
        framework: competencyData.framework,
        difficulty_level: 'beginner',  // Default value from existing data
        performance_level: level,
        primary_insight: levelInsights.primary_insight || '',
        coaching_impact: levelInsights.coaching_impact || '',
        key_observation: levelInsights.key_observation || '',
        development_focus: levelInsights.development_focus || '',
        practice_recommendation: levelInsights.practice_recommendation || '',
        growth_pathway: levelInsights.growth_pathway || '',
        practical_application: levelInsights.practical_application || '',
        supervision_focus: levelInsights.supervision_focus || '',
        learning_approach: levelInsights.learning_approach || '',
        is_active: true,
        sort_order: level === 'foundational' ? 3 : level === 'developing' ? 2 : 1  // Match existing pattern
      }

      // Always create/update insight records (even if empty) for new competencies
      // Try to update existing record first, then insert if it doesn't exist
      const { data: existing, error: checkError } = await adminSupabase
        .from('competency_rich_insights')
        .select('id')
        .eq('competency_id', competencyData.id)  // UUID lookup!
        .eq('difficulty_level', 'beginner')
        .eq('performance_level', level)

      let insightError = null
      if (existing && existing.length > 0 && !checkError) {
        // Update existing record
        const { error } = await adminSupabase
          .from('competency_rich_insights')
          .update(insightData)
          .eq('id', existing[0].id)
        insightError = error
      } else {
        // Insert new record (create placeholder for editing later)
        const { error } = await adminSupabase
          .from('competency_rich_insights')
          .insert(insightData)
        insightError = error
      }
      
      if (insightError) {
        console.warn(`Error saving ${level} insights:`, insightError)
      } else {
        console.log(`Saved ${level} insights for competency ${competencyData.id}`)
      }
    }

    // Redirect back to competencies list
    window.location.href = '/docs/admin/competencies/'
    
  } catch (error) {
    console.error('Error saving competency:', error)
    console.error('Error details:', JSON.stringify(error, null, 2))
    alert('Failed to save competency: ' + (error.message || JSON.stringify(error)))
  } finally {
    saving.value = false
  }
}

const goBack = () => {
  window.location.href = '/docs/admin/competencies/'
}

// Lifecycle
onMounted(async () => {
  // Load competency data if editing
  if (competencyId.value) {
    await loadCompetency()
  }
  
  setTimeout(() => {
    isInitializing.value = false
  }, 500)
})
</script>

<style scoped>
.competency-editor {
  min-height: 100vh;
  background: var(--vp-c-bg);
}

/* Admin Access Required */
.admin-access-required {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  padding: 2rem;
}

.access-message {
  text-align: center;
  max-width: 500px;
}

.access-message h1 {
  font-size: 2rem;
  margin-bottom: 1rem;
  color: var(--vp-c-text-1);
}

.access-message p {
  font-size: 1.1rem;
  color: var(--vp-c-text-2);
  margin-bottom: 2rem;
  line-height: 1.5;
}

.back-link {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  background: var(--vp-c-brand-1);
  color: white;
  text-decoration: none;
  border-radius: 8px;
  font-weight: 600;
  transition: all 0.2s ease;
}

.back-link:hover {
  background: var(--vp-c-brand-2);
  transform: translateY(-1px);
}

/* Loading State */
.loading-state {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  padding: 2rem;
}

.loading-content {
  text-align: center;
}

.loading-content .spinner {
  width: 32px;
  height: 32px;
  border: 3px solid var(--vp-c-border);
  border-top: 3px solid var(--vp-c-brand-1);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 1rem auto;
}

.loading-content p {
  color: var(--vp-c-text-2);
  font-size: 1.1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Page Header */
.page-header {
  background: var(--vp-c-bg-soft);
  border-bottom: 1px solid var(--vp-c-border);
  padding: 2rem 3rem;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 2rem;
}

.page-title-section {
  flex: 1;
}

.breadcrumb {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
  font-size: 0.9rem;
}

.breadcrumb-link {
  color: var(--vp-c-text-2);
  text-decoration: none;
  transition: color 0.2s ease;
}

.breadcrumb-link:hover {
  color: var(--vp-c-brand-1);
}

.breadcrumb-separator {
  color: var(--vp-c-text-3);
}

.breadcrumb-current {
  color: var(--vp-c-text-1);
  font-weight: 500;
}

.title-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.page-title {
  font-size: 2rem;
  font-weight: 600;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  color: var(--vp-c-text-1);
}

.title-icon {
  font-size: 1.5rem;
}

.page-subtitle {
  font-size: 1rem;
  color: var(--vp-c-text-2);
  margin: 0;
  line-height: 1.5;
  max-width: 600px;
}

.page-actions {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.btn-secondary,
.btn-primary {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-weight: 600;
  font-size: 0.95rem;
  cursor: pointer;
  transition: all 0.2s ease;
  border: none;
  min-height: 44px;
}

.btn-secondary {
  background: var(--vp-c-bg);
  color: var(--vp-c-text-2);
  border: 1px solid var(--vp-c-border);
}

.btn-secondary:hover {
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
}

.btn-primary {
  background: var(--vp-c-brand-1);
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: var(--vp-c-brand-2);
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* Main Content */
.page-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 3rem;
}

/* Tab Navigation */
.tab-navigation {
  display: flex;
  border-bottom: 2px solid var(--vp-c-border);
  margin-bottom: 2rem;
  gap: 0.5rem;
}

.tab-button {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 1rem 1.5rem;
  border: none;
  background: none;
  color: var(--vp-c-text-2);
  font-size: 0.95rem;
  font-weight: 500;
  cursor: pointer;
  border-bottom: 3px solid transparent;
  transition: all 0.2s ease;
  position: relative;
}

.tab-button:hover {
  color: var(--vp-c-text-1);
  background: var(--vp-c-bg-soft);
}

.tab-button.active {
  color: var(--vp-c-brand-1);
  border-bottom-color: var(--vp-c-brand-1);
  background: var(--vp-c-brand-soft);
}

.tab-icon {
  font-size: 1.1rem;
}

.tab-error {
  position: absolute;
  top: 0.5rem;
  right: 0.5rem;
  width: 16px;
  height: 16px;
  background: var(--vp-c-danger);
  color: white;
  border-radius: 50%;
  font-size: 0.7rem;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Tab Content */
.tab-content-container {
  min-height: 600px;
}

.tab-content {
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.content-section {
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
  padding: 2rem;
  border: 1px solid var(--vp-c-border);
}

.section-header {
  margin-bottom: 2rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--vp-c-border);
}

.section-title {
  font-size: 1.5rem;
  font-weight: 600;
  margin: 0 0 0.5rem 0;
  color: var(--vp-c-text-1);
}

.section-description {
  font-size: 1rem;
  color: var(--vp-c-text-2);
  margin: 0;
  line-height: 1.5;
}

/* Form Styles */
.form-layout {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-group.full-width {
  grid-column: 1 / -1;
}

.form-label {
  font-weight: 600;
  color: var(--vp-c-text-1);
  font-size: 0.95rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.required {
  color: var(--vp-c-danger);
}

.help-icon {
  font-size: 0.8rem;
  opacity: 0.7;
  cursor: help;
}

.form-input,
.form-select,
.form-textarea {
  padding: 0.75rem;
  border: 2px solid var(--vp-c-border);
  border-radius: 8px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  font-size: 1rem;
  transition: all 0.2s ease;
  font-family: inherit;
}

.form-input:focus,
.form-select:focus,
.form-textarea:focus {
  outline: none;
  border-color: var(--vp-c-brand-1);
  box-shadow: 0 0 0 3px var(--vp-c-brand-soft);
}

.form-input.error,
.form-select.error,
.form-textarea.error {
  border-color: var(--vp-c-danger);
}

.form-textarea {
  resize: vertical;
  line-height: 1.5;
}

.toggle-group {
  display: flex;
  background: var(--vp-c-bg);
  border: 2px solid var(--vp-c-border);
  border-radius: 8px;
  overflow: hidden;
}

.toggle-option {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0.75rem;
  cursor: pointer;
  transition: all 0.2s ease;
}

.toggle-option input {
  display: none;
}

.toggle-option:hover {
  background: var(--vp-c-bg-soft);
}

.toggle-option.active {
  background: var(--vp-c-brand-1);
  color: white;
}

.field-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 0.25rem;
}

.char-count {
  font-size: 0.8rem;
  color: var(--vp-c-text-3);
}

.error-message {
  color: var(--vp-c-danger);
  font-size: 0.85rem;
  margin-top: 0.25rem;
}

/* Threshold Editor */
.threshold-editor {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.threshold-inputs {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
}

.threshold-group {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.threshold-label {
  font-weight: 600;
  color: var(--vp-c-text-1);
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.threshold-indicator {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  flex-shrink: 0;
}

.threshold-label.poor .threshold-indicator {
  background: #dc2626;
}

.threshold-label.good .threshold-indicator {
  background: #059669;
}

.threshold-input-group {
  position: relative;
  display: flex;
  align-items: center;
}

.threshold-input {
  padding: 0.75rem;
  border: 2px solid var(--vp-c-border);
  border-radius: 8px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  font-size: 1rem;
  width: 100px;
  text-align: center;
  font-weight: 600;
}

.input-suffix {
  margin-left: 0.5rem;
  color: var(--vp-c-text-2);
  font-weight: 600;
}

.range-indicator {
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
  background: var(--vp-c-bg);
  padding: 0.5rem;
  border-radius: 6px;
  border: 1px solid var(--vp-c-border);
  text-align: center;
}

/* Threshold Visualization */
.threshold-visualization {
  background: var(--vp-c-bg);
  padding: 1.5rem;
  border-radius: 12px;
  border: 1px solid var(--vp-c-border);
}

.viz-title {
  font-size: 1.1rem;
  font-weight: 600;
  margin: 0 0 1rem 0;
  color: var(--vp-c-text-1);
}

.threshold-bar {
  display: flex;
  height: 60px;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.threshold-segment {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  position: relative;
  transition: all 0.3s ease;
  min-width: 60px;
}

.threshold-segment.poor {
  background: linear-gradient(135deg, #dc2626, #ef4444);
}

.threshold-segment.developing {
  background: linear-gradient(135deg, #f59e0b, #fbbf24);
}

.threshold-segment.strong {
  background: linear-gradient(135deg, #059669, #10b981);
}

.segment-label {
  font-weight: 600;
  font-size: 0.9rem;
  color: white;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
}

.segment-range {
  font-size: 0.7rem;
  color: rgba(255, 255, 255, 0.9);
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
}

/* Insights Editor */
.insights-editor {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.insights-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 2rem;
}

.insight-card {
  background: var(--vp-c-bg);
  border-radius: 12px;
  border: 2px solid var(--vp-c-border);
  overflow: hidden;
}

.insight-card.foundational {
  border-color: #2563eb;
}

.insight-card.developing {
  border-color: #f59e0b;
}

.insight-card.advanced {
  border-color: #059669;
}

.insight-header {
  padding: 1rem 1.5rem;
  background: var(--vp-c-bg-soft);
  border-bottom: 1px solid var(--vp-c-border);
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.insight-icon {
  font-size: 1.2rem;
}

.insight-title {
  font-size: 1rem;
  font-weight: 600;
  margin: 0;
  color: var(--vp-c-text-1);
}

.insight-content {
  padding: 1.5rem;
}

.insight-textarea {
  width: 100%;
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  padding: 0.75rem;
  background: var(--vp-c-bg);
  font-family: inherit;
  font-size: 0.95rem;
  line-height: 1.5;
  resize: vertical;
  min-height: 100px;
}

.insight-footer {
  display: flex;
  justify-content: flex-end;
  margin-top: 0.75rem;
}

/* Insight Tab Navigation */
.insight-tab-navigation {
  display: flex;
  border-bottom: 2px solid var(--vp-c-border);
  margin-bottom: 2rem;
  gap: 0.5rem;
  background: var(--vp-c-bg);
  border-radius: 12px 12px 0 0;
  padding: 0.5rem 0.5rem 0 0.5rem;
}

.insight-tab-button {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  border: none;
  background: none;
  color: var(--vp-c-text-2);
  font-size: 0.9rem;
  font-weight: 500;
  cursor: pointer;
  border-radius: 8px;
  transition: all 0.2s ease;
  position: relative;
}

.insight-tab-button:hover {
  color: var(--vp-c-text-1);
  background: var(--vp-c-bg-soft);
}

.insight-tab-button.active {
  color: var(--vp-c-brand-1);
  background: var(--vp-c-brand-soft);
  font-weight: 600;
}

.insight-tab-icon {
  font-size: 1rem;
}

.insight-tab-label {
  font-size: 0.9rem;
}

/* Insight Level Content */
.insight-level-content {
  background: var(--vp-c-bg);
  border-radius: 0 0 12px 12px;
  padding: 2rem;
  border: 1px solid var(--vp-c-border);
  border-top: none;
}

.insight-form {
  animation: fadeIn 0.3s ease;
}

.insight-form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
}

.insight-form-grid .form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

/* Tips Section */
.tips-section {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-brand-1);
  border-radius: 12px;
  padding: 1.5rem;
  margin-top: 2rem;
}

.tips-title {
  font-size: 1.1rem;
  font-weight: 600;
  margin: 0 0 1rem 0;
  color: var(--vp-c-text-1);
}

.tips-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
}

.tip-item {
  padding: 0.75rem;
  background: var(--vp-c-brand-soft);
  border-radius: 8px;
  font-size: 0.9rem;
  line-height: 1.4;
  color: var(--vp-c-text-1);
}

.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top: 2px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

/* Responsive */
@media (max-width: 768px) {
  .page-header {
    padding: 1.5rem 2rem;
    flex-direction: column;
    align-items: stretch;
    gap: 1.5rem;
  }

  .page-content {
    padding: 1.5rem 2rem;
  }

  .form-row {
    grid-template-columns: 1fr;
    gap: 1rem;
  }

  .threshold-inputs {
    grid-template-columns: 1fr;
  }

  .insights-grid {
    grid-template-columns: 1fr;
  }

  .tips-grid {
    grid-template-columns: 1fr;
  }

  .tab-navigation {
    flex-wrap: wrap;
  }
}

/* Required field styling - now using inline styles for consistency */
</style>