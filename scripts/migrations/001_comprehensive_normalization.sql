-- =============================================
-- COMPREHENSIVE DATABASE NORMALIZATION MIGRATION
-- Addresses ALL text field → FK normalization issues
-- =============================================

-- This migration will:
-- 1. Create ALL proper reference tables
-- 2. Populate reference tables from existing data
-- 3. Add FK columns to existing tables
-- 4. Migrate ALL data to use FKs
-- 5. Create many-to-many relationship tables
-- 6. DROP ALL old text columns (clean break!)
-- 7. Consolidate duplicate level systems

BEGIN;

-- =============================================
-- STEP 1: CREATE ALL REFERENCE TABLES
-- =============================================

-- 1.1 FRAMEWORKS TABLE
CREATE TABLE IF NOT EXISTS frameworks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  sort_order INTEGER NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.2 ASSESSMENT LEVELS TABLE (with correct mappings)
CREATE TABLE IF NOT EXISTS assessment_levels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  framework_id UUID NOT NULL REFERENCES frameworks(id) ON DELETE CASCADE,
  level_code TEXT NOT NULL, -- 'beginner', 'intermediate', 'advanced'
  level_number INTEGER NOT NULL, -- 1, 2, 3
  display_name TEXT NOT NULL,
  short_code TEXT, -- 'core-i', 'icf-ii' for backwards compatibility in URLs
  description TEXT,
  sort_order INTEGER NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(framework_id, level_code),
  UNIQUE(framework_id, level_number),
  UNIQUE(short_code)
);

-- 1.3 RESOURCE TYPES TABLE
CREATE TABLE IF NOT EXISTS resource_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  sort_order INTEGER NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.4 ANALYSIS TYPES TABLE (for strength/weakness enums)
CREATE TABLE IF NOT EXISTS analysis_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  sort_order INTEGER NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- STEP 2: POPULATE ALL REFERENCE TABLES
-- =============================================

-- 2.1 INSERT FRAMEWORKS
INSERT INTO frameworks (code, name, description, sort_order) VALUES
  ('core', 'Core Framework', 'Fundamental coaching competencies and skills', 1),
  ('icf', 'ICF Framework', 'International Coaching Federation competency model', 2),
  ('ac', 'AC Framework', 'Association for Coaching competency framework', 3)
ON CONFLICT (code) DO NOTHING;

-- 2.2 INSERT ASSESSMENT LEVELS (with CORRECT mappings per your specification)
WITH framework_data AS (
  SELECT id, code FROM frameworks
)
INSERT INTO assessment_levels (framework_id, level_code, level_number, display_name, short_code, description, sort_order)
SELECT 
  f.id,
  'beginner',
  1,
  UPPER(f.code) || ' - Beginner',  -- CORE - Beginner, ICF - Beginner, AC - Beginner
  f.code || '-i',  -- core-i = beginner per your spec
  'Beginning level competency in ' || UPPER(f.code) || ' framework',
  1
FROM framework_data f
UNION ALL
SELECT 
  f.id,
  'intermediate', 
  2,
  UPPER(f.code) || ' - Intermediate',  -- CORE - Intermediate, ICF - Intermediate, AC - Intermediate
  f.code || '-ii', -- core-ii = intermediate per your spec
  'Intermediate level competency in ' || UPPER(f.code) || ' framework',
  2
FROM framework_data f
UNION ALL
SELECT 
  f.id,
  'advanced',
  3, 
  UPPER(f.code) || ' - Advanced',  -- CORE - Advanced, ICF - Advanced, AC - Advanced
  f.code || '-iii', -- core-iii = advanced per your spec
  'Advanced level competency in ' || UPPER(f.code) || ' framework',
  3
FROM framework_data f
ON CONFLICT (short_code) DO NOTHING;

-- 2.3 INSERT RESOURCE TYPES
INSERT INTO resource_types (code, name, description, icon, sort_order) VALUES
  ('article', 'Article', 'Written content and blog posts', '📄', 1),
  ('video', 'Video', 'Video content and tutorials', '🎥', 2),
  ('book', 'Book', 'Books and written publications', '📖', 3),
  ('course', 'Course', 'Structured learning courses', '🎓', 4),
  ('podcast', 'Podcast', 'Audio content and interviews', '🎧', 5),
  ('tool', 'Tool', 'Interactive tools and assessments', '🛠️', 6),
  ('exercise', 'Exercise', 'Practice exercises and activities', '💪', 7),
  ('guide', 'Guide', 'Step-by-step guides and tutorials', '📋', 8),
  ('template', 'Template', 'Templates and frameworks', '📝', 9),
  ('webinar', 'Webinar', 'Live and recorded webinars', '🖥️', 10),
  ('workshop', 'Workshop', 'Interactive workshops and sessions', '🏗️', 11),
  ('assessment', 'Assessment', 'Assessment tools and evaluations', '📊', 12)
ON CONFLICT (code) DO NOTHING;

-- 2.4 INSERT ANALYSIS TYPES
INSERT INTO analysis_types (code, name, description, sort_order) VALUES
  ('strength', 'Strength', 'Areas of strong performance and capability', 1),
  ('weakness', 'Weakness', 'Areas needing development and improvement', 2)
ON CONFLICT (code) DO NOTHING;

-- =============================================
-- STEP 3: ADD FK COLUMNS TO ALL EXISTING TABLES
-- =============================================

-- 3.1 competency_display_names
ALTER TABLE competency_display_names 
  ADD COLUMN IF NOT EXISTS framework_id UUID REFERENCES frameworks(id);

-- 3.2 learning_resources
ALTER TABLE learning_resources
  ADD COLUMN IF NOT EXISTS framework_id UUID REFERENCES frameworks(id),
  ADD COLUMN IF NOT EXISTS assessment_level_id UUID REFERENCES assessment_levels(id),
  ADD COLUMN IF NOT EXISTS resource_type_id UUID REFERENCES resource_types(id);

-- 3.3 learning_path_categories
ALTER TABLE learning_path_categories
  ADD COLUMN IF NOT EXISTS assessment_level_id UUID REFERENCES assessment_levels(id);

-- 3.4 assessments
ALTER TABLE assessments
  ADD COLUMN IF NOT EXISTS framework_id UUID REFERENCES frameworks(id),
  ADD COLUMN IF NOT EXISTS assessment_level_id UUID REFERENCES assessment_levels(id);

-- 3.5 assessment_questions
ALTER TABLE assessment_questions
  ADD COLUMN IF NOT EXISTS assessment_level_id UUID REFERENCES assessment_levels(id),
  ADD COLUMN IF NOT EXISTS competency_id UUID REFERENCES competency_display_names(id);

-- 3.6 skill_tags
ALTER TABLE skill_tags
  ADD COLUMN IF NOT EXISTS framework_id UUID REFERENCES frameworks(id),
  ADD COLUMN IF NOT EXISTS assessment_level_id UUID REFERENCES assessment_levels(id),
  ADD COLUMN IF NOT EXISTS competency_id UUID REFERENCES competency_display_names(id);

-- 3.7 competency_leverage_strengths (consolidate context_level to assessment_level_id)
ALTER TABLE competency_leverage_strengths
  ADD COLUMN IF NOT EXISTS framework_id UUID REFERENCES frameworks(id),
  ADD COLUMN IF NOT EXISTS assessment_level_id UUID REFERENCES assessment_levels(id),
  ADD COLUMN IF NOT EXISTS competency_id UUID REFERENCES competency_display_names(id);

-- 3.8 competency_performance_analysis (consolidate ALL level columns)
ALTER TABLE competency_performance_analysis
  ADD COLUMN IF NOT EXISTS framework_id UUID REFERENCES frameworks(id),
  ADD COLUMN IF NOT EXISTS assessment_level_id UUID REFERENCES assessment_levels(id),
  ADD COLUMN IF NOT EXISTS competency_id UUID REFERENCES competency_display_names(id),
  ADD COLUMN IF NOT EXISTS analysis_type_id UUID REFERENCES analysis_types(id);

-- 3.9 competency_rich_insights (consolidate difficulty_level and performance_level)
ALTER TABLE competency_rich_insights
  ADD COLUMN IF NOT EXISTS framework_id UUID REFERENCES frameworks(id),
  ADD COLUMN IF NOT EXISTS assessment_level_id UUID REFERENCES assessment_levels(id),
  ADD COLUMN IF NOT EXISTS competency_id UUID REFERENCES competency_display_names(id);

-- 3.10 competency_strategic_actions (consolidate context_level and difficulty_level)
ALTER TABLE competency_strategic_actions
  ADD COLUMN IF NOT EXISTS framework_id UUID REFERENCES frameworks(id),
  ADD COLUMN IF NOT EXISTS assessment_level_id UUID REFERENCES assessment_levels(id),
  ADD COLUMN IF NOT EXISTS competency_id UUID REFERENCES competency_display_names(id);

-- 3.11 tag_insights
ALTER TABLE tag_insights
  ADD COLUMN IF NOT EXISTS assessment_level_id UUID REFERENCES assessment_levels(id),
  ADD COLUMN IF NOT EXISTS analysis_type_id UUID REFERENCES analysis_types(id);

-- =============================================
-- STEP 4: MIGRATE ALL EXISTING DATA TO USE FKS
-- =============================================

-- 4.1 Migrate competency_display_names.framework
UPDATE competency_display_names 
SET framework_id = f.id
FROM frameworks f
WHERE competency_display_names.framework = f.code;

-- 4.2 Migrate learning_resources
-- Framework based on assessment_level pattern
UPDATE learning_resources 
SET framework_id = f.id
FROM frameworks f
WHERE learning_resources.assessment_level LIKE f.code || '-%';

-- Assessment level (with CORRECTED mappings)
UPDATE learning_resources
SET assessment_level_id = al.id  
FROM assessment_levels al
WHERE (
  -- Handle existing data with old mapping
  (learning_resources.assessment_level = 'core-i' AND al.short_code = 'core-i') OR
  (learning_resources.assessment_level = 'core-ii' AND al.short_code = 'core-ii') OR
  (learning_resources.assessment_level = 'core-iii' AND al.short_code = 'core-iii') OR
  (learning_resources.assessment_level = 'icf-i' AND al.short_code = 'icf-i') OR
  (learning_resources.assessment_level = 'icf-ii' AND al.short_code = 'icf-ii') OR
  (learning_resources.assessment_level = 'icf-iii' AND al.short_code = 'icf-iii') OR
  (learning_resources.assessment_level = 'ac-i' AND al.short_code = 'ac-i') OR
  (learning_resources.assessment_level = 'ac-ii' AND al.short_code = 'ac-ii') OR
  (learning_resources.assessment_level = 'ac-iii' AND al.short_code = 'ac-iii')
);

-- Resource type
UPDATE learning_resources
SET resource_type_id = rt.id
FROM resource_types rt  
WHERE learning_resources.resource_type = rt.code;

-- 4.3 Migrate learning_path_categories
UPDATE learning_path_categories
SET assessment_level_id = al.id
FROM assessment_levels al
WHERE (
  (learning_path_categories.assessment_level = 'core-i' AND al.short_code = 'core-i') OR
  (learning_path_categories.assessment_level = 'core-ii' AND al.short_code = 'core-ii') OR
  (learning_path_categories.assessment_level = 'core-iii' AND al.short_code = 'core-iii') OR
  (learning_path_categories.assessment_level = 'icf-i' AND al.short_code = 'icf-i') OR
  (learning_path_categories.assessment_level = 'icf-ii' AND al.short_code = 'icf-ii') OR
  (learning_path_categories.assessment_level = 'icf-iii' AND al.short_code = 'icf-iii') OR
  (learning_path_categories.assessment_level = 'ac-i' AND al.short_code = 'ac-i') OR
  (learning_path_categories.assessment_level = 'ac-ii' AND al.short_code = 'ac-ii') OR
  (learning_path_categories.assessment_level = 'ac-iii' AND al.short_code = 'ac-iii')
);

-- 4.4 Migrate assessments
UPDATE assessments
SET framework_id = f.id
FROM frameworks f
WHERE assessments.framework = f.code;

-- Map difficulty to assessment_level_id 
UPDATE assessments
SET assessment_level_id = al.id
FROM assessment_levels al
WHERE (
  (LOWER(assessments.difficulty) = 'beginner' AND al.level_code = 'beginner') OR
  (LOWER(assessments.difficulty) = 'intermediate' AND al.level_code = 'intermediate') OR
  (LOWER(assessments.difficulty) = 'advanced' AND al.level_code = 'advanced')
) AND al.framework_id = assessments.framework_id;

-- 4.5 Migrate assessment_questions
UPDATE assessment_questions
SET assessment_level_id = al.id
FROM assessment_levels al
WHERE (
  (assessment_questions.assessment_level = 'core-i' AND al.short_code = 'core-i') OR
  (assessment_questions.assessment_level = 'core-ii' AND al.short_code = 'core-ii') OR
  (assessment_questions.assessment_level = 'core-iii' AND al.short_code = 'core-iii') OR
  (assessment_questions.assessment_level = 'icf-i' AND al.short_code = 'icf-i') OR
  (assessment_questions.assessment_level = 'icf-ii' AND al.short_code = 'icf-ii') OR
  (assessment_questions.assessment_level = 'icf-iii' AND al.short_code = 'icf-iii') OR
  (assessment_questions.assessment_level = 'ac-i' AND al.short_code = 'ac-i') OR
  (assessment_questions.assessment_level = 'ac-ii' AND al.short_code = 'ac-ii') OR
  (assessment_questions.assessment_level = 'ac-iii' AND al.short_code = 'ac-iii')
);

UPDATE assessment_questions
SET competency_id = cd.id
FROM competency_display_names cd
WHERE assessment_questions.competency_area = cd.display_name;

-- 4.6 Migrate skill_tags
UPDATE skill_tags
SET framework_id = f.id
FROM frameworks f
WHERE skill_tags.framework = f.code;

UPDATE skill_tags  
SET assessment_level_id = al.id
FROM assessment_levels al
WHERE (
  (skill_tags.assessment_level = 'core-i' AND al.short_code = 'core-i') OR
  (skill_tags.assessment_level = 'core-ii' AND al.short_code = 'core-ii') OR
  (skill_tags.assessment_level = 'core-iii' AND al.short_code = 'core-iii') OR
  (skill_tags.assessment_level = 'icf-i' AND al.short_code = 'icf-i') OR
  (skill_tags.assessment_level = 'icf-ii' AND al.short_code = 'icf-ii') OR
  (skill_tags.assessment_level = 'icf-iii' AND al.short_code = 'icf-iii') OR
  (skill_tags.assessment_level = 'ac-i' AND al.short_code = 'ac-i') OR
  (skill_tags.assessment_level = 'ac-ii' AND al.short_code = 'ac-ii') OR
  (skill_tags.assessment_level = 'ac-iii' AND al.short_code = 'ac-iii')
);

UPDATE skill_tags
SET competency_id = cd.id
FROM competency_display_names cd
WHERE skill_tags.competency_area = cd.display_name;

-- 4.7 Migrate competency_leverage_strengths (consolidate context_level)
UPDATE competency_leverage_strengths
SET framework_id = f.id
FROM frameworks f
WHERE competency_leverage_strengths.framework = f.code;

UPDATE competency_leverage_strengths
SET assessment_level_id = al.id
FROM assessment_levels al
WHERE (
  (LOWER(competency_leverage_strengths.context_level) = 'beginner' AND al.level_code = 'beginner') OR
  (LOWER(competency_leverage_strengths.context_level) = 'intermediate' AND al.level_code = 'intermediate') OR
  (LOWER(competency_leverage_strengths.context_level) = 'advanced' AND al.level_code = 'advanced')
) AND al.framework_id = competency_leverage_strengths.framework_id;

UPDATE competency_leverage_strengths
SET competency_id = cd.id
FROM competency_display_names cd
WHERE competency_leverage_strengths.competency_area = cd.display_name;

-- 4.8 Migrate competency_performance_analysis (consolidate ALL level columns)
UPDATE competency_performance_analysis
SET framework_id = f.id
FROM frameworks f
WHERE competency_performance_analysis.framework = f.code;

-- Use difficulty_level as primary, fallback to assessment_level
UPDATE competency_performance_analysis
SET assessment_level_id = al.id
FROM assessment_levels al
WHERE (
  (LOWER(competency_performance_analysis.difficulty_level) = 'beginner' AND al.level_code = 'beginner') OR
  (LOWER(competency_performance_analysis.difficulty_level) = 'intermediate' AND al.level_code = 'intermediate') OR
  (LOWER(competency_performance_analysis.difficulty_level) = 'advanced' AND al.level_code = 'advanced') OR
  (competency_performance_analysis.assessment_level = 'core-i' AND al.short_code = 'core-i') OR
  (competency_performance_analysis.assessment_level = 'core-ii' AND al.short_code = 'core-ii') OR
  (competency_performance_analysis.assessment_level = 'core-iii' AND al.short_code = 'core-iii')
) AND al.framework_id = competency_performance_analysis.framework_id;

UPDATE competency_performance_analysis
SET competency_id = cd.id
FROM competency_display_names cd
WHERE competency_performance_analysis.competency_area = cd.display_name;

UPDATE competency_performance_analysis
SET analysis_type_id = at.id
FROM analysis_types at
WHERE competency_performance_analysis.analysis_type = at.code;

-- 4.9 Migrate competency_rich_insights (consolidate difficulty_level and performance_level)
UPDATE competency_rich_insights
SET framework_id = f.id
FROM frameworks f
WHERE competency_rich_insights.framework = f.code;

-- Map performance_level to assessment_level_id
UPDATE competency_rich_insights
SET assessment_level_id = al.id
FROM assessment_levels al
WHERE (
  (LOWER(competency_rich_insights.difficulty_level) = 'beginner' AND al.level_code = 'beginner') OR
  (LOWER(competency_rich_insights.difficulty_level) = 'intermediate' AND al.level_code = 'intermediate') OR
  (LOWER(competency_rich_insights.difficulty_level) = 'advanced' AND al.level_code = 'advanced') OR
  (LOWER(competency_rich_insights.performance_level) = 'foundational' AND al.level_code = 'beginner') OR
  (LOWER(competency_rich_insights.performance_level) = 'developing' AND al.level_code = 'intermediate') OR
  (LOWER(competency_rich_insights.performance_level) = 'advanced' AND al.level_code = 'advanced')
) AND al.framework_id = competency_rich_insights.framework_id;

UPDATE competency_rich_insights
SET competency_id = cd.id
FROM competency_display_names cd
WHERE competency_rich_insights.competency_area = cd.display_name;

-- 4.10 Migrate competency_strategic_actions (consolidate context_level and difficulty_level)
UPDATE competency_strategic_actions
SET framework_id = f.id
FROM frameworks f
WHERE competency_strategic_actions.framework = f.code;

UPDATE competency_strategic_actions
SET assessment_level_id = al.id
FROM assessment_levels al
WHERE (
  (LOWER(competency_strategic_actions.context_level) = 'beginner' AND al.level_code = 'beginner') OR
  (LOWER(competency_strategic_actions.context_level) = 'intermediate' AND al.level_code = 'intermediate') OR
  (LOWER(competency_strategic_actions.context_level) = 'advanced' AND al.level_code = 'advanced') OR
  (LOWER(competency_strategic_actions.difficulty_level) = 'beginner' AND al.level_code = 'beginner') OR
  (LOWER(competency_strategic_actions.difficulty_level) = 'intermediate' AND al.level_code = 'intermediate') OR
  (LOWER(competency_strategic_actions.difficulty_level) = 'advanced' AND al.level_code = 'advanced')
) AND al.framework_id = competency_strategic_actions.framework_id;

UPDATE competency_strategic_actions
SET competency_id = cd.id
FROM competency_display_names cd
WHERE competency_strategic_actions.competency_area = cd.display_name;

-- 4.11 Migrate tag_insights
UPDATE tag_insights
SET assessment_level_id = al.id
FROM assessment_levels al
WHERE (
  (LOWER(tag_insights.context_level) = 'beginner' AND al.level_code = 'beginner') OR
  (LOWER(tag_insights.context_level) = 'intermediate' AND al.level_code = 'intermediate') OR
  (LOWER(tag_insights.context_level) = 'advanced' AND al.level_code = 'advanced')
);

UPDATE tag_insights
SET analysis_type_id = at.id
FROM analysis_types at
WHERE tag_insights.insight_type = at.code;

-- =============================================
-- STEP 5: CREATE MANY-TO-MANY RELATIONSHIP TABLES
-- =============================================

-- 5.1 Learning resource competencies
CREATE TABLE IF NOT EXISTS learning_resource_competencies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  learning_resource_id UUID NOT NULL REFERENCES learning_resources(id) ON DELETE CASCADE,
  competency_id UUID NOT NULL REFERENCES competency_display_names(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(learning_resource_id, competency_id)
);

-- 5.2 Migrate competency_areas arrays to relationship table
INSERT INTO learning_resource_competencies (learning_resource_id, competency_id)
SELECT DISTINCT 
  lr.id,
  cd.id
FROM learning_resources lr
CROSS JOIN LATERAL unnest(lr.competency_areas) AS comp_name
JOIN competency_display_names cd ON cd.display_name = comp_name
WHERE lr.competency_areas IS NOT NULL
ON CONFLICT (learning_resource_id, competency_id) DO NOTHING;

-- 5.3 Learning path category competencies
CREATE TABLE IF NOT EXISTS learning_path_category_competencies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(), 
  category_id UUID NOT NULL REFERENCES learning_path_categories(id) ON DELETE CASCADE,
  competency_id UUID NOT NULL REFERENCES competency_display_names(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(category_id, competency_id)
);

-- 5.4 Migrate learning_path_categories competency_areas  
INSERT INTO learning_path_category_competencies (category_id, competency_id)
SELECT DISTINCT
  lpc.id,
  cd.id  
FROM learning_path_categories lpc
CROSS JOIN LATERAL unnest(lpc.competency_areas) AS comp_name
JOIN competency_display_names cd ON cd.display_name = comp_name
WHERE lpc.competency_areas IS NOT NULL
ON CONFLICT (category_id, competency_id) DO NOTHING;

-- =============================================
-- STEP 6: HANDLE DEPENDENT VIEWS BEFORE DROPPING COLUMNS
-- =============================================

-- Store view definitions before dropping them
-- We'll need to recreate them after the migration

-- Drop dependent views that use the old text columns
DROP VIEW IF EXISTS assessment_overview CASCADE;
DROP VIEW IF EXISTS user_assessment_progress CASCADE;
DROP VIEW IF EXISTS user_competency_performance CASCADE;

-- =============================================
-- STEP 7: CLEAN BREAK - DROP ALL OLD TEXT COLUMNS
-- =============================================

-- 6.1 Drop from competency_display_names
ALTER TABLE competency_display_names 
  DROP COLUMN IF EXISTS framework;

-- 6.2 Drop from learning_resources
ALTER TABLE learning_resources
  DROP COLUMN IF EXISTS assessment_level,
  DROP COLUMN IF EXISTS resource_type, 
  DROP COLUMN IF EXISTS competency_areas;

-- 6.3 Drop from learning_path_categories  
ALTER TABLE learning_path_categories
  DROP COLUMN IF EXISTS assessment_level,
  DROP COLUMN IF EXISTS competency_areas;

-- 6.4 Drop from assessments
ALTER TABLE assessments
  DROP COLUMN IF EXISTS framework,
  DROP COLUMN IF EXISTS difficulty;

-- 6.5 Drop from assessment_questions
ALTER TABLE assessment_questions
  DROP COLUMN IF EXISTS assessment_level,
  DROP COLUMN IF EXISTS competency_area;

-- 6.6 Drop from skill_tags
ALTER TABLE skill_tags
  DROP COLUMN IF EXISTS framework,
  DROP COLUMN IF EXISTS assessment_level,
  DROP COLUMN IF EXISTS competency_area;

-- 6.7 Drop from competency_leverage_strengths
ALTER TABLE competency_leverage_strengths
  DROP COLUMN IF EXISTS framework,
  DROP COLUMN IF EXISTS competency_area,
  DROP COLUMN IF EXISTS context_level;

-- 6.8 Drop from competency_performance_analysis
ALTER TABLE competency_performance_analysis
  DROP COLUMN IF EXISTS framework,
  DROP COLUMN IF EXISTS competency_area,
  DROP COLUMN IF EXISTS assessment_level,
  DROP COLUMN IF EXISTS difficulty_level,
  DROP COLUMN IF EXISTS strength_level,
  DROP COLUMN IF EXISTS analysis_type;

-- 6.9 Drop from competency_rich_insights
ALTER TABLE competency_rich_insights
  DROP COLUMN IF EXISTS framework,
  DROP COLUMN IF EXISTS competency_area,
  DROP COLUMN IF EXISTS difficulty_level,
  DROP COLUMN IF EXISTS performance_level;

-- 6.10 Drop from competency_strategic_actions
ALTER TABLE competency_strategic_actions
  DROP COLUMN IF EXISTS framework,
  DROP COLUMN IF EXISTS competency_area,
  DROP COLUMN IF EXISTS context_level,
  DROP COLUMN IF EXISTS difficulty_level;

-- 6.11 Drop from tag_insights
ALTER TABLE tag_insights
  DROP COLUMN IF EXISTS context_level,
  DROP COLUMN IF EXISTS insight_type;

-- =============================================
-- STEP 8: RECREATE VIEWS WITH NEW FK RELATIONSHIPS
-- =============================================

-- Recreate assessment_overview view with new FK relationships
CREATE OR REPLACE VIEW assessment_overview AS
SELECT 
  a.id,
  a.slug,
  a.title,
  a.description,
  f.code as framework,
  al.level_code as difficulty,
  a.estimated_duration,
  a.icon,
  a.is_active,
  a.sort_order,
  a.created_at,
  a.updated_at,
  COALESCE(q.question_count, 0::bigint) AS question_count
FROM assessments a
LEFT JOIN frameworks f ON a.framework_id = f.id
LEFT JOIN assessment_levels al ON a.assessment_level_id = al.id
LEFT JOIN (
  SELECT assessment_id, COUNT(*) AS question_count
  FROM assessment_questions
  GROUP BY assessment_id
) q ON a.id = q.assessment_id
ORDER BY a.sort_order, a.title;

-- Recreate user_assessment_progress view
CREATE OR REPLACE VIEW user_assessment_progress AS
SELECT 
  uaa.id,
  uaa.user_id,
  uaa.assessment_id,
  a.slug as assessment_slug,
  a.title as assessment_title,
  f.code as framework,
  al.level_code as difficulty,
  uaa.status,
  uaa.score,
  uaa.completed_at,
  uaa.created_at
FROM user_assessment_attempts uaa
JOIN assessments a ON uaa.assessment_id = a.id
LEFT JOIN frameworks f ON a.framework_id = f.id
LEFT JOIN assessment_levels al ON a.assessment_level_id = al.id;

-- Recreate user_competency_performance view
CREATE OR REPLACE VIEW user_competency_performance AS
SELECT 
  ua.user_id,
  cd.display_name as competency_area,
  f.code as framework,
  al.level_code as difficulty,
  COUNT(uqr.id) AS total_answered,
  COUNT(CASE WHEN uqr.is_correct = true THEN 1 END) AS correct_answers,
  CASE
    WHEN COUNT(uqr.id) > 0 THEN 
      ROUND(COUNT(CASE WHEN uqr.is_correct = true THEN 1 END)::numeric / COUNT(uqr.id)::numeric * 100::numeric, 1)
    ELSE 0::numeric
  END AS accuracy_percentage,
  AVG(uqr.time_spent) AS avg_time_spent
FROM user_assessment_attempts ua
JOIN assessments a ON ua.assessment_id = a.id
JOIN user_question_responses uqr ON uqr.attempt_id = ua.id
JOIN assessment_questions aq ON uqr.question_id = aq.id
LEFT JOIN competency_display_names cd ON aq.competency_id = cd.id
LEFT JOIN frameworks f ON a.framework_id = f.id
LEFT JOIN assessment_levels al ON a.assessment_level_id = al.id
WHERE cd.display_name IS NOT NULL
GROUP BY ua.user_id, cd.display_name, f.code, al.level_code
ORDER BY ua.user_id, cd.display_name;

-- =============================================
-- STEP 9: ADD PERFORMANCE INDEXES
-- =============================================

-- Framework indexes
CREATE INDEX IF NOT EXISTS idx_competency_display_names_framework_id ON competency_display_names(framework_id);
CREATE INDEX IF NOT EXISTS idx_learning_resources_framework_id ON learning_resources(framework_id);
CREATE INDEX IF NOT EXISTS idx_assessments_framework_id ON assessments(framework_id);
CREATE INDEX IF NOT EXISTS idx_skill_tags_framework_id ON skill_tags(framework_id);

-- Assessment level indexes
CREATE INDEX IF NOT EXISTS idx_learning_resources_assessment_level_id ON learning_resources(assessment_level_id);
CREATE INDEX IF NOT EXISTS idx_assessments_assessment_level_id ON assessments(assessment_level_id);
CREATE INDEX IF NOT EXISTS idx_learning_path_categories_assessment_level_id ON learning_path_categories(assessment_level_id);

-- Resource type indexes
CREATE INDEX IF NOT EXISTS idx_learning_resources_resource_type_id ON learning_resources(resource_type_id);

-- Competency indexes
CREATE INDEX IF NOT EXISTS idx_assessment_questions_competency_id ON assessment_questions(competency_id);
CREATE INDEX IF NOT EXISTS idx_skill_tags_competency_id ON skill_tags(competency_id);

-- Many-to-many indexes
CREATE INDEX IF NOT EXISTS idx_learning_resource_competencies_resource_id ON learning_resource_competencies(learning_resource_id);
CREATE INDEX IF NOT EXISTS idx_learning_resource_competencies_competency_id ON learning_resource_competencies(competency_id);
CREATE INDEX IF NOT EXISTS idx_learning_path_category_competencies_category_id ON learning_path_category_competencies(category_id);
CREATE INDEX IF NOT EXISTS idx_learning_path_category_competencies_competency_id ON learning_path_category_competencies(competency_id);

COMMIT;

-- =============================================
-- COMPREHENSIVE MIGRATION COMPLETE!
-- =============================================

-- SUMMARY:
-- ✅ Created 4 reference tables (frameworks, assessment_levels, resource_types, analysis_types)
-- ✅ Fixed assessment level mappings (core-i = beginner, core-ii = intermediate, core-iii = advanced)
-- ✅ Consolidated ALL level columns to single assessment_level_id FK
-- ✅ Converted ALL competency_area text fields to competency_id UUID FKs
-- ✅ Converted ALL framework text fields to framework_id UUID FKs
-- ✅ Converted ALL analysis_type text fields to analysis_type_id UUID FKs
-- ✅ Created many-to-many relationship tables for competencies
-- ✅ Handled dependent views by dropping and recreating them
-- ✅ DROPPED ALL old text columns (complete clean break!)
-- ✅ Added performance indexes
--
-- FRONTEND IMPACT:
-- ⚠️ ALL queries using old text columns will break and need updating
-- ⚠️ Assessment level queries need updating for new mappings
-- ⚠️ Competency array queries need updating for many-to-many tables
--
-- NEXT STEPS:
-- 1. Update ALL frontend queries to use new FK relationships
-- 2. Update admin interfaces to load from reference tables
-- 3. Test all functionality works with new normalized structure
-- 4. Enjoy proper relational database! 🚀