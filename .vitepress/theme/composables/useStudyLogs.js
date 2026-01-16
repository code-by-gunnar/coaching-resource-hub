import { ref, computed } from 'vue'
import { useSupabase } from './useSupabase.js'

export function useStudyLogs() {
  const { supabase } = useSupabase()
  
  const studyLogs = ref([])
  const loading = ref(false)
  const error = ref('')
  
  // Computed values
  const totalHours = computed(() => {
    return studyLogs.value.reduce((sum, log) => sum + (log.hours || 0), 0)
  })
  
  const totalSessions = computed(() => studyLogs.value.length)
  
  // Load study logs for a user
  const loadStudyLogs = async (userId) => {
    if (!userId) {
      console.error('User ID is required to load study logs')
      return
    }
    
    loading.value = true
    error.value = ''
    
    try {
      console.log('Loading study logs for user:', userId)
      
      const { data, error: queryError } = await supabase
        .from('self_study')
        .select('*')
        .eq('user_id', userId)
        .order('date', { ascending: false })
      
      if (queryError) {
        console.error('Study logs query error:', queryError)
        throw queryError
      }
      
      console.log('Study logs loaded:', data)
      studyLogs.value = data || []
    } catch (err) {
      console.error('Error loading study logs:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }
  
  // Delete a study log
  const deleteStudyLog = async (id) => {
    if (!confirm('Are you sure you want to delete this study log?')) {
      return false
    }
    
    try {
      const { error: deleteError } = await supabase
        .from('self_study')
        .delete()
        .eq('id', id)
      
      if (deleteError) throw deleteError
      
      // Remove from local state
      studyLogs.value = studyLogs.value.filter(log => log.id !== id)
      return true
    } catch (err) {
      console.error('Error deleting study log:', err)
      alert('Failed to delete study log. Please try again.')
      return false
    }
  }

  // Create a new study log
  const createStudyLog = async (newData) => {
    try {
      const { data, error } = await supabase
        .from('self_study')
        .insert(newData)
        .select()
      
      if (error) throw error
      
      // Add to local state
      if (data && data.length > 0) {
        studyLogs.value.unshift(data[0]) // Add to beginning of array
      }
      
      return true
    } catch (err) {
      console.error('Error creating study log:', err)
      throw err
    }
  }

  // Update a study log
  const updateStudyLog = async (id, updatedData) => {
    try {
      const { error } = await supabase
        .from('self_study')
        .update(updatedData)
        .eq('id', id)
      
      if (error) throw error
      
      // Update local state
      const index = studyLogs.value.findIndex(log => log.id === id)
      if (index !== -1) {
        studyLogs.value[index] = { ...studyLogs.value[index], ...updatedData }
      }
      
      return true
    } catch (err) {
      console.error('Error updating study log:', err)
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
  
  // Export study logs as DOCX
  const exportStudyLogs = async () => {
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
            text: "Study Logs",
            heading: HeadingLevel.HEADING_1,
          }),
          new Paragraph({
            text: `Total Study Hours: ${totalHours.value}`,
            spacing: { after: 200 }
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
                    width: { size: 35, type: WidthType.PERCENTAGE },
                  }),
                  new TableCell({
                    children: [new Paragraph({ text: "Hours" })],
                    width: { size: 10, type: WidthType.PERCENTAGE },
                  }),
                  new TableCell({
                    children: [new Paragraph({ text: "Category" })],
                    width: { size: 15, type: WidthType.PERCENTAGE },
                  }),
                  new TableCell({
                    children: [new Paragraph({ text: "Date" })],
                    width: { size: 12, type: WidthType.PERCENTAGE },
                  }),
                  new TableCell({
                    children: [new Paragraph({ text: "Description" })],
                    width: { size: 28, type: WidthType.PERCENTAGE },
                  }),
                ],
              }),
              // Data rows
              ...studyLogs.value.map(entry => 
                new TableRow({
                  children: [
                    new TableCell({
                      children: [new Paragraph({ text: entry.name || '' })],
                    }),
                    new TableCell({
                      children: [new Paragraph({ text: `${entry.hours}h` })],
                    }),
                    new TableCell({
                      children: [new Paragraph({ text: entry.category || '' })],
                    }),
                    new TableCell({
                      children: [new Paragraph({ text: formatDate(entry.date) })],
                    }),
                    new TableCell({
                      children: [new Paragraph({ text: entry.description || 'No description provided' })],
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
    downloadFile(blob, `study-logs-${new Date().toISOString().split('T')[0]}.docx`)
  } catch (error) {
    console.error('Error exporting study logs:', error)
    alert('Error exporting study logs: ' + error.message)
  }
}
  
  return {
    studyLogs,
    loading,
    error,
    totalHours,
    totalSessions,
    loadStudyLogs,
    createStudyLog,
    deleteStudyLog,
    updateStudyLog,
    exportStudyLogs
  }
}