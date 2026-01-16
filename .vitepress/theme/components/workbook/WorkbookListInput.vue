<template>
  <div class="list-input">
    <div class="list-items">
      <div 
        v-for="(item, index) in items" 
        :key="index"
        class="list-item"
      >
        <input 
          v-model="items[index]"
          type="text"
          :placeholder="field.placeholder_text || 'Enter item...'"
          @input="updateList"
          @keydown.enter="addNewItem"
          class="item-input"
        />
        <button 
          @click="removeItem(index)"
          class="remove-btn"
          type="button"
          :disabled="items.length === 1"
        >
          ×
        </button>
      </div>
    </div>
    
    <button 
      @click="addNewItem"
      class="add-item-btn"
      type="button"
    >
      + Add Item
    </button>
    
    <div v-if="field.instructions" class="list-instructions">
      <small>{{ field.instructions }}</small>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'

const props = defineProps({
  field: {
    type: Object,
    required: true
  },
  value: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update'])

// Local items array for v-model
const items = ref([])

// Initialize items from value prop
const initializeItems = () => {
  if (props.value && props.value.length > 0) {
    items.value = [...props.value]
  } else {
    // Start with one empty item
    items.value = ['']
  }
}

// Add new item
const addNewItem = () => {
  items.value.push('')
  updateList()
  
  // Focus on the new input after Vue updates the DOM
  setTimeout(() => {
    const inputs = document.querySelectorAll('.list-item:last-child .item-input')
    if (inputs.length > 0) {
      inputs[0].focus()
    }
  }, 50)
}

// Remove item
const removeItem = (index) => {
  if (items.value.length > 1) {
    items.value.splice(index, 1)
    updateList()
  }
}

// Update parent with filtered list (remove empty items for saving)
const updateList = () => {
  const filteredItems = items.value.filter(item => item && item.trim().length > 0)
  emit('update', filteredItems)
}

// Watch for external value changes
watch(() => props.value, (newValue) => {
  if (JSON.stringify(newValue) !== JSON.stringify(items.value.filter(item => item && item.trim().length > 0))) {
    initializeItems()
  }
}, { deep: true })

onMounted(() => {
  initializeItems()
})
</script>

<style scoped>
.list-input {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.list-items {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.list-item {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.item-input {
  flex: 1;
  padding: 0.5rem 0.75rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  font-size: 0.95rem;
  transition: all 0.2s;
  font-family: inherit;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
}

.item-input:focus {
  outline: none;
  border-color: var(--vp-c-brand-1);
  box-shadow: 0 0 0 3px var(--vp-c-brand-soft);
}

.remove-btn {
  width: 32px;
  height: 32px;
  border: 1px solid var(--vp-c-divider);
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-2);
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 1.2rem;
  font-weight: 600;
}

.remove-btn:hover:not(:disabled) {
  background: var(--vp-c-red-soft);
  border-color: var(--vp-c-red-light);
  color: var(--vp-c-red-1);
}

.remove-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.add-item-btn {
  align-self: flex-start;
  padding: 0.5rem 1rem;
  border: 1px dashed var(--vp-c-text-3);
  background: transparent;
  color: var(--vp-c-text-2);
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 0.9rem;
  font-weight: 500;
}

.add-item-btn:hover {
  border-color: var(--vp-c-brand-1);
  color: var(--vp-c-brand-1);
  background: var(--vp-c-brand-soft);
}

.list-instructions {
  margin-top: 0.25rem;
}

.list-instructions small {
  color: var(--vp-c-text-2);
  font-style: italic;
  line-height: 1.4;
}

/* Animation for new items */
.list-item {
  animation: slideIn 0.2s ease-out;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Responsive design */
@media (max-width: 768px) {
  .list-item {
    flex-direction: column;
    align-items: stretch;
  }
  
  .remove-btn {
    align-self: flex-end;
    width: auto;
    padding: 0.25rem 0.75rem;
    font-size: 0.85rem;
  }
}
</style>