-- =============================================
-- CORE II INTERMEDIATE ASSESSMENT - PERFORMANCE ANALYSIS
-- =============================================
-- Table: competency_performance_analysis
-- Description: 5 performance analyses for Core II intermediate level (one per competency)
-- 3-Tier Integration: Uses scoring_tier_id for tier-based performance insights
-- Scoring Tier: All analyses use developing tier (c7f1cecf-d491-4fb9-af2e-324154ed1c8f)
-- Universal Composable: Works with useUniversalAssessmentInsights.js for dynamic level support
-- =============================================

BEGIN;

-- Delete existing Core II performance analysis to avoid duplicates
DELETE FROM competency_performance_analysis 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

INSERT INTO competency_performance_analysis (id, analysis_text, is_active, sort_order, framework_id, assessment_level_id, competency_id, scoring_tier_id, created_at, updated_at) VALUES

-- ADVANCED ACTIVE LISTENING ANALYSES (3 tiers)

-- Weakness Analysis (0-49%)
(gen_random_uuid(), 'In listening scenarios, key elements were missed such as emotional layering and somatic awareness. You capture content but emotional undercurrents and body language cues require development. Focus on expanding from hearing words to understanding the complete client experience.', true, 1, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '64888b9f-5c07-4bd1-affa-cc99a3bba77f', '53f95a86-8ebb-4601-913f-8bc28ff2ad7d', NOW(), NOW()),

-- Developing Analysis (50-69%)
(gen_random_uuid(), 'Your listening shows good development in content tracking with growing emotional recognition. Growth focus: integrating multiple awareness layers simultaneously - practice noticing words, emotions, body language, and energy patterns together rather than sequentially. Work on developing somatic awareness and incongruence recognition.', true, 2, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '64888b9f-5c07-4bd1-affa-cc99a3bba77f', 'c7f1cecf-d491-4fb9-af2e-324154ed1c8f', NOW(), NOW()),

-- Strength Analysis (70-100%)
(gen_random_uuid(), 'Your active listening demonstrates strong multi-layered awareness - you consistently integrate content, emotions, and somatic information. Your ability to detect incongruence and honor emotional complexity helps clients access deeper truths about their experience.', true, 3, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '64888b9f-5c07-4bd1-affa-cc99a3bba77f', '60f1a478-70ae-44a8-8bda-afc728d37846', NOW(), NOW()),

-- STRATEGIC POWERFUL QUESTIONS ANALYSES (3 tiers)

-- Weakness Analysis (0-49%)
(gen_random_uuid(), 'In questioning scenarios, questions often stayed surface-level without accessing client belief systems. Development needed in belief inquiry and positive intent discovery to help clients understand deeper patterns rather than focusing on surface behaviors.', true, 4, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '2640accd-a78a-4ddc-9916-b756e07d2b1c', '53f95a86-8ebb-4601-913f-8bc28ff2ad7d', NOW(), NOW()),

-- Developing Analysis (50-69%)
(gen_random_uuid(), 'Good questioning instincts with developing use of open-ended approaches. Growth area: timing and depth - allowing more space after powerful questions and exploring belief systems. Focus on developing core drive questioning and positive intent discovery to access deeper client insights.', true, 5, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '2640accd-a78a-4ddc-9916-b756e07d2b1c', 'c7f1cecf-d491-4fb9-af2e-324154ed1c8f', NOW(), NOW()),

-- Strength Analysis (70-100%)
(gen_random_uuid(), 'Your questioning demonstrates sophisticated belief system exploration with excellent timing and depth. You skillfully use belief inquiry and core drive questioning to help clients understand the positive intent behind challenging patterns, creating profound awareness shifts.', true, 6, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '2640accd-a78a-4ddc-9916-b756e07d2b1c', '60f1a478-70ae-44a8-8bda-afc728d37846', NOW(), NOW()),

-- CREATING AWARENESS ANALYSES (3 tiers)

-- Weakness Analysis (0-49%)
(gen_random_uuid(), 'In awareness scenarios, opportunities to explore strength-shadow dynamics and self-role recognition were missed. Development needed in helping clients see their unconscious contributions to patterns rather than focusing only on external factors.', true, 7, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '6dddbf00-a782-4327-b751-71e18282b16c', '53f95a86-8ebb-4601-913f-8bc28ff2ad7d', NOW(), NOW()),

-- Developing Analysis (50-69%)
(gen_random_uuid(), 'Good foundation in helping clients recognize patterns with developing perspective-shifting skills. Growth focus: helping clients see both their strengths'' shadow sides and their unconscious contributions to problems. Work on strength-shadow recognition and self-role awareness.', true, 8, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '6dddbf00-a782-4327-b751-71e18282b16c', 'c7f1cecf-d491-4fb9-af2e-324154ed1c8f', NOW(), NOW()),

-- Strength Analysis (70-100%)
(gen_random_uuid(), 'Your awareness creation shows exceptional skill in strength-shadow recognition and self-role awareness. You masterfully help clients discover their unconscious contributions to relationship dynamics, empowering them to change patterns from within rather than trying to control others.', true, 9, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '6dddbf00-a782-4327-b751-71e18282b16c', '60f1a478-70ae-44a8-8bda-afc728d37846', NOW(), NOW()),

-- TRUST & PSYCHOLOGICAL SAFETY ANALYSES (3 tiers)

-- Weakness Analysis (0-49%)
(gen_random_uuid(), 'In trust scenarios, opportunities to honor vulnerability and create psychological safety were missed. Development needed in emotional normalization and resource state access to help clients feel safe with difficult emotions and self-doubt.', true, 10, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '86552202-948a-458e-81ac-4d15b7b82daf', '53f95a86-8ebb-4601-913f-8bc28ff2ad7d', NOW(), NOW()),

-- Developing Analysis (50-69%)
(gen_random_uuid(), 'Good instincts for creating safe space with developing empathy and boundary-keeping. Growth area: staying present with difficult emotions without rushing to fix or normalize the experience. Focus on vulnerability honoring and resource state access skills.', true, 11, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '86552202-948a-458e-81ac-4d15b7b82daf', 'c7f1cecf-d491-4fb9-af2e-324154ed1c8f', NOW(), NOW()),

-- Strength Analysis (70-100%)
(gen_random_uuid(), 'Your trust creation demonstrates exceptional vulnerability honoring and resource state access. You skillfully normalize difficult emotions while helping clients access their inner wisdom and strength, creating profound psychological safety for breakthrough conversations.', true, 12, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '86552202-948a-458e-81ac-4d15b7b82daf', '60f1a478-70ae-44a8-8bda-afc728d37846', NOW(), NOW()),

-- DIRECT COMMUNICATION ANALYSES (3 tiers)

-- Weakness Analysis (0-49%)
(gen_random_uuid(), 'In direct communication scenarios, opportunities for impact communication and pattern confrontation were missed. Development needed in collaborative problem-naming to address issues while preserving relationship connection and warmth.', true, 13, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', 'f77a29c6-ccff-4dd7-b964-57f809a113b0', '53f95a86-8ebb-4601-913f-8bc28ff2ad7d', NOW(), NOW()),

-- Developing Analysis (50-69%)
(gen_random_uuid(), 'Good awareness of the need for direct communication with appropriate respect for relationships. Growth focus: finding the balance between directness and warmth when addressing problematic patterns. Work on impact communication and collaborative problem-naming skills.', true, 14, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', 'f77a29c6-ccff-4dd7-b964-57f809a113b0', 'c7f1cecf-d491-4fb9-af2e-324154ed1c8f', NOW(), NOW()),

-- Strength Analysis (70-100%)
(gen_random_uuid(), 'Your direct communication shows exceptional balance of impact and warmth. You masterfully use pattern confrontation and collaborative problem-naming to address difficult topics while strengthening rather than damaging the coaching relationship.', true, 15, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', 'f77a29c6-ccff-4dd7-b964-57f809a113b0', '60f1a478-70ae-44a8-8bda-afc728d37846', NOW(), NOW());

COMMIT;

-- Validation Query
SELECT id, analysis_text, sort_order, competency_id, scoring_tier_id
FROM competency_performance_analysis 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
ORDER BY sort_order;