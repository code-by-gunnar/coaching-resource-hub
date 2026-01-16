-- =============================================
-- CORE II INTERMEDIATE ASSESSMENT - LEARNING RESOURCES (FIXED)
-- =============================================
-- Table: learning_resources
-- Description: Comprehensive learning resources for Core II intermediate level with proper FK relationships
-- Category-First System: Resources linked to learning path categories via category_id
-- Personalized Analysis Types: Resources assigned based on difficulty level
--   • Weakness (b2f61b8d): Foundations, Fundamentals courses for beginners
--   • Developing (a287b894): Training, Certification, Practice exercises for skill building  
--   • Strength (378c3fca): Advanced books by experts, Mastery-level content for high performers
-- Tier Integration: Works with useTieredResources.js for personalized recommendations
-- =============================================

BEGIN;

-- Delete existing Core II learning resources to avoid duplicates
DELETE FROM learning_resources 
WHERE framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
AND assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

-- Insert learning resources using dynamic category_id lookup with personalized analysis_type_id
-- Note: If analysis_type_id column doesn't exist, remove it from INSERT and SELECT
INSERT INTO learning_resources (id, category_id, title, description, url, author_instructor, is_active, created_at, framework_id, assessment_level_id, resource_type_id, analysis_type_id)

-- Get learning path categories and resource types first, then cross join with resource data
SELECT 
    gen_random_uuid() as id,
    lpc.id as category_id,
    resources.title,
    resources.description,
    resources.url,
    resources.author_instructor,
    true as is_active,
    NOW() as created_at,
    'f83064ee-237c-45b1-9db6-e6212c195cdb' as framework_id,
    'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c' as assessment_level_id,
    rt.id as resource_type_id,
    resources.analysis_type_id::uuid
FROM learning_path_categories lpc
CROSS JOIN resource_types rt
CROSS JOIN (
    VALUES
    -- Advanced Active Listening resources (Somatic & Multi-Layered Listening category)
    ('378c3fca-d674-469a-b8cd-45e818410a25', 'Somatic & Multi-Layered Listening', 'book', 'The Body Keeps the Score', 'Essential reading for understanding somatic awareness and trauma-informed coaching approaches to help clients access deeper truths', 'https://www.amazon.com/Body-Keeps-Score-Healing-Trauma/dp/0670785938', 'Bessel van der Kolk'),
    
    ('378c3fca-d674-469a-b8cd-45e818410a25', 'Somatic & Multi-Layered Listening', 'book', 'Somatic Coaching', 'Comprehensive guide to integrating body awareness with coaching conversations for deeper client connection', 'https://www.amazon.com/Somatic-Coaching-Richard-Strozzi-Heckler/dp/1556439393', 'Richard Strozzi-Heckler'),
    
    ('378c3fca-d674-469a-b8cd-45e818410a25', 'Somatic & Multi-Layered Listening', 'book', 'Presence-Based Coaching', 'Master the art of presence and multi-channel awareness in coaching conversations', 'https://www.amazon.com/Presence-Based-Coaching-Cultivating-Awareness-Responsibility/dp/0787974005', 'Doug Silsbee'),
    
    ('b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4', 'Somatic & Multi-Layered Listening', 'course', 'Presence-Based Coaching Foundations', 'Foundational course for developing embodied coaching presence and somatic awareness', 'https://pbcinstitute.com', 'Doug Silsbee/PBC Institute'),
    
    ('b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4', 'Somatic & Multi-Layered Listening', 'course', 'Somatic Coaching Fundamentals', 'Virtual intensive program for developing somatic coaching skills and body awareness', 'https://strozziinstitute.com', 'Strozzi Institute'),
    
    ('a287b894-c573-4b5e-978a-5ab17b4d290d', 'Somatic & Multi-Layered Listening', 'video', 'The Power of Listening', 'TEDx talk exploring the transformative power of deep listening in human connection', 'https://www.youtube.com/watch?v=saXfavo1OQo', 'William Ury'),
    
    ('a287b894-c573-4b5e-978a-5ab17b4d290d', 'Somatic & Multi-Layered Listening', 'exercise', 'Full Spectrum Listening Practice', 'Daily 10-minute practice to track words, emotions, body sensations, and energy simultaneously for enhanced coaching presence', '', 'Core II Assessment Team'),
    
    -- Strategic Powerful Questions resources (Belief Systems & Deep Inquiry category)
    ('378c3fca-d674-469a-b8cd-45e818410a25', 'Belief Systems & Deep Inquiry', 'book', 'The Art of Powerful Questions', 'Comprehensive guide to crafting questions that catalyze insight, innovation, and breakthrough awareness', 'https://www.theworldcafe.com/key-concepts-resources/world-cafe-method/powerful-questions/', 'Eric Vogt, Juanita Brown, David Isaacs'),
    
    ('a287b894-c573-4b5e-978a-5ab17b4d290d', 'Belief Systems & Deep Inquiry', 'book', 'Questions That Work', 'Practical guide to asking the right questions for maximum impact in coaching conversations', 'https://www.amazon.com/Questions-That-Work-Dorothy-Leeds/dp/0814472818', 'Dorothy Leeds'),
    
    ('a287b894-c573-4b5e-978a-5ab17b4d290d', 'Belief Systems & Deep Inquiry', 'course', 'Clean Language for Coaches', 'Master Clean Language techniques for exploring client belief systems without imposing your own framework', 'https://cleanlearning.co.uk', 'Clean Learning'),
    
    ('a287b894-c573-4b5e-978a-5ab17b4d290d', 'Belief Systems & Deep Inquiry', 'course', 'Appreciative Inquiry Coach Training', 'Learn to ask questions that focus on strengths and positive possibilities for transformation', 'https://www.appreciativeinquiry.case.edu/', 'Various AI Providers'),
    
    ('a287b894-c573-4b5e-978a-5ab17b4d290d', 'Belief Systems & Deep Inquiry', 'exercise', 'One Powerful Question Challenge', 'Practice asking one deep question and exploring answers for 2-3 minutes before asking another, developing depth over breadth', '', 'Core II Assessment Team'),
    
    -- Creating Awareness resources (Shadow Work & Self-Role Recognition category)
    ('378c3fca-d674-469a-b8cd-45e818410a25', 'Shadow Work & Self-Role Recognition', 'book', 'Embracing Our Selves', 'Essential guide to understanding voice dialogue and the shadow aspects of personality in coaching relationships', 'https://www.amazon.com/Embracing-Our-Selves-Voice-Dialogue/dp/1577311353', 'Hal Stone & Sidra Stone'),
    
    ('378c3fca-d674-469a-b8cd-45e818410a25', 'Shadow Work & Self-Role Recognition', 'book', 'No Bad Parts', 'Introduction to Internal Family Systems for understanding and working with different parts of the self', 'https://www.amazon.com/No-Bad-Parts-Healing-Internal/dp/1683646680', 'Richard Schwartz'),
    
    ('a287b894-c573-4b5e-978a-5ab17b4d290d', 'Shadow Work & Self-Role Recognition', 'course', 'Gestalt Coaching Training', 'Learn Gestalt coaching methods for exploring present-moment experience and contact patterns', 'https://gestalt.org', 'Various Gestalt Institutes'),
    
    ('a287b894-c573-4b5e-978a-5ab17b4d290d', 'Shadow Work & Self-Role Recognition', 'exercise', 'Strength-Shadow Exploration', 'Weekly practice to identify how your greatest strengths create your biggest blind spots in coaching relationships', '', 'Core II Assessment Team'),
    
    -- Trust & Psychological Safety resources (Vulnerability & Trauma-Informed Coaching category)
    ('378c3fca-d674-469a-b8cd-45e818410a25', 'Vulnerability & Trauma-Informed Coaching', 'book', 'Daring Greatly', 'Research-based exploration of vulnerability and courage in creating psychological safety', 'https://www.amazon.com/Daring-Greatly-Courage-Vulnerable-Transforms/dp/1592408419', 'Brené Brown'),
    
    ('378c3fca-d674-469a-b8cd-45e818410a25', 'Vulnerability & Trauma-Informed Coaching', 'book', 'Hold Me Tight', 'Attachment science applied to creating secure relationships and emotional safety', 'https://www.amazon.com/Hold-Me-Tight-Conversations-Lifetime/dp/031611300X', 'Sue Johnson'),
    
    ('a287b894-c573-4b5e-978a-5ab17b4d290d', 'Vulnerability & Trauma-Informed Coaching', 'course', 'Trauma-Informed Coaching Certification', 'Professional training in trauma-informed approaches to coaching relationships', 'https://www.trauma-informed.ca/', 'Various TIC Providers'),
    
    ('a287b894-c573-4b5e-978a-5ab17b4d290d', 'Vulnerability & Trauma-Informed Coaching', 'exercise', 'Vulnerability Honoring Practice', 'Practice staying present with client vulnerability for 30 seconds without rushing to fix or normalize', '', 'Core II Assessment Team'),
    
    -- Direct Communication resources (Crucial Conversations & Feedback Mastery category)
    ('378c3fca-d674-469a-b8cd-45e818410a25', 'Crucial Conversations & Feedback Mastery', 'book', 'Crucial Conversations', 'Master the art of dialogue when stakes are high, opinions vary, and emotions run strong', 'https://www.amazon.com/Crucial-Conversations-Talking-Stakes-Second/dp/1469266822', 'Kerry Patterson, Joseph Grenny, Ron McMillan, Al Switzler'),
    
    ('378c3fca-d674-469a-b8cd-45e818410a25', 'Crucial Conversations & Feedback Mastery', 'book', 'Nonviolent Communication', 'Learn compassionate communication that preserves relationships while addressing difficult topics', 'https://www.amazon.com/Nonviolent-Communication-Language-Marshall-Rosenberg/dp/1892005034', 'Marshall Rosenberg'),
    
    ('378c3fca-d674-469a-b8cd-45e818410a25', 'Crucial Conversations & Feedback Mastery', 'book', 'Thanks for the Feedback', 'Essential guide to giving and receiving feedback with skill and grace', 'https://www.amazon.com/Thanks-Feedback-Science-Receiving-Well/dp/0670014664', 'Douglas Stone & Sheila Heen'),
    
    ('a287b894-c573-4b5e-978a-5ab17b4d290d', 'Crucial Conversations & Feedback Mastery', 'course', 'Crucial Conversations Training', 'Skills training for high-stakes conversations and conflict resolution', 'https://cruciallearning.com', 'Crucial Learning'),
    
    ('a287b894-c573-4b5e-978a-5ab17b4d290d', 'Crucial Conversations & Feedback Mastery', 'exercise', 'Impact Communication Practice', 'Practice communicating behavioral impact without blame: "Your lateness affects our work together in this way..."', '', 'Core II Assessment Team')
    
) AS resources(analysis_type_id, category_title, resource_type_code, title, description, url, author_instructor)
WHERE 
    lpc.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
    AND lpc.category_title = resources.category_title
    AND rt.code = resources.resource_type_code;

COMMIT;

-- Validation Query
SELECT lr.id, lr.title, lr.author_instructor, rt.name as resource_type, lpc.category_title
FROM learning_resources lr
JOIN resource_types rt ON lr.resource_type_id = rt.id
JOIN learning_path_categories lpc ON lr.category_id = lpc.id
WHERE lr.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
AND lr.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
ORDER BY lpc.priority_order, rt.name, lr.title;