-- ====================================================================
-- ADD COMPETENCY DESCRIPTIONS
-- ====================================================================
-- Purpose: Add description column to competency_display_names table
-- This will provide detailed explanations for each competency
-- to display in development areas on assessment results
-- ====================================================================

-- Add description column to competency_display_names table
ALTER TABLE competency_display_names 
ADD COLUMN IF NOT EXISTS description TEXT;

-- Add descriptions for Core I competencies
UPDATE competency_display_names 
SET description = CASE competency_key
    WHEN 'active_listening' THEN 
        'The ability to fully concentrate, understand, respond and remember what is being said by the client. Active listening involves giving full attention to the speaker, understanding their message, comprehending the information, and responding thoughtfully. It goes beyond simply hearing words to understanding the complete message being conveyed, including emotional undertones and unspoken concerns.'
    
    WHEN 'powerful_questions' THEN 
        'The skill of asking open-ended, thought-provoking questions that invite reflection, discovery, and insight. Powerful questions challenge assumptions, explore possibilities, and help clients gain new perspectives on their situations. These questions are typically short, open-ended, and focused on the client rather than satisfying the coach''s curiosity.'
    
    WHEN 'present_moment_awareness' THEN 
        'The capacity to be fully present and aware of what is happening in the coaching conversation moment by moment. This includes noticing shifts in energy, emotion, body language, and tone of voice. Present moment awareness allows coaches to pick up on subtle cues and patterns that can lead to breakthrough insights and deeper understanding.'
    
    WHEN 'creating_awareness' THEN 
        'The ability to integrate and accurately evaluate multiple sources of information to help clients gain insights that lead to achieving agreed-upon results. This involves helping clients discover new thoughts, beliefs, perceptions, emotions, and moods that strengthen their ability to take action and achieve what is important to them.'
    
    WHEN 'trust_safety' THEN 
        'Creating a safe, supportive environment that produces ongoing mutual respect and trust. This involves showing genuine concern for the client''s welfare and future, continuously demonstrating personal integrity, honesty, and sincerity. It includes establishing clear agreements and keeping promises.'
    
    WHEN 'direct_communication' THEN 
        'The ability to communicate effectively during coaching sessions using language that has the greatest positive impact on the client. This involves being clear, articulate, and direct in sharing and providing feedback. It includes reframing and articulating to help clients understand from another perspective what they want or are uncertain about.'
    
    WHEN 'managing_progress' THEN 
        'The skill of holding attention on what is important for the client while leaving responsibility with the client to take action. This includes developing the client''s ability to make decisions, address key concerns, and develop themselves. It involves managing progress toward the client''s desired outcomes and holding them accountable for their commitments.'
    
    ELSE description
END
WHERE framework = 'core';

-- Add descriptions for ICF competencies (if they exist)
UPDATE competency_display_names 
SET description = CASE competency_key
    WHEN 'foundation' THEN 
        'Demonstrates ethical practice and embodies a coaching mindset. This includes understanding and consistently applying coaching ethics and standards, developing and maintaining a mindset that is open, curious, flexible, and client-centered.'
    
    WHEN 'co_creating_relationship' THEN 
        'Establishes and maintains agreements, cultivates trust and safety, and maintains presence. This involves partnering with the client to create a safe, supportive environment that allows the client to share freely.'
    
    WHEN 'communicating_effectively' THEN 
        'Listens actively and evokes awareness through powerful questioning and direct communication. This competency focuses on the coach''s ability to be fully present and facilitate client insight and learning.'
    
    WHEN 'facilitating_growth' THEN 
        'Facilitates client growth by establishing the coaching agreement, creating awareness, designing actions, planning and goal setting, and managing progress and accountability.'
    
    ELSE description
END
WHERE framework = 'icf';

-- Add descriptions for AC competencies (if they exist)
UPDATE competency_display_names 
SET description = CASE competency_key
    WHEN 'self_management' THEN 
        'The ability to manage one''s own emotions, thoughts, and behaviors effectively in different situations. This includes managing stress, controlling impulses, and motivating oneself. It encompasses personal awareness and the ability to maintain professional boundaries.'
    
    WHEN 'coaching_understanding' THEN 
        'Deep understanding of coaching principles, theories, and methodologies. This includes knowledge of different coaching approaches, understanding the coaching process, and ability to apply appropriate coaching models and frameworks.'
    
    WHEN 'relationship_building' THEN 
        'The ability to develop and maintain effective coaching relationships. This involves establishing rapport, building trust, demonstrating empathy, and creating a partnership that supports the client''s growth and development.'
    
    WHEN 'effective_communication' THEN 
        'Clear, purposeful communication that facilitates understanding and action. This includes both verbal and non-verbal communication skills, the ability to provide feedback effectively, and skill in using language that resonates with the client.'
    
    ELSE description
END
WHERE framework = 'ac';

-- Verify the update
SELECT 
    competency_key,
    display_name,
    framework,
    LEFT(description, 100) || '...' as description_preview
FROM competency_display_names
WHERE is_active = true
ORDER BY framework, competency_key;

-- Success message
DO $$ 
BEGIN 
    RAISE NOTICE '✅ COMPETENCY DESCRIPTIONS ADDED!';
    RAISE NOTICE '';
    RAISE NOTICE '📝 Updated competency_display_names table with:';
    RAISE NOTICE '   ✓ Detailed descriptions for each competency';
    RAISE NOTICE '   ✓ Framework-specific explanations';
    RAISE NOTICE '   ✓ Ready to display in development areas';
    RAISE NOTICE '';
    RAISE NOTICE '🎯 Frontend can now show rich descriptions instead of previews!';
END $$;