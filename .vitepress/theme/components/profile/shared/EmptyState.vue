<template>
  <div class="empty-state">
    <div class="empty-icon">{{ icon }}</div>
    <h4>{{ title }}</h4>
    <p>{{ description }}</p>
    <button v-if="showAction" @click="$emit('action')" class="empty-action-btn">
      {{ actionText }}
    </button>
  </div>
</template>

<script setup>
defineProps({
  icon: {
    type: String,
    required: true
  },
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  actionText: {
    type: String,
    default: 'Add Entry'
  },
  showAction: {
    type: Boolean,
    default: true
  }
})

defineEmits(['action'])
</script>

<style scoped>
.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
}

.empty-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.empty-state h4 {
  margin: 0 0 1rem 0;
  color: var(--vp-c-text-1);
}

.empty-state p {
  margin: 0 0 2rem 0;
  color: var(--vp-c-text-2);
}

.empty-action-btn {
  padding: 12px 24px;
  background: var(--vp-c-brand-1);
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 500;
  transition: background 0.3s ease;
}

.empty-action-btn:hover {
  background: var(--vp-c-brand-dark);
}
</style>