<template>
  <div class="assessment-badge" :class="[framework, size]">
    <span class="badge-text">{{ getBadgeText() }}</span>
  </div>
</template>

<script setup>
const props = defineProps({
  framework: {
    type: String,
    required: true,
    validator: (value) => ['core', 'icf', 'ac'].includes(value)
  },
  difficulty: {
    type: String,
    default: null,
    validator: (value) => !value || ['beginner', 'intermediate', 'advanced', 'Beginner', 'Intermediate', 'Advanced'].includes(value)
  },
  showDifficulty: {
    type: Boolean,
    default: true
  },
  size: {
    type: String,
    default: 'medium',
    validator: (value) => ['mini', 'small', 'medium', 'large'].includes(value)
  }
})

const getBadgeText = () => {
  const frameworkAbbrev = {
    'core': 'CORE',
    'icf': 'ICF',
    'ac': 'AC'
  }
  
  if (!props.showDifficulty || !props.difficulty) {
    return frameworkAbbrev[props.framework]
  }
  
  const difficultyLevel = {
    'beginner': 'I',
    'intermediate': 'II', 
    'advanced': 'III',
    'Beginner': 'I',
    'Intermediate': 'II', 
    'Advanced': 'III'
  }
  
  return `${frameworkAbbrev[props.framework]} ${difficultyLevel[props.difficulty]}`
}
</script>

<style scoped>
.assessment-badge {
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 12px;
  border: 2px solid;
  background: transparent;
  flex-shrink: 0;
}

/* Size variants */
.assessment-badge.large {
  width: 80px;
  height: 80px;
  border-radius: 16px;
}

.assessment-badge.medium {
  width: 60px;
  height: 60px;
  border-radius: 12px;
}

.assessment-badge.small {
  width: 40px;
  height: 40px;
  border-radius: 8px;
}

.assessment-badge.mini {
  width: 32px;
  height: 32px;
  border-radius: 6px;
  border-width: 1px;
}

/* Framework colors */
.assessment-badge.core {
  border-color: #7c3aed;
  background: linear-gradient(135deg, #f3e8ff 0%, #e9d5ff 100%);
}

.assessment-badge.icf {
  border-color: #1e40af;
  background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
}

.assessment-badge.ac {
  border-color: #92400e;
  background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
}

/* Text styling */
.badge-text {
  text-align: center;
  line-height: 1.2;
  letter-spacing: 0.5px;
  font-weight: 700;
}

.assessment-badge.large .badge-text {
  font-size: 0.9rem;
}

.assessment-badge.medium .badge-text {
  font-size: 0.75rem;
}

.assessment-badge.small .badge-text {
  font-size: 0.6rem;
}

.assessment-badge.mini .badge-text {
  font-size: 0.5rem;
  font-weight: 600;
}

/* Text colors */
.assessment-badge.core .badge-text {
  color: #7c3aed;
}

.assessment-badge.icf .badge-text {
  color: #1e40af;
}

.assessment-badge.ac .badge-text {
  color: #92400e;
}
</style>