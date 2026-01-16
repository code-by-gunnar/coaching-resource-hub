-- REDESIGN PERFORMANCE ANALYSIS MESSAGING
-- New Hierarchy: Performance Analysis = Pure Assessment (not actions)
-- Strategic Actions = Immediate next steps (this week/month)
-- Skills to Practice = Long-term development (ongoing)

-- ACTIVE LISTENING - Pure assessment messaging (no action guidance)
UPDATE competency_performance_analysis 
SET analysis_text = 'Your Active Listening performance shows complete disconnection from the fundamentals - you are not distinguishing between content and emotional layers in client communication.'
WHERE competency_area = 'Active Listening' AND analysis_type = 'weakness' AND score_range_min = 0 AND score_range_max = 0;

UPDATE competency_performance_analysis 
SET analysis_text = 'Your Active Listening has significant gaps - you frequently miss emotional cues and interrupt clients rather than creating space for full expression.'
WHERE competency_area = 'Active Listening' AND analysis_type = 'weakness' AND score_range_min = 1 AND score_range_max = 49;

UPDATE competency_performance_analysis 
SET analysis_text = 'Your Active Listening is inconsistent - you sometimes catch emotional undertones but struggle with advanced techniques like accurate reflecting and paraphrasing.'
WHERE competency_area = 'Active Listening' AND analysis_type = 'weakness' AND score_range_min = 50 AND score_range_max = 69;

UPDATE competency_performance_analysis 
SET analysis_text = 'Your Active Listening demonstrates solid competency - you can hear both content and emotional subtext, creating appropriate space for client exploration.'
WHERE competency_area = 'Active Listening' AND analysis_type = 'strength' AND score_range_min = 70 AND score_range_max = 89;

UPDATE competency_performance_analysis 
SET analysis_text = 'Your Active Listening shows exceptional mastery - you consistently demonstrate deep listening that helps clients feel fully understood and creates breakthrough insights.'
WHERE competency_area = 'Active Listening' AND analysis_type = 'strength' AND score_range_min = 90 AND score_range_max = 100;

-- POWERFUL QUESTIONS - Pure assessment messaging
UPDATE competency_performance_analysis 
SET analysis_text = 'Your questioning technique shows major fundamental gaps - you rely heavily on closed questions and advice disguised as questions.'
WHERE competency_area = 'Powerful Questions' AND analysis_type = 'weakness' AND score_range_min = 0 AND score_range_max = 0;

UPDATE competency_performance_analysis 
SET analysis_text = 'Your questioning repertoire is limited - you predominantly use basic surface-level questions without exploring deeper layers of client thinking.'
WHERE competency_area = 'Powerful Questions' AND analysis_type = 'weakness' AND score_range_min = 1 AND score_range_max = 49;

UPDATE competency_performance_analysis 
SET analysis_text = 'Your questioning skills show inconsistent application - you sometimes ask powerful questions but often revert to surface-level or directive inquiries.'
WHERE competency_area = 'Powerful Questions' AND analysis_type = 'weakness' AND score_range_min = 50 AND score_range_max = 69;

UPDATE competency_performance_analysis 
SET analysis_text = 'Your questioning demonstrates strong foundation - you regularly craft open-ended questions that invite genuine client exploration and self-discovery.'
WHERE competency_area = 'Powerful Questions' AND analysis_type = 'strength' AND score_range_min = 70 AND score_range_max = 89;

UPDATE competency_performance_analysis 
SET analysis_text = 'Your questioning shows exceptional mastery - you consistently create breakthrough questions that challenge assumptions and catalyze profound client insights.'
WHERE competency_area = 'Powerful Questions' AND analysis_type = 'strength' AND score_range_min = 90 AND score_range_max = 100;

-- PRESENT MOMENT AWARENESS - Pure assessment messaging  
UPDATE competency_performance_analysis 
SET analysis_text = 'Your present moment awareness shows critical limitations - you miss obvious shifts in client energy, body language, and emotional state during sessions.'
WHERE competency_area = 'Present Moment Awareness' AND analysis_type = 'weakness' AND score_range_min = 0 AND score_range_max = 0;

UPDATE competency_performance_analysis 
SET analysis_text = 'Your present moment awareness is minimal - you occasionally notice obvious changes but miss subtle cues and fail to use observations effectively.'
WHERE competency_area = 'Present Moment Awareness' AND analysis_type = 'weakness' AND score_range_min = 1 AND score_range_max = 49;

UPDATE competency_performance_analysis 
SET analysis_text = 'Your present moment awareness shows inconsistent development - you sometimes notice client shifts but struggle to articulate observations meaningfully.'
WHERE competency_area = 'Present Moment Awareness' AND analysis_type = 'weakness' AND score_range_min = 50 AND score_range_max = 69;

UPDATE competency_performance_analysis 
SET analysis_text = 'Your present moment awareness demonstrates strong foundation - you regularly notice and skillfully reflect client energy shifts and emotional changes.'
WHERE competency_area = 'Present Moment Awareness' AND analysis_type = 'strength' AND score_range_min = 70 AND score_range_max = 89;

UPDATE competency_performance_analysis 
SET analysis_text = 'Your present moment awareness shows exceptional mastery - you demonstrate exquisite attunement to subtle client dynamics and use observations powerfully.'
WHERE competency_area = 'Present Moment Awareness' AND analysis_type = 'strength' AND score_range_min = 90 AND score_range_max = 100;