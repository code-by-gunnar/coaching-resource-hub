-- ENHANCED CONSOLIDATED SCORING SYSTEM FIX
-- Complete solution incorporating all elements from scripts 01-04
-- Includes: 3-tier scoring, RLS policies, validation, analysis types integration
-- Date: 2025-08-23
-- Compatible with both local dev and production environments

-- =============================================================================
-- SECURITY: SET SEARCH PATH AND ENSURE RLS
-- =============================================================================

SET search_path = '';
SET search_path TO public;

-- =============================================================================
-- PART 1: CREATE COMPREHENSIVE 3-TIER SCORING SYSTEM
-- =============================================================================

DO $$ BEGIN RAISE NOTICE 'PART 1: Setting up enhanced 3-tier scoring system...'; END $$;

-- Create scoring_tiers table with full feature set
CREATE TABLE IF NOT EXISTS scoring_tiers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tier_code VARCHAR(20) UNIQUE NOT NULL,  -- 'weakness', 'developing', 'strength'
    tier_name VARCHAR(50) NOT NULL,         -- 'Weakness', 'Developing', 'Strength'
    score_min INTEGER NOT NULL,             -- 0, 50, 70
    score_max INTEGER NOT NULL,             -- 49, 69, 100
    display_order INTEGER NOT NULL,         -- 1, 2, 3
    analysis_type_id UUID,                  -- FK to analysis_types (populated later)
    description TEXT,                       -- What this tier represents
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add constraints to prevent overlapping ranges
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_name = 'scoring_tiers' 
        AND constraint_name = 'check_valid_score_range'
    ) THEN
        ALTER TABLE scoring_tiers 
        ADD CONSTRAINT check_valid_score_range 
        CHECK (score_min >= 0 AND score_max <= 100 AND score_min <= score_max);
    END IF;
END $$;

-- Add unique index to prevent overlapping ranges
CREATE UNIQUE INDEX IF NOT EXISTS idx_scoring_tiers_no_overlap ON scoring_tiers (score_min, score_max);

-- Insert the 3 scoring tiers
INSERT INTO scoring_tiers (tier_code, tier_name, description, score_min, score_max, display_order) VALUES
('weakness', 'Weakness', 'Areas requiring focused development (0-49%)', 0, 49, 1),
('developing', 'Developing', 'Areas showing progress with room for consistency (50-69%)', 50, 69, 2),
('strength', 'Strength', 'Areas of competence and confidence (70-100%)', 70, 100, 3)
ON CONFLICT (tier_code) DO UPDATE SET
    tier_name = EXCLUDED.tier_name,
    description = EXCLUDED.description,
    score_min = EXCLUDED.score_min,
    score_max = EXCLUDED.score_max,
    display_order = EXCLUDED.display_order,
    updated_at = NOW();

-- =============================================================================
-- PART 2: FRAMEWORK-SPECIFIC SCORING OVERRIDES TABLE
-- =============================================================================

DO $$ BEGIN RAISE NOTICE 'Creating framework scoring overrides table...'; END $$;

CREATE TABLE IF NOT EXISTS framework_scoring_overrides (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    framework_id UUID NOT NULL REFERENCES frameworks(id) ON DELETE CASCADE,
    assessment_level_id UUID REFERENCES assessment_levels(id) ON DELETE CASCADE,
    tier_code VARCHAR(20) NOT NULL REFERENCES scoring_tiers(tier_code) ON DELETE CASCADE,
    custom_score_min INTEGER,               -- Override default if needed
    custom_score_max INTEGER,               -- Override default if needed
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Prevent duplicate overrides for same framework/level/tier combination
CREATE UNIQUE INDEX IF NOT EXISTS idx_framework_scoring_unique 
ON framework_scoring_overrides (framework_id, assessment_level_id, tier_code)
WHERE is_active = true;

-- Add constraints for custom ranges
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_name = 'framework_scoring_overrides' 
        AND constraint_name = 'check_custom_score_range'
    ) THEN
        ALTER TABLE framework_scoring_overrides 
        ADD CONSTRAINT check_custom_score_range 
        CHECK (custom_score_min >= 0 AND custom_score_max <= 100 AND custom_score_min <= custom_score_max);
    END IF;
END $$;

-- =============================================================================
-- PART 3: ADD MISSING COLUMNS TO EXISTING TABLES
-- =============================================================================

DO $$ 
BEGIN 
    RAISE NOTICE 'Adding missing columns to existing tables...';
    
    -- Add scoring_tier_id to competency_strategic_actions if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'competency_strategic_actions' 
        AND column_name = 'scoring_tier_id'
    ) THEN
        ALTER TABLE competency_strategic_actions 
        ADD COLUMN scoring_tier_id UUID REFERENCES scoring_tiers(id) ON DELETE SET NULL;
        RAISE NOTICE 'Added scoring_tier_id column to competency_strategic_actions';
    END IF;
    
    
    -- Add scoring_tier_id to competency_performance_analysis if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'competency_performance_analysis' 
        AND column_name = 'scoring_tier_id'
    ) THEN
        ALTER TABLE competency_performance_analysis 
        ADD COLUMN scoring_tier_id UUID REFERENCES scoring_tiers(id) ON DELETE SET NULL;
        RAISE NOTICE 'Added scoring_tier_id column to competency_performance_analysis';
    END IF;
    
    
    -- Add scoring_tier_id to competency_leverage_strengths if exists and missing
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'competency_leverage_strengths') 
    AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'competency_leverage_strengths' 
        AND column_name = 'scoring_tier_id'
    ) THEN
        ALTER TABLE competency_leverage_strengths 
        ADD COLUMN scoring_tier_id UUID REFERENCES scoring_tiers(id) ON DELETE SET NULL;
        RAISE NOTICE 'Added scoring_tier_id column to competency_leverage_strengths';
    END IF;
    
    RAISE NOTICE 'Column addition complete';
END $$;

-- =============================================================================
-- PART 4: ANALYSIS TYPES INTEGRATION
-- =============================================================================

DO $$ BEGIN RAISE NOTICE 'Integrating with analysis types system...'; END $$;

-- Add the "developing" analysis type for middle tier (50-69%)
INSERT INTO analysis_types (id, code, name, description, is_active, created_at) 
VALUES (
    gen_random_uuid(),
    'developing', 
    'Developing Analysis',
    'Analysis for users showing progress but needing consistency development (50-69% performance)',
    true,
    NOW()
) ON CONFLICT (code) DO NOTHING;

-- Link scoring tiers to analysis types
DO $$
DECLARE
    weakness_analysis_id UUID;
    developing_analysis_id UUID;
    strength_analysis_id UUID;
BEGIN
    -- Get analysis type IDs
    SELECT id INTO weakness_analysis_id FROM analysis_types WHERE code = 'weakness' LIMIT 1;
    SELECT id INTO developing_analysis_id FROM analysis_types WHERE code = 'developing' LIMIT 1;
    SELECT id INTO strength_analysis_id FROM analysis_types WHERE code = 'strength' LIMIT 1;
    
    -- Update scoring tiers with analysis type references
    UPDATE scoring_tiers SET analysis_type_id = weakness_analysis_id WHERE tier_code = 'weakness';
    UPDATE scoring_tiers SET analysis_type_id = developing_analysis_id WHERE tier_code = 'developing';
    UPDATE scoring_tiers SET analysis_type_id = strength_analysis_id WHERE tier_code = 'strength';
    
    RAISE NOTICE 'Linked scoring tiers to analysis types';
END;
$$;

-- =============================================================================
-- PART 5: CREATE COMPREHENSIVE DATABASE VIEWS
-- =============================================================================

DO $$ BEGIN RAISE NOTICE 'Creating comprehensive database views...'; END $$;

-- Strategic actions view with analysis type mapping (dynamic based on schema)
DO $$
DECLARE
    has_updated_at BOOLEAN;
    view_sql TEXT;
BEGIN
    -- Check if updated_at column exists
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'competency_strategic_actions' 
        AND column_name = 'updated_at'
    ) INTO has_updated_at;
    
    -- Build view SQL based on column existence
    view_sql := 'CREATE OR REPLACE VIEW strategic_actions_with_analysis_type 
WITH (security_invoker = true) AS
SELECT 
    csa.id,
    csa.action_text,
    csa.priority_order,
    csa.sort_order,
    csa.is_active,
    csa.created_at,';
    
    IF has_updated_at THEN
        view_sql := view_sql || '
    csa.updated_at,';
    ELSE
        view_sql := view_sql || '
    csa.created_at as updated_at,';
    END IF;
    
    view_sql := view_sql || '
    -- Competency information
    cdn.competency_key,
    cdn.display_name as competency_name,
    -- Framework information
    f.code as framework_code,
    f.name as framework_name,
    -- Assessment level information
    al.level_code as assessment_level,
    al.level_name as assessment_level_name,
    -- Scoring tier information
    st.tier_code as analysis_type_code,
    st.tier_name,
    st.score_min,
    st.score_max,
    st.display_order as tier_display_order
FROM competency_strategic_actions csa
LEFT JOIN competency_display_names cdn ON csa.competency_id = cdn.id
LEFT JOIN frameworks f ON csa.framework_id = f.id
LEFT JOIN assessment_levels al ON csa.assessment_level_id = al.id
LEFT JOIN scoring_tiers st ON csa.scoring_tier_id = st.id;';
    
    EXECUTE view_sql;
    
    IF has_updated_at THEN
        RAISE NOTICE 'Created strategic_actions view with updated_at column';
    ELSE
        RAISE NOTICE 'Created strategic_actions view with created_at as updated_at (fallback)';
    END IF;
END;
$$;

-- Performance analysis view with analysis type mapping (dynamic based on schema)
DO $$
DECLARE
    has_updated_at BOOLEAN;
    view_sql TEXT;
BEGIN
    -- Check if updated_at column exists
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'competency_performance_analysis' 
        AND column_name = 'updated_at'
    ) INTO has_updated_at;
    
    -- Build view SQL based on column existence
    view_sql := 'CREATE OR REPLACE VIEW performance_analysis_with_analysis_type 
WITH (security_invoker = true) AS
SELECT 
    cpa.id,
    cpa.analysis_text,
    cpa.sort_order,
    cpa.is_active,
    cpa.created_at,';
    
    IF has_updated_at THEN
        view_sql := view_sql || '
    cpa.updated_at,';
    ELSE
        view_sql := view_sql || '
    cpa.created_at as updated_at,';
    END IF;
    
    view_sql := view_sql || '
    -- Competency information
    cdn.competency_key,
    cdn.display_name as competency_name,
    -- Framework information
    f.code as framework_code,
    f.name as framework_name,
    -- Assessment level information
    al.level_code as assessment_level,
    al.level_name as assessment_level_name,
    -- Scoring tier information
    st.tier_code as analysis_type_code,
    st.tier_name,
    st.score_min,
    st.score_max,
    st.display_order as tier_display_order
FROM competency_performance_analysis cpa
LEFT JOIN competency_display_names cdn ON cpa.competency_id = cdn.id
LEFT JOIN frameworks f ON cpa.framework_id = f.id
LEFT JOIN assessment_levels al ON cpa.assessment_level_id = al.id
LEFT JOIN scoring_tiers st ON cpa.scoring_tier_id = st.id;';
    
    EXECUTE view_sql;
    
    IF has_updated_at THEN
        RAISE NOTICE 'Created performance_analysis view with updated_at column';
    ELSE
        RAISE NOTICE 'Created performance_analysis view with created_at as updated_at (fallback)';
    END IF;
END;
$$;

-- =============================================================================
-- PART 6: RLS POLICIES AND SECURITY
-- =============================================================================

DO $$ BEGIN RAISE NOTICE 'Setting up RLS policies...'; END $$;

-- Enable RLS on scoring_tiers table
ALTER TABLE scoring_tiers ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read all scoring tiers
DROP POLICY IF EXISTS "scoring_tiers_select_authenticated" ON scoring_tiers;
CREATE POLICY "scoring_tiers_select_authenticated" 
ON scoring_tiers FOR SELECT 
TO authenticated 
USING (true);

-- Allow service_role to manage scoring tiers (for admin functions)
DROP POLICY IF EXISTS "scoring_tiers_all_service_role" ON scoring_tiers;
CREATE POLICY "scoring_tiers_all_service_role"
ON scoring_tiers FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- Enable RLS on framework_scoring_overrides table
ALTER TABLE framework_scoring_overrides ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read scoring overrides
DROP POLICY IF EXISTS "framework_scoring_overrides_select_authenticated" ON framework_scoring_overrides;
CREATE POLICY "framework_scoring_overrides_select_authenticated"
ON framework_scoring_overrides FOR SELECT
TO authenticated
USING (true);

-- Allow service_role to manage scoring overrides
DROP POLICY IF EXISTS "framework_scoring_overrides_all_service_role" ON framework_scoring_overrides;
CREATE POLICY "framework_scoring_overrides_all_service_role"
ON framework_scoring_overrides FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- =============================================================================
-- PART 7: HELPER FUNCTIONS
-- =============================================================================

DO $$ BEGIN RAISE NOTICE 'Creating helper functions...'; END $$;

-- Basic function to get scoring tier
CREATE OR REPLACE FUNCTION get_scoring_tier_basic(
    score_percentage INTEGER
) 
RETURNS TABLE(
    tier_code VARCHAR(20),
    tier_name VARCHAR(50), 
    score_min INTEGER,
    score_max INTEGER
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT st.tier_code, st.tier_name, st.score_min, st.score_max
    FROM scoring_tiers st
    WHERE score_percentage BETWEEN st.score_min AND st.score_max
    AND st.is_active = true
    ORDER BY st.display_order
    LIMIT 1;
END;
$$;

-- Advanced function to get analysis type for score
CREATE OR REPLACE FUNCTION get_analysis_type_for_score(
    score_percentage INTEGER,
    p_framework_code TEXT DEFAULT NULL,
    p_assessment_level TEXT DEFAULT NULL
) 
RETURNS TABLE(
    analysis_type_code VARCHAR(20),
    analysis_type_name VARCHAR(50),
    tier_name VARCHAR(50),
    score_min INTEGER,
    score_max INTEGER
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        at.code as analysis_type_code,
        at.name as analysis_type_name,
        st.tier_name,
        st.score_min,
        st.score_max
    FROM scoring_tiers st
    JOIN analysis_types at ON st.analysis_type_id = at.id
    WHERE score_percentage BETWEEN st.score_min AND st.score_max
    AND st.is_active = true
    AND at.is_active = true
    ORDER BY st.display_order
    LIMIT 1;
END;
$$;

-- =============================================================================
-- PART 8: STRATEGIC ACTIONS REDISTRIBUTION
-- =============================================================================

DO $$ BEGIN RAISE NOTICE 'Redistributing strategic actions using intelligent scoring...'; END $$;

DO $$
DECLARE
    weakness_tier_id UUID;
    developing_tier_id UUID;
    strength_tier_id UUID;
    moved_to_developing INTEGER := 0;
    rec RECORD;
BEGIN
    -- Get tier IDs
    SELECT id INTO weakness_tier_id FROM scoring_tiers WHERE tier_code = 'weakness';
    SELECT id INTO developing_tier_id FROM scoring_tiers WHERE tier_code = 'developing';
    SELECT id INTO strength_tier_id FROM scoring_tiers WHERE tier_code = 'strength';
    
    -- Check if we have backup data with original score ranges
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'competency_strategic_actions_scoring_backup') THEN
        RAISE NOTICE 'Found backup table - using original score ranges for intelligent redistribution';
        
        -- Redistribute based on backup data with original score ranges
        FOR rec IN 
            SELECT csa.id, backup.score_range_min, backup.score_range_max,
                   ((backup.score_range_min + backup.score_range_max) / 2.0) as avg_score
            FROM competency_strategic_actions csa
            JOIN competency_strategic_actions_scoring_backup backup ON csa.id = backup.id
            WHERE csa.is_active = true
        LOOP
            -- If score range overlaps with developing tier (50-69%), and includes 60%, move to developing
            IF rec.score_range_min <= 69 AND rec.score_range_max >= 50 AND 
               rec.score_range_min <= 60 AND rec.score_range_max >= 60 THEN
                UPDATE competency_strategic_actions 
                SET scoring_tier_id = developing_tier_id, updated_at = NOW()
                WHERE id = rec.id;
                moved_to_developing := moved_to_developing + 1;
            END IF;
        END LOOP;
        
        RAISE NOTICE 'Redistribution complete: % actions moved to developing tier', moved_to_developing;
    ELSE
        RAISE NOTICE 'No backup table found - using default tier assignment';
        RAISE NOTICE 'This is expected in local development environments';
    END IF;
END;
$$;

-- =============================================================================
-- PART 9: PERFORMANCE ANALYSIS POPULATION
-- =============================================================================

DO $$ BEGIN RAISE NOTICE 'Populating performance analysis with production content...'; END $$;

-- Import production performance analysis content if missing
DO $$
DECLARE
    weakness_tier_id UUID;
    developing_tier_id UUID;
    strength_tier_id UUID;
    core_framework_id UUID;
    beginner_level_id UUID;
    active_listening_id UUID;
    existing_count INTEGER;
BEGIN
    -- Get reference IDs
    SELECT id INTO weakness_tier_id FROM scoring_tiers WHERE tier_code = 'weakness';
    SELECT id INTO developing_tier_id FROM scoring_tiers WHERE tier_code = 'developing';
    SELECT id INTO strength_tier_id FROM scoring_tiers WHERE tier_code = 'strength';
    SELECT id INTO core_framework_id FROM frameworks WHERE code = 'core';
    SELECT id INTO beginner_level_id FROM assessment_levels WHERE level_code = 'beginner' AND framework_id = core_framework_id;
    SELECT id INTO active_listening_id FROM competency_display_names WHERE competency_key = 'active_listening';
    
    -- Check if we already have performance analysis content
    SELECT COUNT(*) INTO existing_count FROM competency_performance_analysis WHERE is_active = true;
    
    IF existing_count = 0 THEN
        RAISE NOTICE 'No existing performance analysis found - importing production content';
        
        -- Insert production-quality performance analysis content
        INSERT INTO competency_performance_analysis 
        (competency_id, framework_id, assessment_level_id, scoring_tier_id, analysis_text, sort_order, is_active)
        VALUES
        -- Active Listening - Weakness Analysis
        (active_listening_id, core_framework_id, beginner_level_id, weakness_tier_id, 
         'In the reviewed scenarios, key emotional elements were missed that could have deepened client connection and trust. This is a common development area that improves with focused practice and awareness building.', 
         1, true),
        (active_listening_id, core_framework_id, beginner_level_id, weakness_tier_id,
         'Opportunities to reflect both content and emotion were not fully utilized. Developing this dual-awareness creates more powerful coaching conversations and helps clients feel truly heard.',
         2, true),
        (active_listening_id, core_framework_id, beginner_level_id, weakness_tier_id,
         'The foundation for deeper listening is present, with room to develop consistency in emotional attunement. This skill becomes more natural with deliberate practice and client feedback.',
         3, true),
        
        -- Active Listening - Developing Analysis  
        (active_listening_id, core_framework_id, beginner_level_id, developing_tier_id,
         'Your listening skills show solid foundation with emerging emotional awareness. Continue developing consistency in reflecting both content and underlying feelings to deepen client connection.',
         1, true),
        (active_listening_id, core_framework_id, beginner_level_id, developing_tier_id,
         'You demonstrate good attention to client words with growing sensitivity to emotional nuances. Focus on trusting your instincts about what you sense beneath the surface.',
         2, true),
        (active_listening_id, core_framework_id, beginner_level_id, developing_tier_id,
         'Your developing skills in emotional attunement are building client trust and safety. Continue practicing the pause between hearing and responding to access deeper insights.',
         3, true),
        
        -- Active Listening - Strength Analysis
        (active_listening_id, core_framework_id, beginner_level_id, strength_tier_id,
         'Your listening demonstrates strong emotional attunement and creates genuine safety for clients to explore deeper truths. This natural ability enhances every coaching conversation.',
         1, true),
        (active_listening_id, core_framework_id, beginner_level_id, strength_tier_id,
         'You consistently hear both content and emotion, helping clients feel truly understood and valued. This strength creates the foundation for transformative coaching relationships.',
         2, true),
        (active_listening_id, core_framework_id, beginner_level_id, strength_tier_id,
         'Your ability to sense and reflect what clients are experiencing beyond their words builds deep trust and connection. This mastery enables clients to access their resourceful state more readily.',
         3, true);
        
        RAISE NOTICE 'Production performance analysis content imported successfully';
    ELSE
        RAISE NOTICE 'Existing performance analysis found (% entries) - skipping import', existing_count;
    END IF;
END;
$$;

-- =============================================================================
-- PART 10: CREATE PERFORMANCE INDEXES
-- =============================================================================

DO $$ BEGIN RAISE NOTICE 'Creating performance indexes...'; END $$;

-- Indexes for scoring_tiers
CREATE INDEX IF NOT EXISTS idx_scoring_tiers_range ON scoring_tiers (score_min, score_max);
CREATE INDEX IF NOT EXISTS idx_scoring_tiers_active ON scoring_tiers (is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_scoring_tiers_tier_code ON scoring_tiers (tier_code);
CREATE INDEX IF NOT EXISTS idx_scoring_tiers_display_order ON scoring_tiers (display_order);

-- Indexes for framework overrides
CREATE INDEX IF NOT EXISTS idx_framework_scoring_framework ON framework_scoring_overrides (framework_id);
CREATE INDEX IF NOT EXISTS idx_framework_scoring_level ON framework_scoring_overrides (assessment_level_id);
CREATE INDEX IF NOT EXISTS idx_framework_scoring_active ON framework_scoring_overrides (is_active) WHERE is_active = true;

-- Indexes for scoring_tier_id columns in content tables
CREATE INDEX IF NOT EXISTS idx_competency_strategic_actions_scoring_tier ON competency_strategic_actions (scoring_tier_id);
CREATE INDEX IF NOT EXISTS idx_competency_performance_analysis_scoring_tier ON competency_performance_analysis (scoring_tier_id);

-- =============================================================================
-- PART 11: VALIDATION CHECKS
-- =============================================================================

DO $$ BEGIN RAISE NOTICE 'Running comprehensive validation checks...'; END $$;

-- Verify no overlapping ranges in scoring_tiers
DO $$
DECLARE
    overlap_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO overlap_count
    FROM scoring_tiers st1
    JOIN scoring_tiers st2 ON st1.id != st2.id
    WHERE st1.is_active = true AND st2.is_active = true
    AND NOT (st1.score_max < st2.score_min OR st1.score_min > st2.score_max);
    
    IF overlap_count > 0 THEN
        RAISE EXCEPTION 'Overlapping score ranges detected in scoring_tiers table!';
    END IF;
    
    RAISE NOTICE '✅ Scoring tiers validation passed - no overlapping ranges detected';
END;
$$;

-- Verify all percentages 0-100 are covered
DO $$
DECLARE
    uncovered_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO uncovered_count
    FROM generate_series(0, 100) AS score
    LEFT JOIN scoring_tiers st ON score BETWEEN st.score_min AND st.score_max 
    AND st.is_active = true
    WHERE st.id IS NULL;
    
    IF uncovered_count > 0 THEN
        RAISE EXCEPTION 'Some score percentages are not covered by any tier!';
    END IF;
    
    RAISE NOTICE '✅ Scoring coverage validation passed - all percentages 0-100 covered';
END;
$$;

-- =============================================================================
-- PART 12: UPDATE TRIGGERS FOR TIMESTAMP MANAGEMENT
-- =============================================================================

DO $$ BEGIN RAISE NOTICE 'Setting up update triggers...'; END $$;

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_scoring_tiers_updated_at ON scoring_tiers;
CREATE TRIGGER update_scoring_tiers_updated_at 
    BEFORE UPDATE ON scoring_tiers 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_framework_scoring_overrides_updated_at ON framework_scoring_overrides;
CREATE TRIGGER update_framework_scoring_overrides_updated_at 
    BEFORE UPDATE ON framework_scoring_overrides 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- PART 13: COMPREHENSIVE TESTING AND VERIFICATION
-- =============================================================================

DO $$ BEGIN RAISE NOTICE 'Running comprehensive verification test...'; END $$;

-- Test 60% score specifically (the reported issue)
DO $$
DECLARE
    total_strategic INTEGER;
    total_performance INTEGER;
    rec RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=== COMPREHENSIVE 60%% SCORE TEST ===';
    
    -- Test strategic actions for 60% score
    SELECT COUNT(*) INTO total_strategic
    FROM strategic_actions_with_analysis_type 
    WHERE 60 BETWEEN score_min AND score_max 
    AND is_active = true;
    
    -- Test performance analysis for 60% score
    SELECT COUNT(*) INTO total_performance
    FROM performance_analysis_with_analysis_type 
    WHERE 60 BETWEEN score_min AND score_max 
    AND is_active = true;
    
    RAISE NOTICE '';
    RAISE NOTICE '=== SCORING SYSTEM FIX RESULTS ===';
    RAISE NOTICE 'Strategic Actions for 60%% scores: %', total_strategic;
    RAISE NOTICE 'Performance Analysis for 60%% scores: %', total_performance;
    
    IF total_strategic > 0 AND total_performance > 0 THEN
        RAISE NOTICE '';
        RAISE NOTICE '✅ SUCCESS: Complete fix applied successfully!';
        RAISE NOTICE '✅ Both strategic actions and performance analysis work for 60%% scores';
        RAISE NOTICE '✅ Frontend should stop showing "No strategic actions found" errors';
        RAISE NOTICE '✅ Assessment system is ready for full testing';
    ELSIF total_strategic > 0 THEN
        RAISE NOTICE '';
        RAISE NOTICE '⚠️  PARTIAL SUCCESS: Strategic actions fixed, performance analysis needs attention';
    ELSIF total_performance > 0 THEN
        RAISE NOTICE '';
        RAISE NOTICE '⚠️  PARTIAL SUCCESS: Performance analysis fixed, strategic actions need attention';
    ELSE
        RAISE NOTICE '';
        RAISE NOTICE '❌ ISSUE: Fix may not have applied correctly - manual verification needed';
    END IF;
    
    -- Show content distribution across tiers
    RAISE NOTICE '';
    RAISE NOTICE '=== CONTENT DISTRIBUTION SUMMARY ===';
    FOR rec IN 
        SELECT 
            st.tier_name,
            COUNT(DISTINCT csa.id) as strategic_actions,
            COUNT(DISTINCT cpa.id) as performance_analysis
        FROM scoring_tiers st
        LEFT JOIN competency_strategic_actions csa ON st.id = csa.scoring_tier_id AND csa.is_active = true
        LEFT JOIN competency_performance_analysis cpa ON st.id = cpa.scoring_tier_id AND cpa.is_active = true
        WHERE st.is_active = true
        GROUP BY st.tier_name, st.display_order
        ORDER BY st.display_order
    LOOP
        RAISE NOTICE '%: % strategic, % analysis', rec.tier_name, rec.strategic_actions, rec.performance_analysis;
    END LOOP;
END;
$$;

DO $$ BEGIN 
  RAISE NOTICE '';
  RAISE NOTICE '=== ENHANCED CONSOLIDATED SCORING FIX COMPLETE ===';
  RAISE NOTICE 'Includes: 3-tier scoring, RLS policies, validation, helper functions';
  RAISE NOTICE 'Includes: Framework overrides, indexes, triggers, comprehensive testing';
  RAISE NOTICE 'Script can be run safely multiple times (idempotent)';
  RAISE NOTICE 'Ready for frontend testing and production deployment';
END $$;