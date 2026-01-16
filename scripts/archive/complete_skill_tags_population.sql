-- Complete skill tags population for all Core framework competency areas
-- This fills in the gaps from the original hardcoded data

-- Insert remaining Core competency skill tags
INSERT INTO skill_tags (name, competency_area, framework, sort_order, is_active) VALUES

-- Active Listening skills
('Level II/III Listening', 'Active Listening', 'core', 1, true),
('Reflecting', 'Active Listening', 'core', 2, true),
('Presence', 'Active Listening', 'core', 3, true),
('Chunking', 'Active Listening', 'core', 4, true),

-- Powerful Questions skills  
('Meta Model', 'Powerful Questions', 'core', 1, true),
('Scaling Questions', 'Powerful Questions', 'core', 2, true),
('Exception Questions', 'Powerful Questions', 'core', 3, true),
('Miracle Question', 'Powerful Questions', 'core', 4, true),

-- Direct Communication skills
('Clean Language', 'Direct Communication', 'core', 1, true),
('Bottom-lining', 'Direct Communication', 'core', 2, true),
('Direct Feedback', 'Direct Communication', 'core', 3, true),
('Observations', 'Direct Communication', 'core', 4, true),

-- Creating Awareness skills
('Reframing', 'Creating Awareness', 'core', 1, true),
('Perceptual Positions', 'Creating Awareness', 'core', 2, true),
('Pattern Recognition', 'Creating Awareness', 'core', 3, true),
('Meta Programs', 'Creating Awareness', 'core', 4, true),

-- Designing Actions skills
('GROW Model', 'Designing Actions', 'core', 1, true),
('SMART-ER Goals', 'Designing Actions', 'core', 2, true),
('Future Pace', 'Designing Actions', 'core', 3, true),
('Timeline Techniques', 'Designing Actions', 'core', 4, true),

-- Planning and Goal Setting skills
('OKR Framework', 'Planning and Goal Setting', 'core', 1, true),
('Success Metrics', 'Planning and Goal Setting', 'core', 2, true),
('Anchoring', 'Planning and Goal Setting', 'core', 3, true),
('Designed Alliance', 'Planning and Goal Setting', 'core', 4, true),

-- Managing Progress skills
('Scaling Progress', 'Managing Progress', 'core', 1, true),
('Course Correction', 'Managing Progress', 'core', 2, true),
('Accountability Structures', 'Managing Progress', 'core', 3, true),
('Exception Finding', 'Managing Progress', 'core', 4, true)

ON CONFLICT (name, competency_area, framework) DO NOTHING;

-- Now populate basic insights for all these new skill tags
INSERT INTO tag_insights (skill_tag_id, insight_text, insight_type, context_level) 
SELECT 
    st.id,
    'You may need focused practice in ' || st.name || ' to strengthen your ' || st.competency_area || ' skills.',
    'weakness',
    'beginner'
FROM skill_tags st
WHERE st.framework = 'core' 
  AND st.competency_area IN (
    'Active Listening', 'Powerful Questions', 'Direct Communication', 
    'Creating Awareness', 'Designing Actions', 'Planning and Goal Setting', 'Managing Progress'
  )
  AND NOT EXISTS (
    SELECT 1 FROM tag_insights ti WHERE ti.skill_tag_id = st.id
  );

-- Populate basic actions for all these skill tags
INSERT INTO tag_actions (skill_tag_id, action_text, is_active) 
SELECT 
    st.id,
    'Practice ' || st.name || ' techniques in your next coaching session and observe the client response.',
    true
FROM skill_tags st
WHERE st.framework = 'core' 
  AND st.competency_area IN (
    'Active Listening', 'Powerful Questions', 'Direct Communication', 
    'Creating Awareness', 'Designing Actions', 'Planning and Goal Setting', 'Managing Progress'
  )
  AND NOT EXISTS (
    SELECT 1 FROM tag_actions ta WHERE ta.skill_tag_id = st.id
  );

-- Add corresponding competency display name mappings for database cache
INSERT INTO competency_display_names (competency_key, display_name, framework, sort_order, is_active) VALUES
('active_listening', 'Active Listening & Presence', 'core', 1, true),
('powerful_questions', 'Powerful Questioning', 'core', 2, true),
('direct_communication', 'Direct Communication', 'core', 3, true),
('creating_awareness', 'Creating Awareness', 'core', 4, true),
('designing_actions', 'Designing Actions', 'core', 5, true),
('planning_goal_setting', 'Goal Setting & Planning', 'core', 6, true),
('managing_progress', 'Managing Progress & Accountability', 'core', 7, true)
ON CONFLICT (competency_key, framework) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  sort_order = EXCLUDED.sort_order;

-- Check results
SELECT 'Skill tags count:', COUNT(*) FROM skill_tags WHERE framework = 'core';
SELECT 'Competency areas:', COUNT(DISTINCT competency_area) FROM skill_tags WHERE framework = 'core';
SELECT 'Tag insights count:', COUNT(*) FROM tag_insights JOIN skill_tags ON skill_tags.id = tag_insights.skill_tag_id WHERE skill_tags.framework = 'core';