-- REDESIGN STRATEGIC ACTIONS - IMMEDIATE NEXT STEPS
-- These should be "What to do THIS WEEK/MONTH" not long-term development
-- No overlap with performance analysis (assessment) or skills to practice (long-term)

-- ACTIVE LISTENING - Immediate actions based on performance level
UPDATE competency_strategic_actions 
SET action_text = 'Schedule foundation Active Listening training this week - you need structured learning before client practice'
WHERE competency_area = 'Active Listening' AND score_range_min = 0 AND score_range_max = 40 AND priority_order = 1;

UPDATE competency_strategic_actions 
SET action_text = 'Find an Active Listening mentor or supervisor - arrange weekly practice sessions with immediate feedback'
WHERE competency_area = 'Active Listening' AND score_range_min = 0 AND score_range_max = 50 AND priority_order = 2;

UPDATE competency_strategic_actions 
SET action_text = 'This week: Record 3 practice conversations and identify your specific listening blocks'
WHERE competency_area = 'Active Listening' AND score_range_min = 20 AND score_range_max = 70 AND priority_order = 3;

UPDATE competency_strategic_actions 
SET action_text = 'Next sessions: Focus specifically on emotional reflection - practice mirroring client feelings before exploring content'
WHERE competency_area = 'Active Listening' AND score_range_min = 50 AND score_range_max = 100 AND priority_order = 4;

-- POWERFUL QUESTIONS - Immediate actions  
UPDATE competency_strategic_actions 
SET action_text = 'This week: Create a list of 20 open-ended question starters and practice using only those'
WHERE competency_area = 'Powerful Questions' AND score_range_min = 0 AND score_range_max = 40 AND priority_order = 1;

UPDATE competency_strategic_actions 
SET action_text = 'Before next session: Prepare 5 powerful questions for different client situations'
WHERE competency_area = 'Powerful Questions' AND score_range_min = 0 AND score_range_max = 50 AND priority_order = 3;

UPDATE competency_strategic_actions 
SET action_text = 'Next month: Track your question-to-advice ratio - aim for 80% questions, 20% observations'
WHERE competency_area = 'Powerful Questions' AND score_range_min = 20 AND score_range_max = 70 AND priority_order = 2;

UPDATE competency_strategic_actions 
SET action_text = 'Immediate focus: Replace any "why" questions with "what" or "how" - practice this in your next 3 sessions'
WHERE competency_area = 'Powerful Questions' AND score_range_min = 50 AND score_range_max = 100 AND priority_order = 4;

-- PRESENT MOMENT AWARENESS - Immediate actions
UPDATE competency_strategic_actions 
SET action_text = 'This week: Set phone reminder every 10 minutes to notice your own present moment awareness'
WHERE competency_area = 'Present Moment Awareness' AND score_range_min = 0 AND score_range_max = 40 AND priority_order = 1;

UPDATE competency_strategic_actions 
SET action_text = 'Next session: Practice naming one client energy shift out loud - "I notice you shifted when..."'
WHERE competency_area = 'Present Moment Awareness' AND score_range_min = 0 AND score_range_max = 50 AND priority_order = 3;

UPDATE competency_strategic_actions 
SET action_text = 'This month: Keep a client energy log - track 3 observations per session about shifts you notice'
WHERE competency_area = 'Present Moment Awareness' AND score_range_min = 20 AND score_range_max = 70 AND priority_order = 2;

UPDATE competency_strategic_actions 
SET action_text = 'Immediate practice: Use present tense language in your next session - "What are you experiencing right now?"'
WHERE competency_area = 'Present Moment Awareness' AND score_range_min = 50 AND score_range_max = 100 AND priority_order = 4;