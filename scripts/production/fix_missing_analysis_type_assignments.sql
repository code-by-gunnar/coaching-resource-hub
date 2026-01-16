-- Fix missing analysis_type_id assignments for all Core I resources
-- Assigns every resource to the appropriate tier
-- Run Date: 2025-08-24

BEGIN;

-- ===================================================================
-- SECTION 1: ASSIGN REMAINING WEAKNESS TIER RESOURCES (Foundational)
-- ===================================================================

UPDATE learning_resources 
SET analysis_type_id = 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4' -- weakness
WHERE title IN (
  'Coaching Basics: Getting Started Guide',
  'Introduction to Powerful Questions'
)
AND framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
AND assessment_level_id = '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132'
AND analysis_type_id IS NULL;

-- ===================================================================
-- SECTION 2: ASSIGN REMAINING DEVELOPING TIER RESOURCES (Skill Building)
-- ===================================================================

UPDATE learning_resources 
SET analysis_type_id = 'a287b894-c573-4b5e-978a-5ab17b4d290d' -- developing
WHERE title IN (
  'Active Listening Practice Exercises',
  'Developing Present Moment Awareness'
)
AND framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
AND assessment_level_id = '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132'
AND analysis_type_id IS NULL;

-- ===================================================================
-- SECTION 3: ASSIGN REMAINING STRENGTH TIER RESOURCES (Advanced)
-- ===================================================================

UPDATE learning_resources 
SET analysis_type_id = '378c3fca-d674-469a-b8cd-45e818410a25' -- strength
WHERE title IN (
  'The Coaching Habit: Say Less, Ask More & Change the Way You Lead Forever',
  'Presence-Based Coaching: Cultivating Self-Generative Leaders',
  'Coaching for Performance: The Principles and Practice of Coaching and Leadership',
  'Advanced Coaching Conversations Masterclass',
  'Mastery in Transformational Questioning',
  'Professional Coaching Supervision Skills',
  'Advanced Mindful Coaching Mastery Course',
  'Executive Presence for Coaching Leaders',
  'Advanced Coaching Research: Neuroscience of Powerful Questions',
  'Mastering Somatic Awareness in Coaching',
  'Complex Scenario Coaching Practice Lab',
  'Advanced Presence Calibration Exercises'
)
AND framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
AND assessment_level_id = '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132'
AND analysis_type_id IS NULL;

-- ===================================================================
-- SECTION 4: SAFETY CHECK - Assign any remaining NULL resources to developing
-- ===================================================================

-- Catch any remaining unassigned resources and put them in developing tier as safe default
UPDATE learning_resources 
SET analysis_type_id = 'a287b894-c573-4b5e-978a-5ab17b4d290d' -- developing (safe default)
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
AND assessment_level_id = '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132'
AND is_active = true
AND analysis_type_id IS NULL;

-- ===================================================================
-- SECTION 5: FINAL VERIFICATION
-- ===================================================================

-- Show complete distribution by tier
SELECT 
  at.code as tier,
  at.name as tier_name,
  COUNT(lr.id) as resource_count,
  STRING_AGG(lr.title, '; ' ORDER BY lr.title) as resource_titles
FROM analysis_types at
LEFT JOIN learning_resources lr ON lr.analysis_type_id = at.id 
  AND lr.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
  AND lr.assessment_level_id = '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132'
  AND lr.is_active = true
WHERE at.is_active = true
GROUP BY at.id, at.code, at.name
ORDER BY 
  CASE at.code 
    WHEN 'weakness' THEN 1
    WHEN 'developing' THEN 2
    WHEN 'strength' THEN 3
    ELSE 4
  END;

-- Check for any remaining unassigned resources
SELECT 
  COUNT(*) as unassigned_count,
  STRING_AGG(title, '; ') as unassigned_titles
FROM learning_resources
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
AND assessment_level_id = '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132'
AND is_active = true
AND analysis_type_id IS NULL;

COMMIT;

-- Success message
SELECT 'All Core I resources successfully assigned to analysis_types!' as status;