-- ====================================================================
-- CORE I BEGINNER - COMPETENCY DATA
-- ====================================================================
-- Purpose: Create competency insights, actions, and resources for real assessment
-- Competencies: Active Listening, Powerful Questions, Present Moment Awareness,
--               Creating Awareness, Direct Communication, Trust & Safety, Managing Progress
-- ====================================================================

-- ====================================================================
-- COMPETENCY STRATEGIC ACTIONS
-- ====================================================================

-- Active Listening Actions
INSERT INTO competency_strategic_actions (competency_area, action_text, action_type, score_range_min, score_range_max, framework, difficulty_level, sort_order) VALUES
-- Low performance (0-40%)
('Active Listening', 'Practice Level 2 listening for 10 minutes daily with a partner - focus entirely on their experience without bringing in your own thoughts', 'practice', 0, 40, 'core', 'beginner', 1),
('Active Listening', 'Record yourself listening to someone for 5 minutes, then review what you noticed about yourself vs what you heard from them', 'reflection', 0, 40, 'core', 'beginner', 2),
('Active Listening', 'Learn to reflect back both content and emotion - practice the phrase "It sounds like..." daily', 'study', 0, 40, 'core', 'beginner', 3),

-- Medium performance (40-70%)
('Active Listening', 'Practice sitting in silence for 10 seconds after someone shares something emotional before responding', 'practice', 40, 70, 'core', 'beginner', 1),
('Active Listening', 'Focus on reflecting back not just what they say, but what you sense they feel', 'session', 40, 70, 'core', 'beginner', 2),

-- High performance (70-100%)
('Active Listening', 'Refine your ability to listen at Level 3 - notice energy, what''s not being said, and environmental factors', 'practice', 70, 100, 'core', 'beginner', 1),
('Active Listening', 'Practice advanced reflecting that captures the deeper meaning beneath their words', 'session', 70, 100, 'core', 'beginner', 2),

-- Powerful Questions Actions
-- Low performance (0-40%)
('Powerful Questions', 'Study the difference between open and closed questions - practice asking "What..." and "How..." questions daily', 'study', 0, 40, 'core', 'beginner', 1),
('Powerful Questions', 'Replace every "Did you..." question with "What was it like when you..." this week', 'practice', 0, 40, 'core', 'beginner', 2),
('Powerful Questions', 'Practice asking follow-up questions that explore "What does that mean to you?" and "What''s important about that?"', 'practice', 0, 40, 'core', 'beginner', 3),

-- Medium performance (40-70%)
('Powerful Questions', 'Focus on asking questions that help clients connect with their values: "What matters most to you about...?"', 'session', 40, 70, 'core', 'beginner', 1),
('Powerful Questions', 'Practice questions that create new perspectives: "What would be possible if...?" or "What else could be true?"', 'practice', 40, 70, 'core', 'beginner', 2),

-- High performance (70-100%)
('Powerful Questions', 'Refine your timing - practice asking powerful questions in moments of pause or energy shift', 'session', 70, 100, 'core', 'beginner', 1),
('Powerful Questions', 'Develop questions that help clients discover their own answers rather than seeking information', 'practice', 70, 100, 'core', 'beginner', 2),

-- Present Moment Awareness Actions
-- Low performance (0-40%)
('Present Moment Awareness', 'Practice checking in with yourself every 5 minutes during conversations - notice your breath, posture, thoughts', 'practice', 0, 40, 'core', 'beginner', 1),
('Present Moment Awareness', 'Learn to notice when your attention drifts to planning what to say next instead of listening', 'reflection', 0, 40, 'core', 'beginner', 2),

-- Medium performance (40-70%)
('Present Moment Awareness', 'Practice noticing and gently sharing body language and energy shifts you observe in others', 'session', 40, 70, 'core', 'beginner', 1),
('Present Moment Awareness', 'Develop comfort with silence - practice staying present during emotional or quiet moments', 'practice', 40, 70, 'core', 'beginner', 2),

-- High performance (70-100%)
('Present Moment Awareness', 'Refine your ability to sense underlying emotions and energy patterns in the room', 'practice', 70, 100, 'core', 'beginner', 1),
('Present Moment Awareness', 'Practice bringing present-moment observations into the conversation to deepen insights', 'session', 70, 100, 'core', 'beginner', 2),

-- Creating Awareness Actions
-- Low performance (0-40%)
('Creating Awareness', 'Practice simply reflecting back patterns you hear: "I''ve noticed you often say..." without interpreting', 'practice', 0, 40, 'core', 'beginner', 1),
('Creating Awareness', 'Learn to ask "What do you notice about that?" after sharing an observation', 'study', 0, 40, 'core', 'beginner', 2),

-- Medium performance (40-70%)
('Creating Awareness', 'Practice identifying and sharing contradictions you hear between what someone says and feels', 'session', 40, 70, 'core', 'beginner', 1),
('Creating Awareness', 'Develop skills in pattern recognition - notice themes across multiple conversations', 'practice', 40, 70, 'core', 'beginner', 2),

-- High performance (70-100%)
('Creating Awareness', 'Refine your ability to help clients see their own blind spots with curiosity rather than judgment', 'practice', 70, 100, 'core', 'beginner', 1),
('Creating Awareness', 'Practice timing awareness-creating interventions for maximum impact and receptivity', 'session', 70, 100, 'core', 'beginner', 2),

-- Direct Communication Actions
-- Low performance (0-40%)
('Direct Communication', 'Practice "bottom-lining" - summarizing the core issue in 1-2 sentences when someone is talking in circles', 'practice', 0, 40, 'core', 'beginner', 1),
('Direct Communication', 'Learn to interrupt respectfully: "Can we pause here?" followed by a focusing question', 'study', 0, 40, 'core', 'beginner', 2),

-- Medium performance (40-70%)
('Direct Communication', 'Practice addressing discrepancies directly but with curiosity: "I hear you saying X and I notice Y..."', 'session', 40, 70, 'core', 'beginner', 1),
('Direct Communication', 'Develop comfort with saying difficult things in service of the client''s growth', 'practice', 40, 70, 'core', 'beginner', 2),

-- High performance (70-100%)
('Direct Communication', 'Refine your delivery to be both direct and compassionate - focus on impact and relationship', 'practice', 70, 100, 'core', 'beginner', 1),
('Direct Communication', 'Practice advanced challenging that opens new possibilities rather than creating defensiveness', 'session', 70, 100, 'core', 'beginner', 2),

-- Trust & Safety Actions
-- Low performance (0-40%)
('Trust & Safety', 'Study and practice clear confidentiality boundaries and agreements from the first session', 'study', 0, 40, 'core', 'beginner', 1),
('Trust & Safety', 'Learn to validate emotions explicitly: "Your feelings are welcome here" or "This is your safe space"', 'practice', 0, 40, 'core', 'beginner', 2),

-- Medium performance (40-70%)
('Trust & Safety', 'Practice creating psychological safety through your presence, tone, and non-judgmental responses', 'session', 40, 70, 'core', 'beginner', 1),
('Trust & Safety', 'Develop consistency in your coaching boundaries and approach to build predictable safety', 'practice', 40, 70, 'core', 'beginner', 2),

-- High performance (70-100%)
('Trust & Safety', 'Refine your ability to maintain safety during challenging or confrontational conversations', 'practice', 70, 100, 'core', 'beginner', 1),
('Trust & Safety', 'Practice advanced trust-building through vulnerability modeling and authentic presence', 'session', 70, 100, 'core', 'beginner', 2),

-- Managing Progress Actions
-- Low performance (0-40%)
('Managing Progress', 'Learn to explore obstacles without judgment: "What got in the way?" rather than expressing disappointment', 'study', 0, 40, 'core', 'beginner', 1),
('Managing Progress', 'Practice collaborative problem-solving: "What would support you in moving forward?"', 'practice', 0, 40, 'core', 'beginner', 2),

-- Medium performance (40-70%)
('Managing Progress', 'Develop skills in helping clients create realistic and supported action plans', 'session', 40, 70, 'core', 'beginner', 1),
('Managing Progress', 'Practice balance between accountability and compassion when clients don''t follow through', 'practice', 40, 70, 'core', 'beginner', 2),

-- High performance (70-100%)
('Managing Progress', 'Refine your ability to co-create accountability structures that truly serve the client', 'practice', 70, 100, 'core', 'beginner', 1),
('Managing Progress', 'Practice advanced progress tracking that focuses on internal shifts as well as external actions', 'session', 70, 100, 'core', 'beginner', 2);

-- ====================================================================
-- COMPETENCY PERFORMANCE ANALYSIS
-- ====================================================================

-- Active Listening Analysis
INSERT INTO competency_performance_analysis (competency_area, analysis_text, analysis_type, score_range_min, score_range_max, framework, difficulty_level, sort_order) VALUES
-- Weakness analysis (0-60%)
('Active Listening', 'Your listening skills need development - you may be missing important emotional cues and focusing too much on formulating responses', 'weakness', 0, 60, 'core', 'beginner', 1),
('Active Listening', 'Building stronger active listening will help you create deeper connection and understanding with clients', 'weakness', 0, 60, 'core', 'beginner', 2),

-- Strength analysis (60-100%)
('Active Listening', 'You demonstrate good listening skills and can effectively hear both content and emotions', 'strength', 60, 100, 'core', 'beginner', 1),
('Active Listening', 'Your listening presence creates safety for clients to share vulnerably and explore deeply', 'strength', 60, 100, 'core', 'beginner', 2),

-- Powerful Questions Analysis
-- Weakness analysis (0-60%)
('Powerful Questions', 'Your questioning skills could be stronger - you may be asking too many closed or information-seeking questions', 'weakness', 0, 60, 'core', 'beginner', 1),
('Powerful Questions', 'Developing more powerful questions will help clients discover their own insights rather than relying on your solutions', 'weakness', 0, 60, 'core', 'beginner', 2),

-- Strength analysis (60-100%)
('Powerful Questions', 'You ask thoughtful questions that help clients explore their situation from new perspectives', 'strength', 60, 100, 'core', 'beginner', 1),
('Powerful Questions', 'Your questions effectively guide clients toward self-discovery and deeper understanding', 'strength', 60, 100, 'core', 'beginner', 2),

-- Present Moment Awareness Analysis
-- Weakness analysis (0-60%)
('Present Moment Awareness', 'Your present-moment awareness needs strengthening - you may be missing important cues or getting caught in future planning', 'weakness', 0, 60, 'core', 'beginner', 1),
('Present Moment Awareness', 'Developing better presence will help you notice energy shifts, emotions, and breakthrough moments', 'weakness', 0, 60, 'core', 'beginner', 2),

-- Strength analysis (60-100%)
('Present Moment Awareness', 'You demonstrate good awareness of what''s happening in the moment during coaching conversations', 'strength', 60, 100, 'core', 'beginner', 1),
('Present Moment Awareness', 'Your present-moment awareness helps you notice and work with energy shifts and unspoken dynamics', 'strength', 60, 100, 'core', 'beginner', 2),

-- Creating Awareness Analysis
-- Weakness analysis (0-60%)
('Creating Awareness', 'Your awareness-creating skills need development - you may be missing opportunities to help clients see patterns and blind spots', 'weakness', 0, 60, 'core', 'beginner', 1),
('Creating Awareness', 'Building skills in creating awareness will help clients develop deeper self-understanding and insight', 'weakness', 0, 60, 'core', 'beginner', 2),

-- Strength analysis (60-100%)
('Creating Awareness', 'You effectively help clients notice patterns, contradictions, and insights about themselves', 'strength', 60, 100, 'core', 'beginner', 1),
('Creating Awareness', 'Your awareness-creating interventions help clients develop greater self-understanding and clarity', 'strength', 60, 100, 'core', 'beginner', 2),

-- Direct Communication Analysis
-- Weakness analysis (0-60%)
('Direct Communication', 'Your direct communication skills could be stronger - you may avoid difficult conversations or lack clarity in your delivery', 'weakness', 0, 60, 'core', 'beginner', 1),
('Direct Communication', 'Developing more direct communication will help clients get clear on issues and take meaningful action', 'weakness', 0, 60, 'core', 'beginner', 2),

-- Strength analysis (60-100%)
('Direct Communication', 'You communicate directly and clearly while maintaining rapport and trust with clients', 'strength', 60, 100, 'core', 'beginner', 1),
('Direct Communication', 'Your direct communication helps clients cut through confusion and focus on what matters most', 'strength', 60, 100, 'core', 'beginner', 2),

-- Trust & Safety Analysis
-- Weakness analysis (0-60%)
('Trust & Safety', 'Your trust-building skills need attention - clients may not feel completely safe to be vulnerable or authentic', 'weakness', 0, 60, 'core', 'beginner', 1),
('Trust & Safety', 'Building stronger trust and safety will allow for deeper, more transformational coaching work', 'weakness', 0, 60, 'core', 'beginner', 2),

-- Strength analysis (60-100%)
('Trust & Safety', 'You create a safe and trusting environment where clients feel comfortable sharing authentically', 'strength', 60, 100, 'core', 'beginner', 1),
('Trust & Safety', 'Your approach to trust and safety enables deeper vulnerability and more meaningful coaching conversations', 'strength', 60, 100, 'core', 'beginner', 2),

-- Managing Progress Analysis
-- Weakness analysis (0-60%)
('Managing Progress', 'Your progress management skills could be stronger - you may struggle with accountability or following through on commitments', 'weakness', 0, 60, 'core', 'beginner', 1),
('Managing Progress', 'Developing better progress management will help clients maintain momentum and achieve their goals', 'weakness', 0, 60, 'core', 'beginner', 2),

-- Strength analysis (60-100%)
('Managing Progress', 'You effectively support client accountability and progress without being controlling or judgmental', 'strength', 60, 100, 'core', 'beginner', 1),
('Managing Progress', 'Your approach to managing progress helps clients stay motivated and focused on their development', 'strength', 60, 100, 'core', 'beginner', 2);

-- ====================================================================
-- COMPETENCY LEVERAGE STRENGTHS
-- ====================================================================

-- Active Listening Leverage
INSERT INTO competency_leverage_strengths (competency_area, leverage_text, score_range_min, score_range_max, framework, difficulty_level, sort_order) VALUES
-- Good performance (60-80%)
('Active Listening', 'Use your listening strengths to help clients feel truly heard and understood in every conversation', 60, 80, 'core', 'beginner', 1),
('Active Listening', 'Leverage your listening abilities to model deep presence and create space for client vulnerability', 60, 80, 'core', 'beginner', 2),

-- Excellence (80-100%)
('Active Listening', 'Your exceptional listening skills make you a natural coach - consider mentoring others in this fundamental ability', 80, 100, 'core', 'beginner', 1),
('Active Listening', 'Use your listening mastery as a foundation to develop more advanced coaching competencies', 80, 100, 'core', 'beginner', 2),

-- Similar patterns for other competencies...
('Powerful Questions', 'Leverage your questioning skills to consistently guide clients toward self-discovery and insight', 60, 80, 'core', 'beginner', 1),
('Powerful Questions', 'Use your strong questioning ability to help clients connect with their values and deeper motivations', 60, 80, 'core', 'beginner', 2),
('Powerful Questions', 'Your mastery of powerful questions positions you as an expert in helping others discover their own wisdom', 80, 100, 'core', 'beginner', 1),
('Powerful Questions', 'Model excellent questioning for other coaches and consider specializing in question-based coaching approaches', 80, 100, 'core', 'beginner', 2),

('Present Moment Awareness', 'Use your present-moment strengths to help clients stay grounded and connected during coaching', 60, 80, 'core', 'beginner', 1),
('Present Moment Awareness', 'Leverage your awareness to notice and work with subtle energy shifts and unspoken dynamics', 60, 80, 'core', 'beginner', 2),
('Present Moment Awareness', 'Your exceptional presence creates transformational coaching moments - this is a rare and valuable gift', 80, 100, 'core', 'beginner', 1),
('Present Moment Awareness', 'Consider developing somatic or mindfulness-based coaching approaches that leverage your natural awareness', 80, 100, 'core', 'beginner', 2);

-- ====================================================================
-- SUMMARY
-- ====================================================================
SELECT 
    'Competency Data Created' as status,
    (SELECT COUNT(*) FROM competency_strategic_actions WHERE framework = 'core' AND difficulty_level = 'beginner') as strategic_actions,
    (SELECT COUNT(*) FROM competency_performance_analysis WHERE framework = 'core' AND difficulty_level = 'beginner') as performance_analyses,
    (SELECT COUNT(*) FROM competency_leverage_strengths WHERE framework = 'core' AND difficulty_level = 'beginner') as leverage_strengths;