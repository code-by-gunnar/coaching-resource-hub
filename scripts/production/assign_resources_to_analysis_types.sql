-- Assign existing learning resources to appropriate analysis_types
-- Simple, clean tier assignment based on resource intent
-- Run Date: 2025-08-24

BEGIN;

-- ===================================================================
-- SECTION 1: ASSIGN EXISTING CORE I RESOURCES TO TIERS
-- ===================================================================

-- WEAKNESS TIER (Foundational Resources)
-- Resources appropriate for 0-49% scores - foundational learning

UPDATE learning_resources 
SET analysis_type_id = 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4' -- weakness
WHERE title IN (
  'Co-Active Coaching (Fourth Edition)',
  'Active Listening Fundamentals', 
  'What Is Active Listening?',
  'The Power of Now'
)
AND framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
AND assessment_level_id = '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132';

-- DEVELOPING TIER (Skill Building Resources)  
-- Resources appropriate for 50-69% scores - intermediate development

UPDATE learning_resources 
SET analysis_type_id = 'a287b894-c573-4b5e-978a-5ab17b4d290d' -- developing
WHERE title IN (
  'The Art of Powerful Questions',
  'Active Listening Masterclass',
  'Building Coaching Presence Skills',
  'Presence Practice for Coaches'
)
AND framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
AND assessment_level_id = '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132';

-- STRENGTH TIER (Advanced/Mastery Resources)
-- Resources appropriate for 70-100% scores - advanced techniques

UPDATE learning_resources 
SET analysis_type_id = '378c3fca-d674-469a-b8cd-45e818410a25' -- strength  
WHERE title IN (
  'Advanced Awareness Creation Mastery',
  'Awareness Creation Workshop'
)
AND framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
AND assessment_level_id = '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132';

-- ===================================================================
-- SECTION 2: ADD NEW STRENGTH TIER RESOURCES (SIMPLE VERSION)
-- ===================================================================

-- Keep it simple - add just a few key advanced resources for strength tier
INSERT INTO learning_resources (
  id, category_id, title, description, url, author_instructor, 
  resource_type_id, framework_id, assessment_level_id, analysis_type_id, is_active, created_at
) VALUES

-- Advanced Books for Communication & Questioning
(gen_random_uuid(), 
 '3c3fdbff-54c6-4a62-819d-92cc79d47d9b',
 'The Coaching Habit',
 'Advanced questioning techniques for experienced coaches and leaders',
 'https://www.amazon.com/Coaching-Habit-Less-Change-Forever/dp/0978440749',
 'Michael Bungay Stanier',
 'b04373d5-2562-49aa-a1a9-13dfbf14caf2',
 'f83064ee-237c-45b1-9db6-e6212c195cdb',
 '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132',
 '378c3fca-d674-469a-b8cd-45e818410a25', -- strength
 true,
 NOW()),

-- Advanced Books for Presence & Awareness  
(gen_random_uuid(),
 'fc84d6aa-559f-4ce4-a8c6-6d28ddcb3c15',
 'Presence-Based Coaching',
 'Advanced presence techniques for sophisticated coaching professionals',
 'https://www.amazon.com/Presence-Based-Coaching-Cultivating-Self-Generative-Leaders/dp/0470610689',
 'Doug Silsbee',
 'b04373d5-2562-49aa-a1a9-13dfbf14caf2',
 'f83064ee-237c-45b1-9db6-e6212c195cdb',
 '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132',
 '378c3fca-d674-469a-b8cd-45e818410a25', -- strength
 true,
 NOW()),

-- Advanced Workshop
(gen_random_uuid(),
 '3c3fdbff-54c6-4a62-819d-92cc79d47d9b',
 'Advanced Coaching Conversations',
 'Expert-level training for sophisticated coaching dialogue and breakthrough conversations',
 'https://www.centerforexecutivecoaching.com/advanced-programs/',
 'Center for Executive Coaching',
 '42f3e6ee-3335-4fd5-801a-85fdfa479cc8',
 'f83064ee-237c-45b1-9db6-e6212c195cdb',
 '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132',
 '378c3fca-d674-469a-b8cd-45e818410a25', -- strength
 true,
 NOW());

-- ===================================================================
-- SECTION 3: VERIFICATION
-- ===================================================================

-- Show final distribution
SELECT 
  at.code as tier,
  at.name as tier_name,
  COUNT(lr.id) as resource_count,
  STRING_AGG(lr.title, '; ') as resource_titles
FROM analysis_types at
LEFT JOIN learning_resources lr ON lr.analysis_type_id = at.id 
  AND lr.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
  AND lr.assessment_level_id = '9f6e38cc-8f1b-4ab9-b019-a5f5be0c3132'
  AND lr.is_active = true
WHERE at.is_active = true
GROUP BY at.id, at.code, at.name
ORDER BY 
  CASE at.code 
    WHEN 'weakness' THEN 1
    WHEN 'developing' THEN 2
    WHEN 'strength' THEN 3
    ELSE 4
  END;

COMMIT;

-- Success message
SELECT 'Learning resources successfully assigned to analysis_types!' as status;