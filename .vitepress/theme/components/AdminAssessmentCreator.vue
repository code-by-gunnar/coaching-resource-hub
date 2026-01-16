<template>
  <div class="admin-assessment-creator-container">
    <!-- Loading state during auth check -->
    <AdminLoadingState v-if="!isAuthLoaded" />

    <!-- Admin Access Check -->
    <div v-else-if="!hasAdminAccess">
      <h2>⚠️ Admin Access Required</h2>
      <p>You need administrator privileges to create assessments.</p>
      <p><a href="/docs/admin/">← Back to Admin Hub</a></p>
    </div>

    <!-- Assessment Creator -->
    <div v-else>
      <div class="creator-header">
        <div class="header-main">
          <h1>🆕 Create New Assessment</h1>
          <p class="creator-subtitle">Build a new assessment from scratch or duplicate existing</p>
        </div>
      </div>

      <nav class="admin-breadcrumb">
        <a href="/docs/admin/">Admin Hub</a> → 
        <a href="/docs/admin/assessments/">Assessments</a> → 
        Create New
      </nav>

      <!-- Creation Options -->
      <div class="creation-options">
        <div 
          :class="['option-card', { active: creationType === 'blank' }]"
          @click="creationType = 'blank'"
        >
          <div class="option-icon">📝</div>
          <h3>Start from Scratch</h3>
          <p>Create a completely new assessment with custom questions</p>
        </div>
        
        <div 
          :class="['option-card', { active: creationType === 'template' }]"
          @click="creationType = 'template'"
        >
          <div class="option-icon">📋</div>
          <h3>Use Template</h3>
          <p>Start with a pre-built template and customize it</p>
        </div>
        
        <div 
          :class="['option-card', { active: creationType === 'duplicate' }]"
          @click="creationType = 'duplicate'"
        >
          <div class="option-icon">🔄</div>
          <h3>Duplicate Existing</h3>
          <p>Copy an existing assessment and modify it</p>
        </div>
      </div>

      <!-- Template Selection (if template selected) -->
      <div v-if="creationType === 'template'" class="template-selection">
        <h2>Select a Template</h2>
        <div class="template-grid">
          <div 
            v-for="template in templates" 
            :key="template.id"
            :class="['template-card', { selected: selectedTemplate === template.id }]"
            @click="selectedTemplate = template.id"
          >
            <h4>{{ template.name }}</h4>
            <p>{{ template.description }}</p>
            <div class="template-meta">
              <span>{{ template.questions }} questions</span>
              <span>{{ template.framework }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Duplicate Selection (if duplicate selected) -->
      <div v-if="creationType === 'duplicate'" class="duplicate-selection">
        <h2>Select Assessment to Duplicate</h2>
        <select v-model="selectedAssessment" class="assessment-select">
          <option value="">Choose an assessment...</option>
          <option 
            v-for="assessment in existingAssessments" 
            :key="assessment.id"
            :value="assessment.id"
          >
            {{ assessment.title }} ({{ assessment.framework_id }} - {{ assessment.level }})
          </option>
        </select>
      </div>

      <!-- Assessment Form -->
      <div v-if="creationType" class="assessment-form">
        <h2>Assessment Details</h2>
        
        <div class="form-group">
          <label>Title *</label>
          <input 
            v-model="newAssessment.title" 
            type="text" 
            placeholder="e.g., Core Coaching Skills - Beginner"
            required
          />
        </div>

        <div class="form-group">
          <label>Description *</label>
          <textarea 
            v-model="newAssessment.description" 
            rows="3"
            placeholder="Brief description of what this assessment covers"
            required
          ></textarea>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label>Framework *</label>
            <select v-model="newAssessment.framework_id" required>
              <option value="">Select framework</option>
              <option value="core">Core Framework</option>
              <option value="icf">ICF Framework</option>
              <option value="ac">AC Framework</option>
            </select>
          </div>

          <div class="form-group">
            <label>Level *</label>
            <select v-model="newAssessment.level" required>
              <option value="">Select level</option>
              <option value="beginner">Beginner</option>
              <option value="intermediate">Intermediate</option>
              <option value="advanced">Advanced</option>
            </select>
          </div>

          <div class="form-group">
            <label>Initial Status</label>
            <select v-model="newAssessment.status">
              <option value="draft">Draft</option>
              <option value="active">Active</option>
            </select>
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label>Time Limit (minutes)</label>
            <input 
              v-model.number="newAssessment.time_limit" 
              type="number" 
              min="0"
              placeholder="0 for unlimited"
            />
          </div>

          <div class="form-group">
            <label>Passing Score (%)</label>
            <input 
              v-model.number="newAssessment.passing_score" 
              type="number" 
              min="0"
              max="100"
              placeholder="70"
            />
          </div>

          <div class="form-group">
            <label>Question Count</label>
            <input 
              v-model.number="questionCount" 
              type="number" 
              min="1"
              max="100"
              placeholder="20"
            />
          </div>
        </div>

        <div class="form-actions">
          <button @click="createAssessment" class="btn-create" :disabled="!isValid || creating">
            {{ creating ? 'Creating...' : '🚀 Create Assessment' }}
          </button>
          <button @click="cancel" class="btn-cancel">
            Cancel
          </button>
        </div>
      </div>
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

// Creation state
const creationType = ref('')
const selectedTemplate = ref('')
const selectedAssessment = ref('')
const existingAssessments = ref([])
const creating = ref(false)
const questionCount = ref(20)

// New assessment data
const newAssessment = ref({
  title: '',
  description: '',
  framework_id: '',
  level: '',
  status: 'draft',
  time_limit: null,
  passing_score: 70,
  allow_retake: true,
  randomize_questions: false,
  show_results_immediately: true
})

// Templates
const templates = ref([
  {
    id: 'core-beginner',
    name: 'Core Skills Starter',
    description: 'Basic coaching competencies for beginners',
    questions: 20,
    framework: 'Core'
  },
  {
    id: 'icf-intermediate',
    name: 'ICF Professional',
    description: 'ICF competencies for professional coaches',
    questions: 25,
    framework: 'ICF'
  },
  {
    id: 'ac-advanced',
    name: 'AC Master Coach',
    description: 'Advanced AC framework assessment',
    questions: 30,
    framework: 'AC'
  }
])

// Validation
const isValid = computed(() => {
  return newAssessment.value.title && 
         newAssessment.value.description && 
         newAssessment.value.framework_id && 
         newAssessment.value.level
})

// Load existing assessments for duplication
const loadAssessments = async () => {
  if (!supabase) return
  
  try {
    const { data } = await supabase
      .from('assessments')
      .select('id, title, framework_id, level')
      .order('framework_id')
      .order('level')
    
    if (data) {
      existingAssessments.value = data
    }
  } catch (error) {
    console.error('Error loading assessments:', error)
  }
}

// Create assessment
const createAssessment = async () => {
  if (!isValid.value || creating.value) return
  
  creating.value = true
  try {
    // Create the assessment
    const { data: assessment, error } = await supabase
      .from('assessments')
      .insert({
        ...newAssessment.value,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })
      .select()
      .single()
    
    if (error) {
      console.error('Error creating assessment:', error)
      alert('Failed to create assessment')
      return
    }
    
    // If duplicating, copy questions
    if (creationType.value === 'duplicate' && selectedAssessment.value) {
      const { data: questions } = await supabase
        .from('questions')
        .select('*')
        .eq('assessment_id', selectedAssessment.value)
        .order('order_position')
      
      if (questions && questions.length > 0) {
        const newQuestions = questions.map(q => ({
          assessment_id: assessment.id,
          question_text: q.question_text,
          options: q.options,
          correct_answer: q.correct_answer,
          category: q.category,
          competency_id: q.competency_id,
          order_position: q.order_position
        }))
        
        await supabase
          .from('questions')
          .insert(newQuestions)
      }
    } else if (creationType.value === 'blank') {
      // Create placeholder questions
      const questions = []
      for (let i = 0; i < questionCount.value; i++) {
        questions.push({
          assessment_id: assessment.id,
          question_text: `Question ${i + 1}`,
          options: [
            { text: 'Option A', score: 0 },
            { text: 'Option B', score: 25 },
            { text: 'Option C', score: 50 },
            { text: 'Option D', score: 100 }
          ],
          correct_answer: 3,
          order_position: i
        })
      }
      
      await supabase
        .from('questions')
        .insert(questions)
    }
    
    // Redirect to edit page
    alert('Assessment created successfully!')
    window.location.href = `/docs/admin/assessments/edit?id=${assessment.id}`
    
  } catch (error) {
    console.error('Error creating assessment:', error)
    alert('Failed to create assessment')
  } finally {
    creating.value = false
  }
}

// Cancel
const cancel = () => {
  if (confirm('Cancel assessment creation?')) {
    window.location.href = '/docs/admin/assessments/'
  }
}

onMounted(() => {
  isAuthLoaded.value = true
  if (hasAdminAccess.value) {
    loadAssessments()
  }
})
</script>

<style scoped>
.admin-assessment-creator-container {
  position: fixed;
  top: var(--vp-nav-height);
  left: 0;
  right: 0;
  bottom: 0;
  background: var(--vp-c-bg);
  overflow-y: auto;
  padding: 3rem 8rem 6rem 8rem;
}

.creator-header {
  margin-bottom: 2rem;
}

.header-main h1 {
  font-size: 2rem;
  margin-bottom: 0.5rem;
}

.creator-subtitle {
  font-size: 1.1rem;
  opacity: 0.8;
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

.creation-options {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
  margin-bottom: 3rem;
}

.option-card {
  background: var(--vp-c-bg-soft);
  border: 2px solid var(--vp-c-border);
  border-radius: 12px;
  padding: 2rem;
  text-align: center;
  cursor: pointer;
  transition: all 0.2s ease;
}

.option-card:hover {
  border-color: var(--vp-c-brand-1);
  transform: translateY(-2px);
}

.option-card.active {
  border-color: var(--vp-c-brand-1);
  background: var(--vp-c-brand-soft);
}

.option-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.option-card h3 {
  margin: 0 0 0.5rem 0;
}

.option-card p {
  opacity: 0.8;
  font-size: 0.95rem;
}

.template-selection,
.duplicate-selection {
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
  padding: 2rem;
  margin-bottom: 2rem;
}

.template-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 1rem;
  margin-top: 1rem;
}

.template-card {
  background: var(--vp-c-bg);
  border: 2px solid var(--vp-c-border);
  border-radius: 8px;
  padding: 1rem;
  cursor: pointer;
}

.template-card.selected {
  border-color: var(--vp-c-brand-1);
  background: var(--vp-c-brand-soft);
}

.template-meta {
  display: flex;
  justify-content: space-between;
  margin-top: 0.5rem;
  font-size: 0.85rem;
  opacity: 0.7;
}

.assessment-select {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  font-size: 1rem;
  margin-top: 1rem;
}

.assessment-form {
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
  padding: 2rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 600;
}

.form-group input,
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

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.form-actions {
  display: flex;
  gap: 1rem;
  margin-top: 2rem;
}

.btn-create,
.btn-cancel {
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  border: none;
  transition: all 0.2s ease;
}

.btn-create {
  background: var(--vp-c-brand-1);
  color: white;
}

.btn-create:hover:not(:disabled) {
  background: var(--vp-c-brand-2);
}

.btn-create:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-cancel {
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  border: 1px solid var(--vp-c-border);
}
</style>