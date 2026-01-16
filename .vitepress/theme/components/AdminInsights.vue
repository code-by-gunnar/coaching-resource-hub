<template>
  <div class="admin-container">
    <!-- Loading state during auth check -->
    <AdminLoadingState v-if="!isAuthLoaded" />

    <!-- Admin Access Check -->
    <div v-else-if="!hasAdminAccess" class="admin-content">
      <div class="admin-header">
        <h1>⚠️ Admin Access Required</h1>
        <p class="admin-subtitle">You need administrator privileges to manage insights.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- Insights Management -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>💡 Insights Management</h1>
          <p class="admin-subtitle">Manage personalized insights templates and strategic actions</p>
        </div>
        
        <div class="header-actions">
          <ActionButton @click="createNewInsight" icon="➕">Create New Insight</ActionButton>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>Insights</span>
      </nav>

      <!-- Framework & Category Filters -->
      <div class="filter-controls">
        <select v-model="selectedFramework" @change="loadInsights">
          <option value="">All Frameworks</option>
          <option value="core">Core Framework</option>
          <option value="icf">ICF Framework</option>
          <option value="ac">AC Framework</option>
        </select>
        
        <select v-model="selectedLevel" @change="loadInsights">
          <option value="">All Levels</option>
          <option value="beginner">Beginner</option>
          <option value="intermediate">Intermediate</option>
          <option value="advanced">Advanced</option>
        </select>
        
        <select v-model="selectedCategory" @change="loadInsights">
          <option value="">All Categories</option>
          <option value="strategic_actions">Strategic Actions</option>
          <option value="strength_leverage">Strength Leverage</option>
          <option value="learning_resources">Learning Resources</option>
          <option value="development_plans">Development Plans</option>
        </select>
      </div>

      <!-- Insights Stats -->
      <div class="stats-grid">
        <div class="stat-card">
          <h3>🎯 Strategic Actions</h3>
          <div class="stat-number">{{ stats.strategicActions }}</div>
        </div>
        <div class="stat-card">
          <h3>💪 Strength Leverage</h3>
          <div class="stat-number">{{ stats.strengthLeverage }}</div>
        </div>
        <div class="stat-card">
          <h3>📚 Learning Resources</h3>
          <div class="stat-number">{{ stats.learningResources }}</div>
        </div>
        <div class="stat-card">
          <h3>📈 Development Plans</h3>
          <div class="stat-number">{{ stats.developmentPlans }}</div>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="loading">
        <div class="loading-spinner"></div>
        <p>Loading insights...</p>
      </div>

      <!-- Insights List -->
      <div v-else class="insights-list">
        <div v-if="filteredInsights.length === 0" class="no-results">
          <p>No insights found matching your criteria.</p>
          <p class="help-text">Use the "Create New Insight" button above to get started.</p>
        </div>

        <div v-else>
          <div class="insights-table">
            <div class="table-header">
              <div class="col-framework">Framework</div>
              <div class="col-level">Level</div>
              <div class="col-category">Category</div>
              <div class="col-content">Content</div>
              <div class="col-actions">Actions</div>
            </div>
            
            <div 
              v-for="insight in filteredInsights" 
              :key="insight.id"
              class="table-row"
            >
              <div class="col-framework">
                <span class="framework-badge" :class="insight.framework">
                  {{ insight.framework?.toUpperCase() || 'N/A' }}
                </span>
              </div>
              <div class="col-level">
                <span class="level-badge" :class="insight.difficulty_level">
                  {{ insight.difficulty_level || 'N/A' }}
                </span>
              </div>
              <div class="col-category">
                <span class="category-tag">{{ insight.category || 'General' }}</span>
              </div>
              <div class="col-content">
                <div class="insight-preview">
                  <strong>{{ insight.title || 'Untitled' }}</strong>
                  <p>{{ truncateText(insight.content || insight.action_text || '', 100) }}</p>
                </div>
              </div>
              <div class="col-actions">
                <ActionButton @click="editInsight(insight)" variant="gray" class="btn-icon">✏️</ActionButton>
                <ActionButton @click="deleteInsight(insight)" variant="secondary" class="btn-icon">🗑️</ActionButton>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Create/Edit Modal -->
      <div v-if="showModal" class="modal-overlay" @click="closeModal">
        <div class="modal-content" @click.stop>
          <h2>{{ editingInsight ? 'Edit' : 'Create' }} Insight</h2>
          
          <form @submit.prevent="saveInsight">
            <div class="form-group">
              <label>Framework</label>
              <select v-model="currentInsight.framework" required>
                <option value="core">Core Framework</option>
                <option value="icf">ICF Framework</option>
                <option value="ac">AC Framework</option>
              </select>
            </div>
            
            <div class="form-group">
              <label>Level</label>
              <select v-model="currentInsight.difficulty_level" required>
                <option value="beginner">Beginner</option>
                <option value="intermediate">Intermediate</option>
                <option value="advanced">Advanced</option>
              </select>
            </div>
            
            <div class="form-group">
              <label>Category</label>
              <select v-model="currentInsight.category" required>
                <option value="strategic_actions">Strategic Actions</option>
                <option value="strength_leverage">Strength Leverage</option>
                <option value="learning_resources">Learning Resources</option>
                <option value="development_plans">Development Plans</option>
              </select>
            </div>
            
            <div class="form-group">
              <label>Competency Area</label>
              <input v-model="currentInsight.competency_area" type="text" placeholder="e.g., coaching_presence">
            </div>
            
            <div class="form-group">
              <label>Title</label>
              <input v-model="currentInsight.title" type="text" placeholder="Insight title">
            </div>
            
            <div class="form-group">
              <label>Content</label>
              <textarea 
                v-model="currentInsight.content" 
                rows="4" 
                placeholder="Insight content or action text"
                required
              ></textarea>
            </div>
            
            <div class="form-row">
              <div class="form-group">
                <label>Score Range Min</label>
                <input v-model.number="currentInsight.score_range_min" type="number" min="0" max="100">
              </div>
              
              <div class="form-group">
                <label>Score Range Max</label>
                <input v-model.number="currentInsight.score_range_max" type="number" min="0" max="100">
              </div>
            </div>
            
            <div class="form-group">
              <label>
                <input v-model="currentInsight.is_active" type="checkbox">
                Active
              </label>
            </div>
            
            <div class="modal-actions">
              <ActionButton type="button" @click="closeModal" variant="secondary">Cancel</ActionButton>
              <ActionButton type="submit" :disabled="saving">
                {{ saving ? 'Saving...' : 'Save' }}
              </ActionButton>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useAuth } from '../composables/useAuth'
import { useSupabase } from '../composables/useSupabase'
import { useAdminSession } from '../composables/useAdminSession'
import ActionButton from './shared/ActionButton.vue'
import AdminLoadingState from './shared/AdminLoadingState.vue'

const { user } = useAuth()
const { supabase } = useSupabase()
const { hasAdminAccess } = useAdminSession()

// Authentication loading state
const isAuthLoaded = ref(false)

// State
const insights = ref([])
const loading = ref(false)
const showModal = ref(false)
const editingInsight = ref(null)
const saving = ref(false)

// Filters
const selectedFramework = ref('')
const selectedLevel = ref('')
const selectedCategory = ref('')

// Stats
const stats = ref({
  strategicActions: 0,
  strengthLeverage: 0,
  learningResources: 0,
  developmentPlans: 0
})

// Current insight for editing
const currentInsight = ref({
  framework: 'core',
  difficulty_level: 'beginner',
  category: 'strategic_actions',
  competency_area: '',
  title: '',
  content: '',
  score_range_min: 0,
  score_range_max: 100,
  is_active: true
})

// Computed
const filteredInsights = computed(() => {
  let filtered = insights.value

  if (selectedFramework.value) {
    filtered = filtered.filter(i => i.framework === selectedFramework.value)
  }
  
  if (selectedLevel.value) {
    filtered = filtered.filter(i => i.difficulty_level === selectedLevel.value)
  }
  
  if (selectedCategory.value) {
    filtered = filtered.filter(i => i.category === selectedCategory.value)
  }

  return filtered
})

// Methods
const loadInsights = async () => {
  if (!supabase || !hasAdminAccess.value) return
  
  loading.value = true
  try {
    // Load strategic actions
    const { data: actions } = await supabase
      .from('competency_strategic_actions')
      .select('*')
      .order('framework, difficulty_level, competency_area, sort_order')

    // Transform strategic actions to common format
    const transformedActions = (actions || []).map(action => ({
      ...action,
      category: 'strategic_actions',
      content: action.action_text,
      table: 'competency_strategic_actions'
    }))

    insights.value = transformedActions
    
    // Calculate stats
    stats.value = {
      strategicActions: transformedActions.length,
      strengthLeverage: 0, // TODO: Add when table exists
      learningResources: 0, // TODO: Add when table exists  
      developmentPlans: 0 // TODO: Add when table exists
    }

  } catch (error) {
    console.error('Error loading insights:', error)
  } finally {
    loading.value = false
  }
}

const truncateText = (text, length) => {
  if (!text) return ''
  return text.length > length ? text.substring(0, length) + '...' : text
}

const createNewInsight = () => {
  editingInsight.value = null
  currentInsight.value = {
    framework: selectedFramework.value || 'core',
    difficulty_level: selectedLevel.value || 'beginner',
    category: selectedCategory.value || 'strategic_actions',
    competency_area: '',
    title: '',
    content: '',
    score_range_min: 0,
    score_range_max: 100,
    is_active: true
  }
  showModal.value = true
}

const editInsight = (insight) => {
  editingInsight.value = insight
  currentInsight.value = { ...insight }
  // Map action_text to content for consistency
  if (insight.action_text && !currentInsight.value.content) {
    currentInsight.value.content = insight.action_text
  }
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  editingInsight.value = null
}

const saveInsight = async () => {
  if (!supabase || saving.value) return
  
  saving.value = true
  try {
    // For strategic actions, map content back to action_text
    const dataToSave = { ...currentInsight.value }
    if (currentInsight.value.category === 'strategic_actions') {
      dataToSave.action_text = currentInsight.value.content
      delete dataToSave.content
    }
    
    if (editingInsight.value) {
      // Update existing
      const { error } = await supabase
        .from('competency_strategic_actions')
        .update(dataToSave)
        .eq('id', editingInsight.value.id)
      
      if (error) throw error
    } else {
      // Create new
      const { error } = await supabase
        .from('competency_strategic_actions')
        .insert([dataToSave])
      
      if (error) throw error
    }
    
    await loadInsights()
    closeModal()
  } catch (error) {
    console.error('Error saving insight:', error)
  } finally {
    saving.value = false
  }
}

const deleteInsight = async (insight) => {
  if (!confirm('Are you sure you want to delete this insight?')) return
  
  try {
    const { error } = await supabase
      .from('competency_strategic_actions')
      .delete()
      .eq('id', insight.id)
    
    if (error) throw error
    
    await loadInsights()
  } catch (error) {
    console.error('Error deleting insight:', error)
  }
}

// Watch for admin access changes
watch(hasAdminAccess, (newValue) => {
  if (newValue) {
    loadInsights()
  }
}, { immediate: true })

onMounted(() => {
  isAuthLoaded.value = true
  if (hasAdminAccess.value) {
    loadInsights()
  }
})
</script>

<style scoped>
/* Base Admin Container */
.admin-container {
  position: fixed;
  top: var(--vp-nav-height);
  left: 0;
  right: 0;
  bottom: 0;
  background: var(--vp-c-bg);
  overflow-y: auto;
}

.admin-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 2rem 12rem 2rem; /* Extra bottom padding for footer */
  min-height: calc(100vh - var(--vp-nav-height) - 8rem); /* Ensure minimum height */
}

/* Admin Header */
.admin-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 2rem;
  gap: 2rem;
}

.header-main h1 {
  font-size: 2rem;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.admin-subtitle {
  font-size: 1rem;
  opacity: 0.7;
  margin: 0;
  color: var(--vp-c-text-2);
}

.header-actions {
  display: flex;
  gap: 1rem;
}

/* Breadcrumb */
.breadcrumb {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 2rem;
}

.breadcrumb-separator {
  color: var(--vp-c-text-3);
  font-size: 0.9rem;
}

.filter-controls {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  flex-wrap: wrap;
}

.filter-controls select {
  padding: 0.5rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 4px;
  background: var(--vp-c-bg);
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.stat-card {
  padding: 1rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  text-align: center;
  background: var(--vp-c-bg-soft);
}

.stat-card h3 {
  margin: 0 0 0.5rem 0;
  font-size: 0.9rem;
}

.stat-number {
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--vp-c-brand-1);
}

.loading {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 2rem;
  justify-content: center;
}

.loading-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid var(--vp-c-border);
  border-top: 2px solid var(--vp-c-brand-1);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.insights-table {
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  overflow: hidden;
  margin: 1rem 0 4rem 0; /* Extra bottom margin for footer clearance */
}

.table-header, .table-row {
  display: grid;
  grid-template-columns: 80px 100px 140px 1fr 80px;
  gap: 1rem;
  padding: 1rem;
  align-items: center;
}

.table-header {
  background: var(--vp-c-bg-soft);
  font-weight: 600;
  border-bottom: 1px solid var(--vp-c-border);
}

.table-row {
  border-bottom: 1px solid var(--vp-c-border);
}

.table-row:last-child {
  border-bottom: none;
}

.framework-badge {
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  font-size: 0.7rem;
  font-weight: 600;
  text-transform: uppercase;
}

.framework-badge.core { background: #e1f5fe; color: #0277bd; }
.framework-badge.icf { background: #f3e5f5; color: #7b1fa2; }
.framework-badge.ac { background: #e8f5e8; color: #2e7d32; }

.level-badge {
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  font-size: 0.7rem;
  font-weight: 500;
  text-transform: capitalize;
}

.level-badge.beginner { background: #fff3e0; color: #e65100; }
.level-badge.intermediate { background: #fff8e1; color: #f57c00; }
.level-badge.advanced { background: #ffebee; color: #c62828; }

.category-tag {
  font-size: 0.8rem;
  padding: 0.2rem 0.5rem;
  background: var(--vp-c-bg-soft);
  border-radius: 4px;
}

.insight-preview strong {
  display: block;
  margin-bottom: 0.3rem;
  font-size: 0.9rem;
}

.insight-preview p {
  font-size: 0.8rem;
  opacity: 0.7;
  margin: 0;
  line-height: 1.3;
}

.btn-icon {
  min-width: 40px;
  padding: 0.5rem;
}

.no-results {
  text-align: center;
  padding: 3rem;
}

.help-text {
  font-size: 0.9rem;
  color: var(--vp-c-text-3);
  margin-top: 0.5rem;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: var(--vp-c-bg);
  padding: 2rem;
  border-radius: 8px;
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  border: 1px solid var(--vp-c-border);
}

.modal-content h2 {
  margin: 0 0 1.5rem 0;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.3rem;
  font-weight: 500;
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 4px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
}

.form-group input[type="checkbox"] {
  width: auto;
  margin-right: 0.5rem;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

.modal-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 2rem;
  padding-top: 1rem;
  border-top: 1px solid var(--vp-c-border);
}

/* Responsive Design */
@media (max-width: 768px) {
  .admin-content {
    padding: 1rem 1rem 10rem 1rem; /* Increased bottom padding on mobile */
  }
  
  .admin-header {
    flex-direction: column;
    gap: 1rem;
  }
  
  .filter-controls {
    flex-direction: column;
  }
  
  .table-header, .table-row {
    grid-template-columns: 1fr 80px 100px 1fr 80px;
    font-size: 0.9rem;
  }
  
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>