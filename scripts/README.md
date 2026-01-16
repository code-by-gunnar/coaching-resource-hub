# Scripts Directory - Coaching Resource Hub

## Overview

This directory contains all database scripts, documentation, and utilities for the Coaching Resource Hub assessment system. Scripts are organized by purpose and production readiness.

## Directory Structure

```
scripts/
├── production/           # Production-ready deployment scripts
├── documentation/        # System documentation and guides
├── development/          # Development tools and utilities
├── archive/             # Legacy and superseded scripts
└── README.md            # This file
```

## Production Scripts 📦

### Core Production Deployment
- **`production/PROD_DEPLOYMENT_COMPLETE.sql`** - Complete production deployment script
  - Creates all tables, schema, and base data
  - Includes Core I assessment with 15 questions
  - Sets up learning resources and competency mappings
  - **Usage**: Run this first for fresh production deployment

- **`production/CORE_I_DATA_POPULATION.sql`** - Complete data population for Core I
  - Populates all 34 skill tag insights (17 skills × 2 types)
  - Adds all 17 skill tag actionable steps
  - Includes verification queries
  - **Usage**: Run after PROD_DEPLOYMENT_COMPLETE.sql

- **`production/restore_dev_from_prod.sql`** - Development environment restoration
  - Restores development database to production state
  - Includes all fixes and data corrections
  - **Usage**: For emergency dev environment restoration

## Documentation 📚

### System Architecture
- **`documentation/CORE_I_SYSTEM_ARCHITECTURE_DOCUMENTATION.md`** - Complete system documentation
  - Comprehensive technical architecture documentation
  - Database schema, frontend architecture, performance considerations
  - Security implementation and deployment procedures
  - **Audience**: Developers, system administrators, technical stakeholders

### Implementation Guides  
- **`documentation/ASSESSMENT_CREATION_WORKFLOW.md`** - Future assessment implementation guide
  - Step-by-step workflow for creating new assessments
  - Core II, Core III, ICF, and AC implementation guidance
  - Quality standards and testing procedures
  - **Audience**: Developers implementing new assessment levels

- **`documentation/README.md`** - Original scripts documentation
  - Legacy documentation from initial development
  - **Status**: Superseded by architecture documentation

## Development Tools 🔧

### Testing Utilities
- **`development/testing/generate_test_patterns.js`** - Test data generation utility
  - Generates test patterns for assessment validation
  - **Usage**: Node.js utility for testing scenarios

### Database Utilities
- **`development/utilities/check_production_changes.sql`** - Production validation queries
  - Verifies database state and data integrity
  - **Usage**: Run to validate production deployment success

- **`development/utilities/restore_dev_database.sh`** - Linux development restoration script
- **`development/utilities/restore_dev_database.bat`** - Windows development restoration script
  - **Usage**: Quick development environment restoration utilities

## Archive 🗃️

The `archive/` directory contains legacy scripts from the development process that have been superseded by the production scripts. These are kept for historical reference and debugging purposes but should not be used for new deployments.

### Notable Archived Scripts:
- `complete_normalized_database_setup.sql` - Early database setup (superseded by PROD_DEPLOYMENT)
- `fix_missing_tag_insights.sql` - Insight fixes (integrated into CORE_I_DATA_POPULATION)
- `populate_learning_resources*.sql` - Resource population iterations (integrated into PROD_DEPLOYMENT)
- Various `core_i_beginner_*.sql` files - Development iterations

## Quick Start Guide

### Fresh Production Deployment
```bash
# 1. Deploy base system and Core I assessment
psql -d your_database -f production/PROD_DEPLOYMENT_COMPLETE.sql

# 2. Populate all skill insights and actions
psql -d your_database -f production/CORE_I_DATA_POPULATION.sql

# 3. Verify deployment success
psql -d your_database -f development/utilities/check_production_changes.sql
```

### Development Environment Setup
```bash
# Option 1: Full production restoration
docker cp production/restore_dev_from_prod.sql supabase_db_coaching-resource-hub:/tmp/restore.sql
docker exec supabase_db_coaching-resource-hub psql -U postgres -d postgres -v ON_ERROR_STOP=0 -c "\i /tmp/restore.sql"

# Option 2: Use platform-specific utility
# Linux/Mac:
./development/utilities/restore_dev_database.sh

# Windows:
development/utilities/restore_dev_database.bat
```

## Script Dependencies

### Production Deployment Order
1. `production/PROD_DEPLOYMENT_COMPLETE.sql` (creates all infrastructure)
2. `production/CORE_I_DATA_POPULATION.sql` (populates insights/actions)
3. `development/utilities/check_production_changes.sql` (optional verification)

### Development Restoration
- Use `production/restore_dev_from_prod.sql` for complete restoration
- Use platform utilities for quick restoration with existing backups

## Maintenance

### Adding New Scripts
- **Production scripts**: Must be thoroughly tested and documented
- **Development utilities**: Should be clearly documented with usage instructions
- **Archive policy**: Scripts superseded by newer implementations go to archive/

### Script Naming Convention
- Production scripts: `[PURPOSE]_[SCOPE].sql` (e.g., `PROD_DEPLOYMENT_COMPLETE.sql`)
- Documentation: `[SUBJECT]_[TYPE].md` (e.g., `SYSTEM_ARCHITECTURE_DOCUMENTATION.md`)
- Development utilities: `[function]_[purpose].sql/js/sh` (e.g., `check_production_changes.sql`)

### Version Control
- All scripts are version controlled with Git
- Use meaningful commit messages for script changes
- Tag major production releases
- Document breaking changes in commit messages

## Support

### Script Issues
- Check the documentation/ directory for implementation guidance
- Review archived scripts for historical context
- Verify script execution order and dependencies

### Development Environment Issues
- Use `production/restore_dev_from_prod.sql` for clean restoration
- Check platform-specific utilities in `development/utilities/`
- Verify environment variables and database connections

### Production Deployment Issues
- Follow the Quick Start Guide deployment order
- Run verification queries after each major script
- Check database logs for error details
- Ensure all foreign key relationships are properly established

## Current System Status

- ✅ **Core I Assessment**: Production ready with complete data population
- 🚧 **Core II Assessment**: Planned - use ASSESSMENT_CREATION_WORKFLOW.md
- 🚧 **Core III Assessment**: Planned - use ASSESSMENT_CREATION_WORKFLOW.md
- 🚧 **ICF Assessments**: Planned - use ASSESSMENT_CREATION_WORKFLOW.md  
- 🚧 **AC Assessments**: Planned - use ASSESSMENT_CREATION_WORKFLOW.md

---

**Last Updated**: January 2025  
**Production Ready**: Core I Assessment System  
**Architecture Version**: 2.0 - Multi-level assessment framework