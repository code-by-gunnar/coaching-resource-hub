-- ============================================================================
-- Migrate Comprehensive Questions from Original Production Data
-- ============================================================================
-- This migration replaces the current AI questions with the more comprehensive
-- scenario-based questions from the original production backup.
-- These questions have better real-world coaching scenarios with named characters.
-- ============================================================================

-- Delete existing questions for Core Beginner
DELETE FROM ai_questions
WHERE framework_id = (SELECT id FROM ai_frameworks WHERE code = 'core')
  AND level_id = (SELECT al.id FROM ai_assessment_levels al
                  JOIN ai_frameworks f ON al.framework_id = f.id
                  WHERE f.code = 'core' AND al.level_code = 'beginner');

-- Insert comprehensive questions
DO $$
DECLARE
    v_framework_id UUID;
    v_level_id UUID;
    v_active_listening_id UUID;
    v_powerful_questions_id UUID;
    v_present_moment_id UUID;
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

    -- ================================================================
    -- ACTIVE LISTENING (5 questions)
    -- ================================================================

    -- Q1: Sarah - Marketing Director (emotional career setback)
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_active_listening_id,
        'Sarah, a 38-year-old marketing director, is tearfully sharing how she feels lost after being passed over for a promotion she expected. She''s questioning whether to stay in her company of 10 years or risk starting over elsewhere.',
        'How should you listen as Sarah shares this emotional career setback?',
        '[
            {"key": "a", "text": "Focus on how her story relates to your own career disappointments"},
            {"key": "b", "text": "Listen deeply to both her words and the emotions behind them"},
            {"key": "c", "text": "Consider what her colleagues might think about her situation"},
            {"key": "d", "text": "Think about advice you could give her about job searching"}
        ]'::jsonb,
        'b',
        'emotional_listening',
        'When someone is emotional, they need to feel truly heard. Listening to both their words and feelings shows you''re really there with them, not just waiting for your turn to talk.',
        'Level 1 listening (focusing on yourself) or planning advice misses the emotional connection Sarah needs right now.',
        1
    );

    -- Q2: Marcus - Entrepreneur (multiple decisions under pressure)
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_active_listening_id,
        'Marcus, an entrepreneur, is rapidly listing multiple business decisions he needs to make: whether to hire his first employee, move to a larger office space, and take on a major client project - all while his personal savings are running low.',
        'How do you best reflect back what you''re hearing from Marcus?',
        '[
            {"key": "a", "text": "I went through something similar when I started my business - it''s really tough."},
            {"key": "b", "text": "What I''m hearing is that you''re juggling multiple major decisions while feeling financial pressure."},
            {"key": "c", "text": "Don''t stress about it - most entrepreneurs face these challenges."},
            {"key": "d", "text": "Have you considered prioritizing just one decision at a time?"}
        ]'::jsonb,
        'b',
        'reflective_listening',
        'Great reflection is like being a clear mirror - you show Marcus exactly what he shared so he knows you really got it. No advice needed, just genuine understanding.',
        'Sharing your own experience (a), minimizing (c), or giving advice (d) takes the focus away from Marcus.',
        2
    );

    -- Q3: Kevin - Accountant (vulnerable disclosure about anxiety)
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_active_listening_id,
        'Kevin, a usually reserved accountant, takes a deep breath and quietly shares: ''I''ve never told anyone this, but I''ve been struggling with anxiety attacks before important presentations. It''s affecting my career prospects.''',
        'How do you best respond to Kevin''s vulnerable disclosure to build trust and safety?',
        '[
            {"key": "a", "text": "Kevin, that''s interesting - can you tell me more about when these anxiety attacks typically happen?"},
            {"key": "b", "text": "I can see why that would be really difficult to deal with, especially in your profession."},
            {"key": "c", "text": "Thank you for trusting me with something so personal, Kevin. What feels most important about this for you right now?"},
            {"key": "d", "text": "You should be proud of yourself for having the courage to share that with me."}
        ]'::jsonb,
        'c',
        'trust_building',
        'When someone shares something deeply personal, thanking them for their trust creates a safe space. It shows you honor their vulnerability instead of rushing to fix or judge.',
        'Immediately probing (a) can feel intrusive. Sympathy (b) is okay but less powerful. Telling him how to feel (d) is directive.',
        3
    );

    -- Q4: Patricia - Department Head (second-guessing decisions)
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_active_listening_id,
        'Patricia, a department head, is second-guessing her decision to restructure her team after two employees expressed concerns. She''s worried she may have acted too hastily and damaged team morale.',
        'How do you best support Patricia while maintaining psychological safety in the coaching space?',
        '[
            {"key": "a", "text": "Patricia, I hear you questioning your restructuring decision, and I''m curious what feels most important to explore about that."},
            {"key": "b", "text": "Based on what you''ve shared about the employee concerns, here''s what I think you should do next..."},
            {"key": "c", "text": "That sounds like a really challenging leadership situation that many department heads face."},
            {"key": "d", "text": "Let''s focus on finding solutions for the team morale issue rather than dwelling on what''s already happened."}
        ]'::jsonb,
        'a',
        'psychological_safety',
        'Stay curious instead of jumping into advice mode. This response keeps Patricia feeling safe to explore her thoughts without pressure to defend her decisions.',
        'Giving advice (b), normalizing (c), or redirecting (d) misses the opportunity for Patricia to process her concerns.',
        4
    );

    -- Q5: Nicole - Real Estate Agent (reluctance to share)
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_active_listening_id,
        'Nicole, a real estate agent, mentions having a ''situation with a client'' but then becomes vague, avoiding eye contact and changing the subject when you ask for more details about what happened.',
        'How do you best navigate Nicole''s reluctance to share while practicing active listening?',
        '[
            {"key": "a", "text": "Let''s move on to something else that might be easier for you to discuss right now."},
            {"key": "b", "text": "Nicole, I can sense there might be more to this client situation. What feels safe to share right now?"},
            {"key": "c", "text": "It''s completely okay if you don''t want to talk about this - we all have things we prefer to keep private."},
            {"key": "d", "text": "Sometimes it really helps to talk through these difficult client situations, even when it feels uncomfortable."}
        ]'::jsonb,
        'b',
        'sensing_reluctance',
        'When someone seems hesitant to share, gently acknowledging what you sense while respecting their boundaries often helps them feel safer to open up.',
        'Moving on (a) abandons the opportunity. Over-validating avoidance (c) enables it. Pushing (d) can feel pressuring.',
        5
    );

    -- ================================================================
    -- POWERFUL QUESTIONS (5 questions)
    -- ================================================================

    -- Q6: David - Software Engineer (limiting beliefs after layoff)
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_powerful_questions_id,
        'David, a software engineer who was recently laid off, slumps in his chair and says: ''I always mess things up. I probably said something wrong in my last performance review that led to this.''',
        'Which question would most powerfully challenge David''s limiting belief?',
        '[
            {"key": "a", "text": "What specifically happened in that performance review that concerns you?"},
            {"key": "b", "text": "Why do you think you have this pattern of self-sabotage?"},
            {"key": "c", "text": "How long have you been carrying this story about yourself?"},
            {"key": "d", "text": "What would someone who truly knows your capabilities say about this situation?"}
        ]'::jsonb,
        'd',
        'challenging_limiting_beliefs',
        'Sometimes we''re our own worst critic. This question helps David step outside his harsh self-talk by imagining what someone who truly knows his strengths would say.',
        'Information gathering (a) stays in the problem. "Why" questions (b) can feel judgmental. Option (c) is good but (d) offers fresh perspective.',
        6
    );

    -- Q7: Jennifer - Nurse Practitioner (career crossroads)
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_powerful_questions_id,
        'Jennifer, a nurse practitioner, is considering leaving her stable hospital job to open her own wellness practice. She''s torn between financial security and pursuing her passion for holistic medicine.',
        'Which question would best help Jennifer connect with what truly matters to her?',
        '[
            {"key": "a", "text": "What do you think would be the financially smarter decision?"},
            {"key": "b", "text": "What matters most to you about how you want to spend your professional life?"},
            {"key": "c", "text": "What would your family and colleagues advise you to do?"},
            {"key": "d", "text": "What are the financial risks versus benefits of each option?"}
        ]'::jsonb,
        'b',
        'values_exploration',
        'This cuts through all the external noise and gets to the heart of what really matters to Jennifer. It''s about her authentic desires, not everyone else''s expectations.',
        'Financial analysis (a, d) or others'' opinions (c) are external factors. Values-based questions reveal internal truth.',
        7
    );

    -- Q8: Michael - College Graduate (parental expectations vs dreams)
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_powerful_questions_id,
        'Michael, a recent college graduate, is paralyzed between accepting a well-paying consulting job his parents approve of or pursuing his dream of teaching abroad with the Peace Corps for much less money.',
        'Which question would best help Michael access his authentic desires beyond external expectations?',
        '[
            {"key": "a", "text": "Which option do you think would make your parents prouder?"},
            {"key": "b", "text": "What does your gut instinct tell you about each path?"},
            {"key": "c", "text": "If you close your eyes and imagine yourself in each role, which one feels more aligned with who you''re becoming?"},
            {"key": "d", "text": "Which choice would be easier to defend to your family?"}
        ]'::jsonb,
        'c',
        'accessing_authentic_self',
        'This question invites Michael to feel into his future, not just think about it. Our bodies often know the right answer before our minds catch up.',
        'Parent-focused questions (a, d) reinforce external validation. Gut instinct (b) is good but (c) is more immersive and powerful.',
        8
    );

    -- Q9: Carlos - Middle Manager (wanting advice)
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_powerful_questions_id,
        'Carlos, a middle manager, keeps asking what you think he should do about his underperforming team member. He''s looking for direct advice and seems frustrated when you redirect back to him, saying ''I just need someone to tell me the right answer.''',
        'How do you respond to Carlos''s request for advice while empowering him to find his own solution?',
        '[
            {"key": "a", "text": "Carlos, what would need to be true for you to feel completely confident in your approach with this team member?"},
            {"key": "b", "text": "Based on what you''ve shared, here''s exactly what I think you should do with this employee..."},
            {"key": "c", "text": "Most managers in your situation would probably start with a formal performance improvement plan."},
            {"key": "d", "text": "You seem to already know what needs to happen - what''s holding you back from taking action?"}
        ]'::jsonb,
        'a',
        'empowering_self_discovery',
        'Instead of giving Carlos the fish, this question helps him learn to fish. It focuses on building his confidence rather than creating dependence on your advice.',
        'Giving advice (b, c) creates dependency. Option (d) is good but makes an assumption. Option (a) builds capability.',
        9
    );

    -- Q10: Rachel - Graphic Designer (limiting self-perception)
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_powerful_questions_id,
        'Rachel, a talented graphic designer, sighs and says: ''I''m just not leadership material. I''ve never been good at managing people or making big decisions. Maybe I should just stay in my current role forever.''',
        'How do you challenge Rachel''s limiting belief while maintaining a supportive coaching relationship?',
        '[
            {"key": "a", "text": "Rachel, what would you tell a dear friend who shared these exact same doubts about their capabilities?"},
            {"key": "b", "text": "You''re being too hard on yourself - you need to stop thinking so negatively about your potential."},
            {"key": "c", "text": "Why do you always jump to worst-case scenarios about your leadership abilities?"},
            {"key": "d", "text": "Rachel, what might become possible if this belief about not being leadership material wasn''t actually true?"}
        ]'::jsonb,
        'd',
        'opening_possibilities',
        'This gently challenges Rachel''s limiting story without making her feel wrong. It opens up new possibilities by questioning the belief itself, not attacking it.',
        'Telling her she''s wrong (b) or using "why" (c) can feel judgmental. Self-compassion (a) is good but (d) directly opens new thinking.',
        10
    );

    -- ================================================================
    -- PRESENT MOMENT AWARENESS (5 questions)
    -- ================================================================

    -- Q11: Elena - Busy Executive (coach's wandering attention)
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_present_moment_id,
        'During a session with Elena, a busy executive, you catch your mind drifting to your own challenges with work-life balance as she describes her 60-hour work weeks and missing her daughter''s soccer games.',
        'What''s your best response when you notice your attention has wandered in this present moment?',
        '[
            {"key": "a", "text": "Continue listening and hope Elena doesn''t notice your distraction."},
            {"key": "b", "text": "Gently redirect your full attention back to Elena without judgment."},
            {"key": "c", "text": "Ask Elena to pause and repeat what she just shared with you."},
            {"key": "d", "text": "Start taking detailed notes to help you stay more focused."}
        ]'::jsonb,
        'b',
        'managing_attention',
        'Mind wandering happens to everyone! The key is catching it quickly and coming back without beating yourself up. Self-compassion keeps you present for your client.',
        'Pretending (a) is inauthentic. Asking to repeat (c) can feel awkward. Note-taking (d) can actually reduce presence.',
        11
    );

    -- Q12: Lisa - Project Manager (energy shift)
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_present_moment_id,
        'Lisa, a project manager, started the session enthusiastically discussing her new role. Halfway through, when you ask about her team dynamics, her posture changes, she looks down, and her voice becomes quieter and more hesitant.',
        'How should you address Lisa''s visible shift in energy and body language?',
        '[
            {"key": "a", "text": "Continue discussing her new role without mentioning the change you observed."},
            {"key": "b", "text": "Ask directly: Why did your energy just change when I asked about your team?"},
            {"key": "c", "text": "Share your observation: Lisa, I noticed your energy shifted when we moved to team dynamics. What''s happening for you?"},
            {"key": "d", "text": "Save your observation for the end of the session to avoid interrupting her flow."}
        ]'::jsonb,
        'c',
        'noticing_energy_shifts',
        'Bodies often tell the truth before words do. Gently sharing what you notice helps Lisa become aware of her own signals and what they might mean.',
        'Ignoring (a) misses important data. "Why" (b) can feel confrontational. Waiting (d) loses the moment.',
        12
    );

    -- Q13: Robert - Financial Advisor (internal processing)
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_present_moment_id,
        'Robert, a financial advisor, is mid-sentence explaining his frustration with a difficult client when he suddenly stops talking, stares out the window, and appears to be thinking deeply about something.',
        'How do you best support Robert in this moment of internal processing?',
        '[
            {"key": "a", "text": "Ask him what''s going through his mind to keep the conversation moving forward."},
            {"key": "b", "text": "Hold the silence and create space for whatever insight might be emerging."},
            {"key": "c", "text": "Offer your perspective on what he might be realizing about the situation."},
            {"key": "d", "text": "Summarize what he''s shared about the difficult client to refocus the conversation."}
        ]'::jsonb,
        'b',
        'holding_silence',
        'Sometimes the most powerful thing you can do is absolutely nothing. Silence gives Robert space for his own insights to emerge naturally.',
        'Interrupting (a, c, d) can disrupt important processing. Trust the silence.',
        13
    );

    -- Q14: Amanda - High School Teacher (body language incongruence)
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_present_moment_id,
        'Amanda, a high school teacher, is describing a conflict with her principal. While her words are factual and measured, you notice her jaw is clenched, her hands are fidgeting, and there''s tension in her shoulders.',
        'How do you best help Amanda become aware of what her body is communicating?',
        '[
            {"key": "a", "text": "Tell her directly that she seems angry or frustrated about the situation."},
            {"key": "b", "text": "Ask Amanda: How are you feeling right now as you talk about this?"},
            {"key": "c", "text": "Share your observation: Amanda, I''m noticing tension in your body as you describe this conflict. What are you aware of?"},
            {"key": "d", "text": "Focus only on the factual content she''s sharing rather than her physical responses."}
        ]'::jsonb,
        'c',
        'somatic_awareness',
        'Our bodies hold so much wisdom! Pointing out Amanda''s physical tension helps her tune into messages she might be missing from her own nervous system.',
        'Telling her what she feels (a) is presumptuous. Asking about feelings (b) is less specific than naming what you see. Ignoring (d) misses data.',
        14
    );

    -- Q15: Tom - Sales Manager (unconscious conflict pattern)
    INSERT INTO ai_questions (
        framework_id, level_id, competency_id,
        scenario_text, question_text, options, correct_option,
        concept_tag, explanation, ai_hint, question_order
    ) VALUES (
        v_framework_id, v_level_id, v_present_moment_id,
        'Tom, a sales manager, has mentioned in three separate sessions that when faced with conflict, he either completely avoids the conversation or immediately becomes defensive. He doesn''t seem to recognize this pattern himself.',
        'How do you best help Tom become aware of his unconscious conflict pattern?',
        '[
            {"key": "a", "text": "Tell him directly: Tom, you keep avoiding conflict or getting defensive - you need to see this pattern."},
            {"key": "b", "text": "Ask: Tom, what do you notice about how you typically respond when conflict arises?"},
            {"key": "c", "text": "Wait for him to figure out the pattern on his own without your intervention."},
            {"key": "d", "text": "Ask: What patterns are you noticing in how you handle challenging conversations?"}
        ]'::jsonb,
        'd',
        'pattern_recognition',
        'Help Tom become the observer of his own patterns. When people discover their habits themselves, they''re more likely to actually change them.',
        'Telling directly (a) can create defensiveness. Waiting (c) might never happen. Option (b) is specific to conflict, (d) is broader and more exploratory.',
        15
    );

END $$;


-- ============================================================================
-- Verify Migration
-- ============================================================================

SELECT 'Comprehensive Questions Migration Summary' as report;

SELECT
    c.name as competency,
    COUNT(q.id) as questions
FROM ai_competencies c
JOIN ai_frameworks f ON c.framework_id = f.id
LEFT JOIN ai_questions q ON q.competency_id = c.id
WHERE f.code = 'core'
GROUP BY c.name, c.sort_order
ORDER BY c.sort_order;

SELECT COUNT(*) as total_questions FROM ai_questions q
JOIN ai_frameworks f ON q.framework_id = f.id
WHERE f.code = 'core';

-- ============================================================================
-- Migration Complete
-- ============================================================================
