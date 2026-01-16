<template>
  <div class="edit-form-overlay" @click="$emit('close')">
    <div class="edit-form-content" @click.stop>
      <div class="edit-form-header">
        <h3>{{ isEditing ? 'Edit Learning Log' : 'Add Learning Log' }}</h3>
        <button @click="$emit('close')" class="form-close">&times;</button>
      </div>
      <form @submit.prevent="handleSubmit" class="edit-form">
        <div class="form-group">
          <label for="activity_name">Activity Name</label>
          <input 
            id="activity_name"
            v-model="formData.activity_name" 
            type="text" 
            required 
            placeholder="e.g., Coaching Session with Client A"
          />
        </div>
        
        <div class="form-group">
          <label for="date">Date</label>
          <input 
            id="date"
            v-model="formData.date" 
            type="date" 
            required 
          />
        </div>
        
        <div class="form-group">
          <label for="learnings_and_reflections">Learning Reflection</label>
          <textarea 
            id="learnings_and_reflections"
            v-model="formData.learnings_and_reflections" 
            rows="8"
            required
            placeholder="Reflect on what you learned, insights gained, challenges faced, and how you can apply this learning..."
          ></textarea>
        </div>
        
        <div class="form-actions">
          <button type="button" @click="$emit('close')" class="form-btn secondary">
            Cancel
          </button>
          <button type="submit" class="form-btn primary" :disabled="saving">
            {{ saving ? 'Saving...' : (isEditing ? 'Update' : 'Add Log') }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  entry: {
    type: Object,
    default: null
  },
  saving: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close', 'save'])

const isEditing = ref(false)

const formData = ref({
  activity_name: '',
  date: new Date().toISOString().split('T')[0],
  learnings_and_reflections: ''
})

// Initialize form with entry data if editing
watch(() => props.entry, (entry) => {
  if (entry && entry.id) {
    isEditing.value = true
    formData.value = {
      activity_name: entry.activity_name || '',
      date: entry.date || new Date().toISOString().split('T')[0],
      learnings_and_reflections: entry.learnings_and_reflections || ''
    }
  } else {
    isEditing.value = false
    formData.value = {
      activity_name: '',
      date: new Date().toISOString().split('T')[0],
      learnings_and_reflections: ''
    }
  }
}, { immediate: true })

const handleSubmit = () => {
  emit('save', {
    id: props.entry?.id,
    ...formData.value
  })
}
</script>

<style scoped>
.edit-form-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.edit-form-content {
  background: var(--vp-c-bg);
  border-radius: 12px;
  width: 90%;
  max-width: 600px;
  max-height: 90%;
  overflow-y: auto;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  border: 1px solid var(--vp-c-divider);
}

.edit-form-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem 2rem;
  border-bottom: 1px solid var(--vp-c-divider);
}

.edit-form-header h3 {
  margin: 0;
  color: var(--vp-c-text-1);
  font-size: 1.25rem;
}

.form-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  color: var(--vp-c-text-2);
  cursor: pointer;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: all 0.3s ease;
}

.form-close:hover {
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
}

.edit-form {
  padding: 2rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  color: var(--vp-c-text-1);
  font-weight: 500;
  font-size: 0.9rem;
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 12px;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  font-size: 1rem;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', sans-serif;
  transition: border-color 0.3s ease;
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: var(--vp-c-brand-1);
}

.form-group textarea {
  resize: vertical;
  min-height: 200px;
  line-height: 1.6;
}

.form-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 2rem;
  padding-top: 1.5rem;
  border-top: 1px solid var(--vp-c-divider);
}

.form-btn {
  padding: 0.75rem 1.5rem;
  border: 1px solid transparent;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 500;
  transition: all 0.3s ease;
}

.form-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.form-btn.primary {
  background: #10b981;
  color: white;
  border-color: #10b981;
}

.form-btn.primary:hover:not(:disabled) {
  background: #059669;
  border-color: #059669;
}

.form-btn.secondary {
  background: #64748b;
  color: white;
  border-color: #64748b;
}

.form-btn.secondary:hover {
  background: #475569;
  border-color: #475569;
}

@media (max-width: 768px) {
  .edit-form-content {
    width: 95%;
    margin: 1rem;
  }
  
  .edit-form-header, .edit-form {
    padding: 1rem;
  }
  
  .form-actions {
    flex-direction: column;
  }
  
  .form-btn {
    width: 100%;
  }
}
</style>