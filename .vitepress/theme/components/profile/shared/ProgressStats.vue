<template>
  <div class="progress-bar">
    <div class="progress-stat">
      <span class="stat-number">{{ totalHours }}</span>
      <span class="stat-label">Study Hours</span>
    </div>
    <div class="progress-stat">
      <span class="stat-number">{{ studySessions }}</span>
      <span class="stat-label">Study Sessions</span>
    </div>
    <div class="progress-stat">
      <span class="stat-number">{{ learningLogs }}</span>
      <span class="stat-label">Learning Logs</span>
    </div>
    <div class="progress-stat">
      <span class="stat-number">{{ assessmentStats.completed }}</span>
      <span class="stat-label">Completed</span>
    </div>
    <div class="progress-stat" v-if="assessmentStats.inProgress > 0">
      <span class="stat-number stat-in-progress">{{ assessmentStats.inProgress }}</span>
      <span class="stat-label">In Progress</span>
    </div>
    <div class="progress-stat">
      <span class="stat-number">{{ assessmentStats.averageScore }}%</span>
      <span class="stat-label">Avg Score</span>
    </div>
  </div>
</template>

<script setup>
defineProps({
  totalHours: {
    type: Number,
    default: 0
  },
  studySessions: {
    type: Number,
    default: 0
  },
  learningLogs: {
    type: Number,
    default: 0
  },
  assessmentStats: {
    type: Object,
    default: () => ({ completed: 0, inProgress: 0, averageScore: 0 })
  }
})
</script>

<style scoped>
.progress-bar {
  display: flex;
  justify-content: center;
  gap: 3rem;
  padding: 1.5rem;
  margin-bottom: 2rem;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
}

.progress-stat {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.stat-number {
  font-size: 1.8rem;
  font-weight: bold;
  color: var(--vp-c-brand-1);
  line-height: 1;
}

.stat-in-progress {
  color: var(--vp-c-yellow-1, #fbbf24);
}

.stat-label {
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
  margin-top: 0.25rem;
  font-weight: 500;
}

/* Mobile optimization */
@media (max-width: 768px) {
  .progress-bar {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 1rem;
    padding: 1rem;
    margin-bottom: 1.5rem;
  }
  
  .progress-stat {
    padding: 0.5rem;
  }
  
  .stat-number {
    font-size: 1.3rem;
    font-weight: 600;
  }
  
  .stat-label {
    font-size: 0.7rem;
    margin-top: 0.2rem;
    line-height: 1.2;
  }
}

@media (max-width: 480px) {
  .progress-bar {
    grid-template-columns: repeat(3, 1fr);
    gap: 0.5rem;
    padding: 0.75rem;
  }
  
  .progress-stat {
    padding: 0.25rem;
  }
  
  .stat-number {
    font-size: 1.1rem;
  }
  
  .stat-label {
    font-size: 0.6rem;
    font-weight: 400;
  }
}
</style>