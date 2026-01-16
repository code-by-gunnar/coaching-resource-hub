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
        <h1>� Admin Access Required</h1>
        <p class="admin-subtitle">You need administrator privileges to manage assessment questions.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="�">Back to Admin Hub</ActionButton>
    </div>

    <!-- Assessment Question Editor -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>{{ questionId ? 'Edit' : 'Create' }} Assessment Question</h1>
          <p class="admin-subtitle">{{ questionId ? 'Update' : 'Create' }} question in assessment_questions table</p>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <ActionButton href="/docs/admin/assessments/" variant="gray">Assessments</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>{{ questionId ? 'Edit' : 'Create' }} Question</span>
      </nav>

      <!-- Editor Form -->
      <div class="editor-container">
        <div class="form-card">
          <div class="section-header">
            <div>
              <h2>❓ Assessment Question Fields</h2>
              <p class="section-description">Edit fields from the assessment_questions database table</p>
            </div>
            <div class="table-info">
              <span class="table-badge">assessment_questions</span>
            </div>
          </div>

          <form @submit.prevent="saveQuestion" class="editor-form">
            <!-- Assessment (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Assessment</span>
                <span class="field-info">assessment_id (uuid, required)</span>
              </label>
              <select 
                v-model="formData.assessment_id"
                class="form-select"
                :class="{ error: errors.assessment_id }"
                required
              >
                <option value="">Select Assessment</option>
                <option v-for="assessment in assessments" :key="assessment.id" :value="assessment.id">
                  {{ assessment.title }}
                </option>
              </select>
              <div v-if="errors.assessment_id" class="error-message">{{ errors.assessment_id }}</div>
              <div class="field-help">Which assessment this question belongs to</div>
            </div>

            <!-- Scenario (Optional) -->
            <div class="form-group">
              <label class="form-label">
                Scenario
                <span class="field-info">scenario (text, optional)</span>
              </label>
              <textarea 
                v-model="formData.scenario"
                class="form-textarea"
                :class="{ error: errors.scenario }"
                placeholder="Enter a scenario or context for this question (optional)..."
                rows="3"
                maxlength="500"
              ></textarea>
              <div class="char-count">{{ formData.scenario?.length || 0 }}/500 characters</div>
              <div v-if="errors.scenario" class="error-message">{{ errors.scenario }}</div>
              <div class="field-help">Optional context or scenario that frames the question</div>
            </div>

            <!-- Question Text (Required) -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Question Text</span>
                <span class="field-info">question (text, required)</span>
              </label>
              <textarea 
                v-model="formData.question"
                class="form-textarea"
                :class="{ error: errors.question }"
                placeholder="Enter the question text that will be displayed to users..."
                rows="4"
                maxlength="1000"
                required
              ></textarea>
              <div class="char-count">{{ formData.question?.length || 0 }}/1000 characters</div>
              <div v-if="errors.question" class="error-message">{{ errors.question }}</div>
              <div class="field-help">The question text that users will see during the assessment</div>
            </div>

            <!-- Answer Options with Correct Answer Checkboxes -->
            <div class="form-group">
              <label class="form-label">
                <span style="color: #dc2626; font-weight: 600;">Answer Options</span>
                <span class="field-info">option_a, option_b, option_c, option_d (text, required)</span>
              </label>
              
              <div class="answer-options-vertical">
                <div class="option-item" :class="{ 'correct-option': formData.correct_answer === 1 }">
                  <div class="option-header">
                    <div class="option-label-group">
                      <span class="option-letter">A</span>
                      <label class="option-label">Option A</label>
                    </div>
                    <label class="correct-radio">
                      <input 
                        type="radio" 
                        name="correct_answer" 
                        :value="1"
                        v-model.number="formData.correct_answer"
                        class="radio-input"
                      >
                      <span class="radio-custom"></span>
                      <span class="radio-text">Correct</span>
                    </label>
                  </div>
                  <textarea 
                    v-model="formData.option_a"
                    class="option-textarea"
                    :class="{ error: errors.option_a }"
                    placeholder="Enter the first answer option..."
                    maxlength="300"
                    rows="3"
                    required
                  ></textarea>
                  <div class="option-footer">
                    <div v-if="errors.option_a" class="error-message">{{ errors.option_a }}</div>
                    <div class="char-count">{{ formData.option_a?.length || 0 }}/300</div>
                  </div>
                </div>

                <div class="option-item" :class="{ 'correct-option': formData.correct_answer === 2 }">
                  <div class="option-header">
                    <div class="option-label-group">
                      <span class="option-letter">B</span>
                      <label class="option-label">Option B</label>
                    </div>
                    <label class="correct-radio">
                      <input 
                        type="radio" 
                        name="correct_answer" 
                        :value="2"
                        v-model.number="formData.correct_answer"
                        class="radio-input"
                      >
                      <span class="radio-custom"></span>
                      <span class="radio-text">Correct</span>
                    </label>
                  </div>
                  <textarea 
                    v-model="formData.option_b"
                    class="option-textarea"
                    :class="{ error: errors.option_b }"
                    placeholder="Enter the second answer option..."
                    maxlength="300"
                    rows="3"
                    required
                  ></textarea>
                  <div class="option-footer">
                    <div v-if="errors.option_b" class="error-message">{{ errors.option_b }}</div>
                    <div class="char-count">{{ formData.option_b?.length || 0 }}/300</div>
                  </div>
                </div>

                <div class="option-item" :class="{ 'correct-option': formData.correct_answer === 3 }">
                  <div class="option-header">
                    <div class="option-label-group">
                      <span class="option-letter">C</span>
                      <label class="option-label">Option C</label>
                    </div>
                    <label class="correct-radio">
                      <input 
                        type="radio" 
                        name="correct_answer" 
                        :value="3"
                        v-model.number="formData.correct_answer"
                        class="radio-input"
                      >
                      <span class="radio-custom"></span>
                      <span class="radio-text">Correct</span>
                    </label>
                  </div>
                  <textarea 
                    v-model="formData.option_c"
                    class="option-textarea"
                    :class="{ error: errors.option_c }"
                    placeholder="Enter the third answer option..."
                    maxlength="300"
                    rows="3"
                    required
                  ></textarea>
                  <div class="option-footer">
                    <div v-if="errors.option_c" class="error-message">{{ errors.option_c }}</div>
                    <div class="char-count">{{ formData.option_c?.length || 0 }}/300</div>
                  </div>
                </div>

                <div class="option-item" :class="{ 'correct-option': formData.correct_answer === 4 }">
                  <div class="option-header">
                    <div class="option-label-group">
                      <span class="option-letter">D</span>
                      <label class="option-label">Option D</label>
                    </div>
                    <label class="correct-radio">
                      <input 
                        type="radio" 
                        name="correct_answer" 
                        :value="4"
                        v-model.number="formData.correct_answer"
                        class="radio-input"
                      >
                      <span class="radio-custom"></span>
                      <span class="radio-text">Correct</span>
                    </label>
                  </div>
                  <textarea 
                    v-model="formData.option_d"
                    class="option-textarea"
                    :class="{ error: errors.option_d }"
                    placeholder="Enter the fourth answer option..."
                    maxlength="300"
                    rows="3"
                    required
                  ></textarea>
                  <div class="option-footer">
                    <div v-if="errors.option_d" class="error-message">{{ errors.option_d }}</div>
                    <div class="char-count">{{ formData.option_d?.length || 0 }}/300</div>
                  </div>
                </div>
              </div>
              <div v-if="errors.correct_answer" class="error-message">{{ errors.correct_answer }}</div>
              <div class="field-help">Use radio buttons to mark which option is the correct answer</div>
            </div>

            <!-- Explanation (Optional) -->
            <div class="form-group">
              <label class="form-label">
                Explanation
                <span class="field-info">explanation (text, optional)</span>
              </label>
              <textarea 
                v-model="formData.explanation"
                class="form-textarea"
                :class="{ error: errors.explanation }"
                placeholder="Explain why this answer is correct and how it demonstrates the competency being tested..."
                rows="3"
                maxlength="500"
              ></textarea>
              <div class="char-count">{{ formData.explanation?.length || 0 }}/500 characters</div>
              <div v-if="errors.explanation" class="error-message">{{ errors.explanation }}</div>
              <div class="field-help">Explanation shown to users after completing the assessment</div>
            </div>

            <!-- Competency and Assessment Level Row -->
            <div class="form-row">
              <!-- Competency Area (Required) -->
              <div class="form-group">
                <label class="form-label">
                  <span style="color: #dc2626; font-weight: 600;">Competency Area</span>
                  <span class="field-info">competency_id (uuid, required)</span>
                </label>
                <select 
                  v-model="formData.competency_id"
                  class="form-select"
                  :class="{ error: errors.competency_id }"
                  required
                >
                  <option value="">Select Competency Area</option>
                  <option v-for="competency in competencies" :key="competency.id" :value="competency.id">
                    {{ competency.display_name }}
                  </option>
                </select>
                <div v-if="errors.competency_id" class="error-message">{{ errors.competency_id }}</div>
                <div class="field-help">Which competency area this question tests</div>
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
                <div class="field-help">Target difficulty level for this question</div>
              </div>
            </div>

            <!-- Question Settings Row -->
            <div class="form-row">
              <!-- Question Order -->
              <div class="form-group">
                <label class="form-label">
                  Question Order
                  <span class="field-info">question_order (integer)</span>
                </label>
                <input 
                  v-model.number="formData.question_order"
                  type="number" 
                  class="form-input"
                  :class="{ error: errors.question_order }"
                  placeholder="1"
                  min="1"
                  max="999"
                >
                <div v-if="errors.question_order" class="error-message">{{ errors.question_order }}</div>
              </div>

              <!-- Difficulty Weight -->
              <div class="form-group">
                <label class="form-label">
                  Difficulty Weight
                  <span class="field-info">difficulty_weight (decimal)</span>
                </label>
                <input 
                  v-model.number="formData.difficulty_weight"
                  type="number" 
                  class="form-input"
                  :class="{ error: errors.difficulty_weight }"
                  placeholder="1.0"
                  min="0.1"
                  max="5.0"
                  step="0.1"
                >
                <div v-if="errors.difficulty_weight" class="error-message">{{ errors.difficulty_weight }}</div>
              </div>
            </div>


            <!-- Metadata (Read-only) -->
            <div v-if="questionId" class="form-group metadata-group">
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
                @click="saveQuestion" 
                variant="primary"
                :disabled="saving || !isFormValid"
              >
                <span v-if="saving" class="spinner"></span>
                <span v-else>{{ questionId ? 'Update' : 'Create' }} Question</span>
              </ActionButton>
            </div>
          </form>
        </div>

        <!-- Quick Info Card -->
        <div class="info-card">
          <div class="info-header">
            <span class="info-icon">S</span>
            <h3>Question Management</h3>
          </div>
          <div class="info-content">
            <p>Assessment questions are multiple-choice questions that test specific competency areas.</p>
            <ul class="related-links">
              <li><strong>4 Options</strong> � Each question must have options A, B, C, and D</li>
              <li><strong>Competency</strong> � Links to specific competency areas for scoring</li>
              <li><strong>Difficulty</strong> � Weight affects scoring calculations</li>
              <li><strong>Order</strong> � Controls question sequence in assessments</li>
            </ul>
            <p class="info-note">Questions are used to evaluate users' knowledge and generate personalized assessment results.</p>
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

// Get question ID from URL params
const questionId = computed(() => {
  const id = route.query?.id || route.params?.id || new URLSearchParams(window.location.search).get('id')
  console.log('Question ID from URL:', id)
  return id
})

// Form state
const saving = ref(false)
const errors = ref({})

// Reference data
const assessments = ref([])
const competencies = ref([])
const assessmentLevels = ref([])

// Form data - using database structure
const formData = ref({
  id: '',
  assessment_id: '',
  question: '',
  scenario: '',
  option_a: '',
  option_b: '',
  option_c: '',
  option_d: '',
  correct_answer: '',
  explanation: '',
  competency_id: '',
  assessment_level_id: '',
  question_order: 1,
  difficulty_weight: 1.0,
  is_active: true,
  created_at: '',
  updated_at: ''
})

// Computed
const isFormValid = computed(() => {
  return formData.value.assessment_id && 
         formData.value.question?.trim() &&
         formData.value.option_a?.trim() &&
         formData.value.option_b?.trim() &&
         formData.value.option_c?.trim() &&
         formData.value.option_d?.trim() &&
         formData.value.correct_answer &&
         formData.value.competency_id &&
         Object.keys(errors.value).length === 0
})

// Methods
const validateField = (field) => {
  errors.value = { ...errors.value }
  delete errors.value[field]
  
  switch (field) {
    case 'assessment_id':
      if (!formData.value.assessment_id) {
        errors.value.assessment_id = 'Assessment is required'
      }
      break
      
    case 'question':
      if (!formData.value.question?.trim()) {
        errors.value.question = 'Question text is required'
      } else if (formData.value.question.length > 1000) {
        errors.value.question = 'Question text cannot exceed 1000 characters'
      }
      break
      
    case 'scenario':
      if (formData.value.scenario && formData.value.scenario.length > 500) {
        errors.value.scenario = 'Scenario cannot exceed 500 characters'
      }
      break
      
    case 'option_a':
    case 'option_b':
    case 'option_c':
    case 'option_d':
      if (!formData.value[field]?.trim()) {
        errors.value[field] = `Option ${field.slice(-1).toUpperCase()} is required`
      } else if (formData.value[field].length > 300) {
        errors.value[field] = `Option ${field.slice(-1).toUpperCase()} cannot exceed 300 characters`
      }
      break
      
    case 'correct_answer':
      if (!formData.value.correct_answer) {
        errors.value.correct_answer = 'Correct answer is required'
      } else if (![1, 2, 3, 4].includes(formData.value.correct_answer)) {
        errors.value.correct_answer = 'Correct answer must be 1, 2, 3, or 4'
      }
      break
      
    case 'explanation':
      if (formData.value.explanation && formData.value.explanation.length > 500) {
        errors.value.explanation = 'Explanation cannot exceed 500 characters'
      }
      break
      
    case 'competency_id':
      if (!formData.value.competency_id) {
        errors.value.competency_id = 'Competency area is required'
      }
      break
      
    case 'question_order':
      const order = formData.value.question_order
      if (order !== null && order !== undefined && (order < 1 || order > 999)) {
        errors.value.question_order = 'Question order must be between 1 and 999'
      }
      break
      
    case 'difficulty_weight':
      const weight = formData.value.difficulty_weight
      if (weight !== null && weight !== undefined && (weight < 0.1 || weight > 5.0)) {
        errors.value.difficulty_weight = 'Difficulty weight must be between 0.1 and 5.0'
      }
      break
      
    case 'points_value':
      const points = formData.value.points_value
      if (points !== null && points !== undefined && (points < 1 || points > 10)) {
        errors.value.points_value = 'Points value must be between 1 and 10'
      }
      break
  }
}

const validateForm = () => {
  validateField('assessment_id')
  validateField('question')
  validateField('scenario')
  validateField('option_a')
  validateField('option_b')
  validateField('option_c')
  validateField('option_d')
  validateField('correct_answer')
  validateField('explanation')
  validateField('competency_id')
  validateField('question_order')
  validateField('difficulty_weight')
  return Object.keys(errors.value).length === 0
}

const loadReferenceData = async () => {
  if (!adminSupabase) return

  try {
    console.log('Loading reference data...')
    
    // Load reference data in parallel
    const [assessmentsResult, competenciesResult, levelsResult] = await Promise.all([
      adminSupabase
        .from('assessments')
        .select('id, title, slug')
        .eq('is_active', true)
        .order('title'),
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

    if (assessmentsResult.error) {
      console.error('Error loading assessments:', assessmentsResult.error)
    } else {
      assessments.value = assessmentsResult.data || []
      console.log('Loaded assessments:', assessments.value.length)
    }

    if (competenciesResult.error) {
      console.error('Error loading competencies:', competenciesResult.error)
    } else {
      competencies.value = competenciesResult.data || []
      console.log('Loaded competencies:', competencies.value.length)
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

const loadQuestion = async () => {
  console.log('loadQuestion called with questionId:', questionId.value)
  
  if (!questionId.value || !adminSupabase) {
    console.log('Skipping loadQuestion - missing questionId or adminSupabase')
    return
  }

  try {
    console.log('Fetching question with ID:', questionId.value)
    
    const { data, error } = await adminSupabase
      .from('assessment_questions')
      .select(`
        *,
        assessments!assessment_id (
          id, title, slug
        ),
        competency_display_names!competency_id (
          id, display_name
        ),
        assessment_levels!assessment_level_id (
          id, level_code, level_name
        )
      `)
      .eq('id', questionId.value)
      .single()

    console.log('Supabase response:', { data, error })

    if (error) {
      console.error('Error loading question:', error)
      alert('Error loading question: ' + error.message)
      return
    }

    if (data) {
      console.log('Setting form data with question:', data)
      
      formData.value = {
        id: data.id,
        assessment_id: data.assessment_id || '',
        question: data.question || '',
        scenario: data.scenario || '',
        option_a: data.option_a || '',
        option_b: data.option_b || '',
        option_c: data.option_c || '',
        option_d: data.option_d || '',
        correct_answer: data.correct_answer || '',
        explanation: data.explanation || '',
        competency_id: data.competency_id || '',
        assessment_level_id: data.assessment_level_id || '',
        question_order: data.question_order || 1,
        difficulty_weight: data.difficulty_weight || 1.0,
        is_active: data.is_active !== false,
        created_at: data.created_at,
        updated_at: data.updated_at
      }
      console.log('Form data set to:', formData.value)
    } else {
      console.log('No data returned from Supabase')
    }
  } catch (error) {
    console.error('Error loading question:', error)
    alert('Failed to load question: ' + error.message)
  }
}

const saveQuestion = async () => {
  if (!adminSupabase || saving.value) return
  
  if (!validateForm()) {
    alert('Please fix the errors before saving')
    return
  }

  saving.value = true

  try {
    // Prepare data for database
    const dbData = {
      assessment_id: formData.value.assessment_id,
      question: formData.value.question.trim(),
      scenario: formData.value.scenario?.trim() || null,
      option_a: formData.value.option_a.trim(),
      option_b: formData.value.option_b.trim(),
      option_c: formData.value.option_c.trim(),
      option_d: formData.value.option_d.trim(),
      correct_answer: formData.value.correct_answer,
      correct_answer_option_id: formData.value.correct_answer,
      explanation: formData.value.explanation?.trim() || null,
      competency_id: formData.value.competency_id,
      assessment_level_id: formData.value.assessment_level_id || null,
      question_order: formData.value.question_order || 1,
      difficulty_weight: formData.value.difficulty_weight || 1.0,
      is_active: formData.value.is_active
    }

    if (questionId.value) {
      // Update existing question
      const { data, error } = await adminSupabase
        .from('assessment_questions')
        .update(dbData)
        .eq('id', questionId.value)
        .select()

      if (error) throw error
      console.log('Updated question:', data)
    } else {
      // Create new question
      const { data, error } = await adminSupabase
        .from('assessment_questions')
        .insert(dbData)
        .select()

      if (error) throw error
      console.log('Created question:', data)
    }

    alert('Question saved successfully!')
    goBack()
  } catch (error) {
    console.error('Error saving question:', error)
    alert('Failed to save question: ' + error.message)
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
  console.log('Question ID on mount:', questionId.value)
  
  await loadReferenceData()
  
  if (questionId.value) {
    console.log('QuestionId found, loading question...')
    await loadQuestion()
  } else {
    console.log('No questionId found, showing create form')
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
  grid-template-columns: 1fr 1fr;
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

.answer-options-vertical {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.option-item {
  border: 1px solid var(--vp-c-border);
  border-radius: 12px;
  padding: 20px;
  background: var(--vp-c-bg);
  transition: all 0.2s;
}

.option-item:hover {
  border-color: var(--vp-c-border-hover);
}

.option-item.correct-option {
  border-color: var(--vp-c-brand);
  background: var(--vp-c-brand-soft);
}

.option-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.option-label-group {
  display: flex;
  align-items: center;
  gap: 8px;
}

.option-letter {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  border-radius: 50%;
  font-weight: 600;
  font-size: 14px;
  color: var(--vp-c-text-1);
}

.correct-option .option-letter {
  background: var(--vp-c-brand);
  border-color: var(--vp-c-brand);
  color: white;
}

.option-label {
  font-weight: 500;
  font-size: 14px;
  color: var(--vp-c-text-1);
  margin: 0;
}

.correct-radio {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  user-select: none;
}

.radio-input {
  display: none;
}

.radio-custom {
  width: 18px;
  height: 18px;
  border: 2px solid var(--vp-c-border);
  border-radius: 50%;
  background: var(--vp-c-bg);
  transition: all 0.2s;
  position: relative;
}

.radio-input:checked + .radio-custom {
  border-color: var(--vp-c-brand);
  background: var(--vp-c-brand);
}

.radio-input:checked + .radio-custom::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 6px;
  height: 6px;
  background: white;
  border-radius: 50%;
}

.radio-text {
  font-size: 13px;
  color: var(--vp-c-text-2);
  font-weight: 500;
}

.option-textarea {
  width: 100%;
  min-height: 80px;
  padding: 12px 16px;
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  background: var(--vp-c-bg);
  font-size: 14px;
  line-height: 1.5;
  resize: vertical;
  font-family: inherit;
  transition: border-color 0.2s;
}

.option-textarea:focus {
  outline: none;
  border-color: var(--vp-c-brand);
}

.option-textarea.error {
  border-color: var(--vp-c-danger);
}

.option-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 8px;
  min-height: 20px;
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
  
  .option-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
  
  .correct-checkbox {
    align-self: flex-end;
  }
  
  .form-actions {
    flex-direction: column;
  }
}
</style>