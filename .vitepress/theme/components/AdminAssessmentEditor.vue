<template>
  <div class="admin-assessment-editor-container">
    <!-- Loading state during auth check -->
    <AdminLoadingState v-if="!isAuthLoaded" />

    <!-- Admin Access Check -->
    <div v-else-if="!hasAdminAccess">
      <h2>⚠️ Admin Access Required</h2>
      <p>You need administrator privileges to edit assessments.</p>
      <p><a href="/docs/admin/">← Back to Admin Hub</a></p>
    </div>

    <!-- Loading State -->
    <div v-else-if="loading" class="loading">
      <div class="loading-spinner">⏳</div>
      <p>Loading assessment...</p>
    </div>

    <!-- Assessment Editor -->
    <div v-else-if="assessment">
      <div class="editor-header">
        <div class="header-main">
          <h1>✏️ Edit Assessment</h1>
          <p class="assessment-title">{{ assessment.title }}</p>
        </div>
        
        <div class="header-actions">
          <button @click="saveChanges" class="btn-save" :disabled="saving">
            {{ saving ? 'Saving...' : '💾 Save Changes' }}
          </button>
          <button @click="cancelEdit" class="btn-cancel">
            ❌ Cancel
          </button>
        </div>
      </div>

      <nav class="admin-breadcrumb">
        <a href="/docs/admin/">Admin Hub</a> → 
        <a href="/docs/admin/assessments/">Assessments</a> → 
        Edit
      </nav>

      <!-- Tab Navigation -->
      <div class="editor-tabs">
        <button 
          v-for="tab in tabs" 
          :key="tab.id"
          @click="activeTab = tab.id"
          :class="['tab', { active: activeTab === tab.id }]"
        >
          {{ tab.icon }} {{ tab.label }}
        </button>
      </div>

      <!-- Tab Content -->
      <div class="tab-content">
        <!-- General Settings Tab -->
        <div v-if="activeTab === 'general'" class="tab-panel">
          <h2>General Settings</h2>
          
          <div class="form-group">
            <label>Title</label>
            <input 
              v-model="assessment.title" 
              type="text" 
              placeholder="Assessment title"
            />
          </div>

          <div class="form-group">
            <label>Description</label>
            <textarea 
              v-model="assessment.description" 
              rows="3"
              placeholder="Brief description of the assessment"
            ></textarea>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>Framework</label>
              <select v-model="assessment.framework_id">
                <option value="core">Core Framework</option>
                <option value="icf">ICF Framework</option>
                <option value="ac">AC Framework</option>
              </select>
            </div>

            <div class="form-group">
              <label>Level</label>
              <select v-model="assessment.level">
                <option value="beginner">Beginner</option>
                <option value="intermediate">Intermediate</option>
                <option value="advanced">Advanced</option>
              </select>
            </div>

            <div class="form-group">
              <label>Status</label>
              <select v-model="assessment.status">
                <option value="active">Active</option>
                <option value="draft">Draft</option>
                <option value="archived">Archived</option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>Time Limit (minutes)</label>
              <input 
                v-model.number="assessment.time_limit" 
                type="number" 
                min="0"
                placeholder="0 for no limit"
              />
            </div>

            <div class="form-group">
              <label>Passing Score (%)</label>
              <input 
                v-model.number="assessment.passing_score" 
                type="number" 
                min="0"
                max="100"
                placeholder="70"
              />
            </div>
          </div>
        </div>

        <!-- Questions Tab -->
        <div v-if="activeTab === 'questions'" class="tab-panel">
          <div class="questions-header">
            <h2>Questions ({{ questions.length }})</h2>
            <button @click="addQuestion" class="btn-add">
              ➕ Add Question
            </button>
          </div>

          <div class="questions-list">
            <div 
              v-for="(question, index) in questions" 
              :key="question.id || `new-${index}`"
              class="question-card"
            >
              <div class="question-header">
                <span class="question-number">Q{{ index + 1 }}</span>
                <button @click="removeQuestion(index)" class="btn-remove">
                  🗑️
                </button>
              </div>

              <div class="form-group">
                <label>Question Text</label>
                <textarea 
                  v-model="question.question_text" 
                  rows="2"
                  placeholder="Enter the question"
                ></textarea>
              </div>

              <div class="form-group">
                <label>Answer Options</label>
                <div class="answer-options">
                  <div v-for="(option, optIndex) in (question.options || [])" 
                       :key="optIndex"
                       class="answer-option">
                    <input 
                      type="radio" 
                      :name="`correct-${index}`"
                      :checked="question.correct_answer === optIndex"
                      @change="question.correct_answer = optIndex"
                    />
                    <input 
                      v-model="option.text" 
                      type="text"
                      placeholder="Answer option"
                    />
                    <input 
                      v-model.number="option.score" 
                      type="number"
                      min="0"
                      max="100"
                      placeholder="Score"
                      class="score-input"
                    />
                    <button 
                      @click="removeOption(question, optIndex)" 
                      class="btn-remove-option"
                      :disabled="question.options.length <= 2"
                    >
                      ❌
                    </button>
                  </div>
                  <button @click="addOption(question)" class="btn-add-option">
                    ➕ Add Option
                  </button>
                </div>
              </div>

              <div class="form-row">
                <div class="form-group">
                  <label>Category</label>
                  <input 
                    v-model="question.category" 
                    type="text"
                    placeholder="Question category"
                  />
                </div>

                <div class="form-group">
                  <label>Competency</label>
                  <select v-model="question.competency_id">
                    <option value="">Select competency</option>
                    <option 
                      v-for="comp in competencies" 
                      :key="comp.id"
                      :value="comp.id"
                    >
                      {{ comp.name }}
                    </option>
                  </select>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Competencies Tab -->
        <div v-if="activeTab === 'competencies'" class="tab-panel">
          <h2>Competencies Assessed</h2>
          
          <div class="competencies-grid">
            <div 
              v-for="comp in competencies" 
              :key="comp.id"
              class="competency-card"
            >
              <div class="competency-check">
                <input 
                  type="checkbox"
                  :id="`comp-${comp.id}`"
                  :checked="assessmentCompetencies.includes(comp.id)"
                  @change="toggleCompetency(comp.id)"
                />
                <label :for="`comp-${comp.id}`">
                  <strong>{{ comp.name }}</strong>
                  <p>{{ comp.description }}</p>
                </label>
              </div>
              <div class="competency-stats">
                <span>{{ getQuestionCountForCompetency(comp.id) }} questions</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Settings Tab -->
        <div v-if="activeTab === 'settings'" class="tab-panel">
          <h2>Advanced Settings</h2>
          
          <div class="form-group">
            <label>
              <input 
                type="checkbox" 
                v-model="assessment.allow_retake"
              />
              Allow Retakes
            </label>
          </div>

          <div class="form-group">
            <label>
              <input 
                type="checkbox" 
                v-model="assessment.randomize_questions"
              />
              Randomize Question Order
            </label>
          </div>

          <div class="form-group">
            <label>
              <input 
                type="checkbox" 
                v-model="assessment.show_results_immediately"
              />
              Show Results Immediately
            </label>
          </div>

          <div class="form-group">
            <label>Certificate Template</label>
            <select v-model="assessment.certificate_template">
              <option value="">No Certificate</option>
              <option value="basic">Basic Certificate</option>
              <option value="professional">Professional Certificate</option>
              <option value="custom">Custom Template</option>
            </select>
          </div>

          <div class="form-group">
            <label>Instructions</label>
            <textarea 
              v-model="assessment.instructions" 
              rows="5"
              placeholder="Special instructions for this assessment"
            ></textarea>
          </div>
        </div>
      </div>
    </div>

    <!-- No Assessment Found -->
    <div v-else class="no-assessment">
      <h2>Assessment Not Found</h2>
      <p>The requested assessment could not be loaded.</p>
      <p><a href="/docs/admin/assessments/">← Back to Assessments</a></p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuth } from '../composables/useAuth'
import { useSupabase } from '../composables/useSupabase'
import AdminLoadingState from './shared/AdminLoadingState.vue'

const { user } = useAuth()
const { supabase } = useSupabase()

// Authentication loading state
const isAuthLoaded = ref(false)

// Admin access check
const hasAdminAccess = computed(() => {
  if (!user.value) return false
  const metaData = user.value.raw_user_meta_data || user.value.user_metadata || {}
  const isDeveloper = user.value.email === 'gunnar.finkeldeh@gmail.com'
  const isTestAdmin = user.value.email === 'test@coaching-hub.local'
  const hasAdminFlag = metaData.admin === true
  return isDeveloper || isTestAdmin || hasAdminFlag
})

// Data
const assessment = ref(null)
const questions = ref([])
const competencies = ref([])
const assessmentCompetencies = ref([])
const loading = ref(false)
const saving = ref(false)

// UI State
const activeTab = ref('general')
const tabs = [
  { id: 'general', label: 'General', icon: '⚙️' },
  { id: 'questions', label: 'Questions', icon: '❓' },
  { id: 'competencies', label: 'Competencies', icon: '🎯' },
  { id: 'settings', label: 'Settings', icon: '🔧' }
]

// Get assessment ID from URL
const getAssessmentId = () => {
  const params = new URLSearchParams(window.location.search)
  return params.get('id')
}

// Load assessment data
const loadAssessment = async () => {
  const assessmentId = getAssessmentId()
  if (!assessmentId || !supabase) return
  
  loading.value = true
  try {
    // Load assessment
    const { data: assessmentData, error: assessmentError } = await supabase
      .from('assessments')
      .select('*')
      .eq('id', assessmentId)
      .single()
    
    if (assessmentError) {
      console.error('Error loading assessment:', assessmentError)
      return
    }
    
    assessment.value = assessmentData
    
    // Load questions
    const { data: questionsData, error: questionsError } = await supabase
      .from('questions')
      .select('*')
      .eq('assessment_id', assessmentId)
      .order('order_position')
    
    if (!questionsError) {
      questions.value = questionsData.map(q => ({
        ...q,
        options: q.options || [
          { text: '', score: 0 },
          { text: '', score: 0 }
        ]
      }))
    }
    
    // Load competencies
    const { data: competenciesData } = await supabase
      .from('competencies')
      .select('*')
      .eq('framework_id', assessment.value.framework_id)
      .order('name')
    
    if (competenciesData) {
      competencies.value = competenciesData
    }
    
    // Get assessment competencies
    const competencyIds = [...new Set(questions.value.map(q => q.competency_id).filter(Boolean))]
    assessmentCompetencies.value = competencyIds
    
  } catch (error) {
    console.error('Error loading assessment:', error)
  } finally {
    loading.value = false
  }
}

// Add new question
const addQuestion = () => {
  questions.value.push({
    question_text: '',
    options: [
      { text: '', score: 0 },
      { text: '', score: 25 },
      { text: '', score: 50 },
      { text: '', score: 100 }
    ],
    correct_answer: 3,
    category: '',
    competency_id: null,
    order_position: questions.value.length
  })
}

// Remove question
const removeQuestion = (index) => {
  if (confirm('Remove this question?')) {
    questions.value.splice(index, 1)
  }
}

// Add answer option
const addOption = (question) => {
  if (!question.options) {
    question.options = []
  }
  question.options.push({ text: '', score: 0 })
}

// Remove answer option
const removeOption = (question, index) => {
  if (question.options.length > 2) {
    question.options.splice(index, 1)
    // Adjust correct answer if needed
    if (question.correct_answer >= index) {
      question.correct_answer = Math.max(0, question.correct_answer - 1)
    }
  }
}

// Toggle competency
const toggleCompetency = (competencyId) => {
  const index = assessmentCompetencies.value.indexOf(competencyId)
  if (index > -1) {
    assessmentCompetencies.value.splice(index, 1)
  } else {
    assessmentCompetencies.value.push(competencyId)
  }
}

// Get question count for competency
const getQuestionCountForCompetency = (competencyId) => {
  return questions.value.filter(q => q.competency_id === competencyId).length
}

// Save changes
const saveChanges = async () => {
  if (!assessment.value || saving.value) return
  
  saving.value = true
  try {
    // Update assessment
    const { error: assessmentError } = await supabase
      .from('assessments')
      .update({
        title: assessment.value.title,
        description: assessment.value.description,
        framework_id: assessment.value.framework_id,
        level: assessment.value.level,
        status: assessment.value.status,
        time_limit: assessment.value.time_limit,
        passing_score: assessment.value.passing_score,
        allow_retake: assessment.value.allow_retake,
        randomize_questions: assessment.value.randomize_questions,
        show_results_immediately: assessment.value.show_results_immediately,
        certificate_template: assessment.value.certificate_template,
        instructions: assessment.value.instructions,
        updated_at: new Date().toISOString()
      })
      .eq('id', assessment.value.id)
    
    if (assessmentError) {
      console.error('Error updating assessment:', assessmentError)
      alert('Failed to save assessment')
      return
    }
    
    // Update questions
    for (const [index, question] of questions.value.entries()) {
      question.order_position = index
      question.assessment_id = assessment.value.id
      
      if (question.id) {
        // Update existing question
        await supabase
          .from('questions')
          .update({
            question_text: question.question_text,
            options: question.options,
            correct_answer: question.correct_answer,
            category: question.category,
            competency_id: question.competency_id,
            order_position: question.order_position
          })
          .eq('id', question.id)
      } else {
        // Insert new question
        const { data } = await supabase
          .from('questions')
          .insert({
            assessment_id: assessment.value.id,
            question_text: question.question_text,
            options: question.options,
            correct_answer: question.correct_answer,
            category: question.category,
            competency_id: question.competency_id,
            order_position: question.order_position
          })
          .select()
          .single()
        
        if (data) {
          question.id = data.id
        }
      }
    }
    
    alert('Assessment saved successfully!')
  } catch (error) {
    console.error('Error saving assessment:', error)
    alert('Failed to save assessment')
  } finally {
    saving.value = false
  }
}

// Cancel edit
const cancelEdit = () => {
  if (confirm('Discard unsaved changes?')) {
    window.location.href = '/docs/admin/assessments/'
  }
}

onMounted(() => {
  isAuthLoaded.value = true
  if (hasAdminAccess.value) {
    loadAssessment()
  }
})
</script>

<style scoped>
.admin-assessment-editor-container {
  position: fixed;
  top: var(--vp-nav-height);
  left: 0;
  right: 0;
  bottom: 0;
  background: var(--vp-c-bg);
  overflow-y: auto;
  padding: 3rem 8rem 6rem 8rem;
}

.loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400px;
  gap: 1rem;
}

.loading-spinner {
  font-size: 3rem;
  animation: spin 2s linear infinite;
}

.editor-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 2rem;
}

.header-main h1 {
  font-size: 2rem;
  margin-bottom: 0.5rem;
}

.assessment-title {
  font-size: 1.1rem;
  opacity: 0.8;
}

.header-actions {
  display: flex;
  gap: 1rem;
}

.btn-save, .btn-cancel {
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  border: none;
  transition: all 0.2s ease;
}

.btn-save {
  background: var(--vp-c-brand-1);
  color: white;
}

.btn-save:hover:not(:disabled) {
  background: var(--vp-c-brand-2);
}

.btn-save:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-cancel {
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  border: 1px solid var(--vp-c-border);
}

.btn-cancel:hover {
  background: var(--vp-c-danger-soft);
}

.admin-breadcrumb {
  margin-bottom: 2rem;
  opacity: 0.7;
  font-size: 0.9rem;
}

.admin-breadcrumb a {
  color: var(--vp-c-brand-1);
  text-decoration: none;
}

.editor-tabs {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 2rem;
  border-bottom: 2px solid var(--vp-c-border);
}

.tab {
  padding: 0.75rem 1.5rem;
  background: none;
  border: none;
  color: var(--vp-c-text-2);
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.2s ease;
  border-bottom: 2px solid transparent;
  margin-bottom: -2px;
}

.tab:hover {
  color: var(--vp-c-text-1);
}

.tab.active {
  color: var(--vp-c-brand-1);
  border-bottom-color: var(--vp-c-brand-1);
}

.tab-content {
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
  padding: 2rem;
}

.tab-panel h2 {
  margin-bottom: 1.5rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.form-group input[type="text"],
.form-group input[type="number"],
.form-group textarea,
.form-group select {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  font-size: 1rem;
}

.form-group textarea {
  resize: vertical;
  font-family: inherit;
}

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.questions-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.btn-add {
  background: var(--vp-c-brand-1);
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
}

.questions-list {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.question-card {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  padding: 1.5rem;
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.question-number {
  font-weight: 600;
  color: var(--vp-c-brand-1);
}

.btn-remove {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 1.2rem;
  opacity: 0.7;
}

.btn-remove:hover {
  opacity: 1;
}

.answer-options {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.answer-option {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.answer-option input[type="text"] {
  flex: 1;
}

.score-input {
  width: 80px !important;
}

.btn-remove-option {
  background: none;
  border: none;
  cursor: pointer;
  opacity: 0.7;
}

.btn-add-option {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  padding: 0.5rem;
  border-radius: 6px;
  cursor: pointer;
  margin-top: 0.5rem;
}

.competencies-grid {
  display: grid;
  gap: 1rem;
}

.competency-card {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  padding: 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.competency-check {
  display: flex;
  gap: 1rem;
  align-items: flex-start;
  flex: 1;
}

.competency-check input[type="checkbox"] {
  margin-top: 0.25rem;
}

.competency-check label {
  cursor: pointer;
}

.competency-stats {
  color: var(--vp-c-text-2);
  font-size: 0.9rem;
}

.no-assessment {
  text-align: center;
  padding: 4rem;
}
</style>