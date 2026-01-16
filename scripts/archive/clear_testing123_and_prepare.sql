-- ====================================================================
-- CLEAR TESTING123 AND PREPARE FOR REAL CORE I BEGINNER ASSESSMENT
-- ====================================================================
-- Purpose: Remove all Testing123 test data and prepare for real content
-- WARNING: This will clear assessment questions and related data
-- ====================================================================

-- Step 1: Clear Testing123 questions and responses
DELETE FROM user_assessment_responses 
WHERE assessment_question_id IN (
    SELECT id FROM assessment_questions 
    WHERE question LIKE '%Testing123%' 
    OR scenario LIKE '%Testing123%'
    OR competency_area LIKE '%Testing123%'
);

DELETE FROM assessment_questions 
WHERE question LIKE '%Testing123%' 
OR scenario LIKE '%Testing123%'
OR competency_area LIKE '%Testing123%';

-- Step 2: Clear Testing123 from normalization tables
DELETE FROM competency_strategic_actions WHERE competency_area LIKE '%Testing123%';
DELETE FROM competency_performance_analysis WHERE competency_area LIKE '%Testing123%';
DELETE FROM competency_leverage_strengths WHERE competency_area LIKE '%Testing123%';
DELETE FROM skill_tags WHERE competency_area LIKE '%Testing123%';
DELETE FROM skill_tag_insights WHERE tag_name LIKE '%Testing123%';
DELETE FROM skill_tag_actions WHERE tag_name LIKE '%Testing123%';

-- Step 3: Clear Testing123 learning resources
DELETE FROM learning_resources WHERE title LIKE '%Testing123%' OR description LIKE '%Testing123%';
DELETE FROM learning_path_categories WHERE category_title LIKE '%Testing123%' OR category_description LIKE '%Testing123%';

-- Step 4: Clear Testing123 display names
DELETE FROM competency_display_names WHERE display_name LIKE '%Testing123%';

-- Step 5: Reset user attempts for clean testing
-- Optional: Uncomment if you want to clear all test attempts
-- TRUNCATE TABLE user_assessment_attempts CASCADE;
-- TRUNCATE TABLE user_assessment_responses CASCADE;

-- Step 6: Verify cleanup
SELECT 'Cleanup Complete' as status;

SELECT 
    'Questions' as table_name,
    COUNT(*) as remaining_count 
FROM assessment_questions 
WHERE question LIKE '%Testing123%' 
OR scenario LIKE '%Testing123%'
OR competency_area LIKE '%Testing123%'

UNION ALL

SELECT 
    'Strategic Actions' as table_name,
    COUNT(*) as remaining_count 
FROM competency_strategic_actions 
WHERE competency_area LIKE '%Testing123%'

UNION ALL

SELECT 
    'Learning Resources' as table_name,
    COUNT(*) as remaining_count 
FROM learning_resources 
WHERE title LIKE '%Testing123%' OR description LIKE '%Testing123%';

-- All counts should be 0 if cleanup was successful