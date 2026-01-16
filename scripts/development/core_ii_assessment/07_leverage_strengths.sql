-- =============================================
-- CORE II INTERMEDIATE ASSESSMENT - LEVERAGE STRENGTHS
-- =============================================
-- Table: competency_leverage_strengths
-- Description: 10 leverage strengths for Core II intermediate level (all 70-100 range)
-- 3-Tier Integration: Uses scoring_tier_id for direct strength tier content delivery
-- Scoring Tier: All actions use strength tier (60f1a478-70ae-44a8-8bda-afc728d37846)
-- Frontend Integration: Only shown to high performers (70-100% competency scores)
-- =============================================

BEGIN;

-- Delete existing Core II leverage strengths to avoid duplicates
DELETE FROM competency_leverage_strengths 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

INSERT INTO competency_leverage_strengths (id, leverage_text, scoring_tier_id, priority_order, is_active, created_at, framework_id, assessment_level_id, competency_id) VALUES

-- ADVANCED ACTIVE LISTENING STRENGTHS (2 strengths)

-- Strength 1
(gen_random_uuid(), 'Your natural ability to hear multiple emotional layers simultaneously creates powerful moments where clients feel truly understood beyond their surface concerns, building deep trust and connection that enables breakthrough conversations.', '60f1a478-70ae-44a8-8bda-afc728d37846', 1, true, NOW(), 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '64888b9f-5c07-4bd1-affa-cc99a3bba77f'),

-- Strength 2
(gen_random_uuid(), 'Excellent instinct for recognizing when clients'' words don''t match their energy or body language, allowing you to gently explore incongruence and help them access authentic feelings they may be protecting or hiding.', '60f1a478-70ae-44a8-8bda-afc728d37846', 2, true, NOW(), 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '64888b9f-5c07-4bd1-affa-cc99a3bba77f'),

-- STRATEGIC POWERFUL QUESTIONS STRENGTHS (2 strengths)

-- Strength 3
(gen_random_uuid(), 'Strong skill at connecting client behaviors to underlying belief systems, helping them understand why they do what they do rather than just focusing on surface-level change that doesn''t address root causes.', '60f1a478-70ae-44a8-8bda-afc728d37846', 1, true, NOW(), 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '2640accd-a78a-4ddc-9916-b756e07d2b1c'),

-- Strength 4
(gen_random_uuid(), 'Natural ability to challenge either/or thinking and open up both/and possibilities, expanding clients'' perspective beyond limiting binary choices that keep them stuck in impossible decisions.', '60f1a478-70ae-44a8-8bda-afc728d37846', 2, true, NOW(), 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '2640accd-a78a-4ddc-9916-b756e07d2b1c'),

-- CREATING AWARENESS STRENGTHS (2 strengths)

-- Strength 5
(gen_random_uuid(), 'Excellent at helping clients discover how their strengths create blind spots, recognizing that always being responsible prevents them from experiencing personal enjoyment and spontaneity without guilt.', '60f1a478-70ae-44a8-8bda-afc728d37846', 1, true, NOW(), 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '6dddbf00-a782-4327-b751-71e18282b16c'),

-- Strength 6
(gen_random_uuid(), 'Strong ability to help clients see their unconscious contribution to relationship dynamics, empowering them to change patterns by shifting their own behavior rather than trying to control others.', '60f1a478-70ae-44a8-8bda-afc728d37846', 2, true, NOW(), 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '6dddbf00-a782-4327-b751-71e18282b16c'),

-- TRUST & PSYCHOLOGICAL SAFETY STRENGTHS (2 strengths)

-- Strength 7
(gen_random_uuid(), 'Natural ability to honor vulnerability without rushing to fix allows clients to stay present with difficult emotions about loneliness and social struggles, building self-acceptance through witnessed experience.', '60f1a478-70ae-44a8-8bda-afc728d37846', 1, true, NOW(), 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '86552202-948a-458e-81ac-4d15b7b82daf'),

-- Strength 8
(gen_random_uuid(), 'Excellent at helping clients access their resourceful state when stuck in self-doubt, supporting them in trusting their own knowing about important life decisions rather than seeking external validation.', '60f1a478-70ae-44a8-8bda-afc728d37846', 2, true, NOW(), 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '86552202-948a-458e-81ac-4d15b7b82daf'),

-- DIRECT COMMUNICATION STRENGTHS (2 strengths)

-- Strength 9
(gen_random_uuid(), 'Strong ability to communicate impact directly without blame or defensiveness, clearly stating how behaviors affect the coaching relationship while maintaining professional respect and genuine care.', '60f1a478-70ae-44a8-8bda-afc728d37846', 1, true, NOW(), 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', 'f77a29c6-ccff-4dd7-b964-57f809a113b0'),

-- Strength 10
(gen_random_uuid(), 'Excellent at being direct while preserving relationship warmth, addressing difficult topics like payment issues while expressing genuine value for the coaching relationship and the person''s growth.', '60f1a478-70ae-44a8-8bda-afc728d37846', 2, true, NOW(), 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', 'f77a29c6-ccff-4dd7-b964-57f809a113b0');

COMMIT;

-- Validation Query
SELECT id, leverage_text, scoring_tier_id, priority_order, competency_id
FROM competency_leverage_strengths 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
ORDER BY competency_id, priority_order;