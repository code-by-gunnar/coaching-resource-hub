-- Improve Performance Analysis Messages to be More Contextual and Specific
-- Replace generic messages with competency-specific insights

-- ACTIVE LISTENING - Update for more specific, contextual messaging
UPDATE competency_performance_analysis 
SET analysis_text = 'Complete disconnect from Active Listening fundamentals - unable to distinguish between surface content and underlying emotions or needs'
WHERE competency_area = 'Active Listening' AND analysis_type = 'weakness' AND score_range_min = 0 AND score_range_max = 0;

UPDATE competency_performance_analysis 
SET analysis_text = 'Significant Active Listening gaps - frequently missing emotional cues, interrupting clients, or focusing on solutions rather than understanding'
WHERE competency_area = 'Active Listening' AND analysis_type = 'weakness' AND score_range_min = 1 AND score_range_max = 49;

UPDATE competency_performance_analysis 
SET analysis_text = 'Inconsistent Active Listening application - sometimes catches emotional undertones but struggles with deeper listening techniques like reflecting and paraphrasing'
WHERE competency_area = 'Active Listening' AND analysis_type = 'weakness' AND score_range_min = 50 AND score_range_max = 69;

UPDATE competency_performance_analysis 
SET analysis_text = 'Solid Active Listening foundation - demonstrates ability to hear both spoken content and emotional subtext, creating space for client reflection'
WHERE competency_area = 'Active Listening' AND analysis_type = 'strength' AND score_range_min = 70 AND score_range_max = 89;

UPDATE competency_performance_analysis 
SET analysis_text = 'Exceptional Active Listening mastery - consistently demonstrates deep listening that helps clients feel fully heard and understood, leading to breakthrough insights'
WHERE competency_area = 'Active Listening' AND analysis_type = 'strength' AND score_range_min = 90 AND score_range_max = 100;

-- POWERFUL QUESTIONS - Update for more specific, contextual messaging
UPDATE competency_performance_analysis 
SET analysis_text = 'Major gaps in questioning technique - relying heavily on closed questions, leading questions, or advice disguised as questions'
WHERE competency_area = 'Powerful Questions' AND analysis_type = 'weakness' AND score_range_min = 0 AND score_range_max = 0;

UPDATE competency_performance_analysis 
SET analysis_text = 'Limited questioning repertoire - predominantly using basic "what" and "how" questions without exploring deeper layers of client thinking and feeling'
WHERE competency_area = 'Powerful Questions' AND analysis_type = 'weakness' AND score_range_min = 1 AND score_range_max = 49;

UPDATE competency_performance_analysis 
SET analysis_text = 'Developing questioning skills but inconsistent application - sometimes asks powerful questions but often reverts to surface-level or directive inquiries'
WHERE competency_area = 'Powerful Questions' AND analysis_type = 'weakness' AND score_range_min = 50 AND score_range_max = 69;

UPDATE competency_performance_analysis 
SET analysis_text = 'Strong questioning foundation - regularly crafts open-ended questions that invite client exploration and self-discovery rather than seeking specific answers'
WHERE competency_area = 'Powerful Questions' AND analysis_type = 'strength' AND score_range_min = 70 AND score_range_max = 89;

UPDATE competency_performance_analysis 
SET analysis_text = 'Exceptional questioning mastery - consistently creates breakthrough questions that challenge assumptions, explore new perspectives, and catalyze client insights'
WHERE competency_area = 'Powerful Questions' AND analysis_type = 'strength' AND score_range_min = 90 AND score_range_max = 100;

-- PRESENT MOMENT AWARENESS - Update for more specific, contextual messaging
UPDATE competency_performance_analysis 
SET analysis_text = 'Limited present moment awareness - missing obvious shifts in client energy, body language, tone of voice, and emotional state during conversations'
WHERE competency_area = 'Present Moment Awareness' AND analysis_type = 'weakness' AND score_range_min = 0 AND score_range_max = 0;

UPDATE competency_performance_analysis 
SET analysis_text = 'Minimal awareness of present moment dynamics - occasionally noticing obvious changes but missing subtle cues and failing to use observations effectively'
WHERE competency_area = 'Present Moment Awareness' AND analysis_type = 'weakness' AND score_range_min = 1 AND score_range_max = 49;

UPDATE competency_performance_analysis 
SET analysis_text = 'Developing present moment skills but inconsistent application - sometimes notices client shifts but struggles to articulate observations or use them to deepen conversations'
WHERE competency_area = 'Present Moment Awareness' AND analysis_type = 'weakness' AND score_range_min = 50 AND score_range_max = 69;

UPDATE competency_performance_analysis 
SET analysis_text = 'Strong present moment foundation - regularly notices and skillfully reflects back client energy shifts, emotional changes, and non-verbal communication'
WHERE competency_area = 'Present Moment Awareness' AND analysis_type = 'strength' AND score_range_min = 70 AND score_range_max = 89;

UPDATE competency_performance_analysis 
SET analysis_text = 'Exceptional present moment mastery - demonstrates exquisite attunement to subtle client dynamics and uses real-time observations to create powerful coaching moments'
WHERE competency_area = 'Present Moment Awareness' AND analysis_type = 'strength' AND score_range_min = 90 AND score_range_max = 100;