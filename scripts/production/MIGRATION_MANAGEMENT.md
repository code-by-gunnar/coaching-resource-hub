# Database Migration Management

## Overview

This document explains how to manage database migrations for production deployment and keep consolidated migration scripts updated.

## Current Migration Scripts

### ADMIN_HUB_MIGRATION_20250814.sql
- **Date**: August 14, 2025  
- **Purpose**: Admin hub database schema updates
- **Changes**:
  - Updated `learning_path_categories` to use `assessment_level_id` foreign key
  - Removed hardcoded assessment level mapping
  - Fixed learning paths function for dynamic assessment levels
  - Proper relational structure throughout admin interface

## Process for Creating New Migration Scripts

### 1. When Making Database Changes

Every time you make database changes during development:

1. **Document the Change**: Note what tables/functions/data are being modified
2. **Test Locally**: Ensure the change works in your local environment  
3. **Add to Migration Script**: Update the appropriate production migration script

### 2. Creating New Migration Scripts

When starting a new major feature or significant database changes:

1. **Create New Script**: `FEATURE_NAME_MIGRATION_YYYYMMDD.sql`
2. **Follow Template**:
   ```sql
   -- =====================================================================================
   -- FEATURE NAME MIGRATION - Month DD, YYYY
   -- =====================================================================================
   -- 
   -- Description of what this migration does
   --
   -- Changes included:
   -- 1. List each major change
   -- 2. Be specific about tables/functions modified
   -- 3. Include data migration steps
   --
   -- =====================================================================================
   
   -- Step 1: Schema changes
   -- Step 2: Data migrations  
   -- Step 3: Function updates
   -- Step 4: Verification queries
   -- Step 5: Rollback plan
   ```

### 3. Updating Existing Migration Scripts

When adding to an existing feature migration:

1. **Update the Script**: Add new changes to the appropriate section
2. **Update Change Log**: Add the new changes to the "Changes included" list
3. **Update Verification**: Add verification queries for new changes
4. **Test Full Script**: Ensure the entire script still works from scratch

## Production Deployment Process

### 1. Pre-Deployment
- [ ] Review the migration script thoroughly
- [ ] Test the script on a production-like database
- [ ] Backup production database  
- [ ] Verify rollback plan is ready

### 2. Deployment
- [ ] Run migration script in production
- [ ] Run verification queries
- [ ] Test application functionality
- [ ] Monitor for errors

### 3. Post-Deployment  
- [ ] Document deployment in this file
- [ ] Update production database documentation
- [ ] Archive old migration files if needed

## Migration Script Maintenance

### Keep Scripts Updated

**Every time you run a Supabase migration during development:**

1. Check if it affects an existing production migration script
2. Add the equivalent SQL to the production script
3. Test the consolidated script still works
4. Update the change log in the script comments

### Example Development → Production Flow

1. **Development**: `npx supabase migration new fix_user_table`
2. **Local Testing**: `npx supabase migration up --local`  
3. **Update Production Script**: Add equivalent SQL to `FEATURE_MIGRATION_YYYYMMDD.sql`
4. **Test**: Run full production script against test database
5. **Document**: Update change log and verification queries

## Current Status

### Applied Migrations
- ✅ **ADMIN_HUB_MIGRATION_20250814.sql** - Ready for production
  - Contains all admin hub database changes
  - Tested and verified in development
  - Includes rollback plan

### Pending Migrations
- None currently

## Best Practices

1. **Always Include Rollback Plans**: Every migration should have a rollback strategy
2. **Test Thoroughly**: Run migration scripts on fresh databases to ensure they work
3. **Document Everything**: Include clear comments explaining what each step does
4. **Verify Results**: Include verification queries to confirm migration success
5. **Keep History**: Don't delete old migration scripts, archive them
6. **Version Control**: All migration scripts should be in git with clear commit messages

## Emergency Rollback

If you need to quickly rollback changes in production:

1. **Stop Application**: Prevent new database writes
2. **Run Rollback SQL**: Each migration script includes rollback steps
3. **Restore Backup**: If rollback SQL doesn't work, restore from backup
4. **Test Application**: Verify application works with rolled-back schema
5. **Document Incident**: Record what happened and lessons learned