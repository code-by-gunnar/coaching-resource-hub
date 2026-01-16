-- ====================================================================
-- COMPLETE PRODUCTION DEPLOYMENT SCRIPT - TABLES FIRST
-- Core I Beginner Assessment System - January 2025
-- ====================================================================
-- Purpose: Deploy the complete Core I assessment system to production
-- Creates all tables FIRST, then adds data and constraints
-- Version: 2.2 - Table creation prioritized
-- ====================================================================

-- ====================================================================
-- STEP 1: CREATE ALL CORE TABLES FIRST
-- ====================================================================

-- Create assessments table if it doesn't exist
CREATE TABLE IF NOT EXISTS assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    description TEXT,
    difficulty TEXT CHECK (difficulty IN ('Beginner', 'Intermediate', 'Advanced')),
    estimated_duration INTEGER, -- minutes
    framework TEXT NOT NULL CHECK (framework IN ('core', 'icf', 'ac')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create assessment_questions table if it doesn't exist
CREATE TABLE IF NOT EXISTS assessment_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_id UUID NOT NULL REFERENCES assessments(id) ON DELETE CASCADE,
    question_order INTEGER NOT NULL,
    question TEXT NOT NULL,
    option_a TEXT NOT NULL,
    option_b TEXT NOT NULL, 
    option_c TEXT NOT NULL,
    option_d TEXT NOT NULL,
    correct_answer INTEGER NOT NULL CHECK (correct_answer IN (0, 1, 2, 3)),
    explanation TEXT NOT NULL,
    competency_area TEXT NOT NULL,
    difficulty_weight DECIMAL DEFAULT 1.0,
    assessment_level TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create skill_tags table if it doesn't exist
CREATE TABLE IF NOT EXISTS skill_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    competency_area TEXT NOT NULL,
    framework TEXT NOT NULL CHECK (framework IN ('core', 'icf', 'ac')),
    sort_order INTEGER DEFAULT 0,
    assessment_level TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(name, competency_area, framework, assessment_level)
);

-- Create tag_insights table if it doesn't exist
CREATE TABLE IF NOT EXISTS tag_insights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    skill_tag_id UUID NOT NULL REFERENCES skill_tags(id) ON DELETE CASCADE,
    insight_text TEXT NOT NULL,
    insight_type TEXT NOT NULL CHECK (insight_type IN ('weakness', 'strength')),
    context_level TEXT DEFAULT 'beginner',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(skill_tag_id, insight_type, context_level)
);

-- Create tag_actions table if it doesn't exist
CREATE TABLE IF NOT EXISTS tag_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    skill_tag_id UUID NOT NULL REFERENCES skill_tags(id) ON DELETE CASCADE,
    action_text TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(skill_tag_id)
);

-- Create competency_display_names table if it doesn't exist
CREATE TABLE IF NOT EXISTS competency_display_names (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    competency_key TEXT NOT NULL,
    display_name TEXT NOT NULL,
    framework TEXT NOT NULL CHECK (framework IN ('core', 'icf', 'ac')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(competency_key, framework)
);

-- Create competency_leverage_strengths table if it doesn't exist
CREATE TABLE IF NOT EXISTS competency_leverage_strengths (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    competency_area TEXT NOT NULL,
    leverage_text TEXT NOT NULL,
    score_range_min INTEGER DEFAULT 0,
    score_range_max INTEGER DEFAULT 100,
    framework TEXT NOT NULL CHECK (framework IN ('core', 'icf', 'ac')),
    context_level TEXT DEFAULT 'beginner',
    priority_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create learning_path_categories table if it doesn't exist
CREATE TABLE IF NOT EXISTS learning_path_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_title TEXT NOT NULL,
    category_description TEXT,
    category_icon TEXT,
    competency_areas TEXT[],
    assessment_level TEXT,
    priority_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create learning_resources table if it doesn't exist
CREATE TABLE IF NOT EXISTS learning_resources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES learning_path_categories(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    resource_type TEXT NOT NULL CHECK (resource_type IN ('book', 'course', 'video', 'article', 'exercise', 'workshop', 'tool', 'assessment')),
    url TEXT,
    author_instructor TEXT,
    competency_areas TEXT[],
    assessment_level TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user_attempts table if it doesn't exist (needed for assessment system)
CREATE TABLE IF NOT EXISTS user_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL, -- References auth.users(id) but we can't enforce FK to auth schema
    assessment_id UUID NOT NULL REFERENCES assessments(id) ON DELETE CASCADE,
    score INTEGER NOT NULL CHECK (score >= 0 AND score <= 100),
    time_spent INTEGER, -- seconds
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    frontend_insights JSONB,
    insights_generated_at TIMESTAMP WITH TIME ZONE
);

-- Create user_responses table if it doesn't exist  
CREATE TABLE IF NOT EXISTS user_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attempt_id UUID NOT NULL REFERENCES user_attempts(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES assessment_questions(id) ON DELETE CASCADE,
    selected_answer INTEGER NOT NULL CHECK (selected_answer IN (0, 1, 2, 3)),
    is_correct BOOLEAN NOT NULL,
    response_time INTEGER, -- seconds
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ====================================================================
-- STEP 2: ADD ASSESSMENT LEVEL COLUMNS TO EXISTING TABLES
-- ====================================================================

-- Add assessment_level columns to support multi-level assessment system
ALTER TABLE assessment_questions 
ADD COLUMN IF NOT EXISTS assessment_level text;

ALTER TABLE skill_tags
ADD COLUMN IF NOT EXISTS assessment_level text;

ALTER TABLE learning_path_categories
ADD COLUMN IF NOT EXISTS assessment_level text;

ALTER TABLE learning_resources
ADD COLUMN IF NOT EXISTS assessment_level text;

-- ====================================================================
-- STEP 3: ADD CONSTRAINTS SAFELY
-- ====================================================================

-- Add constraints to ensure valid assessment levels (PostgreSQL safe syntax)
DO $$ 
BEGIN
    -- Add assessment_questions constraint if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'assessment_questions_level_check') THEN
        ALTER TABLE assessment_questions 
        ADD CONSTRAINT assessment_questions_level_check 
        CHECK (assessment_level IN ('core-i', 'core-ii', 'core-iii', 'icf-i', 'icf-ii', 'icf-iii', 'ac-i', 'ac-ii', 'ac-iii'));
    END IF;

    -- Add skill_tags constraint if it doesn't exist  
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'skill_tags_level_check') THEN
        ALTER TABLE skill_tags
        ADD CONSTRAINT skill_tags_level_check 
        CHECK (assessment_level IN ('core-i', 'core-ii', 'core-iii', 'icf-i', 'icf-ii', 'icf-iii', 'ac-i', 'ac-ii', 'ac-iii'));
    END IF;
END $$;

-- ====================================================================
-- STEP 4: CREATE CORE ASSESSMENTS
-- ====================================================================

INSERT INTO assessments (id, slug, title, description, difficulty, estimated_duration, framework, is_active) VALUES
('00000000-0000-0000-0000-000000000001', 'core-fundamentals-i', 'CORE I - Fundamentals', 'Essential coaching fundamentals: Active Listening, Powerful Questions, and Present Moment Awareness', 'Beginner', 20, 'core', true)
ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  difficulty = EXCLUDED.difficulty,
  estimated_duration = EXCLUDED.estimated_duration,
  framework = EXCLUDED.framework,
  is_active = EXCLUDED.is_active;

-- ====================================================================
-- STEP 5: CREATE CORE I ASSESSMENT QUESTIONS (15 TOTAL)
-- ====================================================================

-- Clear existing questions to prevent duplicates
DELETE FROM assessment_questions WHERE assessment_id = '00000000-0000-0000-0000-000000000001';

-- Active Listening Questions (6 questions - 40% of assessment)
INSERT INTO assessment_questions (id, assessment_id, question_order, question, option_a, option_b, option_c, option_d, correct_answer, explanation, competency_area, difficulty_weight, assessment_level) VALUES
(gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 1, 
'What level of listening would be MOST appropriate to use in coaching when the client is sharing their deepest concerns about a career transition?',
'Level 1 - Focused on your own thoughts and responses',
'Level 2 - Focused entirely on the client''s words and emotions', 
'Level 3 - Focused on what others think about the situation',
'Level 0 - Not actively listening at all',
1, 'Level 2 listening shows complete focus on the client''s experience, which is essential for deep coaching conversations.', 'Active Listening', 1.0, 'core-i'),

(gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 2,
'Which response best demonstrates active listening through reflective acknowledgment?',
'I understand exactly how you feel because I went through the same thing.',
'What I''m hearing is that you''re feeling overwhelmed by the number of decisions you need to make.',
'You shouldn''t worry about that - it will work out fine.',
'Have you considered trying a different approach to this problem?',
1, 'This response reflects back what the client shared without inserting the coach''s own experience or advice.', 'Active Listening', 1.0, 'core-i'),

(gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 3,
'As a coach practicing active listening, what is the BEST response when you notice your mind wandering during a client session?',
'Continue the conversation as if nothing happened.',
'Gently bring your attention back to the client without judgment.',
'Ask the client to repeat what they just said.',
'Take notes to help you stay focused.',
1, 'Mindfully returning attention to the client without self-judgment maintains the coaching presence needed for effective listening.', 'Active Listening', 1.0, 'core-i'),

(gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 13,
'What''s the most appropriate response to build trust through active listening when a client shares something vulnerable?',
'That''s interesting - tell me more about that decision.',
'I can see why that would be difficult for you.',
'Thank you for trusting me with that. What feels most important about this for you right now?',
'You should be proud of yourself for sharing that with me.',
2, 'This response acknowledges the vulnerability, expresses gratitude for trust, and continues exploring what matters most to the client.', 'Active Listening', 1.0, 'core-i'),

(gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 14,
'How do you respond to maintain psychological safety while practicing active listening?',
'I hear that you''re questioning whether you made the right choice, and I''m curious what feels most important to explore about that.',
'Based on what you''re telling me, here''s what I think you should do...',
'That sounds like a really challenging situation that many people struggle with.',
'Let''s focus on finding a solution rather than dwelling on the problem.',
0, 'This response demonstrates non-judgmental listening while maintaining curiosity and psychological safety for continued exploration.', 'Active Listening', 1.0, 'core-i'),

(gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 15,
'What''s the most effective coaching approach when practicing active listening with a client who seems hesitant to share details?',
'Let''s move on to a different topic that might be easier to discuss.',
'I can sense there might be more to this story. What feels safe to share right now?',
'It''s okay if you don''t want to talk about this - we all have things we prefer to keep private.',
'Sometimes it helps to talk through these difficult situations, even when it''s uncomfortable.',
1, 'This response acknowledges what the coach is sensing while giving the client complete choice and control over what they share.', 'Active Listening', 1.0, 'core-i');

-- Powerful Questions (5 questions - 33% of assessment)  
INSERT INTO assessment_questions (id, assessment_id, question_order, question, option_a, option_b, option_c, option_d, correct_answer, explanation, competency_area, difficulty_weight, assessment_level) VALUES
(gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 4,
'Which question would be MOST powerful in creating new awareness for a client who says "I always mess things up"?',
'What specifically happened that makes you feel this way?',
'Why do you think you have this pattern of messing things up?',
'How long have you been telling yourself this story?',
'What would someone who believes in you say about your capabilities?',
0, 'This question helps the client get specific rather than staying in generalized negative self-talk.', 'Powerful Questions', 1.0, 'core-i'),

(gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 5,
'Which follow-up question would best help the client gain clarity about their values?',
'What do you think is the right decision in this situation?',
'What matters most to you about how this situation unfolds?',
'What would your family and friends advise you to do?',
'What are the pros and cons of each option you''re considering?',
1, 'This question directly connects the client to their core values and what''s truly important to them.', 'Powerful Questions', 1.0, 'core-i'),

(gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 6,
'When a client feels stuck between two choices, which question would best help them connect with their inner wisdom?',
'Which option do you think would make your parents prouder?',
'What does your gut instinct tell you about each possibility?',
'If you close your eyes and imagine each choice, which one feels more aligned with who you''re becoming?',
'Which choice would be easier to explain to others?',
2, 'This question engages both intuition and future identity, helping clients access deeper wisdom beyond logical analysis.', 'Powerful Questions', 1.0, 'core-i'),

(gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 11,
'How do you use direct communication through powerful questioning to help them find their own answers?',
'What would need to be true for you to feel completely confident in your decision?',
'Here''s what I think you should do based on what you''ve shared...',
'Most people in your situation would probably choose the safer option.',
'You seem to already know what you want to do - why haven''t you done it yet?',
0, 'This question helps the client identify the specific conditions or certainty they need, empowering them to find their own solution.', 'Powerful Questions', 1.0, 'core-i'),

(gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 12,
'How do you address limiting beliefs directly while maintaining support through your questioning?',
'What would you tell a dear friend who was facing this exact same situation?',
'You need to stop thinking so negatively about yourself and your abilities.',
'Why do you always assume the worst-case scenario will happen?',
'What would become possible if that limiting belief wasn''t actually true?',
3, 'This question directly challenges the limiting belief while opening up new possibilities and perspectives for the client.', 'Powerful Questions', 1.0, 'core-i');

-- Present Moment Awareness Questions (4 questions - 27% of assessment)
INSERT INTO assessment_questions (id, assessment_id, question_order, question, option_a, option_b, option_c, option_d, correct_answer, explanation, competency_area, difficulty_weight, assessment_level) VALUES
(gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 7,
'You notice your client''s energy has shifted - they seem more withdrawn than when the session began. How should you use this present-moment observation?',
'Continue with your planned coaching agenda without mentioning it.',
'Ask directly: "Why did your energy just change?"',
'Share what you''re noticing: "I''m sensing a shift in your energy right now. What''s happening for you?"',
'Wait until the end of the session to bring up your observation.',
2, 'Sharing present-moment observations in real-time can create breakthrough moments and deepen self-awareness.', 'Present Moment Awareness', 1.0, 'core-i'),

(gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 8,
'A client pauses mid-sentence and seems to be processing something internally. What is the MOST appropriate coaching response?',
'Ask them what they''re thinking about to keep the conversation moving.',
'Hold the silence and give them space to process whatever is emerging.',
'Offer your own thoughts about what they might be experiencing.',
'Summarize what they''ve shared so far to help them organize their thoughts.',
1, 'Comfortable silence allows clients space for internal processing and often leads to deeper insights.', 'Present Moment Awareness', 1.0, 'core-i'),

(gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 9,
'How would you best help create awareness about their emotional state when you sense unexpressed feelings?',
'Tell them directly what emotion you think they''re experiencing.',
'Ask: "How are you feeling right now in your body?"',
'I''m noticing some tension or hesitation as you talk about this. What are you aware of?',
'Focus on the content of what they''re saying rather than their emotional state.',
2, 'This question gently directs attention to present-moment awareness while giving them complete autonomy to discover and name their own experience.', 'Present Moment Awareness', 1.0, 'core-i'),

(gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 10,
'What''s the best approach to create awareness of their unconscious patterns when you notice them repeating a behavior?',
'Point out the pattern directly: "You keep doing this same thing."',
'Ask: "What do you notice about how you typically handle situations like this?"',
'Ignore the pattern since they''ll figure it out eventually.',
'What pattern are you noticing in how you approach these types of challenges?',
3, 'This question invites self-discovery of patterns without judgment, allowing the client to gain awareness at their own pace.', 'Present Moment Awareness', 1.0, 'core-i');

-- Update all questions to Core I level
UPDATE assessment_questions 
SET assessment_level = 'core-i' 
WHERE assessment_id = '00000000-0000-0000-0000-000000000001';

-- ====================================================================
-- STEP 6: CREATE SKILL TAGS FOR CORE I COMPETENCIES
-- ====================================================================

-- Clear existing Core I skill tags to prevent duplicates
DELETE FROM skill_tags WHERE framework = 'core' AND assessment_level = 'core-i';

-- Core I focuses on 3 foundational competencies: Active Listening, Powerful Questions, Present Moment Awareness
INSERT INTO skill_tags (id, name, competency_area, framework, sort_order, assessment_level, is_active) VALUES
-- Active Listening Skills (6 skills)
(gen_random_uuid(), 'Reflective Listening', 'Active Listening', 'core', 1, 'core-i', true),
(gen_random_uuid(), 'Non-Judgmental Listening', 'Active Listening', 'core', 2, 'core-i', true),
(gen_random_uuid(), 'Paraphrasing', 'Active Listening', 'core', 3, 'core-i', true),
(gen_random_uuid(), 'Emotional Mirroring', 'Active Listening', 'core', 4, 'core-i', true),
(gen_random_uuid(), 'Staying Present', 'Active Listening', 'core', 5, 'core-i', true),
(gen_random_uuid(), 'Deep Listening', 'Active Listening', 'core', 6, 'core-i', true),

-- Powerful Questions Skills (6 skills)
(gen_random_uuid(), 'Open-Ended Questions', 'Powerful Questions', 'core', 1, 'core-i', true),
(gen_random_uuid(), 'Clarifying Questions', 'Powerful Questions', 'core', 2, 'core-i', true),
(gen_random_uuid(), 'Future-Focused Questions', 'Powerful Questions', 'core', 3, 'core-i', true),
(gen_random_uuid(), 'Values-Based Questions', 'Powerful Questions', 'core', 4, 'core-i', true),
(gen_random_uuid(), 'Perspective Shift Questions', 'Powerful Questions', 'core', 5, 'core-i', true),
(gen_random_uuid(), 'Possibility Questions', 'Powerful Questions', 'core', 6, 'core-i', true),

-- Present Moment Awareness Skills (5 skills)  
(gen_random_uuid(), 'Emotional Awareness', 'Present Moment Awareness', 'core', 1, 'core-i', true),
(gen_random_uuid(), 'Energy Reading', 'Present Moment Awareness', 'core', 2, 'core-i', true),
(gen_random_uuid(), 'Intuitive Observations', 'Present Moment Awareness', 'core', 3, 'core-i', true),
(gen_random_uuid(), 'Silence Comfort', 'Present Moment Awareness', 'core', 4, 'core-i', true),
(gen_random_uuid(), 'Present Moment Coaching', 'Present Moment Awareness', 'core', 5, 'core-i', true);

-- ====================================================================
-- STEP 7: CREATE COMPETENCY DISPLAY NAMES
-- ====================================================================

INSERT INTO competency_display_names (competency_key, display_name, framework, is_active) VALUES
('active_listening', 'Active Listening', 'core', true),
('powerful_questions', 'Powerful Questions', 'core', true), 
('present_moment_awareness', 'Present Moment Awareness', 'core', true)
ON CONFLICT (competency_key, framework) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  is_active = EXCLUDED.is_active;

-- ====================================================================
-- STEP 8: CREATE COMPETENCY LEVERAGE STRENGTHS
-- ====================================================================

INSERT INTO competency_leverage_strengths (competency_area, leverage_text, score_range_min, score_range_max, framework, context_level, priority_order) VALUES
('Active Listening', 'Use your strong listening skills to help clients feel deeply heard and understood. Your ability to reflect back what clients share creates safety for them to explore deeper truths about their situation.', 70, 100, 'core', 'beginner', 1),
('Powerful Questions', 'Leverage your questioning skills to help clients discover insights they already possess. Your questions create space for clients to connect with their own wisdom rather than seeking answers from others.', 70, 100, 'core', 'beginner', 1),
('Present Moment Awareness', 'Use your awareness of present-moment dynamics to help clients notice what they might be missing about their situation. Your observations can illuminate blind spots and create breakthrough moments.', 70, 100, 'core', 'beginner', 1);

-- ====================================================================
-- STEP 9: CREATE LEARNING PATH CATEGORIES (COMPETENCY-FOCUSED)
-- ====================================================================

-- Clear existing learning categories to prevent duplicates
DELETE FROM learning_path_categories WHERE assessment_level = 'core-i';

INSERT INTO learning_path_categories (id, category_title, category_description, category_icon, competency_areas, assessment_level, priority_order, is_active) VALUES
(gen_random_uuid(), 'Communication & Questioning', 'Master active listening and powerful questioning techniques for deeper client connections', '🗣️', ARRAY['Active Listening', 'Powerful Questions'], 'core-i', 1, true),
(gen_random_uuid(), 'Presence & Awareness', 'Develop mindful presence and awareness skills to create breakthrough coaching moments', '🧘', ARRAY['Present Moment Awareness'], 'core-i', 2, true);

-- ====================================================================
-- STEP 10: CREATE LEARNING RESOURCES (DIVERSE TYPES FOR EACH CATEGORY)
-- ====================================================================

-- Communication & Questioning Resources (4 resources)
INSERT INTO learning_resources (id, category_id, title, description, resource_type, url, author_instructor, competency_areas, assessment_level, is_active) VALUES
(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = 'Communication & Questioning' AND assessment_level = 'core-i'), 
 'Co-Active Coaching (Fourth Edition)', 
 'Foundational coaching model covering communication patterns, listening levels, and question crafting for deeper client engagement',
 'book', 'https://www.amazon.com/Co-Active-Coaching-Fourth-Changing-Business/dp/1473674840',
 'Laura Whitworth, Karen Kimsey-House, Henry Kimsey-House, Phillip Sandahl',
 ARRAY['Active Listening', 'Powerful Questions'], 'core-i', true),

(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = 'Communication & Questioning' AND assessment_level = 'core-i'), 
 'The Art of Powerful Questions', 
 'Comprehensive guide to creating questions that generate insight, awareness, and breakthrough moments in coaching conversations',
 'article', 'https://theart.ofpowerfulquestions.com',
 'Eric Vogt, Juanita Brown, David Isaacs',
 ARRAY['Powerful Questions'], 'core-i', true),

(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = 'Communication & Questioning' AND assessment_level = 'core-i'), 
 'Active Listening Masterclass', 
 'Professional development course focusing on Level 2 and Level 3 listening skills for coaching effectiveness',
 'course', 'https://example.com/listening-course',
 'International Coach Academy',
 ARRAY['Active Listening'], 'core-i', true),

(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = 'Communication & Questioning' AND assessment_level = 'core-i'), 
 'Daily Listening Practice Exercise', 
 'Structured daily practice routine for developing deeper listening presence and attention in coaching sessions',
 'exercise', 'https://example.com/listening-practice',
 'Coach Training Institute',
 ARRAY['Active Listening'], 'core-i', true);

-- Presence & Awareness Resources (3 resources)
INSERT INTO learning_resources (id, category_id, title, description, resource_type, url, author_instructor, competency_areas, assessment_level, is_active) VALUES
(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = 'Presence & Awareness' AND assessment_level = 'core-i'), 
 'The Power of Now', 
 'Present moment awareness fundamentals for cultivating coaching presence and mindful attention',
 'book', 'https://www.amazon.com/Power-Now-Guide-Spiritual-Enlightenment/dp/1577314808',
 'Eckhart Tolle',
 ARRAY['Present Moment Awareness'], 'core-i', true),

(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = 'Presence & Awareness' AND assessment_level = 'core-i'), 
 'Presence Practice for Coaches', 
 'Video series on developing authentic presence and awareness skills specifically for coaching professionals',
 'video', 'https://example.com/presence-videos',
 'Mindful Schools',
 ARRAY['Present Moment Awareness'], 'core-i', true),

(gen_random_uuid(), 
 (SELECT id FROM learning_path_categories WHERE category_title = 'Presence & Awareness' AND assessment_level = 'core-i'), 
 'Awareness Creation Workshop', 
 'Interactive workshop on facilitating client self-discovery and awareness creation through skillful coaching techniques',
 'workshop', 'https://example.com/awareness-workshop',
 'International Coach Academy',
 ARRAY['Present Moment Awareness'], 'core-i', true);

-- ====================================================================
-- STEP 11: CREATE LEARNING PATHS FUNCTION
-- ====================================================================

CREATE OR REPLACE FUNCTION get_learning_paths_for_assessment(
    weak_competency_areas text[],
    overall_score integer
)
RETURNS TABLE (
    category_id uuid,
    category_title text,
    category_description text,
    category_icon text,
    resources json[]
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        lpc.id as category_id,
        lpc.category_title,
        lpc.category_description,
        lpc.category_icon,
        ARRAY(
            SELECT json_build_object(
                'title', lr.title,
                'description', lr.description,
                'resource_type', lr.resource_type,
                'url', lr.url,
                'author', lr.author_instructor,
                'competency_areas', lr.competency_areas
            )
            FROM learning_resources lr
            WHERE lr.category_id = lpc.id
            AND lr.is_active = true
            ORDER BY lr.resource_type, lr.title
        ) as resources
    FROM learning_path_categories lpc
    WHERE lpc.is_active = true
    AND lpc.assessment_level = 'core-i'
    -- Only show categories where competency areas overlap with weak areas
    AND lpc.competency_areas && weak_competency_areas
    ORDER BY lpc.priority_order, lpc.category_title;
END;
$$;

-- ====================================================================
-- STEP 12: CREATE STORE_FRONTEND_INSIGHTS FUNCTION
-- ====================================================================

-- Drop existing function first to handle return type changes
DROP FUNCTION IF EXISTS store_frontend_insights(uuid, jsonb);

CREATE OR REPLACE FUNCTION store_frontend_insights(
    attempt_uuid UUID,
    frontend_insights JSONB
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE user_attempts 
    SET 
        frontend_insights = frontend_insights,
        insights_generated_at = NOW()
    WHERE id = attempt_uuid;
    
    RETURN FOUND;
END;
$$;

-- ====================================================================
-- STEP 13: VERIFICATION QUERIES
-- ====================================================================

-- Verify the complete Core I assessment architecture
SELECT 'PRODUCTION DEPLOYMENT VERIFICATION' as status;

SELECT '';
SELECT 'TABLES CREATED:' as section;
SELECT table_name, table_type 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('assessments', 'assessment_questions', 'skill_tags', 'tag_insights', 'tag_actions', 'competency_display_names', 'learning_path_categories', 'learning_resources', 'user_attempts', 'user_responses')
ORDER BY table_name;

SELECT '';
SELECT 'ASSESSMENT QUESTIONS:' as section;
SELECT competency_area, COUNT(*) as questions, assessment_level
FROM assessment_questions 
WHERE assessment_id = '00000000-0000-0000-0000-000000000001'
GROUP BY competency_area, assessment_level
ORDER BY competency_area;

SELECT '';
SELECT 'SKILL TAGS:' as section;
SELECT competency_area, COUNT(*) as skills, assessment_level, 
       COUNT(*) FILTER (WHERE is_active = true) as active_skills
FROM skill_tags 
WHERE framework = 'core' AND assessment_level = 'core-i'
GROUP BY competency_area, assessment_level
ORDER BY competency_area;

SELECT '';
SELECT 'LEARNING RESOURCES:' as section;
SELECT lpc.category_title, COUNT(lr.id) as resources, lpc.assessment_level
FROM learning_path_categories lpc
LEFT JOIN learning_resources lr ON lpc.id = lr.category_id AND lr.is_active = true
WHERE lpc.assessment_level = 'core-i'
GROUP BY lpc.category_title, lpc.assessment_level
ORDER BY lpc.category_title;

SELECT '';
SELECT 'DEPLOYMENT COMPLETE - Core I Assessment System Ready' as final_status;