<template>
  <div class="workbook-container">
    <!-- Authentication Required Landing Page -->
    <div v-if="!user" class="auth-required">
      <div class="auth-hero">
        <div class="auth-hero-content">
          <div class="auth-icon">
            <ClipboardDocumentCheckIcon class="auth-icon-svg" aria-hidden="true" />
          </div>
          <h1>Interactive Coaching Business Workbook</h1>
          <p class="auth-subtitle">Build your stand-out coaching business step by step with our comprehensive interactive workbook</p>
          
          <div class="auth-features-grid">
            <div class="auth-feature">
              <div class="auth-feature-icon">
                <BookmarkIcon class="feature-icon-svg" aria-hidden="true" />
              </div>
              <h3>9 Key Business Areas</h3>
              <p>Comprehensive coverage from finding your niche to social media strategy</p>
            </div>
            <div class="auth-feature">
              <div class="auth-feature-icon">
                <CloudArrowUpIcon class="feature-icon-svg" aria-hidden="true" />
              </div>
              <h3>Auto-Save Progress</h3>
              <p>Work at your own pace - your progress is automatically saved as you go</p>
            </div>
            <div class="auth-feature">
              <div class="auth-feature-icon">
                <ChartBarIcon class="feature-icon-svg" aria-hidden="true" />
              </div>
              <h3>Track Your Journey</h3>
              <p>Visual progress tracking and completion analytics for each section</p>
            </div>
          </div>
          
          <div class="auth-cta-section">
            <a href="/docs/auth/?redirect=/docs/profile/interactive-workbook" class="auth-cta-btn">
              <span>Get Started Now</span>
              <span class="auth-cta-arrow">→</span>
            </a>
            <p class="auth-cta-note">Start building your coaching business today</p>
          </div>
        </div>
        
        <div class="auth-preview">
          <div class="preview-card">
            <div class="preview-header">
              <div class="preview-icon">
                <ClipboardDocumentCheckIcon class="preview-icon-svg" aria-hidden="true" />
              </div>
              <div class="preview-info">
                <h4>Kickstart Coaching Workbook</h4>
                <span>9 sections • Self-paced • Business Development</span>
              </div>
            </div>
            <div class="preview-content">
              <div class="preview-sections">
                <div class="preview-section">1. What's So Special About YOU? (Part A)</div>
                <div class="preview-section">2. What's So Special About YOU? (Part B)</div>
                <div class="preview-section">3. Your Ideal Client</div>
                <div class="preview-section">4. Creating Your Stand-Out Brand</div>
                <div class="preview-section">5. Creating Your Avatar</div>
                <div class="preview-section">6. Product • Price • Value</div>
                <div class="preview-section">7. Freemium Product Funnel</div>
                <div class="preview-section">8. Getting Your Message Out There</div>
                <div class="preview-section">9. Social Media & Networking</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Authenticated Workbook Content -->
    <div v-else>
      <!-- Header with progress overview -->
      <div class="workbook-header">
        <div class="header-content">
          <h1>{{ workbookData?.title || 'Interactive Workbook' }}</h1>
          <p class="subtitle">Build your stand-out coaching business step by step</p>
          <div class="overall-progress">
            <div class="progress-bar">
              <div 
                class="progress-fill" 
                :style="{ width: `${overallProgress}%` }"
              ></div>
            </div>
            <span class="progress-text">{{ overallProgress }}% Complete</span>
          </div>
        </div>
        <div class="header-actions">
          <button
            v-if="workbookData && !workbookData.added_to_profile"
            @click="addToProfile"
            class="btn-secondary btn-with-icon"
          >
            <MapPinIcon class="btn-icon" aria-hidden="true" />
            <span>Add to Profile</span>
          </button>
          <div
            v-else-if="workbookData && workbookData.added_to_profile"
            class="profile-status-controls"
          >
            <div class="profile-added-indicator">
              <CheckCircleIcon class="status-icon success" aria-hidden="true" />
              <span>Added to Profile</span>
            </div>
            <button
              @click="removeFromProfile"
              class="btn-remove-profile"
              title="Remove from profile dashboard"
            >
              <XCircleIcon class="remove-icon" aria-hidden="true" />
            </button>
          </div>
        </div>
      </div>

      <!-- Mobile Section Navigation Toggle -->
      <div class="mobile-nav-toggle" v-if="isMobile">
        <button
          @click="toggleMobileSidebar"
          class="mobile-nav-btn"
          :class="{ 'active': showMobileSidebar }"
        >
          <Bars3Icon class="nav-icon-svg" aria-hidden="true" />
          <span class="nav-text">
            Section {{ currentSection }}/{{ sections.length }}
            <span class="completion-badge">{{ overallProgress }}% Complete</span>
          </span>
          <span class="nav-arrow" :class="{ 'open': showMobileSidebar }">▼</span>
        </button>
      </div>

      <!-- Main content area -->
      <div class="workbook-main" :class="{ 'mobile-sidebar-open': showMobileSidebar && isMobile }">
        <!-- Sidebar with section navigation -->
        <WorkbookSidebar 
          :sections="sections"
          :current-section="currentSection"
          @section-change="handleSectionChange"
          @close-sidebar="closeMobileSidebar"
          :class="[
            'workbook-sidebar',
            { 'mobile-open': showMobileSidebar && isMobile }
          ]"
        />

        <!-- Mobile Sidebar Overlay -->
        <div 
          v-if="isMobile && showMobileSidebar" 
          class="mobile-sidebar-overlay"
          @click="closeMobileSidebar"
        ></div>

        <!-- Content area -->
        <div class="workbook-content">
          <WorkbookSection
            v-if="currentSectionData"
            :section="currentSectionData"
            :fields="currentSectionFields"
            :responses="sectionResponses"
            @field-updated="handleFieldUpdate"
            @field-blur="handleFieldBlur"
            @section-completed="handleSectionCompleted"
          />

          <!-- Complete workbook button -->
          <div v-if="currentSection === sections.length && allSectionsCompleted" class="completion-section">
            <div class="completion-message">
              <h3 class="completion-heading">
                <SparklesIcon class="celebration-icon" aria-hidden="true" />
                All sections completed!
              </h3>
              <p>You've finished your interactive workbook. Ready to finalize?</p>
            </div>
            <button
              @click="completeWorkbook"
              class="btn-success btn-large btn-with-icon"
            >
              <span>Complete Workbook</span>
              <SparklesIcon class="btn-icon" aria-hidden="true" />
            </button>
          </div>
        </div>
      </div>

      <!-- Loading overlay -->
      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner"></div>
        <p>Loading your workbook...</p>
      </div>

      <!-- Save status indicator -->
      <div v-if="saveStatus" class="save-status" :class="saveStatus">
        <span v-if="saveStatus === 'saving'">Saving...</span>
        <span v-if="saveStatus === 'saved'" class="status-with-icon">
          <CheckCircleIcon class="save-status-icon" aria-hidden="true" />
          Saved
        </span>
        <span v-if="saveStatus === 'error'" class="status-with-icon">
          <XCircleIcon class="save-status-icon" aria-hidden="true" />
          Save failed
        </span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, watch } from 'vue'
import { useSupabase } from '../../composables/useSupabase.js'
import { useAuth } from '../../composables/useAuth.js'
import WorkbookSidebar from '../../components/workbook/WorkbookSidebar.vue'
import WorkbookSection from '../../components/workbook/WorkbookSection.vue'
import { useWorkbook } from '../../composables/useWorkbook.js'
import {
  ClipboardDocumentCheckIcon,
  BookmarkIcon,
  CloudArrowUpIcon,
  ChartBarIcon,
  CheckCircleIcon,
  XCircleIcon,
  Bars3Icon,
  SparklesIcon,
  MapPinIcon
} from '@heroicons/vue/24/outline'

// Composables
const { supabase } = useSupabase()
const { user } = useAuth()
const { 
  workbookData, 
  sections, 
  fieldDefinitions, 
  responses, 
  loading, 
  saveStatus,
  initializeWorkbook,
  queueFieldChange,
  saveOnFieldBlur,
  saveOnSectionChange,
  calculateProgress,
  cleanup
} = useWorkbook()

// Reactive state
const currentSection = ref(1)
const showMobileSidebar = ref(false)
const isMobile = ref(false)

// Computed properties
const overallProgress = computed(() => {
  if (!sections.value?.length) return 0
  const totalProgress = sections.value.reduce((sum, section) => sum + section.progress_percent, 0)
  return Math.round(totalProgress / sections.value.length)
})

const currentSectionData = computed(() => {
  // Find section by display index (position in the formatted array)
  return sections.value?.[currentSection.value - 1]
})

const currentSectionFields = computed(() => {
  // Get the actual database section number from the current section data
  const actualSectionNumber = currentSectionData.value?.section_number
  return fieldDefinitions.value?.filter(f => f.section_number === actualSectionNumber) || []
})

const sectionResponses = computed(() => {
  // Get the actual database section number from the current section data
  const actualSectionNumber = currentSectionData.value?.section_number
  return responses.value?.filter(r => r.section_number === actualSectionNumber) || []
})

const allSectionsCompleted = computed(() => {
  return sections.value?.every(s => s.progress_percent === 100) || false
})

// Methods
const checkIsMobile = () => {
  isMobile.value = window.innerWidth <= 768
}

const toggleMobileSidebar = () => {
  showMobileSidebar.value = !showMobileSidebar.value
}

const closeMobileSidebar = () => {
  showMobileSidebar.value = false
}

const handleSectionChange = async (sectionNumber) => {
  // Close mobile sidebar when section changes
  if (isMobile.value) {
    showMobileSidebar.value = false
  }
  await goToSection(sectionNumber)
}

const goToSection = async (sectionNumber) => {
  // Save any pending changes before switching sections
  await saveOnSectionChange()
  
  currentSection.value = sectionNumber
  // Update URL without page reload
  window.history.replaceState({}, '', `#section-${sectionNumber}`)
}

const handleFieldUpdate = (fieldKey, value, fieldType) => {
  // Just queue the change, don't save immediately
  const actualSectionNumber = currentSectionData.value?.section_number
  queueFieldChange(actualSectionNumber, fieldKey, value, fieldType)
}

const handleFieldBlur = async () => {
  // Save when field loses focus
  await saveOnFieldBlur()
  
  // Recalculate progress for current section
  const actualSectionNumber = currentSectionData.value?.section_number
  await calculateProgress(actualSectionNumber)
}

const handleSectionCompleted = async (sectionNumber) => {
  // sectionNumber here should be the actual database section number
  await calculateProgress(sectionNumber)
  // Celebrate completion with a brief animation
  showCompletionCelebration()
}

const addToProfile = async () => {
  try {
    const { error } = await supabase
      .from('workbook_progress')
      .update({ added_to_profile: true })
      .eq('id', workbookData.value.id)
    
    if (!error) {
      workbookData.value.added_to_profile = true
      // Show success message
      showMessage('Workbook added to your profile dashboard!', 'success')
    }
  } catch (error) {
    console.error('Error adding to profile:', error)
    showMessage('Failed to add to profile', 'error')
  }
}

const removeFromProfile = async () => {
  try {
    const { error } = await supabase
      .from('workbook_progress')
      .update({ added_to_profile: false })
      .eq('id', workbookData.value.id)
    
    if (!error) {
      workbookData.value.added_to_profile = false
      // Show success message
      showMessage('Workbook removed from your profile dashboard', 'success')
    }
  } catch (error) {
    console.error('Error removing from profile:', error)
    showMessage('Failed to remove from profile', 'error')
  }
}


const completeWorkbook = async () => {
  try {
    const { error } = await supabase
      .from('workbook_progress')
      .update({ completed_at: new Date().toISOString() })
      .eq('id', workbookData.value.id)
    
    if (!error) {
      workbookData.value.completed_at = new Date().toISOString()
      showCompletionCelebration()
      showMessage('🎉 Congratulations! You\'ve completed your workbook!', 'success')
    }
  } catch (error) {
    console.error('Error completing workbook:', error)
  }
}

const showCompletionCelebration = () => {
  // Add celebration animation class
  const container = document.querySelector('.workbook-container')
  container?.classList.add('celebration')
  setTimeout(() => {
    container?.classList.remove('celebration')
  }, 2000)
}

const showMessage = (message, type = 'info') => {
  // Simple message display - could be enhanced with a toast system
  const messageEl = document.createElement('div')
  messageEl.className = `message message-${type}`
  messageEl.textContent = message
  messageEl.style.cssText = `
    position: fixed;
    top: 20px;
    right: 20px;
    padding: 12px 20px;
    background: ${type === 'success' ? '#10b981' : type === 'error' ? '#ef4444' : '#3b82f6'};
    color: white;
    border-radius: 8px;
    z-index: 1000;
    font-weight: 500;
  `
  document.body.appendChild(messageEl)
  setTimeout(() => {
    messageEl.remove()
  }, 3000)
}

// Initialize workbook on mount
onMounted(async () => {
  // Check mobile status initially
  checkIsMobile()
  
  // Add resize listener
  window.addEventListener('resize', checkIsMobile)
  
  if (user.value) {
    await initializeWorkbook()
    
    // Check URL hash for section navigation after sections are loaded
    const hash = window.location.hash
    if (hash.startsWith('#section-')) {
      const sectionNum = parseInt(hash.replace('#section-', ''))
      if (sectionNum >= 1 && sectionNum <= 9) { // We have 9 display sections
        currentSection.value = sectionNum
      }
    }
  }
})

// Watch for user login
watch(user, async (newUser) => {
  if (newUser && !workbookData.value) {
    await initializeWorkbook()
  }
})

// Cleanup on unmount
onBeforeUnmount(() => {
  window.removeEventListener('resize', checkIsMobile)
  cleanup()
})
</script>

<style scoped>
.workbook-container {
  min-height: 100vh;
  background: var(--vp-c-bg);
  position: relative;
}

.workbook-header {
  max-width: 1200px;
  margin: 0 auto;
  background: var(--vp-c-bg-soft);
  padding: 2rem;
  border-bottom: 1px solid var(--vp-c-divider);
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 1px 3px var(--vp-c-shadow-1);
  border-radius: 12px;
  margin-bottom: 2rem;
  margin-top: 2rem;
}

.header-content h1 {
  margin: 0 0 0.5rem 0;
  color: var(--vp-c-text-1);
  font-size: 2rem;
  font-weight: 700;
}

.subtitle {
  margin: 0 0 1rem 0;
  color: var(--vp-c-text-2);
  font-size: 1.1rem;
}

.overall-progress {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.progress-bar {
  width: 200px;
  height: 10px;
  background: var(--vp-c-bg-mute);
  border: 1px solid var(--vp-c-divider);
  border-radius: 5px;
  overflow: hidden;
  box-shadow: inset 0 1px 2px var(--vp-c-shadow-1);
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--vp-c-brand-1) 0%, var(--vp-c-brand-2) 100%);
  transition: width 0.3s ease;
}

.progress-text {
  font-weight: 600;
  color: var(--vp-c-text-1);
  font-size: 0.9rem;
  padding: 3px 8px;
  background: var(--vp-c-bg-alt);
  border: 1px solid var(--vp-c-divider-light);
  border-radius: 6px;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.profile-status-controls {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.profile-added-indicator {
  padding: 0.5rem 1rem;
  background: var(--vp-c-green-soft);
  color: var(--vp-c-green-1);
  border-radius: 6px;
  font-weight: 600;
  font-size: 0.85rem;
  border: 1px solid var(--vp-c-green-light);
  height: 36px;
  display: flex;
  align-items: center;
}

.btn-remove-profile {
  width: 36px;
  height: 36px;
  border: 1px solid var(--vp-c-red-light);
  background: var(--vp-c-red-soft);
  color: var(--vp-c-red-1);
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 0.85rem;
}

.btn-remove-profile:hover {
  background: var(--vp-c-red-1);
  color: var(--vp-c-white);
}

.workbook-main {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem 4rem 2rem;
  display: flex;
  min-height: calc(100vh - 200px);
}

.workbook-sidebar {
  width: 300px;
  flex-shrink: 0;
}

.workbook-content {
  flex: 1;
  padding: 0 2rem 2rem 2rem;
  display: flex;
  flex-direction: column;
}

.completion-section {
  margin-top: 3rem;
  padding: 2rem;
  background: linear-gradient(135deg, var(--vp-c-green-soft) 0%, var(--vp-c-green-light) 100%);
  border: 1px solid var(--vp-c-green-light);
  border-radius: 12px;
  text-align: center;
  box-shadow: 0 4px 12px var(--vp-c-shadow-2);
}

.completion-message {
  margin-bottom: 1.5rem;
}

.completion-message h3 {
  margin: 0 0 0.5rem 0;
  color: var(--vp-c-green-1);
  font-size: 1.5rem;
  font-weight: 700;
}

.completion-message p {
  margin: 0;
  color: var(--vp-c-green-darker);
  font-size: 1.1rem;
}

.btn-primary, .btn-secondary, .btn-success {
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-weight: 600;
  transition: all 0.2s;
  border: none;
  cursor: pointer;
  font-size: 0.95rem;
}

.btn-primary {
  background: var(--vp-c-brand-1);
  color: var(--vp-c-white);
}

.btn-primary:hover {
  background: var(--vp-c-brand-2);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px var(--vp-c-shadow-2);
}

.btn-secondary {
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  border: 1px solid var(--vp-c-divider);
}

.btn-secondary:hover {
  background: var(--vp-c-bg-mute);
  border-color: var(--vp-c-divider-light);
}

.btn-success {
  background: var(--vp-c-green-1);
  color: var(--vp-c-white);
}

.btn-success:hover {
  background: var(--vp-c-green-2);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px var(--vp-c-shadow-2);
}

.btn-large {
  padding: 1rem 2rem;
  font-size: 1.1rem;
  font-weight: 700;
}

.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: var(--vp-c-backdrop);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid var(--vp-c-divider);
  border-top: 3px solid var(--vp-c-brand-1);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.save-status {
  position: fixed;
  bottom: 20px;
  right: 20px;
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 0.85rem;
  font-weight: 500;
  z-index: 100;
  transition: all 0.3s;
}

.save-status.saving {
  background: var(--vp-c-yellow-1);
  color: var(--vp-c-yellow-darker);
}

.save-status.saved {
  background: var(--vp-c-green-1);
  color: var(--vp-c-white);
}

.save-status.error {
  background: var(--vp-c-red-1);
  color: var(--vp-c-white);
}

.celebration {
  animation: celebrate 2s ease-in-out;
}

@keyframes celebrate {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.02); }
}

/* Mobile Navigation Toggle */
.mobile-nav-toggle {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
  margin-bottom: 1rem;
}

.mobile-nav-btn {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s;
  color: var(--vp-c-text-1);
  font-size: 0.95rem;
}

.mobile-nav-btn:hover {
  background: var(--vp-c-bg-alt);
  border-color: var(--vp-c-brand-1);
}

.mobile-nav-btn.active {
  background: var(--vp-c-brand-soft);
  border-color: var(--vp-c-brand-1);
  color: var(--vp-c-brand-1);
}

.nav-icon {
  font-size: 1.2rem;
  font-weight: bold;
}

.nav-text {
  flex: 1;
  margin: 0 1rem;
  text-align: left;
  font-weight: 600;
}

.completion-badge {
  display: block;
  font-size: 0.8rem;
  font-weight: 500;
  color: var(--vp-c-text-2);
  margin-top: 0.25rem;
}

.nav-arrow {
  font-size: 0.8rem;
  transition: transform 0.3s;
}

.nav-arrow.open {
  transform: rotate(180deg);
}

/* Mobile Sidebar Overlay */
.mobile-sidebar-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 1000;
  backdrop-filter: blur(2px);
}

/* Responsive design */
@media (max-width: 768px) {
  .workbook-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
    margin: 1rem;
    padding: 1.5rem;
  }

  .header-content h1 {
    font-size: 1.5rem;
  }

  .subtitle {
    font-size: 1rem;
  }

  .overall-progress {
    width: 100%;
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }

  .progress-bar {
    width: 100%;
  }

  .header-actions {
    width: 100%;
    flex-direction: column;
    align-items: stretch;
    gap: 0.5rem;
  }

  .header-actions > * {
    width: 100%;
    justify-content: center;
  }

  .workbook-main {
    position: relative;
    padding: 0 1rem;
    min-height: auto;
  }

  .workbook-sidebar {
    position: fixed;
    top: 0;
    left: -100%;
    width: 85%;
    max-width: 320px;
    height: 100vh;
    z-index: 1001;
    transition: left 0.3s ease;
    background: var(--vp-c-bg-soft);
    box-shadow: 4px 0 12px rgba(0, 0, 0, 0.15);
    overflow-y: auto;
  }

  .workbook-sidebar.mobile-open {
    left: 0;
  }

  .workbook-content {
    width: 100%;
    padding: 1rem;
    margin-left: 0;
  }

  .completion-section {
    margin-top: 2rem;
    padding: 1.5rem;
  }

  /* Prevent body scroll when sidebar is open */
  .mobile-sidebar-open {
    overflow: hidden;
  }
}

/* Tablet responsive adjustments */
@media (max-width: 1024px) and (min-width: 769px) {
  .workbook-sidebar {
    width: 280px;
  }

  .workbook-content {
    padding: 1rem 1.5rem;
  }

  .workbook-header {
    margin: 1.5rem;
    padding: 1.5rem;
  }
}

/* Small mobile devices */
@media (max-width: 480px) {
  .workbook-header {
    margin: 0.5rem;
    padding: 1rem;
  }

  .header-content h1 {
    font-size: 1.25rem;
  }

  .mobile-nav-btn {
    padding: 0.75rem;
    font-size: 0.9rem;
  }

  .nav-text {
    font-size: 0.85rem;
  }

  .completion-badge {
    font-size: 0.75rem;
  }

  .workbook-sidebar {
    width: 90%;
  }

  .workbook-content {
    padding: 0.75rem;
  }
  
  /* Improve touch targets for small screens */
  .mobile-nav-btn {
    min-height: 48px;
    touch-action: manipulation;
  }
  
  /* Ensure text is readable on small screens */
  .nav-text {
    line-height: 1.3;
  }
  
  /* Better spacing for cramped layouts */
  .mobile-nav-toggle {
    padding: 0 0.5rem;
  }
}

/* Extra small mobile devices */
@media (max-width: 360px) {
  .workbook-header {
    margin: 0.25rem;
    padding: 0.75rem;
  }

  .header-content h1 {
    font-size: 1.1rem;
  }

  .mobile-nav-btn {
    padding: 0.5rem;
    font-size: 0.85rem;
  }

  .nav-text {
    font-size: 0.8rem;
  }

  .completion-badge {
    font-size: 0.7rem;
  }

  .workbook-content {
    padding: 0.5rem;
  }
}

/* Authentication Landing Page Styles */
.auth-required {
  min-height: 100vh;
  background: var(--vp-c-bg);
}

.auth-hero {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4rem;
  max-width: 1200px;
  margin: 0 auto;
  padding: 4rem 2rem;
  align-items: center;
}

.auth-hero-content {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.auth-icon {
  margin-bottom: 1rem;
}

.auth-icon-svg {
  width: 4rem;
  height: 4rem;
  color: var(--vp-c-brand-1);
}

.dark .auth-icon-svg {
  color: #818cf8;
}

.auth-hero h1 {
  font-size: 2.5rem;
  font-weight: 700;
  color: var(--vp-c-text-1);
  margin: 0;
  line-height: 1.2;
}

.auth-subtitle {
  font-size: 1.25rem;
  color: var(--vp-c-text-2);
  margin: 0;
  line-height: 1.4;
}

.auth-features-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
  margin: 2rem 0;
}

.auth-feature {
  padding: 1.5rem;
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
  border: 1px solid var(--vp-c-divider-light);
}

.auth-feature-icon {
  margin-bottom: 0.75rem;
}

.feature-icon-svg {
  width: 2rem;
  height: 2rem;
  color: var(--vp-c-brand-1);
}

.dark .feature-icon-svg {
  color: #818cf8;
}

.auth-feature h3 {
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
  margin: 0 0 0.5rem 0;
}

.auth-feature p {
  font-size: 0.95rem;
  color: var(--vp-c-text-2);
  margin: 0;
  line-height: 1.4;
}

.auth-cta-section {
  text-align: center;
  margin-top: 2rem;
}

.auth-cta-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem 2rem;
  background: linear-gradient(135deg, var(--vp-c-brand-1) 0%, var(--vp-c-brand-2) 100%);
  color: var(--vp-c-white);
  text-decoration: none;
  border-radius: 12px;
  font-size: 1.1rem;
  font-weight: 600;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px var(--vp-c-shadow-2);
}

.auth-cta-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px var(--vp-c-shadow-2);
}

.auth-cta-arrow {
  font-size: 1.2rem;
  transition: transform 0.3s ease;
}

.auth-cta-btn:hover .auth-cta-arrow {
  transform: translateX(4px);
}

.auth-cta-note {
  margin: 1rem 0 0 0;
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
}

.auth-preview {
  display: flex;
  justify-content: center;
  align-items: center;
}

.preview-card {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 12px var(--vp-c-shadow-1);
  max-width: 400px;
  width: 100%;
}

.preview-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.5rem;
  background: var(--vp-c-bg-alt);
  border-bottom: 1px solid var(--vp-c-divider-light);
}

.preview-icon {
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--vp-c-brand-soft);
  border-radius: 8px;
}

.preview-icon-svg {
  width: 1.75rem;
  height: 1.75rem;
  color: var(--vp-c-brand-1);
}

.dark .preview-icon-svg {
  color: #818cf8;
}

.preview-info h4 {
  margin: 0 0 0.25rem 0;
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.preview-info span {
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
}

.preview-content {
  padding: 1.5rem;
}

.preview-sections {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.preview-section {
  padding: 0.75rem 1rem;
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-divider-light);
  border-radius: 8px;
  font-size: 0.9rem;
  color: var(--vp-c-text-1);
  transition: all 0.2s;
}

.preview-section:hover {
  background: var(--vp-c-bg-alt);
  border-color: var(--vp-c-brand-1);
}

/* Responsive design for auth page */
@media (max-width: 768px) {
  .auth-hero {
    grid-template-columns: 1fr;
    gap: 2rem;
    padding: 2rem 1rem;
  }
  
  .auth-hero h1 {
    font-size: 2rem;
  }
  
  .auth-subtitle {
    font-size: 1.1rem;
  }
  
  .auth-features-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
    margin: 1.5rem 0;
  }
  
  .auth-feature {
    padding: 1rem;
  }
  
  .preview-card {
    max-width: 100%;
  }
}

/* ================================================
   HEROICON STYLES
   ================================================ */

/* Button with icon styles */
.btn-with-icon {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-icon {
  width: 1.25rem;
  height: 1.25rem;
  flex-shrink: 0;
}

/* Profile status icons */
.status-icon {
  width: 1.25rem;
  height: 1.25rem;
  flex-shrink: 0;
}

.status-icon.success {
  color: var(--vp-c-green-1);
}

.dark .status-icon.success {
  color: #4ade80;
}

.profile-added-indicator {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

/* Remove button icon */
.remove-icon {
  width: 1.25rem;
  height: 1.25rem;
}

/* Mobile nav icon */
.nav-icon-svg {
  width: 1.5rem;
  height: 1.5rem;
  color: var(--vp-c-text-1);
  flex-shrink: 0;
}

.mobile-nav-btn.active .nav-icon-svg {
  color: var(--vp-c-brand-1);
}

.dark .nav-icon-svg {
  color: var(--vp-c-text-1);
}

.dark .mobile-nav-btn.active .nav-icon-svg {
  color: #818cf8;
}

/* Celebration/completion icons */
.completion-heading {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.celebration-icon {
  width: 2rem;
  height: 2rem;
  color: var(--vp-c-yellow-1);
}

.dark .celebration-icon {
  color: #fbbf24;
}

/* Save status icons */
.status-with-icon {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
}

.save-status-icon {
  width: 1rem;
  height: 1rem;
}

.save-status.saved .save-status-icon {
  color: var(--vp-c-white);
}

.save-status.error .save-status-icon {
  color: var(--vp-c-white);
}
</style>