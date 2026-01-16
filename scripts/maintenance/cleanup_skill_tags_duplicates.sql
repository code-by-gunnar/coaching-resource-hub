-- =============================================
-- SKILL TAGS DUPLICATE CLEANUP
-- =============================================
-- Purpose: Remove duplicate skill_tags entries that may have been created during deployment
-- Target: Core II Intermediate assessment duplicates
-- =============================================

BEGIN;

-- Show duplicates before cleanup
SELECT 'BEFORE CLEANUP - Duplicate skill_tags:' as status;
SELECT name, framework_id, assessment_level_id, competency_id, COUNT(*) as count 
FROM skill_tags 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
GROUP BY name, framework_id, assessment_level_id, competency_id 
HAVING COUNT(*) > 1 
ORDER BY name;

-- Method 1: Keep only the earliest created entry for each duplicate group
-- This preserves the original entries and removes later duplicates
WITH duplicate_groups AS (
    SELECT 
        id,
        name,
        framework_id,
        assessment_level_id,
        competency_id,
        ROW_NUMBER() OVER (
            PARTITION BY name, framework_id, assessment_level_id, competency_id 
            ORDER BY created_at ASC, id ASC
        ) as rn
    FROM skill_tags 
    WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
    AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
),
duplicates_to_delete AS (
    SELECT id, name
    FROM duplicate_groups 
    WHERE rn > 1
)
DELETE FROM skill_tags 
WHERE id IN (SELECT id FROM duplicates_to_delete);

-- Show results after cleanup
SELECT 'AFTER CLEANUP - Remaining skill_tags:' as status;
SELECT name, framework_id, assessment_level_id, competency_id, COUNT(*) as count 
FROM skill_tags 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
GROUP BY name, framework_id, assessment_level_id, competency_id 
ORDER BY name;

-- Verify total count matches expected (26 skill tags for Core II)
SELECT 'TOTAL COUNT CHECK:' as status;
SELECT COUNT(*) as total_skill_tags, 26 as expected_count,
CASE 
    WHEN COUNT(*) = 26 THEN '✅ CORRECT COUNT' 
    ELSE '❌ INCORRECT COUNT - CHECK FOR MISSING/EXTRA ENTRIES' 
END as validation
FROM skill_tags 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

-- Show final skill_tags by competency for verification
SELECT 'FINAL VERIFICATION - Skills by competency:' as status;
SELECT 
    cdn.display_name as competency,
    COUNT(st.id) as skill_count
FROM skill_tags st
JOIN competency_display_names cdn ON st.competency_id = cdn.id
WHERE st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
GROUP BY cdn.display_name, cdn.id
ORDER BY cdn.display_name;

COMMIT;