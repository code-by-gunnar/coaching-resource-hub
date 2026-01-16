-- ====================================================================
-- CREATE MISSING TABLES ONLY - QUICK FIX
-- ====================================================================
-- Purpose: Create just the missing tables the frontend needs
-- ====================================================================

-- Create competency_strategic_actions table (frontend expects this)
CREATE TABLE IF NOT EXISTS competency_strategic_actions (
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

-- Create competency_performance_analysis table (frontend expects this)
CREATE TABLE IF NOT EXISTS competency_performance_analysis (
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

-- Enable RLS and create policies
ALTER TABLE competency_strategic_actions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS competency_strategic_actions_public_read ON competency_strategic_actions;
CREATE POLICY competency_strategic_actions_public_read ON competency_strategic_actions
    FOR SELECT USING (true);

ALTER TABLE competency_performance_analysis ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS competency_performance_analysis_user_policy ON competency_performance_analysis;
CREATE POLICY competency_performance_analysis_user_policy ON competency_performance_analysis
    FOR ALL USING (auth.uid()::text = user_id::text);

-- Add sample strategic actions
INSERT INTO competency_strategic_actions (competency_area, action_text, score_range_min, score_range_max, framework, context_level, priority_order) VALUES
('Active Listening', 'Practice Level 2 listening exercises daily - focus entirely on the speaker without preparing your response', 0, 60, 'core', 'beginner', 1),
('Active Listening', 'Record yourself in practice sessions and identify moments when your attention wandered', 20, 70, 'core', 'beginner', 2),
('Powerful Questions', 'Study the difference between open and closed questions - practice converting closed questions to open ones', 0, 60, 'core', 'beginner', 1),
('Powerful Questions', 'Create a question bank organized by purpose: clarifying, exploring, challenging, visioning', 30, 70, 'core', 'beginner', 2),
('Present Moment Awareness', 'Develop your ability to notice and name what you observe in real-time during conversations', 0, 60, 'core', 'beginner', 1),
('Present Moment Awareness', 'Practice sitting with silence and discomfort - resist the urge to fill every pause', 25, 70, 'core', 'beginner', 2)
ON CONFLICT DO NOTHING;

-- Success message
DO $$ 
BEGIN 
    RAISE NOTICE '✅ MISSING TABLES CREATED!';
    RAISE NOTICE '   ✓ competency_strategic_actions';
    RAISE NOTICE '   ✓ competency_performance_analysis';
    RAISE NOTICE '🎯 Frontend should now find these tables!';
END $$;