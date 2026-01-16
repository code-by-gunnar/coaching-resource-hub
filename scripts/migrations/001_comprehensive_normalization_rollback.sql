-- =============================================
-- ROLLBACK SCRIPT FOR COMPREHENSIVE NORMALIZATION
-- Use this ONLY if the migration fails or causes critical issues
-- =============================================

-- WARNING: This will restore ALL old text fields but lose normalization benefits
-- Only use if absolutely necessary for emergency rollback!

BEGIN;

-- =============================================
-- STEP 1: RE-ADD ALL TEXT COLUMNS
-- =============================================

-- 1.1 competency_display_names
ALTER TABLE competency_display_names 
  ADD COLUMN IF NOT EXISTS framework TEXT;

-- 1.2 learning_resources  
ALTER TABLE learning_resources
  ADD COLUMN IF NOT EXISTS assessment_level TEXT,
  ADD COLUMN IF NOT EXISTS resource_type TEXT,
  ADD COLUMN IF NOT EXISTS competency_areas TEXT[];

-- 1.3 learning_path_categories
ALTER TABLE learning_path_categories
  ADD COLUMN IF NOT EXISTS assessment_level TEXT,
  ADD COLUMN IF NOT EXISTS competency_areas TEXT[];

-- 1.4 assessments
ALTER TABLE assessments
  ADD COLUMN IF NOT EXISTS framework TEXT,
  ADD COLUMN IF NOT EXISTS difficulty TEXT;

-- 1.5 assessment_questions
ALTER TABLE assessment_questions
  ADD COLUMN IF NOT EXISTS assessment_level TEXT,
  ADD COLUMN IF NOT EXISTS competency_area TEXT;

-- 1.6 skill_tags
ALTER TABLE skill_tags
  ADD COLUMN IF NOT EXISTS framework TEXT,
  ADD COLUMN IF NOT EXISTS assessment_level TEXT,
  ADD COLUMN IF NOT EXISTS competency_area TEXT;

-- 1.7 competency_leverage_strengths
ALTER TABLE competency_leverage_strengths
  ADD COLUMN IF NOT EXISTS framework TEXT,
  ADD COLUMN IF NOT EXISTS competency_area TEXT,
  ADD COLUMN IF NOT EXISTS context_level TEXT;

-- 1.8 competency_performance_analysis
ALTER TABLE competency_performance_analysis
  ADD COLUMN IF NOT EXISTS framework TEXT,
  ADD COLUMN IF NOT EXISTS competency_area TEXT,
  ADD COLUMN IF NOT EXISTS assessment_level TEXT,
  ADD COLUMN IF NOT EXISTS difficulty_level TEXT,
  ADD COLUMN IF NOT EXISTS strength_level TEXT,
  ADD COLUMN IF NOT EXISTS analysis_type TEXT;

-- 1.9 competency_rich_insights
ALTER TABLE competency_rich_insights
  ADD COLUMN IF NOT EXISTS framework TEXT,
  ADD COLUMN IF NOT EXISTS competency_area TEXT,
  ADD COLUMN IF NOT EXISTS difficulty_level TEXT,
  ADD COLUMN IF NOT EXISTS performance_level TEXT;

-- 1.10 competency_strategic_actions
ALTER TABLE competency_strategic_actions
  ADD COLUMN IF NOT EXISTS framework TEXT,
  ADD COLUMN IF NOT EXISTS competency_area TEXT,
  ADD COLUMN IF NOT EXISTS context_level TEXT,
  ADD COLUMN IF NOT EXISTS difficulty_level TEXT;

-- 1.11 tag_insights
ALTER TABLE tag_insights
  ADD COLUMN IF NOT EXISTS context_level TEXT,
  ADD COLUMN IF NOT EXISTS insight_type TEXT;

-- =============================================
-- STEP 2: RESTORE DATA FROM FK RELATIONSHIPS
-- =============================================

-- 2.1 Restore competency_display_names.framework
UPDATE competency_display_names 
SET framework = f.code
FROM frameworks f
WHERE competency_display_names.framework_id = f.id;

-- 2.2 Restore learning_resources
UPDATE learning_resources
SET 
  assessment_level = al.short_code,
  resource_type = rt.code
FROM assessment_levels al, resource_types rt
WHERE learning_resources.assessment_level_id = al.id
  AND learning_resources.resource_type_id = rt.id;

-- Restore competency_areas array
UPDATE learning_resources
SET competency_areas = ARRAY(
  SELECT cd.display_name
  FROM learning_resource_competencies lrc
  JOIN competency_display_names cd ON lrc.competency_id = cd.id
  WHERE lrc.learning_resource_id = learning_resources.id
);

-- 2.3 Restore learning_path_categories
UPDATE learning_path_categories
SET assessment_level = al.short_code
FROM assessment_levels al
WHERE learning_path_categories.assessment_level_id = al.id;

UPDATE learning_path_categories
SET competency_areas = ARRAY(
  SELECT cd.display_name
  FROM learning_path_category_competencies lpcc
  JOIN competency_display_names cd ON lpcc.competency_id = cd.id  
  WHERE lpcc.category_id = learning_path_categories.id
);

-- 2.4 Restore assessments
UPDATE assessments
SET framework = f.code
FROM frameworks f
WHERE assessments.framework_id = f.id;

UPDATE assessments
SET difficulty = CASE 
  WHEN al.level_code = 'beginner' THEN 'Beginner'
  WHEN al.level_code = 'intermediate' THEN 'Intermediate'
  WHEN al.level_code = 'advanced' THEN 'Advanced'
  ELSE 'Beginner'
END
FROM assessment_levels al
WHERE assessments.assessment_level_id = al.id;

-- 2.5 Restore assessment_questions
UPDATE assessment_questions
SET assessment_level = al.short_code
FROM assessment_levels al
WHERE assessment_questions.assessment_level_id = al.id;

UPDATE assessment_questions
SET competency_area = cd.display_name
FROM competency_display_names cd
WHERE assessment_questions.competency_id = cd.id;

-- 2.6 Restore skill_tags
UPDATE skill_tags
SET 
  framework = f.code,
  assessment_level = al.short_code,
  competency_area = cd.display_name
FROM frameworks f, assessment_levels al, competency_display_names cd
WHERE skill_tags.framework_id = f.id
  AND skill_tags.assessment_level_id = al.id
  AND skill_tags.competency_id = cd.id;

-- 2.7 Restore competency_leverage_strengths
UPDATE competency_leverage_strengths
SET 
  framework = f.code,
  competency_area = cd.display_name,
  context_level = al.level_code
FROM frameworks f, competency_display_names cd, assessment_levels al
WHERE competency_leverage_strengths.framework_id = f.id
  AND competency_leverage_strengths.competency_id = cd.id
  AND competency_leverage_strengths.assessment_level_id = al.id;

-- 2.8 Restore competency_performance_analysis
UPDATE competency_performance_analysis
SET 
  framework = f.code,
  competency_area = cd.display_name,
  assessment_level = al.short_code,
  difficulty_level = al.level_code,
  analysis_type = at.code
FROM frameworks f, competency_display_names cd, assessment_levels al, analysis_types at
WHERE competency_performance_analysis.framework_id = f.id
  AND competency_performance_analysis.competency_id = cd.id
  AND competency_performance_analysis.assessment_level_id = al.id
  AND competency_performance_analysis.analysis_type_id = at.id;

-- 2.9 Restore competency_rich_insights
UPDATE competency_rich_insights
SET 
  framework = f.code,
  competency_area = cd.display_name,
  difficulty_level = al.level_code,
  performance_level = CASE 
    WHEN al.level_code = 'beginner' THEN 'foundational'
    WHEN al.level_code = 'intermediate' THEN 'developing'
    WHEN al.level_code = 'advanced' THEN 'advanced'
    ELSE 'foundational'
  END
FROM frameworks f, competency_display_names cd, assessment_levels al
WHERE competency_rich_insights.framework_id = f.id
  AND competency_rich_insights.competency_id = cd.id
  AND competency_rich_insights.assessment_level_id = al.id;

-- 2.10 Restore competency_strategic_actions
UPDATE competency_strategic_actions
SET 
  framework = f.code,
  competency_area = cd.display_name,
  context_level = al.level_code,
  difficulty_level = al.level_code
FROM frameworks f, competency_display_names cd, assessment_levels al
WHERE competency_strategic_actions.framework_id = f.id
  AND competency_strategic_actions.competency_id = cd.id
  AND competency_strategic_actions.assessment_level_id = al.id;

-- 2.11 Restore tag_insights
UPDATE tag_insights
SET 
  context_level = al.level_code,
  insight_type = at.code
FROM assessment_levels al, analysis_types at
WHERE tag_insights.assessment_level_id = al.id
  AND tag_insights.analysis_type_id = at.id;

-- =============================================
-- STEP 3: DROP FK COLUMNS
-- =============================================

-- 3.1 Drop FK columns from competency_display_names
ALTER TABLE competency_display_names 
  DROP COLUMN IF EXISTS framework_id;

-- 3.2 Drop FK columns from learning_resources
ALTER TABLE learning_resources
  DROP COLUMN IF EXISTS framework_id,
  DROP COLUMN IF EXISTS assessment_level_id,
  DROP COLUMN IF EXISTS resource_type_id;

-- 3.3 Drop FK columns from learning_path_categories
ALTER TABLE learning_path_categories
  DROP COLUMN IF EXISTS assessment_level_id;

-- 3.4 Drop FK columns from assessments  
ALTER TABLE assessments
  DROP COLUMN IF EXISTS framework_id,
  DROP COLUMN IF EXISTS assessment_level_id;

-- 3.5 Drop FK columns from assessment_questions
ALTER TABLE assessment_questions
  DROP COLUMN IF EXISTS assessment_level_id,
  DROP COLUMN IF EXISTS competency_id;

-- 3.6 Drop FK columns from skill_tags
ALTER TABLE skill_tags
  DROP COLUMN IF EXISTS framework_id,
  DROP COLUMN IF EXISTS assessment_level_id,
  DROP COLUMN IF EXISTS competency_id;

-- 3.7 Drop FK columns from competency_leverage_strengths
ALTER TABLE competency_leverage_strengths
  DROP COLUMN IF EXISTS framework_id,
  DROP COLUMN IF EXISTS assessment_level_id,
  DROP COLUMN IF EXISTS competency_id;

-- 3.8 Drop FK columns from competency_performance_analysis
ALTER TABLE competency_performance_analysis
  DROP COLUMN IF EXISTS framework_id,
  DROP COLUMN IF EXISTS assessment_level_id,
  DROP COLUMN IF EXISTS competency_id,
  DROP COLUMN IF EXISTS analysis_type_id;

-- 3.9 Drop FK columns from competency_rich_insights
ALTER TABLE competency_rich_insights
  DROP COLUMN IF EXISTS framework_id,
  DROP COLUMN IF EXISTS assessment_level_id,
  DROP COLUMN IF EXISTS competency_id;

-- 3.10 Drop FK columns from competency_strategic_actions
ALTER TABLE competency_strategic_actions
  DROP COLUMN IF EXISTS framework_id,
  DROP COLUMN IF EXISTS assessment_level_id,
  DROP COLUMN IF EXISTS competency_id;

-- 3.11 Drop FK columns from tag_insights
ALTER TABLE tag_insights
  DROP COLUMN IF EXISTS assessment_level_id,
  DROP COLUMN IF EXISTS analysis_type_id;

-- =============================================
-- STEP 4: DROP RELATIONSHIP TABLES
-- =============================================

DROP TABLE IF EXISTS learning_resource_competencies;
DROP TABLE IF EXISTS learning_path_category_competencies;

-- ============================================= 
-- STEP 5: DROP REFERENCE TABLES
-- =============================================

DROP TABLE IF EXISTS analysis_types;
DROP TABLE IF EXISTS assessment_levels;
DROP TABLE IF EXISTS resource_types; 
DROP TABLE IF EXISTS frameworks;

COMMIT;

-- =============================================
-- ROLLBACK COMPLETE
-- =============================================
-- Database is back to original text-based structure
-- All normalization benefits have been lost
-- Frontend queries should work with old text fields again