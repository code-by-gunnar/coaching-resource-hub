# Skills Improvement Plan
## Based on Skills Review Analysis

### 🚨 Issues Identified

## 1. OVERLAPPING POWERFUL QUESTIONS (High Priority)

**Problem:** Future-Focused, Possibility, and Perspective Shift Questions have very similar insights and blur together.

**Current Issues:**
- Future-Focused: "Focusing on problems rather than helping clients explore possibilities"
- Possibility: "Focusing on obstacles rather than helping explore possibilities" 
- Both have nearly identical weakness insights!

**Action Plan:**
1. **Consolidate** Future-Focused and Possibility Questions into one skill
2. **Refine** Perspective Shift Questions to be more distinct
3. **Create** a new, more distinct skill to maintain 6 skills per competency

### Recommended Changes:

#### Deactivate: "Possibility Questions" (most redundant)
- Reason: Nearly identical to Future-Focused Questions
- Merge its best content into Future-Focused Questions

#### Improve: "Future-Focused Questions" 
- New name: "Solution-Focused Questions"
- Better action: "Shift from problems to solutions: 'What would need to happen for this to work?'"

#### Improve: "Perspective Shift Questions"
- Better action example: "How might someone with a different background view this situation?" (as suggested in review)

#### Create New: "Scaling Questions"
- Fill the gap with a distinct questioning skill
- Example: "On a scale of 1-10, where are you now? What would move you up one point?"

## 2. OVERLAPPING PRESENT MOMENT AWARENESS (Medium Priority)

**Problem:** Energy Reading and Emotional Awareness overlap significantly

**Current Issues:**
- Energy Reading: "Missing client energy shifts and failing to use therapeutically"
- Emotional Awareness: "Missing emotional cues and present-moment feelings"
- Both actions involve noticing changes and asking about them

**Action Plan:**
1. **Refine** Energy Reading to focus on physical/energetic observations
2. **Refine** Emotional Awareness to focus on emotional content specifically

#### Improve: "Energy Reading"
- Focus on physical energy, pace, breathing, posture
- Action: "Notice physical changes: 'I notice your breathing changed - what's happening?'"

#### Improve: "Emotional Awareness" 
- Focus on emotional content and feeling words
- Action: "Track emotional words: 'You said 'frustrated' - tell me more about that feeling.'"

## 3. AMBIGUOUS ACTION STEPS (High Priority)

**Problems from Review:**
- "Set intention before sessions: approach with curiosity, not judgment" - too vague
- "Watch for tone/pace/body changes: 'Something shifted just now - what happened?'" - too complex

**Action Plan:**
Make all action steps more specific and beginner-friendly.

### Implementation Plan

#### Phase 1: Immediate Deactivations (Safe to do now)
```sql
-- Deactivate the most redundant skill
SELECT * FROM deactivate_skill_tag('Possibility Questions', 'core');
```

#### Phase 2: Content Improvements (Update existing)
- Update Future-Focused Questions with better content
- Update Perspective Shift Questions with better examples
- Improve Energy Reading vs Emotional Awareness distinctions
- Make action steps more specific

#### Phase 3: Add New Skills (Future)
- Add "Scaling Questions" to replace deactivated Possibility Questions
- Ensure each skill has truly distinct purpose

### Priority Order
1. **Deactivate "Possibility Questions"** (immediate - most redundant)
2. **Improve action text clarity** for ambiguous steps
3. **Refine overlapping skills** to be more distinct
4. **Add replacement skills** for better coverage

Would you like me to start with deactivating "Possibility Questions" and then work on improving the content of the remaining skills?