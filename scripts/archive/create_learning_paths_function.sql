-- ====================================================================
-- CREATE LEARNING PATHS FUNCTION
-- ====================================================================
-- Purpose: Create the get_learning_paths_for_assessment function that the frontend expects
-- ====================================================================

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
            FROM learning_resources lr
            WHERE lr.category_id = lpc.id
            AND (
                -- Include resources that match weak competency areas
                lr.competency_areas && weak_competency_areas
                OR
                -- Or include general resources for any score
                lr.competency_areas @> ARRAY['Active Listening', 'Powerful Questions', 'Present Moment Awareness', 'Creating Awareness', 'Direct Communication', 'Trust & Safety', 'Managing Progress']
            )
            AND lr.is_active = true
            ORDER BY lr.title
        ) as resources
    FROM learning_path_categories lpc
    WHERE lpc.is_active = true
    AND EXISTS (
        SELECT 1 FROM learning_resources lr2 
        WHERE lr2.category_id = lpc.id 
        AND lr2.is_active = true
        AND (
            lr2.competency_areas && weak_competency_areas
            OR
            lr2.competency_areas @> ARRAY['Active Listening', 'Powerful Questions', 'Present Moment Awareness', 'Creating Awareness', 'Direct Communication', 'Trust & Safety', 'Managing Progress']
        )
    )
    ORDER BY lpc.priority_order, lpc.category_title;
END;
$$;

-- Test the function
SELECT 'Testing get_learning_paths_for_assessment function:' as test_status;

SELECT 
    category_title,
    category_description,
    array_length(resources, 1) as resource_count
FROM get_learning_paths_for_assessment(
    ARRAY['Active Listening', 'Powerful Questions'], 
    60
);

SELECT 'Learning paths function created and tested successfully' as status;