-- ============================================================================
-- AI-Generated Assessment Reports: Phase 1 - Core I Beginner Seed Data
-- ============================================================================
-- Migration: 20260116_002_seed_core_beginner.sql
-- Purpose: Populate Core I Beginner assessment with questions
-- Design Doc: .plans/2026-01-16-ai-generated-assessment-reports-design.md
-- ============================================================================

-- ============================================================================
-- PART 1: Create Core Beginner Assessment Level
-- ============================================================================

INSERT INTO ai_assessment_levels (framework_id, level_code, name, description, question_count, passing_score)
SELECT
    f.id,
    'beginner',
    'Core I - Fundamentals',
    'Foundation coaching skills assessment covering essential competencies for new coaches',
    15,
    70
FROM ai_frameworks f
WHERE f.code = 'core'
ON CONFLICT (framework_id, level_code) DO NOTHING;


-- ============================================================================
-- PART 2: Create Core Competencies
-- ============================================================================

-- Active Listening
INSERT INTO ai_competencies (framework_id, code, name, description, ai_context, sort_order)
SELECT
    f.id,
    'active_listening',
    'Active Listening',
    'The ability to focus completely on what the client is saying and not saying, to understand the meaning of what is said in the context of the client''s desires, and to support client self-expression.',
    'Active Listening includes three levels: Level 1 (internal listening - focused on self), Level 2 (focused listening - entirely on client), and Level 3 (global listening - energy and what''s not said). Beginner coaches often default to Level 1 or rush to fill silence. Key skills include reflecting content and emotion, using silence effectively, and staying present without agenda.',
    1
FROM ai_frameworks f WHERE f.code = 'core'
ON CONFLICT (framework_id, code) DO UPDATE SET
    description = EXCLUDED.description,
    ai_context = EXCLUDED.ai_context;

-- Powerful Questions
INSERT INTO ai_competencies (framework_id, code, name, description, ai_context, sort_order)
SELECT
    f.id,
    'powerful_questions',
    'Powerful Questions',
    'The ability to ask questions that reveal the information needed for maximum benefit to the coaching relationship and the client.',
    'Powerful questions are open-ended, evoke discovery and insight, and move the client toward their goals. They often start with "What" or "How" rather than "Why" (which can feel judgmental) or closed questions that can be answered yes/no. Common beginner mistakes: asking leading questions, multiple questions at once, or questions that serve the coach''s curiosity rather than the client''s growth.',
    2
FROM ai_frameworks f WHERE f.code = 'core'
ON CONFLICT (framework_id, code) DO UPDATE SET
    description = EXCLUDED.description,
    ai_context = EXCLUDED.ai_context;

-- Present Moment Awareness
INSERT INTO ai_competencies (framework_id, code, name, description, ai_context, sort_order)
SELECT
    f.id,
    'present_moment_awareness',
    'Present Moment Awareness',
    'The ability to be fully conscious and present with the client, employing a style that is open, flexible, and confident.',
    'This competency involves noticing body language, energy shifts, tone changes, and what''s happening in the room right now - not getting lost in the story or planning ahead. Coaches share observations with curiosity, not judgment. Beginners often miss non-verbal cues or ignore present-moment data in favor of following an agenda.',
    3
FROM ai_frameworks f WHERE f.code = 'core'
ON CONFLICT (framework_id, code) DO UPDATE SET
    description = EXCLUDED.description,
    ai_context = EXCLUDED.ai_context;

-- Creating Awareness
INSERT INTO ai_competencies (framework_id, code, name, description, ai_context, sort_order)
SELECT
    f.id,
    'creating_awareness',
    'Creating Awareness',
    'The ability to integrate and accurately evaluate multiple sources of information and to make interpretations that help the client gain awareness and thereby achieve agreed-upon results.',
    'Creating awareness involves helping clients see patterns, blind spots, and connections they haven''t noticed. The coach shares observations and invites exploration rather than telling. Self-discovery is more powerful than coach-provided answers. Beginners often want to give the insight directly rather than facilitating the client''s own discovery.',
    4
FROM ai_frameworks f WHERE f.code = 'core'
ON CONFLICT (framework_id, code) DO UPDATE SET
    description = EXCLUDED.description,
    ai_context = EXCLUDED.ai_context;

-- Direct Communication
INSERT INTO ai_competencies (framework_id, code, name, description, ai_context, sort_order)
SELECT
    f.id,
    'direct_communication',
    'Direct Communication',
    'The ability to communicate effectively during coaching sessions, and to use language that has the greatest positive impact on the client.',
    'Direct communication means being clear, articulate, and respectful. It includes bottom-lining (getting to the essence), challenging inconsistencies, and sharing observations without judgment. Beginners may avoid direct communication to be "nice" or may be too blunt without maintaining rapport.',
    5
FROM ai_frameworks f WHERE f.code = 'core'
ON CONFLICT (framework_id, code) DO UPDATE SET
    description = EXCLUDED.description,
    ai_context = EXCLUDED.ai_context;

-- Trust & Safety
INSERT INTO ai_competencies (framework_id, code, name, description, ai_context, sort_order)
SELECT
    f.id,
    'trust_safety',
    'Trust & Safety',
    'The ability to create a safe, supportive environment that produces ongoing mutual respect and trust.',
    'This competency involves establishing clear confidentiality agreements, validating emotions, creating space for vulnerability, and maintaining consistency. Psychological safety allows clients to take risks and explore difficult topics. Beginners may minimize emotions or fail to establish clear boundaries early in the relationship.',
    6
FROM ai_frameworks f WHERE f.code = 'core'
ON CONFLICT (framework_id, code) DO UPDATE SET
    description = EXCLUDED.description,
    ai_context = EXCLUDED.ai_context;

-- Managing Progress
INSERT INTO ai_competencies (framework_id, code, name, description, ai_context, sort_order)
SELECT
    f.id,
    'managing_progress',
    'Managing Progress',
    'The ability to hold attention on what is important for the client, and to leave responsibility with the client to take action.',
    'This involves co-creating accountability structures, following up on commitments, and exploring obstacles with curiosity rather than judgment. The coach holds the client capable while supporting them through challenges. Beginners may either avoid accountability conversations or make the client feel judged when they don''t follow through.',
    7
FROM ai_frameworks f WHERE f.code = 'core'
ON CONFLICT (framework_id, code) DO UPDATE SET
    description = EXCLUDED.description,
    ai_context = EXCLUDED.ai_context;


-- ============================================================================
-- PART 3: Insert Questions
-- ============================================================================

-- Helper: Get IDs we need
DO $$
DECLARE
    v_framework_id UUID;
    v_level_id UUID;
    v_active_listening_id UUID;
    v_powerful_questions_id UUID;
    v_present_moment_id UUID;
    v_creating_awareness_id UUID;
    v_direct_communication_id UUID;
    v_trust_safety_id UUID;
    v_managing_progress_id UUID;
BEGIN
    -- Get framework ID
    SELECT id INTO v_framework_id FROM ai_frameworks WHERE code = 'core';

    -- Get level ID
    SELECT id INTO v_level_id FROM ai_assessment_levels
    WHERE framework_id = v_framework_id AND level_code = 'beginner';

    -- Get competency IDs
    SELECT id INTO v_active_listening_id FROM ai_competencies
    WHERE framework_id = v_framework_id AND code = 'active_listening';

    SELECT id INTO v_powerful_questions_id FROM ai_competencies
    WHERE framework_id = v_framework_id AND code = 'powerful_questions';

    SELECT id INTO v_present_moment_id FROM ai_competencies
    WHERE framework_id = v_framework_id AND code = 'present_moment_awareness';

    SELECT id INTO v_creating_awareness_id FROM ai_competencies
    WHERE framework_id = v_framework_id AND code = 'creating_awareness';

    SELECT id INTO v_direct_communication_id FROM ai_competencies
    WHERE framework_id = v_framework_id AND code = 'direct_communication';

    SELECT id INTO v_trust_safety_id FROM ai_competencies
    WHERE framework_id = v_framework_id AND code = 'trust_safety';

    SELECT id INTO v_managing_progress_id FROM ai_competencies
    WHERE framework_id = v_framework_id AND code = 'managing_progress';

    -- ================================================================
    -- ACTIVE LISTENING (3 questions)
    -- ================================================================

    -- Q1: Active Listening - Identifying Level
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_active_listening_id,
        'During a coaching session, your client says: "My manager never listens to me. She always interrupts and tells me what to do. I feel so frustrated and unheard."',
        'What level of listening would be MOST appropriate to use in this moment?',
        '[
            {"key": "a", "text": "Level 1: Focus on how this situation relates to your own experiences with difficult managers"},
            {"key": "b", "text": "Level 2: Focus entirely on the client''s words, emotions, and experience"},
            {"key": "c", "text": "Level 3: Focus on the energy in the room and what''s not being said"},
            {"key": "d", "text": "Switch between all three levels rapidly to gather maximum information"}
        ]'::jsonb,
        'b',
        'listening_levels',
        'Level 2 (Focused Listening) is most appropriate here. The client is sharing vulnerable feelings and needs to be heard. Level 2 keeps your attention entirely on the client''s experience without bringing in your own agenda or jumping too quickly to intuitive insights.',
        'Common mistake: jumping to Level 3 too soon when the client needs basic Level 2 focused attention first.',
        1
    );

    -- Q2: Active Listening - Reflecting Back
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_active_listening_id,
        'Your client shares: "I want to start my own business, but I''m terrified of failing. My family thinks I''m crazy to leave a stable job."',
        'Which response best demonstrates active listening through reflecting?',
        '[
            {"key": "a", "text": "You should follow your dreams regardless of what your family thinks"},
            {"key": "b", "text": "It sounds like you''re feeling torn between your entrepreneurial aspirations and concerns about security and family approval"},
            {"key": "c", "text": "Have you considered starting the business as a side project first?"},
            {"key": "d", "text": "Tell me more about your business idea"}
        ]'::jsonb,
        'b',
        'reflecting_content_emotion',
        'Option B reflects both the content (business vs job) and the emotions (torn, concerned) without adding interpretation or advice. This shows the client you truly heard both what they said and how they feel.',
        'Options A and C give advice, Option D redirects away from the emotional content the client shared.',
        2
    );

    -- Q3: Active Listening - Silence
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_active_listening_id,
        'Your client has just shared something deeply personal and becomes quiet, looking down with tears in their eyes.',
        'As a coach practicing active listening, what is the BEST response?',
        '[
            {"key": "a", "text": "Immediately ask \"How does that make you feel?\" to keep them talking"},
            {"key": "b", "text": "Share a similar experience you''ve had to show empathy"},
            {"key": "c", "text": "Allow the silence, maintaining gentle presence and eye contact"},
            {"key": "d", "text": "Suggest taking a quick break to compose themselves"}
        ]'::jsonb,
        'c',
        'using_silence',
        'Silence is a powerful part of active listening. By maintaining gentle presence without rushing to fill the space, you allow the client to process their emotions and often leads to deeper insights.',
        'Beginners often feel uncomfortable with silence and rush to fill it. The discomfort is the coach''s, not the client''s.',
        3
    );

    -- ================================================================
    -- POWERFUL QUESTIONS (3 questions)
    -- ================================================================

    -- Q4: Powerful Questions - Open vs Closed
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_powerful_questions_id,
        'Your client is exploring career options and seems stuck.',
        'Which question would be MOST powerful in creating new awareness?',
        '[
            {"key": "a", "text": "Have you updated your resume?"},
            {"key": "b", "text": "What would be possible if you knew you couldn''t fail?"},
            {"key": "c", "text": "Do you want to stay in the same industry?"},
            {"key": "d", "text": "Is salary the most important factor for you?"}
        ]'::jsonb,
        'b',
        'open_expansive_questions',
        'Option B is an open, expansive question that invites the client to think beyond their current limitations and explore new possibilities. It creates space for insight rather than gathering simple information.',
        'Options A, C, D are closed or information-gathering questions that don''t create new awareness.',
        4
    );

    -- Q5: Powerful Questions - Going Deeper
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_powerful_questions_id,
        'Your client says: "I just want to be successful."',
        'Which follow-up question would best help the client gain clarity?',
        '[
            {"key": "a", "text": "What specific goals do you have for this year?"},
            {"key": "b", "text": "What does success look like for you?"},
            {"key": "c", "text": "Why haven''t you been successful so far?"},
            {"key": "d", "text": "Are you willing to work hard for success?"}
        ]'::jsonb,
        'b',
        'defining_vague_terms',
        'Option B invites the client to define success in their own terms, moving from a vague concept to personal meaning. This helps uncover their values and specific vision rather than assuming what success means.',
        'Option C uses "why" which can feel judgmental. Option A and D assume a definition of success.',
        5
    );

    -- Q6: Powerful Questions - Values Exploration
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_powerful_questions_id,
        'A client is struggling to make a decision between two job offers.',
        'Which question would best help them connect with their values?',
        '[
            {"key": "a", "text": "Which job pays more?"},
            {"key": "b", "text": "What are the pros and cons of each position?"},
            {"key": "c", "text": "What''s most important to you in how you spend your working hours?"},
            {"key": "d", "text": "What would your family prefer you to do?"}
        ]'::jsonb,
        'c',
        'values_based_questions',
        'Option C helps the client connect with their deeper values about work and life, rather than just analyzing external factors. This values-based exploration often leads to clearer, more aligned decisions.',
        'Options A, B, D focus on external factors rather than internal values.',
        6
    );

    -- ================================================================
    -- PRESENT MOMENT AWARENESS (2 questions)
    -- ================================================================

    -- Q7: Present Moment - Noticing
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_present_moment_id,
        'While your client is speaking enthusiastically about their goals, you notice their shoulders are hunched and their breathing is shallow.',
        'How should you use this present-moment observation?',
        '[
            {"key": "a", "text": "Ignore it and focus only on their words"},
            {"key": "b", "text": "Immediately point out the contradiction between their words and body language"},
            {"key": "c", "text": "Gently share your observation and explore it with curiosity: \"I notice your shoulders seem tense as you talk about this...\""},
            {"key": "d", "text": "Make a mental note to discuss stress management at the end of the session"}
        ]'::jsonb,
        'c',
        'noticing_body_language',
        'Option C brings present-moment awareness into the conversation with curiosity rather than judgment. This often reveals important information about how the client really feels versus what they''re saying.',
        'Option B is too confrontational. Options A and D miss the present-moment opportunity.',
        7
    );

    -- Q8: Present Moment - Energy Shifts
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_present_moment_id,
        'During the session, you notice a sudden shift in energy when your client mentions their father.',
        'What is the MOST appropriate coaching response?',
        '[
            {"key": "a", "text": "Continue with the planned session agenda"},
            {"key": "b", "text": "Immediately ask \"What''s your relationship like with your father?\""},
            {"key": "c", "text": "Share what you noticed: \"Something shifted when you mentioned your father. What came up for you?\""},
            {"key": "d", "text": "Make an assumption: \"You seem to have father issues we should work on\""}
        ]'::jsonb,
        'c',
        'noticing_energy_shifts',
        'Option C acknowledges the present-moment shift without making assumptions. It invites the client to explore what''s happening for them right now, which often leads to significant insights.',
        'Option D makes assumptions. Option B is too direct without acknowledging what you noticed. Option A ignores present-moment data.',
        8
    );

    -- ================================================================
    -- CREATING AWARENESS (2 questions)
    -- ================================================================

    -- Q9: Creating Awareness - Patterns
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_creating_awareness_id,
        'Over several sessions, you notice your client frequently says "I should" when discussing their goals.',
        'How would you best help create awareness about this pattern?',
        '[
            {"key": "a", "text": "Tell them to stop using the word \"should\""},
            {"key": "b", "text": "Ignore it as it''s just their way of speaking"},
            {"key": "c", "text": "Share your observation: \"I''ve noticed you often say ''I should.'' What do you notice about that?\""},
            {"key": "d", "text": "Explain why \"should\" statements are psychologically harmful"}
        ]'::jsonb,
        'c',
        'pattern_recognition',
        'Option C creates awareness by sharing the observation and inviting the client to explore it themselves. This self-discovery is more powerful than the coach explaining or directing.',
        'Options A and D tell rather than facilitate discovery. Option B misses the coaching opportunity.',
        9
    );

    -- Q10: Creating Awareness - Blind Spots
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_creating_awareness_id,
        'Your client consistently describes themselves as "not a leader" but shares many examples of leading others successfully.',
        'What''s the best approach to create awareness of this blind spot?',
        '[
            {"key": "a", "text": "Tell them directly: \"You''re wrong, you are clearly a leader\""},
            {"key": "b", "text": "Stay quiet and let them figure it out on their own eventually"},
            {"key": "c", "text": "Reflect back what you hear: \"I''m hearing you say you''re not a leader, and I''m also hearing these examples... What do you make of that?\""},
            {"key": "d", "text": "Give them a leadership assessment test to prove they''re a leader"}
        ]'::jsonb,
        'c',
        'blind_spot_awareness',
        'Option C creates awareness by presenting the contradiction without judgment, allowing the client to discover the insight themselves. This is more impactful than the coach providing the answer.',
        'Options A and D tell the client rather than help them discover. Option B is too passive.',
        10
    );

    -- ================================================================
    -- DIRECT COMMUNICATION (2 questions)
    -- ================================================================

    -- Q11: Direct Communication - Bottom-lining
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_direct_communication_id,
        'Your client has been talking in circles for 10 minutes about a conflict with a colleague.',
        'How do you use direct communication to help them focus?',
        '[
            {"key": "a", "text": "Let them continue until they run out of things to say"},
            {"key": "b", "text": "Interrupt and say: \"You''re rambling. Get to the point.\""},
            {"key": "c", "text": "\"Can we pause here? What''s the core issue you''re facing with this colleague?\""},
            {"key": "d", "text": "Change the subject to something more productive"}
        ]'::jsonb,
        'c',
        'bottom_lining',
        'Option C uses direct communication respectfully. It interrupts the circular pattern while maintaining rapport and helping the client identify the real issue beneath the story.',
        'Option B is too harsh. Options A and D don''t address the issue directly.',
        11
    );

    -- Q12: Direct Communication - Challenging
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_direct_communication_id,
        'Your client has cancelled three sessions last minute and now says they''re "totally committed" to their goals.',
        'How do you address this directly while maintaining the coaching relationship?',
        '[
            {"key": "a", "text": "Ignore the cancellations and take them at their word"},
            {"key": "b", "text": "Terminate the coaching relationship immediately"},
            {"key": "c", "text": "\"I hear you''re committed, and I''ve noticed three cancelled sessions. Help me understand what''s going on.\""},
            {"key": "d", "text": "Lecture them about the importance of consistency"}
        ]'::jsonb,
        'c',
        'challenging_with_care',
        'Option C addresses the discrepancy directly but with curiosity rather than judgment. This opens dialogue about what''s really happening while maintaining trust.',
        'Option D is lecturing, not coaching. Options A and B are extremes that avoid the real conversation.',
        12
    );

    -- ================================================================
    -- TRUST & SAFETY (2 questions)
    -- ================================================================

    -- Q13: Trust & Safety - Confidentiality
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_trust_safety_id,
        'A new client asks: "If I tell you something personal, will you share it with my manager who''s paying for this coaching?"',
        'What''s the most appropriate response to build trust?',
        '[
            {"key": "a", "text": "Of course not, everything is confidential"},
            {"key": "b", "text": "I''ll have to share anything work-related with your manager"},
            {"key": "c", "text": "Let''s clarify the confidentiality agreement - typically everything you share stays between us unless you give permission or there''s risk of harm"},
            {"key": "d", "text": "Why don''t you ask your manager what they expect me to share?"}
        ]'::jsonb,
        'c',
        'establishing_confidentiality',
        'Option C directly addresses confidentiality while being transparent about standard exceptions. This clarity builds trust from the beginning of the relationship.',
        'Option A oversimplifies. Options B and D create uncertainty that undermines trust.',
        13
    );

    -- Q14: Trust & Safety - Vulnerability
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_trust_safety_id,
        'Your client becomes emotional and says: "I''m sorry for crying. This is so unprofessional."',
        'How do you respond to maintain psychological safety?',
        '[
            {"key": "a", "text": "You''re right, let''s try to stay focused on solutions"},
            {"key": "b", "text": "Don''t worry, everyone cries in coaching"},
            {"key": "c", "text": "Your emotions are welcome here. This is your space to be fully yourself"},
            {"key": "d", "text": "Quickly change the topic to something less emotional"}
        ]'::jsonb,
        'c',
        'validating_emotions',
        'Option C validates their emotions and reinforces that the coaching space is safe for all their experiences. This builds trust and allows for deeper work.',
        'Options A and D minimize or avoid emotions. Option B dismisses the client''s concern.',
        14
    );

    -- ================================================================
    -- MANAGING PROGRESS (1 question)
    -- ================================================================

    -- Q15: Managing Progress - Accountability
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_managing_progress_id,
        'Your client didn''t complete the action they committed to last session.',
        'What''s the most effective coaching approach?',
        '[
            {"key": "a", "text": "Express disappointment and stress the importance of follow-through"},
            {"key": "b", "text": "Ignore it and move on to avoid making them feel bad"},
            {"key": "c", "text": "Explore with curiosity: \"What got in the way?\" and \"What would support you in moving forward?\""},
            {"key": "d", "text": "Assign an easier action this time"}
        ]'::jsonb,
        'c',
        'accountability_without_judgment',
        'Option C maintains accountability while exploring obstacles without judgment. This helps identify real barriers and co-create more effective strategies.',
        'Option A shames. Option B avoids accountability. Option D assumes the action was too hard without exploring.',
        15
    );

END $$;


-- ============================================================================
-- Verify Data
-- ============================================================================

SELECT 'Core I Beginner Data Summary' as report;

SELECT
    'Assessment Level' as item,
    al.name as value
FROM ai_assessment_levels al
JOIN ai_frameworks f ON al.framework_id = f.id
WHERE f.code = 'core' AND al.level_code = 'beginner';

SELECT
    'Competencies' as item,
    COUNT(*)::text as value
FROM ai_competencies c
JOIN ai_frameworks f ON c.framework_id = f.id
WHERE f.code = 'core';

SELECT
    'Questions' as item,
    COUNT(*)::text as value
FROM ai_questions q
JOIN ai_frameworks f ON q.framework_id = f.id
WHERE f.code = 'core';

SELECT
    c.name as competency,
    COUNT(q.id) as questions
FROM ai_competencies c
JOIN ai_frameworks f ON c.framework_id = f.id
LEFT JOIN ai_questions q ON q.competency_id = c.id
WHERE f.code = 'core'
GROUP BY c.name, c.sort_order
ORDER BY c.sort_order;


-- ============================================================================
-- Migration Complete
-- ============================================================================
