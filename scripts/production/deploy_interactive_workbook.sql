-- =====================================================
-- INTERACTIVE WORKBOOK SYSTEM - PRODUCTION DEPLOYMENT
-- =====================================================
-- This script deploys the complete interactive workbook system to production
-- Run this script manually in the production database
-- Date: 2025-08-17
-- =====================================================

-- STEP 1: Create core workbook tables
-- =====================================================

-- Table: workbook_progress (main workbook instances)
CREATE TABLE IF NOT EXISTS workbook_progress (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT now(),
    completed_at TIMESTAMP WITH TIME ZONE NULL,
    is_active BOOLEAN DEFAULT true,
    added_to_profile BOOLEAN DEFAULT false,
    title TEXT DEFAULT 'Kickstart Coaching Workbook',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Table: workbook_sections (section progress tracking)
CREATE TABLE IF NOT EXISTS workbook_sections (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    workbook_id UUID NOT NULL REFERENCES workbook_progress(id) ON DELETE CASCADE,
    section_number INTEGER NOT NULL,
    section_title TEXT NOT NULL,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    completed_at TIMESTAMP WITH TIME ZONE NULL,
    progress_percent INTEGER DEFAULT 0 CHECK (progress_percent >= 0 AND progress_percent <= 100),
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Table: workbook_responses (individual field responses)
CREATE TABLE IF NOT EXISTS workbook_responses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    workbook_id UUID NOT NULL REFERENCES workbook_progress(id) ON DELETE CASCADE,
    section_number INTEGER NOT NULL,
    field_key TEXT NOT NULL,
    field_value JSONB,
    field_type TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(workbook_id, field_key)
);

-- Table: workbook_field_definitions (field structure and metadata)
CREATE TABLE IF NOT EXISTS workbook_field_definitions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    section_number INTEGER NOT NULL,
    field_key TEXT UNIQUE NOT NULL,
    field_label TEXT NOT NULL,
    field_type TEXT NOT NULL,
    placeholder_text TEXT,
    instructions TEXT,
    is_required BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- STEP 2: Add indexes for performance
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_workbook_progress_user_id ON workbook_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_workbook_sections_workbook_id ON workbook_sections(workbook_id);
CREATE INDEX IF NOT EXISTS idx_workbook_sections_number ON workbook_sections(workbook_id, section_number);
CREATE INDEX IF NOT EXISTS idx_workbook_responses_workbook_id ON workbook_responses(workbook_id);
CREATE INDEX IF NOT EXISTS idx_workbook_responses_field ON workbook_responses(workbook_id, field_key);
CREATE INDEX IF NOT EXISTS idx_workbook_field_definitions_section ON workbook_field_definitions(section_number);

-- STEP 3: Enable Row Level Security
-- =====================================================

ALTER TABLE workbook_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE workbook_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE workbook_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE workbook_field_definitions ENABLE ROW LEVEL SECURITY;

-- STEP 4: Create RLS Policies
-- =====================================================

-- Workbook Progress policies
CREATE POLICY "Users can manage their own workbooks"
    ON workbook_progress FOR ALL
    TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Workbook Sections policies  
CREATE POLICY "Users can manage their own section progress"
    ON workbook_sections FOR ALL
    TO authenticated
    USING (workbook_id IN (
        SELECT id FROM workbook_progress WHERE user_id = auth.uid()
    ));

-- Workbook Responses policies
CREATE POLICY "Users can manage their own responses"
    ON workbook_responses FOR ALL
    TO authenticated
    USING (workbook_id IN (
        SELECT id FROM workbook_progress WHERE user_id = auth.uid()
    ));

-- Field Definitions policies (read-only for all authenticated users)
CREATE POLICY "Field definitions are readable by authenticated users"
    ON workbook_field_definitions FOR SELECT
    TO authenticated
    USING (true);

-- STEP 5: Insert field definitions for all sections
-- =====================================================

INSERT INTO workbook_field_definitions (section_number, field_key, field_label, field_type, placeholder_text, instructions, is_required, sort_order) VALUES
-- Section 1: What's So Special About YOU? (Part A)
(1, 'quickstart_checklist_1', 'Quick-Start Checklist for Section 1A', 'list', NULL, 'Complete these initial self-discovery tasks', false, 1),
(1, 'dinner_party_answer', 'The Dinner Party Test', 'textarea', 'Write your answer or record a 60-second voice memo', 'Imagine you''re at a dinner party. Someone asks, "So, what do you do?" - What''s your answer?', false, 2),
(1, 'skills_brainstorm', 'My skills (apart from coaching)', 'list', 'Add a skill', 'Set a timer for 2 minutes and list as many skills as you can', false, 3),
(1, 'friend_feedback', 'What do you think I''m best at? (Ask a friend)', 'textarea', 'Their answer...', 'Get an outside perspective on your strengths', false, 4),

-- Section 2: What's So Special About YOU? (Part B)
(2, 'experience_inventory', 'Specific life or work experiences to bring into coaching', 'list', 'Add an experience', 'What experiences have shaped your perspective?', false, 5),
(2, 'awards_qualifications', 'Awards & Qualifications', 'list', 'Add award or qualification', 'Any relevant awards, certifications, or training', false, 6),
(2, 'what_fires_you_up', 'What Fires You Up?', 'textarea', 'What causes excite you? Who inspires you?', 'What causes or social missions excite you? Are you supporting any charities?', false, 7),
(2, 'future_self_letter', 'Letter to Future Self', 'textarea', 'I''m proud of the impact I made on...', 'Write a letter to your future self about the impact you want to make', false, 8),
(2, 'section1b_reflection', 'Section 1B Reflection', 'textarea', 'What insights did you gain about yourself in this deeper exploration?', 'Reflect on your discoveries about your experiences, qualifications, passions, and future vision', false, 9),
(2, 'quickstart_checklist_2', 'Quick-Start Checklist for Section 1B', 'list', NULL, 'Complete these key reflection exercises', false, 10),

-- Section 3: Your Ideal Client
(3, 'quickstart_checklist_3', 'Quick-Start Checklist for Section 3', 'list', NULL, 'Key steps to identify your ideal client', false, 1),
(3, 'ideal_client_description', 'Describe Your Ideal Client', 'textarea', 'What do they look like? What are they worried about?', 'Imagine your ideal client is sitting across from you', false, 2),
(3, 'client_transformation', 'The Transformation', 'textarea', 'From feeling... To feeling...', 'What transformation do you help them achieve?', false, 3),
(3, 'client_objections', 'Common Objections', 'list', 'Add an objection', 'What stops them from working with you?', false, 4),
(3, 'section3_reflection', 'Reflection Space', 'textarea', 'Your insights about your ideal client...', 'How clear is your ideal client profile now?', false, 5),

-- Section 4: Creating Your Stand-Out Brand
(4, 'quickstart_checklist_4', 'Quick-Start Checklist for Section 4', 'list', NULL, 'Essential branding tasks', false, 1),
(4, 'brand_name', 'Your Brand Name', 'text', 'Your name or company name', 'Will you use your own name or create a company name?', false, 2),
(4, 'tagline', 'Your Tagline', 'text', 'Your memorable tagline', 'Even if it''s silly at first - write something memorable', false, 3),
(4, 'mission_values', 'Mission and Values', 'textarea', 'What you stand for...', 'Write your mission statement and core values', false, 4),
(4, 'section4_reflection', 'Brand Clarity Check', 'textarea', 'How does your brand feel?', 'Is your brand starting to feel more real?', false, 5),

-- Section 5: Creating Your Avatar
(5, 'quickstart_checklist_5', 'Quick-Start Checklist for Section 5', 'list', NULL, 'Avatar creation steps', false, 1),
(5, 'avatar_choice', 'Avatar Image or Logo', 'text', 'Describe your choice', 'Choose a personal, relevant image or logo', false, 2),
(5, 'avatar_consistency', 'Consistency Plan', 'textarea', 'Where will you use it?', 'How will you ensure it matches your brand everywhere?', false, 3),
(5, 'section5_reflection', 'Visual Identity Check', 'textarea', 'Your thoughts on your visual identity...', 'Does your avatar represent you well?', false, 4),

-- Section 6: Product • Price • Value
(6, 'quickstart_checklist_6', 'Quick-Start Checklist for Section 6', 'list', NULL, 'Product and pricing decisions', false, 1),
(6, 'delivery_model', 'Session-based or Program-based?', 'text', 'Your choice and why', 'Decide on your delivery model', false, 2),
(6, 'pros_cons', 'Pros and Cons', 'textarea', 'List 2 pros and cons for each model', 'Compare both approaches', false, 3),
(6, 'unique_program', 'Your Unique Program Idea', 'textarea', 'Describe your signature offering', 'What makes your program special?', false, 4),
(6, 'section6_reflection', 'Product Strategy', 'textarea', 'Your thoughts on your offering...', 'How confident are you in your product strategy?', false, 5),

-- Section 7: Freemium Product Funnel
(7, 'quickstart_checklist_7', 'Quick-Start Checklist for Section 7', 'list', NULL, 'Funnel creation steps', false, 1),
(7, 'platinum_client', 'Your Platinum Client', 'textarea', 'Define your highest-tier client', 'Who is your ideal, highest-paying client?', false, 2),
(7, 'freemium_product', 'Freemium Product Idea', 'textarea', 'Your free offering...', 'What valuable content can you give away?', false, 3),
(7, 'warmup_product', 'Warm-up Product Idea', 'textarea', 'Your entry-level paid offering...', 'What''s your first paid stepping stone?', false, 4),
(7, 'section7_reflection', 'Funnel Assessment', 'textarea', 'Your thoughts on your funnel...', 'Is your product funnel taking shape?', false, 5),

-- Section 8: Getting Your Message Out There
(8, 'quickstart_checklist_8', 'Quick-Start Checklist for Section 8', 'list', NULL, 'Marketing action items', false, 1),
(8, 'website_actions', '5 Actions to Improve Your Website', 'list', 'Add an action', 'List 5 specific improvements you''ll make', false, 2),
(8, 'testimonials_plan', 'Testimonials Collection Plan', 'textarea', 'How will you gather testimonials?', 'Your strategy for collecting social proof', false, 3),
(8, 'google_business', 'Google My Business Setup', 'checkbox', NULL, 'Have you set up Google My Business?', false, 4),
(8, 'section8_reflection', 'Marketing Confidence', 'textarea', 'Your thoughts on marketing...', 'How ready are you to market yourself?', false, 5),

-- Section 9: Social Media & Networking
(9, 'quickstart_checklist_9', 'Quick-Start Checklist for Section 9', 'list', NULL, 'Social media strategy steps', false, 1),
(9, 'top_platforms', 'Your Top 2 Social Platforms', 'list', 'Add platform', 'Identify where your clients hang out', false, 2),
(9, 'engagement_ways', '3 Ways to Engage Your Audience', 'list', 'Add engagement method', 'How will you connect with followers?', false, 3),
(9, 'first_networking', 'Your First Networking Event', 'text', 'Event name and date', 'Plan your first networking opportunity', false, 4),
(9, 'section9_reflection', 'Social Strategy Assessment', 'textarea', 'Your social media confidence...', 'Are you ready to be visible online?', false, 5);

-- STEP 6: Create helper functions
-- =====================================================

-- Function to get or create user workbook
CREATE OR REPLACE FUNCTION get_or_create_user_workbook(p_user_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_workbook_id UUID;
BEGIN
    -- Check if user has an active workbook
    SELECT id INTO v_workbook_id
    FROM workbook_progress
    WHERE user_id = p_user_id AND is_active = true
    LIMIT 1;
    
    -- If not, create one
    IF v_workbook_id IS NULL THEN
        INSERT INTO workbook_progress (user_id)
        VALUES (p_user_id)
        RETURNING id INTO v_workbook_id;
        
        -- Initialize all 9 sections with proper numbering
        INSERT INTO workbook_sections (workbook_id, section_number, section_title)
        VALUES 
            (v_workbook_id, 1, 'What''s So Special About YOU? (Part A)'),
            (v_workbook_id, 2, 'What''s So Special About YOU? (Part B)'),
            (v_workbook_id, 3, 'Your Ideal Client'),
            (v_workbook_id, 4, 'Creating Your Stand-Out Brand'),
            (v_workbook_id, 5, 'Creating Your Avatar'),
            (v_workbook_id, 6, 'Product • Price • Value'),
            (v_workbook_id, 7, 'Freemium Product Funnel'),
            (v_workbook_id, 8, 'Getting Your Message Out There'),
            (v_workbook_id, 9, 'Social Media & Networking');
    END IF;
    
    RETURN v_workbook_id;
END;
$$;

-- Function to calculate section progress
CREATE OR REPLACE FUNCTION calculate_section_progress(p_workbook_id UUID, p_section_number INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_fields INTEGER;
    v_completed_fields INTEGER;
    v_progress INTEGER;
BEGIN
    -- Count total required fields for this section
    SELECT COUNT(*) INTO v_total_fields
    FROM workbook_field_definitions
    WHERE section_number = p_section_number
    AND is_required = true;
    
    -- If no required fields, check any fields
    IF v_total_fields = 0 THEN
        SELECT COUNT(*) INTO v_total_fields
        FROM workbook_field_definitions
        WHERE section_number = p_section_number;
    END IF;
    
    -- Count completed fields
    SELECT COUNT(*) INTO v_completed_fields
    FROM workbook_responses r
    JOIN workbook_field_definitions d ON r.field_key = d.field_key
    WHERE r.workbook_id = p_workbook_id
    AND d.section_number = p_section_number
    AND r.field_value IS NOT NULL
    AND (
        (r.field_type = 'text' AND length(r.field_value->>'value') > 0) OR
        (r.field_type = 'textarea' AND length(r.field_value->>'value') > 0) OR
        (r.field_type = 'list' AND jsonb_array_length(r.field_value->'items') > 0) OR
        (r.field_type = 'checkbox' AND (r.field_value->>'checked')::boolean = true)
    );
    
    -- Calculate percentage
    IF v_total_fields > 0 THEN
        v_progress := ROUND((v_completed_fields::NUMERIC / v_total_fields) * 100);
    ELSE
        v_progress := 0;
    END IF;
    
    -- Update section progress
    UPDATE workbook_sections
    SET progress_percent = v_progress,
        last_updated = now(),
        completed_at = CASE WHEN v_progress = 100 THEN now() ELSE NULL END
    WHERE workbook_id = p_workbook_id AND section_number = p_section_number;
    
    RETURN v_progress;
END;
$$;

-- STEP 7: Create update trigger for workbook_progress
-- =====================================================

CREATE OR REPLACE FUNCTION update_workbook_progress_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS update_workbook_progress_last_updated ON workbook_progress;

CREATE TRIGGER update_workbook_progress_last_updated
    BEFORE UPDATE ON workbook_progress
    FOR EACH ROW
    EXECUTE FUNCTION update_workbook_progress_timestamp();

-- STEP 8: Create update trigger for workbook_responses with DELETE handling
-- =====================================================

CREATE OR REPLACE FUNCTION update_workbook_response_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    -- Only update timestamp on INSERT or UPDATE, not DELETE
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        NEW.updated_at = now();
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS update_workbook_response_updated_at ON workbook_responses;

CREATE TRIGGER update_workbook_response_updated_at
    BEFORE INSERT OR UPDATE OR DELETE ON workbook_responses
    FOR EACH ROW
    EXECUTE FUNCTION update_workbook_response_timestamp();

-- =====================================================
-- DEPLOYMENT COMPLETE
-- =====================================================
-- The interactive workbook system is now ready for use
-- Users can access it at /docs/profile/interactive-workbook
-- =====================================================