# Architecture

**Analysis Date:** 2026-01-16

## Pattern Overview

**Overall:** VitePress Documentation Site with Vue 3 SPA Features + Supabase Backend

**Key Characteristics:**
- Static site generation with dynamic Vue components
- Composable-based state management (Vue Composition API)
- Serverless backend via Supabase (Database, Auth, Edge Functions)
- Content-first architecture (Markdown docs + interactive assessments)

## Layers

**Presentation Layer:**
- Purpose: User interface and routing
- Contains: Vue components, CSS, VitePress theme
- Location: `.vitepress/theme/components/*.vue`, `.vitepress/theme/pages/*.vue`
- Depends on: Composables layer for state/logic
- Used by: VitePress framework

**Composables Layer:**
- Purpose: Reusable business logic and state management
- Contains: Vue composables (use*.js pattern)
- Location: `.vitepress/theme/composables/*.js`
- Depends on: Supabase client, external APIs
- Used by: Vue components

**Content Layer:**
- Purpose: Static documentation and educational content
- Contains: Markdown files with frontmatter
- Location: `docs/**/*.md`, `index.md`
- Depends on: VitePress for rendering
- Used by: Site visitors

**Backend Layer (Serverless):**
- Purpose: Server-side logic, PDF generation, data processing
- Contains: Supabase Edge Functions (TypeScript/Deno)
- Location: `supabase/functions/*/index.ts`
- Depends on: Supabase services, external APIs
- Used by: Frontend via HTTP calls

## Data Flow

**Assessment Flow:**

1. User visits assessment page (`/docs/assessments/take`)
2. `Assessments.vue` component loads, calls `useAssessments.js`
3. Composable fetches assessment data from Supabase
4. User answers questions via `AssessmentPlayer.vue`
5. `useScoring.js` calculates results
6. `useFrontendInsightsCapture.js` generates personalized feedback
7. Results saved to Supabase via `useSupabase.js`
8. `AssessmentResults.vue` displays competency analysis

**Authentication Flow:**

1. User clicks login in `AuthNav.vue`
2. `Auth.vue` component renders login form
3. `useAuth.js` composable handles Supabase auth
4. Session stored in Supabase client
5. `useBetaAccess.js` checks user beta permissions
6. Protected features unlocked based on role

**State Management:**
- Singleton Supabase client (`.vitepress/theme/composables/useSupabase.js`)
- Reactive state via Vue 3 Composition API
- No global store (Vuex/Pinia) - composables handle local state

## Key Abstractions

**Composable:**
- Purpose: Encapsulate reusable logic with reactive state
- Examples: `useAssessments.js`, `useAuth.js`, `useScoring.js`, `usePersonalizedInsights.js`
- Pattern: Vue Composition API `use*` convention

**Assessment Framework:**
- Purpose: Pluggable assessment types (Core, ICF, AC) with skill levels
- Examples: `useCoreBeginnerInsights.js`, framework-specific composables
- Location: `.vitepress/theme/composables/assessments/frameworks/`
- Pattern: Factory pattern via `useAssessmentInsightsFactory.js`

**Admin Editor:**
- Purpose: CRUD interfaces for assessment content management
- Examples: `AdminCompetencies.vue`, `AdminQuestions.vue`, `AdminUsers.vue`
- Pattern: Tabbed interface with edit modals

**Edge Function:**
- Purpose: Server-side operations requiring secrets or heavy processing
- Examples: `generate-pdf-report`, `email-assessment-report`, `audit-database`
- Pattern: Deno HTTP handlers with Supabase client

## Entry Points

**Site Entry:**
- Location: `.vitepress/theme/index.js`
- Triggers: VitePress build/dev, page navigation
- Responsibilities: Register Vue components, setup theme, load global CSS

**Page Entry:**
- Location: `index.md`, `docs/**/*.md`
- Triggers: URL routing by VitePress
- Responsibilities: Render content with embedded Vue components

**Edge Function Entry:**
- Location: `supabase/functions/*/index.ts`
- Triggers: HTTP requests to Supabase function URLs
- Responsibilities: Handle API requests, generate PDFs, send emails

## Error Handling

**Strategy:** Component-level error handling with user-friendly messages

**Patterns:**
- `useUserFriendlyErrors.js` transforms technical errors to readable messages
- Try/catch in composables, surface to UI via reactive error state
- Supabase errors logged and transformed before display
- Form validation before API calls

## Cross-Cutting Concerns

**Logging:**
- Console.log for development debugging
- No production logging service detected

**Validation:**
- Form-level validation in components
- Database-level constraints via Supabase RLS policies

**Authentication:**
- Supabase Auth with JWT tokens
- Beta user access control via user metadata (`useBetaAccess.js`)
- Admin session management (`useAdminSession.js`)

**SEO:**
- `useSEO.js` composable for dynamic meta tags
- `SEOHead.vue` component for page-specific SEO
- Schema.org structured data in `.vitepress/config.js`

**Analytics:**
- `useAnalytics.js` composable (Google Analytics setup)
- `GoogleAnalytics.vue` component (currently disabled in config)

---

*Architecture analysis: 2026-01-16*
*Update when major patterns change*
