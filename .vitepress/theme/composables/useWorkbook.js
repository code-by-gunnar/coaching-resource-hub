/**
 * Interactive Workbook Composable with Event-Based Autosave
 * Saves on: field blur, section change, periodic interval, window unload
 */
import { ref, computed, onBeforeUnmount, onMounted } from 'vue'
import { useSupabase } from './useSupabase.js'
import { useAuth } from './useAuth.js'

const workbookData = ref(null)
const sectionsRaw = ref([])
const fieldDefinitions = ref([])
const responses = ref([])
const loading = ref(false)
const saveStatus = ref(null)

// Computed property to display sections with 1A/1B labeling
const sections = computed(() => {
  if (!sectionsRaw.value?.length) return []
  
  // Create a copy and add display formatting
  const formatted = []
  
  // Add Section 1 (1A) 
  const section1 = sectionsRaw.value.find(s => s.section_number === 1)
  if (section1) {
    formatted.push({
      ...section1,
      display_number: '1A',
      display_title: section1.section_title
    })
  }
  
  // Add Section 2 (1B) - What's So Special About YOU? Part B
  const section2 = sectionsRaw.value.find(s => s.section_number === 2)
  if (section2) {
    formatted.push({
      ...section2,
      display_number: '1B', 
      display_title: section2.section_title
    })
  }
  
  // Add remaining sections (3-9) maintaining their actual section numbers for field mapping
  for (let i = 3; i <= 9; i++) {
    const section = sectionsRaw.value.find(s => s.section_number === i)
    if (section) {
      formatted.push({
        ...section,
        display_number: (i - 1).toString(), // 3->2, 4->3, 5->4, 6->5, 7->6, 8->7, 9->8
        display_title: section.section_title
      })
    }
  }
  
  return formatted
})

export function useWorkbook() {
  const { supabase } = useSupabase()
  const { user } = useAuth()

  // Auto-save management
  let autoSaveInterval = null
  const AUTO_SAVE_INTERVAL = 15000 // Auto-save every 15 seconds
  const pendingChanges = new Map() // Track unsaved changes

  /**
   * Initialize or get existing workbook for current user
   */
  const initializeWorkbook = async () => {
    if (!user.value) return

    loading.value = true
    try {
      // Get or create user's workbook
      const { data: workbookId, error: workbookError } = await supabase
        .rpc('get_or_create_user_workbook', { p_user_id: user.value.id })

      if (workbookError) throw workbookError

      // Fetch workbook progress
      const { data: workbook, error: progressError } = await supabase
        .from('workbook_progress')
        .select('*')
        .eq('id', workbookId)
        .single()

      if (progressError) throw progressError

      workbookData.value = workbook

      // Fetch sections with progress
      const { data: sectionsData, error: sectionsError } = await supabase
        .from('workbook_sections')
        .select('*')
        .eq('workbook_id', workbookId)
        .order('section_number')

      if (sectionsError) throw sectionsError

      sectionsRaw.value = sectionsData

      // Fetch field definitions
      const { data: fieldsData, error: fieldsError } = await supabase
        .from('workbook_field_definitions')
        .select('*')
        .order('section_number, sort_order')

      if (fieldsError) throw fieldsError

      fieldDefinitions.value = fieldsData

      // Fetch existing responses
      const { data: responsesData, error: responsesError } = await supabase
        .from('workbook_responses')
        .select('*')
        .eq('workbook_id', workbookId)

      if (responsesError) throw responsesError

      responses.value = responsesData

      // Start periodic auto-save
      startAutoSave()

      // Add window unload listener
      window.addEventListener('beforeunload', handleWindowUnload)

    } catch (error) {
      console.error('Error initializing workbook:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  /**
   * Queue a field change for saving (called on every input)
   */
  const queueFieldChange = (sectionNumber, fieldKey, value, fieldType) => {
    if (!workbookData.value) return

    // Format value based on field type
    let formattedValue
    switch (fieldType) {
      case 'text':
      case 'textarea':
        formattedValue = { value: value || '' }
        break
      case 'list':
        formattedValue = { items: Array.isArray(value) ? value : [] }
        break
      case 'checkbox':
        formattedValue = { checked: Boolean(value) }
        break
      default:
        formattedValue = { value: value || '' }
    }

    // Add to pending changes
    pendingChanges.set(fieldKey, {
      workbook_id: workbookData.value.id,
      section_number: sectionNumber,
      field_key: fieldKey,
      field_value: formattedValue,
      field_type: fieldType,
      updated_at: new Date().toISOString()
    })

    // Update local responses immediately for UI reactivity
    const existingIndex = responses.value.findIndex(
      r => r.workbook_id === workbookData.value.id && r.field_key === fieldKey
    )

    const responseData = {
      workbook_id: workbookData.value.id,
      section_number: sectionNumber,
      field_key: fieldKey,
      field_value: formattedValue,
      field_type: fieldType,
      updated_at: new Date().toISOString()
    }

    if (existingIndex >= 0) {
      responses.value[existingIndex] = responseData
    } else {
      responses.value.push(responseData)
    }
  }

  /**
   * Save all pending changes to database
   */
  const savePendingChanges = async () => {
    if (pendingChanges.size === 0) return

    saveStatus.value = 'saving'
    
    try {
      // Convert pending changes to array
      const changes = Array.from(pendingChanges.values())
      
      // Batch upsert all changes
      const { error } = await supabase
        .from('workbook_responses')
        .upsert(changes, {
          onConflict: 'workbook_id,field_key',
          ignoreDuplicates: false
        })

      if (error) throw error

      // Clear pending changes after successful save
      pendingChanges.clear()
      saveStatus.value = 'saved'
      
      // Clear save status after 2 seconds
      setTimeout(() => {
        if (saveStatus.value === 'saved') {
          saveStatus.value = null
        }
      }, 2000)

    } catch (error) {
      console.error('Error saving changes:', error)
      saveStatus.value = 'error'
      
      // Clear error status after 3 seconds but keep changes pending
      setTimeout(() => {
        if (saveStatus.value === 'error') {
          saveStatus.value = null
        }
      }, 3000)
    }
  }

  /**
   * Save when field loses focus
   */
  const saveOnFieldBlur = async () => {
    await savePendingChanges()
  }

  /**
   * Save when section changes
   */
  const saveOnSectionChange = async () => {
    await savePendingChanges()
  }

  /**
   * Start periodic auto-save
   */
  const startAutoSave = () => {
    // Clear any existing interval
    if (autoSaveInterval) {
      clearInterval(autoSaveInterval)
    }

    // Set up periodic save
    autoSaveInterval = setInterval(() => {
      savePendingChanges()
    }, AUTO_SAVE_INTERVAL)
  }

  /**
   * Stop auto-save
   */
  const stopAutoSave = () => {
    if (autoSaveInterval) {
      clearInterval(autoSaveInterval)
      autoSaveInterval = null
    }
  }

  /**
   * Handle window unload - save before leaving
   */
  const handleWindowUnload = (event) => {
    if (pendingChanges.size > 0) {
      // Try to save synchronously (best effort)
      savePendingChanges()
      
      // Show browser warning if changes pending
      event.preventDefault()
      event.returnValue = 'You have unsaved changes. Are you sure you want to leave?'
    }
  }

  /**
   * Calculate progress for a specific section
   */
  const calculateProgress = async (sectionNumber) => {
    if (!workbookData.value) return

    try {
      // Call the database function to calculate progress
      const { data: progress, error } = await supabase
        .rpc('calculate_section_progress', {
          p_workbook_id: workbookData.value.id,
          p_section_number: sectionNumber
        })

      if (error) throw error

      // Update local section progress in the raw sections data
      const sectionIndex = sectionsRaw.value.findIndex(s => s.section_number === sectionNumber)
      if (sectionIndex >= 0) {
        sectionsRaw.value[sectionIndex].progress_percent = progress
        sectionsRaw.value[sectionIndex].last_updated = new Date().toISOString()
        
        // Mark as completed if 100%
        if (progress === 100) {
          sectionsRaw.value[sectionIndex].completed_at = new Date().toISOString()
        }
      }

      return progress

    } catch (error) {
      console.error('Error calculating progress:', error)
      return 0
    }
  }

  /**
   * Get response value for a specific field
   */
  const getFieldResponse = (fieldKey) => {
    const response = responses.value.find(r => r.field_key === fieldKey)
    if (!response) return null
    
    switch (response.field_type) {
      case 'text':
      case 'textarea':
        return response.field_value?.value || ''
      case 'list':
        return response.field_value?.items || []
      case 'checkbox':
        return response.field_value?.checked || false
      default:
        return response.field_value?.value || ''
    }
  }

  /**
   * Export workbook to PDF
   * NOTE: Workbook PDF export is a future enhancement.
   * Assessment PDF export is available in usePdfReport.js
   */
  const exportToPDF = async () => {
    // Save any pending changes first
    await savePendingChanges()

    // Workbook PDF export is planned for future release
    // For now, users can use browser print or assessment PDF export
    console.warn('Workbook PDF export is not yet implemented. Use browser print (Ctrl+P) as workaround.')
  }

  /**
   * Reset workbook (clear all responses)
   */
  const resetWorkbook = async () => {
    if (!workbookData.value) return
    
    // Save any pending changes first
    await savePendingChanges()
    
    // Clear all responses
    const { error } = await supabase
      .from('workbook_responses')
      .delete()
      .eq('workbook_id', workbookData.value.id)
    
    if (error) {
      console.error('Error resetting workbook:', error)
      return
    }
    
    // Clear local data
    responses.value = []
    pendingChanges.clear()
    
    // Reset all section progress
    for (const section of sectionsRaw.value) {
      section.progress_percent = 0
      section.completed_at = null
    }
  }

  /**
   * Cleanup on component unmount
   */
  const cleanup = () => {
    // Save any pending changes
    savePendingChanges()
    
    // Stop auto-save
    stopAutoSave()
    
    // Remove event listeners
    window.removeEventListener('beforeunload', handleWindowUnload)
  }

  // Computed properties
  const isWorkbookCompleted = computed(() => {
    return sections.value.every(s => s.progress_percent === 100)
  })

  return {
    // Data
    workbookData,
    sections,
    fieldDefinitions,
    responses,
    loading,
    saveStatus,

    // Computed
    isWorkbookCompleted,

    // Methods
    initializeWorkbook,
    queueFieldChange,
    savePendingChanges,
    saveOnFieldBlur,
    saveOnSectionChange,
    calculateProgress,
    getFieldResponse,
    exportToPDF,
    resetWorkbook,
    cleanup
  }
}