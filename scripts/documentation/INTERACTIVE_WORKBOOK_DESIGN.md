# Interactive Workbook Design Specification

## Overview
Transform the static "Kickstart Coaching Workbook" into an interactive, saveable experience that users can complete over time with optional profile integration.

## Current Workbook Analysis

### Content Structure
- **8 Main Sections** with clear learning progression
- **40+ Interactive Elements** including text fields, checklists, brainstorms
- **Progress Tracking Table** for section completion
- **Mixed Input Types**: Short text, long text, lists, checklists, reflection spaces

### Section Breakdown
1. **What's So Special About YOU?** (8 activities)
2. **Your Ideal Client** (4 activities + quiz)
3. **Creating Your Stand-Out Brand** (5 activities)
4. **Creating Your Avatar** (2 activities)
5. **Product – Price – Value** (4 activities + quiz)
6. **Freemium Product Funnel** (2 activities)
7. **Getting Your Message Out There** (3 activities)
8. **Social Media & Networking** (2 activities)

## Database Schema Design

### Core Tables

```sql
-- User workbook instances
CREATE TABLE workbook_progress (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT now(),
    completed_at TIMESTAMP WITH TIME ZONE NULL,
    is_active BOOLEAN DEFAULT true,
    added_to_profile BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Section progress tracking
CREATE TABLE workbook_sections (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    workbook_id UUID NOT NULL REFERENCES workbook_progress(id) ON DELETE CASCADE,
    section_number INTEGER NOT NULL,
    section_title TEXT NOT NULL,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    completed_at TIMESTAMP WITH TIME ZONE NULL,
    progress_percent INTEGER DEFAULT 0,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Individual field responses
CREATE TABLE workbook_responses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    workbook_id UUID NOT NULL REFERENCES workbook_progress(id) ON DELETE CASCADE,
    section_number INTEGER NOT NULL,
    field_key TEXT NOT NULL, -- e.g., "dinner_party_answer", "skills_list", "taglines"
    field_value JSONB, -- Flexible storage for different input types
    field_type TEXT NOT NULL, -- 'text', 'list', 'checkbox', 'longtext'
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(workbook_id, field_key)
);

-- Pre-defined field structure for each section
CREATE TABLE workbook_field_definitions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    section_number INTEGER NOT NULL,
    field_key TEXT NOT NULL,
    field_label TEXT NOT NULL,
    field_type TEXT NOT NULL, -- 'text', 'textarea', 'list', 'checkbox'
    placeholder_text TEXT,
    sort_order INTEGER DEFAULT 0,
    is_required BOOLEAN DEFAULT false
);
```

### RLS Policies
```sql
-- Users can only access their own workbook data
ALTER TABLE workbook_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE workbook_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE workbook_responses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own workbook progress" 
ON workbook_progress FOR ALL 
TO authenticated 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can manage their own section progress" 
ON workbook_sections FOR ALL 
TO authenticated 
USING (workbook_id IN (SELECT id FROM workbook_progress WHERE user_id = auth.uid()));

CREATE POLICY "Users can manage their own responses" 
ON workbook_responses FOR ALL 
TO authenticated 
USING (workbook_id IN (SELECT id FROM workbook_progress WHERE user_id = auth.uid()));
```

## Vue Component Architecture

### Page Structure
```
/profile/interactive-workbook
├── WorkbookMain.vue (container)
├── components/
│   ├── WorkbookSidebar.vue (progress + navigation)
│   ├── WorkbookSection.vue (section container)
│   ├── inputs/
│   │   ├── TextInput.vue
│   │   ├── TextareaInput.vue
│   │   ├── ListInput.vue
│   │   └── ChecklistInput.vue
│   ├── WorkbookProgress.vue (visual progress indicator)
│   └── WorkbookExport.vue (PDF generation)
```

### Key Features

#### 1. Real-time Auto-save
- **Debounced saving** (500ms delay after typing stops)
- **Visual indicators** for save status (saving/saved/error)
- **Offline support** with local storage backup

#### 2. Section Navigation
- **Progress sidebar** with completion indicators
- **Jump to any section** (completed or current)
- **Next/Previous buttons** within sections
- **Progress breadcrumbs** at top

#### 3. Input Components
- **Smart input types** based on field definitions
- **Auto-expanding textareas** for long-form responses
- **Dynamic list management** (add/remove items)
- **Checkbox state persistence**

#### 4. Profile Integration
- **"Add to Profile" toggle** in workbook settings
- **Profile card component** showing:
  - Progress percentage
  - Last activity date
  - Quick access link
  - Completion status

#### 5. Export & Sharing
- **PDF export** of completed sections
- **Print-friendly** formatted output
- **Progress snapshot** for coaches/supervisors

## User Experience Flow

### 1. Discovery & Access
- **Main workbook page** remains static at `/docs/business/workbook`
- **"Start Interactive Version"** button for authenticated users
- **Login prompt** for anonymous users

### 2. First-time Setup
- **Welcome modal** explaining the interactive features
- **Progress indicator** showing 8 sections
- **Optional profile integration** selection

### 3. Working Sessions
- **Resume where left off** automatic
- **Section completion** celebration micro-animations
- **Regular auto-save** with visual feedback
- **Exit anytime** with progress preserved

### 4. Completion & Beyond
- **Completion certificate** or congratulations
- **PDF export** of entire workbook
- **Option to share** progress with coach/mentor
- **Archive completed workbook** and start fresh

## Technical Implementation Plan

### Phase 1: Database & Backend
1. Create database tables and RLS policies
2. Add field definitions for all 8 sections
3. Create API endpoints for CRUD operations
4. Implement auto-save composable

### Phase 2: Core Vue Components
1. Build main workbook container and routing
2. Create input components with auto-save
3. Implement section navigation and progress tracking
4. Add responsive design for mobile completion

### Phase 3: Profile Integration
1. Add profile workbook card component
2. Implement "Add to Profile" toggle functionality
3. Create workbook management in user dashboard
4. Add privacy controls for workbook visibility

### Phase 4: Export & Enhancement
1. PDF export functionality using existing PDF system
2. Progress analytics and insights
3. Coach/mentor sharing capabilities
4. Workbook templates and customization

## Content Preservation Strategy

### Exact Content Mapping
- **Zero content changes** - all original text preserved
- **Field-by-field mapping** from markdown to database schema
- **Section structure** maintained exactly
- **Progressive disclosure** of content as user advances

### Field Definitions Example
```javascript
const section1Fields = [
  {
    section: 1,
    key: 'dinner_party_answer',
    label: 'The Dinner Party Test',
    type: 'textarea',
    placeholder: 'Write your answer here, or describe your 60-second voice memo...'
  },
  {
    section: 1,
    key: 'skills_brainstorm',
    label: 'My skills (apart from coaching)',
    type: 'list',
    placeholder: 'Add a skill...'
  },
  {
    section: 1,
    key: 'friend_feedback',
    label: 'What do you think I\'m best at? (Ask a friend)',
    type: 'text',
    placeholder: 'Their answer...'
  }
  // ... all fields defined
]
```

## Success Metrics

### User Engagement
- **Completion rate** per section
- **Return sessions** and time between visits
- **Total time spent** in workbook
- **Profile integration** adoption rate

### Content Quality
- **Export/download** frequency of completed workbooks
- **Sharing activity** with coaches/mentors
- **User feedback** on interactive vs static experience

### Technical Performance
- **Auto-save success** rate
- **Page load times** for workbook sections
- **Mobile completion** rates
- **Data persistence** reliability

This interactive workbook will transform a static learning resource into a personalized, progressive coaching business development tool that users can complete at their own pace while maintaining all the valuable content and structure of the original.