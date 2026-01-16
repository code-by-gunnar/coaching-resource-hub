/**
 * Normalized Database Insights Composable
 * Replaces hardcoded JSONB data with efficient database queries
 * Reduces storage from ~10kB JSONB to ~1-2kB normalized data
 */
import { ref, computed } from 'vue'
import { useSupabase } from '../useSupabase.js'

export function useNormalizedInsights() {
  const { supabase } = useSupabase()
  const loading = ref(false)
  const error = ref(null)

  /**
   * Get competency display names for a framework
   */
  const getCompetencyDisplayNames = async (framework = 'core') => {
    try {
      loading.value = true
      // Get framework ID first
      const { data: frameworkData } = await supabase
        .from('frameworks')
        .select('id')
        .eq('code', framework)
        .single()

      if (!frameworkData) {
        throw new Error(`Framework not found: ${framework}`)
      }

      const { data, error: dbError } = await supabase
        .from('competency_display_names')
        .select(`
          *,
          frameworks!framework_id(code)
        `)
        .eq('framework_id', frameworkData.id)
        .eq('is_active', true)
        .order('sort_order')

      if (dbError) throw dbError
      return data || []
    } catch (err) {
      error.value = err.message
      console.error('Error fetching competency display names:', err)
      return []
    } finally {
      loading.value = false
    }
  }

  /**
   * Get skill tags for specific competency areas
   */
  const getSkillTags = async (competencyAreas, framework = 'core') => {
    try {
      loading.value = true
      // Get framework ID first
      const { data: frameworkData } = await supabase
        .from('frameworks')
        .select('id')
        .eq('code', framework)
        .single()

      if (!frameworkData) {
        throw new Error(`Framework not found: ${framework}`)
      }

      // Get competency IDs for the areas
      const { data: competencyData } = await supabase
        .from('competency_display_names')
        .select('id, display_name')
        .in('display_name', competencyAreas)
        .eq('framework_id', frameworkData.id)
        .eq('is_active', true)

      if (!competencyData?.length) {
        console.warn('No competencies found for areas:', competencyAreas)
        return []
      }

      const competencyIds = competencyData.map(c => c.id)

      const { data, error: dbError } = await supabase
        .from('skill_tags')
        .select(`
          *,
          competency_display_names!competency_id(display_name),
          frameworks!framework_id(code)
        `)
        .in('competency_id', competencyIds)
        .eq('framework_id', frameworkData.id)
        .eq('is_active', true)
        .order('competency_id, sort_order')

      if (dbError) throw dbError
      return data || []
    } catch (err) {
      error.value = err.message
      console.error('Error fetching skill tags:', err)
      return []
    } finally {
      loading.value = false
    }
  }

  /**
   * Get insights for specific skill tags
   */
  const getInsightsForSkills = async (skillTagIds, insightType = 'weakness') => {
    try {
      loading.value = true
      const { data, error: dbError } = await supabase
        .from('tag_insights')
        .select(`
          *,
          skill_tags (
            name,
            competency_display_names!competency_id(display_name),
            frameworks!framework_id(code)
          ),
          analysis_types!analysis_type_id(code)
        `)
        .in('skill_tag_id', skillTagIds)
        .eq('analysis_types.code', insightType)
        .eq('is_active', true)

      if (dbError) throw dbError
      return data || []
    } catch (err) {
      error.value = err.message
      console.error('Error fetching insights:', err)
      return []
    } finally {
      loading.value = false
    }
  }

  /**
   * Get strategic actions for specific skill tags
   */
  const getActionsForSkills = async (skillTagIds, actionCategory = null) => {
    try {
      loading.value = true
      
      let query = supabase
        .from('tag_actions')
        .select(`
          *,
          skill_tags (
            name,
            competency_display_names!competency_id(display_name),
            frameworks!framework_id(code)
          ),
          assessment_levels!assessment_level_id(level_code)
        `)
        .in('skill_tag_id', skillTagIds)
        .eq('is_active', true)
        .order('assessment_levels(level_code), sort_order')

      if (actionCategory) {
        query = query.eq('action_category', actionCategory)
      }

      const { data, error: dbError } = await query

      if (dbError) throw dbError
      return data || []
    } catch (err) {
      error.value = err.message
      console.error('Error fetching actions:', err)
      return []
    } finally {
      loading.value = false
    }
  }

  /**
   * Get learning resources for competency areas
   */
  const getLearningResources = async (competencyAreas, framework = 'core', difficultyLevel = null) => {
    try {
      loading.value = true
      
      // Get framework ID first
      const { data: frameworkData } = await supabase
        .from('frameworks')
        .select('id')
        .eq('code', framework)
        .single()

      if (!frameworkData) {
        throw new Error(`Framework not found: ${framework}`)
      }

      // Get competency IDs for the areas
      const { data: competencyData } = await supabase
        .from('competency_display_names')
        .select('id')
        .in('display_name', competencyAreas)
        .eq('framework_id', frameworkData.id)
        .eq('is_active', true)

      if (!competencyData?.length) {
        console.warn('No competencies found for areas:', competencyAreas)
        return []
      }

      const competencyIds = competencyData.map(c => c.id)

      // Query learning resources through the many-to-many table
      let query = supabase
        .from('learning_resources')
        .select(`
          *,
          frameworks!framework_id(code),
          assessment_levels!assessment_level_id(level_code),
          resource_types!resource_type_id(code, name),
          learning_resource_competencies!inner(
            competency_display_names!competency_id(display_name)
          )
        `)
        .eq('framework_id', frameworkData.id)
        .eq('is_active', true)
        .order('sort_order', { ascending: false })

      if (difficultyLevel) {
        const { data: levelData } = await supabase
          .from('assessment_levels')
          .select('id')
          .eq('level_code', difficultyLevel)
          .single()
        
        if (levelData) {
          query = query.eq('assessment_level_id', levelData.id)
        }
      }

      const { data, error: dbError } = await query

      if (dbError) throw dbError
      
      // Filter by competency areas and add backward compatibility fields
      const filteredData = (data || []).filter(resource => {
        const resourceCompetencies = resource.learning_resource_competencies?.map(
          lrc => lrc.competency_display_names?.display_name
        ).filter(Boolean) || []
        
        // Check if any of the requested competency areas match
        return competencyAreas.some(area => resourceCompetencies.includes(area))
      }).map(resource => {
        // Add backward compatibility fields
        resource.difficulty_level = resource.assessment_levels?.level_code || 'beginner'
        resource.resource_type = resource.resource_types?.code || 'article'
        resource.competency_areas = resource.learning_resource_competencies?.map(
          lrc => lrc.competency_display_names?.display_name
        ).filter(Boolean) || []
        return resource
      })
      
      return filteredData
    } catch (err) {
      error.value = err.message
      console.error('Error fetching learning resources:', err)
      return []
    } finally {
      loading.value = false
    }
  }

  /**
   * Generate comprehensive assessment insights from normalized data
   * Replaces the massive JSONB enriched_data structure
   */
  const generateNormalizedInsights = async (competencyStats, framework = 'core') => {
    try {
      loading.value = true

      // Extract competency areas from stats
      const competencyAreas = competencyStats.map(stat => stat.area)
      
      // Get all relevant data in parallel for better performance
      const [
        competencyNames,
        skillTags,
        learningResources
      ] = await Promise.all([
        getCompetencyDisplayNames(framework),
        getSkillTags(competencyAreas, framework),
        getLearningResources(competencyAreas, framework)
      ])

      // Process weak areas (areas needing improvement)
      const weakAreas = []
      const strengthAreas = []

      for (const stat of competencyStats) {
        const displayName = competencyNames.find(c => c.internal_name === stat.area)?.display_name || stat.area
        
        if (stat.percentage < 70) {
          // Get relevant skill tags for this competency
          const relevantSkills = skillTags.filter(skill => skill.competency_area === stat.area)
          const skillIds = relevantSkills.map(skill => skill.id)

          // Get insights and actions for these skills
          const [insights, actions] = await Promise.all([
            getInsightsForSkills(skillIds, 'weakness'),
            getActionsForSkills(skillIds, 'practice')
          ])

          weakAreas.push({
            area: stat.area,
            displayName,
            percentage: stat.percentage,
            total: stat.total,
            correct: stat.correct,
            insights: insights.map(i => i.insight_text),
            actions: actions.slice(0, 3).map(a => a.action_text), // Top 3 actions
            skillTags: relevantSkills.map(s => s.name)
          })
        } else if (stat.percentage >= 80) {
          strengthAreas.push({
            area: stat.area,
            displayName,
            percentage: stat.percentage,
            total: stat.total,
            correct: stat.correct,
            message: `You demonstrate strong ${displayName.toLowerCase()} skills, helping clients achieve breakthrough insights.`
          })
        }
      }

      // Generate compact normalized insights structure
      const normalizedInsights = {
        framework,
        smart_insights: {
          strengths: strengthAreas,
          weakAreas: weakAreas
        },
        learning_resources: learningResources.slice(0, 5), // Top 5 resources
        competency_stats: competencyStats.map(stat => ({
          area: stat.area,
          displayName: competencyNames.find(c => c.internal_name === stat.area)?.display_name || stat.area,
          percentage: stat.percentage,
          total: stat.total,
          correct: stat.correct
        })),
        // Metadata for debugging/optimization
        data_source: 'normalized_tables',
        generated_at: new Date().toISOString()
      }

      return normalizedInsights

    } catch (err) {
      error.value = err.message
      console.error('Error generating normalized insights:', err)
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Compare normalized vs JSONB data sizes
   */
  const getDataSizeComparison = (normalizedData, jsonbData) => {
    const normalizedSize = JSON.stringify(normalizedData).length
    const jsonbSize = JSON.stringify(jsonbData).length
    
    return {
      normalized_bytes: normalizedSize,
      jsonb_bytes: jsonbSize,
      size_reduction: Math.round((1 - normalizedSize / jsonbSize) * 100),
      normalized_kb: Math.round(normalizedSize / 1024 * 100) / 100,
      jsonb_kb: Math.round(jsonbSize / 1024 * 100) / 100
    }
  }

  return {
    loading: computed(() => loading.value),
    error: computed(() => error.value),
    
    // Individual query methods
    getCompetencyDisplayNames,
    getSkillTags,
    getInsightsForSkills,
    getActionsForSkills,
    getLearningResources,
    
    // Main insight generation
    generateNormalizedInsights,
    
    // Utility methods
    getDataSizeComparison
  }
}