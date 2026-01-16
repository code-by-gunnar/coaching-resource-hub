# Database Schema Documentation - Coaching Resource Hub

## Overview

This document provides comprehensive documentation of the PostgreSQL database schema for the Coaching Resource Hub assessment system. The schema is designed for multi-level coaching assessments with normalized data storage and optimized performance.

**Database Engine**: PostgreSQL 15+  
**Architecture**: Supabase-hosted with Row Level Security  
**Schema Version**: 2.0 - Multi-level assessment architecture  
**Production Ready**: Core I Assessment System  

---

## Schema Architecture Principles

### 1. Normalized Data Design
- No hardcoded content in application code
- All text content stored in database tables
- Referential integrity enforced with foreign keys
- Efficient querying with proper indexing

### 2. Multi-Framework Support  
- Framework column distinguishes CORE, ICF, AC assessments
- Assessment level column enables I/II/III progression
- Extensible design for future assessment types
- Consistent data structure across all frameworks

### 3. Performance Optimization
- Strategic indexing on frequently queried columns
- Efficient JOIN patterns for complex queries
- Minimal data duplication with normalized structure
- Optimized for frontend caching strategies

---

## Core Tables

### assessments
**Purpose**: Define available coaching assessments  
**Relationships**: Parent to assessment_questions and user_attempts

```sql
CREATE TABLE assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    description TEXT,
    difficulty TEXT CHECK (difficulty IN ('Beginner', 'Intermediate', 'Advanced')),
    estimated_duration INTEGER, -- minutes
    framework TEXT NOT NULL CHECK (framework IN ('core', 'icf', 'ac')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Indexes**:
- `PRIMARY KEY (id)`
- `UNIQUE INDEX (slug)`
- `INDEX idx_assessments_framework ON assessments(framework)`
- `INDEX idx_assessments_active ON assessments(is_active)`

**Sample Data**:
```sql
id: 00000000-0000-0000-0000-000000000001
slug: core-fundamentals-i
title: CORE I - Fundamentals  
framework: core
difficulty: Beginner
estimated_duration: 20
```

### assessment_questions
**Purpose**: Store assessment questions with answer options  
**Relationships**: Child of assessments, referenced by user_responses

```sql
CREATE TABLE assessment_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_id UUID NOT NULL REFERENCES assessments(id) ON DELETE CASCADE,
    question_order INTEGER NOT NULL,
    question TEXT NOT NULL,
    option_a TEXT NOT NULL,
    option_b TEXT NOT NULL, 
    option_c TEXT NOT NULL,
    option_d TEXT NOT NULL,
    correct_answer INTEGER NOT NULL CHECK (correct_answer IN (0, 1, 2, 3)),
    explanation TEXT NOT NULL,
    competency_area TEXT NOT NULL,
    difficulty_weight DECIMAL DEFAULT 1.0,
    assessment_level TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Constraints**:
```sql
ALTER TABLE assessment_questions 
ADD CONSTRAINT assessment_questions_level_check 
CHECK (assessment_level IN ('core-i', 'core-ii', 'core-iii', 'icf-i', 'icf-ii', 'icf-iii', 'ac-i', 'ac-ii', 'ac-iii'));
```

**Indexes**:
- `PRIMARY KEY (id)`
- `INDEX idx_assessment_questions_assessment_id ON assessment_questions(assessment_id)`
- `INDEX idx_assessment_questions_order ON assessment_questions(assessment_id, question_order)`
- `INDEX idx_assessment_questions_competency ON assessment_questions(competency_area)`
- `INDEX idx_assessment_questions_level ON assessment_questions(assessment_level)`

### user_attempts
**Purpose**: Track user assessment attempts and scores  
**Relationships**: Child of assessments, parent to user_responses

```sql
CREATE TABLE user_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    assessment_id UUID NOT NULL REFERENCES assessments(id) ON DELETE CASCADE,
    score INTEGER NOT NULL CHECK (score >= 0 AND score <= 100),
    time_spent INTEGER, -- seconds
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Store frontend insights for performance (JSONB for complex queries)
    frontend_insights JSONB,
    insights_generated_at TIMESTAMP WITH TIME ZONE
);
```

**Indexes**:
- `PRIMARY KEY (id)`
- `INDEX idx_user_attempts_user_id ON user_attempts(user_id)`
- `INDEX idx_user_attempts_assessment_id ON user_attempts(assessment_id)`
- `INDEX idx_user_attempts_completed ON user_attempts(completed_at DESC)`
- `INDEX idx_user_attempts_score ON user_attempts(score)`
- `INDEX idx_user_attempts_insights ON user_attempts USING GIN(frontend_insights)`

### user_responses  
**Purpose**: Store individual question responses from users  
**Relationships**: Child of user_attempts and assessment_questions

```sql
CREATE TABLE user_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attempt_id UUID NOT NULL REFERENCES user_attempts(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES assessment_questions(id) ON DELETE CASCADE,
    selected_answer INTEGER NOT NULL CHECK (selected_answer IN (0, 1, 2, 3)),
    is_correct BOOLEAN NOT NULL,
    response_time INTEGER, -- seconds
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Indexes**:
- `PRIMARY KEY (id)`
- `INDEX idx_user_responses_attempt_id ON user_responses(attempt_id)`
- `INDEX idx_user_responses_question_id ON user_responses(question_id)`
- `INDEX idx_user_responses_correct ON user_responses(is_correct)`

---

## Skill & Competency Tables

### skill_tags
**Purpose**: Define coaching skills within competency areas  
**Relationships**: Referenced by tag_insights and tag_actions

```sql
CREATE TABLE skill_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    competency_area TEXT NOT NULL,
    framework TEXT NOT NULL CHECK (framework IN ('core', 'icf', 'ac')),
    sort_order INTEGER DEFAULT 0,
    assessment_level TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(name, competency_area, framework, assessment_level)
);
```

**Constraints**:
```sql
ALTER TABLE skill_tags
ADD CONSTRAINT skill_tags_level_check 
CHECK (assessment_level IN ('core-i', 'core-ii', 'core-iii', 'icf-i', 'icf-ii', 'icf-iii', 'ac-i', 'ac-ii', 'ac-iii'));
```

**Indexes**:
- `PRIMARY KEY (id)`
- `UNIQUE INDEX skill_tags_unique ON skill_tags(name, competency_area, framework, assessment_level)`
- `INDEX idx_skill_tags_framework_level ON skill_tags(framework, assessment_level)`
- `INDEX idx_skill_tags_competency ON skill_tags(competency_area)`
- `INDEX idx_skill_tags_active ON skill_tags(is_active)`

### tag_insights
**Purpose**: Store personalized insights for each skill tag  
**Relationships**: Child of skill_tags

```sql  
CREATE TABLE tag_insights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    skill_tag_id UUID NOT NULL REFERENCES skill_tags(id) ON DELETE CASCADE,
    insight_text TEXT NOT NULL,
    insight_type TEXT NOT NULL CHECK (insight_type IN ('weakness', 'strength')),
    context_level TEXT DEFAULT 'beginner',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(skill_tag_id, insight_type, context_level)
);
```

**Indexes**:
- `PRIMARY KEY (id)`
- `INDEX idx_tag_insights_skill_tag ON tag_insights(skill_tag_id)`
- `INDEX idx_tag_insights_type ON tag_insights(insight_type)`
- `UNIQUE INDEX tag_insights_unique ON tag_insights(skill_tag_id, insight_type, context_level)`

### tag_actions
**Purpose**: Store actionable development steps for each skill  
**Relationships**: Child of skill_tags

```sql
CREATE TABLE tag_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    skill_tag_id UUID NOT NULL REFERENCES skill_tags(id) ON DELETE CASCADE,
    action_text TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(skill_tag_id) -- One action per skill tag
);
```

**Indexes**:
- `PRIMARY KEY (id)`
- `INDEX idx_tag_actions_skill_tag ON tag_actions(skill_tag_id)`
- `INDEX idx_tag_actions_active ON tag_actions(is_active)`
- `UNIQUE INDEX tag_actions_unique ON tag_actions(skill_tag_id)`

### competency_display_names
**Purpose**: Map competency keys to user-friendly display names  
**Relationships**: Referenced by frontend for competency naming

```sql
CREATE TABLE competency_display_names (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    competency_key TEXT NOT NULL, -- lowercase_with_underscores
    display_name TEXT NOT NULL,   -- User-friendly name
    framework TEXT NOT NULL CHECK (framework IN ('core', 'icf', 'ac')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(competency_key, framework)
);
```

**Indexes**:
- `PRIMARY KEY (id)`
- `UNIQUE INDEX competency_display_names_unique ON competency_display_names(competency_key, framework)`
- `INDEX idx_competency_display_names_framework ON competency_display_names(framework)`

**Sample Data**:
```sql
competency_key: active_listening
display_name: Active Listening
framework: core

competency_key: powerful_questions  
display_name: Powerful Questions
framework: core
```

### competency_leverage_strengths
**Purpose**: Store strength leverage messages for competencies  
**Relationships**: Referenced by frontend for strength insights

```sql
CREATE TABLE competency_leverage_strengths (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    competency_area TEXT NOT NULL,
    leverage_text TEXT NOT NULL,
    score_range_min INTEGER DEFAULT 0,
    score_range_max INTEGER DEFAULT 100,
    framework TEXT NOT NULL CHECK (framework IN ('core', 'icf', 'ac')),
    context_level TEXT DEFAULT 'beginner',
    priority_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Indexes**:
- `PRIMARY KEY (id)`
- `INDEX idx_competency_leverage_strengths_area ON competency_leverage_strengths(competency_area)`
- `INDEX idx_competency_leverage_strengths_framework ON competency_leverage_strengths(framework)`
- `INDEX idx_competency_leverage_strengths_score ON competency_leverage_strengths(score_range_min, score_range_max)`

---

## Learning Resources Tables

### learning_path_categories
**Purpose**: Group learning resources into competency-focused categories  
**Relationships**: Parent to learning_resources

```sql
CREATE TABLE learning_path_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_title TEXT NOT NULL,
    category_description TEXT,
    category_icon TEXT, -- Emoji or icon identifier
    competency_areas TEXT[], -- Array of competency areas this category addresses
    assessment_level TEXT,
    priority_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Indexes**:
- `PRIMARY KEY (id)`
- `INDEX idx_learning_path_categories_level ON learning_path_categories(assessment_level)`
- `INDEX idx_learning_path_categories_active ON learning_path_categories(is_active)`
- `INDEX idx_learning_path_categories_competency ON learning_path_categories USING GIN(competency_areas)`

### learning_resources
**Purpose**: Store individual learning resources with metadata  
**Relationships**: Child of learning_path_categories

```sql
CREATE TABLE learning_resources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES learning_path_categories(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    resource_type TEXT NOT NULL CHECK (resource_type IN ('book', 'course', 'video', 'article', 'exercise', 'workshop', 'tool', 'assessment')),
    url TEXT, -- Direct link to resource
    author_instructor TEXT,
    competency_areas TEXT[], -- Specific competencies this resource addresses
    assessment_level TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Indexes**:
- `PRIMARY KEY (id)`
- `INDEX idx_learning_resources_category ON learning_resources(category_id)`
- `INDEX idx_learning_resources_type ON learning_resources(resource_type)`
- `INDEX idx_learning_resources_level ON learning_resources(assessment_level)`
- `INDEX idx_learning_resources_active ON learning_resources(is_active)`
- `INDEX idx_learning_resources_competency ON learning_resources USING GIN(competency_areas)`

---

## Database Functions

### get_learning_paths_for_assessment
**Purpose**: Dynamic learning resource recommendations based on weak competencies  
**Usage**: Called by frontend to generate personalized learning paths

```sql
CREATE OR REPLACE FUNCTION get_learning_paths_for_assessment(
    weak_competency_areas text[],
    overall_score integer
)
RETURNS TABLE (
    category_id uuid,
    category_title text,
    category_description text,
    category_icon text,
    resources json[]
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        lpc.id as category_id,
        lpc.category_title,
        lpc.category_description,
        lpc.category_icon,
        ARRAY(
            SELECT json_build_object(
                'title', lr.title,
                'description', lr.description,
                'resource_type', lr.resource_type,
                'url', lr.url,
                'author', lr.author_instructor,
                'competency_areas', lr.competency_areas
            )
            FROM learning_resources lr
            WHERE lr.category_id = lpc.id
            AND lr.is_active = true
            ORDER BY lr.resource_type, lr.title
        ) as resources
    FROM learning_path_categories lpc
    WHERE lpc.is_active = true
    AND lpc.assessment_level = 'core-i'
    -- Only show categories where competency areas overlap with weak areas
    AND lpc.competency_areas && weak_competency_areas
    ORDER BY lpc.priority_order, lpc.category_title;
END;
$$;
```

### store_frontend_insights
**Purpose**: Store frontend-generated insights for performance optimization  
**Usage**: Called after assessment completion to cache personalized insights

```sql
CREATE OR REPLACE FUNCTION store_frontend_insights(
    attempt_uuid UUID,
    frontend_insights JSONB
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE user_attempts 
    SET 
        frontend_insights = frontend_insights,
        insights_generated_at = NOW()
    WHERE id = attempt_uuid;
    
    RETURN FOUND;
END;
$$;
```

---

## Relationship Diagram

```
                    auth.users
                         |
                         | (1:M)
                         |
    assessments ────────user_attempts
         |                   |
         | (1:M)             | (1:M)
         |                   |
    assessment_questions ────user_responses
         |
         | (references competency_area)
         |
    skill_tags ──────────┬── tag_insights
         |               |
         | (1:1)         | (1:2)
         |               |
    tag_actions          └── (weakness/strength)

    competency_display_names (lookup table)
         |
         | (referenced by frontend)
         |
    competency_leverage_strengths

    learning_path_categories
         |
         | (1:M)
         |
    learning_resources
```

## Data Flow Patterns

### Assessment Completion Flow
```sql
1. User selects assessment → assessments table
2. Questions loaded → assessment_questions table  
3. Responses recorded → user_responses table
4. Attempt completed → user_attempts table
5. Insights generated → skill_tags + tag_insights + tag_actions
6. Learning paths → learning_path_categories + learning_resources
7. Frontend insights cached → user_attempts.frontend_insights
```

### Competency Analysis Flow
```sql
1. Load competency mappings → competency_display_names
2. Get skill tags → skill_tags (filtered by framework + level)
3. Fetch insights → tag_insights (weakness/strength types)
4. Get actions → tag_actions (actionable development steps)
5. Load strengths → competency_leverage_strengths (for high scores)
6. Generate learning paths → get_learning_paths_for_assessment()
```

---

## Security Implementation

### Row Level Security (RLS) Policies

**user_attempts table**:
```sql
-- Users can only see their own attempts
CREATE POLICY "Users can only see their own attempts" 
ON user_attempts FOR SELECT 
TO authenticated 
USING (user_id = auth.uid());

-- Users can only insert their own attempts
CREATE POLICY "Users can only insert their own attempts"
ON user_attempts FOR INSERT 
TO authenticated 
WITH CHECK (user_id = auth.uid());
```

**user_responses table**:
```sql
-- Users can only see responses from their attempts
CREATE POLICY "Users can only see their own responses"
ON user_responses FOR SELECT
TO authenticated
USING (
    attempt_id IN (
        SELECT id FROM user_attempts WHERE user_id = auth.uid()
    )
);

-- Users can only insert responses to their attempts  
CREATE POLICY "Users can only insert responses to their attempts"
ON user_responses FOR INSERT
TO authenticated
WITH CHECK (
    attempt_id IN (
        SELECT id FROM user_attempts WHERE user_id = auth.uid()
    )
);
```

**Public read access for reference tables**:
```sql
-- Assessment content is publicly readable
CREATE POLICY "Assessment content is publicly readable"
ON assessments FOR SELECT
TO authenticated
USING (is_active = true);

-- Similar policies for: assessment_questions, skill_tags, tag_insights, 
-- tag_actions, competency_display_names, learning_path_categories, learning_resources
```

---

## Performance Considerations

### Query Optimization Strategies

1. **Strategic Indexing**: All frequently queried columns have appropriate indexes
2. **Efficient JOINs**: Foreign key relationships optimized for common query patterns
3. **GIN Indexes**: Array columns (competency_areas) use GIN indexes for overlap queries
4. **Selective Queries**: Assessment level and framework filtering reduces result sets
5. **JSONB Storage**: Frontend insights stored as JSONB for complex queries when needed

### Caching Strategy

1. **Global Frontend Cache**: Static data (skill_tags, insights, actions) cached in application
2. **Database Functions**: Complex queries encapsulated in functions for reusability  
3. **Materialized Insights**: User-specific insights cached in user_attempts.frontend_insights
4. **Efficient Loading**: Single queries load related data to minimize database round trips

### Scalability Design

1. **Horizontal Scaling**: Framework and assessment_level columns enable independent scaling
2. **Data Partitioning**: Large tables can be partitioned by framework or date if needed
3. **Archive Strategy**: Older user_attempts can be archived without affecting active data
4. **Connection Pooling**: Supabase handles automatic connection pooling and scaling

---

## Maintenance Procedures

### Regular Maintenance Tasks

1. **Index Maintenance**: Monitor and rebuild indexes as data grows
2. **Statistics Updates**: Keep PostgreSQL statistics current for optimal query planning
3. **Cleanup Procedures**: Remove orphaned data and maintain referential integrity
4. **Performance Monitoring**: Track slow queries and optimize as needed

### Data Integrity Checks

```sql
-- Verify all assessments have questions
SELECT a.title, COUNT(aq.id) as question_count
FROM assessments a
LEFT JOIN assessment_questions aq ON a.id = aq.assessment_id
WHERE a.is_active = true
GROUP BY a.id, a.title
HAVING COUNT(aq.id) = 0;

-- Verify all skill tags have insights and actions
SELECT st.name, st.competency_area,
       COUNT(ti.id) as insights_count,
       COUNT(ta.id) as actions_count
FROM skill_tags st
LEFT JOIN tag_insights ti ON st.id = ti.skill_tag_id
LEFT JOIN tag_actions ta ON st.id = ta.skill_tag_id
WHERE st.is_active = true
GROUP BY st.id, st.name, st.competency_area
HAVING COUNT(ti.id) < 2 OR COUNT(ta.id) = 0;

-- Verify learning resources have valid URLs
SELECT lr.title, lr.url
FROM learning_resources lr
WHERE lr.is_active = true
AND (lr.url IS NULL OR lr.url = '');
```

### Backup and Recovery

1. **Automated Backups**: Supabase provides automated daily backups
2. **Point-in-time Recovery**: Available for data restoration to specific timestamps
3. **Export Procedures**: Critical data can be exported for additional backup security
4. **Disaster Recovery**: Complete schema and data restoration procedures documented

---

## Development Guidelines

### Adding New Assessments

1. **Follow Multi-Level Pattern**: Use assessment_level column for new frameworks
2. **Maintain Relationships**: Ensure all foreign key relationships are properly established
3. **Update Constraints**: Add new assessment levels to CHECK constraints
4. **Create Indexes**: Add appropriate indexes for new assessment query patterns

### Schema Changes

1. **Migration Scripts**: All schema changes must have corresponding migration scripts
2. **Backward Compatibility**: Ensure changes don't break existing functionality
3. **Data Migration**: Include data migration procedures for structural changes
4. **Testing**: Thoroughly test schema changes in development before production

### Performance Guidelines  

1. **Index Strategy**: Add indexes for new query patterns, remove unused indexes
2. **Query Analysis**: Use EXPLAIN ANALYZE to optimize complex queries
3. **Data Types**: Choose appropriate data types for optimal storage and performance
4. **Normalization**: Maintain normalized structure while optimizing for common queries

---

## Current Schema Status

### Production Ready (Core I)
- ✅ All tables created and indexed
- ✅ Complete data population for Core I assessment
- ✅ Row Level Security policies active
- ✅ Database functions implemented and tested
- ✅ Performance optimizations in place

### Future Development
- 🚧 Core II/III assessment tables (schema ready, data pending)
- 🚧 ICF framework assessment data (schema ready, data pending)  
- 🚧 AC framework assessment data (schema ready, data pending)
- 🚧 Advanced analytics tables (future enhancement)

---

## Summary

This database schema provides a robust, scalable foundation for the Coaching Resource Hub assessment system. The normalized design eliminates hardcoded content while maintaining excellent performance through strategic indexing and caching. The multi-level architecture supports expansion to 9 total assessment types while maintaining data consistency and referential integrity.

**Key Strengths**:
- Normalized design prevents data duplication
- Multi-framework architecture supports unlimited expansion
- Performance optimized with strategic indexing
- Security-first design with comprehensive RLS policies
- Production-ready with complete Core I implementation

**Scalability Features**:
- Framework and assessment_level columns enable independent scaling
- Efficient query patterns minimize database load
- JSONB storage for complex personalized data when needed
- Function-based architecture for reusable complex queries

---

*Schema Documentation Version: 2.0*  
*Last Updated: January 2025*  
*Production Status: Core I Assessment System Ready*