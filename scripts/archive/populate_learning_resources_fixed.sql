-- ====================================================================
-- LEARNING PATH CATEGORIES AND RESOURCES - CORE I BEGINNER - FIXED
-- ====================================================================
-- Purpose: Create comprehensive learning resources for Core I Beginner assessment
-- Categories: Books, Articles, Courses, Exercises, Videos, Assessments
-- ====================================================================

-- ====================================================================
-- LEARNING PATH CATEGORIES
-- ====================================================================

-- Foundational Reading Category
INSERT INTO learning_path_categories (category_title, category_description, category_icon, competency_areas, priority_order) VALUES
('📚 Foundational Reading', 'Essential books and articles for developing core coaching competencies', '📚', 
ARRAY['Active Listening', 'Powerful Questions', 'Present Moment Awareness', 'Creating Awareness', 'Direct Communication', 'Trust & Safety', 'Managing Progress'], 1);

-- Practical Exercises Category
INSERT INTO learning_path_categories (category_title, category_description, category_icon, competency_areas, priority_order) VALUES
('🎯 Practical Exercises', 'Hands-on activities to develop and practice coaching skills', '🎯', 
ARRAY['Active Listening', 'Powerful Questions', 'Present Moment Awareness', 'Creating Awareness', 'Direct Communication', 'Trust & Safety', 'Managing Progress'], 2);

-- Online Training Category
INSERT INTO learning_path_categories (category_title, category_description, category_icon, competency_areas, priority_order) VALUES
('💻 Online Training', 'Structured courses and workshops for skill development', '💻', 
ARRAY['Active Listening', 'Powerful Questions', 'Present Moment Awareness', 'Creating Awareness', 'Direct Communication', 'Trust & Safety', 'Managing Progress'], 3);

-- Assessment Tools Category
INSERT INTO learning_path_categories (category_title, category_description, category_icon, competency_areas, priority_order) VALUES
('📊 Assessment Tools', 'Tools to evaluate and track your coaching skill progress', '📊', 
ARRAY['Active Listening', 'Powerful Questions', 'Present Moment Awareness', 'Creating Awareness', 'Direct Communication', 'Trust & Safety', 'Managing Progress'], 4);

-- Specialized Training Category
INSERT INTO learning_path_categories (category_title, category_description, category_icon, competency_areas, priority_order) VALUES
('🎓 Specialized Training', 'Advanced and specialized coaching training programs', '🎓', 
ARRAY['Present Moment Awareness', 'Creating Awareness', 'Trust & Safety'], 5);

-- ====================================================================
-- LEARNING RESOURCES
-- ====================================================================

-- Get category IDs for references
-- We'll use the category_id in the learning_resources table

-- Foundational Reading Resources
INSERT INTO learning_resources (category_id, title, description, resource_type, url, competency_areas) 
SELECT lpc.id, 'Co-Active Coaching (Fourth Edition)', 'The definitive guide to coaching with excellent chapters on listening, questioning, and coaching presence', 'book', 'https://www.amazon.com/Co-Active-Coaching-Fourth-Henry-Kimsey-House/dp/1473674948', 
ARRAY['Active Listening', 'Powerful Questions', 'Present Moment Awareness']
FROM learning_path_categories lpc WHERE lpc.category_title = '📚 Foundational Reading';

INSERT INTO learning_resources (category_id, title, description, resource_type, url, competency_areas) 
SELECT lpc.id, 'The Art of Powerful Questions', 'Classic resource on crafting questions that create breakthrough insights and awareness', 'article', 'https://www.theworldcafe.com/wp-content/uploads/2015/07/Powerful-Questions-2003.pdf', 
ARRAY['Powerful Questions', 'Creating Awareness'], 2
FROM learning_path_categories lpc WHERE lpc.category_title = '📚 Foundational Reading';

INSERT INTO learning_resources (category_id, title, description, resource_type, url, competency_areas) 
SELECT lpc.id, 'Difficult Conversations: How to Discuss What Matters Most', 'Essential skills for navigating challenging conversations with skill and care', 'book', 'https://www.amazon.com/Difficult-Conversations-Discuss-What-Matters/dp/0143118447', 
ARRAY['Direct Communication', 'Trust & Safety'], 3
FROM learning_path_categories lpc WHERE lpc.category_title = '📚 Foundational Reading';

INSERT INTO learning_resources (category_id, title, description, resource_type, url, competency_areas) 
SELECT lpc.id, 'The Power of Now for Coaches', 'Foundational text on presence and mindfulness in coaching relationships', 'book', 'https://www.amazon.com/Power-Now-Guide-Spiritual-Enlightenment/dp/1577314808', 
ARRAY['Present Moment Awareness'], 4
FROM learning_path_categories lpc WHERE lpc.category_title = '📚 Foundational Reading';

INSERT INTO learning_resources (category_id, title, description, resource_type, url, competency_areas) 
SELECT lpc.id, 'Nonviolent Communication: A Language of Life', 'Framework for direct, compassionate communication that builds trust', 'book', 'https://www.amazon.com/Nonviolent-Communication-Language-Life-Changing-Relationships/dp/189200528X', 
ARRAY['Direct Communication', 'Trust & Safety'], 5
FROM learning_path_categories lpc WHERE lpc.category_title = '📚 Foundational Reading';

-- Practical Exercises Resources
INSERT INTO learning_resources (category_id, title, description, resource_type, competency_areas) 
SELECT lpc.id, 'Daily Level 2 Listening Practice', '10-minute daily practice focusing entirely on others without planning responses', 'exercise', 
ARRAY['Active Listening'], 1
FROM learning_path_categories lpc WHERE lpc.category_title = '🎯 Practical Exercises';

INSERT INTO learning_resources (category_id, title, description, resource_type, competency_areas) 
SELECT lpc.id, 'Reflection Practice Exercise', 'Practice paraphrasing content and emotions using "It sounds like..." and "You seem to be feeling..."', 'exercise', 
ARRAY['Active Listening'], 2
FROM learning_path_categories lpc WHERE lpc.category_title = '🎯 Practical Exercises';

INSERT INTO learning_resources (category_id, title, description, resource_type, competency_areas) 
SELECT lpc.id, 'Open vs Closed Question Transform', 'Practice converting closed questions to open-ended exploration questions', 'exercise', 
ARRAY['Powerful Questions'], 3
FROM learning_path_categories lpc WHERE lpc.category_title = '🎯 Practical Exercises';

INSERT INTO learning_resources (category_id, title, description, resource_type, competency_areas) 
SELECT lpc.id, 'Daily Question Challenge', 'Ask one powerful question each day and notice the impact on conversations', 'exercise', 
ARRAY['Powerful Questions'], 4
FROM learning_path_categories lpc WHERE lpc.category_title = '🎯 Practical Exercises';

INSERT INTO learning_resources (category_id, title, description, resource_type, competency_areas) 
SELECT lpc.id, 'Body Scan for Coaches', 'Regular body awareness practice to enhance somatic coaching skills and presence', 'exercise', 
ARRAY['Present Moment Awareness'], 5
FROM learning_path_categories lpc WHERE lpc.category_title = '🎯 Practical Exercises';

INSERT INTO learning_resources (category_id, title, description, resource_type, competency_areas) 
SELECT lpc.id, 'Pattern Recognition Exercise', 'Systematic approach to identifying themes and patterns across coaching sessions', 'exercise', 
ARRAY['Creating Awareness'], 6
FROM learning_path_categories lpc WHERE lpc.category_title = '🎯 Practical Exercises';

INSERT INTO learning_resources (category_id, title, description, resource_type, competency_areas) 
SELECT lpc.id, 'Bottom-Lining Practice', 'Practice summarizing core issues when clients talk in circles: "So the core issue seems to be..."', 'exercise', 
ARRAY['Direct Communication'], 7
FROM learning_path_categories lpc WHERE lpc.category_title = '🎯 Practical Exercises';

INSERT INTO learning_resources (category_id, title, description, resource_type, competency_areas) 
SELECT lpc.id, 'Confidentiality Agreement Creation', 'Practice creating clear confidentiality agreements that build trust with clients', 'exercise', 
ARRAY['Trust & Safety'], 8
FROM learning_path_categories lpc WHERE lpc.category_title = '🎯 Practical Exercises';

INSERT INTO learning_resources (category_id, title, description, resource_type, competency_areas) 
SELECT lpc.id, 'Curiosity-Based Accountability', 'Practice asking "What got in the way?" with genuine curiosity when clients don''t follow through', 'exercise', 
ARRAY['Managing Progress'], 9
FROM learning_path_categories lpc WHERE lpc.category_title = '🎯 Practical Exercises';

-- Online Training Resources
INSERT INTO learning_resources (category_id, title, description, resource_type, url, competency_areas) 
SELECT lpc.id, 'ICF Core Competency Training', 'Comprehensive courses on all ICF core competencies including active listening and powerful questions', 'course', 'https://www.coachfederation.org/core-competencies', 
ARRAY['Active Listening', 'Powerful Questions', 'Creating Awareness', 'Direct Communication'], 1
FROM learning_path_categories lpc WHERE lpc.category_title = '💻 Online Training';

INSERT INTO learning_resources (category_id, title, description, resource_type, url, competency_areas) 
SELECT lpc.id, 'Mindful Coaching Certification', 'Integration of mindfulness principles with coaching for enhanced presence and awareness', 'course', 'https://www.mindfulschools.org/mindful-coaching/', 
ARRAY['Present Moment Awareness', 'Trust & Safety'], 2
FROM learning_path_categories lpc WHERE lpc.category_title = '💻 Online Training';

INSERT INTO learning_resources (category_id, title, description, resource_type, url, competency_areas) 
SELECT lpc.id, 'Clean Language Training', 'Advanced questioning techniques using Clean Language methodology for creating awareness', 'course', 'https://www.cleanlanguage.co.uk/training/', 
ARRAY['Powerful Questions', 'Creating Awareness'], 3
FROM learning_path_categories lpc WHERE lpc.category_title = '💻 Online Training';

-- Assessment Tools Resources
INSERT INTO learning_resources (category_id, title, description, resource_type, competency_areas) 
SELECT lpc.id, 'Core I Beginner Self-Assessment', 'Complete this assessment to evaluate your current competency levels and track progress', 'assessment', 
ARRAY['Active Listening', 'Powerful Questions', 'Present Moment Awareness', 'Creating Awareness', 'Direct Communication', 'Trust & Safety', 'Managing Progress'], 1
FROM learning_path_categories lpc WHERE lpc.category_title = '📊 Assessment Tools';

INSERT INTO learning_resources (category_id, title, description, resource_type, competency_areas) 
SELECT lpc.id, 'Listening Skills Self-Evaluation', 'Detailed assessment of your active listening abilities with specific feedback', 'assessment', 
ARRAY['Active Listening'], 2
FROM learning_path_categories lpc WHERE lpc.category_title = '📊 Assessment Tools';

INSERT INTO learning_resources (category_id, title, description, resource_type, competency_areas) 
SELECT lpc.id, 'Coaching Presence Assessment', 'Evaluate your present moment awareness and coaching presence skills', 'assessment', 
ARRAY['Present Moment Awareness'], 3
FROM learning_path_categories lpc WHERE lpc.category_title = '📊 Assessment Tools';

-- Specialized Training Resources
INSERT INTO learning_resources (category_id, title, description, resource_type, url, competency_areas) 
SELECT lpc.id, 'Somatic Coaching Certification', 'Body-based coaching approaches that enhance present moment awareness and intuition', 'course', 'https://www.strozziinstitute.com/somatic-coaching/', 
ARRAY['Present Moment Awareness', 'Creating Awareness'], 1
FROM learning_path_categories lpc WHERE lpc.category_title = '🎓 Specialized Training';

INSERT INTO learning_resources (category_id, title, description, resource_type, url, competency_areas) 
SELECT lpc.id, 'Trauma-Informed Coaching Training', 'Creating safety and building trust with clients who have trauma backgrounds', 'course', 'https://www.traumainformedoregon.org/trauma-informed-coaching/', 
ARRAY['Trust & Safety'], 2
FROM learning_path_categories lpc WHERE lpc.category_title = '🎓 Specialized Training';

SELECT 
    'Learning path data populated successfully' as status,
    (SELECT COUNT(*) FROM learning_path_categories WHERE is_active = true) as categories,
    (SELECT COUNT(*) FROM learning_resources WHERE is_active = true) as resources;