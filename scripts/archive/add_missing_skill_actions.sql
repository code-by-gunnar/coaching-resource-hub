-- ====================================================================
-- ADD MISSING SKILL ACTIONS FOR CORE I SKILL TAGS  
-- ====================================================================
-- Purpose: Add actionable steps for the 11 skill tags that are missing actions
-- This fixes the "No action for tag" database mismatch errors
-- ====================================================================

-- Active Listening - Missing Actions
INSERT INTO tag_actions (skill_tag_id, action_text, is_active) 
SELECT st.id, 'Practice 5 minutes of daily meditation to develop present-moment listening awareness', true
FROM skill_tags st WHERE st.name = 'Non-Judgmental Listening' AND st.competency_area = 'Active Listening';

INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'After each coaching session, practice restating the key points your client shared in your own words', true  
FROM skill_tags st WHERE st.name = 'Paraphrasing' AND st.competency_area = 'Active Listening';

INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'When you notice your mind wandering during coaching, gently return attention to your client', true
FROM skill_tags st WHERE st.name = 'Staying Present' AND st.competency_area = 'Active Listening';

-- Powerful Questions - Missing Actions  
INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'When clients seem confused, ask "What specifically would help you understand this better?"', true
FROM skill_tags st WHERE st.name = 'Clarifying Questions' AND st.competency_area = 'Powerful Questions';

INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'Replace "Why did this happen?" with "What do you want to create going forward?"', true  
FROM skill_tags st WHERE st.name = 'Future-Focused Questions' AND st.competency_area = 'Powerful Questions';

INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'When clients are stuck, ask "How might someone else see this situation differently?"', true
FROM skill_tags st WHERE st.name = 'Perspective Shift Questions' AND st.competency_area = 'Powerful Questions';

INSERT INTO tag_actions (skill_tag_id, action_text, is_active)  
SELECT st.id, 'Replace limiting questions with "What becomes possible if...?" or "What would it look like if...?"', true
FROM skill_tags st WHERE st.name = 'Possibility Questions' AND st.competency_area = 'Powerful Questions';

-- Present Moment Awareness - Missing Actions
INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'Notice and gently name emotions you sense: "I''m sensing some frustration - is that accurate?"', true
FROM skill_tags st WHERE st.name = 'Emotional Awareness' AND st.competency_area = 'Present Moment Awareness';

INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'Pay attention to shifts in your client''s voice tone, pace, and energy during sessions', true
FROM skill_tags st WHERE st.name = 'Energy Reading' AND st.competency_area = 'Present Moment Awareness';

INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'When you sense something unspoken, share it tentatively: "I''m noticing... does that resonate?"', true
FROM skill_tags st WHERE st.name = 'Intuitive Observations' AND st.competency_area = 'Present Moment Awareness';

INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'Practice holding silent pauses for 3-5 seconds after your client finishes speaking', true  
FROM skill_tags st WHERE st.name = 'Silence Comfort' AND st.competency_area = 'Present Moment Awareness';

-- Verify all actions were added successfully
SELECT 'Verification - All skill tags now have actions:' as status;
SELECT st.competency_area, COUNT(st.id) as total_skills, COUNT(ta.id) as skills_with_actions
FROM skill_tags st
LEFT JOIN tag_actions ta ON st.id = ta.skill_tag_id AND ta.is_active = true  
WHERE st.framework = 'core' 
AND st.is_active = true 
AND st.assessment_level = 'core-i'
GROUP BY st.competency_area
ORDER BY st.competency_area;

SELECT '';
SELECT 'Overall coverage:' as status;
SELECT 
    COUNT(DISTINCT st.id) as total_skill_tags,
    COUNT(DISTINCT ta.skill_tag_id) as tags_with_actions,
    CASE WHEN COUNT(DISTINCT st.id) = COUNT(DISTINCT ta.skill_tag_id) 
         THEN '✅ COMPLETE' 
         ELSE '❌ MISSING ACTIONS' 
    END as status
FROM skill_tags st
LEFT JOIN tag_actions ta ON st.id = ta.skill_tag_id AND ta.is_active = true
WHERE st.framework = 'core' 
AND st.is_active = true 
AND st.assessment_level = 'core-i';