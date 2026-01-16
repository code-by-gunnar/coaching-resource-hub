-- ====================================================================
-- PRODUCTION DATABASE NORMALIZATION SCRIPT
-- ====================================================================
-- Purpose: Normalize the production database with all required tables
--          for dynamic content generation and assessment insights
-- 
-- WARNING: This script should be run on production ONLY after testing
--          in development environment
-- ====================================================================

-- ====================================================================
-- PART 1: CORE NORMALIZATION TABLES
-- ====================================================================

-- 1. Competency Display Names
CREATE TABLE IF NOT EXISTS competency_display_names (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    competency_key text NOT NULL,
    display_name text NOT NULL,
    framework text CHECK (framework IN ('core', 'icf', 'ac')) NOT NULL,
    difficulty_level text CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),
    UNIQUE(competency_key, framework, difficulty_level)
);

-- 2. Competency Strategic Actions
CREATE TABLE IF NOT EXISTS competency_strategic_actions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    competency_area text NOT NULL,
    action_text text NOT NULL,
    action_type text CHECK (action_type IN ('immediate', 'session', 'practice', 'reflection', 'study')) NOT NULL,
    score_range_min integer NOT NULL,
    score_range_max integer NOT NULL,
    framework text CHECK (framework IN ('core', 'icf', 'ac')) NOT NULL,
    difficulty_level text CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')) NOT NULL,
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now()
);

-- 3. Competency Performance Analysis
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

-- 4. Competency Leverage Strengths
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

-- 5. Skill Tags
CREATE TABLE IF NOT EXISTS skill_tags (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tag_name text NOT NULL,
    competency_area text NOT NULL,
    framework text CHECK (framework IN ('core', 'icf', 'ac')) NOT NULL,
    difficulty_level text CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')) NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),
    UNIQUE(tag_name, competency_area, framework, difficulty_level)
);

-- 6. Skill Tag Insights
CREATE TABLE IF NOT EXISTS skill_tag_insights (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tag_name text NOT NULL,
    insight_text text NOT NULL,
    insight_type text CHECK (insight_type IN ('weakness', 'strength')) NOT NULL,
    framework text CHECK (framework IN ('core', 'icf', 'ac')) NOT NULL,
    difficulty_level text CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')) NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now()
);

-- 7. Skill Tag Actions
CREATE TABLE IF NOT EXISTS skill_tag_actions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tag_name text NOT NULL,
    action_text text NOT NULL,
    framework text CHECK (framework IN ('core', 'icf', 'ac')) NOT NULL,
    difficulty_level text CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')) NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now()
);

-- 8. Learning Path Categories
CREATE TABLE IF NOT EXISTS learning_path_categories (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    category_title text NOT NULL,
    category_description text NOT NULL,
    category_icon text DEFAULT '📚',
    competency_areas text[] DEFAULT '{}',
    score_range_min integer DEFAULT 0,
    score_range_max integer DEFAULT 100,
    framework text CHECK (framework IN ('core', 'icf', 'ac', 'all')) DEFAULT 'all',
    difficulty_level text CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced', 'all')) DEFAULT 'all',
    priority_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now()
);

-- 9. Learning Resources
CREATE TABLE IF NOT EXISTS learning_resources (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    title text NOT NULL,
    resource_type text CHECK (resource_type IN ('book', 'course', 'video', 'article', 'exercise', 'tool', 'workshop', 'certification', 'assessment', 'mentor', 'community', 'conference', 'app')) NOT NULL,
    description text,
    author_instructor text,
    url text,
    competency_areas text[] DEFAULT '{}',
    score_range_min integer DEFAULT 0,
    score_range_max integer DEFAULT 100,
    framework text CHECK (framework IN ('core', 'icf', 'ac', 'all')) DEFAULT 'all',
    difficulty_level text CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced', 'all')) DEFAULT 'all',
    category_id uuid REFERENCES learning_path_categories(id) ON DELETE SET NULL,
    priority_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now()
);

-- ====================================================================
-- PART 2: RPC FUNCTIONS FOR DATA ACCESS
-- ====================================================================

-- Function to get learning paths for assessment results
CREATE OR REPLACE FUNCTION get_learning_paths_for_assessment(
    weak_competency_areas text[],
    overall_score integer DEFAULT 60
)
RETURNS TABLE (
    category_title text,
    category_description text,
    category_icon text,
    resources json
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        lpc.category_title,
        lpc.category_description,
        lpc.category_icon,
        COALESCE(
            json_agg(
                json_build_object(
                    'title', lr.title,
                    'type', lr.resource_type,
                    'description', lr.description,
                    'author', lr.author_instructor
                ) ORDER BY lr.priority_order
            ) FILTER (WHERE lr.id IS NOT NULL),
            '[]'::json
        ) as resources
    FROM learning_path_categories lpc
    LEFT JOIN learning_resources lr ON lr.category_id = lpc.id
        AND lr.is_active = true
        AND lr.score_range_min <= overall_score
        AND lr.score_range_max >= overall_score
    WHERE lpc.is_active = true
        AND lpc.score_range_min <= overall_score
        AND lpc.score_range_max >= overall_score
        AND (
            -- Include if category has no specific competency areas (general resources)
            array_length(lpc.competency_areas, 1) IS NULL 
            OR lpc.competency_areas = '{}'
            -- Or if any weak area matches category areas
            OR lpc.competency_areas && weak_competency_areas
        )
    GROUP BY lpc.category_title, lpc.category_description, lpc.category_icon, lpc.priority_order
    ORDER BY lpc.priority_order
    LIMIT 3;
END;
$$;

-- ====================================================================
-- PART 3: CREATE INDEXES FOR PERFORMANCE
-- ====================================================================

CREATE INDEX IF NOT EXISTS idx_strategic_actions_lookup 
ON competency_strategic_actions(competency_area, framework, difficulty_level, score_range_min, score_range_max);

CREATE INDEX IF NOT EXISTS idx_performance_analysis_lookup 
ON competency_performance_analysis(competency_area, framework, difficulty_level, analysis_type, score_range_min, score_range_max);

CREATE INDEX IF NOT EXISTS idx_leverage_strengths_lookup 
ON competency_leverage_strengths(competency_area, framework, difficulty_level, score_range_min, score_range_max);

CREATE INDEX IF NOT EXISTS idx_skill_tags_lookup 
ON skill_tags(competency_area, framework, difficulty_level);

CREATE INDEX IF NOT EXISTS idx_learning_paths_score 
ON learning_path_categories(score_range_min, score_range_max);

CREATE INDEX IF NOT EXISTS idx_learning_resources_score 
ON learning_resources(score_range_min, score_range_max);

-- ====================================================================
-- VERIFICATION QUERY
-- ====================================================================
SELECT 
    'Tables Created' as status,
    COUNT(*) as table_count
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
    'competency_display_names',
    'competency_strategic_actions',
    'competency_performance_analysis',
    'competency_leverage_strengths',
    'skill_tags',
    'skill_tag_insights',
    'skill_tag_actions',
    'learning_path_categories',
    'learning_resources'
);