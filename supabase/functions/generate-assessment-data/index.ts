// Function to generate assessment data from normalized database structure
// Replaces the monolithic JSONB approach with relational queries

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface AssessmentRequest {
  assessment_type_slug: string
  user_answers: Record<string, number>
  user_id?: string
}

interface SkillInsight {
  tag: string
  insight: string
  actionableStep: string
}

interface CompetencyAnalysis {
  area: string
  total: number
  correct: number
  percentage: number
  displayName: string
  skillTags: string[]
  tagInsights: SkillInsight[]
  personalizedActions: string[]
  personalizedInsights: string[]
}

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    )

    const { assessment_type_slug, user_answers, user_id } = await req.json() as AssessmentRequest

    // Get assessment type info
    const { data: assessmentType, error: assessmentError } = await supabaseClient
      .from('assessment_types')
      .select(`
        *,
        framework:frameworks(*),
        difficulty:difficulties(*)
      `)
      .eq('slug', assessment_type_slug)
      .single()

    if (assessmentError) {
      throw new Error(`Assessment type not found: ${assessmentError.message}`)
    }

    // Get competencies for this framework
    const { data: competencies, error: competenciesError } = await supabaseClient
      .from('competencies')
      .select(`
        *,
        competency_skills!inner (
          skill_id,
          sort_order,
          skill:skills (*)
        )
      `)
      .eq('framework_id', assessmentType.framework.id)
      .order('id')

    if (competenciesError) {
      throw new Error(`Failed to fetch competencies: ${competenciesError.message}`)
    }

    // Get questions and calculate results
    const { data: questions, error: questionsError } = await supabaseClient
      .from('assessment_questions')
      .select('*')
      .eq('assessment_type_id', assessmentType.id)
      .order('sort_order')

    if (questionsError) {
      throw new Error(`Failed to fetch questions: ${questionsError.message}`)
    }

    // Calculate competency results
    const competencyAnalysis: CompetencyAnalysis[] = []
    let totalQuestions = 0
    let totalCorrect = 0

    for (const competency of competencies) {
      const competencyQuestions = questions.filter(q => q.competency_id === competency.id)
      const competencyCorrect = competencyQuestions.filter(q => 
        user_answers[q.id.toString()] === q.correct_option_index
      ).length

      totalQuestions += competencyQuestions.length
      totalCorrect += competencyCorrect

      // Get insights and actions for this competency's skills
      const skillIds = competency.competency_skills.map(cs => cs.skill_id)
      
      const { data: skillInsights, error: skillInsightsError } = await supabaseClient
        .from('skill_insights')
        .select(`
          *,
          skill:skills(*)
        `)
        .in('skill_id', skillIds)
        .eq('framework_id', assessmentType.framework.id)
        .eq('difficulty_id', assessmentType.difficulty.id)

      if (skillInsightsError) {
        throw new Error(`Failed to fetch skill insights: ${skillInsightsError.message}`)
      }

      const { data: actionTemplates, error: actionsError } = await supabaseClient
        .from('action_templates')
        .select(`
          *,
          skill:skills(*)
        `)
        .in('skill_id', skillIds)
        .eq('framework_id', assessmentType.framework.id)
        .eq('difficulty_id', assessmentType.difficulty.id)

      if (actionsError) {
        throw new Error(`Failed to fetch action templates: ${actionsError.message}`)
      }

      const tagInsights: SkillInsight[] = skillInsights.map(si => ({
        tag: si.skill.display_name,
        insight: si.insight_text,
        actionableStep: si.actionable_step
      }))

      const personalizedActions = actionTemplates.map(at => 
        `${at.action_type}: ${at.template_text}`
      )

      // Generate insights based on performance
      const percentage = competencyQuestions.length > 0 
        ? Math.round((competencyCorrect / competencyQuestions.length) * 100)
        : 0

      const personalizedInsights = percentage === 100
        ? [
            `Your ${competency.display_name} suggests you can help clients in this area effectively.`,
            `Your perfect accuracy shows strong mastery of ${competency.display_name} concepts.`,
            `You can model ${competency.display_name} for clients who struggle in this area.`
          ]
        : [
            `${competency.display_name} gaps may limit your coaching effectiveness in this area.`,
            `You missed ${competencyQuestions.length - competencyCorrect} question(s) - focus on specific skill development.`,
            `Clients may not receive the full benefit of your coaching in ${competency.display_name}.`
          ]

      competencyAnalysis.push({
        area: competency.name,
        total: competencyQuestions.length,
        correct: competencyCorrect,
        percentage,
        displayName: competency.display_name,
        skillTags: competency.competency_skills.map(cs => cs.skill.display_name),
        tagInsights,
        personalizedActions,
        personalizedInsights
      })
    }

    // Generate overall stats
    const overallPercentage = totalQuestions > 0 ? Math.round((totalCorrect / totalQuestions) * 100) : 0
    
    // Get learning resources
    const { data: resourceCategories, error: resourcesError } = await supabaseClient
      .from('resource_categories')
      .select(`
        *,
        learning_resources(*)
      `)

    if (resourcesError) {
      throw new Error(`Failed to fetch resources: ${resourcesError.message}`)
    }

    const learningResources = resourceCategories.map(category => ({
      icon: category.icon,
      title: category.display_name,
      description: category.description,
      resources: category.learning_resources.map(lr => `${lr.resource_type}: "${lr.title}" - ${lr.description}`)
    }))

    // Generate the response structure matching the original JSONB format
    const enrichedData = {
      source: "normalized_db",
      version: "3.0",
      pdf_ready: true,
      calculated_at: new Date().toISOString(),
      overall_stats: {
        score: overallPercentage,
        time_spent: 7, // This would come from frontend timing
        assessment_slug: assessment_type_slug,
        completion_rate: 100, // Assuming completed if we're generating results
        correct_answers: totalCorrect,
        total_questions: totalQuestions,
        assessment_title: assessmentType.title,
        assessment_framework: assessmentType.framework.name,
        assessment_difficulty: assessmentType.difficulty.display_name
      },
      competency_analysis: competencyAnalysis,
      learning_resources: learningResources,
      assessment_framework: assessmentType.framework.name
    }

    return new Response(
      JSON.stringify({ enriched_data: enrichedData }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    )

  } catch (error) {
    console.error('Error generating assessment data:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      },
    )
  }
})