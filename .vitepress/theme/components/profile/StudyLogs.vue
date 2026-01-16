<template>
  <div class="study-logs-view">
    <ViewHeader 
      title="Study Logs"
      description="Track your self-study activities and progress"
      :show-add="true"
      add-text="+ Add Log"
      @back="$emit('navigate', 'dashboard')"
      @add="startNewEntry"
      @export="exportStudyLogs"
    />
    
    <div v-if="loading" class="loading-state">
      <p>Loading study logs...</p>
    </div>
    
    <div v-else-if="error" class="error-state">
      <p>Error loading study logs: {{ error }}</p>
      <button @click="loadData" class="retry-btn">Retry</button>
    </div>
    
    <div v-else>
      <div v-if="studyLogs.length > 0" class="entries-table">
        <div class="table-header">
          <div class="col-name">Activity</div>
          <div class="col-hours">Hours</div>
          <div class="col-category">Category</div>
          <div class="col-date">Date</div>
          <div class="col-actions">Actions</div>
        </div>
        <div 
          v-for="entry in studyLogs" 
          :key="entry.id" 
          class="table-row"
        >
          <div class="col-name">
            <div class="entry-name">{{ entry.name }}</div>
            <div class="mobile-metadata">
              <div class="col-hours">{{ entry.hours }}h</div>
              <div class="col-category">
                <span class="category-badge">{{ entry.category }}</span>
              </div>
              <div class="col-date">{{ formatDate(entry.date) }}</div>
            </div>
            <div class="entry-description">{{ truncateText(entry.description, 100) }}</div>
          </div>
          <div class="desktop-metadata col-hours">{{ entry.hours }}h</div>
          <div class="desktop-metadata col-category">
            <span class="category-badge">{{ entry.category }}</span>
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
        icon="📖"
        title="No study logs yet"
        description="Start tracking your learning journey by clicking the Add Log button above."
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
    <StudyLogForm
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
import { useStudyLogs } from '../../composables/useStudyLogs.js'
import ViewHeader from './shared/ViewHeader.vue'
import EmptyState from './shared/EmptyState.vue'
import EntryModal from './shared/EntryModal.vue'
import StudyLogForm from './shared/StudyLogForm.vue'

const { 
  studyLogs, 
  loading, 
  error, 
  loadStudyLogs, 
  createStudyLog,
  deleteStudyLog,
  updateStudyLog,
  exportStudyLogs 
} = useStudyLogs()

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
        name: formData.name,
        hours: formData.hours,
        description: formData.description,
        category: formData.category,
        date: formData.date,
        user_id: user.value.id
      }
      await updateStudyLog(formData.id, updateData)
    } else {
      // Create new entry
      const createData = {
        name: formData.name,
        hours: formData.hours,
        description: formData.description,
        category: formData.category,
        date: formData.date,
        user_id: user.value.id
      }
      await createStudyLog(createData)
    }
    closeEditForm()
    // Trigger parent data refresh
    if (refreshData) {
      await refreshData()
    }
  } catch (error) {
    console.error('Error saving study log:', error)
    alert('Failed to save study log. Please try again.')
  } finally {
    saving.value = false
  }
}

const handleDelete = async (id) => {
  await deleteStudyLog(id)
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
    loadStudyLogs(user.value.id)
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
  grid-template-columns: minmax(200px, 2fr) 80px 120px 100px 140px;
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
  grid-template-columns: minmax(200px, 2fr) 80px 120px 100px 140px;
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

.entry-description {
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
  line-height: 1.4;
}

.category-badge {
  display: inline-block;
  padding: 0.25rem 0.5rem;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-text-1);
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
  border: 1px solid var(--vp-c-brand-light);
}

.col-hours {
  font-weight: 600;
  color: var(--vp-c-brand-1);
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

.mobile-metadata {
  display: none;
}

.desktop-metadata {
  display: block;
}

@media (max-width: 768px) {
  .mobile-metadata {
    display: block;
  }
  
  .desktop-metadata {
    display: none;
  }
  
  .entries-table {
    background: transparent;
    border: none;
    overflow: visible;
  }
  
  .table-header {
    display: none; /* Hide desktop table header on mobile */
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
    margin-bottom: 0.5rem;
  }
  
  .entry-name {
    font-size: 1rem;
    font-weight: 600;
    margin-bottom: 0.75rem;
  }
  
  .mobile-metadata {
    margin-bottom: 0.75rem;
  }
  
  .mobile-metadata .col-hours, 
  .mobile-metadata .col-category, 
  .mobile-metadata .col-date {
    display: inline-block;
    margin-right: 1rem;
    margin-bottom: 0;
  }
  
  .entry-description {
    font-size: 0.9rem;
    margin-bottom: 1rem;
    padding-top: 0.5rem;
    border-top: 1px solid var(--vp-c-divider-light);
  }
  
  .mobile-metadata .col-hours::before {
    content: "⏱️ ";
    color: var(--vp-c-text-3);
  }
  
  .mobile-metadata .col-category::before {
    content: "📂 ";
    color: var(--vp-c-text-3);
  }
  
  .mobile-metadata .col-date::before {
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
}

@media (max-width: 480px) {
  .action-btn {
    font-size: 0.75rem;
    padding: 0.4rem;
  }
  
  .col-hours, .col-category, .col-date {
    margin-right: 0.75rem;
  }
}
</style>