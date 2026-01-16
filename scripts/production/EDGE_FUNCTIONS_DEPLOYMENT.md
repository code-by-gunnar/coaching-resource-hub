# Edge Functions Deployment Guide

## Overview
Edge functions must be deployed **manually** after database migration. They are not included in SQL migrations as they are TypeScript/JavaScript code that runs on Supabase's edge runtime.

## Prerequisites
- Database migration must be completed successfully
- Supabase CLI configured with production credentials
- Edge function environment variables set

## Environment Variables Setup

### Required Environment Variables
```bash
export SUPABASE_ACCESS_TOKEN=sbp_2516261a0bb974c4d4d6a32c1a3bd725efa815e4
export SUPABASE_PROJECT_REF=hfmpacbmbyvnupzgorek
```

### Production Database Password
```bash
# Used for migration deployment
PRODUCTION_DB_PASSWORD="ghy@jue1vdg2EJV@dct"
```

## Edge Functions to Deploy

### 1. Core Assessment Functions ✅ Working
```bash
# PDF Report Generation
npx supabase functions deploy generate-pdf-report --project-ref=hfmpacbmbyvnupzgorek

# Email Assessment Reports  
npx supabase functions deploy email-assessment-report --project-ref=hfmpacbmbyvnupzgorek

# Question Analysis Reports (FIXED - competency schema compatible)
npx supabase functions deploy generate-question-analysis-report --project-ref=hfmpacbmbyvnupzgorek
```

### 2. Utility Functions ✅ Working
```bash
# PDF Cleanup
npx supabase functions deploy cleanup-temp-pdfs --project-ref=hfmpacbmbyvnupzgorek

# PDF Download Handler
npx supabase functions deploy download-assessment-pdf --project-ref=hfmpacbmbyvnupzgorek
```

### 3. Development/Testing Function ⚠️ Needs Schema Update
```bash
# NOTE: This function uses OLD schema and should be updated before deployment
# Current status: BROKEN - references old 'competencies' and 'skills' tables
# npx supabase functions deploy generate-assessment-data --project-ref=hfmpacbmbyvnupzgorek
```

## Function Status and Dependencies

### ✅ Production Ready Functions
| Function | Status | Dependencies | Notes |
|----------|--------|--------------|-------|
| `generate-pdf-report` | ✅ Ready | New competency schema | Performance optimized |
| `email-assessment-report` | ✅ Ready | PDF function + SMTP | Includes both PDF reports |
| `generate-question-analysis-report` | ✅ Ready | New competency schema | **FIXED** - Uses competency_display_names |
| `cleanup-temp-pdfs` | ✅ Ready | None | Security optimized (search_path fixed) |
| `download-assessment-pdf` | ✅ Ready | Storage bucket | Token-based access |

### ⚠️ Functions Needing Updates
| Function | Status | Issue | Action Required |
|----------|--------|-------|-----------------|
| `generate-assessment-data` | ❌ Broken | Uses old schema tables | Update or deprecate before deployment |

## Deployment Commands

### Full Production Deployment
```bash
# Set environment variables
export SUPABASE_ACCESS_TOKEN=sbp_2516261a0bb974c4d4d6a32c1a3bd725efa815e4
export SUPABASE_PROJECT_REF=hfmpacbmbyvnupzgorek

# Deploy all working functions
npx supabase functions deploy generate-pdf-report --project-ref=hfmpacbmbyvnupzgorek
npx supabase functions deploy email-assessment-report --project-ref=hfmpacbmbyvnupzgorek  
npx supabase functions deploy generate-question-analysis-report --project-ref=hfmpacbmbyvnupzgorek
npx supabase functions deploy cleanup-temp-pdfs --project-ref=hfmpacbmbyvnupzgorek
npx supabase functions deploy download-assessment-pdf --project-ref=hfmpacbmbyvnupzgorek

# SKIP generate-assessment-data until schema is updated
```

### Single Function Deployment
```bash
# Deploy specific function with logging
npx supabase functions deploy FUNCTION_NAME --project-ref=hfmpacbmbyvnupzgorek --debug
```

## Post-Deployment Validation

### Test Core Assessment Flow
```bash
# Test PDF generation
curl -X POST "https://hfmpacbmbyvnupzgorek.supabase.co/functions/v1/generate-pdf-report" \
  -H "Authorization: Bearer [SERVICE_ROLE_KEY]" \
  -H "Content-Type: application/json" \
  -d '{"attemptId": "[REAL_ATTEMPT_ID]", "assessmentData": {...}}'

# Test email delivery  
curl -X POST "https://hfmpacbmbyvnupzgorek.supabase.co/functions/v1/email-assessment-report" \
  -H "Authorization: Bearer [SERVICE_ROLE_KEY]" \
  -H "Content-Type: application/json" \
  -d '{"attemptId": "[REAL_ATTEMPT_ID]", "userEmail": "test@example.com", ...}'

# Test question analysis
curl -X POST "https://hfmpacbmbyvnupzgorek.supabase.co/functions/v1/generate-question-analysis-report" \
  -H "Authorization: Bearer [SERVICE_ROLE_KEY]" \
  -H "Content-Type: application/json" \
  -d '{"attemptId": "[REAL_ATTEMPT_ID]", "assessmentData": {...}}'
```

### Verify Function Health
```bash
# Check function status
npx supabase functions list --project-ref=hfmpacbmbyvnupzgorek

# View function logs
npx supabase functions logs generate-pdf-report --project-ref=hfmpacbmbyvnupzgorek
npx supabase functions logs email-assessment-report --project-ref=hfmpacbmbyvnupzgorek
```

## Function Dependencies & Environment

### Required Environment Variables (Per Function)
- **PDF Generation**: Requires access to competency data and storage bucket
- **Email**: Requires SMTP credentials and PDF generation access
- **Question Analysis**: Requires assessment questions and competency relationships
- **Cleanup**: Requires storage bucket access for PDF deletion
- **Download**: Requires storage bucket and token validation

### Database Dependencies
All functions depend on:
- New normalized competency schema (`competency_display_names`)
- Proper FK relationships in assessment questions
- Performance indexes for query optimization
- Updated RLS policies for security

### Storage Dependencies
Functions requiring storage access:
- `generate-pdf-report` → Writes PDFs
- `generate-question-analysis-report` → Writes PDFs  
- `email-assessment-report` → Reads PDFs for attachment
- `cleanup-temp-pdfs` → Deletes expired PDFs
- `download-assessment-pdf` → Reads PDFs for download

## Troubleshooting

### Common Issues
1. **Function deployment fails**: Check environment variables and project ref
2. **Function runs but errors**: Check database schema compatibility  
3. **PDF generation fails**: Verify storage bucket permissions
4. **Email delivery fails**: Check SMTP configuration
5. **Performance issues**: Verify database indexes are created

### Debug Commands
```bash
# View function logs in real-time
npx supabase functions logs FUNCTION_NAME --project-ref=hfmpacbmbyvnupzgorek --follow

# Test function locally first
npx supabase functions serve FUNCTION_NAME

# Check function configuration
npx supabase functions inspect FUNCTION_NAME --project-ref=hfmpacbmbyvnupzgorek
```

## Security Notes
- All functions use service role authentication
- RLS policies apply to function database access
- PDF files have automatic expiration cleanup
- Download tokens provide secure file access

## Performance Considerations
- Functions now benefit from optimized database indexes
- RLS policies are performance-optimized for scale
- PDF generation includes caching mechanisms
- Email function includes rate limiting and retry logic

## Update generate-assessment-data Function (If Needed)

If you need to update the broken function, it requires:

### Schema Changes Required
```typescript
// OLD (broken)
.from('assessment_types')
.from('competencies')
.from('skills')
.from('skill_insights')

// NEW (should be)
.from('assessments')
.from('competency_display_names')
.from('frameworks')
.from('assessment_levels')
```

### Deployment After Fix
```bash
npx supabase functions deploy generate-assessment-data --project-ref=hfmpacbmbyvnupzgorek
```

---

## Summary
Deploy the 5 working functions immediately after database migration. The `generate-assessment-data` function can be updated later or deprecated if not needed in production.