-- SECURITY FIX: Remove SECURITY DEFINER from views and add proper access controls
-- This fixes the security vulnerability where views enforce permissions of creator instead of querying user
-- Views should use security_invoker='true' and have proper GRANT permissions

-- Fix assessment_overview view with security_invoker
DROP VIEW IF EXISTS assessment_overview CASCADE;
CREATE OR REPLACE VIEW assessment_overview WITH (security_invoker='true') AS
SELECT 
    a.id, a.slug, a.title, a.description,
    f.code as framework, al.level_code as difficulty,
    a.estimated_duration, a.icon, a.is_active, a.sort_order,
    a.created_at, a.updated_at,
    COALESCE(q.question_count, 0) AS question_count
FROM assessments a
LEFT JOIN frameworks f ON a.framework_id = f.id
LEFT JOIN assessment_levels al ON a.assessment_level_id = al.id
LEFT JOIN (
    SELECT assessment_id, COUNT(*) AS question_count 
    FROM assessment_questions 
    GROUP BY assessment_id
) q ON a.id = q.assessment_id
ORDER BY a.sort_order, a.title;

-- Grant public access to assessment_overview (assessments are public)
GRANT SELECT ON assessment_overview TO anon;
GRANT SELECT ON assessment_overview TO authenticated;
GRANT SELECT ON assessment_overview TO service_role;

-- Fix user_assessment_progress view with security_invoker and user restriction
DROP VIEW IF EXISTS user_assessment_progress CASCADE;
CREATE OR REPLACE VIEW user_assessment_progress WITH (security_invoker='true') AS
SELECT 
    ua.user_id, ua.assessment_id, a.slug AS assessment_slug, a.title AS assessment_title,
    f.code as framework, al.level_code as difficulty,
    ua.status, ua.score, ua.total_questions, ua.correct_answers,
    ua.started_at, ua.completed_at,
    CASE 
        WHEN ua.status = 'completed' THEN 100
        ELSE COALESCE(
            ((SELECT COUNT(*) FROM user_question_responses uqr WHERE uqr.attempt_id = ua.id)::numeric / 
            NULLIF(ua.total_questions, 0)::numeric * 100), 0
        )
    END AS progress_percentage
FROM user_assessment_attempts ua
JOIN assessments a ON ua.assessment_id = a.id
LEFT JOIN frameworks f ON a.framework_id = f.id
LEFT JOIN assessment_levels al ON a.assessment_level_id = al.id
WHERE ua.user_id = auth.uid()  -- Explicit user restriction
ORDER BY ua.started_at DESC;

-- Grant ONLY authenticated access (no anon access for user data)
REVOKE ALL ON user_assessment_progress FROM anon;
GRANT SELECT ON user_assessment_progress TO authenticated;
GRANT SELECT ON user_assessment_progress TO service_role;

-- Fix user_competency_performance view with security_invoker and user restriction
DROP VIEW IF EXISTS user_competency_performance CASCADE;
CREATE OR REPLACE VIEW user_competency_performance WITH (security_invoker='true') AS
SELECT 
    ua.user_id, cd.display_name as competency_area,
    f.code as framework, al.level_code as difficulty,
    COUNT(uqr.id) AS total_answered,
    COUNT(CASE WHEN uqr.is_correct = true THEN 1 END) AS correct_answers,
    CASE 
        WHEN COUNT(uqr.id) > 0 THEN 
            ROUND((COUNT(CASE WHEN uqr.is_correct = true THEN 1 END)::numeric / COUNT(uqr.id)::numeric * 100), 1)
        ELSE 0
    END AS accuracy_percentage,
    AVG(uqr.time_spent) as avg_time_spent
FROM user_assessment_attempts ua
JOIN assessments a ON ua.assessment_id = a.id
LEFT JOIN frameworks f ON a.framework_id = f.id
LEFT JOIN assessment_levels al ON a.assessment_level_id = al.id
JOIN user_question_responses uqr ON uqr.attempt_id = ua.id
JOIN assessment_questions aq ON uqr.question_id = aq.id
JOIN competency_display_names cd ON aq.competency_id = cd.id
WHERE cd.display_name IS NOT NULL
  AND ua.user_id = auth.uid()  -- Explicit user restriction
GROUP BY ua.user_id, cd.display_name, f.code, al.level_code
ORDER BY ua.user_id, cd.display_name;

-- Grant ONLY authenticated access (no anon access for user data)
REVOKE ALL ON user_competency_performance FROM anon;
GRANT SELECT ON user_competency_performance TO authenticated;
GRANT SELECT ON user_competency_performance TO service_role;