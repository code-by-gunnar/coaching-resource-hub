# Centralized Scoring Reference Table Design
## Flexible, Maintainable Scoring System

**Date:** 2025-08-22  
**Branch:** `scoring-fix`  
**Priority:** HIGH - Eliminates scoring fragility

---

## Current Problem: Fragile Distributed Scoring

### **Current Issues:**
- Score ranges duplicated across multiple tables
- Each table maintains its own `score_range_min/max` columns
- Changes require updating 5+ different tables
- Overlapping ranges cause inconsistent behavior
- No central control over scoring logic

### **Tables Currently With Scoring:**
- `competency_strategic_actions`
- `competency_rich_insights` 
- `competency_leverage_strengths`
- `tag_insights`
- Future assessment tables...

---

## Solution: Reference Table Architecture

### **New Centralized Structure:**

```sql
-- 1. SCORING TIERS REFERENCE TABLE
CREATE TABLE scoring_tiers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tier_code VARCHAR(20) UNIQUE NOT NULL,  -- 'critical', 'poor', 'below_average', etc.
  tier_name VARCHAR(50) NOT NULL,         -- 'Critical Failure', 'Poor Performance', etc.
  score_min INTEGER NOT NULL,             -- 0, 21, 41, 61, 70, 90
  score_max INTEGER NOT NULL,             -- 20, 40, 60, 69, 89, 100
  display_order INTEGER NOT NULL,         -- 1, 2, 3, 4, 5, 6
  is_weakness BOOLEAN NOT NULL,           -- true for 0-69%, false for 70-100%
  description TEXT,                       -- What this tier represents
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 2. FRAMEWORK-SPECIFIC SCORING OVERRIDES (OPTIONAL)
CREATE TABLE framework_scoring_overrides (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  framework_id UUID REFERENCES frameworks(id),
  assessment_level_id UUID REFERENCES assessment_levels(id),
  tier_code VARCHAR(20) REFERENCES scoring_tiers(tier_code),
  custom_score_min INTEGER,               -- Override default if needed
  custom_score_max INTEGER,               -- Override default if needed
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### **Benefits:**
1. **Single source of truth** for all scoring logic
2. **One change cascades** to all content tables
3. **Framework flexibility** - custom scoring per assessment type
4. **Zero overlaps** - enforced at reference level
5. **Easy A/B testing** - toggle scoring systems
6. **Future-proof** - new assessments automatically inherit correct scoring

---

## Migration Strategy

### **Phase 1: Create Reference Tables**

```sql
-- Insert standardized 6-tier scoring system
INSERT INTO scoring_tiers (tier_code, tier_name, score_min, score_max, display_order, is_weakness, description) VALUES
('critical', 'Critical Failure', 0, 20, 1, true, 'Emergency intervention required'),
('poor', 'Poor Performance', 21, 40, 2, true, 'Basic skill building needed'), 
('below_average', 'Below Average', 41, 60, 3, true, 'Consistency development focus'),
('developing', 'Developing', 61, 69, 4, true, 'Refinement techniques needed'),
('good', 'Good Performance', 70, 89, 5, false, 'Leverage existing strengths'),
('excellent', 'Excellent', 90, 100, 6, false, 'Mastery applications');
```

### **Phase 2: Add FK References to Content Tables**

```sql
-- Add scoring_tier reference to existing tables
ALTER TABLE competency_strategic_actions 
ADD COLUMN scoring_tier_id UUID REFERENCES scoring_tiers(id);

ALTER TABLE competency_rich_insights 
ADD COLUMN scoring_tier_id UUID REFERENCES scoring_tiers(id);

ALTER TABLE competency_leverage_strengths 
ADD COLUMN scoring_tier_id UUID REFERENCES scoring_tiers(id);

ALTER TABLE tag_insights 
ADD COLUMN scoring_tier_id UUID REFERENCES scoring_tiers(id);
```

### **Phase 3: Migrate Existing Data**

```sql
-- Example: Map existing overlapping ranges to new tiers
UPDATE competency_strategic_actions 
SET scoring_tier_id = (SELECT id FROM scoring_tiers WHERE tier_code = 'critical')
WHERE score_range_min = 0 AND score_range_max <= 20;

UPDATE competency_strategic_actions 
SET scoring_tier_id = (SELECT id FROM scoring_tiers WHERE tier_code = 'poor')  
WHERE score_range_min <= 25 AND score_range_max >= 35;

-- Continue for all ranges...
```

### **Phase 4: Remove Old Columns**

```sql
-- After validation, remove redundant columns
ALTER TABLE competency_strategic_actions 
DROP COLUMN score_range_min,
DROP COLUMN score_range_max;

-- Repeat for all tables
```

---

## New Query Patterns

### **Before (Fragile):**
```sql
SELECT action_text 
FROM competency_strategic_actions 
WHERE score_range_min <= 45 AND score_range_max >= 45;
-- Could return multiple overlapping results!
```

### **After (Robust):**
```sql
SELECT csa.action_text
FROM competency_strategic_actions csa
JOIN scoring_tiers st ON csa.scoring_tier_id = st.id  
WHERE 45 BETWEEN st.score_min AND st.score_max;
-- Guaranteed single tier match
```

### **Frontend Helper Function:**
```javascript
const getScoringTier = (percentage) => {
  // Single database lookup returns exact tier
  const { data } = await supabase
    .from('scoring_tiers')  
    .select('*')
    .lte('score_min', percentage)
    .gte('score_max', percentage)
    .single()
  
  return data.tier_code
}
```

---

## Advanced Features Enabled

### **1. A/B Testing Different Scoring Systems:**
```sql
-- Easy to test different tier boundaries
INSERT INTO scoring_tiers (tier_code, tier_name, score_min, score_max, ...) VALUES
('experimental_poor', 'Poor (Test)', 15, 35, ...);  -- Different boundaries

-- Switch content to use test scoring
UPDATE competency_strategic_actions 
SET scoring_tier_id = (SELECT id FROM scoring_tiers WHERE tier_code = 'experimental_poor')
WHERE competency_id = 'test_competency';
```

### **2. Framework-Specific Scoring:**
```sql
-- ICF might have different thresholds than Core
INSERT INTO framework_scoring_overrides (framework_id, tier_code, custom_score_min, custom_score_max) VALUES
((SELECT id FROM frameworks WHERE code = 'icf'), 'good', 75, 89);  -- ICF requires 75% for "good"
```

### **3. Dynamic Scoring Updates:**
```sql
-- Change all "poor" performance from 21-40% to 21-35%  
UPDATE scoring_tiers SET score_max = 35 WHERE tier_code = 'poor';
-- Immediately affects ALL content using that tier!
```

---

## Implementation Files

### **Database Migration:**
- `scripts/production/01_create_scoring_reference_tables.sql`
- `scripts/production/02_migrate_existing_scoring_data.sql`
- `scripts/production/03_remove_old_scoring_columns.sql`

### **Frontend Updates:**
- Create `composables/useScoring.js` helper
- Update all components to use scoring tier lookups
- Replace hardcoded 70% threshold with tier-based logic

### **Backend Functions:**
- Update PDF generation to use scoring tiers
- Modify email reports to use tier-based content
- Adjust question analysis to use centralized scoring

---

## Validation & Testing

### **Data Integrity Checks:**
- [ ] No overlapping score ranges in scoring_tiers table
- [ ] All content tables properly reference scoring tiers
- [ ] Foreign key constraints enforce data consistency
- [ ] No orphaned scoring references

### **Functional Testing:**
- [ ] Each percentage score maps to exactly one tier
- [ ] Strategic actions return consistent results
- [ ] Frontend displays correct tier-based content
- [ ] Performance analysis uses proper tier boundaries

---

## Risk Mitigation

### **Rollback Strategy:**
1. Keep old score columns until validation complete
2. Create migration script to restore old structure if needed
3. Test extensively in development before production deployment

### **Deployment Safety:**
1. Deploy reference tables first (non-breaking)
2. Add FK columns without dropping old ones initially  
3. Validate data migration thoroughly
4. Remove old columns only after full validation

---

**Status:** Architecture Designed - Ready for Implementation  
**Estimated Effort:** 1-2 days development + thorough testing  
**Risk Level:** Low-Medium (safer than distributed scoring changes)  
**Long-term Benefit:** HIGH - Future scoring changes become trivial