import { useSupabase } from './useSupabase.js'
import { useAssessmentInsights } from './useAssessmentInsights.js'
import { usePersonalizedInsights } from './usePersonalizedInsights.js'
import { getUserFriendlyError, formatErrorForUI } from './useUserFriendlyErrors.js'

/**
 * Composable to capture and store exact frontend-generated insights
 */
export function useFrontendInsightsCapture() {
  const { supabase } = useSupabase()
  const { generatePersonalizedCompetencyAnalysis } = usePersonalizedInsights()

  /**
   * Generate personalized smart insights from competency analysis
   */
  const generatePersonalizedSmartInsights = (competencyAnalysis, competencyStats) => {
    if (!competencyAnalysis?.length) return { weakAreas: [], strengths: [] }
    
    const weakAreas = competencyAnalysis
      .filter(comp => comp.percentage < 70)
      .sort((a,b) => a.percentage - b.percentage)
      .map(comp => ({
        area: comp.area,
        total: comp.total,
        correct: comp.correct,
        percentage: comp.percentage,
        displayName: comp.displayName,
        // Use personalized insights instead of generic ones
        insights: comp.personalizedInsights?.slice(0, 2) || [`${comp.area} requires focused development to improve coaching effectiveness.`],
        actions: comp.personalizedActions?.slice(0, 3) || [`Focus on practicing ${comp.area.toLowerCase()} skills in upcoming sessions`]
      }))
    
    const strengths = competencyAnalysis
      .filter(comp => comp.percentage >= 70)
      .sort((a,b) => b.percentage - a.percentage)
      .map(comp => ({
        area: comp.area,
        total: comp.total,
        correct: comp.correct,
        percentage: comp.percentage,
        displayName: comp.displayName,
        // Use personalized strength message from coaching implications
        message: comp.performanceContext?.coachingImplications || 
                comp.personalizedInsights?.[0] || 
                `You demonstrate strong capability in ${comp.area}. This is one of your strongest skills.`
      }))
    
    return { weakAreas, strengths }
  }

  /**
   * Generate learning resources from normalized database
   * Query learning_resources table based on competency areas and score ranges
   */
  const generateLearningResources = async (competencyStats, overallScore) => {
    if (!competencyStats?.length) return []
    
    try {
      // Use existing Supabase singleton

      // Get scoring tier for overall score using new 3-tier system
      const analysisType = overallScore >= 70 ? 'strength' : overallScore >= 50 ? 'developing' : 'weakness'
      
      console.log('🔍 Querying learning_resources table:', {
        overallScore,
        analysisType,
        queryFilters: {
          tier_lookup: true,
          is_active: true
        }
      })

      // Query learning resources based on scoring tier instead of score ranges
      const { data: resources, error } = await supabase
        .from('learning_resources')
        .select(`
          *,
          frameworks!framework_id(code),
          assessment_levels!assessment_level_id(level_code),
          resource_types!resource_type_id(code, name),
          learning_resource_competencies(
            competency_display_names!competency_id(display_name)
          ),
          scoring_tiers!scoring_tier_id(
            tier_code,
            tier_name,
            score_min,
            score_max
          )
        `)
        .eq('is_active', true)
        .order('assessment_levels(level_code)')
        .order('resource_types(code)')

      if (error) {
        console.error('❌ DATABASE ERROR: Failed to fetch learning resources:', error)
        console.log('🚨 NO FALLBACK - Database error means no learning resources available')
        return []
      }

      // Transform the normalized data back to expected format for backward compatibility
      if (resources) {
        resources.forEach(resource => {
          // Add backward compatibility fields
          resource.difficulty_level = resource.assessment_levels?.level_code || 'beginner'
          resource.resource_type = resource.resource_types?.code || 'article'
          resource.competency_areas = resource.learning_resource_competencies?.map(
            lrc => lrc.competency_display_names?.display_name
          ).filter(Boolean) || []
        })
      }

      // Filter resources by scoring tier after query (since we need to check if score falls within tier range)
      const filteredResources = resources?.filter(resource => {
        const tier = resource.scoring_tiers
        if (!tier) return false
        return overallScore >= tier.score_min && overallScore <= tier.score_max
      }) || []
      
      console.log('📊 Learning resources query result:', {
        totalResources: resources?.length || 0,
        filteredResources: filteredResources.length,
        scoreRange: overallScore,
        analysisType,
        sampleResources: filteredResources?.slice(0, 2).map(r => ({ 
          title: r.title, 
          type: r.resource_type,
          tier: r.scoring_tiers?.tier_name,
          score_range: `${r.scoring_tiers?.score_min}-${r.scoring_tiers?.score_max}`
        }))
      })

      if (!filteredResources?.length) {
        console.warn('⚠️ DATABASE MISMATCH: No learning resources found for score:', overallScore)
        console.log('📊 Available scoring tiers in database - run this query to check:')
        console.log('SELECT st.tier_name, st.score_min, st.score_max, COUNT(lr.id) as resource_count FROM scoring_tiers st LEFT JOIN learning_resources lr ON st.id = lr.scoring_tier_id WHERE st.is_active = true GROUP BY st.id ORDER BY st.score_min;')
        console.log('🚨 SHOWING ERROR SECTION - Database issue visible on frontend')
        const friendlyError = getUserFriendlyError('NO_LEARNING_RESOURCES_LOADED')
        return [formatErrorForUI(friendlyError)]
      }

      // Group resources by competency area and resource type
      const groupedResources = []
      const lowPerformance = competencyStats.filter(comp => comp.percentage < 70)
      
      // Get weak competency areas for targeted recommendations
      console.log('🏷️ Mapping competency areas for learning resources:', {
        lowPerformanceAreas: lowPerformance.map(c => c.area)
      })
      
      const weakAreas = lowPerformance.map(c => {
        let mappedArea = null
        if (c.area.includes('Active Listening')) mappedArea = 'Active Listening'
        else if (c.area.includes('Powerful Questions')) mappedArea = 'Powerful Questions'  
        else if (c.area.includes('Creating Awareness')) mappedArea = 'Creating Awareness'
        else if (c.area.includes('Direct Communication')) mappedArea = 'Direct Communication'
        else if (c.area.includes('Designing Actions') || c.area.includes('Goal Setting')) mappedArea = 'Designing Actions'
        else if (c.area.includes('Language Awareness')) mappedArea = 'Intuition & Language Awareness'
        else if (c.area.includes('Meaning Exploration')) mappedArea = 'Values & Meaning Exploration'
        else if (c.area.includes('Present Moment Awareness')) mappedArea = 'Present Moment Awareness'
        
        if (!mappedArea) {
          console.warn('⚠️ COMPETENCY MAPPING MISMATCH: No learning resource mapping for area:', c.area)
          console.log('💡 Available mappings: Active Listening, Powerful Questions, Creating Awareness, Direct Communication, Designing Actions, Intuition & Language Awareness, Values & Meaning Exploration, Present Moment Awareness')
        } else {
          console.log('✅ Mapped', c.area, '->', mappedArea)
        }
        
        return mappedArea
      }).filter(Boolean)
      
      console.log('📊 Final weak areas for resource filtering:', weakAreas)

      // Format resources for display
      console.log('🔍 Filtering resources by relevance:', {
        totalResources: resources.length,
        weakAreas,
        sampleResourceCompetencies: resources.slice(0, 3).map(r => ({
          title: r.title,
          competency_areas: r.competency_areas,
          type: r.resource_type
        }))
      })

      const resourcesByType = filteredResources.reduce((acc, resource) => {
        // Check if this resource matches weak areas or is general
        const isRelevant = !resource.competency_areas || 
          resource.competency_areas.some(area => weakAreas.includes(area))
        
        console.log('🎯 Resource relevance check:', {
          title: resource.title,
          resourceCompetencies: resource.competency_areas,
          weakAreas,
          isRelevant
        })
        
        if (isRelevant) {
          const key = resource.resource_type
          if (!acc[key]) acc[key] = []
          
          let displayText = resource.title
          if (resource.author_instructor) displayText += ` by ${resource.author_instructor}`
          if (resource.description) displayText += ` - ${resource.description}`
          
          acc[key].push(displayText)
        }
        return acc
      }, {})

      console.log('📊 Resources grouped by type:', {
        resourceTypes: Object.keys(resourcesByType),
        totalRelevantResources: Object.values(resourcesByType).flat().length,
        typeBreakdown: Object.entries(resourcesByType).map(([type, items]) => ({
          type,
          count: items.length
        }))
      })

      // Create resource sections
      Object.entries(resourcesByType).forEach(([type, items]) => {
        if (items.length > 0) {
          const section = {
            icon: getResourceIcon(type),
            title: getResourceTitle(type, overallScore),
            description: getResourceDescription(type, overallScore),
            resources: items.slice(0, 4) // Limit to top 4 per section
          }
          groupedResources.push(section)
        }
      })

      if (groupedResources.length === 0) {
        console.warn('⚠️ LEARNING RESOURCES MISMATCH: No relevant resources found after filtering')
        console.log('💡 This may indicate:', [
          'Resource competency_areas don\'t match weak area mappings',
          'Score range filters too restrictive', 
          'Missing resources in database for this score range'
        ])
        console.log('🚨 SHOWING ERROR SECTION - Competency mapping issue visible on frontend')
        
        const friendlyError = getUserFriendlyError('COMPETENCY_MAPPING_ISSUE')
        return [formatErrorForUI(friendlyError)]
      }

      return groupedResources

    } catch (error) {
      console.error('❌ CRITICAL ERROR in generateLearningResources:', error)
      console.log('🚨 SHOWING ERROR SECTION - Application error visible on frontend')
      return [{
        icon: '💥',
        title: 'DATABASE ERROR: Application Crash',
        description: 'Critical error loading learning resources from database',
        resources: [
          `Error: ${error.message}`,
          'Fix: Check database connection and query syntax',
          'Debug: Review console logs for stack trace'
        ]
      }]
    }
  }

  /**
   * Helper functions for resource display
   */
  const getResourceIcon = (type) => {
    const icons = {
      book: '📚',
      course: '🎓', 
      video: '🎥',
      article: '📄',
      exercise: '💪',
      tool: '🔧',
      workshop: '🛠️',
      certification: '🏆',
      assessment: '📊',
      mentor: '👥',
      community: '🤝',
      conference: '🎤',
      app: '📱'
    }
    return icons[type] || '📖'
  }

  const getResourceTitle = (type, score) => {
    if (score < 30) return `Foundation ${type.charAt(0).toUpperCase() + type.slice(1)}s`
    if (score >= 80) return `Advanced ${type.charAt(0).toUpperCase() + type.slice(1)}s`
    return `Essential ${type.charAt(0).toUpperCase() + type.slice(1)}s`
  }

  const getResourceDescription = (type, score) => {
    if (score < 30) return `Fundamental ${type} resources to build your coaching foundation.`
    if (score >= 80) return `Advanced ${type} resources for mastery and specialization.`
    return `Targeted ${type} resources for skill development.`
  }

  // ❌ HARDCODED FALLBACK FUNCTION REMOVED
  // All learning resources must come from database only

  /**
   * Capture complete frontend insights data and store it
   */
  const captureAndStoreFrontendInsights = async (attemptId, competencyStats, assessmentFramework, selectedAttempt) => {
    try {
      console.log('🎯 CAPTURING FRONTEND INSIGHTS for attempt:', attemptId)
      console.log('📊 Attempt data structure:', {
        attempt: selectedAttempt.value?.attempt,
        assessments: selectedAttempt.value?.attempt?.assessments
      })

      // Get the insights composable with the same data the frontend uses
      const { 
        getSmartInsights,
        mapCompetencyToDisplayName,
        mapCompetencyToSkill, 
        getSkillTags,
        getTagInsight,
        getTagActionableStep,
        getCompetencyInsights,
        getActionableSteps,
        getStrengthMessage,
        ensureCacheLoaded
      } = useAssessmentInsights(competencyStats, assessmentFramework)
      
      // CRITICAL: Ensure cache is loaded before proceeding to prevent race conditions
      console.log('🔄 Ensuring database cache is loaded before generating insights...')
      await ensureCacheLoaded()

      // Get detailed responses for personalized analysis
      const responses = selectedAttempt.value?.responses || []
      
      // Build overall stats from the attempt data first (needed for competency analysis)
      const attemptData = selectedAttempt.value?.attempt
      const assessmentData = attemptData?.assessments
      const overallScore = selectedAttempt.value?.attempt?.score || 0
      
      const overallStats = {
        total_questions: selectedAttempt.value?.responses?.length || 0,
        correct_answers: selectedAttempt.value?.responses?.filter(r => r.is_correct).length || 0,
        score: overallScore,
        time_spent: attemptData?.time_spent || 0,
        assessment_title: assessmentData?.title || '',
        assessment_framework: assessmentFramework.value || 'core',
        assessment_difficulty: assessmentData?.difficulty || 'Beginner',
        assessment_slug: assessmentData?.slug || '',
        completion_rate: selectedAttempt.value?.responses?.length > 0 
          ? Math.round((selectedAttempt.value.responses.filter(r => r.is_correct).length / selectedAttempt.value.responses.length) * 100)
          : 0
      }
      
      // Build personalized competency analysis based on actual performance
      const competencyAnalysis = await generatePersonalizedCompetencyAnalysis(
        competencyStats.value,
        responses,
        assessmentFramework.value,
        overallStats.assessment_difficulty, // Pass the difficulty level
        getSkillTags,
        getTagInsight,
        getTagActionableStep
      )

      // Generate personalized smart insights AFTER competency analysis is created
      const smartInsights = generatePersonalizedSmartInsights(competencyAnalysis, competencyStats.value)

      // Clean competency analysis - only personalized data
      const competencyAnalysisWithTags = competencyAnalysis.map(comp => {
        const skillTags = getSkillTags(comp.area)
        
        return {
          ...comp,
          skillTags: skillTags,
          tagInsights: skillTags.map(tag => ({
            tag: tag,
            insight: getTagInsight(tag),
            actionableStep: getTagActionableStep(tag)
          }))
        }
      })

      // Learning resources now queried directly from normalized tables (not stored in JSONB)

      // Build ULTRA-LEAN JSONB structure - only dynamic data, no static content
      const frontendInsights = {
        assessment_framework: assessmentFramework.value,
        overall_stats: overallStats,
        // Only store competency performance data (scores), not static text
        competency_performance: competencyStats.value.map(comp => ({
          competency_area: comp.area,
          correct: comp.correct,
          total: comp.total,
          percentage: comp.percentage
        })),
        // Store which areas are weak/strong (IDs only), not static text
        performance_analysis: {
          weak_competency_areas: smartInsights.weakAreas?.map(w => w.area) || [],
          strong_competency_areas: smartInsights.strengths?.map(s => s.area) || []
        }
        // All static content (insights, actions, display names) now queried from normalized tables
      }

      console.log('📊 Frontend insights captured:', {
        competencies: competencyAnalysisWithTags.length,
        personalizedInsights: competencyAnalysisWithTags.filter(c => c.personalizedInsights?.length > 0).length,
        weakAreas: smartInsights.weakAreas?.length || 0,
        strengths: smartInsights.strengths?.length || 0,
        difficulty: overallStats.assessment_difficulty,
        totalResponses: responses.length
        // learningResources now queried from normalized tables (not stored in JSONB)
      })

      // Store the frontend insights in the database
      const { data, error } = await supabase
        .rpc('store_frontend_insights', {
          attempt_uuid: attemptId,
          frontend_insights: frontendInsights
        })

      if (error) {
        console.error('🚨 Error storing frontend insights:', error)
        throw error
      }

      console.log('✅ Frontend insights stored successfully')
      return frontendInsights

    } catch (error) {
      console.error('🚨 Error capturing frontend insights:', error)
      throw error
    }
  }

  return {
    captureAndStoreFrontendInsights
  }
}