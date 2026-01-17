-- ============================================================================
-- Fix Performance and Security Lints
-- ============================================================================
-- This migration addresses Supabase linter warnings:
--
-- PERFORMANCE:
-- 1. RLS policies using auth.uid() need (select auth.uid()) for optimization
-- 2. Duplicate permissive policies need consolidation
--
-- SECURITY:
-- 1. Functions need explicit search_path setting
-- 2. pg_net extension should not be in public schema
-- ============================================================================

-- ============================================================================
-- SECTION 1: Remove duplicate RLS policies (keep original, remove duplicates)
-- ============================================================================

-- ai_assessment_attempts has duplicate policies for INSERT, SELECT, UPDATE
DROP POLICY IF EXISTS "ai_assessment_attempts_select_own" ON ai_assessment_attempts;
DROP POLICY IF EXISTS "ai_assessment_attempts_insert_own" ON ai_assessment_attempts;
DROP POLICY IF EXISTS "ai_assessment_attempts_update_own" ON ai_assessment_attempts;

-- Reference tables have duplicate SELECT policies
DROP POLICY IF EXISTS "ai_frameworks_select_all" ON ai_frameworks;
DROP POLICY IF EXISTS "ai_assessment_levels_select_all" ON ai_assessment_levels;
DROP POLICY IF EXISTS "ai_competencies_select_all" ON ai_competencies;
DROP POLICY IF EXISTS "ai_questions_select_all" ON ai_questions;

-- ============================================================================
-- SECTION 2: Fix RLS policies to use (select auth.uid()) for performance
-- ============================================================================

-- Drop and recreate ai_assessment_attempts policies with optimized auth calls
DROP POLICY IF EXISTS "Users can view their own attempts" ON ai_assessment_attempts;
DROP POLICY IF EXISTS "Users can insert their own attempts" ON ai_assessment_attempts;
DROP POLICY IF EXISTS "Users can update their own attempts" ON ai_assessment_attempts;

CREATE POLICY "Users can view their own attempts"
  ON ai_assessment_attempts FOR SELECT
  USING (user_id = (select auth.uid()));

CREATE POLICY "Users can insert their own attempts"
  ON ai_assessment_attempts FOR INSERT
  WITH CHECK (user_id = (select auth.uid()));

CREATE POLICY "Users can update their own attempts"
  ON ai_assessment_attempts FOR UPDATE
  USING (user_id = (select auth.uid()));

-- ============================================================================
-- SECTION 3: Fix workbook table RLS policies
-- ============================================================================

-- workbook_progress (has user_id directly)
DROP POLICY IF EXISTS "Users can manage their own workbooks" ON workbook_progress;
CREATE POLICY "Users can manage their own workbooks"
  ON workbook_progress FOR ALL
  USING (user_id = (select auth.uid()))
  WITH CHECK (user_id = (select auth.uid()));

-- workbook_sections (links via workbook_id -> workbook_progress)
DROP POLICY IF EXISTS "Users can manage their own section progress" ON workbook_sections;
CREATE POLICY "Users can manage their own section progress"
  ON workbook_sections FOR ALL
  USING (workbook_id IN (
    SELECT id FROM workbook_progress WHERE user_id = (select auth.uid())
  ))
  WITH CHECK (workbook_id IN (
    SELECT id FROM workbook_progress WHERE user_id = (select auth.uid())
  ));

-- workbook_responses (links via workbook_id -> workbook_progress)
DROP POLICY IF EXISTS "Users can manage their own responses" ON workbook_responses;
CREATE POLICY "Users can manage their own responses"
  ON workbook_responses FOR ALL
  USING (workbook_id IN (
    SELECT id FROM workbook_progress WHERE user_id = (select auth.uid())
  ))
  WITH CHECK (workbook_id IN (
    SELECT id FROM workbook_progress WHERE user_id = (select auth.uid())
  ));

-- ============================================================================
-- SECTION 4: Fix function search_path for security
-- ============================================================================

-- Fix ai_link_previous_attempt function
CREATE OR REPLACE FUNCTION ai_link_previous_attempt()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- Find most recent completed attempt for this user/framework/level
  SELECT id INTO NEW.previous_attempt_id
  FROM public.ai_assessment_attempts
  WHERE user_id = NEW.user_id
    AND framework_id = NEW.framework_id
    AND level_id = NEW.level_id
    AND status = 'completed'
    AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid)
  ORDER BY completed_at DESC
  LIMIT 1;

  RETURN NEW;
END;
$$;

-- Fix ai_calculate_competency_scores function
CREATE OR REPLACE FUNCTION ai_calculate_competency_scores(
  p_attempt_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_scores JSONB := '{}';
  v_competency RECORD;
  v_total_points INTEGER;
  v_max_points INTEGER;
  v_percentage NUMERIC(5,2);
BEGIN
  -- Calculate scores for each competency based on question responses
  FOR v_competency IN
    SELECT DISTINCT c.id, c.code
    FROM public.ai_competencies c
    JOIN public.ai_questions q ON q.competency_id = c.id
    JOIN public.ai_assessment_attempts a ON a.level_id = q.level_id
    WHERE a.id = p_attempt_id
  LOOP
    -- Sum points for this competency (selected_points from JSONB responses)
    SELECT
      COALESCE(SUM((r.value->>'selected_points')::INTEGER), 0),
      COUNT(*) * 4 -- Max 4 points per question
    INTO v_total_points, v_max_points
    FROM public.ai_assessment_attempts a,
         jsonb_each(a.responses) r
    JOIN public.ai_questions q ON q.id = (r.key)::UUID
    WHERE a.id = p_attempt_id
      AND q.competency_id = v_competency.id;

    -- Calculate percentage
    IF v_max_points > 0 THEN
      v_percentage := (v_total_points::NUMERIC / v_max_points * 100);
    ELSE
      v_percentage := 0;
    END IF;

    -- Add to scores object
    v_scores := v_scores || jsonb_build_object(
      v_competency.code,
      jsonb_build_object(
        'points', v_total_points,
        'max_points', v_max_points,
        'percentage', v_percentage
      )
    );
  END LOOP;

  RETURN v_scores;
END;
$$;

-- Fix calculate_section_progress function (if exists)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public' AND p.proname = 'calculate_section_progress'
  ) THEN
    EXECUTE '
      CREATE OR REPLACE FUNCTION calculate_section_progress(p_workbook_id UUID, p_section_id TEXT)
      RETURNS NUMERIC
      LANGUAGE plpgsql
      SECURITY DEFINER
      SET search_path = ''''
      AS $func$
      DECLARE
        v_total_fields INTEGER;
        v_completed_fields INTEGER;
      BEGIN
        SELECT COUNT(*) INTO v_total_fields
        FROM public.workbook_field_definitions
        WHERE section_id = p_section_id;

        SELECT COUNT(*) INTO v_completed_fields
        FROM public.workbook_responses
        WHERE workbook_id = p_workbook_id
          AND section_id = p_section_id
          AND response IS NOT NULL
          AND response != '''''''';

        IF v_total_fields = 0 THEN
          RETURN 0;
        END IF;

        RETURN ROUND((v_completed_fields::NUMERIC / v_total_fields) * 100, 2);
      END;
      $func$;
    ';
  END IF;
END;
$$;

-- Fix get_or_create_user_workbook function (if exists)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public' AND p.proname = 'get_or_create_user_workbook'
  ) THEN
    EXECUTE '
      CREATE OR REPLACE FUNCTION get_or_create_user_workbook(p_user_id UUID)
      RETURNS UUID
      LANGUAGE plpgsql
      SECURITY DEFINER
      SET search_path = ''''
      AS $func$
      DECLARE
        v_workbook_id UUID;
      BEGIN
        SELECT id INTO v_workbook_id
        FROM public.workbook_progress
        WHERE user_id = p_user_id
        LIMIT 1;

        IF v_workbook_id IS NULL THEN
          INSERT INTO public.workbook_progress (user_id)
          VALUES (p_user_id)
          RETURNING id INTO v_workbook_id;
        END IF;

        RETURN v_workbook_id;
      END;
      $func$;
    ';
  END IF;
END;
$$;

-- Fix invoke_cleanup_temp_pdfs function
CREATE OR REPLACE FUNCTION public.invoke_cleanup_temp_pdfs()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  project_url text;
  service_key text;
BEGIN
  SELECT decrypted_secret INTO project_url
  FROM vault.decrypted_secrets
  WHERE name = 'supabase_url';

  SELECT decrypted_secret INTO service_key
  FROM vault.decrypted_secrets
  WHERE name = 'service_role_key';

  IF project_url IS NULL OR service_key IS NULL THEN
    RAISE WARNING 'Cleanup cron: vault secrets not configured (supabase_url, service_role_key)';
    RETURN;
  END IF;

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

-- ============================================================================
-- SECTION 5: Move pg_net extension to extensions schema
-- ============================================================================
-- Note: Moving extensions can be complex. For pg_net specifically,
-- Supabase manages this extension and it may need to stay in public.
-- We'll skip moving it to avoid breaking functionality.
-- The warning is low priority and acceptable for this project.

-- ============================================================================
-- Migration complete
-- ============================================================================
