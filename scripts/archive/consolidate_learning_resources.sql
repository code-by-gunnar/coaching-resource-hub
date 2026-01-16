-- ====================================================================
-- CONSOLIDATE LEARNING RESOURCES - REMOVE DUPLICATION & EMPTY CATEGORIES
-- ====================================================================
-- Purpose: Clean up learning resources to be more focused and actionable
-- Remove duplicates, empty categories, and self-referential content
-- ====================================================================

-- 1. Remove duplicate Co-Active Coaching entry
DELETE FROM learning_resources 
WHERE title = 'Co-Active Coaching (Fourth Edition)' 
AND id NOT IN (
    SELECT MIN(id) 
    FROM learning_resources 
    WHERE title = 'Co-Active Coaching (Fourth Edition)'
);

-- 2. Remove self-referential assessment tools category entirely
UPDATE learning_path_categories 
SET is_active = false 
WHERE category_title = '📊 Assessment Tools';

-- 3. Remove empty categories
UPDATE learning_path_categories 
SET is_active = false 
WHERE category_title IN ('💻 Online Training', '🎓 Specialized Training');

-- 4. Rename and simplify remaining categories to be more actionable
UPDATE learning_path_categories 
SET 
    category_title = '📚 Essential Reading',
    category_description = 'Core books that will strengthen your coaching fundamentals',
    priority_order = 1
WHERE category_title = '📚 Foundational Reading';

UPDATE learning_path_categories 
SET 
    category_title = '🎯 Practice Exercises',
    category_description = 'Daily exercises to develop your coaching skills through practice',
    priority_order = 2
WHERE category_title = '🎯 Practical Exercises';

-- 5. Verify the cleanup
SELECT 'After cleanup - Active categories:' as status;
SELECT category_title, category_description, priority_order,
    (SELECT COUNT(*) FROM learning_resources WHERE category_id = lpc.id AND is_active = true) as resource_count
FROM learning_path_categories lpc 
WHERE is_active = true 
ORDER BY priority_order;

SELECT 'After cleanup - All resources:' as status;
SELECT lpc.category_title, lr.title, lr.author_instructor
FROM learning_path_categories lpc 
JOIN learning_resources lr ON lpc.id = lr.category_id 
WHERE lpc.is_active = true AND lr.is_active = true
ORDER BY lpc.priority_order, lr.title;