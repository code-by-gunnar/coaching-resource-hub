# 🚀 PRODUCTION DEPLOYMENT CHECKLIST

## Overview
Complete production deployment checklist for the Coaching Resource Hub database migration and edge function updates. This ensures zero-downtime deployment with full performance optimizations.

---

## 🗂️ **PRE-DEPLOYMENT PREPARATION**

### ✅ Environment Validation
- [ ] **Production database password available**: `ghy@jue1vdg2EJV@dct`
- [ ] **Supabase CLI configured** with production credentials
- [ ] **Environment variables set**:
  ```bash
  export SUPABASE_ACCESS_TOKEN=sbp_2516261a0bb974c4d4d6a32c1a3bd725efa815e4
  export SUPABASE_PROJECT_REF=hfmpacbmbyvnupzgorek
  ```
- [ ] **Service role key accessible** for testing
- [ ] **Database backup taken** (safety measure)

### ✅ File Preparation
- [ ] **Migration script ready**: `scripts/production/PRODUCTION_MIGRATION_FINAL.sql`
- [ ] **Edge function guide ready**: `scripts/production/EDGE_FUNCTIONS_DEPLOYMENT.md` 
- [ ] **This checklist printed/accessible** during deployment

### ✅ Team Coordination
- [ ] **Maintenance window scheduled** (optional - migration designed for zero downtime)
- [ ] **Team notified** of deployment timeline
- [ ] **Rollback plan confirmed** (migration is reversible)

---

## 🗄️ **DATABASE MIGRATION DEPLOYMENT**

### Step 1: Connect to Production Database
```bash
# Test connection first
psql "postgresql://postgres.hfmpacbmbyvnupzgorek:ghy@jue1vdg2EJV@dct@aws-0-us-west-1.pooler.supabase.com:6543/postgres" -c "SELECT current_database(), current_user;"
```
- [ ] **Connection successful**
- [ ] **Database name confirmed**: `postgres`
- [ ] **User permissions verified**: `postgres`

### Step 2: Pre-Migration Validation
```bash
# Check current schema state
psql "postgresql://postgres.hfmpacbmbyvnupzgorek:ghy@jue1vdg2EJV@dct@aws-0-us-west-1.pooler.supabase.com:6543/postgres" -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';"
```
- [ ] **Current table count recorded**: `_____` tables
- [ ] **No active long-running queries** (check `pg_stat_activity`)
- [ ] **Sufficient database storage** available

### Step 3: Execute Migration
```bash
# Deploy the complete migration
psql "postgresql://postgres.hfmpacbmbyvnupzgorek:ghy@jue1vdg2EJV@dct@aws-0-us-west-1.pooler.supabase.com:6543/postgres" -f scripts/production/PRODUCTION_MIGRATION_FINAL.sql
```
- [ ] **Migration started successfully** (no immediate errors)
- [ ] **Migration completed** (watch for "Migration completed successfully!" message)
- [ ] **No ERROR messages** in output
- [ ] **Performance optimizations applied** message visible
- [ ] **Security fixes implemented** message visible

### Step 4: Post-Migration Validation
```bash
# Verify table structure
psql "postgresql://postgres.hfmpacbmbyvnupzgorek:ghy@jue1vdg2EJV@dct@aws-0-us-west-1.pooler.supabase.com:6543/postgres" -c "
SELECT COUNT(*) as total_tables FROM information_schema.tables WHERE table_schema = 'public';
SELECT COUNT(*) as total_indexes FROM pg_indexes WHERE schemaname = 'public';  
SELECT COUNT(*) as total_functions FROM pg_proc WHERE pronamespace = 'public'::regnamespace;
"
```
- [ ] **Table count**: `_____` (should be ~23)
- [ ] **Index count**: `_____` (should be ~95+) 
- [ ] **Function count**: `_____` (should be ~4+)

---

## 🔧 **EDGE FUNCTIONS DEPLOYMENT**

### Step 1: Deploy Core Functions (Required)
```bash
# Deploy critical assessment functions
npx supabase functions deploy generate-pdf-report --project-ref=hfmpacbmbyvnupzgorek
npx supabase functions deploy email-assessment-report --project-ref=hfmpacbmbyvnupzgorek
npx supabase functions deploy generate-question-analysis-report --project-ref=hfmpacbmbyvnupzgorek
npx supabase functions deploy cleanup-temp-pdfs --project-ref=hfmpacbmbyvnupzgorek
npx supabase functions deploy download-assessment-pdf --project-ref=hfmpacbmbyvnupzgorek
```
- [ ] **generate-pdf-report**: Deployed successfully
- [ ] **email-assessment-report**: Deployed successfully  
- [ ] **generate-question-analysis-report**: Deployed successfully
- [ ] **cleanup-temp-pdfs**: Deployed successfully
- [ ] **download-assessment-pdf**: Deployed successfully

---

## 🧪 **END-TO-END TESTING**

### Test Core Assessment Flow (Use Real Attempt ID)
```bash
# Test PDF generation
curl -X POST "https://hfmpacbmbyvnupzgorek.supabase.co/functions/v1/generate-pdf-report" \
  -H "Authorization: Bearer [SERVICE_ROLE_KEY]" \
  -H "Content-Type: application/json" \
  -d '{"attemptId": "[REAL_ATTEMPT_ID]", "assessmentData": {"overall_stats": {"score": 80}, "assessment_framework": "core"}}'
```
- [ ] **PDF generation successful**
- [ ] **Returns valid download URL**
- [ ] **PDF contains competency data** (not "Unknown")

---

## 🎯 **PERFORMANCE VALIDATION**

### Critical Performance Metrics
- [ ] **Assessment loading**: Page loads in < 2 seconds
- [ ] **PDF generation**: Completes in < 10 seconds
- [ ] **Email delivery**: Completes in < 30 seconds
- [ ] **Question analysis**: Generates in < 15 seconds

---

## ✅ **DEPLOYMENT COMPLETION**

### Final Validation
- [ ] **All core functions working** in production
- [ ] **Assessment flow end-to-end tested**
- [ ] **Performance benchmarks met** or exceeded
- [ ] **Security measures validated**
- [ ] **Team notified** of successful deployment

---

## 📝 **DEPLOYMENT NOTES**

### Deployment Date: `__________`
### Deployed By: `__________`
### Migration Duration: `__________`
### Edge Function Deployment Duration: `__________`

### Issues Encountered:
```
_________________________________
_________________________________
_________________________________
```

### Performance Improvements Observed:
```
_________________________________
_________________________________  
_________________________________
```

---

## 🎉 **DEPLOYMENT COMPLETE!**

**Your coaching resource hub is now:**
- **🚀 Performance Optimized** - 21 new indexes, RLS optimized
- **🔒 Security Hardened** - Search paths secured, policies consolidated  
- **📊 Data Normalized** - Clean schema with proper FK relationships
- **⚡ Scale Ready** - Optimized for high user volumes
- **🎯 Feature Complete** - All assessment flows operational

**The system is production-ready and enterprise-grade!** 🏆