#!/bin/bash

# ====================================================================
# DEVELOPMENT DATABASE RESTORATION SCRIPT
# ====================================================================
#
# This script completely resets your development database and restores
# it to match production with all fixes applied.
#
# USAGE: 
#   ./scripts/restore_dev_database.sh
#   
# OR on Windows:
#   bash scripts/restore_dev_database.sh
#
# ====================================================================

echo "🚀 Starting Development Database Restoration..."
echo "=================================================="

# Check if supabase CLI is available
if ! command -v npx supabase &> /dev/null; then
    echo "❌ Supabase CLI not found. Please install it first:"
    echo "   npm install -g supabase"
    exit 1
fi

echo "📋 Step 1: Checking Supabase project status..."
if ! npx supabase status > /dev/null 2>&1; then
    echo "⚠️  Supabase not running. Starting local instance..."
    npx supabase start
else
    echo "✅ Supabase is running"
fi

echo ""
echo "🗑️  Step 2: Resetting database (this will delete all existing data)..."
read -p "Are you sure you want to continue? This will delete ALL data in your dev database. (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Operation cancelled by user"
    exit 0
fi

echo "🔄 Resetting local database..."
npx supabase db reset --linked=false

if [ $? -ne 0 ]; then
    echo "❌ Database reset failed"
    exit 1
fi

echo "✅ Database reset complete"

echo ""
echo "📊 Step 3: Applying database migrations..."
npx supabase db push --include-all

if [ $? -ne 0 ]; then
    echo "❌ Database migrations failed"
    exit 1
fi

echo "✅ Migrations applied"

echo ""
echo "🏗️  Step 4: Restoring production data and fixes..."

# Check if the restoration SQL file exists
if [ ! -f "scripts/restore_dev_from_prod.sql" ]; then
    echo "❌ Restoration script not found at scripts/restore_dev_from_prod.sql"
    exit 1
fi

# Execute the restoration script
npx supabase sql exec --file scripts/restore_dev_from_prod.sql

if [ $? -ne 0 ]; then
    echo "❌ Database restoration failed"
    exit 1
fi

echo ""
echo "🎉 SUCCESS! Database restoration completed!"
echo "=================================================="
echo ""
echo "📋 What was restored:"
echo "   ✅ 9 assessments (Core/ICF/AC × Beginner/Intermediate/Advanced)"
echo "   ✅ 20 sample questions for Core Beginner assessment"
echo "   ✅ All database functions with bug fixes applied"
echo "   ✅ All triggers and RLS policies"
echo "   ✅ Performance indexes"
echo "   ✅ Fixed assessment status constraints"
echo "   ✅ Fixed scoring calculations"
echo ""
echo "🚀 Your development environment is ready!"
echo ""
echo "📝 Next steps:"
echo "   1. Start your dev server: npm run dev"
echo "   2. Create a test user account via signup"
echo "   3. Test the assessment functionality"
echo ""
echo "💡 Tip: Run this script anytime you need to restore dev to production state"