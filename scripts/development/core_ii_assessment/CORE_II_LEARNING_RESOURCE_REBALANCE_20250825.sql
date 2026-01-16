-- ============================================================================
-- CORE II LEARNING RESOURCE REBALANCE - PRODUCTION FIX
-- Date: 2025-08-25
-- Purpose: Fix empty learning paths by rebalancing resource distribution
-- Issue: Weakness tier has only 2 resources, causing empty learning paths
-- Solution: Rebalance to 6 weakness, 9 developing, 10 strength (25 total)
-- ============================================================================

BEGIN;

-- Current problematic distribution:
-- - Weakness: 2 resources (PROBLEM)
-- - Developing: 12 resources 
-- - Strength: 11 resources
-- Target balanced distribution:
-- - Weakness: 6 resources (3x improvement)
-- - Developing: 9 resources
-- - Strength: 10 resources

-- Move 3 developing resources to weakness tier (strengthen foundation)
UPDATE learning_resources 
SET analysis_type_id = 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4'  -- Weakness Analysis
WHERE assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'  -- Core II
AND id IN (
    'de6b5e26-063f-4c69-a796-24a1c20937a9',  -- The Power of Listening
    'c20cdbbd-53f7-4627-9f81-bfcc7cb552ec',  -- Full Spectrum Listening Practice  
    '35975b9d-e076-460c-a6d9-5ea7432fc3b5'   -- Appreciative Inquiry Coach Training
);

-- Move 1 developing resource to weakness tier (critical foundation skill)
UPDATE learning_resources 
SET analysis_type_id = 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4'  -- Weakness Analysis
WHERE assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'  -- Core II
AND id = '0b4fa09a-cb67-447f-a42b-6a214d176a53';  -- Trauma-Informed Coaching Certification

-- Move 1 strength resource to weakness tier (essential intermediate skill)
UPDATE learning_resources 
SET analysis_type_id = 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4'  -- Weakness Analysis
WHERE assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'  -- Core II
AND id = '0deed178-285c-49da-931a-84cc17e1667e';  -- Embracing Our Selves

-- Move 1 strength resource to weakness tier (core foundation)
UPDATE learning_resources 
SET analysis_type_id = 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4'  -- Weakness Analysis
WHERE assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'  -- Core II
AND id = 'c1f19abe-7626-41c5-a603-24fde6e5959a';  -- Daring Greatly

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify new distribution
SELECT 'REBALANCED DISTRIBUTION:' as status;
SELECT 
    at.name as analysis_type,
    at.id as analysis_type_id,
    COUNT(lr.id) as resource_count,
    CASE at.name
        WHEN 'Weakness Analysis' THEN 6
        WHEN 'Developing Analysis' THEN 9  
        WHEN 'Strength Analysis' THEN 10
    END as expected_count,
    CASE 
        WHEN at.name = 'Weakness Analysis' AND COUNT(lr.id) = 6 THEN '✅'
        WHEN at.name = 'Developing Analysis' AND COUNT(lr.id) = 9 THEN '✅'
        WHEN at.name = 'Strength Analysis' AND COUNT(lr.id) = 10 THEN '✅'
        ELSE '❌'
    END as status
FROM analysis_types at
LEFT JOIN learning_resources lr ON lr.analysis_type_id = at.id 
    AND lr.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
GROUP BY at.id, at.name
ORDER BY at.name;

SELECT '🎉 CORE II LEARNING RESOURCE REBALANCE COMPLETED!' as final_status;