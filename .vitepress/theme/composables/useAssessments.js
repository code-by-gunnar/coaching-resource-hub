// Assessment System Composables
// Connects our revolutionary assessment UI to Supabase database

import { ref, computed } from 'vue'
import { useSupabase } from './useSupabase.js'

const { supabase } = useSupabase()

export function useAssessments() {
  // Reactive state
  const assessments = ref([])
  const loading = ref(false)
  const error = ref(null)

  // Get all assessments with question counts (active and inactive)
  const loadAssessments = async () => {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: fetchError } = await supabase
        .from('assessment_overview')
        .select('*')
        .order('framework')
        .order('sort_order')
      
      if (fetchError) throw fetchError
      
      assessments.value = data || []
    } catch (err) {
      console.error('Error loading assessments:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  // Get assessments by framework
  const getAssessmentsByFramework = (framework) => {
    return assessments.value.filter(assessment => 
      assessment.framework === framework
    )
  }

  // Get single assessment by slug
  const getAssessmentBySlug = async (slug) => {
    try {
      const { data, error: fetchError } = await supabase
        .from('assessments')
        .select('*')
        .eq('slug', slug)
        .eq('is_active', true)
        .single()
      
      if (fetchError) throw fetchError
      return data
    } catch (err) {
      console.error('Error loading assessment:', err)
      throw err
    }
  }

  // Get assessment questions in order
  const getAssessmentQuestions = async (assessmentId) => {
    try {
      const { data, error: fetchError } = await supabase
        .from('assessment_questions')
        .select('*')
        .eq('assessment_id', assessmentId)
        .order('question_order')
      
      if (fetchError) throw fetchError
      return data || []
    } catch (err) {
      console.error('Error loading questions:', err)
      throw err
    }
  }

  return {
    // State
    assessments,
    loading,
    error,
    
    // Methods
    loadAssessments,
    getAssessmentsByFramework,
    getAssessmentBySlug,
    getAssessmentQuestions
  }
}

export function useAssessmentAttempts() {
  // Reactive state
  const currentAttempt = ref(null)
  const loading = ref(false)
  const error = ref(null)

  // Start a new assessment attempt
  const startAttempt = async (userId, assessmentId, totalQuestions) => {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: insertError } = await supabase
        .from('user_assessment_attempts')
        .insert([{
          user_id: userId,
          assessment_id: assessmentId,
          total_questions: totalQuestions,
          status: 'started'
        }])
        .select()
        .single()
      
      if (insertError) throw insertError
      
      currentAttempt.value = data
      return data
    } catch (err) {
      console.error('Error starting attempt:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // Save a question response
  const saveResponse = async (attemptId, questionId, selectedAnswer, isCorrect, responseTime) => {
    try {
      const { error: insertError } = await supabase
        .from('user_question_responses')
        .insert([{
          attempt_id: attemptId,
          question_id: questionId,
          selected_answer: selectedAnswer,
          // 🔥 REMOVED is_correct - let check_answer_correctness_v4 trigger handle it!
          time_spent: responseTime
        }])
      
      if (insertError) throw insertError
    } catch (err) {
      console.error('Error saving response:', err)
      throw err
    }
  }

  // Complete assessment attempt
  const completeAttempt = async (attemptId, timeSpent) => {
    try {
      console.log('Completing attempt:', attemptId, 'time spent:', timeSpent)
      
      // Update the attempt as completed
      // Note: The score is calculated automatically by the trigger_auto_calculate_score trigger
      const { data, error: updateError } = await supabase
        .from('user_assessment_attempts')
        .update({
          status: 'completed',
          completed_at: new Date().toISOString(),
          time_spent: timeSpent
        })
        .eq('id', attemptId)
        .select()
        .single()
      
      if (updateError) {
        console.error('Update attempt error:', updateError)
        throw updateError
      }
      
      console.log('Attempt marked as completed:', data)
      
      // Fetch the updated record with the calculated score
      // (trigger runs AFTER the update, so we need to fetch again)
      const { data: finalData, error: fetchError } = await supabase
        .from('user_assessment_attempts')
        .select('*')
        .eq('id', attemptId)
        .single()
      
      if (fetchError) {
        console.error('Error fetching final data:', fetchError)
        throw fetchError
      }
      
      console.log('Final attempt data with score:', finalData)
      console.log('Score (calculated by trigger):', finalData.score)
      
      // Note: Enriched data will be captured later when user views results
      // This ensures we capture the EXACT frontend-generated insights
      console.log('🎯 Assessment completed - enriched data will be captured when results are viewed')
      let enrichedData = null
      
      currentAttempt.value = finalData
      return { ...finalData, enrichedData }
    } catch (err) {
      console.error('Error completing attempt:', err)
      throw err
    }
  }

  // Abandon an attempt (delete it if no questions were answered)
  const abandonAttempt = async (attemptId) => {
    try {
      console.log('Abandoning attempt:', attemptId)
      
      // Check if any questions were answered
      const { data: responses, error: checkError } = await supabase
        .from('user_question_responses')
        .select('id')
        .eq('attempt_id', attemptId)
        .limit(1)
      
      if (checkError) throw checkError
      
      // If no responses exist, delete the attempt entirely
      if (!responses || responses.length === 0) {
        const { error: deleteError } = await supabase
          .from('user_assessment_attempts')
          .delete()
          .eq('id', attemptId)
        
        if (deleteError) throw deleteError
        
        console.log('Empty attempt abandoned (deleted):', attemptId)
        return { action: 'deleted' }
      } else {
        // If responses exist, mark as abandoned but keep the data
        const { data, error: updateError } = await supabase
          .from('user_assessment_attempts')
          .update({
            status: 'abandoned',
            abandoned_at: new Date().toISOString()
          })
          .eq('id', attemptId)
          .select()
          .single()
        
        if (updateError) throw updateError
        
        console.log('Attempt marked as abandoned:', data)
        return { action: 'abandoned', data }
      }
    } catch (err) {
      console.error('Error abandoning attempt:', err)
      throw err
    }
  }

  // Get user's progress for an assessment
  const getUserProgress = async (userId, assessmentId) => {
    try {
      const { data, error: fetchError } = await supabase
        .from('user_assessment_progress')
        .select('*')
        .eq('user_id', userId)
        .eq('assessment_id', assessmentId)
        .eq('attempt_number', 1) // Get most recent attempt
        .single()
      
      if (fetchError && fetchError.code !== 'PGRST116') throw fetchError
      
      return data || null
    } catch (err) {
      console.error('Error getting user progress:', err)
      return null
    }
  }

  // Get all user attempts for dashboard
  const getUserAttempts = async (userId) => {
    try {
      const { data, error: fetchError } = await supabase
        .from('user_assessment_progress')
        .select('*')
        .eq('user_id', userId)
        .eq('attempt_number', 1) // Only most recent attempts
        .order('completed_at', { ascending: false })
      
      if (fetchError) throw fetchError
      return data || []
    } catch (err) {
      console.error('Error getting user attempts:', err)
      return []
    }
  }

  // Get user's best score for assessment
  const getUserBestScore = async (userId, assessmentId) => {
    try {
      const { data, error: rpcError } = await supabase
        .rpc('get_user_best_score', {
          user_uuid: userId,
          assessment_uuid: assessmentId
        })
      
      if (rpcError) throw rpcError
      return data || 0
    } catch (err) {
      console.error('Error getting best score:', err)
      return 0
    }
  }

  return {
    // State
    currentAttempt,
    loading,
    error,
    
    // Methods
    startAttempt,
    saveResponse,
    completeAttempt,
    abandonAttempt,
    getUserProgress,
    getUserAttempts,
    getUserBestScore
  }
}

export function useAssessmentResults() {
  // Get detailed results for a completed attempt
  const getAttemptResults = async (attemptId) => {
    try {
      // Get the attempt details
      const { data: attempt, error: attemptError } = await supabase
        .from('user_assessment_attempts')
        .select(`
          *,
          assessments!inner(
            title,
            framework_id,
            assessment_level_id,
            frameworks(code),
            assessment_levels(level_code)
          )
        `)
        .eq('id', attemptId)
        .single()
      
      if (attemptError) throw attemptError
      
      // Transform the nested data to maintain backward compatibility
      if (attempt && attempt.assessments) {
        attempt.assessments.framework = attempt.assessments.frameworks?.code || 'core'
        const levelCode = attempt.assessments.assessment_levels?.level_code || 'beginner'
        // Capitalize first letter to match AssessmentBadge expected format
        attempt.assessments.difficulty = levelCode.charAt(0).toUpperCase() + levelCode.slice(1)
      }
      
      // Get all responses with question details
      const { data: responses, error: responsesError } = await supabase
        .from('user_question_responses')
        .select(`
          *,
          assessment_questions!inner(
            question_order,
            scenario,
            question,
            option_a,
            option_b,
            option_c,
            option_d,
            correct_answer,
            explanation,
            competency_id,
            competency_display_names(display_name)
          )
        `)
        .eq('attempt_id', attemptId)
        .order('assessment_questions(question_order)')
      
      if (responsesError) throw responsesError
      
      // Transform responses to add competency_area for backward compatibility
      if (responses) {
        responses.forEach(response => {
          if (response.assessment_questions) {
            response.assessment_questions.competency_area = 
              response.assessment_questions.competency_display_names?.display_name || 'Unknown'
          }
        })
      }
      
      const result = {
        attempt,
        responses: responses || []
      }
      console.log('🔍 getAttemptResults returning:', result)
      console.log('🔍 attempt.score:', attempt?.score)
      return result
    } catch (err) {
      console.error('Error getting attempt results:', err)
      throw err
    }
  }

  // Get competency performance for user
  const getCompetencyPerformance = async (userId, framework = null) => {
    try {
      let query = supabase
        .from('user_competency_performance')
        .select('*')
        .eq('user_id', userId)
        .order('competency_score', { ascending: false })
      
      if (framework) {
        query = query.eq('framework', framework)
      }
      
      const { data, error: fetchError } = await query
      
      if (fetchError) throw fetchError
      return data || []
    } catch (err) {
      console.error('Error getting competency performance:', err)
      return []
    }
  }

  return {
    getAttemptResults,
    getCompetencyPerformance
  }
}