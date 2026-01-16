import { createClient } from '@supabase/supabase-js'

// Admin Supabase client with service role key for admin operations
let adminSupabaseClient = null

export function useAdminSupabase() {
  if (!adminSupabaseClient) {
    // Use environment variables, fallback to production if not available
    const serviceRoleKey = import.meta.env.VITE_SUPABASE_SERVICE_ROLE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU'
    const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54321'
    
    console.log('Admin Supabase setup:', {
      url: supabaseUrl,
      keyPrefix: serviceRoleKey.substring(0, 30) + '...',
      envAvailable: {
        VITE_SUPABASE_URL: import.meta.env.VITE_SUPABASE_URL,
        VITE_SERVICE_ROLE: !!import.meta.env.VITE_SUPABASE_SERVICE_ROLE_KEY,
        NODE_ENV: import.meta.env.NODE_ENV,
        MODE: import.meta.env.MODE
      }
    })
    
    adminSupabaseClient = createClient(
      supabaseUrl,
      serviceRoleKey,
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    )
  }
  
  return {
    adminSupabase: adminSupabaseClient
  }
}