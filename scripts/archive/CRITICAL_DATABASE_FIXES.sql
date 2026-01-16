-- ====================================================================
-- CRITICAL DATABASE FIXES - PRODUCTION DEPLOYMENT REPAIR
-- ====================================================================
-- Purpose: Fix critical issues between frontend expectations and actual database state
-- Issues Found:
-- 1. Frontend expects user_assessment_attempts, production has user_attempts
-- 2. Frontend expects user_question_responses, production has user_responses  
-- 3. Table schemas don't match frontend requirements
-- 4. Missing columns and wrong column names
-- 5. Functions reference wrong table names
-- ====================================================================

-- ====================================================================
-- STEP 1: RENAME INCORRECTLY NAMED TABLES
-- ====================================================================

-- Rename user_attempts to user_assessment_attempts (frontend expects this)
ALTER TABLE IF EXISTS user_attempts RENAME TO user_assessment_attempts;

-- Rename user_responses to user_question_responses (frontend expects this)
ALTER TABLE IF EXISTS user_responses RENAME TO user_question_responses;

-- ====================================================================
-- STEP 2: ADD MISSING COLUMNS TO user_assessment_attempts
-- ====================================================================

-- Frontend expects these columns that are missing from user_attempts schema
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

-- Rename frontend_insights to enriched_data (this is what functions expect)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'user_assessment_attempts' 
               AND column_name = 'frontend_insights') THEN
        ALTER TABLE user_assessment_attempts RENAME COLUMN frontend_insights TO enriched_data;
    END IF;
END $$;

-- Remove insights_generated_at column (not used by frontend)
ALTER TABLE user_assessment_attempts DROP COLUMN IF EXISTS insights_generated_at;

-- Make score column nullable (frontend doesn't always set score immediately)
ALTER TABLE user_assessment_attempts ALTER COLUMN score DROP NOT NULL;

-- ====================================================================
-- STEP 3: ADD MISSING COLUMNS TO user_question_responses  
-- ====================================================================

-- Frontend expects selected_answer as TEXT (A,B,C,D), not INTEGER
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'user_question_responses' 
               AND column_name = 'selected_answer' 
               AND data_type = 'integer') THEN
        -- Convert INTEGER to TEXT with mapping
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

-- ====================================================================
-- STEP 4: ADD MISSING CONSTRAINTS
-- ====================================================================

-- Add status constraint if missing
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'user_assessment_attempts_status_check') THEN
        ALTER TABLE user_assessment_attempts 
        ADD CONSTRAINT user_assessment_attempts_status_check 
        CHECK (status IN ('started', 'in_progress', 'completed', 'abandoned'));
    END IF;
END $$;

-- Add selected_answer constraint if missing  
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'user_question_responses_selected_answer_check') THEN
        ALTER TABLE user_question_responses 
        ADD CONSTRAINT user_question_responses_selected_answer_check 
        CHECK (selected_answer IN ('A', 'B', 'C', 'D'));
    END IF;
END $$;

-- ====================================================================
-- STEP 5: UPDATE FOREIGN KEY REFERENCES
-- ====================================================================

-- Drop and recreate foreign keys with correct table names
ALTER TABLE user_question_responses DROP CONSTRAINT IF EXISTS user_responses_attempt_id_fkey;
ALTER TABLE user_question_responses DROP CONSTRAINT IF EXISTS user_question_responses_attempt_id_fkey;

ALTER TABLE user_question_responses 
ADD CONSTRAINT user_question_responses_attempt_id_fkey 
FOREIGN KEY (attempt_id) REFERENCES user_assessment_attempts(id) ON DELETE CASCADE;

-- ====================================================================
-- STEP 6: UPDATE UNIQUE CONSTRAINTS
-- ====================================================================

-- Add missing unique constraint
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'user_question_responses_attempt_id_question_id_key') THEN
        ALTER TABLE user_question_responses 
        ADD CONSTRAINT user_question_responses_attempt_id_question_id_key 
        UNIQUE (attempt_id, question_id);
    END IF;
END $$;

-- ====================================================================
-- STEP 7: CREATE MISSING TRIGGERS FOR UPDATED_AT
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
-- STEP 8: UPDATE RLS POLICIES WITH CORRECT TABLE NAMES
-- ====================================================================

-- Enable RLS on renamed tables
ALTER TABLE user_assessment_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_question_responses ENABLE ROW LEVEL SECURITY;

-- Drop old policies
DROP POLICY IF EXISTS user_attempts_user_policy ON user_assessment_attempts;
DROP POLICY IF EXISTS user_responses_user_policy ON user_question_responses;

-- Create correct policies
CREATE POLICY user_assessment_attempts_user_policy ON user_assessment_attempts
    FOR ALL USING (auth.uid()::text = user_id::text);

CREATE POLICY user_question_responses_user_policy ON user_question_responses
    FOR ALL USING (
        auth.uid()::text IN (
            SELECT user_id::text FROM user_assessment_attempts WHERE id = attempt_id
        )
    );

-- ====================================================================
-- STEP 9: UPDATE INDEXES WITH CORRECT TABLE NAMES
-- ====================================================================

-- Drop old indexes and create with correct names
DROP INDEX IF EXISTS idx_user_assessment_attempts_user_id;
CREATE INDEX IF NOT EXISTS idx_user_assessment_attempts_user_id 
ON user_assessment_attempts(user_id);

DROP INDEX IF EXISTS idx_user_assessment_attempts_assessment_id;
CREATE INDEX IF NOT EXISTS idx_user_assessment_attempts_assessment_id 
ON user_assessment_attempts(assessment_id);

DROP INDEX IF EXISTS idx_user_question_responses_attempt_id;
CREATE INDEX IF NOT EXISTS idx_user_question_responses_attempt_id 
ON user_question_responses(attempt_id);

DROP INDEX IF EXISTS idx_user_question_responses_question_id;
CREATE INDEX IF NOT EXISTS idx_user_question_responses_question_id 
ON user_question_responses(question_id);

-- ====================================================================
-- STEP 10: VERIFICATION QUERIES
-- ====================================================================

-- Verify table structures
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name IN ('user_assessment_attempts', 'user_question_responses')
AND table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- Verify constraints
SELECT 
    table_name,
    constraint_name,
    constraint_type
FROM information_schema.table_constraints 
WHERE table_name IN ('user_assessment_attempts', 'user_question_responses')
AND table_schema = 'public'
ORDER BY table_name, constraint_name;

-- Success message
DO $$ 
BEGIN 
    RAISE NOTICE '✅ CRITICAL DATABASE FIXES COMPLETED!';
    RAISE NOTICE '';
    RAISE NOTICE '🔧 TABLES FIXED:';
    RAISE NOTICE '   ✓ user_attempts → user_assessment_attempts';
    RAISE NOTICE '   ✓ user_responses → user_question_responses';
    RAISE NOTICE '';
    RAISE NOTICE '📋 COLUMNS ADDED/FIXED:';
    RAISE NOTICE '   ✓ status, total_questions, correct_answers, started_at, updated_at';
    RAISE NOTICE '   ✓ selected_answer converted from INTEGER to TEXT (A,B,C,D)';
    RAISE NOTICE '   ✓ frontend_insights → enriched_data';
    RAISE NOTICE '';
    RAISE NOTICE '🔒 SECURITY UPDATED:';
    RAISE NOTICE '   ✓ RLS policies updated with correct table names';
    RAISE NOTICE '   ✓ Foreign keys and constraints fixed';
    RAISE NOTICE '';
    RAISE NOTICE '🎯 STATUS: Database now matches frontend expectations!';
END $$;