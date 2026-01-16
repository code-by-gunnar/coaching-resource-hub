/**
 * Test PDF generation without sending emails
 * This preserves Resend credits while testing PDF functionality
 * 
 * Usage:
 *   node test-pdfs-only.js --id YOUR_ATTEMPT_ID
 *   node test-pdfs-only.js --id YOUR_ATTEMPT_ID --email test@example.com
 */

// Parse command line arguments
function parseArgs() {
  const args = process.argv.slice(2)
  const config = {
    attemptId: null,
    email: 'test@example.com'
  }
  
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--id' && i + 1 < args.length) {
      config.attemptId = args[i + 1]
      i++
    } else if (args[i] === '--email' && i + 1 < args.length) {
      config.email = args[i + 1]
      i++
    } else if (args[i] === '--help' || args[i] === '-h') {
      console.log('Usage:')
      console.log('  node test-pdfs-only.js --id YOUR_ATTEMPT_ID')
      console.log('  node test-pdfs-only.js --id YOUR_ATTEMPT_ID --email test@example.com')
      console.log('')
      console.log('Options:')
      console.log('  --id     Attempt ID (required)')
      console.log('  --email  Test email address (optional, defaults to test@example.com)')
      console.log('  --help   Show this help message')
      process.exit(0)
    }
  }
  
  return config
}

const config = parseArgs()

// Validate required arguments
if (!config.attemptId) {
  console.error('❌ Error: Attempt ID is required')
  console.log('')
  console.log('Usage:')
  console.log('  node test-pdfs-only.js --id YOUR_ATTEMPT_ID')
  console.log('')
  console.log('Example:')
  console.log('  node test-pdfs-only.js --id 550e8400-e29b-41d4-a716-446655440000')
  process.exit(1)
}

// Test configuration
const ATTEMPT_ID = config.attemptId
const TEST_EMAIL = config.email

const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU"
const SUPABASE_URL = process.env.SUPABASE_URL || "http://127.0.0.1:54321"

// Mock assessment data structure (similar to what email function receives)
const mockAssessmentData = {
  overall_stats: {
    score: 75,
    total_questions: 20,
    correct_answers: 15,
    time_spent: 1200
  },
  assessment_framework: 'core',
  competency_performance: [
    {
      competency_area: "Active Listening",
      correct: 3,
      total: 4,
      percentage: 75
    },
    {
      competency_area: "Powerful Questions", 
      correct: 2,
      total: 4,
      percentage: 50
    }
  ]
}

async function testMainPDF() {
  console.log('🔄 Testing Main PDF Generation...')
  
  try {
    const response = await fetch(`${SUPABASE_URL}/functions/v1/generate-pdf-report`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        attemptId: ATTEMPT_ID,
        assessmentData: mockAssessmentData,
        userEmail: TEST_EMAIL
      })
    })

    if (response.ok) {
      const result = await response.json()
      console.log('✅ Main PDF Success:', {
        downloadUrl: result.downloadUrl,
        filename: result.filename
      })
      return result
    } else {
      const error = await response.text()
      console.error('❌ Main PDF Failed:', response.status, error)
      return null
    }
  } catch (error) {
    console.error('❌ Main PDF Error:', error)
    return null
  }
}

async function testQuestionAnalysisPDF() {
  console.log('🔄 Testing Question Analysis PDF Generation...')
  
  try {
    const response = await fetch(`${SUPABASE_URL}/functions/v1/generate-question-analysis-report`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        attemptId: ATTEMPT_ID,
        assessmentData: mockAssessmentData,
        userEmail: TEST_EMAIL
      })
    })

    if (response.ok) {
      const result = await response.json()
      console.log('✅ Question Analysis PDF Success:', {
        downloadUrl: result.downloadUrl,
        filename: result.filename
      })
      return result
    } else {
      const error = await response.text()
      console.error('❌ Question Analysis PDF Failed:', response.status, error)
      return null
    }
  } catch (error) {
    console.error('❌ Question Analysis PDF Error:', error)
    return null
  }
}

async function runTests() {
  console.log('🧪 Starting PDF Tests (No Email Sending)')
  console.log('📋 Attempt ID:', ATTEMPT_ID)
  console.log('📧 Test Email:', TEST_EMAIL)
  console.log('')

  // Test Main PDF
  const mainPdfResult = await testMainPDF()
  console.log('')

  // Wait 2 seconds (like email function does)
  console.log('⏳ Waiting 2 seconds before testing question analysis PDF...')
  await new Promise(resolve => setTimeout(resolve, 2000))
  console.log('')

  // Test Question Analysis PDF
  const questionPdfResult = await testQuestionAnalysisPDF()
  console.log('')

  // Summary
  console.log('📊 Test Summary:')
  console.log('Main PDF:', mainPdfResult ? '✅ Success' : '❌ Failed')
  console.log('Question Analysis PDF:', questionPdfResult ? '✅ Success' : '❌ Failed')
  
  if (mainPdfResult && questionPdfResult) {
    console.log('')
    console.log('🎉 Both PDFs generated successfully!')
    console.log('📄 Main Report:', mainPdfResult.downloadUrl)
    console.log('📋 Question Analysis:', questionPdfResult.downloadUrl)
  }
}

// Run the tests
runTests().catch(console.error)