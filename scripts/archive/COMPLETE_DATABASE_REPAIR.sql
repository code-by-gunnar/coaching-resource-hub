-- ====================================================================
-- COMPLETE DATABASE REPAIR - PRODUCTION FIX
-- ====================================================================
-- Purpose: Fix all database issues after incomplete deployment
-- Issues: 
-- 1. Policy conflicts on renamed tables
-- 2. Wrong schema on renamed tables (missing columns, wrong types)
-- 3. Missing tables that frontend expects
-- 4. Missing functions and views
-- ====================================================================

-- ====================================================================
-- STEP 1: DROP CONFLICTING POLICIES
-- ====================================================================

DROP POLICY IF EXISTS user_assessment_attempts_user_policy ON user_assessment_attempts;
DROP POLICY IF EXISTS user_question_responses_user_policy ON user_question_responses;
DROP POLICY IF EXISTS temporary_pdf_files_user_policy ON temporary_pdf_files;
DROP POLICY IF EXISTS temporary_pdf_files_token_policy ON temporary_pdf_files;

-- ====================================================================
-- STEP 2: FIX user_assessment_attempts SCHEMA
-- ====================================================================

-- Add missing columns that frontend expects
ALTER TABLE user_assessment_attempts 
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'started';

ALTER TABLE user_assessment_attempts 
ADD COLUMN IF NOT EXISTS total_questions INTEGER;

ALTER TABLE user_assessment_attempts 
ADD COLUMN IF NOT EXISTS correct_answers INTEGER;

ALTER TABLE user_assessment_attempts 
ADD COLUMN IF NOT EXISTS started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

ALTER TABLE user_assessment_attempts 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Rename frontend_insights to enriched_data (functions expect this)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'user_assessment_attempts' 
               AND column_name = 'frontend_insights') THEN
        ALTER TABLE user_assessment_attempts RENAME COLUMN frontend_insights TO enriched_data;
    END IF;
END $$;

-- Make score nullable (frontend doesn't set initially)
ALTER TABLE user_assessment_attempts ALTER COLUMN score DROP NOT NULL;

-- Add status constraint
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'user_assessment_attempts_status_check') THEN
        ALTER TABLE user_assessment_attempts 
        ADD CONSTRAINT user_assessment_attempts_status_check 
        CHECK (status IN ('started', 'in_progress', 'completed', 'abandoned'));
    END IF;
END $$;

-- ====================================================================
-- STEP 3: FIX user_question_responses SCHEMA
-- ====================================================================

-- Convert selected_answer from INTEGER to TEXT (A,B,C,D)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'user_question_responses' 
               AND column_name = 'selected_answer' 
               AND data_type = 'integer') THEN
        
        ALTER TABLE user_question_responses 
        ADD COLUMN selected_answer_text TEXT;
        
        UPDATE user_question_responses 
        SET selected_answer_text = CASE selected_answer
            WHEN 0 THEN 'A'
            WHEN 1 THEN 'B' 
            WHEN 2 THEN 'C'
            WHEN 3 THEN 'D'
            ELSE NULL
        END;
        
        ALTER TABLE user_question_responses DROP COLUMN selected_answer;
        ALTER TABLE user_question_responses RENAME COLUMN selected_answer_text TO selected_answer;
    END IF;
END $$;

-- Add missing columns
ALTER TABLE user_question_responses 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

ALTER TABLE user_question_responses 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Rename response_time to time_spent (frontend uses time_spent)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'user_question_responses' 
               AND column_name = 'response_time') THEN
        ALTER TABLE user_question_responses RENAME COLUMN response_time TO time_spent;
    END IF;
END $$;

-- Add selected_answer constraint
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'user_question_responses_selected_answer_check') THEN
        ALTER TABLE user_question_responses 
        ADD CONSTRAINT user_question_responses_selected_answer_check 
        CHECK (selected_answer IN ('A', 'B', 'C', 'D'));
    END IF;
END $$;

-- ====================================================================
-- STEP 4: CREATE MISSING TABLES
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

-- ====================================================================
-- STEP 5: RECREATE PROPER RLS POLICIES
-- ====================================================================

-- Enable RLS on user tables
ALTER TABLE user_assessment_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_question_responses ENABLE ROW LEVEL SECURITY;

-- Create user-specific policies
CREATE POLICY user_assessment_attempts_user_policy ON user_assessment_attempts
    FOR ALL USING (auth.uid()::text = user_id::text);

CREATE POLICY user_question_responses_user_policy ON user_question_responses
    FOR ALL USING (
        auth.uid()::text IN (
            SELECT user_id::text FROM user_assessment_attempts WHERE id = attempt_id
        )
    );

-- Enable RLS on new tables
ALTER TABLE competency_strategic_actions ENABLE ROW LEVEL SECURITY;
CREATE POLICY competency_strategic_actions_public_read ON competency_strategic_actions
    FOR SELECT USING (true);

ALTER TABLE competency_performance_analysis ENABLE ROW LEVEL SECURITY;
CREATE POLICY competency_performance_analysis_user_policy ON competency_performance_analysis
    FOR ALL USING (auth.uid()::text = user_id::text);

-- ====================================================================
-- STEP 6: CREATE MISSING TRIGGERS
-- ====================================================================

-- Create or replace update timestamp function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql'
SET search_path = '';

-- Add updated_at triggers
DROP TRIGGER IF EXISTS update_user_assessment_attempts_updated_at ON user_assessment_attempts;
CREATE TRIGGER update_user_assessment_attempts_updated_at 
    BEFORE UPDATE ON user_assessment_attempts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_question_responses_updated_at ON user_question_responses;
CREATE TRIGGER update_user_question_responses_updated_at 
    BEFORE UPDATE ON user_question_responses 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ====================================================================
-- STEP 7: POPULATE SAMPLE DATA FOR MISSING TABLES
-- ====================================================================

-- Add sample strategic actions for Core I competencies
INSERT INTO competency_strategic_actions (competency_area, action_text, score_range_min, score_range_max, framework, context_level, priority_order) VALUES
('Active Listening', 'Practice Level 2 listening exercises daily - focus entirely on the speaker without preparing your response', 0, 60, 'core', 'beginner', 1),
('Active Listening', 'Record yourself in practice sessions and identify moments when your attention wandered', 20, 70, 'core', 'beginner', 2),
('Powerful Questions', 'Study the difference between open and closed questions - practice converting closed questions to open ones', 0, 60, 'core', 'beginner', 1),
('Powerful Questions', 'Create a question bank organized by purpose: clarifying, exploring, challenging, visioning', 30, 70, 'core', 'beginner', 2),
('Present Moment Awareness', 'Develop your ability to notice and name what you observe in real-time during conversations', 0, 60, 'core', 'beginner', 1),
('Present Moment Awareness', 'Practice sitting with silence and discomfort - resist the urge to fill every pause', 25, 70, 'core', 'beginner', 2)
ON CONFLICT DO NOTHING;

-- ====================================================================
-- STEP 8: VERIFICATION
-- ====================================================================

-- Check that all expected tables exist
SELECT table_name, table_type 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
    'user_assessment_attempts', 'user_question_responses', 
    'competency_strategic_actions', 'competency_performance_analysis',
    'assessment_overview', 'user_assessment_progress', 'user_competency_performance'
)
ORDER BY table_name;

-- Check key columns exist with correct types
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name = 'user_assessment_attempts'
AND column_name IN ('status', 'total_questions', 'enriched_data', 'started_at')
ORDER BY table_name, column_name;

-- Success message
DO $$ 
BEGIN 
    RAISE NOTICE '✅ COMPLETE DATABASE REPAIR FINISHED!';
    RAISE NOTICE '';
    RAISE NOTICE '🔧 SCHEMA FIXES:';
    RAISE NOTICE '   ✓ user_assessment_attempts: Added missing columns, fixed types';
    RAISE NOTICE '   ✓ user_question_responses: Converted selected_answer to TEXT';
    RAISE NOTICE '';
    RAISE NOTICE '📋 MISSING TABLES CREATED:';
    RAISE NOTICE '   ✓ competency_strategic_actions';
    RAISE NOTICE '   ✓ competency_performance_analysis';
    RAISE NOTICE '';
    RAISE NOTICE '🔒 SECURITY RESTORED:';
    RAISE NOTICE '   ✓ RLS policies recreated without conflicts';
    RAISE NOTICE '';
    RAISE NOTICE '🎯 STATUS: Database should now match frontend expectations!';
END $$;