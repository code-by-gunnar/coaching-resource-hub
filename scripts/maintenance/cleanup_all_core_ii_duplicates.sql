-- =============================================
-- COMPREHENSIVE CORE II DUPLICATE CLEANUP
-- =============================================
-- Purpose: Remove all duplicate entries that may have been created during Core II deployment
-- Target: All Core II Intermediate assessment tables
-- Strategy: Keep earliest created entry, remove later duplicates
-- =============================================

BEGIN;

-- =============================================
-- 1. CLEANUP SKILL_TAGS DUPLICATES
-- =============================================
SELECT '🧹 CLEANING UP SKILL_TAGS DUPLICATES...' as status;

-- Show duplicates before cleanup
SELECT 'BEFORE - skill_tags duplicates:' as check_type, name, COUNT(*) as count 
FROM skill_tags 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
GROUP BY name, framework_id, assessment_level_id, competency_id 
HAVING COUNT(*) > 1;

-- Remove skill_tags duplicates
WITH duplicate_groups AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (
            PARTITION BY name, framework_id, assessment_level_id, competency_id 
            ORDER BY created_at ASC, id ASC
        ) as rn
    FROM skill_tags 
    WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
    AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
)
DELETE FROM skill_tags 
WHERE id IN (
    SELECT id FROM duplicate_groups WHERE rn > 1
);

-- =============================================
-- 2. CLEANUP COMPETENCY_STRATEGIC_ACTIONS DUPLICATES
-- =============================================
SELECT '🧹 CLEANING UP STRATEGIC_ACTIONS DUPLICATES...' as status;

-- Remove strategic actions duplicates (keep earliest by action_text + score ranges)
WITH duplicate_groups AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (
            PARTITION BY action_text, framework_id, assessment_level_id, competency_id, score_range_min, score_range_max
            ORDER BY created_at ASC, id ASC
        ) as rn
    FROM competency_strategic_actions 
    WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
    AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
)
DELETE FROM competency_strategic_actions 
WHERE id IN (
    SELECT id FROM duplicate_groups WHERE rn > 1
);

-- =============================================
-- 3. CLEANUP COMPETENCY_LEVERAGE_STRENGTHS DUPLICATES
-- =============================================
SELECT '🧹 CLEANING UP LEVERAGE_STRENGTHS DUPLICATES...' as status;

-- Remove leverage strengths duplicates
WITH duplicate_groups AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (
            PARTITION BY leverage_text, framework_id, assessment_level_id, competency_id
            ORDER BY created_at ASC, id ASC
        ) as rn
    FROM competency_leverage_strengths 
    WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
    AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
)
DELETE FROM competency_leverage_strengths 
WHERE id IN (
    SELECT id FROM duplicate_groups WHERE rn > 1
);

-- =============================================
-- 4. CLEANUP COMPETENCY_PERFORMANCE_ANALYSIS DUPLICATES
-- =============================================
SELECT '🧹 CLEANING UP PERFORMANCE_ANALYSIS DUPLICATES...' as status;

-- Remove performance analysis duplicates
WITH duplicate_groups AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (
            PARTITION BY analysis_text, framework_id, assessment_level_id, competency_id, analysis_type_id
            ORDER BY created_at ASC, id ASC
        ) as rn
    FROM competency_performance_analysis 
    WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
    AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
)
DELETE FROM competency_performance_analysis 
WHERE id IN (
    SELECT id FROM duplicate_groups WHERE rn > 1
);

-- =============================================
-- 5. CLEANUP COMPETENCY_RICH_INSIGHTS DUPLICATES
-- =============================================
SELECT '🧹 CLEANING UP RICH_INSIGHTS DUPLICATES...' as status;

-- Remove rich insights duplicates
WITH duplicate_groups AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (
            PARTITION BY primary_insight, framework_id, assessment_level_id, competency_id
            ORDER BY created_at ASC, id ASC
        ) as rn
    FROM competency_rich_insights 
    WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
    AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
)
DELETE FROM competency_rich_insights 
WHERE id IN (
    SELECT id FROM duplicate_groups WHERE rn > 1
);

-- =============================================
-- 6. CLEANUP COMPETENCY_CONSOLIDATED_INSIGHTS DUPLICATES
-- =============================================
SELECT '🧹 CLEANING UP CONSOLIDATED_INSIGHTS DUPLICATES...' as status;

-- Remove consolidated insights duplicates (this one has unique constraint so may not have dupes)
WITH duplicate_groups AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (
            PARTITION BY competency_id, framework_id, assessment_level_id, analysis_type_id
            ORDER BY created_at ASC, id ASC
        ) as rn
    FROM competency_consolidated_insights 
    WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
    AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
)
DELETE FROM competency_consolidated_insights 
WHERE id IN (
    SELECT id FROM duplicate_groups WHERE rn > 1
);

-- =============================================
-- 7. CLEANUP TAG_INSIGHTS DUPLICATES (if any)
-- =============================================
SELECT '🧹 CLEANING UP TAG_INSIGHTS DUPLICATES...' as status;

-- Remove tag insights duplicates
WITH duplicate_groups AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (
            PARTITION BY skill_tag_id, insight_text, assessment_level_id, analysis_type_id
            ORDER BY created_at ASC, id ASC
        ) as rn
    FROM tag_insights ti
    JOIN skill_tags st ON ti.skill_tag_id = st.id
    WHERE ti.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
    AND st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
)
DELETE FROM tag_insights 
WHERE id IN (
    SELECT id FROM duplicate_groups WHERE rn > 1
);

-- =============================================
-- FINAL VERIFICATION
-- =============================================
SELECT '✅ CLEANUP COMPLETE - VERIFICATION:' as status;

-- Verify skill_tags count (should be 26)
SELECT 'skill_tags' as table_name, COUNT(*) as count, 26 as expected,
    CASE WHEN COUNT(*) = 26 THEN '✅' ELSE '❌' END as status
FROM skill_tags 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'

UNION ALL

-- Verify strategic actions count (should be 20: 4 actions × 5 competencies)
SELECT 'strategic_actions' as table_name, COUNT(*) as count, 20 as expected,
    CASE WHEN COUNT(*) = 20 THEN '✅' ELSE '❌' END as status
FROM competency_strategic_actions 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'

UNION ALL

-- Verify leverage strengths count (should be 10: 2 × 5 competencies)
SELECT 'leverage_strengths' as table_name, COUNT(*) as count, 10 as expected,
    CASE WHEN COUNT(*) = 10 THEN '✅' ELSE '❌' END as status
FROM competency_leverage_strengths 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'

UNION ALL

-- Verify rich insights count (should be 5: 1 per competency)
SELECT 'rich_insights' as table_name, COUNT(*) as count, 5 as expected,
    CASE WHEN COUNT(*) = 5 THEN '✅' ELSE '❌' END as status
FROM competency_rich_insights 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'

UNION ALL

-- Verify consolidated insights count (should be 10: 2 per competency - strength + weakness)
SELECT 'consolidated_insights' as table_name, COUNT(*) as count, 10 as expected,
    CASE WHEN COUNT(*) = 10 THEN '✅' ELSE '❌' END as status
FROM competency_consolidated_insights 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

-- Check for any remaining duplicates
SELECT 'FINAL DUPLICATE CHECK:' as status;
SELECT 'No remaining duplicates found' as result
WHERE NOT EXISTS (
    SELECT 1 FROM skill_tags 
    WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
    AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
    GROUP BY name, framework_id, assessment_level_id, competency_id 
    HAVING COUNT(*) > 1
);

COMMIT;

SELECT '🎉 CORE II DUPLICATE CLEANUP COMPLETED SUCCESSFULLY!' as final_status;