#!/usr/bin/env node
/**
 * Database Connection Switcher
 * Easily switch between development and production database connections
 * 
 * Usage:
 *   node scripts/development/utilities/switch-db-connection.cjs dev
 *   node scripts/development/utilities/switch-db-connection.cjs prod
 * 
 * Targets:
 *   dev/development  - Development Supabase project (woevhievwvqeritksxzl)
 *   prod/production  - Production Supabase project (hfmpacbmbyvnupzgorek)
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const ENV_FILE = path.join(__dirname, '..', '..', '..', '.env.local');

// Database credentials
const DEV_DB_PASSWORD = 'tuq0fzu.dua2NXA5fgu\\';
const PROD_DB_PASSWORD = 'ghy@jue1vdg2EJV@dct';
const SUPABASE_ACCESS_TOKEN = 'sbp_2516261a0bb974c4d4d6a32c1a3bd725efa815e4';

const DEV_CONFIG = `# Development Database Configuration
# Development frontend connects to development Supabase instance

VITE_SUPABASE_URL=https://woevhievwvqeritksxzl.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvZXZoaWV2d3ZxZXJpdGtzeHpsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU1NTgyMTUsImV4cCI6MjA3MTEzNDIxNX0.kD-hSA8Xw_kpQdGvw8zJQzV2vY9n4HGF1dF5pXfG8j4
VITE_SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvZXZoaWV2d3ZxZXJpdGtzeHpsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTU1ODIxNSwiZXhwIjoyMDcxMTM0MjE1fQ.6UcH_jKukkgqaRRT1EvChS9lqwlqmXV2i5bgmxlqs4M

# Backend/CLI Configuration for Development 
SUPABASE_URL=https://woevhievwvqeritksxzl.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvZXZoaWV2d3ZxZXJpdGtzeHpsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU1NTgyMTUsImV4cCI6MjA3MTEzNDIxNX0.kD-hSA8Xw_kpQdGvw8zJQzV2vY9n4HGF1dF5pXfG8j4
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvZXZoaWV2d3ZxZXJpdGtzeHpsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTU1ODIxNSwiZXhwIjoyMDcxMTM0MjE1fQ.6UcH_jKukkgqaRRT1EvChS9lqwlqmXV2i5bgmxlqs4M
SUPABASE_ACCESS_TOKEN=sbp_2516261a0bb974c4d4d6a32c1a3bd725efa815e4
SUPABASE_PROJECT_REF=woevhievwvqeritksxzl
SUPABASE_PROJECT_ID=coaching-resource-hub-dev
`;

const PROD_CONFIG = `# Production Database Configuration - Exclusive Use
# Development frontend connects directly to production database

VITE_SUPABASE_URL=https://hfmpacbmbyvnupzgorek.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmbXBhY2JtYnl2bnVwemdvcmVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQyMjQzMzMsImV4cCI6MjA2OTgwMDMzM30.mOe-d0dFRYXpolZcv3LMOfECjATY5nYqq_iR9gaXWIU
VITE_SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmbXBhY2JtYnl2bnVwemdvcmVrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDIyNDMzMywiZXhwIjoyMDY5ODAwMzMzfQ.qjUKU7fGuV-Cseso8v5i6Ps-0YNtd7C5PVLVxp0NIvE

# Backend/CLI Configuration for Production 
SUPABASE_URL=https://hfmpacbmbyvnupzgorek.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmbXBhY2JtYnl2bnVwemdvcmVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQyMjQzMzMsImV4cCI6MjA2OTgwMDMzM30.mOe-d0dFRYXpolZcv3LMOfECjATY5nYqq_iR9gaXWIU
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmbXBhY2JtYnl2bnVwemdvcmVrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDIyNDMzMywiZXhwIjoyMDY5ODAwMzMzfQ.qjUKU7fGuV-Cseso8v5i6Ps-0YNtd7C5PVLVxp0NIvE
SUPABASE_ACCESS_TOKEN=sbp_2516261a0bb974c4d4d6a32c1a3bd725efa815e4
SUPABASE_PROJECT_REF=hfmpacbmbyvnupzgorek
SUPABASE_PROJECT_ID=coaching-resource-hub
`;

function linkCliToProject(projectRef, password) {
  try {
    console.log(`🔗 Linking CLI to ${projectRef}...`);
    
    // Set access token
    process.env.SUPABASE_ACCESS_TOKEN = SUPABASE_ACCESS_TOKEN;
    
    // Unlink current project first
    try {
      execSync('npx supabase unlink', { stdio: 'pipe' });
      console.log('   ✓ Unlinked from previous project');
    } catch (unlinkError) {
      // Ignore unlink errors (might not be linked)
    }
    
    // Link to new project
    const linkCommand = `npx supabase link --project-ref ${projectRef} --password "${password}"`;
    execSync(linkCommand, { stdio: 'pipe', timeout: 30000 }); // 30 second timeout
    console.log(`   ✓ CLI linked to ${projectRef}`);
    
  } catch (error) {
    console.log(`   ⚠️  CLI linking failed: ${error.message.split('\n')[0]}`);
    
    if (error.message.includes('timeout') || error.message.includes('i/o timeout')) {
      console.log('   🔍 Database connection timeout - project may be sleeping or unreachable');
      console.log('   💡 This is common with free tier databases after inactivity');
      console.log(`   📝 Frontend .env.local updated to use ${projectRef}, but CLI linking failed`);
    } else if (error.message.includes('password authentication failed')) {
      console.log('   🔑 Password authentication failed - password may have changed');
    }
    
    console.log('   💡 You may need to manually link the CLI later:');
    console.log(`       npx supabase link --project-ref ${projectRef}`);
    console.log('   ⚠️  WARNING: CLI operations may target the wrong database until linked!');
  }
}

function showManualCliInstructions(projectRef, dbType) {
  console.log('🔗 Please manually link CLI to avoid security timeouts:');
  console.log('');
  console.log(`   export SUPABASE_ACCESS_TOKEN=${SUPABASE_ACCESS_TOKEN}`);
  console.log(`   npx supabase link --project-ref ${projectRef}`);
  console.log('');
  console.log(`   This ensures CLI operations target ${dbType} database`);
}

function switchDatabase(target) {
  if (target === 'dev' || target === 'development') {
    fs.writeFileSync(ENV_FILE, DEV_CONFIG);
    console.log('✅ Switched to DEVELOPMENT database connection');
    console.log('   Frontend: https://woevhievwvqeritksxzl.supabase.co');
    console.log('   Project: coaching-resource-hub-dev');
    console.log('   💡 Safe for testing and development work');
    console.log('');
    
    showManualCliInstructions('woevhievwvqeritksxzl', 'DEVELOPMENT');
    
  } else if (target === 'prod' || target === 'production') {
    fs.writeFileSync(ENV_FILE, PROD_CONFIG);
    console.log('✅ Switched to PRODUCTION database connection');
    console.log('   Frontend: https://hfmpacbmbyvnupzgorek.supabase.co');
    console.log('   Project: coaching-resource-hub');
    console.log('   ⚠️  CAUTION: You are now working with LIVE data!');
    console.log('');
    
    showManualCliInstructions('hfmpacbmbyvnupzgorek', 'PRODUCTION');
    
  } else {
    console.log('❌ Invalid target. Use "dev" or "prod"');
    console.log('');
    console.log('Usage:');
    console.log('  node scripts/development/utilities/switch-db-connection.cjs dev');
    console.log('  node scripts/development/utilities/switch-db-connection.cjs prod');
    console.log('');
    console.log('Available targets:');
    console.log('  dev, development  - Development database (safe for testing)');
    console.log('  prod, production  - Production database (live data!)');
    process.exit(1);
  }
  
  console.log('');
  console.log('🔄 Please restart your dev server for changes to take effect.');
}

const target = process.argv[2];
if (!target) {
  console.log('❌ No target specified');
  console.log('');
  console.log('Usage:');
  console.log('  node scripts/development/utilities/switch-db-connection.cjs dev');
  console.log('  node scripts/development/utilities/switch-db-connection.cjs prod');
  console.log('');
  console.log('Available targets:');
  console.log('  dev, development  - Development database (safe for testing)');
  console.log('  prod, production  - Production database (live data!)');
  process.exit(1);
}

switchDatabase(target);