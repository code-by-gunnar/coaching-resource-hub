-- ====================================================================
-- CHECK PRODUCTION DATABASE CHANGES
-- ====================================================================
-- Purpose: Verify what normalization tables already exist in production
-- ====================================================================

-- Check if normalization tables exist
SELECT 
    table_name,
    CASE 
        WHEN table_name IN (
            'competency_display_names',
            'competency_strategic_actions',
            'competency_performance_analysis',
            'competency_leverage_strengths',
            'skill_tags',
            'skill_tag_insights',
            'skill_tag_actions',
            'learning_path_categories',
            'learning_resources'
        ) THEN 'NORMALIZATION TABLE'
        ELSE 'ORIGINAL TABLE'
    END as table_type
FROM information_schema.tables 
WHERE table_schema = 'public'
AND table_name IN (
    -- Original tables
    'assessments',
    'assessment_questions',
    'user_assessment_attempts',
    'user_assessment_responses',
    'user_profiles',
    -- Normalization tables
    'competency_display_names',
    'competency_strategic_actions',
    'competency_performance_analysis',
    'competency_leverage_strengths',
    'skill_tags',
    'skill_tag_insights',
    'skill_tag_actions',
    'learning_path_categories',
    'learning_resources'
)
ORDER BY table_type, table_name;

-- Check for any Testing123 data in production
SELECT 
    'Testing123 Data Check' as check_type,
    COUNT(*) as count
FROM assessment_questions
WHERE question LIKE '%Testing123%'
OR scenario LIKE '%Testing123%'
OR explanation LIKE '%Testing123%';

-- Check user activity
SELECT 
    'User Activity' as metric,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(*) as total_attempts,
    MAX(created_at) as latest_attempt
FROM user_assessment_attempts;

-- Summary
SELECT 
    'PRODUCTION STATUS' as status,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_name = 'competency_display_names'
        ) THEN 'NORMALIZATION TABLES EXIST - USE CAUTION'
        ELSE 'NO NORMALIZATION TABLES - SAFE TO PROCEED'
    END as normalization_status;