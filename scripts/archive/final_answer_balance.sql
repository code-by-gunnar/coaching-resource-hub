-- ====================================================================
-- FINAL ANSWER DISTRIBUTION BALANCE
-- ====================================================================
-- Target: A=4, B=4, C=4, D=3 (or similar balanced distribution)
-- ====================================================================

-- Move a few more D answers to C to balance better

-- Question 6: Powerful Questions - Change from D (3) to C (2)
-- Swap C and D options
UPDATE assessment_questions SET 
    option_c = 'What''s most important to you in how you spend your working hours?',
    option_d = 'What are the pros and cons of each position?',
    correct_answer = 2,
    explanation = 'Option C helps the client connect with their deeper values about work and life, rather than just analyzing external factors. This values-based exploration often leads to clearer, more aligned decisions.'
WHERE assessment_id = '00000000-0000-0000-0000-000000000001' AND question_order = 6;

-- Question 7: Present Moment - Change from D (3) to C (2)
-- Swap C and D options  
UPDATE assessment_questions SET 
    option_c = 'Gently share your observation and explore it with curiosity: "I notice your shoulders seem tense as you talk about this..."',
    option_d = 'Immediately point out the contradiction between their words and body language',
    correct_answer = 2,
    explanation = 'Option C brings present-moment awareness into the conversation with curiosity rather than judgment. This often reveals important information about how the client really feels versus what they''re saying.'
WHERE assessment_id = '00000000-0000-0000-0000-000000000001' AND question_order = 7;

-- Question 9: Creating Awareness - Change from D (3) to C (2)
-- Swap C and D options
UPDATE assessment_questions SET 
    option_c = 'Share your observation: "I''ve noticed you often say ''I should.'' What do you notice about that?"',
    option_d = 'Tell them to stop using the word "should"',
    correct_answer = 2,
    explanation = 'Option C creates awareness by sharing the observation and inviting the client to explore it themselves. This self-discovery is more powerful than the coach explaining or directing.'
WHERE assessment_id = '00000000-0000-0000-0000-000000000001' AND question_order = 9;

-- Question 11: Direct Communication - Change from D (3) to A (0)
-- Swap A and D options
UPDATE assessment_questions SET 
    option_a = 'Can we pause here? What''s the core issue you''re facing with this colleague?',
    option_d = 'Let them continue until they run out of things to say',
    correct_answer = 0,
    explanation = 'Option A uses direct communication respectfully. It interrupts the circular pattern while maintaining rapport and helping the client identify the real issue beneath the story.'
WHERE assessment_id = '00000000-0000-0000-0000-000000000001' AND question_order = 11;

-- ====================================================================
-- FINAL VERIFICATION
-- ====================================================================

SELECT 'FINAL DISTRIBUTION' as status;
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

SELECT 'Perfect Answer Distribution Achieved!' as status;