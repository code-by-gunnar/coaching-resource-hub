# Database Scripts

## ⚠️ Script Categories

- **PRODUCTION**: Scripts for production deployment (use with extreme caution)
- **DEVELOPMENT**: Scripts for dev environment setup and testing
- **UTILITY**: Helper scripts for database management

## Production Scripts (USE WITH CAUTION)

### 🚨 `production_normalization.sql`
- **Purpose**: Creates all normalization tables needed for dynamic content generation
- **When to run**: ONCE on production after thorough testing in dev
- **Creates**: 9 normalization tables + RPC functions + indexes
- **Safe**: Uses IF NOT EXISTS, won't overwrite existing data

### 📊 `production_data_population.sql`
- **Purpose**: Populates normalization tables with production-ready content
- **When to run**: After running production_normalization.sql
- **Populates**: Display names, strategic actions, performance insights, learning resources
- **Safe**: Uses ON CONFLICT DO NOTHING

### 🔍 `check_production_changes.sql`
- **Purpose**: Verifies current production database state
- **When to run**: BEFORE applying any production changes
- **Checks**: Existing tables, Testing123 data, user activity
- **Output**: Safety status for proceeding with normalization

## Development Scripts

### 🔧 `complete_normalized_database_setup.sql`
- **Purpose**: Complete dev environment setup with all tables and test data
- **When to run**: Setting up new dev environment
- **Includes**: All tables, functions, indexes, and Testing123 test data

### 🎯 `implement_dynamic_generation_tables.sql`
- **Purpose**: Creates dynamic generation tables for Testing123 validation
- **When to run**: When testing dynamic content generation
- **Creates**: Tables and Testing123-specific test data

### 📚 `complete_skill_tags_population.sql`
- **Purpose**: Populates skill tags and related tables
- **When to run**: After normalization tables are created
- **Populates**: Skill tags, insights, and actions

### 🗂️ `create_learning_path_categories.sql`
- **Purpose**: Creates and populates learning path categories
- **When to run**: Setting up learning resources system
- **Creates**: Categories and learning resources

## Utility Scripts

### 🔄 `restore_dev_from_prod.sql`
- **Purpose**: Restores dev database from production backup
- **When to run**: When dev database needs fresh production data
- **Note**: Includes all fixes and updates applied during development

### ⚙️ `restore_dev_database.bat` / `restore_dev_database.sh`
- **Purpose**: Automated dev database restoration scripts
- **Platform**: .bat for Windows, .sh for Unix/Mac
- **Usage**: Run to quickly restore dev database

### 📝 `add_question_tracking.sql`
- **Purpose**: Adds question tracking fields to assessment tables
- **When to run**: If tracking detailed question metadata
- **Adds**: Additional tracking columns

## Workflow

### For Production Deployment:
1. Run `check_production_changes.sql` to verify state
2. If safe, run `production_normalization.sql`
3. Run `production_data_population.sql`
4. Verify with queries in check script

### For Dev Environment:
1. Run `complete_normalized_database_setup.sql` for full setup
2. Or use `restore_dev_from_prod.sql` for production mirror
3. Use individual scripts for specific features

## Important Notes

- **NEVER** run Testing123 scripts on production
- Always backup before running production scripts
- Test everything in dev first
- Production scripts are idempotent (safe to re-run)

## 📊 What Gets Restored (Dev Scripts)

### Assessments (9 total)
- **Core Framework:** Beginner, Intermediate, Advanced
- **ICF Framework:** Beginner, Intermediate, Advanced  
- **AC Framework:** Beginner, Intermediate, Advanced

### Sample Data
- 20 complete questions for Core Beginner assessment
- All other assessments ready for additional questions

### Database Functions (Fixed)
- `calculate_assessment_score()` - No ambiguous column references
- `auto_calculate_score()` - Trigger function for score calculation
- `check_answer_correctness()` - Validates answers automatically
- `update_updated_at_column()` - Timestamp maintenance

### Bug Fixes Applied
- ✅ Assessment status constraint: `'started'` (not `'in_progress'`)
- ✅ Fixed scoring calculation with proper variable names
- ✅ Answer format: A,B,C,D letters (not indices)
- ✅ All foreign key relationships working
- ✅ Proper RLS policies for data security

## 🚀 Development Workflow

1. **Initial Setup:** Run restoration script once
2. **Daily Development:** Work normally with your dev database
3. **When Production Changes:** Re-run restoration script to sync
4. **Testing:** Create test user via frontend, test assessments
5. **Before Deployment:** Verify dev matches expected production state

## 🛡️ Safety Features

- Scripts prompt for confirmation before destructive operations
- All operations are logged with clear success/failure messages
- Database reset only affects local development environment
- Production data is replicated without user accounts (for security)

## 🔍 Verification

After running restoration, verify with these queries:

```sql
-- Check assessments created
SELECT COUNT(*) FROM assessments;  -- Should be 9

-- Check sample questions  
SELECT COUNT(*) FROM assessment_questions 
WHERE assessment_id = '550e8400-e29b-41d4-a716-446655440001';  -- Should be 20

-- Verify functions exist
\df calculate_assessment_score

-- Check triggers
SELECT * FROM pg_trigger WHERE tgname LIKE '%calculate%';
```

## 📝 Adding More Questions

To add questions to other assessments:

```sql
-- Use this assessment ID template for each framework/difficulty:
-- Core Beginner:     550e8400-e29b-41d4-a716-446655440001
-- Core Intermediate: 550e8400-e29b-41d4-a716-446655440002  
-- Core Advanced:     550e8400-e29b-41d4-a716-446655440003
-- ICF Beginner:      550e8400-e29b-41d4-a716-446655440004
-- etc.

INSERT INTO assessment_questions (assessment_id, question_text, option_a, option_b, option_c, option_d, correct_answer, question_order) VALUES
('550e8400-e29b-41d4-a716-446655440002', 'Your question here...', 'Option A', 'Option B', 'Option C', 'Option D', 'B', 1);
```

## 🆘 Troubleshooting

**"Database reset failed"**
- Check Supabase is running: `npx supabase status`
- Start if needed: `npx supabase start`

**"Restoration script not found"**  
- Verify you're in the project root directory
- Check file exists at `scripts/restore_dev_from_prod.sql`

**"Supabase CLI not found"**
- Install globally: `npm install -g supabase`
- Or use npx: `npx supabase`

**Permission errors (Linux/Mac)**
- Make script executable: `chmod +x scripts/restore_dev_database.sh`

## 📧 Support

If you encounter issues:
1. Check the console output for specific error messages
2. Verify all prerequisites are installed
3. Try running steps manually to isolate the issue
4. Check Supabase local instance is healthy: `npx supabase status`