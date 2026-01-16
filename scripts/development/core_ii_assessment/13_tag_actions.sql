-- =============================================
-- CORE II INTERMEDIATE ASSESSMENT - TAG ACTIONS (REFINED)
-- =============================================
-- Table: tag_actions
-- Description: 15 skill-level actions for Core II intermediate level (1 per refined skill tag)
-- Aligned with 15 refined skill tags: 3 per competency
-- Frontend Critical: Prevents "Skills to practice data is the same for each skill" error
-- Universal Integration: Works with skill-specific action display system
-- Note: Uses dynamic skill_tag_id lookup to work with gen_random_uuid()
-- =============================================

BEGIN;

-- Delete existing Core II tag actions to avoid duplicates
DELETE FROM tag_actions WHERE skill_tag_id IN (
  SELECT st.id FROM skill_tags st 
  WHERE st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
  AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
);

-- =============================================
-- ADVANCED ACTIVE LISTENING - TAG ACTIONS (3 refined skills)
-- =============================================

-- 1. Emotional Layering
INSERT INTO tag_actions (id, skill_tag_id, action_text, is_active, created_at)
SELECT gen_random_uuid(), st.id, 
'Practice listening for one emotion beneath the surface emotion. When clients share frustration, ask yourself "What else might be here?" and gently explore with "I hear the frustration... what else comes up for you?"', 
true, NOW()
FROM skill_tags st 
WHERE st.name = 'Emotional Layering' AND st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

-- 2. Somatic Listening
INSERT INTO tag_actions (id, skill_tag_id, action_text, is_active, created_at)
SELECT gen_random_uuid(), st.id,
'Notice body language shifts and integrate with verbal content: "I notice your posture changed when you talked about your living space. What''s happening in your body right now?" Connect words with physical presence.',
true, NOW()
FROM skill_tags st 
WHERE st.name = 'Somatic Listening' AND st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

-- 3. Incongruence Detection
INSERT INTO tag_actions (id, skill_tag_id, action_text, is_active, created_at)
SELECT gen_random_uuid(), st.id,
'When you notice energy doesn''t match words, explore gently: "I''m curious - your words say excited but your voice sounds hesitant. What''s really true for you right now?" Help clients access authentic experience.',
true, NOW()
FROM skill_tags st 
WHERE st.name = 'Incongruence Detection' AND st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

-- =============================================
-- STRATEGIC POWERFUL QUESTIONS - TAG ACTIONS (3 refined skills)
-- =============================================

-- 4. Belief Inquiry
INSERT INTO tag_actions (id, skill_tag_id, action_text, is_active, created_at)
SELECT gen_random_uuid(), st.id,
'Start connecting behaviors to beliefs with simple language: "How does this pattern serve you?" or "What belief might this behavior be protecting?" Help clients see the belief-behavior connection.',
true, NOW()
FROM skill_tags st 
WHERE st.name = 'Belief Inquiry' AND st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

-- 5. Core Drive Questioning
INSERT INTO tag_actions (id, skill_tag_id, action_text, is_active, created_at)
SELECT gen_random_uuid(), st.id,
'Question beneath surface behaviors to core motivations: "What are you really trying to control when you manage the household tasks?" Help clients understand their deeper drives and unconscious patterns.',
true, NOW()
FROM skill_tags st 
WHERE st.name = 'Core Drive Questioning' AND st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

-- 6. Positive Intent Discovery
INSERT INTO tag_actions (id, skill_tag_id, action_text, is_active, created_at)
SELECT gen_random_uuid(), st.id,
'Find the protective function behind seemingly negative patterns: "How is your perfectionism trying to take care of you?" Help clients understand what their patterns are trying to protect or provide.',
true, NOW()
FROM skill_tags st 
WHERE st.name = 'Positive Intent Discovery' AND st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

-- =============================================
-- CREATING AWARENESS - TAG ACTIONS (3 refined skills)
-- =============================================

-- 7. Strength-Shadow Recognition
INSERT INTO tag_actions (id, skill_tag_id, action_text, is_active, created_at)
SELECT gen_random_uuid(), st.id,
'When clients minimize their strengths, practice asking: "What might your helpfulness be preventing you from experiencing?" Help them see how strengths can create blind spots and unintended consequences.',
true, NOW()
FROM skill_tags st 
WHERE st.name = 'Strength-Shadow Recognition' AND st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

-- 8. Self-Role Recognition
INSERT INTO tag_actions (id, skill_tag_id, action_text, is_active, created_at)
SELECT gen_random_uuid(), st.id,
'Help clients see their unconscious contribution to relationship dynamics: "What part do you play in keeping this pattern alive?" Empower them to change patterns by shifting their own behavior rather than trying to control others.',
true, NOW()
FROM skill_tags st 
WHERE st.name = 'Self-Role Recognition' AND st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

-- 9. Internal Process Awareness
INSERT INTO tag_actions (id, skill_tag_id, action_text, is_active, created_at)
SELECT gen_random_uuid(), st.id,
'Help clients notice their internal experience during challenging moments: "What happens inside when your partner gets emotional?" Enable them to understand their patterns of connection, disconnection, and decision-making.',
true, NOW()
FROM skill_tags st 
WHERE st.name = 'Internal Process Awareness' AND st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

-- =============================================
-- TRUST & PSYCHOLOGICAL SAFETY - TAG ACTIONS (3 refined skills)
-- =============================================

-- 10. Vulnerability Honoring
INSERT INTO tag_actions (id, skill_tag_id, action_text, is_active, created_at)
SELECT gen_random_uuid(), st.id,
'When clients share something vulnerable, pause and acknowledge: "Thank you for trusting me with this." Stay present for three breaths before responding to honor their courage without rushing to fix or normalize.',
true, NOW()
FROM skill_tags st 
WHERE st.name = 'Vulnerability Honoring' AND st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

-- 11. Resource State Access
INSERT INTO tag_actions (id, skill_tag_id, action_text, is_active, created_at)
SELECT gen_random_uuid(), st.id,
'Help clients access their resourceful state and own thinking: "If you already knew the answer to this, what would it be?" Support them in trusting their capabilities when caught in self-doubt about important decisions.',
true, NOW()
FROM skill_tags st 
WHERE st.name = 'Resource State Access' AND st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

-- 12. Emotional Normalization
INSERT INTO tag_actions (id, skill_tag_id, action_text, is_active, created_at)
SELECT gen_random_uuid(), st.id,
'Reframe emotional expression as strength rather than weakness: "Your tears show courage and authenticity" rather than "It''s okay to cry." Help clients see vulnerability as strength and notice when they interrupt themselves mid-share.',
true, NOW()
FROM skill_tags st 
WHERE st.name = 'Emotional Normalization' AND st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

-- =============================================
-- DIRECT COMMUNICATION - TAG ACTIONS (3 refined skills)
-- =============================================

-- 13. Impact Communication
INSERT INTO tag_actions (id, skill_tag_id, action_text, is_active, created_at)
SELECT gen_random_uuid(), st.id,
'Practice stating behavioral impact directly without blame: "Your lateness affects our work together" while expressing value for the relationship. Balance clear boundaries with professional respect and care.',
true, NOW()
FROM skill_tags st 
WHERE st.name = 'Impact Communication' AND st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

-- 14. Pattern Confrontation
INSERT INTO tag_actions (id, skill_tag_id, action_text, is_active, created_at)
SELECT gen_random_uuid(), st.id,
'Name patterns directly without getting hooked by deflection: "The humor is a pattern I see when we get close to something important." Stay curious about what avoidance strategies are protecting rather than becoming defensive.',
true, NOW()
FROM skill_tags st 
WHERE st.name = 'Pattern Confrontation' AND st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

-- 15. Collaborative Problem-Naming
INSERT INTO tag_actions (id, skill_tag_id, action_text, is_active, created_at)
SELECT gen_random_uuid(), st.id,
'Directly acknowledge when coaching conversations are cycling: "I''ve also noticed we''re cycling. What do you think is keeping us stuck here?" Join clients in curiosity about process issues rather than becoming defensive about coaching effectiveness.',
true, NOW()
FROM skill_tags st 
WHERE st.name = 'Collaborative Problem-Naming' AND st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

COMMIT;

-- =============================================
-- VERIFICATION QUERIES
-- =============================================

-- Validate 15 tag actions created
SELECT 'CORE II TAG ACTIONS REFINED VERIFICATION:' as status;
SELECT 
    'tag_actions' as table_name,
    COUNT(*) as count,
    15 as expected,
    CASE WHEN COUNT(*) = 15 THEN '✅' ELSE '❌' END as status
FROM tag_actions ta
JOIN skill_tags st ON ta.skill_tag_id = st.id
WHERE st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

-- Show created actions by competency
SELECT 'ACTIONS BY COMPETENCY (REFINED):' as section;
SELECT 
    cdn.display_name as competency,
    st.name as skill_tag,
    ta.action_text
FROM tag_actions ta
JOIN skill_tags st ON ta.skill_tag_id = st.id
JOIN competency_display_names cdn ON st.competency_id = cdn.id
WHERE st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb' 
AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
ORDER BY cdn.display_name, st.sort_order;

SELECT '🎉 CORE II TAG ACTIONS (REFINED) DEPLOYMENT COMPLETED!' as final_status;