-- ====================================================================
-- SIMPLE COLUMN FIX - NO COMPLEX LOGIC
-- ====================================================================
-- Purpose: Just add the missing columns the frontend needs
-- ====================================================================

-- Add difficulty_level to competency_strategic_actions
ALTER TABLE competency_strategic_actions 
ADD COLUMN IF NOT EXISTS difficulty_level TEXT DEFAULT 'beginner';

UPDATE competency_strategic_actions SET difficulty_level = 'beginner' WHERE difficulty_level IS NULL;

-- Add difficulty_level to competency_performance_analysis  
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

UPDATE competency_performance_analysis SET difficulty_level = 'beginner' WHERE difficulty_level IS NULL;

-- Add difficulty_level to competency_leverage_strengths if table exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'competency_leverage_strengths') THEN
        -- Add missing columns
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'competency_leverage_strengths' AND column_name = 'difficulty_level') THEN
            ALTER TABLE competency_leverage_strengths ADD COLUMN difficulty_level TEXT DEFAULT 'beginner';
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'competency_leverage_strengths' AND column_name = 'sort_order') THEN
            ALTER TABLE competency_leverage_strengths ADD COLUMN sort_order INTEGER DEFAULT 0;
        END IF;
        
        UPDATE competency_leverage_strengths SET difficulty_level = 'beginner' WHERE difficulty_level IS NULL;
        
        RAISE NOTICE '✅ Updated competency_leverage_strengths table';
    ELSE
        RAISE NOTICE '⚠️ competency_leverage_strengths table does not exist - skipping';
    END IF;
END $$;

-- Add basic sample data for performance analysis if table is empty
INSERT INTO competency_performance_analysis (
    competency_area, framework, difficulty_level, analysis_type, 
    analysis_text, score_range_min, score_range_max, is_active, sort_order
)
SELECT * FROM (VALUES
    ('Active Listening', 'core', 'beginner', 'weakness', 'Multiple gaps in Active Listening indicate this competency needs focused development and practice', 0, 60, true, 1),
    ('Powerful Questions', 'core', 'beginner', 'weakness', 'Multiple gaps in Powerful Questions indicate this competency needs focused development and practice', 0, 60, true, 1),
    ('Present Moment Awareness', 'core', 'beginner', 'weakness', 'Multiple gaps in Present Moment Awareness indicate this competency needs focused development and practice', 0, 60, true, 1)
) AS v(competency_area, framework, difficulty_level, analysis_type, analysis_text, score_range_min, score_range_max, is_active, sort_order)
WHERE NOT EXISTS (SELECT 1 FROM competency_performance_analysis WHERE analysis_text IS NOT NULL LIMIT 1);

-- Success message
DO $$ 
BEGIN 
    RAISE NOTICE '✅ SIMPLE COLUMN FIX COMPLETE!';
    RAISE NOTICE 'Added difficulty_level columns where missing';
    RAISE NOTICE 'Added performance analysis columns and sample data';
END $$;