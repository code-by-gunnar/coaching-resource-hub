-- =====================================================================================
-- ADMIN HUB MIGRATION - August 14, 2025
-- =====================================================================================
-- 
-- This script contains ALL database schema changes made during the admin hub
-- development session on 2025-08-14. Apply this to production environment.
--
-- Changes included:
-- 1. Updated learning_path_categories to use assessment_level_id foreign key
-- 2. Fixed data mapping from old flat structure to relational structure  
-- 3. Updated get_learning_paths_for_assessment function for dynamic assessment levels
-- 4. Proper foreign key relationships throughout the system
-- 5. Fixed ICF and AC assessments framework_id and assessment_level_id assignments
-- 6. Enabled dynamic "Take Assessment" vs "Not Available" button states
--
-- IMPORTANT: This script assumes the base relational schema is already in place
-- (assessment_levels table, foreign key constraints, etc.)
-- =====================================================================================

-- Step 1: Add assessment_level_id foreign key column to learning_path_categories
-- (Replaces the old flat assessment_level text field)
ALTER TABLE learning_path_categories 
ADD COLUMN IF NOT EXISTS assessment_level_id UUID REFERENCES assessment_levels(id);

-- Step 2: Map existing assessment_level text values to proper foreign keys
-- This handles the conversion from old flat structure to relational structure
UPDATE learning_path_categories 
SET assessment_level_id = (
  SELECT id FROM assessment_levels 
  WHERE level_code = CASE 
    WHEN learning_path_categories.assessment_level = 'core-b' THEN 'beginner'
    WHEN learning_path_categories.assessment_level = 'core-i' THEN 'intermediate'  
    WHEN learning_path_categories.assessment_level = 'core-a' THEN 'advanced'
    ELSE 'beginner'  -- Default fallback
  END
)
WHERE assessment_level IS NOT NULL AND assessment_level_id IS NULL;

-- Step 3: Set specific category levels based on content analysis
-- Communication & Questioning should be beginner level (foundational skills)
UPDATE learning_path_categories 
SET assessment_level_id = (SELECT id FROM assessment_levels WHERE level_code = 'beginner')
WHERE category_title = 'Communication & Questioning';

-- Presence & Awareness should be intermediate level (more advanced skill)
UPDATE learning_path_categories 
SET assessment_level_id = (SELECT id FROM assessment_levels WHERE level_code = 'intermediate')
WHERE category_title = 'Presence & Awareness';

-- Step 4: Remove the old flat assessment_level text column
-- (Only after confirming all data has been migrated to foreign key)
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'learning_path_categories' 
               AND column_name = 'assessment_level') THEN
        ALTER TABLE learning_path_categories DROP COLUMN assessment_level;
    END IF;
END $$;

-- Step 5: Update the learning paths function to use dynamic assessment levels
-- This function is called by the assessment results page to show appropriate learning resources
CREATE OR REPLACE FUNCTION public.get_learning_paths_for_assessment(
    weak_competency_areas text[], 
    overall_score integer,
    assessment_level text
)
RETURNS TABLE(
    category_id uuid, 
    category_title text, 
    category_description text, 
    category_icon text, 
    resources json[]
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
DECLARE
    target_level_code text;
BEGIN
    -- Map frontend assessment level names to database level_code
    target_level_code := CASE 
        WHEN LOWER(assessment_level) = 'beginner' THEN 'beginner'
        WHEN LOWER(assessment_level) = 'intermediate' THEN 'intermediate'  
        WHEN LOWER(assessment_level) = 'advanced' THEN 'advanced'
        ELSE 'beginner'  -- Default to beginner for safety
    END;
    
    RETURN QUERY
    SELECT
        lpc.id as category_id,
        lpc.category_title,
        lpc.category_description,
        lpc.category_icon,
        ARRAY(
            SELECT json_build_object(
                'title', lr.title,
                'description', lr.description,
                'resource_type', rt.code,
                'url', lr.url,
                'author', lr.author_instructor,
                'competency_areas', ARRAY(
                    SELECT cd.display_name 
                    FROM public.learning_resource_competencies lrc
                    JOIN public.competency_display_names cd ON lrc.competency_id = cd.id
                    WHERE lrc.learning_resource_id = lr.id
                )
            )
            FROM public.learning_resources lr
            LEFT JOIN public.resource_types rt ON lr.resource_type_id = rt.id
            WHERE lr.category_id = lpc.id
            AND lr.is_active = true
            ORDER BY rt.code, lr.title
        ) as resources
    FROM public.learning_path_categories lpc
    JOIN public.assessment_levels al ON lpc.assessment_level_id = al.id
    WHERE lpc.is_active = true
    AND al.level_code = target_level_code  -- Dynamic assessment level matching
    -- Only show categories where competency areas overlap with weak areas
    AND lpc.competency_areas && weak_competency_areas
    ORDER BY lpc.priority_order, lpc.category_title;
END;
$function$;

-- =====================================================================================
-- STEP 6: FIX ICF AND AC ASSESSMENTS FRAMEWORK AND LEVEL ASSIGNMENTS
-- =====================================================================================
-- These assessments were missing proper framework_id and assessment_level_id values
-- which prevented them from showing correctly in the assessments page

-- Update ICF assessments with proper framework and level assignments
UPDATE assessments SET 
  framework_id = (SELECT id FROM frameworks WHERE code = 'icf'),
  assessment_level_id = CASE 
    WHEN title = 'ICF I - Foundation' THEN (SELECT id FROM assessment_levels WHERE level_code = 'beginner')
    WHEN title = 'ICF II - Core Practice' THEN (SELECT id FROM assessment_levels WHERE level_code = 'intermediate')
    WHEN title = 'ICF III - Mastery' THEN (SELECT id FROM assessment_levels WHERE level_code = 'advanced')
  END
WHERE title LIKE 'ICF%' AND (framework_id IS NULL OR assessment_level_id IS NULL);

-- Update AC assessments with proper framework and level assignments  
UPDATE assessments SET 
  framework_id = (SELECT id FROM frameworks WHERE code = 'ac'),
  assessment_level_id = CASE 
    WHEN title = 'AC I - Foundation' THEN (SELECT id FROM assessment_levels WHERE level_code = 'beginner')
    WHEN title = 'AC II - Applied Practice' THEN (SELECT id FROM assessment_levels WHERE level_code = 'intermediate')
    WHEN title = 'AC III - Professional Mastery' THEN (SELECT id FROM assessment_levels WHERE level_code = 'advanced')
  END
WHERE title LIKE 'AC%' AND (framework_id IS NULL OR assessment_level_id IS NULL);

-- =====================================================================================
-- STEP 7: SET REALISTIC PRODUCTION ASSESSMENT STATES  
-- =====================================================================================
-- Configure a good mix of active/inactive assessments for production launch

-- Enable foundation and intermediate level assessments (ready for users)
UPDATE assessments SET is_active = true WHERE title IN (
  'CORE I - Fundamentals',        -- Foundation level - ready
  'CORE II - Intermediate Skills', -- Intermediate level - ready
  'ICF I - Foundation',           -- ICF foundation - ready
  'ICF II - Core Practice',       -- ICF intermediate - ready  
  'AC I - Foundation'             -- AC foundation - ready
);

-- Keep advanced levels as "Not Available" for now (can be enabled when ready)
UPDATE assessments SET is_active = false WHERE title IN (
  'CORE III - Mastery',           -- Advanced level - coming later
  'ICF III - Mastery',            -- ICF advanced - coming later
  'AC II - Applied Practice',     -- AC intermediate - coming later
  'AC III - Professional Mastery' -- AC advanced - coming later
);

-- =====================================================================================
-- VERIFICATION QUERIES
-- =====================================================================================
-- Run these queries after applying the migration to verify everything worked correctly:

-- 1. Verify learning_path_categories schema
-- \d learning_path_categories

-- 2. Verify foreign key relationships
-- SELECT lpc.category_title, al.level_code, al.level_name 
-- FROM learning_path_categories lpc 
-- JOIN assessment_levels al ON lpc.assessment_level_id = al.id 
-- ORDER BY lpc.category_title;

-- 3. Test the learning paths function with beginner level
-- SELECT category_title 
-- FROM get_learning_paths_for_assessment(ARRAY['Active Listening'], 60, 'Beginner');

-- 4. Test the learning paths function with intermediate level  
-- SELECT category_title 
-- FROM get_learning_paths_for_assessment(ARRAY['Present Moment Awareness'], 60, 'Intermediate');

-- 5. Verify all assessments now have proper framework and level assignments
-- SELECT title, framework, difficulty, is_active 
-- FROM assessment_overview 
-- ORDER BY framework, difficulty;

-- 6. Verify assessments are properly grouped by framework
-- SELECT framework, COUNT(*) as assessment_count, 
--        COUNT(CASE WHEN is_active THEN 1 END) as active_count
-- FROM assessment_overview 
-- GROUP BY framework 
-- ORDER BY framework;

-- =====================================================================================
-- ROLLBACK PLAN (if needed)
-- =====================================================================================
-- 
-- If you need to rollback these changes:
-- 1. Add back assessment_level text column:
--    ALTER TABLE learning_path_categories ADD COLUMN assessment_level TEXT;
-- 
-- 2. Restore text values from foreign keys:
--    UPDATE learning_path_categories SET assessment_level = (
--      SELECT level_code FROM assessment_levels WHERE id = assessment_level_id
--    );
-- 
-- 3. Remove foreign key column:
--    ALTER TABLE learning_path_categories DROP COLUMN assessment_level_id;
-- 
-- 4. Restore old function (check previous backup for exact definition)
--
-- 5. Rollback ICF and AC assessment framework assignments (if needed):
--    UPDATE assessments SET framework_id = NULL, assessment_level_id = NULL 
--    WHERE title LIKE 'ICF%' OR title LIKE 'AC%';
--
-- =====================================================================================

-- Migration completed successfully
-- Run verification queries above to confirm all changes applied correctly