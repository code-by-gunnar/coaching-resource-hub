-- ============================================================================
-- Fix ai_report_context view security
-- Changes from SECURITY DEFINER to SECURITY INVOKER so the view respects
-- the caller's permissions and RLS policies rather than the view creator's
-- ============================================================================

-- Drop and recreate the view with SECURITY INVOKER
DROP VIEW IF EXISTS ai_report_context;

CREATE VIEW ai_report_context
WITH (security_invoker = true)
AS
SELECT
    a.id as attempt_id,
    a.user_id,
    a.started_at,
    a.completed_at,
    a.questions_served,
    a.answers,
    a.score_percentage,
    a.competency_scores,
    a.previous_attempt_id,
    a.ai_report,
    a.ai_report_metadata,

    -- Framework/Level info
    f.code as framework_code,
    f.name as framework_name,
    l.level_code,
    l.name as level_name,
    l.passing_score,

    -- Previous attempt for comparison
    prev.score_percentage as prev_score_percentage,
    prev.competency_scores as prev_competency_scores,
    prev.completed_at as prev_completed_at

FROM ai_assessment_attempts a
JOIN ai_frameworks f ON a.framework_id = f.id
JOIN ai_assessment_levels l ON a.level_id = l.id
LEFT JOIN ai_assessment_attempts prev ON a.previous_attempt_id = prev.id;

-- Ensure proper permissions
GRANT SELECT ON ai_report_context TO authenticated;
GRANT SELECT ON ai_report_context TO service_role;

-- Add comment explaining security model
COMMENT ON VIEW ai_report_context IS
'View for generating AI reports - uses SECURITY INVOKER to respect caller permissions and RLS policies';
