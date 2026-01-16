import { ref } from 'vue'
import { useSupabase } from './useSupabase.js'
import fileSaver from 'file-saver'
const { saveAs } = fileSaver

export function useProfileSettings(user) {
  const { supabase } = useSupabase()

  // Reactive state
  const loading = ref(false)
  const currentPassword = ref('')
  const newPassword = ref('')
  const confirmPassword = ref('')
  const passwordLoading = ref(false)
  const exportLoading = ref(false)
  const deleteLoading = ref(false)
  const showDeleteConfirm = ref(false)
  const deleteConfirmEmail = ref('')
  const successMessage = ref('')
  const errorMessage = ref('')

  // Clear messages after timeout
  const clearMessages = () => {
    setTimeout(() => {
      successMessage.value = ''
      errorMessage.value = ''
    }, 5000)
  }

  // Password change handler
  const handlePasswordChange = async () => {
    if (newPassword.value !== confirmPassword.value) {
      errorMessage.value = 'New passwords do not match'
      clearMessages()
      return
    }

    passwordLoading.value = true
    errorMessage.value = ''
    successMessage.value = ''

    try {
      const { error } = await supabase.auth.updateUser({
        password: newPassword.value
      })

      if (error) throw error

      successMessage.value = 'Password updated successfully!'
      currentPassword.value = ''
      newPassword.value = ''
      confirmPassword.value = ''
      clearMessages()

    } catch (err) {
      errorMessage.value = err.message
      clearMessages()
    } finally {
      passwordLoading.value = false
    }
  }

  // Export data functionality
  const exportData = async (type) => {
    if (!user?.value?.id) {
      errorMessage.value = 'User not authenticated'
      clearMessages()
      return
    }

    exportLoading.value = true
    errorMessage.value = ''

    try {
      let studyLogs = []
      let learningLogs = []

      if (type === 'study' || type === 'all') {
        const { data: studyData, error: studyError } = await supabase
          .from('self_study')
          .select('*')
          .eq('user_id', user.value.id)
          .order('date', { ascending: false })

        if (studyError) throw studyError
        studyLogs = studyData || []
      }

      if (type === 'reflections' || type === 'all') {
        const { data: learningData, error: learningError } = await supabase
          .from('learning_logs')
          .select('*')
          .eq('user_id', user.value.id)
          .order('date', { ascending: false })

        if (learningError) throw learningError
        learningLogs = learningData || []
      }

      const { Document, Packer, Paragraph, Table, TableRow, TableCell, WidthType, PageOrientation, AlignmentType, HeadingLevel } = await import('docx')
      
      // Generate document
      const doc = new Document({
        styles: {
          default: {
            document: {
              run: {
                font: 'Arial',
                size: 22
              }
            }
          }
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
            }
          },
          children: [
            new Paragraph({
              text: `Coaching Resource Hub - Data Export - ${new Date().toLocaleDateString()}`,
              heading: HeadingLevel.HEADING_1,
              alignment: AlignmentType.CENTER
            }),
            new Paragraph({ text: '' }), // Empty line
            
            // Study Logs Section
            ...(studyLogs.length > 0 ? [
              new Paragraph({
                text: 'Study Logs',
                heading: 'Heading2'
              }),
              new Table({
                width: { size: 100, type: WidthType.PERCENTAGE },
                rows: [
                  new TableRow({
                    children: [
                      new TableCell({ children: [new Paragraph({ text: 'Activity' })] }),
                      new TableCell({ children: [new Paragraph({ text: 'Hours' })] }),
                      new TableCell({ children: [new Paragraph({ text: 'Category' })] }),
                      new TableCell({ children: [new Paragraph({ text: 'Date' })] }),
                      new TableCell({ children: [new Paragraph({ text: 'Description' })] })
                    ]
                  }),
                  ...studyLogs.map(log => new TableRow({
                    children: [
                      new TableCell({ children: [new Paragraph({ text: log.name || '' })] }),
                      new TableCell({ children: [new Paragraph({ text: log.hours?.toString() || '0', alignment: AlignmentType.CENTER })] }),
                      new TableCell({ children: [new Paragraph({ text: log.category || '', alignment: AlignmentType.CENTER })] }),
                      new TableCell({ children: [new Paragraph({ text: new Date(log.date).toLocaleDateString(), alignment: AlignmentType.CENTER })] }),
                      new TableCell({ children: [new Paragraph({ text: log.description || '' })] })
                    ]
                  }))
                ]
              }),
              new Paragraph({ text: '' }), // Empty line
            ] : []),

            // Learning Logs Section
            ...(learningLogs.length > 0 ? [
              new Paragraph({
                text: 'Learning Logs',
                heading: 'Heading2'
              }),
              new Table({
                width: { size: 100, type: WidthType.PERCENTAGE },
                rows: [
                  new TableRow({
                    children: [
                      new TableCell({ children: [new Paragraph({ text: 'Activity' })] }),
                      new TableCell({ children: [new Paragraph({ text: 'Date' })] }),
                      new TableCell({ children: [new Paragraph({ text: 'Learning Reflections' })] })
                    ]
                  }),
                  ...learningLogs.map(log => new TableRow({
                    children: [
                      new TableCell({ children: [new Paragraph({ text: log.activity_name || '' })] }),
                      new TableCell({ children: [new Paragraph({ text: new Date(log.date).toLocaleDateString(), alignment: AlignmentType.CENTER })] }),
                      new TableCell({ children: [new Paragraph({ text: log.learnings_and_reflections || '' })] })
                    ]
                  }))
                ]
              })
            ] : [])
          ]
        }]
      })

      const blob = await Packer.toBlob(doc)
      const filename = type === 'all' ? 'coaching-hub-complete-export.docx' : 
                      type === 'study' ? 'study-logs-export.docx' : 
                      'learning-logs-export.docx'
      
      saveAs(blob, filename)
      successMessage.value = `${type === 'all' ? 'Complete data' : type === 'study' ? 'Study logs' : 'Learning logs'} exported successfully!`
      clearMessages()

    } catch (err) {
      errorMessage.value = `Export failed: ${err.message}`
      clearMessages()
    } finally {
      exportLoading.value = false
    }
  }

  // Account deletion handler
  const handleAccountDeletion = async () => {
    if (!user?.value?.id) {
      errorMessage.value = 'User not authenticated'
      clearMessages()
      return
    }

    // Normalize emails for comparison (trim whitespace, convert to lowercase)
    const userEmail = user.value?.email?.toLowerCase().trim()
    const confirmEmail = deleteConfirmEmail.value?.toLowerCase().trim()
    
    console.log('Email validation:', { userEmail, confirmEmail, match: userEmail === confirmEmail })
    
    if (!confirmEmail) {
      errorMessage.value = 'Please enter your email address'
      clearMessages()
      return
    }
    
    if (confirmEmail !== userEmail) {
      errorMessage.value = `Email address does not match. Expected: ${userEmail}`
      clearMessages()
      return
    }

    deleteLoading.value = true
    errorMessage.value = ''

    try {
      // First delete all user data from our tables
      const { error: studyError } = await supabase
        .from('self_study')
        .delete()
        .eq('user_id', user.value.id)

      if (studyError) throw studyError

      const { error: learningError } = await supabase
        .from('learning_logs')
        .delete()
        .eq('user_id', user.value.id)

      if (learningError) throw learningError

      // Then sign out and redirect (account deletion will be handled by auth policies)
      await supabase.auth.signOut()
      successMessage.value = 'Account deletion initiated. You have been signed out.'
      
      // Redirect to home after a delay
      setTimeout(() => {
        window.location.href = '/'
      }, 2000)

    } catch (err) {
      errorMessage.value = `Account deletion failed: ${err.message}`
      clearMessages()
    } finally {
      deleteLoading.value = false
    }
  }

  // Cancel account deletion
  const cancelAccountDeletion = () => {
    showDeleteConfirm.value = false
    deleteConfirmEmail.value = ''
    errorMessage.value = ''
  }

  return {
    loading,
    currentPassword,
    newPassword,
    confirmPassword,
    passwordLoading,
    exportLoading,
    deleteLoading,
    showDeleteConfirm,
    deleteConfirmEmail,
    successMessage,
    errorMessage,
    handlePasswordChange,
    exportData,
    handleAccountDeletion,
    cancelAccountDeletion
  }
}