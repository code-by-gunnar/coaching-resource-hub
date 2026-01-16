-- =============================================
-- CORE II INTERMEDIATE ASSESSMENT - COMPETENCY DISPLAY NAMES
-- =============================================
-- Table: competency_display_names
-- Description: 5 competency display names for Core II intermediate level
-- =============================================

BEGIN;

INSERT INTO competency_display_names (id, competency_key, display_name, is_active, created_at, description, framework_id) VALUES

('64888b9f-5c07-4bd1-affa-cc99a3bba77f', 'advanced_active_listening', 'Advanced Active Listening', true, NOW(), 'Multi-layered emotional processing and systemic pattern recognition for complex coaching scenarios', 'f83064ee-237c-45b1-9db6-e6212c195cdb'),

('2640accd-a78a-4ddc-9916-b756e07d2b1c', 'strategic_powerful_questions', 'Strategic Powerful Questions', true, NOW(), 'Sophisticated inquiry that reveals belief systems and challenges assumptions to create breakthrough moments', 'f83064ee-237c-45b1-9db6-e6212c195cdb'),

('6dddbf00-a782-4327-b751-71e18282b16c', 'creating_awareness', 'Creating Awareness', true, NOW(), 'Helping clients recognize patterns, discover blind spots, and shift perspectives to access new possibilities', 'f83064ee-237c-45b1-9db6-e6212c195cdb'),

('86552202-948a-458e-81ac-4d15b7b82daf', 'trust_psychological_safety', 'Trust & Psychological Safety', true, NOW(), 'Building deeper trust containers that allow clients to explore vulnerability and resistance safely', 'f83064ee-237c-45b1-9db6-e6212c195cdb'),

('f77a29c6-ccff-4dd7-b964-57f809a113b0', 'direct_communication', 'Direct Communication', true, NOW(), 'Clear, honest feedback and challenging conversations with compassion and professional boundaries', 'f83064ee-237c-45b1-9db6-e6212c195cdb');

COMMIT;

-- Validation Query
SELECT id, competency_key, display_name, is_active
FROM competency_display_names 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
AND competency_key IN ('advanced_active_listening', 'strategic_powerful_questions', 'creating_awareness', 'trust_psychological_safety', 'direct_communication')
ORDER BY competency_key;