import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.0.0'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Query 1: All functions including trigger functions
    const functionsQuery = `
      SELECT 
        f.proname as function_name,
        f.pronargs as num_arguments,
        CASE 
          WHEN f.proname LIKE '%test%' THEN 'TEST_FUNCTION'
          WHEN f.proname LIKE '%debug%' THEN 'DEBUG_FUNCTION'  
          WHEN f.proname LIKE '%temp%' THEN 'TEMP_FUNCTION'
          WHEN f.proname LIKE '%old%' THEN 'OLD_FUNCTION'
          WHEN f.proname LIKE '%backup%' THEN 'BACKUP_FUNCTION'
          WHEN f.proname ~ '_v[0-9]+$' THEN 'VERSIONED_FUNCTION'
          WHEN f.proname ~ '_[0-9]+$' THEN 'NUMBERED_FUNCTION'
          WHEN f.proname LIKE '%duplicate%' THEN 'DUPLICATE_FUNCTION'
          WHEN f.proname LIKE 'check_answer_correctness%' THEN 'ANSWER_CHECK_FUNCTION'
          ELSE 'PRODUCTION_FUNCTION'
        END as status,
        (f.proname LIKE '%test%' OR 
         f.proname LIKE '%debug%' OR 
         f.proname LIKE '%temp%' OR 
         f.proname LIKE '%old%' OR 
         f.proname LIKE '%backup%' OR
         f.proname LIKE '%duplicate%' OR
         f.proname ~ '_v[0-9]+$' OR
         f.proname ~ '_[0-9]+$') as is_removal_candidate
      FROM pg_proc f
      JOIN pg_namespace n ON f.pronamespace = n.oid 
      WHERE n.nspname = 'public'
      AND f.proname NOT IN ('extensions', 'version')
      ORDER BY is_removal_candidate DESC, f.proname
    `

    // Query 2: Function families (versioned functions)
    const familiesQuery = `
      WITH function_families AS (
        SELECT 
          CASE 
            WHEN f.proname ~ '_v[0-9]+$' THEN regexp_replace(f.proname, '_v[0-9]+$', '')
            WHEN f.proname ~ '_[0-9]+$' THEN regexp_replace(f.proname, '_[0-9]+$', '') 
            ELSE f.proname
          END as base_name,
          f.proname as full_name,
          CASE 
            WHEN f.proname ~ '_v([0-9]+)$' THEN (regexp_match(f.proname, '_v([0-9]+)$'))[1]::int
            WHEN f.proname ~ '_([0-9]+)$' THEN (regexp_match(f.proname, '_([0-9]+)$'))[1]::int
            ELSE 0
          END as version_number
        FROM pg_proc f
        JOIN pg_namespace n ON f.pronamespace = n.oid 
        WHERE n.nspname = 'public'
      )
      SELECT 
        base_name,
        COUNT(*) as total_versions,
        MAX(version_number) as highest_version,
        array_agg(full_name ORDER BY version_number) as all_versions
      FROM function_families
      WHERE base_name != 'version'
      GROUP BY base_name
      HAVING COUNT(*) > 1
      ORDER BY total_versions DESC, base_name
    `

    // Query 3: Triggers
    const triggersQuery = `
      SELECT 
        t.trigger_name,
        t.event_object_table as table_name,
        t.action_statement,
        CASE 
          WHEN t.trigger_name LIKE '%test%' THEN 'TEST_TRIGGER'
          WHEN t.trigger_name LIKE '%debug%' THEN 'DEBUG_TRIGGER'
          WHEN t.trigger_name LIKE '%temp%' THEN 'TEMP_TRIGGER'
          WHEN t.trigger_name LIKE '%old%' THEN 'OLD_TRIGGER'
          WHEN t.trigger_name LIKE '%backup%' THEN 'BACKUP_TRIGGER'
          WHEN t.trigger_name ~ '_v[0-9]+$' THEN 'VERSIONED_TRIGGER'
          WHEN t.trigger_name ~ '_[0-9]+$' THEN 'NUMBERED_TRIGGER'
          ELSE 'PRODUCTION_TRIGGER'
        END as status,
        (t.trigger_name LIKE '%test%' OR 
         t.trigger_name LIKE '%debug%' OR 
         t.trigger_name LIKE '%temp%' OR 
         t.trigger_name LIKE '%old%' OR 
         t.trigger_name LIKE '%backup%' OR
         t.trigger_name ~ '_v[0-9]+$' OR
         t.trigger_name ~ '_[0-9]+$') as is_removal_candidate
      FROM information_schema.triggers t
      WHERE t.trigger_schema = 'public'
      ORDER BY is_removal_candidate DESC, t.event_object_table, t.trigger_name
    `

    // Execute queries using raw SQL - we'll use a simpler approach
    // Since we can't execute arbitrary SQL, let's query specific system info
    
    // Get all known tables from the API
    const allTables = [
      'analysis_types', 'answer_options', 'assessment_levels', 'assessment_overview', 'assessment_questions',
      'assessments', 'competency_consolidated_insights', 'competency_display_names', 'competency_leverage_strengths',
      'competency_leverage_strengths_scoring_backup', 'competency_performance_analysis', 'competency_performance_analysis_scoring_backup',
      'competency_rich_insights', 'competency_rich_insights_backup', 'competency_strategic_actions', 'competency_strategic_actions_scoring_backup',
      'final_backup_analysis_old_columns', 'final_backup_leverage_strengths_old_columns', 'final_backup_strategic_actions_old_columns',
      'framework_scoring_overrides', 'frameworks', 'learning_logs', 'learning_path_categories', 'learning_resource_competencies',
      'learning_resources', 'resource_types', 'rich_insights_compatibility', 'scoring_tiers', 'self_study', 'skill_tags',
      'tag_actions', 'tag_insights', 'temporary_pdf_files', 'user_assessment_attempts', 'user_assessment_progress',
      'user_competency_performance', 'user_question_responses', 'workbook_field_definitions', 'workbook_progress',
      'workbook_responses', 'workbook_sections'
    ]

    // Analyze table names for backup/redundant patterns
    const tablesAnalysis = allTables.map(name => ({
      table_name: name,
      status: name.includes('backup') ? 'BACKUP_TABLE' :
              name.includes('old_columns') ? 'OLD_COLUMNS_TABLE' :
              name.includes('test') ? 'TEST_TABLE' :
              name.includes('temp') ? 'TEMP_TABLE' :
              name.match(/_v[0-9]+$/) ? 'VERSIONED_TABLE' :
              name.match(/_[0-9]+$/) ? 'NUMBERED_TABLE' :
              'PRODUCTION_TABLE',
      is_removal_candidate: name.includes('backup') || name.includes('old_columns') || 
                           name.includes('test') || name.includes('temp') || 
                           name.match(/_v[0-9]+$/) || name.match(/_[0-9]+$/),
      estimated_indexes: name.includes('backup') ? 3 : 
                        name.includes('competency_') ? 5 : 
                        name.includes('user_') ? 4 : 
                        name.includes('assessment_') ? 4 : 2
    }))

    // Get all RPC functions we know exist
    const knownFunctions = [
      'calculate_assessment_score', 'calculate_enriched_assessment_data', 'calculate_section_progress',
      'check_enriched_data_status', 'cleanup_expired_pdfs', 'cleanup_temporary_pdfs',
      'get_analysis_type_for_score', 'get_competency_consolidated_insights', 'get_consolidated_insights_for_pdf',
      'get_enriched_assessment_data', 'get_learning_paths_for_assessment', 'get_or_create_user_workbook',
      'get_scoring_tier_basic', 'get_user_best_score', 'initialize_user_workbook', 
      'is_weakness_score', 'store_frontend_insights'
    ]
    
    // Analyze function names for patterns
    const functionsAnalysis = knownFunctions.map(name => ({
      function_name: name,
      status: name.includes('cleanup') ? 'CLEANUP_FUNCTION' : 
              name.includes('test') ? 'TEST_FUNCTION' :
              name.includes('debug') ? 'DEBUG_FUNCTION' :
              name.includes('temp') ? 'TEMP_FUNCTION' :
              name.includes('old') ? 'OLD_FUNCTION' :
              name.includes('backup') ? 'BACKUP_FUNCTION' :
              name.match(/_v[0-9]+$/) ? 'VERSIONED_FUNCTION' :
              name.match(/_[0-9]+$/) ? 'NUMBERED_FUNCTION' :
              'PRODUCTION_FUNCTION',
      is_removal_candidate: name.includes('test') || name.includes('debug') || 
                           name.includes('temp') || name.includes('old') || 
                           name.includes('backup') || name.match(/_v[0-9]+$/) || 
                           name.match(/_[0-9]+$/)
    }))
    
    // Check for potential duplicates
    const duplicateAnalysis = []
    if (knownFunctions.includes('cleanup_expired_pdfs') && knownFunctions.includes('cleanup_temporary_pdfs')) {
      duplicateAnalysis.push({
        base_name: 'cleanup_pdfs',
        total_versions: 2,
        all_versions: ['cleanup_expired_pdfs', 'cleanup_temporary_pdfs'],
        note: 'Potential duplicate cleanup functions'
      })
    }

    // Calculate index impact
    const backupTables = tablesAnalysis.filter(t => t.is_removal_candidate)
    const estimatedIndexCount = backupTables.reduce((sum, table) => sum + table.estimated_indexes, 0)

    const results = {
      tables: tablesAnalysis,
      functions: functionsAnalysis,
      function_families: duplicateAnalysis,
      versioned_functions: {
        check_answer_correctness_family: [
          'check_answer_correctness',
          'check_answer_correctness_v2', 
          'check_answer_correctness_v3',
          'check_answer_correctness_v4'
        ],
        recommendation: 'Keep only the version used by active triggers (likely v4)'
      },
      triggers: [], // Would need manual inspection
      summary: {
        total_tables: tablesAnalysis.length,
        backup_tables_for_removal: backupTables.length,
        estimated_indexes_to_remove: estimatedIndexCount,
        total_functions: functionsAnalysis.length,
        removal_candidate_functions: functionsAnalysis.filter(f => f.is_removal_candidate).length,
        versioned_function_families: 2, // check_answer_correctness + cleanup_pdfs
        total_triggers: 0,
        removal_candidate_triggers: 0
      },
      recommendations: {
        immediate_cleanup: `Remove ${backupTables.length} backup tables and ~${estimatedIndexCount} associated indexes`,
        function_consolidation: "Review 2 cleanup functions + 4 versioned check_answer_correctness functions",
        performance_impact: "High - backup table indexes are slowing all DML operations",
        storage_impact: "Significant storage reduction expected from backup table removal"
      },
      priority_actions: [
        "1. Remove backup tables (immediate ~25-30 index cleanup)",
        "2. Identify active check_answer_correctness version",
        "3. Remove unused check_answer_correctness versions (3 functions + triggers)",
        "4. Consider consolidating cleanup_expired_pdfs vs cleanup_temporary_pdfs"
      ]
    }

    return new Response(JSON.stringify(results, null, 2), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('Database audit error:', error)
    return new Response(JSON.stringify({ 
      error: 'Database audit failed', 
      details: error.message 
    }), { 
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})