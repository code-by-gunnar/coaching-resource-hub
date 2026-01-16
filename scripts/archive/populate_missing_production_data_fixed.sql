-- ====================================================================
-- POPULATE MISSING PRODUCTION DATA FOR CORE I BEGINNER ASSESSMENT - FIXED
-- ====================================================================
-- Purpose: Complete all missing database tables for production-ready assessment
-- Tables: skill_tags, tag_insights, tag_actions, competency_display_names, 
--         learning_path_categories, learning_resources
-- ====================================================================

-- ====================================================================
-- COMPETENCY DISPLAY NAMES
-- ====================================================================
INSERT INTO competency_display_names (competency_key, display_name, description, framework, sort_order) VALUES
-- Core I Beginner competency display names
('Active Listening', 'Active Listening', 'The foundation of coaching - truly hearing and understanding your clients', 'core', 1),
('Powerful Questions', 'Powerful Questions', 'Questions that create insight, awareness, and forward movement', 'core', 2),
('Present Moment Awareness', 'Present Moment Awareness', 'Staying present and aware of what''s happening in the coaching conversation', 'core', 3),
('Creating Awareness', 'Creating Awareness', 'Helping clients see patterns, insights, and new perspectives', 'core', 4),
('Direct Communication', 'Direct Communication', 'Clear, honest communication that serves the client''s growth', 'core', 5),
('Trust & Safety', 'Trust & Safety', 'Creating a safe, confidential space for client vulnerability and growth', 'core', 6),
('Managing Progress', 'Managing Progress', 'Supporting client accountability and forward momentum', 'core', 7);

-- ====================================================================
-- SKILL TAGS
-- ====================================================================

-- Active Listening Skills
INSERT INTO skill_tags (name, competency_area, framework, description, difficulty_level, sort_order) VALUES
('Level 2 Listening', 'Active Listening', 'core', 'Focused listening entirely on the client without bringing in your own agenda', 'beginner', 1),
('Reflecting Content', 'Active Listening', 'core', 'Accurately paraphrasing and reflecting what clients share', 'beginner', 2),
('Reflecting Emotions', 'Active Listening', 'core', 'Noticing and reflecting emotional undertones in client communications', 'beginner', 3),
('Paraphrasing', 'Active Listening', 'core', 'Restating client content in your own words to show understanding', 'beginner', 4),
('Staying Present', 'Active Listening', 'core', 'Maintaining consistent attention without planning responses', 'beginner', 5),
('Non-Judgmental Listening', 'Active Listening', 'core', 'Listening without bringing judgment or personal agenda', 'beginner', 6);

-- Powerful Questions Skills
INSERT INTO skill_tags (name, competency_area, framework, description, difficulty_level, sort_order) VALUES
('Open-Ended Questions', 'Powerful Questions', 'core', 'Questions that invite exploration rather than yes/no answers', 'beginner', 1),
('Values-Based Questions', 'Powerful Questions', 'core', 'Questions that help clients connect with their deeper values', 'beginner', 2),
('Future-Focused Questions', 'Powerful Questions', 'core', 'Questions that explore possibilities and potential outcomes', 'beginner', 3),
('Possibility Questions', 'Powerful Questions', 'core', 'Questions that open new perspectives and possibilities', 'beginner', 4),
('Clarifying Questions', 'Powerful Questions', 'core', 'Questions that help clients gain clarity on their situation', 'beginner', 5),
('Perspective Shift Questions', 'Powerful Questions', 'core', 'Questions that help clients see from different viewpoints', 'beginner', 6);

-- Present Moment Awareness Skills
INSERT INTO skill_tags (name, competency_area, framework, description, difficulty_level, sort_order) VALUES
('Body Language Awareness', 'Present Moment Awareness', 'core', 'Noticing and working with non-verbal communication', 'beginner', 1),
('Energy Reading', 'Present Moment Awareness', 'core', 'Sensing energy shifts and dynamics in conversations', 'beginner', 2),
('Silence Comfort', 'Present Moment Awareness', 'core', 'Using silence effectively for reflection and insight', 'beginner', 3),
('Emotional Awareness', 'Present Moment Awareness', 'core', 'Noticing emotional shifts and underlying feelings', 'beginner', 4),
('Intuitive Observations', 'Present Moment Awareness', 'core', 'Trusting and sharing intuitive insights appropriately', 'beginner', 5);

-- Creating Awareness Skills  
INSERT INTO skill_tags (name, competency_area, framework, description, difficulty_level, sort_order) VALUES
('Pattern Recognition', 'Creating Awareness', 'core', 'Noticing themes and patterns across client conversations', 'beginner', 1),
('Contradiction Pointing', 'Creating Awareness', 'core', 'Gently highlighting contradictions in client thinking or behavior', 'beginner', 2),
('Self-Discovery Facilitation', 'Creating Awareness', 'core', 'Helping clients discover insights rather than providing answers', 'beginner', 3),
('Observation Sharing', 'Creating Awareness', 'core', 'Sharing observations that create new awareness', 'beginner', 4),
('Blind Spot Illumination', 'Creating Awareness', 'core', 'Helping clients see what they cannot see themselves', 'beginner', 5);

-- Direct Communication Skills
INSERT INTO skill_tags (name, competency_area, framework, description, difficulty_level, sort_order) VALUES
('Bottom-Lining', 'Direct Communication', 'core', 'Helping clients get to the core issue without circular stories', 'beginner', 1),
('Respectful Interrupting', 'Direct Communication', 'core', 'Redirecting conversations while maintaining rapport', 'beginner', 2),
('Clear Boundaries', 'Direct Communication', 'core', 'Setting and maintaining clear coaching boundaries', 'beginner', 3),
('Honest Feedback', 'Direct Communication', 'core', 'Providing direct feedback that serves client growth', 'beginner', 4),
('Difficult Conversations', 'Direct Communication', 'core', 'Navigating challenging topics with skill and care', 'beginner', 5);

-- Trust & Safety Skills
INSERT INTO skill_tags (name, competency_area, framework, description, difficulty_level, sort_order) VALUES
('Confidentiality Management', 'Trust & Safety', 'core', 'Creating and maintaining clear confidentiality agreements', 'beginner', 1),
('Emotional Safety', 'Trust & Safety', 'core', 'Creating an emotionally safe space for vulnerability', 'beginner', 2),
('Non-Judgmental Presence', 'Trust & Safety', 'core', 'Maintaining non-judgmental presence that enables authentic sharing', 'beginner', 3),
('Boundary Setting', 'Trust & Safety', 'core', 'Establishing healthy boundaries that serve the coaching relationship', 'beginner', 4),
('Vulnerability Encouragement', 'Trust & Safety', 'core', 'Creating safety for clients to be vulnerable and authentic', 'beginner', 5);

-- Managing Progress Skills
INSERT INTO skill_tags (name, competency_area, framework, description, difficulty_level, sort_order) VALUES
('Accountability Without Judgment', 'Managing Progress', 'core', 'Supporting accountability while maintaining compassion', 'beginner', 1),
('Obstacle Exploration', 'Managing Progress', 'core', 'Exploring barriers to progress with curiosity', 'beginner', 2),
('Action Plan Co-Creation', 'Managing Progress', 'core', 'Collaboratively creating realistic action plans', 'beginner', 3),
('Progress Tracking', 'Managing Progress', 'core', 'Monitoring and supporting client progress effectively', 'beginner', 4),
('Supportive Follow-Up', 'Managing Progress', 'core', 'Following up on commitments with support rather than judgment', 'beginner', 5);

-- ====================================================================
-- TAG INSIGHTS (Using skill_tag_id references)
-- ====================================================================

-- We need to create insights that reference the skill_tag_id
-- First, let's create weakness insights for each skill tag

-- Active Listening Weakness Insights
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may be focusing too much on your own thoughts and responses instead of fully attending to your client', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Level 2 Listening' AND st.competency_area = 'Active Listening';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'Your content reflection skills need development - practice paraphrasing what clients say', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Reflecting Content' AND st.competency_area = 'Active Listening';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may be missing emotional cues or struggling to reflect feelings accurately', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Reflecting Emotions' AND st.competency_area = 'Active Listening';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'Your attention may drift to planning responses rather than staying fully present', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Staying Present' AND st.competency_area = 'Active Listening';

-- Active Listening Strength Insights
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You demonstrate strong ability to focus entirely on your client without bringing in your own agenda', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Level 2 Listening' AND st.competency_area = 'Active Listening';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You effectively paraphrase and reflect back what clients share with accuracy', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Reflecting Content' AND st.competency_area = 'Active Listening';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You skillfully pick up on and reflect emotional undertones in client communications', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Reflecting Emotions' AND st.competency_area = 'Active Listening';

-- Powerful Questions Insights
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may be asking too many closed questions that limit client exploration', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Open-Ended Questions' AND st.competency_area = 'Powerful Questions';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You consistently ask questions that invite deep exploration and self-discovery', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Open-Ended Questions' AND st.competency_area = 'Powerful Questions';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'Your questions could better help clients connect with their deeper values and motivations', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Values-Based Questions' AND st.competency_area = 'Powerful Questions';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'Your questions effectively help clients connect with what matters most to them', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Values-Based Questions' AND st.competency_area = 'Powerful Questions';

-- Present Moment Awareness Insights
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may be missing important non-verbal cues from your clients', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Body Language Awareness' AND st.competency_area = 'Present Moment Awareness';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You effectively notice and work with non-verbal communication from clients', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Body Language Awareness' AND st.competency_area = 'Present Moment Awareness';

-- Creating Awareness Insights
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may be missing patterns and themes that emerge across client conversations', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Pattern Recognition' AND st.competency_area = 'Creating Awareness';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You effectively notice and highlight patterns in client thinking and behavior', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Pattern Recognition' AND st.competency_area = 'Creating Awareness';

-- Direct Communication Insights
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may let clients talk in circles without helping them focus on core issues', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Bottom-Lining' AND st.competency_area = 'Direct Communication';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You effectively help clients get to the heart of issues without getting lost in stories', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Bottom-Lining' AND st.competency_area = 'Direct Communication';

-- Trust & Safety Insights
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may need clearer boundaries and agreements around confidentiality', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Confidentiality Management' AND st.competency_area = 'Trust & Safety';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You create clear, trustworthy confidentiality agreements and boundaries', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Confidentiality Management' AND st.competency_area = 'Trust & Safety';

-- Managing Progress Insights
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may struggle with holding clients accountable without making them feel bad', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Accountability Without Judgment' AND st.competency_area = 'Managing Progress';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You effectively support accountability while maintaining compassion and understanding', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Accountability Without Judgment' AND st.competency_area = 'Managing Progress';

-- ====================================================================
-- TAG ACTIONS (Using skill_tag_id references)
-- ====================================================================

-- Active Listening Actions
INSERT INTO tag_actions (skill_tag_id, action_text, action_category, priority_order) 
SELECT st.id, 'Practice 10 minutes daily of Level 2 listening - focus entirely on the other person without planning your response', 'practice', 1
FROM skill_tags st WHERE st.name = 'Level 2 Listening' AND st.competency_area = 'Active Listening';

INSERT INTO tag_actions (skill_tag_id, action_text, action_category, priority_order) 
SELECT st.id, 'After someone shares something, practice starting with "It sounds like..." and paraphrase their content', 'practice', 1
FROM skill_tags st WHERE st.name = 'Reflecting Content' AND st.competency_area = 'Active Listening';

INSERT INTO tag_actions (skill_tag_id, action_text, action_category, priority_order) 
SELECT st.id, 'Listen specifically for feeling words and emotional undertones, then reflect: "You seem to be feeling..."', 'practice', 1
FROM skill_tags st WHERE st.name = 'Reflecting Emotions' AND st.competency_area = 'Active Listening';

-- Powerful Questions Actions
INSERT INTO tag_actions (skill_tag_id, action_text, action_category, priority_order) 
SELECT st.id, 'Replace every "Did you..." with "What was it like when you..." this week', 'practice', 1
FROM skill_tags st WHERE st.name = 'Open-Ended Questions' AND st.competency_area = 'Powerful Questions';

INSERT INTO tag_actions (skill_tag_id, action_text, action_category, priority_order) 
SELECT st.id, 'Practice asking "What matters most to you about..." in every conversation', 'practice', 1
FROM skill_tags st WHERE st.name = 'Values-Based Questions' AND st.competency_area = 'Powerful Questions';

-- Present Moment Awareness Actions
INSERT INTO tag_actions (skill_tag_id, action_text, action_category, priority_order) 
SELECT st.id, 'Practice noticing body language changes and gently sharing: "I notice your shoulders..."', 'practice', 1
FROM skill_tags st WHERE st.name = 'Body Language Awareness' AND st.competency_area = 'Present Moment Awareness';

-- Creating Awareness Actions
INSERT INTO tag_actions (skill_tag_id, action_text, action_category, priority_order) 
SELECT st.id, 'Keep notes on themes you hear and share: "I\'ve noticed you often say..."', 'practice', 1
FROM skill_tags st WHERE st.name = 'Pattern Recognition' AND st.competency_area = 'Creating Awareness';

-- Direct Communication Actions  
INSERT INTO tag_actions (skill_tag_id, action_text, action_category, priority_order) 
SELECT st.id, 'Practice summarizing: "So the core issue seems to be..." when clients are circular', 'practice', 1
FROM skill_tags st WHERE st.name = 'Bottom-Lining' AND st.competency_area = 'Direct Communication';

-- Trust & Safety Actions
INSERT INTO tag_actions (skill_tag_id, action_text, action_category, priority_order) 
SELECT st.id, 'Study coaching confidentiality standards and create clear agreements with clients', 'learning', 1
FROM skill_tags st WHERE st.name = 'Confidentiality Management' AND st.competency_area = 'Trust & Safety';

-- Managing Progress Actions
INSERT INTO tag_actions (skill_tag_id, action_text, action_category, priority_order) 
SELECT st.id, 'When clients don\'t follow through, ask: "What got in the way?" with genuine curiosity', 'practice', 1
FROM skill_tags st WHERE st.name = 'Accountability Without Judgment' AND st.competency_area = 'Managing Progress';

SELECT 'Skill tags, tag insights, and tag actions populated successfully' as status;