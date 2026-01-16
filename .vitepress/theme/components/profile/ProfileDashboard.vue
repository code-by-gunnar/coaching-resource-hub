<template>
  <div class="profile-dashboard">
    <!-- Progress Stats -->
    <ProgressStats 
      :total-hours="totalHours" 
      :study-sessions="studySessions"
      :learning-logs="learningLogs"
      :assessment-stats="assessmentStats"
    />


    <!-- Action Cards -->
    <div class="profile-sections">
      <div class="section-card">
        <h3>📖 Study Logs</h3>
        <p>Track your self-study activities and progress</p>
        <ActionButton @click="$emit('navigate', 'logs')" full-width>View Study Logs</ActionButton>
      </div>

      <div class="section-card">
        <h3>💭 Learning Logs</h3>
        <p>Document your learning insights and growth</p>
        <ActionButton @click="$emit('navigate', 'learningLogs')" full-width>View Learning Logs</ActionButton>
      </div>

      <div class="section-card">
        <h3>🎯 Assessments</h3>
        <p>View your assessments, continue in-progress, and review results</p>
        <ActionButton href="/docs/assessments/results" full-width>View Assessments</ActionButton>
      </div>

      <!-- Conditional Interactive Workbook Card -->
      <div v-if="showWorkbookCard" class="section-card">
        <h3>📋 Interactive Workbook</h3>
        <p>Build your coaching business step by step with our interactive workbook</p>
        <div class="workbook-progress" v-if="workbookProgress">
          <div class="progress-indicator">
            <div class="progress-bar">
              <div class="progress-fill" :style="{ width: `${workbookProgress}%` }"></div>
            </div>
            <span class="progress-text">{{ workbookProgress }}% complete</span>
          </div>
        </div>
        <ActionButton href="/docs/profile/interactive-workbook" full-width>Continue Workbook</ActionButton>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, inject, watch } from 'vue'
import { useSupabase } from '../../composables/useSupabase.js'
import ProgressStats from './shared/ProgressStats.vue'

const props = defineProps({
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

defineEmits(['navigate'])

// Get user and refresh function from parent Profile component
const user = inject('user')
const refreshData = inject('refreshData')
const { supabase } = useSupabase()

// Workbook profile integration state
const workbookData = ref(null)
const workbookSections = ref([])

// Check if workbook should be shown in profile
const showWorkbookCard = computed(() => {
  return workbookData.value && workbookData.value.added_to_profile
})

// Calculate overall workbook progress
const workbookProgress = computed(() => {
  if (!workbookSections.value?.length) return 0
  const totalProgress = workbookSections.value.reduce((sum, section) => sum + section.progress_percent, 0)
  return Math.round(totalProgress / workbookSections.value.length)
})

// Load workbook profile integration status
const loadWorkbookStatus = async () => {
  if (!user.value?.id) return
  
  try {
    // Check if user has an active workbook
    const { data: workbook, error: workbookError } = await supabase
      .from('workbook_progress')
      .select('id, added_to_profile, title, completed_at')
      .eq('user_id', user.value.id)
      .eq('is_active', true)
      .order('created_at', { ascending: false })
      .limit(1)
      .single()
    
    if (workbookError && workbookError.code !== 'PGRST116') {
      console.error('Error loading workbook status:', workbookError)
      return
    }
    
    workbookData.value = workbook
    
    // If workbook exists and is added to profile, load sections for progress
    if (workbook && workbook.added_to_profile) {
      const { data: sections, error: sectionsError } = await supabase
        .from('workbook_sections')
        .select('section_number, progress_percent')
        .eq('workbook_id', workbook.id)
        .order('section_number')
      
      if (!sectionsError) {
        workbookSections.value = sections
      }
    }
  } catch (error) {
    console.error('Error loading workbook profile status:', error)
  }
}

// Load workbook status when component mounts
onMounted(() => {
  loadWorkbookStatus()
})

// Watch for user changes and reload workbook status
watch(user, (newUser) => {
  if (newUser) {
    loadWorkbookStatus()
  }
}, { deep: true })
</script>

<style scoped>
.profile-sections {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
}

.section-card {
  padding: 2rem;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  text-align: center;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.section-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

.section-card h3 {
  margin: 0 0 1rem 0;
  color: var(--vp-c-text-1);
  font-size: 1.2rem;
}

.section-card p {
  margin: 0 0 1rem 0;
  color: var(--vp-c-text-2);
  line-height: 1.5;
}

/* ActionButton spacing in section cards */
.section-card .action-button {
  margin-top: 1rem;
}

/* Workbook progress indicator in profile card */
.workbook-progress {
  margin: 1rem 0;
  padding: 1rem;
  background: var(--vp-c-bg-alt);
  border-radius: 8px;
  border: 1px solid var(--vp-c-divider-light);
}

.progress-indicator {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.workbook-progress .progress-bar {
  flex: 1;
  height: 6px;
  background: var(--vp-c-bg-mute);
  border-radius: 3px;
  overflow: hidden;
}

.workbook-progress .progress-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--vp-c-brand-1) 0%, var(--vp-c-brand-2) 100%);
  transition: width 0.3s ease;
}

.workbook-progress .progress-text {
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--vp-c-brand-1);
  min-width: 60px;
}

@media (max-width: 768px) {
  .profile-sections {
    grid-template-columns: 1fr;
  }
}
</style>