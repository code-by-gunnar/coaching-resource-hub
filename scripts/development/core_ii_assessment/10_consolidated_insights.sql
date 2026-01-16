-- =============================================
-- CORE II INTERMEDIATE ASSESSMENT - CONSOLIDATED INSIGHTS
-- =============================================
-- Table: competency_consolidated_insights
-- Description: 10 consolidated insights for Core II intermediate level (2 per competency: strength + weakness)
-- =============================================

BEGIN;

-- Delete existing Core II consolidated insights to avoid duplicates
DELETE FROM competency_consolidated_insights 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

INSERT INTO competency_consolidated_insights (id, competency_id, framework_id, assessment_level_id, analysis_type_id, performance_insight, development_focus, practical_application, is_active, created_at, updated_at) VALUES

-- ADVANCED ACTIVE LISTENING CONSOLIDATED INSIGHTS (2 insights)

-- Advanced Active Listening - Strength Consolidated
(gen_random_uuid(), '64888b9f-5c07-4bd1-affa-cc99a3bba77f', 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '378c3fca-d674-469a-b8cd-45e818410a25', 'Strong foundation in reflective listening with good ability to track client content and demonstrate understanding of surface-level emotional experiences, building basic trust and connection.', 'Build on listening strength by developing capacity to integrate multiple awareness streams simultaneously - words, emotions, body language, and energy patterns - rather than processing them sequentially.', 'Use existing listening skills as foundation while practicing multi-channel awareness: ''I hear your words about work stress, I notice your shoulders are tense, and I sense something deeper. What do you notice?''', true, NOW(), NOW()),

-- Advanced Active Listening - Weakness Consolidated
(gen_random_uuid(), '64888b9f-5c07-4bd1-affa-cc99a3bba77f', 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4', 'Tendency to focus primarily on verbal content while missing emotional undertones, body language cues, and energetic shifts that reveal deeper client patterns and unconscious communication.', 'Develop integrated listening skills that simultaneously track content, emotion, somatic information, and incongruence between different channels of client communication to catch subtle but important information.', 'Practice asking ''What am I sensing beyond their words?'' after client speaks. Notice voice tone, posture, energy shifts, and gently explore discrepancies with curiosity rather than accepting surface presentations.', true, NOW(), NOW()),

-- STRATEGIC POWERFUL QUESTIONS CONSOLIDATED INSIGHTS (2 insights)

-- Strategic Powerful Questions - Strength Consolidated
(gen_random_uuid(), '2640accd-a78a-4ddc-9916-b756e07d2b1c', 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '378c3fca-d674-469a-b8cd-45e818410a25', 'Good foundation in open-ended questioning with emerging ability to generate client insight and challenge surface-level thinking patterns, encouraging deeper self-reflection.', 'Build on questioning strength by developing belief system inquiry and positive intent discovery to help clients understand the deeper ''why'' behind their patterns rather than just exploring behaviors.', 'Use current questioning skills while adding belief exploration: ''How is your pattern of [behavior] serving the beliefs you have about yourself?'' Stay curious about their responses rather than moving to next question.', true, NOW(), NOW()),

-- Strategic Powerful Questions - Weakness Consolidated
(gen_random_uuid(), '2640accd-a78a-4ddc-9916-b756e07d2b1c', 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4', 'Tendency to ask multiple questions in sequence without allowing deep exploration of single inquiries, which prevents clients from accessing profound awareness that comes from sustained reflection.', 'Develop timing and depth skills - practice asking one powerful question and staying with client responses for extended exploration, allowing breakthrough insights to emerge naturally.', 'Practice asking ''How is this pattern trying to take care of you?'' and staying with it for 2-3 minutes of exploration before asking anything else. Allow 30-60 seconds of silence after questions.', true, NOW(), NOW()),

-- CREATING AWARENESS CONSOLIDATED INSIGHTS (2 insights)

-- Creating Awareness - Strength Consolidated
(gen_random_uuid(), '6dddbf00-a782-4327-b751-71e18282b16c', 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '378c3fca-d674-469a-b8cd-45e818410a25', 'Good instincts for helping clients recognize obvious patterns and behavioral cycles, supporting them in gaining new perspectives on recurring challenges and relationship dynamics.', 'Build on pattern recognition strength by developing self-role awareness and strength-shadow recognition to help clients see their unconscious contribution and how strengths create blind spots.', 'Use current pattern recognition while adding self-role exploration: ''I notice this pattern... how might you be unconsciously contributing to it?'' Focus on empowering client agency rather than victimhood.', true, NOW(), NOW()),

-- Creating Awareness - Weakness Consolidated
(gen_random_uuid(), '6dddbf00-a782-4327-b751-71e18282b16c', 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4', 'Tendency to focus on external patterns and relationship dynamics without equal attention to internal process and unconscious contributions, which limits client sense of empowerment and agency.', 'Develop internal process awareness and strength-shadow recognition to help clients understand their unconscious role in problems and reclaim lost aspects of identity and personal power.', 'Balance external pattern exploration with internal process questions: ''What happens inside you when...'' and ''What part of you gets lost when...'' Help clients see their power to change situations.', true, NOW(), NOW()),

-- TRUST & PSYCHOLOGICAL SAFETY CONSOLIDATED INSIGHTS (2 insights)

-- Trust & Psychological Safety - Strength Consolidated
(gen_random_uuid(), '86552202-948a-458e-81ac-4d15b7b82daf', 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '378c3fca-d674-469a-b8cd-45e818410a25', 'Solid foundation in creating basic safety with appropriate empathy and professional boundaries, enabling clients to share routine emotional experiences and personal challenges.', 'Build on safety-creation strength by developing deeper vulnerability honoring and resource state access to create containers for profound emotional processing and self-discovery.', 'Use current empathy skills while practicing deeper presence: ''Thank you for trusting me with this. What''s it like to share this with someone?'' Stay present with emotions rather than rushing to solutions.', true, NOW(), NOW()),

-- Trust & Psychological Safety - Weakness Consolidated
(gen_random_uuid(), '86552202-948a-458e-81ac-4d15b7b82daf', 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4', 'Tendency to move quickly past vulnerable moments toward problem-solving rather than staying present with difficult emotions long enough for full processing and integration.', 'Develop capacity to stay present with intense vulnerability without rushing to fix, and help clients access their resourceful state when stuck in self-doubt and overwhelming emotions.', 'Practice sitting with difficult emotions for 30 seconds before responding. Ask ''If you already knew the answer, what would it be?'' to help clients access their own thinking.', true, NOW(), NOW()),

-- DIRECT COMMUNICATION CONSOLIDATED INSIGHTS (2 insights)

-- Direct Communication - Strength Consolidated
(gen_random_uuid(), 'f77a29c6-ccff-4dd7-b964-57f809a113b0', 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '378c3fca-d674-469a-b8cd-45e818410a25', 'Good awareness of the importance of direct communication with solid instincts for maintaining relationships and avoiding unnecessarily confrontational approaches.', 'Build on relationship awareness by developing precise balance between clarity and warmth, especially when addressing behaviors that affect coaching effectiveness or relationship boundaries.', 'Use relationship sensitivity while practicing clearer communication: ''I value our work together, and I need to address...'' Combine directness with appreciation and collaborative problem-solving.', true, NOW(), NOW()),

-- Direct Communication - Weakness Consolidated
(gen_random_uuid(), 'f77a29c6-ccff-4dd7-b964-57f809a113b0', 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4', 'Tendency to either soften direct communication to preserve relationships or be direct in ways that feel confrontational, struggling to find collaborative approaches to difficult conversations.', 'Develop impact communication and collaborative problem-naming skills to address issues clearly while strengthening relationships and modeling healthy conflict resolution.', 'Practice formula: ''I''ve also noticed we''re cycling. What do you think is keeping us stuck here?'' Join clients in curiosity about problems rather than becoming defensive or avoidant.', true, NOW(), NOW());

COMMIT;

-- Validation Query
SELECT id, performance_insight, development_focus, practical_application, competency_id
FROM competency_consolidated_insights 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
ORDER BY competency_id;