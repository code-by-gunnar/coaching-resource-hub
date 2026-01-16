-- ====================================================================
-- CREATE COMPETENCY-FOCUSED LEARNING PATH STRUCTURE
-- ====================================================================
-- Purpose: Create 4 competency-focused learning buckets that map to the 7 core competencies
-- Each bucket will have diverse resource types (books, courses, audio, references)
-- ====================================================================

-- First, deactivate all current categories
UPDATE learning_path_categories SET is_active = false;

-- Create the 4 new competency-focused learning buckets
INSERT INTO learning_path_categories (id, category_title, category_description, category_icon, priority_order, is_active) VALUES
(gen_random_uuid(), '🗣️ Communication & Questioning', 'Master active listening and powerful questioning techniques for deeper client connections', '🗣️', 1, true),
(gen_random_uuid(), '🧘 Presence & Awareness', 'Develop mindful presence and awareness skills to create breakthrough coaching moments', '🧘', 2, true), 
(gen_random_uuid(), '🤝 Relationship & Trust Building', 'Build strong coaching relationships through trust, safety, and direct communication', '🤝', 3, true),
(gen_random_uuid(), '📈 Progress & Foundation', 'Structure coaching conversations and manage client progress effectively', '📈', 4, true);

-- Get the new category IDs for resource mapping
-- Communication & Questioning bucket
INSERT INTO learning_resources (
    id, category_id, title, description, resource_type, url, 
    author_instructor, competency_areas, is_active
) VALUES 
(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = '🗣️ Communication & Questioning'), 
 'Co-Active Coaching (Fourth Edition)', 
 'The foundational book on coaching communication and questioning techniques',
 'book', 'https://www.amazon.com/Co-Active-Coaching-Fourth-Changing-Business/dp/1473674840',
 'Laura Whitworth, Karen Kimsey-House, Henry Kimsey-House, Phillip Sandahl',
 ARRAY['Active Listening', 'Powerful Questions'], 
 true),

(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = '🗣️ Communication & Questioning'), 
 'The Art of Powerful Questions', 
 'Essential guide to crafting questions that create awareness and insight',
 'reference', 'https://theart.ofpowerfulquestions.com',
 'Eric Vogt, Juanita Brown, David Isaacs',
 ARRAY['Powerful Questions'], 
 true),

(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = '🗣️ Communication & Questioning'), 
 'Active Listening Masterclass', 
 'Comprehensive online course for developing advanced listening skills',
 'course', 'https://example.com/listening-course',
 'International Coach Academy',
 ARRAY['Active Listening'], 
 true),

(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = '🗣️ Communication & Questioning'), 
 'The Coaching Conversation Audio Series', 
 'Audio training on communication patterns and questioning techniques',
 'audio', 'https://example.com/audio-series',
 'Center for Executive Coaching',
 ARRAY['Active Listening', 'Powerful Questions'], 
 true);

-- Presence & Awareness bucket
INSERT INTO learning_resources (
    id, category_id, title, description, resource_type, url, 
    author_instructor, competency_areas, is_active
) VALUES 
(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = '🧘 Presence & Awareness'), 
 'The Power of Now', 
 'Foundational text on present moment awareness and mindful presence',
 'book', 'https://www.amazon.com/Power-Now-Guide-Spiritual-Enlightenment/dp/1577314808',
 'Eckhart Tolle',
 ARRAY['Present Moment Awareness'], 
 true),

(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = '🧘 Presence & Awareness'), 
 'Mindful Coaching Certification', 
 'Professional certification program in presence-based coaching',
 'course', 'https://example.com/mindful-coaching',
 'Center for Mindful Coaching',
 ARRAY['Present Moment Awareness', 'Creating Awareness'], 
 true),

(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = '🧘 Presence & Awareness'), 
 'Guided Presence Practice for Coaches', 
 'Audio meditations and presence exercises specifically for coaching professionals',
 'audio', 'https://example.com/presence-audio',
 'Mindful Schools',
 ARRAY['Present Moment Awareness'], 
 true),

(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = '🧘 Presence & Awareness'), 
 'The Handbook of Coaching Psychology', 
 'Academic reference on awareness and insight creation in coaching',
 'reference', 'https://example.com/psychology-handbook',
 'Stephen Palmer, Alison Whybrow',
 ARRAY['Creating Awareness'], 
 true);

-- Relationship & Trust Building bucket  
INSERT INTO learning_resources (
    id, category_id, title, description, resource_type, url, 
    author_instructor, competency_areas, is_active
) VALUES 
(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = '🤝 Relationship & Trust Building'), 
 'Difficult Conversations: How to Discuss What Matters Most', 
 'Essential skills for navigating challenging coaching conversations with care',
 'book', 'https://www.amazon.com/Difficult-Conversations-Discuss-What-Matters/dp/0143118447',
 'Douglas Stone, Bruce Patton, Sheila Heen',
 ARRAY['Direct Communication', 'Trust & Safety'], 
 true),

(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = '🤝 Relationship & Trust Building'), 
 'Trust-Based Coaching Relationships', 
 'Online course on building psychological safety and trust in coaching',
 'course', 'https://example.com/trust-coaching',
 'International Coaching Federation',
 ARRAY['Trust & Safety'], 
 true),

(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = '🤝 Relationship & Trust Building'), 
 'Crucial Conversations Audio Training', 
 'Audio program for mastering direct, honest communication',
 'audio', 'https://example.com/crucial-conversations',
 'VitalSmarts',
 ARRAY['Direct Communication'], 
 true),

(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = '🤝 Relationship & Trust Building'), 
 'Psychological Safety Research Compendium', 
 'Research-based reference on creating safe spaces for growth',
 'reference', 'https://example.com/psych-safety',
 'Amy Edmondson, Harvard Business School',
 ARRAY['Trust & Safety'], 
 true);

-- Progress & Foundation bucket
INSERT INTO learning_resources (
    id, category_id, title, description, resource_type, url, 
    author_instructor, competency_areas, is_active
) VALUES 
(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = '📈 Progress & Foundation'), 
 'The Coaching Habit: Say Less, Ask More & Change the Way You Lead Forever', 
 'Practical guide to structuring coaching conversations and managing progress',
 'book', 'https://www.amazon.com/Coaching-Habit-Less-Change-Forever/dp/0978440749',
 'Michael Bungay Stanier',
 ARRAY['Managing Progress'], 
 true),

(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = '📈 Progress & Foundation'), 
 'Coaching Foundations Certificate Program', 
 'Comprehensive foundation course covering core coaching methodology',
 'course', 'https://example.com/foundations-course',
 'Coach Training Alliance',
 ARRAY['Managing Progress'], 
 true),

(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = '📈 Progress & Foundation'), 
 'Goal Setting and Accountability Audio Workshop', 
 'Audio training on effective progress tracking and accountability systems',
 'audio', 'https://example.com/goal-setting',
 'Franklin Covey',
 ARRAY['Managing Progress'], 
 true),

(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = '📈 Progress & Foundation'), 
 'ICF Core Competencies Reference Guide', 
 'Official reference for coaching competency standards and progress measurement',
 'reference', 'https://coachingfederation.org/core-competencies',
 'International Coaching Federation',
 ARRAY['Managing Progress'], 
 true);

-- Verify the new structure
SELECT 'New competency-focused learning structure:' as status;
SELECT category_title, category_description, priority_order,
    (SELECT COUNT(*) FROM learning_resources WHERE category_id = lpc.id AND is_active = true) as resource_count
FROM learning_path_categories lpc 
WHERE is_active = true 
ORDER BY priority_order;