import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

// CORS headers - support both dev and production
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    console.log('📋 STEP 1: Question Analysis PDF function called')
    console.log('Request method:', req.method)
    console.log('Request URL:', req.url)
    
    let requestBody
    try {
      requestBody = await req.json()
      console.log('✅ STEP 2: Request body parsed successfully')
      console.log('Request body keys:', Object.keys(requestBody))
    } catch (parseError) {
      console.error('❌ STEP 2: Failed to parse request body:', parseError)
      throw parseError
    }
    
    const { attemptId, assessmentData, userEmail } = requestBody
    
    console.log('📋 STEP 3: Processing question analysis request:', {
      attemptId,
      userEmail,
      hasAssessmentData: !!assessmentData
    })

    if (!attemptId || !assessmentData) {
      return new Response(
        JSON.stringify({ error: 'attemptId and assessmentData are required' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Get environment variables
    console.log('📋 STEP 4: Checking environment variables...')
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    const pdfShiftApiKey = Deno.env.get('PDFSHIFT_API_KEY')

    console.log('Environment check:', {
      hasSupabaseUrl: !!supabaseUrl,
      hasServiceRoleKey: !!serviceRoleKey,
      hasPdfShiftApiKey: !!pdfShiftApiKey
    })

    if (!supabaseUrl || !serviceRoleKey || !pdfShiftApiKey) {
      console.error('❌ STEP 4: Missing required environment variables')
      return new Response(
        JSON.stringify({ error: 'Missing required environment variables' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }
    
    console.log('✅ STEP 4: Environment variables OK')

    // Fetch detailed response data with questions
    console.log('📋 STEP 5: Fetching detailed responses for attempt:', attemptId)
    
    const responsesQuery = `user_question_responses?attempt_id=eq.${attemptId}&select=*,assessment_questions!question_id(id,question,scenario,option_a,option_b,option_c,option_d,correct_answer,explanation,competency_display_names!competency_id(display_name))&order=created_at`
    console.log('Database query:', responsesQuery)
    
    const responsesResponse = await fetch(`${supabaseUrl}/rest/v1/${responsesQuery}`, {
      headers: {
        'apikey': serviceRoleKey,
        'Authorization': `Bearer ${serviceRoleKey}`,
        'Content-Type': 'application/json'
      }
    })
    
    console.log('Database response status:', responsesResponse.status, responsesResponse.statusText)

    if (!responsesResponse.ok) {
      const errorText = await responsesResponse.text()
      console.error('❌ Failed to fetch responses:', responsesResponse.status, responsesResponse.statusText)
      console.error('Response body:', errorText)
      return new Response(
        JSON.stringify({ 
          error: 'Failed to fetch assessment responses', 
          status: responsesResponse.status,
          details: errorText 
        }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    const responses = await responsesResponse.json()
    console.log('✅ STEP 5: Database query successful')
    console.log('📋 Found responses:', responses.length)

    if (responses.length === 0) {
      console.warn('⚠️ No responses found for attempt:', attemptId)
      return new Response(
        JSON.stringify({ error: 'No assessment responses found for this attempt' }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Generate detailed question analysis HTML
    console.log('📋 STEP 6: Generating HTML content...')
    let htmlContent
    try {
      htmlContent = await generateQuestionAnalysisHTML(responses, assessmentData, attemptId, userEmail)
      console.log('✅ STEP 6: HTML content generated, length:', htmlContent.length, 'characters')
    } catch (htmlError) {
      console.error('❌ STEP 6: HTML generation failed:', htmlError)
      throw htmlError
    }
    
    // Generate PDF using PDFShift
    console.log('📄 STEP 7: Generating question analysis PDF with PDFShift...')
    
    const pdfResponse = await fetch('https://api.pdfshift.io/v3/convert/pdf', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${btoa(`api:${pdfShiftApiKey}`)}`
      },
      body: JSON.stringify({
        source: htmlContent,
        landscape: false,
        format: "A4",
        margin: { top: 25, right: 25, bottom: 50, left: 25 },
        use_print: true,
        delay: 2000,
        footer: {
          source: `<div style="font-family: Arial, sans-serif; font-size: 10px; color: #666; padding: 10px 0; width: 100%; display: flex; justify-content: center; align-items: center;">
            <span>Your Coaching Hub • Professional Development Platform</span>
          </div>`,
          height: 30
        }
      })
    })

    if (!pdfResponse.ok) {
      const errorText = await pdfResponse.text()
      console.error('❌ PDFShift error:', pdfResponse.status, errorText)
      return new Response(
        JSON.stringify({ error: 'PDF generation failed', details: errorText }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    const pdfBuffer = await pdfResponse.arrayBuffer()
    console.log('✅ STEP 7: PDF generated successfully, size:', pdfBuffer.byteLength, 'bytes')

    // Get user_id from the attempt data to properly structure storage path
    console.log('👤 STEP 8a: Fetching user_id from attempt data for proper storage structure...')
    const attemptUserResponse = await fetch(`${supabaseUrl}/rest/v1/user_assessment_attempts?id=eq.${attemptId}&select=user_id`, {
      headers: {
        'apikey': serviceRoleKey,
        'Authorization': `Bearer ${serviceRoleKey}`,
        'Content-Type': 'application/json'
      }
    })
    
    let userId = null
    if (attemptUserResponse.ok) {
      const attemptUserData = await attemptUserResponse.json()
      if (attemptUserData && attemptUserData.length > 0) {
        userId = attemptUserData[0].user_id
        console.log('✅ Found user_id for storage path:', userId)
      }
    }
    
    if (!userId) {
      console.warn('⚠️ Could not get user_id, using fallback email-based storage path')
    }

    // Generate unique filename and storage path
    const filename = `question-analysis-${attemptId}-${Date.now()}.pdf`
    const storagePath = userId ? `${userId}/${filename}` : `fallback/${filename}`
    console.log('📄 STEP 8b: Uploading PDF to storage with path:', storagePath)
    
    // Upload to Supabase Storage with correct bucket and path structure
    const uploadResponse = await fetch(`${supabaseUrl}/storage/v1/object/temporary-pdfs/${storagePath}`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${serviceRoleKey}`,
        'apikey': serviceRoleKey,
        'Content-Type': 'application/pdf'
      },
      body: pdfBuffer
    })

    if (!uploadResponse.ok) {
      const uploadError = await uploadResponse.text()
      console.error('❌ Upload failed:', uploadResponse.status, uploadError)
      return new Response(
        JSON.stringify({ error: 'Failed to upload PDF', details: uploadError }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    console.log('✅ STEP 8: PDF uploaded to storage successfully:', filename)

    // Create database record for cleanup tracking
    console.log('📝 STEP 8.5: Creating database record for PDF cleanup tracking...')
    
    // Generate download token for secure access
    const downloadToken = crypto.randomUUID()
    
    // Set expiration date (7 days from now)
    const expiresAt = new Date()
    expiresAt.setDate(expiresAt.getDate() + 7)
    
    // Insert record into temporary_pdf_files table
    const dbInsertResponse = await fetch(`${supabaseUrl}/rest/v1/temporary_pdf_files`, {
      method: 'POST',
      headers: {
        'apikey': serviceRoleKey,
        'Authorization': `Bearer ${serviceRoleKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        file_path: storagePath,
        expires_at: expiresAt.toISOString(),
        user_id: userId, // Use the user_id we fetched
        assessment_attempt_id: attemptId,
        download_token: downloadToken
      })
    })
    
    if (!dbInsertResponse.ok) {
      const errorText = await dbInsertResponse.text()
      console.error('❌ Failed to create database record:', dbInsertResponse.status, errorText)
      console.log('⚠️ PDF will be accessible but may not be automatically cleaned up after 7 days')
      // Continue anyway - PDF is still accessible via public URL
    } else {
      console.log('✅ Database record created for PDF cleanup tracking')
    }

    // Create public download URL
    console.log('📄 STEP 9: Creating public download URL...')
    
    // Since temporary-pdfs bucket is public, use direct public URL instead of signed URL
    const downloadUrl = `${supabaseUrl}/storage/v1/object/public/temporary-pdfs/${storagePath}`
    console.log('✅ STEP 9: Download URL created successfully:', downloadUrl)
    console.log('🎉 COMPLETE: Question analysis PDF ready for download')

    return new Response(
      JSON.stringify({
        success: true,
        downloadUrl: downloadUrl,
        filename: filename,
        storagePath: storagePath
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )

  } catch (error) {
    console.error('❌ CRITICAL ERROR in question analysis function:')
    console.error('Error name:', error.name)
    console.error('Error message:', error.message)
    console.error('Error stack:', error.stack)
    console.error('Error details:', JSON.stringify(error, null, 2))
    
    return new Response(
      JSON.stringify({ 
        error: 'Failed to generate question analysis report', 
        details: error.message,
        errorName: error.name,
        stack: error.stack?.split('\n').slice(0, 5) // First 5 lines of stack trace
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

/**
 * Generate comprehensive question analysis HTML report
 */
async function generateQuestionAnalysisHTML(responses: any[], assessmentData: any, attemptId: string, userEmail?: string): Promise<string> {
  const { overall_stats, assessment_framework } = assessmentData
  
  // Group responses by competency area and correctness
  const competencyGroups: { [key: string]: { correct: any[], incorrect: any[] } } = {}
  
  responses.forEach(response => {
    const competency = response.assessment_questions?.competency_display_names?.display_name || 'Unknown'
    
    if (!competencyGroups[competency]) {
      competencyGroups[competency] = { correct: [], incorrect: [] }
    }
    
    if (response.is_correct) {
      competencyGroups[competency].correct.push(response)
    } else {
      competencyGroups[competency].incorrect.push(response)
    }
  })

  // Generate HTML sections with page breaks between competencies, sorted by percentage (lowest first)
  const competencySections = Object.entries(competencyGroups)
    .map(([competency, group]) => {
      const totalQuestions = group.correct.length + group.incorrect.length
      const correctCount = group.correct.length
      const percentage = Math.round((correctCount / totalQuestions) * 100)
      return { competency, group, percentage, totalQuestions }
    })
    .sort((a, b) => a.percentage - b.percentage) // Sort by percentage, lowest first
    .map(({ competency, group, percentage, totalQuestions }, index) => {
      const sectionHTML = generateCompetencySection(competency, group, percentage, totalQuestions)
      
      // Add page break before each competency section (except the first)
      if (index > 0 && sectionHTML.trim()) {
        return `<div style="page-break-before: always;"></div>${sectionHTML}`
      }
      
      return sectionHTML
    }).join('')

  const reportDate = new Date().toLocaleDateString()
  const reportTime = new Date().toLocaleTimeString()

  return `
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Question Analysis Report</title>
      <style>
        ${getQuestionAnalysisCSS()}
      </style>
    </head>
    <body>
      <div class="report-container">
        <!-- First Page: Cover and Summary -->
        <div class="page">
          <!-- Header with consistent branding -->
          <div class="report-header">
            <img src="${Deno.env.get('SUPABASE_URL') || 'https://hfmpacbmbyvnupzgorek.supabase.co'}/storage/v1/object/public/coaching-downloads/assets/logo.png" alt="Your Coaching Hub Logo" class="logo" />
            <div class="header-content">
              <h1>Question Analysis Report</h1>
              <div class="subtitle">Professional Coaching Competency Assessment</div>
            </div>
          </div>

          <!-- Report Meta Information -->
          <div class="report-meta-section">
            <div class="meta-grid">
              <div class="meta-item">
                <span class="meta-label">Assessment:</span>
                <span class="meta-value">${assessment_framework?.toUpperCase() || 'CORE'} - Fundamentals</span>
              </div>
              <div class="meta-item">
                <span class="meta-label">Overall Score:</span>
                <span class="meta-value">${overall_stats?.score || 0}% (${overall_stats?.correct_answers || 0}/${overall_stats?.total_questions || 0} questions)</span>
              </div>
              <div class="meta-item">
                <span class="meta-label">Generated:</span>
                <span class="meta-value">${reportDate} at ${reportTime}</span>
              </div>
            </div>
          </div>

          <!-- Executive Summary with Integrated Participant Info (matching main report) -->
          <div class="executive-summary" style="background: #f8fafc; padding: 25px; border-radius: 8px; margin-bottom: 35px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
              <h2 style="margin: 0; color: #333; font-size: 18px;">Question Analysis Summary</h2>
              <div style="text-align: right; font-size: 12px; color: #666;">
                <div style="margin-bottom: 3px;">${userEmail || 'Participant'}</div>
                <div>${reportDate}</div>
              </div>
            </div>
            
            <p style="margin-bottom: 20px; color: #555; line-height: 1.6;">This detailed analysis examines each question from your <strong>${assessment_framework?.toUpperCase() || 'CORE'} - Fundamentals Assessment</strong>, providing insights into coaching scenarios, correct approaches, and learning opportunities. Use this report to identify specific areas for focused development and practice.</p>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 20px; margin-bottom: 20px;">
              <div style="text-align: center; background: white; padding: 15px; border-radius: 6px; border: 1px solid #e5e7eb;">
                <div style="font-size: 24px; font-weight: bold; color: #4a90e2; margin-bottom: 5px;">${Object.keys(competencyGroups).length}</div>
                <div style="font-size: 11px; color: #7a8999; text-transform: uppercase; font-weight: 600;">Competency Areas</div>
              </div>
              <div style="text-align: center; background: white; padding: 15px; border-radius: 6px; border: 1px solid #e5e7eb;">
                <div style="font-size: 24px; font-weight: bold; color: #dc2626; margin-bottom: 5px;">${responses.filter(r => !r.is_correct).length}</div>
                <div style="font-size: 11px; color: #7a8999; text-transform: uppercase; font-weight: 600;">Questions to Review</div>
              </div>
              <div style="text-align: center; background: white; padding: 15px; border-radius: 6px; border: 1px solid #e5e7eb;">
                <div style="font-size: 24px; font-weight: bold; color: #059669; margin-bottom: 5px;">${responses.filter(r => r.is_correct).length}</div>
                <div style="font-size: 11px; color: #7a8999; text-transform: uppercase; font-weight: 600;">Questions Correct</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Question Pages: Each competency section with its questions -->
        ${competencySections}

        <!-- Study Recommendations Page -->
        <div class="page">
          <div class="study-recommendations">
          <h2>Study Recommendations</h2>
          <div class="recommendation-box">
            <h3>🎯 Focus Areas for Development</h3>
            <ul>
              ${Object.entries(competencyGroups)
                .filter(([_, group]) => {
                  const total = group.correct.length + group.incorrect.length
                  const percentage = (group.correct.length / total) * 100
                  return percentage < 70
                })
                .map(([competency, group]) => {
                  const total = group.correct.length + group.incorrect.length
                  const percentage = Math.round((group.correct.length / total) * 100)
                  return `<li><strong>${competency}:</strong> ${percentage}% - ${group.incorrect.length} question${group.incorrect.length !== 1 ? 's' : ''} to review</li>`
                })
                .join('')}
            </ul>
          </div>

          <div class="recommendation-box">
            <h3>📚 Next Steps</h3>
            <ol>
              <li><strong>Review Incorrect Questions:</strong> Focus on the scenarios where your approach differed from the coaching best practice</li>
              <li><strong>Practice Similar Scenarios:</strong> Work through similar coaching situations with colleagues or in supervision</li>
              <li><strong>Study Key Concepts:</strong> Deep dive into the competency areas where you scored below 70%</li>
              <li><strong>Apply Learning:</strong> Consciously practice the correct approaches in your coaching sessions</li>
            </ol>
          </div>
        </div>

        </div>
      </div>
    </body>
    </html>
  `
}

/**
 * Generate competency section with detailed question analysis
 */
function generateCompetencySection(competency: string, group: any, percentage: number, totalQuestions: number): string {
  const statusClass = percentage >= 70 ? 'strength' : 'development'
  const statusIcon = percentage >= 70 ? '✅' : '🎯'
  
  // If no incorrect questions, show a success page
  if (group.incorrect.length === 0) {
    return `
      <div class="page">
        <div class="competency-header-page">
          <div class="competency-banner ${statusClass}">
            <h2>${statusIcon} ${competency}</h2>
            <div class="competency-stats">
              <span class="score">${percentage}%</span>
              <span class="breakdown">${group.correct.length}/${totalQuestions} correct</span>
            </div>
          </div>
          
          <div class="perfect-performance">
            <div class="success-message">
              <h3>🎉 Perfect Performance!</h3>
              <p>You answered all questions correctly in this competency area. This demonstrates strong mastery of ${competency} concepts.</p>
              <div class="next-steps">
                <h4>Continue Building on This Strength:</h4>
                <ul>
                  <li>Consider mentoring others in this competency area</li>
                  <li>Look for advanced training opportunities to deepen your expertise</li>
                  <li>Apply these skills to challenge yourself with complex coaching scenarios</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    `
  }

  // Generate individual question pages, with the first one having the competency banner
  const incorrectQuestionsHTML = group.incorrect.map((response: any, index: number) => {
    const question = response.assessment_questions
    if (!question) return ''
    
    // First question gets the competency banner
    const isFirstQuestion = index === 0
    return generateQuestionDetailHTML(question, response, index + 1, isFirstQuestion ? { competency, statusClass, statusIcon, percentage, correctCount: group.correct.length, totalQuestions } : null)
  }).join('')

  return incorrectQuestionsHTML
}

/**
 * Convert letter answer (A, B, C, D) to numeric index (1, 2, 3, 4)
 */
function getAnswerIndex(letterAnswer: string): number {
  if (!letterAnswer) return 1
  const mapping: { [key: string]: number } = { 'A': 1, 'B': 2, 'C': 3, 'D': 4 }
  const result = mapping[letterAnswer.toUpperCase()]
  console.log(`Converting answer "${letterAnswer}" to index: ${result || 1}`)
  return result || 1
}

/**
 * Get answer option text from question based on numeric index
 */
function getAnswerOptionText(question: any, answerIndex: number): string {
  if (!question) return 'Not available'
  
  // Ensure answerIndex is valid (1-4)
  if (answerIndex < 1 || answerIndex > 4) {
    console.warn(`Invalid answerIndex: ${answerIndex}, defaulting to 1`)
    answerIndex = 1
  }
  
  const options = ['option_a', 'option_b', 'option_c', 'option_d']
  const optionKey = options[answerIndex - 1]
  const optionText = question[optionKey]
  
  console.log(`Getting option ${answerIndex} (${optionKey}): "${optionText}"`)
  return optionText || `Option ${answerIndex} (missing)`
}

/**
 * Generate detailed question analysis HTML
 */
function generateQuestionDetailHTML(question: any, response: any, questionNumber: number, competencyInfo?: any): string {
  // Convert selected answer from letter to index
  const selectedIndex = getAnswerIndex(response.selected_answer)
  let correctIndex = question.correct_answer
  
  // Fix database issue: correct_answer should be 1-4, not 0-3
  if (correctIndex === 0) {
    console.warn(`Question ${question.id} has incorrect correct_answer: 0, converting to 1`)
    correctIndex = 1
  } else if (correctIndex < 1 || correctIndex > 4) {
    console.warn(`Question ${question.id} has invalid correct_answer: ${correctIndex}, defaulting to 1`)
    correctIndex = 1
  }
  
  // Handle database inconsistencies: recalculate correctness based on actual data
  const actuallyCorrect = selectedIndex === correctIndex
  
  if (actuallyCorrect && !response.is_correct) {
    console.warn(`Question ${questionNumber}: Database inconsistency - user selected correct answer but marked wrong. Skipping this question.`)
    // Skip questions where user was actually correct but marked wrong
    return ''
  }
  
  if (!actuallyCorrect && response.is_correct) {
    console.warn(`Question ${questionNumber}: Database inconsistency - user selected wrong answer but marked correct.`)
    // Continue showing this as it's useful feedback
  }
  
  console.log(`Question ${questionNumber}:`)
  console.log(`- Selected: "${response.selected_answer}" → index ${selectedIndex}`)
  console.log(`- Correct: ${question.correct_answer} → corrected to ${correctIndex}`)
  console.log(`- Is Correct: ${response.is_correct}`)
  
  const selectedText = getAnswerOptionText(question, selectedIndex)
  const correctText = getAnswerOptionText(question, correctIndex)

  return `
    <div class="page">
      ${competencyInfo ? `
        <!-- Competency Banner for first question -->
        <div class="competency-banner ${competencyInfo.statusClass}">
          <h2>${competencyInfo.statusIcon} ${competencyInfo.competency}</h2>
          <div class="competency-stats">
            <span class="score">${competencyInfo.percentage}%</span>
            <span class="breakdown">${competencyInfo.correctCount}/${competencyInfo.totalQuestions} correct</span>
          </div>
        </div>
      ` : ''}
      
      <div class="question-detail">
      <div class="question-header">
        <h4>Question ${questionNumber}</h4>
        <span class="question-type">${question.competency_display_names?.display_name || 'Coaching'}</span>
      </div>

      ${question.scenario ? `
        <div class="scenario-section">
          <h5>🎭 Scenario</h5>
          <div class="scenario-text">${question.scenario.length > 200 ? question.scenario.substring(0, 200) + '...' : question.scenario}</div>
        </div>
      ` : ''}

      <div class="question-section">
        <h5>❓ Question</h5>
        <div class="question-text">${question.question}</div>
      </div>

      <div class="answers-section">
        <div class="answer-comparison">
          <div class="your-answer">
            <h5>Your Approach</h5>
            <div class="answer-text incorrect">${selectedText}</div>
          </div>
          
          <div class="correct-answer">
            <h5>Best Practice</h5>
            <div class="answer-text correct">${correctText}</div>
          </div>
        </div>
      </div>

      <div class="explanation-section">
        <h5>💡 Key Learning</h5>
        <div class="explanation-text">${question.explanation || 'Focus on understanding the most effective coaching approach for this situation.'}</div>
      </div>
    </div>
  `
}

/**
 * CSS styles for question analysis report
 */
function getQuestionAnalysisCSS(): string {
  return `
    @page {
      size: A4;
      margin: 20mm;
    }
    
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      line-height: 1.6;
      color: #333;
      background-color: #fff;
      print-color-adjust: exact;
      -webkit-print-color-adjust: exact;
    }

    .report-container {
      max-width: 210mm;
      margin: 0 auto;
      background: white;
      border: none;
    }

    .page {
      page-break-after: always;
      min-height: 100vh;
      padding: 0;
    }

    .page:last-child {
      page-break-after: avoid;
    }

    /* Header Section - Consistent with Main Report */
    .report-header {
      display: flex;
      align-items: center;
      margin-bottom: 30px;
      padding-bottom: 15px;
      border-bottom: 2px solid #e0e4e7;
    }
    
    .logo {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      margin-right: 15px;
    }
    
    .header-content h1 {
      font-size: 20px;
      font-weight: 600;
      color: #4a90e2;
      margin: 0;
      line-height: 1.2;
    }
    
    .subtitle {
      font-size: 12px;
      color: #666;
      margin-top: 2px;
    }

    /* Report Meta Information Section */
    .report-meta-section {
      background: #f8fafc;
      padding: 20px;
      border-radius: 8px;
      margin-bottom: 30px;
      border-left: 4px solid #4a90e2;
    }

    .meta-grid {
      display: grid;
      grid-template-columns: 1fr 1fr 1fr;
      gap: 15px;
    }

    .meta-item {
      text-align: center;
    }

    .meta-label {
      display: block;
      font-size: 11px;
      color: #7a8999;
      text-transform: uppercase;
      font-weight: 600;
      letter-spacing: 0.5px;
      margin-bottom: 4px;
    }

    .meta-value {
      display: block;
      font-size: 13px;
      color: #333;
      font-weight: 500;
    }

    .executive-summary {
      background: #f8f9fa;
      padding: 25px;
      border-radius: 8px;
      margin-bottom: 30px;
      border-left: 4px solid #667eea;
    }

    .executive-summary h2 {
      color: #667eea;
      font-size: 20px;
      margin-bottom: 15px;
    }

    .summary-stats {
      display: flex;
      justify-content: space-around;
      margin-top: 20px;
    }

    .stat-item {
      text-align: center;
    }

    .stat-value {
      display: block;
      font-size: 24px;
      font-weight: bold;
      color: #667eea;
    }

    .stat-label {
      display: block;
      font-size: 12px;
      color: #666;
      text-transform: uppercase;
    }

    /* Competency Banner */
    .competency-banner {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 20px;
      margin-bottom: 25px;
      border-radius: 8px;
      color: white;
    }

    .competency-banner.strength {
      background: linear-gradient(135deg, #10b981 0%, #059669 100%);
    }

    .competency-banner.development {
      background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
    }

    .competency-banner h2 {
      font-size: 18px;
      margin: 0;
      font-weight: 600;
    }

    .competency-banner .competency-stats {
      text-align: right;
    }

    .competency-banner .score {
      display: block;
      font-size: 20px;
      font-weight: bold;
    }

    .competency-banner .breakdown {
      display: block;
      font-size: 12px;
      opacity: 0.9;
    }

    .competency-section {
      margin-bottom: 40px;
      border: 1px solid #e9ecef;
      border-radius: 8px;
      overflow: hidden;
    }

    .competency-header {
      padding: 20px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .competency-header.strength {
      background: linear-gradient(135deg, #10b981 0%, #059669 100%);
      color: white;
    }

    .competency-header.development {
      background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
      color: white;
    }

    .competency-header h2 {
      font-size: 18px;
      margin: 0;
    }

    .competency-stats {
      text-align: right;
    }

    .score {
      display: block;
      font-size: 20px;
      font-weight: bold;
    }

    .breakdown {
      display: block;
      font-size: 12px;
      opacity: 0.9;
    }

    .questions-to-review {
      padding: 25px;
    }

    .questions-to-review h3 {
      color: #d97706;
      margin-bottom: 20px;
      font-size: 16px;
    }

    .perfect-performance {
      padding: 25px;
    }

    .success-message {
      background: #f0fdf4;
      border: 1px solid #bbf7d0;
      border-radius: 6px;
      padding: 20px;
    }

    .success-message h3 {
      color: #059669;
      margin-bottom: 10px;
    }

    .next-steps {
      margin-top: 15px;
    }

    .next-steps h4 {
      color: #059669;
      font-size: 14px;
      margin-bottom: 8px;
    }

    .next-steps ul {
      padding-left: 20px;
    }

    .next-steps li {
      margin: 5px 0;
      font-size: 14px;
    }

    .question-detail {
      background: white;
      border: 1px solid #e5e7eb;
      border-radius: 8px;
      margin-bottom: 15px;
      overflow: hidden;
      page-break-inside: avoid;
      min-height: 60vh;
      padding: 15px;
    }

    .question-header {
      background: #f9fafb;
      padding: 15px 20px;
      border-bottom: 1px solid #e5e7eb;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .question-header h4 {
      color: #374151;
      font-size: 16px;
    }

    .question-type {
      background: #667eea;
      color: white;
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 11px;
      text-transform: uppercase;
      font-weight: 600;
    }

    .scenario-section, .question-section, .answers-section, 
    .explanation-section {
      padding: 10px 15px;
      border-bottom: 1px solid #f3f4f6;
    }

    .scenario-section:last-child, .question-section:last-child, 
    .answers-section:last-child, .explanation-section:last-child {
      border-bottom: none;
    }

    .scenario-section h5, .question-section h5, .answers-section h5,
    .explanation-section h5 {
      font-size: 14px;
      font-weight: 600;
      margin-bottom: 6px;
      color: #374151;
    }

    .scenario-text {
      background: #fef3c7;
      border-left: 3px solid #f59e0b;
      padding: 10px;
      border-radius: 4px;
      font-style: italic;
      color: #92400e;
      font-size: 14px;
    }

    .question-text {
      font-weight: 500;
      color: #374151;
      font-size: 14px;
    }

    .answer-comparison {
      display: flex;
      gap: 20px;
    }

    .your-answer, .correct-answer {
      flex: 1;
    }

    .your-answer h5 {
      color: #dc2626;
    }

    .correct-answer h5 {
      color: #059669;
    }

    .answer-text {
      padding: 12px;
      border-radius: 6px;
      font-size: 14px;
      border: 2px solid transparent;
    }

    .answer-text.incorrect {
      background: #fef2f2;
      border-color: #fca5a5;
      color: #991b1b;
    }

    .answer-text.correct {
      background: #f0fdf4;
      border-color: #86efac;
      color: #166534;
    }

    .explanation-text {
      background: #eff6ff;
      border-left: 3px solid #3b82f6;
      padding: 10px;
      border-radius: 4px;
      color: #1e40af;
      font-size: 14px;
    }


    .study-recommendations {
      background: #f1f5f9;
      padding: 25px;
      border-radius: 8px;
      margin-top: 30px;
      page-break-before: always;
      page-break-inside: avoid;
      min-height: 80vh;
    }

    .study-recommendations h2 {
      color: #0f172a;
      font-size: 20px;
      margin-bottom: 20px;
    }

    .recommendation-box {
      background: white;
      border-radius: 6px;
      padding: 20px;
      margin-bottom: 20px;
      border: 1px solid #e2e8f0;
    }

    .recommendation-box h3 {
      color: #0f172a;
      font-size: 16px;
      margin-bottom: 15px;
    }

    .recommendation-box ul, .recommendation-box ol {
      padding-left: 20px;
    }

    .recommendation-box li {
      margin: 8px 0;
      line-height: 1.5;
    }


    @media print {
      .report-container {
        margin: 0;
        padding: 0;
      }
      
      .page {
        margin: 0;
        padding: 0;
        page-break-after: always;
      }
      
      .page:last-child {
        page-break-after: avoid;
      }
      
      .meta-grid {
        grid-template-columns: 1fr 1fr 1fr;
        gap: 10px;
      }
      
      .report-meta-section {
        page-break-inside: avoid;
      }
      
      .competency-section {
        page-break-inside: avoid;
        break-inside: avoid;
      }
      
      .question-detail {
        page-break-inside: avoid;
        break-inside: avoid;
        margin-bottom: 15px;
      }
      
      .study-recommendations {
        page-break-inside: avoid;
        break-inside: avoid;
      }
    }
  `
}