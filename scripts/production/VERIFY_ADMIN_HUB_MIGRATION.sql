-- =====================================================================================
-- ADMIN HUB MIGRATION VERIFICATION SCRIPT
-- =====================================================================================
-- 
-- Run this script after applying ADMIN_HUB_MIGRATION_20250814.sql to verify
-- all changes were applied correctly.
--
-- =====================================================================================

\echo 'Starting Admin Hub Migration Verification...'
\echo ''

-- 1. Verify learning_path_categories schema has correct columns
\echo '1. Verifying learning_path_categories schema:'
\d learning_path_categories

\echo ''
\echo '2. Verifying foreign key relationships:'
SELECT 
    lpc.category_title,
    al.level_code,
    al.level_name,
    lpc.competency_areas,
    lpc.is_active
FROM learning_path_categories lpc 
LEFT JOIN assessment_levels al ON lpc.assessment_level_id = al.id 
ORDER BY lpc.category_title;

\echo ''
\echo '3. Testing learning paths function with BEGINNER level:'
SELECT 
    category_title,
    category_description,
    array_length(resources, 1) as resource_count
FROM get_learning_paths_for_assessment(ARRAY['Active Listening'], 60, 'Beginner');

\echo ''
\echo '4. Testing learning paths function with INTERMEDIATE level:'
SELECT 
    category_title,
    category_description,
    array_length(resources, 1) as resource_count
FROM get_learning_paths_for_assessment(ARRAY['Present Moment Awareness'], 60, 'Intermediate');

\echo ''
\echo '5. Verifying function signature:'
\df get_learning_paths_for_assessment

\echo ''
\echo '6. Checking for orphaned data (should return 0 rows):'
SELECT category_title 
FROM learning_path_categories 
WHERE assessment_level_id IS NULL AND is_active = true;

\echo ''
\echo '7. Verifying assessment levels exist:'
SELECT level_code, level_name, is_active 
FROM assessment_levels 
ORDER BY level_code;

\echo ''
\echo 'Migration verification completed!'
\echo 'Review the output above to ensure all checks passed.'