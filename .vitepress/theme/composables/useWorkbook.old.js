/**
 * Interactive Workbook Composable
 * Handles all workbook data management, auto-saving, and progress tracking
 */
import { ref, computed } from 'vue'
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

    } catch (error) {
      console.error('Error initializing workbook:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  /**
   * Save a field response with debouncing
   */
  const saveResponse = async (sectionNumber, fieldKey, value, fieldType) => {
    if (!workbookData.value) return

    // Clear existing timeout for this field
    if (saveTimeout) {
      clearTimeout(saveTimeout)
    }

    // Set saving status immediately
    saveStatus.value = 'saving'

    // Debounce the actual save
    saveTimeout = setTimeout(async () => {
      try {
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

        // Upsert response with proper conflict resolution
        const { error } = await supabase
          .from('workbook_responses')
          .upsert({
            workbook_id: workbookData.value.id,
            section_number: sectionNumber,
            field_key: fieldKey,
            field_value: formattedValue,
            field_type: fieldType,
            updated_at: new Date().toISOString()
          }, {
            onConflict: 'workbook_id,field_key',
            ignoreDuplicates: false
          })

        if (error) throw error

        // Update local responses
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

        saveStatus.value = 'saved'
        
        // Clear save status after 2 seconds
        setTimeout(() => {
          saveStatus.value = null
        }, 2000)

      } catch (error) {
        console.error('Error saving response:', error)
        saveStatus.value = 'error'
        
        // Clear error status after 3 seconds
        setTimeout(() => {
          saveStatus.value = null
        }, 3000)
      }
    }, SAVE_DELAY)
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
   */
  const exportToPDF = async () => {
    if (!workbookData.value) return

    try {
      // Call the PDF generation function
      const { data, error } = await supabase.functions.invoke('generate-workbook-pdf', {
        body: {
          workbookId: workbookData.value.id,
          userEmail: user.value.email
        }
      })

      if (error) throw error

      return data

    } catch (error) {
      console.error('Error exporting workbook:', error)
      throw error
    }
  }

  /**
   * Get section completion status
   */
  const getSectionCompletionStatus = computed(() => {
    const completed = sections.value.filter(s => s.progress_percent === 100).length
    const total = sections.value.length
    return { completed, total, percentage: total > 0 ? Math.round((completed / total) * 100) : 0 }
  })

  /**
   * Get overall workbook completion status
   */
  const isWorkbookCompleted = computed(() => {
    return sections.value.length > 0 && sections.value.every(s => s.progress_percent === 100)
  })

  /**
   * Reset workbook (for testing or starting over)
   */
  const resetWorkbook = async () => {
    if (!workbookData.value) return

    try {
      // Delete all responses
      const { error: responsesError } = await supabase
        .from('workbook_responses')
        .delete()
        .eq('workbook_id', workbookData.value.id)

      if (responsesError) throw responsesError

      // Reset section progress
      const { error: sectionsError } = await supabase
        .from('workbook_sections')
        .update({ 
          progress_percent: 0, 
          completed_at: null,
          last_updated: new Date().toISOString()
        })
        .eq('workbook_id', workbookData.value.id)

      if (sectionsError) throw sectionsError

      // Reset workbook completion
      const { error: workbookError } = await supabase
        .from('workbook_progress')
        .update({ 
          completed_at: null,
          last_updated: new Date().toISOString()
        })
        .eq('id', workbookData.value.id)

      if (workbookError) throw workbookError

      // Refresh data
      await initializeWorkbook()

    } catch (error) {
      console.error('Error resetting workbook:', error)
      throw error
    }
  }

  return {
    // State
    workbookData,
    sections,
    fieldDefinitions,
    responses,
    loading,
    saveStatus,

    // Computed
    getSectionCompletionStatus,
    isWorkbookCompleted,

    // Methods
    initializeWorkbook,
    saveResponse,
    calculateProgress,
    getFieldResponse,
    exportToPDF,
    resetWorkbook
  }
}