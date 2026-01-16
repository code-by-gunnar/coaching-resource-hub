/**
 * Universal Assessment Insights Composable
 * Database-driven composable that works for ALL assessment combinations automatically
 * Eliminates need for framework-specific composables like useCoreBeginnerInsights.js
 */
import { useSupabase } from '../useSupabase.js'

export function useUniversalAssessmentInsights(framework = 'core', difficulty = 'beginner') {
  const { supabase } = useSupabase()
  
  console.log(`🎯 Universal Insights loaded for ${framework} ${difficulty}`)
  
  /**
   * Get framework and assessment level IDs for database queries
   */
  const getAssessmentIds = async () => {
    try {
      // Get framework ID
      const { data: frameworkData, error: frameworkError } = await supabase
        .from('frameworks')
        .select('id')
        .eq('code', framework.toLowerCase())
        .single()

      if (frameworkError) {
        console.error('Error fetching framework:', frameworkError)
        throw new Error(`Framework ${framework} not found`)
      }

      // Get assessment level ID
      const { data: levelData, error: levelError } = await supabase
        .from('assessment_levels')
        .select('id')
        .eq('level_code', difficulty.toLowerCase())
        .eq('framework_id', frameworkData.id)
        .single()

      if (levelError) {
        console.error('Error fetching assessment level:', levelError)
        throw new Error(`Assessment level ${difficulty} not found for framework ${framework}`)
      }

      return {
        frameworkId: frameworkData.id,
        assessmentLevelId: levelData.id
      }
    } catch (error) {
      console.error('Error getting assessment IDs:', error)
      throw error
    }
  }

  /**
   * Generate strategic actions for development areas (weaknesses)
   * Works for ALL assessments automatically via database query
   */
  const generateStrategicActions = async (competencyArea, percentage, incorrect, total) => {
    try {
      const cleanCompetencyArea = competencyArea?.trim()
      
      if (!cleanCompetencyArea) {
        console.warn('No competency area provided to generateStrategicActions')
        return [`No strategic actions available`]
      }

      console.log(`🎯 Generating strategic actions for ${cleanCompetencyArea} (${percentage}% performance)`)

      const { frameworkId, assessmentLevelId } = await getAssessmentIds()

      // Get competency ID by display_name (the frontend passes display names like "Advanced Active Listening")
      const { data: competencyData, error: competencyError } = await supabase
        .from('competency_display_names')
        .select('id, competency_key, display_name')
        .eq('framework_id', frameworkId)
        .eq('display_name', cleanCompetencyArea)
        .single()

      if (competencyError || !competencyData) {
        console.error('Competency not found:', cleanCompetencyArea, competencyError)
        return [`Strategic actions not available for ${cleanCompetencyArea}`]
      }

      // Query strategic actions using new scoring tier system
      const analysisType = percentage >= 70 ? 'strength' : percentage >= 50 ? 'developing' : 'weakness'
      
      console.log('🔍 Querying strategic actions:', {
        competencyArea: cleanCompetencyArea,
        percentage,
        analysisType,
        framework,
        difficulty: difficulty.toLowerCase()
      })
      
      const { data: actions, error: actionsError } = await supabase
        .from('strategic_actions_with_analysis_type')
        .select('action_text, priority_order')
        .eq('framework_code', framework.toLowerCase())
        .eq('assessment_level', difficulty.toLowerCase())
        .eq('competency_name', cleanCompetencyArea)
        .eq('analysis_type_code', analysisType)
        .lte('score_min', percentage)
        .gte('score_max', percentage)
        .eq('is_active', true)
        .order('priority_order')

      if (actionsError) {
        console.error('Error fetching strategic actions:', actionsError)
        return [`Error loading strategic actions for ${cleanCompetencyArea}`]
      }

      if (!actions || actions.length === 0) {
        console.warn(`❌ No strategic actions found for ${cleanCompetencyArea} at ${percentage}%`)
        console.log('🔍 Debugging: Trying to find ANY actions for this competency...')
        
        // Debug: Try to find actions in any tier for this competency
        const { data: debugActions, error: debugError } = await supabase
          .from('strategic_actions_with_analysis_type')
          .select('analysis_type_code, score_min, score_max, tier_name')
          .eq('framework_code', framework.toLowerCase())
          .eq('assessment_level', difficulty.toLowerCase())
          .eq('competency_name', cleanCompetencyArea)
          .eq('is_active', true)
        
        if (debugActions && debugActions.length > 0) {
          console.log(`🔍 Found ${debugActions.length} actions for ${cleanCompetencyArea} in other tiers:`, debugActions)
          
          // Try fallback to adjacent tiers if no exact match
          const fallbackTypes = analysisType === 'developing' 
            ? ['weakness', 'strength'] 
            : analysisType === 'weakness' 
            ? ['developing', 'strength'] 
            : ['developing', 'weakness']
          
          console.log(`🔄 Trying fallback tiers for ${analysisType}:`, fallbackTypes)
          
          for (const fallbackType of fallbackTypes) {
            const { data: fallbackActions } = await supabase
              .from('strategic_actions_with_analysis_type')
              .select('action_text, priority_order')
              .eq('framework_code', framework.toLowerCase())
              .eq('assessment_level', difficulty.toLowerCase())
              .eq('competency_name', cleanCompetencyArea)
              .eq('analysis_type_code', fallbackType)
              .eq('is_active', true)
              .order('priority_order')
              .limit(3)
            
            if (fallbackActions && fallbackActions.length > 0) {
              console.log(`✅ Using fallback: Found ${fallbackActions.length} actions in ${fallbackType} tier`)
              return fallbackActions.map(action => `${action.action_text} (Note: From ${fallbackType} tier as fallback)`)
            }
          }
        } else {
          console.log(`❌ No actions found for ${cleanCompetencyArea} in any tier - may be data migration issue`)
        }
        
        return [`No strategic actions available for ${cleanCompetencyArea}. This may indicate a data migration issue - please check database.`]
      }

      console.log(`✅ Found ${actions.length} strategic actions for ${cleanCompetencyArea}`)
      return actions.map(action => action.action_text)

    } catch (error) {
      console.error('Error in generateStrategicActions:', error)
      return [`Error generating strategic actions: ${error.message}`]
    }
  }

  /**
   * Generate strength leverage actions (for high performers, 70-100%)
   * Works for ALL assessments automatically via database query
   */
  const generateStrengthLeverageActions = async (competencyArea, percentage) => {
    try {
      const cleanCompetencyArea = competencyArea?.trim()
      
      if (!cleanCompetencyArea) {
        console.warn('No competency area provided to generateStrengthLeverageActions')
        return [`No strength leverage actions available`]
      }

      // Only return strength leverage for high performers (70%+)
      if (percentage < 70) {
        return []
      }

      console.log(`🎯 Generating strength leverage actions for ${cleanCompetencyArea} (${percentage}% performance)`)

      const { frameworkId, assessmentLevelId } = await getAssessmentIds()

      // Get competency ID by display_name (the frontend passes display names like "Advanced Active Listening")
      const { data: competencyData, error: competencyError } = await supabase
        .from('competency_display_names')
        .select('id, competency_key, display_name')
        .eq('framework_id', frameworkId)
        .eq('display_name', cleanCompetencyArea)
        .single()

      if (competencyError || !competencyData) {
        console.error('Competency not found:', cleanCompetencyArea, competencyError)
        return [`Strength leverage actions not available for ${cleanCompetencyArea}`]
      }

      // Query leverage strengths using new scoring tier system (strength tier: 70-100%)
      console.log('🔍 Querying leverage strengths:', {
        competencyArea: cleanCompetencyArea,
        percentage,
        framework,
        difficulty: difficulty.toLowerCase()
      })
      
      const { data: strengths, error: strengthsError } = await supabase
        .from('leverage_strengths_with_analysis_type')
        .select('leverage_text, priority_order')
        .eq('framework_code', framework.toLowerCase())
        .eq('assessment_level', difficulty.toLowerCase())
        .eq('competency_name', cleanCompetencyArea)
        .eq('analysis_type_code', 'strength')
        .lte('score_min', percentage)
        .gte('score_max', percentage)
        .eq('is_active', true)
        .order('priority_order')

      if (strengthsError) {
        console.error('Error fetching leverage strengths:', strengthsError)
        return [`Error loading strength leverage actions for ${cleanCompetencyArea}`]
      }

      if (!strengths || strengths.length === 0) {
        console.warn(`No leverage strengths found for ${cleanCompetencyArea} at ${percentage}%`)
        return []
      }

      console.log(`✅ Found ${strengths.length} strength leverage actions for ${cleanCompetencyArea}`)
      return strengths.map(strength => strength.leverage_text)

    } catch (error) {
      console.error('Error in generateStrengthLeverageActions:', error)
      return [`Error generating strength leverage actions: ${error.message}`]
    }
  }

  /**
   * Generate learning resources organized by category
   * Works for ALL assessments automatically via database query
   */
  const generateLearningResources = async () => {
    try {
      console.log(`🎯 Generating learning resources for ${framework} ${difficulty}`)

      const { frameworkId, assessmentLevelId } = await getAssessmentIds()

      // Query learning resources with categories and resource types
      const { data: resources, error: resourcesError } = await supabase
        .from('learning_resources')
        .select(`
          title,
          description,
          url,
          author_instructor,
          learning_path_categories!inner(
            category_title,
            category_description,
            category_icon,
            priority_order
          ),
          resource_types!inner(
            name,
            code
          )
        `)
        .eq('framework_id', frameworkId)
        .eq('assessment_level_id', assessmentLevelId)
        .eq('is_active', true)
        .order('learning_path_categories.priority_order')

      if (resourcesError) {
        console.error('Error fetching learning resources:', resourcesError)
        return [{
          icon: '⚠️',
          title: 'Learning Resources Error',
          description: 'Unable to load learning resources at this time.',
          resources: [`Error: ${resourcesError.message}`]
        }]
      }

      if (!resources || resources.length === 0) {
        console.warn(`No learning resources found for ${framework} ${difficulty}`)
        return [{
          icon: '📚',
          title: `${framework.toUpperCase()} ${difficulty.charAt(0).toUpperCase() + difficulty.slice(1)} Resources`,
          description: 'Learning resources are being developed for this assessment level.',
          resources: ['Check back soon for curated learning resources']
        }]
      }

      // Group resources by category
      const resourcesByCategory = {}
      
      resources.forEach(resource => {
        const categoryTitle = resource.learning_path_categories.category_title
        const categoryIcon = resource.learning_path_categories.category_icon
        const categoryDescription = resource.learning_path_categories.category_description
        
        if (!resourcesByCategory[categoryTitle]) {
          resourcesByCategory[categoryTitle] = {
            icon: categoryIcon,
            title: categoryTitle,
            description: categoryDescription,
            resources: []
          }
        }
        
        // Format resource entry
        const resourceText = resource.url 
          ? `📖 **${resource.title}** by ${resource.author_instructor} - ${resource.description} [Learn More](${resource.url})`
          : `📖 **${resource.title}** by ${resource.author_instructor} - ${resource.description}`
        
        resourcesByCategory[categoryTitle].resources.push(resourceText)
      })

      const formattedResources = Object.values(resourcesByCategory)
      
      console.log(`✅ Found ${formattedResources.length} learning resource categories for ${framework} ${difficulty}`)
      return formattedResources

    } catch (error) {
      console.error('Error in generateLearningResources:', error)
      return [{
        icon: '⚠️',
        title: 'Learning Resources Error',
        description: 'Unable to load learning resources at this time.',
        resources: [`Error: ${error.message}`]
      }]
    }
  }

  /**
   * Get proper display name for competency
   * Works for ALL assessments automatically via database query
   */
  const getCompetencyDisplayName = async (competency) => {
    try {
      if (!competency) return 'Unknown Competency'
      
      const { frameworkId } = await getAssessmentIds()

      const { data, error } = await supabase
        .from('competency_display_names')
        .select('display_name, competency_key')
        .eq('framework_id', frameworkId)
        .eq('display_name', competency)
        .single()

      if (error || !data) {
        console.warn(`Display name not found for competency: ${competency}`)
        return competency
      }

      return data.display_name
    } catch (error) {
      console.error('Error getting competency display name:', error)
      return competency
    }
  }

  /**
   * Validate that this assessment combination exists in the database
   */
  const validateAssessment = async () => {
    try {
      const { frameworkId, assessmentLevelId } = await getAssessmentIds()
      return true // If we got here without throwing, the assessment exists
    } catch (error) {
      console.error(`Assessment validation failed for ${framework} ${difficulty}:`, error)
      return false
    }
  }

  // Return the composable interface - same as framework-specific composables
  return {
    generateStrategicActions,
    generateStrengthLeverageActions,
    generateLearningResources,
    getCompetencyDisplayName,
    validateAssessment,
    framework: framework.toLowerCase(),
    difficulty: difficulty.toLowerCase(),
    version: 'universal-database-driven'
  }
}