import { computed, ref } from 'vue'
import { useSupabase } from './useSupabase.js'
import { getUserFriendlyError, formatErrorForUI } from './useUserFriendlyErrors.js'

// GLOBAL cache outside the function - shared across ALL component instances
const globalStaticDataCache = ref({
  skillTags: {},
  tagInsights: {},
  tagActions: {},
  competencyDisplayNames: {},
  isLoaded: false,
  lastLoadTime: null,
  framework: null
})

// GLOBAL loading promise - prevents multiple concurrent loads
let globalCacheLoadingPromise = null

// Expose cache refresh to window for debugging/testing
if (typeof window !== 'undefined') {
  window.refreshAssessmentCache = () => {
    console.log('🔄 Manually refreshing assessment cache...')
    Object.assign(globalStaticDataCache.value, {
      isLoaded: false,
      lastLoadTime: null
    })
    // Clear the global promise to allow fresh load
    globalCacheLoadingPromise = null
    console.log('✅ Cache and promise cleared. Will reload on next use.')
    return 'Cache cleared - refresh the page to reload from database'
  }
  
  window.viewAssessmentCache = () => {
    return {
      isLoaded: globalStaticDataCache.value.isLoaded,
      lastLoadTime: globalStaticDataCache.value.lastLoadTime,
      framework: globalStaticDataCache.value.framework,
      competencyDisplayNames: globalStaticDataCache.value.competencyDisplayNames,
      skillTagsCount: Object.keys(globalStaticDataCache.value.skillTags).length,
      sampleSkillTags: Object.entries(globalStaticDataCache.value.skillTags).slice(0, 2)
    }
  }
}

/**
 * Assessment Insights Composable
 * Provides intelligent insights and actionable recommendations based on assessment results
 * Supports multiple assessment frameworks and competency types
 * Now uses database-cached static data instead of hardcoded arrays
 */
export function useAssessmentInsights(competencyStats, assessmentFramework = 'core') {
  
  // Use the global cache instead of local
  const staticDataCache = globalStaticDataCache

  /**
   * Load all static reference data from database into memory cache
   * @param {boolean} forceRefresh - Force reload even if already loaded
   */
  const loadStaticDataCache = async (forceRefresh = false) => {
    // Check if we need to reload due to framework change
    const frameworkValue = assessmentFramework?.value || assessmentFramework || 'core'
    const frameworkChanged = staticDataCache.value.framework && 
                            staticDataCache.value.framework !== frameworkValue
    
    if (staticDataCache.value.isLoaded && !forceRefresh && !frameworkChanged) {
      console.log('✅ Database cache already loaded for', assessmentFramework, ', skipping reload')
      return // Already loaded
    }
    
    if (forceRefresh) {
      console.log('🔄 FORCE REFRESHING database cache...')
    } else if (frameworkChanged) {
      console.log('🔄 Framework changed from', staticDataCache.value.framework, 'to', assessmentFramework, '- reloading cache')
    }
    
    // Reset cache for new load
    Object.assign(staticDataCache.value, {
      isLoaded: false,
      framework: frameworkValue
    })
    
    try {
      console.log('🔄 STARTING database cache loading process...')
      console.log('📍 Current cache state:', {
        isLoaded: staticDataCache.value.isLoaded,
        skillTagsCount: Object.keys(staticDataCache.value.skillTags).length,
        framework: assessmentFramework
      })
      
      // Get Supabase singleton
      const { supabase } = useSupabase()

      // Load skill tags grouped by competency area
      // Fix reactive object issue - extract actual value from framework
      const frameworkValue = assessmentFramework?.value || assessmentFramework || 'core'
      console.log('🔧 Framework value for database query:', frameworkValue)
      
      const { data: skillTagsData, error: skillError } = await supabase
        .from('skill_tags')
        .select(`
          name,
          competency_display_names!competency_id(display_name),
          frameworks!framework_id(code)
        `)
        .eq('frameworks.code', frameworkValue)
        .eq('is_active', true)
        .order('sort_order')

      if (skillError) throw skillError

      // Group skill tags by competency area
      const skillTagsMap = {}
      skillTagsData.forEach(tag => {
        const competencyArea = tag.competency_display_names?.display_name || 'Unknown'
        if (!skillTagsMap[competencyArea]) {
          skillTagsMap[competencyArea] = []
        }
        skillTagsMap[competencyArea].push(tag.name)
      })
      // Load tag insights with proper FK joins - support multiple levels
      const { data: insightsData, error: insightsError } = await supabase
        .from('tag_insights')
        .select(`
          insight_text,
          analysis_types!analysis_type_id(code),
          assessment_levels!assessment_level_id(level_code),
          skill_tags(
            name,
            frameworks!framework_id(code)
          )
        `)
        // Load insights for both beginner and intermediate levels to support Core II
        .in('assessment_levels.level_code', ['beginner', 'intermediate'])

      if (insightsError) throw insightsError

      // Group insights by tag name and type - filter by framework on frontend
      const insightsMap = {}
      insightsData.forEach(item => {
        // Only include insights for tags matching our framework
        if (item.skill_tags?.frameworks?.code === frameworkValue) {
          const tagName = item.skill_tags.name
          const insightType = item.analysis_types?.code || 'unknown'
          if (!insightsMap[tagName]) insightsMap[tagName] = {}
          insightsMap[tagName][insightType] = item.insight_text
        }
      })

      // Load tag actions with proper FK joins
      const { data: actionsData, error: actionsError } = await supabase
        .from('tag_actions')
        .select(`
          action_text,
          skill_tags(
            name,
            frameworks!framework_id(code)
          )
        `)
        .eq('is_active', true)

      if (actionsError) throw actionsError

      // Group actions by tag name - filter by framework on frontend
      const actionsMap = {}
      actionsData.forEach(item => {
        // Only include actions for tags matching our framework
        if (item.skill_tags?.frameworks?.code === frameworkValue) {
          const tagName = item.skill_tags.name
          actionsMap[tagName] = item.action_text
        }
      })

      // Load competency display names with framework join
      const { data: displayNamesData, error: displayError } = await supabase
        .from('competency_display_names')
        .select(`
          competency_key, 
          display_name,
          frameworks!framework_id(code)
        `)
        .eq('frameworks.code', frameworkValue)
        .eq('is_active', true)

      if (displayError) throw displayError

      // Map competency keys to display names
      const displayNamesMap = {}
      displayNamesData.forEach(item => {
        displayNamesMap[item.competency_key] = item.display_name
      })

      // Update cache using Object.assign for proper reactivity
      Object.assign(staticDataCache.value, {
        skillTags: skillTagsMap,
        tagInsights: insightsMap,
        tagActions: actionsMap,
        competencyDisplayNames: displayNamesMap,
        isLoaded: true,
        lastLoadTime: new Date().toISOString()
      })
      console.log('🎉 DATABASE CACHE SUCCESSFULLY LOADED!', {
        skillTagsAreas: Object.keys(staticDataCache.value.skillTags),
        skillTagsCount: Object.keys(staticDataCache.value.skillTags).length,
        tagInsightsCount: Object.keys(staticDataCache.value.tagInsights).length,
        tagActionsCount: Object.keys(staticDataCache.value.tagActions).length,
        displayNamesCount: Object.keys(staticDataCache.value.competencyDisplayNames).length,
        sampleSkillTags: Object.entries(staticDataCache.value.skillTags).slice(0, 2),
        isLoadedFlag: staticDataCache.value.isLoaded
      })
      
    } catch (error) {
      console.error('❌ CRITICAL ERROR loading static data cache:', error)
      console.log('🚨 NO FALLBACK - Database must be available for assessment insights')
      // NO FALLBACK - Application must fail gracefully but visibly show database issues
      throw new Error(`Database cache loading failed: ${error.message}`)
    }
  }
  
  // ❌ HARDCODED COMPETENCY MAPPINGS REMOVED
  // All competency display names now loaded from database competency_display_names table

  // ⚠️ HARDCODED SKILL TAGS REMOVED - Now using database cache only
  // All skill tags data now loaded from database in loadStaticDataCache()

  // 🚫 ALL HARDCODED DATA STRUCTURES REMOVED
  // =====================================
  // Previously contained massive hardcoded objects:
  // - skillMappings (compact display names)
  // - tagInsights (skill-specific insights)  
  // - tagActionableSteps (skill-specific actions)
  // - competencyInsights (competency-level insights)
  // - actionableSteps (competency-level actions)
  // - strengthMessages (positive feedback messages)
  //
  // 🎯 ALL DATA NOW LOADED FROM DATABASE CACHE ONLY
  // See loadStaticDataCache() function above

  // ❌ HARDCODED COMPETENCY NAME-TO-KEY MAPPING REMOVED
  // Keys are now generated dynamically from competency names

  // Helper functions
  const mapCompetencyToDisplayName = (competency) => {
    console.log('🏷️ mapCompetencyToDisplayName called for:', competency, 'isLoaded:', staticDataCache.value.isLoaded)
    
    // Use database cache if loaded, otherwise show no data message
    if (staticDataCache.value.isLoaded) {
      // Generate competency key dynamically from name
      const competencyKey = competency.toLowerCase().replace(/[^a-z0-9]/g, '_')
      const displayName = staticDataCache.value.competencyDisplayNames[competencyKey]
      
      if (!displayName) {
        console.warn('⚠️ DATABASE MISMATCH: No display name for competency:', competency)
        console.log('🔍 Tried key:', competencyKey)
        console.log('📊 Available keys in database:', Object.keys(staticDataCache.value.competencyDisplayNames))
        console.log('💡 Database must contain competency_display_names entry for key:', competencyKey)
        
        // Return user-friendly error instead of technical message
        const friendlyError = getUserFriendlyError('NO_INSIGHT_FOR_TAG', competency)
        return friendlyError.title
      }
      
      console.log('✅ Successfully mapped', competency, '->', competencyKey, '->', displayName)
      return displayName
    }
    console.error('🚨 Database cache not loaded - mapCompetencyToDisplayName called before cache ready for:', competency)
    const friendlyError = getUserFriendlyError('DB_CACHE_NOT_LOADED')
    return friendlyError.title
  }

  const mapCompetencyToSkill = (competency) => {
    // Use database cache if loaded, otherwise show no data message  
    if (staticDataCache.value.isLoaded) {
      // For now, just return the competency since we don't have skill mappings in DB yet
      return competency
    }
    console.error('🚨 Database cache not loaded - mapCompetencyToSkill called before cache ready for:', competency)
    return '🚨 DB CACHE NOT LOADED'
  }

  const getCompetencyInsights = (competency) => {
    // Use database cache if loaded, otherwise show database issue
    if (staticDataCache.value.isLoaded) {
      // ❌ NO HARDCODED FALLBACK - Must implement competency insights in database
      return ['🚨 DB ERROR: Competency insights table not implemented']
    }
    console.error('🚨 Database cache not loaded - getCompetencyInsights called before cache ready')
    return ['🚨 DB CACHE NOT LOADED']
  }

  const getActionableSteps = (competency) => {
    // Use database cache if loaded, otherwise show database issue
    if (staticDataCache.value.isLoaded) {
      // ❌ NO HARDCODED FALLBACK - Must implement competency actions in database
      return ['🚨 DB ERROR: Competency actions table not implemented']
    }
    console.error('🚨 Database cache not loaded - getActionableSteps called before cache ready')
    return ['🚨 DB CACHE NOT LOADED']
  }

  const getStrengthMessage = (competency, percentage) => {
    // Use database cache if loaded, otherwise show database issue
    if (staticDataCache.value.isLoaded) {
      // ❌ NO HARDCODED FALLBACK - Must implement strength messages in database
      return '🚨 DB ERROR: Strength messages table not implemented'
    }
    console.error('🚨 Database cache not loaded - getStrengthMessage called before cache ready')
    return '🚨 DB CACHE NOT LOADED'
  }

  const getSkillTags = (competency) => {
    console.log('🔍 getSkillTags called for:', competency, 'isLoaded:', staticDataCache.value.isLoaded)
    
    // Ensure cache is loaded first - this is critical for preventing race conditions
    if (!staticDataCache.value.isLoaded) {
      console.warn('⚠️ RACE CONDITION DETECTED: getSkillTags called before cache loaded for:', competency)
      console.log('🔄 Cache is still loading... This is normal during app initialization.')
      console.log('💡 Components should call ensureCacheLoaded() before using getSkillTags')
      // Return empty array during loading to prevent errors - this is expected during init
      return []
    }
    
    // Use database cache if loaded, otherwise show no data message
    if (staticDataCache.value.isLoaded) {
      // Try exact match first
      let tags = staticDataCache.value.skillTags[competency] || []
      
      // If no exact match, try to find partial matches (for Testing123 cases)
      if (tags.length === 0) {
        console.warn('⚠️ DATABASE MISMATCH: No exact match for "' + competency + '"')
        console.log('📊 Available competency areas in database:', Object.keys(staticDataCache.value.skillTags))
        
        // Look for any key that contains the competency name (in either direction)
        for (const [key, value] of Object.entries(staticDataCache.value.skillTags)) {
          // Check if database key contains the competency OR competency contains key
          // This handles cases like "Testing123 Present Moment Awareness" containing "Present Moment Awareness"
          if (key.includes(competency) || competency.includes(key)) {
            console.log('✅ Found partial match:', key, 'for', competency)
            tags = value
            break
          }
          
          // Also check for word-level matches (handles cases with different word ordering)
          const competencyWords = competency.split(' ')
          const keyWords = key.split(' ')
          const commonWords = competencyWords.filter(word => keyWords.includes(word))
          if (commonWords.length >= 2) { // At least 2 words match
            console.log('✅ Found word-level match:', key, 'for', competency, '(common words:', commonWords.join(', ') + ')')
            tags = value
            break
          }
        }
        
        if (tags.length === 0) {
          console.error('❌ DATABASE INTEGRITY ISSUE: Assessment questions use "' + competency + '" but skill_tags table has no matching competency_area')
          console.log('💡 Available database competency areas:', Object.keys(staticDataCache.value.skillTags).join(', '))
          console.log('💡 Assessment competency:', competency)
          console.log('🚨 SKILL TAG SECTION WILL SHOW ERROR - Database mismatch visible on frontend')
        }
      }
      
      console.log('📋 Skill tags result for', competency, ':', tags.length > 0 ? tags : 'NONE FOUND')
      return tags
    }
    // NO FALLBACK - show user-friendly message to detect issues
    console.warn('⚠️ Database cache not loaded yet - getSkillTags for:', competency)
    return [] // Return empty array instead of error message
  }

  const getTagInsight = (tag, insightType = 'weakness') => {
    // Use database cache if loaded, otherwise show no data message
    if (staticDataCache.value.isLoaded) {
      const tagData = staticDataCache.value.tagInsights[tag]
      if (!tagData) {
        console.warn('⚠️ DATABASE MISMATCH: No insights for tag:', tag)
        console.log('📊 Available tags in database:', Object.keys(staticDataCache.value.tagInsights).slice(0, 10))
        console.log('💡 This may indicate tag name mismatch or missing data in tag_insights table')
        
        const friendlyError = getUserFriendlyError('NO_INSIGHT_FOR_TAG', tag)
        return friendlyError.message
      }
      
      // Try to get the requested insight type, fall back to any available insight
      const insight = tagData[insightType] || tagData.weakness || tagData.strength
      if (!insight) {
        console.warn('⚠️ DATABASE MISMATCH: No insight of type', insightType, 'for tag:', tag)
        console.log('📊 Available insight types:', Object.keys(tagData))
        return `🚨 DB ERROR: No ${insightType} insight for ${tag}`
      }
      
      console.log('✅ Found insight for', tag, 'type:', insightType, '- insight starts with:', insight.substring(0, 50) + '...')
      return insight
    }
    // NO FALLBACK - show user-friendly message to detect issues
    console.warn('⚠️ Database cache not loaded yet - getTagInsight for:', tag)
    return `🚨 DB CACHE NOT LOADED`
  }

  const getTagActionableStep = (tag) => {
    // Use database cache if loaded, otherwise show no data message
    if (staticDataCache.value.isLoaded) {
      const action = staticDataCache.value.tagActions[tag]
      if (!action) {
        console.warn('⚠️ DATABASE MISMATCH: No action for tag:', tag)
        console.log('📊 Available tags in database:', Object.keys(staticDataCache.value.tagActions).slice(0, 10))
        console.log('💡 This may indicate tag name mismatch or missing data in tag_actions table')
        
        const friendlyError = getUserFriendlyError('NO_ACTION_FOR_TAG', tag)
        return friendlyError.message
      }
      return action
    }
    // NO FALLBACK - show user-friendly message to detect issues
    console.warn('⚠️ Database cache not loaded yet - getTagActionableStep for:', tag)
    return `🚨 DB CACHE NOT LOADED`
  }

  const getKeyConceptFromQuestion = (question) => {
    const competency = question.competency_area
    if (competency?.includes('Listening')) return 'Reflecting and understanding client emotions'
    if (competency?.includes('Question')) return 'Using open-ended, exploratory questions'
    if (competency?.includes('Awareness')) return 'Helping clients discover insights'
    return 'Core coaching principle'
  }

  const getLessonFromMistake = (question) => {
    const competency = question.competency_area
    if (competency?.includes('Listening')) return 'Focus on what the client is feeling, not just what they\'re saying'
    if (competency?.includes('Question')) return 'Ask "What" and "How" questions to explore deeper'
    if (competency?.includes('Awareness')) return 'Guide clients to their own discoveries rather than giving advice'
    return 'Practice this coaching skill in your next session'
  }

  // Main insights computation
  const getSmartInsights = computed(() => {
    if (!competencyStats.value?.length) return { weakAreas: [], strengths: [] }
    
    const weakAreas = competencyStats.value
      .filter(c => c.percentage < 70)
      .sort((a,b) => a.percentage - b.percentage)
      .map(comp => ({
        ...comp,
        displayName: mapCompetencyToDisplayName(comp.area),
        insights: getCompetencyInsights(comp.area),
        actions: getActionableSteps(comp.area)
      }))
    
    const strengths = competencyStats.value
      .filter(c => c.percentage >= 70)
      .sort((a,b) => b.percentage - a.percentage)
      .map(comp => ({
        ...comp,
        displayName: mapCompetencyToDisplayName(comp.area),
        message: getStrengthMessage(comp.area, comp.percentage)
      }))
    
    return { weakAreas, strengths }
  })

  // Helper function to ensure cache is loaded before use
  const ensureCacheLoaded = async () => {
    if (staticDataCache.value.isLoaded) {
      return true
    }
    
    // If already loading, wait for that promise
    if (globalCacheLoadingPromise) {
      console.log('⏳ Waiting for existing global cache load to complete...')
      try {
        await globalCacheLoadingPromise
        return staticDataCache.value.isLoaded
      } catch (error) {
        console.error('❌ Existing cache load promise failed:', error)
        globalCacheLoadingPromise = null // Reset to allow retry
      }
    }
    
    // Start loading and save the promise globally
    console.log('🔄 Starting global cache load to prevent race conditions...')
    globalCacheLoadingPromise = loadStaticDataCache().catch(error => {
      console.error('❌ Cache load failed:', error.message)
      throw error // Re-throw to allow retry logic
    }).finally(() => {
      // Clear the promise after completion (success or failure)
      const wasLoaded = staticDataCache.value.isLoaded
      globalCacheLoadingPromise = null
      
      if (wasLoaded) {
        console.log('✅ Cache load completed successfully')
      } else {
        console.log('❌ Cache load failed or incomplete - will allow retry')
      }
    })
    
    try {
      await globalCacheLoadingPromise
      
      // Add a small verification delay to ensure cache is truly ready
      if (staticDataCache.value.isLoaded) {
        await new Promise(resolve => setTimeout(resolve, 50)) // 50ms delay
        console.log('✅ Cache verified as loaded with verification delay')
      }
      
      return staticDataCache.value.isLoaded
    } catch (error) {
      console.error('❌ ensureCacheLoaded failed:', error)
      return false
    }
  }

  // Auto-load database cache when composable is first used - but save the promise globally
  if (!globalCacheLoadingPromise && !staticDataCache.value.isLoaded) {
    console.log('🚀 Initiating background cache load on composable initialization...')
    globalCacheLoadingPromise = loadStaticDataCache().catch(error => {
      console.warn('⚠️ Background database cache load failed:', error.message)
      console.log('🚨 Cache will remain empty - all functions will show database error messages')
      // Don't throw - let the page continue to work with error messages
    })
  }

  return {
    // Computed insights
    getSmartInsights,
    
    // Helper functions
    mapCompetencyToDisplayName,
    mapCompetencyToSkill,
    getSkillTags,
    getTagInsight,
    getTagActionableStep,
    getCompetencyInsights,
    getActionableSteps,
    getStrengthMessage,
    getKeyConceptFromQuestion,
    getLessonFromMistake,
    
    // Database management
    loadStaticDataCache,
    ensureCacheLoaded, // Export this to allow pre-loading
    staticDataCache: staticDataCache.value,
    // Force refresh function for testing
    forceRefreshCache: () => loadStaticDataCache(true)
  }
}