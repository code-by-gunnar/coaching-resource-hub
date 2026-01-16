# Production Scripts Directory

## Current Production Scripts

### 🚨 Disaster Recovery Backups
- **`DISASTER_RECOVERY_BACKUPS.md`** - Complete backup documentation and restoration procedures
- **`COMPLETE_SCHEMA_BACKUP_20250812_184043.sql`** - Full database schema (47KB) 
- **`COMPLETE_DATA_BACKUP_20250812_184101.sql`** - All production data (84KB)
- **`ROLES_BACKUP_20250812_184032.sql`** - Database roles and permissions

### Database Fixes
- **`FIX_CORRECT_ANSWER_DATA_INTEGRITY.sql`** - Fixed questions with invalid `correct_answer=0` values and added database constraint (Applied: 2025-08-12)
- **`ADD_COMPETENCY_DESCRIPTIONS.sql`** - Add competency descriptions to database
- **`FIX_STRATEGIC_ACTIONS_SCORE_RANGES.sql`** - Fix strategic actions score ranges
- **`REDESIGN_PERFORMANCE_ANALYSIS_HIERARCHY.sql`** - Redesign performance analysis hierarchy
- **`REDESIGN_STRATEGIC_ACTIONS_IMMEDIATE.sql`** - Immediate strategic actions redesign
- **`UPDATE_PERFORMANCE_ANALYSIS_MESSAGING.sql`** - Update performance analysis messaging

### Data Backups
- **`EXACT_PRODUCTION_BACKUP_1TO1.sql`** - 1:1 production backup
- **`PRODUCTION_DATA_ONLY.sql`** - Production data only backup

## ⚠️ Important Notes

### Database Changes
**ALL database schema changes should now be done via migrations:**
```bash
# Create migration
npx supabase migration new descriptive_name

# Edit the migration file with your SQL changes

# Test locally  
npx supabase migration up --local

# Deploy to production
npx supabase db push --linked
```

### Script Documentation
Each script in this directory should:
- Document what issue it fixes
- Include the date it was applied
- Show verification queries
- Be marked with application status (✅ APPLIED or ⏳ PENDING)

### Migration vs Script
- **Use migrations for**: Schema changes, function updates, constraints
- **Use scripts for**: One-time data fixes, documentation, backup references

## Recent Fixes Applied

### 2025-08-12: Data Integrity Fix
**Issue**: Questions had `correct_answer=0` causing "Option 0" bugs in PDFs
**Fix**: `FIX_CORRECT_ANSWER_DATA_INTEGRITY.sql` 
**Migration**: `20250812173111_add_correct_answer_constraint.sql`
**Status**: ✅ APPLIED TO PRODUCTION

Fixed 3 questions and added database constraint to prevent future occurrences.