# Codebase Structure

**Analysis Date:** 2026-01-16

## Directory Layout

```
coaching-resource-hub/
├── .planning/              # Project planning documents (GSD workflow)
│   └── codebase/          # Codebase analysis documents
├── .vitepress/            # VitePress configuration and theme
│   ├── cache/             # VitePress build cache
│   ├── config.js          # Site configuration
│   ├── dist/              # Build output
│   └── theme/             # Custom theme
│       ├── components/    # Vue components
│       ├── composables/   # Vue composables (business logic)
│       ├── pages/         # Vue page components
│       ├── custom.css     # Global styles
│       ├── index.js       # Theme entry point
│       ├── Layout.vue     # Main layout wrapper
│       └── tokens.css     # Design tokens
├── docs/                  # Markdown documentation content
│   ├── admin/             # Admin documentation
│   ├── assessments/       # Assessment pages
│   ├── auth/              # Authentication pages
│   ├── business/          # Business coaching content
│   ├── certification/     # Certification resources
│   ├── concepts/          # Coaching concepts
│   ├── getting-started/   # Onboarding content
│   ├── profile/           # User profile pages
│   ├── resources/         # General resources
│   ├── training/          # Training materials
│   └── workshops/         # Workshop content
├── public/                # Static assets (images, favicon)
├── scripts/               # Development and utility scripts
├── supabase/              # Supabase configuration
│   ├── config.toml        # Supabase project config
│   ├── email-templates/   # Auth email templates
│   ├── functions/         # Edge Functions
│   └── migrations/        # Database migrations (empty)
├── tests/                 # Test files
│   └── e2e/               # Playwright E2E tests
│       ├── fixtures/      # Test utilities
│       └── specs/         # Test specifications
├── index.md               # Homepage
├── package.json           # Project manifest
├── playwright.config.js   # E2E test config
└── vercel.json            # Deployment config
```

## Directory Purposes

**.vitepress/theme/components/**
- Purpose: Vue single-file components for UI
- Contains: Assessment components, Admin editors, Auth forms, Profile views
- Key files: `AssessmentPlayer.vue`, `AssessmentResults.vue`, `AdminHub.vue`, `Auth.vue`
- Subdirectories: `profile/`, `shared/`, `workbook/`

**.vitepress/theme/composables/**
- Purpose: Reusable Vue composition functions
- Contains: State management, API calls, business logic
- Key files: `useAssessments.js`, `useAuth.js`, `useScoring.js`, `useSupabase.js`
- Subdirectories: `assessments/` (framework-specific insights), `shared/`

**docs/**
- Purpose: Markdown content rendered as site pages
- Contains: Educational content, feature pages with embedded Vue components
- Key files: `intro.md`, `privacy-policy.md`
- Structure: Topic-based subdirectories

**supabase/functions/**
- Purpose: Serverless Edge Functions (Deno runtime)
- Contains: PDF generation, email sending, database auditing
- Key files: `generate-pdf-report/index.ts`, `email-assessment-report/index.ts`
- Pattern: One directory per function with `index.ts` entry

**tests/e2e/**
- Purpose: End-to-end browser tests
- Contains: Playwright test specs and fixtures
- Key files: `basic-assessment-test.spec.js`, `auth.js` fixture
- Structure: `fixtures/` for helpers, `specs/` for tests

## Key File Locations

**Entry Points:**
- `.vitepress/theme/index.js` - Theme/app entry point
- `index.md` - Homepage content
- `.vitepress/config.js` - VitePress configuration

**Configuration:**
- `package.json` - Dependencies, scripts
- `.prettierrc` - Code formatting
- `playwright.config.js` - E2E test config
- `vercel.json` - Deployment settings
- `supabase/config.toml` - Supabase local config
- `.env.example` - Environment variable template

**Core Logic:**
- `.vitepress/theme/composables/useAssessments.js` - Assessment data management
- `.vitepress/theme/composables/useScoring.js` - Score calculation
- `.vitepress/theme/composables/usePersonalizedInsights.js` - AI-driven insights
- `.vitepress/theme/composables/useSupabase.js` - Database client singleton

**Testing:**
- `tests/e2e/specs/*.spec.js` - E2E test files
- `tests/e2e/fixtures/auth.js` - Authentication test helper
- `tests/e2e/fixtures/databaseHelper.js` - DB test utilities

**Documentation:**
- `README.md` - Project overview
- `CLAUDE.md` - AI assistant instructions
- `docs/intro.md` - User-facing introduction

## Naming Conventions

**Files:**
- PascalCase.vue: Vue components (`AssessmentPlayer.vue`, `AdminHub.vue`)
- camelCase.js: JavaScript modules (`useAssessments.js`, `useAuth.js`)
- kebab-case.md: Markdown content (`privacy-policy.md`)
- kebab-case.spec.js: Test files (`basic-assessment-test.spec.js`)
- UPPERCASE.md: Important project files (`README.md`, `CLAUDE.md`)

**Directories:**
- kebab-case: All directories (`getting-started/`, `e2e/`)
- Plural for collections: `components/`, `composables/`, `fixtures/`

**Special Patterns:**
- `use*.js`: Vue composables
- `Admin*.vue`: Admin interface components
- `*/index.ts`: Edge Function entry points

## Where to Add New Code

**New Vue Component:**
- Implementation: `.vitepress/theme/components/ComponentName.vue`
- Shared components: `.vitepress/theme/components/shared/`
- Profile-related: `.vitepress/theme/components/profile/`

**New Composable:**
- Implementation: `.vitepress/theme/composables/useFeatureName.js`
- Assessment-specific: `.vitepress/theme/composables/assessments/`
- Shared utilities: `.vitepress/theme/composables/shared/`

**New Documentation Page:**
- Implementation: `docs/category/page-name.md`
- Add to nav in `.vitepress/config.js`

**New Edge Function:**
- Implementation: `supabase/functions/function-name/index.ts`
- Add `.env` if needed

**New E2E Test:**
- Implementation: `tests/e2e/specs/feature-name.spec.js`
- Test utilities: `tests/e2e/fixtures/`

## Special Directories

**.vitepress/dist/**
- Purpose: VitePress build output
- Source: Generated by `npm run build`
- Committed: No (gitignored)

**.vitepress/cache/**
- Purpose: VitePress build cache
- Source: Auto-generated
- Committed: No (gitignored)

**supabase/migrations/**
- Purpose: Database schema migrations
- Source: Created via Supabase CLI
- Committed: Yes (currently empty - schema managed via dashboard)

**scripts/**
- Purpose: Development utilities, testing helpers
- Contains: Local testing scripts, data generation
- Committed: Yes

---

*Structure analysis: 2026-01-16*
*Update when directory structure changes*
