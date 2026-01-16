-- ====================================================================
-- ENABLE ROW LEVEL SECURITY ON TEMPORARY_PDF_FILES TABLE
-- ====================================================================
-- Purpose: Add proper RLS policies to temporary_pdf_files table
-- Allows user-specific access and token-based downloads
-- ====================================================================

-- Enable RLS on temporary_pdf_files table
ALTER TABLE temporary_pdf_files ENABLE ROW LEVEL SECURITY;

-- Policy 1: Users can only access their own PDF files (drop if exists first)
DROP POLICY IF EXISTS temporary_pdf_files_user_policy ON temporary_pdf_files;
CREATE POLICY temporary_pdf_files_user_policy ON temporary_pdf_files
    FOR ALL USING (auth.uid()::text = user_id::text);

-- Policy 2: Allow SELECT access via download token (for anonymous/shared downloads)
DROP POLICY IF EXISTS temporary_pdf_files_token_policy ON temporary_pdf_files;
CREATE POLICY temporary_pdf_files_token_policy ON temporary_pdf_files
    FOR SELECT USING (download_token IS NOT NULL);

-- ====================================================================
-- VERIFICATION
-- ====================================================================

-- Check RLS status
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'temporary_pdf_files';

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
AND tablename = 'temporary_pdf_files'
ORDER BY policyname;

-- Success message
DO $$ 
BEGIN 
    RAISE NOTICE '✅ RLS ENABLED ON temporary_pdf_files TABLE!';
    RAISE NOTICE '';
    RAISE NOTICE '🔒 POLICIES CREATED:';
    RAISE NOTICE '   ✓ temporary_pdf_files_user_policy: Users access only their own PDFs';
    RAISE NOTICE '   ✓ temporary_pdf_files_token_policy: Token-based access for downloads';
    RAISE NOTICE '';
    RAISE NOTICE '🎯 SECURITY STATUS: temporary_pdf_files table is now properly secured';
END $$;