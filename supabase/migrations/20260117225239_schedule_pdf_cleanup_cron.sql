-- Enable required extensions for scheduled HTTP calls
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

-- Create a wrapper function that calls the cleanup edge function
-- This function retrieves the service role key from vault
CREATE OR REPLACE FUNCTION public.invoke_cleanup_temp_pdfs()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  project_url text;
  service_key text;
BEGIN
  -- Get the Supabase project URL and service role key from vault
  -- These must be added to vault via Supabase dashboard:
  -- INSERT INTO vault.secrets (name, secret) VALUES ('supabase_url', 'https://your-project.supabase.co');
  -- INSERT INTO vault.secrets (name, secret) VALUES ('service_role_key', 'your-service-role-key');

  SELECT decrypted_secret INTO project_url
  FROM vault.decrypted_secrets
  WHERE name = 'supabase_url';

  SELECT decrypted_secret INTO service_key
  FROM vault.decrypted_secrets
  WHERE name = 'service_role_key';

  -- If secrets not configured, log and exit
  IF project_url IS NULL OR service_key IS NULL THEN
    RAISE WARNING 'Cleanup cron: vault secrets not configured (supabase_url, service_role_key)';
    RETURN;
  END IF;

  -- Call the cleanup edge function
  PERFORM net.http_post(
    url := project_url || '/functions/v1/cleanup-temp-pdfs',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || service_key
    ),
    body := '{}'::jsonb
  );

  RAISE LOG 'Cleanup cron: initiated cleanup-temp-pdfs edge function';
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.invoke_cleanup_temp_pdfs() TO postgres;

-- Schedule daily cleanup at 3 AM UTC
SELECT cron.schedule(
  'cleanup-temp-pdfs-daily',
  '0 3 * * *',
  'SELECT public.invoke_cleanup_temp_pdfs();'
);

-- Add helpful comment
COMMENT ON FUNCTION public.invoke_cleanup_temp_pdfs() IS
  'Wrapper function to call cleanup-temp-pdfs edge function. Requires vault secrets: supabase_url and service_role_key';
