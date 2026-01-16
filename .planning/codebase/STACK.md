# Technology Stack

**Analysis Date:** 2026-01-16

## Languages

**Primary:**
- JavaScript (ES Modules) - All frontend application code, composables, components

**Secondary:**
- TypeScript - Supabase Edge Functions (`supabase/functions/*.ts`)
- Markdown - Documentation content (`docs/**/*.md`)

## Runtime

**Environment:**
- Node.js (ES Modules via `"type": "module"` in `package.json`)
- Browser runtime (VitePress static site with Vue 3 SPA features)
- Deno - Supabase Edge Functions runtime

**Package Manager:**
- npm
- Lockfile: `package-lock.json` present

## Frameworks

**Core:**
- VitePress 1.6.3 - Static site generator with Vue 3 (`package.json`)
- Vue 3 - UI framework (via VitePress)

**Testing:**
- Playwright 1.54.2 - E2E testing (`playwright.config.js`)

**Build/Dev:**
- Vite - Bundling (via VitePress)
- VitePress - Build and dev server

## Key Dependencies

**Critical:**
- `@supabase/supabase-js` 2.53.0 - Database, auth, storage client (`.vitepress/theme/composables/useSupabase.js`)
- `docx` 9.5.1 - Word document generation for assessments
- `docx-preview` 0.3.6 - Document preview functionality
- `file-saver` 2.0.5 - Client-side file downloads

**Infrastructure:**
- `@heroicons/vue` 2.2.0 - Icon library for UI components
- `dotenv` 17.2.1 - Environment variable loading

## Configuration

**Environment:**
- `.env.local` - Local development configuration
- `.env.example` - Template for required env vars
- Required: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`

**Build:**
- `.vitepress/config.js` - VitePress site configuration
- `.prettierrc` - Code formatting rules
- `playwright.config.js` - E2E test configuration

## Platform Requirements

**Development:**
- Any platform with Node.js
- Supabase CLI for local database development
- PostgreSQL 17 (via Supabase local)

**Production:**
- Vercel - Static site hosting (`vercel.json`)
- Supabase Cloud - Database, Auth, Edge Functions, Storage
- Output: `.vitepress/dist` static files

---

*Stack analysis: 2026-01-16*
*Update after major dependency changes*
