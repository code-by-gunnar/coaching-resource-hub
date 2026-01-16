/**
 * Centralized Scoring System Composable
 * Uses new scoring_tiers reference table system
 * Eliminates hardcoded 70% threshold and overlapping ranges
 */
import { useSupabase } from './useSupabase.js'

export function useScoring() {
  const { supabase } = useSupabase()
  
  // Cache for scoring tiers to avoid repeated database queries
  let scoringTiersCache = null
  let cacheLoadPromise = null
  
  /**
   * Load scoring tiers into cache
   * Called automatically on first use
   */
  const loadScoringTiers = async () => {
    if (cacheLoadPromise) {
      return cacheLoadPromise
    }
    
    cacheLoadPromise = (async () => {
      try {
        console.log('🎯 Loading scoring tiers from database...')
        
        const { data, error } = await supabase
          .from('scoring_tiers')
          .select('*')
          .eq('is_active', true)
          .order('display_order')
        
        if (error) {
          console.error('Error loading scoring tiers:', error)
          throw error
        }
        
        scoringTiersCache = data
        console.log(`✅ Loaded ${data.length} scoring tiers:`, data.map(t => `${t.tier_name} (${t.score_min}-${t.score_max}%)`))
        return data
        
      } catch (error) {
        console.error('Failed to load scoring tiers:', error)
        // Return fallback hardcoded tiers to prevent app crashes
        scoringTiersCache = getFallbackScoringTiers()
        return scoringTiersCache
      }
    })()
    
    return cacheLoadPromise
  }
  
  /**
   * Fallback scoring tiers if database is unavailable
   * Matches the standardized 6-tier system
   */
  const getFallbackScoringTiers = () => {
    console.warn('🚨 Using fallback scoring tiers - database unavailable')
    return [
      { tier_code: 'critical', tier_name: 'Critical Failure', score_min: 0, score_max: 20, display_order: 1, is_weakness: true },
      { tier_code: 'poor', tier_name: 'Poor Performance', score_min: 21, score_max: 40, display_order: 2, is_weakness: true },
      { tier_code: 'below_average', tier_name: 'Below Average', score_min: 41, score_max: 60, display_order: 3, is_weakness: true },
      { tier_code: 'developing', tier_name: 'Developing', score_min: 61, score_max: 69, display_order: 4, is_weakness: true },
      { tier_code: 'good', tier_name: 'Good Performance', score_min: 70, score_max: 89, display_order: 5, is_weakness: false },
      { tier_code: 'excellent', tier_name: 'Excellent', score_min: 90, score_max: 100, display_order: 6, is_weakness: false }
    ]
  }
  
  /**
   * Get scoring tier for a specific percentage
   * Replaces hardcoded 70% threshold logic
   */
  const getScoringTier = async (percentage, frameworkCode = null, assessmentLevelCode = null) => {
    try {
      if (!scoringTiersCache) {
        await loadScoringTiers()
      }
      
      // First check for framework-specific overrides (future feature)
      if (frameworkCode && assessmentLevelCode) {
        try {
          const { data: override, error } = await supabase
            .rpc('get_scoring_tier', {
              score_percentage: percentage,
              framework_code: frameworkCode,
              assessment_level_code: assessmentLevelCode
            })
          
          if (!error && override && override.length > 0) {
            console.log(`🎯 Using framework override for ${frameworkCode} ${assessmentLevelCode}: ${override[0].tier_name}`)
            return override[0]
          }
        } catch (overrideError) {
          console.warn('Framework override lookup failed, using default tiers:', overrideError)
        }
      }
      
      // Use cached scoring tiers  
      const tier = scoringTiersCache.find(t => 
        percentage >= t.score_min && percentage <= t.score_max
      )
      
      if (!tier) {
        console.error(`No scoring tier found for ${percentage}%`)
        // Return developing tier as fallback
        return scoringTiersCache.find(t => t.tier_code === 'developing') || scoringTiersCache[3]
      }
      
      return tier
      
    } catch (error) {
      console.error('Error getting scoring tier:', error)
      // Return fallback based on old 70% threshold
      return {
        tier_code: percentage >= 70 ? 'good' : 'developing',
        tier_name: percentage >= 70 ? 'Good Performance' : 'Developing',
        score_min: percentage >= 70 ? 70 : 61,
        score_max: percentage >= 70 ? 89 : 69,
        is_weakness: percentage < 70
      }
    }
  }
  
  /**
   * Get analysis type for a specific percentage (weakness, developing, strength)
   * Replaces hardcoded binary weakness/strength logic
   */
  const getAnalysisType = async (percentage, frameworkCode = null, assessmentLevelCode = null) => {
    try {
      // Call the database function to get analysis type
      const { data, error } = await supabase
        .rpc('get_analysis_type_for_score', {
          score_percentage: percentage,
          framework_code: frameworkCode,
          assessment_level_code: assessmentLevelCode
        })
      
      if (error) {
        console.error('Error getting analysis type:', error)
        // Fallback to 3-tier logic based on percentage
        if (percentage < 50) return 'weakness'
        if (percentage < 70) return 'developing' 
        return 'strength'
      }
      
      return data || (percentage < 50 ? 'weakness' : percentage < 70 ? 'developing' : 'strength')
    } catch (error) {
      console.error('Error getting analysis type:', error)
      // Fallback to 3-tier logic
      if (percentage < 50) return 'weakness'
      if (percentage < 70) return 'developing'
      return 'strength'
    }
  }

  /**
   * Check if a percentage is considered a weakness (0-49%)
   * Updated for 3-tier system - no longer includes 50-69%
   */
  const isWeaknessScore = async (percentage, frameworkCode = null, assessmentLevelCode = null) => {
    try {
      const analysisType = await getAnalysisType(percentage, frameworkCode, assessmentLevelCode)
      return analysisType === 'weakness'
    } catch (error) {
      console.error('Error checking weakness score:', error)
      // Fallback to 3-tier logic - weakness is now 0-49%
      return percentage < 50
    }
  }

  /**
   * Check if a percentage is considered developing (50-69%)
   * New function for 3-tier system
   */
  const isDevelopingScore = async (percentage, frameworkCode = null, assessmentLevelCode = null) => {
    try {
      const analysisType = await getAnalysisType(percentage, frameworkCode, assessmentLevelCode)
      return analysisType === 'developing'
    } catch (error) {
      console.error('Error checking developing score:', error)
      // Fallback logic
      return percentage >= 50 && percentage < 70
    }
  }

  /**
   * Check if a percentage is considered a strength (70-100%)
   * Updated for 3-tier system
   */
  const isStrengthScore = async (percentage, frameworkCode = null, assessmentLevelCode = null) => {
    try {
      const analysisType = await getAnalysisType(percentage, frameworkCode, assessmentLevelCode)
      return analysisType === 'strength'
    } catch (error) {
      console.error('Error checking strength score:', error)
      // Fallback logic
      return percentage >= 70
    }
  }
  
  /**
   * Get all scoring tiers (useful for UI components)
   */
  const getAllScoringTiers = async () => {
    if (!scoringTiersCache) {
      await loadScoringTiers()
    }
    return scoringTiersCache
  }
  
  /**
   * Get weakness tiers only (scores < 70% in standard system)
   */
  const getWeaknessTiers = async () => {
    const tiers = await getAllScoringTiers()
    return tiers.filter(t => t.is_weakness)
  }
  
  /**
   * Get strength tiers only (scores >= 70% in standard system) 
   */
  const getStrengthTiers = async () => {
    const tiers = await getAllScoringTiers()
    return tiers.filter(t => !t.is_weakness)
  }
  
  /**
   * Get strategic actions for a specific score using new tier system
   * Replaces old overlapping range queries
   */
  const getStrategicActionsForScore = async (percentage, competencyId, frameworkId, assessmentLevelId) => {
    try {
      const tier = await getScoringTier(percentage)
      
      const { data, error } = await supabase
        .from('strategic_actions_by_tier')
        .select('*')
        .eq('tier_code', tier.tier_code)
        .eq('competency_id', competencyId)
        .eq('framework_id', frameworkId)
        .eq('assessment_level_id', assessmentLevelId)
        .order('priority_order')
      
      if (error) {
        console.error('Error fetching strategic actions:', error)
        return []
      }
      
      console.log(`✅ Found ${data.length} strategic actions for ${tier.tier_name} (${percentage}%)`)
      return data.map(action => action.action_text)
      
    } catch (error) {
      console.error('Error getting strategic actions for score:', error)
      return [`Strategic actions not available for ${percentage}% performance`]
    }
  }
  
  /**
   * Get rich insights for a specific score using new tier system
   */
  const getRichInsightsForScore = async (percentage, competencyId, frameworkId, assessmentLevelId) => {
    try {
      const tier = await getScoringTier(percentage)
      
      // Only return rich insights for weakness tiers
      if (!tier.is_weakness) {
        return []
      }
      
      const { data, error } = await supabase
        .from('rich_insights_by_tier')
        .select('*')
        .eq('tier_code', tier.tier_code)
        .eq('competency_id', competencyId)
        .eq('framework_id', frameworkId)
        .eq('assessment_level_id', assessmentLevelId)
      
      if (error) {
        console.error('Error fetching rich insights:', error)
        return []
      }
      
      console.log(`✅ Found ${data.length} rich insights for ${tier.tier_name} (${percentage}%)`)
      return data.map(insight => insight.insight_text)
      
    } catch (error) {
      console.error('Error getting rich insights for score:', error)
      return []
    }
  }
  
  /**
   * Get leverage strengths for a specific score using new tier system
   */
  const getLeverageStrengthsForScore = async (percentage, competencyId, frameworkId, assessmentLevelId) => {
    try {
      const tier = await getScoringTier(percentage)
      
      // Only return leverage strengths for strength tiers (70%+)
      if (tier.is_weakness) {
        return []
      }
      
      const { data, error } = await supabase
        .from('leverage_strengths_by_tier')
        .select('*')
        .eq('tier_code', tier.tier_code)
        .eq('competency_id', competencyId)
        .eq('framework_id', frameworkId)
        .eq('assessment_level_id', assessmentLevelId)
        .order('priority_order')
      
      if (error) {
        console.error('Error fetching leverage strengths:', error)
        return []
      }
      
      console.log(`✅ Found ${data.length} leverage strengths for ${tier.tier_name} (${percentage}%)`)
      return data.map(strength => strength.leverage_text)
      
    } catch (error) {
      console.error('Error getting leverage strengths for score:', error)
      return []
    }
  }
  
  /**
   * Format percentage with tier context for display
   */
  const formatScoreWithTier = async (percentage, frameworkCode = null, assessmentLevelCode = null) => {
    try {
      const tier = await getScoringTier(percentage, frameworkCode, assessmentLevelCode)
      return `${percentage}% (${tier.tier_name})`
    } catch (error) {
      console.error('Error formatting score with tier:', error)
      return `${percentage}%`
    }
  }
  
  /**
   * Get tier color for UI components (standardized colors)
   */
  const getTierColor = (tierCode) => {
    const colors = {
      critical: '#dc2626',     // Red-600
      poor: '#ea580c',         // Orange-600  
      below_average: '#d97706', // Amber-600
      developing: '#ca8a04',    // Yellow-600
      good: '#16a34a',         // Green-600
      excellent: '#059669'     // Emerald-600
    }
    return colors[tierCode] || '#6b7280' // Gray-500 fallback
  }
  
  /**
   * Get tier icon for UI components
   */
  const getTierIcon = (tierCode) => {
    const icons = {
      critical: '🚨',
      poor: '⚠️',
      below_average: '📈',
      developing: '🎯',
      good: '✅',
      excellent: '🌟'
    }
    return icons[tierCode] || '📊'
  }
  
  // Pre-load scoring tiers on composable creation
  loadScoringTiers()
  
  return {
    // Core functions
    getScoringTier,
    getAnalysisType,
    isWeaknessScore,
    isDevelopingScore,
    isStrengthScore,
    getAllScoringTiers,
    getWeaknessTiers,
    getStrengthTiers,
    
    // Content queries
    getStrategicActionsForScore,
    getRichInsightsForScore, 
    getLeverageStrengthsForScore,
    
    // UI helpers
    formatScoreWithTier,
    getTierColor,
    getTierIcon,
    
    // Cache management
    loadScoringTiers,
    
    // Legacy compatibility (to ease migration)
    isWeakness: isWeaknessScore, // Alias for existing code
    getPerformanceTier: getScoringTier // Alias for existing code
  }
}