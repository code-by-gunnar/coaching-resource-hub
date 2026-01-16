-- ====================================================================
-- LEARNING PATH CATEGORIES AND RESOURCES - CORE I BEGINNER
-- ====================================================================
-- Purpose: Create comprehensive learning resources for each competency area
-- Categories: Books, Articles, Courses, Exercises, Videos, Assessments
-- ====================================================================

-- ====================================================================
-- LEARNING PATH CATEGORIES
-- ====================================================================

-- Active Listening Learning Categories
INSERT INTO learning_path_categories (competency_area, category_name, description, framework, difficulty_level, sort_order) VALUES
('Active Listening', 'Foundational Reading', 'Essential books and articles on listening skills development', 'core', 'beginner', 1),
('Active Listening', 'Practical Exercises', 'Hands-on activities to develop listening presence and skills', 'core', 'beginner', 2),
('Active Listening', 'Online Training', 'Structured courses and workshops for listening skill development', 'core', 'beginner', 3),
('Active Listening', 'Self-Assessment Tools', 'Tools to evaluate and track your listening skill progress', 'core', 'beginner', 4);

-- Powerful Questions Learning Categories  
INSERT INTO learning_path_categories (competency_area, category_name, description, framework, difficulty_level, sort_order) VALUES
('Powerful Questions', 'Foundational Reading', 'Key resources on the art and science of powerful questioning', 'core', 'beginner', 1),
('Powerful Questions', 'Question Banks', 'Collections of powerful questions organized by coaching situation', 'core', 'beginner', 2),
('Powerful Questions', 'Practice Exercises', 'Structured activities to develop your questioning skills', 'core', 'beginner', 3),
('Powerful Questions', 'Online Training', 'Courses focused on developing powerful questioning abilities', 'core', 'beginner', 4);

-- Present Moment Awareness Learning Categories
INSERT INTO learning_path_categories (competency_area, category_name, description, framework, difficulty_level, sort_order) VALUES
('Present Moment Awareness', 'Mindfulness Resources', 'Books and practices for developing present-moment awareness', 'core', 'beginner', 1),
('Present Moment Awareness', 'Somatic Training', 'Body-based approaches to coaching presence and awareness', 'core', 'beginner', 2),
('Present Moment Awareness', 'Meditation & Practices', 'Daily practices to strengthen your presence and awareness', 'core', 'beginner', 3),
('Present Moment Awareness', 'Energy Work Training', 'Learning to read and work with energy and intuition', 'core', 'beginner', 4);

-- Creating Awareness Learning Categories
INSERT INTO learning_path_categories (competency_area, category_name, description, framework, difficulty_level, sort_order) VALUES
('Creating Awareness', 'Pattern Recognition Training', 'Developing skills in noticing patterns and themes', 'core', 'beginner', 1),
('Creating Awareness', 'Observation Skills', 'Learning to share observations that create insight', 'core', 'beginner', 2),
('Creating Awareness', 'Breakthrough Techniques', 'Methods for helping clients see new perspectives', 'core', 'beginner', 3),
('Creating Awareness', 'Advanced Coaching Skills', 'Higher-level interventions for awareness creation', 'core', 'beginner', 4);

-- Direct Communication Learning Categories  
INSERT INTO learning_path_categories (competency_area, category_name, description, framework, difficulty_level, sort_order) VALUES
('Direct Communication', 'Communication Fundamentals', 'Core principles of clear, direct communication', 'core', 'beginner', 1),
('Direct Communication', 'Difficult Conversations', 'Skills for navigating challenging communication', 'core', 'beginner', 2),
('Direct Communication', 'Boundary Setting', 'Learning to communicate boundaries clearly and kindly', 'core', 'beginner', 3),
('Direct Communication', 'Feedback & Confrontation', 'Giving direct feedback that serves growth', 'core', 'beginner', 4);

-- Trust & Safety Learning Categories
INSERT INTO learning_path_categories (competency_area, category_name, description, framework, difficulty_level, sort_order) VALUES
('Trust & Safety', 'Trust Building Fundamentals', 'Core principles of creating psychological safety', 'core', 'beginner', 1),
('Trust & Safety', 'Confidentiality & Ethics', 'Understanding coaching ethics and confidentiality', 'core', 'beginner', 2),
('Trust & Safety', 'Trauma-Informed Coaching', 'Creating safety for clients with trauma backgrounds', 'core', 'beginner', 3),
('Trust & Safety', 'Vulnerability & Authenticity', 'Modeling and encouraging authentic sharing', 'core', 'beginner', 4);

-- Managing Progress Learning Categories
INSERT INTO learning_path_categories (competency_area, category_name, description, framework, difficulty_level, sort_order) VALUES
('Managing Progress', 'Accountability Systems', 'Creating supportive accountability structures', 'core', 'beginner', 1),
('Managing Progress', 'Goal Setting & Tracking', 'Effective methods for setting and tracking progress', 'core', 'beginner', 2),
('Managing Progress', 'Obstacle Navigation', 'Helping clients work through barriers and setbacks', 'core', 'beginner', 3),
('Managing Progress', 'Motivation & Engagement', 'Keeping clients motivated and engaged in their growth', 'core', 'beginner', 4);

-- ====================================================================
-- LEARNING RESOURCES
-- ====================================================================

-- Active Listening Resources
INSERT INTO learning_resources (competency_area, category_name, resource_title, resource_type, description, url, framework, difficulty_level, sort_order) VALUES
-- Foundational Reading
('Active Listening', 'Foundational Reading', 'Co-Active Coaching (Chapter 3: Listening)', 'book', 'The classic coaching text with excellent content on Level 1, 2, and 3 listening', 'https://www.amazon.com/Co-Active-Coaching-Fourth-Henry-Kimsey-House/dp/1473674948', 'core', 'beginner', 1),
('Active Listening', 'Foundational Reading', 'The Art of Listening in Coaching', 'article', 'Comprehensive overview of listening skills for new coaches', 'https://www.coachingworld.com/article/the-art-of-listening', 'core', 'beginner', 2),
('Active Listening', 'Foundational Reading', 'Deep Listening: Impact, Healing and Reconciliation', 'book', 'Profound exploration of listening as a transformational tool', 'https://www.amazon.com/Deep-Listening-Impact-Healing-Reconciliation/dp/0595214902', 'core', 'beginner', 3),

-- Practical Exercises
('Active Listening', 'Practical Exercises', 'Daily Level 2 Listening Practice', 'exercise', '10-minute daily practice focusing entirely on others without planning responses', NULL, 'core', 'beginner', 1),
('Active Listening', 'Practical Exercises', 'Reflection Practice Exercise', 'exercise', 'Practice paraphrasing content and emotions using "It sounds like..." and "You seem to be feeling..."', NULL, 'core', 'beginner', 2),
('Active Listening', 'Practical Exercises', 'Presence Check-In Exercise', 'exercise', 'Regular self-check on where your attention is during conversations', NULL, 'core', 'beginner', 3),

-- Online Training
('Active Listening', 'Online Training', 'ICF Core Competency: Active Listening', 'course', 'Comprehensive course on developing active listening as a core coaching competency', 'https://www.coachfederation.org/core-competencies', 'core', 'beginner', 1),
('Active Listening', 'Online Training', 'Mindful Listening for Coaches', 'course', 'Integration of mindfulness principles with coaching listening skills', 'https://www.coachingworld.com/mindful-listening', 'core', 'beginner', 2),

-- Powerful Questions Resources
('Powerful Questions', 'Foundational Reading', 'The Art of Powerful Questions', 'article', 'Classic resource on crafting questions that create breakthrough insights', 'https://www.theworldcafe.com/wp-content/uploads/2015/07/Powerful-Questions-2003.pdf', 'core', 'beginner', 1),
('Powerful Questions', 'Foundational Reading', 'Clean Language: Revealing Metaphors', 'book', 'Advanced questioning techniques using Clean Language methodology', 'https://www.amazon.com/Clean-Language-Revealing-Metaphors-Opening/dp/0953875008', 'core', 'beginner', 2),

-- Question Banks
('Powerful Questions', 'Question Banks', 'Essential Coaching Questions by Category', 'resource', 'Organized collection of powerful questions for different coaching situations', NULL, 'core', 'beginner', 1),
('Powerful Questions', 'Question Banks', 'Values-Based Questions Collection', 'resource', 'Questions specifically designed to help clients connect with their core values', NULL, 'core', 'beginner', 2),
('Powerful Questions', 'Question Banks', 'Future-Focused Question Bank', 'resource', 'Questions that help clients explore possibilities and potential', NULL, 'core', 'beginner', 3),

-- Practice Exercises
('Powerful Questions', 'Practice Exercises', 'Open vs Closed Question Transform', 'exercise', 'Practice converting closed questions to open-ended exploration', NULL, 'core', 'beginner', 1),
('Powerful Questions', 'Practice Exercises', 'Daily Question Challenge', 'exercise', 'Ask one powerful question each day and notice the impact', NULL, 'core', 'beginner', 2),

-- Present Moment Awareness Resources
('Present Moment Awareness', 'Mindfulness Resources', 'The Power of Now for Coaches', 'book', 'Foundational text on presence and mindfulness in professional practice', 'https://www.amazon.com/Power-Now-Guide-Spiritual-Enlightenment/dp/1577314808', 'core', 'beginner', 1),
('Present Moment Awareness', 'Mindfulness Resources', 'Mindful Coaching: How to Be Present', 'article', 'Practical application of mindfulness principles in coaching relationships', 'https://www.coachingworld.com/mindful-coaching', 'core', 'beginner', 2),

-- Somatic Training
('Present Moment Awareness', 'Somatic Training', 'Somatic Coaching Fundamentals', 'course', 'Introduction to body-based coaching and somatic awareness', 'https://www.strozziinstitute.com/somatic-coaching/', 'core', 'beginner', 1),
('Present Moment Awareness', 'Somatic Training', 'Reading Energy in Coaching', 'workshop', 'Learning to notice and work with energy dynamics in coaching', NULL, 'core', 'beginner', 2),

-- Meditation & Practices  
('Present Moment Awareness', 'Meditation & Practices', 'Daily Presence Practice', 'exercise', '5-minute daily meditation to strengthen present-moment awareness', NULL, 'core', 'beginner', 1),
('Present Moment Awareness', 'Meditation & Practices', 'Body Scan for Coaches', 'exercise', 'Regular body awareness practice to enhance somatic coaching skills', NULL, 'core', 'beginner', 2),

-- Creating Awareness Resources
('Creating Awareness', 'Pattern Recognition Training', 'Seeing Patterns in Coaching', 'article', 'How to notice and work with recurring themes in client conversations', 'https://www.coachingworld.com/pattern-recognition', 'core', 'beginner', 1),
('Creating Awareness', 'Pattern Recognition Training', 'Theme Tracking Exercise', 'exercise', 'Systematic approach to identifying patterns across coaching sessions', NULL, 'core', 'beginner', 2),

-- Observation Skills
('Creating Awareness', 'Observation Skills', 'The Art of Observation in Coaching', 'article', 'Developing skills in noticing and sharing what you observe', NULL, 'core', 'beginner', 1),
('Creating Awareness', 'Observation Skills', 'Curiosity-Based Observation Practice', 'exercise', 'Practice sharing observations with curiosity rather than interpretation', NULL, 'core', 'beginner', 2),

-- Direct Communication Resources
('Direct Communication', 'Communication Fundamentals', 'Difficult Conversations: How to Discuss What Matters Most', 'book', 'Essential skills for navigating challenging conversations with skill', 'https://www.amazon.com/Difficult-Conversations-Discuss-What-Matters/dp/0143118447', 'core', 'beginner', 1),
('Direct Communication', 'Communication Fundamentals', 'Nonviolent Communication for Coaches', 'book', 'Framework for direct, compassionate communication', 'https://www.amazon.com/Nonviolent-Communication-Language-Life-Changing-Relationships/dp/189200528X', 'core', 'beginner', 2),

-- Difficult Conversations
('Direct Communication', 'Difficult Conversations', 'Bottom-Lining Technique', 'exercise', 'Practice summarizing core issues when clients talk in circles', NULL, 'core', 'beginner', 1),
('Direct Communication', 'Difficult Conversations', 'Respectful Interruption Practice', 'exercise', 'Learn to redirect conversations respectfully using "Can we pause here?"', NULL, 'core', 'beginner', 2),

-- Trust & Safety Resources
('Trust & Safety', 'Trust Building Fundamentals', 'Building Trust in Coaching Relationships', 'article', 'Core principles for creating psychological safety with clients', 'https://www.coachingworld.com/building-trust', 'core', 'beginner', 1),
('Trust & Safety', 'Trust Building Fundamentals', 'The Trust Equation for Coaches', 'resource', 'Framework for understanding and building trust systematically', NULL, 'core', 'beginner', 2),

-- Confidentiality & Ethics
('Trust & Safety', 'Confidentiality & Ethics', 'ICF Code of Ethics', 'resource', 'Official ICF ethical guidelines including confidentiality standards', 'https://www.coachfederation.org/ethics', 'core', 'beginner', 1),
('Trust & Safety', 'Confidentiality & Ethics', 'Confidentiality Agreement Template', 'resource', 'Template for creating clear confidentiality agreements with clients', NULL, 'core', 'beginner', 2),

-- Managing Progress Resources
('Managing Progress', 'Accountability Systems', 'Creating Supportive Accountability', 'article', 'Framework for accountability that motivates rather than punishes', 'https://www.coachingworld.com/supportive-accountability', 'core', 'beginner', 1),
('Managing Progress', 'Accountability Systems', 'The Accountability Partner Method', 'resource', 'Structured approach to co-creating accountability with clients', NULL, 'core', 'beginner', 2),

-- Goal Setting & Tracking
('Managing Progress', 'Goal Setting & Tracking', 'SMART Goals for Coaching', 'article', 'Adapting SMART goal framework for coaching relationships', NULL, 'core', 'beginner', 1),
('Managing Progress', 'Goal Setting & Tracking', 'Progress Tracking Templates', 'resource', 'Tools and templates for monitoring client progress effectively', NULL, 'core', 'beginner', 2),

-- Obstacle Navigation  
('Managing Progress', 'Obstacle Navigation', 'Exploring Obstacles with Curiosity', 'exercise', 'Practice asking "What got in the way?" with genuine curiosity', NULL, 'core', 'beginner', 1),
('Managing Progress', 'Obstacle Navigation', 'Barrier Identification Technique', 'exercise', 'Systematic approach to identifying and addressing progress barriers', NULL, 'core', 'beginner', 2);

SELECT 
    'Learning path data populated successfully' as status,
    (SELECT COUNT(*) FROM learning_path_categories WHERE framework = 'core' AND difficulty_level = 'beginner') as categories,
    (SELECT COUNT(*) FROM learning_resources WHERE framework = 'core' AND difficulty_level = 'beginner') as resources;