-- ====================================================================
-- FIX DATABASE COLUMN MISMATCHES - TARGETED FIX
-- ====================================================================
-- Purpose: Fix specific column name mismatches between frontend expectations and database
-- Frontend expects: difficulty_level, analysis_text, analysis_type
-- Database has: context_level, analysis_data, no analysis_type
-- ====================================================================

-- ====================================================================
-- FIX 1: competency_strategic_actions table
-- ====================================================================

-- Add difficulty_level column (frontend expects this, not context_level)
ALTER TABLE competency_strategic_actions 
ADD COLUMN IF NOT EXISTS difficulty_level TEXT DEFAULT 'beginner';

-- Populate difficulty_level from context_level if it exists
UPDATE competency_strategic_actions 
SET difficulty_level = context_level 
WHERE difficulty_level IS NULL AND context_level IS NOT NULL;

-- Add sort_order column if missing (frontend orders by this)
ALTER TABLE competency_strategic_actions 
ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;

-- ====================================================================
-- FIX 2: competency_performance_analysis table  
-- ====================================================================

-- Add difficulty_level column (frontend expects this, not assessment_level)
ALTER TABLE competency_performance_analysis
ADD COLUMN IF NOT EXISTS difficulty_level TEXT DEFAULT 'beginner';

-- Populate difficulty_level from assessment_level if it exists
UPDATE competency_performance_analysis 
SET difficulty_level = assessment_level 
WHERE difficulty_level IS NULL AND assessment_level IS NOT NULL;

-- Add analysis_text column (frontend expects this, not analysis_data JSONB)
ALTER TABLE competency_performance_analysis
ADD COLUMN IF NOT EXISTS analysis_text TEXT;

-- Add analysis_type column (frontend filters by 'strength' vs 'weakness')  
ALTER TABLE competency_performance_analysis
ADD COLUMN IF NOT EXISTS analysis_type TEXT;

-- Add missing columns frontend expects
ALTER TABLE competency_performance_analysis
ADD COLUMN IF NOT EXISTS score_range_min INTEGER DEFAULT 0;

ALTER TABLE competency_performance_analysis
ADD COLUMN IF NOT EXISTS score_range_max INTEGER DEFAULT 100;

ALTER TABLE competency_performance_analysis
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

ALTER TABLE competency_performance_analysis
ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;

-- ====================================================================
-- FIX 3: competency_leverage_strengths table (referenced by frontend)
-- ====================================================================

-- Check if this table exists, if not create it with correct schema
CREATE TABLE IF NOT EXISTS competency_leverage_strengths (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    competency_area TEXT NOT NULL,
    leverage_text TEXT NOT NULL,
    score_range_min INTEGER DEFAULT 0,
    score_range_max INTEGER DEFAULT 100,
    framework TEXT NOT NULL CHECK (framework IN ('core', 'icf', 'ac')),
    difficulty_level TEXT DEFAULT 'beginner',  -- Frontend expects this name
    context_level TEXT DEFAULT 'beginner',     -- Keep both for compatibility  
    priority_order INTEGER DEFAULT 0,
    sort_order INTEGER DEFAULT 0,              -- Frontend orders by this
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS if not already enabled
ALTER TABLE competency_leverage_strengths ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS competency_leverage_strengths_public_read ON competency_leverage_strengths;
CREATE POLICY competency_leverage_strengths_public_read ON competency_leverage_strengths
    FOR SELECT USING (true);

-- ====================================================================
-- ADD SAMPLE DATA WITH CORRECT SCHEMA
-- ====================================================================

-- Add sample performance analysis data
INSERT INTO competency_performance_analysis (
    user_id, competency_area, framework, difficulty_level, analysis_type, 
    analysis_text, score_range_min, score_range_max, is_active, sort_order
) VALUES
    ('00000000-0000-0000-0000-000000000000', 'Active Listening', 'core', 'beginner', 'weakness', 'Multiple gaps in Active Listening indicate this competency needs focused development and practice', 0, 60, true, 1),
    ('00000000-0000-0000-0000-000000000000', 'Powerful Questions', 'core', 'beginner', 'weakness', 'Multiple gaps in Powerful Questions indicate this competency needs focused development and practice', 0, 60, true, 1),
    ('00000000-0000-0000-0000-000000000000', 'Present Moment Awareness', 'core', 'beginner', 'weakness', 'Multiple gaps in Present Moment Awareness indicate this competency needs focused development and practice', 0, 60, true, 1),
    ('00000000-0000-0000-0000-000000000000', 'Active Listening', 'core', 'beginner', 'strength', 'Strong performance in Active Listening shows natural coaching ability and client connection skills', 70, 100, true, 1),
    ('00000000-0000-0000-0000-000000000000', 'Powerful Questions', 'core', 'beginner', 'strength', 'Excellent questioning skills demonstrate your ability to create awareness and insight for clients', 70, 100, true, 1),
    ('00000000-0000-0000-0000-000000000000', 'Present Moment Awareness', 'core', 'beginner', 'strength', 'Strong present moment awareness enables you to notice what others miss and create breakthrough moments', 70, 100, true, 1)
ON CONFLICT DO NOTHING;

-- Add sample leverage strengths data  
INSERT INTO competency_leverage_strengths (
    competency_area, leverage_text, score_range_min, score_range_max, 
    framework, difficulty_level, sort_order, is_active
) VALUES
    ('Active Listening', 'Use your strong listening skills to help clients feel deeply heard and understood. Your ability to reflect back what clients share creates safety for them to explore deeper truths about their situation.', 70, 100, 'core', 'beginner', 1, true),
    ('Powerful Questions', 'Leverage your questioning skills to help clients discover insights they already possess. Your questions create space for clients to connect with their own wisdom rather than seeking answers from others.', 70, 100, 'core', 'beginner', 1, true),
    ('Present Moment Awareness', 'Use your awareness of present-moment dynamics to help clients notice what they might be missing about their situation. Your observations can illuminate blind spots and create breakthrough moments.', 70, 100, 'core', 'beginner', 1, true)
ON CONFLICT DO NOTHING;

-- Update existing strategic actions to have correct difficulty_level
UPDATE competency_strategic_actions 
SET difficulty_level = 'beginner', sort_order = priority_order
WHERE difficulty_level IS NULL;

-- ====================================================================
-- VERIFICATION
-- ====================================================================

-- Check that all expected columns exist
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name IN ('competency_strategic_actions', 'competency_performance_analysis', 'competency_leverage_strengths')
AND column_name IN ('difficulty_level', 'analysis_text', 'analysis_type', 'sort_order', 'is_active')
ORDER BY table_name, column_name;

-- Check data exists
SELECT 'competency_strategic_actions' as table_name, count(*) as row_count FROM competency_strategic_actions
UNION ALL
SELECT 'competency_performance_analysis', count(*) FROM competency_performance_analysis  
UNION ALL
SELECT 'competency_leverage_strengths', count(*) FROM competency_leverage_strengths;

-- Success message
DO $$ 
BEGIN 
    RAISE NOTICE '✅ DATABASE COLUMN MISMATCHES FIXED!';
    RAISE NOTICE '';
    RAISE NOTICE '🔧 COLUMNS ADDED:';
    RAISE NOTICE '   ✓ difficulty_level (frontend expects this)';
    RAISE NOTICE '   ✓ analysis_text, analysis_type (for performance insights)'; 
    RAISE NOTICE '   ✓ sort_order, is_active (for filtering/ordering)';
    RAISE NOTICE '';
    RAISE NOTICE '📊 TABLES COMPLETED:';
    RAISE NOTICE '   ✓ competency_strategic_actions';
    RAISE NOTICE '   ✓ competency_performance_analysis';
    RAISE NOTICE '   ✓ competency_leverage_strengths';
    RAISE NOTICE '';
    RAISE NOTICE '🎯 STATUS: Database now matches frontend expectations!';
    RAISE NOTICE 'Strategic Actions and Performance Analysis should now work!';
END $$;