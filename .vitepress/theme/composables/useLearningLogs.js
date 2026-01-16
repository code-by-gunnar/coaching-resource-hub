import { ref, computed } from 'vue'
import { useSupabase } from './useSupabase.js'

export function useLearningLogs() {
  const { supabase } = useSupabase()
  
  const learningLogs = ref([])
  const loading = ref(false)
  const error = ref('')
  
  // Computed values
  const totalLearningLogs = computed(() => learningLogs.value.length)
  
  // Load learning logs for a user
  const loadLearningLogs = async (userId) => {
    if (!userId) {
      console.error('User ID is required to load learning logs')
      return
    }
    
    loading.value = true
    error.value = ''
    
    try {
      console.log('Loading learning logs for user:', userId)
      
      const { data, error: queryError } = await supabase
        .from('learning_logs')
        .select('*')
        .eq('user_id', userId)
        .order('date', { ascending: false })
      
      if (queryError) {
        console.error('Learning logs query error:', queryError)
        throw queryError
      }
      
      console.log('Learning logs loaded:', data)
      learningLogs.value = data || []
    } catch (err) {
      console.error('Error loading learning logs:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }
  
  // Delete a learning log
  const deleteLearningLog = async (id) => {
    if (!confirm('Are you sure you want to delete this learning log?')) {
      return false
    }
    
    try {
      const { error: deleteError } = await supabase
        .from('learning_logs')
        .delete()
        .eq('id', id)
      
      if (deleteError) throw deleteError
      
      // Remove from local state
      learningLogs.value = learningLogs.value.filter(log => log.id !== id)
      return true
    } catch (err) {
      console.error('Error deleting learning log:', err)
      alert('Failed to delete learning log. Please try again.')
      return false
    }
  }

  // Create a new learning log
  const createLearningLog = async (newData) => {
    try {
      const { data, error } = await supabase
        .from('learning_logs')
        .insert(newData)
        .select()
      
      if (error) throw error
      
      // Add to local state
      if (data && data.length > 0) {
        learningLogs.value.unshift(data[0]) // Add to beginning of array
      }
      
      return true
    } catch (err) {
      console.error('Error creating learning log:', err)
      throw err
    }
  }

  // Update a learning log
  const updateLearningLog = async (id, updatedData) => {
    try {
      const { error } = await supabase
        .from('learning_logs')
        .update(updatedData)
        .eq('id', id)
      
      if (error) throw error
      
      // Update local state
      const index = learningLogs.value.findIndex(log => log.id === id)
      if (index !== -1) {
        learningLogs.value[index] = { ...learningLogs.value[index], ...updatedData }
      }
      
      return true
    } catch (err) {
      console.error('Error updating learning log:', err)
      throw err
    }
  }
  
  // Helper functions
  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    })
  }

  const downloadFile = (blob, filename) => {
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = filename
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  }
  
  // Export learning logs as DOCX
  const exportLearningLogs = async () => {
    try {
      const { Document, Packer, Paragraph, HeadingLevel, Table, TableRow, TableCell, WidthType, PageOrientation } = await import('docx')
      
      const doc = new Document({
        styles: {
          default: {
            document: {
              run: {
                font: "Arial",
                size: 22, // 11pt (size is in half-points)
              },
            },
          },
        },
        sections: [{
          properties: {
            page: {
              margin: {
                top: 720,
                right: 720,
                bottom: 720,
                left: 720,
              },
              size: {
                orientation: PageOrientation.LANDSCAPE,
              },
            },
          },
          children: [
            new Paragraph({
              text: "Learning Logs",
              heading: HeadingLevel.HEADING_1,
            }),
            
            new Table({
              width: {
                size: 100,
                type: WidthType.PERCENTAGE,
              },
              rows: [
                // Header row
                new TableRow({
                  children: [
                    new TableCell({
                      children: [new Paragraph({ text: "Activity Name" })],
                      width: { size: 25, type: WidthType.PERCENTAGE },
                    }),
                    new TableCell({
                      children: [new Paragraph({ text: "Date" })],
                      width: { size: 15, type: WidthType.PERCENTAGE },
                    }),
                    new TableCell({
                      children: [new Paragraph({ text: "Learning Reflection" })],
                      width: { size: 60, type: WidthType.PERCENTAGE },
                    }),
                  ],
                }),
                // Data rows
                ...learningLogs.value.map(entry => 
                  new TableRow({
                    children: [
                      new TableCell({
                        children: [new Paragraph({ text: entry.activity_name || 'Learning Reflection' })],
                      }),
                      new TableCell({
                        children: [new Paragraph({ text: formatDate(entry.date) })],
                      }),
                      new TableCell({
                        children: [new Paragraph({ text: entry.learnings_and_reflections || '' })],
                      }),
                    ],
                  })
                ),
              ],
            }),
          ]
        }]
      })

      const blob = await Packer.toBlob(doc)
      downloadFile(blob, `learning-logs-${new Date().toISOString().split('T')[0]}.docx`)
    } catch (error) {
      console.error('Error exporting learning logs:', error)
      alert('Error exporting learning logs: ' + error.message)
    }
  }
  
  return {
    learningLogs,
    loading,
    error,
    totalLearningLogs,
    loadLearningLogs,
    createLearningLog,
    deleteLearningLog,
    updateLearningLog,
    exportLearningLogs
  }
}