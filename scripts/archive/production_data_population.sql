-- ====================================================================
-- PRODUCTION DATA POPULATION SCRIPT
-- ====================================================================
-- Purpose: Populate normalized tables with production-ready data
-- 
-- NOTE: Run this AFTER production_normalization.sql
-- ====================================================================

-- ====================================================================
-- COMPETENCY DISPLAY NAMES
-- ====================================================================

INSERT INTO competency_display_names (competency_key, display_name, framework, difficulty_level) VALUES
-- Core Framework - Beginner
('present_moment_awareness', 'Present Moment Awareness', 'core', 'beginner'),
('language_awareness', 'Language Awareness', 'core', 'beginner'),
('meaning_exploration', 'Meaning Exploration', 'core', 'beginner'),
('active_listening', 'Active Listening', 'core', 'beginner'),
('powerful_questions', 'Powerful Questions', 'core', 'beginner'),
('creating_awareness', 'Creating Awareness', 'core', 'beginner')
ON CONFLICT (competency_key, framework, difficulty_level) DO NOTHING;

-- ====================================================================
-- COMPETENCY STRATEGIC ACTIONS
-- ====================================================================

-- Core Framework - Beginner - Language Awareness
INSERT INTO competency_strategic_actions (competency_area, action_text, action_type, score_range_min, score_range_max, framework, difficulty_level, sort_order) VALUES
-- Low performance (0-40%)
('Language Awareness', 'Focus on foundational language pattern recognition - practice identifying client deletions, distortions, and generalizations daily', 'practice', 0, 40, 'core', 'beginner', 1),
('Language Awareness', 'Seek feedback from an experienced coach on your language awareness skills during practice sessions', 'session', 0, 40, 'core', 'beginner', 2),
('Language Awareness', 'Study Meta Model techniques for 15 minutes daily to build precision questioning skills', 'study', 0, 40, 'core', 'beginner', 3),

-- Medium performance (40-70%)
('Language Awareness', 'Practice identifying and challenging specific language patterns with clients this week', 'practice', 40, 70, 'core', 'beginner', 1),
('Language Awareness', 'Record a coaching session and review for missed language pattern opportunities', 'reflection', 40, 70, 'core', 'beginner', 2),

-- High performance (70-100%)
('Language Awareness', 'Refine advanced language awareness techniques for greater client impact', 'practice', 70, 100, 'core', 'beginner', 1),
('Language Awareness', 'Expand application of language skills to more challenging client situations', 'session', 70, 100, 'core', 'beginner', 2)
ON CONFLICT DO NOTHING;

-- Add more competency areas as needed...

-- ====================================================================
-- COMPETENCY PERFORMANCE ANALYSIS
-- ====================================================================

INSERT INTO competency_performance_analysis (competency_area, analysis_text, analysis_type, score_range_min, score_range_max, framework, difficulty_level, sort_order) VALUES
-- Language Awareness - Weakness
('Language Awareness', 'Your language pattern recognition skills need development - you may be missing opportunities to notice client limiting beliefs and distortions', 'weakness', 0, 60, 'core', 'beginner', 1),
('Language Awareness', 'Building precision in language awareness will significantly enhance your ability to help clients gain clarity and insight', 'weakness', 0, 60, 'core', 'beginner', 2),

-- Language Awareness - Strength
('Language Awareness', 'You demonstrate good awareness of language patterns and can effectively identify client communication nuances', 'strength', 60, 100, 'core', 'beginner', 1),
('Language Awareness', 'Your language precision skills support client clarity and contribute to meaningful insight development', 'strength', 60, 100, 'core', 'beginner', 2)
ON CONFLICT DO NOTHING;

-- ====================================================================
-- COMPETENCY LEVERAGE STRENGTHS
-- ====================================================================

INSERT INTO competency_leverage_strengths (competency_area, leverage_text, score_range_min, score_range_max, framework, difficulty_level, sort_order) VALUES
-- Language Awareness - Good performance (60-80%)
('Language Awareness', 'Use your language awareness skills to help clients identify their own limiting language patterns and beliefs', 60, 80, 'core', 'beginner', 1),
('Language Awareness', 'Apply your precision questioning consistently to support client breakthrough and awareness moments', 60, 80, 'core', 'beginner', 2),

-- Language Awareness - Excellence (80-100%)
('Language Awareness', 'Model excellence in language awareness for peer coaches and share your natural abilities', 80, 100, 'core', 'beginner', 1),
('Language Awareness', 'Mentor other coaches in developing precision questioning and language pattern recognition', 80, 100, 'core', 'beginner', 2)
ON CONFLICT DO NOTHING;

-- ====================================================================
-- SKILL TAGS
-- ====================================================================

INSERT INTO skill_tags (tag_name, competency_area, framework, difficulty_level) VALUES
('Clean Language', 'Language Awareness', 'core', 'beginner'),
('Meta Model', 'Language Awareness', 'core', 'beginner'),
('Precision Questioning', 'Language Awareness', 'core', 'beginner'),
('Level II/III Listening', 'Active Listening', 'core', 'beginner'),
('Empathetic Presence', 'Active Listening', 'core', 'beginner'),
('GROW Model', 'Powerful Questions', 'core', 'beginner'),
('Open-Ended Questions', 'Powerful Questions', 'core', 'beginner')
ON CONFLICT (tag_name, competency_area, framework, difficulty_level) DO NOTHING;

-- ====================================================================
-- SKILL TAG INSIGHTS
-- ====================================================================

INSERT INTO skill_tag_insights (tag_name, insight_text, insight_type, framework, difficulty_level) VALUES
('Clean Language', 'You may need to develop precision in language pattern recognition', 'weakness', 'core', 'beginner'),
('Clean Language', 'You demonstrate excellent mastery in clean language techniques', 'strength', 'core', 'beginner'),
('Meta Model', 'Missing opportunities to challenge client deletions and distortions', 'weakness', 'core', 'beginner'),
('Meta Model', 'Effectively using Meta Model to uncover deeper client meanings', 'strength', 'core', 'beginner')
ON CONFLICT DO NOTHING;

-- ====================================================================
-- SKILL TAG ACTIONS
-- ====================================================================

INSERT INTO skill_tag_actions (tag_name, action_text, framework, difficulty_level) VALUES
('Clean Language', 'Practice identifying and challenging language patterns daily', 'core', 'beginner'),
('Meta Model', 'Study the Meta Model patterns and practice with peer coaches', 'core', 'beginner'),
('Level II/III Listening', 'Practice deep listening without formulating responses', 'core', 'beginner'),
('GROW Model', 'Apply GROW structure in your next 3 coaching sessions', 'core', 'beginner')
ON CONFLICT DO NOTHING;

-- ====================================================================
-- LEARNING PATH CATEGORIES
-- ====================================================================

INSERT INTO learning_path_categories (category_title, category_description, category_icon, competency_areas, score_range_min, score_range_max, priority_order) VALUES
('Foundation Development Path', 'Essential resources for building core coaching competencies', '🎯', '{}', 0, 40, 1),
('Skill Enhancement Path', 'Targeted resources for developing specific coaching skills', '📈', '{}', 40, 70, 2),
('Advanced Mastery Path', 'Resources for coaches demonstrating high competency ready for mastery', '🏆', '{}', 70, 100, 3)
ON CONFLICT DO NOTHING;

-- ====================================================================
-- LEARNING RESOURCES
-- ====================================================================

-- Get category IDs for linking
WITH category_ids AS (
    SELECT id, category_title FROM learning_path_categories
)
INSERT INTO learning_resources (
    title, 
    resource_type, 
    description, 
    author_instructor,
    competency_areas,
    score_range_min,
    score_range_max,
    category_id,
    priority_order
)
SELECT 
    'Co-Active Coaching', 
    'book',
    'The foundational text for understanding coaching presence and awareness',
    'Henry Kimsey-House',
    ARRAY['Language Awareness', 'Active Listening'],
    0,
    40,
    (SELECT id FROM category_ids WHERE category_title = 'Foundation Development Path'),
    1
WHERE NOT EXISTS (
    SELECT 1 FROM learning_resources WHERE title = 'Co-Active Coaching'
);

-- Add more resources as needed...

-- ====================================================================
-- VERIFICATION
-- ====================================================================

SELECT 
    'Data Population Complete' as status,
    json_build_object(
        'competency_display_names', (SELECT COUNT(*) FROM competency_display_names),
        'strategic_actions', (SELECT COUNT(*) FROM competency_strategic_actions),
        'performance_analysis', (SELECT COUNT(*) FROM competency_performance_analysis),
        'leverage_strengths', (SELECT COUNT(*) FROM competency_leverage_strengths),
        'skill_tags', (SELECT COUNT(*) FROM skill_tags),
        'skill_tag_insights', (SELECT COUNT(*) FROM skill_tag_insights),
        'skill_tag_actions', (SELECT COUNT(*) FROM skill_tag_actions),
        'learning_paths', (SELECT COUNT(*) FROM learning_path_categories),
        'learning_resources', (SELECT COUNT(*) FROM learning_resources)
    ) as record_counts;