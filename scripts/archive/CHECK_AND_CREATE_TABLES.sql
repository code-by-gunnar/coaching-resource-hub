-- ====================================================================
-- CHECK AND CREATE MISSING TABLES - SAFE VERSION
-- ====================================================================

-- Only create tables if they don't exist, skip RLS setup if already exists
DO $$
BEGIN
    -- Check if competency_strategic_actions exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'competency_strategic_actions') THEN
        RAISE NOTICE 'Creating competency_strategic_actions table...';
        
        CREATE TABLE competency_strategic_actions (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            competency_area TEXT NOT NULL,
            action_text TEXT NOT NULL,
            score_range_min INTEGER DEFAULT 0,
            score_range_max INTEGER DEFAULT 100,
            framework TEXT NOT NULL CHECK (framework IN ('core', 'icf', 'ac')),
            context_level TEXT DEFAULT 'beginner',
            priority_order INTEGER DEFAULT 0,
            is_active BOOLEAN DEFAULT true,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        ALTER TABLE competency_strategic_actions ENABLE ROW LEVEL SECURITY;
        CREATE POLICY competency_strategic_actions_public_read ON competency_strategic_actions
            FOR SELECT USING (true);
            
        RAISE NOTICE '✅ competency_strategic_actions created';
    ELSE
        RAISE NOTICE '⚠️  competency_strategic_actions already exists';
    END IF;
    
    -- Check if competency_performance_analysis exists  
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'competency_performance_analysis') THEN
        RAISE NOTICE 'Creating competency_performance_analysis table...';
        
        CREATE TABLE competency_performance_analysis (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID NOT NULL,
            competency_area TEXT NOT NULL,
            framework TEXT NOT NULL,
            assessment_level TEXT,
            performance_percentage DECIMAL,
            strength_level TEXT,
            analysis_data JSONB,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        ALTER TABLE competency_performance_analysis ENABLE ROW LEVEL SECURITY;
        CREATE POLICY competency_performance_analysis_user_policy ON competency_performance_analysis
            FOR ALL USING (auth.uid()::text = user_id::text);
            
        RAISE NOTICE '✅ competency_performance_analysis created';
    ELSE
        RAISE NOTICE '⚠️  competency_performance_analysis already exists';
    END IF;
END $$;

-- Add sample data only if table is empty
INSERT INTO competency_strategic_actions (competency_area, action_text, score_range_min, score_range_max, framework, context_level, priority_order)
SELECT * FROM (VALUES
    ('Active Listening', 'Practice Level 2 listening exercises daily - focus entirely on the speaker without preparing your response', 0, 60, 'core', 'beginner', 1),
    ('Powerful Questions', 'Study the difference between open and closed questions - practice converting closed questions to open ones', 0, 60, 'core', 'beginner', 1),
    ('Present Moment Awareness', 'Develop your ability to notice and name what you observe in real-time during conversations', 0, 60, 'core', 'beginner', 1)
) AS v(competency_area, action_text, score_range_min, score_range_max, framework, context_level, priority_order)
WHERE NOT EXISTS (SELECT 1 FROM competency_strategic_actions LIMIT 1);

-- Final status
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🎯 TABLES STATUS CHECK COMPLETE';
    RAISE NOTICE 'Both tables should now exist for frontend use';
END $$;