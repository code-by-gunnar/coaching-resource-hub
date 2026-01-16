-- =============================================
-- CORE II INTERMEDIATE ASSESSMENT - ASSESSMENT QUESTIONS (REFINED)
-- =============================================
-- Table: assessment_questions
-- Description: 30 assessment questions aligned with 15 refined skill tags (2 questions per skill tag)
-- Skill Tag Alignment: Each refined skill tag has exactly 2 questions for comprehensive assessment
-- Anti-gaming verified: Balanced distribution across A/B/C/D options
-- =============================================

BEGIN;

-- Delete existing Core II questions to avoid duplicates
DELETE FROM assessment_questions 
WHERE assessment_id = '00000000-0000-0000-0000-000000000002';

INSERT INTO assessment_questions (
    id, assessment_id, question_order, scenario, question,
    option_a, option_b, option_c, option_d,
    correct_answer, explanation, difficulty_weight,
    created_at, updated_at, competency_id, assessment_level_id,
    correct_answer_option_id, is_active
) VALUES

-- =============================================
-- COMPETENCY 1: Advanced Active Listening (Questions 1-6)
-- Refined Skills: Emotional Layering, Somatic Listening, Incongruence Detection
-- =============================================

-- Question 1: Emotional Layering (Correct: A)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 1,
'Sarah, a nurse manager recently promoted to director of patient care, is tearfully sharing how she feels lost after being passed over for a promotion she expected. She''s questioning whether to stay in her company of 10 years or risk starting over elsewhere, expressing both fear of failure and underlying patterns of self-doubt about her leadership capabilities.',
'How do you demonstrate the highest level of emotional awareness in this listening moment?',
'Listen for both her fear of failure AND her underlying imposter syndrome patterns',
'Focus primarily on her work-life balance concerns and suggest practical time management strategies',
'Reflect back her concerns about the long hours and overwhelming workload',
'Ask immediately about her specific leadership challenges and skill gaps',
1,
'Advanced emotional layering requires hearing both surface fear and deeper imposter syndrome patterns simultaneously, not just addressing surface concerns or rushing to problem-solving.',
1,
NOW(), NOW(), '64888b9f-5c07-4bd1-affa-cc99a3bba77f', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
2, true),

-- Question 2: Emotional Layering (Correct: D)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 2,
'Marcus, a 34-year-old software developer, takes a deep breath and shares: ''I used to love painting and playing music, but I haven''t touched either in years. I tell myself I''m too busy, but the truth is I feel guilty spending time on ''non-productive'' activities. I miss the person I used to be when I was creative.''',
'What reflection demonstrates systemic listening skills?',
'It sounds like you''re caught between wanting creativity and feeling productive',
'You''re frustrated with your lack of creative time and missing your artistic self',
'What I''m hearing is guilt about non-productive activities conflicting with your creative desires',
'What I''m hearing is a cycle where your need to be productive creates the very disconnection from creativity you''re mourning',
4,
'Emotional layering identifies the systemic cycle where productivity demands create the creative disconnection, helping clients see cause-effect relationships.',
1,
NOW(), NOW(), '64888b9f-5c07-4bd1-affa-cc99a3bba77f', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
3, true),

-- Question 3: Somatic Listening (Correct: B)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 3,
'Jennifer, a 29-year-old marketing coordinator, sits back in her chair, crosses her arms, and her voice becomes flat as she says: ''I''ve been living in this tiny apartment for five years, telling myself it''s temporary. But I never make time to look for something better. My space feels chaotic and cramped, and I guess I should just accept this is how it''s going to be.''',
'What somatic awareness should guide your listening approach?',
'Focus primarily on the content of what she''s saying about her housing situation',
'Notice the shift in her posture and voice as signals of deeper resignation patterns',
'Ask her to elaborate on why she feels this way about her living space',
'Encourage her to think more positively about her current situation and possibilities',
2,
'Somatic listening integrates body language changes (posture, voice) with verbal content to recognize emotional states like resignation that clients may not express directly.',
1,
NOW(), NOW(), '64888b9f-5c07-4bd1-affa-cc99a3bba77f', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
2, true),

-- Question 4: Somatic Listening (Correct: D)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 4,
'David, a 31-year-old consultant, shares multiple concerns rapidly: ''My old friends from college keep inviting me to things, but I feel like we''ve grown apart. When we get together, I feel like I''m pretending to be someone I used to be. But I''m afraid if I''m authentic, they won''t like who I''ve become.'' As he speaks, you notice he''s speaking faster and faster, barely pausing between thoughts.',
'What listening skill is most important in this complex moment?',
'Try to remember all the specific details he''s sharing about each relationship',
'Ask him to slow down so you can take comprehensive notes',
'Focus on determining which relationship seems most important to address first',
'Track the emotional thread beneath his concerns while noticing his accelerating speech pattern',
4,
'Somatic listening combines emotional threading with awareness of body/speech patterns (accelerating pace) that reveal underlying anxiety about authenticity.',
1,
NOW(), NOW(), '64888b9f-5c07-4bd1-affa-cc99a3bba77f', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
2, true),

-- Question 5: Incongruence Detection (Correct: C)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 5,
'Lisa, a usually energetic and talkative client, arrives to your session speaking very quietly and avoiding eye contact. She sits with slumped shoulders and says: ''Everything''s fine. I just want to focus on my work goals today like we planned.''',
'What does advanced listening awareness suggest in this moment?',
'Respect her stated request and focus on work goals as she clearly requested',
'Ask directly what''s wrong since she''s clearly upset about something',
'Gently acknowledge the shift in her energy and offer space to explore what''s present',
'Continue with the planned session agenda since that''s what she wants',
3,
'Incongruence detection notices when words (''everything''s fine'') don''t match energy/body language, requiring gentle exploration rather than accepting surface statements.',
1,
NOW(), NOW(), '64888b9f-5c07-4bd1-affa-cc99a3bba77f', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
2, true),

-- Question 6: Incongruence Detection (Correct: A)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 6,
'Tom, a confident executive, laughs nervously while sharing: ''I''ve been thinking about starting my own business for years. Everyone says I should - I have the skills, the connections, the experience. It''s a no-brainer, really.'' His hands are clenched and his breathing seems shallow as he speaks.',
'What incongruence requires your attention as a coach?',
'His confident words don''t match his nervous laughter and physical tension',
'He seems unclear about what type of business he wants to start',
'His timeline for starting the business needs more concrete planning',
'He may be overestimating his readiness based on others'' encouragement',
1,
'Incongruence detection recognizes when confident verbal content contradicts somatic signals (nervous laughter, tension), indicating unexpressed fears or doubts.',
1,
NOW(), NOW(), '64888b9f-5c07-4bd1-affa-cc99a3bba77f', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
1, true),

-- =============================================
-- COMPETENCY 2: Strategic Powerful Questions (Questions 7-12)
-- Refined Skills: Belief Inquiry, Core Drive Questioning, Positive Intent Discovery
-- =============================================

-- Question 7: Belief Inquiry (Correct: D)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 7,
'Jennifer, a 32-year-old financial analyst, shares with frustration: ''I know I should be saving and investing for the future, but every month I find reasons to spend instead. I tell myself I''ll start next month, but I''m 32 and have almost nothing saved. I''m terrified of being financially insecure but can''t seem to change my spending habits.''',
'What question would most effectively reveal the underlying belief system driving this pattern?',
'What would happen if you actually saved money this month instead of spending?',
'Which specific expenses could you eliminate this month to start saving?',
'What would true financial security look like for you in concrete terms?',
'How is your pattern of spending serving the beliefs you have about yourself?',
4,
'Belief inquiry connects behaviors to underlying belief systems, helping clients understand the ''why'' behind patterns rather than focusing on behavior change.',
1,
NOW(), NOW(), '2640accd-a78a-4ddc-9916-b756e07d2b1c', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
2, true),

-- Question 8: Belief Inquiry (Correct: C)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 8,
'Emma, a 27-year-old nonprofit worker, says with conflicted energy: ''I know I should be grateful for my job, but I feel trapped. I tell myself I''m lucky to have steady income, especially in this economy. My friends think I''m crazy for even considering leaving when so many people are unemployed.''',
'What question would most effectively explore her belief system about work and gratitude?',
'What would have to change for you to feel less trapped in this position?',
'What would your ideal work situation look like if you could create anything?',
'What do you believe it means about you if you''re not grateful for steady income?',
'How might you explore other opportunities while keeping your current job?',
3,
'Belief inquiry explores the meaning clients assign to emotions and situations, uncovering belief systems about worthiness, gratitude, and deservingness.',
1,
NOW(), NOW(), '2640accd-a78a-4ddc-9916-b756e07d2b1c', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
3, true),

-- Question 9: Core Drive Questioning (Correct: A)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 9,
'David, a 38-year-old operations manager, explains with exasperation: ''My partner and I keep having the same fights about household responsibilities. We''ll resolve it temporarily, but then we fall back into the same patterns. I end up feeling like their parent, and they feel like I''m controlling everything.''',
'What question would challenge his current thinking pattern most effectively?',
'What are you really trying to control when you control household tasks?',
'What would happen if you stopped trying to manage the household responsibilities?',
'How might you both be contributing to this parent-child dynamic you''ve created?',
'When did you first learn that you''re responsible for managing others'' choices?',
1,
'Core drive questioning explores deeper motivations beneath surface behaviors, helping clients understand what they''re really trying to control or achieve.',
1,
NOW(), NOW(), '2640accd-a78a-4ddc-9916-b756e07d2b1c', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
3, true),

-- Question 10: Core Drive Questioning (Correct: B)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 10,
'Robert, a 45-year-old teacher, says with self-judgment: ''I keep promising myself I''ll get healthy - lose weight, exercise regularly, eat better. I''ll start strong for a few weeks, then life gets busy and I''m back to old habits. I feel like I''m failing my body and my family who worry about me.''',
'What question explores his core drive beneath the health goals?',
'What does health success mean to you specifically versus society''s expectations?',
'What are you really trying to prove or achieve through becoming healthy?',
'Who is this ''everyone'' that maintains perfect health habits you''re comparing yourself to?',
'What small steps could you take that would feel sustainable given your real life?',
2,
'Core drive questioning uncovers what clients are trying to prove, achieve, or control through their goals, revealing deeper motivational patterns.',
1,
NOW(), NOW(), '2640accd-a78a-4ddc-9916-b756e07d2b1c', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
3, true),

-- Question 11: Positive Intent Discovery (Correct: C)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 11,
'Maria, a 30-year-old graphic designer, shares with frustration: ''I''m a perfectionist, and I know it''s holding me back. I spend too much time on details that don''t matter. Everyone tells me I need to just stop being such a perfectionist, but I can''t seem to change.''',
'What question would help her discover the hidden value in her perfectionism?',
'What would ''good enough'' look like in your work instead of perfect?',
'When has your attention to detail actually served you well in your career?',
'How is perfectionism trying to take care of you or protect something important?',
'What are you afraid would happen if you lowered your standards significantly?',
3,
'Positive intent discovery finds the protective function behind seemingly negative patterns, helping clients understand what these behaviors are trying to provide.',
1,
NOW(), NOW(), '2640accd-a78a-4ddc-9916-b756e07d2b1c', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
3, true),

-- Question 12: Positive Intent Discovery (Correct: A)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 12,
'Karen, a 39-year-old nurse, describes with exhaustion: ''I''ve been dealing with chronic pain for two years. Some days I can barely function, but I push through because I don''t want to be seen as weak or unreliable. I''m exhausted from pretending everything''s fine when my body is screaming.''',
'What question would help her discover the positive intent behind pushing through pain?',
'How is pushing through pain trying to take care of your sense of worth and reliability?',
'What does showing weakness represent to you, and where did you learn that?',
'When did you first learn that you had to be strong all the time to be acceptable?',
'What happens if you don''t pretend everything is fine - what are you afraid of?',
1,
'Positive intent discovery helps clients see how pushing through pain serves their values of reliability and worth, even when causing harm.',
1,
NOW(), NOW(), '2640accd-a78a-4ddc-9916-b756e07d2b1c', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
3, true),

-- =============================================
-- COMPETENCY 3: Creating Awareness (Questions 13-18)  
-- Refined Skills: Strength-Shadow Recognition, Self-Role Recognition, Internal Process Awareness
-- =============================================

-- Question 13: Strength-Shadow Recognition (Correct: D)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 13,
'Lisa, a 35-year-old event coordinator, explains with resignation: ''Everyone sees me as the responsible one who has it all together. I plan everyone else''s fun but never prioritize my own. When friends invite me out, I automatically think of reasons I can''t go. I''ve forgotten how to just enjoy myself without feeling guilty.''',
'How would you help her recognize the unintended consequences of her strength?',
'Point out that always being responsible isn''t actually helpful to anyone long-term',
'Suggest she needs to find a better balance between helping others and herself',
'Explore what ''being selfish'' means to her specifically and where that came from',
'Ask: ''What might your responsibility be preventing you from experiencing?''',
4,
'Strength-shadow recognition helps clients discover how their greatest strengths create blind spots, preventing them from experiencing other aspects of life.',
1,
NOW(), NOW(), '6dddbf00-a782-4327-b751-71e18282b16c', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
2, true),

-- Question 14: Strength-Shadow Recognition (Correct: B)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 14,
'Michael, a 42-year-old team leader, shares: ''I pride myself on being helpful and solving problems for my team. But lately, I''ve noticed they''re coming to me for everything, even simple decisions. They seem less confident and more dependent. I want to help, but something feels off about this dynamic.''',
'What question would help him recognize the shadow side of his helpfulness?',
'How might your problem-solving strength be limiting your team''s growth and confidence?',
'How might your helpfulness be accidentally creating the dependency you''re noticing?',
'What would happen if you stepped back and let your team struggle with problems sometimes?',
'When did you first learn that your worth comes from being needed and helpful?',
2,
'Strength-shadow recognition reveals how helping others can create dependency, showing clients how their strengths can have unintended consequences.',
1,
NOW(), NOW(), '6dddbf00-a782-4327-b751-71e18282b16c', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
2, true),

-- Question 15: Self-Role Recognition (Correct: B)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 15,
'Michelle, a 28-year-old social worker, describes with frustration: ''I have one friend who constantly vents to me about her problems but never asks about my life. I feel like an unpaid therapist, but if I try to change the dynamic, she gets upset. I don''t know how to have a balanced friendship with her.''',
'What would help her become aware of her role in this pattern?',
'What type of friendship would you prefer to have with her instead?',
'How might you be unconsciously enabling this dynamic to continue?',
'What is it about her upset reaction that stops you from setting boundaries?',
'What specific changes could you make to redirect the conversation toward balance?',
2,
'Self-role recognition helps clients see their unconscious contribution to problematic patterns, empowering them with agency to create change.',
1,
NOW(), NOW(), '6dddbf00-a782-4327-b751-71e18282b16c', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
2, true),

-- Question 16: Self-Role Recognition (Correct: C) 
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 16,
'James, a 35-year-old consultant, explains: ''My business partner and I have completely different work styles. They''re laid-back and flexible, I''m structured and deadline-focused. We keep clashing because they think I''m controlling, and I think they''re irresponsible. Our working relationship is deteriorating.''',
'What question would help him see his role in the dynamic?',
'How might you both adapt your styles to work together more effectively?',
'What would happen if you relaxed your standards to match their flexible approach?',
'How might your need for structure be creating the resistance you''re experiencing?',
'What do you appreciate about their flexible approach that could balance your structure?',
3,
'Self-role recognition helps clients see how their approach creates predictable responses in others, revealing their contribution to relationship dynamics.',
1,
NOW(), NOW(), '6dddbf00-a782-4327-b751-71e18282b16c', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
2, true),

-- Question 17: Internal Process Awareness (Correct: A)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 17,
'Robert, a 42-year-old accountant, explains with sadness: ''I''ve been married 10 years, but we barely talk anymore beyond logistics. We used to share everything, but now we just coexist. I want to reconnect but don''t know how to bridge this distance we''ve created.''',
'What approach would help him gain awareness about his internal process?',
'What happens inside you when you think about being vulnerable with your spouse?',
'How do you typically initiate deeper conversations when you want connection?',
'What would it feel like to share something real with them again?',
'What evidence do you have that they want distance too, or is that your assumption?',
1,
'Internal process awareness helps clients notice their internal experience during challenging moments, understanding their patterns of connection and disconnection.',
1,
NOW(), NOW(), '6dddbf00-a782-4327-b751-71e18282b16c', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
1, true),

-- Question 18: Internal Process Awareness (Correct: D)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 18,
'Tom, a 33-year-old sales manager, shares with confusion: ''Money was always tight growing up, so now that I''m earning well, I can''t stop spending. I buy things I don''t need because I can finally afford them. But I''m not building wealth - I''m just living paycheck to paycheck at a higher income level.''',
'What awareness-building approach would help him understand his internal process?',
'What did you want before money became available that you''re trying to satisfy now?',
'What would financial security look like if childhood scarcity wasn''t influencing your choices?',
'What feelings come up when you imagine having money but not spending it?',
'What part of you gets lost when you focus on having things instead of being secure?',
4,
'Internal process awareness helps clients notice the emotional experience of scarcity/abundance and understand how past experiences drive current choices.',
1,
NOW(), NOW(), '6dddbf00-a782-4327-b751-71e18282b16c', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
3, true),

-- =============================================
-- COMPETENCY 4: Trust & Psychological Safety (Questions 19-24)
-- Refined Skills: Vulnerability Honoring, Resource State Access, Emotional Normalization  
-- =============================================

-- Question 19: Vulnerability Honoring (Correct: B)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 19,
'Emma, a 26-year-old marketing assistant, becomes emotional and shares: ''I moved to this city three years ago for work, but I still feel like an outsider. I don''t have a community here, and I''m too embarrassed to admit how lonely I am. Everyone else seems to have found their people, and I just... haven''t.''',
'How do you respond to deepen safety for this vulnerable moment?',
'Many people struggle with loneliness after moving - you''re definitely not alone in this',
'It takes courage to share something this personal. What does it feel like to say this out loud?',
'What makes you think you haven''t found your people when you''ve only been here three years?',
'Those other people probably have their own struggles with connection that they don''t share',
2,
'Vulnerability honoring stays present with the courage it takes to share difficult emotions rather than rushing to normalize or fix the experience.',
1,
NOW(), NOW(), '86552202-948a-458e-81ac-4d15b7b82daf', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
2, true),

-- Question 20: Vulnerability Honoring (Correct: C)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 20,
'Kevin, a 31-year-old project manager, shares with visible anxiety: ''I made a decision last month that cost the company $50,000. I haven''t told my boss yet because I''m terrified of losing my job. The longer I wait, the worse it gets, but I just can''t bring myself to have that conversation.''',
'What response honors his vulnerability while maintaining coaching boundaries?',
'What''s the worst that could realistically happen if you tell your boss about this mistake?',
'Holding this secret seems to be creating more pain than the original mistake would',
'I can feel how heavy this burden is for you. What do you need right now to face this?',
'Most bosses appreciate honesty about mistakes, even expensive ones like this',
3,
'Vulnerability honoring acknowledges the emotional weight of difficult situations while asking what the client needs rather than rushing to advice or reassurance.',
1,
NOW(), NOW(), '86552202-948a-458e-81ac-4d15b7b82daf', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
3, true),

-- Question 21: Resource State Access (Correct: A)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 21,
'Rachel, a 29-year-old therapist, shares with overwhelm: ''I spend all day helping others access their resourceful state, but when it comes to my own decisions, I second-guess everything. I feel like I should know what to do since I help others figure it out, but I''m completely stuck about my own life direction.''',
'How do you help her access her resourceful state?',
'If you already knew the answer about your direction, what would it be?',
'What advice would you give a client who came to you with this exact situation?',
'When you trust yourself completely, what comes up for you about this decision?',
'What comes up for you when you trust yourself and quiet the self-doubt voices?',
1,
'Resource state access helps clients connect with their own thinking and capabilities when stuck in self-doubt, supporting them in trusting their resourceful state.',
1,
NOW(), NOW(), '86552202-948a-458e-81ac-4d15b7b82daf', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
1, true),

-- Question 22: Resource State Access (Correct: D)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 22,
'Brian, a 40-year-old consultant, shares with frustration: ''I''ve been offered a promotion that would mean more money but also more travel and stress. My family needs the income, but I''m already stretched thin. I keep going back and forth and can''t decide what''s right.''',
'What question would help him access his resourceful state about this decision?',
'What are the pros and cons of each option when you list them out objectively?',
'What would your family prefer - more income or more time with you?',
'What does your gut tell you when you imagine yourself in each scenario?',
'What do you know about what''s right for your family that you''re not trusting?',
4,
'Resource state access helps clients trust their inner knowing about complex decisions rather than getting stuck in mental analysis or external validation.',
1,
NOW(), NOW(), '86552202-948a-458e-81ac-4d15b7b82daf', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
1, true),

-- Question 23: Emotional Normalization (Correct: C)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 23,
'Mark, a usually composed 37-year-old engineer, starts crying during your session and immediately says: ''I hate that I''m crying. This is so embarrassing. I shouldn''t be getting this emotional over work stuff. I''m supposed to be stronger than this.''',
'What response creates the most safety for his emotional expression?',
'There''s absolutely nothing embarrassing about having feelings - that''s what makes us human',
'What would it mean about you if you let yourself feel this without any judgment?',
'I see someone being real and human - there''s nothing more courageous than that',
'Who taught you that you shouldn''t get emotional? Where did that rule come from originally?',
3,
'Emotional normalization reframes emotional expression as courage and authenticity rather than weakness, helping clients see vulnerability as strength.',
1,
NOW(), NOW(), '86552202-948a-458e-81ac-4d15b7b82daf', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
3, true),

-- Question 24: Emotional Normalization (Correct: A)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 24,
'Brian, a 40-year-old consultant, suddenly stops mid-sentence during an emotional share and says: ''Sorry, I''m being ridiculous. I shouldn''t be complaining about this stuff when other people have real problems. This is just me being dramatic.''',
'What response maintains psychological safety while normalizing his experience?',
'What just happened there? I noticed you stopped yourself from sharing something important',
'You''re not being ridiculous at all - your feelings are completely valid and important',
'Comparison can be a way we dismiss our own experience. What matters to you matters',
'Who taught you that your problems aren''t important enough to deserve attention?',
1,
'Emotional normalization notices self-interruption patterns and gently brings awareness to how clients minimize their own experience in real-time.',
1,
NOW(), NOW(), '86552202-948a-458e-81ac-4d15b7b82daf', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
2, true),

-- =============================================
-- COMPETENCY 5: Direct Communication (Questions 25-30)
-- Refined Skills: Impact Communication, Pattern Confrontation, Collaborative Problem-Naming
-- =============================================

-- Question 25: Impact Communication (Correct: B)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 25,
'Alex, your client for three sessions, consistently arrives 10 minutes late and seems distracted by his phone throughout your time together. When you''ve gently mentioned it before, he apologizes but the pattern continues. Today he''s late again and checking messages during your conversation.',
'How do you address this pattern directly while maintaining the relationship?',
'Alex, I''ve noticed a pattern with timing and attention. How can we make sure you''re getting full value from our sessions?',
'I need to address something. Your lateness and phone use are affecting our work together',
'It seems like this might not be the right time for coaching for you given how you''re showing up',
'I''m curious about what these sessions mean to you, given the way you''re engaging with them',
2,
'Impact communication states behavioral impact directly without blame or softening, clearly communicating how behaviors affect the coaching relationship.',
1,
NOW(), NOW(), 'f77a29c6-ccff-4dd7-b964-57f809a113b0', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
2, true),

-- Question 26: Impact Communication (Correct: D)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 26,
'Maria, your client for two months, has missed two scheduled payments and avoided the topic when mentioned gently. She''s now requesting to schedule additional sessions while the unpaid invoices remain outstanding. You value the coaching relationship, but this is affecting your business.',
'What demonstrates professional boundary setting while preserving the relationship?',
'Maria, I need to pause our sessions until we resolve the outstanding payments',
'I notice we have some unpaid invoices. How would you like to handle bringing these current?',
'Before we schedule more sessions, let''s talk about bringing your account current',
'I value our work together, and I need to address the payment situation directly',
4,
'Impact communication combines clear boundary communication with expressed value for the relationship and person''s growth.',
1,
NOW(), NOW(), 'f77a29c6-ccff-4dd7-b964-57f809a113b0', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
4, true),

-- Question 27: Pattern Confrontation (Correct: B)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 27,
'Jake, your client, consistently deflects with humor whenever you approach deeper emotional topics. Today when you ask about his relationship patterns, he jokes: ''What am I, paying you to be my mom? Next you''ll want me to talk about my feelings and cry together!''',
'What direct response would be most effective in addressing this pattern?',
'I notice you use humor when things get deeper. What''s that about for you, Jake?',
'Jake, the humor is a pattern I see when we get close to something important',
'I''m not your mom, and I am interested in what matters to you beyond the jokes',
'What would happen if we stayed serious for just a moment without the humor?',
2,
'Pattern confrontation names deflection patterns directly without getting hooked by the deflection, addressing avoidance strategies clearly.',
1,
NOW(), NOW(), 'f77a29c6-ccff-4dd7-b964-57f809a113b0', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
2, true),

-- Question 28: Pattern Confrontation (Correct: A)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 28,
'Sam, your client, frequently interrupts you mid-sentence and seems impatient with your questions throughout today''s session. This pattern has happened multiple times, and it''s significantly affecting the quality of your time together.',
'What''s the most skillful direct intervention in this moment?',
'Sam, I notice you''re interrupting me frequently today. What''s happening for you right now?',
'I need you to let me finish my thoughts so I can support you most effectively',
'You seem really activated today. Should we pause and check in about what''s present?',
'I''m having trouble finishing my questions. Can we slow down the pace a bit?',
1,
'Pattern confrontation addresses problematic behaviors directly while staying curious about client''s internal experience rather than just managing the behavior.',
1,
NOW(), NOW(), 'f77a29c6-ccff-4dd7-b964-57f809a113b0', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
1, true),

-- Question 29: Collaborative Problem-Naming (Correct: C)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 29,
'Rachel, your client for six weeks, expresses frustration: ''I keep talking about the same problems every week. I feel like I''m wasting your time and my money. Maybe I should find a different coach who can actually help me make progress.''',
'What direct response addresses her concern most effectively?',
'You''re not wasting anyone''s time - real change takes time and patience with the process',
'What would need to happen for you to feel like we''re making meaningful progress together?',
'I''ve also noticed we''re cycling. What do you think is keeping us stuck here?',
'If you feel like you need a different coach, I completely support that decision',
3,
'Collaborative problem-naming joins clients in curiosity about process issues rather than becoming defensive, acknowledging their observation and exploring it together.',
1,
NOW(), NOW(), 'f77a29c6-ccff-4dd7-b964-57f809a113b0', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
3, true),

-- Question 30: Collaborative Problem-Naming (Correct: B)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 30,
'During supervision, your coaching mentor provides direct feedback: ''I''ve noticed you tend to ask three questions in a row instead of staying with the client''s response to one question. It''s preventing deeper exploration and making sessions feel rushed.''',
'How do you respond to this direct feedback professionally?',
'You''re absolutely right, I do that when I''m nervous about silence and want to keep things moving',
'Thank you for pointing that out. I hadn''t noticed that pattern in my questioning approach',
'I guess I''m trying to find the right question instead of trusting the process',
'Can you help me understand what I should do instead when I feel that urge?',
2,
'Collaborative problem-naming demonstrates receiving feedback with professional acknowledgment while staying open to exploration rather than becoming defensive.',
1,
NOW(), NOW(), 'f77a29c6-ccff-4dd7-b964-57f809a113b0', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c',
1, true);

COMMIT;

-- Validation Queries
SELECT 'Total Questions' as metric, COUNT(*)::text as value
FROM assessment_questions 
WHERE assessment_id = '00000000-0000-0000-0000-000000000002'

UNION ALL

SELECT 'Anti-Gaming Distribution' as metric, 
       CONCAT('A:', SUM(CASE WHEN correct_answer = 1 THEN 1 ELSE 0 END),
              ' B:', SUM(CASE WHEN correct_answer = 2 THEN 1 ELSE 0 END),
              ' C:', SUM(CASE WHEN correct_answer = 3 THEN 1 ELSE 0 END),
              ' D:', SUM(CASE WHEN correct_answer = 4 THEN 1 ELSE 0 END)) as value
FROM assessment_questions 
WHERE assessment_id = '00000000-0000-0000-0000-000000000002';

-- Expected Results:
-- Total Questions: 30
-- Anti-Gaming: A:8 B:8 C:7 D:7 (balanced distribution)