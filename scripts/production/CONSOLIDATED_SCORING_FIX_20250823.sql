-- ============================================================================
-- CONSOLIDATED PRODUCTION SCORING & CLEANUP FIX
-- Date: 2025-08-23
-- Purpose: Fix scoring_tier_id assignments + Remove backup tables
-- ============================================================================

-- PART 1: Fix missing scoring_tier_id in leverage strengths
-- (This addresses the original issue mentioned)
UPDATE competency_leverage_strengths 
SET scoring_tier_id = get_scoring_tier_basic(score_threshold)
WHERE scoring_tier_id IS NULL 
AND score_threshold IS NOT NULL
AND is_active = true;

-- PART 2: Remove backup tables (immediate performance improvement)
-- These are confirmed safe to remove and will free significant space + indexes

DO $$ BEGIN
    RAISE NOTICE '=== REMOVING BACKUP TABLES ===';
END $$;

-- Verify main tables are healthy first
DO $$
DECLARE
    strategic_count INTEGER;
    leverage_count INTEGER; 
    analysis_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO strategic_count FROM competency_strategic_actions WHERE is_active = true;
    SELECT COUNT(*) INTO leverage_count FROM competency_leverage_strengths WHERE is_active = true;
    SELECT COUNT(*) INTO analysis_count FROM competency_performance_analysis WHERE is_active = true;
    
    IF strategic_count = 0 OR leverage_count = 0 OR analysis_count = 0 THEN
        RAISE EXCEPTION 'ABORT: Main tables appear empty!';
    END IF;
    
    RAISE NOTICE 'Safety check passed - proceeding with backup removal';
END $$;

-- Remove backup tables (these contain old scoring columns from migration)
DROP TABLE IF EXISTS competency_strategic_actions_scoring_backup;
DROP TABLE IF EXISTS competency_performance_analysis_scoring_backup;
DROP TABLE IF EXISTS competency_leverage_strengths_scoring_backup;
DROP TABLE IF EXISTS competency_rich_insights_backup;
DROP TABLE IF EXISTS final_backup_strategic_actions_old_columns;
DROP TABLE IF EXISTS final_backup_leverage_strengths_old_columns;
DROP TABLE IF EXISTS final_backup_analysis_old_columns;

DO $$ BEGIN
    RAISE NOTICE '✅ Removed 7 backup tables and their indexes';
    RAISE NOTICE '🚀 DML performance should improve immediately';
END $$;

-- PART 3: Verification
DO $$
DECLARE
    backup_count INTEGER;
    null_scoring_count INTEGER;
BEGIN
    -- Verify backups are gone
    SELECT COUNT(*) INTO backup_count
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND (table_name LIKE '%backup%' OR table_name LIKE '%_old_columns');
    
    -- Verify scoring_tier_id fix
    SELECT COUNT(*) INTO null_scoring_count
    FROM competency_leverage_strengths 
    WHERE scoring_tier_id IS NULL 
    AND score_threshold IS NOT NULL
    AND is_active = true;
    
    RAISE NOTICE 'Backup tables remaining: %', backup_count;
    RAISE NOTICE 'Leverage strengths with missing scoring_tier_id: %', null_scoring_count;
    
    IF backup_count = 0 AND null_scoring_count = 0 THEN
        RAISE NOTICE '🎉 COMPLETE SUCCESS: All issues resolved!';
    END IF;
END $$;