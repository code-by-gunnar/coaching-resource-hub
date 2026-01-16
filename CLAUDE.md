# Claude Instructions for Coaching Resource Hub

## Development Server Management

**🚨 CRITICAL: CLAUDE MUST NEVER MANAGE DEV SERVER DIRECTLY 🚨**

**ABSOLUTELY FORBIDDEN - THESE COMMANDS WILL CRASH THE SYSTEM:**
- `npm run dev` - NEVER run this directly
- `pkill node` - NEVER kill dev server processes  
- `taskkill` - NEVER attempt to restart dev server
- Any command that starts/stops/restarts the development server

**ONLY THE USER should manage the dev server. If dev server needs to be started/stopped/restarted, ASK THE USER to do it.**

**For checking server status (READ-ONLY operations only):**

```bash
# Check if dev server is already running on localhost:5173
curl -s http://localhost:5173 > nul 2>&1 && echo "Dev server is already running on localhost:5173" || echo "Dev server is not running"
```

**Why this restriction:**
- Claude running `npm run dev` when server is already active breaks the terminal session
- Claude attempting to kill/restart dev server processes crashes the development environment
- Only the user has proper terminal control to safely manage the dev server

**If development server issues occur:** 
1. Inform the user about the issue
2. Ask the user to restart the dev server themselves
3. Never attempt to fix it directly

## Project Structure

### Assessment System Architecture

Current framework structure:
- **Core**: Beginner → Intermediate → Advanced  
- **ICF**: Beginner → Intermediate → Advanced
- **AC**: Beginner → Intermediate → Advanced

**9 total assessment variations**

### Composables Structure

```
.vitepress/theme/composables/
├── assessments/
│   ├── frameworks/
│   │   ├── core/
│   │   │   ├── useCoreBeginnerInsights.js
│   │   │   ├── useCoreIntermediateInsights.js
│   │   │   └── useCoreAdvancedInsights.js
│   │   ├── icf/
│   │   │   ├── useIcfBeginnerInsights.js
│   │   │   ├── useIcfIntermediateInsights.js
│   │   │   └── useIcfAdvancedInsights.js
│   │   └── ac/
│   │       ├── useAcBeginnerInsights.js
│   │       ├── useAcIntermediateInsights.js
│   │       └── useAcAdvancedInsights.js
│   ├── useAssessmentInsightsFactory.js (dynamic loader)
│   └── shared/
│       ├── useStrengthLeverageBase.js (common strength patterns)
│       └── useLearningResourcesBase.js (common resource types)
```

### Current Focus

- **Primary**: Core Beginner assessment functionality and results perfection
- **Next**: Field test with small user group before expanding
- **Future**: Build question library and launch other 8 assessment variations

## Content Standards & Language Guidelines

### Professional Coaching Language Requirements

**⚠️ CRITICAL: All content must use professional coaching terminology**

**APPROVED Coaching Terms:**
- "resourceful state" (not "wisdom" or "inner knowing")
- "awareness" and "insights" (not "profound truths" or "deep wisdom")
- "skills" and "capability" (not "mastery" unless truly exceptional)
- "powerful experiences" (not "transformational experiences")
- "breakthrough moments" (acceptable - common coaching term)
- "access their thinking" (not "tap into wisdom")
- "trust yourself" (not "inner voice whispers")

**FORBIDDEN Mystical/New Age Language:**
- ❌ "wisdom," "inner wisdom," "ancient wisdom"
- ❌ "profound truths," "deepest truths," "spiritual insights"
- ❌ "transformational," "transcendent," "mystical"
- ❌ "inner voice," "soul," "spirit," "divine"
- ❌ "chakras," "energy healing," "vibrations"
- ❌ "universe," "cosmic," "sacred"

### Strategic Actions Content Standards

**MUST BE:**
- **Immediately actionable** - coaches can use today
- **Concise** - 1-2 sentences maximum
- **Practical techniques** - specific methods, not theory
- **Professional language** - appropriate for business coaching
- **Original content** - not rehashing assessment scenarios

**MUST NOT BE:**
- **Explanatory or educational** - not mini-lectures
- **Assessment scenario references** - no "like Marcus" or "in Jennifer's case"
- **Overwhelming instructions** - no complex multi-step processes
- **Mystical or spiritual** - stick to evidence-based coaching
- **Repetitive** - each action must offer unique value

**EXAMPLES:**

✅ **Good Strategic Actions:**
- "Practice the pause: After client speaks, take a breath and ask yourself 'What am I sensing?'"
- "Use emotion labeling: 'It sounds like frustration' or 'I hear excitement.'"
- "Help them access their resourceful state: 'If you already knew the answer, what would it be?'"

❌ **Bad Strategic Actions:**
- "In scenarios like Marcus (juggling decisions + financial pressure), you missed emotional elements..."
- "Your listening mastery shines through with profound wisdom activation..."
- "Set a timer every 5 minutes to scan client's chakra energy and breathing patterns..."

### Performance Analysis Standards

**TONE REQUIREMENTS:**
- **Growth-oriented** - focus on development, not criticism
- **Encouraging** - acknowledge progress while identifying areas for growth
- **Specific** - reference actual coaching skills and behaviors
- **Professional** - maintain coaching industry credibility

**LANGUAGE REFINEMENTS:**
- "In the reviewed scenarios, key elements were missed..." (not "You failed all...")
- "This is a key development area..." (not "This is a major weakness...")
- "Your skills show promise with room for consistency..." (not "You're inconsistent and unreliable...")

### Content Development Process

**1. Content Creation:**
- Write for professional coaches, not coaching students
- Use ICF Core Competencies language where appropriate
- Focus on practical skill development
- Avoid assessment-specific references

**2. Language Review:**
- Check for mystical/spiritual terms → replace with coaching terms
- Ensure professional tone throughout
- Verify actionability of strategic actions
- Confirm content provides unique value

**3. Testing Standards:**
- Content must be immediately usable by practicing coaches
- Language must sound credible to coaching professionals
- Actions must be doable without special training or tools
- Insights must relate to real coaching challenges

**4. Feedback Integration:**
- Expert reviewers should find language appropriate and professional
- Beta users should find content immediately applicable
- No feedback about "weird" or "mystical" language
- Content should enhance coaching credibility, not detract from it

### Key Learnings from Competency Content Rebuild (August 2025)

**CRITICAL INSIGHTS:**

**1. Assessment-Skills Alignment Methodology**
- Strategic actions must be independent of assessment scenarios
- No references to "Marcus," "Sarah," "Jennifer," etc. from assessment questions
- Focus on skill development techniques, not assessment result explanations
- Each competency needs exactly 4 strategic actions for consistency

**2. Language Evolution Discovery**
- Initial content used mystical language ("wisdom," "inner voice")
- Professional coaching community found this "out there" and inappropriate
- Successful replacement: "resourceful state," "access their thinking," "trust yourself"
- Language must sound credible to ICF-certified professional coaches

**3. Practical vs. Theoretical Balance**
- Users want immediately actionable techniques, not explanations
- "Count your heartbeats to 15" = too weird and impractical
- "Take one deep breath before speaking" = natural and doable
- Strategic actions should integrate organically into coaching conversations

**4. Content Redundancy Issues**
- Performance analysis and strategic actions were overlapping
- Strategic actions were rehashing assessment content instead of providing new value
- Solution: Performance analysis = insights about performance, Strategic actions = techniques to improve
- Each piece of content must offer unique, non-repetitive value

**5. Technical Implementation Learnings**
- SQL scripts can fail due to special characters or quote escaping issues
- Large multi-INSERT statements can hit PostgreSQL parsing limits
- Breaking scripts into smaller transactions improves reliability
- Always include sort_order values for consistent frontend query results
- Fresh script creation often better than editing problematic existing scripts

**6. Content Volume Feedback**
- Beta users found 15 fields per competency "overwhelming"
- Recommended reduction to 2-3 key areas with consolidated information
- Quality over quantity approach more effective for busy coaching professionals
- Rich insights for PDFs also need simplification using same principles

**DEPLOYMENT BEST PRACTICES:**
- Always test individual components before running full scripts
- Use professional coaching terminology consistently
- Verify content is actionable and immediately applicable
- Ensure each content piece provides unique value
- Maintain current scoring system compatibility (70% threshold)
- Include proper SQL sort_order and transaction structure

## Database Management

**⚠️ CRITICAL: NEVER RESET THE DATABASE ⚠️**

**ABSOLUTELY FORBIDDEN:**
- `npx supabase db reset` - NEVER USE THIS
- Any command that drops/recreates the database
- Any command that deletes existing data

**ONLY USE SAFE DATABASE OPERATIONS:**
- `ALTER TABLE table_name ADD COLUMN ...` - Add columns
- `CREATE TABLE IF NOT EXISTS ...` - Create new tables safely  
- `INSERT INTO ...` - Add new data
- `UPDATE ... WHERE ...` - Update existing data
- `CREATE OR REPLACE FUNCTION ...` - Update functions
- `DROP TRIGGER IF EXISTS ... ; CREATE TRIGGER ...` - Update triggers
- `npx supabase db push --local` - Apply migrations safely

**Reason:** Resetting destroys all test data, user accounts, assessment progress, and forces recreation of the entire development environment. This wastes time and loses valuable development state.

**IF DATABASE RESET IS ABSOLUTELY UNAVOIDABLE (EMERGENCY ONLY):**

**Option 1: Modern migration-based approach (Recommended)**:

```bash
# 1. Reset (only if absolutely necessary)
npx supabase db reset --local

# 2. Apply all migrations to restore schema and data
npx supabase migration up --local

# 3. If migrations don't include production data, use Supabase data sync:
npx supabase db pull --data-only
```

**Modern Approach Benefits:**
- Migrations ensure consistent, repeatable database state
- Schema changes are tracked and versioned
- Safer than manual scripts - less risk of data corruption
- Automatic dependency management and ordering
- Production data can be synced separately when needed

**⚠️ CRITICAL: USE MIGRATIONS FOR ALL SCHEMA CHANGES ⚠️**

**ALL database fixes, schema changes, or function updates MUST be applied via migrations:**

- Create migration: `npx supabase migration new descriptive_name`
- Add your SQL changes to the migration file
- Test locally: `npx supabase migration up --local`
- Deploy to production: `npx supabase db push --linked`
- Document major fixes in `scripts/production/` for reference

**This ensures:**
- All changes are versioned and tracked
- Production deployments are reliable and repeatable
- Team members get consistent database state
- No manual script maintenance required

**Option 2: Disaster Recovery Backups (Complete restoration)**:

For complete system recovery with all production data and fixes:
```bash
# See: scripts/production/DISASTER_RECOVERY_BACKUPS.md
# Restores complete production database state from August 12, 2025
# Includes all fixes, data integrity improvements, and production data
```

## Development Test User

**After any database restore, create the standard test user:**

📧 **Email:** `test@coaching-hub.local`  
🔑 **Password:** `test123456`

**How to create:**
Use Supabase API to create user directly in auth.users:

```bash
# Create test user via Supabase API
npx supabase db shell --local
```

Then run in psql:
```sql
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'test@coaching-hub.local',
    crypt('test123456', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
);
```

**Why this specific user:**
- Consistent across all development environments
- Easy to remember credentials
- Local domain (.local) ensures it's dev-only
- Standard user for testing assessment flows

## Development Database Access

**For development database queries and updates via API:**

### Development Environment Details
**Base URL:** `https://woevhievwvqeritksxzl.supabase.co/rest/v1/`

**Service Role Key:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvZXZoaWV2d3ZxZXJpdGtzeHpsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTU1ODIxNSwiZXhwIjoyMDcxMTM0MjE1fQ.6UcH_jKukkgqaRRT1EvChS9lqwlqmXV2i5bgmxlqs4M`

**Headers required for all development requests:**
```bash
-H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvZXZoaWV2d3ZxZXJpdGtzeHpsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTU1ODIxNSwiZXhwIjoyMDcxMTM0MjE1fQ.6UcH_jKukkgqaRRT1EvChS9lqwlqmXV2i5bgmxlqs4M" 
-H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvZXZoaWV2d3ZxZXJpdGtzeHpsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTU1ODIxNSwiZXhwIjoyMDcxMTM0MjE1fQ.6UcH_jKukkgqaRRT1EvChS9lqwlqmXV2i5bgmxlqs4M"
-H "Content-Type: application/json"
```

### Development Operations

**Query development data:**
```bash
curl -X GET "https://woevhievwvqeritksxzl.supabase.co/rest/v1/table_name?select=column1,column2" \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvZXZoaWV2d3ZxZXJpdGtzeHpsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTU1ODIxNSwiZXhwIjoyMDcxMTM0MjE1fQ.6UcH_jKukkgqaRRT1EvChS9lqwlqmXV2i5bgmxlqs4M" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvZXZoaWV2d3ZxZXJpdGtzeHpsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTU1ODIxNSwiZXhwIjoyMDcxMTM0MjE1fQ.6UcH_jKukkgqaRRT1EvChS9lqwlqmXV2i5bgmxlqs4M"
```

**Update development data:**
```bash
curl -X PATCH "https://woevhievwvqeritksxzl.supabase.co/rest/v1/table_name?column=eq.value" \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvZXZoaWV2d3ZxZXJpdGtzeHpsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTU1ODIxNSwiZXhwIjoyMDcxMTM0MjE1fQ.6UcH_jKukkgqaRRT1EvChS9lqwlqmXV2i5bgmxlqs4M" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvZXZoaWV2d3ZxZXJpdGtzeHpsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTU1ODIxNSwiZXhwIjoyMDcxMTM0MjE1fQ.6UcH_jKukkgqaRRT1EvChS9lqwlqmXV2i5bgmxlqs4M" \
  -H "Content-Type: application/json" \
  -d '{"column_name": "new_value"}'
```

### Development Environment Variables
Set these before Supabase CLI operations:
```bash
export SUPABASE_ACCESS_TOKEN=sbp_2516261a0bb974c4d4d6a32c1a3bd725efa815e4
export SUPABASE_PROJECT_REF=woevhievwvqeritksxzl
```

## Production Database Access

**For direct production database queries and updates via API:**

### Authentication
Use service role key from production environment:
```bash
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmbXBhY2JtYnl2bnVwemdvcmVrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDIyNDMzMywiZXhwIjoyMDY5ODAwMzMzfQ.qjUKU7fGuV-Cseso8v5i6Ps-0YNtd7C5PVLVxp0NIvE
```

### REST API Access
**Base URL:** `https://hfmpacbmbyvnupzgorek.supabase.co/rest/v1/`

**Headers required for all requests:**
```bash
-H "apikey: [SERVICE_ROLE_KEY]" 
-H "Authorization: Bearer [SERVICE_ROLE_KEY]"
-H "Content-Type: application/json"
```

### Common Operations

**Query data:**
```bash
curl -X GET "https://hfmpacbmbyvnupzgorek.supabase.co/rest/v1/table_name?select=column1,column2" \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmbXBhY2JtYnl2bnVwemdvcmVrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDIyNDMzMywiZXhwIjoyMDY5ODAwMzMzfQ.qjUKU7fGuV-Cseso8v5i6Ps-0YNtd7C5PVLVxp0NIvE" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmbXBhY2JtYnl2bnVwemdvcmVrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDIyNDMzMywiZXhwIjoyMDY5ODAwMzMzfQ.qjUKU7fGuV-Cseso8v5i6Ps-0YNtd7C5PVLVxp0NIvE"
```

**Update data:**
```bash
curl -X PATCH "https://hfmpacbmbyvnupzgorek.supabase.co/rest/v1/table_name?column=eq.value" \
  -H "apikey: [SERVICE_ROLE_KEY]" \
  -H "Authorization: Bearer [SERVICE_ROLE_KEY]" \
  -H "Content-Type: application/json" \
  -d '{"column_name": "new_value"}'
```

### Schema Changes
**For schema changes (ADD COLUMN, etc.), use migrations:**
```bash
# 1. Create migration
npx supabase migration new migration_name

# 2. Edit the migration file with SQL changes

# 3. Push to production
npx supabase db push --linked --password "ghy@jue1vdg2EJV@dct"
```

**Production database password:** `ghy@jue1vdg2EJV@dct`

## Database Dump Commands

**For complete production database backup (you need PostgreSQL client tools installed):**

```bash
# Complete backup (schema + data) - RUN IN YOUR LOCAL ENVIRONMENT
pg_dump "postgresql://postgres.hfmpacbmbyvnupzgorek:ghy@jue1vdg2EJV@dct@aws-0-eu-west-2.pooler.supabase.com:6543/postgres" \
  --verbose --clean --if-exists --create --format=plain \
  --file="FINAL_COMPLETE_BACKUP_$(date +%Y%m%d).sql"

# Schema only backup
pg_dump "postgresql://postgres.hfmpacbmbyvnupzgorek:ghy@jue1vdg2EJV@dct@aws-0-eu-west-2.pooler.supabase.com:6543/postgres" \
  --verbose --schema-only --clean --if-exists --create \
  --file="SCHEMA_ONLY_$(date +%Y%m%d).sql"

# Data only backup  
pg_dump "postgresql://postgres.hfmpacbmbyvnupzgorek:ghy@jue1vdg2EJV@dct@aws-0-eu-west-2.pooler.supabase.com:6543/postgres" \
  --verbose --data-only \
  --file="DATA_ONLY_$(date +%Y%m%d).sql"
```

**Alternative if PostgreSQL tools not installed:**
- Install PostgreSQL client tools only (not full server)
- Use pgAdmin GUI tool for backup
- Download portable PostgreSQL client binaries

## Beta User Management

**Assessment system is now protected by beta user access control.**

**To create beta test accounts with assessment access:**

1. **Create user via Supabase dashboard Auth section** OR use SQL
2. **Add beta_user flag to user metadata:**

### Method 1: Auth Admin API (Recommended - SAFE)

**First, get user list to find user ID:**
```bash
curl -X GET "https://hfmpacbmbyvnupzgorek.supabase.co/auth/v1/admin/users" \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmbXBhY2JtYnl2bnVwemdvcmVrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDIyNDMzMywiZXhwIjoyMDY5ODAwMzMzfQ.qjUKU7fGuV-Cseso8v5i6Ps-0YNtd7C5PVLVxp0NIvE" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmbXBhY2JtYnl2bnVwemdvcmVrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDIyNDMzMywiZXhwIjoyMDY5ODAwMzMzfQ.qjUKU7fGuV-Cseso8v5i6Ps-0YNtd7C5PVLVxp0NIvE"
```

**Then update user with beta access (replace USER_ID):**
```bash
curl -X PUT "https://hfmpacbmbyvnupzgorek.supabase.co/auth/v1/admin/users/USER_ID" \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmbXBhY2JtYnl2bnVwemdvcmVrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDIyNDMzMywiZXhwIjoyMDY5ODAwMzMzfQ.qjUKU7fGuV-Cseso8v5i6Ps-0YNtd7C5PVLVxp0NIvE" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmbXBhY2JtYnl2bnVwemdvcmVrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDIyNDMzMywiZXhwIjoyMDY5ODAwMzMzfQ.qjUKU7fGuV-Cseso8v5i6Ps-0YNtd7C5PVLVxp0NIvE" \
  -H "Content-Type: application/json" \
  -d '{"user_metadata": {"beta_user": true}}'
```

### Method 2: Direct SQL (USE WITH CAUTION - BACKUP FIRST)

```sql
-- Update existing user's metadata to grant beta access
UPDATE auth.users 
SET raw_user_meta_data = raw_user_meta_data || '{"beta_user": true}'::jsonb
WHERE email = 'tester@example.com';
```

**Or create user directly with beta access:**
```sql
-- Insert user with beta access (use actual email addresses)
INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    email_confirmed_at, created_at, updated_at,
    raw_user_meta_data
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated', 'authenticated', 
    'tester@example.com',
    crypt('TestPassword123!', gen_salt('bf')),
    NOW(), NOW(), NOW(),
    '{"beta_user": true}'::jsonb
);
```

**Remove beta access:**
```sql
UPDATE auth.users 
SET raw_user_meta_data = raw_user_meta_data - 'beta_user'
WHERE email = 'tester@example.com';
```

**Non-beta users will see:** "Assessment System - In Beta" message with contact email for access request.

### Environment Variables
Set these before Supabase CLI operations:
```bash
export SUPABASE_ACCESS_TOKEN=sbp_2516261a0bb974c4d4d6a32c1a3bd725efa815e4
export SUPABASE_PROJECT_REF=hfmpacbmbyvnupzgorek
```

## Commands

- `npm run dev` - Start development server (CHECK FIRST!)
- `npm run build` - Build for production  
- `npm run lint` - Run linting
- `npm run typecheck` - Run type checking