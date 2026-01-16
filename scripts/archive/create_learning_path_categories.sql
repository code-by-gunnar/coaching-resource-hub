-- Learning Path Categories Table
-- Creates proper relationships between competency areas and user-friendly learning path categories
-- Resolves naming inconsistencies and provides structured learning recommendations

-- First, let's standardize the competency area names
-- Standard format: Title Case with consistent naming

CREATE TABLE IF NOT EXISTS learning_path_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_title VARCHAR(255) NOT NULL, -- User-friendly category name like "Language Mastery Resources"
    category_description TEXT, -- Description shown to users
    category_icon VARCHAR(10), -- Emoji icon for the category
    competency_areas TEXT[] NOT NULL, -- Array of standardized competency area names this category covers
    priority_order INTEGER DEFAULT 0, -- Display order priority
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert the learning path categories based on current frontend hardcoded categories
-- These map the inconsistent competency names to user-friendly learning path titles

INSERT INTO learning_path_categories (category_title, category_description, category_icon, competency_areas, priority_order) VALUES
-- Active Listening Category
('Active Listening Mastery', 'Study materials and courses to develop your listening skills.', '👂', '{"Active Listening"}', 1),

-- Powerful Questions Category  
('Powerful Questioning Mastery', 'Resources to develop sophisticated questioning techniques.', '❓', '{"Powerful Questions"}', 2),

-- Awareness Creation Category
('Awareness Creation Resources', 'Study materials to master insight generation techniques.', '💡', '{"Creating Awareness"}', 3),

-- Action Planning Category
('Action Planning & Goal Setting Resources', 'Comprehensive materials for effective goal design and accountability.', '🎯', '{"Designing Actions", "Planning and Goal Setting"}', 4),

-- Language Mastery Category (resolves Language Awareness vs Intuition & Language Awareness)
('Language Mastery Resources', 'Advanced training in linguistic patterns and communication.', '🗣️', '{"Language Awareness"}', 5),

-- Present Moment Category
('Presence & Mindfulness Resources', 'Training materials for cultivating coaching presence.', '🧘', '{"Present Moment Awareness"}', 6),

-- Values & Meaning Category (resolves Meaning Exploration vs Values & Meaning Exploration)
('Values & Purpose Resources', 'Comprehensive materials for deep meaning exploration.', '💫', '{"Meaning Exploration"}', 7),

-- Direct Communication Category
('Communication Excellence Resources', 'Resources for clear, direct, and effective communication.', '💬', '{"Direct Communication"}', 8),

-- Managing Progress Category
('Progress Management Resources', 'Tools and techniques for tracking coaching progress and accountability.', '📈', '{"Managing Progress"}', 9),

-- Score-based categories for overall performance
('Foundation Building Resources', 'Essential materials to strengthen your core coaching foundation.', '🏗️', '{}', 10),

('Advanced Specialization Resources', 'Sophisticated training for experienced practitioners.', '🚀', '{}', 11),

-- Testing category to verify database connectivity
('Testing123 Language Resources', 'Test category to verify database connectivity and data flow.', '🧪', '{"Language Awareness"}', 99);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_learning_path_categories_competency_areas ON learning_path_categories USING GIN (competency_areas);
CREATE INDEX IF NOT EXISTS idx_learning_path_categories_active ON learning_path_categories (is_active);
CREATE INDEX IF NOT EXISTS idx_learning_path_categories_priority ON learning_path_categories (priority_order);

-- Update learning_resources table to add category_id reference
ALTER TABLE learning_resources ADD COLUMN IF NOT EXISTS category_id UUID REFERENCES learning_path_categories(id);

-- Create mapping from existing learning_resources to categories
-- This maps the current inconsistent competency_areas to the new standardized categories

UPDATE learning_resources 
SET category_id = (SELECT id FROM learning_path_categories WHERE category_title = 'Active Listening Mastery')
WHERE 'Active Listening' = ANY(competency_areas);

UPDATE learning_resources 
SET category_id = (SELECT id FROM learning_path_categories WHERE category_title = 'Powerful Questioning Mastery')
WHERE 'Powerful Questions' = ANY(competency_areas);

UPDATE learning_resources 
SET category_id = (SELECT id FROM learning_path_categories WHERE category_title = 'Awareness Creation Resources')
WHERE 'Creating Awareness' = ANY(competency_areas);

UPDATE learning_resources 
SET category_id = (SELECT id FROM learning_path_categories WHERE category_title = 'Action Planning & Goal Setting Resources')
WHERE 'Designing Actions' = ANY(competency_areas) OR 'Planning and Goal Setting' = ANY(competency_areas);

UPDATE learning_resources 
SET category_id = (SELECT id FROM learning_path_categories WHERE category_title = 'Language Mastery Resources')
WHERE 'Intuition & Language Awareness' = ANY(competency_areas);

UPDATE learning_resources 
SET category_id = (SELECT id FROM learning_path_categories WHERE category_title = 'Presence & Mindfulness Resources')
WHERE 'Present Moment Awareness' = ANY(competency_areas);

UPDATE learning_resources 
SET category_id = (SELECT id FROM learning_path_categories WHERE category_title = 'Values & Purpose Resources')
WHERE 'Values & Meaning Exploration' = ANY(competency_areas);

UPDATE learning_resources 
SET category_id = (SELECT id FROM learning_path_categories WHERE category_title = 'Communication Excellence Resources')
WHERE 'Direct Communication' = ANY(competency_areas);

UPDATE learning_resources 
SET category_id = (SELECT id FROM learning_path_categories WHERE category_title = 'Progress Management Resources')
WHERE 'Managing Progress' = ANY(competency_areas);

-- Verification queries to check the mappings
SELECT 
    lpc.category_title,
    lpc.competency_areas,
    COUNT(lr.id) as resource_count
FROM learning_path_categories lpc
LEFT JOIN learning_resources lr ON lr.category_id = lpc.id
GROUP BY lpc.id, lpc.category_title, lpc.competency_areas
ORDER BY lpc.priority_order;