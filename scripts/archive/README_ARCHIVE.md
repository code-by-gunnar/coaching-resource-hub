# Archive Directory - Legacy Development Scripts

## ⚠️ CRITICAL WARNING
**ALL SCRIPTS IN THIS DIRECTORY ARE DEPRECATED AND OUTDATED**

- **DO NOT USE ANY SCRIPTS IN THIS ARCHIVE**
- **`restore_dev_from_prod.sql` has been REMOVED** (was dangerous and outdated)
- **Use modern migration-based approach instead** (see `/CLAUDE.md`)
- **For database changes, create migrations:** `npx supabase migration new`

## Purpose
This directory contains scripts from the development process that have been superseded by modern migration-based database management. These files are preserved for:
- Historical reference during debugging
- Understanding the development progression
- Recovering specific fixes if needed

## ⚠️ Important Notice
**DO NOT USE THESE SCRIPTS FOR NEW DEPLOYMENTS**

All functionality from these scripts has been integrated into the current production scripts:
- `../production/PROD_DEPLOYMENT_COMPLETE.sql`
- `../production/CORE_I_DATA_POPULATION.sql`

## Archived Scripts Inventory

### Database Setup Scripts (Superseded)
- `complete_normalized_database_setup.sql` - Early database architecture
- `complete_normalized_database_setup.sql.backup` - Backup of early setup
- `production_normalization.sql` - Database normalization iteration
- `implement_dynamic_generation_tables.sql` - Dynamic table implementation

### Assessment Data Scripts (Superseded)  
- `core_i_beginner_competency_data.sql` - Early competency data
- `core_i_beginner_real_assessment.sql` - Assessment implementation iteration
- `complete_skill_tags_population.sql` - Skill tag population iteration

### Insights & Actions Scripts (Superseded)
- `add_missing_skill_actions.sql` - Skill action additions
- `fix_missing_tag_insights.sql` - Tag insight fixes  
- `populate_missing_production_data.sql` - Production data fixes
- `populate_missing_production_data_fixed.sql` - Fixed production data

### Learning Resources Scripts (Superseded)
- `populate_learning_resources.sql` - Learning resource population
- `populate_learning_resources_fixed.sql` - Fixed resource population
- `consolidate_learning_resources.sql` - Resource consolidation
- `create_learning_path_categories.sql` - Learning path creation
- `create_learning_paths_function.sql` - Learning path function
- `create_competency_focused_learning_paths.sql` - Competency-focused paths

### Question & Answer Scripts (Superseded)
- `final_answer_balance.sql` - Answer distribution balancing
- `fix_answer_distribution.sql` - Answer distribution fixes
- `add_question_tracking.sql` - Question tracking implementation

### Testing & Validation Scripts (Superseded)
- `clear_testing123_and_prepare.sql` - Test data cleanup
- `production_data_population.sql` - Production data population iteration

## Integration Status

All useful functionality from these archived scripts has been integrated into:

### `production/PROD_DEPLOYMENT_COMPLETE.sql` includes:
- Complete database schema setup
- Assessment creation and question population
- Skill tags and competency mappings
- Learning resources and categories
- All database functions and constraints

### `production/CORE_I_DATA_POPULATION.sql` includes:
- All skill tag insights (weakness + strength)
- All skill tag actionable steps
- Complete data population for Core I assessment
- Verification queries

## Recovery Guidance

If you need to reference specific implementations from the development process:

1. **Database Schema Questions**: Review `complete_normalized_database_setup.sql`
2. **Learning Resource Structure**: Review `populate_learning_resources*.sql` files
3. **Assessment Question Logic**: Review `core_i_beginner_real_assessment.sql`
4. **Data Fix Patterns**: Review `fix_missing_tag_insights.sql` and related files

## Historical Context

These scripts represent the iterative development process of the Core I assessment system from:
- Initial database design → Final normalized architecture
- Hardcoded frontend data → Database-driven dynamic content
- Single assessment → Multi-level assessment framework
- Basic error handling → User-friendly error system

The evolution demonstrates the transformation from prototype to production-ready system with proper architecture, security, and maintainability.

---

**Archive Date**: January 2025  
**Superseded By**: Production scripts v2.0  
**Purpose**: Historical reference and debugging support