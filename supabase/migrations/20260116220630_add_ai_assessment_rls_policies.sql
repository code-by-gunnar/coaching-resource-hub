-- Add RLS policies for AI Assessment tables
-- These tables need to be readable by authenticated users

-- ============================================================================
-- AI_FRAMEWORKS - Public read access
-- ============================================================================
ALTER TABLE ai_frameworks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "ai_frameworks_select_all" ON ai_frameworks
  FOR SELECT USING (true);

-- ============================================================================
-- AI_ASSESSMENT_LEVELS - Public read access
-- ============================================================================
ALTER TABLE ai_assessment_levels ENABLE ROW LEVEL SECURITY;

CREATE POLICY "ai_assessment_levels_select_all" ON ai_assessment_levels
  FOR SELECT USING (true);

-- ============================================================================
-- AI_COMPETENCIES - Public read access
-- ============================================================================
ALTER TABLE ai_competencies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "ai_competencies_select_all" ON ai_competencies
  FOR SELECT USING (true);

-- ============================================================================
-- AI_QUESTIONS - Public read access (questions are public, answers aren't exposed)
-- ============================================================================
ALTER TABLE ai_questions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "ai_questions_select_all" ON ai_questions
  FOR SELECT USING (true);

-- ============================================================================
-- AI_ASSESSMENT_ATTEMPTS - Users can only access their own attempts
-- ============================================================================
ALTER TABLE ai_assessment_attempts ENABLE ROW LEVEL SECURITY;

-- Users can view their own attempts
CREATE POLICY "ai_assessment_attempts_select_own" ON ai_assessment_attempts
  FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own attempts
CREATE POLICY "ai_assessment_attempts_insert_own" ON ai_assessment_attempts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own attempts
CREATE POLICY "ai_assessment_attempts_update_own" ON ai_assessment_attempts
  FOR UPDATE USING (auth.uid() = user_id);
