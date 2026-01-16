# External Integrations

**Analysis Date:** 2026-01-16

## APIs & External Services

**Payment Processing:**
- Not detected - No Stripe or payment integration found

**Email/SMS:**
- Supabase Edge Function `email-assessment-report` - Email delivery for assessment reports
  - Location: `supabase/functions/email-assessment-report/index.ts`
  - Auth: Supabase service role key
  - Likely uses Supabase's built-in email or external service

**External APIs:**
- Not detected - No third-party API integrations found

## Data Storage

**Databases:**
- PostgreSQL on Supabase Cloud - Primary data store
  - Connection: `VITE_SUPABASE_URL` env var (via client SDK)
  - Client: `@supabase/supabase-js` 2.53.0
  - Singleton client: `.vitepress/theme/composables/useSupabase.js`
  - Admin client: `.vitepress/theme/composables/useAdminSupabase.js`
  - Local dev: PostgreSQL 17 via Supabase CLI (`supabase/config.toml`)
  - Migrations: `supabase/migrations/` (currently empty - schema via dashboard)

**File Storage:**
- Supabase Storage - Assessment PDFs and uploads
  - Client: Same `@supabase/supabase-js` SDK
  - Edge Functions interact with storage for PDF generation
  - Temp PDF cleanup: `supabase/functions/cleanup-temp-pdfs/index.ts`

**Caching:**
- VitePress build cache (`.vitepress/cache/`)
- No runtime caching service (Redis, etc.)

## Authentication & Identity

**Auth Provider:**
- Supabase Auth - Email/password authentication
  - Implementation: `@supabase/supabase-js` client SDK
  - Composable: `.vitepress/theme/composables/useAuth.js`
  - Token storage: Handled by Supabase client (localStorage)
  - Session management: Supabase JWT with automatic refresh

**Beta Access Control:**
- Custom metadata-based access control
  - Implementation: `.vitepress/theme/composables/useBetaAccess.js`
  - Beta flag stored in user metadata
  - Restricts assessment access to approved users

**Admin Session:**
- Enhanced admin permissions
  - Implementation: `.vitepress/theme/composables/useAdminSession.js`
  - Separate admin role checking

**OAuth Integrations:**
- Not detected - Email/password only (OAuth could be added via Supabase)

## Monitoring & Observability

**Error Tracking:**
- Not detected - No Sentry or similar service
- Errors handled locally via `useUserFriendlyErrors.js`

**Analytics:**
- Google Analytics (partially implemented)
  - Composable: `.vitepress/theme/composables/useAnalytics.js`
  - Component: `.vitepress/theme/components/GoogleAnalytics.vue`
  - Status: Commented out in `.vitepress/config.js` (GA ID placeholder)

**Logs:**
- Console logging only (development)
- Vercel function logs (production)
- No centralized logging service

## CI/CD & Deployment

**Hosting:**
- Vercel - VitePress static site
  - Config: `vercel.json`
  - Build command: `npm run build`
  - Output: `.vitepress/dist`
  - Deployment: Automatic on git push (assumed)

**Backend Hosting:**
- Supabase Cloud - Edge Functions
  - Deploy via Supabase CLI: `supabase functions deploy`
  - Functions: `supabase/functions/*/index.ts`

**CI Pipeline:**
- Not detected - No GitHub Actions or similar config
- Vercel likely handles build/deploy

## Environment Configuration

**Development:**
- Required env vars: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`
- Secrets location: `.env.local` (gitignored)
- Template: `.env.example`
- Supabase local: `supabase start` for local PostgreSQL + Auth

**Edge Functions:**
- Separate `.env` in `supabase/functions/`
- Service role key for elevated permissions
- Template: `supabase/functions/.env.example`

**Production:**
- Secrets management: Vercel environment variables (for frontend)
- Supabase dashboard: Project settings for backend secrets
- Production Supabase project separate from development

## Webhooks & Callbacks

**Incoming:**
- Not detected - No webhook endpoints found

**Outgoing:**
- Not detected - No outgoing webhook configuration

## Edge Functions Summary

| Function | Purpose | Location |
|----------|---------|----------|
| `generate-pdf-report` | Create assessment PDF reports | `supabase/functions/generate-pdf-report/index.ts` |
| `download-assessment-pdf` | Serve PDF downloads | `supabase/functions/download-assessment-pdf/index.ts` |
| `email-assessment-report` | Email assessment results | `supabase/functions/email-assessment-report/index.ts` |
| `generate-assessment-data` | Generate assessment content | `supabase/functions/generate-assessment-data/index.ts` |
| `generate-question-analysis-report` | Analyze question performance | `supabase/functions/generate-question-analysis-report/index.ts` |
| `audit-database` | Database health checks | `supabase/functions/audit-database/index.ts` |
| `database-audit` | Additional DB auditing | `supabase/functions/database-audit/index.ts` |
| `cleanup-temp-pdfs` | Remove temporary PDF files | `supabase/functions/cleanup-temp-pdfs/index.ts` |
| `execute-cleanup` | General cleanup tasks | `supabase/functions/execute-cleanup/index.ts` |

---

*Integration audit: 2026-01-16*
*Update when adding/removing external services*
