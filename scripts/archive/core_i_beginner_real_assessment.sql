-- ====================================================================
-- CORE I BEGINNER - REAL ASSESSMENT QUESTIONS
-- ====================================================================
-- Purpose: Create a real, balanced Core I Beginner assessment
-- Questions: 15 questions covering essential beginner competencies
-- 
-- Distribution:
-- - Active Listening: 3 questions (fundamental skill)
-- - Powerful Questions: 3 questions (core coaching tool)
-- - Present Moment Awareness: 2 questions (foundation)
-- - Creating Awareness: 2 questions (key outcome)
-- - Direct Communication: 2 questions (clarity)
-- - Trust & Safety: 2 questions (relationship foundation)
-- - Managing Progress: 1 question (accountability)
-- ====================================================================

-- Clear any existing questions for Core Beginner (just in case)
DELETE FROM assessment_questions 
WHERE assessment_id = '00000000-0000-0000-0000-000000000001';

-- ====================================================================
-- ACTIVE LISTENING (3 questions)
-- ====================================================================

-- Question 1: Active Listening - Identifying Level
INSERT INTO assessment_questions (
    assessment_id,
    question_order,
    scenario,
    question,
    option_a,
    option_b, 
    option_c,
    option_d,
    correct_answer,
    explanation,
    competency_area
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    1,
    'During a coaching session, your client says: "My manager never listens to me. She always interrupts and tells me what to do. I feel so frustrated and unheard."',
    'What level of listening would be MOST appropriate to use in this moment?',
    'Level 1: Focus on how this situation relates to your own experiences with difficult managers',
    'Level 2: Focus entirely on the client''s words, emotions, and experience',
    'Level 3: Focus on the energy in the room and what''s not being said',
    'Switch between all three levels rapidly to gather maximum information',
    2,
    'Level 2 (Focused Listening) is most appropriate here. The client is sharing vulnerable feelings and needs to be heard. Level 2 keeps your attention entirely on the client''s experience without bringing in your own agenda or jumping too quickly to intuitive insights.',
    'Active Listening'
);

-- Question 2: Active Listening - Reflecting Back
INSERT INTO assessment_questions (
    assessment_id,
    question_order,
    scenario,
    question,
    option_a,
    option_b,
    option_c,
    option_d,
    correct_answer,
    explanation,
    competency_area
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    2,
    'Your client shares: "I want to start my own business, but I''m terrified of failing. My family thinks I''m crazy to leave a stable job."',
    'Which response best demonstrates active listening through reflecting?',
    '"You should follow your dreams regardless of what your family thinks"',
    '"It sounds like you''re feeling torn between your entrepreneurial aspirations and concerns about security and family approval"',
    '"Have you considered starting the business as a side project first?"',
    '"Tell me more about your business idea"',
    2,
    'Option B reflects both the content (business vs job) and the emotions (torn, concerned) without adding interpretation or advice. This shows the client you truly heard both what they said and how they feel.',
    'Active Listening'
);

-- Question 3: Active Listening - Silence
INSERT INTO assessment_questions (
    assessment_id,
    question_order,
    scenario,
    question,
    option_a,
    option_b,
    option_c,
    option_d,
    correct_answer,
    explanation,
    competency_area
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    3,
    'Your client has just shared something deeply personal and becomes quiet, looking down with tears in their eyes.',
    'As a coach practicing active listening, what is the BEST response?',
    'Immediately ask "How does that make you feel?" to keep them talking',
    'Share a similar experience you''ve had to show empathy',
    'Allow the silence, maintaining gentle presence and eye contact',
    'Suggest taking a quick break to compose themselves',
    3,
    'Silence is a powerful part of active listening. By maintaining gentle presence without rushing to fill the space, you allow the client to process their emotions and often leads to deeper insights.',
    'Active Listening'
);

-- ====================================================================
-- POWERFUL QUESTIONS (3 questions)
-- ====================================================================

-- Question 4: Powerful Questions - Open vs Closed
INSERT INTO assessment_questions (
    assessment_id,
    question_order,
    scenario,
    question,
    option_a,
    option_b,
    option_c,
    option_d,
    correct_answer,
    explanation,
    competency_area
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    4,
    'Your client is exploring career options and seems stuck.',
    'Which question would be MOST powerful in creating new awareness?',
    '"Have you updated your resume?"',
    '"What would be possible if you knew you couldn''t fail?"',
    '"Do you want to stay in the same industry?"',
    '"Is salary the most important factor for you?"',
    2,
    'Option B is an open, expansive question that invites the client to think beyond their current limitations and explore new possibilities. It creates space for insight rather than gathering simple information.',
    'Powerful Questions'
);

-- Question 5: Powerful Questions - Going Deeper
INSERT INTO assessment_questions (
    assessment_id,
    question_order,
    scenario,
    question,
    option_a,
    option_b,
    option_c,
    option_d,
    correct_answer,
    explanation,
    competency_area
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    5,
    'Your client says: "I just want to be successful."',
    'Which follow-up question would best help the client gain clarity?',
    '"What specific goals do you have for this year?"',
    '"What does success look like for you?"',
    '"Why haven''t you been successful so far?"',
    '"Are you willing to work hard for success?"',
    2,
    'Option B invites the client to define success in their own terms, moving from a vague concept to personal meaning. This helps uncover their values and specific vision rather than assuming what success means.',
    'Powerful Questions'
);

-- Question 6: Powerful Questions - Values Exploration
INSERT INTO assessment_questions (
    assessment_id,
    question_order,
    scenario,
    question,
    option_a,
    option_b,
    option_c,
    option_d,
    correct_answer,
    explanation,
    competency_area
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    6,
    'A client is struggling to make a decision between two job offers.',
    'Which question would best help them connect with their values?',
    '"Which job pays more?"',
    '"What are the pros and cons of each position?"',
    '"What''s most important to you in how you spend your working hours?"',
    '"What would your family prefer you to do?"',
    3,
    'Option C helps the client connect with their deeper values about work and life, rather than just analyzing external factors. This values-based exploration often leads to clearer, more aligned decisions.',
    'Powerful Questions'
);

-- ====================================================================
-- PRESENT MOMENT AWARENESS (2 questions)
-- ====================================================================

-- Question 7: Present Moment - Noticing
INSERT INTO assessment_questions (
    assessment_id,
    question_order,
    scenario,
    question,
    option_a,
    option_b,
    option_c,
    option_d,
    correct_answer,
    explanation,
    competency_area
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    7,
    'While your client is speaking enthusiastically about their goals, you notice their shoulders are hunched and their breathing is shallow.',
    'How should you use this present-moment observation?',
    'Ignore it and focus only on their words',
    'Immediately point out the contradiction between their words and body language',
    'Gently share your observation and explore it with curiosity: "I notice your shoulders seem tense as you talk about this..."',
    'Make a mental note to discuss stress management at the end of the session',
    3,
    'Option C brings present-moment awareness into the conversation with curiosity rather than judgment. This often reveals important information about how the client really feels versus what they''re saying.',
    'Present Moment Awareness'
);

-- Question 8: Present Moment - Energy Shifts
INSERT INTO assessment_questions (
    assessment_id,
    question_order,
    scenario,
    question,
    option_a,
    option_b,
    option_c,
    option_d,
    correct_answer,
    explanation,
    competency_area
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    8,
    'During the session, you notice a sudden shift in energy when your client mentions their father.',
    'What is the MOST appropriate coaching response?',
    'Continue with the planned session agenda',
    'Immediately ask "What''s your relationship like with your father?"',
    'Share what you noticed: "Something shifted when you mentioned your father. What came up for you?"',
    'Make an assumption: "You seem to have father issues we should work on"',
    3,
    'Option C acknowledges the present-moment shift without making assumptions. It invites the client to explore what''s happening for them right now, which often leads to significant insights.',
    'Present Moment Awareness'
);

-- ====================================================================
-- CREATING AWARENESS (2 questions)
-- ====================================================================

-- Question 9: Creating Awareness - Patterns
INSERT INTO assessment_questions (
    assessment_id,
    question_order,
    scenario,
    question,
    option_a,
    option_b,
    option_c,
    option_d,
    correct_answer,
    explanation,
    competency_area
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    9,
    'Over several sessions, you notice your client frequently says "I should" when discussing their goals.',
    'How would you best help create awareness about this pattern?',
    'Tell them to stop using the word "should"',
    'Ignore it as it''s just their way of speaking',
    'Share your observation: "I''ve noticed you often say ''I should.'' What do you notice about that?"',
    'Explain why "should" statements are psychologically harmful',
    3,
    'Option C creates awareness by sharing the observation and inviting the client to explore it themselves. This self-discovery is more powerful than the coach explaining or directing.',
    'Creating Awareness'
);

-- Question 10: Creating Awareness - Blind Spots
INSERT INTO assessment_questions (
    assessment_id,
    question_order,
    scenario,
    question,
    option_a,
    option_b,
    option_c,
    option_d,
    correct_answer,
    explanation,
    competency_area
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    10,
    'Your client consistently describes themselves as "not a leader" but shares many examples of leading others successfully.',
    'What''s the best approach to create awareness of this blind spot?',
    'Tell them directly: "You''re wrong, you are clearly a leader"',
    'Stay quiet and let them figure it out on their own eventually',
    'Reflect back what you hear: "I''m hearing you say you''re not a leader, and I''m also hearing these examples... What do you make of that?"',
    'Give them a leadership assessment test to prove they''re a leader',
    3,
    'Option C creates awareness by presenting the contradiction without judgment, allowing the client to discover the insight themselves. This is more impactful than the coach providing the answer.',
    'Creating Awareness'
);

-- ====================================================================
-- DIRECT COMMUNICATION (2 questions)
-- ====================================================================

-- Question 11: Direct Communication - Bottom-lining
INSERT INTO assessment_questions (
    assessment_id,
    question_order,
    scenario,
    question,
    option_a,
    option_b,
    option_c,
    option_d,
    correct_answer,
    explanation,
    competency_area
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    11,
    'Your client has been talking in circles for 10 minutes about a conflict with a colleague.',
    'How do you use direct communication to help them focus?',
    'Let them continue until they run out of things to say',
    'Interrupt and say: "You''re rambling. Get to the point."',
    '"Can we pause here? What''s the core issue you''re facing with this colleague?"',
    'Change the subject to something more productive',
    3,
    'Option C uses direct communication respectfully. It interrupts the circular pattern while maintaining rapport and helping the client identify the real issue beneath the story.',
    'Direct Communication'
);

-- Question 12: Direct Communication - Challenging
INSERT INTO assessment_questions (
    assessment_id,
    question_order,
    scenario,
    question,
    option_a,
    option_b,
    option_c,
    option_d,
    correct_answer,
    explanation,
    competency_area
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    12,
    'Your client has cancelled three sessions last minute and now says they''re "totally committed" to their goals.',
    'How do you address this directly while maintaining the coaching relationship?',
    'Ignore the cancellations and take them at their word',
    'Terminate the coaching relationship immediately',
    '"I hear you''re committed, and I''ve noticed three cancelled sessions. Help me understand what''s going on."',
    'Lecture them about the importance of consistency',
    3,
    'Option C addresses the discrepancy directly but with curiosity rather than judgment. This opens dialogue about what''s really happening while maintaining trust.',
    'Direct Communication'
);

-- ====================================================================
-- TRUST & SAFETY (2 questions)
-- ====================================================================

-- Question 13: Trust & Safety - Confidentiality
INSERT INTO assessment_questions (
    assessment_id,
    question_order,
    scenario,
    question,
    option_a,
    option_b,
    option_c,
    option_d,
    correct_answer,
    explanation,
    competency_area
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    13,
    'A new client asks: "If I tell you something personal, will you share it with my manager who''s paying for this coaching?"',
    'What''s the most appropriate response to build trust?',
    '"Of course not, everything is confidential"',
    '"I''ll have to share anything work-related with your manager"',
    '"Let''s clarify the confidentiality agreement - typically everything you share stays between us unless you give permission or there''s risk of harm"',
    '"Why don''t you ask your manager what they expect me to share?"',
    3,
    'Option C directly addresses confidentiality while being transparent about standard exceptions. This clarity builds trust from the beginning of the relationship.',
    'Trust & Safety'
);

-- Question 14: Trust & Safety - Vulnerability
INSERT INTO assessment_questions (
    assessment_id,
    question_order,
    scenario,
    question,
    option_a,
    option_b,
    option_c,
    option_d,
    correct_answer,
    explanation,
    competency_area
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    14,
    'Your client becomes emotional and says: "I''m sorry for crying. This is so unprofessional."',
    'How do you respond to maintain psychological safety?',
    '"You''re right, let''s try to stay focused on solutions"',
    '"Don''t worry, everyone cries in coaching"',
    '"Your emotions are welcome here. This is your space to be fully yourself"',
    'Quickly change the topic to something less emotional',
    3,
    'Option C validates their emotions and reinforces that the coaching space is safe for all their experiences. This builds trust and allows for deeper work.',
    'Trust & Safety'
);

-- ====================================================================
-- MANAGING PROGRESS (1 question)
-- ====================================================================

-- Question 15: Managing Progress - Accountability
INSERT INTO assessment_questions (
    assessment_id,
    question_order,
    scenario,
    question,
    option_a,
    option_b,
    option_c,
    option_d,
    correct_answer,
    explanation,
    competency_area
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    15,
    'Your client didn''t complete the action they committed to last session.',
    'What''s the most effective coaching approach?',
    'Express disappointment and stress the importance of follow-through',
    'Ignore it and move on to avoid making them feel bad',
    'Explore with curiosity: "What got in the way?" and "What would support you in moving forward?"',
    'Assign an easier action this time',
    3,
    'Option C maintains accountability while exploring obstacles without judgment. This helps identify real barriers and co-create more effective strategies.',
    'Managing Progress'
);

-- ====================================================================
-- SUMMARY
-- ====================================================================
SELECT 
    'Core I Beginner Assessment Created' as status,
    COUNT(*) as total_questions,
    COUNT(DISTINCT competency_area) as competencies_covered
FROM assessment_questions 
WHERE assessment_id = '00000000-0000-0000-0000-000000000001';

SELECT 
    competency_area,
    COUNT(*) as question_count
FROM assessment_questions 
WHERE assessment_id = '00000000-0000-0000-0000-000000000001'
GROUP BY competency_area
ORDER BY question_count DESC;