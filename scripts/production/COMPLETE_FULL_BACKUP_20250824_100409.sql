

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."auto_calculate_score"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
BEGIN
    -- Only calculate when status changes to 'completed'
    IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status <> 'completed') THEN
        PERFORM public.calculate_assessment_score(NEW.id);
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."auto_calculate_score"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calculate_assessment_score"("attempt_uuid" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
    total_q integer;
    correct_q integer;
    score_pct integer;
BEGIN
    -- Get total questions for this attempt
    SELECT ua.total_questions INTO total_q
    FROM public.user_assessment_attempts ua
    WHERE ua.id = attempt_uuid;
    
    -- Count correct answers
    SELECT COUNT(*) INTO correct_q
    FROM public.user_question_responses uqr
    WHERE uqr.attempt_id = attempt_uuid AND uqr.is_correct = true;
    
    -- Calculate percentage score
    IF total_q > 0 THEN
        score_pct := ROUND((correct_q::decimal / total_q::decimal) * 100);
    ELSE
        score_pct := 0;
    END IF;
    
    -- Update the attempt record
    UPDATE public.user_assessment_attempts 
    SET 
        score = score_pct,
        correct_answers = correct_q,
        updated_at = NOW()
    WHERE id = attempt_uuid;
END;
$$;


ALTER FUNCTION "public"."calculate_assessment_score"("attempt_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calculate_enriched_assessment_data"("attempt_uuid" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
    attempt_data RECORD;
    competency_data RECORD;
    enriched_json JSONB;
BEGIN
    -- Get attempt basic data
    SELECT * INTO attempt_data
    FROM public.user_assessment_attempts
    WHERE id = attempt_uuid;
    
    IF NOT FOUND THEN
        RETURN;
    END IF;
    
    -- Build enriched data structure
    enriched_json := jsonb_build_object(
        'attempt_id', attempt_uuid,
        'score', attempt_data.score,
        'completion_date', attempt_data.completed_at,
        'competency_analysis', jsonb_build_array(),
        'insights', jsonb_build_array(),
        'recommended_actions', jsonb_build_array(),
        'learning_resources', jsonb_build_array()
    );
    
    -- Update the attempt with enriched data
    UPDATE public.user_assessment_attempts
    SET enriched_data = enriched_json,
        updated_at = NOW()
    WHERE id = attempt_uuid;
END;
$$;


ALTER FUNCTION "public"."calculate_enriched_assessment_data"("attempt_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calculate_section_progress"("p_workbook_id" "uuid", "p_section_number" integer) RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_total_fields INTEGER;
    v_completed_fields INTEGER;
    v_progress INTEGER;
BEGIN
    -- Count total required fields for this section
    SELECT COUNT(*) INTO v_total_fields
    FROM workbook_field_definitions
    WHERE section_number = p_section_number
    AND is_required = true;
    
    -- If no required fields, check any fields
    IF v_total_fields = 0 THEN
        SELECT COUNT(*) INTO v_total_fields
        FROM workbook_field_definitions
        WHERE section_number = p_section_number;
    END IF;
    
    -- Count completed fields
    SELECT COUNT(*) INTO v_completed_fields
    FROM workbook_responses r
    JOIN workbook_field_definitions d ON r.field_key = d.field_key
    WHERE r.workbook_id = p_workbook_id
    AND d.section_number = p_section_number
    AND r.field_value IS NOT NULL
    AND (
        (r.field_type = 'text' AND length(r.field_value->>'value') > 0) OR
        (r.field_type = 'textarea' AND length(r.field_value->>'value') > 0) OR
        (r.field_type = 'list' AND jsonb_array_length(r.field_value->'items') > 0) OR
        (r.field_type = 'checkbox' AND (r.field_value->>'checked')::boolean = true)
    );
    
    -- Calculate percentage
    IF v_total_fields > 0 THEN
        v_progress := ROUND((v_completed_fields::NUMERIC / v_total_fields) * 100);
    ELSE
        v_progress := 0;
    END IF;
    
    -- Update section progress
    UPDATE workbook_sections
    SET progress_percent = v_progress,
        last_updated = now(),
        completed_at = CASE WHEN v_progress = 100 THEN now() ELSE NULL END
    WHERE workbook_id = p_workbook_id AND section_number = p_section_number;
    
    RETURN v_progress;
END;
$$;


ALTER FUNCTION "public"."calculate_section_progress"("p_workbook_id" "uuid", "p_section_number" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calculate_section_progress"("user_id_param" "uuid", "section_id_param" "uuid") RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    total_questions integer;
    answered_questions integer;
    progress_percentage integer;
BEGIN
    SELECT COUNT(*) INTO total_questions
    FROM public.workbook_field_definitions wfd
    WHERE wfd.section_id = section_id_param;
    
    SELECT COUNT(*) INTO answered_questions
    FROM public.workbook_responses wr
    JOIN public.workbook_field_definitions wfd ON wr.field_id = wfd.id
    WHERE wr.user_id = user_id_param 
    AND wfd.section_id = section_id_param
    AND wr.response_text IS NOT NULL
    AND wr.response_text != '';
    
    IF total_questions > 0 THEN
        progress_percentage := ROUND((answered_questions::numeric / total_questions::numeric) * 100);
    ELSE
        progress_percentage := 0;
    END IF;
    
    RETURN progress_percentage;
END;
$$;


ALTER FUNCTION "public"."calculate_section_progress"("user_id_param" "uuid", "section_id_param" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_answer_correctness_v4"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    -- Scenario 1: Frontend sends only text (selected_answer = 'A', selected_answer_option_id = NULL)
    IF NEW.selected_answer_option_id IS NULL AND NEW.selected_answer IS NOT NULL THEN
        NEW.selected_answer_option_id := CASE NEW.selected_answer
            WHEN 'A' THEN 1
            WHEN 'B' THEN 2
            WHEN 'C' THEN 3
            WHEN 'D' THEN 4
            ELSE NULL
        END;
        
        -- Validate the conversion worked
        IF NEW.selected_answer_option_id IS NULL THEN
            RAISE EXCEPTION 'Invalid selected_answer: %. Must be A, B, C, or D', NEW.selected_answer;
        END IF;
    END IF;
    
    -- Scenario 2: Future API sends only FK (selected_answer_option_id = 2, selected_answer = NULL) 
    IF NEW.selected_answer IS NULL AND NEW.selected_answer_option_id IS NOT NULL THEN
        NEW.selected_answer := (
            SELECT letter 
            FROM public.answer_options 
            WHERE id = NEW.selected_answer_option_id
        );
        
        -- Validate the FK exists
        IF NEW.selected_answer IS NULL THEN
            RAISE EXCEPTION 'Invalid selected_answer_option_id: %. Must be 1, 2, 3, or 4', NEW.selected_answer_option_id;
        END IF;
    END IF;
    
    -- Validate we have both values now
    IF NEW.selected_answer_option_id IS NULL OR NEW.selected_answer IS NULL THEN
        RAISE EXCEPTION 'Both selected_answer and selected_answer_option_id must be provided or derivable';
    END IF;
    
    -- Calculate correctness using FK (more reliable)
    NEW.is_correct := (NEW.selected_answer_option_id = (
        SELECT correct_answer_option_id 
        FROM public.assessment_questions 
        WHERE id = NEW.question_id
    ));
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."check_answer_correctness_v4"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_enriched_data_status"("attempt_uuid" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
    has_enriched_data boolean DEFAULT false;
BEGIN
    SELECT (enriched_data IS NOT NULL AND enriched_data != '{}'::jsonb) INTO has_enriched_data
    FROM public.user_assessment_attempts
    WHERE id = attempt_uuid;
    
    RETURN COALESCE(has_enriched_data, false);
END;
$$;


ALTER FUNCTION "public"."check_enriched_data_status"("attempt_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."cleanup_expired_pdfs"() RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    deleted_count integer;
BEGIN
    -- Delete expired PDF records
    DELETE FROM public.temporary_pdf_files
    WHERE expires_at < NOW();
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    -- Log cleanup for monitoring
    IF deleted_count > 0 THEN
        RAISE NOTICE 'PDF Cleanup: Deleted % expired records', deleted_count;
    END IF;
    
    RETURN deleted_count;
END;
$$;


ALTER FUNCTION "public"."cleanup_expired_pdfs"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."cleanup_temporary_pdfs"() RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
BEGIN
    PERFORM cleanup_expired_pdfs();
END;
$$;


ALTER FUNCTION "public"."cleanup_temporary_pdfs"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_analysis_type_for_score"("score_percentage" integer, "framework_code" "text" DEFAULT NULL::"text", "assessment_level_code" "text" DEFAULT NULL::"text") RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    analysis_type_code TEXT;
BEGIN
    -- Get the scoring tier for this percentage
    SELECT at.code INTO analysis_type_code
    FROM scoring_tiers st
    JOIN analysis_types at ON st.analysis_type_id = at.id
    WHERE score_percentage BETWEEN st.score_min AND st.score_max
    AND st.is_active = true
    AND at.is_active = true
    ORDER BY st.display_order
    LIMIT 1;
    
    -- Return the analysis type (weakness, developing, or strength)
    RETURN COALESCE(analysis_type_code, 'weakness'); -- Default to weakness if not found
END;
$$;


ALTER FUNCTION "public"."get_analysis_type_for_score"("score_percentage" integer, "framework_code" "text", "assessment_level_code" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_competency_consolidated_insights"("p_competency_id" "uuid", "p_framework_id" "uuid", "p_assessment_level_id" "uuid") RETURNS TABLE("analysis_type_code" "text", "performance_insight" "text", "development_focus" "text", "practical_application" "text")
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        at.code as analysis_type_code,
        cci.performance_insight,
        cci.development_focus,
        cci.practical_application
    FROM competency_consolidated_insights cci
    JOIN analysis_types at ON cci.analysis_type_id = at.id
    WHERE cci.competency_id = p_competency_id
      AND cci.framework_id = p_framework_id
      AND cci.assessment_level_id = p_assessment_level_id
      AND cci.is_active = true
    ORDER BY at.code; -- 'strength' comes before 'weakness' alphabetically
END;
$$;


ALTER FUNCTION "public"."get_competency_consolidated_insights"("p_competency_id" "uuid", "p_framework_id" "uuid", "p_assessment_level_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_consolidated_insights_for_pdf"("p_competency_id" "uuid", "p_framework_id" "uuid", "p_assessment_level_id" "uuid", "p_analysis_type_id" "uuid") RETURNS TABLE("performance_insight" "text", "development_focus" "text", "practical_application" "text")
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cci.performance_insight,
        cci.development_focus,
        cci.practical_application
    FROM competency_consolidated_insights cci
    WHERE cci.competency_id = p_competency_id
      AND cci.framework_id = p_framework_id
      AND cci.assessment_level_id = p_assessment_level_id
      AND cci.analysis_type_id = p_analysis_type_id
      AND cci.is_active = true;
END;
$$;


ALTER FUNCTION "public"."get_consolidated_insights_for_pdf"("p_competency_id" "uuid", "p_framework_id" "uuid", "p_assessment_level_id" "uuid", "p_analysis_type_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_enriched_assessment_data"("attempt_uuid" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
    enriched_data jsonb;
BEGIN
    SELECT ua.enriched_data INTO enriched_data
    FROM public.user_assessment_attempts ua
    WHERE ua.id = attempt_uuid;
    
    RETURN COALESCE(enriched_data, '{}'::jsonb);
END;
$$;


ALTER FUNCTION "public"."get_enriched_assessment_data"("attempt_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_learning_paths_for_assessment"("weak_competency_areas" "text"[], "overall_score" integer) RETURNS TABLE("category_id" "uuid", "category_title" "text", "category_description" "text", "category_icon" "text", "resources" json[])
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        lpc.id as category_id,
        lpc.category_title,
        lpc.category_description,
        lpc.category_icon,
        ARRAY(
            SELECT json_build_object(
                'title', lr.title,
                'description', lr.description,
                'resource_type', rt.code,
                'url', lr.url,
                'author', lr.author_instructor,
                'competency_areas', ARRAY(
                    SELECT cd.display_name 
                    FROM public.learning_resource_competencies lrc
                    JOIN public.competency_display_names cd ON lrc.competency_id = cd.id
                    WHERE lrc.learning_resource_id = lr.id
                )
            )
            FROM public.learning_resources lr
            LEFT JOIN public.resource_types rt ON lr.resource_type_id = rt.id
            WHERE lr.category_id = lpc.id
            AND lr.is_active = true
            ORDER BY rt.code, lr.title
        ) as resources
    FROM public.learning_path_categories lpc
    WHERE lpc.is_active = true
    AND lpc.assessment_level = 'core-i'
    -- Only show categories where competency areas overlap with weak areas
    AND lpc.competency_areas && weak_competency_areas
    ORDER BY lpc.priority_order, lpc.category_title;
END;
$$;


ALTER FUNCTION "public"."get_learning_paths_for_assessment"("weak_competency_areas" "text"[], "overall_score" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_learning_paths_for_assessment"("weak_competency_areas" "text"[], "overall_score" integer, "assessment_level" "text") RETURNS TABLE("category_id" "uuid", "category_title" "text", "category_description" "text", "category_icon" "text", "resources" json[])
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
    target_level_code text;
BEGIN
    -- Map frontend assessment level names to database level_code
    target_level_code := CASE 
        WHEN LOWER(assessment_level) = 'beginner' THEN 'beginner'
        WHEN LOWER(assessment_level) = 'intermediate' THEN 'intermediate'  
        WHEN LOWER(assessment_level) = 'advanced' THEN 'advanced'
        ELSE 'beginner'  -- Default to beginner for safety
    END;
    
    RETURN QUERY
    SELECT
        lpc.id as category_id,
        lpc.category_title,
        lpc.category_description,
        lpc.category_icon,
        ARRAY(
            SELECT json_build_object(
                'title', lr.title,
                'description', lr.description,
                'resource_type', rt.code,
                'url', lr.url,
                'author', lr.author_instructor,
                'competency_areas', ARRAY(
                    SELECT cd.display_name 
                    FROM public.learning_resource_competencies lrc
                    JOIN public.competency_display_names cd ON lrc.competency_id = cd.id
                    WHERE lrc.learning_resource_id = lr.id
                )
            )
            FROM public.learning_resources lr
            LEFT JOIN public.resource_types rt ON lr.resource_type_id = rt.id
            WHERE lr.category_id = lpc.id
            AND lr.is_active = true
            ORDER BY rt.code, lr.title
        ) as resources
    FROM public.learning_path_categories lpc
    JOIN public.assessment_levels al ON lpc.assessment_level_id = al.id
    WHERE lpc.is_active = true
    AND al.level_code = target_level_code  -- Dynamic assessment level matching
    -- Only show categories where competency areas overlap with weak areas
    AND lpc.competency_areas && weak_competency_areas
    ORDER BY lpc.priority_order, lpc.category_title;
END;
$$;


ALTER FUNCTION "public"."get_learning_paths_for_assessment"("weak_competency_areas" "text"[], "overall_score" integer, "assessment_level" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_or_create_user_workbook"("user_id_param" "uuid") RETURNS TABLE("id" "uuid", "user_id" "uuid", "progress_data" "jsonb", "created_at" timestamp with time zone, "updated_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    existing_workbook RECORD;
BEGIN
    SELECT w.id, w.user_id, w.progress_data, w.created_at, w.updated_at
    INTO existing_workbook
    FROM public.workbook_progress w
    WHERE w.user_id = user_id_param
    LIMIT 1;
    
    IF existing_workbook.id IS NOT NULL THEN
        RETURN QUERY
        SELECT existing_workbook.id, existing_workbook.user_id, 
               existing_workbook.progress_data, existing_workbook.created_at, 
               existing_workbook.updated_at;
    ELSE
        RETURN QUERY
        INSERT INTO public.workbook_progress (user_id, progress_data)
        VALUES (user_id_param, '{}'::jsonb)
        RETURNING workbook_progress.id, workbook_progress.user_id, 
                  workbook_progress.progress_data, workbook_progress.created_at, 
                  workbook_progress.updated_at;
    END IF;
END;
$$;


ALTER FUNCTION "public"."get_or_create_user_workbook"("user_id_param" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_scoring_tier_basic"("score_percentage" integer) RETURNS TABLE("tier_code" character varying, "tier_name" character varying, "score_min" integer, "score_max" integer)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    SELECT st.tier_code, st.tier_name, st.score_min, st.score_max
    FROM scoring_tiers st
    WHERE score_percentage BETWEEN st.score_min AND st.score_max
    AND st.is_active = true
    ORDER BY st.display_order
    LIMIT 1;
END;
$$;


ALTER FUNCTION "public"."get_scoring_tier_basic"("score_percentage" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_best_score"("user_uuid" "uuid", "assessment_uuid" "uuid") RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
    best_score integer;
BEGIN
    SELECT COALESCE(MAX(score), 0) INTO best_score
    FROM public.user_assessment_attempts
    WHERE user_id = user_uuid 
    AND assessment_id = assessment_uuid
    AND status = 'completed';
    
    RETURN best_score;
END;
$$;


ALTER FUNCTION "public"."get_user_best_score"("user_uuid" "uuid", "assessment_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."initialize_user_workbook"("user_id_param" "uuid") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    new_workbook_id uuid;
BEGIN
    INSERT INTO public.workbook_progress (user_id, progress_data)
    VALUES (user_id_param, '{}'::jsonb)
    RETURNING id INTO new_workbook_id;
    
    RETURN new_workbook_id;
END;
$$;


ALTER FUNCTION "public"."initialize_user_workbook"("user_id_param" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_weakness_score"("score_percentage" integer, "framework_code" "text" DEFAULT NULL::"text", "assessment_level_code" "text" DEFAULT NULL::"text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    analysis_type_code TEXT;
BEGIN
    SELECT get_analysis_type_for_score(score_percentage, framework_code, assessment_level_code) 
    INTO analysis_type_code;
    
    -- In 3-tier system, only 0-49% is considered "weakness"
    RETURN analysis_type_code = 'weakness';
END;
$$;


ALTER FUNCTION "public"."is_weakness_score"("score_percentage" integer, "framework_code" "text", "assessment_level_code" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."store_frontend_insights"("attempt_uuid" "uuid", "frontend_insights" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
BEGIN
    UPDATE public.user_assessment_attempts
    SET enriched_data = COALESCE(enriched_data, '{}'::jsonb) || store_frontend_insights.frontend_insights,
        updated_at = NOW()
    WHERE id = attempt_uuid;
    
    RETURN frontend_insights;
END;
$$;


ALTER FUNCTION "public"."store_frontend_insights"("attempt_uuid" "uuid", "frontend_insights" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_attempt_status"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
BEGIN
    -- Update the attempt status to 'in_progress' when first response is saved
    UPDATE public.user_assessment_attempts 
    SET 
        status = 'in_progress',
        updated_at = NOW()
    WHERE id = NEW.attempt_id 
      AND status = 'started';
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_attempt_status"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_workbook_progress_timestamp"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_workbook_progress_timestamp"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_workbook_response_timestamp"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_workbook_response_timestamp"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."analysis_types" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "text" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."analysis_types" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."answer_options" (
    "id" integer NOT NULL,
    "letter" character(1) NOT NULL,
    "display_order" integer NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "answer_options_display_order_check" CHECK ((("display_order" >= 1) AND ("display_order" <= 4))),
    CONSTRAINT "answer_options_letter_check" CHECK (("letter" = ANY (ARRAY['A'::"bpchar", 'B'::"bpchar", 'C'::"bpchar", 'D'::"bpchar"])))
);


ALTER TABLE "public"."answer_options" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."assessment_levels" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "framework_id" "uuid" NOT NULL,
    "level_code" "text" NOT NULL,
    "level_name" "text" NOT NULL,
    "level_number" integer NOT NULL,
    "short_code" "text" NOT NULL,
    "description" "text",
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."assessment_levels" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."assessment_questions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "assessment_id" "uuid" NOT NULL,
    "question_order" integer NOT NULL,
    "scenario" "text",
    "question" "text" NOT NULL,
    "option_a" "text" NOT NULL,
    "option_b" "text" NOT NULL,
    "option_c" "text" NOT NULL,
    "option_d" "text" NOT NULL,
    "correct_answer" integer NOT NULL,
    "explanation" "text",
    "difficulty_weight" numeric DEFAULT 1.0,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "competency_id" "uuid",
    "assessment_level_id" "uuid",
    "correct_answer_option_id" integer NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    CONSTRAINT "assessment_questions_correct_answer_option_fk_valid" CHECK ((("correct_answer_option_id" >= 1) AND ("correct_answer_option_id" <= 4))),
    CONSTRAINT "check_correct_answer_range" CHECK ((("correct_answer" >= 1) AND ("correct_answer" <= 4)))
);


ALTER TABLE "public"."assessment_questions" OWNER TO "postgres";


COMMENT ON COLUMN "public"."assessment_questions"."is_active" IS 'Indicates whether the question is active and should be included in assessments';



CREATE TABLE IF NOT EXISTS "public"."assessments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "slug" "text" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "estimated_duration" integer DEFAULT 30,
    "icon" "text" DEFAULT '📋'::"text",
    "is_active" boolean DEFAULT true,
    "sort_order" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "framework_id" "uuid",
    "assessment_level_id" "uuid"
);


ALTER TABLE "public"."assessments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."frameworks" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "text" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "is_active" boolean DEFAULT true,
    "priority_order" integer DEFAULT 1,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."frameworks" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."assessment_overview" WITH ("security_invoker"='true') AS
 SELECT "a"."id",
    "a"."slug",
    "a"."title",
    "a"."description",
    "f"."code" AS "framework",
    "al"."level_code" AS "difficulty",
    "a"."estimated_duration",
    "a"."icon",
    "a"."is_active",
    "a"."sort_order",
    "a"."created_at",
    "a"."updated_at",
    COALESCE("q"."question_count", (0)::bigint) AS "question_count"
   FROM ((("public"."assessments" "a"
     LEFT JOIN "public"."frameworks" "f" ON (("a"."framework_id" = "f"."id")))
     LEFT JOIN "public"."assessment_levels" "al" ON (("a"."assessment_level_id" = "al"."id")))
     LEFT JOIN ( SELECT "assessment_questions"."assessment_id",
            "count"(*) AS "question_count"
           FROM "public"."assessment_questions"
          GROUP BY "assessment_questions"."assessment_id") "q" ON (("a"."id" = "q"."assessment_id")))
  ORDER BY "a"."sort_order", "a"."title";


ALTER VIEW "public"."assessment_overview" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."competency_consolidated_insights" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "competency_id" "uuid" NOT NULL,
    "framework_id" "uuid" NOT NULL,
    "assessment_level_id" "uuid" NOT NULL,
    "analysis_type_id" "uuid" NOT NULL,
    "performance_insight" "text" NOT NULL,
    "development_focus" "text" NOT NULL,
    "practical_application" "text" NOT NULL,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."competency_consolidated_insights" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."competency_display_names" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "competency_key" "text" NOT NULL,
    "display_name" "text" NOT NULL,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "description" "text",
    "framework_id" "uuid"
);


ALTER TABLE "public"."competency_display_names" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."competency_leverage_strengths" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "leverage_text" "text" NOT NULL,
    "priority_order" integer DEFAULT 0,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "framework_id" "uuid",
    "assessment_level_id" "uuid",
    "competency_id" "uuid",
    "scoring_tier_id" "uuid"
);


ALTER TABLE "public"."competency_leverage_strengths" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."competency_performance_analysis" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "performance_percentage" numeric,
    "strength_level" "text",
    "analysis_data" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "analysis_text" "text",
    "is_active" boolean DEFAULT true,
    "sort_order" integer DEFAULT 0,
    "framework_id" "uuid",
    "assessment_level_id" "uuid",
    "competency_id" "uuid",
    "scoring_tier_id" "uuid"
);


ALTER TABLE "public"."competency_performance_analysis" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."competency_rich_insights" (
    "id" "uuid",
    "primary_insight" "text",
    "coaching_impact" "text",
    "key_observation" "text",
    "development_focus" "text",
    "practice_recommendation" "text",
    "growth_pathway" "text",
    "practical_application" "text",
    "supervision_focus" "text",
    "learning_approach" "text",
    "sort_order" integer,
    "is_active" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "framework_id" "uuid",
    "assessment_level_id" "uuid",
    "competency_id" "uuid"
);


ALTER TABLE "public"."competency_rich_insights" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."competency_strategic_actions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "action_text" "text" NOT NULL,
    "priority_order" integer DEFAULT 0,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "sort_order" integer DEFAULT 0,
    "framework_id" "uuid",
    "assessment_level_id" "uuid",
    "competency_id" "uuid",
    "scoring_tier_id" "uuid"
);


ALTER TABLE "public"."competency_strategic_actions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."framework_scoring_overrides" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "framework_id" "uuid" NOT NULL,
    "assessment_level_id" "uuid",
    "tier_code" character varying(20) NOT NULL,
    "custom_score_min" integer,
    "custom_score_max" integer,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "check_custom_score_range" CHECK ((("custom_score_min" >= 0) AND ("custom_score_max" <= 100) AND ("custom_score_min" <= "custom_score_max")))
);


ALTER TABLE "public"."framework_scoring_overrides" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."learning_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "activity_name" "text" NOT NULL,
    "date" "date" NOT NULL,
    "learnings_and_reflections" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."learning_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."learning_path_categories" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "category_title" "text" NOT NULL,
    "category_description" "text",
    "category_icon" "text",
    "competency_areas" "text"[],
    "priority_order" integer DEFAULT 0,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "assessment_level_id" "uuid"
);


ALTER TABLE "public"."learning_path_categories" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."learning_resource_competencies" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "learning_resource_id" "uuid",
    "competency_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."learning_resource_competencies" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."learning_resources" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "category_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "url" "text",
    "author_instructor" "text",
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "framework_id" "uuid",
    "assessment_level_id" "uuid",
    "resource_type_id" "uuid"
);


ALTER TABLE "public"."learning_resources" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."scoring_tiers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "tier_code" character varying(20) NOT NULL,
    "tier_name" character varying(50) NOT NULL,
    "score_min" integer NOT NULL,
    "score_max" integer NOT NULL,
    "display_order" integer NOT NULL,
    "analysis_type_id" "uuid",
    "description" "text",
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "check_valid_score_range" CHECK ((("score_min" >= 0) AND ("score_max" <= 100) AND ("score_min" <= "score_max")))
);


ALTER TABLE "public"."scoring_tiers" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."leverage_strengths_with_analysis_type" WITH ("security_invoker"='true', "security_barrier"='true') AS
 SELECT "cls"."id",
    "cls"."leverage_text",
    "cls"."priority_order",
    "cls"."competency_id",
    "cls"."framework_id",
    "cls"."assessment_level_id",
    "cls"."is_active",
    "st"."tier_code",
    "st"."tier_name",
    "st"."score_min",
    "st"."score_max",
    "at"."code" AS "analysis_type_code",
    "at"."name" AS "analysis_type_name",
    "at"."description" AS "analysis_type_description",
    "cdn"."display_name" AS "competency_name",
    "cdn"."competency_key",
    "f"."code" AS "framework_code",
    "al"."level_code" AS "assessment_level"
   FROM ((((("public"."competency_leverage_strengths" "cls"
     LEFT JOIN "public"."scoring_tiers" "st" ON (("cls"."scoring_tier_id" = "st"."id")))
     LEFT JOIN "public"."analysis_types" "at" ON (("st"."analysis_type_id" = "at"."id")))
     LEFT JOIN "public"."competency_display_names" "cdn" ON (("cls"."competency_id" = "cdn"."id")))
     LEFT JOIN "public"."frameworks" "f" ON (("cls"."framework_id" = "f"."id")))
     LEFT JOIN "public"."assessment_levels" "al" ON (("cls"."assessment_level_id" = "al"."id")))
  WHERE ("cls"."is_active" = true);


ALTER VIEW "public"."leverage_strengths_with_analysis_type" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."performance_analysis_with_analysis_type" WITH ("security_invoker"='true', "security_barrier"='true') AS
 SELECT "cpa"."id",
    "cpa"."analysis_text",
    "cpa"."sort_order",
    "cpa"."competency_id",
    "cpa"."framework_id",
    "cpa"."assessment_level_id",
    "cpa"."is_active",
    "cpa"."created_at",
    "st"."tier_code",
    "st"."tier_name",
    "st"."score_min",
    "st"."score_max",
    "st"."display_order" AS "tier_display_order",
    "at"."code" AS "analysis_type_code",
    "at"."name" AS "analysis_type_name",
    "at"."description" AS "analysis_type_description",
    "cdn"."display_name" AS "competency_name",
    "cdn"."competency_key",
    "f"."code" AS "framework_code",
    "f"."name" AS "framework_name",
    "al"."level_code" AS "assessment_level",
    "al"."level_name" AS "assessment_level_name"
   FROM ((((("public"."competency_performance_analysis" "cpa"
     LEFT JOIN "public"."scoring_tiers" "st" ON (("cpa"."scoring_tier_id" = "st"."id")))
     LEFT JOIN "public"."analysis_types" "at" ON (("st"."analysis_type_id" = "at"."id")))
     LEFT JOIN "public"."competency_display_names" "cdn" ON (("cpa"."competency_id" = "cdn"."id")))
     LEFT JOIN "public"."frameworks" "f" ON (("cpa"."framework_id" = "f"."id")))
     LEFT JOIN "public"."assessment_levels" "al" ON (("cpa"."assessment_level_id" = "al"."id")))
  WHERE ("cpa"."is_active" = true);


ALTER VIEW "public"."performance_analysis_with_analysis_type" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."resource_types" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "text" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."resource_types" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."rich_insights_compatibility" WITH ("security_invoker"='true') AS
 SELECT "id",
    "competency_id",
    "framework_id",
    "assessment_level_id",
    "performance_insight" AS "primary_insight",
    "performance_insight" AS "coaching_impact",
    "performance_insight" AS "key_observation",
    "development_focus",
    "development_focus" AS "practice_recommendation",
    "development_focus" AS "growth_pathway",
    "practical_application",
    NULL::"text" AS "supervision_focus",
    NULL::"text" AS "learning_approach",
    0 AS "sort_order",
    "is_active",
    "created_at"
   FROM "public"."competency_consolidated_insights" "cci";


ALTER VIEW "public"."rich_insights_compatibility" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."self_study" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "hours" numeric NOT NULL,
    "description" "text",
    "category" "text",
    "date" "date" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."self_study" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."skill_tags" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "sort_order" integer DEFAULT 0,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "framework_id" "uuid",
    "assessment_level_id" "uuid",
    "competency_id" "uuid"
);


ALTER TABLE "public"."skill_tags" OWNER TO "postgres";


COMMENT ON TABLE "public"."skill_tags" IS 'Skill tags linked to assessment competencies and levels. Fixed 2025-08-16: Core framework tags were incorrectly assigned to Intermediate level, corrected to Beginner level for Core I assessment.';



CREATE OR REPLACE VIEW "public"."strategic_actions_with_analysis_type" WITH ("security_invoker"='true', "security_barrier"='true') AS
 SELECT "csa"."id",
    "csa"."action_text",
    "csa"."priority_order",
    "csa"."sort_order",
    "csa"."competency_id",
    "csa"."framework_id",
    "csa"."assessment_level_id",
    "csa"."is_active",
    "csa"."created_at",
    "st"."tier_code",
    "st"."tier_name",
    "st"."score_min",
    "st"."score_max",
    "st"."display_order" AS "tier_display_order",
    "at"."code" AS "analysis_type_code",
    "at"."name" AS "analysis_type_name",
    "at"."description" AS "analysis_type_description",
    "cdn"."display_name" AS "competency_name",
    "cdn"."competency_key",
    "f"."code" AS "framework_code",
    "f"."name" AS "framework_name",
    "al"."level_code" AS "assessment_level",
    "al"."level_name" AS "assessment_level_name"
   FROM ((((("public"."competency_strategic_actions" "csa"
     LEFT JOIN "public"."scoring_tiers" "st" ON (("csa"."scoring_tier_id" = "st"."id")))
     LEFT JOIN "public"."analysis_types" "at" ON (("st"."analysis_type_id" = "at"."id")))
     LEFT JOIN "public"."competency_display_names" "cdn" ON (("csa"."competency_id" = "cdn"."id")))
     LEFT JOIN "public"."frameworks" "f" ON (("csa"."framework_id" = "f"."id")))
     LEFT JOIN "public"."assessment_levels" "al" ON (("csa"."assessment_level_id" = "al"."id")))
  WHERE ("csa"."is_active" = true);


ALTER VIEW "public"."strategic_actions_with_analysis_type" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."tag_actions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "skill_tag_id" "uuid" NOT NULL,
    "action_text" "text" NOT NULL,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "analysis_type_id" "uuid"
);


ALTER TABLE "public"."tag_actions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."tag_insights" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "skill_tag_id" "uuid" NOT NULL,
    "insight_text" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "assessment_level_id" "uuid",
    "analysis_type_id" "uuid"
);


ALTER TABLE "public"."tag_insights" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."temporary_pdf_files" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "file_path" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "expires_at" timestamp with time zone NOT NULL,
    "user_id" "uuid",
    "assessment_attempt_id" "uuid",
    "download_token" "text"
);


ALTER TABLE "public"."temporary_pdf_files" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_assessment_attempts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "assessment_id" "uuid" NOT NULL,
    "status" "text" DEFAULT 'started'::"text",
    "score" integer,
    "total_questions" integer,
    "correct_answers" integer,
    "time_spent" integer,
    "started_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "completed_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "enriched_data" "jsonb",
    "current_question_index" integer,
    "last_activity_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "user_assessment_attempts_status_check" CHECK (("status" = ANY (ARRAY['started'::"text", 'in_progress'::"text", 'completed'::"text", 'abandoned'::"text"])))
);


ALTER TABLE "public"."user_assessment_attempts" OWNER TO "postgres";


COMMENT ON COLUMN "public"."user_assessment_attempts"."current_question_index" IS 'Tracks the current question number (1-based) for assessment resume functionality. NULL means assessment not started or completed.';



COMMENT ON COLUMN "public"."user_assessment_attempts"."last_activity_at" IS 'Tracks when the user last interacted with this assessment attempt for idle monitoring';



CREATE TABLE IF NOT EXISTS "public"."user_question_responses" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "attempt_id" "uuid" NOT NULL,
    "question_id" "uuid" NOT NULL,
    "selected_answer" "text",
    "is_correct" boolean,
    "time_spent" integer,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "selected_answer_option_id" integer,
    CONSTRAINT "user_question_responses_answer_required" CHECK ((("selected_answer" IS NOT NULL) OR ("selected_answer_option_id" IS NOT NULL))),
    CONSTRAINT "user_question_responses_selected_answer_check" CHECK (("selected_answer" = ANY (ARRAY['A'::"text", 'B'::"text", 'C'::"text", 'D'::"text"]))),
    CONSTRAINT "user_question_responses_selected_answer_option_fk_valid" CHECK ((("selected_answer_option_id" >= 1) AND ("selected_answer_option_id" <= 4)))
);


ALTER TABLE "public"."user_question_responses" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."user_assessment_progress" WITH ("security_invoker"='true') AS
 SELECT "ua"."user_id",
    "ua"."assessment_id",
    "a"."slug" AS "assessment_slug",
    "a"."title" AS "assessment_title",
    "f"."code" AS "framework",
    "al"."level_code" AS "difficulty",
    "ua"."status",
    "ua"."score",
    "ua"."total_questions",
    "ua"."correct_answers",
    "ua"."started_at",
    "ua"."completed_at",
        CASE
            WHEN ("ua"."status" = 'completed'::"text") THEN (100)::numeric
            ELSE COALESCE((((( SELECT "count"(*) AS "count"
               FROM "public"."user_question_responses" "uqr"
              WHERE ("uqr"."attempt_id" = "ua"."id")))::numeric / (NULLIF("ua"."total_questions", 0))::numeric) * (100)::numeric), (0)::numeric)
        END AS "progress_percentage"
   FROM ((("public"."user_assessment_attempts" "ua"
     JOIN "public"."assessments" "a" ON (("ua"."assessment_id" = "a"."id")))
     LEFT JOIN "public"."frameworks" "f" ON (("a"."framework_id" = "f"."id")))
     LEFT JOIN "public"."assessment_levels" "al" ON (("a"."assessment_level_id" = "al"."id")))
  WHERE ("ua"."user_id" = "auth"."uid"())
  ORDER BY "ua"."started_at" DESC;


ALTER VIEW "public"."user_assessment_progress" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."user_competency_performance" WITH ("security_invoker"='true') AS
 SELECT "ua"."user_id",
    "cd"."display_name" AS "competency_area",
    "f"."code" AS "framework",
    "al"."level_code" AS "difficulty",
    "count"("uqr"."id") AS "total_answered",
    "count"(
        CASE
            WHEN ("uqr"."is_correct" = true) THEN 1
            ELSE NULL::integer
        END) AS "correct_answers",
        CASE
            WHEN ("count"("uqr"."id") > 0) THEN "round"(((("count"(
            CASE
                WHEN ("uqr"."is_correct" = true) THEN 1
                ELSE NULL::integer
            END))::numeric / ("count"("uqr"."id"))::numeric) * (100)::numeric), 1)
            ELSE (0)::numeric
        END AS "accuracy_percentage",
    "avg"("uqr"."time_spent") AS "avg_time_spent"
   FROM (((((("public"."user_assessment_attempts" "ua"
     JOIN "public"."assessments" "a" ON (("ua"."assessment_id" = "a"."id")))
     LEFT JOIN "public"."frameworks" "f" ON (("a"."framework_id" = "f"."id")))
     LEFT JOIN "public"."assessment_levels" "al" ON (("a"."assessment_level_id" = "al"."id")))
     JOIN "public"."user_question_responses" "uqr" ON (("uqr"."attempt_id" = "ua"."id")))
     JOIN "public"."assessment_questions" "aq" ON (("uqr"."question_id" = "aq"."id")))
     JOIN "public"."competency_display_names" "cd" ON (("aq"."competency_id" = "cd"."id")))
  WHERE (("cd"."display_name" IS NOT NULL) AND ("ua"."user_id" = "auth"."uid"()))
  GROUP BY "ua"."user_id", "cd"."display_name", "f"."code", "al"."level_code"
  ORDER BY "ua"."user_id", "cd"."display_name";


ALTER VIEW "public"."user_competency_performance" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_assessment_responses" WITH ("security_invoker"='true') AS
 SELECT "uqr"."id",
    "uqr"."attempt_id",
    "uqr"."question_id",
    "aq"."question_order",
    "aq"."question",
    "uqr"."selected_answer_option_id",
    "selected_option"."letter" AS "selected_answer",
    "aq"."correct_answer_option_id",
    "correct_option"."letter" AS "correct_answer",
    "uqr"."is_correct",
    "uqr"."time_spent",
    "uqr"."created_at"
   FROM ((("public"."user_question_responses" "uqr"
     JOIN "public"."assessment_questions" "aq" ON (("uqr"."question_id" = "aq"."id")))
     JOIN "public"."answer_options" "selected_option" ON (("uqr"."selected_answer_option_id" = "selected_option"."id")))
     JOIN "public"."answer_options" "correct_option" ON (("aq"."correct_answer_option_id" = "correct_option"."id")))
  ORDER BY "aq"."question_order";


ALTER VIEW "public"."v_assessment_responses" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."workbook_field_definitions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "section_number" integer NOT NULL,
    "field_key" "text" NOT NULL,
    "field_label" "text" NOT NULL,
    "field_type" "text" NOT NULL,
    "placeholder_text" "text",
    "instructions" "text",
    "is_required" boolean DEFAULT false,
    "sort_order" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."workbook_field_definitions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."workbook_progress" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "started_at" timestamp with time zone DEFAULT "now"(),
    "last_updated" timestamp with time zone DEFAULT "now"(),
    "completed_at" timestamp with time zone,
    "is_active" boolean DEFAULT true,
    "added_to_profile" boolean DEFAULT false,
    "title" "text" DEFAULT 'Kickstart Coaching Workbook'::"text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."workbook_progress" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."workbook_responses" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "workbook_id" "uuid" NOT NULL,
    "section_number" integer NOT NULL,
    "field_key" "text" NOT NULL,
    "field_value" "jsonb",
    "field_type" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."workbook_responses" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."workbook_sections" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "workbook_id" "uuid" NOT NULL,
    "section_number" integer NOT NULL,
    "section_title" "text" NOT NULL,
    "started_at" timestamp with time zone DEFAULT "now"(),
    "completed_at" timestamp with time zone,
    "progress_percent" integer DEFAULT 0,
    "last_updated" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "workbook_sections_progress_percent_check" CHECK ((("progress_percent" >= 0) AND ("progress_percent" <= 100)))
);


ALTER TABLE "public"."workbook_sections" OWNER TO "postgres";


ALTER TABLE ONLY "public"."analysis_types"
    ADD CONSTRAINT "analysis_types_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."analysis_types"
    ADD CONSTRAINT "analysis_types_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."answer_options"
    ADD CONSTRAINT "answer_options_display_order_key" UNIQUE ("display_order");



ALTER TABLE ONLY "public"."answer_options"
    ADD CONSTRAINT "answer_options_letter_key" UNIQUE ("letter");



ALTER TABLE ONLY "public"."answer_options"
    ADD CONSTRAINT "answer_options_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."assessment_levels"
    ADD CONSTRAINT "assessment_levels_framework_id_level_code_key" UNIQUE ("framework_id", "level_code");



ALTER TABLE ONLY "public"."assessment_levels"
    ADD CONSTRAINT "assessment_levels_framework_id_level_number_key" UNIQUE ("framework_id", "level_number");



ALTER TABLE ONLY "public"."assessment_levels"
    ADD CONSTRAINT "assessment_levels_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."assessment_levels"
    ADD CONSTRAINT "assessment_levels_short_code_key" UNIQUE ("short_code");



ALTER TABLE ONLY "public"."assessment_questions"
    ADD CONSTRAINT "assessment_questions_assessment_id_question_order_key" UNIQUE ("assessment_id", "question_order");



ALTER TABLE ONLY "public"."assessment_questions"
    ADD CONSTRAINT "assessment_questions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."assessments"
    ADD CONSTRAINT "assessments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."assessments"
    ADD CONSTRAINT "assessments_slug_key" UNIQUE ("slug");



ALTER TABLE ONLY "public"."competency_consolidated_insights"
    ADD CONSTRAINT "competency_consolidated_insights_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."competency_display_names"
    ADD CONSTRAINT "competency_display_names_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."competency_leverage_strengths"
    ADD CONSTRAINT "competency_leverage_strengths_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."competency_performance_analysis"
    ADD CONSTRAINT "competency_performance_analysis_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."competency_strategic_actions"
    ADD CONSTRAINT "competency_strategic_actions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."competency_consolidated_insights"
    ADD CONSTRAINT "consolidated_insights_unique" UNIQUE ("competency_id", "framework_id", "assessment_level_id", "analysis_type_id");



ALTER TABLE ONLY "public"."framework_scoring_overrides"
    ADD CONSTRAINT "framework_scoring_overrides_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."frameworks"
    ADD CONSTRAINT "frameworks_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."frameworks"
    ADD CONSTRAINT "frameworks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."learning_logs"
    ADD CONSTRAINT "learning_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."learning_path_categories"
    ADD CONSTRAINT "learning_path_categories_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."learning_resource_competencies"
    ADD CONSTRAINT "learning_resource_competencie_learning_resource_id_competen_key" UNIQUE ("learning_resource_id", "competency_id");



ALTER TABLE ONLY "public"."learning_resource_competencies"
    ADD CONSTRAINT "learning_resource_competencies_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."learning_resources"
    ADD CONSTRAINT "learning_resources_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."resource_types"
    ADD CONSTRAINT "resource_types_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."resource_types"
    ADD CONSTRAINT "resource_types_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."scoring_tiers"
    ADD CONSTRAINT "scoring_tiers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."scoring_tiers"
    ADD CONSTRAINT "scoring_tiers_tier_code_key" UNIQUE ("tier_code");



ALTER TABLE ONLY "public"."self_study"
    ADD CONSTRAINT "self_study_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."skill_tags"
    ADD CONSTRAINT "skill_tags_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tag_actions"
    ADD CONSTRAINT "tag_actions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tag_actions"
    ADD CONSTRAINT "tag_actions_skill_analysis_unique" UNIQUE ("skill_tag_id", "analysis_type_id");



ALTER TABLE ONLY "public"."tag_insights"
    ADD CONSTRAINT "tag_insights_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."temporary_pdf_files"
    ADD CONSTRAINT "temporary_pdf_files_download_token_key" UNIQUE ("download_token");



ALTER TABLE ONLY "public"."temporary_pdf_files"
    ADD CONSTRAINT "temporary_pdf_files_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_assessment_attempts"
    ADD CONSTRAINT "user_assessment_attempts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_question_responses"
    ADD CONSTRAINT "user_question_responses_attempt_id_question_id_key" UNIQUE ("attempt_id", "question_id");



ALTER TABLE ONLY "public"."user_question_responses"
    ADD CONSTRAINT "user_question_responses_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."workbook_field_definitions"
    ADD CONSTRAINT "workbook_field_definitions_field_key_key" UNIQUE ("field_key");



ALTER TABLE ONLY "public"."workbook_field_definitions"
    ADD CONSTRAINT "workbook_field_definitions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."workbook_progress"
    ADD CONSTRAINT "workbook_progress_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."workbook_responses"
    ADD CONSTRAINT "workbook_responses_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."workbook_responses"
    ADD CONSTRAINT "workbook_responses_workbook_id_field_key_key" UNIQUE ("workbook_id", "field_key");



ALTER TABLE ONLY "public"."workbook_sections"
    ADD CONSTRAINT "workbook_sections_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_analysis_types_code" ON "public"."analysis_types" USING "btree" ("code");



CREATE INDEX "idx_assessment_levels_framework_id" ON "public"."assessment_levels" USING "btree" ("framework_id");



CREATE INDEX "idx_assessment_questions_assessment_id" ON "public"."assessment_questions" USING "btree" ("assessment_id");



CREATE INDEX "idx_assessment_questions_assessment_level_id" ON "public"."assessment_questions" USING "btree" ("assessment_level_id");



CREATE INDEX "idx_assessment_questions_competency_id" ON "public"."assessment_questions" USING "btree" ("competency_id");



CREATE INDEX "idx_assessment_questions_correct_answer_option_id" ON "public"."assessment_questions" USING "btree" ("correct_answer_option_id");



CREATE INDEX "idx_assessment_questions_is_active" ON "public"."assessment_questions" USING "btree" ("is_active");



CREATE INDEX "idx_assessments_active" ON "public"."assessments" USING "btree" ("is_active");



CREATE INDEX "idx_assessments_assessment_level_id" ON "public"."assessments" USING "btree" ("assessment_level_id");



CREATE INDEX "idx_assessments_framework_id" ON "public"."assessments" USING "btree" ("framework_id");



CREATE INDEX "idx_assessments_slug" ON "public"."assessments" USING "btree" ("slug");



CREATE INDEX "idx_assessments_sort" ON "public"."assessments" USING "btree" ("sort_order");



CREATE INDEX "idx_competency_display_names_framework_id" ON "public"."competency_display_names" USING "btree" ("framework_id");



CREATE INDEX "idx_competency_leverage_strengths_assessment_level_id" ON "public"."competency_leverage_strengths" USING "btree" ("assessment_level_id");



CREATE INDEX "idx_competency_leverage_strengths_competency_id" ON "public"."competency_leverage_strengths" USING "btree" ("competency_id");



CREATE INDEX "idx_competency_leverage_strengths_framework_id" ON "public"."competency_leverage_strengths" USING "btree" ("framework_id");



CREATE INDEX "idx_competency_performance_analysis_assessment_level_id" ON "public"."competency_performance_analysis" USING "btree" ("assessment_level_id");



CREATE INDEX "idx_competency_performance_analysis_competency_id" ON "public"."competency_performance_analysis" USING "btree" ("competency_id");



CREATE INDEX "idx_competency_performance_analysis_framework_id" ON "public"."competency_performance_analysis" USING "btree" ("framework_id");



CREATE INDEX "idx_competency_performance_analysis_scoring_tier" ON "public"."competency_performance_analysis" USING "btree" ("scoring_tier_id");



CREATE INDEX "idx_competency_strategic_actions_assessment_level_id" ON "public"."competency_strategic_actions" USING "btree" ("assessment_level_id");



CREATE INDEX "idx_competency_strategic_actions_competency_id" ON "public"."competency_strategic_actions" USING "btree" ("competency_id");



CREATE INDEX "idx_competency_strategic_actions_framework_id" ON "public"."competency_strategic_actions" USING "btree" ("framework_id");



CREATE INDEX "idx_competency_strategic_actions_scoring_tier" ON "public"."competency_strategic_actions" USING "btree" ("scoring_tier_id");



CREATE INDEX "idx_consolidated_insights_analysis_type_id" ON "public"."competency_consolidated_insights" USING "btree" ("analysis_type_id");



CREATE INDEX "idx_consolidated_insights_assessment_level_id" ON "public"."competency_consolidated_insights" USING "btree" ("assessment_level_id");



CREATE INDEX "idx_consolidated_insights_competency_id" ON "public"."competency_consolidated_insights" USING "btree" ("competency_id");



CREATE INDEX "idx_consolidated_insights_framework_id" ON "public"."competency_consolidated_insights" USING "btree" ("framework_id");



CREATE INDEX "idx_framework_scoring_active" ON "public"."framework_scoring_overrides" USING "btree" ("is_active") WHERE ("is_active" = true);



CREATE INDEX "idx_framework_scoring_framework" ON "public"."framework_scoring_overrides" USING "btree" ("framework_id");



CREATE INDEX "idx_framework_scoring_level" ON "public"."framework_scoring_overrides" USING "btree" ("assessment_level_id");



CREATE UNIQUE INDEX "idx_framework_scoring_unique" ON "public"."framework_scoring_overrides" USING "btree" ("framework_id", "assessment_level_id", "tier_code") WHERE ("is_active" = true);



CREATE INDEX "idx_frameworks_code" ON "public"."frameworks" USING "btree" ("code");



CREATE INDEX "idx_learning_logs_user_id" ON "public"."learning_logs" USING "btree" ("user_id");



CREATE INDEX "idx_learning_resource_competencies_competency_id" ON "public"."learning_resource_competencies" USING "btree" ("competency_id");



CREATE INDEX "idx_learning_resource_competencies_resource_id" ON "public"."learning_resource_competencies" USING "btree" ("learning_resource_id");



CREATE INDEX "idx_learning_resources_assessment_level_id" ON "public"."learning_resources" USING "btree" ("assessment_level_id");



CREATE INDEX "idx_learning_resources_category_id" ON "public"."learning_resources" USING "btree" ("category_id");



CREATE INDEX "idx_learning_resources_framework_id" ON "public"."learning_resources" USING "btree" ("framework_id");



CREATE INDEX "idx_learning_resources_resource_type_id" ON "public"."learning_resources" USING "btree" ("resource_type_id");



CREATE INDEX "idx_questions_order" ON "public"."assessment_questions" USING "btree" ("question_order");



CREATE INDEX "idx_resource_types_code" ON "public"."resource_types" USING "btree" ("code");



CREATE INDEX "idx_scoring_tiers_active" ON "public"."scoring_tiers" USING "btree" ("is_active") WHERE ("is_active" = true);



CREATE INDEX "idx_scoring_tiers_display_order" ON "public"."scoring_tiers" USING "btree" ("display_order");



CREATE UNIQUE INDEX "idx_scoring_tiers_no_overlap" ON "public"."scoring_tiers" USING "btree" ("score_min", "score_max");



CREATE INDEX "idx_scoring_tiers_range" ON "public"."scoring_tiers" USING "btree" ("score_min", "score_max");



CREATE INDEX "idx_scoring_tiers_tier_code" ON "public"."scoring_tiers" USING "btree" ("tier_code");



CREATE INDEX "idx_self_study_user_id" ON "public"."self_study" USING "btree" ("user_id");



CREATE INDEX "idx_skill_tags_assessment_level_id" ON "public"."skill_tags" USING "btree" ("assessment_level_id");



CREATE INDEX "idx_skill_tags_competency_id" ON "public"."skill_tags" USING "btree" ("competency_id");



CREATE INDEX "idx_skill_tags_framework_id" ON "public"."skill_tags" USING "btree" ("framework_id");



CREATE INDEX "idx_tag_insights_analysis_type_id" ON "public"."tag_insights" USING "btree" ("analysis_type_id");



CREATE INDEX "idx_tag_insights_assessment_level_id" ON "public"."tag_insights" USING "btree" ("assessment_level_id");



CREATE INDEX "idx_tag_insights_skill_tag_id" ON "public"."tag_insights" USING "btree" ("skill_tag_id");



CREATE INDEX "idx_temporary_pdf_files_expires_at" ON "public"."temporary_pdf_files" USING "btree" ("expires_at");



CREATE INDEX "idx_temporary_pdf_files_user_id" ON "public"."temporary_pdf_files" USING "btree" ("user_id");



CREATE INDEX "idx_user_assessment_attempts_assessment_id" ON "public"."user_assessment_attempts" USING "btree" ("assessment_id");



CREATE INDEX "idx_user_assessment_attempts_user_id" ON "public"."user_assessment_attempts" USING "btree" ("user_id");



CREATE INDEX "idx_user_question_responses_attempt_id" ON "public"."user_question_responses" USING "btree" ("attempt_id");



CREATE INDEX "idx_user_question_responses_question_id" ON "public"."user_question_responses" USING "btree" ("question_id");



CREATE INDEX "idx_user_question_responses_selected_answer_option_id" ON "public"."user_question_responses" USING "btree" ("selected_answer_option_id");



CREATE INDEX "idx_workbook_field_definitions_section" ON "public"."workbook_field_definitions" USING "btree" ("section_number");



CREATE INDEX "idx_workbook_progress_user_id" ON "public"."workbook_progress" USING "btree" ("user_id");



CREATE INDEX "idx_workbook_responses_field" ON "public"."workbook_responses" USING "btree" ("workbook_id", "field_key");



CREATE INDEX "idx_workbook_responses_workbook_id" ON "public"."workbook_responses" USING "btree" ("workbook_id");



CREATE INDEX "idx_workbook_sections_number" ON "public"."workbook_sections" USING "btree" ("workbook_id", "section_number");



CREATE INDEX "idx_workbook_sections_workbook_id" ON "public"."workbook_sections" USING "btree" ("workbook_id");



CREATE OR REPLACE TRIGGER "trigger_auto_calculate_score" AFTER UPDATE ON "public"."user_assessment_attempts" FOR EACH ROW EXECUTE FUNCTION "public"."auto_calculate_score"();



CREATE OR REPLACE TRIGGER "trigger_check_answer_correctness_v4" BEFORE INSERT OR UPDATE ON "public"."user_question_responses" FOR EACH ROW EXECUTE FUNCTION "public"."check_answer_correctness_v4"();



CREATE OR REPLACE TRIGGER "trigger_update_attempt_status" AFTER INSERT ON "public"."user_question_responses" FOR EACH ROW EXECUTE FUNCTION "public"."update_attempt_status"();



CREATE OR REPLACE TRIGGER "update_workbook_progress_updated_at" BEFORE UPDATE ON "public"."workbook_progress" FOR EACH ROW EXECUTE FUNCTION "public"."update_workbook_progress_timestamp"();



CREATE OR REPLACE TRIGGER "update_workbook_responses_updated_at" BEFORE UPDATE ON "public"."workbook_responses" FOR EACH ROW EXECUTE FUNCTION "public"."update_workbook_response_timestamp"();



ALTER TABLE ONLY "public"."assessment_levels"
    ADD CONSTRAINT "assessment_levels_framework_id_fkey" FOREIGN KEY ("framework_id") REFERENCES "public"."frameworks"("id");



ALTER TABLE ONLY "public"."assessment_questions"
    ADD CONSTRAINT "assessment_questions_assessment_id_fkey" FOREIGN KEY ("assessment_id") REFERENCES "public"."assessments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."assessment_questions"
    ADD CONSTRAINT "assessment_questions_assessment_level_id_fkey" FOREIGN KEY ("assessment_level_id") REFERENCES "public"."assessment_levels"("id");



ALTER TABLE ONLY "public"."assessment_questions"
    ADD CONSTRAINT "assessment_questions_competency_id_fkey" FOREIGN KEY ("competency_id") REFERENCES "public"."competency_display_names"("id");



ALTER TABLE ONLY "public"."assessment_questions"
    ADD CONSTRAINT "assessment_questions_correct_answer_option_id_fkey" FOREIGN KEY ("correct_answer_option_id") REFERENCES "public"."answer_options"("id");



ALTER TABLE ONLY "public"."assessments"
    ADD CONSTRAINT "assessments_assessment_level_id_fkey" FOREIGN KEY ("assessment_level_id") REFERENCES "public"."assessment_levels"("id");



ALTER TABLE ONLY "public"."assessments"
    ADD CONSTRAINT "assessments_framework_id_fkey" FOREIGN KEY ("framework_id") REFERENCES "public"."frameworks"("id");



ALTER TABLE ONLY "public"."competency_consolidated_insights"
    ADD CONSTRAINT "competency_consolidated_insights_analysis_type_id_fkey" FOREIGN KEY ("analysis_type_id") REFERENCES "public"."analysis_types"("id");



ALTER TABLE ONLY "public"."competency_consolidated_insights"
    ADD CONSTRAINT "competency_consolidated_insights_assessment_level_id_fkey" FOREIGN KEY ("assessment_level_id") REFERENCES "public"."assessment_levels"("id");



ALTER TABLE ONLY "public"."competency_consolidated_insights"
    ADD CONSTRAINT "competency_consolidated_insights_competency_id_fkey" FOREIGN KEY ("competency_id") REFERENCES "public"."competency_display_names"("id");



ALTER TABLE ONLY "public"."competency_consolidated_insights"
    ADD CONSTRAINT "competency_consolidated_insights_framework_id_fkey" FOREIGN KEY ("framework_id") REFERENCES "public"."frameworks"("id");



ALTER TABLE ONLY "public"."competency_display_names"
    ADD CONSTRAINT "competency_display_names_framework_id_fkey" FOREIGN KEY ("framework_id") REFERENCES "public"."frameworks"("id");



ALTER TABLE ONLY "public"."competency_leverage_strengths"
    ADD CONSTRAINT "competency_leverage_strengths_assessment_level_id_fkey" FOREIGN KEY ("assessment_level_id") REFERENCES "public"."assessment_levels"("id");



ALTER TABLE ONLY "public"."competency_leverage_strengths"
    ADD CONSTRAINT "competency_leverage_strengths_competency_id_fkey" FOREIGN KEY ("competency_id") REFERENCES "public"."competency_display_names"("id");



ALTER TABLE ONLY "public"."competency_leverage_strengths"
    ADD CONSTRAINT "competency_leverage_strengths_framework_id_fkey" FOREIGN KEY ("framework_id") REFERENCES "public"."frameworks"("id");



ALTER TABLE ONLY "public"."competency_leverage_strengths"
    ADD CONSTRAINT "competency_leverage_strengths_scoring_tier_id_fkey" FOREIGN KEY ("scoring_tier_id") REFERENCES "public"."scoring_tiers"("id");



ALTER TABLE ONLY "public"."competency_performance_analysis"
    ADD CONSTRAINT "competency_performance_analysis_assessment_level_id_fkey" FOREIGN KEY ("assessment_level_id") REFERENCES "public"."assessment_levels"("id");



ALTER TABLE ONLY "public"."competency_performance_analysis"
    ADD CONSTRAINT "competency_performance_analysis_competency_id_fkey" FOREIGN KEY ("competency_id") REFERENCES "public"."competency_display_names"("id");



ALTER TABLE ONLY "public"."competency_performance_analysis"
    ADD CONSTRAINT "competency_performance_analysis_framework_id_fkey" FOREIGN KEY ("framework_id") REFERENCES "public"."frameworks"("id");



ALTER TABLE ONLY "public"."competency_performance_analysis"
    ADD CONSTRAINT "competency_performance_analysis_scoring_tier_id_fkey" FOREIGN KEY ("scoring_tier_id") REFERENCES "public"."scoring_tiers"("id");



ALTER TABLE ONLY "public"."competency_strategic_actions"
    ADD CONSTRAINT "competency_strategic_actions_assessment_level_id_fkey" FOREIGN KEY ("assessment_level_id") REFERENCES "public"."assessment_levels"("id");



ALTER TABLE ONLY "public"."competency_strategic_actions"
    ADD CONSTRAINT "competency_strategic_actions_competency_id_fkey" FOREIGN KEY ("competency_id") REFERENCES "public"."competency_display_names"("id");



ALTER TABLE ONLY "public"."competency_strategic_actions"
    ADD CONSTRAINT "competency_strategic_actions_framework_id_fkey" FOREIGN KEY ("framework_id") REFERENCES "public"."frameworks"("id");



ALTER TABLE ONLY "public"."competency_strategic_actions"
    ADD CONSTRAINT "competency_strategic_actions_scoring_tier_id_fkey" FOREIGN KEY ("scoring_tier_id") REFERENCES "public"."scoring_tiers"("id");



ALTER TABLE ONLY "public"."framework_scoring_overrides"
    ADD CONSTRAINT "framework_scoring_overrides_assessment_level_id_fkey" FOREIGN KEY ("assessment_level_id") REFERENCES "public"."assessment_levels"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."framework_scoring_overrides"
    ADD CONSTRAINT "framework_scoring_overrides_framework_id_fkey" FOREIGN KEY ("framework_id") REFERENCES "public"."frameworks"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."framework_scoring_overrides"
    ADD CONSTRAINT "framework_scoring_overrides_tier_code_fkey" FOREIGN KEY ("tier_code") REFERENCES "public"."scoring_tiers"("tier_code") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."learning_path_categories"
    ADD CONSTRAINT "learning_path_categories_assessment_level_id_fkey" FOREIGN KEY ("assessment_level_id") REFERENCES "public"."assessment_levels"("id");



ALTER TABLE ONLY "public"."learning_resource_competencies"
    ADD CONSTRAINT "learning_resource_competencies_competency_id_fkey" FOREIGN KEY ("competency_id") REFERENCES "public"."competency_display_names"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."learning_resource_competencies"
    ADD CONSTRAINT "learning_resource_competencies_learning_resource_id_fkey" FOREIGN KEY ("learning_resource_id") REFERENCES "public"."learning_resources"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."learning_resources"
    ADD CONSTRAINT "learning_resources_assessment_level_id_fkey" FOREIGN KEY ("assessment_level_id") REFERENCES "public"."assessment_levels"("id");



ALTER TABLE ONLY "public"."learning_resources"
    ADD CONSTRAINT "learning_resources_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."learning_path_categories"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."learning_resources"
    ADD CONSTRAINT "learning_resources_framework_id_fkey" FOREIGN KEY ("framework_id") REFERENCES "public"."frameworks"("id");



ALTER TABLE ONLY "public"."learning_resources"
    ADD CONSTRAINT "learning_resources_resource_type_id_fkey" FOREIGN KEY ("resource_type_id") REFERENCES "public"."resource_types"("id");



ALTER TABLE ONLY "public"."skill_tags"
    ADD CONSTRAINT "skill_tags_assessment_level_id_fkey" FOREIGN KEY ("assessment_level_id") REFERENCES "public"."assessment_levels"("id");



ALTER TABLE ONLY "public"."skill_tags"
    ADD CONSTRAINT "skill_tags_competency_id_fkey" FOREIGN KEY ("competency_id") REFERENCES "public"."competency_display_names"("id");



ALTER TABLE ONLY "public"."skill_tags"
    ADD CONSTRAINT "skill_tags_framework_id_fkey" FOREIGN KEY ("framework_id") REFERENCES "public"."frameworks"("id");



ALTER TABLE ONLY "public"."tag_actions"
    ADD CONSTRAINT "tag_actions_analysis_type_id_fkey" FOREIGN KEY ("analysis_type_id") REFERENCES "public"."analysis_types"("id");



ALTER TABLE ONLY "public"."tag_actions"
    ADD CONSTRAINT "tag_actions_skill_tag_id_fkey" FOREIGN KEY ("skill_tag_id") REFERENCES "public"."skill_tags"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tag_insights"
    ADD CONSTRAINT "tag_insights_analysis_type_id_fkey" FOREIGN KEY ("analysis_type_id") REFERENCES "public"."analysis_types"("id");



ALTER TABLE ONLY "public"."tag_insights"
    ADD CONSTRAINT "tag_insights_assessment_level_id_fkey" FOREIGN KEY ("assessment_level_id") REFERENCES "public"."assessment_levels"("id");



ALTER TABLE ONLY "public"."tag_insights"
    ADD CONSTRAINT "tag_insights_skill_tag_id_fkey" FOREIGN KEY ("skill_tag_id") REFERENCES "public"."skill_tags"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_assessment_attempts"
    ADD CONSTRAINT "user_assessment_attempts_assessment_id_fkey" FOREIGN KEY ("assessment_id") REFERENCES "public"."assessments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_question_responses"
    ADD CONSTRAINT "user_question_responses_attempt_id_fkey" FOREIGN KEY ("attempt_id") REFERENCES "public"."user_assessment_attempts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_question_responses"
    ADD CONSTRAINT "user_question_responses_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "public"."assessment_questions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_question_responses"
    ADD CONSTRAINT "user_question_responses_selected_answer_option_id_fkey" FOREIGN KEY ("selected_answer_option_id") REFERENCES "public"."answer_options"("id");



ALTER TABLE ONLY "public"."workbook_progress"
    ADD CONSTRAINT "workbook_progress_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."workbook_responses"
    ADD CONSTRAINT "workbook_responses_workbook_id_fkey" FOREIGN KEY ("workbook_id") REFERENCES "public"."workbook_progress"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."workbook_sections"
    ADD CONSTRAINT "workbook_sections_workbook_id_fkey" FOREIGN KEY ("workbook_id") REFERENCES "public"."workbook_progress"("id") ON DELETE CASCADE;



CREATE POLICY "Allow anon users to read active consolidated insights" ON "public"."competency_consolidated_insights" FOR SELECT TO "anon" USING (("is_active" = true));



CREATE POLICY "Allow anon users to read active rich insights" ON "public"."competency_rich_insights" FOR SELECT TO "anon" USING (("is_active" = true));



CREATE POLICY "Allow authenticated users to read consolidated insights" ON "public"."competency_consolidated_insights" FOR SELECT TO "authenticated" USING (("is_active" = true));



CREATE POLICY "Allow authenticated users to read rich insights" ON "public"."competency_rich_insights" FOR SELECT TO "authenticated" USING (("is_active" = true));



CREATE POLICY "Allow service_role full access to consolidated insights" ON "public"."competency_consolidated_insights" TO "service_role" USING (true) WITH CHECK (true);



CREATE POLICY "Allow service_role full access to rich insights" ON "public"."competency_rich_insights" TO "service_role" USING (true) WITH CHECK (true);



CREATE POLICY "Field definitions are readable by authenticated users" ON "public"."workbook_field_definitions" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Users can manage their own responses" ON "public"."workbook_responses" TO "authenticated" USING (("workbook_id" IN ( SELECT "workbook_progress"."id"
   FROM "public"."workbook_progress"
  WHERE ("workbook_progress"."user_id" = "auth"."uid"()))));



CREATE POLICY "Users can manage their own section progress" ON "public"."workbook_sections" TO "authenticated" USING (("workbook_id" IN ( SELECT "workbook_progress"."id"
   FROM "public"."workbook_progress"
  WHERE ("workbook_progress"."user_id" = "auth"."uid"()))));



CREATE POLICY "Users can manage their own workbooks" ON "public"."workbook_progress" TO "authenticated" USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));



ALTER TABLE "public"."analysis_types" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "analysis_types_public_read" ON "public"."analysis_types" FOR SELECT USING (("is_active" = true));



ALTER TABLE "public"."answer_options" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "answer_options_public_read" ON "public"."answer_options" FOR SELECT USING (true);



ALTER TABLE "public"."assessment_levels" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "assessment_levels_public_read" ON "public"."assessment_levels" FOR SELECT USING (("is_active" = true));



ALTER TABLE "public"."assessment_questions" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "assessment_questions_public_read" ON "public"."assessment_questions" FOR SELECT USING (true);



ALTER TABLE "public"."assessments" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "assessments_public_read" ON "public"."assessments" FOR SELECT USING (true);



ALTER TABLE "public"."competency_consolidated_insights" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."competency_display_names" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "competency_display_names_public_read" ON "public"."competency_display_names" FOR SELECT USING (true);



ALTER TABLE "public"."competency_leverage_strengths" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "competency_leverage_strengths_public_read" ON "public"."competency_leverage_strengths" FOR SELECT USING (true);



ALTER TABLE "public"."competency_performance_analysis" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "competency_performance_analysis_public_read" ON "public"."competency_performance_analysis" FOR SELECT USING (true);



ALTER TABLE "public"."competency_rich_insights" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."competency_strategic_actions" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "competency_strategic_actions_public_read" ON "public"."competency_strategic_actions" FOR SELECT USING (true);



ALTER TABLE "public"."framework_scoring_overrides" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "framework_scoring_overrides_all_service_role" ON "public"."framework_scoring_overrides" TO "service_role" USING (true) WITH CHECK (true);



CREATE POLICY "framework_scoring_overrides_select_authenticated" ON "public"."framework_scoring_overrides" FOR SELECT TO "authenticated" USING (true);



ALTER TABLE "public"."frameworks" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "frameworks_public_read" ON "public"."frameworks" FOR SELECT USING (("is_active" = true));



ALTER TABLE "public"."learning_logs" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "learning_logs_user_policy" ON "public"."learning_logs" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



ALTER TABLE "public"."learning_path_categories" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "learning_path_categories_public_read" ON "public"."learning_path_categories" FOR SELECT USING (true);



ALTER TABLE "public"."learning_resource_competencies" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "learning_resource_competencies_public_read" ON "public"."learning_resource_competencies" FOR SELECT USING (true);



ALTER TABLE "public"."learning_resources" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "learning_resources_public_read" ON "public"."learning_resources" FOR SELECT USING (true);



ALTER TABLE "public"."resource_types" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "resource_types_public_read" ON "public"."resource_types" FOR SELECT USING (("is_active" = true));



ALTER TABLE "public"."scoring_tiers" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "scoring_tiers_all_service_role" ON "public"."scoring_tiers" TO "service_role" USING (true) WITH CHECK (true);



CREATE POLICY "scoring_tiers_select_authenticated" ON "public"."scoring_tiers" FOR SELECT TO "authenticated" USING (true);



ALTER TABLE "public"."self_study" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "self_study_user_policy" ON "public"."self_study" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



ALTER TABLE "public"."skill_tags" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "skill_tags_public_read" ON "public"."skill_tags" FOR SELECT USING (true);



ALTER TABLE "public"."tag_actions" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "tag_actions_public_read" ON "public"."tag_actions" FOR SELECT USING (true);



ALTER TABLE "public"."tag_insights" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "tag_insights_public_read" ON "public"."tag_insights" FOR SELECT USING (true);



ALTER TABLE "public"."temporary_pdf_files" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "temporary_pdf_files_access_policy" ON "public"."temporary_pdf_files" USING (((( SELECT "auth"."uid"() AS "uid") = "user_id") OR (("download_token" IS NOT NULL) AND ("expires_at" > "now"()))));



ALTER TABLE "public"."user_assessment_attempts" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "user_assessment_attempts_user_policy" ON "public"."user_assessment_attempts" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



ALTER TABLE "public"."user_question_responses" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "user_question_responses_user_policy" ON "public"."user_question_responses" USING ((( SELECT "auth"."uid"() AS "uid") IN ( SELECT "ua"."user_id"
   FROM "public"."user_assessment_attempts" "ua"
  WHERE ("ua"."id" = "user_question_responses"."attempt_id"))));



ALTER TABLE "public"."workbook_field_definitions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."workbook_progress" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."workbook_responses" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."workbook_sections" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

























































































































































GRANT ALL ON FUNCTION "public"."auto_calculate_score"() TO "anon";
GRANT ALL ON FUNCTION "public"."auto_calculate_score"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."auto_calculate_score"() TO "service_role";



GRANT ALL ON FUNCTION "public"."calculate_assessment_score"("attempt_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_assessment_score"("attempt_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_assessment_score"("attempt_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."calculate_enriched_assessment_data"("attempt_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_enriched_assessment_data"("attempt_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_enriched_assessment_data"("attempt_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."calculate_section_progress"("p_workbook_id" "uuid", "p_section_number" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_section_progress"("p_workbook_id" "uuid", "p_section_number" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_section_progress"("p_workbook_id" "uuid", "p_section_number" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."calculate_section_progress"("user_id_param" "uuid", "section_id_param" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_section_progress"("user_id_param" "uuid", "section_id_param" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_section_progress"("user_id_param" "uuid", "section_id_param" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."check_answer_correctness_v4"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_answer_correctness_v4"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_answer_correctness_v4"() TO "service_role";



GRANT ALL ON FUNCTION "public"."check_enriched_data_status"("attempt_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."check_enriched_data_status"("attempt_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_enriched_data_status"("attempt_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."cleanup_expired_pdfs"() TO "anon";
GRANT ALL ON FUNCTION "public"."cleanup_expired_pdfs"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."cleanup_expired_pdfs"() TO "service_role";



GRANT ALL ON FUNCTION "public"."cleanup_temporary_pdfs"() TO "anon";
GRANT ALL ON FUNCTION "public"."cleanup_temporary_pdfs"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."cleanup_temporary_pdfs"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_analysis_type_for_score"("score_percentage" integer, "framework_code" "text", "assessment_level_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_analysis_type_for_score"("score_percentage" integer, "framework_code" "text", "assessment_level_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_analysis_type_for_score"("score_percentage" integer, "framework_code" "text", "assessment_level_code" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_competency_consolidated_insights"("p_competency_id" "uuid", "p_framework_id" "uuid", "p_assessment_level_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_competency_consolidated_insights"("p_competency_id" "uuid", "p_framework_id" "uuid", "p_assessment_level_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_competency_consolidated_insights"("p_competency_id" "uuid", "p_framework_id" "uuid", "p_assessment_level_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_consolidated_insights_for_pdf"("p_competency_id" "uuid", "p_framework_id" "uuid", "p_assessment_level_id" "uuid", "p_analysis_type_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_consolidated_insights_for_pdf"("p_competency_id" "uuid", "p_framework_id" "uuid", "p_assessment_level_id" "uuid", "p_analysis_type_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_consolidated_insights_for_pdf"("p_competency_id" "uuid", "p_framework_id" "uuid", "p_assessment_level_id" "uuid", "p_analysis_type_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_enriched_assessment_data"("attempt_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_enriched_assessment_data"("attempt_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_enriched_assessment_data"("attempt_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_learning_paths_for_assessment"("weak_competency_areas" "text"[], "overall_score" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_learning_paths_for_assessment"("weak_competency_areas" "text"[], "overall_score" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_learning_paths_for_assessment"("weak_competency_areas" "text"[], "overall_score" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_learning_paths_for_assessment"("weak_competency_areas" "text"[], "overall_score" integer, "assessment_level" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_learning_paths_for_assessment"("weak_competency_areas" "text"[], "overall_score" integer, "assessment_level" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_learning_paths_for_assessment"("weak_competency_areas" "text"[], "overall_score" integer, "assessment_level" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_or_create_user_workbook"("user_id_param" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_or_create_user_workbook"("user_id_param" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_or_create_user_workbook"("user_id_param" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_scoring_tier_basic"("score_percentage" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_scoring_tier_basic"("score_percentage" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_scoring_tier_basic"("score_percentage" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_best_score"("user_uuid" "uuid", "assessment_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_best_score"("user_uuid" "uuid", "assessment_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_best_score"("user_uuid" "uuid", "assessment_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."initialize_user_workbook"("user_id_param" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."initialize_user_workbook"("user_id_param" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."initialize_user_workbook"("user_id_param" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_weakness_score"("score_percentage" integer, "framework_code" "text", "assessment_level_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."is_weakness_score"("score_percentage" integer, "framework_code" "text", "assessment_level_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_weakness_score"("score_percentage" integer, "framework_code" "text", "assessment_level_code" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."store_frontend_insights"("attempt_uuid" "uuid", "frontend_insights" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."store_frontend_insights"("attempt_uuid" "uuid", "frontend_insights" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."store_frontend_insights"("attempt_uuid" "uuid", "frontend_insights" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_attempt_status"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_attempt_status"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_attempt_status"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_workbook_progress_timestamp"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_workbook_progress_timestamp"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_workbook_progress_timestamp"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_workbook_response_timestamp"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_workbook_response_timestamp"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_workbook_response_timestamp"() TO "service_role";


















GRANT ALL ON TABLE "public"."analysis_types" TO "anon";
GRANT ALL ON TABLE "public"."analysis_types" TO "authenticated";
GRANT ALL ON TABLE "public"."analysis_types" TO "service_role";



GRANT ALL ON TABLE "public"."answer_options" TO "anon";
GRANT ALL ON TABLE "public"."answer_options" TO "authenticated";
GRANT ALL ON TABLE "public"."answer_options" TO "service_role";



GRANT ALL ON TABLE "public"."assessment_levels" TO "anon";
GRANT ALL ON TABLE "public"."assessment_levels" TO "authenticated";
GRANT ALL ON TABLE "public"."assessment_levels" TO "service_role";



GRANT ALL ON TABLE "public"."assessment_questions" TO "anon";
GRANT ALL ON TABLE "public"."assessment_questions" TO "authenticated";
GRANT ALL ON TABLE "public"."assessment_questions" TO "service_role";



GRANT ALL ON TABLE "public"."assessments" TO "anon";
GRANT ALL ON TABLE "public"."assessments" TO "authenticated";
GRANT ALL ON TABLE "public"."assessments" TO "service_role";



GRANT ALL ON TABLE "public"."frameworks" TO "anon";
GRANT ALL ON TABLE "public"."frameworks" TO "authenticated";
GRANT ALL ON TABLE "public"."frameworks" TO "service_role";



GRANT ALL ON TABLE "public"."assessment_overview" TO "anon";
GRANT ALL ON TABLE "public"."assessment_overview" TO "authenticated";
GRANT ALL ON TABLE "public"."assessment_overview" TO "service_role";



GRANT ALL ON TABLE "public"."competency_consolidated_insights" TO "anon";
GRANT ALL ON TABLE "public"."competency_consolidated_insights" TO "authenticated";
GRANT ALL ON TABLE "public"."competency_consolidated_insights" TO "service_role";



GRANT ALL ON TABLE "public"."competency_display_names" TO "anon";
GRANT ALL ON TABLE "public"."competency_display_names" TO "authenticated";
GRANT ALL ON TABLE "public"."competency_display_names" TO "service_role";



GRANT ALL ON TABLE "public"."competency_leverage_strengths" TO "anon";
GRANT ALL ON TABLE "public"."competency_leverage_strengths" TO "authenticated";
GRANT ALL ON TABLE "public"."competency_leverage_strengths" TO "service_role";



GRANT ALL ON TABLE "public"."competency_performance_analysis" TO "anon";
GRANT ALL ON TABLE "public"."competency_performance_analysis" TO "authenticated";
GRANT ALL ON TABLE "public"."competency_performance_analysis" TO "service_role";



GRANT ALL ON TABLE "public"."competency_rich_insights" TO "anon";
GRANT ALL ON TABLE "public"."competency_rich_insights" TO "authenticated";
GRANT ALL ON TABLE "public"."competency_rich_insights" TO "service_role";



GRANT ALL ON TABLE "public"."competency_strategic_actions" TO "anon";
GRANT ALL ON TABLE "public"."competency_strategic_actions" TO "authenticated";
GRANT ALL ON TABLE "public"."competency_strategic_actions" TO "service_role";



GRANT ALL ON TABLE "public"."framework_scoring_overrides" TO "anon";
GRANT ALL ON TABLE "public"."framework_scoring_overrides" TO "authenticated";
GRANT ALL ON TABLE "public"."framework_scoring_overrides" TO "service_role";



GRANT ALL ON TABLE "public"."learning_logs" TO "anon";
GRANT ALL ON TABLE "public"."learning_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."learning_logs" TO "service_role";



GRANT ALL ON TABLE "public"."learning_path_categories" TO "anon";
GRANT ALL ON TABLE "public"."learning_path_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."learning_path_categories" TO "service_role";



GRANT ALL ON TABLE "public"."learning_resource_competencies" TO "anon";
GRANT ALL ON TABLE "public"."learning_resource_competencies" TO "authenticated";
GRANT ALL ON TABLE "public"."learning_resource_competencies" TO "service_role";



GRANT ALL ON TABLE "public"."learning_resources" TO "anon";
GRANT ALL ON TABLE "public"."learning_resources" TO "authenticated";
GRANT ALL ON TABLE "public"."learning_resources" TO "service_role";



GRANT ALL ON TABLE "public"."scoring_tiers" TO "anon";
GRANT ALL ON TABLE "public"."scoring_tiers" TO "authenticated";
GRANT ALL ON TABLE "public"."scoring_tiers" TO "service_role";



GRANT ALL ON TABLE "public"."leverage_strengths_with_analysis_type" TO "anon";
GRANT ALL ON TABLE "public"."leverage_strengths_with_analysis_type" TO "authenticated";
GRANT ALL ON TABLE "public"."leverage_strengths_with_analysis_type" TO "service_role";



GRANT ALL ON TABLE "public"."performance_analysis_with_analysis_type" TO "anon";
GRANT ALL ON TABLE "public"."performance_analysis_with_analysis_type" TO "authenticated";
GRANT ALL ON TABLE "public"."performance_analysis_with_analysis_type" TO "service_role";



GRANT ALL ON TABLE "public"."resource_types" TO "anon";
GRANT ALL ON TABLE "public"."resource_types" TO "authenticated";
GRANT ALL ON TABLE "public"."resource_types" TO "service_role";



GRANT ALL ON TABLE "public"."rich_insights_compatibility" TO "anon";
GRANT ALL ON TABLE "public"."rich_insights_compatibility" TO "authenticated";
GRANT ALL ON TABLE "public"."rich_insights_compatibility" TO "service_role";



GRANT ALL ON TABLE "public"."self_study" TO "anon";
GRANT ALL ON TABLE "public"."self_study" TO "authenticated";
GRANT ALL ON TABLE "public"."self_study" TO "service_role";



GRANT ALL ON TABLE "public"."skill_tags" TO "anon";
GRANT ALL ON TABLE "public"."skill_tags" TO "authenticated";
GRANT ALL ON TABLE "public"."skill_tags" TO "service_role";



GRANT ALL ON TABLE "public"."strategic_actions_with_analysis_type" TO "anon";
GRANT ALL ON TABLE "public"."strategic_actions_with_analysis_type" TO "authenticated";
GRANT ALL ON TABLE "public"."strategic_actions_with_analysis_type" TO "service_role";



GRANT ALL ON TABLE "public"."tag_actions" TO "anon";
GRANT ALL ON TABLE "public"."tag_actions" TO "authenticated";
GRANT ALL ON TABLE "public"."tag_actions" TO "service_role";



GRANT ALL ON TABLE "public"."tag_insights" TO "anon";
GRANT ALL ON TABLE "public"."tag_insights" TO "authenticated";
GRANT ALL ON TABLE "public"."tag_insights" TO "service_role";



GRANT ALL ON TABLE "public"."temporary_pdf_files" TO "anon";
GRANT ALL ON TABLE "public"."temporary_pdf_files" TO "authenticated";
GRANT ALL ON TABLE "public"."temporary_pdf_files" TO "service_role";



GRANT ALL ON TABLE "public"."user_assessment_attempts" TO "anon";
GRANT ALL ON TABLE "public"."user_assessment_attempts" TO "authenticated";
GRANT ALL ON TABLE "public"."user_assessment_attempts" TO "service_role";



GRANT ALL ON TABLE "public"."user_question_responses" TO "anon";
GRANT ALL ON TABLE "public"."user_question_responses" TO "authenticated";
GRANT ALL ON TABLE "public"."user_question_responses" TO "service_role";



GRANT ALL ON TABLE "public"."user_assessment_progress" TO "authenticated";
GRANT ALL ON TABLE "public"."user_assessment_progress" TO "service_role";



GRANT ALL ON TABLE "public"."user_competency_performance" TO "authenticated";
GRANT ALL ON TABLE "public"."user_competency_performance" TO "service_role";



GRANT ALL ON TABLE "public"."v_assessment_responses" TO "anon";
GRANT ALL ON TABLE "public"."v_assessment_responses" TO "authenticated";
GRANT ALL ON TABLE "public"."v_assessment_responses" TO "service_role";



GRANT ALL ON TABLE "public"."workbook_field_definitions" TO "anon";
GRANT ALL ON TABLE "public"."workbook_field_definitions" TO "authenticated";
GRANT ALL ON TABLE "public"."workbook_field_definitions" TO "service_role";



GRANT ALL ON TABLE "public"."workbook_progress" TO "anon";
GRANT ALL ON TABLE "public"."workbook_progress" TO "authenticated";
GRANT ALL ON TABLE "public"."workbook_progress" TO "service_role";



GRANT ALL ON TABLE "public"."workbook_responses" TO "anon";
GRANT ALL ON TABLE "public"."workbook_responses" TO "authenticated";
GRANT ALL ON TABLE "public"."workbook_responses" TO "service_role";



GRANT ALL ON TABLE "public"."workbook_sections" TO "anon";
GRANT ALL ON TABLE "public"."workbook_sections" TO "authenticated";
GRANT ALL ON TABLE "public"."workbook_sections" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






























RESET ALL;
