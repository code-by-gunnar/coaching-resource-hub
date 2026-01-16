-- ====================================================================
-- MIGRATION 002: Fix get_learning_paths_for_assessment function
-- ====================================================================
-- Purpose: Update the get_learning_paths_for_assessment function to use
--          the new normalized database schema with FK relationships
-- ====================================================================

-- Drop the old function
DROP FUNCTION IF EXISTS get_learning_paths_for_assessment(text[], integer);

-- Recreate with normalized schema support
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
        "lpc"."id" as category_id,
        "lpc"."category_title",
        "lpc"."category_description",
        "lpc"."category_icon",
        ARRAY(
            SELECT json_build_object(
                'title', "lr"."title",
                'description', "lr"."description",
                'resource_type', "rt"."code",
                'url', "lr"."url",
                'author', "lr"."author_instructor",
                'competency_areas', ARRAY(
                    SELECT "cd"."display_name"
                    FROM "public"."learning_resource_competencies" "lrc"
                    JOIN "public"."competency_display_names" "cd" ON "lrc"."competency_id" = "cd"."id"
                    WHERE "lrc"."learning_resource_id" = "lr"."id"
                    AND "cd"."is_active" = true
                )
            )
            FROM "public"."learning_resources" "lr"
            JOIN "public"."resource_types" "rt" ON "lr"."resource_type_id" = "rt"."id"
            JOIN "public"."learning_path_categories" "lpc2" ON "lr"."learning_path_category_id" = "lpc2"."id"
            WHERE "lpc2"."id" = "lpc"."id"
            AND "lr"."score_range_min" <= overall_score
            AND "lr"."score_range_max" >= overall_score
            AND "lr"."is_active" = true
            AND EXISTS (
                -- Check if resource matches any weak competency areas
                SELECT 1
                FROM "public"."learning_resource_competencies" "lrc"
                JOIN "public"."competency_display_names" "cd" ON "lrc"."competency_id" = "cd"."id"
                WHERE "lrc"."learning_resource_id" = "lr"."id"
                AND "cd"."display_name" = ANY(weak_competency_areas)
                AND "cd"."is_active" = true
            )
            ORDER BY "lr"."sort_order", "lr"."title"
            LIMIT 5
        ) as resources
    FROM "public"."learning_path_categories" "lpc"
    WHERE EXISTS (
        -- Only include categories that have resources for the weak competency areas
        SELECT 1
        FROM "public"."learning_resources" "lr"
        JOIN "public"."learning_resource_competencies" "lrc" ON "lr"."id" = "lrc"."learning_resource_id"
        JOIN "public"."competency_display_names" "cd" ON "lrc"."competency_id" = "cd"."id"
        WHERE "lr"."learning_path_category_id" = "lpc"."id"
        AND "cd"."display_name" = ANY(weak_competency_areas)
        AND "lr"."score_range_min" <= overall_score
        AND "lr"."score_range_max" >= overall_score
        AND "lr"."is_active" = true
        AND "cd"."is_active" = true
    )
    ORDER BY "lpc"."priority_order", "lpc"."category_title";
END;
$$;

-- Grant permissions
GRANT ALL ON FUNCTION get_learning_paths_for_assessment(text[], integer) TO anon;
GRANT ALL ON FUNCTION get_learning_paths_for_assessment(text[], integer) TO authenticated;
GRANT ALL ON FUNCTION get_learning_paths_for_assessment(text[], integer) TO service_role;