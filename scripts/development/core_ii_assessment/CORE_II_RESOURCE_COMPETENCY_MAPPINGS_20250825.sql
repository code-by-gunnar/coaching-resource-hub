-- ============================================================================
-- CORE II LEARNING RESOURCE COMPETENCY MAPPINGS - PRODUCTION FIX
-- Date: 2025-08-25
-- Purpose: Create missing competency mappings for Core II learning resources
-- Issue: Learning resources not showing because they're not mapped to competencies
-- Solution: Map all 25 Core II resources to appropriate competencies
-- ============================================================================

BEGIN;

-- Core II Competency IDs:
-- 64888b9f-5c07-4bd1-affa-cc99a3bba77f = Advanced Active Listening
-- 2640accd-a78a-4ddc-9916-b756e07d2b1c = Strategic Powerful Questions  
-- 6dddbf00-a782-4327-b751-71e18282b16c = Creating Awareness
-- 86552202-948a-458e-81ac-4d15b7b82daf = Trust & Psychological Safety
-- f77a29c6-ccff-4dd7-b964-57f809a113b0 = Direct Communication

-- ============================================================================
-- ADVANCED ACTIVE LISTENING RESOURCES
-- ============================================================================

-- Somatic & listening-focused resources
INSERT INTO learning_resource_competencies (id, learning_resource_id, competency_id, created_at) VALUES
(gen_random_uuid(), '3d995641-c7db-4182-94f6-590cca1eae62', '64888b9f-5c07-4bd1-affa-cc99a3bba77f', NOW()), -- The Body Keeps the Score
(gen_random_uuid(), '79eac1b5-6268-42be-af0a-8651ed570b6f', '64888b9f-5c07-4bd1-affa-cc99a3bba77f', NOW()), -- Somatic Coaching  
(gen_random_uuid(), 'f450246b-0f3c-4c26-be16-17d0cb3b90ea', '64888b9f-5c07-4bd1-affa-cc99a3bba77f', NOW()), -- Presence-Based Coaching
(gen_random_uuid(), '86c11fa4-e4dc-4d17-a58b-656e5dc87553', '64888b9f-5c07-4bd1-affa-cc99a3bba77f', NOW()), -- Presence-Based Coaching Foundations
(gen_random_uuid(), 'ab84c04c-ea20-4bae-b1ab-13347d95ecfc', '64888b9f-5c07-4bd1-affa-cc99a3bba77f', NOW()); -- Somatic Coaching Fundamentals

-- ============================================================================
-- STRATEGIC POWERFUL QUESTIONS RESOURCES  
-- ============================================================================

-- Question-focused and inquiry resources
INSERT INTO learning_resource_competencies (id, learning_resource_id, competency_id, created_at) VALUES
(gen_random_uuid(), 'de6b5e26-063f-4c69-a796-24a1c20937a9', '2640accd-a78a-4ddc-9916-b756e07d2b1c', NOW()), -- The Power of Listening
(gen_random_uuid(), 'c20cdbbd-53f7-4627-9f81-bfcc7cb552ec', '2640accd-a78a-4ddc-9916-b756e07d2b1c', NOW()), -- Full Spectrum Listening Practice
(gen_random_uuid(), '04ea09ae-e1ce-40bd-b2ca-a5cb109f5ef1', '2640accd-a78a-4ddc-9916-b756e07d2b1c', NOW()), -- The Art of Powerful Questions
(gen_random_uuid(), 'c0f11493-e0c5-4585-a309-d70b8c3a7d7b', '2640accd-a78a-4ddc-9916-b756e07d2b1c', NOW()), -- Questions That Work
(gen_random_uuid(), '72cabb91-ab0c-411c-a67c-f2c717016840', '2640accd-a78a-4ddc-9916-b756e07d2b1c', NOW()); -- Clean Language for Coaches

-- ============================================================================
-- CREATING AWARENESS RESOURCES
-- ============================================================================

-- Awareness, shadow work, and inquiry resources  
INSERT INTO learning_resource_competencies (id, learning_resource_id, competency_id, created_at) VALUES
(gen_random_uuid(), '35975b9d-e076-460c-a6d9-5ea7432fc3b5', '6dddbf00-a782-4327-b751-71e18282b16c', NOW()), -- Appreciative Inquiry Coach Training
(gen_random_uuid(), '31d2c2a8-0a7a-4cd8-9865-37908bc7f725', '6dddbf00-a782-4327-b751-71e18282b16c', NOW()), -- One Powerful Question Challenge
(gen_random_uuid(), '0deed178-285c-49da-931a-84cc17e1667e', '6dddbf00-a782-4327-b751-71e18282b16c', NOW()), -- Embracing Our Selves
(gen_random_uuid(), 'd3ddb795-51c4-483d-8293-75964fa04845', '6dddbf00-a782-4327-b751-71e18282b16c', NOW()), -- No Bad Parts
(gen_random_uuid(), '6f66c3bc-38e0-4f97-b9af-eb6021aa6990', '6dddbf00-a782-4327-b751-71e18282b16c', NOW()); -- Gestalt Coaching Training

-- ============================================================================ 
-- TRUST & PSYCHOLOGICAL SAFETY RESOURCES
-- ============================================================================

-- Vulnerability, trauma-informed, and safety resources
INSERT INTO learning_resource_competencies (id, learning_resource_id, competency_id, created_at) VALUES
(gen_random_uuid(), '2753cc25-8156-4847-8a83-27afbb7f068d', '86552202-948a-458e-81ac-4d15b7b82daf', NOW()), -- Strength-Shadow Exploration
(gen_random_uuid(), 'c1f19abe-7626-41c5-a603-24fde6e5959a', '86552202-948a-458e-81ac-4d15b7b82daf', NOW()), -- Daring Greatly
(gen_random_uuid(), 'e2d6f389-b4b1-4534-95d7-9c5bd700df8b', '86552202-948a-458e-81ac-4d15b7b82daf', NOW()), -- Hold Me Tight
(gen_random_uuid(), '0b4fa09a-cb67-447f-a42b-6a214d176a53', '86552202-948a-458e-81ac-4d15b7b82daf', NOW()), -- Trauma-Informed Coaching Certification
(gen_random_uuid(), '9435240d-091a-4cab-bfee-30f67fe77612', '86552202-948a-458e-81ac-4d15b7b82daf', NOW()); -- Vulnerability Honoring Practice

-- ============================================================================
-- DIRECT COMMUNICATION RESOURCES
-- ============================================================================

-- Communication, feedback, and difficult conversation resources
INSERT INTO learning_resource_competencies (id, learning_resource_id, competency_id, created_at) VALUES
(gen_random_uuid(), 'f0743e1f-46cd-4f1a-9671-214a5d8fff12', 'f77a29c6-ccff-4dd7-b964-57f809a113b0', NOW()), -- Crucial Conversations
(gen_random_uuid(), '6a77b75a-9275-4ea0-bdf1-b1e8483dba41', 'f77a29c6-ccff-4dd7-b964-57f809a113b0', NOW()), -- Nonviolent Communication
(gen_random_uuid(), '383eb9ad-6644-498e-b07b-57a4ef41864d', 'f77a29c6-ccff-4dd7-b964-57f809a113b0', NOW()), -- Thanks for the Feedback
(gen_random_uuid(), 'b971c1c2-63ed-4b24-bfd5-8cb56c9e11c1', 'f77a29c6-ccff-4dd7-b964-57f809a113b0', NOW()), -- Crucial Conversations Training
(gen_random_uuid(), '89fe9aef-d4f7-4864-9a1c-01433119cacb', 'f77a29c6-ccff-4dd7-b964-57f809a113b0', NOW()); -- Impact Communication Practice

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify mappings created
SELECT 'RESOURCE COMPETENCY MAPPINGS CREATED:' as status;
SELECT 
    cdn.display_name as competency,
    COUNT(lrc.learning_resource_id) as mapped_resources
FROM competency_display_names cdn
LEFT JOIN learning_resource_competencies lrc ON cdn.id = lrc.competency_id
WHERE cdn.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
AND cdn.id IN (
    '64888b9f-5c07-4bd1-affa-cc99a3bba77f', -- Advanced Active Listening
    '2640accd-a78a-4ddc-9916-b756e07d2b1c', -- Strategic Powerful Questions
    '6dddbf00-a782-4327-b751-71e18282b16c', -- Creating Awareness  
    '86552202-948a-458e-81ac-4d15b7b82daf', -- Trust & Psychological Safety
    'f77a29c6-ccff-4dd7-b964-57f809a113b0'  -- Direct Communication
)
GROUP BY cdn.id, cdn.display_name
ORDER BY cdn.display_name;

SELECT '🎉 CORE II RESOURCE COMPETENCY MAPPINGS COMPLETED!' as final_status;