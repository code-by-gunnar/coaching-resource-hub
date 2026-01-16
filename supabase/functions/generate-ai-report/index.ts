// Edge Function: generate-ai-report
// Purpose: Generate personalized AI assessment reports using Claude Sonnet
// Design Doc: .plans/2026-01-16-ai-generated-assessment-reports-design.md

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// ============================================================================
// FORBIDDEN TERMS FILTER
// ============================================================================
const FORBIDDEN_TERMS = [
  'wisdom', 'inner wisdom', 'profound', 'transformational',
  'journey', 'inner voice', 'sacred', 'universe', 'manifest',
  'authentic self', 'divine', 'spiritual', 'enlighten',
  'transcend', 'awaken', 'soul', 'energy healing', 'vibration',
  'mystical', 'cosmic', 'chakra'
]

function validateReport(report: string): { valid: boolean; violations: string[] } {
  const lowerReport = report.toLowerCase()
  const violations = FORBIDDEN_TERMS.filter(term => lowerReport.includes(term))
  return { valid: violations.length === 0, violations }
}

// ============================================================================
// INTERFACES
// ============================================================================
interface GenerateReportRequest {
  attempt_id: string
}

interface QuestionDetail {
  id: string
  scenario_text: string
  question_text: string
  options: { key: string; text: string }[]
  correct_option: string
  concept_tag: string
  explanation: string
  ai_hint: string | null
  competency_name: string
  competency_code: string
  user_answer: string | null
  is_correct: boolean
}

interface CompetencyScore {
  correct: number
  total: number
  percentage: number
}

interface AttemptContext {
  attempt_id: string
  framework_code: string
  framework_name: string
  level_code: string
  level_name: string
  passing_score: number
  score_percentage: number
  competency_scores: Record<string, CompetencyScore>
  questions: QuestionDetail[]
  previous_attempt?: {
    score_percentage: number
    competency_scores: Record<string, CompetencyScore>
    completed_at: string
  }
}

// ============================================================================
// SYSTEM PROMPT
// ============================================================================
const SYSTEM_PROMPT = `You are an experienced life coach with over 10 years of professional coaching experience. You provide direct, honest, evidence-based feedback grounded in established coaching frameworks.

## Your Voice
- Direct and practical, never airy-fairy or mystical
- Evidence-based: reference specific answers and patterns
- Peer-to-peer tone: you're a fellow professional, not a guru
- Acknowledge both strengths and development areas honestly
- Use professional coaching terminology (ICF Core Competencies, etc.)

## Forbidden Language
Never use: "wisdom," "inner wisdom," "transformational," "journey," "inner voice," "profound," "sacred," "universe," "energy" (in spiritual sense), "manifest," "authentic self," "divine," "spiritual," "enlighten," "transcend," "awaken," "soul," "mystical," "cosmic," "chakra," "vibration"

## Report Structure
Generate a personalized coaching assessment report in Markdown format with these sections:

1. **Overall Assessment** (2-3 sentences)
   - Honest summary of performance
   - Key pattern observed

2. **Strength Areas** (for competencies ≥70%)
   - What specifically they did well (reference specific answers)
   - How to leverage this strength

3. **Development Areas** (for competencies <70%)
   - Specific patterns in wrong answers (not just "you scored low")
   - What the wrong answers reveal about gaps
   - Concrete, actionable next steps

4. **Cross-Competency Insights**
   - Connections between strengths and development areas
   - How one area could support another

5. **Progress Notes** (if repeat assessment - ONLY include if previous attempt data is provided)
   - What improved since last time
   - What remains consistent
   - Adjusted recommendations

6. **Priority Focus**
   - Single most impactful area to focus on
   - Why this matters
   - One specific practice to start this week`

// ============================================================================
// BUILD USER PROMPT
// ============================================================================
function buildUserPrompt(context: AttemptContext): string {
  const { framework_name, level_name, score_percentage, competency_scores, questions, previous_attempt } = context

  // Group questions by competency
  const questionsByCompetency: Record<string, QuestionDetail[]> = {}
  for (const q of questions) {
    if (!questionsByCompetency[q.competency_name]) {
      questionsByCompetency[q.competency_name] = []
    }
    questionsByCompetency[q.competency_name].push(q)
  }

  // Build competency summary
  let competencySummary = ''
  for (const [compName, score] of Object.entries(competency_scores)) {
    const status = score.percentage >= 70 ? '✓ Strength' : '⚠ Development Area'
    competencySummary += `- ${compName}: ${score.correct}/${score.total} (${score.percentage}%) ${status}\n`
  }

  // Build detailed answer analysis
  let answerAnalysis = ''
  for (const [compName, compQuestions] of Object.entries(questionsByCompetency)) {
    answerAnalysis += `\n### ${compName}\n`
    for (const q of compQuestions) {
      const resultIcon = q.is_correct ? '✓' : '✗'
      const userAnswerText = q.options.find(o => o.key === q.user_answer)?.text || 'No answer'
      const correctAnswerText = q.options.find(o => o.key === q.correct_option)?.text || ''

      answerAnalysis += `\n**Question (${q.concept_tag}):** ${q.question_text}\n`
      answerAnalysis += `- Scenario: ${q.scenario_text.substring(0, 200)}...\n`
      answerAnalysis += `- User selected: ${resultIcon} "${userAnswerText}"\n`

      if (!q.is_correct) {
        answerAnalysis += `- Correct answer: "${correctAnswerText}"\n`
        answerAnalysis += `- Why correct: ${q.explanation}\n`
        if (q.ai_hint) {
          answerAnalysis += `- Common mistake pattern: ${q.ai_hint}\n`
        }
      }
    }
  }

  // Build previous attempt comparison if exists
  let previousAttemptSection = ''
  if (previous_attempt) {
    const scoreDiff = score_percentage - previous_attempt.score_percentage
    const direction = scoreDiff > 0 ? 'improved' : scoreDiff < 0 ? 'decreased' : 'unchanged'

    previousAttemptSection = `
## Previous Attempt Comparison
- Previous score: ${previous_attempt.score_percentage}%
- Current score: ${score_percentage}%
- Change: ${scoreDiff > 0 ? '+' : ''}${scoreDiff.toFixed(1)}% (${direction})
- Previous attempt date: ${previous_attempt.completed_at}

### Competency Changes:`

    for (const [compName, currentScore] of Object.entries(competency_scores)) {
      const prevScore = previous_attempt.competency_scores[compName]
      if (prevScore) {
        const diff = currentScore.percentage - prevScore.percentage
        previousAttemptSection += `\n- ${compName}: ${prevScore.percentage}% → ${currentScore.percentage}% (${diff > 0 ? '+' : ''}${diff.toFixed(1)}%)`
      }
    }
  }

  return `## Assessment Context
- Framework: ${framework_name}
- Level: ${level_name}
- Overall Score: ${score_percentage}%
- Passing Score: ${context.passing_score}%
- Result: ${score_percentage >= context.passing_score ? 'PASSED' : 'BELOW PASSING'}

## Competency Scores
${competencySummary}
${previousAttemptSection}

## Detailed Answer Analysis
${answerAnalysis}

---
Please generate a personalized assessment report following the structure in your instructions. Be specific about what the wrong answers reveal and provide actionable guidance.`
}

// ============================================================================
// CALL CLAUDE API
// ============================================================================
async function callClaudeAPI(systemPrompt: string, userPrompt: string): Promise<{ report: string; metadata: object }> {
  const apiKey = Deno.env.get('ANTHROPIC_API_KEY')
  if (!apiKey) {
    throw new Error('ANTHROPIC_API_KEY not configured')
  }

  const startTime = Date.now()

  const response = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01'
    },
    body: JSON.stringify({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 2000,
      system: systemPrompt,
      messages: [
        { role: 'user', content: userPrompt }
      ]
    })
  })

  if (!response.ok) {
    const errorBody = await response.text()
    throw new Error(`Claude API error: ${response.status} - ${errorBody}`)
  }

  const data = await response.json()
  const generationMs = Date.now() - startTime

  const report = data.content[0]?.text || ''
  const metadata = {
    model: data.model,
    input_tokens: data.usage?.input_tokens,
    output_tokens: data.usage?.output_tokens,
    generated_at: new Date().toISOString(),
    generation_ms: generationMs
  }

  return { report, metadata }
}

// ============================================================================
// GENERATE BASIC FALLBACK REPORT
// ============================================================================
function generateBasicFallbackReport(context: AttemptContext): string {
  const { framework_name, level_name, score_percentage, competency_scores, passing_score } = context
  const passed = score_percentage >= passing_score

  let report = `# ${framework_name} - ${level_name} Assessment Results\n\n`
  report += `## Overall Score: ${score_percentage}%\n\n`
  report += passed
    ? `Congratulations! You passed this assessment.\n\n`
    : `You scored below the passing threshold of ${passing_score}%.\n\n`

  report += `## Competency Breakdown\n\n`

  const strengths: string[] = []
  const development: string[] = []

  for (const [compName, score] of Object.entries(competency_scores)) {
    if (score.percentage >= 70) {
      strengths.push(`- **${compName}**: ${score.percentage}% (${score.correct}/${score.total})`)
    } else {
      development.push(`- **${compName}**: ${score.percentage}% (${score.correct}/${score.total})`)
    }
  }

  if (strengths.length > 0) {
    report += `### Strength Areas\n${strengths.join('\n')}\n\n`
  }

  if (development.length > 0) {
    report += `### Development Areas\n${development.join('\n')}\n\n`
  }

  report += `---\n*Basic report generated. AI-powered insights temporarily unavailable.*`

  return report
}

// ============================================================================
// MAIN HANDLER
// ============================================================================
Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialize Supabase client with service role for full access
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    const { attempt_id } = await req.json() as GenerateReportRequest

    if (!attempt_id) {
      throw new Error('attempt_id is required')
    }

    // ========================================================================
    // FETCH ATTEMPT DATA
    // ========================================================================
    const { data: attempt, error: attemptError } = await supabaseClient
      .from('ai_report_context')
      .select('*')
      .eq('attempt_id', attempt_id)
      .single()

    if (attemptError || !attempt) {
      throw new Error(`Attempt not found: ${attemptError?.message || 'Unknown error'}`)
    }

    // Check if report already exists
    if (attempt.ai_report) {
      return new Response(
        JSON.stringify({
          report: attempt.ai_report,
          metadata: attempt.ai_report_metadata,
          cached: true
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // ========================================================================
    // FETCH QUESTION DETAILS
    // ========================================================================
    const questionIds = attempt.questions_served as string[]
    const answers = attempt.answers as Record<string, string>

    const { data: questions, error: questionsError } = await supabaseClient
      .from('ai_questions')
      .select(`
        id,
        scenario_text,
        question_text,
        options,
        correct_option,
        concept_tag,
        explanation,
        ai_hint,
        competency:ai_competencies(name, code)
      `)
      .in('id', questionIds)

    if (questionsError || !questions) {
      throw new Error(`Failed to fetch questions: ${questionsError?.message}`)
    }

    // Build question details with user answers
    const questionDetails: QuestionDetail[] = questions.map(q => ({
      id: q.id,
      scenario_text: q.scenario_text,
      question_text: q.question_text,
      options: q.options as { key: string; text: string }[],
      correct_option: q.correct_option,
      concept_tag: q.concept_tag,
      explanation: q.explanation,
      ai_hint: q.ai_hint,
      competency_name: q.competency?.name || 'Unknown',
      competency_code: q.competency?.code || 'unknown',
      user_answer: answers[q.id] || null,
      is_correct: answers[q.id] === q.correct_option
    }))

    // ========================================================================
    // BUILD CONTEXT
    // ========================================================================
    const context: AttemptContext = {
      attempt_id,
      framework_code: attempt.framework_code,
      framework_name: attempt.framework_name,
      level_code: attempt.level_code,
      level_name: attempt.level_name,
      passing_score: attempt.passing_score,
      score_percentage: parseFloat(attempt.score_percentage) || 0,
      competency_scores: attempt.competency_scores || {},
      questions: questionDetails,
      previous_attempt: attempt.prev_score_percentage ? {
        score_percentage: parseFloat(attempt.prev_score_percentage),
        competency_scores: attempt.prev_competency_scores || {},
        completed_at: attempt.prev_completed_at
      } : undefined
    }

    // ========================================================================
    // GENERATE AI REPORT
    // ========================================================================
    let report: string
    let metadata: object
    let usedFallback = false

    try {
      const userPrompt = buildUserPrompt(context)
      const result = await callClaudeAPI(SYSTEM_PROMPT, userPrompt)
      report = result.report
      metadata = result.metadata

      // Validate for forbidden terms
      const validation = validateReport(report)
      if (!validation.valid) {
        console.warn('Forbidden terms found in report:', validation.violations)
        // Attempt regeneration with stricter prompt
        const stricterPrompt = userPrompt + '\n\nIMPORTANT: Use only professional coaching terminology. Avoid any mystical or new-age language.'
        const retryResult = await callClaudeAPI(SYSTEM_PROMPT, stricterPrompt)
        report = retryResult.report
        metadata = { ...retryResult.metadata, retry_reason: 'forbidden_terms', original_violations: validation.violations }
      }

    } catch (apiError) {
      console.error('Claude API error, using fallback:', apiError)
      report = generateBasicFallbackReport(context)
      metadata = {
        fallback: true,
        error: apiError.message,
        generated_at: new Date().toISOString()
      }
      usedFallback = true
    }

    // ========================================================================
    // STORE REPORT
    // ========================================================================
    const { error: updateError } = await supabaseClient
      .from('ai_assessment_attempts')
      .update({
        ai_report: report,
        ai_report_metadata: metadata
      })
      .eq('id', attempt_id)

    if (updateError) {
      console.error('Failed to store report:', updateError)
      // Continue anyway - return the report to user
    }

    return new Response(
      JSON.stringify({
        report,
        metadata,
        fallback: usedFallback
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200
      }
    )

  } catch (error) {
    console.error('Error generating AI report:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400
      }
    )
  }
})
