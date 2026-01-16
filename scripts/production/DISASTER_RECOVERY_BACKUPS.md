# Disaster Recovery Backups - August 12, 2025

## Complete Database Backup Set

Created after fixing database integrity issues and achieving stable production state.

### Backup Files

#### 1. Complete Schema Backup
**File**: `COMPLETE_SCHEMA_BACKUP_20250812_184043.sql` (47KB)
**Contains**:
- All database tables and columns
- All functions and stored procedures  
- All triggers and constraints
- All indexes and sequences
- Row Level Security (RLS) policies
- Database extensions and settings
- **Does NOT contain data rows**

#### 2. Complete Data Backup  
**File**: `COMPLETE_DATA_BACKUP_20250812_184101.sql` (84KB)
**Contains**:
- All table data (INSERT statements)
- User accounts and assessment attempts
- Questions, answers, and competency data
- Learning resources and performance analysis
- **Does NOT contain schema/structure**

#### 3. Database Roles Backup
**File**: `ROLES_BACKUP_20250812_184032.sql` (297 bytes)
**Contains**:
- Database user roles and permissions
- Access controls and security settings

## Database State at Backup Time

### Recent Fixes Applied ✅
- **Data Integrity**: Fixed 3 questions with `correct_answer=0` → proper 1-4 values
- **Database Constraint**: Added check constraint to prevent future `correct_answer` issues  
- **PDF Generation**: Fixed "Option 0" bugs and incorrect answer mappings
- **Question Analysis**: Enhanced PDF reports with proper A4 formatting
- **Authentication**: Resolved JWT and storage API issues

### Production Quality Confirmed ✅
- All Edge Functions working (email, main PDF, question analysis PDF)
- Database integrity validated with constraints
- Assessment system fully functional
- Test user exists: `test@coaching-hub.local` / `test123456`

## Disaster Recovery Usage

### Full Database Restoration (Emergency Only)

```bash
# 1. Reset local database (if needed)
npx supabase db reset --local

# 2. Restore schema first
cat scripts/production/COMPLETE_SCHEMA_BACKUP_20250812_184043.sql | \
  docker exec -i supabase_db_coaching-resource-hub psql -U postgres -d postgres

# 3. Restore data
cat scripts/production/COMPLETE_DATA_BACKUP_20250812_184101.sql | \
  docker exec -i supabase_db_coaching-resource-hub psql -U postgres -d postgres

# 4. Restore roles (if needed)
cat scripts/production/ROLES_BACKUP_20250812_184032.sql | \
  docker exec -i supabase_db_coaching-resource-hub psql -U postgres -d postgres
```

### Schema-Only Restoration
For development environment setup without production data:
```bash
cat scripts/production/COMPLETE_SCHEMA_BACKUP_20250812_184043.sql | \
  docker exec -i supabase_db_coaching-resource-hub psql -U postgres -d postgres
```

### Data-Only Restoration  
To refresh data in existing schema:
```bash
cat scripts/production/COMPLETE_DATA_BACKUP_20250812_184101.sql | \
  docker exec -i supabase_db_coaching-resource-hub psql -U postgres -d postgres
```

## Production Deployment to New Environment

For deploying to a completely new environment:

```bash
# 1. Set up Supabase project
npx supabase init
npx supabase start

# 2. Apply schema
cat scripts/production/COMPLETE_SCHEMA_BACKUP_20250812_184043.sql | \
  docker exec -i supabase_db_coaching-resource-hub psql -U postgres -d postgres

# 3. Apply data  
cat scripts/production/COMPLETE_DATA_BACKUP_20250812_184101.sql | \
  docker exec -i supabase_db_coaching-resource-hub psql -U postgres -d postgres

# 4. Deploy Edge Functions (NOT included in database backup)
npx supabase functions deploy generate-pdf-report
npx supabase functions deploy generate-question-analysis-report  
npx supabase functions deploy email-assessment-report

# Note: Edge Functions are separate TypeScript/Deno files, not database objects
# They exist in: supabase/functions/ directory

# 5. Set up environment variables
# Copy .env.local with API keys (Resend, PDFShift, etc.)
```

## Backup Verification

### Schema Verification
```sql
-- Verify all main tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Verify constraint was applied
SELECT conname FROM pg_constraint 
WHERE conname = 'check_correct_answer_range';
```

### Data Verification  
```sql
-- Verify question data integrity
SELECT COUNT(*) as total_questions,
       COUNT(*) FILTER (WHERE correct_answer BETWEEN 1 AND 4) as valid_answers,
       COUNT(*) FILTER (WHERE correct_answer < 1 OR correct_answer > 4) as invalid_answers
FROM assessment_questions;

-- Should show: invalid_answers = 0

-- Verify test user exists
SELECT email FROM auth.users WHERE email = 'test@coaching-hub.local';
```

## Backup Schedule Recommendation

**After Major Changes**:
- Database schema modifications
- Critical bug fixes  
- Production deployments
- Data integrity improvements

**Command to Create Fresh Backups**:
```bash
# Schema backup
npx supabase db dump --linked -p "ghy@jue1vdg2EJV@dct" \
  -f "scripts/production/COMPLETE_SCHEMA_BACKUP_$(date +%Y%m%d_%H%M%S).sql"

# Data backup  
npx supabase db dump --linked -p "ghy@jue1vdg2EJV@dct" --data-only \
  -f "scripts/production/COMPLETE_DATA_BACKUP_$(date +%Y%m%d_%H%M%S).sql"
```

---

**Created**: August 12, 2025  
**Database State**: Post-integrity fixes, production-ready  
**Next Backup**: After next major schema/data changes