<template>
  <div v-if="entry" class="modal-overlay" @click="$emit('close')">
    <div class="modal-content" @click.stop>
      <div class="modal-header">
        <h3>{{ entry.name || entry.activity_name || 'Entry Details' }}</h3>
        <button @click="$emit('close')" class="modal-close">&times;</button>
      </div>
      <div class="modal-body">
        <!-- Study Log View -->
        <div v-if="entry.hours !== undefined" class="entry-details">
          <div class="entry-metadata">
            <div class="meta-item">
              <span class="meta-label">Hours</span>
              <span class="meta-value hours-value">{{ entry.hours }}h</span>
            </div>
            <div class="meta-item">
              <span class="meta-label">Category</span>
              <span class="category-badge">{{ entry.category }}</span>
            </div>
            <div class="meta-item">
              <span class="meta-label">Date</span>
              <span class="meta-value">{{ formatDate(entry.date) }}</span>
            </div>
          </div>
          <div class="entry-content">
            <h4>Description</h4>
            <div class="description-full">{{ entry.description }}</div>
          </div>
        </div>
        
        <!-- Learning Log View -->
        <div v-else class="entry-details">
          <div class="entry-metadata">
            <div class="meta-item">
              <span class="meta-label">Date</span>
              <span class="meta-value">{{ formatDate(entry.date) }}</span>
            </div>
          </div>
          <div class="entry-content">
            <h4>Learning Reflection</h4>
            <div class="reflection-full">{{ entry.learnings_and_reflections }}</div>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button @click="$emit('close')" class="modal-btn close-modal-btn">
          Close
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  entry: {
    type: Object,
    default: null
  }
})

defineEmits(['close'])

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString('en-US', {
    month: 'long',
    day: 'numeric',
    year: 'numeric'
  })
}
</script>

<style scoped>
.modal-overlay {
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

.modal-content {
  background: var(--vp-c-bg);
  border-radius: 12px;
  width: 90%;
  max-width: 600px;
  max-height: 80%;
  overflow-y: auto;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  border: 1px solid var(--vp-c-divider);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem 2rem;
  border-bottom: 1px solid var(--vp-c-divider);
}

.modal-header h3 {
  margin: 0;
  color: var(--vp-c-text-1);
  font-size: 1.25rem;
}

.modal-close {
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

.modal-close:hover {
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
}

.modal-body {
  padding: 2rem;
}

.entry-metadata {
  display: flex;
  gap: 2rem;
  margin-bottom: 2rem;
  flex-wrap: wrap;
}

.meta-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.meta-label {
  font-size: 0.8rem;
  font-weight: 500;
  color: var(--vp-c-text-2);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.meta-value {
  font-size: 1rem;
  color: var(--vp-c-text-1);
}

.hours-value {
  font-weight: 600;
  color: var(--vp-c-brand-1);
}

.category-badge {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-text-1);
  border-radius: 12px;
  font-size: 0.9rem;
  font-weight: 500;
  border: 1px solid var(--vp-c-brand-light);
}

.entry-content h4 {
  margin: 0 0 1rem 0;
  color: var(--vp-c-text-1);
  font-size: 1rem;
}

.description-full, .reflection-full {
  color: var(--vp-c-text-1);
  line-height: 1.6;
  white-space: pre-wrap;
  background: var(--vp-c-bg-soft);
  padding: 1rem;
  border-radius: 8px;
  border: 1px solid var(--vp-c-divider);
}

.modal-footer {
  padding: 1.5rem 2rem;
  border-top: 1px solid var(--vp-c-divider);
  display: flex;
  justify-content: center;
}

.modal-btn {
  padding: 0.75rem 1.5rem;
  border: 1px solid transparent;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 500;
  transition: all 0.3s ease;
}

.close-modal-btn {
  background: #64748b;
  color: white;
  border-color: #64748b;
}

.close-modal-btn:hover {
  background: #475569;
  border-color: #475569;
}

@media (max-width: 768px) {
  .modal-content {
    width: 95%;
    margin: 1rem;
  }
  
  .modal-header, .modal-body, .modal-footer {
    padding: 1rem;
  }
  
  .entry-metadata {
    gap: 1rem;
  }
  
  .modal-footer {
    flex-direction: column;
  }
  
  .modal-btn {
    width: 100%;
  }
}
</style>