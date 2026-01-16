-- ====================================================================
-- FIX: CORRECT_ANSWER DATA INTEGRITY ISSUE
-- ====================================================================
-- 
-- Issue: Some questions had correct_answer=0 instead of valid 1-4 values
-- Root Cause: Likely 0-based indexing confusion during data entry/import
-- Impact: PDFs showing "Option 0" and incorrect answer mappings
--
-- FIXES APPLIED:
-- 1. Updated the 3 questions with invalid correct_answer=0
-- 2. Added database constraint to prevent future occurrences
--
-- Date: 2025-08-12
-- Status: ✅ APPLIED TO PRODUCTION
-- Migration: 20250812173111_add_correct_answer_constraint.sql
-- ====================================================================

-- These questions had correct_answer=0 and were fixed manually:

-- Question 1: Active Listening competency
-- "How do you respond to maintain psychological safety while practicing active listening?"
-- Fixed: correct_answer = 1 (Option A: Professional coaching response)
-- ID: 2cfa92c3-057a-49e6-a95f-9bf741b59308

-- Question 2: Powerful Questions competency  
-- "Which question would be MOST powerful in creating new awareness for a client who says 'I always mess things up'?"
-- Fixed: correct_answer = 3 (Option C: Challenges limiting belief)
-- ID: 646897e4-c839-44b1-825c-ee720449e78d

-- Question 3: Powerful Questions competency
-- "How do you use direct communication through powerful questioning to help them find their own answers?"
-- Fixed: correct_answer = 1 (Option A: Self-discovery question)
-- ID: 4f4cdf6d-00c2-4b58-b5aa-199d185e374c

-- ====================================================================
-- APPLIED FIXES (Already executed in production):
-- ====================================================================

-- Fix the 3 questions with invalid data:
UPDATE assessment_questions 
SET correct_answer = 1 
WHERE id = '2cfa92c3-057a-49e6-a95f-9bf741b59308';

UPDATE assessment_questions 
SET correct_answer = 3 
WHERE id = '646897e4-c839-44b1-825c-ee720449e78d';

UPDATE assessment_questions 
SET correct_answer = 1 
WHERE id = '4f4cdf6d-00c2-4b58-b5aa-199d185e374c';

-- Add constraint to prevent future data integrity issues:
ALTER TABLE assessment_questions 
ADD CONSTRAINT check_correct_answer_range 
CHECK (correct_answer >= 1 AND correct_answer <= 4);

-- ====================================================================
-- VERIFICATION QUERIES:
-- ====================================================================

-- Check no questions have correct_answer=0:
-- SELECT COUNT(*) as invalid_questions FROM assessment_questions WHERE correct_answer = 0;
-- Expected result: 0

-- Check constraint exists:
-- SELECT conname, consrc FROM pg_constraint WHERE conname = 'check_correct_answer_range';
-- Expected result: constraint definition

-- Verify the fixed questions:
-- SELECT id, question, correct_answer, competency_area 
-- FROM assessment_questions 
-- WHERE id IN (
--   '2cfa92c3-057a-49e6-a95f-9bf741b59308',
--   '646897e4-c839-44b1-825c-ee720449e78d', 
--   '4f4cdf6d-00c2-4b58-b5aa-199d185e374c'
-- );
-- Expected: correct_answer values should be 1, 3, 1 respectively

-- ====================================================================