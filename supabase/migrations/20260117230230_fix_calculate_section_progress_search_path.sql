-- ============================================================================
-- Fix calculate_section_progress function search_path
-- ============================================================================
-- The function currently uses SET search_path TO 'public' which is still
-- considered mutable. Changing to SET search_path = '' for security.
-- ============================================================================

-- Version 1: calculate_section_progress(p_workbook_id uuid, p_section_number integer)
CREATE OR REPLACE FUNCTION public.calculate_section_progress(p_workbook_id uuid, p_section_number integer)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    v_total_fields INTEGER;
    v_completed_fields INTEGER;
    v_progress INTEGER;
BEGIN
    -- Count total required fields for this section
    SELECT COUNT(*) INTO v_total_fields
    FROM public.workbook_field_definitions
    WHERE section_number = p_section_number
    AND is_required = true;

    -- If no required fields, check any fields
    IF v_total_fields = 0 THEN
        SELECT COUNT(*) INTO v_total_fields
        FROM public.workbook_field_definitions
        WHERE section_number = p_section_number;
    END IF;

    -- Count completed fields
    SELECT COUNT(*) INTO v_completed_fields
    FROM public.workbook_responses r
    JOIN public.workbook_field_definitions d ON r.field_key = d.field_key
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
    UPDATE public.workbook_sections
    SET progress_percent = v_progress,
        last_updated = now(),
        completed_at = CASE WHEN v_progress = 100 THEN now() ELSE NULL END
    WHERE workbook_id = p_workbook_id AND section_number = p_section_number;

    RETURN v_progress;
END;
$$;

-- Version 2: calculate_section_progress(user_id_param uuid, section_id_param uuid)
CREATE OR REPLACE FUNCTION public.calculate_section_progress(user_id_param uuid, section_id_param uuid)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
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
