-- =============================================
-- CORE II INTERMEDIATE ASSESSMENT - LEARNING PATH CATEGORIES
-- =============================================
-- Table: learning_path_categories
-- Description: 5 learning path categories for Core II intermediate level (one per competency)
-- Category-First System: Provides meaningful topic organization instead of generic tier names
-- Frontend Integration: Users see "Somatic & Multi-Layered Listening" not "Developing Resources"
-- =============================================

BEGIN;

-- Delete existing Core II learning path categories to avoid duplicates
DELETE FROM learning_path_categories 
WHERE assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

INSERT INTO learning_path_categories (id, category_title, category_description, category_icon, competency_areas, priority_order, is_active, created_at, assessment_level_id) VALUES

-- Advanced Active Listening
(gen_random_uuid(), 'Somatic & Multi-Layered Listening', 'Develop integrated listening skills that track words, emotions, body language, and energy patterns simultaneously for deeper client understanding', '👂', ARRAY['Advanced Active Listening','Somatic Awareness','Incongruence Detection'], 1, true, NOW(), 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'),

-- Strategic Powerful Questions
(gen_random_uuid(), 'Belief Systems & Deep Inquiry', 'Master sophisticated questioning techniques that explore underlying beliefs, core drives, and the positive intent behind client patterns', '❓', ARRAY['Strategic Powerful Questions','Belief Inquiry','Positive Intent Discovery'], 2, true, NOW(), 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'),

-- Creating Awareness
(gen_random_uuid(), 'Shadow Work & Self-Role Recognition', 'Help clients discover how their strengths create blind spots and understand their unconscious contribution to patterns', '💡', ARRAY['Creating Awareness','Shadow Work','Internal Process Awareness'], 3, true, NOW(), 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'),

-- Trust & Psychological Safety
(gen_random_uuid(), 'Vulnerability & Trauma-Informed Coaching', 'Build skills in honoring vulnerability without rushing to fix and helping clients access their resourceful state', '🛡️', ARRAY['Trust & Psychological Safety','Vulnerability Honoring','Resource State Access'], 4, true, NOW(), 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'),

-- Direct Communication
(gen_random_uuid(), 'Crucial Conversations & Feedback Mastery', 'Develop precise balance between clarity and warmth when addressing difficult topics and giving feedback', '💬', ARRAY['Direct Communication','Impact Communication','Collaborative Problem-Naming'], 5, true, NOW(), 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c');

COMMIT;

-- Validation Query
SELECT id, category_title, category_description, category_icon, competency_areas, priority_order
FROM learning_path_categories 
WHERE assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
ORDER BY priority_order;