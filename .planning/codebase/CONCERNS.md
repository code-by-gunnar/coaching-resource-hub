# Codebase Concerns

**Analysis Date:** 2026-01-16

## Tech Debt

**Missing Database Migrations:**
- Issue: `supabase/migrations/` directory is empty - schema managed via dashboard
- Files: `supabase/migrations/` (empty)
- Why: Schema changes likely applied directly in Supabase dashboard
- Impact: Cannot reproduce database schema from code, no version control for DB changes
- Fix approach: Export current schema, create initial migration, use migrations for all future changes

**TODO Comments Indicate Incomplete Features:**
- Issue: Multiple TODO comments for unimplemented functionality
- Files:
  - `AdminInsights.vue:313-315` - Missing table counts for strengthLeverage, learningResources, developmentPlans
  - `useAssessmentInsightsFactory.js:104` - Database query for implemented assessments not done
  - `useWorkbook.js:353` - PDF export not implemented
  - `Assessments.vue:376-391` - Progress tracking functions return placeholder data
- Impact: Features appear complete but return dummy/placeholder values
- Fix approach: Implement each TODO or remove the incomplete feature code

**Old Composable File Kept:**
- Issue: Deprecated file left in codebase
- File: `.vitepress/theme/composables/useWorkbook.old.js`
- Why: Likely kept for reference during refactor
- Impact: Confusion about which file to use, unnecessary code
- Fix approach: Delete after confirming `useWorkbook.js` is fully functional

## Known Bugs

**No critical bugs identified during analysis.**

Note: The CLAUDE.md file mentions a race condition in subscription updates, but this appears to be documentation for a different project state or has been resolved.

## Security Considerations

**Environment Files in Repository:**
- Risk: Multiple `.env.*` files with various configurations present
- Files: `.env.development`, `.env.local.development`, `.env.local.production`, `.env.local.production.backup`
- Current mitigation: Files are gitignored (assumed from `.gitignore`)
- Recommendations: Verify all env files are properly gitignored, remove any committed secrets, use Vercel/Supabase dashboard for production secrets only

**Beta Access Control:**
- Risk: Beta access relies on user metadata that could potentially be manipulated
- File: `.vitepress/theme/composables/useBetaAccess.js`
- Current mitigation: Supabase RLS policies (assumed)
- Recommendations: Ensure RLS policies prevent users from modifying their own beta_user flag

**Admin Session Handling:**
- Risk: Admin functions accessible if session check bypassed
- Files: `.vitepress/theme/composables/useAdminSession.js`, `useAdminSupabase.js`
- Current mitigation: Client-side role checking
- Recommendations: Ensure all admin operations have server-side RLS policies

## Performance Bottlenecks

**No specific performance issues identified during analysis.**

Note: Large Vue components (some 30-60KB) may impact initial load time, but this is typical for admin interfaces with complex forms.

## Fragile Areas

**Assessment Insights Factory:**
- File: `.vitepress/theme/composables/assessments/useAssessmentInsightsFactory.js`
- Why fragile: Dynamic loading of framework-specific insights composables
- Common failures: Adding new assessment type requires updates in multiple places
- Safe modification: Follow existing pattern for Core/ICF/AC, test all assessment types
- Test coverage: E2E tests cover basic flow, no unit tests for factory logic

**Large Admin Components:**
- Files: `AdminCompetenciesTabs.vue` (49KB), `AdminUsersTabs.vue` (66KB), `AssessmentResults.vue` (69KB)
- Why fragile: Large file size indicates complex, tightly coupled logic
- Common failures: Changes in one section affect others unexpectedly
- Safe modification: Make small, focused changes; test thoroughly
- Test coverage: Limited E2E coverage for admin functionality

## Scaling Limits

**Supabase Free/Pro Tier Limits:**
- Current capacity: Depends on Supabase plan
- Limit: Database size, API requests, storage
- Symptoms at limit: API errors, slow queries
- Scaling path: Upgrade Supabase plan, optimize queries, add caching

**VitePress Static Generation:**
- Current capacity: Works well for current content volume
- Limit: Build time increases with content
- Symptoms at limit: Slow builds, memory issues
- Scaling path: Content pagination, lazy loading

## Dependencies at Risk

**No critical dependency risks identified.**

All major dependencies (VitePress, Supabase, Playwright) are actively maintained.

## Missing Critical Features

**Unit Test Suite:**
- Problem: No unit tests for composables or business logic
- Current workaround: E2E tests cover critical paths
- Blocks: Confident refactoring, regression detection
- Implementation complexity: Medium (add Vitest, write tests for key composables)

**Centralized Error Logging:**
- Problem: No production error tracking (Sentry, etc.)
- Current workaround: Console logging, Vercel logs
- Blocks: Proactive bug detection, error trend analysis
- Implementation complexity: Low (add Sentry SDK, configure DSN)

**Google Analytics:**
- Problem: Analytics code present but disabled
- File: `.vitepress/config.js` (GA config commented out)
- Current workaround: No usage tracking
- Blocks: Understanding user behavior, conversion tracking
- Implementation complexity: Low (uncomment config, add real GA4 ID)

## Test Coverage Gaps

**Unit Tests:**
- What's not tested: All composables (`use*.js`), utility functions
- Risk: Logic bugs in scoring, insights generation, data transformation
- Priority: High for `useScoring.js`, `usePersonalizedInsights.js`
- Difficulty to test: Medium (add Vitest, mock Supabase)

**Admin Interface:**
- What's not tested: Admin CRUD operations, content management
- Risk: Admin features could break without detection
- Priority: Medium
- Difficulty to test: Medium (requires auth fixture for admin role)

**Edge Functions:**
- What's not tested: PDF generation, email sending, database audits
- Risk: Backend services could fail silently
- Priority: High for `generate-pdf-report`, `email-assessment-report`
- Difficulty to test: High (requires Deno test setup, mock Supabase)

---

*Concerns audit: 2026-01-16*
*Update as issues are fixed or new ones discovered*
