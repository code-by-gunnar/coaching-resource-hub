-- Add missing sort_order column to competency_strategic_actions
ALTER TABLE competency_strategic_actions 
ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;

-- Update existing rows to have a sort_order
UPDATE competency_strategic_actions 
SET sort_order = COALESCE(priority_order, 0)
WHERE sort_order IS NULL OR sort_order = 0;

-- Add is_active column if missing
ALTER TABLE competency_strategic_actions 
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- Update existing rows  
UPDATE competency_strategic_actions 
SET is_active = true
WHERE is_active IS NULL;

-- Check what columns exist now
SELECT column_name, data_type, column_default 
FROM information_schema.columns 
WHERE table_name = 'competency_strategic_actions'
ORDER BY ordinal_position;