import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

// CORS headers - match ForwardFocus exactly for public access
const corsHeaders = {
  'Access-Control-Allow-Origin': 'https://www.yourcoachinghub.co.uk',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    console.log('🧹 Starting temporary PDF cleanup...')
    
    // Get Supabase credentials
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || Deno.env.get('SUPABASE_ANON_KEY')
    
    if (!supabaseUrl || !supabaseServiceKey) {
      return new Response('Server configuration error', { 
        status: 500,
        headers: corsHeaders  
      })
    }

    // Calculate cutoff date (7 days ago)
    const cutoffDate = new Date()
    cutoffDate.setDate(cutoffDate.getDate() - 7)
    
    console.log(`🗓️ Cleaning up PDFs older than: ${cutoffDate.toISOString()}`)

    // Get expired PDF records from database (more reliable than scanning storage)
    const dbResponse = await fetch(`${supabaseUrl}/rest/v1/temporary_pdf_files?expires_at=lt.${new Date().toISOString()}&select=file_path,download_token,id`, {
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': `Bearer ${supabaseServiceKey}`,
        'Content-Type': 'application/json'
      }
    })

    if (!dbResponse.ok) {
      console.error('❌ Failed to query expired PDFs:', dbResponse.status)
      return new Response('Failed to query database', { 
        status: 500,
        headers: corsHeaders 
      })
    }

    const expiredRecords = await dbResponse.json()
    console.log(`📁 Found ${expiredRecords.length} expired PDF records to clean up`)

    const filesToDelete = expiredRecords

    console.log(`🗑️ Found ${filesToDelete.length} old assessment PDFs to delete`)

    if (filesToDelete.length === 0) {
      return new Response(
        JSON.stringify({ 
          success: true,
          message: 'No files to delete',
          filesChecked: expiredRecords.length,
          filesDeleted: 0
        }),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Delete files and database records
    let deletedCount = 0
    let dbDeletedCount = 0
    
    const deletePromises = filesToDelete.map(async (record: any) => {
      try {
        // Delete from storage using the full path stored in database
        const deleteResponse = await fetch(`${supabaseUrl}/storage/v1/object/temporary-pdfs/${record.file_path}`, {
          method: 'DELETE',
          headers: {
            'apikey': supabaseServiceKey,
            'Authorization': `Bearer ${supabaseServiceKey}`,
          }
        })
        
        let storageDeleted = false
        if (deleteResponse.ok) {
          deletedCount++
          storageDeleted = true
          console.log(`✅ Deleted from storage: ${record.file_path}`)
        } else {
          console.error(`❌ Failed to delete from storage ${record.file_path}:`, deleteResponse.status)
        }
        
        // Delete database record regardless of storage deletion result (cleanup orphaned records)
        const dbDeleteResponse = await fetch(`${supabaseUrl}/rest/v1/temporary_pdf_files?id=eq.${record.id}`, {
          method: 'DELETE',
          headers: {
            'apikey': supabaseServiceKey,
            'Authorization': `Bearer ${supabaseServiceKey}`,
          }
        })
        
        if (dbDeleteResponse.ok) {
          dbDeletedCount++
          console.log(`✅ Deleted database record: ${record.id}`)
        } else {
          console.error(`❌ Failed to delete database record ${record.id}:`, dbDeleteResponse.status)
        }
        
        return { storageDeleted, dbDeleted: dbDeleteResponse.ok }
      } catch (error) {
        console.error(`❌ Error deleting ${record.file_path}:`, error)
        return { storageDeleted: false, dbDeleted: false }
      }
    })

    await Promise.allSettled(deletePromises)

    console.log(`✅ Cleanup completed. Deleted ${deletedCount} files, ${dbDeletedCount} database records`)

    return new Response(
      JSON.stringify({ 
        success: true,
        message: `Cleanup completed successfully`,
        expiredRecordsFound: expiredRecords.length,
        storageFilesDeleted: deletedCount,
        databaseRecordsDeleted: dbDeletedCount,
        cutoffDate: new Date().toISOString()
      }),
      { 
        headers: { 
          ...corsHeaders, 
          'Content-Type': 'application/json' 
        } 
      }
    )

  } catch (error) {
    console.error('❌ Cleanup error:', error)
    return new Response(
      JSON.stringify({ 
        error: 'Cleanup failed', 
        details: error.message 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})