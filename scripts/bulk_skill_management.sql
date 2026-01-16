-- Bulk Skills Management Functions
-- Safe functions to manage skills, insights, and actions while maintaining data integrity

-- 1. Function to deactivate a skill tag and all related data
CREATE OR REPLACE FUNCTION deactivate_skill_tag(skill_tag_name TEXT, framework_code TEXT DEFAULT 'core')
RETURNS TABLE(
  skill_tag_id UUID,
  affected_insights INTEGER,
  affected_actions INTEGER,
  success BOOLEAN,
  message TEXT
) AS $$
DECLARE
  tag_id UUID;
  insights_count INTEGER;
  actions_count INTEGER;
BEGIN
  -- Find the skill tag
  SELECT st.id INTO tag_id
  FROM skill_tags st
  JOIN frameworks f ON st.framework_id = f.id
  WHERE st.name = skill_tag_name 
  AND f.code = framework_code;
  
  -- Check if skill tag exists
  IF tag_id IS NULL THEN
    RETURN QUERY SELECT 
      NULL::UUID, 
      0::INTEGER, 
      0::INTEGER, 
      FALSE, 
      'Skill tag not found: ' || skill_tag_name || ' in framework: ' || framework_code;
    RETURN;
  END IF;
  
  -- Count related records before deactivating
  SELECT COUNT(*) INTO insights_count FROM tag_insights WHERE skill_tag_id = tag_id;
  SELECT COUNT(*) INTO actions_count FROM tag_actions WHERE skill_tag_id = tag_id;
  
  -- Deactivate the skill tag
  UPDATE skill_tags SET is_active = FALSE WHERE id = tag_id;
  
  -- Deactivate related tag_actions
  UPDATE tag_actions SET is_active = FALSE WHERE skill_tag_id = tag_id;
  
  -- Note: tag_insights doesn't have is_active column, so we leave them as-is for data integrity
  
  RETURN QUERY SELECT 
    tag_id,
    insights_count,
    actions_count,
    TRUE,
    'Successfully deactivated skill tag and ' || actions_count || ' related actions';
END;
$$ LANGUAGE plpgsql;

-- 2. Function to reactivate a skill tag and all related data
CREATE OR REPLACE FUNCTION reactivate_skill_tag(skill_tag_name TEXT, framework_code TEXT DEFAULT 'core')
RETURNS TABLE(
  skill_tag_id UUID,
  affected_actions INTEGER,
  success BOOLEAN,
  message TEXT
) AS $$
DECLARE
  tag_id UUID;
  actions_count INTEGER;
BEGIN
  -- Find the skill tag
  SELECT st.id INTO tag_id
  FROM skill_tags st
  JOIN frameworks f ON st.framework_id = f.id
  WHERE st.name = skill_tag_name 
  AND f.code = framework_code;
  
  -- Check if skill tag exists
  IF tag_id IS NULL THEN
    RETURN QUERY SELECT 
      NULL::UUID, 
      0::INTEGER,
      FALSE, 
      'Skill tag not found: ' || skill_tag_name || ' in framework: ' || framework_code;
    RETURN;
  END IF;
  
  -- Count related records
  SELECT COUNT(*) INTO actions_count FROM tag_actions WHERE skill_tag_id = tag_id;
  
  -- Reactivate the skill tag
  UPDATE skill_tags SET is_active = TRUE WHERE id = tag_id;
  
  -- Reactivate related tag_actions
  UPDATE tag_actions SET is_active = TRUE WHERE skill_tag_id = tag_id;
  
  RETURN QUERY SELECT 
    tag_id,
    actions_count,
    TRUE,
    'Successfully reactivated skill tag and ' || actions_count || ' related actions';
END;
$$ LANGUAGE plpgsql;

-- 3. Function to bulk deactivate multiple skills
CREATE OR REPLACE FUNCTION bulk_deactivate_skills(skill_names TEXT[], framework_code TEXT DEFAULT 'core')
RETURNS TABLE(
  skill_name TEXT,
  skill_tag_id UUID,
  success BOOLEAN,
  message TEXT
) AS $$
DECLARE
  skill_name TEXT;
  result RECORD;
BEGIN
  FOREACH skill_name IN ARRAY skill_names
  LOOP
    SELECT * INTO result FROM deactivate_skill_tag(skill_name, framework_code);
    
    RETURN QUERY SELECT 
      skill_name,
      result.skill_tag_id,
      result.success,
      result.message;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 4. Function to update skill tag content (name, insights, actions) safely
CREATE OR REPLACE FUNCTION update_skill_content(
  old_skill_name TEXT,
  new_skill_name TEXT DEFAULT NULL,
  new_weakness_insight TEXT DEFAULT NULL,
  new_strength_insight TEXT DEFAULT NULL,
  new_action_text TEXT DEFAULT NULL,
  framework_code TEXT DEFAULT 'core'
)
RETURNS TABLE(
  skill_tag_id UUID,
  updated_fields TEXT[],
  success BOOLEAN,
  message TEXT
) AS $$
DECLARE
  tag_id UUID;
  updated_fields_list TEXT[] := '{}';
  weakness_type_id UUID;
  strength_type_id UUID;
BEGIN
  -- Find the skill tag
  SELECT st.id INTO tag_id
  FROM skill_tags st
  JOIN frameworks f ON st.framework_id = f.id
  WHERE st.name = old_skill_name 
  AND f.code = framework_code;
  
  -- Check if skill tag exists
  IF tag_id IS NULL THEN
    RETURN QUERY SELECT 
      NULL::UUID, 
      updated_fields_list,
      FALSE, 
      'Skill tag not found: ' || old_skill_name || ' in framework: ' || framework_code;
    RETURN;
  END IF;
  
  -- Get analysis type IDs
  SELECT id INTO weakness_type_id FROM analysis_types WHERE code = 'weakness';
  SELECT id INTO strength_type_id FROM analysis_types WHERE code = 'strength';
  
  -- Update skill tag name if provided
  IF new_skill_name IS NOT NULL THEN
    UPDATE skill_tags SET name = new_skill_name WHERE id = tag_id;
    updated_fields_list := array_append(updated_fields_list, 'skill_name');
  END IF;
  
  -- Update weakness insight if provided
  IF new_weakness_insight IS NOT NULL THEN
    UPDATE tag_insights 
    SET insight_text = new_weakness_insight
    WHERE skill_tag_id = tag_id AND analysis_type_id = weakness_type_id;
    updated_fields_list := array_append(updated_fields_list, 'weakness_insight');
  END IF;
  
  -- Update strength insight if provided
  IF new_strength_insight IS NOT NULL THEN
    UPDATE tag_insights 
    SET insight_text = new_strength_insight
    WHERE skill_tag_id = tag_id AND analysis_type_id = strength_type_id;
    updated_fields_list := array_append(updated_fields_list, 'strength_insight');
  END IF;
  
  -- Update action text if provided
  IF new_action_text IS NOT NULL THEN
    UPDATE tag_actions 
    SET action_text = new_action_text
    WHERE skill_tag_id = tag_id;
    updated_fields_list := array_append(updated_fields_list, 'action_text');
  END IF;
  
  RETURN QUERY SELECT 
    tag_id,
    updated_fields_list,
    TRUE,
    'Successfully updated: ' || array_to_string(updated_fields_list, ', ');
END;
$$ LANGUAGE plpgsql;

-- 5. Function to view all active/inactive skills for review
CREATE OR REPLACE FUNCTION review_skills_status(framework_code TEXT DEFAULT 'core')
RETURNS TABLE(
  skill_name TEXT,
  competency TEXT,
  sort_order INTEGER,
  skill_active BOOLEAN,
  has_weakness_insight BOOLEAN,
  has_strength_insight BOOLEAN,
  has_action BOOLEAN,
  action_active BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    st.name,
    cdn.display_name,
    st.sort_order,
    st.is_active,
    EXISTS(SELECT 1 FROM tag_insights ti JOIN analysis_types at ON ti.analysis_type_id = at.id WHERE ti.skill_tag_id = st.id AND at.code = 'weakness'),
    EXISTS(SELECT 1 FROM tag_insights ti JOIN analysis_types at ON ti.analysis_type_id = at.id WHERE ti.skill_tag_id = st.id AND at.code = 'strength'),
    EXISTS(SELECT 1 FROM tag_actions ta WHERE ta.skill_tag_id = st.id),
    COALESCE((SELECT ta.is_active FROM tag_actions ta WHERE ta.skill_tag_id = st.id), FALSE)
  FROM skill_tags st
  JOIN frameworks f ON st.framework_id = f.id
  LEFT JOIN competency_display_names cdn ON st.competency_id = cdn.id
  WHERE f.code = framework_code
  ORDER BY cdn.display_name, st.sort_order, st.name;
END;
$$ LANGUAGE plpgsql;