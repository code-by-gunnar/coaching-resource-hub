/**
 * Test Edge Functions Locally with Real API Keys
 * 
 * Usage:
 *   node test-local-edge-functions.js --id ATTEMPT_ID
 *   node test-local-edge-functions.js --pdf-only
 *   node test-local-edge-functions.js --email-only
 */

// Generate a valid UUID for testing
function generateTestUUID() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

// Parse command line arguments
function parseArgs() {
  const args = process.argv.slice(2)
  const config = {
    attemptId: generateTestUUID(), // Use valid UUID instead of string
    email: 'test@local-dev.com',
    pdfOnly: false,
    emailOnly: false
  }
  
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--id' && i + 1 < args.length) {
      config.attemptId = args[i + 1]
      i++
    } else if (args[i] === '--email' && i + 1 < args.length) {
      config.email = args[i + 1]
      i++
    } else if (args[i] === '--pdf-only') {
      config.pdfOnly = true
    } else if (args[i] === '--email-only') {
      config.emailOnly = true
    } else if (args[i] === '--help' || args[i] === '-h') {
      console.log('Usage:')
      console.log('  node test-local-edge-functions.js [options]')
      console.log('')
      console.log('Options:')
      console.log('  --id ATTEMPT_ID    Use specific attempt ID (default: generated UUID)')
      console.log('  --email EMAIL      Test email address (default: test@local-dev.com)')
      console.log('  --pdf-only         Test only PDF generation')
      console.log('  --email-only       Test only email sending')
      console.log('  --help             Show this help message')
      process.exit(0)
    }
  }
  
  return config
}

const config = parseArgs()

// Local Supabase configuration
const LOCAL_SUPABASE_URL = 'http://127.0.0.1:54321'
const LOCAL_SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU'

// Mock assessment data for testing
const mockAssessmentData = {
  overall_stats: {
    score: 72,
    total_questions: 20,
    correct_answers: 14,
    time_spent: 1350
  },
  assessment_framework: 'core',
  performance_analysis: "This is a test assessment showing strengths in Active Listening and areas for growth in Powerful Questions.",
  competency_performance: [
    {
      competency_area: "Active Listening",
      correct: 4,
      total: 5,
      percentage: 80
    },
    {
      competency_area: "Powerful Questions", 
      correct: 2,
      total: 5,
      percentage: 40
    },
    {
      competency_area: "Creating Awareness",
      correct: 3,
      total: 5,
      percentage: 60
    },
    {
      competency_area: "Present Moment Awareness",
      correct: 3,
      total: 5,
      percentage: 60
    }
  ]
}

async function testLocalPDFGeneration() {
  console.log('🔄 Testing LOCAL PDF Generation...')
  
  try {
    const response = await fetch(`${LOCAL_SUPABASE_URL}/functions/v1/generate-pdf-report`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${LOCAL_SERVICE_ROLE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        attemptId: config.attemptId,
        assessmentData: mockAssessmentData,
        userEmail: config.email
      })
    })

    console.log('📊 PDF Response Status:', response.status)
    
    if (response.ok) {
      const result = await response.json()
      console.log('✅ LOCAL PDF Success:', {
        downloadUrl: result.downloadUrl,
        filename: result.filename,
        token: result.token
      })
      return result
    } else {
      const errorText = await response.text()
      console.error('❌ LOCAL PDF Failed:', errorText)
      return null
    }
  } catch (error) {
    console.error('❌ LOCAL PDF Error:', error.message)
    return null
  }
}

async function testLocalEmailFunction() {
  console.log('🔄 Testing LOCAL Email Function...')
  
  try {
    const response = await fetch(`${LOCAL_SUPABASE_URL}/functions/v1/email-assessment-report`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${LOCAL_SERVICE_ROLE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email: config.email,
        attemptId: config.attemptId,
        userProfile: {
          email: config.email,
          full_name: 'Local Test User'
        }
      })
    })

    console.log('📧 Email Response Status:', response.status)
    
    if (response.ok) {
      const result = await response.json()
      console.log('✅ LOCAL Email Success:', result)
      return result
    } else {
      const errorText = await response.text()
      console.error('❌ LOCAL Email Failed:', errorText)
      return null
    }
  } catch (error) {
    console.error('❌ LOCAL Email Error:', error.message)
    return null
  }
}

async function testFunctionHealth() {
  console.log('🔍 Testing Local Function Health...')
  
  const functions = [
    'generate-pdf-report',
    'email-assessment-report', 
    'generate-assessment-data',
    'cleanup-temp-pdfs',
    'download-assessment-pdf'
  ]

  for (const funcName of functions) {
    try {
      const response = await fetch(`${LOCAL_SUPABASE_URL}/functions/v1/${funcName}`, {
        method: 'OPTIONS'
      })
      
      const status = response.ok ? '✅' : '❌'
      console.log(`${status} ${funcName}: ${response.status}`)
      
    } catch (error) {
      console.log(`❌ ${funcName}: ${error.message}`)
    }
  }
  console.log('')
}

async function runLocalTests() {
  console.log('🚀 Starting LOCAL Edge Functions Testing')
  console.log('📍 Local Supabase URL:', LOCAL_SUPABASE_URL)
  console.log('📋 Attempt ID:', config.attemptId)
  console.log('📧 Test Email:', config.email)
  console.log('')
  
  // Test function health first
  await testFunctionHealth()
  
  let pdfResult = null
  let emailResult = null
  
  // Test PDF Generation (unless email-only)
  if (!config.emailOnly) {
    pdfResult = await testLocalPDFGeneration()
    console.log('')
    
    if (pdfResult) {
      console.log('🎯 PDF Generated! Download URL:', pdfResult.downloadUrl)
    }
  }
  
  // Test Email Function (unless pdf-only)
  if (!config.pdfOnly) {
    console.log('⏳ Waiting 2 seconds before testing email...')
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    emailResult = await testLocalEmailFunction() 
    console.log('')
    
    if (emailResult) {
      console.log('📬 Email Sent! Check your inbox at:', config.email)
    }
  }
  
  // Summary
  console.log('📊 Local Test Summary:')
  if (!config.emailOnly) {
    console.log('PDF Generation:', pdfResult ? '✅ Success' : '❌ Failed')
  }
  if (!config.pdfOnly) {
    console.log('Email Sending:', emailResult ? '✅ Success' : '❌ Failed')
  }
  
  if (pdfResult || emailResult) {
    console.log('')
    console.log('🎉 Local edge functions working with real API keys!')
    console.log('💡 Check the terminal running "npx supabase functions serve" for detailed logs')
  }
}

// Add handler for mock assessment attempt if needed
async function createMockAssessmentAttempt() {
  if (config.attemptId.length === 36 && config.attemptId.includes('-')) {
    console.log('💡 Using valid UUID for testing:', config.attemptId)
    console.log('💡 For testing with real assessment data, use --id with actual attempt ID from database')
  }
}

// Run the tests
createMockAssessmentAttempt()
  .then(() => runLocalTests())
  .catch(console.error)