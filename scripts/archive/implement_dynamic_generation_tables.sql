-- ====================================================================
-- IMPLEMENT DYNAMIC GENERATION TABLES
-- ====================================================================
-- Creates the database tables needed for truly dynamic generation
-- No hardcoded content - composables will query these tables
-- ====================================================================

-- Create competency_strategic_actions table
-- For competency-level strategic actions (different from tag-level actions)
CREATE TABLE IF NOT EXISTS competency_strategic_actions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    competency_area text NOT NULL,
    action_text text NOT NULL,
    action_type text CHECK (action_type IN ('immediate', 'session', 'practice', 'reflection', 'study')) NOT NULL,
    score_range_min integer NOT NULL, -- e.g., 0 for 0-30% range
    score_range_max integer NOT NULL, -- e.g., 30 for 0-30% range
    framework text CHECK (framework IN ('core', 'icf', 'ac')) NOT NULL,
    difficulty_level text CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')) NOT NULL,
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now()
);

-- Create competency_performance_analysis table
-- For competency-level performance insights
CREATE TABLE IF NOT EXISTS competency_performance_analysis (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    competency_area text NOT NULL,
    analysis_text text NOT NULL,
    analysis_type text CHECK (analysis_type IN ('weakness', 'strength', 'general')) NOT NULL,
    score_range_min integer NOT NULL,
    score_range_max integer NOT NULL,
    framework text CHECK (framework IN ('core', 'icf', 'ac')) NOT NULL,
    difficulty_level text CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')) NOT NULL,
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now()
);

-- Create competency_leverage_strengths table
-- For strength leverage actions
CREATE TABLE IF NOT EXISTS competency_leverage_strengths (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    competency_area text NOT NULL,
    leverage_text text NOT NULL,
    score_range_min integer NOT NULL,
    score_range_max integer NOT NULL,
    framework text CHECK (framework IN ('core', 'icf', 'ac')) NOT NULL,
    difficulty_level text CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')) NOT NULL,
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now()
);

-- ====================================================================
-- POPULATE WITH TESTING123 DATA FOR VALIDATION
-- ====================================================================

-- Strategic Actions for Testing123 competency areas
INSERT INTO competency_strategic_actions (competency_area, action_text, action_type, score_range_min, score_range_max, framework, difficulty_level, sort_order) VALUES

-- Testing123 Language Awareness - Low performance (0-40%)
('Testing123 Language Awareness', 'Focus on foundational language pattern recognition - practice identifying client deletions, distortions, and generalizations daily', 'practice', 0, 40, 'core', 'beginner', 1),
('Testing123 Language Awareness', 'Seek feedback from an experienced coach on your language awareness skills during practice sessions', 'session', 0, 40, 'core', 'beginner', 2),
('Testing123 Language Awareness', 'Study Meta Model techniques for 15 minutes daily to build precision questioning skills', 'study', 0, 40, 'core', 'beginner', 3),
('Testing123 Language Awareness', 'Immediately pause and ask clarifying questions when you hear vague client language', 'immediate', 0, 40, 'core', 'beginner', 4),

-- Testing123 Language Awareness - Medium performance (40-70%)
('Testing123 Language Awareness', 'Practice identifying and challenging specific language patterns with clients this week', 'practice', 40, 70, 'core', 'beginner', 1),
('Testing123 Language Awareness', 'Record a coaching session and review for missed language pattern opportunities', 'reflection', 40, 70, 'core', 'beginner', 2),
('Testing123 Language Awareness', 'Apply precision questioning techniques in your next 3 coaching sessions consistently', 'session', 40, 70, 'core', 'beginner', 3),

-- Testing123 Language Awareness - High performance (70-100%)
('Testing123 Language Awareness', 'Refine advanced language awareness techniques for greater client impact', 'practice', 70, 100, 'core', 'beginner', 1),
('Testing123 Language Awareness', 'Expand application of language skills to more challenging client situations', 'session', 70, 100, 'core', 'beginner', 2),

-- Testing123 Strength Area - Low performance (0-40%)
('Testing123 Strength Area', 'Focus on foundational skills in this core competency area with daily practice', 'practice', 0, 40, 'core', 'beginner', 1),
('Testing123 Strength Area', 'Work with a mentor to develop confidence and consistency in this competency', 'session', 0, 40, 'core', 'beginner', 2),
('Testing123 Strength Area', 'Study core techniques and principles related to this competency area', 'study', 0, 40, 'core', 'beginner', 3),

-- Testing123 Strength Area - Medium performance (40-70%)
('Testing123 Strength Area', 'Build consistency by applying these skills reliably in every coaching session', 'practice', 40, 70, 'core', 'beginner', 1),
('Testing123 Strength Area', 'Reflect on your application of this competency after each coaching session', 'reflection', 40, 70, 'core', 'beginner', 2),

-- Testing123 Strength Area - High performance (70-100%)
('Testing123 Strength Area', 'Fine-tune your expertise in this competency for maximum client benefit', 'practice', 70, 100, 'core', 'beginner', 1),
('Testing123 Strength Area', 'Look for new ways to apply this competency in diverse coaching situations', 'session', 70, 100, 'core', 'beginner', 2);

-- Performance Analysis for Testing123 competency areas
INSERT INTO competency_performance_analysis (competency_area, analysis_text, analysis_type, score_range_min, score_range_max, framework, difficulty_level, sort_order) VALUES

-- Testing123 Language Awareness - Weakness analysis (0-60%)
('Testing123 Language Awareness', 'Your language pattern recognition skills need development - you may be missing opportunities to notice client limiting beliefs and distortions', 'weakness', 0, 60, 'core', 'beginner', 1),
('Testing123 Language Awareness', 'Building precision in language awareness will significantly enhance your ability to help clients gain clarity and insight', 'weakness', 0, 60, 'core', 'beginner', 2),
('Testing123 Language Awareness', 'Focus on developing your ability to identify and work with client language patterns to promote deeper awareness', 'weakness', 0, 60, 'core', 'beginner', 3),

-- Testing123 Language Awareness - Strength analysis (60-100%)
('Testing123 Language Awareness', 'You demonstrate good awareness of language patterns and can effectively identify client communication nuances', 'strength', 60, 100, 'core', 'beginner', 1),
('Testing123 Language Awareness', 'Your language precision skills support client clarity and contribute to meaningful insight development', 'strength', 60, 100, 'core', 'beginner', 2),
('Testing123 Language Awareness', 'You effectively work with client language to promote awareness and facilitate breakthrough moments', 'strength', 60, 100, 'core', 'beginner', 3),

-- Testing123 Strength Area - Weakness analysis (0-60%)
('Testing123 Strength Area', 'This competency area requires additional attention and focused development to build your coaching effectiveness', 'weakness', 0, 60, 'core', 'beginner', 1),
('Testing123 Strength Area', 'Building confidence and consistency in this foundational coaching competency will enhance your overall practice', 'weakness', 0, 60, 'core', 'beginner', 2),
('Testing123 Strength Area', 'Focus on strengthening the core skills within this competency to improve your coaching impact', 'weakness', 0, 60, 'core', 'beginner', 3),

-- Testing123 Strength Area - Strength analysis (60-100%)
('Testing123 Strength Area', 'You show excellent mastery and natural ability in this competency - this is a significant coaching strength', 'strength', 60, 100, 'core', 'beginner', 1),
('Testing123 Strength Area', 'Your skills in this area provide a solid foundation for your coaching practice and client impact', 'strength', 60, 100, 'core', 'beginner', 2),
('Testing123 Strength Area', 'Continue building on this competency strength and consider how it can support development in other areas', 'strength', 60, 100, 'core', 'beginner', 3);

-- Leverage Strengths for Testing123 competency areas
INSERT INTO competency_leverage_strengths (competency_area, leverage_text, score_range_min, score_range_max, framework, difficulty_level, sort_order) VALUES

-- Testing123 Language Awareness - Strength leverage (60-80%)
('Testing123 Language Awareness', 'Use your language awareness skills to help clients identify their own limiting language patterns and beliefs', 'score', 60, 80, 'core', 'beginner', 1),
('Testing123 Language Awareness', 'Apply your precision questioning consistently to support client breakthrough and awareness moments', 'score', 60, 80, 'core', 'beginner', 2),
('Testing123 Language Awareness', 'Build confidence by leveraging your language skills in progressively more challenging coaching conversations', 'score', 60, 80, 'core', 'beginner', 3),

-- Testing123 Language Awareness - Excellence leverage (80-100%)
('Testing123 Language Awareness', 'Model excellence in language awareness for peer coaches and share your natural abilities', 'score', 80, 100, 'core', 'beginner', 1),
('Testing123 Language Awareness', 'Mentor other coaches in developing precision questioning and language pattern recognition', 'score', 80, 100, 'core', 'beginner', 2),
('Testing123 Language Awareness', 'Use this strength as a foundation to tackle the most complex and challenging client situations', 'score', 80, 100, 'core', 'beginner', 3),

-- Testing123 Strength Area - Strength leverage (60-80%)
('Testing123 Strength Area', 'Consistently apply your competency in this area to support client transformation and growth', 'score', 60, 80, 'core', 'beginner', 1),
('Testing123 Strength Area', 'Use this competency strength to build confidence and expand your coaching effectiveness', 'score', 60, 80, 'core', 'beginner', 2),
('Testing123 Strength Area', 'Leverage this area of strength to support development in your weaker coaching competencies', 'score', 60, 80, 'core', 'beginner', 3),

-- Testing123 Strength Area - Excellence leverage (80-100%)
('Testing123 Strength Area', 'Model mastery in this competency and mentor other coaches in developing these critical skills', 'score', 80, 100, 'core', 'beginner', 1),
('Testing123 Strength Area', 'Share your expertise and natural abilities to create positive impact for clients and fellow coaches', 'score', 80, 100, 'core', 'beginner', 2),
('Testing123 Strength Area', 'Use this strength as a cornerstone for developing advanced coaching capabilities and specialized skills', 'score', 80, 100, 'core', 'beginner', 3);

-- ====================================================================
-- CREATE INDEXES FOR PERFORMANCE
-- ====================================================================

CREATE INDEX IF NOT EXISTS idx_strategic_actions_competency_score ON competency_strategic_actions(competency_area, score_range_min, score_range_max);
CREATE INDEX IF NOT EXISTS idx_performance_analysis_competency_score ON competency_performance_analysis(competency_area, analysis_type, score_range_min, score_range_max);
CREATE INDEX IF NOT EXISTS idx_leverage_strengths_competency_score ON competency_leverage_strengths(competency_area, score_range_min, score_range_max);

-- ====================================================================
-- VERIFICATION QUERIES
-- ====================================================================

-- Check that tables are created and populated
SELECT 'strategic_actions' as table_name, COUNT(*) as count FROM competency_strategic_actions WHERE competency_area LIKE '%Testing123%'
UNION ALL
SELECT 'performance_analysis' as table_name, COUNT(*) as count FROM competency_performance_analysis WHERE competency_area LIKE '%Testing123%'
UNION ALL
SELECT 'leverage_strengths' as table_name, COUNT(*) as count FROM competency_leverage_strengths WHERE competency_area LIKE '%Testing123%';