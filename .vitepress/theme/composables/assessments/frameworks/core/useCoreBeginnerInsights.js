/**
 * Core Framework - Beginner Level Assessment Insights
 * Specialized insights, actions, and learning resources for Core Beginner assessments
 */
import { useSupabase } from '../../../useSupabase.js'

export function useCoreBeginnerInsights() {
  const { supabase } = useSupabase()
  
  /**
   * Generate strategic actions for development areas (weaknesses)
   * Queries competency_strategic_actions table based on competency area and score range
   */
  const generateStrategicActions = async (competencyArea, percentage, incorrect, total) => {
    try {
      // Clean the competency area name
      const cleanCompetencyArea = competencyArea?.trim()
      
      if (!cleanCompetencyArea) {
        console.warn('No competency area provided to generateStrategicActions')
        return [`No strategic actions available`]
      }

      // Use the singleton Supabase client

      // Get framework and assessment level IDs first
      const { data: frameworkData, error: frameworkError } = await supabase
        .from('frameworks')
        .select('id')
        .eq('code', 'core')
        .single()

      if (frameworkError) {
        console.error('Error fetching framework:', frameworkError)
        return [`Error loading strategic actions: Framework lookup failed`]
      }

      const { data: levelData, error: levelError } = await supabase
        .from('assessment_levels')
        .select('id')
        .eq('level_code', 'beginner')
        .eq('framework_id', frameworkData.id)
        .single()

      if (levelError) {
        console.error('Error fetching assessment level:', levelError)
        return [`Error loading strategic actions: Assessment level lookup failed`]
      }

      const { data: competencyData, error: competencyError } = await supabase
        .from('competency_display_names')
        .select('id')
        .eq('display_name', cleanCompetencyArea)
        .eq('framework_id', frameworkData?.id)
        .maybeSingle()

      if (competencyError) {
        console.error('Error fetching competency:', competencyError)
      }

      if (!frameworkData || !levelData || !competencyData) {
        console.warn(`Missing reference data for strategic actions: ${cleanCompetencyArea}`, {
          frameworkFound: !!frameworkData,
          levelFound: !!levelData,
          competencyFound: !!competencyData,
          competencyArea,
          frameworkId: frameworkData?.id
        })
        return [`No strategic actions found for ${competencyArea} at ${percentage}% performance level`]
      }

      // Query strategic actions using new scoring tier system
      const analysisType = percentage >= 70 ? 'strength' : percentage >= 50 ? 'developing' : 'weakness'
      
      console.log('🔍 Querying strategic actions:', {
        competencyArea: cleanCompetencyArea,
        percentage,
        analysisType
      })
      
      const { data: actions, error } = await supabase
        .from('strategic_actions_with_analysis_type')
        .select('action_text')
        .eq('competency_name', cleanCompetencyArea)
        .eq('framework_code', 'core')
        .eq('assessment_level', 'beginner')
        .eq('analysis_type_code', analysisType)
        .lte('score_min', percentage)
        .gte('score_max', percentage)
        .eq('is_active', true)
        .order('priority_order')

      if (error) {
        console.error('Error querying strategic actions:', error)
        return [`Error loading strategic actions for ${competencyArea}`]
      }

      if (!actions || actions.length === 0) {
        return [`No strategic actions found for ${competencyArea} at ${percentage}% performance level`]
      }

      return actions.map(action => action.action_text)
    } catch (error) {
      console.error('Error in generateStrategicActions:', error)
      return [`Database error loading strategic actions for ${competencyArea}`]
    }
  }

  /**
   * Generate strength leverage actions for areas of strength
   * NEW: Uses skills-based strength actions from tag_actions table (Assessment-Skills Alignment)
   */
  const generateStrengthLeverageActions = async (competencyArea, percentage) => {
    try {
      // Clean the competency area name
      const cleanCompetencyArea = competencyArea?.trim()
      
      if (!cleanCompetencyArea) {
        console.warn('No competency area provided to generateStrengthLeverageActions')
        return [`No strength leverage actions available`]
      }

      // Get framework and assessment level IDs
      const { data: frameworkData, error: frameworkError } = await supabase
        .from('frameworks')
        .select('id')
        .eq('code', 'core')
        .single()

      if (frameworkError) {
        console.error('Error fetching framework:', frameworkError)
        return [`Error loading strength actions: Framework lookup failed`]
      }

      const { data: levelData, error: levelError } = await supabase
        .from('assessment_levels')
        .select('id')
        .eq('level_code', 'beginner')
        .eq('framework_id', frameworkData.id)
        .single()

      if (levelError) {
        console.error('Error fetching assessment level:', levelError)
        return [`Error loading strength actions: Assessment level lookup failed`]
      }

      const { data: competencyData, error: competencyError } = await supabase
        .from('competency_display_names')
        .select('id')
        .eq('display_name', cleanCompetencyArea)
        .eq('framework_id', frameworkData?.id)
        .maybeSingle()

      if (competencyError) {
        console.error('Error fetching competency for strength actions:', competencyError)
      }

      if (!frameworkData || !levelData || !competencyData) {
        console.warn(`Missing reference data for strength actions: ${cleanCompetencyArea}`, {
          frameworkFound: !!frameworkData,
          levelFound: !!levelData,
          competencyFound: !!competencyData,
          competencyArea,
          frameworkId: frameworkData?.id
        })
        return [`No strength actions found for ${competencyArea} at ${percentage}% performance level`]
      }

      // Get strength analysis type ID first
      const { data: strengthAnalysisType, error: analysisTypeError } = await supabase
        .from('analysis_types')
        .select('id')
        .eq('code', 'strength')
        .single()

      if (analysisTypeError || !strengthAnalysisType) {
        console.error('Error fetching strength analysis type:', analysisTypeError)
        return [`Error loading strength analysis type`]
      }

      // NEW: Query skills-based strength actions from tag_actions table
      // This replaces the old competency_leverage_strengths approach
      const { data: actions, error } = await supabase
        .from('tag_actions')
        .select(`
          action_text,
          skill_tags!inner(
            name,
            sort_order
          )
        `)
        .eq('skill_tags.framework_id', frameworkData.id)
        .eq('skill_tags.assessment_level_id', levelData.id)
        .eq('skill_tags.competency_id', competencyData.id)
        .eq('analysis_type_id', strengthAnalysisType.id)
        .eq('is_active', true)
        .order('skill_tags(sort_order)')

      if (error) {
        console.error('Error querying strength actions:', error.message || error)
        return [`Error loading strength actions for ${competencyArea}`]
      }

      if (!actions || actions.length === 0) {
        return [`No strength actions found for ${competencyArea} at ${percentage}% performance level`]
      }

      // Return skill-specific strength actions
      return actions.map(action => action.action_text)
    } catch (error) {
      console.error('Error in generateStrengthLeverageActions:', error)
      return [`Database error loading strength actions for ${competencyArea}`]
    }
  }

  /**
   * Generate learning resources from normalized database
   * Query learning_resources table based on competency areas and score ranges
   */
  const generateLearningResources = async (competencyStats, overallScore) => {
    if (!competencyStats?.length) return []
    
    try {
      // Use the singleton Supabase client

      // Get framework and assessment level IDs for FK filtering
      const { data: frameworkData } = await supabase
        .from('frameworks')
        .select('id')
        .eq('code', 'core')
        .single()

      if (!frameworkData) {
        console.error('Framework "core" not found')
        return []
      }

      // Determine assessment level based on overall score
      const levelCode = overallScore < 50 ? 'beginner' : overallScore < 80 ? 'intermediate' : 'advanced'
      
      const { data: levelData } = await supabase
        .from('assessment_levels')
        .select('id')
        .eq('level_code', levelCode)
        .eq('framework_id', frameworkData.id)
        .single()

      if (!levelData) {
        console.error(`Assessment level "${levelCode}" not found`)
        return []
      }

      // Query learning resources using FK relationships
      const { data: resources, error } = await supabase
        .from('learning_resources')
        .select(`
          *,
          frameworks!framework_id(code),
          assessment_levels!assessment_level_id(level_code),
          resource_types!resource_type_id(code, name),
          learning_resource_competencies(
            competency_display_names!competency_id(display_name)
          )
        `)
        .eq('framework_id', frameworkData.id)
        .eq('assessment_level_id', levelData.id)
        .eq('is_active', true)
        .order('id')

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

      if (!resources?.length) {
        console.warn('⚠️ DATABASE MISMATCH: No learning resources found for score:', overallScore)
        console.log('🚨 NO FALLBACK - Must populate learning_resources table for this score range')
        return [{
          icon: '⚠️',
          title: 'Database Missing Learning Resources',
          description: `No learning resources found in database for score ${overallScore}. Check learning_resources table.`,
          resources: ['Database integrity issue - populate learning_resources table']
        }]
      }

      // Group resources by competency area and resource type
      const groupedResources = []
      
      // Get ALL competency areas from the assessment (not just weak ones)
      // Learning resources should be shown based on overall score, not just weaknesses
      const allCompetencyAreas = competencyStats.map(c => {
        // Direct mapping - use the exact competency area name from the assessment
        return c.area
      }).filter(Boolean)

      // Format resources for display
      const resourcesByType = resources.reduce((acc, resource) => {
        // Check if this resource matches any competency areas or is general
        const isRelevant = !resource.competency_areas || 
          resource.competency_areas.some(area => allCompetencyAreas.includes(area))
        
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
        console.log('🚨 NO FALLBACK - Must fix database competency area mappings')
        console.log('🔍 Debug info - resources found:', resources.length)
        console.log('🔍 Debug info - competency areas from assessment:', allCompetencyAreas)
        console.log('🔍 Debug info - resource competency areas:', resources.map(r => r.competency_areas))
        return [{
          icon: '⚠️',
          title: 'Database Competency Mapping Issue', 
          description: `Found ${resources.length} resources but none match competency areas`,
          resources: ['Database integrity issue - check competency_areas in learning_resources table']
        }]
      }

      return groupedResources

    } catch (error) {
      console.error('❌ CRITICAL ERROR in generateLearningResources:', error)
      console.log('🚨 NO FALLBACK - Application error, no learning resources available')
      return [{
        icon: '💥',
        title: 'Application Error',
        description: 'Critical error loading learning resources from database',
        resources: ['Application error - check console logs']
      }]
    }
  }

  // ❌ HARDCODED FALLBACK FUNCTION REMOVED
  // All learning resources must come from database only

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

  /**
   * Core competency display names for beginner level
   * Queries competency_display_names table for proper display names
   */
  const getCompetencyDisplayName = async (competency) => {
    try {
      // Use the singleton Supabase client

      // Create a competency key by converting the area name to a key format
      let competencyKey = competency.toLowerCase().replace(/\s+/g, '_').replace(/&/g, '').replace(/__+/g, '_')
      
      // First get the framework ID
      const { data: frameworkData } = await supabase
        .from('frameworks')
        .select('id')
        .eq('code', 'core')
        .single()

      if (!frameworkData) {
        console.warn('Framework "core" not found')
        return competency.replace(/Testing123\s*/, '').trim()
      }
      
      // Query competency display names
      const { data: displayName, error } = await supabase
        .from('competency_display_names')
        .select('display_name')
        .eq('competency_key', competencyKey)
        .eq('framework_id', frameworkData.id)
        .eq('is_active', true)
        .single()

      if (error || !displayName) {
        // Fallback: return the original competency area name cleaned up
        return competency.replace(/Testing123\s*/, '').trim()
      }

      return displayName.display_name
    } catch (error) {
      console.error('Error in getCompetencyDisplayName:', error)
      // Fallback: return the original competency area name
      return competency
    }
  }

  return {
    generateStrategicActions,
    generateStrengthLeverageActions,
    generateLearningResources,
    getCompetencyDisplayName,
    // Framework metadata
    framework: 'core',
    difficulty: 'beginner',
    version: '1.0.0'
  }
}