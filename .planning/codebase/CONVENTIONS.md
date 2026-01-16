# Coding Conventions

**Analysis Date:** 2026-01-16

## Naming Patterns

**Files:**
- PascalCase.vue for Vue components (`AssessmentPlayer.vue`, `AdminHub.vue`)
- camelCase.js for JavaScript modules (`useAssessments.js`, `useScoring.js`)
- kebab-case.spec.js for test files (`basic-assessment-test.spec.js`)
- UPPERCASE.md for important project files (`README.md`, `CLAUDE.md`)

**Functions:**
- camelCase for all functions
- `use*` prefix for Vue composables (`useAuth`, `useAssessments`)
- `handle*` for event handlers in components

**Variables:**
- camelCase for variables and properties
- UPPER_SNAKE_CASE for constants (rare in codebase)
- No underscore prefix for private members

**Types:**
- Not applicable (JavaScript codebase, TypeScript only in Edge Functions)
- JSDoc comments for type hints where needed

## Code Style

**Formatting (`.prettierrc`):**
- Print width: 100 characters
- Tab width: 2 spaces
- No tabs (spaces only)
- Semicolons required
- Single quotes for strings
- Trailing commas: ES5 compatible
- Bracket spacing: enabled
- Arrow function parens: avoid when possible
- End of line: LF

**Linting:**
- No ESLint configuration detected
- Prettier is the primary code style enforcer

## Import Organization

**Order (observed pattern):**
1. External packages (`import { createClient } from '@supabase/supabase-js'`)
2. Vue/framework imports (`import { ref, computed } from 'vue'`)
3. Local composables (`import { useSupabase } from '../composables/useSupabase'`)
4. Local components (relative imports)

**Grouping:**
- No enforced blank lines between groups
- Generally alphabetical within groups

**Path Aliases:**
- No path aliases configured
- Relative imports used throughout (`../composables/`, `./shared/`)

## Error Handling

**Patterns:**
- Try/catch in async functions within composables
- Error state exposed via reactive refs
- `useUserFriendlyErrors.js` transforms technical errors

**Error Types:**
- Supabase errors caught and transformed
- Form validation before API calls
- User-friendly messages displayed in UI

**Example pattern:**
```javascript
try {
  const { data, error } = await supabase.from('table').select()
  if (error) throw error
  // process data
} catch (err) {
  error.value = getUserFriendlyError(err)
}
```

## Logging

**Framework:**
- Console.log for development debugging
- No production logging service

**Patterns:**
- `console.log('=== Section Header ===')` for test output
- Emoji prefixes in tests (`✅`, `❌`) for visual scanning
- No structured logging

## Comments

**When to Comment:**
- Explain business logic decisions
- Document TODO items with context
- Describe complex algorithms

**JSDoc/TSDoc:**
- Minimal JSDoc usage
- Type hints via JSDoc where helpful
- No enforced documentation standard

**TODO Comments:**
- Format: `// TODO: description`
- Found in: `AdminInsights.vue`, `useAssessmentInsightsFactory.js`, `Assessments.vue`
- Used for planned features and missing implementations

## Function Design

**Size:**
- Composables can be large (100-300 lines) when containing related logic
- Components vary widely based on complexity
- No enforced size limits

**Parameters:**
- Destructuring common for options objects
- Vue composables typically return object with multiple properties

**Return Values:**
- Composables return objects with reactive refs and methods
- Explicit returns preferred

**Example composable pattern:**
```javascript
export function useFeatureName() {
  const data = ref(null)
  const loading = ref(false)
  const error = ref(null)

  async function fetchData() {
    loading.value = true
    try {
      // implementation
    } catch (err) {
      error.value = err
    } finally {
      loading.value = false
    }
  }

  return {
    data,
    loading,
    error,
    fetchData
  }
}
```

## Module Design

**Exports:**
- Named exports for composables
- Single default export for Vue components
- Barrel files not used

**Vue Component Pattern:**
- Single File Components (SFC) with `<script setup>` or Options API
- Template, script, style order
- Scoped styles preferred

## Vue-Specific Conventions

**Component Structure:**
```vue
<template>
  <!-- Template content -->
</template>

<script>
// Options API or setup() function
export default {
  name: 'ComponentName',
  // ...
}
</script>

<style scoped>
/* Scoped styles */
</style>
```

**Reactive State:**
- `ref()` for primitive values
- `reactive()` for complex objects
- `computed()` for derived state

**Props/Emits:**
- Props defined with validation where critical
- Events emitted via `$emit` or `emit`

---

*Convention analysis: 2026-01-16*
*Update when patterns change*
