<template>
  <div class="learning-logs-view">
    <ViewHeader 
      title="Learning Logs"
      description="Document your coaching competence learnings"
      :show-add="true"
      add-text="+ Add Log"
      @back="$emit('navigate', 'dashboard')"
      @add="startNewEntry"
      @export="exportLearningLogs"
    />
    
    <div v-if="loading" class="loading-state">
      <p>Loading learning logs...</p>
    </div>
    
    <div v-else-if="error" class="error-state">
      <p>Error loading learning logs: {{ error }}</p>
      <button @click="loadData" class="retry-btn">Retry</button>
    </div>
    
    <div v-else>
      <div v-if="learningLogs.length > 0" class="entries-table learning-logs-table">
        <div class="table-header">
          <div class="col-activity">Activity</div>
          <div class="col-date">Date</div>
          <div class="col-actions">Actions</div>
        </div>
        <div 
          v-for="entry in learningLogs" 
          :key="entry.id" 
          class="table-row learning-log-row"
        >
          <div class="col-activity">
            <div class="entry-name">{{ entry.activity_name || 'Learning Log' }}</div>
            <div class="mobile-metadata">
              <div class="col-date">{{ formatDate(entry.date) }}</div>
            </div>
            <div class="entry-reflection">{{ truncateText(entry.learnings_and_reflections, 150) }}</div>
          </div>
          <div class="desktop-metadata col-date">{{ formatDate(entry.date) }}</div>
          <div class="col-actions">
            <button @click="viewEntry(entry)" class="action-btn view-btn" title="View">👁️</button>
            <button @click="editEntry(entry)" class="action-btn edit-btn" title="Edit">✏️</button>
            <button @click="handleDelete(entry.id)" class="action-btn delete-btn" title="Delete">🗑️</button>
          </div>
        </div>
      </div>

      <EmptyState
        v-else
        icon="💭"
        title="No learning logs yet"
        description="Start documenting your learning insights and growth by clicking the Add Log button above."
        :show-action="false"
      />
    </div>

    <!-- View Modal -->
    <EntryModal 
      :entry="viewingEntry" 
      @close="closeViewer"
      @edit="editEntryFromModal"
    />

    <!-- Edit Form -->
    <LearningLogForm
      v-if="editingEntry"
      :entry="editingEntry"
      :saving="saving"
      @close="closeEditForm"
      @save="handleSave"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, inject } from 'vue'
import { useLearningLogs } from '../../composables/useLearningLogs.js'
import ViewHeader from './shared/ViewHeader.vue'
import EmptyState from './shared/EmptyState.vue'
import EntryModal from './shared/EntryModal.vue'
import LearningLogForm from './shared/LearningLogForm.vue'

const { 
  learningLogs, 
  loading, 
  error, 
  loadLearningLogs, 
  createLearningLog,
  deleteLearningLog,
  updateLearningLog,
  exportLearningLogs 
} = useLearningLogs()

// Get user and refresh function from parent context
const user = inject('user')
const refreshData = inject('refreshData')

defineEmits(['navigate'])

// Modal and editing state
const viewingEntry = ref(null)
const editingEntry = ref(null)
const saving = ref(false)

// Utility functions
const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  })
}

const truncateText = (text, maxLength) => {
  if (!text) return ''
  if (text.length <= maxLength) return text
  return text.substring(0, maxLength) + '...'
}

// Actions
const viewEntry = (entry) => {
  viewingEntry.value = entry
}

const editEntry = (entry) => {
  editingEntry.value = entry
}

const closeViewer = () => {
  viewingEntry.value = null
}

const editEntryFromModal = (entry) => {
  viewingEntry.value = null
  editingEntry.value = entry
}

const closeEditForm = () => {
  editingEntry.value = null
}

const handleSave = async (formData) => {
  saving.value = true
  try {
    if (formData.id) {
      // Update existing entry
      const updateData = {
        activity_name: formData.activity_name,
        date: formData.date,
        learnings_and_reflections: formData.learnings_and_reflections,
        user_id: user.value.id
      }
      await updateLearningLog(formData.id, updateData)
    } else {
      // Create new entry
      const createData = {
        activity_name: formData.activity_name,
        date: formData.date,
        learnings_and_reflections: formData.learnings_and_reflections,
        user_id: user.value.id
      }
      await createLearningLog(createData)
    }
    closeEditForm()
    // Trigger parent data refresh
    if (refreshData) {
      await refreshData()
    }
  } catch (error) {
    console.error('Error saving learning log:', error)
    alert('Failed to save learning log. Please try again.')
  } finally {
    saving.value = false
  }
}

const handleDelete = async (id) => {
  await deleteLearningLog(id)
  // Trigger parent data refresh after deletion
  if (refreshData) {
    await refreshData()
  }
}

const startNewEntry = () => {
  editingEntry.value = {} // Empty object for new entry
}

const loadData = () => {
  if (user?.value?.id) {
    loadLearningLogs(user.value.id)
  }
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.loading-state, .error-state {
  text-align: center;
  padding: 2rem;
}


.retry-btn {
  padding: 8px 16px;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  margin-top: 1rem;
  font-weight: 500;
  transition: background 0.3s ease;
}

.retry-btn:hover {
  background: #2563eb;
}

.entries-table {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  overflow: hidden;
}

.table-header {
  display: grid;
  grid-template-columns: minmax(300px, 3fr) 120px 140px;
  padding: 1rem;
  background: var(--vp-c-bg-alt);
  border-bottom: 1px solid var(--vp-c-divider);
  font-weight: 600;
  font-size: 0.9rem;
  color: var(--vp-c-text-1);
  gap: 1rem;
}

.table-row {
  display: grid;
  grid-template-columns: minmax(300px, 3fr) 120px 140px;
  padding: 1rem;
  border-bottom: 1px solid var(--vp-c-divider);
  transition: background 0.3s ease;
  gap: 1rem;
  align-items: center;
}

.table-row:hover {
  background: var(--vp-c-bg-alt);
}

.table-row:last-child {
  border-bottom: none;
}

.entry-name {
  font-weight: 600;
  color: var(--vp-c-text-1);
  margin-bottom: 0.25rem;
}

.entry-reflection {
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
  line-height: 1.4;
}

.col-date {
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
  font-weight: 400;
}

.col-actions {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.action-btn {
  display: inline-block;
  border: 1px solid var(--vp-c-divider);
  text-align: center;
  font-weight: 500;
  white-space: nowrap;
  cursor: pointer;
  transition: all 0.3s;
  padding: 0 12px;
  line-height: 32px;
  font-size: 14px;
  border-radius: 20px;
  color: var(--vp-c-text-2);
  background-color: var(--vp-c-bg-soft);
}

.action-btn:hover {
  color: var(--vp-c-text-1);
  border-color: var(--vp-c-divider-dark);
  background-color: var(--vp-c-bg-alt);
}

@media (max-width: 768px) {
  .entries-table {
    background: transparent;
    border: none;
    overflow: visible;
  }
  
  .table-header {
    display: none;
  }
  
  .table-row {
    display: block;
    background: var(--vp-c-bg-soft);
    border: 1px solid var(--vp-c-divider);
    border-radius: 12px;
    margin-bottom: 1rem;
    padding: 1rem;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  }
  
  .table-row:hover {
    background: var(--vp-c-bg-soft);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }
  
  .col-name {
    margin-bottom: 1rem;
  }
  
  .col-date {
    display: inline-block;
    margin-bottom: 1rem;
  }
  
  .col-date::before {
    content: "📅 ";
    color: var(--vp-c-text-3);
  }
  
  .col-actions {
    margin-top: 1rem;
    padding-top: 1rem;
    border-top: 1px solid var(--vp-c-divider);
    justify-content: space-between;
  }
  
  .action-btn {
    flex: 1;
    margin: 0 0.25rem;
    padding: 0.5rem;
    line-height: 1.2;
    font-size: 0.8rem;
    text-align: center;
    border-radius: 6px;
  }
  
  .table-header {
    font-size: 0.8rem;
  }
  
  .entry-name {
    font-size: 0.9rem;
  }
  
  .entry-reflection {
    font-size: 0.8rem;
  }
  
  .action-btn {
    padding: 0 8px;
    line-height: 28px;
    font-size: 12px;
  }
}

@media (max-width: 480px) {
  .table-header,
  .table-row {
    grid-template-columns: 1fr 80px 100px;
    gap: 0.25rem;
    padding: 0.5rem;
  }
}
</style>