import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.0.0'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface RequestBody {
  type: 'functions' | 'indexes' | 'summary'
}

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { type }: RequestBody = await req.json()

    let query = ''
    
    switch (type) {
      case 'functions':
        query = `
          SELECT 
              f.proname::text as function_name,
              pg_get_function_result(f.oid)::text as return_type,
              f.pronargs as num_arguments,
              CASE 
                  WHEN length(f.prosrc) > 200 THEN left(f.prosrc, 200) || '...'
                  ELSE f.prosrc 
              END::text as function_source,
              CASE 
                  WHEN f.proname LIKE '%test%' THEN 'TEST FUNCTION - CANDIDATE FOR REMOVAL'
                  WHEN f.proname LIKE '%debug%' THEN 'DEBUG FUNCTION - CANDIDATE FOR REMOVAL'  
                  WHEN f.proname LIKE '%temp%' THEN 'TEMP FUNCTION - CANDIDATE FOR REMOVAL'
                  WHEN f.proname LIKE '%old%' THEN 'OLD FUNCTION - CANDIDATE FOR REMOVAL'
                  WHEN f.proname LIKE '%backup%' THEN 'BACKUP FUNCTION - CANDIDATE FOR REMOVAL'
                  WHEN f.proname ~ '_[0-9]+$' THEN 'NUMBERED FUNCTION - LIKELY TEST'
                  ELSE 'PRODUCTION FUNCTION - REVIEW NEEDED'
              END::text as audit_recommendation
          FROM pg_proc f
          JOIN pg_namespace n ON f.pronamespace = n.oid 
          WHERE n.nspname = 'public'
          AND f.proname NOT IN ('extensions', 'version')
          ORDER BY 
              CASE 
                  WHEN f.proname LIKE '%test%' THEN 1
                  WHEN f.proname LIKE '%debug%' THEN 1
                  WHEN f.proname LIKE '%temp%' THEN 1
                  WHEN f.proname LIKE '%old%' THEN 1
                  WHEN f.proname LIKE '%backup%' THEN 1
                  ELSE 2
              END,
              f.proname;
        `
        break
        
      case 'indexes':
        query = `
          SELECT 
              schemaname::text,
              tablename::text,
              indexname::text,
              indexdef::text,
              CASE 
                  WHEN indexname LIKE '%test%' THEN 'TEST INDEX - CANDIDATE FOR REMOVAL'
                  WHEN indexname LIKE '%debug%' THEN 'DEBUG INDEX - CANDIDATE FOR REMOVAL'
                  WHEN indexname LIKE '%temp%' THEN 'TEMP INDEX - CANDIDATE FOR REMOVAL'
                  WHEN indexname LIKE '%old%' THEN 'OLD INDEX - CANDIDATE FOR REMOVAL'
                  WHEN indexname LIKE '%backup%' THEN 'BACKUP INDEX - CANDIDATE FOR REMOVAL'
                  WHEN indexname LIKE '%duplicate%' THEN 'DUPLICATE INDEX - CANDIDATE FOR REMOVAL'
                  WHEN indexname ~ '_[0-9]+$' THEN 'NUMBERED INDEX - LIKELY TEST'
                  WHEN indexname LIKE '%_pkey' THEN 'PRIMARY KEY - KEEP'
                  WHEN indexname LIKE '%_key' THEN 'UNIQUE KEY - REVIEW'
                  ELSE 'CUSTOM INDEX - REVIEW NEEDED'
              END::text as audit_recommendation
          FROM pg_indexes 
          WHERE schemaname = 'public'
          ORDER BY 
              CASE 
                  WHEN indexname LIKE '%test%' THEN 1
                  WHEN indexname LIKE '%debug%' THEN 1
                  WHEN indexname LIKE '%temp%' THEN 1
                  WHEN indexname LIKE '%old%' THEN 1
                  WHEN indexname LIKE '%backup%' THEN 1
                  WHEN indexname LIKE '%duplicate%' THEN 1
                  WHEN indexname ~ '_[0-9]+$' THEN 2
                  ELSE 3
              END,
              tablename,
              indexname;
        `
        break
        
      case 'summary':
        query = `
          SELECT 
              'FUNCTIONS'::text as object_type,
              COUNT(*) as total_count,
              COUNT(*) FILTER (WHERE proname LIKE '%test%' OR proname LIKE '%debug%' OR proname LIKE '%temp%' OR proname LIKE '%old%' OR proname LIKE '%backup%') as candidates_for_removal
          FROM pg_proc f
          JOIN pg_namespace n ON f.pronamespace = n.oid 
          WHERE n.nspname = 'public'
          
          UNION ALL
          
          SELECT 
              'INDEXES'::text as object_type,
              COUNT(*) as total_count,
              COUNT(*) FILTER (WHERE indexname LIKE '%test%' OR indexname LIKE '%debug%' OR indexname LIKE '%temp%' OR indexname LIKE '%old%' OR indexname LIKE '%backup%' OR indexname ~ '_[0-9]+$') as candidates_for_removal
          FROM pg_indexes 
          WHERE schemaname = 'public'
          
          ORDER BY object_type;
        `
        break
        
      default:
        return new Response(JSON.stringify({ error: 'Invalid audit type' }), { 
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        })
    }

    const { data, error } = await supabase.rpc('exec_sql', { query })
    
    if (error) {
      console.error('Database error:', error)
      return new Response(JSON.stringify({ error: 'Database query failed', details: error }), { 
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    return new Response(JSON.stringify({ data }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('Function error:', error)
    return new Response(JSON.stringify({ error: 'Internal server error', details: error.message }), { 
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})