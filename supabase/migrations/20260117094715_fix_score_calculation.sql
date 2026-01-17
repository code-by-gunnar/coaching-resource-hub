-- ============================================================================
-- Fix AI Assessment Score Calculation Function
-- ============================================================================
-- The original function had issues with:
-- 1. Improper GROUP BY with jsonb_object_agg
-- 2. Not correctly aggregating competency scores
-- ============================================================================

CREATE OR REPLACE FUNCTION ai_calculate_competency_scores(
    p_attempt_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_scores JSONB := '{}'::jsonb;
    v_total_correct INTEGER := 0;
    v_total_questions INTEGER := 0;
    v_percentage DECIMAL(5,2);
    rec RECORD;
BEGIN
    -- First, calculate per-competency scores
    FOR rec IN
        WITH answer_analysis AS (
            SELECT
                c.code as competency_code,
                c.name as competency_name,
                q.id as question_id,
                (a.answers->>q.id::text) as selected,
                q.correct_option,
                CASE WHEN (a.answers->>q.id::text) = q.correct_option THEN 1 ELSE 0 END as is_correct
            FROM ai_assessment_attempts a
            CROSS JOIN LATERAL jsonb_array_elements_text(a.questions_served) AS qs(question_id)
            JOIN ai_questions q ON q.id = qs.question_id::uuid
            JOIN ai_competencies c ON q.competency_id = c.id
            WHERE a.id = p_attempt_id
        )
        SELECT
            competency_code,
            competency_name,
            SUM(is_correct) as correct_count,
            COUNT(*) as total_count,
            ROUND((SUM(is_correct)::numeric / NULLIF(COUNT(*)::numeric, 0)) * 100, 1) as pct
        FROM answer_analysis
        GROUP BY competency_code, competency_name
    LOOP
        -- Build the competency scores JSON
        v_scores := v_scores || jsonb_build_object(
            rec.competency_name,
            jsonb_build_object(
                'correct', rec.correct_count,
                'total', rec.total_count,
                'percentage', rec.pct
            )
        );

        -- Track totals
        v_total_correct := v_total_correct + rec.correct_count;
        v_total_questions := v_total_questions + rec.total_count;
    END LOOP;

    -- Calculate overall percentage
    IF v_total_questions > 0 THEN
        v_percentage := ROUND((v_total_correct::numeric / v_total_questions::numeric) * 100, 1);
    ELSE
        v_percentage := 0;
    END IF;

    -- Update the attempt with calculated scores
    UPDATE ai_assessment_attempts
    SET
        competency_scores = v_scores,
        score_percentage = v_percentage
    WHERE id = p_attempt_id;

    RETURN v_scores;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION ai_calculate_competency_scores(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION ai_calculate_competency_scores(UUID) TO service_role;

-- ============================================================================
-- Now recalculate scores for any existing completed attempts that have NULL scores
-- ============================================================================

DO $$
DECLARE
    attempt_rec RECORD;
BEGIN
    FOR attempt_rec IN
        SELECT id FROM ai_assessment_attempts
        WHERE completed_at IS NOT NULL
          AND (score_percentage IS NULL OR competency_scores IS NULL)
    LOOP
        PERFORM ai_calculate_competency_scores(attempt_rec.id);
    END LOOP;
END $$;
