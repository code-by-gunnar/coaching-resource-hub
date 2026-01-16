<template>
  <div 
    class="admin-table-container" 
    :style="containerStyle"
  >
    <!-- Table Header -->
    <div 
      class="admin-table-header"
      :style="headerStyle"
    >
      <div 
        v-for="(column, index) in columns" 
        :key="index"
        :style="getColumnStyle(column)"
      >
        {{ column.label }}
      </div>
    </div>
    
    <!-- Table Content Slot -->
    <slot></slot>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  columns: {
    type: Array,
    required: true,
    // Example: [
    //   { label: 'Email & Status', width: '3fr' },
    //   { label: 'Joined', width: '120px' },
    //   { label: 'Actions', width: '120px' }
    // ]
  },
  responsive: {
    type: Object,
    default: () => ({
      tablet: null,  // Optional tablet breakpoint columns
      mobile: null   // Optional mobile breakpoint columns  
    })
  }
})

// Container styling - inline to avoid CSS class conflicts
const containerStyle = computed(() => ({
  background: 'var(--vp-c-bg-soft)',
  border: '1px solid var(--vp-c-border)',
  borderRadius: '12px',
  overflow: 'hidden',
  margin: '1rem 0 4rem 0'
}))

// Header styling - inline to avoid CSS class conflicts
const headerStyle = computed(() => ({
  display: 'grid',
  gridTemplateColumns: props.columns.map(col => col.width).join(' '),
  gap: '1rem',
  padding: '1rem 1.5rem',
  background: 'var(--vp-c-bg)',
  borderBottom: '2px solid var(--vp-c-border)',
  fontWeight: '600',
  fontSize: '0.9rem',
  color: 'var(--vp-c-text-1)'
}))

const getColumnStyle = (column) => ({
  minWidth: column.minWidth || '0',
  textAlign: column.align || 'left'
})
</script>

<style scoped>
/* Responsive breakpoints */
@media (max-width: 1200px) {
  .admin-table-header {
    grid-template-columns: v-bind(tabletColumns) !important;
  }
}

@media (max-width: 768px) {
  .admin-table-header {
    display: none !important;
  }
  
  .admin-table-container {
    /* Mobile stacked layout handled by parent component */
  }
}
</style>