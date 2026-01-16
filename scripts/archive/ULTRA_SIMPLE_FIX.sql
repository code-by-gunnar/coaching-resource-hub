-- ====================================================================
-- ULTRA SIMPLE FIX - JUST ADD COLUMNS
-- ====================================================================
-- Purpose: Only add missing columns, no data insertion
-- ====================================================================

-- Add difficulty_level to competency_strategic_actions
ALTER TABLE competency_strategic_actions 
ADD COLUMN IF NOT EXISTS difficulty_level TEXT DEFAULT 'beginner';

UPDATE competency_strategic_actions 
SET difficulty_level = 'beginner' 
WHERE difficulty_level IS NULL;

-- Add missing columns to competency_performance_analysis
ALTER TABLE competency_performance_analysis
ADD COLUMN IF NOT EXISTS difficulty_level TEXT DEFAULT 'beginner';

ALTER TABLE competency_performance_analysis
ADD COLUMN IF NOT EXISTS analysis_text TEXT;

ALTER TABLE competency_performance_analysis
ADD COLUMN IF NOT EXISTS analysis_type TEXT;

ALTER TABLE competency_performance_analysis
ADD COLUMN IF NOT EXISTS score_range_min INTEGER DEFAULT 0;

ALTER TABLE competency_performance_analysis
ADD COLUMN IF NOT EXISTS score_range_max INTEGER DEFAULT 100;

ALTER TABLE competency_performance_analysis
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

ALTER TABLE competency_performance_analysis
ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;

UPDATE competency_performance_analysis 
SET difficulty_level = 'beginner', is_active = true 
WHERE difficulty_level IS NULL;

-- Make user_id nullable since we don't have user-specific data
ALTER TABLE competency_performance_analysis 
ALTER COLUMN user_id DROP NOT NULL;

-- Success message
DO $$ 
BEGIN 
    RAISE NOTICE '✅ ULTRA SIMPLE FIX COMPLETE!';
    RAISE NOTICE 'Added all required columns for frontend queries';
    RAISE NOTICE 'Made user_id nullable to avoid constraint issues';
END $$;