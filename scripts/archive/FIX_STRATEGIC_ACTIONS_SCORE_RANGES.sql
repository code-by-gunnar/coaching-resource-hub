-- Fix Strategic Actions Score Ranges
-- Problem: Currently high performers get more actions than low performers (backwards)
-- Solution: Restructure ranges so low performers get more foundational guidance

-- First, let's see current data structure
-- SELECT competency_area, action_text, score_range_min, score_range_max, sort_order 
-- FROM competency_strategic_actions 
-- WHERE framework = 'core' AND difficulty_level = 'beginner' AND is_active = true
-- ORDER BY competency_area, score_range_min, sort_order;

-- ACTIVE LISTENING: Restructure ranges for logical progression
-- Low performers (0-40%): Need ALL foundational actions
-- Mid performers (40-70%): Need most actions but can skip basic ones  
-- High performers (70-100%): Need only advanced refinement actions

-- Update Active Listening actions with logical score ranges
UPDATE competency_strategic_actions 
SET score_range_min = 0, score_range_max = 40,
    sort_order = 1, priority_order = 1
WHERE competency_area = 'Active Listening' 
  AND action_text = 'Practice Level 2 listening exercises daily - focus entirely on the speaker without preparing your response'
  AND framework = 'core' AND difficulty_level = 'beginner';

UPDATE competency_strategic_actions 
SET score_range_min = 0, score_range_max = 50,
    sort_order = 2, priority_order = 2  
WHERE competency_area = 'Active Listening'
  AND action_text = 'Record yourself in practice sessions and identify moments when your attention wandered'
  AND framework = 'core' AND difficulty_level = 'beginner';

UPDATE competency_strategic_actions 
SET score_range_min = 20, score_range_max = 70,
    sort_order = 3, priority_order = 3
WHERE competency_area = 'Active Listening'
  AND action_text = 'Practice mirror exercises: reflect back exact words client uses for emotions before exploring deeper'
  AND framework = 'core' AND difficulty_level = 'beginner';

UPDATE competency_strategic_actions 
SET score_range_min = 50, score_range_max = 100,
    sort_order = 4, priority_order = 4
WHERE competency_area = 'Active Listening'
  AND action_text = 'Use body language check-ins: "I notice tension in your shoulders as you talk about this..."'
  AND framework = 'core' AND difficulty_level = 'beginner';

-- POWERFUL QUESTIONS: Restructure ranges for logical progression  
UPDATE competency_strategic_actions 
SET score_range_min = 0, score_range_max = 40,
    sort_order = 1, priority_order = 1
WHERE competency_area = 'Powerful Questions'
  AND action_text = 'Study the difference between open and closed questions - practice converting closed questions to open ones'
  AND framework = 'core' AND difficulty_level = 'beginner';

UPDATE competency_strategic_actions 
SET score_range_min = 0, score_range_max = 50,
    sort_order = 2, priority_order = 2
WHERE competency_area = 'Powerful Questions'
  AND action_text = 'Practice question stems: "What would it look like if..." and "How might you..."'
  AND framework = 'core' AND difficulty_level = 'beginner';

UPDATE competency_strategic_actions 
SET score_range_min = 20, score_range_max = 70,
    sort_order = 3, priority_order = 3
WHERE competency_area = 'Powerful Questions'
  AND action_text = 'Create a question bank organized by purpose: clarifying, exploring, challenging, visioning'
  AND framework = 'core' AND difficulty_level = 'beginner';

UPDATE competency_strategic_actions 
SET score_range_min = 50, score_range_max = 100,
    sort_order = 4, priority_order = 4
WHERE competency_area = 'Powerful Questions'
  AND action_text = 'Create challenge questions: "What would someone who disagrees with you say about this?"'
  AND framework = 'core' AND difficulty_level = 'beginner';

-- Add similar fixes for other competency areas if they exist
-- Check Present Moment Awareness actions
-- SELECT competency_area, action_text, score_range_min, score_range_max, sort_order 
-- FROM competency_strategic_actions 
-- WHERE competency_area = 'Present Moment Awareness' AND framework = 'core' AND difficulty_level = 'beginner' AND is_active = true
-- ORDER BY score_range_min, sort_order;

-- PRESENT MOMENT AWARENESS: Apply same logical structure
UPDATE competency_strategic_actions 
SET score_range_min = 0, score_range_max = 40,
    sort_order = 1, priority_order = 1
WHERE competency_area = 'Present Moment Awareness'
  AND score_range_min = 0 AND score_range_max = 60
  AND framework = 'core' AND difficulty_level = 'beginner';

UPDATE competency_strategic_actions 
SET score_range_min = 0, score_range_max = 50,
    sort_order = 2, priority_order = 2
WHERE competency_area = 'Present Moment Awareness'
  AND score_range_min = 10 AND score_range_max = 70
  AND framework = 'core' AND difficulty_level = 'beginner';

UPDATE competency_strategic_actions 
SET score_range_min = 20, score_range_max = 70,
    sort_order = 3, priority_order = 3
WHERE competency_area = 'Present Moment Awareness'
  AND score_range_min = 30 AND score_range_max = 70
  AND framework = 'core' AND difficulty_level = 'beginner';

UPDATE competency_strategic_actions 
SET score_range_min = 50, score_range_max = 100,
    sort_order = 4, priority_order = 4
WHERE competency_area = 'Present Moment Awareness'
  AND score_range_min = 40 AND score_range_max = 80
  AND framework = 'core' AND difficulty_level = 'beginner';

-- Verify the changes
-- SELECT competency_area, action_text, score_range_min, score_range_max, sort_order 
-- FROM competency_strategic_actions 
-- WHERE framework = 'core' AND difficulty_level = 'beginner' AND is_active = true
-- ORDER BY competency_area, score_range_min, sort_order;

-- Expected result after fix:
-- 0% performance: Gets 2 foundational actions (ranges 0-40, 0-50)
-- 25% performance: Gets 2 foundational actions (ranges 0-40, 0-50)  
-- 45% performance: Gets 3 actions (ranges 0-50, 20-70)
-- 65% performance: Gets 2 actions (ranges 20-70, 50-100)
-- 85% performance: Gets 1 advanced action (range 50-100)