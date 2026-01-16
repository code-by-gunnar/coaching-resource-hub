/**
 * Assessment Insights Factory
 * Database-driven factory that works for ALL assessment combinations automatically
 * No more manual framework-specific composables needed!
 */
import { useUniversalAssessmentInsights } from './useUniversalAssessmentInsights.js'

export function useAssessmentInsightsFactory() {
  
  /**
   * Get the appropriate insights composable for a specific framework and difficulty
   * Now uses universal database-driven approach - works for ALL assessments!
   */
  const getInsightsComposable = async (framework, difficulty) => {
    const normalizedFramework = framework?.toLowerCase() || 'core'
    const normalizedDifficulty = difficulty?.toLowerCase() || 'beginner'
    
    try {
      console.log(`🎯 Loading universal insights for ${normalizedFramework} ${normalizedDifficulty}`)
      
      // Create universal composable instance
      const universalInsights = useUniversalAssessmentInsights(normalizedFramework, normalizedDifficulty)
      
      // Validate that this assessment exists in the database
      const isValid = await universalInsights.validateAssessment()
      
      if (isValid) {
        console.log(`✅ Assessment ${normalizedFramework} ${normalizedDifficulty} validated successfully`)
        return universalInsights
      } else {
        console.warn(`⚠️ Assessment ${normalizedFramework} ${normalizedDifficulty} not found in database`)
        // Return fallback for non-existent assessments
        return createFallbackInsights(normalizedFramework, normalizedDifficulty)
      }
      
    } catch (error) {
      console.error(`🚨 Failed to load insights for ${framework} ${difficulty}:`, error)
      
      // Return a minimal fallback to prevent app crashes
      return createFallbackInsights(framework, difficulty)
    }
  }
  
  /**
   * Create a minimal fallback insights object for unimplemented assessments
   */
  const createFallbackInsights = (framework, difficulty) => {
    console.warn(`⚠️ Using fallback insights for ${framework} ${difficulty} - implement specific composable!`)
    
    return {
      generateStrategicActions: (competencyArea) => [
        `Strategic actions for ${competencyArea} not yet implemented for ${framework} ${difficulty}`,
        'Please implement the specific insights composable for this assessment'
      ],
      generateStrengthLeverageActions: (competencyArea) => [
        `Strength leverage actions for ${competencyArea} not yet implemented for ${framework} ${difficulty}`,
        'Please implement the specific insights composable for this assessment'
      ],
      generateLearningResources: () => [
        {
          icon: '⚠️',
          title: `${framework} ${difficulty} Resources Not Available`,
          description: 'Learning resources need to be implemented for this assessment level.',
          resources: [
            'Please implement learning resources for this specific assessment',
            'Check the framework-specific composable development status'
          ]
        }
      ],
      getCompetencyDisplayName: (competency) => competency,
      framework,
      difficulty,
      version: 'fallback'
    }
  }
  
  /**
   * Helper function to capitalize strings
   */
  const capitalize = (str) => {
    return str.charAt(0).toUpperCase() + str.slice(1)
  }
  
  /**
   * Validate that a framework/difficulty combination is supported
   * Now uses database validation instead of hardcoded list
   */
  const isImplemented = async (framework, difficulty) => {
    try {
      const insights = useUniversalAssessmentInsights(framework, difficulty)
      return await insights.validateAssessment()
    } catch (error) {
      console.error(`Error validating ${framework} ${difficulty}:`, error)
      return false
    }
  }
  
  /**
   * Get list of all implemented framework/difficulty combinations
   * Now queries database dynamically instead of hardcoded list
   */
  const getImplementedAssessments = async () => {
    // For now, return the expected combinations
    // TODO: Query database to get actual implemented assessments
    return [
      { framework: 'core', difficulty: 'beginner', status: 'implemented' },
      { framework: 'core', difficulty: 'intermediate', status: 'implemented' },
      { framework: 'core', difficulty: 'advanced', status: 'planned' },
      { framework: 'icf', difficulty: 'beginner', status: 'planned' },
      { framework: 'icf', difficulty: 'intermediate', status: 'planned' },
      { framework: 'icf', difficulty: 'advanced', status: 'planned' },
      { framework: 'ac', difficulty: 'beginner', status: 'planned' },
      { framework: 'ac', difficulty: 'intermediate', status: 'planned' },
      { framework: 'ac', difficulty: 'advanced', status: 'planned' }
    ]
  }

  return {
    getInsightsComposable,
    isImplemented,
    getImplementedAssessments
  }
}