import { createClient } from '@supabase/supabase-js'

// Singleton Supabase client to avoid multiple instances
let supabaseClient = null

export function useSupabase() {
  if (!supabaseClient) {
    supabaseClient = createClient(
      import.meta.env.VITE_SUPABASE_URL,
      import.meta.env.VITE_SUPABASE_ANON_KEY
    )
  }
  
  return {
    supabase: supabaseClient
  }
}