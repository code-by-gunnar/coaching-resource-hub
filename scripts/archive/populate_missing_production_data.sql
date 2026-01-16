-- ====================================================================
-- POPULATE MISSING PRODUCTION DATA FOR CORE I BEGINNER ASSESSMENT
-- ====================================================================
-- Purpose: Complete all missing database tables for production-ready assessment
-- Tables: skill_tags, tag_insights, tag_actions, competency_display_names, 
--         learning_path_categories, learning_resources
-- ====================================================================

-- ====================================================================
-- COMPETENCY DISPLAY NAMES
-- ====================================================================
INSERT INTO competency_display_names (competency_area, display_name, framework, difficulty_level, sort_order) VALUES
-- Core I Beginner competency display names
('Active Listening', 'Active Listening', 'core', 'beginner', 1),
('Powerful Questions', 'Powerful Questions', 'core', 'beginner', 2),
('Present Moment Awareness', 'Present Moment Awareness', 'core', 'beginner', 3),
('Creating Awareness', 'Creating Awareness', 'core', 'beginner', 4),
('Direct Communication', 'Direct Communication', 'core', 'beginner', 5),
('Trust & Safety', 'Trust & Safety', 'core', 'beginner', 6),
('Managing Progress', 'Managing Progress', 'core', 'beginner', 7);

-- ====================================================================
-- SKILL TAGS
-- ====================================================================

-- Active Listening Skills
INSERT INTO skill_tags (competency_area, tag_name, tag_type, framework, difficulty_level, sort_order) VALUES
('Active Listening', 'Level 2 Listening', 'fundamental', 'core', 'beginner', 1),
('Active Listening', 'Reflecting Content', 'fundamental', 'core', 'beginner', 2),
('Active Listening', 'Reflecting Emotions', 'fundamental', 'core', 'beginner', 3),
('Active Listening', 'Paraphrasing', 'fundamental', 'core', 'beginner', 4),
('Active Listening', 'Staying Present', 'fundamental', 'core', 'beginner', 5),
('Active Listening', 'Non-Judgmental Listening', 'fundamental', 'core', 'beginner', 6);

-- Powerful Questions Skills
INSERT INTO skill_tags (competency_area, tag_name, tag_type, framework, difficulty_level, sort_order) VALUES
('Powerful Questions', 'Open-Ended Questions', 'fundamental', 'core', 'beginner', 1),
('Powerful Questions', 'Values-Based Questions', 'fundamental', 'core', 'beginner', 2),
('Powerful Questions', 'Future-Focused Questions', 'fundamental', 'core', 'beginner', 3),
('Powerful Questions', 'Possibility Questions', 'fundamental', 'core', 'beginner', 4),
('Powerful Questions', 'Clarifying Questions', 'fundamental', 'core', 'beginner', 5),
('Powerful Questions', 'Perspective Shift Questions', 'fundamental', 'core', 'beginner', 6);

-- Present Moment Awareness Skills
INSERT INTO skill_tags (competency_area, tag_name, tag_type, framework, difficulty_level, sort_order) VALUES
('Present Moment Awareness', 'Body Language Awareness', 'fundamental', 'core', 'beginner', 1),
('Present Moment Awareness', 'Energy Reading', 'fundamental', 'core', 'beginner', 2),
('Present Moment Awareness', 'Silence Comfort', 'fundamental', 'core', 'beginner', 3),
('Present Moment Awareness', 'Emotional Awareness', 'fundamental', 'core', 'beginner', 4),
('Present Moment Awareness', 'Intuitive Observations', 'fundamental', 'core', 'beginner', 5);

-- Creating Awareness Skills  
INSERT INTO skill_tags (competency_area, tag_name, tag_type, framework, difficulty_level, sort_order) VALUES
('Creating Awareness', 'Pattern Recognition', 'fundamental', 'core', 'beginner', 1),
('Creating Awareness', 'Contradiction Pointing', 'fundamental', 'core', 'beginner', 2),
('Creating Awareness', 'Self-Discovery Facilitation', 'fundamental', 'core', 'beginner', 3),
('Creating Awareness', 'Observation Sharing', 'fundamental', 'core', 'beginner', 4),
('Creating Awareness', 'Blind Spot Illumination', 'fundamental', 'core', 'beginner', 5);

-- Direct Communication Skills
INSERT INTO skill_tags (competency_area, tag_name, tag_type, framework, difficulty_level, sort_order) VALUES
('Direct Communication', 'Bottom-Lining', 'fundamental', 'core', 'beginner', 1),
('Direct Communication', 'Respectful Interrupting', 'fundamental', 'core', 'beginner', 2),
('Direct Communication', 'Clear Boundaries', 'fundamental', 'core', 'beginner', 3),
('Direct Communication', 'Honest Feedback', 'fundamental', 'core', 'beginner', 4),
('Direct Communication', 'Difficult Conversations', 'fundamental', 'core', 'beginner', 5);

-- Trust & Safety Skills
INSERT INTO skill_tags (competency_area, tag_name, tag_type, framework, difficulty_level, sort_order) VALUES
('Trust & Safety', 'Confidentiality Management', 'fundamental', 'core', 'beginner', 1),
('Trust & Safety', 'Emotional Safety', 'fundamental', 'core', 'beginner', 2),
('Trust & Safety', 'Non-Judgmental Presence', 'fundamental', 'core', 'beginner', 3),
('Trust & Safety', 'Boundary Setting', 'fundamental', 'core', 'beginner', 4),
('Trust & Safety', 'Vulnerability Encouragement', 'fundamental', 'core', 'beginner', 5);

-- Managing Progress Skills
INSERT INTO skill_tags (competency_area, tag_name, tag_type, framework, difficulty_level, sort_order) VALUES
('Managing Progress', 'Accountability Without Judgment', 'fundamental', 'core', 'beginner', 1),
('Managing Progress', 'Obstacle Exploration', 'fundamental', 'core', 'beginner', 2),
('Managing Progress', 'Action Plan Co-Creation', 'fundamental', 'core', 'beginner', 3),
('Managing Progress', 'Progress Tracking', 'fundamental', 'core', 'beginner', 4),
('Managing Progress', 'Supportive Follow-Up', 'fundamental', 'core', 'beginner', 5);

-- ====================================================================
-- TAG INSIGHTS
-- ====================================================================

-- Active Listening Tag Insights
INSERT INTO tag_insights (competency_area, tag_name, insight_text, score_range_min, score_range_max, framework, difficulty_level) VALUES
-- Weakness insights (0-60%)
('Active Listening', 'Level 2 Listening', 'You may be focusing too much on your own thoughts and responses instead of fully attending to your client', 0, 60, 'core', 'beginner'),
('Active Listening', 'Reflecting Content', 'Your content reflection skills need development - practice paraphrasing what clients say', 0, 60, 'core', 'beginner'),
('Active Listening', 'Reflecting Emotions', 'You may be missing emotional cues or struggling to reflect feelings accurately', 0, 60, 'core', 'beginner'),
('Active Listening', 'Staying Present', 'Your attention may drift to planning responses rather than staying fully present', 0, 60, 'core', 'beginner'),

-- Strength insights (60-100%)
('Active Listening', 'Level 2 Listening', 'You demonstrate strong ability to focus entirely on your client without bringing in your own agenda', 60, 100, 'core', 'beginner'),
('Active Listening', 'Reflecting Content', 'You effectively paraphrase and reflect back what clients share with accuracy', 60, 100, 'core', 'beginner'),
('Active Listening', 'Reflecting Emotions', 'You skillfully pick up on and reflect emotional undertones in client communications', 60, 100, 'core', 'beginner'),
('Active Listening', 'Staying Present', 'You maintain consistent presence and attention throughout coaching conversations', 60, 100, 'core', 'beginner'),

-- Powerful Questions Tag Insights
('Powerful Questions', 'Open-Ended Questions', 'You may be asking too many closed questions that limit client exploration', 0, 60, 'core', 'beginner'),
('Powerful Questions', 'Values-Based Questions', 'Your questions could better help clients connect with their deeper values and motivations', 0, 60, 'core', 'beginner'),
('Powerful Questions', 'Future-Focused Questions', 'You may be staying too focused on problems rather than exploring possibilities', 0, 60, 'core', 'beginner'),

('Powerful Questions', 'Open-Ended Questions', 'You consistently ask questions that invite deep exploration and self-discovery', 60, 100, 'core', 'beginner'),
('Powerful Questions', 'Values-Based Questions', 'Your questions effectively help clients connect with what matters most to them', 60, 100, 'core', 'beginner'),
('Powerful Questions', 'Future-Focused Questions', 'You skillfully guide clients toward exploring possibilities and potential outcomes', 60, 100, 'core', 'beginner'),

-- Present Moment Awareness Tag Insights
('Present Moment Awareness', 'Body Language Awareness', 'You may be missing important non-verbal cues from your clients', 0, 60, 'core', 'beginner'),
('Present Moment Awareness', 'Energy Reading', 'Your ability to sense energy shifts and dynamics could be stronger', 0, 60, 'core', 'beginner'),
('Present Moment Awareness', 'Silence Comfort', 'You may feel uncomfortable with silence and rush to fill quiet moments', 0, 60, 'core', 'beginner'),

('Present Moment Awareness', 'Body Language Awareness', 'You effectively notice and work with non-verbal communication from clients', 60, 100, 'core', 'beginner'),
('Present Moment Awareness', 'Energy Reading', 'You demonstrate good awareness of energy shifts and unspoken dynamics', 60, 100, 'core', 'beginner'),
('Present Moment Awareness', 'Silence Comfort', 'You use silence effectively to create space for client reflection and insight', 60, 100, 'core', 'beginner'),

-- Creating Awareness Tag Insights  
('Creating Awareness', 'Pattern Recognition', 'You may be missing patterns and themes that emerge across client conversations', 0, 60, 'core', 'beginner'),
('Creating Awareness', 'Observation Sharing', 'Your skills in sharing observations with clients need development', 0, 60, 'core', 'beginner'),
('Creating Awareness', 'Self-Discovery Facilitation', 'You may be telling clients insights rather than helping them discover for themselves', 0, 60, 'core', 'beginner'),

('Creating Awareness', 'Pattern Recognition', 'You effectively notice and highlight patterns in client thinking and behavior', 60, 100, 'core', 'beginner'),
('Creating Awareness', 'Observation Sharing', 'You skillfully share observations that create new awareness for clients', 60, 100, 'core', 'beginner'),
('Creating Awareness', 'Self-Discovery Facilitation', 'You excel at helping clients discover their own insights rather than providing answers', 60, 100, 'core', 'beginner'),

-- Direct Communication Tag Insights
('Direct Communication', 'Bottom-Lining', 'You may let clients talk in circles without helping them focus on core issues', 0, 60, 'core', 'beginner'),
('Direct Communication', 'Respectful Interrupting', 'Your skills in respectfully redirecting conversations need development', 0, 60, 'core', 'beginner'),
('Direct Communication', 'Honest Feedback', 'You may avoid giving direct feedback that could benefit your clients', 0, 60, 'core', 'beginner'),

('Direct Communication', 'Bottom-Lining', 'You effectively help clients get to the heart of issues without getting lost in stories', 60, 100, 'core', 'beginner'),
('Direct Communication', 'Respectful Interrupting', 'You skillfully redirect conversations while maintaining rapport and respect', 60, 100, 'core', 'beginner'),
('Direct Communication', 'Honest Feedback', 'You provide direct, helpful feedback that serves your client\'s growth', 60, 100, 'core', 'beginner'),

-- Trust & Safety Tag Insights
('Trust & Safety', 'Confidentiality Management', 'You may need clearer boundaries and agreements around confidentiality', 0, 60, 'core', 'beginner'),
('Trust & Safety', 'Emotional Safety', 'Clients may not feel completely safe to be vulnerable in your presence', 0, 60, 'core', 'beginner'),
('Trust & Safety', 'Non-Judgmental Presence', 'You may inadvertently communicate judgment through tone, words, or body language', 0, 60, 'core', 'beginner'),

('Trust & Safety', 'Confidentiality Management', 'You create clear, trustworthy confidentiality agreements and boundaries', 60, 100, 'core', 'beginner'),
('Trust & Safety', 'Emotional Safety', 'You consistently create an emotionally safe space for client vulnerability', 60, 100, 'core', 'beginner'),
('Trust & Safety', 'Non-Judgmental Presence', 'Your non-judgmental presence allows clients to share authentically', 60, 100, 'core', 'beginner'),

-- Managing Progress Tag Insights
('Managing Progress', 'Accountability Without Judgment', 'You may struggle with holding clients accountable without making them feel bad', 0, 60, 'core', 'beginner'),
('Managing Progress', 'Obstacle Exploration', 'Your skills in exploring what gets in clients\' way need development', 0, 60, 'core', 'beginner'),
('Managing Progress', 'Action Plan Co-Creation', 'You may create action plans for clients rather than co-creating with them', 0, 60, 'core', 'beginner'),

('Managing Progress', 'Accountability Without Judgment', 'You effectively support accountability while maintaining compassion and understanding', 60, 100, 'core', 'beginner'),
('Managing Progress', 'Obstacle Exploration', 'You skillfully explore obstacles and barriers with curiosity rather than judgment', 60, 100, 'core', 'beginner'),
('Managing Progress', 'Action Plan Co-Creation', 'You excel at co-creating realistic, supportive action plans with clients', 60, 100, 'core', 'beginner');

-- ====================================================================
-- TAG ACTIONS  
-- ====================================================================

-- Active Listening Tag Actions
INSERT INTO tag_actions (competency_area, tag_name, action_text, action_type, score_range_min, score_range_max, framework, difficulty_level) VALUES
-- Development actions (0-60%)
('Active Listening', 'Level 2 Listening', 'Practice 10 minutes daily of Level 2 listening - focus entirely on the other person without planning your response', 'practice', 0, 60, 'core', 'beginner'),
('Active Listening', 'Reflecting Content', 'After someone shares something, practice starting with "It sounds like..." and paraphrase their content', 'practice', 0, 60, 'core', 'beginner'),
('Active Listening', 'Reflecting Emotions', 'Listen specifically for feeling words and emotional undertones, then reflect: "You seem to be feeling..."', 'practice', 0, 60, 'core', 'beginner'),
('Active Listening', 'Staying Present', 'Notice when your mind wanders to your response and gently bring attention back to the speaker', 'reflection', 0, 60, 'core', 'beginner'),

-- Leverage actions (60-100%)  
('Active Listening', 'Level 2 Listening', 'Use your Level 2 listening strength to model deep presence for other coaches', 'session', 60, 100, 'core', 'beginner'),
('Active Listening', 'Reflecting Content', 'Leverage your content reflection skills to help clients feel truly heard and understood', 'session', 60, 100, 'core', 'beginner'),
('Active Listening', 'Reflecting Emotions', 'Use your emotional reflection abilities to create deeper safety and connection', 'session', 60, 100, 'core', 'beginner'),

-- Powerful Questions Tag Actions
('Powerful Questions', 'Open-Ended Questions', 'Replace every "Did you..." with "What was it like when you..." this week', 'practice', 0, 60, 'core', 'beginner'),
('Powerful Questions', 'Values-Based Questions', 'Practice asking "What matters most to you about..." in every conversation', 'practice', 0, 60, 'core', 'beginner'),
('Powerful Questions', 'Future-Focused Questions', 'Ask "What would be possible if..." to shift from problems to possibilities', 'practice', 0, 60, 'core', 'beginner'),

('Powerful Questions', 'Open-Ended Questions', 'Use your questioning strength to help clients discover insights they already have within them', 'session', 60, 100, 'core', 'beginner'),
('Powerful Questions', 'Values-Based Questions', 'Leverage your values-based questions to help clients make aligned decisions', 'session', 60, 100, 'core', 'beginner'),

-- Present Moment Awareness Tag Actions
('Present Moment Awareness', 'Body Language Awareness', 'Practice noticing body language changes and gently sharing: "I notice your shoulders..."', 'practice', 0, 60, 'core', 'beginner'),
('Present Moment Awareness', 'Energy Reading', 'Pay attention to energy shifts in conversations and pause to check: "Something just shifted..."', 'practice', 0, 60, 'core', 'beginner'),
('Present Moment Awareness', 'Silence Comfort', 'Practice sitting in silence for 10 seconds after emotional shares before responding', 'practice', 0, 60, 'core', 'beginner'),

('Present Moment Awareness', 'Body Language Awareness', 'Use your body language awareness to deepen conversations with your observations', 'session', 60, 100, 'core', 'beginner'),
('Present Moment Awareness', 'Energy Reading', 'Leverage your energy reading to work with what\'s really happening beneath the surface', 'session', 60, 100, 'core', 'beginner'),

-- Creating Awareness Tag Actions
('Creating Awareness', 'Pattern Recognition', 'Keep notes on themes you hear and share: "I\'ve noticed you often say..." ', 'practice', 0, 60, 'core', 'beginner'),
('Creating Awareness', 'Observation Sharing', 'Practice sharing observations with curiosity: "I notice... what do you notice about that?"', 'practice', 0, 60, 'core', 'beginner'),
('Creating Awareness', 'Self-Discovery Facilitation', 'Instead of giving insights, ask: "What do you think might be going on here?"', 'practice', 0, 60, 'core', 'beginner'),

('Creating Awareness', 'Pattern Recognition', 'Use your pattern recognition to help clients see themes they haven\'t noticed', 'session', 60, 100, 'core', 'beginner'),
('Creating Awareness', 'Observation Sharing', 'Leverage your observation skills to create powerful breakthrough moments', 'session', 60, 100, 'core', 'beginner'),

-- Direct Communication Tag Actions  
('Direct Communication', 'Bottom-Lining', 'Practice summarizing: "So the core issue seems to be..." when clients are circular', 'practice', 0, 60, 'core', 'beginner'),
('Direct Communication', 'Respectful Interrupting', 'Learn to say "Can we pause here?" followed by a focusing question', 'practice', 0, 60, 'core', 'beginner'),
('Direct Communication', 'Honest Feedback', 'Practice giving one piece of direct feedback that serves the client\'s growth', 'practice', 0, 60, 'core', 'beginner'),

('Direct Communication', 'Bottom-Lining', 'Use your bottom-lining skills to help clients get unstuck from story-telling', 'session', 60, 100, 'core', 'beginner'),
('Direct Communication', 'Respectful Interrupting', 'Leverage your respectful interrupting to keep sessions focused and productive', 'session', 60, 100, 'core', 'beginner'),

-- Trust & Safety Tag Actions
('Trust & Safety', 'Confidentiality Management', 'Study coaching confidentiality standards and create clear agreements with clients', 'study', 0, 60, 'core', 'beginner'),
('Trust & Safety', 'Emotional Safety', 'Practice saying "Your feelings are welcome here" and "This is your safe space"', 'practice', 0, 60, 'core', 'beginner'),
('Trust & Safety', 'Non-Judgmental Presence', 'Notice judgmental thoughts and practice responding with curiosity instead', 'reflection', 0, 60, 'core', 'beginner'),

('Trust & Safety', 'Confidentiality Management', 'Use your strong confidentiality practices as a foundation for deeper trust', 'session', 60, 100, 'core', 'beginner'),
('Trust & Safety', 'Emotional Safety', 'Leverage your emotional safety skills to enable vulnerable, transformational work', 'session', 60, 100, 'core', 'beginner'),

-- Managing Progress Tag Actions
('Managing Progress', 'Accountability Without Judgment', 'When clients don\'t follow through, ask: "What got in the way?" with genuine curiosity', 'practice', 0, 60, 'core', 'beginner'),
('Managing Progress', 'Obstacle Exploration', 'Practice exploring barriers: "What would support you in moving forward?"', 'practice', 0, 60, 'core', 'beginner'),
('Managing Progress', 'Action Plan Co-Creation', 'Always ask: "What feels realistic and supportive for you?" when creating action plans', 'practice', 0, 60, 'core', 'beginner'),

('Managing Progress', 'Accountability Without Judgment', 'Use your compassionate accountability approach to support consistent client growth', 'session', 60, 100, 'core', 'beginner'),
('Managing Progress', 'Obstacle Exploration', 'Leverage your obstacle exploration skills to help clients overcome real barriers', 'session', 60, 100, 'core', 'beginner');

SELECT 'Skill tags, tag insights, and tag actions populated successfully' as status;