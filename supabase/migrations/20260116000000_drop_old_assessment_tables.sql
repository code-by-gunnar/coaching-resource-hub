-- ============================================================================
-- Drop Old Assessment Tables: Phase 1 Cleanup
-- ============================================================================
-- Migration: 20260116_000_drop_old_assessment_tables.sql
-- Purpose: Remove old complex assessment content tables to prepare for AI system
-- Design Doc: .plans/2026-01-16-ai-generated-assessment-reports-design.md
--
-- KEEPS (7 tables):
--   - self_study
--   - learning_logs
--   - workbook_progress
--   - workbook_sections
--   - workbook_responses
--   - workbook_field_definitions
--   - temporary_pdf_files
--
-- DROPS (26 tables): All assessment content management tables
-- ============================================================================

-- ============================================================================
-- DROP ORDER: Child tables first (respecting FK constraints)
-- Using CASCADE to handle any remaining FK dependencies
-- ============================================================================

-- ============================================================================
-- LAYER 1: User response/attempt tables (leaf tables, depend on assessments)
-- ============================================================================
DROP TABLE IF EXISTS user_question_responses CASCADE;
DROP TABLE IF EXISTS user_assessment_attempts CASCADE;

-- ============================================================================
-- LAYER 2: Competency insight/action/content tables
-- ============================================================================
DROP TABLE IF EXISTS competency_rich_insights CASCADE;
DROP TABLE IF EXISTS competency_consolidated_insights CASCADE;
DROP TABLE IF EXISTS competency_performance_analysis CASCADE;
DROP TABLE IF EXISTS competency_strategic_actions CASCADE;
DROP TABLE IF EXISTS competency_leverage_strengths CASCADE;

-- ============================================================================
-- LAYER 3: Tag system tables
-- ============================================================================
DROP TABLE IF EXISTS tag_actions CASCADE;
DROP TABLE IF EXISTS tag_insights CASCADE;
DROP TABLE IF EXISTS skill_tags CASCADE;

-- ============================================================================
-- LAYER 4: Learning resource tables
-- ============================================================================
DROP TABLE IF EXISTS learning_resource_competencies CASCADE;
DROP TABLE IF EXISTS learning_resources CASCADE;
DROP TABLE IF EXISTS learning_path_categories CASCADE;

-- ============================================================================
-- LAYER 5: Assessment structure tables
-- ============================================================================
DROP TABLE IF EXISTS assessment_questions CASCADE;
DROP TABLE IF EXISTS assessments CASCADE;

-- ============================================================================
-- LAYER 6: Reference/lookup tables
-- ============================================================================
DROP TABLE IF EXISTS answer_options CASCADE;
DROP TABLE IF EXISTS framework_scoring_overrides CASCADE;
DROP TABLE IF EXISTS scoring_tiers CASCADE;
DROP TABLE IF EXISTS analysis_types CASCADE;
DROP TABLE IF EXISTS resource_types CASCADE;

-- ============================================================================
-- LAYER 7: Core framework tables (parents of many)
-- ============================================================================
DROP TABLE IF EXISTS competency_display_names CASCADE;
DROP TABLE IF EXISTS assessment_levels CASCADE;
DROP TABLE IF EXISTS frameworks CASCADE;

-- ============================================================================
-- VERIFICATION: Tables that MUST remain after this migration
-- ============================================================================
-- Run this query after migration to verify:
--
-- SELECT table_name FROM information_schema.tables
-- WHERE table_schema = 'public'
-- AND table_type = 'BASE TABLE'
-- ORDER BY table_name;
--
-- Expected remaining tables:
--   - learning_logs
--   - self_study
--   - temporary_pdf_files
--   - workbook_field_definitions
--   - workbook_progress
--   - workbook_responses
--   - workbook_sections
-- ============================================================================

-- ============================================================================
-- Cleanup Complete - 26 tables dropped, 7 tables preserved
-- ============================================================================
-- Next: Run 20260116_001_ai_assessment_schema.sql to create new AI tables
-- ============================================================================
