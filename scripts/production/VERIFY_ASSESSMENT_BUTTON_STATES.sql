-- =====================================================================================
-- VERIFICATION SCRIPT: Assessment Button States Feature
-- =====================================================================================
-- This script verifies that the assessment button states feature is working correctly
-- Run this after applying ADMIN_HUB_MIGRATION_20250814.sql
-- =====================================================================================

-- 1. Verify all assessments have proper framework and level assignments
SELECT 
    title,
    framework,
    difficulty,
    is_active,
    CASE 
        WHEN is_active THEN 'Take Assessment'
        ELSE 'Not Available'
    END as button_text
FROM assessment_overview 
ORDER BY framework, difficulty;

-- 2. Test framework grouping (should have 3 assessments per framework)
SELECT 
    framework,
    COUNT(*) as total_assessments,
    COUNT(CASE WHEN is_active THEN 1 END) as active_assessments,
    COUNT(CASE WHEN NOT is_active THEN 1 END) as inactive_assessments
FROM assessment_overview 
GROUP BY framework 
ORDER BY framework;

-- 3. Verify assessment level progression (I = beginner, II = intermediate, III = advanced)
SELECT 
    title,
    framework,
    difficulty,
    CASE 
        WHEN title LIKE '%I %' AND difficulty = 'beginner' THEN '✓ Correct'
        WHEN title LIKE '%II %' AND difficulty = 'intermediate' THEN '✓ Correct'  
        WHEN title LIKE '%III %' AND difficulty = 'advanced' THEN '✓ Correct'
        ELSE '❌ Incorrect mapping'
    END as level_mapping_status
FROM assessment_overview 
WHERE framework IN ('icf', 'ac')
ORDER BY framework, difficulty;

-- 4. Check that assessments view is working (used by frontend)
SELECT COUNT(*) as total_assessments_available
FROM assessment_overview;

-- 5. Verify no assessments have NULL framework or difficulty
SELECT 
    COUNT(*) as assessments_with_missing_data
FROM assessment_overview 
WHERE framework IS NULL OR difficulty IS NULL;

-- Expected Results:
-- - Query 1: Should show 9 assessments total with mix of "Take Assessment" and "Not Available"
-- - Query 2: Should show 3 frameworks (ac, core, icf) each with 3 assessments
-- - Query 3: Should show all "✓ Correct" for ICF and AC assessments
-- - Query 4: Should return 9 total assessments
-- - Query 5: Should return 0 (no missing data)