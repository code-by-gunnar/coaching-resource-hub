import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1'

// CORS headers - match ForwardFocus exactly for public downloads
const corsHeaders = {
  'Access-Control-Allow-Origin': 'https://www.yourcoachinghub.co.uk',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
}


serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Parse URL parameters
    const url = new URL(req.url)
    const downloadToken = url.searchParams.get('token')
    
    console.log('📥 PDF download request with token:', { hasToken: !!downloadToken })

    if (!downloadToken) {
      return new Response('Missing download token', { 
        status: 400,
        headers: corsHeaders
      })
    }

    // Initialize Supabase client with service role for full access
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    
    if (!supabaseUrl || !supabaseServiceKey) {
      return new Response('Server configuration error', { 
        status: 500,
        headers: corsHeaders  
      })
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Look up PDF record by token using Supabase client
    console.log('🔍 Looking up PDF record by token...')
    const { data: record, error: recordError } = await supabase
      .from('temporary_pdf_files')
      .select('*')
      .eq('download_token', downloadToken)
      .gt('expires_at', new Date().toISOString())
      .single()

    if (recordError || !record) {
      console.error('❌ Token lookup failed:', recordError?.message || 'No record found')
      return new Response('Invalid or expired token', { 
        status: 404,
        headers: corsHeaders
      })
    }

    const pdfPath = `temporary-pdfs/${record.filename}`
    console.log('📄 Found PDF record:', { filename: record.filename, attempts: record.attempt_id })
    
    // Fetch PDF from storage
    console.log('📥 Fetching PDF from storage:', pdfPath)
    const storageUrl = `${supabaseUrl}/storage/v1/object/public/${pdfPath}`
    const pdfResponse = await fetch(storageUrl)
    
    if (!pdfResponse.ok) {
      console.error('❌ PDF not found in storage')
      return new Response('PDF not found', { 
        status: 404,
        headers: corsHeaders
      })
    }
    
    const pdfBuffer = await pdfResponse.arrayBuffer()
    
    // Update download tracking
    console.log('📊 Updating download tracking...')
    await supabase
      .from('temporary_pdf_files')
      .update({
        download_count: (record.download_count || 0) + 1,
        last_downloaded_at: new Date().toISOString()
      })
      .eq('id', record.id)
    
    console.log('✅ Serving PDF from storage')
    return new Response(pdfBuffer, {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/pdf',
        'Content-Disposition': `attachment; filename="assessment-report-${record.attempt_id}.pdf"`
      }
    })

  } catch (error) {
    console.error('❌ Download error:', error)
    return new Response('Internal server error', { 
      status: 500,
      headers: corsHeaders
    })
  }
})

