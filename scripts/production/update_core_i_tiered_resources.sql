-- Core I Tiered Resource System Update
-- Updates existing resources for better tier targeting and adds advanced strength resources
-- Run Date: 2025-08-24

BEGIN;

-- ===================================================================
-- SECTION 1: UPDATE EXISTING RESOURCES FOR BETTER TIER TARGETING
-- ===================================================================

-- Update "What Is Active Listening?" to be more foundational (WEAKNESS tier focused)
UPDATE learning_resources 
SET 
  title = 'Active Listening Fundamentals',
  description = 'Essential fundamentals of active listening for beginning coaches - core basics of Level 1 and Level 2 listening skills'
WHERE id = '75b91357-07fd-4e1a-9fac-edfd39d1e2c1';

-- Update "The Power of Now" to emphasize foundations (WEAKNESS tier focused)  
UPDATE learning_resources
SET description = 'Foundational guide to present moment awareness - essential basics for developing coaching presence and mindful attention'
WHERE id = 'eacae1ab-4952-4c33-ae29-53c0949a47e8';

-- Update "The Art of Powerful Questions" for developing tier emphasis (DEVELOPING tier focused)
UPDATE learning_resources 
SET description = 'Comprehensive guide to developing powerful questioning skills - intermediate techniques for creating insight-generating questions in coaching'
WHERE id = '31a80bc8-1986-4443-938d-6c6dbbfa7f61';

-- Update "Presence Practice for Coaches" to be more skill-building focused (DEVELOPING tier focused)
UPDATE learning_resources
SET 
  title = 'Building Coaching Presence Skills',
  description = 'Practical video series for developing and improving authentic presence - intermediate techniques for building awareness skills'
WHERE id = '2b7abe40-1c1f-499d-ba42-4c6d5268f579';

-- Reactivate and enhance the advanced workshop (STRENGTH tier focused)
UPDATE learning_resources 
SET 
  is_active = true,
  title = 'Advanced Awareness Creation Mastery',
  description = 'Expert-level workshop for mastering sophisticated awareness creation techniques - advanced coaching skills for experienced professionals'
WHERE id = 'cd2a4d35-cb89-4388-a0cc-426c51fa3638';

-- ===================================================================
-- SECTION 2: ADD NEW WEAKNESS TIER RESOURCES (Foundational/Basic)
-- ===================================================================

INSERT INTO learning_resources (
  id, category_id, title, description, url, author_instructor, 
  resource_type_id, framework_id, assessment_level_id, is_active, created_at
) VALUES

-- Basic introduction article
(gen_random_uuid(), 
 '3c3fdbff-54c6-4a62-819d-92cc79d47d9b', 
 'Coaching Basics: Getting Started Guide', 
 'Essential introduction to core coaching fundamentals - beginner-friendly guide covering basic principles every new coach needs',
 'https://www.coachfederation.org/blog/coaching-basics-getting-started',
 'International Coach Federation',
 '5dbbc2f1-a7bc-42f9-b667-7a6f003528f9', 
 'f83064ee-237c-45b1-9db6-e6212c195cdb',
 '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132',
 true,
 NOW()),

-- Basic questioning exercise
(gen_random_uuid(),
 '3c3fdbff-54c6-4a62-819d-92cc79d47d9b',
 'Introduction to Powerful Questions',
 'Basic question fundamentals for beginner coaches - essential starter techniques for creating simple, effective coaching questions',
 'https://www.centerforexecutivecoaching.com/basic-coaching-questions/',
 'Center for Executive Coaching',
 'ca796c69-15dd-4fd5-9aba-151aaa612304',
 'f83064ee-237c-45b1-9db6-e6212c195cdb', 
 '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132',
 true,
 NOW());

-- ===================================================================
-- SECTION 3: ADD NEW DEVELOPING TIER RESOURCES (Skill Building)
-- ===================================================================

INSERT INTO learning_resources (
  id, category_id, title, description, url, author_instructor, 
  resource_type_id, framework_id, assessment_level_id, is_active, created_at
) VALUES

-- Practice exercises for developing skills
(gen_random_uuid(),
 '3c3fdbff-54c6-4a62-819d-92cc79d47d9b',
 'Active Listening Practice Exercises', 
 'Hands-on exercises for building and improving listening skills - intermediate practice sessions for developing Level 2 and 3 listening',
 'https://www.coachingtools.com/active-listening-practice-exercises',
 'Coaching Tools Company',
 'ca796c69-15dd-4fd5-9aba-151aaa612304',
 'f83064ee-237c-45b1-9db6-e6212c195cdb',
 '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132',
 true,
 NOW()),

-- Developing presence course
(gen_random_uuid(),
 'fc84d6aa-559f-4ce4-a8c6-6d28ddcb3c15',
 'Developing Present Moment Awareness',
 'Skills-building course for improving coaching presence - practice techniques for developing mindful attention and awareness',
 'https://www.mindfulnessstudies.com/developing-presence-course',
 'Center for Mindfulness Studies',
 '3993f2c5-1929-4249-baaf-d7df8723f46f',
 'f83064ee-237c-45b1-9db6-e6212c195cdb',
 '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132',
 true,
 NOW());

-- ===================================================================
-- SECTION 4: ADD NEW STRENGTH TIER RESOURCES (Advanced/Expert)
-- ===================================================================

INSERT INTO learning_resources (
  id, category_id, title, description, url, author_instructor, 
  resource_type_id, framework_id, assessment_level_id, is_active, created_at
) VALUES

-- Advanced Books
(gen_random_uuid(),
 '3c3fdbff-54c6-4a62-819d-92cc79d47d9b',
 'The Coaching Habit: Say Less, Ask More & Change the Way You Lead Forever',
 'Advanced guide to masterful coaching questions - sophisticated techniques for leaders and experienced coaching professionals',
 'https://www.amazon.com/Coaching-Habit-Less-Change-Forever/dp/0978440749',
 'Michael Bungay Stanier',
 'b04373d5-2562-49aa-a1a9-13dfbf14caf2',
 'f83064ee-237c-45b1-9db6-e6212c195cdb',
 '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132',
 true,
 NOW()),

(gen_random_uuid(),
 'fc84d6aa-559f-4ce4-a8c6-6d28ddcb3c15',
 'Presence-Based Coaching: Cultivating Self-Generative Leaders',
 'Expert-level guide to sophisticated presence and awareness techniques - advanced methods for masterful coaching professionals',
 'https://www.amazon.com/Presence-Based-Coaching-Cultivating-Self-Generative-Leaders/dp/0470610689',
 'Doug Silsbee',
 'b04373d5-2562-49aa-a1a9-13dfbf14caf2',
 'f83064ee-237c-45b1-9db6-e6212c195cdb',
 '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132',
 true,
 NOW()),

(gen_random_uuid(),
 '3c3fdbff-54c6-4a62-819d-92cc79d47d9b',
 'Coaching for Performance: The Principles and Practice of Coaching and Leadership',
 'Masterful coaching methodology for advanced practitioners - sophisticated performance coaching techniques for experienced professionals',
 'https://www.amazon.com/Coaching-Performance-Principles-Practice-Leadership/dp/1473658128',
 'Sir John Whitmore',
 'b04373d5-2562-49aa-a1a9-13dfbf14caf2',
 'f83064ee-237c-45b1-9db6-e6212c195cdb',
 '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132',
 true,
 NOW()),

-- Advanced Workshops
(gen_random_uuid(),
 '3c3fdbff-54c6-4a62-819d-92cc79d47d9b',
 'Advanced Coaching Conversations Masterclass',
 'Expert-level training for sophisticated coaching dialogue - mastery techniques for complex client situations and breakthrough conversations',
 'https://www.centerforexecutivecoaching.com/advanced-programs/',
 'Center for Executive Coaching',
 '42f3e6ee-3335-4fd5-801a-85fdfa479cc8',
 'f83064ee-237c-45b1-9db6-e6212c195cdb',
 '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132',
 true,
 NOW()),

(gen_random_uuid(),
 '3c3fdbff-54c6-4a62-819d-92cc79d47d9b',
 'Mastery in Transformational Questioning',
 'Advanced workshop on sophisticated questioning techniques for experienced coaches - expert methods for creating profound client insights',
 'https://www.coachville.com/advanced-coaching-workshops/',
 'CoachVille',
 '42f3e6ee-3335-4fd5-801a-85fdfa479cc8',
 'f83064ee-237c-45b1-9db6-e6212c195cdb',
 '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132',
 true,
 NOW()),

(gen_random_uuid(),
 '3c3fdbff-54c6-4a62-819d-92cc79d47d9b',
 'Professional Coaching Supervision Skills',
 'Expert-level training for coaching other coaches - advanced mentoring and supervision techniques for coaching professionals',
 'https://www.instituteofcoachingsupervision.com/training/',
 'Institute of Coaching Supervision',
 '42f3e6ee-3335-4fd5-801a-85fdfa479cc8',
 'f83064ee-237c-45b1-9db6-e6212c195cdb',
 '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132',
 true,
 NOW()),

-- Advanced Courses/Videos
(gen_random_uuid(),
 'fc84d6aa-559f-4ce4-a8c6-6d28ddcb3c15',
 'Advanced Mindful Coaching Mastery Course',
 'Expert-level online training for sophisticated mindfulness integration - advanced presence techniques for coaching professionals',
 'https://www.mindfulschools.org/training/',
 'Mindful Schools',
 '3993f2c5-1929-4249-baaf-d7df8723f46f',
 'f83064ee-237c-45b1-9db6-e6212c195cdb',
 '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132',
 true,
 NOW()),

(gen_random_uuid(),
 'fc84d6aa-559f-4ce4-a8c6-6d28ddcb3c15',
 'Executive Presence for Coaching Leaders',
 'Advanced leadership presence training for experienced coaches - sophisticated techniques for executive coaching and organizational leadership',
 'https://www.centerforexecutivecoaching.com/executive-presence/',
 'Center for Executive Coaching',
 '3993f2c5-1929-4249-baaf-d7df8723f46f',
 'f83064ee-237c-45b1-9db6-e6212c195cdb',
 '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132',
 true,
 NOW()),

-- Advanced Articles
(gen_random_uuid(),
 '3c3fdbff-54c6-4a62-819d-92cc79d47d9b',
 'Advanced Coaching Research: Neuroscience of Powerful Questions',
 'Expert-level research on sophisticated questioning techniques - advanced neuroscience insights for masterful coaching professionals',
 'https://www.coachfederation.org/research/neuroscience-coaching',
 'International Coach Federation Research',
 '5dbbc2f1-a7bc-42f9-b667-7a6f003528f9',
 'f83064ee-237c-45b1-9db6-e6212c195cdb',
 '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132',
 true,
 NOW()),

(gen_random_uuid(),
 'fc84d6aa-559f-4ce4-a8c6-6d28ddcb3c15',
 'Mastering Somatic Awareness in Coaching',
 'Advanced article on sophisticated body awareness techniques - expert methods for integrating somatic intelligence in professional coaching',
 'https://www.somaticexperiencing.com/coaching-applications',
 'Somatic Experiencing International',
 '5dbbc2f1-a7bc-42f9-b667-7a6f003528f9',
 'f83064ee-237c-45b1-9db6-e6212c195cdb',
 '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132',
 true,
 NOW()),

-- Advanced Practice Exercises
(gen_random_uuid(),
 '3c3fdbff-54c6-4a62-819d-92cc79d47d9b',
 'Complex Scenario Coaching Practice Lab',
 'Advanced practice exercises for sophisticated client situations - expert-level scenarios for mastering complex coaching challenges',
 'https://www.coachingtools.com/advanced-scenarios/',
 'Coaching Tools Company',
 'ca796c69-15dd-4fd5-9aba-151aaa612304',
 'f83064ee-237c-45b1-9db6-e6212c195cdb',
 '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132',
 true,
 NOW()),

(gen_random_uuid(),
 'fc84d6aa-559f-4ce4-a8c6-6d28ddcb3c15',
 'Advanced Presence Calibration Exercises',
 'Expert-level exercises for sophisticated presence awareness - advanced practices for mastering subtle energy and attention in coaching',
 'https://www.embodiedpresentprocess.com/advanced-practices/',
 'Embodied Present Process',
 'ca796c69-15dd-4fd5-9aba-151aaa612304',
 'f83064ee-237c-45b1-9db6-e6212c195cdb',
 '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132',
 true,
 NOW());

-- ===================================================================
-- VERIFICATION: Check final resource counts by tier keywords
-- ===================================================================

-- Show updated/added resources summary
DO $$
DECLARE
    weakness_count INTEGER;
    developing_count INTEGER;
    strength_count INTEGER;
BEGIN
    -- Count weakness-focused resources (foundational keywords)
    SELECT COUNT(*) INTO weakness_count
    FROM learning_resources
    WHERE is_active = true 
    AND framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
    AND assessment_level_id = '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132'
    AND (LOWER(title || ' ' || description) ~ '(foundation|basic|fundamentals|introduction|getting started|beginner|essential)');

    -- Count developing-focused resources (intermediate keywords)
    SELECT COUNT(*) INTO developing_count
    FROM learning_resources
    WHERE is_active = true 
    AND framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
    AND assessment_level_id = '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132'
    AND (LOWER(title || ' ' || description) ~ '(intermediate|building|developing|improving|practice|skills|techniques)');

    -- Count strength-focused resources (advanced keywords)
    SELECT COUNT(*) INTO strength_count
    FROM learning_resources
    WHERE is_active = true 
    AND framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
    AND assessment_level_id = '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132'
    AND (LOWER(title || ' ' || description) ~ '(advanced|mastery|expert|leadership|sophisticated|complex|professional)');

    RAISE NOTICE 'CORE I TIERED RESOURCES SUMMARY:';
    RAISE NOTICE '  Weakness Tier (Foundational): % resources', weakness_count;
    RAISE NOTICE '  Developing Tier (Building): % resources', developing_count;
    RAISE NOTICE '  Strength Tier (Advanced): % resources', strength_count;
    RAISE NOTICE '  Total Core I Resources: %', weakness_count + developing_count + strength_count;
END $$;

COMMIT;

-- Success message
SELECT 'Core I Tiered Resource System Update Complete!' as status;