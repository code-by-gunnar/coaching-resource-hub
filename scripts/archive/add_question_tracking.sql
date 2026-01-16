-- Add question tracking columns to user_assessment_attempts table
-- This enables direct navigation to the exact question user left off at

ALTER TABLE user_assessment_attempts 
ADD COLUMN IF NOT EXISTS current_question_index INTEGER DEFAULT 1;

ALTER TABLE user_assessment_attempts 
ADD COLUMN IF NOT EXISTS last_activity_at TIMESTAMP DEFAULT NOW();

-- Update existing records to have sensible defaults
UPDATE user_assessment_attempts 
SET current_question_index = 1 
WHERE current_question_index IS NULL;

UPDATE user_assessment_attempts 
SET last_activity_at = created_at 
WHERE last_activity_at IS NULL;

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_user_assessment_attempts_current_question 
ON user_assessment_attempts(user_id, assessment_id, current_question_index);

CREATE INDEX IF NOT EXISTS idx_user_assessment_attempts_activity 
ON user_assessment_attempts(user_id, last_activity_at);

-- Add comments for clarity
COMMENT ON COLUMN user_assessment_attempts.current_question_index IS 'Index of the question user is currently on (1-based)';
COMMENT ON COLUMN user_assessment_attempts.last_activity_at IS 'Timestamp of last user activity in this assessment';

-- Create a function to automatically update last_activity_at
CREATE OR REPLACE FUNCTION update_last_activity_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_activity_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update last_activity_at on any update
DROP TRIGGER IF EXISTS trigger_update_last_activity ON user_assessment_attempts;
CREATE TRIGGER trigger_update_last_activity
    BEFORE UPDATE ON user_assessment_attempts
    FOR EACH ROW
    EXECUTE FUNCTION update_last_activity_at();