// Tiered Resource Recommendation System
// Maps assessment results to personalized learning resources based on 3-tier scoring system

import { ref, computed } from 'vue'
import { useSupabase } from './useSupabase.js'

const { supabase } = useSupabase()

export function useTieredResources() {
  // Reactive state
  const recommendations = ref([])
  const loading = ref(false)
  const error = ref(null)

  // Scoring tiers configuration
  const SCORING_TIERS = {
    weakness: { min: 0, max: 49, code: 'weakness', name: 'Needs Development', priority: 1 },
    developing: { min: 50, max: 69, code: 'developing', name: 'Developing', priority: 2 },
    strength: { min: 70, max: 100, code: 'strength', name: 'Strength', priority: 3 }
  }

  // Determine tier based on score
  const getTierForScore = (score) => {
    if (score >= 70) return SCORING_TIERS.strength
    if (score >= 50) return SCORING_TIERS.developing
    return SCORING_TIERS.weakness
  }

  // Map competency names to learning path categories
  const COMPETENCY_MAPPING = {
    // Core I Competencies (Beginner)
    'Active Listening': ['Communication & Questioning'],
    'Powerful Questions': ['Communication & Questioning'], 
    'Present Moment Awareness': ['Presence & Awareness'],
    
    // Core II Competencies (Intermediate) 
    'Advanced Active Listening': ['Somatic & Multi-Layered Listening'],
    'Strategic Powerful Questions': ['Belief Systems & Deep Inquiry'], 
    'Creating Awareness': ['Shadow Work & Self-Role Recognition'],
    'Trust & Psychological Safety': ['Vulnerability & Trauma-Informed Coaching'],
    'Direct Communication': ['Crucial Conversations & Feedback Mastery']
  }

  // Generate category-based tiered resource recommendations  
  const generateRecommendations = async (userId, assessmentId, attemptId = null) => {
    loading.value = true
    error.value = null
    
    try {
      console.log('🎯 Generating category-based tiered resource recommendations...')
      
      let finalAttemptId = attemptId
      
      // 1. If no attemptId provided, get the most recent assessment attempt
      if (!finalAttemptId) {
        const { data: attemptData, error: attemptError } = await supabase
          .from('user_assessment_attempts')
          .select('id')
          .eq('user_id', userId)
          .eq('assessment_id', assessmentId)
          .eq('status', 'completed')
          .order('completed_at', { ascending: false })
          .limit(1)
          .single()
        
        if (attemptError) throw attemptError
        finalAttemptId = attemptData.id
      }
      
      console.log('📋 Using attempt:', finalAttemptId)
      
      // 2. Get question responses with competency information  
      const { data: responses, error: responsesError } = await supabase
        .from('user_question_responses')
        .select(`
          *,
          assessment_questions!inner(
            competency_id,
            competency_display_names(display_name)
          )
        `)
        .eq('attempt_id', finalAttemptId)
      
      if (responsesError) throw responsesError
      
      console.log('📊 Got responses:', responses?.length || 0)
      
      // 3. Calculate competency performance from responses
      const competencyStats = {}
      responses.forEach(response => {
        const competencyName = response.assessment_questions?.competency_display_names?.display_name
        if (!competencyName) return
        
        if (!competencyStats[competencyName]) {
          competencyStats[competencyName] = { correct: 0, total: 0 }
        }
        
        competencyStats[competencyName].total++
        if (response.is_correct) {
          competencyStats[competencyName].correct++
        }
      })
      
      // 4. Convert to competency data format
      const competencyData = Object.entries(competencyStats).map(([name, stats]) => ({
        competency_name: name,
        competency_score: Math.round((stats.correct / stats.total) * 100)
      }))
      
      console.log('📊 Calculated competency scores:', competencyData)
      
      // 5. If no competency data, fall back to overall assessment score
      if (!competencyData || competencyData.length === 0) {
        console.log('⚠️ No competency data found, using overall assessment approach')
        return await generateGeneralRecommendations(userId, assessmentId)
      }
      
      // 6. NEW: Group competencies by learning path category AND tier
      const categoryRecommendations = await generateCategoryBasedRecommendations(competencyData)
      
      recommendations.value = categoryRecommendations
      console.log('✅ Category-based tiered recommendations generated:', categoryRecommendations)
      
      return categoryRecommendations
      
    } catch (err) {
      console.error('Error generating recommendations:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // NEW: Generate category-based recommendations (category-first approach)
  const generateCategoryBasedRecommendations = async (competencyData) => {
    try {
      console.log('📚 Generating category-based recommendations...')
      
      // Get all learning path categories
      const { data: categories, error: categoriesError } = await supabase
        .from('learning_path_categories')
        .select('*')
        .order('category_title')
      
      if (categoriesError) throw categoriesError
      
      const categoryRecommendations = []
      
      // For each category, find relevant competencies and get appropriate tier resources
      for (const category of categories) {
        const relevantCompetencies = []
        
        // Find which competencies map to this category
        competencyData.forEach(comp => {
          const mappedCategories = COMPETENCY_MAPPING[comp.competency_name] || []
          console.log(`🔍 Checking competency "${comp.competency_name}" (${comp.competency_score}%) for category "${category.category_title}"`)
          console.log(`🔍 Mapped categories:`, mappedCategories)
          
          if (mappedCategories.includes(category.category_title)) {
            const tier = getTierForScore(comp.competency_score)
            console.log(`✅ Match! Tier:`, tier)
            relevantCompetencies.push({
              competency: comp.competency_name,
              score: comp.competency_score,
              tier: tier
            })
          }
        })
        
        // If this category has relevant competencies, get resources
        console.log(`📊 Category "${category.category_title}" has ${relevantCompetencies.length} relevant competencies:`, relevantCompetencies)
        
        if (relevantCompetencies.length > 0) {
          // Determine the priority tier (worst performance gets priority)
          // Start with the first competency's tier, then find the worst
          let priorityTier = relevantCompetencies[0].tier
          
          for (const comp of relevantCompetencies) {
            console.log(`🔍 Checking comp.tier:`, comp.tier)
            if (comp.tier && comp.tier.priority < priorityTier.priority) {
              priorityTier = comp.tier
            }
          }
          
          console.log(`📖 Category "${category.category_title}" - Priority tier:`, priorityTier)
          console.log(`📖 Priority tier code: "${priorityTier?.code}", category ID: "${category.id}"`)
          
          // Validate we have a valid tier before proceeding
          if (!priorityTier || !priorityTier.code) {
            console.error(`❌ Invalid priority tier for category ${category.category_title}:`, priorityTier)
            continue
          }
          
          // Get resources for this category at the appropriate tier
          const categoryResources = await getResourcesForCategory(category.id, priorityTier.code)
          
          if (categoryResources.length > 0) {
            categoryRecommendations.push({
              title: category.category_title,
              description: category.category_description,
              icon: getCategoryIcon(category.category_title),
              category: category,
              tier: priorityTier,
              competencies: relevantCompetencies,
              resources: categoryResources,
              message: getCategoryMessage(priorityTier.code, category.category_title)
            })
          }
        }
      }
      
      // Sort by tier priority first (weaknesses first), then by lowest competency score within tier
      categoryRecommendations.sort((a, b) => {
        // Primary sort: by tier priority (weakness=1, developing=2, strength=3)
        if (a.tier.priority !== b.tier.priority) {
          return a.tier.priority - b.tier.priority
        }
        
        // Secondary sort: within same tier, lowest scores first
        const aLowestScore = Math.min(...a.competencies.map(c => c.score))
        const bLowestScore = Math.min(...b.competencies.map(c => c.score))
        return aLowestScore - bLowestScore
      })
      
      console.log(`✅ Generated ${categoryRecommendations.length} category-based recommendations`)
      return categoryRecommendations
      
    } catch (error) {
      console.error('Error generating category-based recommendations:', error)
      return []
    }
  }
  
  // Get resources for a specific category and tier
  const getResourcesForCategory = async (categoryId, tierCode) => {
    try {
      console.log(`🔍 getResourcesForCategory called with categoryId: "${categoryId}", tierCode: "${tierCode}"`)
      
      // Validate inputs
      if (!categoryId || !tierCode) {
        console.error('❌ Invalid parameters:', { categoryId, tierCode })
        return []
      }
      
      // Get the analysis_type_id for this tier code
      const { data: analysisType, error: analysisError } = await supabase
        .from('analysis_types')
        .select('id')
        .eq('code', tierCode)
        .maybeSingle() // Use maybeSingle to handle 0 results gracefully
      
      if (analysisError) {
        console.error('❌ Analysis type query error:', analysisError)
        throw analysisError
      }
      
      if (!analysisType) {
        console.error(`❌ No analysis type found for code: "${tierCode}"`)
        return []
      }
      
      // Get resources for this category at the appropriate tier
      const { data: resources, error: resourceError } = await supabase
        .from('learning_resources')
        .select(`
          *,
          learning_path_categories(category_title, category_description),
          resource_types(id, code, name)
        `)
        .eq('category_id', categoryId)
        .eq('analysis_type_id', analysisType.id)
        .eq('is_active', true)
        .limit(5)
      
      if (resourceError) throw resourceError
      
      console.log(`📚 Found ${resources?.length || 0} resources for category ${categoryId} at ${tierCode} tier`)
      return resources || []
      
    } catch (error) {
      console.error(`Error fetching resources for category ${categoryId}:`, error)
      return []
    }
  }
  
  // Get appropriate icon for learning path category
  const getCategoryIcon = (categoryTitle) => {
    const icons = {
      // Core I Categories
      'Communication & Questioning': '🗣️',
      'Presence & Awareness': '🧘',
      'Coaching Relationship': '🤝',
      'Effective Communication': '💬',
      'Facilitates Learning': '🎓',
      
      // Core II Categories  
      'Somatic & Multi-Layered Listening': '👂',
      'Belief Systems & Deep Inquiry': '❓',
      'Shadow Work & Self-Role Recognition': '💡',
      'Vulnerability & Trauma-Informed Coaching': '🛡️',
      'Crucial Conversations & Feedback Mastery': '💬',
      
      'Default': '📚'
    }
    return icons[categoryTitle] || icons['Default']
  }
  
  // Get contextual message for category and tier
  const getCategoryMessage = (tierCode, categoryTitle) => {
    const messages = {
      weakness: `Build strong foundations in ${categoryTitle} with these essential resources`,
      developing: `Enhance your growing ${categoryTitle} skills with targeted practice`,
      strength: `Leverage your ${categoryTitle} expertise with advanced techniques`
    }
    return messages[tierCode] || `Develop your ${categoryTitle} capabilities`
  }


  // Get resources for specific competencies and tier
  const getResourcesForCompetencies = async (competencies, tierCode) => {
    try {
      // Find relevant learning path categories
      const relevantCategories = []
      competencies.forEach(competency => {
        const categories = COMPETENCY_MAPPING[competency] || []
        relevantCategories.push(...categories)
      })
      
      // Remove duplicates
      const uniqueCategories = [...new Set(relevantCategories)]
      
      console.log(`🔍 Finding resources for competencies: ${competencies.join(', ')} (${tierCode} tier)`)
      console.log('📚 Relevant categories:', uniqueCategories)
      
      // If no specific categories found, get general resources for this tier
      if (uniqueCategories.length === 0) {
        console.log(`⚠️ No specific categories found for ${tierCode} tier, getting general resources`)
        
        // Get the analysis_type_id for this tier code
        const { data: analysisType, error: analysisError } = await supabase
          .from('analysis_types')
          .select('id')
          .eq('code', tierCode)
          .single()
        
        if (analysisError) throw analysisError
        
        const { data: resources, error: resourceError } = await supabase
          .from('learning_resources')
          .select(`
            *,
            learning_path_categories(category_title, category_description),
            resource_types(id, code, name)
          `)
          .eq('analysis_type_id', analysisType.id)
          .eq('is_active', true)
          .limit(3) // Fewer resources when getting general ones
        
        if (resourceError) throw resourceError
        console.log(`📖 Found ${resources?.length || 0} general resources for ${tierCode} tier`)
        return resources || []
      }
      
      // Get the analysis_type_id for this tier code first
      const { data: analysisType, error: analysisError } = await supabase
        .from('analysis_types')
        .select('id')
        .eq('code', tierCode)
        .single()
      
      if (analysisError) throw analysisError
      
      // Get resources for this specific tier using the analysis_type_id FK
      const { data: resources, error: resourceError } = await supabase
        .from('learning_resources')
        .select(`
          *,
          learning_path_categories!inner(category_title, category_description),
          resource_types(id, code, name)
        `)
        .in('learning_path_categories.category_title', uniqueCategories)
        .eq('analysis_type_id', analysisType.id)
        .eq('is_active', true)
        .limit(5)
      
      if (resourceError) throw resourceError
      
      console.log(`📖 Found ${resources?.length || 0} resources for ${tierCode} tier`)
      return resources || []
      
    } catch (err) {
      console.error(`Error fetching resources for tier ${tierCode}:`, err)
      // Return empty array instead of throwing to prevent component crash
      return []
    }
  }

  // Fallback: Generate general recommendations based on overall assessment score
  const generateGeneralRecommendations = async (userId, assessmentId) => {
    try {
      // Get overall assessment score
      const { data: attemptData, error: attemptError } = await supabase
        .from('user_assessment_attempts')
        .select('score')
        .eq('user_id', userId)
        .eq('assessment_id', assessmentId)
        .eq('status', 'completed')
        .order('completed_at', { ascending: false })
        .limit(1)
        .single()
      
      if (attemptError) throw attemptError
      
      const overallScore = attemptData.score
      const tier = getTierForScore(overallScore)
      
      console.log(`📊 Overall assessment score: ${overallScore}% (${tier.name} tier)`)
      
      // Get general resources for this tier level
      const { data: resources, error: resourceError } = await supabase
        .from('learning_resources')
        .select(`
          *,
          learning_path_categories(category_title, category_description)
        `)
        .eq('is_active', true)
        .limit(8) // More resources for general recommendations
      
      if (resourceError) throw resourceError
      
      recommendations.value = [{
        tier: tier,
        competencies: [{ competency: 'Overall Coaching Skills', score: overallScore, tier: tier }],
        resources: resources || [],
        message: `Based on your ${overallScore}% overall score`
      }]
      
      return recommendations.value
      
    } catch (err) {
      console.error('Error generating general recommendations:', err)
      throw err
    }
  }

  return {
    // State
    recommendations,
    loading,
    error,
    
    // Methods
    generateRecommendations,
    getTierForScore,
    
    // Constants
    SCORING_TIERS
  }
}