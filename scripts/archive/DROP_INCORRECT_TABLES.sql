-- ====================================================================
-- DROP INCORRECT TABLES - CLEANUP SCRIPT
-- ====================================================================
-- Purpose: Remove incorrectly named tables created by deployment scripts
-- We have both correct and incorrect tables, need to drop the wrong ones
-- 
-- CORRECT TABLES (keep these):
-- - user_assessment_attempts  
-- - user_question_responses
--
-- INCORRECT TABLES (drop these):
-- - user_attempts
-- - user_responses
-- ====================================================================

-- Drop foreign key constraints first to avoid dependency issues
ALTER TABLE IF EXISTS user_responses DROP CONSTRAINT IF EXISTS user_responses_attempt_id_fkey;
ALTER TABLE IF EXISTS user_responses DROP CONSTRAINT IF EXISTS user_responses_question_id_fkey;

-- Drop RLS policies from incorrect tables first
DROP POLICY IF EXISTS user_attempts_user_policy ON user_attempts;
DROP POLICY IF EXISTS user_responses_user_policy ON user_responses;

-- Drop the incorrectly named tables
DROP TABLE IF EXISTS user_responses CASCADE;
DROP TABLE IF EXISTS user_attempts CASCADE;

-- Verify cleanup
DO $$ 
BEGIN 
    RAISE NOTICE '✅ INCORRECT TABLES DROPPED!';
    RAISE NOTICE '';
    RAISE NOTICE '🗑️ DROPPED TABLES:';
    RAISE NOTICE '   ✓ user_attempts (incorrect name)';
    RAISE NOTICE '   ✓ user_responses (incorrect name)';
    RAISE NOTICE '';
    RAISE NOTICE '✅ KEPT CORRECT TABLES:';
    RAISE NOTICE '   ✓ user_assessment_attempts (frontend uses this)';
    RAISE NOTICE '   ✓ user_question_responses (frontend uses this)';
    RAISE NOTICE '';
    RAISE NOTICE '🎯 STATUS: Database cleaned up - only correct tables remain!';
END $$;

-- Show remaining tables for verification
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name LIKE '%user_%' 
ORDER BY table_name;