/**
 * Personalized Assessment Insights Composable
 * Orchestrates the generation of personalized insights using framework-specific composables
 * Generates specific, personalized insights based on actual assessment performance
 */
import { useAssessmentInsightsFactory } from './assessments/useAssessmentInsightsFactory.js'
import { useSupabase } from './useSupabase.js'

export function usePersonalizedInsights() {
  const { supabase } = useSupabase()
  
  const { getInsightsComposable } = useAssessmentInsightsFactory()
  
  /**
   * Generate personalized competency analysis based on actual responses
   * Now uses framework-specific insights composables for scalable assessment support
   */
  const generatePersonalizedCompetencyAnalysis = async (competencyStats, responses, assessmentFramework, assessmentDifficulty, skillTagsFunction, tagInsightsFunction, tagActionsFunction) => {
    if (!responses?.length || !competencyStats?.length) return []

    // Get the appropriate framework-specific insights composable
    const frameworkInsights = await getInsightsComposable(assessmentFramework, assessmentDifficulty)

    // Group responses by competency area for detailed analysis
    const responsesByCompetency = {}
    responses.forEach(response => {
      const area = response.assessment_questions?.competency_area
      if (!area) return
      
      if (!responsesByCompetency[area]) {
        responsesByCompetency[area] = {
          correct: [],
          incorrect: []
        }
      }
      
      if (response.is_correct) {
        responsesByCompetency[area].correct.push(response)
      } else {
        responsesByCompetency[area].incorrect.push(response)
      }
    })

    // Generate personalized analysis for each competency using framework-specific logic
    const competencyAnalyses = await Promise.all(competencyStats.map(async comp => {
      const competencyResponses = responsesByCompetency[comp.area] || { correct: [], incorrect: [] }
      const incorrectQuestions = competencyResponses.incorrect
      const totalQuestions = competencyResponses.correct.length + competencyResponses.incorrect.length
      
      // Get skill tags for this competency
      const skillTags = skillTagsFunction ? skillTagsFunction(comp.area) : []
      console.log('🏷️ Getting skill tags for', comp.area, ':', skillTags)
      
      return {
        ...comp,
        displayName: frameworkInsights.getCompetencyDisplayName ? 
          await frameworkInsights.getCompetencyDisplayName(comp.area) : 
          await getCompetencyDisplayName(comp.area, assessmentFramework),
        description: await getCompetencyDescription(comp.area, assessmentFramework),
        skillName: getCompetencySkillName(comp.area, assessmentFramework),
        
        // Personalized performance insights
        personalizedInsights: await generatePerformanceInsights(comp, totalQuestions, incorrectQuestions, assessmentFramework, assessmentDifficulty),
        
        // Use framework-specific actions based on actual performance
        personalizedActions: comp.percentage >= 70 
          ? await frameworkInsights.generateStrengthLeverageActions(comp.area, comp.percentage)
          : await frameworkInsights.generateStrategicActions(comp.area, comp.percentage, incorrectQuestions.length, totalQuestions),
        
        // Skill tag analysis
        skillTagAnalysis: generateSkillTagAnalysis(comp, skillTags, tagInsightsFunction, tagActionsFunction),
        
        // Question-level analysis with detailed review
        questionAnalysis: generateDetailedQuestionAnalysis(competencyResponses.incorrect, comp.area),
        
        // Performance context
        performanceContext: generatePerformanceContext(comp, competencyStats),
        
        // Framework metadata
        framework: assessmentFramework,
        difficulty: assessmentDifficulty,
        version: frameworkInsights.version || 'unknown'
      }
    }))

    return competencyAnalyses
  }

  /**
   * Generate unique performance insights focused on coaching development patterns
   */
  const generatePerformanceInsights = async (competency, totalQuestions, incorrectQuestions, assessmentFramework, assessmentDifficulty) => {
    const insights = []
    const percentage = competency.percentage
    const area = competency.area
    const incorrect = incorrectQuestions.length

    // Generate unique insights based on competency area and performance patterns
    const competencyInsights = await getCompetencySpecificInsights(area, percentage, incorrect, totalQuestions, assessmentFramework, assessmentDifficulty)
    insights.push(...competencyInsights)

    // ONLY use database insights - no additional hardcoded patterns
    // This ensures clean, contextual messaging without duplication
    
    return insights
  }

  /**
   * Get competency-specific insights that relate to real coaching challenges
   * Queries competency_performance_analysis table based on competency area and score range
   */
  const getCompetencySpecificInsights = async (area, percentage, incorrect, totalQuestions, assessmentFramework, assessmentDifficulty) => {
    try {
      // Clean the area name
      const cleanArea = area?.trim()
      
      if (!cleanArea) {
        console.warn('No competency area provided to getCompetencySpecificInsights')
        return [`No performance insights available`]
      }

      // Use the singleton Supabase client

      // Determine analysis type based on 3-tier system
      const analysisType = percentage >= 70 ? 'strength' : percentage >= 50 ? 'developing' : 'weakness'

      // Convert difficulty to level_code (Beginner -> beginner, Intermediate -> intermediate)
      const levelCode = assessmentDifficulty?.toLowerCase() || 'beginner'

      // First get the IDs we need for filtering
      const { data: frameworkData, error: frameworkError } = await supabase
        .from('frameworks')
        .select('id')
        .eq('code', assessmentFramework?.toLowerCase() || 'core')
        .single()

      if (frameworkError) {
        console.error('Error fetching framework for analysis:', frameworkError)
        return [`Error loading performance insights for ${cleanArea}`]
      }

      const { data: analysisTypeData, error: analysisTypeError } = await supabase
        .from('analysis_types')
        .select('id')
        .eq('code', analysisType)
        .single()

      if (analysisTypeError) {
        console.error('Error fetching analysis type:', analysisTypeError)
        return [`Error loading performance insights for ${cleanArea}`]
      }

      const { data: assessmentLevelData, error: levelError } = await supabase
        .from('assessment_levels')
        .select('id')
        .eq('level_code', levelCode)
        .eq('framework_id', frameworkData.id)
        .single()

      if (levelError) {
        console.error('Error fetching assessment level for analysis:', levelError)
        return [`Error loading performance insights for ${cleanArea}`]
      }

      // Find competency ID by display name
      const { data: competencyData, error: competencyError } = await supabase
        .from('competency_display_names')
        .select('id')
        .eq('display_name', cleanArea)
        .eq('framework_id', frameworkData.id)
        .maybeSingle()

      if (competencyError) {
        console.error('Error fetching competency for analysis:', competencyError)
      }

      if (!competencyData) {
        console.warn(`Missing reference data for competency analysis: ${cleanArea}`, {
          frameworkFound: !!frameworkData,
          analysisTypeFound: !!analysisTypeData,
          assessmentLevelFound: !!assessmentLevelData,
          competencyFound: false,
          competencyArea: cleanArea,
          frameworkId: frameworkData.id
        })
        return [`No performance insights found for ${cleanArea} at ${percentage}% performance level`]
      }

      // Query performance analysis using new scoring tier system
      console.log('🔍 Querying performance analysis:', {
        competencyArea: cleanArea,
        percentage,
        analysisType,
        framework: assessmentFramework?.toLowerCase() || 'core',
        assessmentLevel: levelCode
      })
      
      const { data: analyses, error } = await supabase
        .from('performance_analysis_with_analysis_type')
        .select('analysis_text')
        .eq('competency_name', cleanArea)
        .eq('analysis_type_code', analysisType)
        .eq('framework_code', assessmentFramework?.toLowerCase() || 'core')
        .eq('assessment_level', levelCode)
        .lte('score_min', percentage)
        .gte('score_max', percentage)
        .eq('is_active', true)
        .order('tier_display_order')
        .limit(1)

      if (error) {
        console.error('Error querying competency performance analysis:', error)
        return [`Error loading performance insights for ${area}`]
      }

      if (!analyses || analyses.length === 0) {
        return [`No performance insights found for ${area} at ${percentage}% performance level`]
      }

      // Return only the first (best) analysis to avoid repetitive messaging
      return [analyses[0].analysis_text]
    } catch (error) {
      console.error('Error in getCompetencySpecificInsights:', error)
      return [`Database error loading performance insights for ${area}`]
    }
  }

  /**
   * Identify competency-specific developmental patterns based on performance
   */
  const getDevelopmentalPattern = (area, percentage, incorrectCount) => {
    // Generate competency-specific insights based on error patterns
    if (incorrectCount === 0) {
      return getZeroErrorInsight(area)
    } else if (incorrectCount === 1) {
      return getSingleErrorInsight(area)
    } else if (incorrectCount >= 2) {
      return getMultipleErrorInsight(area)
    }
    return null
  }

  /**
   * Get competency-specific insights for perfect performance
   */
  const getZeroErrorInsight = (area) => {
    // Generate appropriate insights for perfect performance based on competency area
    if (area.includes('Language Awareness')) {
      return `Your perfect performance demonstrates mastery in language pattern recognition and precision questioning skills`
    } else if (area.includes('Strength Area')) {
      return `Outstanding performance in this core competency demonstrates exceptional coaching mastery`
    } else {
      return `Perfect performance in ${area} shows strong competency mastery and coaching readiness`
    }
  }

  /**
   * Get competency-specific insights for single error pattern
   */
  const getSingleErrorInsight = (area) => {
    // Generate appropriate insights for single error patterns based on competency area
    if (area.includes('Language Awareness')) {
      return `Nearly perfect performance with one small gap - review language pattern recognition to achieve full mastery`
    } else if (area.includes('Strength Area')) {
      return `Excellent performance overall - focus on the specific concept you missed to reach complete competency`
    } else {
      return `Strong performance in ${area} with minor refinement needed in one specific area`
    }
  }

  /**
   * Get competency-specific insights for multiple error pattern
   */
  const getMultipleErrorInsight = (area) => {
    // Generate appropriate insights for multiple error patterns based on competency area
    if (area.includes('Language Awareness')) {
      return `Multiple gaps in language pattern recognition indicate this competency requires intensive development focus`
    } else if (area.includes('Strength Area')) {
      return `This competency requires intensive development focus to build essential coaching capabilities`
    } else {
      return `Multiple gaps in ${area} indicate this competency needs focused development and practice`
    }
  }

  /**
   * Generate insights about practical coaching application (unique content)
   */
  const getCoachingApplicationInsight = (area, percentage) => {
    // Generate appropriate coaching application insights based on competency area and performance
    if (area.includes('Language Awareness')) {
      if (percentage >= 70) {
        return `Your language awareness skills enable you to help clients identify limiting beliefs and breakthrough linguistic patterns that hold them back`
      } else {
        return `Developing language awareness skills will help you recognize when clients are using limiting language patterns and guide them toward more empowering communication`
      }
    } else if (area.includes('Strength Area')) {
      if (percentage >= 70) {
        return `This competency strength enables you to create powerful client transformations and serves as a foundation for your coaching practice`
      } else {
        return `Building this core competency will significantly enhance your ability to support client growth and transformation`
      }
    } else {
      if (percentage >= 70) {
        return `Your ${area} skills enable effective client support and contribute to meaningful coaching outcomes`
      } else {
        return `Developing ${area} will enhance your coaching effectiveness and client impact`
      }
    }
  }

  /**
   * Generate skill tag analysis combining performance with specific tag insights
   */
  const generateSkillTagAnalysis = (competency, skillTags, tagInsightsFunction, tagActionsFunction) => {
    console.log('📊 generateSkillTagAnalysis called:', {
      competency: competency.area,
      skillTagsLength: skillTags?.length || 0,
      skillTags: skillTags,
      hasInsightsFn: !!tagInsightsFunction,
      hasActionsFn: !!tagActionsFunction
    })
    
    if (!skillTags?.length || !tagInsightsFunction || !tagActionsFunction) {
      console.warn('⚠️ Skill tag analysis skipped - missing data')
      return []
    }
    
    // Determine how many tags to show based on performance
    const percentage = competency.percentage
    const maxTags = percentage < 50 ? 3 : percentage < 70 ? 4 : 2
    
    return skillTags
      .map(tag => {
        // Determine insight type based on competency performance
        const insightType = competency.percentage >= 70 ? 'strength' : 'weakness'
        const insight = tagInsightsFunction(tag, insightType)
        const action = tagActionsFunction(tag)
        
        // Personalize the tag insight based on performance
        const personalizedInsight = personalizeTagInsight(competency, tag, insight)
        const personalizedAction = personalizeTagAction(competency, tag, action)
        
        return {
          tag,
          insight: personalizedInsight,
          action: personalizedAction,
          priority: getTagPriority(competency, tag)
        }
      })
      .sort((a, b) => b.priority - a.priority) // Sort by priority
      .slice(0, maxTags) // Limit to top priority tags
  }

  /**
   * Personalize tag insights based on actual performance
   */
  const personalizeTagInsight = (competency, tag, genericInsight) => {
    const percentage = competency.percentage
    const performance = percentage < 50 ? 'critical' : percentage < 70 ? 'developing' : 'strong'
    
    if (performance === 'critical') {
      return `${genericInsight.replace('You may be', 'You are likely')}`
    } else if (performance === 'developing') {
      return `${genericInsight}`
    } else {
      return `${genericInsight.replace('Missing opportunities', 'Minor opportunities')}`
    }
  }

  /**
   * Personalize tag actions based on performance level
   */
  const personalizeTagAction = (competency, tag, genericAction) => {
    const percentage = competency.percentage
    
    if (percentage < 50) {
      return `${genericAction} (Practice daily)`
    } else if (percentage < 70) {
      return `${genericAction} (Practice 2-3x per week)`
    } else {
      return `${genericAction} (Practice occasionally for mastery)`
    }
  }

  /**
   * Calculate tag priority based on competency performance
   */
  const getTagPriority = (competency, tag) => {
    const baseScore = 100 - competency.percentage // Lower percentage = higher priority
    
    // Boost priority for fundamental skills
    const fundamentalTags = ['Level II/III Listening', 'Meta Model', 'Clean Language', 'GROW Model', 'Values Clarification']
    const boost = fundamentalTags.includes(tag) ? 20 : 0
    
    return baseScore + boost
  }

  /**
   * Generate enhanced actions - now returns only high-level strategic actions
   * Tag-specific actions are shown in the skill breakdown to avoid duplication
   */
  const generateEnhancedActions = (competency, incorrectQuestions, skillTags, framework, tagInsightsFunction, tagActionsFunction) => {
    const actions = []
    const percentage = competency.percentage
    
    // Only include high-level strategic actions based on performance
    if (incorrectQuestions.length === 0) {
      actions.push(`Continue applying your ${competency.area} skills - consider mentoring others in this strength area.`)
      return actions
    }
    
    // Performance-based strategic guidance (not tag-specific)
    if (percentage < 50) {
      actions.push(`Schedule dedicated daily practice time for ${competency.area} skills`)
      actions.push('Work with a mentor who excels in this competency area')
    } else if (percentage < 70) {
      actions.push(`Set weekly practice goals for ${competency.area} improvement`)
      actions.push('Focus on the top 2-3 skill areas shown below')
    } else {
      actions.push('Review the specific concepts you missed to achieve mastery')
    }
    
    
    return actions
  }

  // Note: Strategic actions are now handled by framework-specific composables
  // This provides better scalability across different frameworks and difficulty levels

  /**
   * Generate meaningful performance context - what this performance means for their coaching practice
   */
  const generatePerformanceContext = (competency, allCompetencies) => {
    const percentage = competency.percentage
    const area = competency.area
    const correct = competency.correct
    const total = competency.total
    
    // Determine their coaching readiness level in this area
    let readinessLevel, impactOnCoaching, developmentFocus
    
    if (percentage >= 90) {
      readinessLevel = "coaching-ready"
      impactOnCoaching = `You demonstrate strong mastery in ${area}. This competency can be a cornerstone of your coaching practice.`
      developmentFocus = "Leverage this strength to support clients and mentor other coaches in this area."
    } else if (percentage >= 70) {
      readinessLevel = "developing-confidence" 
      impactOnCoaching = `You show solid understanding of ${area} with room for refinement. You can coach clients effectively in this area while continuing to develop your skills.`
      developmentFocus = "Focus on advanced techniques and challenging client scenarios to reach mastery."
    } else if (percentage >= 50) {
      readinessLevel = "needs-development"
      impactOnCoaching = `${area} requires focused development before working with clients in situations that heavily depend on this competency.`
      developmentFocus = "Prioritize structured learning, practice, and supervision in this area."
    } else {
      readinessLevel = "foundational-gaps"
      impactOnCoaching = `Critical gaps in ${area} could significantly limit your coaching effectiveness. This needs immediate attention.`
      developmentFocus = "Begin with foundational training and extensive supervised practice before client work."
    }
    
    // Add specific coaching implications
    const coachingImplications = getCoachingImplications(area, percentage, correct, total)
    
    return {
      readinessLevel,
      impactOnCoaching,
      developmentFocus,
      coachingImplications,
      performanceIndicators: {
        percentage,
        correct,
        total,
        masteryLevel: percentage >= 90 ? "Advanced" : percentage >= 70 ? "Proficient" : percentage >= 50 ? "Developing" : "Beginner"
      }
    }
  }

  /**
   * Get specific implications for coaching practice based on competency performance
   */
  const getCoachingImplications = (area, percentage, correct, total) => {
    const implications = {
      'Present Moment Awareness': percentage >= 70 
        ? "You can help clients stay present and aware during sessions, creating deeper insights."
        : "You may miss important client cues, energy shifts, and breakthrough moments during sessions.",
      
      'Language Awareness': percentage >= 70
        ? "You can skillfully use language patterns to create awareness and facilitate client breakthroughs."
        : "You may miss linguistic clues about client beliefs and could inadvertently reinforce limiting patterns.",
      
      'Meaning Exploration': percentage >= 70
        ? "You can guide clients to connect their goals with deeper values and life purpose."
        : "Your clients may achieve surface-level goals but miss the deeper fulfillment that comes from values-aligned living.",
        
      'Active Listening': percentage >= 70
        ? "You create safe space for clients to explore difficult topics and feel truly heard."
        : "Clients may not feel fully understood, limiting their willingness to go deeper in sessions.",
        
      'Powerful Questions': percentage >= 70
        ? "Your questions help clients discover insights and solutions they didn't know they had."
        : "You may rely too heavily on advice-giving rather than helping clients develop their own wisdom.",
        
      'Creating Awareness': percentage >= 70
        ? "You can help clients see blind spots and patterns that keep them stuck."
        : "Clients may continue repeating unproductive patterns without gaining insight into their causes."
    }

    return implications[area] || `This competency affects how effectively you can support clients in ${area.toLowerCase()}.`
  }

  /**
   * Generate detailed question analysis with coaching scenarios and learning points
   */
  const generateDetailedQuestionAnalysis = (incorrectQuestions, competencyArea) => {
    if (!incorrectQuestions?.length) {
      return {
        hasIncorrectQuestions: false,
        summary: "Perfect performance - no questions answered incorrectly in this competency.",
        learningFocus: "Continue to refine and deepen your mastery through advanced practice."
      }
    }

    const analysis = incorrectQuestions.map((response, index) => {
      const question = response.assessment_questions
      if (!question) return null

      // Extract the coaching scenario context
      const scenario = question.scenario || ''
      const questionText = question.question || 'Question not available'
      const explanation = question.explanation || 'Explanation not available'
      
      // Generate coaching-focused learning point
      const coachingLearningPoint = generateCoachingLearningPoint(
        scenario, 
        questionText, 
        explanation, 
        competencyArea,
        response.selected_answer,
        question.correct_answer
      )

      return {
        scenarioContext: scenario,
        questionFocus: questionText,
        explanationOfCorrectApproach: explanation,
        yourApproach: getAnswerOptionText(question, response.selected_answer),
        correctApproach: getAnswerOptionText(question, question.correct_answer),
        coachingLearningPoint,
        competencySkill: competencyArea
      }
    }).filter(Boolean)

    return {
      hasIncorrectQuestions: true,
      incorrectCount: incorrectQuestions.length,
      questionsReview: analysis,
      summary: generateQuestionAnalysisSummary(analysis, competencyArea),
      learningFocus: generateLearningFocus(analysis, competencyArea)
    }
  }

  /**
   * Generate coaching-focused learning point from incorrect response
   */
  const generateCoachingLearningPoint = (scenario, question, explanation, competencyArea, selectedAnswer, correctAnswer) => {
    // ❌ HARDCODED COACHING CONTEXT REMOVED
    // All coaching context descriptions must come from database - implement coaching_context_descriptions table
    const context = `Database Missing: Coaching context description for ${competencyArea} not implemented in database schema`
    
    return {
      coachingContext: context,
      commonMistake: `Many coaches would choose similar responses, but the key distinction is ${explanation.split('.')[0].toLowerCase()}.`,
      keyInsight: explanation,
      practiceOpportunity: `Practice this scenario with colleagues or in supervision to refine your ${competencyArea.toLowerCase()} skills.`
    }
  }

  /**
   * Get the text of a specific answer option
   */
  const getAnswerOptionText = (question, answerIndex) => {
    if (!question) return 'Not available'
    
    const options = ['option_a', 'option_b', 'option_c', 'option_d']
    const optionKey = options[answerIndex - 1]
    return question[optionKey] || `Option ${answerIndex}`
  }

  /**
   * Generate summary of question analysis
   */
  const generateQuestionAnalysisSummary = (analysis, competencyArea) => {
    const count = analysis.length
    if (count === 1) {
      return `You missed 1 question in ${competencyArea}. This represents a specific learning opportunity in a coaching scenario that commonly challenges developing coaches.`
    } else {
      return `You missed ${count} questions in ${competencyArea}. These scenarios highlight specific areas where targeted practice and learning will significantly improve your coaching effectiveness.`
    }
  }

  /**
   * Generate focused learning recommendation based on question analysis
   */
  const generateLearningFocus = (analysis, competencyArea) => {
    // ❌ HARDCODED FOCUS AREAS REMOVED
    // All learning focus recommendations must come from database - implement learning_focus_recommendations table
    return `Database Missing: Learning focus recommendations for ${competencyArea} not implemented in database schema`
  }

  /**
   * Get competency-specific actionable steps
   */
  const getCompetencySpecificAction = (competencyArea, percentage, framework) => {
    // ❌ HARDCODED COMPETENCY ACTIONS REMOVED
    // All competency-specific actions must come from database - implement competency_actions table
    return `Database Missing: Competency-specific actions for ${competencyArea} not implemented in database schema`
  }

  /**
   * Get display name for competency
   * Queries competency_display_names table for proper display names
   */
  const getCompetencyDisplayName = async (competency, framework = 'core') => {
    try {
      // Use the singleton Supabase client

      // Create a competency key by converting the area name to a key format
      let competencyKey = competency.toLowerCase().replace(/\s+/g, '_').replace(/&/g, '').replace(/__+/g, '_')
      
      // First get the framework ID
      const { data: frameworkData } = await supabase
        .from('frameworks')
        .select('id')
        .eq('code', framework)
        .single()

      if (!frameworkData) {
        console.warn(`Framework not found: ${framework}`)
        return competency.replace(/Testing123\s*/, '').trim()
      }
      
      // Query competency display names and descriptions
      const { data: competencyData, error } = await supabase
        .from('competency_display_names')
        .select('display_name, description')
        .eq('competency_key', competencyKey)
        .eq('framework_id', frameworkData.id)
        .eq('is_active', true)
        .single()

      if (error || !competencyData) {
        // Fallback: return the original competency area name cleaned up
        return competency.replace(/Testing123\s*/, '').trim()
      }

      return competencyData.display_name
    } catch (error) {
      console.error('Error in getCompetencyDisplayName:', error)
      // Fallback: return the original competency area name
      return competency
    }
  }

  /**
   * Get description for competency from database
   */
  const getCompetencyDescription = async (competency, framework = 'core') => {
    try {
      // Use the singleton Supabase client

      // Create a competency key by converting the area name to a key format
      let competencyKey = competency.toLowerCase().replace(/\s+/g, '_').replace(/&/g, '').replace(/__+/g, '_')
      
      // First get the framework ID
      const { data: frameworkData } = await supabase
        .from('frameworks')
        .select('id')
        .eq('code', framework)
        .single()

      if (!frameworkData) {
        console.warn(`Framework not found: ${framework}`)
        return null
      }
      
      // Query competency descriptions
      const { data: competencyData, error } = await supabase
        .from('competency_display_names')
        .select('description')
        .eq('competency_key', competencyKey)
        .eq('framework_id', frameworkData.id)
        .eq('is_active', true)
        .single()

      if (error || !competencyData?.description) {
        // Fallback: return null if no description found
        return null
      }

      return competencyData.description
    } catch (error) {
      console.error('Error in getCompetencyDescription:', error)
      // Fallback: return null
      return null
    }
  }

  /**
   * Get skill name for competency
   */
  const getCompetencySkillName = (competency, framework = 'core') => {
    // ❌ HARDCODED SKILL NAME MAPPINGS REMOVED
    // All skill names must come from database - implement competency_skill_names table
    return `Database Missing: Skill names for ${framework} framework not implemented`
  }

  // Note: Strength leverage actions are now handled by framework-specific composables
  // This allows for different approaches across frameworks and difficulty levels

  return {
    generatePersonalizedCompetencyAnalysis,
    getCompetencyDescription
  }
}