-- =====================================================
-- FRESH COMPETENCY CONTENT REBUILD - CURRENT SCORING
-- =====================================================
-- 
-- Clean rebuild with practical strategic actions and improved performance analysis
-- Uses current score ranges to maintain system compatibility
-- Date: 2025-08-17
-- =====================================================

BEGIN;

-- =====================================================
-- STEP 1: BACKUP CURRENT DATA
-- =====================================================

CREATE TABLE IF NOT EXISTS competency_strategic_actions_backup_20250817 AS 
SELECT * FROM competency_strategic_actions;

CREATE TABLE IF NOT EXISTS competency_performance_analysis_backup_20250817 AS 
SELECT * FROM competency_performance_analysis;

-- =====================================================
-- STEP 2: GET REFERENCE IDs
-- =====================================================

DO $$
DECLARE
    core_framework_id uuid;
    beginner_level_id uuid;
    weakness_analysis_id uuid;
    strength_analysis_id uuid;
    active_listening_id uuid;
    powerful_questions_id uuid;
    present_moment_id uuid;
BEGIN
    -- Get framework and level IDs
    SELECT id INTO core_framework_id FROM frameworks WHERE code = 'core';
    SELECT id INTO beginner_level_id FROM assessment_levels 
    WHERE framework_id = core_framework_id AND level_code = 'beginner';
    
    -- Get analysis type IDs
    SELECT id INTO weakness_analysis_id FROM analysis_types WHERE code = 'weakness';
    SELECT id INTO strength_analysis_id FROM analysis_types WHERE code = 'strength';
    
    -- Get competency IDs
    SELECT id INTO active_listening_id FROM competency_display_names 
    WHERE display_name = 'Active Listening' AND framework_id = core_framework_id;
    
    SELECT id INTO powerful_questions_id FROM competency_display_names 
    WHERE display_name = 'Powerful Questions' AND framework_id = core_framework_id;
    
    SELECT id INTO present_moment_id FROM competency_display_names 
    WHERE display_name = 'Present Moment Awareness' AND framework_id = core_framework_id;
    
    -- Store IDs for use
    PERFORM set_config('rebuild.core_framework_id', core_framework_id::text, true);
    PERFORM set_config('rebuild.beginner_level_id', beginner_level_id::text, true);
    PERFORM set_config('rebuild.weakness_analysis_id', weakness_analysis_id::text, true);
    PERFORM set_config('rebuild.strength_analysis_id', strength_analysis_id::text, true);
    PERFORM set_config('rebuild.active_listening_id', active_listening_id::text, true);
    PERFORM set_config('rebuild.powerful_questions_id', powerful_questions_id::text, true);
    PERFORM set_config('rebuild.present_moment_id', present_moment_id::text, true);
END $$;

-- =====================================================
-- STEP 3: CLEAR OLD CONTENT
-- =====================================================

DELETE FROM competency_strategic_actions 
WHERE framework_id = current_setting('rebuild.core_framework_id')::uuid
AND assessment_level_id = current_setting('rebuild.beginner_level_id')::uuid;

DELETE FROM competency_performance_analysis 
WHERE framework_id = current_setting('rebuild.core_framework_id')::uuid
AND assessment_level_id = current_setting('rebuild.beginner_level_id')::uuid;

-- =====================================================
-- STEP 4: INSERT NEW STRATEGIC ACTIONS
-- =====================================================

INSERT INTO competency_strategic_actions 
(competency_id, framework_id, assessment_level_id, action_text, score_range_min, score_range_max, sort_order, is_active) 
VALUES

-- ACTIVE LISTENING STRATEGIC ACTIONS (4 actions)
(current_setting('rebuild.active_listening_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 'Practice the pause: After client speaks, take a breath and ask yourself "What am I sensing?" then respond to both content and emotion.',
 0, 40, 1, true),

(current_setting('rebuild.active_listening_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 'Use emotion labeling: "It sounds like frustration" or "I hear excitement." Practice identifying emotions in conversations.',
 0, 50, 2, true),

(current_setting('rebuild.active_listening_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 'Master reflective listening: Repeat back what you heard, then add "and it seems like..." to capture the emotional layer.',
 20, 70, 3, true),

(current_setting('rebuild.active_listening_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 'Create safety for vulnerability: Slow down, lower your voice, and say "That takes courage to share."',
 50, 100, 4, true),

-- POWERFUL QUESTIONS STRATEGIC ACTIONS (4 actions)
(current_setting('rebuild.powerful_questions_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 'Ask about feelings: "What excites you about this?" or "How does that land with you?"',
 0, 40, 1, true),

(current_setting('rebuild.powerful_questions_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 'Challenge assumptions: "What if the opposite were true?" or "What would need to change for this to feel easy?"',
 20, 70, 2, true),

(current_setting('rebuild.powerful_questions_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 'Replace advice with curiosity: When you want to suggest something, ask "What possibilities are you seeing?"',
 0, 50, 3, true),

(current_setting('rebuild.powerful_questions_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 'Help them access their resourceful state: "If you already knew the answer, what would it be?" or "What comes up when you trust yourself?"',
 50, 100, 4, true),

-- PRESENT MOMENT AWARENESS STRATEGIC ACTIONS (4 actions)
(current_setting('rebuild.present_moment_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 'Notice what you sense: "Something shifted for you just then" or "I sense some energy around this topic."',
 0, 50, 1, true),

(current_setting('rebuild.present_moment_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 'Name what you see: "Your voice got softer" or "I see a smile in your eyes." Let them interpret the meaning.',
 0, 40, 2, true),

(current_setting('rebuild.present_moment_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 'Get comfortable with silence: After asking a question, take one deep breath before speaking again.',
 20, 70, 3, true),

(current_setting('rebuild.present_moment_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 'Trust your intuition: When something feels different, say "I notice something shifted" and pause for their response.',
 50, 100, 4, true);

-- =====================================================
-- STEP 5: INSERT NEW PERFORMANCE ANALYSIS
-- =====================================================

INSERT INTO competency_performance_analysis 
(competency_id, framework_id, assessment_level_id, analysis_type_id, analysis_text, score_range_min, score_range_max, sort_order, is_active) 
VALUES

-- ACTIVE LISTENING PERFORMANCE ANALYSIS
-- Weakness Analysis
(current_setting('rebuild.active_listening_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 current_setting('rebuild.weakness_analysis_id')::uuid,
 'In Active Listening scenarios, key elements were missed such as emotional undercurrents and creating psychological safety. You receive the words, but the underlying messages require greater attention.',
 0, 0, 1, true),

(current_setting('rebuild.active_listening_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 current_setting('rebuild.weakness_analysis_id')::uuid,
 'Your listening captures some content but emotional layers often go unnoticed. This is a key development area - expanding from listening for information to understanding the whole person.',
 1, 49, 2, true),

(current_setting('rebuild.active_listening_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 current_setting('rebuild.weakness_analysis_id')::uuid,
 'Your listening skills show inconsistency - sometimes effective, other times missing crucial emotional undercurrents. Your listening succeeds with straightforward content but needs strengthening with complex emotions.',
 50, 69, 3, true),

-- Strength Analysis
(current_setting('rebuild.active_listening_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 current_setting('rebuild.strength_analysis_id')::uuid,
 'Your active listening demonstrates strong capability - you consistently catch both content and emotions. Your ability to reflect both facts and feelings helps clients feel deeply understood.',
 70, 89, 4, true),

(current_setting('rebuild.active_listening_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 current_setting('rebuild.strength_analysis_id')::uuid,
 'Your listening skills are highly developed with exceptional awareness. Your ability to create safety while reflecting deep understanding enhances conversations significantly. Clients feel deeply heard and understood.',
 90, 100, 5, true),

-- POWERFUL QUESTIONS PERFORMANCE ANALYSIS
-- Weakness Analysis
(current_setting('rebuild.powerful_questions_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 current_setting('rebuild.weakness_analysis_id')::uuid,
 'The questioning scenarios revealed missed opportunities in connecting with core values, challenging perspectives, and empowering self-discovery. The focus has been on gathering information rather than facilitating breakthrough insights.',
 0, 0, 1, true),

(current_setting('rebuild.powerful_questions_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 current_setting('rebuild.weakness_analysis_id')::uuid,
 'Your questions often direct rather than explore, where guidance replaces discovery. This pattern limits the client ability to access their own insights and solutions.',
 1, 49, 2, true),

(current_setting('rebuild.powerful_questions_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 current_setting('rebuild.weakness_analysis_id')::uuid,
 'Your questioning ability shows promise - effective questions in some scenarios while reverting to advice-giving in others. Developing consistency will enhance client self-discovery.',
 50, 69, 3, true),

-- Strength Analysis
(current_setting('rebuild.powerful_questions_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 current_setting('rebuild.strength_analysis_id')::uuid,
 'Your questioning skills demonstrate strong capability - you effectively explore values and challenge perspectives. Your questions consistently open new thinking pathways for clients.',
 70, 89, 4, true),

(current_setting('rebuild.powerful_questions_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 current_setting('rebuild.strength_analysis_id')::uuid,
 'Your questioning skills create breakthrough moments. Your questions consistently generate valuable insights that clients remember long after sessions end. Clients access their own resourceful thinking through your skillful inquiry.',
 90, 100, 5, true),

-- PRESENT MOMENT AWARENESS PERFORMANCE ANALYSIS
-- Weakness Analysis
(current_setting('rebuild.present_moment_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 current_setting('rebuild.weakness_analysis_id')::uuid,
 'Present moment awareness showed significant gaps - energy shifts went unnoticed and processing needs were overlooked. This suggests focus on your own agenda rather than responding to what is actually happening in real-time.',
 0, 0, 1, true),

(current_setting('rebuild.present_moment_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 current_setting('rebuild.weakness_analysis_id')::uuid,
 'Your present moment awareness captures obvious changes but misses subtle shifts that provide important coaching information. This indicates mental preoccupation with planning next steps rather than staying present.',
 1, 49, 2, true),

(current_setting('rebuild.present_moment_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 current_setting('rebuild.weakness_analysis_id')::uuid,
 'Your presence shows inconsistency - effectively catching some moments while rushing through others. Your awareness fluctuates based on comfort level rather than staying consistently attuned to client needs.',
 50, 69, 3, true),

-- Strength Analysis
(current_setting('rebuild.present_moment_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 current_setting('rebuild.strength_analysis_id')::uuid,
 'Your present moment awareness demonstrates strong development. Your ability to track and respond to real-time changes deepens coaching impact significantly.',
 70, 89, 4, true),

(current_setting('rebuild.present_moment_id')::uuid,
 current_setting('rebuild.core_framework_id')::uuid,
 current_setting('rebuild.beginner_level_id')::uuid,
 current_setting('rebuild.strength_analysis_id')::uuid,
 'Your presence skills create powerful experiences. Your sensitivity to subtle shifts creates breakthrough moments where clients feel completely safe to explore important insights.',
 90, 100, 5, true);

-- =====================================================
-- STEP 6: VERIFICATION
-- =====================================================

DO $$
DECLARE
    actions_count integer;
    analysis_count integer;
BEGIN
    -- Count new strategic actions
    SELECT COUNT(*) INTO actions_count 
    FROM competency_strategic_actions 
    WHERE framework_id = current_setting('rebuild.core_framework_id')::uuid
    AND assessment_level_id = current_setting('rebuild.beginner_level_id')::uuid;
    
    -- Count new performance analysis
    SELECT COUNT(*) INTO analysis_count 
    FROM competency_performance_analysis 
    WHERE framework_id = current_setting('rebuild.core_framework_id')::uuid
    AND assessment_level_id = current_setting('rebuild.beginner_level_id')::uuid;
    
    -- Verify expected counts
    IF actions_count != 12 THEN
        RAISE EXCEPTION 'Expected 12 strategic actions, found %', actions_count;
    END IF;
    
    IF analysis_count != 15 THEN
        RAISE EXCEPTION 'Expected 15 performance analyses, found %', analysis_count;
    END IF;
    
    RAISE NOTICE 'Competency rebuild successful!';
    RAISE NOTICE 'Strategic Actions: % | Performance Analyses: %', actions_count, analysis_count;
END $$;

COMMIT;

-- =====================================================
-- DEPLOYMENT COMPLETE
-- =====================================================