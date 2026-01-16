import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

// CORS headers - support both dev and production
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

// Generate COMPLETE insights from normalized database tables (like frontend does)
async function generateFreshInsightsFromDatabase(competency_stats: any[], framework: string = 'core') {
  console.log('🔍 PDF: Generating COMPLETE insights from database for competencies:', competency_stats.map(c => `${c.area}: ${c.percentage}%`))
  
  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || Deno.env.get('SUPABASE_ANON_KEY')
  
  if (!supabaseUrl || !serviceRoleKey) {
    console.error('❌ PDF: Missing Supabase credentials for database queries')
    return { weakAreas: [], strengths: [], competencyAnalysis: [] }
  }
  
  // Get framework and analysis type IDs first
  const frameworkResponse = await fetch(`${supabaseUrl}/rest/v1/frameworks?code=eq.${framework}&select=id`, {
    headers: {
      'apikey': serviceRoleKey,
      'Authorization': `Bearer ${serviceRoleKey}`,
      'Content-Type': 'application/json'
    }
  })
  
  if (!frameworkResponse.ok) {
    console.error('❌ PDF: Failed to fetch framework data')
    return { weakAreas: [], strengths: [], competencyAnalysis: [] }
  }
  
  const frameworkData = await frameworkResponse.json()
  if (!frameworkData || frameworkData.length === 0) {
    console.error('❌ PDF: Framework not found:', framework)
    return { weakAreas: [], strengths: [], competencyAnalysis: [] }
  }
  
  const frameworkId = frameworkData[0].id
  
  // Get assessment level ID (beginner)
  const levelResponse = await fetch(`${supabaseUrl}/rest/v1/assessment_levels?framework_id=eq.${frameworkId}&level_code=eq.beginner&select=id`, {
    headers: {
      'apikey': serviceRoleKey,
      'Authorization': `Bearer ${serviceRoleKey}`,
      'Content-Type': 'application/json'
    }
  })
  
  if (!levelResponse.ok) {
    console.error('❌ PDF: Failed to fetch assessment level data')
    return { weakAreas: [], strengths: [], competencyAnalysis: [] }
  }
  
  const levelData = await levelResponse.json()
  if (!levelData || levelData.length === 0) {
    console.error('❌ PDF: Assessment level not found for framework:', framework)
    return { weakAreas: [], strengths: [], competencyAnalysis: [] }
  }
  
  const assessmentLevelId = levelData[0].id
  
  const weakAreas = []
  const strengths = []
  const competencyAnalysis = []
  
  for (const comp of competency_stats) {
    const { area, percentage, correct, total } = comp
    const analysisType = percentage >= 70 ? 'strength' : 'weakness'
    
    try {
      // Get competency ID
      const competencyResponse = await fetch(`${supabaseUrl}/rest/v1/competency_display_names?framework_id=eq.${frameworkId}&display_name=eq.${encodeURIComponent(area)}&select=id`, {
        headers: {
          'apikey': serviceRoleKey,
          'Authorization': `Bearer ${serviceRoleKey}`,
          'Content-Type': 'application/json'
        }
      })
      
      if (!competencyResponse.ok) {
        console.warn(`⚠️ PDF: Failed to fetch competency data for ${area}`)
        continue
      }
      
      const competencyQueryResult = await competencyResponse.json()
      if (!competencyQueryResult || competencyQueryResult.length === 0) {
        console.warn(`⚠️ PDF: Competency not found: ${area}`)
        continue
      }
      
      const competencyId = competencyQueryResult[0].id
      
      // Get analysis type ID
      const analysisTypeResponse = await fetch(`${supabaseUrl}/rest/v1/analysis_types?code=eq.${analysisType}&select=id`, {
        headers: {
          'apikey': serviceRoleKey,
          'Authorization': `Bearer ${serviceRoleKey}`,
          'Content-Type': 'application/json'
        }
      })
      
      if (!analysisTypeResponse.ok) {
        console.warn(`⚠️ PDF: Failed to fetch analysis type data for ${analysisType}`)
        continue
      }
      
      const analysisTypeData = await analysisTypeResponse.json()
      if (!analysisTypeData || analysisTypeData.length === 0) {
        console.warn(`⚠️ PDF: Analysis type not found: ${analysisType}`)
        continue
      }
      
      const analysisTypeId = analysisTypeData[0].id
      
      // 1. Query performance analysis using new comprehensive view
      const assessmentLevel = 'beginner' // TODO: Get from context or parameter
      const analysisResponse = await fetch(`${supabaseUrl}/rest/v1/performance_analysis_with_analysis_type?competency_id=eq.${competencyId}&analysis_type_code=eq.${analysisType}&framework_code=eq.${framework}&assessment_level=eq.${assessmentLevel}&score_min=lte.${percentage}&score_max=gte.${percentage}&is_active=eq.true&order=tier_display_order&limit=1`, {
        headers: {
          'apikey': serviceRoleKey,
          'Authorization': `Bearer ${serviceRoleKey}`,
          'Content-Type': 'application/json'
        }
      })
      
      let analysisText = `${area} needs focused development to improve coaching effectiveness.`
      if (analysisResponse.ok) {
        const analysisData = await analysisResponse.json()
        if (analysisData && analysisData.length > 0) {
          analysisText = analysisData[0].analysis_text
        }
      }
      
      // 2. Query strategic actions using new comprehensive view
      const actionsResponse = await fetch(`${supabaseUrl}/rest/v1/strategic_actions_with_analysis_type?competency_id=eq.${competencyId}&analysis_type_code=eq.${analysisType}&framework_code=eq.${framework}&assessment_level=eq.${assessmentLevel}&score_min=lte.${percentage}&score_max=gte.${percentage}&is_active=eq.true&order=priority_order&limit=5`, {
        headers: {
          'apikey': serviceRoleKey,
          'Authorization': `Bearer ${serviceRoleKey}`,
          'Content-Type': 'application/json'
        }
      })
      
      let strategicActions = [`Focus on developing ${area} skills through targeted practice.`]
      if (actionsResponse.ok) {
        const actionsData = await actionsResponse.json()
        if (actionsData && actionsData.length > 0) {
          strategicActions = actionsData.map(action => action.action_text)
        }
      }
      
      // 3. Query skill tags using FK relationships
      const tagsResponse = await fetch(`${supabaseUrl}/rest/v1/skill_tags?framework_id=eq.${frameworkId}&competency_id=eq.${competencyId}&is_active=eq.true&order=priority_order&limit=5`, {
        headers: {
          'apikey': serviceRoleKey,
          'Authorization': `Bearer ${serviceRoleKey}`,
          'Content-Type': 'application/json'
        }
      })
      
      let skillTags = []
      if (tagsResponse.ok) {
        const tagsData = await tagsResponse.json()
        if (tagsData && tagsData.length > 0) {
          // For each tag, get its insight using FK relationships
          for (const tag of tagsData) {
            const tagInsightResponse = await fetch(`${supabaseUrl}/rest/v1/tag_insights?tag_name=eq.${encodeURIComponent(tag.tag_name)}&analysis_type_id=eq.${analysisTypeId}&is_active=eq.true&limit=1`, {
              headers: {
                'apikey': serviceRoleKey,
                'Authorization': `Bearer ${serviceRoleKey}`,
                'Content-Type': 'application/json'
              }
            })
            
            if (tagInsightResponse.ok) {
              const insightData = await tagInsightResponse.json()
              if (insightData && insightData.length > 0) {
                skillTags.push({
                  tag: tag.tag_name,
                  insight: insightData[0].insight_text,
                  priority: tag.priority_order
                })
              }
            }
          }
        }
      }
      
      // 4. Query leverage strengths using FK relationships if this is a strength
      let leverageActions = []
      if (analysisType === 'strength') {
        const leverageResponse = await fetch(`${supabaseUrl}/rest/v1/leverage_strengths_with_analysis_type?competency_id=eq.${competencyId}&analysis_type_code=eq.strength&framework_code=eq.${framework}&assessment_level=eq.${assessmentLevel}&score_min=lte.${percentage}&score_max=gte.${percentage}&is_active=eq.true&order=priority_order&limit=3`, {
          headers: {
            'apikey': serviceRoleKey,
            'Authorization': `Bearer ${serviceRoleKey}`,
            'Content-Type': 'application/json'
          }
        })
        
        if (leverageResponse.ok) {
          const leverageData = await leverageResponse.json()
          if (leverageData && leverageData.length > 0) {
            leverageActions = leverageData.map(action => action.leverage_text)
          }
        }
      }
      
      // 5. Get rich insights from database for detailed PDF sections
      const richInsights = await generateRichCompetencyInsights(area, percentage, framework)
      
      // Build complete competency analysis object
      const competencyData = {
        area,
        percentage,
        correct,
        total,
        analysisType,
        personalizedInsights: [analysisText],
        strategicActions: strategicActions,
        personalizedActions: analysisType === 'strength' ? leverageActions : strategicActions, // Map for HTML template
        skillTags: skillTags,
        tagInsights: skillTags, // Map for HTML template
        leverageActions: leverageActions,
        // Add rich insights for detailed PDF sections
        richInsights: richInsights
      }
      
      competencyAnalysis.push(competencyData)
      
      // Also build the simplified format for backwards compatibility
      if (analysisType === 'strength') {
        strengths.push({
          area,
          percentage,
          correct,
          total,
          message: analysisText,
          actions: leverageActions
        })
      } else {
        weakAreas.push({
          area,
          percentage,
          correct,
          total,
          insights: [analysisText],
          message: analysisText,
          actions: strategicActions,
          skillTags: skillTags
        })
      }
      
    } catch (error) {
      console.error(`❌ PDF: Error fetching complete insights for ${area}:`, error)
      // Add fallback data with rich insights fallback
      const fallbackRichInsights = await generateRichCompetencyInsights(area, percentage, framework)
      const fallbackData = {
        area,
        percentage,
        correct,
        total,
        analysisType,
        personalizedInsights: [`Focus on developing ${area} skills to improve your coaching effectiveness.`],
        strategicActions: [`Practice ${area} in your next coaching sessions.`],
        personalizedActions: analysisType === 'strength' ? [`Use your ${area} skills to support clients.`] : [`Practice ${area} in your next coaching sessions.`], // Map for HTML template
        skillTags: [],
        tagInsights: [], // Map for HTML template
        leverageActions: analysisType === 'strength' ? [`Use your ${area} skills to support clients.`] : [],
        // Add rich insights even for fallback
        richInsights: fallbackRichInsights
      }
      
      competencyAnalysis.push(fallbackData)
      
      if (analysisType === 'strength') {
        strengths.push({
          area,
          percentage,
          correct,
          total,
          message: `${area} is one of your strongest coaching competencies.`,
          actions: fallbackData.leverageActions
        })
      } else {
        weakAreas.push({
          area,
          percentage,
          correct,
          total,
          insights: [`Focus on developing ${area} skills to improve your coaching effectiveness.`],
          message: `Focus on developing ${area} skills to improve your coaching effectiveness.`,
          actions: fallbackData.strategicActions,
          skillTags: []
        })
      }
    }
  }
  
  console.log('✅ PDF: Generated COMPLETE insights:', {
    strengths: strengths.length,
    weakAreas: weakAreas.length,
    competencyAnalysis: competencyAnalysis.length,
    totalQueries: competencyAnalysis.length * 4 // Performance, Actions, Tags, Leverage
  })
  
  // Sort weak areas by percentage (lowest first) to ensure priority development focus is correct
  weakAreas.sort((a, b) => a.percentage - b.percentage)
  
  // Sort competency analysis by percentage (lowest first) for logical presentation in detailed analysis
  competencyAnalysis.sort((a, b) => a.percentage - b.percentage)
  
  return { 
    weakAreas, 
    strengths, 
    competencyAnalysis // Rich data for detailed PDF sections
  }
}

// Generate learning resources from database just like the frontend does
async function generateLearningResourcesFromDatabase(competency_stats: any[], overallScore: number, framework: string = 'core') {
  console.log('📚 PDF: Generating learning resources from database for score:', overallScore)
  
  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || Deno.env.get('SUPABASE_ANON_KEY')
  
  if (!supabaseUrl || !serviceRoleKey) {
    console.error('❌ PDF: Missing Supabase credentials for learning resources')
    return []
  }
  
  if (!competency_stats?.length) {
    console.log('⚠️ PDF: No competency stats provided')
    return []
  }

  try {
    // Get framework ID first
    const frameworkResponse = await fetch(`${supabaseUrl}/rest/v1/frameworks?code=eq.${framework}&select=id`, {
      headers: {
        'apikey': serviceRoleKey,
        'Authorization': `Bearer ${serviceRoleKey}`,
        'Content-Type': 'application/json'
      }
    })
    
    if (!frameworkResponse.ok) {
      console.error('❌ PDF: Failed to fetch framework data for learning resources')
      return []
    }
    
    const frameworkData = await frameworkResponse.json()
    if (!frameworkData || frameworkData.length === 0) {
      console.error('❌ PDF: Framework not found for learning resources:', framework)
      return []
    }
    
    const frameworkId = frameworkData[0].id
    
    // Get assessment level ID (beginner for now)
    const levelResponse = await fetch(`${supabaseUrl}/rest/v1/assessment_levels?framework_id=eq.${frameworkId}&level_code=eq.beginner&select=id`, {
      headers: {
        'apikey': serviceRoleKey,
        'Authorization': `Bearer ${serviceRoleKey}`,
        'Content-Type': 'application/json'
      }
    })
    
    if (!levelResponse.ok) {
      console.error('❌ PDF: Failed to fetch assessment level for learning resources')
      return []
    }
    
    const levelData = await levelResponse.json()
    if (!levelData || levelData.length === 0) {
      console.error('❌ PDF: Assessment level not found for learning resources')
      return []
    }
    
    const assessmentLevelId = levelData[0].id
    
    // Query learning resources using FK relationships with joins for resource type
    console.log('🔍 PDF: Querying learning_resources table with FK relationships:', {
      frameworkId,
      assessmentLevelId
    })
    
    const resourcesResponse = await fetch(`${supabaseUrl}/rest/v1/learning_resources?framework_id=eq.${frameworkId}&assessment_level_id=eq.${assessmentLevelId}&is_active=eq.true&select=*,resource_types!inner(code,name),learning_resource_competencies(competency_display_names!inner(display_name))&order=title`, {
      headers: {
        'apikey': serviceRoleKey,
        'Authorization': `Bearer ${serviceRoleKey}`,
        'Content-Type': 'application/json'
      }
    })

    if (!resourcesResponse.ok) {
      console.error('❌ PDF: Failed to fetch learning resources:', resourcesResponse.status)
      return []
    }

    const resources = await resourcesResponse.json()
    console.log('📊 PDF: Learning resources query result:', {
      resourcesFound: resources?.length || 0,
      frameworkId,
      assessmentLevelId,
      sampleResources: resources?.slice(0, 2).map((r: any) => ({ 
        title: r.title, 
        resourceType: r.resource_types?.code,
        competencyAreas: r.learning_resource_competencies?.map((lrc: any) => lrc.competency_display_names?.display_name)
      }))
    })

    if (!resources?.length) {
      console.warn('⚠️ PDF: No learning resources found for score:', overallScore)
      return []
    }

    // Group resources by competency area and resource type using FK relationships
    const groupedResources = []
    const lowPerformance = competency_stats.filter(comp => comp.percentage < 70)
    
    // Get weak competency areas for targeted recommendations
    console.log('🏷️ PDF: Mapping competency areas for learning resources:', {
      lowPerformanceAreas: lowPerformance.map(c => c.area)
    })
    
    const weakAreas = lowPerformance.map(c => c.area) // Direct mapping since FK relationship handles this now
    
    console.log('📊 PDF: Final weak areas for resource filtering:', weakAreas)

    // Format resources for display using FK relationship data
    console.log('🔍 PDF: Filtering resources by relevance using FK relationships:', {
      totalResources: resources.length,
      weakAreas,
      sampleResourceCompetencies: resources.slice(0, 3).map((r: any) => ({
        title: r.title,
        competencyAreas: r.learning_resource_competencies?.map((lrc: any) => lrc.competency_display_names?.display_name),
        resourceType: r.resource_types?.code
      }))
    })

    const resourcesByType = resources.reduce((acc: any, resource: any) => {
      // Extract competency areas from junction table relationship
      const resourceCompetencyAreas = resource.learning_resource_competencies?.map((lrc: any) => 
        lrc.competency_display_names?.display_name
      ).filter(Boolean) || []
      
      // Check if this resource matches weak areas or is general (no specific competencies)
      const isRelevant = resourceCompetencyAreas.length === 0 || 
        resourceCompetencyAreas.some((area: string) => weakAreas.includes(area))
      
      console.log('🎯 PDF: Resource relevance check:', {
        title: resource.title,
        resourceCompetencies: resourceCompetencyAreas,
        weakAreas,
        isRelevant
      })
      
      if (isRelevant) {
        const resourceTypeCode = resource.resource_types?.code || 'article'
        if (!acc[resourceTypeCode]) acc[resourceTypeCode] = []
        
        let displayText = resource.title
        if (resource.author_instructor) displayText += ` by ${resource.author_instructor}`
        if (resource.description) displayText += ` - ${resource.description}`
        
        acc[resourceTypeCode].push(displayText)
      }
      return acc
    }, {})

    console.log('📊 PDF: Resources grouped by type:', {
      resourceTypes: Object.keys(resourcesByType),
      totalRelevantResources: Object.values(resourcesByType).flat().length,
      typeBreakdown: Object.entries(resourcesByType).map(([type, items]: [string, any]) => ({
        type,
        count: items.length
      }))
    })

    // Create resource sections (same logic as frontend)
    Object.entries(resourcesByType).forEach(([type, items]: [string, any]) => {
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
      console.warn('⚠️ PDF: No relevant resources found after filtering')
      return []
    }

    console.log('✅ PDF: Generated learning resources:', {
      sections: groupedResources.length,
      totalResources: groupedResources.reduce((sum, section) => sum + section.resources.length, 0)
    })

    return groupedResources

  } catch (error) {
    console.error('❌ PDF: CRITICAL ERROR in generateLearningResourcesFromDatabase:', error)
    return []
  }
}

// Helper functions for resource display (same as frontend)
function getResourceIcon(type: string): string {
  const icons: Record<string, string> = {
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

function getResourceTitle(type: string, score: number): string {
  const typeMap: Record<string, string> = {
    'book': 'Recommended Books',
    'course': 'Training Courses', 
    'video': 'Video Learning',
    'article': 'Essential Reading',
    'exercise': 'Practice Exercises',
    'tool': 'Coaching Tools',
    'workshop': 'Workshops & Events',
    'certification': 'Certifications',
    'assessment': 'Self-Assessments',
    'mentor': 'Mentorship',
    'community': 'Communities',
    'conference': 'Conferences',
    'app': 'Apps & Software'
  }
  
  return typeMap[type] || `${type.charAt(0).toUpperCase() + type.slice(1)} Resources`
}

function getResourceDescription(type: string, score: number): string {
  if (score < 30) return `Fundamental ${type} resources to build your coaching foundation.`
  if (score >= 80) return `Advanced ${type} resources for mastery and specialization.`
  return `Targeted ${type} resources for skill development.`
}

// Color helper functions for resource sections
function getResourceBackgroundColor(index: number): string {
  const colors = ['#e3f2fd', '#fce4ec', '#f3e5f5', '#e8f5e9', '#fff3e0', '#e1f5fe']
  return colors[index % colors.length]
}

function getResourceBorderColor(index: number): string {
  const colors = ['#2196f3', '#e91e63', '#9c27b0', '#4caf50', '#ff9800', '#00bcd4']
  return colors[index % colors.length]
}

function getResourceTextColor(index: number): string {
  const colors = ['#0d47a1', '#880e4f', '#4a148c', '#1b5e20', '#e65100', '#006064']
  return colors[index % colors.length]
}

function getResourceDescriptionColor(index: number): string {
  const colors = ['#1565c0', '#ad1457', '#6a1b9a', '#2e7d32', '#ef6c00', '#0097a7']
  return colors[index % colors.length]
}

function getResourceItemColor(index: number): string {
  const colors = ['#1976d2', '#c2185b', '#7b1fa2', '#388e3c', '#f57c00', '#00acc1']
  return colors[index % colors.length]
}

// Generate HTML content for the PDF matching the exact screenshot design
async function generateAssessmentHTML(assessmentData: any, attemptId: string, userEmail?: string): Promise<string> {
  // Extract data from new lean structure
  const { 
    overall_stats, 
    assessment_framework,
    performance_analysis,
    competency_performance,
    user_email 
  } = assessmentData

  // Create competency stats from the lean structure
  const competency_stats = competency_performance?.map((comp: any) => ({
    area: comp.competency_area,
    percentage: comp.percentage,
    correct: comp.correct,
    total: comp.total
  })) || []
  
  // Generate fresh insights from database - like the frontend does
  const insightsData = await generateFreshInsightsFromDatabase(competency_stats, assessment_framework || 'core')
  const smart_insights = insightsData // Keep backwards compatibility
  const competencyAnalysis = insightsData.competencyAnalysis // Rich data for detailed sections
  
  // Generate learning resources like the frontend does
  console.log('🔍 PDF: About to generate learning resources with score:', overall_stats?.score || 0)
  const learning_resources = await generateLearningResourcesFromDatabase(competency_stats, overall_stats?.score || 0, assessment_framework || 'core')
  console.log('✅ PDF: Learning resources generated:', {
    resourceCount: learning_resources?.length || 0,
    resources: learning_resources?.map(r => ({ title: r.title, resourceCount: r.resources?.length }))
  })

  // Format date
  const completedDate = new Date().toLocaleDateString('en-US', {
    month: 'long',
    day: 'numeric', 
    year: 'numeric'
  })

  // Get duration
  const duration = overall_stats?.time_spent 
    ? `${Math.floor(overall_stats.time_spent / 60)}m ${overall_stats.time_spent % 60}s`
    : '0m 37s'

  // Get performance level
  const getPerformanceLevel = (score: number) => {
    if (score >= 90) return 'Excellent'
    if (score >= 70) return 'Good' 
    if (score >= 50) return 'Developing'
    return 'Needs Improvement'
  }

  // Get learning recommendation (strength or weak area)
  const topStrength = smart_insights?.strengths?.[0]
  const topWeakArea = smart_insights?.weakAreas?.[0]
  
  let strengthTitle, strengthDesc, strengthAction
  
  if (topStrength && topStrength.area) {
    strengthTitle = `Leverage Your ${topStrength.area} Strength`
    strengthDesc = topStrength.message || 'You demonstrate strong capability in this area. This is one of your strongest skills.'
    strengthAction = 'Use your present moment awareness skills to support clients in other areas'
  } else if (topWeakArea && topWeakArea.area) {
    strengthTitle = `Strengthen Your ${topWeakArea.area} Skills`
    strengthDesc = topWeakArea.insight || 'This area needs focused attention and practice to improve your coaching effectiveness.'
    strengthAction = topWeakArea.actions?.[0] || 'Focus on practicing this skill in upcoming sessions'
  } else {
    strengthTitle = 'Continue Your Development'
    strengthDesc = 'Focus on building your foundational coaching competencies through targeted practice.'
    strengthAction = 'Continue developing your coaching competencies through targeted practice and study.'
  }

  // Public URL to logo in Supabase storage (same approach as ForwardFocus)
  const supabaseUrl = Deno.env.get('SUPABASE_URL') || 'https://hfmpacbmbyvnupzgorek.supabase.co'
  const logoUrl = `${supabaseUrl}/storage/v1/object/public/coaching-downloads/assets/logo.png`

  // Create enriched assessment data with competency analysis
  // If original assessmentData has competency_analysis with questionAnalysis data, we need to merge and sort it
  let finalCompetencyAnalysis = competencyAnalysis
  
  if (assessmentData.competency_analysis && Array.isArray(assessmentData.competency_analysis)) {
    // Merge our rich insights with existing questionAnalysis data, sorted by percentage
    const existingAnalysis = assessmentData.competency_analysis
    console.log('🔍 PDF: Original competency_analysis order:', existingAnalysis.map(c => `${c.area}: ${c.percentage}%`))
    
    finalCompetencyAnalysis = competencyAnalysis.map(comp => {
      const existingComp = existingAnalysis.find(existing => existing.area === comp.area)
      return {
        ...comp,
        ...(existingComp?.questionAnalysis && { questionAnalysis: existingComp.questionAnalysis })
      }
    }).sort((a, b) => a.percentage - b.percentage) // Ensure sorted by percentage
    
    console.log('🔍 PDF: Final merged competency_analysis order:', finalCompetencyAnalysis.map(c => `${c.area}: ${c.percentage}%`))
  }
  
  const enrichedAssessmentData = {
    ...assessmentData,
    competency_analysis: finalCompetencyAnalysis, // Add the merged and sorted data
    smart_insights,
    competency_stats,
    learning_resources // Add database learning resources
  }

  return `
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Assessment Performance Report</title>
      <style>
        @page {
          size: A4;
          margin: 20mm;
        }
        
        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }
        
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
          line-height: 1.4;
          color: #333;
          font-size: 13px;
          background: white;
        }
        
        .page {
          page-break-after: always;
          min-height: 100vh;
        }
        
        .page:last-child {
          page-break-after: avoid;
        }
        
        /* Header Section */
        .report-header {
          display: flex;
          align-items: center;
          margin-bottom: 30px;
          padding-bottom: 15px;
          border-bottom: 2px solid #e0e4e7;
        }
        
        .logo {
          width: 40px;
          height: 40px;
          border-radius: 50%;
          margin-right: 15px;
        }
        
        .header-content h1 {
          font-size: 20px;
          font-weight: 600;
          color: #4a90e2;
          margin-bottom: 2px;
        }
        
        .header-content .subtitle {
          font-size: 12px;
          color: #666;
        }
        /* Overall Performance */
        .overall-performance {
          background: #f8fafc;
          padding: 25px;
          border-radius: 8px;
          margin-bottom: 35px;
        }
        
        .overall-performance h2 {
          font-size: 16px;
          font-weight: 600;
          color: #333;
          margin-bottom: 20px;
          margin-top: 0;
        }
        
        .performance-content {
          display: grid;
          grid-template-columns: 200px 1fr;
          gap: 30px;
          align-items: center;
        }
        
        .score-display {
          text-align: center;
        }
        
        .score-number {
          font-size: 64px;
          font-weight: 700;
          color: #4a90e2;
          line-height: 1;
        }
        
        .score-label {
          font-size: 14px;
          color: #666;
          margin-top: 5px;
        }
        
        .performance-stats {
          display: grid;
          grid-template-columns: 1fr 1fr 1fr;
          gap: 15px;
        }
        
        .stat-item {
          text-align: center;
        }
        
        .stat-label {
          font-size: 11px;
          color: #666;
          margin-bottom: 4px;
        }
        
        .stat-value {
          font-size: 16px;
          font-weight: 600;
          color: #333;
        }
        
        /* Competency Performance */
        .competency-performance {
          margin-bottom: 35px;
        }
        
        .competency-performance h2 {
          font-size: 16px;
          font-weight: 600;
          color: #333;
          margin-bottom: 20px;
        }
        
        .competency-item {
          margin-bottom: 25px;
        }
        
        .competency-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 8px;
        }
        
        .competency-name {
          font-size: 14px;
          font-weight: 500;
          color: #333;
        }
        
        .competency-score {
          font-size: 14px;
          font-weight: 600;
          color: #4a90e2;
        }
        
        .progress-bar {
          width: 100%;
          height: 12px;
          background: #f0f2f5;
          border-radius: 6px;
          overflow: hidden;
          margin-bottom: 4px;
        }
        
        .progress-fill {
          height: 100%;
          background: #10b981;
          border-radius: 6px;
        }
        
        .competency-detail {
          font-size: 11px;
          color: #666;
        }
        
        /* Recommended Learning Path */
        .learning-path {
          margin-bottom: 35px;
        }
        
        .learning-path h2 {
          font-size: 16px;
          font-weight: 600;
          color: #333;
          margin-bottom: 20px;
        }
        
        .learning-item {
          display: flex;
          align-items: flex-start;
          padding: 20px;
          background: #f8f9fa;
          border-radius: 8px;
        }
        
        .learning-icon {
          width: 32px;
          height: 32px;
          background: #4a90e2;
          color: white;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          margin-right: 15px;
          font-size: 16px;
          flex-shrink: 0;
        }
        
        .learning-content h3 {
          font-size: 14px;
          font-weight: 600;
          color: #333;
          margin-bottom: 8px;
        }
        
        .learning-description {
          font-size: 13px;
          color: #666;
          line-height: 1.5;
          margin-bottom: 8px;
        }
        
        .learning-action {
          font-size: 12px;
          color: #666;
          font-style: italic;
        }
        
        /* Simple centered generation footer */
        .generation-footer {
          margin-top: 40px;
          padding-top: 20px;
          border-top: 1px solid #e0e4e7;
          text-align: center;
          font-size: 11px;
          color: #666;
        }
        
        /* Remove CSS page footers - PDFShift handles this via API */
        
        /* Print optimizations */
        @media print {
          body {
            -webkit-print-color-adjust: exact;
            print-color-adjust: exact;
          }
          
          .page {
            page-break-inside: avoid;
          }
        }
      </style>
    </head>
    <body>
      <div class="content-wrapper">
        <!-- Header -->
        <div class="report-header">
          <img src="${logoUrl}" alt="Your Coaching Hub Logo" class="logo" />
          <div class="header-content">
            <h1>Assessment Performance Report</h1>
            <div class="subtitle">Professional Coaching Competency Assessment</div>
          </div>
        </div>
        
        <!-- Executive Summary with Integrated Participant Info -->
        <div class="executive-summary" style="background: #f8fafc; padding: 25px; border-radius: 8px; margin-bottom: 35px;">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
            <h2 style="margin: 0; color: #333; font-size: 18px;">Executive Summary</h2>
            <div style="text-align: right; font-size: 12px; color: #666;">
              <div style="margin-bottom: 3px;">${userEmail || user_email || 'Participant'}</div>
              <div>${completedDate}</div>
            </div>
          </div>
          
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
            <div style="text-align: center; padding: 15px; background: white; border-radius: 6px;">
              <div style="font-size: 36px; font-weight: 700; color: #4a90e2; line-height: 1;">${overall_stats?.score || 0}%</div>
              <div style="font-size: 14px; color: #666; margin-top: 5px;">${getPerformanceLevel(overall_stats?.score || 0)} Performance</div>
            </div>
            <div style="padding: 15px; background: white; border-radius: 6px;">
              <div style="font-size: 13px; color: #666; margin-bottom: 8px;"><strong>Assessment:</strong> ${(assessment_framework || 'CORE').toUpperCase()} - ${overall_stats?.assessment_difficulty || 'Fundamentals'}</div>
              <div style="font-size: 13px; color: #666; margin-bottom: 8px;"><strong>Questions:</strong> ${overall_stats?.correct_answers || 0} of ${overall_stats?.total_questions || 0} correct</div>
              <div style="font-size: 13px; color: #666;"><strong>Duration:</strong> ${duration}</div>
            </div>
          </div>
          
          ${topWeakArea ? `
            <div style="background: #fef3c7; padding: 15px; border-radius: 6px; border-left: 4px solid #f59e0b; margin-bottom: 15px;">
              <h3 style="color: #92400e; font-size: 14px; margin-bottom: 8px;">🎯 Priority Development Focus</h3>
              <div style="color: #78350f; font-size: 13px; margin-bottom: 6px;"><strong>${topWeakArea.area}</strong> - ${topWeakArea.percentage || 0}% accuracy</div>
              <div style="color: #92400e; font-size: 12px; line-height: 1.4;">${topWeakArea.insight || 'This area requires immediate attention to improve your coaching effectiveness.'}</div>
            </div>
          ` : ''}
          
          ${topStrength && topStrength.percentage >= 70 ? `
            <div style="background: #f0fdf4; padding: 15px; border-radius: 6px; border-left: 4px solid #10b981; margin-bottom: 15px;">
              <h3 style="color: #065f46; font-size: 14px; margin-bottom: 8px;">💪 Key Strength to Leverage</h3>
              <div style="color: #064e3b; font-size: 13px; margin-bottom: 6px;"><strong>${topStrength.area}</strong> - ${topStrength.percentage || 0}% accuracy</div>
              <div style="color: #065f46; font-size: 12px; line-height: 1.4;">Use this strength as a foundation for developing other competencies and supporting clients.</div>
            </div>
          ` : ''}
          
          <div style="background: #ede9fe; padding: 12px; border-radius: 6px; text-align: center;">
            <div style="color: #5b21b6; font-size: 13px; font-weight: 600;">
              ${overall_stats?.score >= 80 ? 'Ready for advanced practice and specialization' : 
                overall_stats?.score >= 60 ? 'Building solid foundations - continue structured practice' :
                'Focus on fundamentals through study and supervision'}
            </div>
          </div>
          
          <!-- Question Review integrated into Executive Summary -->
          <div style="margin-top: 20px;">
            <h3 style="color: #333; font-size: 16px; margin-bottom: 15px; border-bottom: 1px solid #e0e4e7; padding-bottom: 6px;">Assessment Overview</h3>
            
            <div style="background: white; padding: 15px; border-radius: 6px; margin-bottom: 15px; border-left: 3px solid #667eea;">
              <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 15px; margin-bottom: 12px;">
                <div style="text-align: center;">
                  <div style="font-size: 20px; font-weight: bold; color: #10b981;">${overall_stats?.correct_answers || 0}</div>
                  <div style="font-size: 11px; color: #666;">Questions Correct</div>
                </div>
                <div style="text-align: center;">
                  <div style="font-size: 20px; font-weight: bold; color: #f59e0b;">${(overall_stats?.total_questions || 0) - (overall_stats?.correct_answers || 0)}</div>
                  <div style="font-size: 11px; color: #666;">Questions to Review</div>
                </div>
                <div style="text-align: center;">
                  <div style="font-size: 20px; font-weight: bold; color: #667eea;">${overall_stats?.total_questions || 0}</div>
                  <div style="font-size: 11px; color: #666;">Total Questions</div>
                </div>
              </div>
              <p style="color: #666; font-size: 11px; margin: 0; text-align: center;">
                ${(overall_stats?.total_questions || 0) - (overall_stats?.correct_answers || 0) > 0 
                  ? `Download the Question Analysis Report for detailed study material on the ${(overall_stats?.total_questions || 0) - (overall_stats?.correct_answers || 0)} question${(overall_stats?.total_questions || 0) - (overall_stats?.correct_answers || 0) === 1 ? '' : 's'} to review.`
                  : 'Perfect performance! The Question Analysis Report provides detailed breakdowns for continued learning.'
                }
              </p>
            </div>

            ${(() => {
              // Show competency breakdown
              const competencyBreakdown = competency_stats
                .map(comp => {
                  const incorrectCount = comp.total - comp.correct
                  const status = comp.percentage >= 70 ? 'strength' : 'review'
                  return { ...comp, incorrectCount, status }
                })
                .sort((a, b) => a.percentage - b.percentage) // Show lowest scoring first
              
              if (competencyBreakdown.length > 0) {
                return `
                  <div style="background: white; border: 1px solid #e5e7eb; border-radius: 6px; padding: 15px;">
                    <h4 style="color: #374151; font-size: 14px; margin-bottom: 12px; font-weight: 600;">Competency Review Focus</h4>
                    <div style="display: grid; grid-template-columns: 1fr; gap: 8px;">
                      ${competencyBreakdown.map(comp => `
                        <div style="display: flex; justify-content: space-between; align-items: center; padding: 8px; background: ${comp.status === 'strength' ? '#f0fdf4' : '#fef2f2'}; border-radius: 4px; border-left: 2px solid ${comp.status === 'strength' ? '#10b981' : '#ef4444'};">
                          <div>
                            <div style="font-size: 12px; font-weight: 500; color: #374151; margin-bottom: 1px;">${comp.area}</div>
                            <div style="font-size: 10px; color: #6b7280;">
                              ${comp.incorrectCount === 0 
                                ? 'Perfect performance' 
                                : `${comp.incorrectCount} question${comp.incorrectCount === 1 ? '' : 's'} to review`
                              }
                            </div>
                          </div>
                          <div style="text-align: right;">
                            <div style="font-size: 13px; font-weight: 600; color: ${comp.status === 'strength' ? '#059669' : '#dc2626'};">${comp.percentage}%</div>
                            <div style="font-size: 9px; color: #6b7280;">${comp.correct}/${comp.total}</div>
                          </div>
                        </div>
                      `).join('')}
                    </div>
                  </div>
                `
              }
              return ''
            })()}
          </div>
        </div>

        <!-- Professional Development Insights - Consolidated -->
        <div class="development-insights" style="margin-top: 40px; page-break-before: always;">
          <h2 style="margin-bottom: 30px;">Professional Development Insights</h2>
          <p style="color: #666; font-size: 14px; margin-bottom: 30px; font-style: italic;">
            Based on your assessment results, here are personalized insights to support your coaching career development.
          </p>
          
          ${competencyAnalysis?.map((comp: any, index: number) => `
            <div class="competency-insight" style="margin-bottom: 40px;">
              <h3 style="color: #333; font-size: 18px; margin-bottom: 20px; border-bottom: 2px solid #e0e4e7; padding-bottom: 8px;">
                ${comp.area} - ${comp.percentage}%
              </h3>
              
              ${comp.richInsights ? `
                <!-- CONSOLIDATED: 3 Key Areas Instead of 7-9 Fields -->
                
                <!-- Performance Insight: Assessment Context + Why It Matters -->
                <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
                  <h4 style="color: #2c5aa0; font-size: 15px; margin-bottom: 12px; font-weight: 600;">🎯 Assessment Context & Impact</h4>
                  <div style="color: #444; font-size: 14px; line-height: 1.6;">${comp.richInsights.primaryInsight || comp.richInsights.coachingImpact || 'Based on your assessment results, this competency shows opportunities for professional growth.'}</div>
                </div>
                
                <!-- Development Focus: Professional Growth Beyond Immediate Techniques -->
                <div style="background: #fff3cd; padding: 20px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #ffc107;">
                  <h4 style="color: #856404; font-size: 15px; margin-bottom: 12px; font-weight: 600;">📈 Professional Development Path</h4>
                  <div style="color: #444; font-size: 14px; line-height: 1.6;">${comp.richInsights.developmentFocus || comp.richInsights.growthPathway || 'Focus on building this competency through consistent practice and reflection on your coaching sessions.'}</div>
                </div>
                
                <!-- Practical Application: Career & Business Context -->
                <div style="background: #d1ecf1; padding: 20px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #bee5eb;">
                  <h4 style="color: #0c5460; font-size: 15px; margin-bottom: 12px; font-weight: 600;">💼 Career Application & Impact</h4>
                  <div style="color: #444; font-size: 14px; line-height: 1.6;">${comp.richInsights.practicalApplication || comp.richInsights.practiceRecommendation || 'Apply this competency consistently in your coaching practice to enhance client outcomes and professional effectiveness.'}</div>
                </div>
                
              ` : `
                <!-- Fallback: Basic Professional Development Guidance -->
                <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
                  <h4 style="color: #2c5aa0; font-size: 15px; margin-bottom: 12px; font-weight: 600;">🎯 Development Opportunity</h4>
                  <div style="color: #444; font-size: 14px; line-height: 1.6;">
                    Based on your ${comp.percentage}% performance in ${comp.area}, ${comp.percentage >= 70 ? 'leverage this strength to enhance your coaching effectiveness and build your professional reputation.' : 'focus on developing this foundational competency to improve your overall coaching effectiveness.'}
                  </div>
                </div>
              `}
            </div>
          `).join('') || ''}
        </div>

        <!-- Question Analysis Section -->
        ${(() => {
          // Smart filtering logic for scaling - VERY selective to keep PDF concise
          const questionsToShow = []
          let totalQuestionsShown = 0
          const maxQuestionsToShow = 3 // Reduced from 6 to keep PDF manageable
          
          // First, get all competencies with incorrect questions
          const competenciesWithErrors = enrichedAssessmentData.competency_analysis?.filter((comp: any) => 
            comp.questionAnalysis?.questionsReview?.length > 0
          ) || []
          
          console.log('🔍 PDF: Question Analysis - competencies with errors before sorting:', 
            competenciesWithErrors.map(c => `${c.area}: ${c.percentage}%`))
          
          // Sort by percentage (lowest first - prioritize weakest areas)
          const sortedCompetencies = competenciesWithErrors.sort((a: any, b: any) => 
            (a.percentage || 0) - (b.percentage || 0)
          )
          
          console.log('🔍 PDF: Question Analysis - competencies with errors after sorting:', 
            sortedCompetencies.map(c => `${c.area}: ${c.percentage}%`))
          
          // Build questions to show based on priority
          for (const comp of sortedCompetencies) {
            if (totalQuestionsShown >= maxQuestionsToShow) break
            
            const questionsFromComp = comp.questionAnalysis.questionsReview || []
            let questionsToTake = 0
            
            if (comp.percentage < 50) {
              // Critical gap - show up to 2 questions to keep PDF manageable
              questionsToTake = Math.min(questionsFromComp.length, 2)
            } else if (comp.percentage < 70) {
              // Development area - show 1 key question
              questionsToTake = Math.min(questionsFromComp.length, 1)
            } else {
              // Minor gap - skip to keep PDF concise
              questionsToTake = 0
            }
            
            const remainingSlots = maxQuestionsToShow - totalQuestionsShown
            questionsToTake = Math.min(questionsToTake, remainingSlots)
            
            if (questionsToTake > 0) {
              questionsToShow.push({
                competency: comp,
                questions: questionsFromComp.slice(0, questionsToTake),
                totalQuestions: questionsFromComp.length,
                showingAll: questionsToTake === questionsFromComp.length
              })
              totalQuestionsShown += questionsToTake
            }
          }
          
          // Calculate totals for summary
          const totalIncorrect = competenciesWithErrors.reduce((sum: number, comp: any) => 
            sum + (comp.questionAnalysis?.incorrectCount || 0), 0
          )
          
          if (questionsToShow.length === 0) return ''
          
          return `
            <div class="question-analysis-section" style="margin-top: 40px; margin-bottom: 35px;">
              <h2 style="color: #333; font-size: 18px; margin-bottom: 20px; border-bottom: 2px solid #e0e4e7; padding-bottom: 8px;">Question Analysis & Learning Opportunities</h2>
              
              <div style="background: #fff8e1; padding: 20px; border-radius: 8px; margin-bottom: 25px; border-left: 4px solid #ffa726;">
                <p style="color: #e65100; font-size: 13px; margin-bottom: 8px;"><strong>💡 Learning Focus:</strong> Reviewing ${totalQuestionsShown} of ${totalIncorrect} incorrect responses, prioritizing critical competency gaps.</p>
                <p style="color: #f57c00; font-size: 12px; margin: 0;">Each scenario represents a real coaching situation you may encounter with clients.</p>
              </div>
              
              ${questionsToShow.map((item: any, index: number) => `
                <div style="margin-bottom: 35px; page-break-inside: avoid;">
                  <h3 style="color: #333; font-size: 16px; margin-bottom: 15px; border-left: 4px solid #667eea; padding-left: 12px;">
                    ${item.competency.displayName || item.competency.area} - ${item.showingAll ? '' : `Showing ${item.questions.length} of `}${item.totalQuestions} Question${item.totalQuestions > 1 ? 's' : ''} Missed
                  </h3>
                  
                  ${item.questions.map((q: any, qIndex: number) => `
                  <div style="background: white; border: 1px solid #e2e8f0; padding: 20px; border-radius: 8px; margin-bottom: 20px; page-break-inside: avoid;">
                    <div style="background: #f8fafc; padding: 15px; border-radius: 6px; margin-bottom: 15px;">
                      <h4 style="color: #4a5568; font-size: 14px; margin-bottom: 8px; font-weight: 600;">🎭 Coaching Scenario</h4>
                      <p style="color: #2d3748; font-size: 12px; line-height: 1.5; margin: 0;">${q.scenarioContext || 'Scenario details not available'}</p>
                    </div>
                    
                    <div style="margin-bottom: 15px;">
                      <h4 style="color: #4a5568; font-size: 13px; margin-bottom: 6px; font-weight: 600;">❓ Question</h4>
                      <p style="color: #2d3748; font-size: 12px; line-height: 1.4; margin: 0; font-style: italic;">"${q.questionFocus || 'Question not available'}"</p>
                    </div>
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 15px;">
                      <div style="background: #fef5e7; padding: 12px; border-radius: 6px; border-left: 3px solid #f6ad55;">
                        <h5 style="color: #c05621; font-size: 12px; margin-bottom: 4px; font-weight: 600;">Your Approach</h5>
                        <p style="color: #744210; font-size: 11px; margin: 0;">${q.yourApproach || 'Selected option not available'}</p>
                      </div>
                      <div style="background: #f0fff4; padding: 12px; border-radius: 6px; border-left: 3px solid #48bb78;">
                        <h5 style="color: #22543d; font-size: 12px; margin-bottom: 4px; font-weight: 600;">Effective Approach</h5>
                        <p style="color: #276749; font-size: 11px; margin: 0;">${q.correctApproach || 'Correct option not available'}</p>
                      </div>
                    </div>
                    
                    ${q.coachingLearningPoint ? `
                      <div style="background: #f0f9ff; padding: 15px; border-radius: 6px; margin-bottom: 15px; border-left: 3px solid #3b82f6;">
                        <h5 style="color: #1e40af; font-size: 12px; margin-bottom: 8px; font-weight: 600;">🧠 Coaching Context</h5>
                        <p style="color: #1e3a8a; font-size: 11px; line-height: 1.4; margin-bottom: 8px;">${q.coachingLearningPoint.coachingContext || ''}</p>
                        
                        <div style="background: white; padding: 10px; border-radius: 4px; margin-bottom: 8px;">
                          <h6 style="color: #7c2d12; font-size: 11px; margin-bottom: 4px; font-weight: 600;">Common Pattern</h6>
                          <p style="color: #92400e; font-size: 10px; margin: 0;">${q.coachingLearningPoint.commonMistake || ''}</p>
                        </div>
                        
                        <div style="background: white; padding: 10px; border-radius: 4px; margin-bottom: 8px;">
                          <h6 style="color: #065f46; font-size: 11px; margin-bottom: 4px; font-weight: 600;">Key Insight</h6>
                          <p style="color: #047857; font-size: 10px; margin: 0;">${q.coachingLearningPoint.keyInsight || q.explanationOfCorrectApproach || ''}</p>
                        </div>
                        
                        <div style="background: #ede9fe; padding: 8px; border-radius: 4px;">
                          <h6 style="color: #5b21b6; font-size: 11px; margin-bottom: 4px; font-weight: 600;">Practice Opportunity</h6>
                          <p style="color: #6d28d9; font-size: 10px; margin: 0; font-style: italic;">${q.coachingLearningPoint.practiceOpportunity || ''}</p>
                        </div>
                      </div>
                    ` : `
                      <div style="background: #edf2f7; padding: 12px; border-radius: 6px; border-left: 3px solid #4299e1;">
                        <h5 style="color: #2b6cb0; font-size: 12px; margin-bottom: 6px; font-weight: 600;">💡 Coaching Insight</h5>
                        <p style="color: #2c5282; font-size: 11px; line-height: 1.4; margin: 0;">${q.explanationOfCorrectApproach || 'Detailed explanation not available'}</p>
                      </div>
                    `}
                  </div>
                `).join('')}
                  
                  <div style="background: #e6fffa; padding: 15px; border-radius: 6px; border-left: 4px solid #38b2ac;">
                    <h4 style="color: #234e52; font-size: 13px; margin-bottom: 8px; font-weight: 600;">📚 Learning Summary</h4>
                    <p style="color: #285e61; font-size: 12px; line-height: 1.4; margin: 0;">${item.competency.questionAnalysis.summary || 'Review these scenarios to strengthen your coaching skills in this competency area.'}</p>
                  </div>
                </div>
              `).join('')}
            </div>
          `
        })()}

        <!-- Removed Performance Insights Section - Redundant with Detailed Analysis -->

        <!-- Removed Coaching Development Summary - Redundant with Executive Summary -->
        <!-- Start of remaining sections -->
        <div style="display: none;"><!-- Hidden wrapper to maintain structure -->
          
          <div style="display: flex; gap: 20px; margin-bottom: 25px;">
            <!-- Performance Overview -->
            <div style="flex: 1; background: #e3f2fd; padding: 20px; border-radius: 8px; border-left: 4px solid #2196f3;">
              <h3 style="color: #0d47a1; font-size: 16px; margin-bottom: 15px;">Performance Overview</h3>
              <div style="color: #1565c0; font-size: 13px; line-height: 1.6;">
                <p style="margin-bottom: 8px;"><strong>Overall Score:</strong> ${overall_stats?.score || 0}% (${overall_stats?.score >= 70 ? 'Proficient' : overall_stats?.score >= 50 ? 'Developing' : 'Needs Improvement'})</p>
                <p style="margin-bottom: 8px;"><strong>Questions Completed:</strong> ${overall_stats?.correct_answers || 0}/${overall_stats?.total_questions || 0}</p>
                <p style="margin-bottom: 8px;"><strong>Assessment Level:</strong> ${assessment_framework?.toUpperCase() || 'CORE'} - ${overall_stats?.assessment_difficulty || 'Beginner'}</p>
                <p style="margin: 0;"><strong>Time Invested:</strong> ${Math.floor((overall_stats?.time_spent || 0) / 60)}m ${(overall_stats?.time_spent || 0) % 60}s</p>
              </div>
            </div>
            
            <!-- Priority Development Area -->
            ${(() => {
              const topWeakArea = smart_insights?.weakAreas?.[0]
              if (topWeakArea) {
                return `
                  <div style="flex: 1; background: #fff3e0; padding: 20px; border-radius: 8px; border-left: 4px solid #ff9800;">
                    <h3 style="color: #e65100; font-size: 16px; margin-bottom: 15px;">Priority Development Area</h3>
                    <div style="color: #bf360c; font-size: 13px; line-height: 1.6;">
                      <p style="margin-bottom: 8px; font-weight: 600;">${topWeakArea.area}</p>
                      <p style="margin-bottom: 12px;">Focus on strengthening your core coaching foundations.</p>
                      ${topWeakArea.actions?.[0] ? `
                        <div style="background: rgba(255, 152, 0, 0.1); padding: 10px; border-radius: 6px;">
                          <p style="color: #ef6c00; font-size: 12px; margin: 0; font-style: italic;">
                            <em>Next step:</em> ${topWeakArea.actions[0]}
                          </p>
                        </div>
                      ` : ''}
                    </div>
                  </div>
                `
              }
              return ''
            })()}
          </div>
          
          <!-- Key Takeaways -->
          <div style="background: #e8f5e9; padding: 20px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #4caf50;">
            <h3 style="color: #1b5e20; font-size: 16px; margin-bottom: 15px; display: flex; align-items: center;">
              <span style="font-size: 20px; margin-right: 8px;">🎯</span> Key Takeaways from Your Assessment
            </h3>
            <ul style="color: #2e7d32; font-size: 13px; line-height: 1.6; margin: 0; padding-left: 20px;">
              ${smart_insights?.strengths?.length > 0 ? `
                <li style="margin-bottom: 8px;">Your strongest competency is <strong>${smart_insights.strengths[0].area}</strong> - leverage this in your coaching practice</li>
                <li style="margin-bottom: 8px;">You performed best in <strong>${smart_insights.strengths[0].area}</strong> (${smart_insights.strengths[0].percentage}%)</li>
              ` : ''}
              <li style="margin-bottom: 8px;">You have ${competency_stats?.length || 0} competencies with personalized action plans</li>
              <li style="margin-bottom: 8px;">Targeted learning resources identified for your development</li>
              <li style="margin: 0;">This assessment provides a baseline for tracking your coaching journey progression</li>
            </ul>
          </div>
          
          <!-- Next Steps Action Plan -->
          <div style="background: #f3e5f5; padding: 20px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #9c27b0;">
            <h3 style="color: #4a148c; font-size: 16px; margin-bottom: 15px; display: flex; align-items: center;">
              <span style="font-size: 20px; margin-right: 8px;">🚀</span> Your Next Steps Action Plan
            </h3>
            <ol style="color: #6a1b9a; font-size: 13px; line-height: 1.6; margin: 0; padding-left: 20px;">
              ${(() => {
                const topWeakArea = smart_insights?.weakAreas?.[0]
                const topStrength = smart_insights?.strengths?.[0]
                
                let actions = []
                
                if (topWeakArea) {
                  actions.push(`<strong>Focus on Priority:</strong> Dedicate the next 2-3 sessions to strengthening ${topWeakArea.area}`)
                }
                
                if (topStrength) {
                  actions.push(`<strong>Leverage Strength:</strong> Use your ${topStrength.area} to support clients in challenging situations`)
                }
                
                actions.push('<strong>Study Resources:</strong> Start with the first recommended learning resource for your development area')
                actions.push('<strong>Practice Application:</strong> Apply new techniques in real coaching sessions and seek feedback')
                actions.push('<strong>Track Progress:</strong> Retake this assessment in 3-6 months to measure your improvement')
                
                return actions.map(action => `<li style="margin-bottom: 8px;">${action}</li>`).join('')
              })()}
            </ol>
          </div>
        </div>

        <!-- Learning Resources & Development Path -->
        <div class="learning-path-section" style="margin-top: 40px; margin-bottom: 35px;">
          <h2 style="color: #333; font-size: 18px; margin-bottom: 20px; border-bottom: 2px solid #e0e4e7; padding-bottom: 8px;">Learning Resources & Development Path</h2>
          
          <!-- Dynamic learning resources from database -->
          ${enrichedAssessmentData.learning_resources?.length > 0 ? `
            ${enrichedAssessmentData.learning_resources.map((resource: any, index: number) => `
              <div style="background: ${getResourceBackgroundColor(index)}; padding: 20px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid ${getResourceBorderColor(index)}; page-break-inside: avoid;">
                <h3 style="color: ${getResourceTextColor(index)}; font-size: 16px; margin-bottom: 12px; display: flex; align-items: center;">
                  <span style="font-size: 20px; margin-right: 8px;">${resource.icon}</span> ${resource.title}
                </h3>
                <p style="color: ${getResourceDescriptionColor(index)}; font-size: 13px; margin-bottom: 15px;">${resource.description}</p>
                
                <ul style="margin: 0; padding-left: 20px;">
                  ${resource.resources.slice(0, 4).map((item: string) => `
                    <li style="color: ${getResourceItemColor(index)}; font-size: 12px; margin-bottom: 8px;">
                      ${item}
                    </li>
                  `).join('')}
                </ul>
              </div>
            `).join('')}
          ` : `
            <div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
              <p style="color: #666; font-size: 13px; margin: 0;">
                No learning resources found for score ${overall_stats?.score || 0}%. 
                Check database for resources with matching score range or add generic resources.
              </p>
            </div>
          `}
          
          <!-- Leverage Your Strength Section -->
          ${(() => {
            const topStrength = smart_insights?.strengths?.[0]
            if (topStrength) {
              return `
                <div style="background: #e8f5e9; padding: 20px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #4caf50;">
                  <h3 style="color: #1b5e20; font-size: 16px; margin-bottom: 12px; display: flex; align-items: center;">
                    <span style="font-size: 20px; margin-right: 8px;">💡</span> Leverage Your ${topStrength.area} Strength
                  </h3>
                  <p style="color: #2e7d32; font-size: 13px; margin-bottom: 12px;">${topStrength.message}</p>
                  <div style="background: rgba(76, 175, 80, 0.1); padding: 12px; border-radius: 6px;">
                    <p style="color: #1b5e20; font-size: 12px; margin: 0; font-weight: 500;">
                      <em>Next Action:</em> ${topStrength.actions?.[0] || strengthAction}
                    </p>
                  </div>
                </div>
              `
            }
            return ''
          })()}
          
          <!-- Practice Reminder -->
          <div style="background: #e3f2fd; padding: 15px; border-radius: 8px; border-left: 4px solid #2196f3; text-align: center;">
            <p style="color: #1565c0; font-size: 12px; margin: 0; font-weight: 600;">
              💡 Remember: Knowledge without practice is incomplete. Apply these learnings in your coaching sessions and seek feedback regularly.
            </p>
          </div>
        </div>
        
        <!-- Simple Generation Footer -->
        <div class="generation-footer">
          <div>Generated on ${completedDate}</div>
          <div style="margin-top: 5px; font-style: italic;">This report is confidential and for professional development use only.</div>
        </div>
        
      </div>
    </body>
    </html>
  `
}

// Generate PDF from HTML using PDFShift API (same as ForwardFocus)
async function generatePDFFromHTML(htmlContent: string, attemptId: string): Promise<Uint8Array> {
  try {
    console.log('🔄 Converting HTML to PDF using PDFShift...')
    
    // Get PDFShift API key
    const pdfShiftApiKey = Deno.env.get('PDFSHIFT_API_KEY')
    if (!pdfShiftApiKey) {
      console.warn('⚠️ PDFSHIFT_API_KEY not found, using placeholder PDF')
      // Fallback to simple PDF if no API key
      return createPlaceholderPDF(attemptId)
    }

    // PDFShift API configuration with properly styled footer
    const requestBody = {
      source: htmlContent,
      landscape: false,
      format: "A4",
      margin: { top: 25, right: 25, bottom: 50, left: 25 },
      use_print: true,
      delay: 2000,  // Wait 2 seconds for images/fonts to load
      footer: {
        source: `<div style="font-family: Arial, sans-serif; font-size: 10px; color: #666; padding: 10px 0; width: 100%; display: flex; justify-content: center; align-items: center;">
          <span>Your Coaching Hub • Professional Development Platform</span>
        </div>`,
        height: 30
      }
    }

    console.log('📡 Sending HTML to PDFShift API...')

    // Call PDFShift API
    const pdfResponse = await fetch('https://api.pdfshift.io/v3/convert/pdf', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${btoa('api:' + pdfShiftApiKey)}`
      },
      body: JSON.stringify(requestBody)
    })

    if (!pdfResponse.ok) {
      const errorText = await pdfResponse.text()
      console.error('❌ PDFShift API error:', pdfResponse.status, errorText)
      // Fallback to placeholder on API error
      return createPlaceholderPDF(attemptId)
    }

    const pdfBuffer = await pdfResponse.arrayBuffer()
    console.log('✅ PDF generated successfully via PDFShift:', pdfBuffer.byteLength, 'bytes')
    
    return new Uint8Array(pdfBuffer)

  } catch (error) {
    console.error('❌ Error generating PDF:', error)
    // Fallback to placeholder on any error
    return createPlaceholderPDF(attemptId)
  }
}

// Fallback placeholder PDF when PDFShift is not available
function createPlaceholderPDF(attemptId: string): Uint8Array {
  console.log('📄 Creating placeholder PDF (PDFShift not available)')
  
  const pdfContent = `%PDF-1.4
1 0 obj
<<
/Type /Catalog
/Pages 2 0 R
>>
endobj

2 0 obj
<<
/Type /Pages
/Kids [3 0 R]
/Count 1
>>
endobj

3 0 obj
<<
/Type /Page
/Parent 2 0 R
/MediaBox [0 0 612 792]
/Resources <<
  /Font <<
    /F1 4 0 R
  >>
>>
/Contents 5 0 R
>>
endobj

4 0 obj
<<
/Type /Font
/Subtype /Type1
/BaseFont /Helvetica
>>
endobj

5 0 obj
<<
/Length 300
>>
stream
BT
/F1 18 Tf
50 750 Td
(Assessment Report - Setup Required) Tj
0 -30 Td
/F1 12 Tf
(Assessment ID: ${attemptId}) Tj
0 -20 Td
(Generated: ${new Date().toLocaleDateString()}) Tj
0 -40 Td
(PDFShift API key required for beautiful PDF generation.) Tj
0 -20 Td
(HTML template ready - add PDFSHIFT_API_KEY to environment.) Tj
ET
endstream
endobj

xref
0 6
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
0000000273 00000 n 
0000000351 00000 n 
trailer
<<
/Size 6
/Root 1 0 R
>>
startxref
700
%%EOF`

  return new TextEncoder().encode(pdfContent)
}


/**
 * Generate rich insights for PDF based on competency performance from database
 */
async function generateRichCompetencyInsights(competency: string, percentage: number, framework: string = 'core'): Promise<any> {
  const level = percentage >= 80 ? 'advanced' : percentage >= 60 ? 'developing' : 'foundational'
  
  try {
    // Get Supabase environment
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    
    if (!supabaseUrl || !serviceRoleKey) {
      console.warn('Missing Supabase credentials for rich insights query')
      return getGenericInsight(competency, level)
    }
    
    // Get framework ID first
    const frameworkResponse = await fetch(`${supabaseUrl}/rest/v1/frameworks?code=eq.${framework}&select=id`, {
      headers: {
        'apikey': serviceRoleKey,
        'Authorization': `Bearer ${serviceRoleKey}`,
        'Content-Type': 'application/json'
      }
    })
    
    if (!frameworkResponse.ok) {
      console.warn('Failed to fetch framework data for rich insights')
      return getGenericInsight(competency, level)
    }
    
    const frameworkData = await frameworkResponse.json()
    if (!frameworkData || frameworkData.length === 0) {
      console.warn('Framework not found for rich insights:', framework)
      return getGenericInsight(competency, level)
    }
    
    const frameworkId = frameworkData[0].id
    
    // Get competency ID
    const competencyResponse = await fetch(`${supabaseUrl}/rest/v1/competency_display_names?framework_id=eq.${frameworkId}&display_name=eq.${encodeURIComponent(competency)}&select=id`, {
      headers: {
        'apikey': serviceRoleKey,
        'Authorization': `Bearer ${serviceRoleKey}`,
        'Content-Type': 'application/json'
      }
    })
    
    if (!competencyResponse.ok) {
      console.warn('Failed to fetch competency data for rich insights')
      return getGenericInsight(competency, level)
    }
    
    const competencyQueryData = await competencyResponse.json()
    if (!competencyQueryData || competencyQueryData.length === 0) {
      console.warn('Competency not found for rich insights:', competency)
      return getGenericInsight(competency, level)
    }
    
    const competencyId = competencyQueryData[0].id
    
    // Get assessment level ID (beginner)
    const levelResponse = await fetch(`${supabaseUrl}/rest/v1/assessment_levels?framework_id=eq.${frameworkId}&level_code=eq.beginner&select=id`, {
      headers: {
        'apikey': serviceRoleKey,
        'Authorization': `Bearer ${serviceRoleKey}`,
        'Content-Type': 'application/json'
      }
    })
    
    if (!levelResponse.ok) {
      console.warn('Failed to fetch assessment level data for rich insights')
      return getGenericInsight(competency, level)
    }
    
    const levelData = await levelResponse.json()
    if (!levelData || levelData.length === 0) {
      console.warn('Assessment level not found for rich insights')
      return getGenericInsight(competency, level)
    }
    
    const assessmentLevelId = levelData[0].id
    
    // Determine analysis type based on performance (70% threshold like skills system)
    const analysisType = percentage >= 70 ? 'strength' : 'weakness'
    
    // Get analysis type ID
    const analysisTypeResponse = await fetch(`${supabaseUrl}/rest/v1/analysis_types?code=eq.${analysisType}&select=id`, {
      headers: {
        'apikey': serviceRoleKey,
        'Authorization': `Bearer ${serviceRoleKey}`,
        'Content-Type': 'application/json'
      }
    })
    
    if (!analysisTypeResponse.ok) {
      console.warn('Failed to fetch analysis type data for consolidated rich insights')
      return getGenericInsight(competency, level)
    }
    
    const analysisTypeData = await analysisTypeResponse.json()
    if (!analysisTypeData || analysisTypeData.length === 0) {
      console.warn('Analysis type not found for consolidated rich insights:', analysisType)
      return getGenericInsight(competency, level)
    }
    
    const analysisTypeId = analysisTypeData[0].id
    
    // Query NEW consolidated insights table
    const response = await fetch(`${supabaseUrl}/rest/v1/competency_consolidated_insights?framework_id=eq.${frameworkId}&assessment_level_id=eq.${assessmentLevelId}&competency_id=eq.${competencyId}&analysis_type_id=eq.${analysisTypeId}&is_active=eq.true&limit=1`, {
      headers: {
        'apikey': serviceRoleKey,
        'Authorization': `Bearer ${serviceRoleKey}`,
        'Content-Type': 'application/json'
      }
    })
    
    if (response.ok) {
      const insights = await response.json()
      if (insights && insights.length > 0) {
        const insight = insights[0]
        console.log(`✅ PDF: Found consolidated insights for ${competency} (${percentage}% - ${analysisType})`)
        
        // Map NEW consolidated 3-field structure to expected field names for PDF template
        return {
          // NEW consolidated fields (for potential future use)
          performanceInsight: insight.performance_insight,
          developmentFocus: insight.development_focus,
          practicalApplication: insight.practical_application,
          
          // Backward compatibility mapping to old field names used in PDF template
          primaryInsight: insight.performance_insight,
          coachingImpact: insight.performance_insight,
          keyObservation: insight.performance_insight,
          practiceRecommendation: insight.development_focus,
          growthPathway: insight.development_focus,
          supervisionFocus: insight.practical_application,
          learningApproach: insight.practical_application
        }
      }
    }
    
    console.warn(`No consolidated insights found for ${competency} at ${percentage}% (${analysisType}), using generic`)
    return getGenericInsight(competency, level)
    
  } catch (error) {
    console.error('Error fetching rich insights:', error)
    return getGenericInsight(competency, level)
  }
}

/**
 * Fallback generic insights while database is being populated
 */
function getGenericInsight(competency: string, level: string): any {
  const templates = {
    advanced: {
      primaryInsight: `Your mastery of ${competency} demonstrates senior-level coaching competence. You consistently apply this skill to create transformative client experiences.`,
      coachingImpact: `Your advanced ${competency} skills enable profound client transformation and breakthrough moments.`,
      keyObservation: `You demonstrate sophisticated application of ${competency} in complex coaching scenarios.`,
      developmentFocus: `Consider how to leverage your ${competency} expertise in specialized coaching contexts or organizational settings.`,
      practiceRecommendation: `Experiment with advanced applications of ${competency} in challenging client situations.`,
      growthPathway: `Your expertise positions you to mentor others and contribute to the field through thought leadership.`,
      practicalApplication: `Use your ${competency} mastery to tackle complex, multi-stakeholder coaching challenges.`
    },
    developing: {
      primaryInsight: `Your ${competency} skills show solid development with opportunities for refinement. Continue building on your current foundation.`,
      coachingImpact: `Your developing ${competency} skills support effective coaching with room for deeper impact.`,
      keyObservation: `You demonstrate good foundational understanding with potential for greater sophistication.`,
      developmentFocus: `Focus on deepening your ${competency} practice through deliberate application and reflection.`,
      practiceRecommendation: `Practice ${competency} in structured exercises and seek feedback on your application.`,
      growthPathway: `With focused development, you can achieve mastery level competence in ${competency}.`,
      practicalApplication: `Apply ${competency} consistently in your coaching sessions and notice the impact on client outcomes.`
    },
    foundational: {
      primaryInsight: `${competency} is an essential coaching competency requiring focused development. This represents a significant growth opportunity.`,
      coachingImpact: `Strengthening ${competency} will substantially improve your coaching effectiveness and client satisfaction.`,
      keyObservation: `This competency requires fundamental skill building and consistent practice.`,
      developmentFocus: `Invest time in understanding and practicing the basic principles of ${competency}.`,
      practiceRecommendation: `Begin with structured practice in low-stakes environments before applying in client sessions.`,
      growthPathway: `Start with foundational learning, then progress to supervised practice and peer feedback.`,
      practicalApplication: `Study exemplar coaches demonstrating ${competency} and identify specific behaviors to adopt.`
    }
  }
  
  return templates[level as keyof typeof templates] || templates.foundational
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    console.log('🎯 PDF generation function called')
    const requestBody = await req.json()
    console.log('📊 Request received:', { 
      hasAssessmentData: !!requestBody.assessmentData,
      attemptId: requestBody.attemptId
    })

    const { assessmentData, attemptId, userEmail } = requestBody

    if (!assessmentData || !attemptId) {
      console.error('❌ Missing assessment data or attempt ID')
      return new Response(
        JSON.stringify({ error: 'Assessment data and attempt ID are required' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Get Supabase credentials
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || Deno.env.get('SUPABASE_ANON_KEY')
    
    if (!supabaseUrl || !supabaseServiceKey) {
      console.error('❌ Missing Supabase credentials')
      return new Response(
        JSON.stringify({ error: 'Server configuration error' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Get user_id from the attempt data to properly structure storage path
    console.log('👤 Fetching user_id from attempt data for proper storage structure...')
    const storageUserResponse = await fetch(`${supabaseUrl}/rest/v1/user_assessment_attempts?id=eq.${attemptId}&select=user_id`, {
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': `Bearer ${supabaseServiceKey}`,
        'Content-Type': 'application/json'
      }
    })
    
    let userId = null
    if (storageUserResponse.ok) {
      const storageUserData = await storageUserResponse.json()
      if (storageUserData && storageUserData.length > 0) {
        userId = storageUserData[0].user_id
        console.log('✅ Found user_id for storage path:', userId)
      }
    }
    
    if (!userId) {
      console.warn('⚠️ Could not get user_id, using fallback email-based storage path')
    }

    console.log('✅ Generating PDF content...')

    // Generate HTML content for PDF (now async because it queries database)
    const htmlContent = await generateAssessmentHTML(assessmentData, attemptId, userEmail)
    
    // Generate PDF from HTML using PDFShift API (same as ForwardFocus)
    const pdfBuffer = await generatePDFFromHTML(htmlContent, attemptId)
    
    // Store in Supabase Storage with user-specific path structure
    const filename = `assessment-report-${attemptId}-${Date.now()}.pdf`
    const storagePath = userId ? `${userId}/${filename}` : `fallback/${filename}`
    
    console.log('📤 Uploading PDF to storage bucket temporary-pdfs:', storagePath)
    
    const uploadResponse = await fetch(`${supabaseUrl}/storage/v1/object/temporary-pdfs/${storagePath}`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${supabaseServiceKey}`,
        'apikey': supabaseServiceKey,
        'Content-Type': 'application/pdf',
        'x-upsert': 'true'
      },
      body: pdfBuffer
    })
    
    if (!uploadResponse.ok) {
      const errorText = await uploadResponse.text()
      console.error('❌ Failed to upload PDF to storage:', uploadResponse.status, errorText)
      return new Response(
        JSON.stringify({ error: 'Failed to store PDF', details: errorText }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }
    
    console.log('✅ PDF uploaded successfully')

    // Create token record in temporary_pdf_files table
    // Use the email passed from the email function (which comes from the actual user)
    const finalUserEmail = userEmail || assessmentData.user_email
    
    if (!finalUserEmail) {
      console.error('❌ No user email provided')
      return new Response(
        JSON.stringify({ error: 'User email is required for PDF generation' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }
    
    // Reuse the userId we already fetched above for PDF tracking
    console.log('📝 Using user_id for PDF tracking:', userId || 'null')

    // Generate download token for secure access
    const downloadToken = crypto.randomUUID()
    
    // Set expiration date (7 days from now)
    const expiresAt = new Date()
    expiresAt.setDate(expiresAt.getDate() + 7)
    
    console.log('📝 Creating database record for PDF cleanup tracking...')
    
    // Insert record into temporary_pdf_files table
    const dbInsertResponse = await fetch(`${supabaseUrl}/rest/v1/temporary_pdf_files`, {
      method: 'POST',
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': `Bearer ${supabaseServiceKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        file_path: storagePath,
        expires_at: expiresAt.toISOString(),
        user_id: userId, // Now properly tracks user ownership
        assessment_attempt_id: attemptId,
        download_token: downloadToken
      })
    })
    
    if (!dbInsertResponse.ok) {
      const errorText = await dbInsertResponse.text()
      console.error('❌ Failed to create database record:', dbInsertResponse.status, errorText)
      console.log('⚠️ PDF will be accessible but may not be automatically cleaned up after 7 days')
      // Continue anyway - PDF is still accessible via public URL
    } else {
      console.log('✅ Database record created for PDF cleanup tracking')
    }
    
    console.log('📝 Creating public download URL for temporary-pdfs bucket...')
    
    // Since temporary-pdfs bucket is public, use direct public URL instead of signed URL
    const downloadUrl = `${supabaseUrl}/storage/v1/object/public/temporary-pdfs/${storagePath}`
    console.log('✅ PDF available at public URL:', downloadUrl)

    return new Response(
      JSON.stringify({ 
        success: true, 
        downloadUrl: downloadUrl,
        filename: filename,
        storagePath: storagePath,
        message: 'PDF generated and stored successfully'
      }),
      { 
        headers: { 
          ...corsHeaders, 
          'Content-Type': 'application/json' 
        } 
      }
    )

  } catch (error) {
    console.error('❌ PDF generation error:', error)
    return new Response(
      JSON.stringify({ 
        error: 'Failed to generate PDF', 
        details: error.message,
        message: 'Beautiful HTML template ready for conversion'
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})