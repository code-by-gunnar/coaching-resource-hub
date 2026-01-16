-- ====================================================================
-- CORE I DATA POPULATION SCRIPT
-- Complete skill tag insights and actions for production deployment
-- ====================================================================
-- Purpose: Populate all skill-specific insights and actionable steps
-- for the Core I Beginner Assessment (17 skills across 3 competencies)
-- Version: 2.0 - Production-ready data population
-- ====================================================================

-- Clear existing data to prevent duplicates (production-safe updates)
DELETE FROM tag_insights WHERE skill_tag_id IN (
  SELECT st.id FROM skill_tags st WHERE st.framework = 'core' AND st.assessment_level = 'core-i'
);

DELETE FROM tag_actions WHERE skill_tag_id IN (
  SELECT st.id FROM skill_tags st WHERE st.framework = 'core' AND st.assessment_level = 'core-i'
);

-- ====================================================================
-- ACTIVE LISTENING SKILLS - TAG INSIGHTS (6 skills)
-- ====================================================================

-- 1. Reflective Listening
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT st.id, 'You may struggle to accurately reflect back what clients are sharing, missing the emotional undertones or focusing too heavily on the facts rather than the feelings behind their words.', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Reflective Listening' AND st.framework = 'core' AND st.assessment_level = 'core-i';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'Your ability to reflect back both the content and emotional undertones of what clients share creates a powerful sense of being heard and understood, which deepens trust and encourages further exploration.', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Reflective Listening' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 2. Non-Judgmental Listening  
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'You may unconsciously judge clients or their situations, which can create barriers to open communication and prevent clients from sharing their most vulnerable truths.', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Non-Judgmental Listening' AND st.framework = 'core' AND st.assessment_level = 'core-i';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'Your non-judgmental presence creates psychological safety for clients to explore difficult topics without fear of criticism, allowing for authentic self-discovery and growth.', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Non-Judgmental Listening' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 3. Paraphrasing
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'You may have difficulty summarizing and restating what clients have shared in a way that demonstrates understanding while helping them see their situation from a new perspective.', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Paraphrasing' AND st.framework = 'core' AND st.assessment_level = 'core-i';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'Your skillful paraphrasing helps clients hear their own thoughts reflected back in a way that creates clarity and new understanding about their situation and feelings.', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Paraphrasing' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 4. Emotional Mirroring
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'You may miss or inadequately acknowledge the emotional content of what clients share, focusing primarily on facts and missing opportunities to help clients explore their feelings.', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Emotional Mirroring' AND st.framework = 'core' AND st.assessment_level = 'core-i';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'Your sensitivity to emotional nuances and ability to reflect feelings back to clients helps them develop greater emotional awareness and process complex feelings safely.', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Emotional Mirroring' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 5. Staying Present
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'Your mind may wander during coaching sessions, or you might get caught up in planning your next response rather than staying fully present with what the client is sharing in the moment.', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Staying Present' AND st.framework = 'core' AND st.assessment_level = 'core-i';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'Your ability to maintain present-moment awareness creates a container of focused attention that allows clients to feel fully seen and supported as they explore their thoughts and feelings.', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Staying Present' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 6. Deep Listening
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'You may listen primarily at a surface level, hearing the words but missing the deeper meanings, unspoken concerns, or underlying themes that are most important to your client.', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Deep Listening' AND st.framework = 'core' AND st.assessment_level = 'core-i';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'Your capacity for deep listening allows you to hear beyond words to the underlying meanings, concerns, and desires that clients may not even be fully aware of themselves.', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Deep Listening' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- ====================================================================
-- POWERFUL QUESTIONS SKILLS - TAG INSIGHTS (6 skills)
-- ====================================================================

-- 7. Open-Ended Questions
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'You may rely too heavily on closed-ended questions that limit client responses, missing opportunities to help clients explore their thoughts and feelings more deeply.', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Open-Ended Questions' AND st.framework = 'core' AND st.assessment_level = 'core-i';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'Your skillful use of open-ended questions creates space for clients to explore their thoughts and feelings comprehensively, leading to richer insights and self-discovery.', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Open-Ended Questions' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 8. Clarifying Questions
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'You may make assumptions about what clients mean rather than asking clarifying questions, which can lead to misunderstandings and missed opportunities for deeper exploration.', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Clarifying Questions' AND st.framework = 'core' AND st.assessment_level = 'core-i';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'Your use of clarifying questions helps ensure mutual understanding while encouraging clients to articulate their thoughts and feelings with greater precision and awareness.', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Clarifying Questions' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 9. Future-Focused Questions
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'You may focus too much on past events or current problems rather than helping clients envision possibilities and explore what they want to create moving forward.', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Future-Focused Questions' AND st.framework = 'core' AND st.assessment_level = 'core-i';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'Your ability to guide clients toward future possibilities and desired outcomes helps them shift from problem-focused thinking to solution-oriented exploration and goal creation.', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Future-Focused Questions' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 10. Values-Based Questions
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'You may focus on surface-level concerns without helping clients connect their decisions and challenges to their deeper values and what matters most to them.', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Values-Based Questions' AND st.framework = 'core' AND st.assessment_level = 'core-i';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'Your questions help clients connect with their core values and what matters most to them, providing a foundation for authentic decision-making and meaningful goal setting.', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Values-Based Questions' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 11. Perspective Shift Questions
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'You may allow clients to remain stuck in their current perspective rather than offering questions that help them consider alternative viewpoints or reframe their situation.', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Perspective Shift Questions' AND st.framework = 'core' AND st.assessment_level = 'core-i';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'Your questions skillfully invite clients to consider new perspectives and reframe their challenges, opening up possibilities they may not have previously considered.', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Perspective Shift Questions' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 12. Possibility Questions
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'You may focus on limitations and obstacles rather than helping clients explore possibilities and expand their sense of what could be achievable for them.', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Possibility Questions' AND st.framework = 'core' AND st.assessment_level = 'core-i';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'Your questions help clients expand their awareness of possibilities and potential, shifting them from constraint-based thinking to opportunity-focused exploration.', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Possibility Questions' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- ====================================================================
-- PRESENT MOMENT AWARENESS SKILLS - TAG INSIGHTS (5 skills)
-- ====================================================================

-- 13. Emotional Awareness
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'You may miss emotional cues or fail to help clients become aware of their feelings in the present moment, limiting opportunities for emotional growth and self-understanding.', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Emotional Awareness' AND st.framework = 'core' AND st.assessment_level = 'core-i';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'Your ability to notice and help clients become aware of their emotions in real-time creates opportunities for powerful breakthroughs and deeper self-understanding.', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Emotional Awareness' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 14. Energy Reading
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'You may not notice shifts in client energy or fail to use these observations therapeutically to deepen the coaching conversation and create breakthrough moments.', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Energy Reading' AND st.framework = 'core' AND st.assessment_level = 'core-i';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'Your sensitivity to energy shifts and changes in client presence allows you to identify important moments and guide clients toward deeper self-awareness and insight.', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Energy Reading' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 15. Intuitive Observations
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'You may rely too heavily on logic and miss intuitive insights about clients, or lack confidence in sharing observations that could lead to powerful coaching moments.', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Intuitive Observations' AND st.framework = 'core' AND st.assessment_level = 'core-i';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'Your intuitive observations and willingness to share what you notice creates opportunities for clients to gain unexpected insights and access their own inner wisdom.', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Intuitive Observations' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 16. Silence Comfort
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'You may feel uncomfortable with silence and rush to fill quiet moments, missing opportunities for clients to process internally and access deeper insights.', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Silence Comfort' AND st.framework = 'core' AND st.assessment_level = 'core-i';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'Your comfort with silence creates space for clients to process deeply and often leads to their most profound insights and breakthrough moments during coaching sessions.', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Silence Comfort' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 17. Present Moment Coaching
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'You may focus too much on content and stories rather than helping clients notice what is happening for them right now in the present moment of the coaching session.', 'weakness', 'beginner'
FROM skill_tags st WHERE st.name = 'Present Moment Coaching' AND st.framework = 'core' AND st.assessment_level = 'core-i';

INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level)
SELECT st.id, 'Your skill in present moment coaching helps clients become aware of immediate experiences, thoughts, and feelings, creating powerful opportunities for real-time transformation.', 'strength', 'beginner'
FROM skill_tags st WHERE st.name = 'Present Moment Coaching' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- ====================================================================
-- ACTIVE LISTENING SKILLS - TAG ACTIONS (6 skills)
-- ====================================================================

-- 1. Reflective Listening
INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'Practice the "What I heard you say..." technique: After clients share something important, reflect back both the content and the emotional undertone you noticed. For example: "What I heard you say is that you''re feeling overwhelmed by the decision, and there seems to be some sadness there too - is that accurate?"', true
FROM skill_tags st WHERE st.name = 'Reflective Listening' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 2. Non-Judgmental Listening
INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'Before each session, set an intention to approach your client with curiosity rather than judgment. When you notice judgmental thoughts arising, gently redirect your attention back to understanding the client''s experience from their perspective. Practice the phrase: "Help me understand more about that..."', true
FROM skill_tags st WHERE st.name = 'Non-Judgmental Listening' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 3. Paraphrasing
INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'After clients share complex information, paraphrase using different words to check understanding: "So if I''m hearing this correctly, what you''re saying is..." This helps clients hear their thoughts reflected back and often leads to new clarity or corrections that deepen understanding.', true
FROM skill_tags st WHERE st.name = 'Paraphrasing' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 4. Emotional Mirroring
INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'Pay special attention to the emotional words clients use and reflect those back: "I notice you used the word ''frustrated'' - can you tell me more about that frustration?" Also notice non-verbal emotional cues like tone, pace, or energy shifts and gently bring awareness to what you observe.', true
FROM skill_tags st WHERE st.name = 'Emotional Mirroring' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 5. Staying Present
INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'When you notice your mind wandering, gently bring your attention back to your client without judgment. Take a breath and refocus on their words, tone, and energy. If you miss something, it''s okay to say: "I want to make sure I''m fully present with you - could you share that last part again?"', true
FROM skill_tags st WHERE st.name = 'Staying Present' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 6. Deep Listening
INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'Listen for themes, patterns, and what''s NOT being said. Ask yourself: "What might be the deeper concern here?" and "What theme keeps appearing in different forms?" Share these observations gently: "I''m noticing a theme around [pattern] - does that resonate with you?"', true
FROM skill_tags st WHERE st.name = 'Deep Listening' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- ====================================================================
-- POWERFUL QUESTIONS SKILLS - TAG ACTIONS (6 skills)
-- ====================================================================

-- 7. Open-Ended Questions
INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'Replace "Did you..." and "Are you..." questions with "What..." and "How..." questions. Instead of "Did that work for you?" ask "What was that experience like for you?" Practice starting questions with: What, How, When used in the right context, and Who in relation to support systems.', true
FROM skill_tags st WHERE st.name = 'Open-Ended Questions' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 8. Clarifying Questions
INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'When clients use vague language, ask for specifics: "When you say ''stressful,'' what does that look like for you?" or "Help me understand what you mean by ''not going well.''" This helps both you and the client gain clarity about their actual experience.', true
FROM skill_tags st WHERE st.name = 'Clarifying Questions' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 9. Future-Focused Questions
INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'When clients get stuck in problems, gently shift toward possibilities: "What would you like to see happen instead?" or "If this situation were exactly as you wanted it to be, what would that look like?" Help clients envision their desired future state before problem-solving.', true
FROM skill_tags st WHERE st.name = 'Future-Focused Questions' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 10. Values-Based Questions
INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'Help clients connect decisions to their values: "What''s most important to you about how this situation unfolds?" and "What would need to be true for this to feel aligned with who you are?" Guide them to consider not just what they want, but why it matters to them.', true
FROM skill_tags st WHERE st.name = 'Values-Based Questions' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 11. Perspective Shift Questions
INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'Offer alternative viewpoints gently: "What would someone who cares about you say about this situation?" or "If you were advising a good friend in this exact situation, what would you tell them?" Help clients step outside their current perspective to gain new insights.', true
FROM skill_tags st WHERE st.name = 'Perspective Shift Questions' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 12. Possibility Questions
INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'Expand client thinking with possibility questions: "What becomes possible if you approach this differently?" and "What would you attempt if you knew you couldn''t fail?" Help clients move beyond current limitations to explore potential opportunities and solutions.', true
FROM skill_tags st WHERE st.name = 'Possibility Questions' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- ====================================================================
-- PRESENT MOMENT AWARENESS SKILLS - TAG ACTIONS (5 skills)
-- ====================================================================

-- 13. Emotional Awareness
INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'Notice when clients'' emotional state shifts during the session and gently bring attention to it: "I''m noticing your energy seems different now than when we started - what are you aware of?" Help clients connect with their present-moment emotional experience.', true
FROM skill_tags st WHERE st.name = 'Emotional Awareness' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 14. Energy Reading
INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'Pay attention to changes in client voice tone, pace, body language, and overall energy throughout the session. When you notice a shift, share your observation: "Something seems to have shifted for you just now - what happened?" These moments often lead to breakthrough insights.', true
FROM skill_tags st WHERE st.name = 'Energy Reading' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 15. Intuitive Observations
INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'Trust and share your intuitive observations with clients: "I''m sensing some hesitation as you talk about this - am I reading that correctly?" or "Something feels unfinished about this topic for you." Give clients permission to correct you if your intuition is off-target.', true
FROM skill_tags st WHERE st.name = 'Intuitive Observations' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 16. Silence Comfort
INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'Practice holding comfortable silence after powerful questions or moments. Count to at least 10 before speaking again. When clients are processing internally, resist the urge to fill the space with words. Often their most profound insights emerge from these quiet moments.', true
FROM skill_tags st WHERE st.name = 'Silence Comfort' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- 17. Present Moment Coaching
INSERT INTO tag_actions (skill_tag_id, action_text, is_active)
SELECT st.id, 'Regularly bring clients back to the present moment: "What are you noticing right now as you talk about this?" or "How does it feel in your body to say that out loud?" Help clients connect with their immediate experience rather than staying in story or analysis.', true
FROM skill_tags st WHERE st.name = 'Present Moment Coaching' AND st.framework = 'core' AND st.assessment_level = 'core-i';

-- ====================================================================
-- VERIFICATION QUERIES
-- ====================================================================

SELECT 'CORE I DATA POPULATION VERIFICATION' as status;

SELECT '';
SELECT 'TAG INSIGHTS CREATED:' as section;
SELECT st.competency_area, st.name, COUNT(ti.id) as insights_count
FROM skill_tags st
LEFT JOIN tag_insights ti ON st.id = ti.skill_tag_id
WHERE st.framework = 'core' AND st.assessment_level = 'core-i'
GROUP BY st.competency_area, st.name, st.sort_order
ORDER BY st.competency_area, st.sort_order;

SELECT '';
SELECT 'TAG ACTIONS CREATED:' as section;  
SELECT st.competency_area, st.name, COUNT(ta.id) as actions_count
FROM skill_tags st
LEFT JOIN tag_actions ta ON st.id = ta.skill_tag_id
WHERE st.framework = 'core' AND st.assessment_level = 'core-i'
GROUP BY st.competency_area, st.name, st.sort_order
ORDER BY st.competency_area, st.sort_order;

SELECT '';
SELECT 'TOTAL DATA SUMMARY:' as section;
SELECT 
  'Tag Insights' as data_type,
  COUNT(ti.id) as total_records
FROM tag_insights ti
JOIN skill_tags st ON ti.skill_tag_id = st.id
WHERE st.framework = 'core' AND st.assessment_level = 'core-i'
UNION ALL
SELECT 
  'Tag Actions' as data_type,
  COUNT(ta.id) as total_records
FROM tag_actions ta
JOIN skill_tags st ON ta.skill_tag_id = st.id
WHERE st.framework = 'core' AND st.assessment_level = 'core-i';

SELECT '';
SELECT 'DATA POPULATION COMPLETE - Core I Assessment Ready with Full Insights' as final_status;