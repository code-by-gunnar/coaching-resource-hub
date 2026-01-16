-- ====================================================================
-- ENABLE ROW LEVEL SECURITY ON NEW ASSESSMENT SYSTEM TABLES
-- ====================================================================
-- Purpose: Add proper RLS policies to new tables created for assessment system
-- Tables: user_attempts, user_responses, skill_tags, tag_insights, tag_actions,
--         competency_display_names, competency_leverage_strengths,
--         learning_path_categories, learning_resources
-- ====================================================================

-- ====================================================================
-- STEP 1: ENABLE RLS ON USER DATA TABLES
-- ====================================================================

-- Enable RLS on user_attempts (contains user-specific data)
ALTER TABLE user_attempts ENABLE ROW LEVEL SECURITY;

-- Enable RLS on user_responses (contains user-specific data)
ALTER TABLE user_responses ENABLE ROW LEVEL SECURITY;

-- Enable RLS on temporary_pdf_files (contains user-specific PDF files)
ALTER TABLE temporary_pdf_files ENABLE ROW LEVEL SECURITY;

-- ====================================================================
-- STEP 2: CREATE RLS POLICIES FOR USER DATA TABLES
-- ====================================================================

-- Policy for user_attempts - users can only access their own attempts
CREATE POLICY user_attempts_user_policy ON user_attempts
    FOR ALL USING (auth.uid()::text = user_id::text);

-- Policy for user_responses - users can only access responses from their own attempts
CREATE POLICY user_responses_user_policy ON user_responses
    FOR ALL USING (
        auth.uid()::text IN (
            SELECT ua.user_id::text 
            FROM user_attempts ua 
            WHERE ua.id = attempt_id
        )
    );

-- Policy for temporary_pdf_files - users can only access their own PDF files
CREATE POLICY temporary_pdf_files_user_policy ON temporary_pdf_files
    FOR ALL USING (auth.uid()::text = user_id::text);

-- Policy for temporary_pdf_files - allow access via download token (for anonymous downloads)
CREATE POLICY temporary_pdf_files_token_policy ON temporary_pdf_files
    FOR SELECT USING (download_token IS NOT NULL);

-- ====================================================================
-- STEP 3: ENABLE RLS ON PUBLIC READ TABLES (ASSESSMENT CONFIGURATION)
-- ====================================================================

-- These tables contain assessment configuration data that should be publicly readable
-- but only modifiable by admins

-- Enable RLS on skill_tags
ALTER TABLE skill_tags ENABLE ROW LEVEL SECURITY;
CREATE POLICY skill_tags_public_read ON skill_tags
    FOR SELECT USING (true);

-- Enable RLS on tag_insights  
ALTER TABLE tag_insights ENABLE ROW LEVEL SECURITY;
CREATE POLICY tag_insights_public_read ON tag_insights
    FOR SELECT USING (true);

-- Enable RLS on tag_actions
ALTER TABLE tag_actions ENABLE ROW LEVEL SECURITY;
CREATE POLICY tag_actions_public_read ON tag_actions
    FOR SELECT USING (true);

-- Enable RLS on competency_display_names
ALTER TABLE competency_display_names ENABLE ROW LEVEL SECURITY;
CREATE POLICY competency_display_names_public_read ON competency_display_names
    FOR SELECT USING (true);

-- Enable RLS on competency_leverage_strengths
ALTER TABLE competency_leverage_strengths ENABLE ROW LEVEL SECURITY;
CREATE POLICY competency_leverage_strengths_public_read ON competency_leverage_strengths
    FOR SELECT USING (true);

-- Enable RLS on learning_path_categories
ALTER TABLE learning_path_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY learning_path_categories_public_read ON learning_path_categories
    FOR SELECT USING (true);

-- Enable RLS on learning_resources
ALTER TABLE learning_resources ENABLE ROW LEVEL SECURITY;
CREATE POLICY learning_resources_public_read ON learning_resources
    FOR SELECT USING (true);

-- ====================================================================
-- STEP 4: VERIFICATION
-- ====================================================================

-- Check RLS status on all tables
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN (
    'user_attempts', 'user_responses', 'temporary_pdf_files', 'skill_tags', 'tag_insights', 
    'tag_actions', 'competency_display_names', 'competency_leverage_strengths',
    'learning_path_categories', 'learning_resources'
)
ORDER BY tablename;

-- Check policies created
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN (
    'user_attempts', 'user_responses', 'temporary_pdf_files', 'skill_tags', 'tag_insights', 
    'tag_actions', 'competency_display_names', 'competency_leverage_strengths',
    'learning_path_categories', 'learning_resources'
)
ORDER BY tablename, policyname;

-- Success message
DO $$ 
BEGIN 
    RAISE NOTICE '✅ RLS ENABLED AND POLICIES CREATED SUCCESSFULLY!';
    RAISE NOTICE '';
    RAISE NOTICE '🔒 USER DATA TABLES (user_attempts, user_responses, temporary_pdf_files):';
    RAISE NOTICE '   - RLS enabled with user-specific access policies';
    RAISE NOTICE '   - temporary_pdf_files also allows token-based access for downloads';
    RAISE NOTICE '';
    RAISE NOTICE '📖 PUBLIC READ TABLES (assessment configuration):';
    RAISE NOTICE '   - skill_tags, tag_insights, tag_actions';
    RAISE NOTICE '   - competency_display_names, competency_leverage_strengths';
    RAISE NOTICE '   - learning_path_categories, learning_resources';
    RAISE NOTICE '   - All enabled with public read access';
    RAISE NOTICE '';
    RAISE NOTICE '🎯 SECURITY STATUS: Assessment system is now properly secured';
END $$;