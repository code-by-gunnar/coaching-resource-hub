-- ====================================================================
-- FIX MISSING TAG INSIGHTS FOR ALL SKILL TAGS
-- ====================================================================
-- Purpose: Add weakness and strength insights for every skill tag
-- ====================================================================

-- Active Listening - Missing Insights
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may unconsciously judge clients based on their words or stories, limiting their openness', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Non-Judgmental Listening' AND st.competency_area = 'Active Listening';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You create a non-judgmental space that allows clients to share authentically without fear', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Non-Judgmental Listening' AND st.competency_area = 'Active Listening';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may struggle to accurately restate what clients share in your own words', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Paraphrasing' AND st.competency_area = 'Active Listening';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You skillfully paraphrase client content to show deep understanding and build connection', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Paraphrasing' AND st.competency_area = 'Active Listening';

-- Powerful Questions - Missing Insights
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'Your questions may be too general or not specific enough to help clients gain clarity', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Clarifying Questions' AND st.competency_area = 'Powerful Questions';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You ask excellent clarifying questions that help clients gain precision and understanding', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Clarifying Questions' AND st.competency_area = 'Powerful Questions';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may stay too focused on current problems rather than exploring future possibilities', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Future-Focused Questions' AND st.competency_area = 'Powerful Questions';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You skillfully guide clients toward exploring future possibilities and potential outcomes', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Future-Focused Questions' AND st.competency_area = 'Powerful Questions';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'Your questions may not effectively help clients see situations from different angles', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Perspective Shift Questions' AND st.competency_area = 'Powerful Questions';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You excel at asking questions that help clients see their situation from new perspectives', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Perspective Shift Questions' AND st.competency_area = 'Powerful Questions';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'Your questions may limit rather than expand the client''s sense of what''s possible', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Possibility Questions' AND st.competency_area = 'Powerful Questions';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You ask powerful possibility questions that open new opportunities and expand client thinking', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Possibility Questions' AND st.competency_area = 'Powerful Questions';

-- Present Moment Awareness - Missing Insights
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may miss important emotional undercurrents and feeling states in your clients', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Emotional Awareness' AND st.competency_area = 'Present Moment Awareness';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You demonstrate strong awareness of emotional undercurrents and feeling states', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Emotional Awareness' AND st.competency_area = 'Present Moment Awareness';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'Your ability to sense energy shifts and subtle dynamics could be stronger', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Energy Reading' AND st.competency_area = 'Present Moment Awareness';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You effectively sense and work with energy shifts and unspoken dynamics', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Energy Reading' AND st.competency_area = 'Present Moment Awareness';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may struggle to trust and appropriately share your intuitive observations', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Intuitive Observations' AND st.competency_area = 'Present Moment Awareness';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You skillfully trust and share intuitive observations that create breakthrough moments', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Intuitive Observations' AND st.competency_area = 'Present Moment Awareness';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may feel uncomfortable with silence and rush to fill quiet moments', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Silence Comfort' AND st.competency_area = 'Present Moment Awareness';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You use silence effectively to create space for client reflection and deeper insights', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Silence Comfort' AND st.competency_area = 'Present Moment Awareness';

-- Creating Awareness - Missing Insights
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may miss opportunities to help clients see their blind spots and unconscious patterns', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Blind Spot Illumination' AND st.competency_area = 'Creating Awareness';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You skillfully help clients discover blind spots and unconscious patterns with care', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Blind Spot Illumination' AND st.competency_area = 'Creating Awareness';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may avoid pointing out contradictions between what clients say and do', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Contradiction Pointing' AND st.competency_area = 'Creating Awareness';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You effectively notice and gently explore contradictions in client thinking and behavior', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Contradiction Pointing' AND st.competency_area = 'Creating Awareness';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'Your observation sharing skills need development - you may miss important patterns', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Observation Sharing' AND st.competency_area = 'Creating Awareness';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You share observations skillfully in ways that create new awareness and insight', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Observation Sharing' AND st.competency_area = 'Creating Awareness';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may provide answers too quickly rather than helping clients discover for themselves', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Self-Discovery Facilitation' AND st.competency_area = 'Creating Awareness';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You excel at facilitating client self-discovery rather than providing direct answers', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Self-Discovery Facilitation' AND st.competency_area = 'Creating Awareness';

-- Direct Communication - Missing Insights
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may struggle to set and maintain clear boundaries in coaching relationships', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Clear Boundaries' AND st.competency_area = 'Direct Communication';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You effectively establish and maintain clear boundaries that serve the coaching relationship', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Clear Boundaries' AND st.competency_area = 'Direct Communication';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may avoid difficult conversations that could benefit your client''s growth', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Difficult Conversations' AND st.competency_area = 'Direct Communication';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You navigate difficult conversations with skill, care, and courage when needed', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Difficult Conversations' AND st.competency_area = 'Direct Communication';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may avoid giving direct feedback that could benefit your client''s development', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Honest Feedback' AND st.competency_area = 'Direct Communication';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You provide honest, direct feedback that truly serves your client''s growth and development', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Honest Feedback' AND st.competency_area = 'Direct Communication';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'Your skills in respectfully redirecting conversations need development', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Respectful Interrupting' AND st.competency_area = 'Direct Communication';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You skillfully redirect conversations while maintaining rapport and respect', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Respectful Interrupting' AND st.competency_area = 'Direct Communication';

-- Trust & Safety - Missing Insights
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'Your boundary setting skills may be unclear or inconsistent', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Boundary Setting' AND st.competency_area = 'Trust & Safety';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You establish healthy boundaries that create safety and structure for coaching', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Boundary Setting' AND st.competency_area = 'Trust & Safety';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'Clients may not feel completely emotionally safe to be vulnerable with you', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Emotional Safety' AND st.competency_area = 'Trust & Safety';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You consistently create emotional safety that enables deep vulnerability and trust', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Emotional Safety' AND st.competency_area = 'Trust & Safety';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may inadvertently communicate judgment through your words, tone, or body language', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Non-Judgmental Presence' AND st.competency_area = 'Trust & Safety';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'Your non-judgmental presence creates deep safety for authentic client expression', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Non-Judgmental Presence' AND st.competency_area = 'Trust & Safety';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may struggle to create conditions that encourage client vulnerability and openness', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Vulnerability Encouragement' AND st.competency_area = 'Trust & Safety';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You skillfully create conditions that encourage appropriate vulnerability and authentic sharing', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Vulnerability Encouragement' AND st.competency_area = 'Trust & Safety';

-- Managing Progress - Missing Insights
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may create action plans for clients rather than co-creating with them', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Action Plan Co-Creation' AND st.competency_area = 'Managing Progress';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You excel at co-creating realistic, achievable action plans that clients feel ownership of', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Action Plan Co-Creation' AND st.competency_area = 'Managing Progress';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'Your skills in exploring obstacles and barriers with clients need development', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Obstacle Exploration' AND st.competency_area = 'Managing Progress';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You skillfully explore obstacles and barriers with curiosity rather than judgment', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Obstacle Exploration' AND st.competency_area = 'Managing Progress';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'Your progress tracking methods may be unclear or overwhelming for clients', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Progress Tracking' AND st.competency_area = 'Managing Progress';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You create effective progress tracking systems that motivate and support client development', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Progress Tracking' AND st.competency_area = 'Managing Progress';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'Your follow-up approach may feel like checking up rather than providing support', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Supportive Follow-Up' AND st.competency_area = 'Managing Progress';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You follow up with clients in ways that feel supportive and caring rather than intrusive', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Supportive Follow-Up' AND st.competency_area = 'Managing Progress';

SELECT 'All missing tag insights added successfully' as status;