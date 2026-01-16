-- ============================================================================
-- Drop Old Assessment Tables: Phase 1 Cleanup
-- ============================================================================
-- Migration: 20260116_000_drop_old_assessment_tables.sql
-- Purpose: Remove old complex assessment content tables to prepare for AI system
-- Design Doc: .plans/2026-01-16-ai-generated-assessment-reports-design.md
--
-- KEEPS: self_study, workbook_*, learning_logs, temporary_pdf_files
-- DROPS: All assessment content management tables
-- ============================================================================

-- ============================================================================
-- DROP ORDER: Child tables first (respecting FK constraints)
-- ============================================================================

-- User response/attempt tables (depend on assessments)
DROP TABLE IF EXISTS user_question_responses CASCADE;
DROP TABLE IF EXISTS user_assessment_attempts CASCADE;

-- Competency insight/action tables
DROP TABLE IF EXISTS competency_rich_insights CASCADE;
DROP TABLE IF EXISTS competency_consolidated_insights CASCADE;
DROP TABLE IF EXISTS competency_performance_analysis CASCADE;
DROP TABLE IF EXISTS competency_strategic_actions CASCADE;
DROP TABLE IF EXISTS competency_leverage_strengths CASCADE;
DROP TABLE IF EXISTS competency_display_names CASCADE;

-- Tag system
DROP TABLE IF EXISTS tag_actions CASCADE;
DROP TABLE IF EXISTS tag_insights CASCADE;
DROP TABLE IF EXISTS skill_tags CASCADE;

-- Learning resources
DROP TABLE IF EXISTS learning_resource_competencies CASCADE;
DROP TABLE IF EXISTS learning_resources CASCADE;
DROP TABLE IF EXISTS learning_path_categories CASCADE;

-- Assessment structure
DROP TABLE IF EXISTS answer_options CASCADE;
DROP TABLE IF EXISTS assessment_questions CASCADE;
DROP TABLE IF EXISTS assessment_levels CASCADE;
DROP TABLE IF EXISTS assessments CASCADE;

-- Reference/lookup tables
DROP TABLE IF EXISTS framework_scoring_overrides CASCADE;
DROP TABLE IF EXISTS scoring_tiers CASCADE;
DROP TABLE IF EXISTS analysis_types CASCADE;
DROP TABLE IF EXISTS resource_types CASCADE;

-- Framework table (parent of many)
DROP TABLE IF EXISTS frameworks CASCADE;

-- ============================================================================
-- VERIFICATION: Tables that should remain
-- ============================================================================
-- These tables are NOT dropped (workbook & self-study system):
--   - self_study
--   - learning_logs
--   - workbook_progress
--   - workbook_sections
--   - workbook_responses
--   - workbook_field_definitions
--   - temporary_pdf_files
-- ============================================================================

-- ============================================================================
-- Cleanup Complete
-- ============================================================================
-- Next: Run 20260116_001_ai_assessment_schema.sql to create new AI tables
-- ============================================================================
