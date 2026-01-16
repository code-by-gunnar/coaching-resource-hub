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

    const { action } = await req.json()

    if (action !== 'EXECUTE_CLEANUP') {
      return new Response(JSON.stringify({ error: 'Invalid action' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    const results = []

    // Verify main tables are healthy first
    const verifyQueries = [
      'SELECT COUNT(*) as count FROM competency_strategic_actions WHERE is_active = true',
      'SELECT COUNT(*) as count FROM competency_leverage_strengths WHERE is_active = true', 
      'SELECT COUNT(*) as count FROM competency_performance_analysis WHERE is_active = true'
    ]

    for (const query of verifyQueries) {
      const { data, error } = await supabase.rpc('exec_sql', { query })
      if (error || !data || data[0]?.count === 0) {
        return new Response(JSON.stringify({ 
          error: 'Main tables verification failed - aborting cleanup',
          details: error
        }), {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        })
      }
      results.push(`Verified ${data[0].count} records in table`)
    }

    // Execute cleanup operations
    const cleanupTables = [
      'competency_strategic_actions_scoring_backup',
      'competency_performance_analysis_scoring_backup',
      'competency_leverage_strengths_scoring_backup',
      'competency_rich_insights_backup',
      'final_backup_strategic_actions_old_columns',
      'final_backup_leverage_strengths_old_columns',
      'final_backup_analysis_old_columns'
    ]

    let removedTables = 0
    for (const table of cleanupTables) {
      try {
        const { error } = await supabase.rpc('exec_sql', { 
          query: `DROP TABLE IF EXISTS ${table}` 
        })
        if (!error) {
          results.push(`✅ Removed table: ${table}`)
          removedTables++
        } else {
          results.push(`⚠️ Failed to remove ${table}: ${error.message}`)
        }
      } catch (e) {
        results.push(`⚠️ Error removing ${table}: ${e.message}`)
      }
    }

    return new Response(JSON.stringify({
      success: true,
      tables_removed: removedTables,
      estimated_indexes_removed: removedTables * 3,
      results: results,
      performance_impact: 'Immediate improvement in DML operations expected',
      next_steps: [
        'Review check_answer_correctness function versions',
        'Consider consolidating cleanup_expired_pdfs vs cleanup_temporary_pdfs',
        'Monitor application performance improvements'
      ]
    }, null, 2), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('Cleanup execution error:', error)
    return new Response(JSON.stringify({ 
      error: 'Cleanup execution failed', 
      details: error.message 
    }), { 
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})