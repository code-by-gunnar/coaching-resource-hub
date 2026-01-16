-- =============================================
-- CORE II INTERMEDIATE ASSESSMENT - SKILL TAGS (REFINED)
-- =============================================
-- Table: skill_tags
-- Description: 15 essential skill tags for Core II intermediate level (3 per competency)
-- Refinement: Reduced from 26 to 15 tags to prevent information overload
-- Focus: Most critical skills for intermediate coaching development
-- =============================================

BEGIN;

-- Delete existing Core II skill tags to avoid duplicates
DELETE FROM skill_tags 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

INSERT INTO skill_tags (id, name, sort_order, is_active, framework_id, assessment_level_id, competency_id) VALUES

-- ADVANCED ACTIVE LISTENING (3 essential skills)
(gen_random_uuid(), 'Emotional Layering', 1, true, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '64888b9f-5c07-4bd1-affa-cc99a3bba77f'),
(gen_random_uuid(), 'Somatic Listening', 2, true, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '64888b9f-5c07-4bd1-affa-cc99a3bba77f'),
(gen_random_uuid(), 'Incongruence Detection', 3, true, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '64888b9f-5c07-4bd1-affa-cc99a3bba77f'),

-- STRATEGIC POWERFUL QUESTIONS (3 essential skills)
(gen_random_uuid(), 'Belief Inquiry', 4, true, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '2640accd-a78a-4ddc-9916-b756e07d2b1c'),
(gen_random_uuid(), 'Core Drive Questioning', 5, true, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '2640accd-a78a-4ddc-9916-b756e07d2b1c'),
(gen_random_uuid(), 'Positive Intent Discovery', 6, true, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '2640accd-a78a-4ddc-9916-b756e07d2b1c'),

-- CREATING AWARENESS (3 essential skills)
(gen_random_uuid(), 'Strength-Shadow Recognition', 7, true, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '6dddbf00-a782-4327-b751-71e18282b16c'),
(gen_random_uuid(), 'Self-Role Recognition', 8, true, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '6dddbf00-a782-4327-b751-71e18282b16c'),
(gen_random_uuid(), 'Internal Process Awareness', 9, true, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '6dddbf00-a782-4327-b751-71e18282b16c'),

-- TRUST & PSYCHOLOGICAL SAFETY (3 essential skills)
(gen_random_uuid(), 'Vulnerability Honoring', 10, true, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '86552202-948a-458e-81ac-4d15b7b82daf'),
(gen_random_uuid(), 'Resource State Access', 11, true, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '86552202-948a-458e-81ac-4d15b7b82daf'),
(gen_random_uuid(), 'Emotional Normalization', 12, true, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', '86552202-948a-458e-81ac-4d15b7b82daf'),

-- DIRECT COMMUNICATION (3 essential skills)
(gen_random_uuid(), 'Impact Communication', 13, true, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', 'f77a29c6-ccff-4dd7-b964-57f809a113b0'),
(gen_random_uuid(), 'Pattern Confrontation', 14, true, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', 'f77a29c6-ccff-4dd7-b964-57f809a113b0'),
(gen_random_uuid(), 'Collaborative Problem-Naming', 15, true, 'f83064ee-237c-45b1-9db6-e6212c195cdb', 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c', 'f77a29c6-ccff-4dd7-b964-57f809a113b0');

COMMIT;

-- Validation Query
SELECT id, name, sort_order, is_active, competency_id
FROM skill_tags 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
ORDER BY sort_order;

-- Count by competency 
SELECT 
    cdn.display_name,
    COUNT(st.id) as skill_count
FROM skill_tags st
JOIN competency_display_names cdn ON st.competency_id = cdn.id
WHERE st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
GROUP BY cdn.display_name
ORDER BY cdn.display_name;