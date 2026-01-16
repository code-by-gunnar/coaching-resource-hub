-- =============================================
-- CORE II INTERMEDIATE ASSESSMENT - TAG INSIGHTS (REFINED)
-- =============================================
-- Table: tag_insights
-- Description: 30 tag insights for Core II intermediate level (2 per skill: strength + weakness)
-- Aligned with 15 refined skill tags: 3 per competency 
-- Uses dynamic skill_tag_id lookup to work with gen_random_uuid()
-- =============================================

BEGIN;

-- Delete existing Core II tag insights to avoid duplicates
DELETE FROM tag_insights 
WHERE assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

-- Insert tag insights with dynamic skill_tag_id lookup
INSERT INTO tag_insights (id, skill_tag_id, insight_text, created_at, assessment_level_id, analysis_type_id) 

-- Get all skill tags first, then insert insights
SELECT 
    gen_random_uuid() as id,
    st.id as skill_tag_id,
    insights.insight_text,
    NOW() as created_at,
    'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c' as assessment_level_id,
    insights.analysis_type_id::uuid
FROM skill_tags st
CROSS JOIN (
    VALUES 
    -- ADVANCED ACTIVE LISTENING INSIGHTS
    
    -- Emotional Layering insights (strength + weakness)
    ('Strong ability to hear multiple emotional layers simultaneously, recognizing both surface concerns and deeper patterns like imposter syndrome or identity struggles, helping clients access complex feelings they may not fully understand.', 1, '378c3fca-d674-469a-b8cd-45e818410a25'),
    ('May focus on surface emotional content without recognizing deeper patterns, missing opportunities to help clients understand how current struggles connect to broader themes like belonging, capability, or self-worth.', 2, 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4'),
    
    -- Somatic Listening insights (strength + weakness)
    ('Natural ability to integrate body language with verbal content, noticing when client posture and voice shift as signals of deeper resignation patterns, helping them access authentic emotions beyond their words.', 3, '378c3fca-d674-469a-b8cd-45e818410a25'),
    ('Tendency to focus primarily on verbal content while missing body language cues, voice tone changes, and energetic shifts that reveal resignation, excitement, or other emotions clients may not be expressing verbally.', 4, 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4'),
    
    -- Incongruence Detection insights (strength + weakness)
    ('Excellent instinct for recognizing when clients'' words don''t match their energy or body language, allowing you to gently explore the discrepancy and help them access what''s really present for them.', 5, '378c3fca-d674-469a-b8cd-45e818410a25'),
    ('May accept client words at face value without noticing when their energy, posture, or voice suggests something different is happening, missing opportunities to explore deeper truths.', 6, 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4'),
    
    -- STRATEGIC POWERFUL QUESTIONS INSIGHTS
    
    -- Belief Inquiry insights (strength + weakness)
    ('Excellent at connecting client behaviors to underlying belief systems, helping them understand the ''why'' behind repetitive patterns rather than just addressing surface-level symptoms or trying to change behaviors without understanding their function.', 7, '378c3fca-d674-469a-b8cd-45e818410a25'),
    ('Questions may stay focused on behavioral change without exploring the belief systems driving the patterns, limiting clients'' ability to create lasting transformation at the identity and worldview level.', 8, 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4'),
    
    -- Core Drive Questioning insights (strength + weakness)
    ('Strong skill at questioning beneath surface behaviors to core motivations, helping clients understand what they''re really trying to control when they manage household tasks or other relationship dynamics.', 9, '378c3fca-d674-469a-b8cd-45e818410a25'),
    ('May focus on problem-solving surface issues without exploring the deeper drives and needs underneath, missing opportunities to help clients understand their core motivations and unconscious patterns.', 10, 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4'),
    
    -- Positive Intent Discovery insights (strength + weakness)
    ('Excellent at finding the protective function behind seemingly negative patterns, helping clients discover how perfectionism is trying to take care of them rather than just seeing it as something to eliminate.', 11, '378c3fca-d674-469a-b8cd-45e818410a25'),
    ('May focus on eliminating problematic behaviors without exploring their positive intent, missing opportunities to help clients understand what these patterns are trying to protect or provide.', 12, 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4'),
    
    -- CREATING AWARENESS INSIGHTS
    
    -- Strength-Shadow Recognition insights (strength + weakness)
    ('Strong ability to help clients discover how their strengths create blind spots, recognizing that always being responsible prevents them from experiencing personal enjoyment and spontaneity while helping others see how helpfulness can create dependency.', 13, '378c3fca-d674-469a-b8cd-45e818410a25'),
    ('May focus on celebrating client strengths without exploring their shadow side, missing opportunities to help them see how responsibility can become a prison that prevents personal fulfillment or how helping creates dependency.', 14, 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4'),
    
    -- Self-Role Recognition insights (strength + weakness)  
    ('Skilled at helping clients see their unconscious contribution to relationship dynamics, empowering them to change patterns by shifting their own behavior rather than trying to change others, recognizing how their approach creates predictable responses.', 15, '378c3fca-d674-469a-b8cd-45e818410a25'),
    ('May help clients see others'' contributions to problematic dynamics without helping them recognize their own unconscious role, missing opportunities to empower them with their own agency for change.', 16, 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4'),
    
    -- Internal Process Awareness insights (strength + weakness)
    ('Excellent at helping clients notice their internal experience during challenging moments, enabling them to understand what happens inside when they face emotional vulnerability with partners or when scarcity influences spending choices.', 17, '378c3fca-d674-469a-b8cd-45e818410a25'),
    ('May focus on relationship dynamics or external situations without helping clients explore their internal experience of intimacy, vulnerability, or decision-making, missing opportunities to help them understand their patterns of connection and disconnection.', 18, 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4'),
    
    -- TRUST & PSYCHOLOGICAL SAFETY INSIGHTS
    
    -- Vulnerability Honoring insights (strength + weakness)
    ('Strong ability to honor vulnerability without rushing to fix or normalize, allowing clients to stay present with difficult emotions about loneliness and social struggles while building self-acceptance through witnessed experience.', 19, '378c3fca-d674-469a-b8cd-45e818410a25'),
    ('May rush to normalize or fix vulnerable moments (''many people feel lonely after moving''), preventing clients from fully experiencing the courage it takes to share difficult emotions and missing opportunities for deeper healing.', 20, 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4'),
    
    -- Resource State Access insights (strength + weakness)
    ('Excellent at helping clients access their resourceful state and own thinking, supporting them in trusting their capabilities when they''re caught in self-doubt about important life decisions, connecting them with their inner knowing rather than external validation.', 21, '378c3fca-d674-469a-b8cd-45e818410a25'),
    ('May struggle to help clients access their resourceful state when they''re stuck in self-doubt, either providing answers rather than helping them find their own or missing opportunities to connect them with their capabilities and inner wisdom.', 22, 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4'),
    
    -- Emotional Normalization insights (strength + weakness)
    ('Natural ability to reframe emotional expression as strength rather than weakness, helping clients see crying and emotional expression as courage and authenticity rather than embarrassment or failure, noticing self-interruption patterns in real-time.', 23, '378c3fca-d674-469a-b8cd-45e818410a25'),
    ('May struggle to help clients normalize emotional expression, either minimizing their feelings or getting caught in their shame about having emotions, missing when clients interrupt themselves mid-share or dismiss their own experience.', 24, 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4'),
    
    -- DIRECT COMMUNICATION INSIGHTS
    
    -- Impact Communication insights (strength + weakness)
    ('Strong ability to communicate impact directly without blame or softening, clearly stating how behaviors affect the coaching relationship while maintaining professional respect and care, combining clear boundaries with expressed value for the relationship.', 25, '378c3fca-d674-469a-b8cd-45e818410a25'),
    ('May either avoid addressing problematic behaviors or address them in ways that feel blaming or harsh, struggling to find the balance between directness and relationship preservation when discussing lateness, payment issues, or engagement patterns.', 26, 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4'),
    
    -- Pattern Confrontation insights (strength + weakness)
    ('Skilled at naming patterns directly without getting hooked by deflection, addressing humor and other avoidance strategies while staying curious about what they''re protecting rather than becoming defensive, managing interrupting patterns with behavioral curiosity.', 27, '378c3fca-d674-469a-b8cd-45e818410a25'),
    ('May either avoid confronting patterns or get hooked by client deflection strategies, missing opportunities to address avoidance behaviors that limit coaching effectiveness, or addressing problematic behaviors without curiosity about what''s driving them.', 28, 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4'),
    
    -- Collaborative Problem-Naming insights (strength + weakness)  
    ('Excellent at directly acknowledging when coaching conversations are cycling, joining clients in curiosity about what''s keeping the process stuck rather than becoming defensive about coaching effectiveness, receiving feedback with self-awareness rather than defensiveness.', 29, '378c3fca-d674-469a-b8cd-45e818410a25'),
    ('May become defensive or reassuring when clients express dissatisfaction with coaching progress, missing opportunities to collaborate in identifying what''s actually keeping the process stuck, or becoming defensive when receiving feedback about coaching patterns.', 30, 'b2f61b8d-66c9-4d79-8fcd-58fd3bb370e4')
    
) AS insights(insight_text, sort_order, analysis_type_id)
WHERE 
    st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
    AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c'
    AND (
        (st.name = 'Emotional Layering' AND insights.sort_order IN (1,2)) OR
        (st.name = 'Somatic Listening' AND insights.sort_order IN (3,4)) OR
        (st.name = 'Incongruence Detection' AND insights.sort_order IN (5,6)) OR
        (st.name = 'Belief Inquiry' AND insights.sort_order IN (7,8)) OR
        (st.name = 'Core Drive Questioning' AND insights.sort_order IN (9,10)) OR
        (st.name = 'Positive Intent Discovery' AND insights.sort_order IN (11,12)) OR
        (st.name = 'Strength-Shadow Recognition' AND insights.sort_order IN (13,14)) OR
        (st.name = 'Self-Role Recognition' AND insights.sort_order IN (15,16)) OR
        (st.name = 'Internal Process Awareness' AND insights.sort_order IN (17,18)) OR
        (st.name = 'Vulnerability Honoring' AND insights.sort_order IN (19,20)) OR
        (st.name = 'Resource State Access' AND insights.sort_order IN (21,22)) OR
        (st.name = 'Emotional Normalization' AND insights.sort_order IN (23,24)) OR
        (st.name = 'Impact Communication' AND insights.sort_order IN (25,26)) OR
        (st.name = 'Pattern Confrontation' AND insights.sort_order IN (27,28)) OR
        (st.name = 'Collaborative Problem-Naming' AND insights.sort_order IN (29,30))
    );

COMMIT;

-- Validation Query
SELECT COUNT(*) as total_insights, 
       COUNT(DISTINCT st.name) as skill_tags_covered
FROM tag_insights ti
JOIN skill_tags st ON ti.skill_tag_id = st.id
WHERE st.framework_id = 'f83064ee-237c-45b1-9db6-e6212c195cdb'
AND st.assessment_level_id = 'a2021eb1-93fb-4f23-8d2b-5ee1da88dc8c';

-- Expected Results:
-- total_insights: 30 (2 per refined skill tag)
-- skill_tags_covered: 15 (all refined skill tags)