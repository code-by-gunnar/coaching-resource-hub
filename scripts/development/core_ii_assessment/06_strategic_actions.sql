-- =============================================
-- CORE II INTERMEDIATE ASSESSMENT - STRATEGIC ACTIONS
-- =============================================
-- Table: competency_strategic_actions
-- Description: 20 strategic actions for Core II intermediate level across 4 score ranges
-- 3-Tier Integration: Uses scoring_tier_id for direct tier-based content delivery
-- Scoring Tiers: weakness (53f95a86) | developing (c7f1cecf) | strength (60f1a478) 
-- Frontend Integration: Universal composables query by scoring_tier_id for personalized actions
-- =============================================

BEGIN;

-- Delete existing Core II strategic actions to avoid duplicates
DELETE FROM competency_strategic_actions 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

INSERT INTO competency_strategic_actions (id, action_text, scoring_tier_id, priority_order, is_active, created_at, sort_order, framework_id, assessment_level_id, competency_id) VALUES

-- WEAKNESS TIER (0-49% performance) - 5 actions

-- Action 1 (Advanced Active Listening)
(gen_random_uuid(), 'Practice listening for one emotion beneath the surface emotion. When clients share frustration, ask yourself ''What else might be here?'' and gently explore with ''I hear the frustration... what else comes up for you?''', '53f95a86-8ebb-4601-913f-8bc28ff2ad7d', 1, true, NOW(), 1, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '64888b9f-5c07-4bd1-affa-cc99a3bba77f'),

-- Action 2 (Strategic Powerful Questions)
(gen_random_uuid(), 'Start connecting behaviors to beliefs with simple language: ''How does this pattern serve you?'' or ''What belief might this behavior be protecting?'' Help clients see the belief-behavior connection.', '53f95a86-8ebb-4601-913f-8bc28ff2ad7d', 2, true, NOW(), 2, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '2640accd-a78a-4ddc-9916-b756e07d2b1c'),

-- Action 3 (Creating Awareness)
(gen_random_uuid(), 'When clients minimize their strengths, practice asking: ''What might your helpfulness be preventing you from experiencing?'' Help them see how strengths can create blind spots.', '53f95a86-8ebb-4601-913f-8bc28ff2ad7d', 3, true, NOW(), 3, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '6dddbf00-a782-4327-b751-71e18282b16c'),

-- Action 4 (Trust & Psychological Safety)
(gen_random_uuid(), 'When clients share something vulnerable, pause and acknowledge: ''Thank you for trusting me with this.'' Stay present for three breaths before responding to honor their courage.', '53f95a86-8ebb-4601-913f-8bc28ff2ad7d', 4, true, NOW(), 4, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '86552202-948a-458e-81ac-4d15b7b82daf'),

-- Action 5 (Direct Communication)
(gen_random_uuid(), 'Practice naming patterns you observe: ''I notice when we approach deeper topics, you tend to use humor. What do you notice about that?'' State observations without interpretation.', '53f95a86-8ebb-4601-913f-8bc28ff2ad7d', 5, true, NOW(), 5, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', 'f77a29c6-ccff-4dd7-b964-57f809a113b0'),

-- DEVELOPING TIER (50-69% performance) - 5 actions

-- Action 6 (Advanced Active Listening)
(gen_random_uuid(), 'Track emotional coherence across complex sharing. When clients jump between topics, listen for the connecting feeling: ''I hear several concerns, and underneath I sense something about belonging. What do you notice?''', 'c7f1cecf-d491-4fb9-af2e-324154ed1c8f', 1, true, NOW(), 6, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '64888b9f-5c07-4bd1-affa-cc99a3bba77f'),

-- Action 7 (Strategic Powerful Questions)
(gen_random_uuid(), 'Challenge either/or thinking with both/and possibilities: ''What if both things are true - you can be grateful AND want something different?'' Help clients expand beyond limiting binary choices.', 'c7f1cecf-d491-4fb9-af2e-324154ed1c8f', 2, true, NOW(), 7, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '2640accd-a78a-4ddc-9916-b756e07d2b1c'),

-- Action 8 (Creating Awareness)
(gen_random_uuid(), 'Help clients notice their internal experience: ''What happens inside you when you think about being vulnerable with your spouse?'' Focus on internal awareness rather than relationship advice.', 'c7f1cecf-d491-4fb9-af2e-324154ed1c8f', 3, true, NOW(), 8, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '6dddbf00-a782-4327-b751-71e18282b16c'),

-- Action 9 (Trust & Psychological Safety)
(gen_random_uuid(), 'When clients share shame, honor their courage: ''It takes courage to share something this personal. What does it feel like to say this out loud?'' Stay with their brave act of sharing.', 'c7f1cecf-d491-4fb9-af2e-324154ed1c8f', 4, true, NOW(), 9, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '86552202-948a-458e-81ac-4d15b7b82daf'),

-- Action 10 (Direct Communication)
(gen_random_uuid(), 'Practice direct communication while preserving warmth: ''I value our work together, and I need to address the payment situation directly.'' State needs clearly with relationship appreciation.', 'c7f1cecf-d491-4fb9-af2e-324154ed1c8f', 5, true, NOW(), 10, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', 'f77a29c6-ccff-4dd7-b964-57f809a113b0'),

-- DEVELOPING TIER (50-69% performance) - 5 actions

-- Action 11 (Advanced Active Listening)
(gen_random_uuid(), 'Notice body language shifts and integrate with verbal content: ''I notice your posture changed when you talked about your living space. What''s happening in your body right now?'' Connect words with physical presence.', 'c7f1cecf-d491-4fb9-af2e-324154ed1c8f', 1, true, NOW(), 11, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '64888b9f-5c07-4bd1-affa-cc99a3bba77f'),

-- Action 12 (Strategic Powerful Questions)
(gen_random_uuid(), 'Help clients reframe problems as information: ''What if your pattern of starting and stopping is actually perfect information about what you need?'' Show them how struggles contain valuable data.', 'c7f1cecf-d491-4fb9-af2e-324154ed1c8f', 2, true, NOW(), 12, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '2640accd-a78a-4ddc-9916-b756e07d2b1c'),

-- Action 13 (Creating Awareness)
(gen_random_uuid(), 'Help clients see their unconscious contribution: ''How might you be unconsciously enabling this dynamic?'' Empower them to change patterns by shifting their own behavior.', 'c7f1cecf-d491-4fb9-af2e-324154ed1c8f', 3, true, NOW(), 13, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '6dddbf00-a782-4327-b751-71e18282b16c'),

-- Action 14 (Trust & Psychological Safety)
(gen_random_uuid(), 'Address self-interruption in real-time: ''What just happened there? I noticed you stopped yourself from sharing something real.'' Bring awareness to self-protective patterns.', 'c7f1cecf-d491-4fb9-af2e-324154ed1c8f', 4, true, NOW(), 14, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '86552202-948a-458e-81ac-4d15b7b82daf'),

-- Action 15 (Direct Communication)
(gen_random_uuid(), 'Communicate impact directly: ''Your lateness and phone use are affecting our work together.'' State behavioral impact clearly without blame or softening.', 'c7f1cecf-d491-4fb9-af2e-324154ed1c8f', 5, true, NOW(), 15, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', 'f77a29c6-ccff-4dd7-b964-57f809a113b0'),

-- STRENGTH TIER (70-100% performance) - 5 actions

-- Action 16 (Advanced Active Listening)
(gen_random_uuid(), 'Reflect complex systemic patterns in real-time: ''What I''m hearing is a cycle where your need to be productive creates the very disconnection from creativity you''re mourning.'' Help clients see multi-layered cause-effect systems.', '60f1a478-70ae-44a8-8bda-afc728d37846', 1, true, NOW(), 16, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '64888b9f-5c07-4bd1-affa-cc99a3bba77f'),

-- Action 17 (Strategic Powerful Questions)
(gen_random_uuid(), 'Find protective functions behind seemingly negative patterns: ''How is perfectionism trying to take care of you?'' Help clients discover insights in their symptoms and resistance.', '60f1a478-70ae-44a8-8bda-afc728d37846', 2, true, NOW(), 17, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '2640accd-a78a-4ddc-9916-b756e07d2b1c'),

-- Action 18 (Creating Awareness)
(gen_random_uuid(), 'Help clients reconnect with lost parts: ''What part of you gets lost when you focus on having things instead of being secure?'' Guide them back to forgotten aspects of identity.', '60f1a478-70ae-44a8-8bda-afc728d37846', 3, true, NOW(), 18, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '6dddbf00-a782-4327-b751-71e18282b16c'),

-- Action 19 (Trust & Psychological Safety)
(gen_random_uuid(), 'Help clients access their resourceful state: ''If you already knew the answer about your direction, what would it be?'' Support them in trusting their own thinking and capabilities.', '60f1a478-70ae-44a8-8bda-afc728d37846', 4, true, NOW(), 19, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '86552202-948a-458e-81ac-4d15b7b82daf'),

-- Action 20 (Direct Communication)
(gen_random_uuid(), 'Join clients in curiosity about process issues: ''I''ve also noticed we''re cycling. What do you think is keeping us stuck here?'' Become partners in solving coaching challenges together.', '60f1a478-70ae-44a8-8bda-afc728d37846', 5, true, NOW(), 20, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', 'f77a29c6-ccff-4dd7-b964-57f809a113b0');

COMMIT;

-- Validation Query
SELECT id, action_text, scoring_tier_id, priority_order, sort_order, competency_id
FROM competency_strategic_actions 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
ORDER BY sort_order;