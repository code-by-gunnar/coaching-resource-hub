<template>
  <div class="loading-container">
    <div class="loading-content">
      <div class="loading-spinner">🔄</div>
      <h2 class="loading-title">{{ title || 'Loading Admin Panel' }}</h2>
      <p class="loading-subtitle">{{ subtitle || 'Verifying administrator access...' }}</p>
    </div>
  </div>
</template>

<script setup>
defineProps({
  title: String,
  subtitle: String
})
</script>

<style scoped>
/* Centered Loading State */
.loading-container {
  position: fixed;
  top: var(--vp-nav-height);
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--vp-c-bg);
  z-index: 10;
}

.loading-content {
  text-align: center;
  padding: 2rem;
}

.loading-spinner {
  font-size: 3rem;
  margin-bottom: 1rem;
  animation: spin 1s linear infinite;
  display: inline-block;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.loading-title {
  font-size: 1.5rem;
  margin: 0 0 0.5rem 0;
  color: var(--vp-c-text-1);
  font-weight: 600;
}

.loading-subtitle {
  font-size: 1rem;
  margin: 0;
  color: var(--vp-c-text-2);
}
</style>