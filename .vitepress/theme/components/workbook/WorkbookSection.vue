<template>
  <div class="workbook-section">
    <!-- Section header -->
    <div class="section-header">
      <div class="section-title-area">
        <div class="section-badge">
          Section {{ section.display_number || section.section_number }}
        </div>
        <h2>{{ section.display_title || section.section_title }}</h2>
      </div>
      
      <div class="section-status">
        <div v-if="section.progress_percent === 100" class="status-badge completed">
          ✓ Completed
        </div>
        <div v-else-if="section.progress_percent > 0" class="status-badge in-progress">
          In Progress
        </div>
        <div v-else class="status-badge not-started">
          Not Started
        </div>
      </div>
    </div>

    <!-- Section content -->
    <div class="section-content">
      <!-- Section introduction based on original workbook -->
      <div v-if="sectionIntro" class="section-intro">
        <div v-html="sectionIntro"></div>
      </div>

      <!-- Section guidelines if available -->
      <div v-if="quickStartItems.length > 0" class="section-guidelines">
        <h3>💡 Key Things to Consider</h3>
        <ul class="guidelines-list">
          <li 
            v-for="(item, index) in quickStartItems"
            :key="index"
            class="guideline-item"
          >
            {{ item }}
          </li>
        </ul>
      </div>

      <!-- Completion criteria info -->
      <div class="completion-info">
        <div class="completion-info-header">
          <span class="completion-icon">✅</span>
          <span class="completion-text">Complete all fields below to finish this section</span>
        </div>
      </div>

      <!-- Field inputs -->
      <div class="fields-container">
        <div 
          v-for="field in fields" 
          :key="field.field_key"
          class="field-group"
        >
          <div class="field-header">
            <label :for="field.field_key" class="field-label">
              {{ field.field_label }}
              <span v-if="field.is_required" class="required">*</span>
            </label>
            <div v-if="field.instructions" class="field-instructions">
              {{ field.instructions }}
            </div>
          </div>

          <!-- Text input -->
          <input 
            v-if="field.field_type === 'text'"
            :id="field.field_key"
            v-model="fieldValues[field.field_key]"
            type="text"
            :placeholder="field.placeholder_text"
            @input="handleFieldInput(field.field_key, $event.target.value, field.field_type)"
            @blur="handleFieldBlur"
            class="field-input text-input"
          />

          <!-- Textarea input -->
          <textarea
            v-else-if="field.field_type === 'textarea'"
            :id="field.field_key"
            v-model="fieldValues[field.field_key]"
            :placeholder="field.placeholder_text"
            @input="handleFieldInput(field.field_key, $event.target.value, field.field_type)"
            @blur="handleFieldBlur"
            class="field-input textarea-input"
            rows="4"
          ></textarea>

          <!-- List input -->
          <WorkbookListInput
            v-else-if="field.field_type === 'list'"
            :field="field"
            :value="fieldValues[field.field_key] || []"
            @update="handleFieldUpdate(field.field_key, $event, field.field_type)"
          />

          <!-- Checkbox input -->
          <label 
            v-else-if="field.field_type === 'checkbox'"
            class="checkbox-input"
          >
            <input 
              type="checkbox"
              :checked="fieldValues[field.field_key]"
              @change="handleFieldUpdate(field.field_key, $event.target.checked, field.field_type)"
            />
            <span>{{ field.placeholder_text || 'Check if complete' }}</span>
          </label>
        </div>
      </div>

      <!-- Section completion celebration -->
      <div v-if="section.progress_percent === 100" class="completion-celebration">
        <div class="celebration-content">
          <div class="celebration-icon">🎉</div>
          <h3>Section Complete!</h3>
          <p>Great work! You've completed this section of your workbook.</p>
          <div v-if="section.completed_at" class="completion-time">
            Completed on {{ formatDate(section.completed_at) }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useWorkbook } from '../../composables/useWorkbook.js'
import WorkbookListInput from './WorkbookListInput.vue'

const props = defineProps({
  section: {
    type: Object,
    required: true
  },
  fields: {
    type: Array,
    required: true
  },
  responses: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['field-updated', 'field-blur', 'section-completed'])

const { getFieldResponse } = useWorkbook()

// Local field values for v-model
const fieldValues = ref({})

// Section-specific content
const sectionIntros = {
  1: null, // Removed cluttered intro - guidelines serve this purpose better
  2: null,
  3: null,
  4: null,
  5: null,
  6: null,
  7: null,
  8: null,
  9: null
}

const sectionGuidelines = {
  1: [
    'List 3 unique skills (not just "coaching")',
    'Name 2 life experiences you want to draw on',
    'Note any awards or qualifications'
  ],
  2: [
    'List your relevant work/life experiences',
    'Note your key qualifications and awards',
    'Identify what truly fires you up',
    'Write your future self letter'
  ],
  3: [
    'Age, gender, location (if relevant)',
    'Their biggest pain point',
    'Their fear, their "secret"',
    'How you help'
  ],
  4: [
    'Decide: use your name or a company name?',
    'Draft a "tagline" (even if it\'s silly)',
    'Write your mission and values'
  ],
  5: [
    'Choose a personal, relevant image or logo',
    'Make sure it matches your brand',
    'Use it everywhere'
  ],
  6: [
    'Decide: session-based or program-based?',
    'List 2 pros and cons for each',
    'Brainstorm your unique program idea'
  ],
  7: [
    'Define your "platinum" client',
    'List a freemium product idea',
    'List a warm-up product idea'
  ],
  8: [
    'List 5 actions to improve your website',
    'Plan to collect testimonials',
    'Set up Google My Business'
  ],
  9: [
    'Identify your top 2 social platforms',
    'List 3 ways to engage your audience',
    'Plan your first networking event'
  ]
}

// Computed properties
const sectionIntro = computed(() => sectionIntros[props.section.section_number])

const quickStartItems = computed(() => sectionGuidelines[props.section.section_number] || [])

// Initialize field values from responses
const initializeFieldValues = () => {
  const values = {}
  
  props.fields.forEach(field => {
    const response = props.responses.find(r => r.field_key === field.field_key)
    if (response) {
      switch (field.field_type) {
        case 'text':
        case 'textarea':
          values[field.field_key] = response.field_value?.value || ''
          break
        case 'list':
          values[field.field_key] = response.field_value?.items || []
          break
        case 'checkbox':
          values[field.field_key] = response.field_value?.checked || false
          break
        default:
          values[field.field_key] = response.field_value?.value || ''
      }
    } else {
      // Set default values
      switch (field.field_type) {
        case 'text':
        case 'textarea':
          values[field.field_key] = ''
          break
        case 'list':
          values[field.field_key] = []
          break
        case 'checkbox':
          values[field.field_key] = false
          break
        default:
          values[field.field_key] = ''
      }
    }
  })
  
  fieldValues.value = values
}

// Handle field input (queues change but doesn't save)
const handleFieldInput = (fieldKey, value, fieldType) => {
  fieldValues.value[fieldKey] = value
  emit('field-updated', fieldKey, value, fieldType)
  
  // Check if section is completed
  checkSectionCompletion()
}

// Handle field blur (triggers save)
const handleFieldBlur = () => {
  emit('field-blur')
}

// Check if all required fields are completed
const checkSectionCompletion = () => {
  const completed = props.fields.every(field => {
    const value = fieldValues.value[field.field_key]
    
    if (!field.is_required) return true
    
    switch (field.field_type) {
      case 'text':
      case 'textarea':
        return value && value.trim().length > 0
      case 'list':
        return Array.isArray(value) && value.length > 0
      case 'checkbox':
        return value === true
      default:
        return value && value.toString().trim().length > 0
    }
  })
  
  if (completed && props.section.progress_percent < 100) {
    emit('section-completed', props.section.section_number)
  }
}


// Utility methods
const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString()
}

// Watchers and lifecycle
watch(() => props.responses, initializeFieldValues, { immediate: true, deep: true })
watch(() => props.fields, initializeFieldValues, { immediate: true })

onMounted(() => {
  initializeFieldValues()
})
</script>

<style scoped>
.workbook-section {
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
  box-shadow: 0 1px 3px var(--vp-c-shadow-1);
  overflow: hidden;
}

.section-header {
  background: linear-gradient(135deg, var(--vp-c-bg-soft) 0%, var(--vp-c-bg-mute) 100%);
  padding: 2rem;
  border-bottom: 1px solid var(--vp-c-divider);
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.section-badge {
  display: inline-block;
  background: var(--vp-c-brand-1);
  color: var(--vp-c-white);
  padding: 0.25rem 0.75rem;
  border-radius: 1rem;
  font-size: 0.8rem;
  font-weight: 600;
  margin-bottom: 1.25rem;
}

.section-title-area h2 {
  margin: 0;
  color: var(--vp-c-text-1);
  font-size: 1.5rem;
  font-weight: 700;
}


.status-badge {
  padding: 0.5rem 1rem;
  border-radius: 6px;
  font-size: 0.85rem;
  font-weight: 600;
}

.status-badge.completed {
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green-1);
}

.status-badge.in-progress {
  background: var(--vp-c-yellow-soft);
  color: var(--vp-c-yellow-1);
}

.status-badge.not-started {
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-2);
}

.section-content {
  padding: 2rem;
}

.section-intro {
  background: var(--vp-c-bg-alt);
  border: 1px solid var(--vp-c-divider-light);
  border-left: 3px solid var(--vp-c-brand-2);
  padding: 1rem 1.25rem;
  margin-bottom: 1.5rem;
  border-radius: 6px;
  font-size: 0.85rem;
}

.section-intro :deep(.intro-columns) {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
}

.section-intro :deep(.intro-column h3) {
  color: var(--vp-c-text-1);
  margin-top: 0;
  margin-bottom: 0.5rem;
  font-size: 0.9rem;
  font-weight: 600;
}

.section-intro :deep(.intro-column ul) {
  margin: 0;
  padding-left: 1rem;
}

.section-intro :deep(.intro-column li) {
  margin: 0.2rem 0;
  color: var(--vp-c-text-2);
  line-height: 1.3;
  font-size: 0.8rem;
}

/* Fallback for legacy single-column content */
.section-intro h3, .section-intro h4 {
  color: var(--vp-c-text-1);
  margin-top: 0;
  margin-bottom: 0.75rem;
  font-size: 1rem;
  font-weight: 600;
}

.section-intro ul {
  margin: 0.5rem 0;
  padding-left: 1.25rem;
}

.section-intro li {
  margin: 0.25rem 0;
  color: var(--vp-c-text-2);
  line-height: 1.4;
}

.section-guidelines {
  background: linear-gradient(135deg, var(--vp-c-yellow-soft) 0%, var(--vp-c-orange-soft) 100%);
  border: 2px solid var(--vp-c-yellow-1);
  border-radius: 12px;
  padding: 2rem;
  margin-bottom: 2.5rem;
  box-shadow: 0 4px 12px var(--vp-c-shadow-2);
  position: relative;
  overflow: hidden;
}

.section-guidelines::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, var(--vp-c-yellow-1) 0%, var(--vp-c-orange-1) 50%, var(--vp-c-yellow-1) 100%);
}

.section-guidelines h3 {
  margin: 0 0 1.25rem 0;
  color: var(--vp-c-yellow-darker);
  font-size: 1.2rem;
  font-weight: 700;
  text-shadow: 0 1px 2px rgba(0,0,0,0.1);
}

.guidelines-list {
  margin: 0;
  padding-left: 0;
  list-style: none;
}

.guideline-item {
  margin: 0.75rem 0;
  font-size: 1rem;
  color: var(--vp-c-text-1);
  line-height: 1.5;
  font-weight: 500;
  position: relative;
  padding-left: 1.5rem;
}

.guideline-item::before {
  content: '👉';
  position: absolute;
  left: 0;
  top: 0;
  font-size: 0.9rem;
}

.completion-info {
  background: var(--vp-c-green-soft);
  border: 1px solid var(--vp-c-green-light);
  border-radius: 8px;
  padding: 1rem 1.5rem;
  margin-bottom: 2rem;
}

.completion-info-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.completion-icon {
  font-size: 1.1rem;
}

.completion-text {
  color: var(--vp-c-green-darker);
  font-weight: 500;
  font-size: 0.95rem;
}

.fields-container {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.field-group {
  border: 1px solid var(--vp-c-divider-light);
  border-radius: 8px;
  padding: 1.5rem;
  transition: all 0.2s;
}

.field-group:hover {
  border-color: var(--vp-c-divider);
  box-shadow: 0 2px 4px var(--vp-c-shadow-1);
}

.field-header {
  margin-bottom: 1rem;
}

.field-label {
  display: block;
  font-weight: 600;
  color: var(--vp-c-text-1);
  margin-bottom: 0.5rem;
  font-size: 1rem;
}

.required {
  color: var(--vp-c-red-1);
}

.field-instructions {
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
  font-style: italic;
  line-height: 1.4;
}

.field-input {
  width: 100%;
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  padding: 0.75rem;
  font-size: 0.95rem;
  transition: all 0.2s;
  font-family: inherit;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
}

.field-input:focus {
  outline: none;
  border-color: var(--vp-c-brand-1);
  box-shadow: 0 0 0 3px var(--vp-c-brand-soft);
}

.text-input {
  height: 42px;
}

.textarea-input {
  min-height: 100px;
  resize: vertical;
  line-height: 1.5;
}

.checkbox-input {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  cursor: pointer;
  font-size: 0.95rem;
  color: var(--vp-c-text-1);
}

.checkbox-input input[type="checkbox"] {
  width: 18px;
  height: 18px;
  accent-color: var(--vp-c-brand-1);
}

.completion-celebration {
  background: linear-gradient(135deg, var(--vp-c-green-soft) 0%, var(--vp-c-green-light) 100%);
  border: 1px solid var(--vp-c-green-light);
  border-radius: 12px;
  padding: 2rem;
  margin-top: 2rem;
  text-align: center;
}

.celebration-content {
  max-width: 400px;
  margin: 0 auto;
}

.celebration-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.completion-celebration h3 {
  margin: 0 0 0.5rem 0;
  color: var(--vp-c-green-1);
  font-size: 1.25rem;
}

.completion-celebration p {
  margin: 0 0 1rem 0;
  color: var(--vp-c-green-darker);
}

.completion-time {
  font-size: 0.85rem;
  color: var(--vp-c-green-darker);
  font-weight: 500;
}

/* Responsive design */
@media (max-width: 768px) {
  .section-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }


  .section-content {
    padding: 1rem;
  }

  .field-group {
    padding: 1rem;
  }

  .section-intro :deep(.intro-columns) {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
}

</style>