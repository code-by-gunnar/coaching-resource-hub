-- =====================================================================================
-- ADMIN HUB MIGRATION VERIFICATION SCRIPT - PRODUCTION VERSION
-- =====================================================================================
-- 
-- Run this script against production database to verify all changes were applied.
-- This version removes psql-specific \echo commands for compatibility with API execution.
--
-- =====================================================================================

-- 1. Verify foreign key relationships
SELECT 
    'Foreign Key Relationships Check' as check_name,
    lpc.category_title,
    al.level_code,
    al.level_name,
    lpc.competency_areas,
    lpc.is_active
FROM learning_path_categories lpc 
LEFT JOIN assessment_levels al ON lpc.assessment_level_id = al.id 
ORDER BY lpc.category_title;

-- 2. Testing learning paths function with BEGINNER level
SELECT 
    'Learning Paths Function Test - BEGINNER' as check_name,
    category_title,
    category_description,
    array_length(resources, 1) as resource_count
FROM get_learning_paths_for_assessment(ARRAY['Active Listening'], 60, 'Beginner');

-- 3. Testing learning paths function with INTERMEDIATE level
SELECT 
    'Learning Paths Function Test - INTERMEDIATE' as check_name,
    category_title,
    category_description,
    array_length(resources, 1) as resource_count
FROM get_learning_paths_for_assessment(ARRAY['Present Moment Awareness'], 60, 'Intermediate');

-- 4. Checking for orphaned data (should return 0 rows)
SELECT 
    'Orphaned Data Check' as check_name,
    category_title,
    'WARNING: Active category without assessment_level_id' as status
FROM learning_path_categories 
WHERE assessment_level_id IS NULL AND is_active = true;

-- 5. Verifying assessment levels exist
SELECT 
    'Assessment Levels Verification' as check_name,
    level_code, 
    level_name, 
    is_active 
FROM assessment_levels 
ORDER BY level_code;

-- 6. Count verification
SELECT 
    'Count Summary' as check_name,
    'learning_path_categories' as table_name,
    COUNT(*) as total_records,
    COUNT(*) FILTER (WHERE is_active = true) as active_records,
    COUNT(*) FILTER (WHERE assessment_level_id IS NOT NULL) as with_level_id
FROM learning_path_categories;

-- 7. Function exists verification
SELECT 
    'Function Verification' as check_name,
    routine_name,
    routine_type,
    'Function exists' as status
FROM information_schema.routines 
WHERE routine_name = 'get_learning_paths_for_assessment'
AND routine_schema = 'public';