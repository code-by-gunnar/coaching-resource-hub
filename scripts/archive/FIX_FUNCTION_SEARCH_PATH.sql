-- ====================================================================
-- FIX FUNCTION SEARCH_PATH SECURITY ISSUES
-- ====================================================================
-- Purpose: Add SET search_path = '' to functions to prevent security vulnerabilities
-- Functions: store_frontend_insights, get_learning_paths_for_assessment
-- ====================================================================

-- Fix store_frontend_insights function
DROP FUNCTION IF EXISTS store_frontend_insights(uuid, jsonb);
CREATE OR REPLACE FUNCTION store_frontend_insights(
    attempt_uuid UUID,
    frontend_insights JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
    UPDATE public.user_assessment_attempts
    SET enriched_data = COALESCE(enriched_data, '{}'::jsonb) || store_frontend_insights.frontend_insights,
        updated_at = NOW()
    WHERE id = attempt_uuid;
    
    RETURN frontend_insights;
END;
$$;

-- Fix get_learning_paths_for_assessment function
DROP FUNCTION IF EXISTS get_learning_paths_for_assessment(text[], integer);
CREATE OR REPLACE FUNCTION get_learning_paths_for_assessment(
    weak_competency_areas text[],
    overall_score integer
)
RETURNS TABLE (
    category_id uuid,
    category_title text,
    category_description text,
    category_icon text,
    resources json[]
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
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
                'resource_type', lr.resource_type,
                'url', lr.url,
                'author', lr.author_instructor,
                'competency_areas', lr.competency_areas
            )
            FROM public.learning_resources lr
            WHERE lr.category_id = lpc.id
            AND lr.is_active = true
            ORDER BY lr.resource_type, lr.title
        ) as resources
    FROM public.learning_path_categories lpc
    WHERE lpc.is_active = true
    AND lpc.assessment_level = 'core-i'
    -- Only show categories where competency areas overlap with weak areas
    AND lpc.competency_areas && weak_competency_areas
    ORDER BY lpc.priority_order, lpc.category_title;
END;
$$;

-- ====================================================================
-- VERIFICATION
-- ====================================================================

-- Check functions have proper search_path settings
SELECT 
    routine_name,
    routine_type,
    security_type,
    routine_definition
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN ('store_frontend_insights', 'get_learning_paths_for_assessment');

-- Success message
DO $$ 
BEGIN 
    RAISE NOTICE '✅ FUNCTION SECURITY FIXED!';
    RAISE NOTICE '';
    RAISE NOTICE '🔒 FUNCTIONS UPDATED:';
    RAISE NOTICE '   ✓ store_frontend_insights: Added SET search_path = ''''';
    RAISE NOTICE '   ✓ get_learning_paths_for_assessment: Added SET search_path = ''''';
    RAISE NOTICE '';
    RAISE NOTICE '🛡️  SECURITY STATUS: Functions are now protected from search_path attacks';
END $$;