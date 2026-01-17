// AI Assessment System Composables
// Connects to the new ai_* tables for AI-generated assessment reports
// Design Doc: .plans/2026-01-16-ai-generated-assessment-reports-design.md

import { ref, computed } from 'vue'
import { useSupabase } from './useSupabase.js'

const { supabase } = useSupabase()

// ============================================================================
// ASSESSMENT LISTING & QUESTIONS
// ============================================================================
export function useAiAssessments() {
  const assessments = ref([])
  const loading = ref(false)
  const error = ref(null)

  // Get all available AI assessments
  const loadAssessments = async () => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('ai_assessment_levels')
        .select(`
          *,
          framework:ai_frameworks(*)
        `)
        .eq('is_active', true)
        .order('framework_id')
        .order('level_code')

      if (fetchError) throw fetchError

      // Map level_code to difficulty display name
      const difficultyMap = {
        'beginner': 'Beginner',
        'intermediate': 'Intermediate',
        'advanced': 'Advanced'
      }

      // Transform to match expected format
      assessments.value = (data || []).map(level => ({
        id: level.id,
        title: level.name,
        slug: `${level.framework.code}-${level.level_code}`,
        framework: level.framework.code,
        framework_name: level.framework.name,
        difficulty: difficultyMap[level.level_code] || 'Beginner',
        level_code: level.level_code,
        passing_score: level.passing_score,
        questions_per_attempt: level.question_count || 15,
        description: level.framework.description,
        is_active: level.is_active
      }))
    } catch (err) {
      console.error('Error loading AI assessments:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  // Get single assessment by slug (format: "core-beginner")
  const getAssessmentBySlug = async (slug) => {
    try {
      const [frameworkCode, levelCode] = slug.split('-')

      // First, look up the framework by code
      const { data: framework, error: frameworkError } = await supabase
        .from('ai_frameworks')
        .select('id')
        .eq('code', frameworkCode)
        .single()

      if (frameworkError || !framework) {
        throw new Error(`Framework '${frameworkCode}' not found`)
      }

      // Then get the level with that framework
      const { data, error: fetchError } = await supabase
        .from('ai_assessment_levels')
        .select(`
          *,
          framework:ai_frameworks(*)
        `)
        .eq('framework_id', framework.id)
        .eq('level_code', levelCode)
        .single()

      if (fetchError) throw fetchError

      return {
        id: data.id,
        title: `${data.framework.name} - ${data.name}`,
        slug: slug,
        framework: data.framework.code,
        framework_id: data.framework.id,
        framework_name: data.framework.name,
        difficulty: data.name,
        level_code: data.level_code,
        level_id: data.id,
        passing_score: data.passing_score,
        questions_per_attempt: data.question_count || 15,
        description: data.framework.description
      }
    } catch (err) {
      console.error('Error loading AI assessment:', err)
      throw err
    }
  }

  // Get questions for an assessment (with concept-based rotation)
  const getAssessmentQuestions = async (levelId, questionsPerAttempt = 15) => {
    try {
      // Get all questions for this level
      const { data: allQuestions, error: fetchError } = await supabase
        .from('ai_questions')
        .select(`
          *,
          competency:ai_competencies(id, name, code)
        `)
        .eq('level_id', levelId)
        .eq('is_active', true)

      if (fetchError) throw fetchError

      // Group questions by concept_tag for rotation
      const questionsByTag = {}
      allQuestions.forEach(q => {
        if (!questionsByTag[q.concept_tag]) {
          questionsByTag[q.concept_tag] = []
        }
        questionsByTag[q.concept_tag].push(q)
      })

      // Select one question per concept_tag randomly
      const selectedQuestions = []
      const tags = Object.keys(questionsByTag)

      for (const tag of tags) {
        const tagQuestions = questionsByTag[tag]
        const randomIndex = Math.floor(Math.random() * tagQuestions.length)
        selectedQuestions.push(tagQuestions[randomIndex])
      }

      // If we need more questions, add randomly from remaining pool
      if (selectedQuestions.length < questionsPerAttempt) {
        const selectedIds = new Set(selectedQuestions.map(q => q.id))
        const remainingQuestions = allQuestions.filter(q => !selectedIds.has(q.id))

        while (selectedQuestions.length < questionsPerAttempt && remainingQuestions.length > 0) {
          const randomIndex = Math.floor(Math.random() * remainingQuestions.length)
          selectedQuestions.push(remainingQuestions.splice(randomIndex, 1)[0])
        }
      }

      // Limit to requested count and shuffle
      const finalQuestions = selectedQuestions.slice(0, questionsPerAttempt)
      for (let i = finalQuestions.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [finalQuestions[i], finalQuestions[j]] = [finalQuestions[j], finalQuestions[i]]
      }

      // Transform to match expected format
      return finalQuestions.map((q, index) => ({
        id: q.id,
        question_order: index + 1,
        scenario: q.scenario_text,
        question: q.question_text,
        option_a: q.options[0]?.text || '',
        option_b: q.options[1]?.text || '',
        option_c: q.options[2]?.text || '',
        option_d: q.options[3]?.text || '',
        correct_answer: q.options.findIndex(o => o.key === q.correct_option) + 1,
        correct_option: q.correct_option,
        explanation: q.explanation,
        competency_id: q.competency.id,
        competency_area: q.competency.name,
        concept_tag: q.concept_tag
      }))
    } catch (err) {
      console.error('Error loading AI assessment questions:', err)
      throw err
    }
  }

  // Get questions by their IDs in a specific order (for resume functionality)
  const getQuestionsByIds = async (questionIds) => {
    try {
      const { data: questions, error: fetchError } = await supabase
        .from('ai_questions')
        .select(`
          *,
          competency:ai_competencies(id, name, code)
        `)
        .in('id', questionIds)

      if (fetchError) throw fetchError

      // Create a map for quick lookup
      const questionsMap = new Map(questions.map(q => [q.id, q]))

      // Return questions in the order of questionIds (preserving saved order)
      const orderedQuestions = questionIds
        .map(id => questionsMap.get(id))
        .filter(q => q !== undefined)

      // Transform to match expected format
      return orderedQuestions.map((q, index) => ({
        id: q.id,
        question_order: index + 1,
        scenario: q.scenario_text,
        question: q.question_text,
        option_a: q.options[0]?.text || '',
        option_b: q.options[1]?.text || '',
        option_c: q.options[2]?.text || '',
        option_d: q.options[3]?.text || '',
        correct_answer: q.options.findIndex(o => o.key === q.correct_option) + 1,
        correct_option: q.correct_option,
        explanation: q.explanation,
        competency_id: q.competency.id,
        competency_area: q.competency.name,
        concept_tag: q.concept_tag
      }))
    } catch (err) {
      console.error('Error loading questions by IDs:', err)
      throw err
    }
  }

  return {
    assessments,
    loading,
    error,
    loadAssessments,
    getAssessmentBySlug,
    getAssessmentQuestions,
    getQuestionsByIds
  }
}

// ============================================================================
// ASSESSMENT ATTEMPTS
// ============================================================================
export function useAiAssessmentAttempts() {
  const currentAttempt = ref(null)
  const loading = ref(false)
  const error = ref(null)

  // Start a new AI assessment attempt
  const startAttempt = async (userId, frameworkId, levelId, questionIds) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: insertError } = await supabase
        .from('ai_assessment_attempts')
        .insert([{
          user_id: userId,
          framework_id: frameworkId,
          level_id: levelId,
          questions_served: questionIds,
          answers: {}
        }])
        .select()
        .single()

      if (insertError) throw insertError

      currentAttempt.value = data
      return data
    } catch (err) {
      console.error('Error starting AI attempt:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Save a question response (updates the JSONB answers field)
  const saveResponse = async (attemptId, questionId, selectedOption) => {
    try {
      // First get current answers
      const { data: attempt, error: fetchError } = await supabase
        .from('ai_assessment_attempts')
        .select('answers')
        .eq('id', attemptId)
        .single()

      if (fetchError) throw fetchError

      // Update answers object
      const updatedAnswers = { ...(attempt.answers || {}), [questionId]: selectedOption }

      const { error: updateError } = await supabase
        .from('ai_assessment_attempts')
        .update({
          answers: updatedAnswers
        })
        .eq('id', attemptId)

      if (updateError) throw updateError

    } catch (err) {
      console.error('Error saving AI response:', err)
      throw err
    }
  }

  // Complete the assessment attempt
  const completeAttempt = async (attemptId) => {
    try {
      console.log('Completing AI attempt:', attemptId)

      // Set completed_at timestamp
      const { data, error: updateError } = await supabase
        .from('ai_assessment_attempts')
        .update({
          completed_at: new Date().toISOString()
        })
        .eq('id', attemptId)
        .select()
        .single()

      if (updateError) throw updateError

      // Call the function to calculate scores
      const { error: calcError } = await supabase
        .rpc('ai_calculate_competency_scores', { p_attempt_id: attemptId })

      if (calcError) {
        console.warn('Score calculation warning:', calcError)
        // Continue anyway - scores might already be set
      }

      // Fetch final data with calculated scores
      const { data: finalData, error: fetchError } = await supabase
        .from('ai_assessment_attempts')
        .select('*')
        .eq('id', attemptId)
        .single()

      if (fetchError) throw fetchError

      console.log('AI Assessment completed with score:', finalData.score_percentage)

      currentAttempt.value = finalData
      return finalData
    } catch (err) {
      console.error('Error completing AI attempt:', err)
      throw err
    }
  }

  // Abandon an attempt (delete incomplete attempts)
  const abandonAttempt = async (attemptId) => {
    try {
      // Delete incomplete attempt - no status column, so we just remove it
      const { error: deleteError } = await supabase
        .from('ai_assessment_attempts')
        .delete()
        .eq('id', attemptId)
        .is('completed_at', null)  // Only delete if not completed

      if (deleteError) throw deleteError
      return { action: 'deleted' }
    } catch (err) {
      console.error('Error abandoning AI attempt:', err)
      throw err
    }
  }

  // Get user's in-progress attempt for an assessment level
  const getInProgressAttempt = async (userId, levelId) => {
    try {
      const { data, error: fetchError } = await supabase
        .from('ai_assessment_attempts')
        .select('*')
        .eq('user_id', userId)
        .eq('level_id', levelId)
        .is('completed_at', null)  // In-progress = not completed
        .order('started_at', { ascending: false })
        .limit(1)
        .maybeSingle()

      if (fetchError) throw fetchError
      return data
    } catch (err) {
      console.error('Error getting in-progress attempt:', err)
      return null
    }
  }

  // Get user's attempts for dashboard
  const getUserAttempts = async (userId) => {
    try {
      const { data, error: fetchError } = await supabase
        .from('ai_assessment_attempts')
        .select(`
          *,
          level:ai_assessment_levels(
            *,
            framework:ai_frameworks(*)
          )
        `)
        .eq('user_id', userId)
        .not('completed_at', 'is', null)  // Only completed attempts
        .order('completed_at', { ascending: false })

      if (fetchError) throw fetchError
      return data || []
    } catch (err) {
      console.error('Error getting user attempts:', err)
      return []
    }
  }

  return {
    currentAttempt,
    loading,
    error,
    startAttempt,
    saveResponse,
    completeAttempt,
    abandonAttempt,
    getInProgressAttempt,
    getUserAttempts
  }
}

// ============================================================================
// ASSESSMENT RESULTS & AI REPORTS
// ============================================================================
export function useAiAssessmentResults() {
  const aiReport = ref(null)
  const aiReportLoading = ref(false)
  const aiReportError = ref(null)

  // Get attempt results with question details
  const getAttemptResults = async (attemptId) => {
    try {
      // Get attempt with level info
      const { data: attempt, error: attemptError } = await supabase
        .from('ai_assessment_attempts')
        .select(`
          *,
          level:ai_assessment_levels(
            *,
            framework:ai_frameworks(*)
          )
        `)
        .eq('id', attemptId)
        .single()

      if (attemptError) throw attemptError

      // Ensure questions_served is an array
      const questionsServed = Array.isArray(attempt.questions_served)
        ? attempt.questions_served
        : []

      // Get question details for the questions that were served
      const { data: questions, error: questionsError } = await supabase
        .from('ai_questions')
        .select(`
          *,
          competency:ai_competencies(id, name, code)
        `)
        .in('id', questionsServed)

      if (questionsError) throw questionsError

      // Build responses from answers JSONB
      const responses = []
      const questionsMap = new Map((questions || []).map(q => [q.id, q]))
      let correctCount = 0
      const answers = attempt.answers || {}

      for (const questionId of questionsServed) {
        const question = questionsMap.get(questionId)
        if (question) {
          const userAnswer = answers[questionId]
          const isCorrect = userAnswer === question.correct_option
          if (isCorrect) correctCount++

          responses.push({
            question_id: questionId,
            selected_answer: userAnswer,
            is_correct: isCorrect,
            question: {
              question_order: questionsServed.indexOf(questionId) + 1,
              scenario: question.scenario_text,
              question: question.question_text,
              option_a: question.options[0]?.text || '',
              option_b: question.options[1]?.text || '',
              option_c: question.options[2]?.text || '',
              option_d: question.options[3]?.text || '',
              correct_answer: question.options.findIndex(o => o.key === question.correct_option) + 1,
              explanation: question.explanation,
              competency_area: question.competency?.name || 'Unknown'
            }
          })
        }
      }

      // Calculate time spent in seconds
      let timeSpentSeconds = 0
      if (attempt.started_at && attempt.completed_at) {
        const startTime = new Date(attempt.started_at).getTime()
        const endTime = new Date(attempt.completed_at).getTime()
        timeSpentSeconds = Math.round((endTime - startTime) / 1000)
      }

      // Format time for display (e.g., "0m 50s")
      const formatTimeSpent = (seconds) => {
        if (!seconds) return '0m 0s'
        const mins = Math.floor(seconds / 60)
        const secs = seconds % 60
        return `${mins}m ${secs}s`
      }

      // Transform attempt to expected format - put calculated values LAST to ensure they override
      // Include both old field names (for AssessmentResults.vue) and new field names (for AiAssessmentResults.vue)
      const transformedAttempt = {
        ...attempt,
        questions_served: questionsServed, // Ensure it's always an array
        score: attempt.score_percentage ?? 0,
        // New field names (for AiAssessmentResults.vue)
        correct_count: correctCount,
        time_spent_seconds: timeSpentSeconds,
        // Old field names (for backward compatibility with AssessmentResults.vue)
        correct_answers: correctCount,
        total_questions: questionsServed.length,
        time_spent: formatTimeSpent(timeSpentSeconds),
        assessments: {
          title: `${attempt.level.framework.name} - ${attempt.level.name}`,
          framework: attempt.level.framework.code,
          difficulty: attempt.level.level_code  // Use level_code ('beginner') not name
        }
      }

      return {
        attempt: transformedAttempt,
        responses,
        competencyScores: attempt.competency_scores || {}
      }
    } catch (err) {
      console.error('Error getting AI attempt results:', err)
      throw err
    }
  }

  // Generate AI report for an attempt
  const generateAiReport = async (attemptId) => {
    aiReportLoading.value = true
    aiReportError.value = null

    try {
      console.log('Generating AI report for attempt:', attemptId)

      const response = await fetch(
        `${import.meta.env.VITE_SUPABASE_URL || 'https://hfmpacbmbyvnupzgorek.supabase.co'}/functions/v1/generate-ai-report`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmbXBhY2JtYnl2bnVwemdvcmVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQyMjQzMzMsImV4cCI6MjA2OTgwMDMzM30.vt_TdE1Fj0b4bI6pz_4SfqzXrU1AX14xSwJpH3LiO3Y'}`
          },
          body: JSON.stringify({ attempt_id: attemptId })
        }
      )

      if (!response.ok) {
        const errorData = await response.json()
        throw new Error(errorData.error || 'Failed to generate AI report')
      }

      const data = await response.json()

      aiReport.value = {
        content: data.report,
        metadata: data.metadata,
        cached: data.cached || false,
        fallback: data.fallback || false
      }

      console.log('AI report generated:', data.cached ? 'from cache' : 'new generation')

      return aiReport.value
    } catch (err) {
      console.error('Error generating AI report:', err)
      aiReportError.value = err.message
      throw err
    } finally {
      aiReportLoading.value = false
    }
  }

  // Get cached AI report if it exists
  const getCachedReport = async (attemptId) => {
    try {
      const { data, error: fetchError } = await supabase
        .from('ai_assessment_attempts')
        .select('ai_report, ai_report_metadata')
        .eq('id', attemptId)
        .single()

      if (fetchError) throw fetchError

      if (data.ai_report) {
        aiReport.value = {
          content: data.ai_report,
          metadata: data.ai_report_metadata,
          cached: true
        }
        return aiReport.value
      }

      return null
    } catch (err) {
      console.error('Error getting cached report:', err)
      return null
    }
  }

  // Clear the AI report (used when switching between attempts)
  const clearAiReport = () => {
    aiReport.value = null
    aiReportError.value = null
  }

  return {
    aiReport,
    aiReportLoading,
    aiReportError,
    getAttemptResults,
    generateAiReport,
    getCachedReport,
    clearAiReport
  }
}
