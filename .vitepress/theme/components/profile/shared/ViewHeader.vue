<template>
  <div class="view-header">
    <div class="header-content">
      <h3>{{ title }}</h3>
      <p class="view-description">{{ description }}</p>
    </div>
    <div class="header-actions">
      <ActionButton @click="$emit('back')" variant="gray" icon="←">
        Back
      </ActionButton>
      <ActionButton v-if="showAdd" @click="$emit('add')" variant="success" icon="+">
        {{ addText.replace('+ ', '') }}
      </ActionButton>
      <ActionButton v-if="showExport" @click="$emit('export')" variant="primary" icon="📄">
        Export
      </ActionButton>
    </div>
  </div>
</template>

<script setup>
import ActionButton from '../../shared/ActionButton.vue'

defineProps({
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  showExport: {
    type: Boolean,
    default: true
  },
  showAdd: {
    type: Boolean,
    default: false
  },
  addText: {
    type: String,
    default: '+ Add Entry'
  }
})

defineEmits(['back', 'export', 'add'])
</script>

<style scoped>
.view-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 2rem;
  padding: 1.5rem;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  min-width: 0;
}

.header-content h3 {
  margin: 0 0 0.5rem 0;
  color: var(--vp-c-text-1);
  font-size: 1.5rem;
  font-weight: 700;
}

.view-description {
  margin: 0;
  color: var(--vp-c-text-2);
  font-size: 0.9rem;
}

.header-actions {
  display: flex;
  gap: 0.5rem;
  align-items: center;
  flex-wrap: nowrap;
}

/* Custom styling for header action buttons */
.header-actions .action-button {
  min-width: 110px;
  padding: 12px 16px;
  font-size: 0.9rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

@media (max-width: 768px) {
  .view-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
    padding: 1rem;
  }
  
  .header-content h3 {
    font-size: 1.25rem;
  }
  
  .header-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
    justify-content: flex-start;
  }
  
  /* Mobile-specific button adjustments */
  .header-actions .action-button {
    min-width: 70px;
    padding: 8px 12px;
    font-size: 0.8rem;
  }
}
</style>