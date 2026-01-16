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
    console.log('📧 EMAIL STEP 1: Email function called')
    console.log('Request method:', req.method)
    console.log('Request URL:', req.url)
    console.log('📧 EMAIL STEP 2: Parsing request body...')
    let requestBody
    
    try {
      requestBody = await req.json()
      console.log('✅ Request body parsed successfully')
    } catch (parseError) {
      console.error('❌ Failed to parse request JSON:', parseError)
      return new Response(
        JSON.stringify({ 
          error: 'Invalid JSON in request body',
          details: parseError.message 
        }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }
    
    console.log('📧 Email function called with:', { 
      email: requestBody.email, 
      attemptId: requestBody.attemptId,
      hasUserProfile: !!requestBody.userProfile,
      bodyKeys: Object.keys(requestBody || {})
    })

    const { email, attemptId, userProfile } = requestBody

    if (!email || !attemptId) {
      console.error('❌ Missing required fields:', { email: !!email, attemptId: !!attemptId })
      return new Response(
        JSON.stringify({ 
          error: 'Email and attempt ID are required',
          received: { email: !!email, attemptId: !!attemptId }
        }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Get Resend API key from environment
    const resendApiKey = Deno.env.get('RESEND_API_KEY')
    if (!resendApiKey) {
      console.error('❌ RESEND_API_KEY not found in environment')
      return new Response(
        JSON.stringify({ error: 'RESEND_API_KEY environment variable is required' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Get Supabase client to fetch assessment data
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')
    
    console.log('🔑 Environment check:', { 
      hasSupabaseUrl: !!supabaseUrl, 
      hasSupabaseKey: !!supabaseKey,
      hasResendKey: !!resendApiKey
    })
    
    if (!supabaseUrl || !supabaseKey) {
      console.error('❌ Supabase environment variables missing')
      return new Response(
        JSON.stringify({ error: 'Supabase environment variables are required' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Fetch the enriched assessment data from the database including assessment title
    console.log('📊 Fetching attempt data for ID:', attemptId)
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || supabaseKey
    const attemptResponse = await fetch(`${supabaseUrl}/rest/v1/user_assessment_attempts?id=eq.${attemptId}&select=*,assessments!inner(title)`, {
      headers: {
        'apikey': serviceRoleKey,
        'Authorization': `Bearer ${serviceRoleKey}`,
        'Content-Type': 'application/json'
      }
    })

    if (!attemptResponse.ok) {
      console.error('❌ Failed to fetch attempt data:', attemptResponse.status, attemptResponse.statusText)
      const errorText = await attemptResponse.text()
      console.error('Response body:', errorText)
      
      return new Response(
        JSON.stringify({ 
          error: 'Failed to fetch attempt data', 
          status: attemptResponse.status,
          details: errorText
        }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    const attemptData = await attemptResponse.json()
    console.log('📋 Found attempts:', attemptData.length)
    
    if (!attemptData || attemptData.length === 0) {
      console.error('❌ No assessment attempt found for ID:', attemptId)
      return new Response(
        JSON.stringify({ error: 'Assessment attempt not found', attemptId }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    const attempt = attemptData[0]
    const assessmentData = attempt.enriched_data
    const assessmentTitle = attempt.assessments?.title || 'Coaching Assessment'

    console.log('🔍 Attempt found:', {
      id: attempt.id,
      assessmentTitle: assessmentTitle,
      hasEnrichedData: !!assessmentData,
      enrichedDataKeys: assessmentData ? Object.keys(assessmentData) : []
    })

    if (!assessmentData) {
      console.error('❌ No enriched assessment data found')
      return new Response(
        JSON.stringify({ error: 'No enriched assessment data found for this attempt' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Generate both PDFs - main report and question analysis
    console.log('📄 Generating main PDF report...')
    
    const pdfResponse = await fetch(`${supabaseUrl}/functions/v1/generate-pdf-report`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${serviceRoleKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        attemptId,
        assessmentData,
        userEmail: email
      })
    })
    
    if (!pdfResponse.ok) {
      const errorText = await pdfResponse.text()
      console.error('❌ Main PDF generation failed:', pdfResponse.status, errorText)
      return new Response(
        JSON.stringify({ 
          error: 'Failed to generate main PDF report', 
          details: errorText 
        }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }
    
    const pdfResult = await pdfResponse.json()
    console.log('✅ Main PDF generated successfully:', pdfResult.token)
    const mainDownloadUrl = pdfResult.downloadUrl
    
    // Wait a moment before generating second PDF to avoid PDFShift rate limits
    console.log('📧 EMAIL STEP 4: Waiting 2 seconds before generating question analysis PDF...')
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    // Generate question analysis PDF
    console.log('📧 EMAIL STEP 5: Calling generate-question-analysis-report function...')
    console.log('Request data:', {
      attemptId,
      userEmail: email,
      hasAssessmentData: !!assessmentData
    })
    
    const questionAnalysisPdfResponse = await fetch(`${supabaseUrl}/functions/v1/generate-question-analysis-report`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${serviceRoleKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        attemptId,
        assessmentData,
        userEmail: email
      })
    })
    
    console.log('📧 EMAIL STEP 5: Question analysis response status:', questionAnalysisPdfResponse.status, questionAnalysisPdfResponse.statusText)
    
    let questionAnalysisDownloadUrl = null
    let questionAnalysisGenerated = false
    
    if (questionAnalysisPdfResponse.ok) {
      const questionAnalysisResult = await questionAnalysisPdfResponse.json()
      console.log('✅ Question analysis PDF generated successfully:', questionAnalysisResult.token)
      questionAnalysisDownloadUrl = questionAnalysisResult.downloadUrl
      questionAnalysisGenerated = true
    } else {
      const errorText = await questionAnalysisPdfResponse.text()
      console.warn('⚠️ Question analysis PDF generation failed (non-critical):', questionAnalysisPdfResponse.status, errorText)
      // Continue with main PDF only - question analysis is optional
    }
    
    const downloadUrl = mainDownloadUrl // Keep backwards compatibility
    const pdfGenerated = true
    
    // Create email content with download links using actual assessment title
    const emailSubject = `Your ${assessmentTitle} Assessment Report`
    const emailHtml = await createEmailTemplate(assessmentData, userProfile, downloadUrl, pdfGenerated, assessmentTitle, questionAnalysisDownloadUrl, questionAnalysisGenerated)
    const emailText = await createEmailTextVersion(assessmentData, userProfile, downloadUrl, pdfGenerated, assessmentTitle, questionAnalysisDownloadUrl, questionAnalysisGenerated)

    // Send email via Resend API
    console.log('📧 EMAIL STEP 6: Sending email via Resend API...')
    console.log('Sending to:', email)
    console.log('Subject:', emailSubject)
    
    const emailResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${resendApiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        from: 'Your Coaching Hub <noreply@forwardfocus-coaching.co.uk>',
        to: email,
        subject: emailSubject,
        html: emailHtml,
        text: emailText
      })
    })

    if (!emailResponse.ok) {
      const errorText = await emailResponse.text()
      console.error('❌ Resend API error:', emailResponse.status, errorText)
      
      return new Response(
        JSON.stringify({ 
          error: 'Failed to send email', 
          details: errorText 
        }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    const emailResult = await emailResponse.json()
    console.log('✅ Email sent successfully:', emailResult.id)

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Assessment report sent successfully',
        emailId: emailResult.id
      }),
      { 
        headers: { 
          ...corsHeaders, 
          'Content-Type': 'application/json' 
        } 
      }
    )

  } catch (error) {
    console.error('❌ Email function error:', error)
    console.error('Error stack:', error.stack)
    console.error('Error name:', error.name)
    console.error('Error message:', error.message)
    
    return new Response(
      JSON.stringify({ 
        error: 'Failed to send assessment report', 
        details: error.message,
        name: error.name,
        stack: error.stack?.split('\n').slice(0, 3) // First few lines of stack trace
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

// Generate fresh insights from normalized database tables (like frontend does)
async function generateFreshInsightsFromDatabase(competency_stats: any[], framework: string = 'core') {
  console.log('🔍 EMAIL: Generating fresh insights from database for competencies:', competency_stats.map(c => `${c.area}: ${c.percentage}%`))
  
  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || Deno.env.get('SUPABASE_ANON_KEY')
  
  if (!supabaseUrl || !serviceRoleKey) {
    console.error('❌ EMAIL: Missing Supabase credentials for database queries')
    return { weakAreas: [], strengths: [] }
  }
  
  // Get framework and analysis type IDs first (like PDF function)
  const frameworkResponse = await fetch(`${supabaseUrl}/rest/v1/frameworks?code=eq.${framework}&select=id`, {
    headers: {
      'apikey': serviceRoleKey,
      'Authorization': `Bearer ${serviceRoleKey}`,
      'Content-Type': 'application/json'
    }
  })
  
  if (!frameworkResponse.ok) {
    console.error('❌ EMAIL: Failed to fetch framework data')
    return { weakAreas: [], strengths: [] }
  }
  
  const frameworkData = await frameworkResponse.json()
  if (!frameworkData || frameworkData.length === 0) {
    console.error('❌ EMAIL: Framework not found:', framework)
    return { weakAreas: [], strengths: [] }
  }
  
  const frameworkId = frameworkData[0].id
  
  // Get assessment level ID (beginner)
  const levelResponse = await fetch(`${supabaseUrl}/rest/v1/assessment_levels?framework_id=eq.${frameworkId}&level_code=eq.beginner&select=id`, {
    headers: {
      'apikey': serviceRoleKey,
      'Authorization': `Bearer ${serviceRoleKey}`,
      'Content-Type': 'application/json'
    }
  })
  
  if (!levelResponse.ok) {
    console.error('❌ EMAIL: Failed to fetch assessment level data')
    return { weakAreas: [], strengths: [] }
  }
  
  const levelData = await levelResponse.json()
  if (!levelData || levelData.length === 0) {
    console.error('❌ EMAIL: Assessment level not found for framework:', framework)
    return { weakAreas: [], strengths: [] }
  }
  
  const assessmentLevelId = levelData[0].id
  
  const weakAreas = []
  const strengths = []
  
  for (const comp of competency_stats) {
    const { area, percentage, correct, total } = comp
    const analysisType = percentage >= 70 ? 'strength' : 'weakness'
    
    try {
      // Get competency ID
      const competencyResponse = await fetch(`${supabaseUrl}/rest/v1/competency_display_names?framework_id=eq.${frameworkId}&display_name=eq.${encodeURIComponent(area)}&select=id`, {
        headers: {
          'apikey': serviceRoleKey,
          'Authorization': `Bearer ${serviceRoleKey}`,
          'Content-Type': 'application/json'
        }
      })
      
      if (!competencyResponse.ok) {
        console.warn(`⚠️ EMAIL: Failed to fetch competency data for ${area}`)
        continue
      }
      
      const competencyData = await competencyResponse.json()
      if (!competencyData || competencyData.length === 0) {
        console.warn(`⚠️ EMAIL: Competency not found: ${area}`)
        continue
      }
      
      const competencyId = competencyData[0].id
      
      // Get analysis type ID
      const analysisTypeResponse = await fetch(`${supabaseUrl}/rest/v1/analysis_types?code=eq.${analysisType}&select=id`, {
        headers: {
          'apikey': serviceRoleKey,
          'Authorization': `Bearer ${serviceRoleKey}`,
          'Content-Type': 'application/json'
        }
      })
      
      if (!analysisTypeResponse.ok) {
        console.warn(`⚠️ EMAIL: Failed to fetch analysis type data for ${analysisType}`)
        continue
      }
      
      const analysisTypeData = await analysisTypeResponse.json()
      if (!analysisTypeData || analysisTypeData.length === 0) {
        console.warn(`⚠️ EMAIL: Analysis type not found: ${analysisType}`)
        continue
      }
      
      const analysisTypeId = analysisTypeData[0].id
      
      // Query performance analysis using new comprehensive view
      const assessmentLevel = 'beginner' // TODO: Get from context or parameter
      const analysisResponse = await fetch(`${supabaseUrl}/rest/v1/performance_analysis_with_analysis_type?competency_id=eq.${competencyId}&analysis_type_code=eq.${analysisType}&framework_code=eq.${framework}&assessment_level=eq.${assessmentLevel}&score_min=lte.${percentage}&score_max=gte.${percentage}&is_active=eq.true&order=tier_display_order&limit=1`, {
        headers: {
          'apikey': serviceRoleKey,
          'Authorization': `Bearer ${serviceRoleKey}`,
          'Content-Type': 'application/json'
        }
      })
      
      let analysisText = `${area} needs focused development to improve coaching effectiveness.`
      if (analysisResponse.ok) {
        const analysisData = await analysisResponse.json()
        if (analysisData && analysisData.length > 0) {
          analysisText = analysisData[0].analysis_text
        }
      }
      
      if (analysisType === 'strength') {
        strengths.push({
          area,
          percentage,
          correct,
          total,
          message: analysisText
        })
      } else {
        weakAreas.push({
          area,
          percentage,
          correct,
          total,
          insights: [analysisText]
        })
      }
      
    } catch (error) {
      console.error(`❌ Error fetching insights for ${area}:`, error)
      // Add fallback data
      if (analysisType === 'strength') {
        strengths.push({
          area,
          percentage,
          correct,
          total,
          message: `${area} is one of your strongest coaching competencies.`
        })
      } else {
        weakAreas.push({
          area,
          percentage,
          correct,
          total,
          insights: [`Focus on developing ${area} skills to improve your coaching effectiveness.`]
        })
      }
    }
  }
  
  console.log('✅ Generated insights:', {
    strengths: strengths.length,
    weakAreas: weakAreas.length
  })
  
  return { weakAreas, strengths }
}

async function createEmailTemplate(assessmentData: any, userProfile: any, downloadUrl: string, pdfGenerated: boolean = false, assessmentTitle: string = 'Coaching Assessment', questionAnalysisUrl?: string, questionAnalysisGenerated: boolean = false): Promise<string> {
  // Extract data from new lean structure
  const { overall_stats, assessment_framework, performance_analysis, competency_performance } = assessmentData
  
  // Create competency stats from the lean structure
  const competency_stats = competency_performance?.map((comp: any) => ({
    area: comp.competency_area,
    percentage: comp.percentage,
    correct: comp.correct,
    total: comp.total
  })) || []
  
  // Generate fresh insights from database - like the frontend does
  const smart_insights = await generateFreshInsightsFromDatabase(competency_stats, assessment_framework || 'core')
  
  return `
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Your Assessment Report - Your Coaching Hub</title>
        <!--[if mso]>
        <noscript>
            <xml>
                <o:OfficeDocumentSettings>
                    <o:PixelsPerInch>96</o:PixelsPerInch>
                </o:OfficeDocumentSettings>
            </xml>
        </noscript>
        <![endif]-->
        <!-- Work Sans is closest to Inter and works well in Gmail -->
        <style>
            @import url('https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700&display=swap');
        </style>
    </head>
    <body style="margin: 0; padding: 0; font-family: 'Work Sans', Arial, Helvetica, sans-serif; background-color: #fafafa; color: #213547;">
        <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background-color: #fafafa;">
            <tr>
                <td align="center" style="padding: 40px 20px;">
                    <!-- Email Container -->
                    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="600" style="background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06); border: 1px solid #e2e8f0;">
                        
                        <!-- Gmail-Compatible Header with Hero Background -->
                        <tr>
                            <td align="center" style="padding: 0; background-color: #ffffff; border-radius: 8px 8px 0 0;">
                                <!-- Hero Background Table for Gmail Compatibility -->
                                <table width="100%" cellspacing="0" cellpadding="0" border="0" style="background-image: url('https://hfmpacbmbyvnupzgorek.supabase.co/storage/v1/object/public/coaching-downloads/assets/hero-image.png'); background-position: center center; background-repeat: no-repeat; background-size: cover; height: 160px; border-radius: 8px 8px 0 0;">
                                    <tr>
                                        <td align="center" style="padding: 40px 20px; background: linear-gradient(to right, rgba(255,255,255,0.95), rgba(255,255,255,0.85)); height: 160px; vertical-align: middle; border-radius: 8px 8px 0 0;">
                                            <!-- Bulletproof Logo Centering -->
                                            <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                                                <tr>
                                                    <td align="center" style="padding: 10px 0;">
                                                        <img src="https://hfmpacbmbyvnupzgorek.supabase.co/storage/v1/object/public/coaching-downloads/assets/full-logo.png"
                                                             alt="Your Coaching Hub"
                                                             width="240"
                                                             border="0"
                                                             style="display: block; max-width: 240px; height: auto; filter: drop-shadow(0 1px 2px rgba(0, 0, 0, 0.1));">
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        
                        <!-- Main Content -->
                        <tr>
                            <td style="padding: 48px 48px 32px;">
                                
                                <!-- Assessment Report Title -->
                                <h1 style="margin: 0 0 24px; font-size: 32px; font-weight: bold; color: #213547; text-align: center; line-height: 38px; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                    Your Assessment Report is Ready!
                                </h1>
                                
                                <!-- Assessment Title -->
                                <p style="margin: 0 0 32px; font-size: 18px; color: #64748b; line-height: 27px; text-align: center; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                    ${assessmentTitle}
                                </p>
                                
                                <!-- Welcome Message -->
                                <p style="margin: 0 0 32px; font-size: 16px; color: #475569; line-height: 24px; text-align: center; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                    Congratulations on completing your <strong>${assessmentTitle}</strong> assessment! ${pdfGenerated ? 'Your personalized PDF reports are ready for download.' : 'Your results are available below, and we\'re currently preparing your detailed PDF reports.'}
                                </p>
                                
                                ${questionAnalysisGenerated ? `
                                <!-- Two Reports Notice -->
                                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background-color: #f0f7ff; border: 1px solid #3b82f6; border-radius: 6px; margin: 32px 0;">
                                    <tr>
                                        <td style="padding: 20px 24px;">
                                            <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                                                <tr>
                                                    <td width="30" style="vertical-align: top;">
                                                        <span style="color: #3b82f6; font-size: 18px;">📋</span>
                                                    </td>
                                                    <td>
                                                        <h3 style="margin: 0 0 8px; font-size: 16px; font-weight: bold; color: #1565c0; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">Two Reports Available</h3>
                                                        <p style="margin: 0; font-size: 14px; color: #1565c0; line-height: 20px; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                                            <strong>Main Report:</strong> Executive summary with insights and learning resources<br>
                                                            <strong>Question Analysis:</strong> Detailed breakdown of each question with coaching scenarios and explanations
                                                        </p>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                                ` : ''}
                                
                                <!-- Overall Score Highlight -->
                                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 6px; margin: 32px 0;">
                                    <tr>
                                        <td style="padding: 32px 28px; text-align: center;">
                                            <div style="font-size: 48px; font-weight: bold; color: #3451b2; margin-bottom: 8px; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                                ${overall_stats?.score || 0}%
                                            </div>
                                            <div style="font-size: 16px; color: #64748b; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                                Overall Score
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                                
                                <!-- Key Highlights -->
                                <h3 style="margin: 32px 0 20px; font-size: 20px; font-weight: bold; color: #213547; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                    Key Highlights from Your Report:
                                </h3>
                                
                                ${smart_insights?.strengths?.length ? `
                                <!-- Strengths Section -->
                                <h4 style="margin: 24px 0 12px; font-size: 16px; font-weight: bold; color: #334155; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                    🌟 Your Top Strengths:
                                </h4>
                                ${smart_insights.strengths.slice(0, 2).map((strength: any) => `
                                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background-color: #f8fafc; border-left: 4px solid #10b981; border-radius: 0 6px 6px 0; margin: 12px 0;">
                                    <tr>
                                        <td style="padding: 16px 20px;">
                                            <p style="margin: 0; font-size: 14px; color: #475569; line-height: 20px; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                                <strong>${strength.area}:</strong> ${strength.message}
                                            </p>
                                        </td>
                                    </tr>
                                </table>
                                `).join('')}
                                ` : ''}
                                
                                ${smart_insights?.weakAreas?.length ? `
                                <!-- Development Areas Section -->
                                <h4 style="margin: 24px 0 12px; font-size: 16px; font-weight: bold; color: #334155; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                    🎯 Priority Development Areas:
                                </h4>
                                ${smart_insights.weakAreas.map((area: any) => `
                                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background-color: #f8fafc; border-left: 4px solid #f59e0b; border-radius: 0 6px 6px 0; margin: 12px 0;">
                                    <tr>
                                        <td style="padding: 16px 20px;">
                                            <p style="margin: 0; font-size: 14px; color: #475569; line-height: 20px; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                                <strong>${area.area}:</strong> ${area.insights?.[0] || area.insight || 'Focus on building strength in this area'}
                                            </p>
                                        </td>
                                    </tr>
                                </table>
                                `).join('')}
                                ` : ''}
                                
                                ${competency_stats?.length ? `
                                <!-- Competency Breakdown -->
                                <h4 style="margin: 24px 0 12px; font-size: 16px; font-weight: bold; color: #334155; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                    📊 Competency Breakdown:
                                </h4>
                                ${competency_stats.map((comp: any) => `
                                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background-color: #f8fafc; border-left: 4px solid #3451b2; border-radius: 0 6px 6px 0; margin: 12px 0;">
                                    <tr>
                                        <td style="padding: 16px 20px;">
                                            <p style="margin: 0; font-size: 14px; color: #475569; line-height: 20px; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                                <strong>${comp.area}:</strong> ${comp.percentage}% (${comp.correct}/${comp.total} correct)
                                            </p>
                                        </td>
                                    </tr>
                                </table>
                                `).join('')}
                                ` : ''}
                                
                                <!-- What's Included -->
                                <p style="margin: 32px 0 16px; font-size: 16px; font-weight: bold; color: #213547; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                    Your detailed PDF report includes:
                                </p>
                                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                                    <tr>
                                        <td style="padding: 4px 0;">
                                            <p style="margin: 0; font-size: 14px; color: #475569; line-height: 20px; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                                • Complete competency analysis with personalized insights
                                            </p>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 4px 0;">
                                            <p style="margin: 0; font-size: 14px; color: #475569; line-height: 20px; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                                • Specific action steps for each skill area
                                            </p>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 4px 0;">
                                            <p style="margin: 0; font-size: 14px; color: #475569; line-height: 20px; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                                • Curated learning resources and next steps
                                            </p>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 4px 0;">
                                            <p style="margin: 0; font-size: 14px; color: #475569; line-height: 20px; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                                • Professional formatting for easy sharing
                                            </p>
                                        </td>
                                    </tr>
                                </table>
                                
                                <!-- CTA Buttons - Gmail Compatible with Better Spacing -->
                                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="margin: 32px 0;">
                                    <!-- Main Report Button -->
                                    <tr>
                                        <td align="center" style="padding: 20px 0;">
                                            <table role="presentation" cellspacing="0" cellpadding="0" border="0">
                                                <tr>
                                                    <td align="center" style="background: ${pdfGenerated ? '#10b981' : '#6c757d'}; border-radius: 6px; mso-padding-alt: 0;">
                                                        <!--[if mso]>
                                                        <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                                                        <tr>
                                                            <td align="center" style="padding: 12px 24px;">
                                                        <![endif]-->
                                                        <a href="${downloadUrl}" 
                                                           style="display: inline-block; padding: 12px 24px; color: #ffffff; text-decoration: none; font-size: 16px; font-weight: bold; font-family: 'Work Sans', Arial, Helvetica, sans-serif; border-radius: 6px; background: ${pdfGenerated ? '#10b981' : '#6c757d'};">
                                                            ${pdfGenerated ? '📄 Download Main Report' : '⏳ Main Report Being Prepared'}
                                                        </a>
                                                        <!--[if mso]>
                                                            </td>
                                                        </tr>
                                                        </table>
                                                        <![endif]-->
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    
                                    ${questionAnalysisUrl ? `
                                    <!-- Question Analysis Button -->
                                    <tr>
                                        <td align="center" style="padding: 20px 0;">
                                            <table role="presentation" cellspacing="0" cellpadding="0" border="0">
                                                <tr>
                                                    <td align="center" style="background: ${questionAnalysisGenerated ? '#10b981' : '#6c757d'}; border-radius: 6px; mso-padding-alt: 0;">
                                                        <!--[if mso]>
                                                        <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                                                        <tr>
                                                            <td align="center" style="padding: 12px 24px;">
                                                        <![endif]-->
                                                        <a href="${questionAnalysisUrl}" 
                                                           style="display: inline-block; padding: 12px 24px; color: #ffffff; text-decoration: none; font-size: 16px; font-weight: bold; font-family: 'Work Sans', Arial, Helvetica, sans-serif; border-radius: 6px; background: ${questionAnalysisGenerated ? '#10b981' : '#6c757d'};">
                                                            ${questionAnalysisGenerated ? '📋 Download Question Analysis' : '⏳ Question Analysis Being Prepared'}
                                                        </a>
                                                        <!--[if mso]>
                                                            </td>
                                                        </tr>
                                                        </table>
                                                        <![endif]-->
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    ` : ''}
                                    
                                    <!-- Take Another Assessment Button -->
                                    <tr>
                                        <td align="center" style="padding: 20px 0;">
                                            <table role="presentation" cellspacing="0" cellpadding="0" border="0">
                                                <tr>
                                                    <td align="center" style="background: #3451b2; border-radius: 6px; mso-padding-alt: 0;">
                                                        <!--[if mso]>
                                                        <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                                                        <tr>
                                                            <td align="center" style="padding: 12px 24px;">
                                                        <![endif]-->
                                                        <a href="https://www.yourcoachinghub.co.uk/docs/assessments" 
                                                           style="display: inline-block; padding: 12px 24px; color: #ffffff; text-decoration: none; font-size: 16px; font-weight: bold; font-family: 'Work Sans', Arial, Helvetica, sans-serif; border-radius: 6px; background: #3451b2;">
                                                            Take Another Assessment
                                                        </a>
                                                        <!--[if mso]>
                                                            </td>
                                                        </tr>
                                                        </table>
                                                        <![endif]-->
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                                
                                <!-- Closing Message -->
                                <p style="margin: 24px 0 32px; font-size: 16px; color: #475569; line-height: 24px; text-align: center; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                    Questions about your results? We're here to help you on your coaching journey!
                                </p>
                                
                                <p style="margin: 0; font-size: 16px; color: #475569; line-height: 24px; text-align: center; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                    Best regards,<br>The Your Coaching Hub Team
                                </p>
                            </td>
                        </tr>
                        
                        <!-- Clean Footer -->
                        <tr>
                            <td style="padding: 32px 48px; background-color: #f8fafc; border-top: 1px solid #e2e8f0; border-radius: 0 0 8px 8px;">
                                <!-- Generation Info -->
                                <p style="margin: 0 0 20px; font-size: 14px; color: #64748b; text-align: center; line-height: 21px; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                    This report was generated on ${new Date().toLocaleDateString()} at ${new Date().toLocaleTimeString()}
                                </p>
                                
                                <!-- Quick Links -->
                                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                                    <tr>
                                        <td align="center" style="padding: 0 0 20px;">
                                            <a href="https://www.yourcoachinghub.co.uk" style="color: #3451b2; text-decoration: none; font-size: 14px; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">Visit Your Coaching Hub</a>
                                            <span style="color: #cbd5e0; margin: 0 8px;">•</span>
                                            <a href="https://www.yourcoachinghub.co.uk/docs/privacy-policy" style="color: #3451b2; text-decoration: none; font-size: 14px; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">Privacy Policy</a>
                                        </td>
                                    </tr>
                                </table>
                                
                                <!-- Copyright -->
                                <p style="margin: 0; font-size: 12px; color: #94a3b8; text-align: center; line-height: 18px; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                    © 2025 Your Coaching Hub - Coaching Made Simple
                                </p>
                            </td>
                        </tr>
                    </table>
                    
                    <!-- Subtle Security Footer -->
                    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="600">
                        <tr>
                            <td style="padding: 24px 20px; text-align: center;">
                                <p style="margin: 0; font-size: 11px; color: #94a3b8; line-height: 16px; font-family: 'Work Sans', Arial, Helvetica, sans-serif;">
                                    This assessment report was generated for your account at Your Coaching Hub.
                                </p>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </body>
    </html>
  `
}

async function createEmailTextVersion(assessmentData: any, userProfile: any, downloadUrl: string, pdfGenerated: boolean = false, assessmentTitle: string = 'Coaching Assessment', questionAnalysisUrl?: string, questionAnalysisGenerated: boolean = false): Promise<string> {
  // Extract data from new lean structure
  const { overall_stats, assessment_framework, performance_analysis, competency_performance } = assessmentData
  
  // Create competency stats from the lean structure
  const competency_stats = competency_performance?.map((comp: any) => ({
    area: comp.competency_area,
    percentage: comp.percentage,
    correct: comp.correct,
    total: comp.total
  })) || []
  
  // Generate fresh insights from database - like the frontend does
  const smart_insights = await generateFreshInsightsFromDatabase(competency_stats, assessment_framework || 'core')
  
  let textContent = `
Your Assessment Report is Ready!

Hi,

Congratulations on completing your ${assessmentTitle} assessment!

${questionAnalysisGenerated ? `
📋 Two Reports Available:
• Main Report: Executive summary with insights and learning resources
• Question Analysis: Detailed breakdown of each question with coaching scenarios and explanations
` : ''}

Your Results:
- Overall Score: ${overall_stats?.score || 0}%
- Assessment: ${assessmentTitle}
- Questions: ${overall_stats?.correct_answers || 0}/${overall_stats?.total_questions || 0} correct
`

  if (smart_insights?.strengths?.length) {
    textContent += `\n\nYour Top Strengths:\n`
    smart_insights.strengths.forEach((strength: any) => {
      textContent += `- ${strength.area}: ${strength.message}\n`
    })
  }

  if (smart_insights?.weakAreas?.length) {
    textContent += `\n\nPriority Development Areas:\n`
    smart_insights.weakAreas.forEach((area: any) => {
      textContent += `- ${area.area}: ${area.insights?.[0] || area.insight || 'Focus on building strength in this area'}\n`
    })
  }

  if (competency_stats?.length) {
    textContent += `\n\nCompetency Breakdown:\n`
    competency_stats.forEach((comp: any) => {
      textContent += `- ${comp.area}: ${comp.percentage}% (${comp.correct}/${comp.total} correct)\n`
    })
  }

  textContent += `

Your detailed PDF report includes:
- Complete competency analysis with personalized insights
- Specific action steps for each skill area
- Curated learning resources and next steps
- Professional formatting for easy sharing

${pdfGenerated ? '📄 Download Main Report' : '⏳ Main Report Being Prepared'}: ${downloadUrl}
${questionAnalysisUrl && questionAnalysisGenerated ? `📋 Download Question Analysis: ${questionAnalysisUrl}` : ''}

Take more assessments: https://www.yourcoachinghub.co.uk/docs/assessments

Questions? We're here to help you on your coaching journey!

Best regards,
The Your Coaching Hub Team

---
This report was generated on ${new Date().toLocaleDateString()} at ${new Date().toLocaleTimeString()}
Privacy Policy: https://www.yourcoachinghub.co.uk/docs/privacy-policy
Your Coaching Hub: https://www.yourcoachinghub.co.uk
`

  return textContent
}