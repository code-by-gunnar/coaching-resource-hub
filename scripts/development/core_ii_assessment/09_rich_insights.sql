-- =============================================
-- CORE II INTERMEDIATE ASSESSMENT - RICH INSIGHTS
-- =============================================
-- Table: competency_rich_insights
-- Description: 5 rich insights for Core II intermediate level (9 fields each)
-- =============================================

BEGIN;

-- Delete existing Core II rich insights to avoid duplicates
DELETE FROM competency_rich_insights 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

INSERT INTO competency_rich_insights (id, primary_insight, coaching_impact, key_observation, development_focus, practice_recommendation, growth_pathway, practical_application, supervision_focus, learning_approach, sort_order, is_active, created_at, updated_at, framework_id, assessment_level_id, competency_id) VALUES

-- Advanced Active Listening Rich Insight
(gen_random_uuid(), 
'Demonstrates emerging ability in multi-layered listening with particular strength in content tracking and basic emotional recognition. Development needed in simultaneous processing of verbal, emotional, somatic, and energetic information to fully support complex coaching scenarios where clients communicate on multiple levels simultaneously.',
'This competency level enables effective support for straightforward emotional processing but may miss subtle client communication that reveals deeper patterns, unconscious beliefs, or systemic cycles, limiting ability to help clients access breakthrough awareness in complex life situations.',
'Tends to focus sequentially on different types of client information (content first, then emotion, then body language) rather than integrating multiple awareness streams simultaneously in real-time coaching moments, which reduces responsiveness to the full spectrum of client communication.',
'Priority development in somatic integration and incongruence recognition - practice noticing when client words, emotions, energy, and body language don''t align, and gently exploring these discrepancies with curiosity rather than accepting surface-level presentations at face value.',
'Spend 10 minutes daily practicing ''full spectrum listening'' - notice your own words, emotions, body sensations, and energy simultaneously. Apply this awareness to coaching sessions by tracking client information across all channels and practicing specific integration language.',
'Progress from sequential awareness (content → emotion → body) to simultaneous multi-channel processing, eventually developing capacity to reflect complex patterns and systemic cycles in real-time that help clients understand how different aspects of their experience connect.',
'In coaching sessions, practice specific language: ''I notice your words say X, your voice sounds Y, and your body looks Z. What do you notice?'' Help clients integrate their complete experience rather than focusing only on their verbal content.',
'Work with supervisor on developing somatic awareness in coaching sessions. Practice noticing your own body responses to client energy shifts and using this information to guide interventions and timing of deeper explorations.',
'Study somatic coaching approaches, trauma-informed practices, and Gestalt coaching methods. Recommended reading: ''The Body Keeps the Score'' by van der Kolk, ''Somatic Coaching'' by Strozzi-Heckler, ''Presence-Based Coaching'' by Doug Silsbee.',
1, true, NOW(), NOW(), 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '64888b9f-5c07-4bd1-affa-cc99a3bba77f'),

-- Strategic Powerful Questions Rich Insight
(gen_random_uuid(), 'Shows good foundation in open-ended questioning with emerging ability to generate client insight. Development needed in timing, depth, and sophistication of inquiry to help clients access breakthrough awareness about belief systems, core drives, and the positive intent behind problematic patterns.',
'Current questioning level supports surface-level exploration and basic insight generation but may not access the deeper belief systems and unconscious motivations that drive repetitive patterns, limiting clients'' ability to create lasting transformation at the identity level.',
'Tends to ask multiple questions in sequence rather than staying with client responses and allowing deep exploration of single powerful inquiries, which prevents clients from accessing the profound awareness that comes from sustained reflection on core issues.',
'Priority development in belief system inquiry and positive intent discovery - practice connecting client behaviors to underlying beliefs and finding the protective insights in seemingly negative patterns rather than focusing primarily on behavior change.',
'Practice asking one powerful question per session and staying with it for extended exploration. Focus on ''How is this pattern serving you?'' and ''What belief might this behavior be protecting?'' Allow clients to sit with questions for 30-60 seconds before responding.',
'Progress from surface-level exploration to deep belief system inquiry, eventually developing capacity to help clients discover the positive intent and protective function behind their most challenging patterns and resistance.',
'In coaching sessions, practice specific inquiry: ''How is your pattern of [behavior] serving the beliefs you have about yourself?'' Then stay curious about their response rather than moving to the next question immediately.',
'Work with supervisor on question timing and depth. Practice staying with client responses longer and developing comfort with silence that allows profound insight to emerge naturally from sustained inquiry.',
'Study Clean Language, Socratic questioning methods, and appreciative inquiry approaches. Recommended reading: ''The Art of Powerful Questions'' by Vogt, Brown & Isaacs, ''Questions That Work'' by Andrew Finlayson.',
2, true, NOW(), NOW(), 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '2640accd-a78a-4ddc-9916-b756e07d2b1c'),

-- Creating Awareness Rich Insight
(gen_random_uuid(), 'Demonstrates good instincts for helping clients recognize patterns with particular strength in identifying obvious behavioral cycles. Development needed in helping clients discover unconscious contributions, strength-shadow dynamics, and lost aspects of identity that create blind spots in personal effectiveness.',
'Current awareness-building level supports recognition of surface-level patterns but may miss the deeper self-role recognition and strength-shadow dynamics that would empower clients to understand their unconscious contribution to problems and reclaim lost parts of themselves.',
'Tends to focus on helping clients see external patterns and relationship dynamics without equal attention to their internal process and unconscious contribution, which limits their sense of agency and empowerment in creating change.',
'Priority development in strength-shadow recognition and self-role awareness - practice helping clients see how their greatest strengths create their biggest blind spots and how they unconsciously contribute to the very problems they want to solve.',
'Practice specific awareness-building language: ''What might your helpfulness be preventing you from experiencing?'' and ''How might you be unconsciously enabling this dynamic?'' Focus on empowering clients with their own agency rather than making them victims of circumstances.',
'Progress from external pattern recognition to internal process awareness, eventually developing capacity to help clients reclaim lost aspects of identity and understand the shadow side of their greatest strengths.',
'In coaching sessions, balance exploring external patterns with internal process questions: ''What happens inside you when...'' and ''What part of you gets lost when...'' Help clients see their power to change patterns by changing themselves.',
'Work with supervisor on developing awareness of your own strength-shadow dynamics and unconscious contributions to coaching process issues. Practice modeling self-awareness and personal responsibility.',
'Study shadow work, parts work, and internal family systems approaches. Recommended reading: ''Embracing Our Selves'' by Stone & Stone, ''No Bad Parts'' by Richard Schwartz, Gestalt coaching methods.',
3, true, NOW(), NOW(), 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '6dddbf00-a782-4327-b751-71e18282b16c'),

-- Trust & Psychological Safety Rich Insight
(gen_random_uuid(), 'Shows solid foundation in creating basic safety with appropriate empathy and professional boundaries. Development needed in staying present with intense vulnerability without rushing to fix, and in helping clients access their resourceful state when stuck in self-doubt and emotional overwhelm.',
'Current trust-building level provides adequate safety for routine emotional processing but may not create the deep container needed for clients to explore their most vulnerable experiences or access their full potential when facing significant life challenges.',
'Tends to move quickly past vulnerable moments toward problem-solving rather than staying present with difficult emotions long enough for clients to fully process and integrate their experience, which limits the depth of healing and self-acceptance possible.',
'Priority development in vulnerability honoring and resource state access - practice staying present with difficult emotions without rushing to normalize or fix, and helping clients trust their own knowing when they''re caught in self-doubt.',
'When clients share something vulnerable, practice staying present for 30 seconds of silence before responding. Use language like: ''Thank you for trusting me with this. What''s it like to share this with someone?'' Honor their courage rather than jumping to solutions.',
'Progress from basic safety creation to deep vulnerability honoring, eventually developing capacity to help clients access their resourceful state and capabilities even in moments of significant emotional intensity.',
'In coaching sessions, practice specific vulnerability honoring: ''It takes courage to share something this personal. What does it feel like to say this out loud?'' Then help them access their knowing: ''If you already knew the answer, what would it be?''',
'Work with supervisor on your own comfort with intense emotions and vulnerability. Practice staying present with difficult feelings in your own life to develop capacity to hold space for others.',
'Study trauma-informed coaching, attachment theory, and vulnerability research. Recommended reading: ''Daring Greatly'' by Brené Brown, ''The Body Keeps the Score'' by van der Kolk, ''Hold Me Tight'' by Sue Johnson.',
4, true, NOW(), NOW(), 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '86552202-948a-458e-81ac-4d15b7b82daf'),

-- Direct Communication Rich Insight
(gen_random_uuid(), 'Demonstrates awareness of the importance of direct communication with good instincts for maintaining relationships. Development needed in finding the precise balance between clarity and warmth, especially when addressing problematic behaviors or process issues that affect coaching effectiveness.',
'Current directness level supports addressing routine coaching issues but may avoid difficult conversations that could significantly improve coaching effectiveness, or address them in ways that create defensiveness rather than collaborative problem-solving.',
'Tends to either soften direct communication to preserve relationships or be direct in ways that feel confrontational, struggling to find the sweet spot of clear, warm, collaborative communication about difficult topics.',
'Priority development in impact communication and collaborative problem-naming - practice stating behavioral impact clearly while maintaining relationship warmth, and joining clients in curiosity about process issues rather than becoming defensive.',
'Practice specific direct communication formulas: ''I value our work together, and I need to address...'' and ''I''ve also noticed we''re cycling. What do you think is keeping us stuck here?'' Combine directness with relationship appreciation and collaborative curiosity.',
'Progress from avoiding difficult conversations to clear, warm, collaborative communication that addresses problems while strengthening relationships and modeling healthy conflict resolution.',
'In coaching sessions, practice addressing patterns immediately when you notice them: ''I notice when we approach deeper topics, you tend to use humor. What''s that about for you?'' Address issues with curiosity rather than judgment.',
'Work with supervisor on receiving feedback about your own directness style. Practice giving and receiving difficult feedback with warmth and curiosity to develop modeling capacity for clients.',
'Study crucial conversations, nonviolent communication, and feedback methodologies. Recommended reading: ''Crucial Conversations'' by Patterson, ''Nonviolent Communication'' by Marshall Rosenberg, ''Thanks for the Feedback'' by Stone & Heen.',
5, true, NOW(), NOW(), 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', 'f77a29c6-ccff-4dd7-b964-57f809a113b0');

COMMIT;

-- Validation Query
SELECT id, primary_insight, sort_order, competency_id
FROM competency_rich_insights 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
ORDER BY sort_order;