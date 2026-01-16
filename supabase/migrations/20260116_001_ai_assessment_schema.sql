-- ============================================================================
-- AI-Generated Assessment Reports: Phase 1 - Fresh Schema
-- ============================================================================
-- Migration: 20260116_001_ai_assessment_schema.sql
-- Purpose: Create simplified schema for AI-generated assessment reports
-- Design Doc: .plans/2026-01-16-ai-generated-assessment-reports-design.md
--
-- Strategy: Fresh schema - new tables that replace the complex content system
-- Old tables remain for reference but are not used by the new system
-- ============================================================================

-- ============================================================================
-- PART 1: FRAMEWORKS TABLE
-- Core reference table for assessment frameworks (core, icf, ac)
-- ============================================================================

CREATE TABLE IF NOT EXISTS ai_frameworks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,  -- 'core', 'icf', 'ac'
    name TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE ai_frameworks IS
'Coaching assessment frameworks: Core Coaching, ICF, Association for Coaching';

-- Seed frameworks
INSERT INTO ai_frameworks (code, name, description) VALUES
('core', 'Core Coaching Fundamentals', 'Foundation coaching skills and competencies for all coaches'),
('icf', 'ICF Core Competencies', 'International Coaching Federation competency framework'),
('ac', 'AC Competencies', 'Association for Coaching competency framework')
ON CONFLICT (code) DO NOTHING;


-- ============================================================================
-- PART 2: ASSESSMENT LEVELS TABLE
-- Difficulty levels per framework (beginner, intermediate, advanced)
-- ============================================================================

CREATE TABLE IF NOT EXISTS ai_assessment_levels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    framework_id UUID NOT NULL REFERENCES ai_frameworks(id) ON DELETE CASCADE,
    level_code TEXT NOT NULL,  -- 'beginner', 'intermediate', 'advanced'
    name TEXT NOT NULL,
    description TEXT,
    question_count INTEGER DEFAULT 15,  -- How many questions in this assessment
    passing_score INTEGER DEFAULT 70,    -- Minimum score to pass (percentage)
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),

    UNIQUE(framework_id, level_code)
);

COMMENT ON TABLE ai_assessment_levels IS
'Assessment difficulty levels within each framework';

-- Index for active levels
CREATE INDEX IF NOT EXISTS idx_ai_assessment_levels_active
ON ai_assessment_levels(framework_id)
WHERE is_active = true;


-- ============================================================================
-- PART 3: COMPETENCIES TABLE
-- Coaching competencies with AI context for report generation
-- ============================================================================

CREATE TABLE IF NOT EXISTS ai_competencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    framework_id UUID NOT NULL REFERENCES ai_frameworks(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    ai_context TEXT,  -- Additional context for AI when generating reports
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),

    UNIQUE(framework_id, code)
);

COMMENT ON TABLE ai_competencies IS
'Coaching competencies used for assessment categorization and AI report context';

COMMENT ON COLUMN ai_competencies.ai_context IS
'Rich context about this competency provided to AI for generating insightful reports';

-- Index for framework queries
CREATE INDEX IF NOT EXISTS idx_ai_competencies_framework
ON ai_competencies(framework_id)
WHERE is_active = true;


-- ============================================================================
-- PART 4: QUESTIONS TABLE (Question Pool)
-- Assessment questions with concept tagging for rotation and AI context
-- ============================================================================

CREATE TABLE IF NOT EXISTS ai_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    framework_id UUID NOT NULL REFERENCES ai_frameworks(id) ON DELETE CASCADE,
    level_id UUID NOT NULL REFERENCES ai_assessment_levels(id) ON DELETE CASCADE,
    competency_id UUID NOT NULL REFERENCES ai_competencies(id) ON DELETE CASCADE,

    -- Question content
    scenario_text TEXT NOT NULL,          -- The scenario/context
    question_text TEXT NOT NULL,          -- The actual question
    options JSONB NOT NULL,               -- [{key: 'a', text: '...'}, {key: 'b', text: '...'}, ...]
    correct_option TEXT NOT NULL,         -- 'a', 'b', 'c', or 'd'

    -- AI context
    concept_tag TEXT NOT NULL,            -- e.g., 'emotional_cue_recognition', 'open_questions'
    explanation TEXT NOT NULL,            -- Why the correct answer is correct
    ai_hint TEXT,                         -- Additional hint for AI about common mistakes

    -- Metadata
    difficulty_weight INTEGER DEFAULT 1,  -- 1-3, affects scoring weight
    question_order INTEGER,               -- Optional ordering within assessment
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE ai_questions IS
'Question pool supporting rotation - same concepts can have multiple scenario variations';

COMMENT ON COLUMN ai_questions.concept_tag IS
'The underlying skill/concept tested. Multiple questions can share the same concept_tag for rotation.';

COMMENT ON COLUMN ai_questions.explanation IS
'Why the correct answer is correct - provided to AI for generating specific feedback';

COMMENT ON COLUMN ai_questions.ai_hint IS
'Optional hint about common mistakes on this question, helps AI provide targeted guidance';

-- Indexes for question selection
CREATE INDEX IF NOT EXISTS idx_ai_questions_level
ON ai_questions(level_id)
WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_ai_questions_competency
ON ai_questions(competency_id)
WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_ai_questions_concept
ON ai_questions(concept_tag)
WHERE is_active = true;


-- ============================================================================
-- PART 5: ASSESSMENT ATTEMPTS TABLE
-- User assessment attempts with AI-generated reports
-- ============================================================================

CREATE TABLE IF NOT EXISTS ai_assessment_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    framework_id UUID NOT NULL REFERENCES ai_frameworks(id),
    level_id UUID NOT NULL REFERENCES ai_assessment_levels(id),

    -- Assessment data
    started_at TIMESTAMPTZ DEFAULT now(),
    completed_at TIMESTAMPTZ,
    questions_served JSONB NOT NULL,      -- Array of question IDs shown to user
    answers JSONB NOT NULL DEFAULT '{}',  -- {question_id: selected_option, ...}

    -- Scoring
    score_percentage DECIMAL(5,2),
    competency_scores JSONB,              -- {competency_code: {correct: N, total: N, pct: N}, ...}

    -- AI Report
    ai_report TEXT,                       -- The generated report (markdown)
    ai_report_metadata JSONB,             -- {model, tokens, generated_at, generation_ms}

    -- Progress tracking
    previous_attempt_id UUID REFERENCES ai_assessment_attempts(id),

    created_at TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE ai_assessment_attempts IS
'User assessment attempts with AI-generated personalized reports';

-- Indexes for queries
CREATE INDEX IF NOT EXISTS idx_ai_attempts_user
ON ai_assessment_attempts(user_id);

CREATE INDEX IF NOT EXISTS idx_ai_attempts_user_level
ON ai_assessment_attempts(user_id, framework_id, level_id, completed_at DESC);

CREATE INDEX IF NOT EXISTS idx_ai_attempts_completed
ON ai_assessment_attempts(completed_at DESC)
WHERE completed_at IS NOT NULL;


-- ============================================================================
-- PART 6: FUNCTION - Auto-link Previous Attempts
-- ============================================================================

CREATE OR REPLACE FUNCTION ai_link_previous_attempt()
RETURNS TRIGGER AS $$
BEGIN
    -- Find user's most recent completed attempt for same framework/level
    SELECT id INTO NEW.previous_attempt_id
    FROM ai_assessment_attempts
    WHERE user_id = NEW.user_id
      AND framework_id = NEW.framework_id
      AND level_id = NEW.level_id
      AND completed_at IS NOT NULL
      AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid)
    ORDER BY completed_at DESC
    LIMIT 1;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_ai_link_previous_attempt ON ai_assessment_attempts;
CREATE TRIGGER trg_ai_link_previous_attempt
    BEFORE INSERT ON ai_assessment_attempts
    FOR EACH ROW
    EXECUTE FUNCTION ai_link_previous_attempt();


-- ============================================================================
-- PART 7: FUNCTION - Calculate Competency Scores
-- ============================================================================

CREATE OR REPLACE FUNCTION ai_calculate_competency_scores(
    p_attempt_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_scores JSONB;
    v_total_correct INTEGER := 0;
    v_total_questions INTEGER := 0;
    v_percentage DECIMAL(5,2);
BEGIN
    -- Calculate per-competency scores
    WITH answer_analysis AS (
        SELECT
            c.code as competency_code,
            q.id as question_id,
            (a.answers->>q.id::text) as selected,
            q.correct_option,
            (a.answers->>q.id::text) = q.correct_option as is_correct
        FROM ai_assessment_attempts a
        CROSS JOIN LATERAL jsonb_array_elements_text(a.questions_served) AS qs(question_id)
        JOIN ai_questions q ON q.id = qs.question_id::uuid
        JOIN ai_competencies c ON q.competency_id = c.id
        WHERE a.id = p_attempt_id
    )
    SELECT
        jsonb_object_agg(
            competency_code,
            jsonb_build_object(
                'correct', SUM(CASE WHEN is_correct THEN 1 ELSE 0 END),
                'total', COUNT(*),
                'percentage', ROUND((SUM(CASE WHEN is_correct THEN 1 ELSE 0 END)::numeric / COUNT(*)::numeric) * 100, 1)
            )
        ),
        SUM(CASE WHEN is_correct THEN 1 ELSE 0 END),
        COUNT(*)
    INTO v_scores, v_total_correct, v_total_questions
    FROM answer_analysis
    GROUP BY competency_code;

    -- Calculate overall percentage
    IF v_total_questions > 0 THEN
        v_percentage := ROUND((v_total_correct::numeric / v_total_questions::numeric) * 100, 1);
    ELSE
        v_percentage := 0;
    END IF;

    -- Update the attempt
    UPDATE ai_assessment_attempts
    SET
        competency_scores = v_scores,
        score_percentage = v_percentage
    WHERE id = p_attempt_id;

    RETURN v_scores;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================================================
-- PART 8: VIEW - AI Report Context
-- Aggregates all data needed for AI report generation
-- ============================================================================

CREATE OR REPLACE VIEW ai_report_context AS
SELECT
    a.id as attempt_id,
    a.user_id,
    a.started_at,
    a.completed_at,
    a.questions_served,
    a.answers,
    a.score_percentage,
    a.competency_scores,
    a.previous_attempt_id,
    a.ai_report,
    a.ai_report_metadata,

    -- Framework/Level info
    f.code as framework_code,
    f.name as framework_name,
    l.level_code,
    l.name as level_name,
    l.passing_score,

    -- Previous attempt for comparison
    prev.score_percentage as prev_score_percentage,
    prev.competency_scores as prev_competency_scores,
    prev.completed_at as prev_completed_at

FROM ai_assessment_attempts a
JOIN ai_frameworks f ON a.framework_id = f.id
JOIN ai_assessment_levels l ON a.level_id = l.id
LEFT JOIN ai_assessment_attempts prev ON a.previous_attempt_id = prev.id;


-- ============================================================================
-- PART 9: ROW LEVEL SECURITY
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE ai_frameworks ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_assessment_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_competencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_assessment_attempts ENABLE ROW LEVEL SECURITY;

-- Reference tables: public read access
CREATE POLICY "Frameworks are publicly readable"
ON ai_frameworks FOR SELECT TO authenticated
USING (is_active = true);

CREATE POLICY "Assessment levels are publicly readable"
ON ai_assessment_levels FOR SELECT TO authenticated
USING (is_active = true);

CREATE POLICY "Competencies are publicly readable"
ON ai_competencies FOR SELECT TO authenticated
USING (is_active = true);

CREATE POLICY "Questions are publicly readable"
ON ai_questions FOR SELECT TO authenticated
USING (is_active = true);

-- User attempts: user can only see/modify their own
CREATE POLICY "Users can view their own attempts"
ON ai_assessment_attempts FOR SELECT TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Users can insert their own attempts"
ON ai_assessment_attempts FOR INSERT TO authenticated
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own attempts"
ON ai_assessment_attempts FOR UPDATE TO authenticated
USING (user_id = auth.uid());


-- ============================================================================
-- PART 10: GRANTS
-- ============================================================================

GRANT SELECT ON ai_frameworks TO authenticated;
GRANT SELECT ON ai_assessment_levels TO authenticated;
GRANT SELECT ON ai_competencies TO authenticated;
GRANT SELECT ON ai_questions TO authenticated;
GRANT SELECT, INSERT, UPDATE ON ai_assessment_attempts TO authenticated;
GRANT SELECT ON ai_report_context TO authenticated;
GRANT EXECUTE ON FUNCTION ai_calculate_competency_scores(UUID) TO authenticated;


-- ============================================================================
-- Migration Complete
-- ============================================================================
-- Next: Run 20260116_002_seed_core_beginner.sql to populate Core I data
-- ============================================================================
