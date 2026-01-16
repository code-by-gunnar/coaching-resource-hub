# Frontend Migration Guide: Scoring System Modernization
## Replace Hardcoded 70% Threshold with Flexible Scoring Tiers

**Date:** 2025-08-22  
**Branch:** `scoring-fix`  
**Priority:** HIGH - Required for new centralized scoring system

---

## Overview

This guide shows how to migrate frontend code from the old hardcoded scoring system to the new centralized scoring tier system.

### **Old System Issues:**
- Hardcoded `percentage >= 70` threshold in 15+ files
- Overlapping database score ranges causing unpredictable results
- No flexibility for framework-specific scoring
- Difficult to change scoring logic globally

### **New System Benefits:**
- Single source of truth in `scoring_tiers` database table
- Flexible 6-tier system (0-20%, 21-40%, 41-60%, 61-69%, 70-89%, 90-100%)
- Framework-specific overrides capability
- Easy global scoring changes
- Consistent, predictable query results

---

## Migration Patterns

### **Pattern 1: Replace Hardcoded Weakness Check**

**❌ Old Code:**
```javascript
// Hardcoded 70% threshold
const isWeakness = comp.percentage < 70
const performanceType = comp.percentage >= 70 ? 'strength' : 'weakness'
```

**✅ New Code:**
```javascript
import { useScoring } from '../composables/useScoring.js'

const { isWeaknessScore } = useScoring()

// Dynamic tier-based weakness check
const isWeakness = await isWeaknessScore(comp.percentage, frameworkCode, assessmentLevel)
const performanceType = isWeakness ? 'weakness' : 'strength'
```

### **Pattern 2: Replace Score Range Queries**

**❌ Old Code:**
```javascript
// Overlapping ranges cause unpredictable results
const { data } = await supabase
  .from('competency_strategic_actions')
  .select('action_text')
  .lte('score_range_min', percentage)
  .gte('score_range_max', percentage)
```

**✅ New Code:**
```javascript
import { useScoring } from '../composables/useScoring.js'

const { getStrategicActionsForScore } = useScoring()

// Guaranteed single tier match
const actions = await getStrategicActionsForScore(
  percentage, 
  competencyId, 
  frameworkId, 
  assessmentLevelId
)
```

### **Pattern 3: Replace Performance Analysis Logic**

**❌ Old Code:**
```javascript
// Multiple hardcoded thresholds
const getPerformanceLevel = (percentage) => {
  if (percentage === 0) return 'zero'
  if (percentage < 50) return 'low'
  if (percentage < 70) return 'developing'
  if (percentage < 90) return 'good'
  return 'excellent'
}
```

**✅ New Code:**
```javascript
import { useScoring } from '../composables/useScoring.js'

const { getScoringTier } = useScoring()

const getPerformanceLevel = async (percentage, framework, level) => {
  const tier = await getScoringTier(percentage, framework, level)
  return tier.tier_code // 'critical', 'poor', 'below_average', 'developing', 'good', 'excellent'
}
```

### **Pattern 4: Replace Filter Logic**

**❌ Old Code:**
```javascript
// Hardcoded filtering
const weaknesses = competencies.filter(comp => comp.percentage < 70)
const strengths = competencies.filter(comp => comp.percentage >= 70)
```

**✅ New Code:**
```javascript
import { useScoring } from '../composables/useScoring.js'

const { isWeaknessScore } = useScoring()

// Dynamic tier-based filtering
const weaknesses = []
const strengths = []

for (const comp of competencies) {
  const isWeak = await isWeaknessScore(comp.percentage, frameworkCode, assessmentLevel)
  if (isWeak) {
    weaknesses.push(comp)
  } else {
    strengths.push(comp)
  }
}
```

---

## Files Requiring Updates

### **High Priority - Core Assessment Logic:**

**1. `.vitepress/theme/composables/usePersonalizedInsights.js`**
- Lines: ~66, ~125 (hardcoded `< 70` checks)
- Impact: Performance analysis broken for all assessments

**2. `.vitepress/theme/composables/useAssessmentInsights.js`**  
- Lines: ~437, ~447 (weakness filtering)
- Impact: Strategic actions and insights selection

**3. `.vitepress/theme/components/AssessmentResults.vue`**
- Line: ~602 (strength/weakness classification)
- Impact: Main results display logic

### **Medium Priority - Display Components:**

**4. `.vitepress/theme/components/AssessmentInsights.vue`**
- Lines: ~292, ~305 (performance indicators)
- Impact: Visual performance indicators

**5. `.vitepress/theme/composables/useFrontendInsightsCapture.js`**
- Lines: ~20, ~34 (insights categorization)
- Impact: Insights capture and categorization

### **Backend Functions (Future):**

**6. `supabase/functions/email-assessment-report/index.ts`**
- Line: ~381 (email report logic)

**7. `supabase/functions/generate-pdf-report/index.ts`**
- Lines: ~72, ~420 (PDF generation)

**8. `supabase/functions/generate-question-analysis-report/index.ts`**
- Lines: ~435, ~468 (question analysis)

---

## Detailed Migration Examples

### **Example 1: usePersonalizedInsights.js**

**Current Issue:**
```javascript
// Line 153 - HARDCODED 'beginner' level (fixed in previous migration)
// Line 66 - Hardcoded 70% threshold
const isLowPerformance = competency.percentage < 70
```

**Migration:**
```javascript
import { useScoring } from './useScoring.js'

export function usePersonalizedInsights(assessment) {
  const { isWeaknessScore, getScoringTier } = useScoring()
  
  const generateInsights = async (competencies) => {
    const insights = []
    
    for (const competency of competencies) {
      // Replace hardcoded threshold
      const isLowPerformance = await isWeaknessScore(
        competency.percentage,
        assessment.framework,
        assessment.difficulty  
      )
      
      if (isLowPerformance) {
        // Get tier-specific insights
        const tier = await getScoringTier(competency.percentage)
        const insight = `Performance in ${competency.name} is at ${tier.tier_name} level (${competency.percentage}%)`
        insights.push(insight)
      }
    }
    
    return insights
  }
  
  return { generateInsights }
}
```

### **Example 2: AssessmentResults.vue**

**Current Issue:**
```javascript
// Line 602 - Hardcoded classification
computed: {
  competencyResults() {
    return this.competencies.map(comp => ({
      ...comp,
      type: comp.percentage >= 70 ? 'strength' : 'weakness'
    }))
  }
}
```

**Migration:**
```javascript
<script setup>
import { useScoring } from '../composables/useScoring.js'

const { isWeaknessScore } = useScoring()

// Replace computed with async method
const getCompetencyResults = async () => {
  const results = []
  
  for (const comp of competencies.value) {
    const isWeak = await isWeaknessScore(
      comp.percentage,
      assessment.value.framework,
      assessment.value.difficulty
    )
    
    results.push({
      ...comp,
      type: isWeak ? 'weakness' : 'strength'
    })
  }
  
  return results
}
</script>
```

### **Example 3: Strategic Actions Query**

**Current Issue:**
```javascript
// Overlapping ranges return multiple results
const getStrategicActions = async (percentage, competencyId) => {
  const { data } = await supabase
    .from('competency_strategic_actions')
    .select('action_text')
    .eq('competency_id', competencyId)
    .lte('score_range_min', percentage)
    .gte('score_range_max', percentage)
  
  // Could return multiple overlapping actions!
  return data?.map(d => d.action_text) || []
}
```

**Migration:**
```javascript
import { useScoring } from './useScoring.js'

const { getStrategicActionsForScore } = useScoring()

const getStrategicActions = async (percentage, competencyId, frameworkId, assessmentLevelId) => {
  // Guaranteed single tier match, no overlaps
  return await getStrategicActionsForScore(
    percentage,
    competencyId, 
    frameworkId,
    assessmentLevelId
  )
}
```

---

## Testing Strategy

### **1. Unit Tests for Scoring Logic:**
```javascript
// Test each scoring tier boundary
describe('useScoring', () => {
  test('tier boundaries work correctly', async () => {
    const { getScoringTier } = useScoring()
    
    // Test each tier
    expect((await getScoringTier(15)).tier_code).toBe('critical')    // 0-20%
    expect((await getScoringTier(35)).tier_code).toBe('poor')        // 21-40%
    expect((await getScoringTier(55)).tier_code).toBe('below_average') // 41-60%
    expect((await getScoringTier(65)).tier_code).toBe('developing')  // 61-69%  
    expect((await getScoringTier(75)).tier_code).toBe('good')        // 70-89%
    expect((await getScoringTier(95)).tier_code).toBe('excellent')   // 90-100%
  })
})
```

### **2. Integration Tests:**
- Test assessment results with various score combinations
- Verify strategic actions return consistent results
- Validate performance analysis uses correct tiers

### **3. Manual Testing:**
- Create test assessment attempts with scores in each tier
- Verify UI displays correct tier information
- Confirm no duplicate strategic actions appear

---

## Rollout Strategy

### **Phase 1: Core Logic (This Branch)**
1. ✅ Create `useScoring.js` composable
2. ⏳ Update `usePersonalizedInsights.js` 
3. ⏳ Update `useAssessmentInsights.js`
4. ⏳ Test with existing assessments

### **Phase 2: UI Components**
1. Update `AssessmentResults.vue`
2. Update `AssessmentInsights.vue`  
3. Add tier indicators to UI
4. Test visual changes

### **Phase 3: Backend Functions**
1. Update PDF generation logic
2. Update email report logic
3. Update question analysis
4. Full system testing

---

## Compatibility & Risk Mitigation

### **Backward Compatibility:**
- `useScoring.js` provides legacy aliases (`isWeakness`, `getPerformanceTier`)
- Graceful fallback to old 70% logic if database unavailable
- Migration can be done incrementally file by file

### **Risk Mitigation:**
- Keep old files backed up until migration complete
- Extensive testing in development environment
- Ability to quickly revert individual file changes
- Database-level validation ensures no overlapping ranges

### **Monitoring:**
- Log scoring tier usage to verify correct migration
- Monitor for any unexpected behavior changes
- Track query performance with new tier-based queries

---

## Success Criteria

### **Technical Validation:**
- [ ] Zero hardcoded 70% thresholds remaining in frontend
- [ ] All strategic action queries return single consistent results  
- [ ] Performance analysis works correctly for all assessment levels
- [ ] UI displays appropriate tier information

### **Functional Validation:**
- [ ] Assessment results remain consistent with previous behavior
- [ ] New granular scoring provides better user guidance
- [ ] System performance maintained or improved
- [ ] New assessments inherit correct scoring automatically

---

**Next Steps:**
1. Run database migration scripts (01, 02, 03)
2. Start frontend migration with core composables
3. Test thoroughly with existing assessment data
4. Deploy incrementally with monitoring and rollback capability