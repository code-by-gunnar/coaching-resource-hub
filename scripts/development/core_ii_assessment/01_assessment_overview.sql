-- =============================================
-- CORE II INTERMEDIATE ASSESSMENT - ASSESSMENT OVERVIEW
-- =============================================
-- Table: assessment_overview
-- Description: Main assessment metadata and configuration
-- =============================================

BEGIN;

INSERT INTO assessment_overview (
    id, slug, title, description, framework, difficulty,
    estimated_duration, icon, is_active, sort_order,
    created_at, updated_at, question_count
) VALUES (
    '00000000-0000-0000-0000-000000000002',
    'core-intermediate',
    'Core Intermediate Coaching Assessment',
    'Advanced coaching skills assessment for intermediate practitioners focusing on emotional awareness, powerful questioning, and direct communication',
    'core',
    'intermediate',
    25,
    '📊',
    true,
    2,
    NOW(),
    NOW(),
    26
);

COMMIT;

-- Validation Query
SELECT id, slug, title, framework, difficulty, question_count, is_active
FROM assessment_overview 
WHERE id = '00000000-0000-0000-0000-000000000002';