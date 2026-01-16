# AI-Generated Assessment Reports Design

**Date:** 2026-01-16
**Status:** Approved
**Author:** Claude + User collaboration

---

## Problem Statement

The current assessment system requires massive content maintenance:
- 80+ SQL scripts for content population
- 13+ content tables per assessment (strategic actions, skill tags, learning resources, etc.)
- 9 assessment variations to maintain (3 frameworks × 3 levels)
- Complex multi-table joins with FK relationships, score tiers, analysis types

This maintenance burden caused the project to be parked for months.

Additionally, current reports are generic:
- Score-bucket generalization (65% in Active Listening = same content for everyone at 65%)
- No pattern recognition (can't see *which* questions were missed within a competency)
- No cross-competency insights (can't connect strengths to development areas)
- Templated tone (form letters, not personalized coaching feedback)
- No progress tracking (repeat assessments don't acknowledge improvement)

---

## Solution

Replace database-driven content generation with Claude API (Sonnet) generated personalized reports.

**Core Principle:** The AI *is* the insight engine. No pre-written strategic actions or insights.

---

## Requirements

### Functional
1. Generate personalized assessment reports based on specific answers (not just scores)
2. Recognize patterns within competencies (which sub-skills are weak)
3. Connect insights across competencies (strengths that support development areas)
4. Track progress between assessment attempts
5. Support question rotation (same concepts, different scenarios)

### Voice & Tone
- Experienced life coach with 10+ years experience
- Direct, honest, grounded in facts
- Evidence-based observations referencing specific answers
- Professional coaching terminology (ICF competencies, etc.)
- **Forbidden:** "wisdom," "transformational," "inner voice," "journey," mystical/new-age language
- Peer-to-peer tone, not guru-to-student

### Non-Functional
- Response time: Target 10-20 seconds (Sonnet)
- Consistency: Thematic consistency (same themes, different phrasing acceptable)
- Reliability: Graceful fallback if API fails
- Cost: Optimize prompts, but quality over cost

---

## Architecture

### Simplified Database Schema

**Keep (streamlined):**

```sql
-- Framework definitions
CREATE TABLE frameworks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL, -- 'core', 'icf', 'ac'
    name TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Assessment levels per framework
CREATE TABLE assessment_levels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    framework_id UUID REFERENCES frameworks(id),
    level_code TEXT NOT NULL, -- 'beginner', 'intermediate', 'advanced'
    name TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(framework_id, level_code)
);

-- Competency definitions
CREATE TABLE competencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    framework_id UUID REFERENCES frameworks(id),
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(framework_id, code)
);

-- Question pool (supports rotation)
CREATE TABLE questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    framework_id UUID REFERENCES frameworks(id),
    level_id UUID REFERENCES assessment_levels(id),
    competency_id UUID REFERENCES competencies(id),
    scenario_text TEXT NOT NULL,
    options JSONB NOT NULL, -- [{key: 'a', text: '...', is_correct: false}, ...]
    correct_option TEXT NOT NULL, -- 'a', 'b', 'c', 'd'
    concept_tag TEXT NOT NULL, -- e.g., 'emotional_cue_recognition', 'verbal_acknowledgment'
    explanation TEXT, -- Why this answer is correct (for AI context)
    difficulty_weight INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Assessment attempts with AI reports
CREATE TABLE assessment_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id),
    framework_id UUID REFERENCES frameworks(id),
    level_id UUID REFERENCES assessment_levels(id),
    started_at TIMESTAMPTZ DEFAULT now(),
    completed_at TIMESTAMPTZ,
    questions_served JSONB NOT NULL, -- Array of question IDs that were shown
    answers JSONB NOT NULL, -- {question_id: selected_option, ...}
    score_percentage DECIMAL(5,2),
    competency_scores JSONB, -- {competency_id: {correct: 2, total: 3, percentage: 66.7}, ...}
    ai_report TEXT, -- The generated report
    ai_report_metadata JSONB, -- {model: 'claude-sonnet-4-20250514', tokens_used: 1234, generated_at: '...'}
    previous_attempt_id UUID REFERENCES assessment_attempts(id), -- For progress tracking
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Index for fetching user's previous attempts
CREATE INDEX idx_assessment_attempts_user_framework
ON assessment_attempts(user_id, framework_id, level_id, completed_at DESC);
```

**Eliminate:**
- `strategic_actions` / `competency_strategic_actions`
- `tag_actions` / `skill_tags` / `tag_insights`
- `learning_resources` / `learning_resource_competencies`
- `performance_analysis` / `analysis_types`
- `competency_leverage_strengths`
- `consolidated_insights` / `competency_rich_insights`
- All scoring tier tables

### API Integration

**Supabase Edge Function:** `generate-assessment-report`

```
User completes assessment
        ↓
Frontend calls edge function with:
  - user_id
  - assessment answers
  - framework/level
        ↓
Edge function:
  1. Validate input
  2. Fetch questions served (with correct answers, explanations)
  3. Fetch competency definitions
  4. Fetch user's previous attempt (if exists)
  5. Build comprehensive prompt
  6. Call Claude API (Sonnet)
  7. Validate output (forbidden term filter)
  8. Store report in assessment_attempts
  9. Return report to frontend
        ↓
Frontend displays personalized report
```

### System Prompt Design

```
You are an experienced life coach with over 10 years of professional coaching experience. You provide direct, honest, evidence-based feedback grounded in established coaching frameworks.

## Your Voice
- Direct and practical, never airy-fairy or mystical
- Evidence-based: reference specific answers and patterns
- Peer-to-peer tone: you're a fellow professional, not a guru
- Acknowledge both strengths and development areas honestly
- Use professional coaching terminology (ICF Core Competencies, etc.)

## Forbidden Language
Never use: "wisdom," "inner wisdom," "transformational," "journey," "inner voice," "profound," "sacred," "universe," "energy" (in spiritual sense), "manifest," "authentic self"

## Your Task
Analyze this coaching assessment and provide a personalized development report.

## Assessment Context
Framework: {framework_name}
Level: {level_name}
Competencies assessed: {competency_list}

## User's Answers
{formatted_answers_with_correct_indicators}

## Previous Attempt (if applicable)
{previous_attempt_summary_or_null}

## Report Structure
1. **Overall Assessment** (2-3 sentences)
   - Honest summary of performance
   - Key pattern observed

2. **Strength Areas** (for competencies ≥70%)
   - What specifically they did well (reference specific answers)
   - How to leverage this strength

3. **Development Areas** (for competencies <70%)
   - Specific patterns in wrong answers (not just "you scored low")
   - What the wrong answers reveal about gaps
   - Concrete, actionable next steps

4. **Cross-Competency Insights**
   - Connections between strengths and development areas
   - How one area could support another

5. **Progress Notes** (if repeat assessment)
   - What improved since last time
   - What remains consistent
   - Adjusted recommendations

6. **Priority Focus**
   - Single most impactful area to focus on
   - Why this matters
   - One specific practice to start this week
```

### Forbidden Term Filter

Lightweight post-processing check:

```javascript
const FORBIDDEN_TERMS = [
  'wisdom', 'inner wisdom', 'profound', 'transformational',
  'journey', 'inner voice', 'sacred', 'universe', 'manifest',
  'authentic self', 'divine', 'spiritual', 'enlighten',
  'transcend', 'awaken', 'soul', 'energy healing', 'vibration'
];

function validateReport(report) {
  const lowerReport = report.toLowerCase();
  const violations = FORBIDDEN_TERMS.filter(term => lowerReport.includes(term));

  if (violations.length > 0) {
    console.warn('Forbidden terms found:', violations);
    // Option 1: Regenerate with stricter prompt
    // Option 2: Simple string replacement
    // Option 3: Flag for review (not recommended for production)
  }

  return { valid: violations.length === 0, violations };
}
```

### Error Handling

```javascript
// Edge function error handling
try {
  const report = await generateWithClaude(prompt);
  return { success: true, report };
} catch (error) {
  if (error.status === 529) {
    // API overloaded - retry with backoff
    return retry(generateWithClaude, prompt, { maxRetries: 3 });
  }

  if (error.status === 401 || error.status === 403) {
    // Auth error - log and return graceful failure
    console.error('Claude API auth error');
    return {
      success: false,
      fallback: generateBasicScoreReport(answers) // Simple score-only fallback
    };
  }

  // Unknown error
  return {
    success: false,
    error: 'Report generation temporarily unavailable. Your results have been saved.',
    fallback: generateBasicScoreReport(answers)
  };
}
```

---

## Implementation Phases

### Phase 1: Database Migration
1. Create new simplified schema (migrations)
2. Migrate existing questions data to new structure
3. Add `concept_tag` to questions
4. Keep existing tables temporarily for reference
5. Test data integrity

### Phase 2: Edge Function
1. Create `generate-assessment-report` edge function
2. Implement Claude API integration
3. Build comprehensive prompt with all context
4. Add forbidden term filter
5. Add error handling and fallbacks
6. Test with sample assessments

### Phase 3: Frontend Integration
1. Update assessment completion flow to call edge function
2. Create new report display component (replace current complex rendering)
3. Add loading state (10-20 second wait)
4. Handle errors gracefully
5. Test end-to-end flow

### Phase 4: Progress Tracking
1. Link assessment attempts for same user/framework/level
2. Include previous attempt in prompt context
3. Test progress comparison in generated reports

### Phase 5: Cleanup
1. Remove old insight composables
2. Remove old database tables (after confirming new system works)
3. Remove old admin content management components
4. Update CLAUDE.md with new architecture

---

## Cost Estimate

**Claude Sonnet pricing (approximate):**
- Input: $3 / 1M tokens
- Output: $15 / 1M tokens

**Per assessment estimate:**
- Input: ~2,000 tokens (questions, answers, context, prompt)
- Output: ~1,500 tokens (report)
- Cost: ~$0.006 + ~$0.0225 = **~$0.03 per assessment**

**At scale:**
- 100 assessments/month: ~$3
- 1,000 assessments/month: ~$30
- 10,000 assessments/month: ~$300

Very manageable costs.

---

## Success Criteria

1. Reports feel personalized (reference specific answers, not generic)
2. Cross-competency insights present and meaningful
3. Repeat assessments acknowledge progress
4. No forbidden terms in output
5. Response time under 30 seconds
6. Graceful degradation on API failure
7. Maintenance burden reduced (no content SQL scripts needed)

---

## Open Questions (Resolved)

| Question | Decision |
|----------|----------|
| Haiku vs Sonnet? | Sonnet (better nuance for coaching context) |
| Caching strategy? | No caching - variation is a feature |
| Human review? | No - prompt engineering + filter only |
| Database content backup? | Keep old tables during transition, delete after validation |

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| API downtime | Fallback to basic score report |
| Forbidden terms slip through | Post-processing filter + prompt iteration |
| Inconsistent quality | Strong system prompt + testing across scenarios |
| Cost spike | Monitor usage, implement rate limiting if needed |
| Slow response time | Set user expectations with loading indicator |

---

*Design approved: 2026-01-16*
