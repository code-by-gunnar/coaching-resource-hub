-- Add analysis_type_id column to learning_resources table
-- This creates the simple FK relationship for tiered resources
-- Run Date: 2025-08-24

BEGIN;

-- ===================================================================
-- SECTION 1: ADD ANALYSIS_TYPE_ID COLUMN
-- ===================================================================

-- Add the foreign key column
ALTER TABLE learning_resources 
ADD COLUMN analysis_type_id UUID REFERENCES analysis_types(id);

-- Create index for performance
CREATE INDEX idx_learning_resources_analysis_type_id 
ON learning_resources(analysis_type_id);

-- ===================================================================
-- SECTION 2: GET ANALYSIS_TYPE IDS FOR REFERENCE
-- ===================================================================

-- Show the analysis types for easy reference
SELECT 
  id,
  code,
  name,
  description
FROM analysis_types
ORDER BY 
  CASE code 
    WHEN 'weakness' THEN 1
    WHEN 'developing' THEN 2  
    WHEN 'strength' THEN 3
    ELSE 4
  END;

COMMIT;

-- Success message
SELECT 'analysis_type_id column added to learning_resources table successfully!' as status;