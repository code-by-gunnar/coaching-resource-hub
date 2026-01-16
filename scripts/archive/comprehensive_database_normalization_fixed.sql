-- ====================================================================
-- COMPREHENSIVE DATABASE NORMALIZATION - STANDALONE SCRIPT (FIXED)
-- ====================================================================
-- PURPOSE: Transform text-based relationships to normalized FK relationships
-- FIXES: "Unknown" errors, duplicate columns, missing FK relationships
-- ====================================================================

-- Set timeouts for long-running operations
SET statement_timeout = '30min';
SET lock_timeout = '10min';

-- ====================================================================
-- STEP 1: CREATE REFERENCE TABLES
-- ====================================================================

-- Create frameworks table
CREATE TABLE IF NOT EXISTS frameworks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    priority_order INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create analysis_types table
CREATE TABLE IF NOT EXISTS analysis_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create assessment_levels table
CREATE TABLE IF NOT EXISTS assessment_levels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    framework_id UUID REFERENCES frameworks(id) NOT NULL,
    level_code TEXT NOT NULL,
    level_name TEXT NOT NULL,
    level_number INTEGER NOT NULL,
    short_code TEXT UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(framework_id, level_code),
    UNIQUE(framework_id, level_number)
);

-- Create resource_types table
CREATE TABLE IF NOT EXISTS resource_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create junction table for learning resources
CREATE TABLE IF NOT EXISTS learning_resource_competencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    learning_resource_id UUID REFERENCES learning_resources(id) ON DELETE CASCADE,
    competency_id UUID REFERENCES competency_display_names(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(learning_resource_id, competency_id)
);

-- ====================================================================
-- STEP 2: POPULATE REFERENCE TABLES FROM EXISTING DATA
-- ====================================================================

-- Populate frameworks from existing data
INSERT INTO frameworks (code, name, description, priority_order)
SELECT 'core', 'Core Coaching Fundamentals', 'Essential coaching competencies for all practitioners', 1
WHERE NOT EXISTS (SELECT 1 FROM frameworks WHERE code = 'core');

INSERT INTO frameworks (code, name, description, priority_order)
SELECT 'icf', 'ICF Core Competencies', 'International Coaching Federation competency framework', 2
WHERE NOT EXISTS (SELECT 1 FROM frameworks WHERE code = 'icf');

INSERT INTO frameworks (code, name, description, priority_order)
SELECT 'ac', 'Association for Coaching', 'AC competency framework for professional coaching', 3
WHERE NOT EXISTS (SELECT 1 FROM frameworks WHERE code = 'ac');

-- Populate analysis_types (only strength/weakness)
INSERT INTO analysis_types (code, name, description)
SELECT 'strength', 'Strength Analysis', 'Analysis of areas of competency strength'
WHERE NOT EXISTS (SELECT 1 FROM analysis_types WHERE code = 'strength');

INSERT INTO analysis_types (code, name, description)
SELECT 'weakness', 'Weakness Analysis', 'Analysis of areas requiring development focus'
WHERE NOT EXISTS (SELECT 1 FROM analysis_types WHERE code = 'weakness');

-- Populate assessment_levels with correct format
INSERT INTO assessment_levels (framework_id, level_code, level_name, level_number, short_code, description)
SELECT 
    f.id,
    'beginner',
    'CORE - Beginner',
    1,
    'core_beginner',
    'Foundation level coaching competencies for early practitioners'
FROM frameworks f
WHERE f.code = 'core'
AND NOT EXISTS (SELECT 1 FROM assessment_levels WHERE framework_id = f.id AND level_code = 'beginner');

INSERT INTO assessment_levels (framework_id, level_code, level_name, level_number, short_code, description)
SELECT 
    f.id,
    'intermediate',
    'CORE - Intermediate',
    2,
    'core_intermediate',
    'Developing coaching competencies for growing practitioners'
FROM frameworks f
WHERE f.code = 'core'
AND NOT EXISTS (SELECT 1 FROM assessment_levels WHERE framework_id = f.id AND level_code = 'intermediate');

INSERT INTO assessment_levels (framework_id, level_code, level_name, level_number, short_code, description)
SELECT 
    f.id,
    'advanced',
    'CORE - Advanced',
    3,
    'core_advanced',
    'Mastery level coaching competencies for experienced practitioners'
FROM frameworks f
WHERE f.code = 'core'
AND NOT EXISTS (SELECT 1 FROM assessment_levels WHERE framework_id = f.id AND level_code = 'advanced');

-- Populate resource_types from existing data
INSERT INTO resource_types (code, name, description)
SELECT DISTINCT 
    resource_type,
    CASE 
        WHEN resource_type = 'book' THEN 'Books'
        WHEN resource_type = 'video' THEN 'Videos'
        WHEN resource_type = 'course' THEN 'Courses'
        WHEN resource_type = 'article' THEN 'Articles'
        WHEN resource_type = 'tool' THEN 'Tools'
        WHEN resource_type = 'exercise' THEN 'Exercises'
        ELSE INITCAP(resource_type) || 's'
    END,
    CASE 
        WHEN resource_type = 'book' THEN 'Educational books and publications'
        WHEN resource_type = 'video' THEN 'Video content and tutorials'
        WHEN resource_type = 'course' THEN 'Structured learning courses'
        WHEN resource_type = 'article' THEN 'Articles and written content'
        WHEN resource_type = 'tool' THEN 'Practical coaching tools'
        WHEN resource_type = 'exercise' THEN 'Practical exercises and activities'
        ELSE 'Resource type: ' || resource_type
    END
FROM learning_resources 
WHERE resource_type IS NOT NULL
ON CONFLICT (code) DO NOTHING;

-- ====================================================================
-- STEP 3: ADD FK COLUMNS TO EXISTING TABLES
-- ====================================================================

-- Add FK columns to competency_display_names
ALTER TABLE competency_display_names 
ADD COLUMN IF NOT EXISTS framework_id UUID REFERENCES frameworks(id);

-- Add FK columns to competency_performance_analysis
ALTER TABLE competency_performance_analysis
ADD COLUMN IF NOT EXISTS framework_id UUID REFERENCES frameworks(id),
ADD COLUMN IF NOT EXISTS assessment_level_id UUID REFERENCES assessment_levels(id),
ADD COLUMN IF NOT EXISTS competency_id UUID REFERENCES competency_display_names(id),
ADD COLUMN IF NOT EXISTS analysis_type_id UUID REFERENCES analysis_types(id);

-- Add FK columns to skill_tags
ALTER TABLE skill_tags
ADD COLUMN IF NOT EXISTS framework_id UUID REFERENCES frameworks(id),
ADD COLUMN IF NOT EXISTS assessment_level_id UUID REFERENCES assessment_levels(id),
ADD COLUMN IF NOT EXISTS competency_id UUID REFERENCES competency_display_names(id);

-- Add FK columns to learning_resources
ALTER TABLE learning_resources
ADD COLUMN IF NOT EXISTS framework_id UUID REFERENCES frameworks(id),
ADD COLUMN IF NOT EXISTS assessment_level_id UUID REFERENCES assessment_levels(id),
ADD COLUMN IF NOT EXISTS resource_type_id UUID REFERENCES resource_types(id);

-- Add FK columns to assessment_questions (CRITICAL for fixing "Unknown" error)
ALTER TABLE assessment_questions
ADD COLUMN IF NOT EXISTS competency_id UUID REFERENCES competency_display_names(id),
ADD COLUMN IF NOT EXISTS assessment_level_id UUID REFERENCES assessment_levels(id);

-- Add FK columns to other tables
ALTER TABLE competency_strategic_actions
ADD COLUMN IF NOT EXISTS framework_id UUID REFERENCES frameworks(id),
ADD COLUMN IF NOT EXISTS assessment_level_id UUID REFERENCES assessment_levels(id),
ADD COLUMN IF NOT EXISTS competency_id UUID REFERENCES competency_display_names(id);

ALTER TABLE competency_leverage_strengths
ADD COLUMN IF NOT EXISTS framework_id UUID REFERENCES frameworks(id),
ADD COLUMN IF NOT EXISTS assessment_level_id UUID REFERENCES assessment_levels(id),
ADD COLUMN IF NOT EXISTS competency_id UUID REFERENCES competency_display_names(id);

ALTER TABLE competency_rich_insights
ADD COLUMN IF NOT EXISTS framework_id UUID REFERENCES frameworks(id),
ADD COLUMN IF NOT EXISTS assessment_level_id UUID REFERENCES assessment_levels(id),
ADD COLUMN IF NOT EXISTS competency_id UUID REFERENCES competency_display_names(id);

ALTER TABLE assessments
ADD COLUMN IF NOT EXISTS framework_id UUID REFERENCES frameworks(id),
ADD COLUMN IF NOT EXISTS assessment_level_id UUID REFERENCES assessment_levels(id);

-- ====================================================================
-- STEP 4: POPULATE FK RELATIONSHIPS FROM TEXT COLUMNS
-- ====================================================================

-- Populate competency_display_names.framework_id
UPDATE competency_display_names 
SET framework_id = f.id 
FROM frameworks f 
WHERE competency_display_names.framework_id IS NULL 
AND f.code = COALESCE(competency_display_names.framework, 'core');

-- CRITICAL: Fix assessment_questions FK relationships (fixes "Unknown" error)
UPDATE assessment_questions
SET 
    competency_id = cd.id,
    assessment_level_id = al.id
FROM competency_display_names cd, frameworks f, assessment_levels al
WHERE assessment_questions.competency_id IS NULL
AND cd.display_name = assessment_questions.competency_area
AND cd.framework_id = f.id
AND f.code = 'core'
AND al.framework_id = f.id
AND al.level_code = CASE
    WHEN assessment_questions.assessment_level LIKE '%-i' OR assessment_questions.assessment_level LIKE '%-I' THEN 'beginner'
    WHEN assessment_questions.assessment_level LIKE '%-ii' OR assessment_questions.assessment_level LIKE '%-II' THEN 'intermediate'
    WHEN assessment_questions.assessment_level LIKE '%-iii' OR assessment_questions.assessment_level LIKE '%-III' THEN 'advanced'
    ELSE 'beginner'
END;

-- Populate competency_performance_analysis FK relationships
UPDATE competency_performance_analysis
SET 
    framework_id = f.id,
    assessment_level_id = al.id,
    competency_id = cd.id,
    analysis_type_id = at.id
FROM frameworks f, assessment_levels al, competency_display_names cd, analysis_types at
WHERE competency_performance_analysis.framework_id IS NULL
AND f.code = COALESCE(competency_performance_analysis.framework, 'core')
AND al.framework_id = f.id
AND al.level_code = CASE 
    WHEN LOWER(competency_performance_analysis.difficulty_level) = 'intermediate' THEN 'intermediate'
    WHEN LOWER(competency_performance_analysis.difficulty_level) = 'advanced' THEN 'advanced'
    ELSE 'beginner'
END
AND cd.framework_id = f.id  
AND cd.display_name = competency_performance_analysis.competency_area
AND at.code = competency_performance_analysis.analysis_type;

-- Populate skill_tags FK relationships
UPDATE skill_tags
SET 
    framework_id = f.id,
    assessment_level_id = al.id,
    competency_id = cd.id
FROM frameworks f, assessment_levels al, competency_display_names cd
WHERE skill_tags.framework_id IS NULL
AND f.code = COALESCE(skill_tags.framework, 'core')
AND al.framework_id = f.id
AND al.level_code = CASE 
    WHEN skill_tags.assessment_level LIKE '%-i' THEN 'intermediate'
    WHEN skill_tags.assessment_level LIKE '%-a' THEN 'advanced'
    ELSE 'beginner'
END
AND cd.framework_id = f.id  
AND cd.display_name = skill_tags.competency_area;

-- Populate learning_resources FK relationships
UPDATE learning_resources
SET 
    framework_id = f.id,
    assessment_level_id = al.id,
    resource_type_id = rt.id
FROM frameworks f, assessment_levels al, resource_types rt
WHERE learning_resources.framework_id IS NULL
AND f.code = 'core'
AND al.framework_id = f.id
AND al.level_code = CASE 
    WHEN learning_resources.assessment_level LIKE '%-i' THEN 'intermediate'
    WHEN learning_resources.assessment_level LIKE '%-a' THEN 'advanced'
    ELSE 'beginner'
END
AND rt.code = learning_resources.resource_type;

-- Populate assessments FK relationships
UPDATE assessments
SET 
    framework_id = f.id,
    assessment_level_id = al.id
FROM frameworks f, assessment_levels al
WHERE assessments.framework_id IS NULL
AND f.code = COALESCE(assessments.framework, 'core')
AND al.framework_id = f.id
AND al.level_code = COALESCE(LOWER(assessments.difficulty), 'beginner');

-- ====================================================================
-- STEP 5: TRANSFORM TEXT ARRAYS TO JUNCTION TABLES
-- ====================================================================

-- Transform learning_resources.competency_areas to junction table
INSERT INTO learning_resource_competencies (learning_resource_id, competency_id)
SELECT 
    lr.id as learning_resource_id,
    cd.id as competency_id
FROM learning_resources lr,
     LATERAL unnest(lr.competency_areas) AS area_name,
     competency_display_names cd
WHERE cd.display_name = area_name
AND lr.competency_areas IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM learning_resource_competencies lrc 
    WHERE lrc.learning_resource_id = lr.id AND lrc.competency_id = cd.id
);

-- ====================================================================
-- STEP 6: CLEANUP AND VALIDATION
-- ====================================================================

-- Remove invalid analysis types (only strength/weakness should remain)
DELETE FROM analysis_types 
WHERE code NOT IN ('strength', 'weakness');

-- Create essential indexes for performance
CREATE INDEX IF NOT EXISTS idx_competency_display_names_framework_id ON competency_display_names(framework_id);
CREATE INDEX IF NOT EXISTS idx_assessment_questions_competency_id ON assessment_questions(competency_id);
CREATE INDEX IF NOT EXISTS idx_assessment_questions_assessment_level_id ON assessment_questions(assessment_level_id);
CREATE INDEX IF NOT EXISTS idx_competency_performance_analysis_competency_id ON competency_performance_analysis(competency_id);
CREATE INDEX IF NOT EXISTS idx_skill_tags_competency_id ON skill_tags(competency_id);
CREATE INDEX IF NOT EXISTS idx_learning_resource_competencies_resource_id ON learning_resource_competencies(learning_resource_id);
CREATE INDEX IF NOT EXISTS idx_learning_resource_competencies_competency_id ON learning_resource_competencies(competency_id);

-- Enable RLS on reference tables
ALTER TABLE frameworks ENABLE ROW LEVEL SECURITY;
ALTER TABLE analysis_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessment_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE resource_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_resource_competencies ENABLE ROW LEVEL SECURITY;

-- Create public read policies
CREATE POLICY IF NOT EXISTS frameworks_public_read ON frameworks
    FOR SELECT USING (is_active = true);

CREATE POLICY IF NOT EXISTS analysis_types_public_read ON analysis_types
    FOR SELECT USING (is_active = true);

CREATE POLICY IF NOT EXISTS assessment_levels_public_read ON assessment_levels
    FOR SELECT USING (is_active = true);

CREATE POLICY IF NOT EXISTS resource_types_public_read ON resource_types
    FOR SELECT USING (is_active = true);

CREATE POLICY IF NOT EXISTS learning_resource_competencies_public_read ON learning_resource_competencies
    FOR SELECT USING (true);

-- Final validation
DO $$
DECLARE
    orphaned_questions INTEGER;
    orphaned_analysis INTEGER;
    orphaned_tags INTEGER;
BEGIN
    -- Check for orphaned records that couldn't be migrated
    SELECT COUNT(*) INTO orphaned_questions
    FROM assessment_questions
    WHERE competency_id IS NULL OR assessment_level_id IS NULL;
    
    SELECT COUNT(*) INTO orphaned_analysis
    FROM competency_performance_analysis
    WHERE framework_id IS NULL OR competency_id IS NULL OR analysis_type_id IS NULL;
    
    SELECT COUNT(*) INTO orphaned_tags
    FROM skill_tags
    WHERE framework_id IS NULL OR competency_id IS NULL;
    
    RAISE NOTICE '====================================';
    RAISE NOTICE 'DATABASE NORMALIZATION COMPLETE!';
    RAISE NOTICE '====================================';
    RAISE NOTICE 'Orphaned assessment_questions: %', orphaned_questions;
    RAISE NOTICE 'Orphaned performance_analysis: %', orphaned_analysis;
    RAISE NOTICE 'Orphaned skill_tags: %', orphaned_tags;
    
    IF orphaned_questions = 0 AND orphaned_analysis = 0 AND orphaned_tags = 0 THEN
        RAISE NOTICE 'SUCCESS: All FK relationships populated correctly!';
        RAISE NOTICE 'Frontend "Unknown" errors should now be fixed';
    ELSE
        RAISE WARNING 'Some records could not be migrated - check data integrity';
    END IF;
END $$;