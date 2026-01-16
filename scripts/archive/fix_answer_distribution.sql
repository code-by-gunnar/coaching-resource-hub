-- ====================================================================
-- FIX ANSWER DISTRIBUTION FOR CORE I BEGINNER ASSESSMENT
-- ====================================================================
-- Purpose: Redistribute correct answers evenly across A, B, C, D
-- Target: Approximately 3-4 questions for each answer choice
-- ====================================================================

-- Check current distribution
SELECT 'CURRENT DISTRIBUTION' as status;
SELECT 
    CASE correct_answer 
        WHEN 0 THEN 'A' 
        WHEN 1 THEN 'B' 
        WHEN 2 THEN 'C' 
        WHEN 3 THEN 'D' 
    END as answer_choice,
    correct_answer,
    COUNT(*) as count
FROM assessment_questions 
WHERE assessment_id = '00000000-0000-0000-0000-000000000001' 
GROUP BY correct_answer 
ORDER BY correct_answer;

-- ====================================================================
-- REDISTRIBUTE ANSWERS
-- ====================================================================

-- Question 1: Active Listening - Change from C (2) to A (0)
-- Swap A and C options
UPDATE assessment_questions SET 
    option_a = 'Level 2: Focus entirely on the client''s words, emotions, and experience',
    option_c = 'Level 1: Focus on how this situation relates to your own experiences with difficult managers',
    correct_answer = 0,
    explanation = 'Level 2 (Focused Listening) is most appropriate here. The client is sharing vulnerable feelings and needs to be heard. Level 2 keeps your attention entirely on the client''s experience without bringing in your own agenda or jumping too quickly to intuitive insights.'
WHERE assessment_id = '00000000-0000-0000-0000-000000000001' AND question_order = 1;

-- Question 2: Active Listening - Change from C (2) to B (1) 
-- Swap B and C options
UPDATE assessment_questions SET 
    option_b = 'It sounds like you''re feeling torn between your entrepreneurial aspirations and concerns about security and family approval',
    option_c = 'You should follow your dreams regardless of what your family thinks',
    correct_answer = 1,
    explanation = 'Option B reflects both the content (business vs job) and the emotions (torn, concerned) without adding interpretation or advice. This shows the client you truly heard both what they said and how they feel.'
WHERE assessment_id = '00000000-0000-0000-0000-000000000001' AND question_order = 2;

-- Question 3: Active Listening - Keep as D (3)
-- Already D, keep as is

-- Question 4: Powerful Questions - Change from C (2) to A (0)
-- Swap A and C options  
UPDATE assessment_questions SET 
    option_a = 'What would be possible if you knew you couldn''t fail?',
    option_c = 'Have you updated your resume?',
    correct_answer = 0,
    explanation = 'Option A is an open, expansive question that invites the client to think beyond their current limitations and explore new possibilities. It creates space for insight rather than gathering simple information.'
WHERE assessment_id = '00000000-0000-0000-0000-000000000001' AND question_order = 4;

-- Question 5: Powerful Questions - Change from C (2) to B (1)
-- Swap B and C options
UPDATE assessment_questions SET 
    option_b = 'What does success look like for you?',
    option_c = 'What specific goals do you have for this year?',
    correct_answer = 1,
    explanation = 'Option B invites the client to define success in their own terms, moving from a vague concept to personal meaning. This helps uncover their values and specific vision rather than assuming what success means.'
WHERE assessment_id = '00000000-0000-0000-0000-000000000001' AND question_order = 5;

-- Question 6: Powerful Questions - Keep as D (3)
-- Already D, keep as is

-- Question 7: Present Moment - Keep as D (3) 
-- Already D, keep as is

-- Question 8: Present Moment - Keep as D (3)
-- Already D, keep as is

-- Question 9: Creating Awareness - Keep as D (3)
-- Already D, keep as is

-- Question 10: Creating Awareness - Keep as D (3)
-- Already D, keep as is

-- Question 11: Direct Communication - Keep as D (3)
-- Already D, keep as is

-- Question 12: Direct Communication - Keep as D (3)
-- Already D, keep as is

-- Question 13: Trust & Safety - Change from D (3) to C (2)
-- Swap C and D options
UPDATE assessment_questions SET 
    option_c = 'Let''s clarify the confidentiality agreement - typically everything you share stays between us unless you give permission or there''s risk of harm',
    option_d = 'Why don''t you ask your manager what they expect me to share?',
    correct_answer = 2,
    explanation = 'Option C directly addresses confidentiality while being transparent about standard exceptions. This clarity builds trust from the beginning of the relationship.'
WHERE assessment_id = '00000000-0000-0000-0000-000000000001' AND question_order = 13;

-- Question 14: Trust & Safety - Change from D (3) to A (0)
-- Swap A and D options
UPDATE assessment_questions SET 
    option_a = 'Your emotions are welcome here. This is your space to be fully yourself',
    option_d = 'You''re right, let''s try to stay focused on solutions',
    correct_answer = 0,
    explanation = 'Option A validates their emotions and reinforces that the coaching space is safe for all their experiences. This builds trust and allows for deeper work.'
WHERE assessment_id = '00000000-0000-0000-0000-000000000001' AND question_order = 14;

-- Question 15: Managing Progress - Change from D (3) to B (1)
-- Swap B and D options
UPDATE assessment_questions SET 
    option_b = 'Explore with curiosity: "What got in the way?" and "What would support you in moving forward?"',
    option_d = 'Ignore it and move on to avoid making them feel bad',
    correct_answer = 1,
    explanation = 'Option B maintains accountability while exploring obstacles without judgment. This helps identify real barriers and co-create more effective strategies.'
WHERE assessment_id = '00000000-0000-0000-0000-000000000001' AND question_order = 15;

-- ====================================================================
-- VERIFY NEW DISTRIBUTION
-- ====================================================================

SELECT 'NEW DISTRIBUTION' as status;
SELECT 
    CASE correct_answer 
        WHEN 0 THEN 'A' 
        WHEN 1 THEN 'B' 
        WHEN 2 THEN 'C' 
        WHEN 3 THEN 'D' 
    END as answer_choice,
    correct_answer,
    COUNT(*) as count
FROM assessment_questions 
WHERE assessment_id = '00000000-0000-0000-0000-000000000001' 
GROUP BY correct_answer 
ORDER BY correct_answer;

SELECT 'Answer Distribution Fixed' as status;